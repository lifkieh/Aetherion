#!/usr/bin/env python3
"""Peta 30-detik untuk SELF-PLAYTEST Ashbrook64 (#240 - script ikut ter-commit).

Bukan peta dalam-game. Ini lembar contekan Direktur supaya ia tak tersesat saat
menguji loop payoff sendiri: di mana ia muncul, ke mana berjalan, tombol apa.

Seluruh koordinat DITURUNKAN dari konstanta di `game/scenes/world/Ashbrook64.gd`.
Kalau scene digeser, jalankan ulang berkas ini - jangan sunting gambarnya.

Keluaran -> reports/preview/peta_playtest_ashbrook64.png
"""
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
OUT = os.path.join(REPO, "reports", "preview", "peta_playtest_ashbrook64.png")

# --- konstanta yang MENCERMINKAN Ashbrook64.gd (jangan diubah sepihak) ---
TILE = 32
MAP_W, MAP_H = 60, 34
VC = (960, 704)
MERRIT_HOUSE = (464, 752)
SPAWN = (MERRIT_HOUSE[0] + 96, MERRIT_HOUSE[1] + 64)

BUILDINGS = [
    ("Rumah singgah Merrit", MERRIT_HOUSE, (160, 224)),
    ("Gudang gandum", (704, 400), (160, 192)),
    ("Toko Otha (tutup)", (1216, 480), (96, 192)),
    ("Rumah kosong", (1408, 800), (96, 192)),
    ("Rumah Lyra", (640, 992), (160, 192)),
]

# nomor · koordinat · jenis bukti · halaman · nama pendek
POINTS = [
    (1, (704, 480), "akibat", "Ashbrook", "Gudang gandum\n(4 ayam di gudang 40 orang)"),
    (2, (1216, 560), "kebiasaan", "Ashbrook", "200 roti Halloran\ntiap pagi"),
    (3, (1216, 664), "akibat", "OTHA", "Papan Otha\n(bekas cat)"),
    (4, (800, 856), "benda", "Ashbrook", "Batu fondasi\nberpahat"),
    (5, (1504, 1056), "akibat", "Ashbrook", "Garis fondasi\ndi rumput"),
    (6, (1856, 704), "akibat", "Ashbrook", "Jembatan\nterlalu lebar"),
]

BG = (26, 32, 26)
GRASS = (58, 84, 52)
ROAD = (104, 100, 92)
PLAZA = (120, 112, 104)
INK = (238, 240, 232)
DIM = (150, 158, 146)
GOLD = (255, 214, 108)
CYAN = (120, 220, 235)
RED = (240, 120, 110)

S = 0.5          # skala peta: 1920x1088 -> 960x544
PAD_L, PAD_T = 40, 96
PANEL_W = 470    # panel keterangan di kanan


def f(size, bold=False):
    for name in (("consolab.ttf", "consola.ttf") if not bold else ("consolab.ttf",)):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def x(v):
    return PAD_L + int(v * S)


def y(v):
    return PAD_T + int(v * S)


def main():
    w = PAD_L * 2 + int(MAP_W * TILE * S) + PANEL_W
    h = PAD_T + int(MAP_H * TILE * S) + 60
    im = Image.new("RGB", (w, h), BG)
    d = ImageDraw.Draw(im)

    # tanah
    d.rectangle([x(0), y(0), x(MAP_W * TILE), y(MAP_H * TILE)], fill=GRASS)
    # jalan dagang barat-timur
    d.rectangle([x(0), y(VC[1] - 48), x(MAP_W * TILE), y(VC[1] + 48)], fill=ROAD)
    # alun-alun
    d.rectangle([x(VC[0] - 272), y(VC[1] - 176), x(VC[0] + 272), y(VC[1] + 176)], fill=PLAZA)

    # bangunan (kaki = titik tambat, lihat _building())
    fb = f(11)
    for name, foot, size in BUILDINGS:
        x0, y0 = foot[0] - size[0] // 2, foot[1] - size[1]
        d.rectangle([x(x0), y(y0), x(x0 + size[0]), y(y0 + size[1])],
                    fill=(46, 40, 36), outline=(96, 88, 78))
        d.text((x(x0) + 3, y(y0) + 3), name, font=fb, fill=DIM)

    # spawn
    sx, sy = x(SPAWN[0]), y(SPAWN[1])
    d.ellipse([sx - 8, sy - 8, sx + 8, sy + 8], fill=CYAN, outline=INK)
    d.text((sx + 12, sy + 10), "MULAI", font=f(13, True), fill=CYAN)

    # titik-periksa
    fn = f(15, True)
    for n, pos, kind, page, _label in POINTS:
        px, py = x(pos[0]), y(pos[1])
        col = GOLD if page == "Ashbrook" else RED
        if not (0 <= pos[0] <= MAP_W * TILE and 0 <= pos[1] <= MAP_H * TILE):
            d.text((px - 46, py + 14), "DI LUAR PETA", font=f(11, True), fill=RED)
        d.ellipse([px - 11, py - 11, px + 11, py + 11], fill=col, outline=(20, 20, 20), width=2)
        tw = d.textlength(str(n), font=fn)
        d.text((px - tw / 2, py - 9), str(n), font=fn, fill=(20, 20, 20))

    # judul
    d.text((PAD_L, 24), "ASHBROOK64 — PETA SELF-PLAYTEST", font=f(24, True), fill=INK)
    d.text((PAD_L, 56), "Main Baru → Class → Creator → Intro → Ashbrook64. "
                        "Koordinat = dunia, sama dgn Ashbrook64.gd.", font=f(13), fill=DIM)

    # ---- panel keterangan ----
    bx = PAD_L + int(MAP_W * TILE * S) + 24
    ty = PAD_T
    ft = f(14, True)
    fs = f(13)

    def line(txt, font=fs, col=INK, dy=19):
        nonlocal ty
        d.text((bx, ty), txt, font=font, fill=col)
        ty += dy

    line("TOMBOL", ft, GOLD)
    line("WASD  jalan")
    line("E     periksa (berdiri dekat titik)")
    line("E     tutup teks periksa")
    line("I     buka tas → tab KITAB")
    ty += 10

    line("TITIK-PERIKSA", ft, GOLD)
    for n, pos, kind, page, label in POINTS:
        col = GOLD if page == "Ashbrook" else RED
        flat = label.replace("\n", " ")
        line("%d. (%d,%d) %-9s %s" % (n, pos[0], pos[1], kind, flat), fs, col, 17)
    ty += 4
    line("kuning = halaman Ashbrook · merah = halaman Otha", fs, DIM, 17)
    line("titik 5 ADA DI LUAR batas tanah (y=1152 > 1088) — tetap", fs, RED, 15)
    line("terjangkau (nol tabrakan), tapi berdiri di atas kekosongan.", fs, RED, 22)

    line("MINIMUM UNTUK MENULIS ULANG", ft, GOLD)
    line("SENDIRI  : 3 JENIS bukti  → titik 1 + 2 + 4")
    line("ELYN     : 2 JENIS bukti  → titik 1 + 2")
    line("(jenis, bukan jumlah — 3 'akibat' tetap 1 jenis)", fs, DIM)
    ty += 10

    line("LANGKAH LOOP", ft, GOLD)
    for s in ["1. Kumpulkan bukti (E di tiap titik)",
              "2. I → tab Kitab",
              "3. Halaman TERCORET 'Ashbrook — kota yang dulu besar'",
              "4. Tulis ulang → pilih jalur",
              "5a. Simpan sendiri  (butuh 3 jenis)",
              "5b. Biarkan Elyn menanggung (keterbukaan dulu)",
              "6. Halaman pulih + baris yang TIDAK kembali"]:
        line(s, fs, INK, 18)

    im.save(OUT)
    print("peta -> %s  (%dx%d)" % (OUT, im.width, im.height))


if __name__ == "__main__":
    main()
