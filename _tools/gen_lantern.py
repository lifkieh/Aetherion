#!/usr/bin/env python3
"""Gambar lantern.png — lentera Merrit (design-time, HUKUM REPRODUKSI #240).

KONSUMEN SUDAH ADA: Ashbrook.gd:164 memuat res://assets/game/sprites/props/lantern.png.
Sebelum script ini, berkas itu TIDAK ADA -> fallback Image.create(6,8) = KOTAK WARNA polos.
Lelaki yang menyalakan lampu tiap malam 40 tahun, lampunya kotak warna. Itu yang diperbaiki.

#232: prop scene, BUKAN turunan LPC -> aman, milik game sendiri.

PALET DIAMBIL VERBATIM dari prop yang sudah ada (konsistensi, bukan tebakan):
  street_lamp.png 12x44 -> outline #1E1612, logam #46424A/#3C3840/#302C34,
                           kaca #FFE08C, sorot #FFF8D2
  int_lamp.png    12x24 -> kaca #FFE096, kaca redup #DCB46E
Dua-duanya lampu, dua-duanya 12 px lebar -> lentera ikut 12 px lebar.

DUA KELUARAN (sengaja):
  lantern.png       12x20 — sprite yang dilihat pemain
  lantern_glow.png  12x20 — TOPENG CAHAYA: siluet padat hangat, tanpa logam/outline

Kenapa dua? Ashbrook.gd:176 memberi PointLight2D texture yang SAMA dengan sprite.
Sprite lentera yang benar mayoritas logam gelap + outline hitam. PointLight2D
mengalikan cahaya dengan tekstur -> outline hitam = cahaya NOL di situ.
Pakai sprite sebagai tekstur lampu akan MEMBUNUH glow Merrit (hook siluetnya, #229).
Kotak warna lama justru glow sempurna karena isinya rata.
lantern_glow.png menjaga glow itu tetap hidup saat sprite jadi sungguhan.
"""
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
OUTDIR = os.path.join(REPO, "game", "assets", "game", "sprites", "props")

W, H = 12, 20

# --- palet verbatim dari street_lamp.png + int_lamp.png ---
OUTLINE = (0x1E, 0x16, 0x12, 255)   # street_lamp x92, signboard x42, stall x190
MET_HI = (0x46, 0x42, 0x4A, 255)    # street_lamp x64
MET_MID = (0x3C, 0x38, 0x40, 255)   # street_lamp x22
MET_LO = (0x30, 0x2C, 0x34, 255)    # street_lamp x6
GLASS = (0xFF, 0xE0, 0x8C, 255)     # street_lamp x19
GLASS_HI = (0xFF, 0xF8, 0xD2, 255)  # street_lamp x1 (sorot)
GLASS_DIM = (0xDC, 0xB4, 0x6E, 255) # int_lamp x16
NONE = (0, 0, 0, 0)

# Peta piksel. Satu huruf = satu piksel. Dibaca atas->bawah.
#   . kosong   # outline   H logam terang   M logam sedang   L logam gelap
#   g kaca     G kaca terang   d kaca redup
ART = [
    "....##......",   # 0  gantungan: lengkung kiri
    "...#..#.....",   # 1
    "...#..#.....",   # 2
    "....##......",   # 3  cincin tertutup
    "....##......",   # 4  batang ke tudung
    "..########..",   # 5  bibir tudung
    ".#HHHHHHHH#.",   # 6  tudung logam
    ".#HMMMMMMH#.",   # 7
    "..#MMMMMM#..",   # 8  tudung menyempit
    "..#dggggd#..",   # 9  kaca mulai
    "..#gGGGGg#..",   # 10 inti paling terang
    "..#gGGGGg#..",   # 11
    "..#dggggd#..",   # 12
    "..#dggggd#..",   # 13
    "..#ddggdd#..",   # 14 kaca meredup ke bawah
    "..########..",   # 15 bibir alas
    ".#HHHHHHHH#.",   # 16 alas logam
    ".#MMMMMMMM#.",   # 17
    ".#LLLLLLLL#.",   # 18
    "..########..",   # 19 kaki
]

PAL = {
    "#": OUTLINE, "H": MET_HI, "M": MET_MID, "L": MET_LO,
    "g": GLASS, "G": GLASS_HI, "d": GLASS_DIM, ".": NONE,
}

# Topeng cahaya: piksel mana yang MEMANCAR. Logam & outline tidak memancar,
# tapi lampu asli menyinari sekitarnya -> topeng dibuat penuh & lembut,
# BUKAN salinan sprite. Nilai = kuat cahaya 0..3.
GLOW = [
    "............",
    "............",
    "............",
    "............",
    "............",
    "...111111...",
    "..11222211..",
    "..12222221..",
    ".1223333221.",
    ".1233333321.",
    ".1233333321.",
    ".1233333321.",
    ".1233333321.",
    ".1233333321.",
    "..12333321..",
    "..11222211..",
    "...111111...",
    "....1111....",
    "............",
    "............",
]
GLOW_LV = {
    "0": NONE,
    "1": (0xDC, 0xB4, 0x6E, 90),
    "2": (0xFF, 0xE0, 0x8C, 175),
    "3": (0xFF, 0xF8, 0xD2, 255),
}


def _render(rows, palette, name):
    assert len(rows) == H, "%s: %d baris, harus %d" % (name, len(rows), H)
    img = Image.new("RGBA", (W, H), NONE)
    px = img.load()
    for y, row in enumerate(rows):
        assert len(row) == W, "%s baris %d: %d kolom, harus %d" % (name, y, len(row), W)
        for x, ch in enumerate(row):
            c = palette.get(ch)
            if c is None:
                raise KeyError("%s: karakter tak dikenal %r di (%d,%d)" % (name, ch, x, y))
            px[x, y] = c
    return img


def main():
    lantern = _render(ART, PAL, "lantern")
    lantern.save(os.path.join(OUTDIR, "lantern.png"))

    glow = _render(GLOW, {".": NONE, **GLOW_LV}, "lantern_glow")
    glow.save(os.path.join(OUTDIR, "lantern_glow.png"))

    print("lantern.png %dx%d + lantern_glow.png -> %s" % (W, H, OUTDIR))


if __name__ == "__main__":
    main()
