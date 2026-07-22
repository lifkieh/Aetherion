# -*- coding: utf-8 -*-
"""PANEN `lpc-2025-03-08-fixed-feet-assets.zip` -> lembar universal per warna.

KENAPA ALAT KETIGA
------------------
Tiga bentuk sumber, tiga alat, dan itu disengaja:

  ambil_lpc.py       unduh repo generator   — per-animasi, berkas terpisah
  panen_clothing.py  zip lokal              — lembar universal utuh, nol komposisi
  panen_feet.py      zip lokal              — per-animasi DI DALAM zip

Menyatukannya akan memaksa satu jalur kode berpura-pura menangani tiga bentuk yang
cuma sama tujuannya. Yang dibagi bukan kodenya melainkan TABEL BARISNYA — dan tabel
itu memang disalin, karena tiga alat ini boleh berpisah tanpa saling merusak.

APA YANG DIDAPAT
----------------
`shoes`/`boots` revised 32 warna x male|thin, `socks` ankle|high 24 warna x male|thin.
Sebelum ini seluruh proyek punya 2-3 pilihan alas kaki, dan enam warga contoh
bersepatu putih identik.

ANAK TETAP TAK KEBAGIAN, DAN ITU BUKAN KEKURANGAN KITA
------------------------------------------------------
Zip ini pun cuma punya `male` dan `thin`. Tiga sumber bebas kini sepakat: pohon repo
generator, `sheet_definitions/feet_shoes_basic.json` (mendaftarkan female/male/
muscular/pregnant/teen — TIDAK child), dan zip ini. Anak LPC bertelanjang kaki
menurut desain; sepatu anak tak pernah dibuat, jadi tak akan pernah ditemukan.

Pakai:
  python panen_feet.py            # tulis ke assets_raw/lpc_extra/
  python panen_feet.py --lihat    # cetak rencana, tak menulis
"""
import io
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
ZIP = os.path.join(REPO, "assets_raw", "lpc_extra",
                   "lpc-2025-03-08-fixed-feet-assets.zip")
JADI = os.path.join(REPO, "assets_raw", "lpc_extra")

CELL, LEBAR, TINGGI_UNIV, TINGGI_KANON = 64, 832, 1344, 2944

TATA = {
    "spellcast": (0, 4), "thrust": (4, 4), "walk": (8, 4),
    "slash": (12, 4), "shoot": (16, 4), "hurt": (20, 1),
}

## (garmen lemari, prefiks di zip). Nama garmen sengaja BEDA dari yang sudah ada
## (`shoes`, `boots`) supaya panen ini tak menimpa berkas lama diam-diam — kalau yang
## revised ternyata lebih buruk, yang lama masih di tempatnya.
AMBIL = [
    ("shoes2", "shoes/revised"),
    ("boots2", "boots/revised"),
    ("socks_ankle", "socks/ankle"),
    ("socks_high", "socks/high"),
]
BUILD = ["male", "thin"]


def susun(z, dasar, warna):
    im = Image.new("RGBA", (LEBAR, TINGGI_UNIV), (0, 0, 0, 0))
    ada = 0
    for anim, (baris, arah) in TATA.items():
        nama = "%s/%s/%s.png" % (dasar, anim, warna)
        try:
            src = Image.open(io.BytesIO(z.read(nama))).convert("RGBA")
        except KeyError:
            continue
        # TINGGI ketat (ia menentukan BARIS), lebar longgar (cuma jumlah frame).
        if src.height != arah * CELL:
            raise ValueError("%s: tinggi %d, kanon minta %d" % (nama, src.height, arah * CELL))
        if src.width > LEBAR:
            raise ValueError("%s: lebar %d > lembar %d" % (nama, src.width, LEBAR))
        im.alpha_composite(src, (0, baris * CELL))
        ada += 1
    out = Image.new("RGBA", (LEBAR, TINGGI_KANON), (0, 0, 0, 0))
    out.alpha_composite(im, (0, 0))
    return out, ada


def main():
    if not os.path.exists(ZIP):
        print("[GAGAL] zip tak ada: %s" % ZIP, file=sys.stderr)
        return 1
    z = zipfile.ZipFile(ZIP)
    isi = set(z.namelist())
    total = 0
    for garmen, pre in AMBIL:
        for build in BUILD:
            dasar = "%s/%s" % (pre, build)
            warna = sorted({x.split("/")[-1][:-4] for x in isi
                            if x.startswith(dasar + "/walk/") and x.endswith(".png")})
            if not warna:
                print("  [LEWAT] %s/%s — nol warna" % (garmen, build))
                continue
            if "--lihat" in sys.argv:
                print("  %-12s %-5s %2d warna" % (garmen, build, len(warna)))
                total += len(warna)
                continue
            for w in warna:
                lembar, ada = susun(z, dasar, w)
                lembar.save(os.path.join(
                    JADI, "eulpc_feet_%s_%s_%s.png" % (garmen, build, w)))
                total += 1
            print("  [TULIS] %-12s %-5s %2d warna" % (garmen, build, len(warna)))
    print("\n%s %d lembar" % ("rencana:" if "--lihat" in sys.argv else "->", total))
    return 0


if __name__ == "__main__":
    sys.exit(main())
