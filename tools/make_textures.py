"""Generates the tileable placeholder textures in assets/textures/.

Run from the repo root: python3 tools/make_textures.py
"""
import random
from PIL import Image, ImageDraw

SIZE = 256
OUT = "assets/textures/"


def noisy(base, amount, seed):
    rnd = random.Random(seed)
    img = Image.new("RGB", (SIZE, SIZE))
    px = img.load()
    for y in range(SIZE):
        for x in range(SIZE):
            n = rnd.randint(-amount, amount)
            px[x, y] = tuple(max(0, min(255, c + n)) for c in base)
    return img


def shade(color, delta):
    return tuple(max(0, min(255, c + delta)) for c in color)


def panels(base, cells, seed, rivets=True, frame=0):
    """A grid of `cells` x `cells` metal plates with seams, bevels and rivets."""
    img = noisy(base, 5, seed)
    d = ImageDraw.Draw(img)
    rnd = random.Random(seed + 1)
    step = SIZE // cells
    for cy in range(cells):
        for cx in range(cells):
            x0, y0 = cx * step, cy * step
            x1, y1 = x0 + step - 1, y0 + step - 1
            tint = rnd.randint(-6, 6)
            overlay = Image.new("RGB", (step, step), shade(base, tint))
            img.paste(Image.blend(img.crop((x0, y0, x1 + 1, y1 + 1)), overlay, 0.5), (x0, y0))
            d.rectangle((x0, y0, x1, y1), outline=shade(base, -24), width=2)
            d.line((x0 + 2, y0 + 2, x1 - 2, y0 + 2), fill=shade(base, 22))
            d.line((x0 + 2, y0 + 2, x0 + 2, y1 - 2), fill=shade(base, 14))
            if frame:
                d.rectangle((x0 + frame, y0 + frame, x1 - frame, y1 - frame),
                            outline=shade(base, -16), width=2)
                d.line((x0 + frame + 2, y1 - frame + 1, x1 - frame, y1 - frame + 1),
                       fill=shade(base, 18))
            if rivets:
                for rx, ry in ((x0 + 9, y0 + 9), (x1 - 9, y0 + 9), (x0 + 9, y1 - 9), (x1 - 9, y1 - 9)):
                    d.ellipse((rx - 2, ry - 2, rx + 2, ry + 2), fill=shade(base, -30))
                    d.point((rx - 1, ry - 1), fill=shade(base, 40))
    return img


def stripes():
    """Grayscale emission mask: two glowing horizontal bands per tile."""
    img = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
    d = ImageDraw.Draw(img)
    for y in (56, 184):
        d.rectangle((0, y - 14, SIZE, y + 14), fill=(40, 40, 40))
        d.rectangle((0, y - 6, SIZE, y + 6), fill=(255, 255, 255))
    return img


panels((40, 42, 62), 2, seed=1).save(OUT + "panel_dark.png")
panels((92, 98, 124), 2, seed=2, frame=18).save(OUT + "panel_light.png")
panels((24, 24, 38), 2, seed=3, rivets=False).save(OUT + "floor_tiles.png")
stripes().save(OUT + "stripes_emission.png")
