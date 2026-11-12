"""Generates the melee weapons: models in assets/models/melee/ and their
material textures in assets/textures/melee/.

Run from the repo root: python3 tools/make_melee_models.py
Every weapon is an original shape drawn by code. They share one convention,
so the game needs no per-weapon tuning: the handle runs along +Y, the hand
holds it at the origin, the blade points up and its cutting edge faces +X.
Faces are grouped by material name (Blade, Edge, Wood, Grip, Wrap, Guard,
Brass, Accent); Loadout gives each name its look, and a skin repaints the
Blade and Accent parts. Faces are flat shaded and meant to be drawn two-sided.
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

MODEL_DIR = "assets/models/melee/"
TEXTURE_DIR = "assets/textures/melee/"
# Colors written to the .mtl files: only a fallback, the game sets the materials.
COLORS = {
    "Blade": (0.72, 0.74, 0.78), "Edge": (0.9, 0.92, 0.95), "Wood": (0.42, 0.27, 0.15),
    "Grip": (0.1, 0.1, 0.12), "Wrap": (0.12, 0.1, 0.14), "Guard": (0.2, 0.2, 0.23),
    "Brass": (0.78, 0.6, 0.25), "Accent": (0.75, 0.12, 0.12),
}


class Model:
    def __init__(self):
        self.faces = []  # (material, [points])

    def face(self, material, *points):
        self.faces.append((material, list(points)))

    def box(self, material, center, size):
        cx, cy, cz = center
        hx, hy, hz = size[0] / 2, size[1] / 2, size[2] / 2
        p = [(cx + sx * hx, cy + sy * hy, cz + sz * hz) for sx in (-1, 1) for sy in (-1, 1) for sz in (-1, 1)]
        for a, b, c, d in ((0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)):
            self.face(material, p[a], p[b], p[c], p[d])

    def tube(self, material, path, rx, rz, sides=8, closed=False):
        """A bar following `path` (points of the XY plane). Its section is an
        ellipse: `rx` wide in the plane, `rz` thick; both may be lists, one
        value per point of the path."""
        count = len(path)
        rxs = rx if isinstance(rx, list) else [rx] * count
        rzs = rz if isinstance(rz, list) else [rz] * count
        rings = []
        for i, (x, y) in enumerate(path):
            before = path[i - 1] if (i > 0 or closed) else path[i]
            after = path[(i + 1) % count] if (i < count - 1 or closed) else path[i]
            tx, ty = after[0] - before[0], after[1] - before[1]
            length = math.hypot(tx, ty)
            nx, ny = -ty / length, tx / length
            ring = []
            for s in range(sides):
                angle = math.tau * s / sides
                ring.append((x + nx * rxs[i] * math.cos(angle), y + ny * rxs[i] * math.cos(angle), rzs[i] * math.sin(angle)))
            rings.append(ring)
        for i in range(count if closed else count - 1):
            a, b = rings[i], rings[(i + 1) % count]
            for s in range(sides):
                t = (s + 1) % sides
                self.face(material, a[s], a[t], b[t], b[s])
        if not closed:
            self.face(material, *rings[0])
            self.face(material, *rings[-1])

    def blade(self, stations, thickness, ridge=0.55):
        """A single-edged blade. `stations` lists (spine point, edge point)
        pairs from the guard to the tip; the flat runs from the spine to the
        ridge, then a bevel falls to the edge."""
        h = thickness / 2
        rows = []
        for (sx, sy), (ex, ey) in stations:
            mx, my = sx + (ex - sx) * ridge, sy + (ey - sy) * ridge
            rows.append(((sx, sy, h), (sx, sy, -h), (mx, my, h), (mx, my, -h), (ex, ey, 0.0)))
        for a, b in zip(rows, rows[1:]):
            self.face("Blade", a[0], a[2], b[2], b[0])
            self.face("Blade", a[1], a[3], b[3], b[1])
            self.face("Edge", a[2], a[4], b[4], b[2])
            self.face("Edge", a[3], a[4], b[4], b[3])
            self.face("Blade", a[0], a[1], b[1], b[0])
        for row in (rows[0], rows[-1]):
            self.face("Blade", row[0], row[2], row[4], row[3], row[1])

    def dagger(self, stations, thickness):
        """A double-edged blade: `stations` lists (y, half width) from the
        guard to the tip. Its section is a diamond."""
        h = thickness / 2
        rows = [((-w, y, 0.0), (0.0, y, h), (w, y, 0.0), (0.0, y, -h)) for y, w in stations]
        for a, b in zip(rows, rows[1:]):
            for s in range(4):
                t = (s + 1) % 4
                self.face("Blade" if s in (0, 3) else "Edge", a[s], a[t], b[t], b[s])
        self.face("Blade", *rows[0])

    def save(self, name, scale):
        vertices, normals, groups = [], [], {}
        for material, points in self.faces:
            points = [points[i] for i in range(len(points)) if points[i] != points[i - 1]]
            if len(points) < 3:
                continue
            # Newell's method: the normal of a polygon, whatever its shape.
            nx = ny = nz = 0.0
            for (x1, y1, z1), (x2, y2, z2) in zip(points, points[1:] + points[:1]):
                nx += (y1 - y2) * (z1 + z2)
                ny += (z1 - z2) * (x1 + x2)
                nz += (x1 - x2) * (y1 + y2)
            length = math.sqrt(nx * nx + ny * ny + nz * nz)
            if length < 1e-12:
                continue
            normals.append((nx / length, ny / length, nz / length))
            first = len(vertices) + 1
            vertices += [(x * scale, y * scale, z * scale) for x, y, z in points]
            for i in range(1, len(points) - 1):
                groups.setdefault(material, []).append((first, first + i, first + i + 1, len(normals)))
        lines = ["# Generated by tools/make_melee_models.py", f"mtllib {name}.mtl", f"o {name}"]
        lines += ["v %.5f %.5f %.5f" % v for v in vertices]
        lines += ["vn %.4f %.4f %.4f" % n for n in normals]
        for material, triangles in groups.items():
            lines.append(f"usemtl {material}")
            lines += ["f %d//%d %d//%d %d//%d" % (a, n, b, n, c, n) for a, b, c, n in triangles]
        with open(MODEL_DIR + name + ".obj", "w") as out:
            out.write("\n".join(lines) + "\n")
        with open(MODEL_DIR + name + ".mtl", "w") as out:
            for material in groups:
                out.write("newmtl %s\nKd %.3f %.3f %.3f\n\n" % ((material,) + COLORS[material]))
        height = max(v[1] for v in vertices) - min(v[1] for v in vertices)
        print(f"{name}: {len(vertices)} vertices, {height:.2f} m")


def circle(center, radius, steps, start=0.0):
    return [(center[0] + radius * math.cos(start + math.tau * i / steps),
             center[1] + radius * math.sin(start + math.tau * i / steps)) for i in range(steps)]


# --- Weapons ------------------------------------------------------------------

def knife():
    m = Model()
    m.tube("Grip", [(0, -0.07), (0, -0.02), (0, 0.03), (0, 0.07)], [0.016, 0.019, 0.017, 0.016], 0.012)
    m.box("Guard", (0, -0.078, 0), (0.036, 0.016, 0.026))
    m.box("Guard", (0.004, 0.078, 0), (0.075, 0.014, 0.03))
    m.blade([((-0.02, 0.085), (0.022, 0.085)), ((-0.02, 0.27), (0.024, 0.27)), ((-0.014, 0.31), (0.02, 0.33)),
             ((-0.002, 0.375), (0.006, 0.378)), ((0.003, 0.395), (0.003, 0.395))], 0.009)
    m.save("knife", 1.6)


def kunai():
    m = Model()
    m.tube("Guard", circle((0, -0.094), 0.022, 10), 0.006, 0.006, 6, closed=True)
    m.tube("Wrap", [(0, -0.07), (0, 0.05)], 0.009, 0.009)
    m.dagger([(0.05, 0.009), (0.1, 0.034), (0.16, 0.03), (0.3, 0.0)], 0.014)
    m.save("kunai", 1.6)


def butterfly():
    m = Model()
    # Opened: the two handles side by side in the hand, the blade above.
    for side in (-1, 1):
        m.tube("Guard", [(side * 0.009, 0.07), (side * 0.012, -0.075)], 0.0075, 0.009, 6)
        for y in (0.04, 0.0, -0.04):
            m.box("Accent", (side * 0.0105, y, 0), (0.007, 0.016, 0.021))
    m.box("Brass", (0, 0.07, 0), (0.034, 0.012, 0.022))
    m.box("Brass", (0, -0.078, 0), (0.03, 0.007, 0.012))
    m.blade([((-0.012, 0.076), (0.013, 0.076)), ((-0.012, 0.16), (0.014, 0.17)), ((-0.006, 0.2), (0.008, 0.205)),
             ((0.002, 0.222), (0.002, 0.222))], 0.007)
    m.save("butterfly", 1.6)


def karambit():
    m = Model()
    m.tube("Guard", circle((0, -0.092), 0.024, 12), 0.007, 0.007, 6, closed=True)
    m.tube("Grip", [(0, -0.066), (0.005, -0.02), (0.004, 0.03), (-0.002, 0.062)], [0.014, 0.017, 0.017, 0.016], 0.012)
    m.box("Guard", (-0.002, 0.064, 0), (0.044, 0.01, 0.026))
    # A claw: the blade follows an arc that bends toward +X, edge inside.
    center, radius = (0.11, 0.062), 0.112
    stations = []
    for degrees, width in ((180, 0.042), (160, 0.042), (140, 0.036), (120, 0.026), (104, 0.012), (94, 0.0)):
        angle = math.radians(degrees)
        outer, inner = radius + width / 2, radius - width / 2
        stations.append(((center[0] + outer * math.cos(angle), center[1] + outer * math.sin(angle)),
                         (center[0] + inner * math.cos(angle), center[1] + inner * math.sin(angle))))
    m.blade(stations, 0.009, ridge=0.5)
    m.save("karambit", 1.6)


def katana():
    m = Model()
    m.tube("Wrap", [(0, -0.14), (0, 0.0), (0, 0.14)], [0.015, 0.016, 0.015], 0.012)
    m.tube("Brass", [(0, -0.155), (0, -0.14)], 0.016, 0.013)
    m.tube("Brass", [(0, 0.14), (0, 0.15)], 0.045, 0.04, 10)
    m.tube("Brass", [(0, 0.15), (0, 0.18)], 0.017, 0.008)
    # A long blade that curves back, away from its edge.
    stations = []
    for i in range(9):
        u = i / 8
        y = 0.18 + 0.72 * u
        back = -0.055 * u * u
        stations.append(((back - 0.012, y), (back + 0.02 - 0.004 * u, y)))
    stations.append(((stations[-1][0][0], 0.94), (stations[-1][0][0], 0.94)))
    m.blade(stations, 0.008, ridge=0.4)
    m.save("katana", 1.25)


def machete():
    m = Model()
    m.tube("Wood", [(0, -0.075), (0.004, -0.03), (0.004, 0.03), (0, 0.075)], [0.017, 0.02, 0.019, 0.017], 0.012)
    for y in (-0.04, 0.0, 0.04):
        m.tube("Brass", [(0.002, y - 0.004), (0.002, y + 0.004)], 0.006, 0.0135, 6)
    m.blade([((-0.02, 0.078), (0.02, 0.078)), ((-0.02, 0.25), (0.036, 0.25)), ((-0.02, 0.45), (0.058, 0.45)),
             ((-0.018, 0.54), (0.05, 0.55)), ((-0.006, 0.6), (0.02, 0.61)), ((0.004, 0.625), (0.004, 0.625))], 0.007, ridge=0.6)
    m.save("machete", 1.3)


def axe():
    m = Model()
    m.tube("Wood", [(0.004, -0.17), (0, -0.05), (0, 0.3), (0, 0.5)], [0.016, 0.014, 0.013, 0.015], 0.011)
    m.box("Guard", (0, 0.44, 0), (0.05, 0.09, 0.034))
    m.blade([((0.02, 0.4), (0.105, 0.34)), ((0.02, 0.42), (0.132, 0.39)), ((0.02, 0.44), (0.14, 0.44)),
             ((0.02, 0.46), (0.132, 0.49)), ((0.02, 0.48), (0.105, 0.54))], 0.03, ridge=0.45)
    m.box("Accent", (-0.03, 0.44, 0), (0.012, 0.05, 0.02))
    m.save("axe", 1.35)


def mace():
    m = Model()
    m.tube("Grip", [(0, -0.16), (0, 0.0)], 0.014, 0.014)
    m.tube("Guard", [(0, 0.0), (0, 0.42)], 0.011, 0.011)
    m.tube("Brass", [(0, -0.175), (0, -0.16)], 0.019, 0.019)
    m.tube("Brass", [(0, -0.004), (0, 0.006)], 0.018, 0.018)
    m.tube("Blade", [(0, 0.4), (0, 0.44), (0, 0.52), (0, 0.56)], [0.026, 0.05, 0.05, 0.026], [0.026, 0.05, 0.05, 0.026])
    for turn in range(4):
        angle = math.tau * turn / 8
        # Flanges: thin plates through the head, turned around the shaft.
        c, s = math.cos(angle), math.sin(angle)
        plate = [(-0.085, 0.43), (-0.085, 0.53), (0.085, 0.53), (0.085, 0.43)]
        for offset in (-0.004, 0.004):
            m.face("Edge", *[(x * c - offset * s, y, x * s + offset * c) for x, y in plate])
    m.dagger([(0.56, 0.012), (0.63, 0.0)], 0.02)
    m.save("mace", 1.3)


def spear():
    m = Model()
    m.tube("Wood", [(0, -0.55), (0, 1.0)], 0.012, 0.012)
    m.tube("Wrap", [(0, -0.1), (0, 0.1)], 0.014, 0.014)
    m.tube("Brass", [(0, 0.98), (0, 1.03)], 0.017, 0.017)
    m.tube("Accent", [(0, 0.93), (0, 0.98)], 0.015, 0.015)
    m.dagger([(1.03, 0.012), (1.1, 0.04), (1.18, 0.034), (1.36, 0.0)], 0.016)
    m.save("spear", 1.2)


# --- Material textures (tileable) ----------------------------------------------

SIZE = 128


def steel():
    """Brushed steel: fine streaks along the blade."""
    rnd = random.Random(1)
    image = Image.new("RGB", (SIZE, SIZE))
    for x in range(SIZE):
        column = 178 + rnd.randint(-16, 16)
        for y in range(SIZE):
            value = column + rnd.randint(-5, 5)
            image.putpixel((x, y), (value, value + 2, value + 6))
    return image


def wood():
    rnd = random.Random(2)
    image = Image.new("RGB", (SIZE, SIZE))
    for x in range(SIZE):
        # Grain lines that wander a little, and close on themselves.
        tone = 0.5 + 0.5 * math.sin(math.tau * x * 6 / SIZE)
        tone = tone * 0.6 + rnd.random() * 0.4
        for y in range(SIZE):
            wave = tone + 0.12 * math.sin(math.tau * (y * 2 + x * 3) / SIZE)
            image.putpixel((x, y), (int(88 + 46 * wave), int(54 + 30 * wave), int(28 + 16 * wave)))
    return image.filter(ImageFilter.GaussianBlur(0.6))


def crosshatch(base, line, step, width):
    """Diagonal lines both ways: knurled rubber, or the wrap of a sword's handle."""
    image = Image.new("RGB", (SIZE, SIZE), base)
    draw = ImageDraw.Draw(image)
    for offset in range(-SIZE, SIZE * 2, step):
        draw.line([(offset, 0), (offset + SIZE, SIZE)], fill=line, width=width)
        draw.line([(offset, 0), (offset - SIZE, SIZE)], fill=line, width=width)
    return image


os.makedirs(MODEL_DIR, exist_ok=True)
os.makedirs(TEXTURE_DIR, exist_ok=True)
for build in (knife, kunai, butterfly, karambit, katana, machete, axe, mace, spear):
    build()
steel().save(TEXTURE_DIR + "steel.png")
wood().save(TEXTURE_DIR + "wood.png")
crosshatch((30, 30, 34), (12, 12, 14), 16, 3).save(TEXTURE_DIR + "grip.png")
crosshatch((150, 140, 120), (22, 20, 28), 32, 11).save(TEXTURE_DIR + "wrap.png")
