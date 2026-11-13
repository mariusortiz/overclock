#!/usr/bin/env python3
"""Crops a card's art around its subject, so that it fits whole in the card's
window (wider than tall: a subject taller than ~65 % of the picture loses its
head or its feet). Takes art rendered wide and big by make_card_art
("--size=640 --wide"), finds the subject against the flat backdrop, and saves
a 320 x 320 picture with the subject centered and small enough.

    python3 tools/fit_card_art.py card_bat card_dragon ...
"""
import sys
from PIL import Image

ART_DIR = "assets/cards/"
OUT = 320
# Share of the picture's height the subject may take (the window shows ~70 %).
HEIGHT_SHARE = 0.62
WIDTH_SHARE = 0.86

for card in sys.argv[1:]:
    path = ART_DIR + card + ".jpg"
    image = Image.open(path).convert("RGB")
    w, h = image.size
    back = image.getpixel((2, 2))
    pixels = image.load()
    xs, ys = [], []
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            r, g, b = pixels[x, y]
            if abs(r - back[0]) + abs(g - back[1]) + abs(b - back[2]) > 60:
                xs.append(x)
                ys.append(y)
    left, right, top, bottom = min(xs), max(xs), min(ys), max(ys)
    side = max((right - left) / WIDTH_SHARE, (bottom - top) / HEIGHT_SHARE)
    cx, cy = (left + right) / 2, (top + bottom) / 2
    box = (cx - side / 2, cy - side / 2, cx + side / 2, cy + side / 2)
    # Outside the render, the backdrop's color.
    canvas = Image.new("RGB", (int(side), int(side)), back)
    canvas.paste(image, (int(-box[0]), int(-box[1])))
    canvas.resize((OUT, OUT), Image.LANCZOS).save(path, quality=88)
    print(card, "subject", (right - left, bottom - top), "crop", int(side))
