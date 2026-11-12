"""Draws the app icon: the logo's lightning bolt on a slanted plate, in the
game's cyan and magenta, at the sizes the web app needs.

Run from the repo root: python3 tools/make_icons.py
Writes assets/ui/icon_<size>.png (512, 180, 144) for the web app, and
assets/ui/icon.png (256), the project icon (browser tab).
"""
from PIL import Image, ImageDraw, ImageFilter

OUT = "assets/ui/"
NAVY = (6, 11, 42)
PLATE = (8, 18, 52)
CYAN = (41, 212, 255)
MAGENTA = (255, 61, 242)
SCALE = 4  # drawn larger, then reduced: smooth edges


def icon(size):
    s = size * SCALE
    image = Image.new("RGB", (s, s), NAVY)
    draw = ImageDraw.Draw(image)

    # A soft cyan glow behind the plate.
    glow = Image.new("RGB", (s, s), NAVY)
    ImageDraw.Draw(glow).ellipse([s * 0.12, s * 0.12, s * 0.88, s * 0.88], fill=(14, 60, 110))
    image = Image.blend(image, glow.filter(ImageFilter.GaussianBlur(s * 0.12)), 0.9)
    draw = ImageDraw.Draw(image)

    # Slanted plate, as on the logo: a cyan one, and the dark one inside it.
    def plate(inset):
        shift = s * 0.12
        top, bottom = s * 0.2 + inset, s * 0.8 - inset
        left, right = s * 0.14 + inset, s * 0.86 - inset
        return [(left + shift, top), (right, top), (right - shift, bottom), (left, bottom)]

    draw.polygon(plate(0), fill=CYAN)
    draw.polygon(plate(s * 0.035), fill=PLATE)

    # Lightning bolt (same shape as scripts/logo.gd), centered on the plate.
    span = s * 0.5
    origin = (s * 0.5 - span * 0.45, s * 0.5 - span * 0.5)
    points = [(0.55, 0), (0.1, 0.56), (0.42, 0.56), (0.28, 1), (0.8, 0.4), (0.47, 0.4)]
    draw.polygon([(origin[0] + x * span, origin[1] + y * span) for x, y in points], fill=MAGENTA)
    return image.resize((size, size), Image.LANCZOS)


for size in (512, 180, 144):
    icon(size).save(f"{OUT}icon_{size}.png")
icon(256).save(OUT + "icon.png")
