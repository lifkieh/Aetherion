#!/usr/bin/env python3
"""Gambar PELATARAN MELINGKAR alun-alun Ashbrook64 (design-time, #240).

MASALAH YANG DIPECAHKAN
-----------------------
Penilaian visual: pusat desa tak terbaca sebagai pusat. Air mancur duduk di tengah
PERSEGI PANJANG batu polos — satu tekstur, satu ketinggian, nol bingkai. Tak ada
apa pun yang menunjuk ke sana. Satu lentera di pinggir kota memerintah mata lebih
kuat daripada pusatnya sendiri.

Obatnya RUANG, bukan objek: membesarkan air mancur tak menolong kalau lantainya
tetap rata. Pelataran melingkar memberi pusat sebuah TEPI — mata membaca lingkaran
sebagai "ini tempatnya", persis seperti alun-alun sungguhan diberi perkerasan
berbeda di sekeliling sumurnya.

DITURUNKAN DARI UBIN YANG SUDAH ADA, bukan palet baru: `stone32.png` disusun ulang
jadi cakram, lalu tepinya digelapkan sedikit sebagai garis batas. Dengan begitu ia
tak pernah bentrok warna dengan `cobble32` di bawahnya — sumbernya sama.

Keluaran: game/assets/game/tiles/lpc32/pelataran32.png (cakram RGBA, latar transparan)

Pemakaian:
  python gen_pelataran.py
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
TILES = os.path.join(REPO, "game", "assets", "game", "tiles", "lpc32")
SRC = os.path.join(TILES, "stone32.png")
OUT = os.path.join(TILES, "pelataran32.png")

D = 320          # garis tengah cakram, px. ~10 petak 32 — cukup besar untuk dibaca
                 # dari zoom 0.55, cukup kecil untuk tak menelan alun-alun.
TEPI = 3         # tebal garis batas


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    if not os.path.exists(SRC):
        print(f"[GAGAL] ubin sumber hilang: {SRC}", file=sys.stderr)
        return 2
    ubin = Image.open(SRC).convert("RGBA")
    tw, th = ubin.size

    # 1) hamparkan ubin batu memenuhi kotak DxD
    kanvas = Image.new("RGBA", (D, D), (0, 0, 0, 0))
    for y in range(0, D, th):
        for x in range(0, D, tw):
            kanvas.alpha_composite(ubin, (x, y))

    # 2) potong jadi cakram lewat mask — bukan digambar bulat, DIPOTONG bulat,
    #    supaya polanya tetap sejajar grid ubin di bawahnya
    mask = Image.new("L", (D, D), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, D - 1, D - 1], fill=255)
    kanvas.putalpha(mask)

    # 3) garis batas: tepi digelapkan. Inilah yang membuat mata membaca "tepi",
    #    bukan sekadar tambalan batu yang kebetulan bulat.
    cincin = Image.new("L", (D, D), 0)
    dc = ImageDraw.Draw(cincin)
    dc.ellipse([0, 0, D - 1, D - 1], outline=255, width=TEPI)
    gelap = Image.new("RGBA", (D, D), (38, 32, 26, 190))
    kanvas.paste(gelap, (0, 0), cincin)

    os.makedirs(TILES, exist_ok=True)
    kanvas.save(OUT)
    print(f"pelataran {D}x{D} -> {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
