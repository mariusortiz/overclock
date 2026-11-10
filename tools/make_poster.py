"""Turns a raw render of the poster scene into the loading screen artwork.

Usage, from the repo root: python3 tools/make_poster.py <raw_render.png>

The raw render is a 1920 x 1080 screenshot of scenes/tools/poster.tscn (open it
with F6 from the home screen of a test build). This script gives it a poster
look: stronger colors, flat color areas, dark outlines and a vignette. To use
a real illustration instead, simply replace assets/ui/loading_art.jpg.
"""
import sys

from PIL import Image, ImageChops, ImageEnhance, ImageFilter

OUT = "assets/ui/loading_art.jpg"
SIZE = (1920, 1080)

raw = Image.open(sys.argv[1]).convert("RGB").resize(SIZE, Image.LANCZOS)

# Stronger, flatter colors.
image = ImageEnhance.Contrast(raw).enhance(1.25)
image = ImageEnhance.Color(image).enhance(1.3)
image = image.filter(ImageFilter.MedianFilter(5))
image = image.quantize(colors=160, method=Image.MEDIANCUT, dither=Image.NONE).convert("RGB")

# Dark outlines where the smoothed picture changes sharply.
edges = raw.filter(ImageFilter.GaussianBlur(1.5)).convert("L").filter(ImageFilter.FIND_EDGES)
edges = edges.point(lambda v: 255 if v > 22 else 0).filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
ink = Image.new("RGB", SIZE, (6, 10, 32))
image = Image.composite(ink, image, edges.point(lambda v: int(v * 0.85)))

# Vignette: darker toward the corners.
vignette = Image.radial_gradient("L").resize(SIZE)
image = Image.composite(Image.new("RGB", SIZE, (3, 6, 24)), image, vignette.point(lambda v: max(0, int((v - 110) * 1.3))))

image.save(OUT, quality=90)
print("wrote", OUT)
