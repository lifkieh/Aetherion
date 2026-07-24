# -*- coding: utf-8 -*-
"""UBIN TEMA WILAYAH 32px — R2b (#286/#287 lanjutan · #240).

Desert/Candyveil/Frostpeak/Storm naik ke petak 32. Ubin tema 16px lama diganti
32px DI PATH YANG SAMA (pemanggil tak berubah). Identitas warna dijaga: palet
DISAMPEL dari ubin lama, lalu digambar ulang bertekstur pada kanvas 32 —
seni lebih baik, bukan pembesaran blok (#253 kalimat yang bertahan).

Deterministik (seed tetap, #240). Pakai: python gen_tiles_wilayah32.py
"""
import os
import random
import sys
from collections import Counter

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
T_DIR = os.path.join(REPO, "game", "assets", "game", "tiles")
T = 32
rng = random.Random(287)


def _palet(path, n=3):
    """n warna dominan ubin lama (tanpa alpha)."""
    im = Image.open(path).convert("RGBA")
    c = Counter()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = im.getpixel((x, y))
            if a > 128:
                c[(r, g, b)] += 1
    return [w for w, _ in c.most_common(n)] or [(128, 128, 128)]


def _base(pal):
    im = Image.new("RGBA", (T, T), pal[0] + (255,))
    d = ImageDraw.Draw(im)
    for _ in range(46):
        x, y = rng.randrange(T), rng.randrange(T)
        d.rectangle([x, y, x + 1, y + 1], fill=pal[min(1, len(pal) - 1)] + (255,))
    for _ in range(24):
        x, y = rng.randrange(T), rng.randrange(T)
        d.point((x, y), fill=pal[min(2, len(pal) - 1)] + (255,))
    return im


def _gelap(c, f=0.8):
    return tuple(int(v * f) for v in c)


def _terang(c, f=1.18):
    return tuple(min(255, int(v * f)) for v in c)


def sand(pal, dune=False):
    im = _base(pal)
    d = ImageDraw.Draw(im)
    # riak pasir mendatar halus
    for y in (7, 15, 23):
        yy = y + rng.randrange(-2, 3)
        d.line([(0, yy), (T - 1, yy)], fill=_gelap(pal[0], 0.9) + (255,))
        d.line([(0, yy + 1), (T - 1, yy + 1)], fill=_terang(pal[0], 1.08) + (255,))
    if dune:
        d.arc([4, 10, 27, 30], 200, 340, fill=_gelap(pal[0], 0.82) + (255,))
    return im


def batu(pal):
    im = _base(pal)
    d = ImageDraw.Draw(im)
    d.line([(0, 15), (T - 1, 15)], fill=_gelap(pal[0], 0.75) + (255,))
    d.line([(10, 0), (10, 15)], fill=_gelap(pal[0], 0.75) + (255,))
    d.line([(22, 16), (22, T - 1)], fill=_gelap(pal[0], 0.75) + (255,))
    d.line([(0, 0), (T - 1, 0)], fill=_terang(pal[0]) + (255,))
    return im


def salju(pal, varian=False):
    im = _base(pal)
    d = ImageDraw.Draw(im)
    for _ in range(6):  # kilau kristal
        x, y = rng.randrange(2, 30), rng.randrange(2, 30)
        d.point((x, y), fill=(255, 255, 255, 255))
        if varian:
            d.point((x + 1, y), fill=(240, 248, 255, 255))
    if varian:
        d.arc([6, 18, 24, 30], 180, 320, fill=_gelap(pal[0], 0.92) + (255,))
    return im


def es(pal):
    im = _base(pal)
    d = ImageDraw.Draw(im)
    # retakan es diagonal + kilau
    d.line([(4, 26), (14, 12), (12, 5)], fill=_terang(pal[0], 1.25) + (255,))
    d.line([(19, 29), (27, 17)], fill=_terang(pal[0], 1.25) + (255,))
    d.line([(15, 13), (18, 10)], fill=(255, 255, 255, 255))
    return im


def candy(pal, path=False):
    im = _base(pal)
    d = ImageDraw.Draw(im)
    if path:
        # jalur gula: garis karamel diagonal lembut
        for k in range(-1, 3):
            d.line([(0, k * 12 + 4), (T - 1, k * 12 - 8)], fill=_gelap(pal[0], 0.85) + (255,))
    else:
        # taburan permen kecil
        for _ in range(5):
            x, y = rng.randrange(3, 29), rng.randrange(3, 29)
            warna = pal[min(2, len(pal) - 1)]
            d.ellipse([x - 1, y - 1, x + 1, y + 1], fill=_terang(warna, 1.2) + (255,))
    return im


def main():
    kerja = [
        ("desert/sand_a.png",             lambda p: sand(p)),
        ("desert/sand_b.png",             lambda p: sand(p, dune=True)),
        ("desert/stone.png",              batu),
        ("candyveil/candy_grass_a_16.png", lambda p: candy(p)),
        ("candyveil/candy_grass_b_16.png", lambda p: candy(p)),
        ("candyveil/candy_path_16.png",   lambda p: candy(p, path=True)),
        ("snow_0.png",                    lambda p: salju(p)),
        ("snow_1.png",                    lambda p: salju(p, varian=True)),
        ("ice_patch.png",                 es),
        ("storm_grass.png",               lambda p: _base(p)),
        ("storm_rock.png",                batu),
        ("storm_sand.png",                lambda p: sand(p)),
    ]
    kontak = Image.new("RGBA", (len(kerja) * (T * 3 + 4), T * 3 + 18), (30, 28, 34, 255))
    dk = ImageDraw.Draw(kontak)
    for i, (rel, fn) in enumerate(kerja):
        p = os.path.join(T_DIR, rel)
        pal = _palet(p)
        im = fn(pal)
        im.save(p)
        nama = os.path.basename(rel)
        print("  -> %-28s (32x32, palet %s)" % (rel, pal[0]))
        kontak.alpha_composite(im.resize((T * 3, T * 3), Image.NEAREST), (i * (T * 3 + 4), 16))
        dk.text((i * (T * 3 + 4) + 2, 2), nama[:13], fill=(235, 232, 240, 255))
    out = os.path.join(REPO, "reports", "preview", "tiles_wilayah32.png")
    kontak.save(out)
    print("  ->", out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
