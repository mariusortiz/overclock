"""Generates the tileable weapon skin patterns in assets/textures/skins/.

Run from the repo root: python3 tools/make_skin_textures.py
Each pattern is an original design drawn by code. One file per skin id of
Loadout.SKINS (except the standard skin, which keeps the gun's own colors).
"""
import math
import random

from PIL import Image, ImageDraw, ImageFilter

SIZE = 256
OUT = "assets/textures/skins/"


def canvas(color):
    image = Image.new("RGB", (SIZE, SIZE), color)
    return image, ImageDraw.Draw(image)


def tiled(draw_one):
    """Calls draw_one(dx, dy) for the tile and its 8 neighbors, so shapes that
    cross an edge come back on the other side."""
    for dx in (-SIZE, 0, SIZE):
        for dy in (-SIZE, 0, SIZE):
            draw_one(dx, dy)


def stripes(base, colors, width, slant=1.0):
    image, draw = canvas(base)
    step = SIZE // len(colors) if False else width * len(colors)
    for i in range(-SIZE, SIZE * 2, width):
        color = colors[(i // width) % len(colors)]
        draw.polygon([(i, 0), (i + width, 0), (i + width - SIZE * slant, SIZE), (i - SIZE * slant, SIZE)], fill=color)
    return image


def blobs(base, colors, count, radius, seed):
    image, draw = canvas(base)
    rnd = random.Random(seed)
    for _ in range(count):
        x, y, r = rnd.randrange(SIZE), rnd.randrange(SIZE), rnd.randint(radius // 2, radius)
        color = rnd.choice(colors)
        squash = rnd.uniform(0.5, 1.0)
        tiled(lambda dx, dy: draw.ellipse((x - r + dx, y - r * squash + dy, x + r + dx, y + r * squash + dy), fill=color))
    return image.filter(ImageFilter.MedianFilter(5))


def cracks(base, line, glow, count, seed):
    image, draw = canvas(base)
    rnd = random.Random(seed)
    for _ in range(count):
        x, y = rnd.randrange(SIZE), rnd.randrange(SIZE)
        points = [(x, y)]
        for _ in range(6):
            x += rnd.randint(-40, 40)
            y += rnd.randint(-40, 40)
            points.append((x, y))
        tiled(lambda dx, dy: draw.line([(px + dx, py + dy) for px, py in points], fill=glow, width=7))
        tiled(lambda dx, dy: draw.line([(px + dx, py + dy) for px, py in points], fill=line, width=3))
    return image


def hexagons(base, line, cell):
    image, draw = canvas(base)
    height = cell * math.sqrt(3) / 2
    rows = round(SIZE / height)
    height = SIZE / rows  # snap so the pattern tiles
    for row in range(-1, rows + 1):
        for col in range(-1, SIZE // cell + 2):
            cx = col * cell * 1.5
            cy = row * height * 2 + (height if col % 2 else 0)
            corners = [(cx + cell * math.cos(math.radians(a)), cy + height * math.sin(math.radians(a)) / math.sin(math.radians(60)) * math.sin(math.radians(60)))
                       for a in range(0, 360, 60)]
            draw.polygon(corners, outline=line)
    return image


def weave(dark, light, cell):
    image, draw = canvas(dark)
    for y in range(0, SIZE, cell):
        for x in range(0, SIZE, cell):
            if (x // cell + y // cell) % 2 == 0:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill=light)
                draw.line((x, y, x + cell - 1, y + cell - 1), fill=dark)
            else:
                draw.line((x + cell - 1, y, x, y + cell - 1), fill=light)
    return image


def diamonds(base, fill, line, cell):
    image, draw = canvas(base)
    for y in range(-cell, SIZE + cell, cell):
        for x in range(-cell, SIZE + cell, cell):
            draw.polygon([(x, y + cell // 2), (x + cell // 2, y), (x + cell, y + cell // 2), (x + cell // 2, y + cell)],
                         fill=fill, outline=line)
    return image


def waves(colors, band, amplitude):
    image = Image.new("RGB", (SIZE, SIZE))
    pixels = image.load()
    for y in range(SIZE):
        for x in range(SIZE):
            offset = amplitude * math.sin(2 * math.pi * x / SIZE * 2)
            pixels[x, y] = colors[int((y + offset) // band) % len(colors)]
    return image


def brushed(base, amount, seed):
    rnd = random.Random(seed)
    image = Image.new("RGB", (SIZE, SIZE))
    pixels = image.load()
    for y in range(SIZE):
        shift = rnd.randint(-amount, amount)
        for x in range(SIZE):
            n = shift + rnd.randint(-amount // 3, amount // 3)
            pixels[x, y] = tuple(max(0, min(255, c + n)) for c in base)
    return image


def chevrons(base, color, width, gap):
    image, draw = canvas(base)
    for y in range(-SIZE, SIZE * 2, gap):
        draw.line([(0, y + SIZE // 2), (SIZE // 2, y), (SIZE, y + SIZE // 2)], fill=color, width=width)
    return image


def petals(base, colors, count, seed):
    image, draw = canvas(base)
    rnd = random.Random(seed)
    for _ in range(count):
        x, y, r = rnd.randrange(SIZE), rnd.randrange(SIZE), rnd.randint(6, 12)
        color = rnd.choice(colors)
        for k in range(5):
            angle = math.radians(72 * k)
            px, py = x + r * math.cos(angle), y + r * math.sin(angle)
            tiled(lambda dx, dy: draw.ellipse((px - r * 0.6 + dx, py - r * 0.6 + dy, px + r * 0.6 + dx, py + r * 0.6 + dy), fill=color))
    return image


PATTERNS = {
    "skin_neon": stripes((8, 12, 40), [(0, 230, 255), (8, 12, 40), (255, 60, 240), (8, 12, 40)], 32),
    "skin_ice": cracks((150, 205, 240), (240, 250, 255), (110, 170, 225), 14, seed=1),
    "skin_lava": cracks((38, 18, 16), (255, 200, 60), (255, 90, 20), 16, seed=2),
    "skin_camo": blobs((70, 84, 48), [(46, 58, 34), (104, 96, 62), (30, 36, 26)], 70, 34, seed=3),
    "skin_toxic": hexagons((22, 40, 18), (150, 255, 40), 32),
    "skin_royal": diamonds((48, 22, 96), (86, 44, 160), (232, 190, 80), 64),
    "skin_carbon": weave((22, 22, 26), (52, 52, 60), 16),
    "skin_sakura": petals((250, 205, 222), [(255, 150, 190), (255, 255, 255), (240, 110, 160)], 46, seed=4),
    "skin_ocean": waves([(14, 58, 140), (28, 110, 200), (90, 190, 235), (28, 110, 200)], 32, 14),
    "skin_solar": stripes((255, 150, 30), [(255, 210, 60), (255, 150, 30), (240, 90, 20), (255, 150, 30)], 32, slant=0.5),
    "skin_gold": brushed((222, 176, 70), 26, seed=5),
    "skin_champion": chevrons((226, 180, 70), (255, 60, 240), 14, 64),
}

for name, image in PATTERNS.items():
    image.save(OUT + name + ".png")
