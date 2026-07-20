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


# ---------------------------------------------------------------- salin utuh
# Sebagian pack ULPC sudah dikirim sebagai lembar penuh (832x2944) atau lembar
# klasik (832x1344, ditempel rata-atas oleh assemble.py). Lapisan itu tak perlu
# dijahit — cuma perlu DIKELUARKAN dari zip. Dicatat di sini, bukan disalin tangan,
# supaya #240 tetap berlaku: tiap PNG di pustaka punya baris yang membuatnya.
#
# (zip, entry di dalam zip, nama keluaran)
COPIES = [
    # --- tutup kepala: SATU-SATUNYA tuas siluet yang cukup besar di LPC ---
    #     Diukur pada frame hadap-bawah, di luar siluet pria berpakaian:
    #       feather_cap 164 px | hood 73 px | hood_sack 24 px | bandana 0 px
    #       celana/sepatu/baju  0 px  <- pakaian LPC dilukis DI DALAM garis badan
    #     Itu sebabnya "potongan baju berbeda" tak bisa memisahkan siluet siapa pun.
    ("lpc-2024-12-10-expanded-ulpc-facial-assets.zip",
     "hat/cloth/feather_cap/adult/walnut.png", "eulpc_hat_feather_cap_walnut"),
    ("lpc-2024-12-10-expanded-ulpc-facial-assets.zip",
     "hat/cloth/hood/adult/charcoal.png", "eulpc_hat_hood_charcoal"),
    # kerudung ULPC asli. `hijabgrey.png` lama berbentuk sama persis (XOR 0 px) tapi
    # dibayang ABU — dari jauh terbaca RAMBUT kelabu, bukan kain. Bentuk bukan
    # masalahnya; warna yang jadi masalah. Varian `thin` + warna jenuh membaca kain.
    ("lpc-2024-12-10-expanded-ulpc-facial-assets.zip",
     "hat/cloth/hijab/thin/navy.png", "eulpc_hijab_navy"),

    # --- rambut BERUBAN ASLI ---
    #     `_tint` adalah MULTIPLY: ia cuma bisa menggelapkan. `tint.hair = "#d8d4cc"`
    #     di atas rambut oranye tetap oranye — gagal DIAM-DIAM, tak ada galat.
    #     Rambut tua/pirang WAJIB lapisan warna asli, bukan tint. Berlaku umum,
    #     bukan cuma untuk Bram.
    ("hairstyles-2024-03-10.zip",
     "longknot/universal/adult_universal_hair_longknot/white.png", "eulpc_hair_longknot_white"),
    ("hairstyles-2024-03-10.zip",
     "longknot/universal/adult_universal_hair_longknot/ash.png", "eulpc_hair_longknot_ash"),
    ("hairstyles-2024-03-10.zip",
     "shortknot/universal/adult_universal_hair_shortknot/gray.png", "eulpc_hair_shortknot_gray"),
    ("hairstyles-2024-03-10.zip",
     "jewfro/universal/adult_universal_hair_jewfro/ash.png", "eulpc_hair_jewfro_ash"),

    # --- rambut ANAK (832x2944, langsung pakai) ---
    ("lpc-2024-11-09-redrawn-topknot-hairstyles.zip",
     "hair/jewfro/child/chestnut.png", "eulpc_hair_child_jewfro_chestnut"),
    ("lpc-2024-11-09-redrawn-topknot-hairstyles.zip",
     "hair/swoop_side/child/black.png", "eulpc_hair_child_swoop_black"),
    # topknot_short, BUKAN parted_side_bangs. Diukur: parted* nyaris rata dgn tempurung
    # kepala (massa 5 px di luar siluet) — tiga anak berambut rata = tiga anak kembar.
    # Tiga terjauh yang tersedia: topknot_short / jewfro / swoop_side (60, 53, 53 px).
    ("lpc-2024-11-09-redrawn-topknot-hairstyles.zip",
     "hair/extensions/ponytails/topknot_short/child/gold.png", "eulpc_hair_child_topknot_gold"),
]


# ------------------------------------------------------- jahit sebagian animasi
# Celana anak cuma dikirim untuk `walk`. Tak ada slash, tak ada yang lain.
# Dijahit apa adanya: baris walk terisi, baris slash TETAP TRANSPARAN.
#
# AKIBAT YANG DITERIMA SADAR: kalau seorang anak pernah memainkan animasi slash,
# ia akan tampil tanpa celana di frame itu. Anak Ashbrook tak pernah menyerang
# (AshbrookKid.gd cuma berjalan mengejar ayam), jadi baris itu tak pernah dibaca.
# Kalau suatu saat anak diberi animasi lain, INI yang pecah lebih dulu.
#
# (zip, {anim: entry}, nama keluaran)
PIECES = [
    ("lpc-2025-02-03-expanded-ulpc-pants-cleaned-split.zip",
     {"walk": "pants/child/walk/brown.png"}, "eulpc_legs_child_pants_brown"),
    ("lpc-2025-02-03-expanded-ulpc-pants-cleaned-split.zip",
     {"walk": "pants/child/walk/darkblue.png"}, "eulpc_legs_child_pants_darkblue"),
    ("lpc-2025-02-03-expanded-ulpc-pants-cleaned-split.zip",
     {"walk": "pants/child/walk/green.png"}, "eulpc_legs_child_pants_green"),
]


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
    for zname, entry, out in COPIES:
        try:
            zf = _zip(zname)
            if entry not in zf.namelist():
                raise LayerError(f"tak ada di zip {zname}: {entry}")
            im = Image.open(io.BytesIO(zf.read(entry))).convert("RGBA")
            w, h = im.size
            if w != SHEET_W or h not in (1344, SHEET_H):
                raise LayerError(f"{entry}: {w}x{h} bukan lembar LPC (832x1344 / 832x2944).")
            im.save(os.path.join(LIB, out + ".png"))
            print(f"[SALIN] {out}.png  ({w}x{h})")
            ok += 1
        except LayerError as e:
            print(f"[GAGAL] {out}: {e}", file=sys.stderr)
    for zname, potongan, out in PIECES:
        try:
            zf = _zip(zname)
            canvas = Image.new("RGBA", (SHEET_W, SHEET_H), (0, 0, 0, 0))
            for anim, entry in potongan.items():
                if entry not in zf.namelist():
                    raise LayerError(f"tak ada di zip {zname}: {entry}")
                im = Image.open(io.BytesIO(zf.read(entry))).convert("RGBA")
                if im.height != 4 * CELL:
                    raise LayerError(f"{entry}: tinggi {im.height} bukan 4 baris arah.")
                canvas.alpha_composite(im, (0, ANIM_ROW[anim] * CELL))
            canvas.save(os.path.join(LIB, out + ".png"))
            kosong = sorted(set(ANIM_ROW) - set(potongan))
            print(f"[SEBAGIAN] {out}.png  terisi={sorted(potongan)} KOSONG={kosong}")
            ok += 1
        except LayerError as e:
            print(f"[GAGAL] {out}: {e}", file=sys.stderr)
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
    total = len(JOBS) + len(COPIES) + len(PIECES)
    print(f"\n{ok}/{total} lapisan siap -> {LIB}")
    return 0 if ok == total else 2


if __name__ == "__main__":
    sys.exit(main())
