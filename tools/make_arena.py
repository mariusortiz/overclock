"""Generates the arena scenes in scenes/arenas/ from the ARENAS table below.

Run from the repo root: python3 tools/make_arena.py
Godot serializes Transform3D row by row: basis rows first, then the origin.
Every arena is a SIZE x SIZE m walled square. Layouts are written for a 40 m
arena and spread out by SPREAD; a second, inner ring of props is added
automatically. The player and enemy spawn points are kept clear.
"""
import json
import math
import struct

IDENTITY = (1, 0, 0, 0, 1, 0, 0, 0, 1)
STATION = "res://assets/models/station/"
NATURE = "res://assets/models/nature/"
CITY = "res://assets/models/city/"

SIZE = 60
SPREAD = SIZE / 40
CHARACTERS = "res://assets/models/quaternius/characters/"

ENEMY_SPAWNS = [
    (-25, 0.1, -25), (0, 0.1, -26), (25, 0.1, -25), (-26, 0.1, 0),
    (26, 0.1, 12), (-25, 0.1, 25), (25, 0.1, 25),
]
PLAYER_SPAWN = (0, 0.1, 18)

# Second floor: a deck along the west and east walls, DECK_TOP meters up, each
# reached by one ramp. (center x, ramp center z, ramp pitch in degrees)
DECK_TOP = 3.0
DECK_SIZE = (10, 0.4, 24)
DECKS = [(-24.5, 16.1, 20), (24.5, -16.1, -20)]
RAMP_SIZE = (3.2, 0.3, 8.9)


def prop(model, x, z, height, yaw=0, collision=1.0):
    """A model resting on the floor, scaled to `height` meters. `collision`
    shrinks the collision box horizontally (trees: trunk only); 0 means none."""
    return {"model": model, "x": x, "z": z, "height": height, "yaw": yaw, "collision": collision}


# Blocks: (name, size, position, material, basis)
def rot_x(deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return (1, 0, 0, 0, c, -s, 0, s, c)


ARENAS = {
    "station": {
        "name": "STATION", "music": 0, "enemy": "BlueSoldier_Male.fbx",
        "sky_top": (0.03, 0.02, 0.12), "sky_horizon": (0.35, 0.08, 0.45),
        "ambient": (0.45, 0.42, 0.6), "ambient_energy": 0.5,
        "sun": (1, 1, 1), "sun_energy": 1.2,
        "floor": "grid", "wall_color": (1, 1, 1),
        "blocks": [
            ("Pillar", (2, 5, 2), (0, 2.5, -6), "accent_material", IDENTITY),
            ("Platform", (4, 2, 4), (8, 1, 1.2), "block_material", IDENTITY),
            # Rises toward -Z, from the floor up to the top of Platform.
            ("Ramp", (2.4, 0.3, 6), (8, 0.9, 6), "accent_material", rot_x(20)),
            ("PlatformFar", (6, 1.5, 3), (10, 0.75, -12), "block_material", IDENTITY),
        ],
        "props": [
            prop(STATION + "container-tall.glb", -4, 4, 1.9), prop(STATION + "container-tall.glb", -12, 9, 1.9),
            prop(STATION + "container.glb", -10, 10.5, 1.26), prop(STATION + "container-tall.glb", 2, 2, 1.9),
            prop(STATION + "container-wide.glb", 4, 2, 1.47), prop(STATION + "container-tall.glb", -8, -3, 1.9),
            prop(STATION + "container-wide.glb", -8, -5, 1.47), prop(STATION + "container-flat.glb", -5, -12, 1.26, 90),
            prop(STATION + "container-flat.glb", 12, 10, 1.26), prop(STATION + "computer-system.glb", -2.5, -14, 1.26),
            prop(STATION + "table-display.glb", 13, -4, 0.95, 90), prop(STATION + "container-wide.glb", 4, -14, 1.47),
            prop(STATION + "container-wide.glb", 15, 3, 1.47), prop(STATION + "container-tall.glb", -15, -8, 1.9),
            prop(STATION + "container.glb", 5, 13, 1.26), prop(STATION + "container.glb", -14, 2, 1.26),
        ],
    },
    "desert": {
        "name": "DÉSERT", "music": 3, "enemy": "Ninja_Sand.fbx",
        "sky_top": (0.25, 0.5, 0.85), "sky_horizon": (0.95, 0.8, 0.6),
        "ambient": (0.9, 0.8, 0.65), "ambient_energy": 0.4,
        "sun": (1, 0.93, 0.8), "sun_energy": 0.9,
        "floor": "sand", "wall_color": (0.8, 0.62, 0.4),
        "props": [
            prop(NATURE + "statue_obelisk.glb", 0, -4, 5.0, 0, 0.7),
            prop(NATURE + "rock_tallA.glb", -6, 3, 2.4), prop(NATURE + "rock_tallB.glb", 6, -9, 2.6, 40),
            prop(NATURE + "rock_tallC.glb", -11, -8, 2.4, 90), prop(NATURE + "rock_tallD.glb", 10, 6, 2.8),
            prop(NATURE + "stone_tallA.glb", 4, 4, 2.0), prop(NATURE + "stone_tallB.glb", -4, -12, 2.0, 90),
            prop(NATURE + "rock_largeA.glb", -9, 10, 1.3), prop(NATURE + "rock_largeB.glb", 9, -2, 1.3),
            prop(NATURE + "cactus_tall.glb", -13, 3, 2.6, 0, 0.5), prop(NATURE + "cactus_tall.glb", 12, -13, 2.6, 90, 0.5),
            prop(NATURE + "cactus_short.glb", -3, 7, 1.5, 0, 0.6), prop(NATURE + "cactus_short.glb", 7, 11, 1.5, 0, 0.6),
            prop(NATURE + "tree_palmTall.glb", -14, -13, 5.0, 0, 0.2), prop(NATURE + "tree_palmTall.glb", 13, 13, 5.0, 90, 0.2),
            prop(NATURE + "statue_column.glb", -3, -9, 3.5), prop(NATURE + "statue_column.glb", 3, -9, 3.5),
        ],
    },
    "jungle": {
        "name": "JUNGLE", "music": 4, "enemy": "Goblin_Male.fbx",
        "sky_top": (0.2, 0.45, 0.5), "sky_horizon": (0.6, 0.8, 0.6),
        "ambient": (0.5, 0.7, 0.5), "ambient_energy": 0.45,
        "sun": (0.95, 1, 0.85), "sun_energy": 1.1,
        "floor": "grass", "wall_color": (0.3, 0.42, 0.25),
        "props": [
            prop(NATURE + "tree_default.glb", -6, 2, 6.0, 0, 0.2), prop(NATURE + "tree_default.glb", 5, -5, 6.5, 60, 0.2),
            prop(NATURE + "tree_default.glb", -11, -9, 6.0, 120, 0.2), prop(NATURE + "tree_default.glb", 11, 7, 7.0, 0, 0.2),
            prop(NATURE + "tree_default.glb", 0, -11, 6.0, 30, 0.2), prop(NATURE + "tree_default.glb", -13, 9, 6.5, 0, 0.2),
            prop(NATURE + "tree_default.glb", 13, -9, 6.0, 90, 0.2),
            prop(NATURE + "tree_oak.glb", -3, -5, 5.0, 0, 0.25), prop(NATURE + "tree_oak.glb", 7, 2, 5.0, 45, 0.25),
            prop(NATURE + "tree_oak.glb", -8, 12, 5.0, 0, 0.25),
            prop(NATURE + "tree_palmTall.glb", 3, 7, 6.0, 0, 0.2), prop(NATURE + "tree_palmTall.glb", -14, -3, 6.0, 0, 0.2),
            prop(NATURE + "rock_largeC.glb", -4, 8, 1.4), prop(NATURE + "rock_largeC.glb", 9, -12, 1.4, 90),
            prop(NATURE + "rock_largeA.glb", -9, -2, 1.4),
            prop(NATURE + "log_stackLarge.glb", 4, -1, 1.3), prop(NATURE + "log_stackLarge.glb", -5, -14, 1.3, 90),
            prop(NATURE + "statue_head.glb", 0, -3, 2.6),
            prop(NATURE + "plant_bushLarge.glb", 2, 3, 0.9, 0, 0), prop(NATURE + "plant_bushLarge.glb", -7, 6, 0.9, 0, 0),
            prop(NATURE + "plant_bushLarge.glb", 8, 10, 0.9, 0, 0), prop(NATURE + "plant_bushLarge.glb", -12, -12, 0.9, 0, 0),
            prop(NATURE + "plant_bushLarge.glb", 12, -3, 0.9, 0, 0),
        ],
    },
    "volcano": {
        "name": "VOLCAN", "music": 5, "enemy": "Zombie_Male.fbx",
        "sky_top": (0.08, 0.02, 0.02), "sky_horizon": (0.7, 0.2, 0.05),
        "ambient": (0.7, 0.35, 0.25), "ambient_energy": 0.6,
        "sun": (1, 0.6, 0.4), "sun_energy": 1.0,
        "floor": "basalt", "wall_color": (0.3, 0.22, 0.22),
        "props": [
            prop(NATURE + "rock_tallE.glb", -5, 3, 2.8), prop(NATURE + "rock_tallF.glb", 6, -4, 3.0, 40),
            prop(NATURE + "rock_tallG.glb", -10, -10, 2.6), prop(NATURE + "rock_tallH.glb", 11, 8, 3.2, 90),
            prop(NATURE + "rock_tallA.glb", 0, -9, 2.8, 30), prop(NATURE + "rock_tallB.glb", -12, 6, 2.6),
            prop(NATURE + "rock_tallC.glb", 12, -12, 2.8), prop(NATURE + "rock_tallD.glb", 5, 9, 2.6, 60),
            prop(NATURE + "stone_tallC.glb", -3, -3, 2.0), prop(NATURE + "stone_tallA.glb", 8, 3, 2.0, 90),
            prop(NATURE + "statue_columnDamaged.glb", -7, -5, 3.0), prop(NATURE + "statue_columnDamaged.glb", 7, -10, 3.0, 90),
        ],
        # Lava pools: (x, z, radius). They hurt the player.
        "lava": [(-2, 6, 2.2), (9, -8, 2.5), (-9, 0, 2.2), (3, -14, 2.0), (-13, -12, 2.0), (13, 2, 2.0)],
    },
    "city": {
        "name": "VILLE", "music": 6, "enemy": "Suit_Male.fbx",
        "sky_top": (0.05, 0.07, 0.2), "sky_horizon": (0.9, 0.45, 0.35),
        "ambient": (0.5, 0.5, 0.7), "ambient_energy": 0.6,
        "sun": (1, 0.75, 0.6), "sun_energy": 1.1,
        "floor": "asphalt", "wall_color": (0.42, 0.42, 0.48),
        "props": [
            prop(CITY + "building-a.glb", -9, -9, 7.0), prop(CITY + "building-d.glb", -9, 0, 8.0, 90),
            prop(CITY + "building-h.glb", -9, 9, 7.0, 180), prop(CITY + "building-f.glb", 9, -9, 9.0, 270),
            prop(CITY + "building-i.glb", 9, 0, 8.0, 90), prop(CITY + "building-l.glb", 9, 9, 10.0),
            prop(CITY + "building-c.glb", 0, -5, 4.5),
            prop(STATION + "container-flat.glb", -2, 5, 1.26, 90), prop(STATION + "container-flat.glb", 3, -12, 1.26),
            prop(STATION + "container-tall.glb", 2, 8, 1.9), prop(STATION + "container-wide.glb", -3, -13, 1.47),
            prop(STATION + "container.glb", 15, -4, 1.26), prop(STATION + "container.glb", -15, 5, 1.26),
        ],
    },
}
ORDER = ["station", "desert", "jungle", "volcano", "city"]


def transform(pos, basis=IDENTITY):
    return "Transform3D(%s)" % ", ".join(f"{v:.4g}" for v in tuple(basis) + tuple(pos))


def rot_y(deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return (c, 0, s, 0, 1, 0, -s, 0, c)


def color(rgb):
    return "Color(%g, %g, %g, 1)" % tuple(rgb)


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


def sun_basis():
    """Yaw 30, pitch -50: light coming down at an angle."""
    def mul(a, b):
        return [sum(a[i * 3 + k] * b[k * 3 + j] for k in range(3)) for i in range(3) for j in range(3)]
    return mul(rot_y(30), rot_x(-50))


def spread_props(arena):
    """The arena's props moved outward by SPREAD, plus two more rings of copies
    (turned around the center and brought closer) where there is room. Nothing
    is placed under the decks, on the ramps or on a spawn point."""
    keep_clear = [(PLAYER_SPAWN[0], PLAYER_SPAWN[2], 6.0)] + [(x, z, 5.0) for x, _, z in ENEMY_SPAWNS]
    keep_clear += [(pos[0], pos[2], max(size[0], size[2]) / 2 + 3.0) for _, size, pos, _, _ in arena.get("blocks", [])]
    keep_clear += [(x * SPREAD, z * SPREAD, r * 1.3 + 2.0) for x, z, r in arena.get("lava", [])]

    def blocked(x, z, placed):
        # Deck and ramp footprints, with a margin for wide props.
        for deck_x, ramp_z, _ in DECKS:
            if abs(x - deck_x) < DECK_SIZE[0] / 2 + 2 and abs(z) < DECK_SIZE[2] / 2 + 2:
                return True
            if abs(x - deck_x) < RAMP_SIZE[0] / 2 + 2 and abs(z - ramp_z) < RAMP_SIZE[2] / 2 + 2:
                return True
        if abs(x) > SIZE / 2 - 2 or abs(z) > SIZE / 2 - 2:
            return True
        if any(math.hypot(x - cx, z - cz) < radius for cx, cz, radius in keep_clear):
            return True
        return any(math.hypot(x - other["x"], z - other["z"]) < 4.0 for other in placed)

    placed = []
    base = [dict(item, x=item["x"] * SPREAD, z=item["z"] * SPREAD) for item in arena.get("props", [])]
    for item in base:
        if not blocked(item["x"], item["z"], placed):
            placed.append(item)
    for turn, factor in ((90, 0.55), (200, 0.8)):
        c, s = math.cos(math.radians(turn)), math.sin(math.radians(turn))
        for item in base:
            x = (item["x"] * c - item["z"] * s) * factor
            z = (item["x"] * s + item["z"] * c) * factor
            if not blocked(x, z, placed):
                placed.append(dict(item, x=x, z=z, yaw=item["yaw"] + turn))
    return placed


def build(arena_id, arena):
    ext, sub, nodes = [], [], []
    ext_ids = {}

    def ext_resource(kind, path):
        if path not in ext_ids:
            ext_ids[path] = f"ext_{len(ext_ids) + 1}"
            ext.append(f'[ext_resource type="{kind}" path="{path}" id="{ext_ids[path]}"]')
        return f'ExtResource("{ext_ids[path]}")'

    script = ext_resource("Script", "res://scripts/arena.gd")
    panel_dark = ext_resource("Texture2D", "res://assets/textures/panel_dark.png")

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
            "agent_height = 1.75", "agent_radius = 0.5", ""]

    # --- Materials
    if arena["floor"] == "grid":
        shader = ext_resource("Shader", "res://shaders/grid.gdshader")
        floor_texture = ext_resource("Texture2D", "res://assets/textures/floor_tiles.png")
        sub += ['[sub_resource type="ShaderMaterial" id="floor_material"]', f"shader = {shader}",
                f"shader_parameter/floor_texture = {floor_texture}", ""]
    else:
        floor_texture = ext_resource("Texture2D", f'res://assets/textures/{arena["floor"]}.png')
        sub += ['[sub_resource type="StandardMaterial3D" id="floor_material"]', f"albedo_texture = {floor_texture}",
                "roughness = 0.9", "uv1_scale = Vector3(0.25, 0.25, 0.25)", "uv1_triplanar = true", "uv1_world_triplanar = true", ""]
    sub += ['[sub_resource type="StandardMaterial3D" id="wall_material"]', f'albedo_color = {color(arena["wall_color"])}',
            f"albedo_texture = {panel_dark}", "roughness = 0.8", "uv1_scale = Vector3(0.5, 0.5, 0.5)",
            "uv1_triplanar = true", "uv1_world_triplanar = true", ""]
    if arena.get("blocks"):
        panel_light = ext_resource("Texture2D", "res://assets/textures/panel_light.png")
        stripes = ext_resource("Texture2D", "res://assets/textures/stripes_emission.png")
        sub += ['[sub_resource type="StandardMaterial3D" id="block_material"]', f"albedo_texture = {panel_light}",
                "roughness = 0.6", "uv1_scale = Vector3(0.5, 0.5, 0.5)", "uv1_triplanar = true", "uv1_world_triplanar = true", "",
                '[sub_resource type="StandardMaterial3D" id="accent_material"]', "albedo_color = Color(0.75, 0.45, 0.85, 1)",
                f"albedo_texture = {panel_dark}", "emission_enabled = true", "emission = Color(1, 0.24, 0.95, 1)",
                "emission_energy_multiplier = 1.5", "emission_operator = 1", f"emission_texture = {stripes}",
                "uv1_scale = Vector3(0.5, 0.5, 0.5)", "uv1_triplanar = true", "uv1_world_triplanar = true", ""]

    # --- Root, sky and sun
    nodes += ['[node name="Arena" type="NavigationRegion3D"]', 'navigation_mesh = SubResource("navigation_mesh")',
              f"script = {script}", f'display_name = "{arena["name"]}"',
              f'enemy_model = {ext_resource("PackedScene", CHARACTERS + arena["enemy"])}',
              f'music_track = {arena["music"]}', "",
              '[node name="WorldEnvironment" type="WorldEnvironment" parent="."]', 'environment = SubResource("environment")', "",
              '[node name="Sun" type="DirectionalLight3D" parent="."]', f"transform = {transform((0, 10, 0), sun_basis())}",
              f'light_color = {color(arena["sun"])}', f'light_energy = {arena["sun_energy"]}', "shadow_enabled = true", ""]

    # --- Floor, walls, blocks
    boxes = [
        ("Floor", (SIZE, 1, SIZE), (0, -0.5, 0), "floor_material", IDENTITY),
        ("WallNorth", (SIZE, 4, 1), (0, 2, -SIZE / 2 - 0.5), "wall_material", IDENTITY),
        ("WallSouth", (SIZE, 4, 1), (0, 2, SIZE / 2 + 0.5), "wall_material", IDENTITY),
        ("WallWest", (1, 4, SIZE + 2), (-SIZE / 2 - 0.5, 2, 0), "wall_material", IDENTITY),
        ("WallEast", (1, 4, SIZE + 2), (SIZE / 2 + 0.5, 2, 0), "wall_material", IDENTITY),
    ] + arena.get("blocks", [])
    # Second floor: decks on four posts, and their ramps.
    for i, (x, ramp_z, pitch) in enumerate(DECKS, 1):
        boxes.append((f"Deck{i}", DECK_SIZE, (x, DECK_TOP - DECK_SIZE[1] / 2, 0), "wall_material", IDENTITY))
        boxes.append((f"Ramp{i}", RAMP_SIZE, (x, DECK_TOP / 2, ramp_z), "wall_material", rot_x(pitch)))
        for j, (dx, dz) in enumerate(((-4.5, -11.5), (4.5, -11.5), (-4.5, 11.5), (4.5, 11.5)), 1):
            post = (0.6, DECK_TOP - DECK_SIZE[1], 0.6)
            boxes.append((f"Deck{i}Post{j}", post, (x + dx, post[1] / 2, dz), "wall_material", IDENTITY))
    for name, size, pos, material, basis in boxes:
        nodes += [f'[node name="{name}" type="CSGBox3D" parent="."]', f"transform = {transform(pos, basis)}",
                  "use_collision = true", "size = Vector3(%g, %g, %g)" % size, f'material = SubResource("{material}")', ""]

    # --- Props, with a box collision computed from the model bounds
    nodes += ['[node name="Props" type="Node3D" parent="."]', ""]
    for i, item in enumerate(spread_props(arena), 1):
        lo, hi = glb_bounds(item["model"])
        scale = item["height"] / (hi[1] - lo[1])
        name = f"Prop{i}"
        parent_type = "StaticBody3D" if item["collision"] > 0 else "Node3D"
        nodes += [f'[node name="{name}" type="{parent_type}" parent="Props"]',
                  f'transform = {transform((item["x"], -lo[1] * scale, item["z"]), rot_y(item["yaw"]))}', "",
                  f'[node name="Model" parent="Props/{name}" instance={ext_resource("PackedScene", item["model"])}]',
                  f"transform = {transform((0, 0, 0), (scale, 0, 0, 0, scale, 0, 0, 0, scale))}", ""]
        if item["collision"] > 0:
            size = [(h - l) * scale for l, h in zip(lo, hi)]
            size[0] *= item["collision"]
            size[2] *= item["collision"]
            center = [(l + h) / 2 * scale for l, h in zip(lo, hi)]
            shape_id = f"shape_{i}"
            sub += [f'[sub_resource type="BoxShape3D" id="{shape_id}"]', "size = Vector3(%.3f, %.3f, %.3f)" % tuple(size), ""]
            nodes += [f'[node name="CollisionShape3D" type="CollisionShape3D" parent="Props/{name}"]',
                      f"transform = {transform(center)}", f'shape = SubResource("{shape_id}")', ""]

    # --- Lava pools
    if arena.get("lava"):
        hazard = ext_resource("Script", "res://scripts/hazard.gd")
        sub += ['[sub_resource type="StandardMaterial3D" id="lava_material"]', "albedo_color = Color(1, 0.35, 0.05, 1)",
                "emission_enabled = true", "emission = Color(1, 0.3, 0.05, 1)", "emission_energy_multiplier = 2.5", ""]
        nodes += ['[node name="Lava" type="Node3D" parent="."]', ""]
        for i, (x, z, radius) in enumerate([(x * SPREAD, z * SPREAD, r * 1.3) for x, z, r in arena["lava"]], 1):
            sub += [f'[sub_resource type="CylinderMesh" id="lava_mesh_{i}"]', 'material = SubResource("lava_material")',
                    f"top_radius = {radius}", f"bottom_radius = {radius}", "height = 0.06", "radial_segments = 20", "rings = 1", "",
                    f'[sub_resource type="CylinderShape3D" id="lava_shape_{i}"]', "height = 1.0", f"radius = {radius}", ""]
            nodes += [f'[node name="Pool{i}" type="Area3D" parent="Lava"]', f"transform = {transform((x, 0.04, z))}",
                      "collision_layer = 0", "collision_mask = 2", f"script = {hazard}", "",
                      f'[node name="Mesh" type="MeshInstance3D" parent="Lava/Pool{i}"]', f'mesh = SubResource("lava_mesh_{i}")', "",
                      f'[node name="CollisionShape3D" type="CollisionShape3D" parent="Lava/Pool{i}"]',
                      f"transform = {transform((0, 0.5, 0))}", f'shape = SubResource("lava_shape_{i}")', ""]

    # --- Healing pads and chests on the decks
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
    for i, (x, ramp_z, _) in enumerate(DECKS, 1):
        # The pad sits at the far end from the ramp, the chest in the middle.
        pad_z = -8.0 if ramp_z > 0 else 8.0
        nodes += [f'[node name="Pad{i}" type="Area3D" parent="Upstairs"]', f"transform = {transform((x, DECK_TOP + 0.05, pad_z))}",
                  "collision_layer = 0", "collision_mask = 2", f"script = {pad_script}", "",
                  f'[node name="Mesh" type="MeshInstance3D" parent="Upstairs/Pad{i}"]', 'mesh = SubResource("pad_mesh")', "",
                  f'[node name="CollisionShape3D" type="CollisionShape3D" parent="Upstairs/Pad{i}"]',
                  f"transform = {transform((0, 1.0, 0))}", 'shape = SubResource("pad_shape")', "",
                  f'[node name="Chest{i}" type="Area3D" parent="Upstairs"]', f"transform = {transform((x, DECK_TOP, 0))}",
                  "collision_layer = 0", "collision_mask = 2", f"script = {chest_script}", "",
                  f'[node name="Model" parent="Upstairs/Chest{i}" instance={chest_model}]',
                  f"transform = {transform((0, 0, 0), (3, 0, 0, 0, 3, 0, 0, 0, 3))}", "",
                  f'[node name="Marker" type="MeshInstance3D" parent="Upstairs/Chest{i}"]',
                  f"transform = {transform((0, 1.8, 0))}", 'mesh = SubResource("chest_marker_mesh")', "",
                  f'[node name="CollisionShape3D" type="CollisionShape3D" parent="Upstairs/Chest{i}"]',
                  f"transform = {transform((0, 1.0, 0))}", 'shape = SubResource("chest_shape")', ""]

    # --- Spawn points
    nodes += ['[node name="PlayerSpawn" type="Marker3D" parent="."]', f"transform = {transform(PLAYER_SPAWN)}", "",
              '[node name="EnemySpawns" type="Node3D" parent="."]', ""]
    for i, pos in enumerate(ENEMY_SPAWNS, 1):
        nodes += [f'[node name="Spawn{i}" type="Marker3D" parent="EnemySpawns" groups=["enemy_spawns"]]',
                  f"transform = {transform(pos)}", ""]

    header = f"[gd_scene load_steps={len(ext) + sub.count('') + 1} format=3]"
    with open(f"scenes/arenas/{arena_id}.tscn", "w") as f:
        f.write("\n".join([header, ""] + ext + [""] + sub + nodes))


for arena_id in ORDER:
    build(arena_id, ARENAS[arena_id])
