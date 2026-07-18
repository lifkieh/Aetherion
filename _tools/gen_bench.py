#!/usr/bin/env python3
"""Gambar bench.png + workbench.png (design-time, HUKUM REPRODUKSI #240).

PEMISAHAN (putusan Direktur 2026-07-18): satu string "bench" selama ini melayani
DUA benda yang kebetulan sama nama Inggris —

  workbench.png  -> MEJA TEMPA. 37 resep (`station: "workbench"`), label "Bengkel [E]",
                    punya jam kerja (WORKERS), ikon peta ⚒. FUNGSIONAL.
  bench.png      -> BANGKU DUDUK. 8 di alun-alun Ashbrook. Perabot cerita:
                    "perempuan yang duduk di bangku itu tiap sore selama 34 tahun".
                    Ini yang kelak dapat varian cekungan Otha (A1).

Satu sprite merusak salah satunya: cekungan 34 tahun di bawah meja tempa tak masuk
akal; menempa besi di bangku taman juga tidak.

BANGKU SENGAJA TANPA SANDARAN. Bukan gaya — syarat teknis: dari sudut
three-quarter top-down, sandaran menutupi permukaan duduk. Varian cekungan Otha
HANYA terbaca kalau permukaan duduk terlihat penuh.

#232: prop scene, BUKAN turunan LPC -> aman, milik game sendiri.

PALET DIAMBIL VERBATIM dari prop kayu yang sudah ada (konsistensi, bukan tebakan):
  signboard.png 16x14 -> #A07848 (badan), #BE925A (sorot), #5A4228, #46321E, #1E1612
  stall.png     40x34 -> #966E42, #BA8E58, #6E502E, #1E1612
  street_lamp.png     -> #46424A / #3C3840 (logam, untuk landasan tempa)
Skala dipatok int_table.png 24x20 (perabot Ashbrook yang sudah jadi).
"""
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
OUTDIR = os.path.join(REPO, "game", "assets", "game", "sprites", "props")

# --- palet verbatim ---
OUT_ = (0x1E, 0x16, 0x12, 255)   # outline — signboard x42, stall x190, street_lamp x92
W_HI = (0xBE, 0x92, 0x5A, 255)   # signboard x24 — permukaan atas kena cahaya
W_MID = (0xA0, 0x78, 0x48, 255)  # signboard x84 — badan kayu
W_DK = (0x5A, 0x42, 0x28, 255)   # signboard x20 — muka depan / bayangan
W_DP = (0x46, 0x32, 0x1E, 255)   # signboard x8  — kaki, paling gelap
MET_H = (0x46, 0x42, 0x4A, 255)  # street_lamp x64 — landasan tempa
MET_M = (0x3C, 0x38, 0x40, 255)  # street_lamp x22
NONE = (0, 0, 0, 0)

PAL = {
    ".": NONE, "#": OUT_, "L": W_HI, "M": W_MID, "D": W_DK, "P": W_DP,
    "H": MET_H, "m": MET_M,
}

# ---------------------------------------------------------------- bangku duduk
# 20x11. Papan duduk lebar & rendah; muka depan gelap memberi tebal;
# empat kaki. Permukaan duduk (baris 1-3) sengaja POLOS & luas — di situlah
# cekungan Otha kelak dipahat.
BENCH = [
    ".##################.",   # 0  tepi belakang papan
    ".#LLLLLLLLLLLLLLLL#.",   # 1  permukaan duduk (kena cahaya)
    ".#LLLLLLLLLLLLLLLL#.",   # 2
    ".#MMMMMMMMMMMMMMMM#.",   # 3  permukaan menggelap ke depan
    ".##################.",   # 4  tepi depan papan
    ".#DDDDDDDDDDDDDDDD#.",   # 5  muka depan (tebal papan)
    ".##################.",   # 6
    "..#P#..........#P#..",   # 7  kaki
    "..#P#..........#P#..",   # 8
    "..#P#..........#P#..",   # 9
    "..###..........###..",   # 10
]

# ---------------------------------------------------------------- meja tempa
# 22x18. Landasan tempa (logam) DI ATAS meja = siluet yang membedakannya dari
# bangku dalam sekali lihat, bahkan pada 2x zoom kamera.
WORKBENCH = [
    "........######........",   # 0  landasan tempa — tanduk
    "........#HHHH#........",   # 1
    "........##mm##........",   # 2  pinggang landasan
    ".........#mm#.........",   # 3
    "........#mmmm#........",   # 4  alas landasan
    "........######........",   # 5
    ".####################.",   # 6  tepi belakang meja
    ".#LLLLLLLLLLLLLLLLLL#.",   # 7  permukaan kerja
    ".#LLLLLLLLLLLLLLLLLL#.",   # 8
    ".#MMMMMMMMMMMMMMMMMM#.",   # 9
    ".####################.",   # 10 tepi depan
    ".#DDDDDDDDDDDDDDDDDD#.",   # 11 muka depan (lebih tebal dari bangku)
    ".#DDDDDDDDDDDDDDDDDD#.",   # 12
    ".####################.",   # 13
    "..###............###..",   # 14 kaki
    "..#P#............#P#..",   # 15
    "..#P#............#P#..",   # 16
    "..###............###..",   # 17
]


def _render(rows, name):
    h = len(rows)
    w = len(rows[0])
    img = Image.new("RGBA", (w, h), NONE)
    px = img.load()
    for y, row in enumerate(rows):
        assert len(row) == w, "%s baris %d: %d kolom, harus %d" % (name, y, len(row), w)
        for x, ch in enumerate(row):
            c = PAL.get(ch)
            if c is None:
                raise KeyError("%s: karakter tak dikenal %r di (%d,%d)" % (name, ch, x, y))
            px[x, y] = c
    img.save(os.path.join(OUTDIR, name + ".png"))
    return w, h


def main():
    bw, bh = _render(BENCH, "bench")
    ww, wh = _render(WORKBENCH, "workbench")
    print("bench.png %dx%d + workbench.png %dx%d -> %s" % (bw, bh, ww, wh, OUTDIR))


if __name__ == "__main__":
    main()
