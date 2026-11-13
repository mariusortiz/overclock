"""Generates the arena scenes in scenes/arenas/ from the layouts below.

Run from the repo root: python3 tools/make_arena.py
Godot serializes Transform3D row by row: basis rows first, then the origin.

Every arena is a SIZE x SIZE m square with high walls. Each one has its own
layout, built from a few pieces (see Builder): platforms on posts, ramps,
bridges, solid blocks with a walkable roof, low cover walls, water and lava.
Everything that can be walked on is a box with a collision shape, so the
navigation mesh is baked from them; the 3D models (Kenney kits, CC0) dress
the place up. Ramps stay under 30 degrees and there are at least 2.2 m under
anything one can walk beneath, for the enemies' sake (agent 1.75 m high).

Each walkable level gets a "nav checkpoint" marker: the CI (scripts/nav_check.gd)
checks that enemies can walk to every one of them from the player's spawn.
The zone around the player's spawn, x in [-5, 5] and z in [10, 24], is kept
clear in every arena: the trailer stages its shots there.
"""
import json
import math
import struct

IDENTITY = (1, 0, 0, 0, 1, 0, 0, 0, 1)
STATION = "res://assets/models/station/"
NATURE = "res://assets/models/nature/"
CITY = "res://assets/models/city/"
ROADS = "res://assets/models/roads/"
CARS = "res://assets/models/cars/"
CHARACTERS = "res://assets/models/quaternius/characters/"

SIZE = 60
HALF = SIZE / 2
WALL_HEIGHT = 7.0
PLAYER_SPAWN = (0, 0.1, 18)
DEFAULT_SPAWNS = [(-25, 0.1, -25), (0, 0.1, -26), (25, 0.1, -25), (-26, 0.1, 0),
                  (26, 0.1, 0), (-25, 0.1, 25), (25, 0.1, 25)]
SLAB = 0.4      # thickness of platforms and bridges
RAIL = 1.0      # railing height
POST = 0.6      # post width


def rot_x(deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return (1, 0, 0, 0, c, -s, 0, s, c)


def rot_y(deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return (c, 0, s, 0, 1, 0, -s, 0, c)


def rot_z(deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return (c, -s, 0, s, c, 0, 0, 0, 1)


def transform(pos, basis=IDENTITY):
    return "Transform3D(%s)" % ", ".join(f"{v:.4g}" for v in tuple(basis) + tuple(pos))


def color(rgb):
    return "Color(%g, %g, %g, %g)" % (tuple(rgb) + ((1,) if len(rgb) == 3 else ()))


def glb_bounds(res_path):
    """Min and max corners of all meshes of a .glb file."""
    with open(res_path.replace("res://", ""), "rb") as f:
        f.read(12)
        length, _ = struct.unpack("<I4s", f.read(8))
        gltf = json.loads(f.read(length))
    lo, hi = [1e9] * 3, [-1e9] * 3
    for mesh in gltf["meshes"]:
        for primitive in mesh["primitives"]:
            accessor = gltf["accessors"][primitive["attributes"]["POSITION"]]
            lo = [min(a, b) for a, b in zip(lo, accessor["min"])]
            hi = [max(a, b) for a, b in zip(hi, accessor["max"])]
    return lo, hi


class Builder:
    """Collects the boxes, props and markers of one arena."""

    def __init__(self, materials):
        # materials: "struct" (platforms, bridges), "rail", "trim", "block" (solid masses)
        self.m = materials
        self.boxes = []        # (size, center, material, basis, collide)
        self.props = []        # dicts, see prop()
        self.checkpoints = []  # walkable levels to check
        self.loot = []         # ("pad" | "chest", (x, y, z))
        self.water = []        # (x, z, w, d)
        self.lava = []         # (x, z, w, d, height)
        self.footprints = []   # (x0, z0, x1, z1): no prop there

    def box(self, size, center, material, basis=IDENTITY, collide=True):
        self.boxes.append((tuple(size), tuple(center), material, basis, collide))

    def _footprint(self, x0, z0, x1, z1, margin=1.0):
        self.footprints.append((min(x0, x1) - margin, min(z0, z1) - margin, max(x0, x1) + margin, max(z0, z1) + margin))

    def rails(self, x0, z0, x1, z1, top, sides="nesw", gaps=()):
        """Railings around the rectangle x0..x1, z0..z1 at height `top`, on the
        given sides, leaving `gaps`: (side, from, to) along that side."""
        for side in sides:
            if side in "ns":
                z = z0 if side == "n" else z1
                spans = self._cut((x0, x1), [(a, b) for s, a, b in gaps if s == side])
                for a, b in spans:
                    self.box((b - a, RAIL, 0.12), ((a + b) / 2, top + RAIL / 2, z), self.m["rail"])
            else:
                x = x0 if side == "w" else x1
                spans = self._cut((z0, z1), [(a, b) for s, a, b in gaps if s == side])
                for a, b in spans:
                    self.box((0.12, RAIL, b - a), (x, top + RAIL / 2, (a + b) / 2), self.m["rail"])

    @staticmethod
    def _cut(span, gaps):
        pieces = [span]
        for a, b in gaps:
            next_pieces = []
            for p0, p1 in pieces:
                if b <= p0 or a >= p1:
                    next_pieces.append((p0, p1))
                    continue
                if a > p0:
                    next_pieces.append((p0, a))
                if b < p1:
                    next_pieces.append((b, p1))
            pieces = next_pieces
        return [(a, b) for a, b in pieces if b - a > 0.3]

    def slab(self, x, z, w, d, top, sides="nesw", gaps=(), posts=True, base=0.0, check=True, material=None):
        """A platform `top` meters up, on posts from `base`."""
        material = material or self.m["struct"]
        self.box((w, SLAB, d), (x, top - SLAB / 2, z), material)
        if posts:
            height = top - SLAB - base
            for dx in (-w / 2 + POST / 2, w / 2 - POST / 2):
                for dz in (-d / 2 + POST / 2, d / 2 - POST / 2):
                    self.box((POST, height, POST), (x + dx, base + height / 2, z + dz), self.m["trim"])
        self.rails(x - w / 2, z - d / 2, x + w / 2, z + d / 2, top, sides, gaps)
        self._footprint(x - w / 2, z - d / 2, x + w / 2, z + d / 2)
        if check:
            self.checkpoints.append((x, top + 0.1, z))

    def block(self, x, z, w, d, top, material=None, roof_rails="", gaps=(), check=False):
        """A solid mass from the floor up to `top` (a building, a rock, a tier)."""
        self.box((w, top, d), (x, top / 2, z), material or self.m["block"])
        self.rails(x - w / 2, z - d / 2, x + w / 2, z + d / 2, top, roof_rails, gaps)
        self._footprint(x - w / 2, z - d / 2, x + w / 2, z + d / 2)
        if check:
            self.checkpoints.append((x, top + 0.1, z))

    def ramp(self, start, end, h0, h1, width, material=None, rails=True, steps=True):
        """A straight ramp from `start` (x, z) at height h0 to `end` at h1,
        along x or z. Drawn as stairs: thin steps over the walkable slope."""
        material = material or self.m["struct"]
        (xa, za), (xb, zb) = start, end
        along_x = abs(xb - xa) > abs(zb - za)
        run = abs(xb - xa) if along_x else abs(zb - za)
        rise = h1 - h0
        assert math.degrees(math.atan2(abs(rise), run)) <= 30.5, f"ramp too steep: {start} {end}"
        pitch = math.degrees(math.atan2(rise, run))
        length = math.hypot(run, rise) + 0.6
        center = ((xa + xb) / 2, (h0 + h1) / 2 - 0.15, (za + zb) / 2)
        if along_x:
            basis = rot_z(pitch if xb > xa else -pitch)
            size = (length, 0.3, width)
        else:
            basis = rot_x(-pitch if zb > za else pitch)
            size = (width, 0.3, length)
        self.box(size, center, material, basis)
        if steps:
            count = max(int(run / 0.45), 2)
            for i in range(count):
                t = (i + 0.5) / count
                x, z = xa + (xb - xa) * t, za + (zb - za) * t
                y = h0 + rise * t
                step = (0.08, 0.06, width) if along_x else (width, 0.06, 0.08)
                self.box(step, (x, y + 0.02, z), self.m["trim"], collide=False)
        if rails:
            for side in (-1, 1):
                offset = side * (width / 2 + 0.06)
                rail_center = (center[0], center[1] + 0.15 + RAIL / 2, center[2] + offset) if along_x \
                    else (center[0] + offset, center[1] + 0.15 + RAIL / 2, center[2])
                rail_size = (length - 0.6, RAIL, 0.1) if along_x else (0.1, RAIL, length - 0.6)
                self.box(rail_size, rail_center, self.m["rail"], basis)
        self._footprint(xa - width / 2, za - width / 2, xb + width / 2, zb + width / 2)

    def bridge(self, start, end, top, width, pillar_every=7.0, material=None):
        """A straight walkway at `top` meters, from `start` to `end` (x, z),
        with railings and pillars down to the floor."""
        material = material or self.m["struct"]
        (xa, za), (xb, zb) = start, end
        along_x = abs(xb - xa) > abs(zb - za)
        length = abs(xb - xa) if along_x else abs(zb - za)
        cx, cz = (xa + xb) / 2, (za + zb) / 2
        size = (length, SLAB, width) if along_x else (width, SLAB, length)
        self.box(size, (cx, top - SLAB / 2, cz), material)
        for side in (-1, 1):
            if along_x:
                self.box((length, RAIL, 0.12), (cx, top + RAIL / 2, cz + side * width / 2), self.m["rail"])
            else:
                self.box((0.12, RAIL, length), (cx + side * width / 2, top + RAIL / 2, cz), self.m["rail"])
        count = int(length // pillar_every)
        for i in range(1, count + 1):
            t = i / (count + 1)
            px, pz = xa + (xb - xa) * t, za + (zb - za) * t
            height = top - SLAB
            self.box((0.8, height, 0.8), (px, height / 2, pz), self.m["trim"])
        self.checkpoints.append((cx, top + 0.1, cz))
        self._footprint(cx - size[0] / 2, cz - size[2] / 2, cx + size[0] / 2, cz + size[2] / 2, 0.5)

    def arch_bridge(self, start, end, top, width, run):
        """A footbridge over something (water, lava): up a ramp, across, and
        down again, from `start` to `end` along one axis."""
        (xa, za), (xb, zb) = start, end
        along_x = abs(xb - xa) > abs(zb - za)
        sign = 1 if (xb > xa if along_x else zb > za) else -1

        def at(offset):
            return (xa + sign * offset, za) if along_x else (xa, za + sign * offset)
        total = abs(xb - xa) if along_x else abs(zb - za)
        self.ramp(at(0), at(run), 0, top, width)
        self.ramp(at(total), at(total - run), 0, top, width)
        deck_start, deck_end = at(run), at(total - run)
        self.bridge(deck_start, deck_end, top, width, pillar_every=99)

    def cover(self, x, z, w, d, height=1.2, material=None):
        """A low wall to hide behind."""
        self.box((w, height, d), (x, height / 2, z), material or self.m["block"])
        self._footprint(x - w / 2, z - d / 2, x + w / 2, z + d / 2, 0.5)

    def windows(self, x, z, w, d, top, rows, color_name="m_window"):
        """Lit window strips on the four faces of a block."""
        for row in range(rows):
            y = 1.6 + row * (top - 2.0) / max(rows, 1)
            if y > top - 0.6:
                break
            self.box((w + 0.04, 0.5, d * 0.7), (x, y, z), color_name, collide=False)
            self.box((w * 0.7, 0.5, d + 0.04), (x, y, z), color_name, collide=False)

    def prop(self, model, x, z, height=None, yaw=0, collision=1.0, y=0.0, width=None, check=True):
        """A 3D model resting at height `y`, scaled to `height` (or to `width`
        meters across). `collision` shrinks its box horizontally (trees: trunk
        only); 0 means none. Skipped if it lands on a structure."""
        if check and any(x0 < x < x1 and z0 < z < z1 for x0, z0, x1, z1 in self.footprints) and y == 0.0:
            return
        self.props.append({"model": model, "x": x, "y": y, "z": z, "height": height, "width": width,
                           "yaw": yaw, "collision": collision})


# --- Layouts -------------------------------------------------------------------

def station(b):
    """Space hangar: a two-storey control tower in the middle, joined to decks
    along the side walls by high catwalks with the floor free beneath; a raised
    loading dock; stacks of containers."""
    # Control tower: level 1 (3 m), level 2 (6 m) on top of it.
    b.slab(0, -6, 12, 10, 3.0, gaps=[("s", -4.4, -1.6), ("w", -7.6, -4.4), ("e", -7.6, -4.4)])
    b.ramp((-3, 6), (-3, -1), 0, 3.0, 2.6)
    b.slab(3.5, -6, 4, 6, 6.0, gaps=[("w", -7.4, -4.6)], base=3.0)
    b.ramp((-4.5, -6), (1.5, -6), 3.0, 6.0, 2.4)
    # Side decks and the catwalks to the tower.
    for side in (-1, 1):
        x = side * 26.5
        b.slab(x, -10, 7, 20, 3.0, sides="ns" + ("e" if side < 0 else "w"),
               gaps=[("e" if side < 0 else "w", -7.6, -4.4), ("s", x - 1.6, x + 1.6)])
        b.ramp((x, 7), (x, 0), 0, 3.0, 2.8)
        b.bridge((side * 23, -6), (side * 6, -6), 3.0, 3.0)
    # Loading dock.
    b.slab(15, 15, 8, 6, 1.2, gaps=[("s", 13.6, 16.4)], posts=False)
    b.box((8, 1.2 - SLAB, 6), (15, (1.2 - SLAB) / 2, 15), b.m["block"])
    b.ramp((15, 21), (15, 18), 0, 1.2, 2.6)
    b.loot += [("pad", (-26.5, 3.05, -16)), ("chest", (26.5, 3.0, -16)), ("chest", (3.5, 6.0, -6))]
    # Dressing: containers, machines, pipes.
    for x, z, model, height, yaw in [
        (-14, 12, "container-tall", 1.9, 0), (-12, 14, "container", 1.26, 90), (-16, 15, "container-wide", 1.47, 0),
        (12, -16, "container-tall", 1.9, 90), (15, -18, "container-wide", 1.47, 0), (-12, -20, "container-flat", 1.26, 0),
        (8, 6, "container-tall", 1.9, 0), (10, 4, "container", 1.26, 0), (-9, 4, "container-wide", 1.47, 90),
        (-18, -2, "computer-system", 1.26, 90), (18, -2, "computer-system", 1.26, 270), (-6, 14, "table-display", 0.95, 0),
        (6, -16, "container-flat-open", 1.26, 0), (-20, 18, "skip", 1.2, 0), (20, 22, "container-tall", 1.9, 90),
        (-7, -16, "container", 1.26, 0), (14, 9, "table-display-planet", 1.1, 0), (-14, -8, "container-tall", 1.9, 0),
    ]:
        b.prop(STATION + model + ".glb", x, z, height, yaw)
    for z in (-24, -12, 12, 24):
        for side in (-1, 1):
            b.prop(STATION + "pipe.glb", side * 29.4, z, 6.5, 0, 0)


def desert(b):
    """Ruins in the sand: a stepped temple in the middle, a rocky plateau to the
    west joined to it by a stone bridge, a ruined tower, broken walls and an
    oasis."""
    stone = b.m["block"]
    # Temple: three tiers, stairs on the south and north faces.
    b.block(0, -8, 16, 16, 2.0)
    b.ramp((0, 4), (0, 0), 0, 2.0, 3.2)
    b.ramp((0, -20), (0, -16), 0, 2.0, 3.2)
    b.block(0, -8, 8, 8, 4.0)
    b.ramp((0, 0), (0, -4), 2.0, 4.0, 2.6)
    b.block(0, -8, 4, 4, 5.0)
    b.ramp((0, -4), (0, -6), 4.0, 5.0, 2.0)
    # The parts of each tier left uncovered by the next.
    b.checkpoints += [(5.5, 2.1, -2.0), (3.0, 4.1, -11.0), (0.0, 5.1, -8.5)]
    # West plateau and the stone bridge to the temple's second tier.
    b.block(-25, 6, 10, 24, 4.0, material=b.m["rock"], roof_rails="e", gaps=[("e", 8.4, 11.6), ("e", -6.6, -3.4)], check=True)
    b.ramp((-13, 10), (-20, 10), 0, 4.0, 3.0)
    b.bridge((-20, -5), (-4, -5), 4.0, 3.0, pillar_every=6)
    # Ruined tower to the east.
    b.slab(20, 8, 7, 7, 3.0, gaps=[("s", 18.4, 21.6)], posts=False, material=stone)
    b.box((7, 3.0 - SLAB, 7), (20, (3.0 - SLAB) / 2, 8), stone)
    b.ramp((20, 18), (20, 11.5), 0, 3.0, 3.0)
    # Broken walls.
    for x, z, w, d, h in [(-10, 14, 6, 0.8, 1.4), (12, -2, 0.8, 6, 1.6), (-14, -20, 5, 0.8, 1.2), (14, 22, 6, 0.8, 1.2),
                          (24, -6, 0.8, 5, 1.4), (-6, 22, 4, 0.8, 1.0)]:
        b.cover(x, z, w, d, h)
    # Oasis.
    b.water.append((16, -20, 10, 8))
    b.loot += [("pad", (-25, 4.05, 0)), ("chest", (0, 5.0, -8)), ("chest", (20, 3.0, 8))]
    for x, z, model, height, yaw, coll in [
        (11, -15, "tree_palmDetailedTall", 6.0, 0, 0.2), (21, -15, "tree_palmBend", 5.0, 90, 0.2),
        (12, -25, "tree_palmTall", 6.5, 30, 0.2), (21, -25, "tree_palmDetailedShort", 4.0, 0, 0.2),
        (-8, 22, "tent_detailedOpen", 2.6, 180, 1.0), (8, 26, "tent_smallOpen", 2.0, 200, 1.0), (2, 26, "campfire_stones", 0.6, 0, 0),
        (-3, -26, "statue_obelisk", 5.0, 0, 0.7), (6, -2, "statue_column", 3.5, 0, 1.0), (-6, -2, "statue_columnDamaged", 3.0, 0, 1.0),
        (-12, 0, "cactus_tall", 2.6, 0, 0.5), (13, 14, "cactus_short", 1.5, 0, 0.6), (-17, 22, "cactus_tall", 2.6, 90, 0.5),
        (24, -14, "rock_largeD", 1.5, 0, 1.0), (-14, -12, "rock_tallI", 2.6, 0, 1.0), (10, 20, "pot_large", 1.0, 0, 1.0),
        (-10, -26, "rock_largeE", 1.4, 0, 1.0), (26, 26, "statue_ring", 2.0, 0, 1.0), (-22, 24, "rock_tallJ", 3.0, 0, 1.0),
        (8, -26, "stone_tallG", 2.4, 0, 1.0),
    ]:
        b.prop(NATURE + model + ".glb", x, z, height, yaw, coll)


def jungle(b):
    """Tree houses on stilts joined by rope bridges, a river crossed by a
    footbridge and stepping stones, overgrown temple ruins to the north."""
    wood = b.m["struct"]
    # River across the map.
    b.water.append((0, -8.5, SIZE, 5))
    # Tree houses and their hub.
    for side in (-1, 1):
        x = side * 18
        b.slab(x, 4, 7, 7, 3.2, gaps=[("e" if side < 0 else "w", 2.9, 5.1), ("s", x - 1.5, x + 1.5)])
        b.ramp((x, 15), (x, 7.5), 0, 3.2, 2.6)
        b.bridge((side * 14.5, 4), (side * 3, 4), 3.2, 2.0, pillar_every=6)
        # Roof of the tree house.
        b.box((7.6, 0.3, 7.6), (x, 6.6, 4), b.m["roof"], collide=False)
        for dx in (-3.4, 3.4):
            for dz in (-3.4, 3.4):
                b.box((0.3, 3.2, 0.3), (x + dx, 5.0, 4 + dz), b.m["trim"], collide=False)
    b.slab(0, 4, 6, 6, 3.2, gaps=[("w", 2.9, 5.1), ("e", 2.9, 5.1), ("n", -1.5, 1.5)])
    # The trees the houses are built around.
    b.prop(NATURE + "tree_detailed.glb", -18, 4, 9.0, 0, 0.12, check=False)
    b.prop(NATURE + "tree_fat.glb", 18, 4, 9.0, 40, 0.12, check=False)
    b.ramp((0, -5), (0, 1), 0, 3.2, 2.6)
    # Footbridge over the river, and stepping stones further east.
    b.arch_bridge((-12, -14), (-12, -3), 1.2, 2.4, 2.6)
    for i, x in enumerate((13, 14.5, 13.5, 15)):
        b.prop(NATURE + "stone_smallFlatA.glb", x, -11 + i * 1.6, 0.35, i * 40, 0)
    # Ruins of a temple to the north.
    b.block(0, -22, 12, 8, 2.5, material=b.m["ruin"], check=True)
    b.ramp((0, -12.5), (0, -18), 0, 2.5, 3.0)
    b.cover(-11, -20, 0.8, 6, 1.6, b.m["ruin"])
    b.cover(11, -22, 0.8, 5, 1.4, b.m["ruin"])
    b.loot += [("pad", (-18, 3.25, 6)), ("chest", (18, 3.2, 4)), ("chest", (0, 2.5, -22))]
    for x, z, model, height, yaw, coll in [
        (-8, 12, "tree_default", 6.5, 0, 0.2), (9, 14, "tree_oak", 5.5, 60, 0.25), (-24, -16, "tree_tall", 7.0, 0, 0.2),
        (24, -18, "tree_default_dark", 6.5, 0, 0.2), (-26, 20, "tree_palmTall", 6.5, 0, 0.2), (26, 22, "tree_detailed_dark", 7.0, 0, 0.2),
        (-6, -26, "tree_oak_dark", 5.5, 0, 0.25), (8, -26, "tree_tall_dark", 7.0, 0, 0.2), (-20, -26, "tree_fat_darkh", 6.0, 0, 0.2),
        (22, 12, "tree_simple", 5.0, 0, 0.2), (-22, 10, "tree_default", 6.0, 0, 0.2),
        (6, -16, "log_large", 1.2, 80, 1.0), (-4, 16, "stump_roundDetailed", 0.8, 0, 1.0), (-16, 18, "mushroom_redGroup", 0.8, 0, 0),
        (16, 18, "mushroom_tanGroup", 0.8, 0, 0), (-26, -4, "plant_bushLarge", 1.0, 0, 0), (26, -2, "plant_bushDetailed", 1.0, 0, 0),
        (4, 22, "plant_bushLarge", 0.9, 0, 0), (-12, -24, "statue_head", 2.6, 20, 1.0), (12, -18, "statue_block", 1.6, 0, 1.0),
        (20, -8.5, "canoe", 0.6, 90, 0), (-28, 26, "tent_detailedClosed", 2.4, 45, 1.0), (-4, -14, "flower_redA", 0.5, 0, 0),
        (6, 8, "flower_yellowB", 0.5, 0, 0), (-10, 6, "flower_purpleA", 0.5, 0, 0), (24, 26, "rock_largeF", 1.5, 0, 1.0),
    ]:
        b.prop(NATURE + model + ".glb", x, z, height, yaw, coll)


def volcano(b):
    """A river of lava cuts the arena in two, crossed by two stone bridges;
    basalt plateaus at two heights; a crater with a lava pool."""
    rock = b.m["block"]
    b.lava.append((0, -6, SIZE, 6, 0.5))
    for x in (-14, 14):
        b.arch_bridge((x, -13), (x, 1), 1.8, 3.2, 3.4)
    # Plateaus.
    b.block(-24, -24, 12, 12, 3.0, roof_rails="es", gaps=[("e", -25.6, -22.4)], check=True)
    b.ramp((-11, -24), (-18, -24), 0, 3.0, 3.0)
    b.block(24, 17, 12, 10, 4.5, roof_rails="ws", gaps=[("s", 25.6, 28.4)], check=True)
    b.block(24, 4, 12, 12, 2.2, roof_rails="w", gaps=[("w", 2.4, 5.6)], check=True)
    b.ramp((10, 4), (18, 4), 0, 2.2, 3.0)
    b.ramp((27, 6), (27, 12), 2.2, 4.5, 2.8)
    # Crater: a ring of low rock walls around a lava pool, two ways in.
    cx, cz, r = 21, -22, 5
    for i in range(10):
        angle = math.tau * i / 10
        if i in (2, 7):
            continue
        x, z = cx + math.cos(angle) * r, cz + math.sin(angle) * r
        b.box((3.8, 1.6, 1.0), (x, 0.8, z), rock, rot_y(-math.degrees(angle) - 90))
    b.lava.append((cx, cz, 3, 3, 0.08))
    b.loot += [("pad", (-24, 3.05, -24)), ("chest", (24, 4.5, 18)), ("chest", (24, 2.2, 4))]
    for x, z, model, height, yaw in [
        (-6, 10, "rock_tallE", 2.8, 0), (8, 14, "rock_tallF", 3.0, 40), (-14, 14, "rock_tallG", 2.6, 0), (-24, 12, "rock_tallH", 3.2, 90),
        (-2, -20, "rock_tallA", 2.8, 30), (-20, -10, "rock_tallB", 2.6, 0), (6, -14, "stone_tallC", 2.0, 0), (-8, -24, "stone_tallA", 2.0, 90),
        (-4, 4, "statue_columnDamaged", 3.0, 0), (6, 4, "statue_columnDamaged", 3.0, 90), (-26, 2, "rock_largeD", 1.6, 0),
        (12, 24, "rock_largeE", 1.4, 0), (-12, 24, "campfire_stones", 0.6, 0), (2, -26, "rock_tallJ", 3.0, 0),
    ]:
        b.prop(NATURE + model + ".glb", x, z, height, yaw)


def city(b):
    """A crossroads under a highway overpass, buildings with rooftops reached
    by outside stairs, parked cars, street lights."""
    concrete = b.m["struct"]
    # Roads: an east-west and a north-south road, crossing in the middle.
    for i in range(-5, 6):
        tile = "road-crossroad-line" if i == 0 else "road-straight"
        b.prop(ROADS + tile + ".glb", i * 6, 0, width=6, yaw=90, collision=0, y=0.01, check=False)
        if i != 0:
            b.prop(ROADS + "road-straight.glb", 0, i * 6, width=6, yaw=0, collision=0, y=0.01, check=False)
    # Overpass over the north-south road, ramps at both ends.
    b.bridge((-16, -14), (16, -14), 4.0, 6.0, pillar_every=7)
    b.ramp((-25, -14), (-16, -14), 0, 4.0, 6.0)
    b.ramp((25, -14), (16, -14), 0, 4.0, 6.0)
    # Buildings with a walkable roof, stairs on the outside.
    for side in (-1, 1):
        x = side * 18
        b.block(x, 14, 10, 8, 5.0, roof_rails="nesw", gaps=[("s", x - 1.6, x + 1.6)], check=True)
        b.windows(x, 14, 10, 8, 5.0, 2)
        b.ramp((x, 27.5), (x, 18), 0, 5.0, 2.8)
    # Tall buildings to the north (no access).
    for x, model, height, yaw in [(-21, "building-skyscraper-a", 16, 0), (21, "building-skyscraper-c", 14, 180)]:
        b.block(x, -25, 9, 9, height, material=b.m["building"])
        b.prop(CITY + model + ".glb", x, -25, height, yaw, 0, check=False)
    b.prop(CITY + "building-h.glb", -21, 4, 6.5, 90, 1.0)
    b.prop(CITY + "building-d.glb", 21, 4, 7.0, 270, 1.0)
    b.loot += [("pad", (-18, 5.05, 12)), ("chest", (18, 5.0, 12)), ("chest", (0, 4.0, -14))]
    # Street furniture and parked cars.
    for x, z, model, yaw in [(-10, 4.8, "sedan", 90), (9, -4.8, "taxi", 270), (-4.8, -8, "police", 0), (4.8, 10, "van", 180),
                             (-22, -4.6, "suv", 90), (23, 4.6, "hatchback-sports", 270), (12, 22, "truck", 0), (-12, -24, "delivery", 90)]:
        b.prop(CARS + model + ".glb", x, z, width=2.2, yaw=yaw)
    for x, z, model, height, yaw in [
        (-4.4, -4.4, "traffic-light", 4.5, 45), (4.4, 4.4, "traffic-light", 4.5, 225),
        (-10, -3.6, "light-curved", 5.0, 0), (10, 3.6, "light-curved", 5.0, 180), (-3.6, 14, "light-curved", 5.0, 90),
        (3.6, -20, "light-curved", 5.0, 270), (-26, 8, "dumpster", 1.4, 90), (26, -8, "dumpster", 1.4, 270),
        (6, -9, "construction-barrier", 1.0, 0), (-6, 9, "construction-cone", 0.7, 0), (-7, 10, "construction-cone", 0.7, 0),
        (8, 26, "road-sign-stop", 2.4, 0), (-26, -20, "electricity-pole", 7.0, 0),
    ]:
        b.prop(ROADS + model + ".glb", x, z, height, yaw)


def matrix(b):
    """Inside the code: a raised core in the middle, reached by a ramp and by
    two data bridges from side platforms; towers of falling code; low
    firewalls to hide behind. Blocks glitch in the air above (scripts/matrix_fx.gd)."""
    code = b.m["block"]
    # The core.
    b.block(0, 0, 10, 10, 3.0, material=code, roof_rails="nesw",
            gaps=[("n", -1.6, 1.6), ("e", -1.6, 1.6), ("w", -1.6, 1.6)], check=True)
    b.ramp((0, -14), (0, -5), 0, 3.0, 3.0)
    # The side platforms, a bridge to the core each, a ramp down.
    for side in (-1, 1):
        x = side * 20
        b.slab(x, 0, 8, 8, 3.0, gaps=[("w" if side > 0 else "e", -1.6, 1.6), ("s", x - 1.6, x + 1.6)])
        b.bridge((side * 5, 0), (side * 16, 0), 3.0, 3.0, pillar_every=6)
        b.ramp((x, 12), (x, 4), 0, 3.0, 3.0)
    # Towers of code (no way up).
    for x, z, w, top in [(-22, -22, 7, 9.0), (22, -22, 7, 11.0), (-24, 20, 6, 7.5), (24, 22, 6, 9.5), (0, -26, 5, 6.0)]:
        b.block(x, z, w, w, top, material=code)
    # Firewalls.
    for x, z, w, d in [(-10, -14, 4, 0.8), (10, -14, 4, 0.8), (-12, 12, 0.8, 4), (12, 12, 0.8, 4),
                       (-26, -8, 0.8, 5), (26, -10, 0.8, 5), (-6, 26, 5, 0.8)]:
        b.cover(x, z, w, d, 1.3, material=b.m["firewall"])
    b.loot += [("pad", (0, 3.05, 0)), ("chest", (-20, 3.0, -2)), ("chest", (20, 3.0, -2))]


def pine(b, x, z, height, collide=True):
    """A fir tree: a trunk and three tiers of needles, snow on top."""
    b.box((0.5, height * 0.3, 0.5), (x, height * 0.15, z), b.m["trunk"], collide=collide)
    for i in range(3):
        width = height * 0.55 * (1 - i * 0.28)
        tier = height * 0.3
        y = height * 0.25 + i * height * 0.22 + tier / 2
        b.box((width, tier, width), (x, y, z), b.m["pine"], rot_y(45 + i * 20), collide=False)
        b.box((width * 0.55, tier * 0.18, width * 0.55), (x, y + tier / 2, z), b.m["snowcap"], rot_y(45 + i * 20), collide=False)


def snow(b):
    """The Christmas village: a frozen lake, chalets with roofs reached by
    outside stairs, an ice bridge over the north side, fir trees and the big
    tree of the village square (lights in scripts/snow_fx.gd)."""
    b.box((16, 0.06, 12), (0, 0.03, -4), b.m["ice"], collide=False)
    for side in (-1, 1):
        x = side * 18
        b.block(x, 10, 9, 7, 4.0, roof_rails="nesw", gaps=[("s", x - 1.6, x + 1.6)], check=True)
        b.windows(x, 10, 9, 7, 4.0, 1)
        b.box((9.6, 0.5, 7.6), (x, 4.25, 10), b.m["snowcap"], collide=False)
        b.ramp((x, 23.5), (x, 13.5), 0, 4.0, 2.8)
    b.bridge((-14, -16), (14, -16), 3.0, 3.0, pillar_every=7, material=b.m["ice"])
    b.ramp((-25, -16), (-14, -16), 0, 3.0, 3.0)
    b.ramp((25, -16), (14, -16), 0, 3.0, 3.0)
    b.checkpoints.append((0, 3.1, -16))
    # The big tree, its star lit.
    pine(b, 0, -25, 11.0)
    b.box((0.9, 0.9, 0.9), (0, 11.4, -25), "m_window", rot_y(45), collide=False)
    for x, z, h in [(-26, -26, 6), (-22, 2, 5), (25, -2, 5.5), (26, -26, 6.5), (-10, 24, 4.5), (11, 25, 5),
                    (-27, 14, 5), (27, 26, 4.5), (-8, -26, 5), (8, -27, 5.5)]:
        pine(b, x, z, h)
    # Snow walls to hide behind.
    for x, z, w, d in [(-10, -6, 0.9, 4), (10, -6, 0.9, 4), (-6, 6, 4, 0.9), (6, 6, 4, 0.9), (-24, -8, 4, 0.9), (24, -9, 4, 0.9)]:
        b.cover(x, z, w, d, 1.3, material=b.m["snowcap"])
    b.loot += [("pad", (-18, 4.05, 9)), ("chest", (18, 4.0, 9)), ("chest", (0, 3.0, -16))]
    for x, z, model, height, yaw in [
        (-14, 14, "log_stackLarge", 1.2, 0), (14, -6, "tent_detailedOpen", 2.4, 200), (-15, -5, "tent_detailedClosed", 2.4, 20),
        (4, 14, "campfire_stones", 0.6, 0), (-26, 22, "rock_largeD", 1.4, 0), (22, 18, "stump_roundDetailed", 0.6, 0),
    ]:
        b.prop(NATURE + model + ".glb", x, z, height, yaw)


def crystal_cluster(b, x, z, height, yaw=0, cover=True):
    """A cluster of glowing crystals leaning out of the ground; its base is a
    low rock to hide behind (the points themselves don't collide)."""
    for i, (dx, dz, scale, lean) in enumerate([(0, 0, 1.0, 0), (0.7, 0.3, 0.7, 18), (-0.6, 0.4, 0.6, -20), (0.2, -0.6, 0.55, 14)]):
        h = height * scale
        w = max(0.35, h * 0.22)
        basis = rot_y(yaw + i * 37)
        tilt = rot_z(lean) if i % 2 else rot_x(lean)
        # rotate: yaw first, then the lean
        m = [sum(basis[r * 3 + k] * tilt[k * 3 + c] for k in range(3)) for r in range(3) for c in range(3)]
        b.box((w, h, w), (x + dx, h / 2 - 0.1, z + dz), b.m["crystal" if i % 3 else "crystal_pink"], tuple(m), collide=False)
    if cover:
        b.cover(x, z, 2.2, 2.2, 1.0, material=b.m["rock"])


def crystal(b):
    """The crystal planet: a raised mesa in the middle, two rock plateaus
    joined to it by stone bridges, glowing crystal clusters all over (they sing
    in season 3), a luminous pool. Sparks drift in the air (scripts/crystal_fx.gd)."""
    rock = b.m["rock"]
    # The mesa, reached from the north and by the two bridges.
    b.block(0, -2, 10, 10, 3.5, material=rock, roof_rails="nesw",
            gaps=[("n", -1.6, 1.6), ("e", -3.6, -0.4), ("w", -3.6, -0.4)], check=True)
    b.ramp((0, -16), (0, -7), 0, 3.5, 3.2, material=rock)
    for side in (-1, 1):
        x = side * 20
        b.block(x, -6, 9, 9, 3.5, material=rock, roof_rails="nesw",
                gaps=[("w" if side > 0 else "e", -3.6, -0.4), ("s", x - 1.6, x + 1.6)], check=True)
        b.bridge((side * 5, -2), (side * 15.5, -2), 3.5, 3.0, pillar_every=99, material=rock)
        b.ramp((x, 8), (x, -1.5), 0, 3.5, 3.0, material=rock)
    # The glowing pool.
    b.water.append((-14, 14, 7, 5))
    # Crystal clusters: tall ones near the walls, small ones to hide behind.
    for x, z, h, yaw in [(-26, -26, 9.5, 10), (25, -25, 11.0, 40), (-27, 2, 7.0, 70), (27, 4, 8.0, 20), (-25, 25, 7.5, 0),
                         (26, 26, 9.0, 55), (0, -27, 12.0, 30), (12, -20, 4.5, 15), (-12, -21, 4.0, 80), (-27, -14, 5.5, 25),
                         (27, -14, 6.0, 65), (-14, 26, 5.0, 35), (14, 27, 6.5, 5)]:
        crystal_cluster(b, x, z, h, yaw)
    # Giant spires beyond the walls, on the horizon.
    for x, z, h, yaw in [(-40, -38, 26, 0), (-12, -44, 34, 30), (18, -42, 28, 60), (42, -30, 22, 15), (44, 8, 18, 45),
                         (-44, 0, 20, 70), (-38, 30, 16, 20), (36, 38, 20, 50)]:
        crystal_cluster(b, x, z, h, yaw, cover=False)
    for x, z, h, yaw in [(-8, 8, 2.2, 0), (9, 7, 2.4, 45), (-20, 13, 2.0, 20), (19, 14, 2.6, 70), (-6, -12, 2.0, 10), (7, -12, 2.2, 60)]:
        crystal_cluster(b, x, z, h, yaw)
    # Crystals glowing on the mesa's roof (no collision).
    for x, z in [(-3.8, -5.8), (3.8, 1.8)]:
        crystal_cluster(b, x, z, 2.0, 30, cover=False)
    b.loot += [("pad", (0, 3.55, -2)), ("chest", (-20, 3.5, -8)), ("chest", (20, 3.5, -8))]
    for x, z, model, height, yaw in [(-18, 22, "rock_largeA", 1.6, 0), (16, 22, "rock_largeC", 1.4, 90), (24, -12, "rock_tallB", 3.0, 0),
                                      (-24, -12, "rock_tallD", 2.8, 40)]:
        b.prop(NATURE + model + ".glb", x, z, height, yaw)


def ruins(b):
    """The star ruins: what is left of a civilization that knew Le Créateur. A
    great portal arch to the north, two temple halls high up reached by a
    ramp each, an alley of columns to the portal, more columns (some broken,
    some fallen), glyphs glowing gold.
    Stone fragments float overhead (scripts/ruins_fx.gd)."""
    stone = b.m["block"]
    # The portal: two pillars and a lintel, glyphs down the pillars.
    for side in (-1, 1):
        b.block(side * 5, -26, 2.2, 2.2, 9.0, material=stone)
        b.box((0.3, 6.0, 2.3), (side * 5 - side * 1.12, 4.5, -26), b.m["glyph"], collide=False)
    b.box((12.2, 1.6, 2.6), (0, 9.8, -26), stone)
    # Two temple halls up high, a ramp each.
    for side in (-1, 1):
        x = side * 19
        b.slab(x, -12, 9, 9, 3.5, gaps=[("s", x - 1.6, x + 1.6)], material=stone)
        b.ramp((x, 6), (x, -7.5), 0, 3.5, 3.0)
    # An alley of columns leading to the portal, some of them broken.
    for z, top in [(-5, 6.0), (-11, 4.2), (-17, 6.0)]:
        for side in (-1, 1):
            height = top if side < 0 or z != -11 else 2.4
            b.block(side * 6, z, 1.4, 1.4, height, material=stone)
            b.box((1.8, 0.3, 1.8), (side * 6, height + 0.15, z), b.m["trim"])
    # Columns: whole, broken, and fallen ones to hide behind.
    for x, z, top in [(-10, 6, 6.0), (10, 6, 3.0), (-10, 16, 2.0), (10, 16, 6.0), (-24, 18, 5.0), (24, 18, 1.6),
                      (-26, -2, 6.0), (26, -2, 4.0)]:
        b.block(x, z, 1.4, 1.4, top, material=stone)
        b.box((1.8, 0.3, 1.8), (x, top + 0.15, z), b.m["trim"])
    for x, z, yaw in [(-16, 22, 20), (17, 24, -30), (-4, 26, 80), (14, -22, 60)]:
        b.box((5.0, 1.2, 1.2), (x, 0.6, z), stone, rot_y(yaw))
        b._footprint(x - 2.5, z - 2.5, x + 2.5, z + 2.5, 0.5)
    for x, z, w, d in [(-6, 9, 3.5, 1.0), (6, 9, 3.5, 1.0), (-22, 8, 1.0, 3.5), (22, 8, 1.0, 3.5), (-14, -24, 4, 1.0), (24, -24, 1.0, 4)]:
        b.cover(x, z, w, d, 1.3, material=stone)
    # Glyph stones glowing gold.
    for x, z in [(-17, 0), (17, 0), (9, -20)]:
        b.box((0.4, 2.4, 1.6), (x, 1.2, z), b.m["glyph"])
    b.loot += [("pad", (-19, 3.55, -12)), ("chest", (19, 3.5, -14))]
    for x, z, model, height, yaw in [(-26, -16, "rock_largeB", 1.6, 0), (26, -16, "rock_largeE", 1.5, 90), (-26, 26, "rock_tallA", 2.6, 0)]:
        b.prop(NATURE + model + ".glb", x, z, height, yaw)


LAYOUTS = {"station": station, "desert": desert, "jungle": jungle, "volcano": volcano, "matrix": matrix, "city": city, "snow": snow,
           "crystal": crystal, "ruins": ruins}

ARENAS = {
    "station": {
        "name": "STATION", "music": 0, "enemy": "BlueSoldier_Male.fbx", "enemy_weapon": "blaster",
        "sky_top": (0.03, 0.02, 0.12), "sky_horizon": (0.35, 0.08, 0.45), "ambient": (0.45, 0.42, 0.6), "ambient_energy": 0.5,
        "sun": (1, 1, 1), "sun_energy": 1.2, "floor": "grid", "wall": ("panel_dark", (1, 1, 1)),
        "materials": {"struct": ("panel_light", (0.85, 0.85, 0.95)), "block": ("panel_light", (0.7, 0.72, 0.85)),
                      "trim": ("panel_dark", (0.6, 0.6, 0.7)), "rail": "accent"},
        "spawns": [(-25, 0.1, -25), (0, 0.1, -26), (25, 0.1, -25), (-26, 0.1, 12), (26, 0.1, 12), (-20, 0.1, 25), (20, 0.1, 25)],
        "boss": (9, 0.1, 6),
    },
    "desert": {
        "name": "DÉSERT", "music": 3, "enemy": "Ninja_Sand.fbx", "enemy_weapon": "smg",
        "sky_top": (0.25, 0.5, 0.85), "sky_horizon": (0.95, 0.8, 0.6), "ambient": (0.9, 0.8, 0.65), "ambient_energy": 0.4,
        "sun": (1, 0.93, 0.8), "sun_energy": 0.9, "floor": "sand", "wall": ("sand", (0.8, 0.62, 0.4)),
        "materials": {"struct": ("sand", (0.85, 0.7, 0.5)), "block": ("sand", (0.9, 0.75, 0.55)),
                      "rock": ("basalt", (0.75, 0.55, 0.4)), "trim": ("sand", (0.7, 0.55, 0.38)), "rail": ("sand", (0.75, 0.6, 0.42))},
        "spawns": [(-25, 0.1, -25), (8, 0.1, -27), (25, 0.1, -25), (-12, 0.1, 25), (26, 0.1, 0), (-26, 0.1, 25), (25, 0.1, 25)],
        "boss": (12, 0.1, 6),
    },
    "jungle": {
        "name": "JUNGLE", "music": 4, "enemy": "Goblin_Male.fbx", "enemy_weapon": "knife",
        "sky_top": (0.2, 0.45, 0.5), "sky_horizon": (0.6, 0.8, 0.6), "ambient": (0.5, 0.7, 0.5), "ambient_energy": 0.45,
        "sun": (0.95, 1, 0.85), "sun_energy": 1.1, "floor": "grass", "wall": ("grass", (0.3, 0.42, 0.25)),
        "materials": {"struct": ("melee/wood", (1, 1, 1)), "trim": ("melee/wood", (0.7, 0.6, 0.5)), "rail": ("melee/wrap", (0.85, 0.75, 0.55)),
                      "roof": ("grass", (0.45, 0.6, 0.3)), "ruin": ("basalt", (0.6, 0.7, 0.55)), "block": ("basalt", (0.6, 0.7, 0.55))},
        "spawns": [(-25, 0.1, -25), (0, 0.1, -28), (25, 0.1, -25), (-26, 0.1, 3), (26, 0.1, 3), (-25, 0.1, 25), (25, 0.1, 25)],
        "boss": (8, 0.1, 14),
    },
    "volcano": {
        "name": "VOLCAN", "music": 5, "enemy": "Zombie_Male.fbx", "enemy_weapon": "",
        "sky_top": (0.08, 0.02, 0.02), "sky_horizon": (0.7, 0.2, 0.05), "ambient": (0.7, 0.35, 0.25), "ambient_energy": 0.6,
        "sun": (1, 0.6, 0.4), "sun_energy": 1.0, "floor": "basalt", "wall": ("basalt", (0.3, 0.22, 0.22)),
        "materials": {"struct": ("basalt", (0.45, 0.4, 0.4)), "block": ("basalt", (0.38, 0.32, 0.32)),
                      "trim": ("basalt", (0.3, 0.25, 0.25)), "rail": ("basalt", (0.25, 0.2, 0.2))},
        "spawns": [(-10, 0.1, -26), (0, 0.1, -26), (26, 0.1, -26), (-26, 0.1, 2), (8, 0.1, 24), (-25, 0.1, 25), (25, 0.1, 27)],
        "boss": (-6, 0.1, 8),
    },
    "matrix": {
        "name": "MATRICE", "music": 15, "enemy": "Ninja_Male.fbx", "enemy_weapon": "laser", "corrupted": True,
        "fx": "res://scripts/matrix_fx.gd",
        "sky_top": (0.0, 0.01, 0.005), "sky_horizon": (0.01, 0.1, 0.05), "ambient": (0.35, 0.6, 0.4), "ambient_energy": 0.5,
        "sun": (0.7, 1, 0.8), "sun_energy": 0.7, "floor": "code", "wall": "code",
        "materials": {"struct": "code", "block": "code", "trim": ("panel_dark", (0.2, 0.35, 0.25)), "rail": "glow",
                      "firewall": "firewall"},
        "spawns": [(-12, 0.1, -26), (12, 0.1, -26), (-6, 0.1, -20), (-27, 0.1, 6), (27, 0.1, 6), (-14, 0.1, 25), (14, 0.1, 26)],
        "boss": (10, 0.1, 8),
    },
    "city": {
        "name": "VILLE", "music": 6, "enemy": "Suit_Male.fbx", "enemy_weapon": "revolver_1",
        "sky_top": (0.05, 0.07, 0.2), "sky_horizon": (0.9, 0.45, 0.35), "ambient": (0.5, 0.5, 0.7), "ambient_energy": 0.6,
        "sun": (1, 0.75, 0.6), "sun_energy": 1.1, "floor": "asphalt", "wall": ("panel_light", (0.42, 0.42, 0.48)),
        "materials": {"struct": ("asphalt", (0.75, 0.75, 0.8)), "block": ("panel_light", (0.75, 0.72, 0.7)),
                      "building": ("panel_light", (0.6, 0.62, 0.7)), "trim": ("panel_dark", (0.6, 0.6, 0.65)),
                      "rail": ("panel_dark", (0.8, 0.8, 0.85))},
        "spawns": [(-8, 0.1, -27), (8, 0.1, -27), (-27, 0.1, -8), (27, 0.1, -8), (-27, 0.1, 25), (27, 0.1, 25), (-12, 0.1, 6)],
        "boss": (10, 0.1, 6),
    },
    # Only during the Christmas event (scripts/events.gd).
    "snow": {
        "name": "VILLAGE ENNEIGÉ", "music": 23, "enemy": "Elf.fbx", "enemy_weapon": "smg", "fx": "res://scripts/snow_fx.gd",
        "sky_top": (0.22, 0.32, 0.55), "sky_horizon": (0.6, 0.68, 0.82), "ambient": (0.55, 0.6, 0.75), "ambient_energy": 0.3,
        "sun": (1, 0.95, 0.88), "sun_energy": 0.6, "floor": "snow", "floor_tint": (0.46, 0.52, 0.64), "wall": ("snow", (0.5, 0.56, 0.68)),
        "materials": {"struct": ("melee/wood", (0.95, 0.85, 0.75)), "block": ("melee/wood", (0.75, 0.55, 0.42)),
                      "trim": ("melee/wood", (0.55, 0.4, 0.3)), "rail": ("melee/wood", (0.6, 0.45, 0.35)),
                      "ice": ("ice", (0.85, 0.95, 1.0)), "pine": ("grass", (0.2, 0.42, 0.28)), "trunk": ("melee/wood", (0.45, 0.32, 0.22)),
                      "snowcap": ("snow", (0.85, 0.9, 0.98))},
        "spawns": [(-12, 0.1, -27), (12, 0.1, -27), (-27, 0.1, -12), (27, 0.1, -12), (-27, 0.1, 6), (27, 0.1, 8), (-14, 0.1, 24)],
        "boss": (10, 0.1, 4),
    },
    # Season 3: the crystal planet (in the waves, the Gardien's arena) and the
    # star ruins (story, capture, fight).
    "crystal": {
        "name": "PLANÈTE DE CRISTAL", "music": 24, "enemy": "Knight_Male.fbx", "enemy_weapon": "rifle_3",
        "enemy_glow": (0.45, 0.8, 1.0, 0.35), "fx": "res://scripts/crystal_fx.gd",
        "sky_top": (0.04, 0.02, 0.14), "sky_horizon": (0.5, 0.3, 0.75), "ambient": (0.55, 0.5, 0.85), "ambient_energy": 0.5,
        "sun": (0.8, 0.85, 1), "sun_energy": 0.9, "floor": "basalt", "floor_tint": (0.5, 0.44, 0.7), "wall": ("basalt", (0.36, 0.3, 0.52)),
        "materials": {"struct": ("basalt", (0.55, 0.5, 0.75)), "block": ("basalt", (0.5, 0.45, 0.7)), "rock": ("basalt", (0.5, 0.45, 0.7)),
                      "trim": ("basalt", (0.38, 0.33, 0.55)), "rail": ("@crystal", (0.45, 0.85, 1.0)),
                      "crystal": ("@crystal", (0.45, 0.85, 1.0)), "crystal_pink": ("@crystal", (0.95, 0.45, 1.0))},
        "spawns": [(-12, 0.1, -26), (12, 0.1, -26), (-27, 0.1, -16), (27, 0.1, -16), (-27, 0.1, 18), (27, 0.1, 18), (8, 0.1, 26)],
        "boss": (13, 0.1, 3),
    },
    "ruins": {
        "name": "RUINES STELLAIRES", "music": 25, "enemy": "Pirate_Male.fbx", "enemy_weapon": "shotgun_2", "fx": "res://scripts/ruins_fx.gd",
        "sky_top": (0.01, 0.01, 0.05), "sky_horizon": (0.28, 0.16, 0.42), "ambient": (0.6, 0.55, 0.75), "ambient_energy": 0.55,
        "sun": (1, 0.9, 0.75), "sun_energy": 0.9, "floor": "sand", "floor_tint": (0.42, 0.45, 0.62), "wall": ("panel_dark", (0.5, 0.48, 0.62)),
        "materials": {"struct": ("panel_light", (0.72, 0.7, 0.8)), "block": ("panel_light", (0.64, 0.62, 0.74)),
                      "trim": ("panel_dark", (0.6, 0.58, 0.7)), "rail": ("panel_dark", (0.7, 0.68, 0.8)), "glyph": ("@glow", (1.0, 0.75, 0.3))},
        "spawns": [(-12, 0.1, -27), (12, 0.1, -27), (-27, 0.1, -20), (27, 0.1, -20), (-27, 0.1, 12), (27, 0.1, 12), (-10, 0.1, 26)],
        "boss": (0, 0.1, 5),
    },
}
ORDER = ["station", "desert", "jungle", "volcano", "matrix", "crystal", "city", "ruins", "snow"]


def sun_basis():
    """Yaw 30, pitch -50: light coming down at an angle."""
    def mul(a, b):
        return [sum(a[i * 3 + k] * b[k * 3 + j] for k in range(3)) for i in range(3) for j in range(3)]
    return mul(rot_y(30), rot_x(-50))


def build(arena_id, arena):
    ext, sub, nodes = [], [], []
    ext_ids = {}

    def ext_resource(kind, path):
        if path not in ext_ids:
            ext_ids[path] = f"ext_{len(ext_ids) + 1}"
            ext.append(f'[ext_resource type="{kind}" path="{path}" id="{ext_ids[path]}"]')
        return f'ExtResource("{ext_ids[path]}")'

    def textured(material_id, texture, tint, scale=0.5, extra=()):
        tex = ext_resource("Texture2D", f"res://assets/textures/{texture}.png")
        sub.extend([f'[sub_resource type="StandardMaterial3D" id="{material_id}"]', f"albedo_color = {color(tint)}",
                    f"albedo_texture = {tex}", "roughness = 0.8", f"uv1_scale = Vector3({scale}, {scale}, {scale})",
                    "uv1_triplanar = true", "uv1_world_triplanar = true", *extra, ""])

    script = ext_resource("Script", "res://scripts/arena.gd")

    # --- Sky, light, navigation
    sub += ['[sub_resource type="ProceduralSkyMaterial" id="sky_material"]',
            f'sky_top_color = {color(arena["sky_top"])}', f'sky_horizon_color = {color(arena["sky_horizon"])}',
            f'ground_bottom_color = {color(arena["sky_top"])}', f'ground_horizon_color = {color(arena["sky_horizon"])}', "",
            '[sub_resource type="Sky" id="sky"]', 'sky_material = SubResource("sky_material")', "",
            '[sub_resource type="Environment" id="environment"]', "background_mode = 2", 'sky = SubResource("sky")',
            "ambient_light_source = 2", f'ambient_light_color = {color(arena["ambient"])}',
            f'ambient_light_energy = {arena["ambient_energy"]}', "tonemap_mode = 2", "glow_enabled = true",
            "fog_enabled = true", f'fog_light_color = {color(arena["sky_horizon"])}', "fog_density = 0.006", "",
            '[sub_resource type="NavigationMesh" id="navigation_mesh"]', "geometry_parsed_geometry_type = 1",
            "agent_height = 1.75", "agent_radius = 0.5", "agent_max_slope = 32.0", ""]

    # --- Materials
    def code_material(material_id, cell=0.3):
        shader = ext_resource("Shader", "res://shaders/code_rain.gdshader")
        sub.extend([f'[sub_resource type="ShaderMaterial" id="{material_id}"]', f"shader = {shader}",
                    f"shader_parameter/cell = {cell}", ""])

    if arena["floor"] == "code":
        code_material("floor_material")
    elif arena["floor"] == "grid":
        shader = ext_resource("Shader", "res://shaders/grid.gdshader")
        floor_texture = ext_resource("Texture2D", "res://assets/textures/floor_tiles.png")
        sub += ['[sub_resource type="ShaderMaterial" id="floor_material"]', f"shader = {shader}",
                f"shader_parameter/floor_texture = {floor_texture}", ""]
    else:
        textured("floor_material", arena["floor"], arena.get("floor_tint", (1, 1, 1)), 0.25)
    if arena["wall"] == "code":
        code_material("wall_material", 0.45)
    else:
        textured("wall_material", arena["wall"][0], arena["wall"][1])
    names = {}
    for key, value in arena["materials"].items():
        if value == "code":
            code_material(f"m_{key}")
        elif value == "glow":
            # Railings like glass panes with a faint green glow.
            sub += [f'[sub_resource type="StandardMaterial3D" id="m_{key}"]', "transparency = 1",
                    "albedo_color = Color(0.2, 1, 0.45, 0.18)", "emission_enabled = true", "emission = Color(0.2, 1, 0.45, 1)",
                    "emission_energy_multiplier = 0.2", ""]
        elif value == "firewall":
            sub += [f'[sub_resource type="StandardMaterial3D" id="m_{key}"]', "transparency = 1",
                    "albedo_color = Color(1, 0.3, 0.2, 0.55)", "emission_enabled = true", "emission = Color(1, 0.25, 0.15, 1)",
                    "emission_energy_multiplier = 1.2", ""]
        elif isinstance(value, tuple) and value[0] == "@crystal":
            # Glowing crystal, half see-through.
            sub += [f'[sub_resource type="StandardMaterial3D" id="m_{key}"]', "transparency = 1",
                    f"albedo_color = Color({value[1][0]}, {value[1][1]}, {value[1][2]}, 0.7)", "metallic = 0.4", "roughness = 0.1",
                    "emission_enabled = true", f"emission = {color(value[1])}", "emission_energy_multiplier = 0.9", ""]
        elif isinstance(value, tuple) and value[0] == "@glow":
            sub += [f'[sub_resource type="StandardMaterial3D" id="m_{key}"]', f"albedo_color = {color(value[1])}",
                    "emission_enabled = true", f"emission = {color(value[1])}", "emission_energy_multiplier = 1.6", ""]
        elif value == "accent":
            stripes = ext_resource("Texture2D", "res://assets/textures/stripes_emission.png")
            panel = ext_resource("Texture2D", "res://assets/textures/panel_dark.png")
            sub += [f'[sub_resource type="StandardMaterial3D" id="m_{key}"]', "albedo_color = Color(0.75, 0.45, 0.85, 1)",
                    f"albedo_texture = {panel}", "emission_enabled = true", "emission = Color(1, 0.24, 0.95, 1)",
                    "emission_energy_multiplier = 1.5", "emission_operator = 1", f"emission_texture = {stripes}",
                    "uv1_scale = Vector3(0.5, 0.5, 0.5)", "uv1_triplanar = true", "uv1_world_triplanar = true", ""]
        else:
            textured(f"m_{key}", value[0], value[1])
        names[key] = f"m_{key}"
    sub += ['[sub_resource type="StandardMaterial3D" id="m_window"]', "albedo_color = Color(1, 0.85, 0.55, 1)",
            "emission_enabled = true", "emission = Color(1, 0.8, 0.45, 1)", "emission_energy_multiplier = 1.2", "",
            '[sub_resource type="StandardMaterial3D" id="m_water"]', "transparency = 1", "albedo_color = Color(0.15, 0.5, 0.65, 0.75)",
            "metallic = 0.3", "roughness = 0.1", "",
            '[sub_resource type="StandardMaterial3D" id="m_lava"]', "albedo_color = Color(1, 0.35, 0.05, 1)",
            "emission_enabled = true", "emission = Color(1, 0.3, 0.05, 1)", "emission_energy_multiplier = 2.5", ""]
    names.update(window="m_window")

    builder = Builder(names)
    LAYOUTS[arena_id](builder)

    # --- Root, sky and sun
    nodes += ['[node name="Arena" type="NavigationRegion3D"]', 'navigation_mesh = SubResource("navigation_mesh")',
              f"script = {script}", f'display_name = "{arena["name"]}"',
              f'enemy_model = {ext_resource("PackedScene", CHARACTERS + arena["enemy"])}',
              f'enemy_weapon = "{arena["enemy_weapon"]}"', f'music_track = {arena["music"]}',
              *(["corrupted = true"] if arena.get("corrupted") else []),
              *([f'enemy_glow = Color({", ".join(str(v) for v in arena["enemy_glow"])})'] if arena.get("enemy_glow") else []), "",
              '[node name="WorldEnvironment" type="WorldEnvironment" parent="."]', 'environment = SubResource("environment")', "",
              '[node name="Sun" type="DirectionalLight3D" parent="."]', f"transform = {transform((0, 10, 0), sun_basis())}",
              f'light_color = {color(arena["sun"])}', f'light_energy = {arena["sun_energy"]}', "shadow_enabled = true", ""]

    # --- Boxes: floor, walls, then the layout's. One mesh and one shape per size.
    boxes = [((SIZE, 1, SIZE), (0, -0.5, 0), "floor_material", IDENTITY, True),
             ((SIZE, WALL_HEIGHT, 1), (0, WALL_HEIGHT / 2, -HALF - 0.5), "wall_material", IDENTITY, True),
             ((SIZE, WALL_HEIGHT, 1), (0, WALL_HEIGHT / 2, HALF + 0.5), "wall_material", IDENTITY, True),
             ((1, WALL_HEIGHT, SIZE + 2), (-HALF - 0.5, WALL_HEIGHT / 2, 0), "wall_material", IDENTITY, True),
             ((1, WALL_HEIGHT, SIZE + 2), (HALF + 0.5, WALL_HEIGHT / 2, 0), "wall_material", IDENTITY, True)]
    boxes += builder.boxes
    mesh_ids, shape_ids = {}, {}
    nodes += ['[node name="Structure" type="Node3D" parent="."]', ""]
    for i, (size, center, material, basis, collide) in enumerate(boxes, 1):
        key = (tuple(round(v, 3) for v in size), material)
        if key not in mesh_ids:
            mesh_ids[key] = f"box_mesh_{len(mesh_ids) + 1}"
            sub += [f'[sub_resource type="BoxMesh" id="{mesh_ids[key]}"]', "size = Vector3(%g, %g, %g)" % key[0],
                    f'material = SubResource("{material}")', ""]
        name = f"Box{i}"
        if collide:
            if key[0] not in shape_ids:
                shape_ids[key[0]] = f"box_shape_{len(shape_ids) + 1}"
                sub += [f'[sub_resource type="BoxShape3D" id="{shape_ids[key[0]]}"]', "size = Vector3(%g, %g, %g)" % key[0], ""]
            nodes += [f'[node name="{name}" type="StaticBody3D" parent="Structure"]', f"transform = {transform(center, basis)}", "",
                      f'[node name="Mesh" type="MeshInstance3D" parent="Structure/{name}"]', f'mesh = SubResource("{mesh_ids[key]}")', "",
                      f'[node name="Shape" type="CollisionShape3D" parent="Structure/{name}"]', f'shape = SubResource("{shape_ids[key[0]]}")', ""]
        else:
            nodes += [f'[node name="{name}" type="MeshInstance3D" parent="Structure"]', f"transform = {transform(center, basis)}",
                      f'mesh = SubResource("{mesh_ids[key]}")', ""]

    # --- Water (no collision: one wades through it)
    for i, (x, z, w, d) in enumerate(builder.water, 1):
        sub += [f'[sub_resource type="BoxMesh" id="water_mesh_{i}"]', f"size = Vector3({w}, 0.05, {d})", 'material = SubResource("m_water")', ""]
        nodes += [f'[node name="Water{i}" type="MeshInstance3D" parent="."]', f"transform = {transform((x, 0.04, z))}",
                  f'mesh = SubResource("water_mesh_{i}")', ""]

    # --- Lava: a raised hot surface that hurts. Enemies cannot step onto it, so they cross by the bridges.
    if builder.lava:
        hazard = ext_resource("Script", "res://scripts/hazard.gd")
        nodes += ['[node name="Lava" type="Node3D" parent="."]', ""]
        for i, (x, z, w, d, height) in enumerate(builder.lava, 1):
            sub += [f'[sub_resource type="BoxMesh" id="lava_mesh_{i}"]', f"size = Vector3({w}, {height}, {d})", 'material = SubResource("m_lava")', "",
                    f'[sub_resource type="BoxShape3D" id="lava_body_{i}"]', f"size = Vector3({w}, {height}, {d})", "",
                    f'[sub_resource type="BoxShape3D" id="lava_zone_{i}"]', f"size = Vector3({w}, 2.0, {d})", ""]
            nodes += [f'[node name="Body{i}" type="StaticBody3D" parent="Lava"]', f"transform = {transform((x, height / 2, z))}", "",
                      f'[node name="Mesh" type="MeshInstance3D" parent="Lava/Body{i}"]', f'mesh = SubResource("lava_mesh_{i}")', "",
                      f'[node name="Shape" type="CollisionShape3D" parent="Lava/Body{i}"]', f'shape = SubResource("lava_body_{i}")', "",
                      f'[node name="Zone{i}" type="Area3D" parent="Lava"]', f"transform = {transform((x, height + 0.9, z))}",
                      "collision_layer = 0", "collision_mask = 2", f"script = {hazard}", "",
                      f'[node name="Shape" type="CollisionShape3D" parent="Lava/Zone{i}"]', f'shape = SubResource("lava_zone_{i}")', ""]

    # --- Props, with a box collision computed from the model bounds
    nodes += ['[node name="Props" type="Node3D" parent="."]', ""]
    for i, item in enumerate(builder.props, 1):
        lo, hi = glb_bounds(item["model"])
        if item["width"]:
            scale = item["width"] / max(hi[0] - lo[0], hi[2] - lo[2])
        else:
            scale = item["height"] / (hi[1] - lo[1])
        name = f"Prop{i}"
        parent_type = "StaticBody3D" if item["collision"] > 0 else "Node3D"
        nodes += [f'[node name="{name}" type="{parent_type}" parent="Props"]',
                  f'transform = {transform((item["x"], item["y"] - lo[1] * scale, item["z"]), rot_y(item["yaw"]))}', "",
                  f'[node name="Model" parent="Props/{name}" instance={ext_resource("PackedScene", item["model"])}]',
                  f"transform = {transform((0, 0, 0), (scale, 0, 0, 0, scale, 0, 0, 0, scale))}", ""]
        if item["collision"] > 0:
            size = [(h - l) * scale for l, h in zip(lo, hi)]
            size[0] *= item["collision"]
            size[2] *= item["collision"]
            center = [(l + h) / 2 * scale for l, h in zip(lo, hi)]
            shape_id = f"prop_shape_{i}"
            sub += [f'[sub_resource type="BoxShape3D" id="{shape_id}"]', "size = Vector3(%.3f, %.3f, %.3f)" % tuple(size), ""]
            nodes += [f'[node name="CollisionShape3D" type="CollisionShape3D" parent="Props/{name}"]',
                      f"transform = {transform(center)}", f'shape = SubResource("{shape_id}")', ""]

    # --- Healing pads and chests upstairs
    pad_script = ext_resource("Script", "res://scripts/regen_pad.gd")
    chest_script = ext_resource("Script", "res://scripts/chest.gd")
    chest_model = ext_resource("PackedScene", "res://assets/models/melee/chest.glb")
    sub += ['[sub_resource type="CylinderMesh" id="pad_mesh"]', "top_radius = 1.5", "bottom_radius = 1.5", "height = 0.08",
            "radial_segments = 20", "rings = 1", "",
            '[sub_resource type="CylinderShape3D" id="pad_shape"]', "height = 2.0", "radius = 1.5", "",
            '[sub_resource type="BoxShape3D" id="chest_shape"]', "size = Vector3(2, 2, 2)", "",
            '[sub_resource type="StandardMaterial3D" id="chest_marker_material"]', "albedo_color = Color(1, 0.85, 0.2, 1)",
            "emission_enabled = true", "emission = Color(1, 0.8, 0.2, 1)", "emission_energy_multiplier = 2.0", "",
            '[sub_resource type="BoxMesh" id="chest_marker_mesh"]', 'material = SubResource("chest_marker_material")',
            "size = Vector3(0.3, 0.3, 0.3)", ""]
    nodes += ['[node name="Upstairs" type="Node3D" parent="."]', ""]
    for i, (kind, pos) in enumerate(builder.loot, 1):
        if kind == "pad":
            nodes += [f'[node name="Pad{i}" type="Area3D" parent="Upstairs"]', f"transform = {transform(pos)}",
                      "collision_layer = 0", "collision_mask = 2", f"script = {pad_script}", "",
                      f'[node name="Mesh" type="MeshInstance3D" parent="Upstairs/Pad{i}"]', 'mesh = SubResource("pad_mesh")', "",
                      f'[node name="CollisionShape3D" type="CollisionShape3D" parent="Upstairs/Pad{i}"]',
                      f"transform = {transform((0, 1.0, 0))}", 'shape = SubResource("pad_shape")', ""]
        else:
            nodes += [f'[node name="Chest{i}" type="Area3D" parent="Upstairs"]', f"transform = {transform(pos)}",
                      "collision_layer = 0", "collision_mask = 2", f"script = {chest_script}", "",
                      f'[node name="Model" parent="Upstairs/Chest{i}" instance={chest_model}]',
                      f"transform = {transform((0, 0, 0), (3, 0, 0, 0, 3, 0, 0, 0, 3))}", "",
                      f'[node name="Marker" type="MeshInstance3D" parent="Upstairs/Chest{i}"]',
                      f"transform = {transform((0, 1.8, 0))}", 'mesh = SubResource("chest_marker_mesh")', "",
                      f'[node name="CollisionShape3D" type="CollisionShape3D" parent="Upstairs/Chest{i}"]',
                      f"transform = {transform((0, 1.0, 0))}", 'shape = SubResource("chest_shape")', ""]

    # --- Moving decor (the arena's own script)
    if arena.get("fx"):
        nodes += ['[node name="Effects" type="Node3D" parent="."]', f'script = {ext_resource("Script", arena["fx"])}', ""]

    # --- Spawn points and checkpoints
    nodes += ['[node name="PlayerSpawn" type="Marker3D" parent="."]', f"transform = {transform(PLAYER_SPAWN)}", "",
              '[node name="BossSpawn" type="Marker3D" parent="."]', f'transform = {transform(arena["boss"])}', "",
              '[node name="EnemySpawns" type="Node3D" parent="."]', ""]
    for i, pos in enumerate(arena.get("spawns", DEFAULT_SPAWNS), 1):
        nodes += [f'[node name="Spawn{i}" type="Marker3D" parent="EnemySpawns" groups=["enemy_spawns"]]',
                  f"transform = {transform(pos)}", ""]
    nodes += ['[node name="NavCheckpoints" type="Node3D" parent="."]', ""]
    for i, pos in enumerate(builder.checkpoints, 1):
        nodes += [f'[node name="Level{i}" type="Marker3D" parent="NavCheckpoints"]', f"transform = {transform(pos)}", ""]

    header = f"[gd_scene load_steps={len(ext) + sub.count('') + 1} format=3]"
    with open(f"scenes/arenas/{arena_id}.tscn", "w") as f:
        f.write("\n".join([header, ""] + ext + [""] + sub + nodes))
    print(f"{arena_id}: {len(boxes)} boxes, {len(builder.props)} props, {len(builder.checkpoints)} levels")


for arena_id in ORDER:
    build(arena_id, ARENAS[arena_id])
