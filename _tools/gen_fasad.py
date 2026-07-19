#!/usr/bin/env python3
"""Fasad TINGGI bergaya Suikoden untuk Ashbrook64 (#254 · LANGKAH 5c · HUKUM #240).

Putusan lisensi Direktur — opsi (1), nol CC-BY-SA, nol beli:
  • dinding + atap : LPC Revised 4-Seasons  — **OGA-BY 3.0** (atribusi, TAK menular)
                     JaidynReiman, dari LPC Revised (Eliza Wyatt/DeathsDarling dkk)
                     https://opengameart.org/content/lpc-revised-fully-configured-4-seasons-tilesets-for-tiled-map-editor
                     Kredit resmi: https://github.com/ElizaWy/LPC/blob/main/Credits.txt
                     Diverifikasi verbatim: "This pack is licensed OGA-BY 3.0."
  • PINTU          : **DIGAMBAR SENDIRI di berkas ini** — milik penuh Aetherion.
                     bluecarrot16 ([LPC] Windows & Doors) DITOLAK: CC-BY-SA menular.

Kenapa fasad dirakit, bukan dipakai apa adanya: LPC Revised memberi ubin dinding,
lereng atap, dan lengkung bukaan — TAPI tak memberi "rumah jadi". Bangunan yang
menjulang harus disusun. Itu isi berkas ini.

Keluaran → game/assets/game/sprites/lpc32/
  fasad_inn.png   — rumah singgah Merrit (5x7 petak = 160x224 px)
  fasad_shop.png  — toko Otha, tutup dua musim (4x6 petak = 128x192 px)

Proporsi sasaran: karakter LPC ~1,5 petak (5b). Fasad 6-7 petak → bangunan
**4-5x tinggi karakter**. Itu rasa Suikoden: kota yang menjulang di atas orang.
"""
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
SRC = os.path.join(REPO, "assets_raw", "lpc_revised", "lpc-tileset-buildings.png")
OUT = os.path.join(REPO, "game", "assets", "game", "sprites", "lpc32")
T = 32

# --- petak sumber (koordinat diverifikasi dari kisi berlabel) ---
WALL_LIGHT = (2, 6)     # bata terang polos — badan bangunan
WALL_DARK = (2, 9)      # bata gelap — lantai dasar / toko tutup
ROOF_FACE = (41, 1)     # permukaan atap bergenteng (blok warna kanan atlas)
ROOF_RIDGE = (41, 0)    # bubungan / tepi atas
ARCH_TOP = (2, 24)      # lengkung bukaan — bagian atas
ARCH_BOT = (2, 25)      # lengkung bukaan — bagian bawah

# --- palet PINTU (milik sendiri; diambil dari kayu Aetherion yang sudah ada) ---
D_OUT = (0x1E, 0x16, 0x12, 255)   # outline — sama dgn signboard/street_lamp
D_DARK = (0x46, 0x32, 0x1E, 255)
D_MID = (0x5A, 0x42, 0x28, 255)
D_LIT = (0x78, 0x54, 0x30, 255)
D_IRON = (0x46, 0x42, 0x4A, 255)  # engsel/gagang — logam street_lamp


def tile(src, cr):
    c, r = cr
    return src.crop((c * T, r * T, (c + 1) * T, (r + 1) * T))


def band(src, cr, cols):
    """Satu baris petak yang diulang mendatar."""
    t = tile(src, cr)
    row = Image.new("RGBA", (cols * T, T), (0, 0, 0, 0))
    for c in range(cols):
        row.paste(t, (c * T, 0))
    return row


def draw_door(w=32, h=48):
    """PINTU — digambar sendiri, bukan diambil dari pack (putusan lisensi #254).

    Papan vertikal + dua palang + engsel besi. Sengaja gelap & sederhana supaya
    terbaca sebagai LUBANG MASUK pada jarak main, bukan ornamen.
    """
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    for y in range(h):
        for x in range(w):
            px[x, y] = D_MID
    # papan vertikal: garis gelap tiap 6 px
    for x in range(0, w, 6):
        for y in range(h):
            px[x, y] = D_DARK
    # dua palang mendatar
    for y in (h // 3, 2 * h // 3):
        for x in range(w):
            px[x, y] = D_LIT
            px[x, y + 1] = D_DARK
    # bingkai
    for x in range(w):
        px[x, 0] = D_OUT
        px[x, h - 1] = D_OUT
    for y in range(h):
        px[0, y] = D_OUT
        px[w - 1, y] = D_OUT
    # engsel + gagang besi
    for y in (h // 4, 3 * h // 4):
        for x in range(2, 7):
            px[x, y] = D_IRON
    px[w - 7, h // 2] = D_IRON
    px[w - 6, h // 2] = D_IRON
    return im


def facade(src, cols, wall_rows, wall_tile, roof_rows=2, door=True, name=""):
    """Susun fasad menjulang: bubungan → muka atap → dinding → (pintu)."""
    rows = roof_rows + wall_rows
    im = Image.new("RGBA", (cols * T, rows * T), (0, 0, 0, 0))
    # atap
    im.paste(band(src, ROOF_RIDGE, cols), (0, 0))
    for r in range(1, roof_rows):
        im.paste(band(src, ROOF_FACE, cols), (0, r * T))
    # dinding
    for r in range(roof_rows, rows):
        im.paste(band(src, wall_tile, cols), (0, r * T))
    # lengkung + pintu di tengah, menempel tanah
    if door:
        cx = (cols // 2) * T
        base = rows * T
        im.paste(tile(src, ARCH_TOP), (cx, base - 2 * T))
        im.paste(tile(src, ARCH_BOT), (cx, base - T))
        d = draw_door(T, 48)
        im.alpha_composite(d, (cx, base - 48))
    print("  %-14s %3dx%-3d  (%dx%d petak)" % (name, im.width, im.height, cols, rows))
    return im


def main():
    os.makedirs(OUT, exist_ok=True)
    src = Image.open(SRC).convert("RGBA")
    facade(src, 5, 5, WALL_LIGHT, 2, True, "fasad_inn").save(os.path.join(OUT, "fasad_inn.png"))
    facade(src, 4, 4, WALL_DARK, 2, True, "fasad_shop").save(os.path.join(OUT, "fasad_shop.png"))
    draw_door(T, 48).save(os.path.join(OUT, "pintu.png"))
    print("fasad + pintu -> %s" % OUT)


if __name__ == "__main__":
    main()
