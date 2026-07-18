#!/usr/bin/env python3
"""Turunkan 3 varian papan nama Otha dari signboard.png (design-time, #240).

Sumber: game/assets/game/sprites/props/signboard.png — NON-LPC (aset game sendiri,
lolos audit provenance #247). #232: objek TAK BOLEH turunan LPC → aman.

3 varian (Hukum Bukti #226, adegan A1 — bukti `akibat`):
  1. otha_sign_written   — BERTULISAN: cat biru pudar ("OTHA — JAHIT & TAMBAL")
  2. otha_sign_fadedmark — KOSONG + BEKAS CAT  ← INI MEKANIKNYA (ev_otha_papan_bekas_cat)
       kayu pudar 34 musim KECUALI persegi di tengah (terlindung di bawah tulisan) =
       persegi LEBIH GELAP. Papan bersih tanpa bekas = bukti MATI = Otha tak terpulihkan.
  3. otha_sign_plain     — KAYU POLOS: setelah bekas pudar habis (R3, hari 60)

Hukum bekas: yang terbaca = KONTRAS & BENTUK (persegi gelap), bukan detail sub-piksel.
"""
import os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
SRC = os.path.join(REPO, "game", "assets", "game", "sprites", "props", "signboard.png")
OUTDIR = os.path.join(REPO, "game", "assets", "game", "sprites", "props")

BLEACH = (183, 172, 152)   # kayu terbakar matahari (abu hangat)


def _is_face(px, x, y):
    r, g, b, a = px[x, y]
    return a > 200 and (r + g + b) // 3 > 100   # muka kayu terang, bukan bingkai gelap


def _bleach(c, amt):
    r, g, b, a = c
    return (
        int(r + (BLEACH[0] - r) * amt),
        int(g + (BLEACH[1] - g) * amt),
        int(b + (BLEACH[2] - b) * amt),
        a,
    )


def main():
    base = Image.open(SRC).convert("RGBA")
    W, H = base.size
    bpx = base.load()

    # kotak "bekas" tengah (tempat cat/tulisan melindungi kayu 34 tahun)
    mx0, mx1 = W // 2 - 4, W // 2 + 3
    my0, my1 = H // 2 - 2, H // 2 + 3

    # --- varian 1: BERTULISAN (cat biru pudar) ---
    v1 = base.copy()
    p1 = v1.load()
    blue = (86, 104, 150)
    for ty in (H // 2 - 2, H // 2, H // 2 + 2):          # 3 baris "tulisan"
        for x in range(3, W - 3):
            if _is_face(bpx, x, ty) and x % 2 == 0:      # goresan putus = kesan huruf
                r, g, b, a = p1[x, ty]
                p1[x, ty] = (int((r + blue[0]) / 2), int((g + blue[1]) / 2), int((b + blue[2]) / 2), a)
    v1.save(os.path.join(OUTDIR, "otha_sign_written.png"))

    # --- varian 2: KOSONG + BEKAS CAT (persegi lebih GELAP di tengah) ---
    v2 = base.copy()
    p2 = v2.load()
    for y in range(H):
        for x in range(W):
            if not _is_face(bpx, x, y):
                continue
            in_mark = (mx0 <= x <= mx1) and (my0 <= y <= my1)
            if in_mark:
                p2[x, y] = bpx[x, y]                     # kayu asli (lebih gelap) — terlindung
            else:
                p2[x, y] = _bleach(bpx[x, y], 0.62)      # sekelilingnya pudar
    v2.save(os.path.join(OUTDIR, "otha_sign_fadedmark.png"))

    # --- varian 3: KAYU POLOS (bekas sudah pudar habis) ---
    v3 = base.copy()
    p3 = v3.load()
    for y in range(H):
        for x in range(W):
            if _is_face(bpx, x, y):
                p3[x, y] = _bleach(bpx[x, y], 0.62)      # seragam, tanpa bekas
    v3.save(os.path.join(OUTDIR, "otha_sign_plain.png"))

    print("3 varian papan Otha -> %s" % OUTDIR)


if __name__ == "__main__":
    main()
