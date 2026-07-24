# -*- coding: utf-8 -*-
"""UBIN DUNGEON 32px — migrasi R1 (#286 · #279 · #240).

Ubin dungeon lama 16x16 datar; dunia pindah ke petak 32 (kanon #256) dan pemain
platformer jadi LPC 64. Gudang & OGA tak punya tileset gua side-view 32px yang
layak (dicek 2026-07-25) — maka ubin DIGAMBAR PROSEDURAL di sini: deterministik
(seed tetap), bisa dibuat ulang, bisa di-diff, bisa dihapus (#240/#162).

Gaya mengikuti mood gua yang sudah ada (batu biru-sabak dingin, tanah cokelat
hangat, bedrock nyaris hitam, urat tembaga berkilau) — seni lebih baik pada
kanvas lebih besar, bukan sekadar pembesaran (#253 kalimat yang bertahan).

Keluaran: game/assets/game/tiles/dungeon/{dirt,stone,bedrock,ore_copper,
platform,ladder,bg}.png — nama SAMA, pemakai (DungeonTerrain) tak berubah.
"""
import os
import random
import sys

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
DST = os.path.join(REPO, "game", "assets", "game", "tiles", "dungeon")
T = 32
rng = random.Random(279)      # seed tetap = keluaran identik tiap run (#240)


def _noise(im, warna, n, ukuran=1):
    d = ImageDraw.Draw(im)
    for _ in range(n):
        x = rng.randrange(0, T)
        y = rng.randrange(0, T)
        d.rectangle([x, y, x + ukuran - 1, y + ukuran - 1], fill=warna)


def dirt():
    im = Image.new("RGBA", (T, T), (110, 76, 48, 255))
    _noise(im, (126, 90, 58, 255), 46, 2)
    _noise(im, (96, 64, 40, 255), 40, 2)
    _noise(im, (82, 54, 34, 255), 18, 1)
    d = ImageDraw.Draw(im)
    d.line([(0, 0), (T - 1, 0)], fill=(134, 98, 64, 255))      # bibir atas terang
    d.line([(0, T - 1), (T - 1, T - 1)], fill=(74, 48, 30, 255))
    return im


def stone():
    im = Image.new("RGBA", (T, T), (74, 84, 104, 255))
    _noise(im, (86, 97, 118, 255), 40, 2)
    _noise(im, (62, 70, 88, 255), 34, 2)
    d = ImageDraw.Draw(im)
    # nat bata kasar 2 baris — membaca sebagai pasangan batu, bukan papan catur
    d.line([(0, 15), (T - 1, 15)], fill=(56, 63, 80, 255))
    d.line([(9, 0), (9, 15)], fill=(56, 63, 80, 255))
    d.line([(23, 16), (23, T - 1)], fill=(56, 63, 80, 255))
    d.line([(0, 0), (T - 1, 0)], fill=(96, 108, 130, 255))
    d.line([(0, T - 1), (T - 1, T - 1)], fill=(50, 56, 72, 255))
    return im


def bedrock():
    im = Image.new("RGBA", (T, T), (28, 30, 40, 255))
    _noise(im, (38, 41, 54, 255), 30, 2)
    _noise(im, (20, 22, 30, 255), 24, 2)
    d = ImageDraw.Draw(im)
    # retakan diagonal samar — terbaca "keras", bukan datar
    d.line([(4, 28), (14, 16), (12, 8)], fill=(16, 17, 24, 255))
    d.line([(20, 30), (27, 20)], fill=(16, 17, 24, 255))
    return im


def ore_copper():
    im = stone()
    d = ImageDraw.Draw(im)
    for cx, cy, r in [(8, 9, 3), (22, 20, 4), (14, 26, 2), (25, 6, 2)]:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(196, 118, 58, 255))
        d.point((cx - 1, cy - 1), fill=(255, 196, 140, 255))   # kilau
    return im


def platform():
    im = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 2, T - 1, 9], fill=(122, 88, 52, 255))       # papan
    d.line([(0, 2), (T - 1, 2)], fill=(150, 112, 70, 255))
    d.line([(0, 9), (T - 1, 9)], fill=(88, 60, 36, 255))
    for x in (5, 16, 27):
        d.line([(x, 3), (x, 8)], fill=(96, 66, 40, 255))          # sambungan papan
    d.point((3, 4), fill=(60, 40, 24, 255)); d.point((29, 6), fill=(60, 40, 24, 255))  # paku
    return im


def ladder():
    im = Image.new("RGBA", (T, T), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for x in (7, 23):
        d.rectangle([x - 1, 0, x + 1, T - 1], fill=(120, 86, 50, 255))
        d.line([(x - 1, 0), (x - 1, T - 1)], fill=(146, 108, 66, 255))
    for y in (5, 14, 23, 30):
        d.rectangle([6, y - 1, 25, y + 1], fill=(138, 100, 60, 255))
        d.line([(6, y + 1), (25, y + 1)], fill=(100, 70, 42, 255))
    return im


def bg():
    im = Image.new("RGBA", (T, T), (24, 27, 38, 255))
    _noise(im, (30, 34, 47, 255), 26, 2)
    _noise(im, (19, 21, 30, 255), 18, 2)
    return im


def main():
    os.makedirs(DST, exist_ok=True)
    for nama, fn in [("dirt", dirt), ("stone", stone), ("bedrock", bedrock),
                     ("ore_copper", ore_copper), ("platform", platform),
                     ("ladder", ladder), ("bg", bg)]:
        fn().save(os.path.join(DST, nama + ".png"))
        print("  ->", nama + ".png (32x32)")
    # lembar kontak bukti
    kontak = Image.new("RGBA", (7 * (T * 3 + 6), T * 3 + 18), (30, 28, 34, 255))
    d = ImageDraw.Draw(kontak)
    for i, nama in enumerate(["dirt", "stone", "bedrock", "ore_copper", "platform", "ladder", "bg"]):
        im = Image.open(os.path.join(DST, nama + ".png")).resize((T * 3, T * 3), Image.NEAREST)
        kontak.alpha_composite(im, (i * (T * 3 + 6), 16))
        d.text((i * (T * 3 + 6) + 2, 2), nama, fill=(235, 232, 240, 255))
    p = os.path.join(REPO, "reports", "preview", "tiles_dungeon32.png")
    kontak.save(p)
    print("  ->", p)
    return 0


if __name__ == "__main__":
    sys.exit(main())
