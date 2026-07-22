# -*- coding: utf-8 -*-
"""Rasterize PNG di atas papan catur + kisi 32 px, supaya BENTUK terlihat.

Aturan gudang: nama berkas TIDAK dipercaya. Ini alat untuk melihat.
Kisi digambar supaya "berkisi 32 atau bukan" bisa dijawab dari mata, bukan dari
ukuran kanvas (1024x1024 bisa berkisi 16, 32, atau bukan kisi sama sekali).
"""
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw

OUT = os.path.dirname(os.path.abspath(__file__))


def papan(w, h, k=8):
    im = Image.new("RGBA", (w, h), (120, 120, 120, 255))
    d = ImageDraw.Draw(im)
    for y in range(0, h, k):
        for x in range(0, w, k):
            if (x // k + y // k) % 2:
                d.rectangle([x, y, x + k - 1, y + k - 1], fill=(160, 160, 160, 255))
    return im


def pandang(src, dst, skala=0, kisi=32, maks=1500, data=None):
    im = (data or Image.open(src)).convert("RGBA")
    w, h = im.size
    if skala == 0:
        skala = max(1, min(6, maks // max(w, h)))
    im = im.resize((w * skala, h * skala), Image.NEAREST)
    bg = papan(im.width, im.height)
    bg.alpha_composite(im)
    if kisi:
        d = ImageDraw.Draw(bg)
        s = kisi * skala
        for x in range(0, bg.width, s):
            d.line([(x, 0), (x, bg.height)], fill=(255, 0, 0, 80))
        for y in range(0, bg.height, s):
            d.line([(0, y), (bg.width, y)], fill=(255, 0, 0, 80))
    p = os.path.join(OUT, dst)
    bg.convert("RGB").save(p)
    print("%-44s %sx%s x%d kisi%s -> %s" % (os.path.basename(str(src)), w, h, skala, kisi, dst))
    return p


if __name__ == "__main__":
    a = sys.argv[1:]
    pandang(a[0], a[1], int(a[2]) if len(a) > 2 else 0, int(a[3]) if len(a) > 3 else 32)
