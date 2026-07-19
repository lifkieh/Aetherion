#!/usr/bin/env python3
"""Potong ubin/objek dunia dari Mage City Arcanos untuk LAYAR BUKTI #254 (#240).

⚠ TEMUAN YANG HARUS DIBACA DULU: **tak ada "tileset LPC 64px".**
Standar LPC = **ubin dunia 32×32** + **frame karakter 64×64**. Angka 64 di LPC
mengacu pada kanvas karakter, bukan petak dunia. Jadi "dunia 64px lewat LPC"
sesungguhnya berarti **petak 32px dengan karakter berframe 64px** — dan itu
justru tampilan LPC kanonik (badan tampak ~34×47 di dalam frame 64).
Diverifikasi: seluruh terrain keluarga LPC di gudang berkisi 32px.

SUMBER (WAJIB dicatat — pelajaran 80-CC0-RPG-SFX):
  Berkas   : assets_raw/lpc/magecity.png  (256×1450 = 8 kolom × 45 baris @32px)
  Pack     : "Mage City Arcanos"
  Pembuat  : Hyptosis
  Lisensi  : **CC0** (domain publik) — diverifikasi di halaman sumber
  URL      : https://opengameart.org/content/mage-city-arcanos
  Catatan  : gudang TIDAK memuat berkas lisensi untuk tileset ini; lisensi
             diverifikasi dari halaman OGA, bukan dari nama folder.
             assets_raw/lpc/_lic/ hanya memuat lisensi karakter/hewan/monster.

#232 sudah DICABUT (#254) — aset SA kini diterima. Mage City sendiri CC0,
jadi ia aman tanpa syarat apa pun; atribusi tetap dicatat sebagai kebiasaan.
"""
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
SRC = os.path.join(REPO, "assets_raw", "lpc", "magecity.png")
T_OUT = os.path.join(REPO, "game", "assets", "game", "tiles", "lpc32")
S_OUT = os.path.join(REPO, "game", "assets", "game", "sprites", "lpc32")

T = 32

# (nama, kolom, baris, lebar_petak, tinggi_petak, tujuan)
SLICES = [
    ("grass32",    0, 0, 1, 1, "tiles"),    # rumput/lumut
    ("cobble32",   1, 9, 1, 1, "tiles"),    # perkerasan alun-alun (tengah blok, hindari tepi)
    ("stone32",    1, 1, 1, 1, "tiles"),    # batu pucat
    ("wall_inn",   0, 4, 4, 2, "sprites"),  # fasad batu pasir 128×64 = "rumah singgah"
    ("fountain",   6, 2, 2, 2, "sprites"),  # air mancur 64×64 — pengganti ColorRect Ashbrook
    ("bench_lpc",  7, 0, 1, 1, "sprites"),  # bangku
    ("barrel_lpc", 4, 2, 1, 2, "sprites"),  # tong
]


def main():
    os.makedirs(T_OUT, exist_ok=True)
    os.makedirs(S_OUT, exist_ok=True)
    im = Image.open(SRC).convert("RGBA")
    for name, c, r, w, h, dest in SLICES:
        box = (c * T, r * T, (c + w) * T, (r + h) * T)
        out = os.path.join(T_OUT if dest == "tiles" else S_OUT, name + ".png")
        im.crop(box).save(out)
        print("  %-12s %3dx%-3d  <- magecity (%d,%d)" % (name, w * T, h * T, c, r))
    print("%d potongan -> tiles/lpc32 + sprites/lpc32" % len(SLICES))


if __name__ == "__main__":
    main()
