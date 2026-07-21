# -*- coding: utf-8 -*-
"""Lembar rujukan BADAN DASAR karakter + diagnosis "kaki kelebaran" (#240).

KENAPA BADAN DIGAMBAR TANPA KEPALA
----------------------------------
Di ULPC/eulpc, `body` dan `head` adalah DUA LAPIS TERPISAH. Badan dasar memang
berhenti di leher; kepala ditumpuk sesudahnya. Jadi lembar A & B di bawah yang
tampak "tanpa kepala" bukan potongan yang salah — itulah wujud badan dasarnya.

DUA LEMBAR
----------
A · BASE_01_semua.png        — 4 badan yang dipakai perakit + 8 badan yang ADA di
                               pack ULPC v3.1 (4 di antaranya belum tersambung).
B · BASE_02_kaki_vs_celana.png — badan male polos vs `pants_thin` (yang dipakai
                               sekarang) vs `pants_male` (yang menganggur di disk),
                               tiga frame jalan-bawah berdampingan.

TEMUAN YANG DIBUKTIKAN LEMBAR B
-------------------------------
Semua tokoh dewasa memakai pakaian build **thin** di atas badan **male/female**
standar. Lebar pada baris jalan-bawah (metode ukur SAMA untuk keduanya):

    eulpc_legs_pants_thin.png   16 px
    eulpc_legs_pants_male_*.png 20 px   <- 25% lebih lebar, ADA di disk, nol dipakai

Akibatnya pinggul & paha badan menyembul di luar celana — persis "kaki kelebaran
dengan baju dan celana". Torso tidak kena: `eulpc_torso_*` selebar badan (30 px).

Pemakaian:
  python gen_lembar_karakter.py
"""
import io
import json
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
LIB = os.path.join(REPO, "assets_raw", "lpc_extra")
ZIP_BASES = os.path.join(REPO, "assets_raw", "lpc", "lpc-character-bases-v3_1.zip")
OUT = os.path.join(REPO, "reports", "preview", "karakter")

## Baris 10 = jalan-hadap-bawah (frame_map.json: walk.rows.down = 10).
## Dipakai untuk SEMUA perbandingan supaya angka lebarnya sebanding.
ROW = 10
CELL = 64


def _f(n, tebal=False):
    for nama in (("consolab.ttf", "consola.ttf") if tebal else ("consola.ttf",)):
        try:
            return ImageFont.truetype(nama, n)
        except OSError:
            continue
    return ImageFont.load_default()


def papan(w, h, k=8):
    """Papan catur — supaya alfa terbaca. Badan LPC banyak bagian tembus."""
    im = Image.new("RGBA", (w, h), (104, 106, 110, 255))
    d = ImageDraw.Draw(im)
    for y in range(0, h, k):
        for x in range(0, w, k):
            if (x // k + y // k) % 2:
                d.rectangle([x, y, x + k - 1, y + k - 1], fill=(138, 140, 144, 255))
    return im


def sel(path, kolom=0, baris=ROW):
    im = Image.open(path).convert("RGBA")
    if im.height < (baris + 1) * CELL:
        baris = 0
    return im.crop((kolom * CELL, baris * CELL, (kolom + 1) * CELL, (baris + 1) * CELL))


def lebar(path, kolom=0, baris=ROW):
    bb = sel(path, kolom, baris).getbbox()
    return (bb[2] - bb[0]) if bb else 0


# ══════════════════════════════════════════════════ LEMBAR A — semua badan dasar
def lembar_a():
    pakai = []
    for n in ["child", "teen", "female", "male"]:
        p = os.path.join(LIB, "eulpc_body_%s.png" % n)
        pakai.append((n, sel(p), Image.open(p).size))

    pack = []
    if os.path.exists(ZIP_BASES):
        z = zipfile.ZipFile(ZIP_BASES)
        for t in ["male", "female", "muscular", "pregnant", "teen", "child",
                  "skeleton", "zombie"]:
            cand = [x for x in z.namelist() if x.endswith("/bodies/%s/universal.png" % t)]
            if not cand:
                continue
            im = Image.open(io.BytesIO(z.read(cand[0]))).convert("RGBA")
            baris = ROW if im.height >= (ROW + 1) * CELL else 0
            pack.append((t, im.crop((0, baris * CELL, CELL, (baris + 1) * CELL)), im.size))

    ZM, PAD, HDR, CAP = 4, 18, 64, 42
    CW = CELL * ZM

    def blok(judul, data, warna):
        out = Image.new("RGBA", (len(data) * (CW + PAD) + PAD, HDR + CW + CAP), warna)
        d = ImageDraw.Draw(out)
        d.text((PAD, 14), judul, font=_f(19, True), fill=(245, 244, 240))
        x = PAD
        for nama, crop, size in data:
            c = papan(CW, CW)
            c.alpha_composite(crop.resize((CW, CW), Image.NEAREST))
            out.alpha_composite(c, (x, HDR))
            d.text((x, HDR + CW + 6), nama, font=_f(16, True), fill=(250, 240, 200))
            d.text((x, HDR + CW + 24), "%dx%d" % size, font=_f(12), fill=(200, 200, 205))
            x += CW + PAD
        return out

    a = blok("A · BADAN DASAR YANG DIPAKAI PERAKIT SEKARANG — %d" % len(pakai),
             pakai, (30, 52, 40, 255))
    b = blok("B · BADAN DASAR YANG ADA DI PACK ULPC v3.1 — %d (4 belum tersambung)"
             % len(pack), pack, (52, 34, 34, 255))
    W = max(a.width, b.width)
    out = Image.new("RGBA", (W, a.height + b.height + 10), (20, 21, 24, 255))
    out.alpha_composite(a, (0, 0))
    out.alpha_composite(b, (0, a.height + 10))
    p = os.path.join(OUT, "BASE_01_semua.png")
    out.convert("RGB").save(p)
    print("->", p, out.size)


# ═══════════════════════════════════════════ LEMBAR B — kaki vs celana (diagnosis)
def lembar_b():
    def L(n):
        return os.path.join(LIB, n)

    varian = [
        ("badan SAJA (male)", [L("eulpc_body_male.png")]),
        ("+ pants_thin  <- DIPAKAI SEKARANG",
         [L("eulpc_body_male.png"), L("eulpc_legs_pants_thin_navy.png"),
          L("eulpc_feet_shoes_thin.png")]),
        ("+ pants_male  <- ADA DI DISK, MENGANGGUR",
         [L("eulpc_body_male.png"), L("eulpc_legs_pants_male_navy.png"),
          L("eulpc_feet_shoes_thin.png")]),
    ]
    KOL = [0, 2, 4]                     # tiga frame jalan, bukan satu pose diam
    ZM, PAD, HDR, CAP = 6, 16, 58, 30
    CW = CELL * ZM
    w = len(varian) * (len(KOL) * CW + PAD * 2) + PAD
    out = Image.new("RGBA", (w, HDR + CW + CAP), (22, 23, 26, 255))
    d = ImageDraw.Draw(out)
    d.text((PAD, 12), 'KELUHAN "KAKI KELEBARAN" — badan male, tiga frame jalan-bawah',
           font=_f(20, True), fill=(245, 244, 240))
    x = PAD
    for judul, lapis in varian:
        d.text((x, 38), judul, font=_f(15, True), fill=(250, 225, 150))
        for kol in KOL:
            c = papan(CW, CW)
            for p in lapis:
                if os.path.exists(p):
                    c.alpha_composite(sel(p, kol).resize((CW, CW), Image.NEAREST))
            out.alpha_composite(c, (x, HDR))
            x += CW
        x += PAD * 2
    p = os.path.join(OUT, "BASE_02_kaki_vs_celana.png")
    out.convert("RGB").save(p)
    print("->", p, out.size)


def ukur():
    """Angka yang jadi dasar vonis — dicetak supaya bisa dibantah, bukan dipercaya."""
    print("\n=== LEBAR pada baris jalan-bawah (metode sama untuk semua) ===")
    for n in ["eulpc_body_male.png", "eulpc_body_female.png", "eulpc_body_teen.png",
              "eulpc_body_child.png", "eulpc_legs_pants_thin.png",
              "eulpc_legs_pants_male_navy.png", "eulpc_legs_hose_thin.png",
              "eulpc_feet_shoes_thin.png", "eulpc_torso_longsleeve_male_slate.png"]:
        p = os.path.join(LIB, n)
        if os.path.exists(p):
            print("  %-42s %d px" % (n, lebar(p)))

    kar = os.path.join(HERE, "lpc_assembler", "characters")
    if os.path.isdir(kar):
        print("\n=== siapa memakai apa ===")
        for f in sorted(os.listdir(kar)):
            if not f.endswith(".json"):
                continue
            d = json.load(open(os.path.join(kar, f), encoding="utf-8"))
            print("  %-16s body=%-9s legs=%-16s feet=%s"
                  % (f[:-5], d.get("body", "-"), d.get("legs", "-"), d.get("feet", "-")))


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    lembar_a()
    lembar_b()
    ukur()
