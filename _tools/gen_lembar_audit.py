# -*- coding: utf-8 -*-
"""Lembar kontak aset: buka tiap PNG, lihat isinya. Bukan percaya namanya."""
import sys, os
sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw

REPO = r"D:\2DGAME\game\assets\game"
DIRS = [("lpc32", os.path.join(REPO, "sprites", "lpc32")),
        ("props", os.path.join(REPO, "sprites", "props")),
        ("tiles", os.path.join(REPO, "tiles", "lpc32"))]

items = []
for tag, d in DIRS:
    if not os.path.isdir(d):
        print("LEWAT", d); continue
    for f in sorted(os.listdir(d)):
        if not f.endswith(".png"):
            continue
        p = os.path.join(d, f)
        im = Image.open(p).convert("RGBA")
        items.append((tag, f, im))

print(len(items), "aset")
SEL = 96
KOL = 8
baris = (len(items) + KOL - 1) // KOL
sheet = Image.new("RGBA", (KOL * SEL, baris * (SEL + 14)), (240, 238, 232, 255))
d = ImageDraw.Draw(sheet)
for i, (tag, f, im) in enumerate(items):
    x = (i % KOL) * SEL
    y = (i // KOL) * (SEL + 14)
    # kotak transparansi supaya krop-kosong ketahuan
    d.rectangle([x, y, x + SEL - 1, y + SEL - 1], outline=(200, 196, 188))
    w, h = im.size
    s = min(SEL / max(w, 1), SEL / max(h, 1), 3.0)
    im2 = im.resize((max(1, int(w * s)), max(1, int(h * s))), Image.NEAREST)
    sheet.alpha_composite(im2, (x + (SEL - im2.width) // 2, y + (SEL - im2.height) // 2))
    d.text((x + 2, y + SEL), f"{f[:22]} {w}x{h}", fill=(40, 38, 34))
out = r"D:\2DGAME\reports\preview\_audit_aset.png"
sheet.save(out)
print("->", out)
for i, (tag, f, im) in enumerate(items):
    print(f"{i:3} {tag:6} {f:34} {im.size}")
