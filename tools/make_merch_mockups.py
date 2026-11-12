#!/usr/bin/env python3
"""Product previews for the website's merch shop (site/img/merch/), made from
the print files in merch/: each design on a simple drawn product (T-shirt,
sweat, mug, poster, stickers, tote bag). Only a preview: the print service
shows its own mockups once the designs are uploaded.

Needs Pillow. Run from the repository root: python3 tools/make_merch_mockups.py
"""
from PIL import Image, ImageDraw, ImageFilter
import os

MERCH = "merch"
OUT = "site/img/merch"
SIZE = 900
BACKDROP = (233, 236, 245)


def design(name, max_size):
    image = Image.open(os.path.join(MERCH, name + ".png")).convert("RGBA")
    image.thumbnail(max_size, Image.LANCZOS)
    return image


def canvas():
    image = Image.new("RGBA", (SIZE, SIZE), BACKDROP + (255,))
    draw = ImageDraw.Draw(image)
    # A soft floor shadow under the product.
    draw.ellipse((150, 800, 750, 860), fill=(210, 214, 226, 255))
    return image, draw


def shirt(color, hood=False):
    image, draw = canvas()
    if hood:
        draw.ellipse((300, 60, 600, 260), fill=tuple(max(c - 25, 0) for c in color))
    body = [(300, 120), (600, 120), (770, 175), (870, 340), (770, 395), (705, 330), (705, 835),
            (195, 835), (195, 330), (130, 395), (30, 340), (130, 175)]
    draw.polygon(body, fill=color)
    draw.ellipse((350, 85, 550, 175), fill=tuple(max(c - 35, 0) for c in color))
    if hood:
        draw.rectangle((330, 610, 570, 720), outline=tuple(max(c - 30, 0) for c in color), width=6)
    return image


def paste_center(image, art, center):
    image.alpha_composite(art, (center[0] - art.width // 2, center[1] - art.height // 2))


def tshirt(design_name, color, max_size=(360, 330)):
    image = shirt(color)
    paste_center(image, design(design_name, max_size), (450, 400))
    return image


def sweat(design_name):
    image = shirt((120, 124, 138), hood=True)
    paste_center(image, design(design_name, (470, 300)), (450, 420))
    return image


def mug(design_name):
    image, draw = canvas()
    draw.rounded_rectangle((230, 230, 640, 770), radius=40, fill=(250, 250, 252), outline=(200, 204, 214), width=6)
    draw.ellipse((600, 360, 790, 620), outline=(240, 240, 244), width=46)
    draw.ellipse((600, 360, 790, 620), outline=(200, 204, 214), width=6)
    paste_center(image, design(design_name, (360, 300)), (435, 500))
    return image


def poster(design_name):
    image, draw = canvas()
    art = design(design_name, (520, 760))
    left, top = 450 - art.width // 2, 440 - art.height // 2
    draw.rectangle((left - 26, top - 26, left + art.width + 26, top + art.height + 26), fill=(30, 30, 36))
    image.alpha_composite(art, (left, top))
    return image


def die_cut(art):
    """A white border around the drawing, as on a sticker."""
    alpha = art.split()[3].filter(ImageFilter.MaxFilter(21))
    border = Image.new("RGBA", art.size, (255, 255, 255, 0))
    border.putalpha(alpha)
    border.alpha_composite(art)
    return border


def stickers(names):
    image, _ = canvas()
    spots = [(250, 260), (620, 250), (450, 480), (240, 680), (650, 680)]
    for name, spot in zip(names, spots):
        art = design(name, (300, 300))
        padded = Image.new("RGBA", (art.width + 40, art.height + 40), (0, 0, 0, 0))
        padded.alpha_composite(art, (20, 20))
        paste_center(image, die_cut(padded), spot)
    return image


def tote(design_name):
    image, draw = canvas()
    draw.arc((330, 120, 570, 420), 180, 360, fill=(205, 190, 160), width=22)
    draw.rectangle((210, 280, 690, 820), fill=(236, 224, 196))
    paste_center(image, design(design_name, (460, 320)), (450, 540))
    return image


def main():
    os.makedirs(OUT, exist_ok=True)
    products = {
        "tshirt_logo": tshirt("logo", (14, 22, 62), (400, 120)),
        "tshirt_escouade": tshirt("escouade", (245, 245, 248), (480, 330)),
        "sweat_rivaux": sweat("rivaux"),
        "affiche_titan": poster("affiche_titan"),
        "mug_bulle": mug("bulle"),
        "stickers": stickers(["sticker_soldier", "sticker_kunoichi", "sticker_sand_ghost", "sticker_ronin", "sticker_captain"]),
        "tote_flotte": tote("flotte"),
    }
    for name, image in products.items():
        image.convert("RGB").save(os.path.join(OUT, name + ".jpg"), quality=86)
        print(name)


if __name__ == "__main__":
    main()
