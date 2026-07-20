#!/usr/bin/env python3
"""Penjahit lapisan ULPC modular -> format sheet 832x2944 yang dimengerti assemble.py.

MASALAH YANG DIPECAHKAN
-----------------------
Unduhan ULPC modular (`longsleeve-shirts.zip` dll) datang **terpecah per-animasi**:
`walk.png` 576x256, `slash.png` 384x256, `thrust.png` 512x256 ... Sementara `assemble.py`
menolak apa pun yang lebarnya bukan 832 (spec: perakit tak menebak alignment). Akibatnya
seluruh lemari pakaian di gudang tak terjangkau mesin, dan katalog #239 cuma memuat **tiga**
torso — dua di antaranya TANPA LENGAN. Itu sebabnya enam tokoh Ashbrook berlengan telanjang.

Skrip ini menjahit potongan per-animasi kembali ke kanvas ULPC-expanded 832x2944 pada
BARIS KANONIK, sehingga lapisan hasil jahitan sejajar frame-per-frame dengan `eulpc_*`
yang sudah ada.

BARIS YANG DIJAHIT — hanya yang benar-benar dipakai `frame_map.json`:
  walk  -> baris  8..11   (juga sumber `idle`, frame kolom 0)
  slash -> baris 12..15
Animasi lain sengaja DILEWATI: `sit` masih `calibrate:true` (belum dikalibrasi visual),
sisanya tak pernah di-slice. Menjahit yang tak dipakai = berat tanpa guna.

#240: skrip ini ter-commit bersama aset yang dihasilkannya. Keluarannya mendarat di
`assets_raw/lpc_extra/` (gitignored, sama dgn `eulpc_*` lain) — yang MASUK repo adalah
sprite jadi di `game/assets/game/sprites/characters/`, dirakit `assemble.py`.

Pemakaian:
  python gen_layers.py --list                 # apa saja yang tersedia di zip
  python gen_layers.py                        # jahit set yang dibutuhkan Ashbrook
"""
import argparse
import io
import os
import sys
import zipfile

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
LIB = os.path.join(REPO_ROOT, "assets_raw", "lpc_extra")

SHEET_W, SHEET_H = 832, 2944
CELL = 64

# animasi -> baris pertama di sheet expanded. Urutan arah dalam berkas sumber = ULPC baku.
ANIM_ROW = {"walk": 8, "slash": 12}


class LayerError(Exception):
    """Kegagalan jahit yang menghentikan build (bukan warning)."""


def _zip(name):
    p = os.path.join(LIB, name)
    if not os.path.exists(p):
        raise LayerError(f"zip sumber hilang: {p}")
    return zipfile.ZipFile(p)


def stitch(zf, variant, sex, color):
    """Jahit satu lapisan pakaian jadi kanvas 832x2944.

    Sumber per-animasi ditempel di baris kanoniknya; sisa kanvas tetap transparan.
    Transparan = "lapisan ini tak punya apa-apa di animasi itu", persis yang diinginkan
    alpha_composite di assemble.py.
    """
    canvas = Image.new("RGBA", (SHEET_W, SHEET_H), (0, 0, 0, 0))
    found = 0
    for anim, row0 in ANIM_ROW.items():
        entry = f"{variant.split('/')[0]}/{variant}/{sex}/{anim}/{color}.png"
        if entry not in zf.namelist():
            raise LayerError(f"tak ada di zip: {entry}")
        im = Image.open(io.BytesIO(zf.read(entry))).convert("RGBA")
        w, h = im.size
        if h != 4 * CELL:
            raise LayerError(f"{entry}: tinggi {h} bukan 4 baris arah — format tak dikenal.")
        if w > SHEET_W:
            raise LayerError(f"{entry}: lebar {w} > {SHEET_W}.")
        canvas.alpha_composite(im, (0, row0 * CELL))
        found += 1
    if found != len(ANIM_ROW):
        raise LayerError("tidak semua animasi terjahit")
    return canvas


# (zip, variant, sex, color, nama keluaran)
# Warna dipilih supaya enam tokoh TIDAK seragam — desa dihuni orang berbeda.
JOBS = [
    ("longsleeve-shirts.zip", "longsleeve", "male", "slate", "eulpc_torso_longsleeve_male_slate"),
    ("longsleeve-shirts.zip", "longsleeve", "male", "white", "eulpc_torso_longsleeve_male_white"),
    ("longsleeve-shirts.zip", "longsleeve", "male", "walnut", "eulpc_torso_longsleeve_male_walnut"),
    ("longsleeve-shirts.zip", "longsleeve", "male", "forest", "eulpc_torso_longsleeve_male_forest"),
    ("longsleeve-shirts.zip", "longsleeve", "male", "maroon", "eulpc_torso_longsleeve_male_maroon"),
    ("longsleeve-shirts.zip", "longsleeve", "female", "maroon", "eulpc_torso_longsleeve_female_maroon"),
    ("longsleeve-shirts.zip", "longsleeve", "female", "charcoal", "eulpc_torso_longsleeve_female_charcoal"),
    ("longsleeve-shirts.zip", "longsleeve", "female", "forest", "eulpc_torso_longsleeve_female_forest"),
    ("longsleeve-shirts.zip", "longsleeve", "female", "sky", "eulpc_torso_longsleeve_female_sky"),
    ("longsleeve-shirts.zip", "longsleeve", "teen", "teal", "eulpc_torso_longsleeve_teen_teal"),
    ("longsleeve-shirts.zip", "longsleeve", "teen", "rose", "eulpc_torso_longsleeve_teen_rose"),
    # anak memakai potongan `teen` — pustaka ULPC tak punya baris `child` untuk kemeja ini;
    # badan anak lebih pendek, jadi kemeja teen menggantung. Dipakai HANYA bila terbukti
    # sejajar di uji visual; kalau tidak, anak pakai overall/rompi yang ada.
]


def main(argv=None):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Penjahit lapisan ULPC modular -> 832x2944.")
    ap.add_argument("--list", action="store_true", help="daftar variant/sex/warna yang tersedia")
    args = ap.parse_args(argv)

    if args.list:
        zf = _zip("longsleeve-shirts.zip")
        names = zf.namelist()
        variants = sorted({n.split("/")[1] for n in names if n.count("/") > 2})
        sexes = sorted({n.split("/")[2] for n in names if n.count("/") > 2})
        colors = sorted({os.path.basename(n)[:-4] for n in names
                         if n.startswith("longsleeve/longsleeve/male/walk/") and n.endswith(".png")})
        print("variant:", variants)
        print("sex    :", sexes)
        print("warna  :", colors)
        return 0

    os.makedirs(LIB, exist_ok=True)
    ok = 0
    for zname, variant, sex, color, out in JOBS:
        try:
            zf = _zip(zname)
            sheet = stitch(zf, variant, sex, color)
            dst = os.path.join(LIB, out + ".png")
            sheet.save(dst)
            print(f"[OK] {out}.png  ({variant}/{sex}/{color})")
            ok += 1
        except LayerError as e:
            print(f"[GAGAL] {out}: {e}", file=sys.stderr)
    print(f"\n{ok}/{len(JOBS)} lapisan dijahit -> {LIB}")
    return 0 if ok == len(JOBS) else 2


if __name__ == "__main__":
    sys.exit(main())
