#!/usr/bin/env python3
"""Ubin tanah 64px untuk LAYAR BUKTI #253 (design-time, HUKUM REPRODUKSI #240).

⚠ INI SENI BUKTI, BUKAN SENI FINAL. Tujuannya menjawab satu pertanyaan Direktur:
   "apakah 64px cukup lebih indah untuk membenarkan membangun ulang 148 aset?"
   Ubin ini digambar NATIF di 64px (bukan 16px dinaikkan), supaya panel bukti
   menunjukkan detail yang memang HANYA muat di 64px — rumput berhelai, nat batu,
   kerikil jalan — bukan piksel lama yang digemukkan.

#232 aman: digambar dari nol oleh proyek sendiri. Nol turunan LPC, nol SA.
Deterministik: `random.seed()` tetap → berkas identik tiap kali dijalankan (#240).

Palet diturunkan dari dunia 16px yang sudah ada supaya identitas warna Aetherion
tidak berubah saat skalanya berubah:
  cobble_0.png · dirt_path.png · storm_grass.png  (game/assets/game/tiles/)
"""
import os
import random

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
OUT = os.path.join(REPO, "game", "assets", "game", "tiles", "t64")

S = 64   # sisi ubin


def _px(img):
    return img.load()


def grass():
    """Rumput: dasar bergradasi halus + helai 1px + bunga kecil jarang."""
    random.seed(6401)
    im = Image.new("RGBA", (S, S), (86, 122, 62, 255))
    p = _px(im)
    for y in range(S):
        for x in range(S):
            n = random.randint(-7, 7)
            p[x, y] = (86 + n, 122 + n, 62 + n // 2, 255)
    d = ImageDraw.Draw(im)
    for _ in range(150):                       # helai rumput — mustahil di 16px
        x, y = random.randrange(S), random.randrange(S)
        h = random.randint(2, 4)
        c = (104 + random.randint(-6, 10), 146 + random.randint(-8, 12), 70, 255)
        d.line([(x, y), (x + random.choice((-1, 0, 1)), y - h)], fill=c)
    for _ in range(5):                         # bunga
        x, y = random.randrange(2, S - 2), random.randrange(2, S - 2)
        c = random.choice([(214, 206, 132, 255), (198, 158, 176, 255)])
        p[x, y] = c
        p[x + 1, y] = c
    return im


def dirt():
    """Jalan tanah: dasar hangat + kerikil bergaris-tepi + alur roda samar."""
    random.seed(6402)
    im = Image.new("RGBA", (S, S), (140, 112, 78, 255))
    p = _px(im)
    for y in range(S):
        for x in range(S):
            n = random.randint(-9, 9)
            p[x, y] = (140 + n, 112 + n, 78 + n, 255)
    d = ImageDraw.Draw(im)
    for _ in range(3):                         # alur roda mendatar
        y = random.randrange(8, S - 8)
        d.line([(0, y), (S, y + random.choice((-1, 0, 1)))], fill=(126, 99, 68, 255))
    for _ in range(26):                        # kerikil: isi + tepi gelap
        x, y = random.randrange(1, S - 3), random.randrange(1, S - 3)
        w, h = random.randint(2, 4), random.randint(2, 3)
        d.rectangle([x, y, x + w, y + h], fill=(163, 137, 102, 255),
                    outline=(108, 86, 60, 255))
    return im


def cobble():
    """Alun-alun: batu 14-18px BERGARIS-TEPI dengan nat — struktur khas 64px."""
    random.seed(6403)
    im = Image.new("RGBA", (S, S), (74, 72, 68, 255))     # nat
    d = ImageDraw.Draw(im)
    y = 0
    row = 0
    while y < S:
        h = random.randint(14, 18)
        x = -random.randint(0, 8) if row % 2 else 0        # baris berselang-seling
        while x < S:
            w = random.randint(14, 18)
            base = random.randint(-8, 8)
            d.rectangle([x + 1, y + 1, x + w - 1, y + h - 1],
                        fill=(132 + base, 128 + base, 120 + base, 255))
            d.line([(x + 2, y + 2), (x + w - 2, y + 2)],   # sorot atas
                   fill=(154 + base, 150 + base, 142 + base, 255))
            d.line([(x + 2, y + h - 2), (x + w - 2, y + h - 2)],  # bayangan bawah
                   fill=(104 + base, 100 + base, 94 + base, 255))
            x += w
        y += h
        row += 1
    return im


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, fn in (("grass64", grass), ("dirt64", dirt), ("cobble64", cobble)):
        fn().save(os.path.join(OUT, name + ".png"))
    print("3 ubin 64x64 -> %s" % OUT)


if __name__ == "__main__":
    main()
