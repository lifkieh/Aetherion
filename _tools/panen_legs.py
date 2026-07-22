# -*- coding: utf-8 -*-
"""PANEN `lpc-2025-02-03-expanded-ulpc-pants-cleaned-split.zip` -> pustaka lemari.

UTANG YANG DIBAYAR
------------------
`male legs: 4 pilihan` — empat, sementara female punya 55. Setiap warga lelaki
Ashbrook memakai salah satu dari empat celana yang sama, dan itu terlihat.

Zip ini sudah di disk sejak lama, 10.209 PNG, tak pernah dibongkar. Ini KETIGA
KALINYA pola yang sama muncul dalam satu sesi: sepatu male, 961 pakaian, sekarang
celana. Tiap kali lubangnya dilaporkan sebagai kekurangan pustaka, dan tiap kali
barangnya sudah ada — cuma di dalam zip yang tak pernah dibuka.

Pelajaran yang layak ditulis: **"pustaka kita cuma punya N" hampir selalu berarti
"kita baru memindai N", bukan "N yang ada."**

BENTUK SUMBER
-------------
`<garmen>/<build>/<anim>/<warna>.png` 576x256 — per-animasi, sama dengan pak feet.
Karena itu berkas ini mendekati kembar `panen_feet.py`, dan itu DIBIARKAN: keduanya
akan berpisah begitu salah satu paknya berubah bentuk, dan menyatukannya sekarang
cuma memindahkan percabangan ke dalam satu fungsi yang lebih sulit dibaca.

Pakai:
  python panen_legs.py            # tulis ke assets_raw/lpc_extra/
  python panen_legs.py --lihat    # rencana saja
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
                   "lpc-2025-02-03-expanded-ulpc-pants-cleaned-split.zip")
JADI = os.path.join(REPO, "assets_raw", "lpc_extra")

CELL, LEBAR, TINGGI_UNIV, TINGGI_KANON = 64, 832, 1344, 2944
TATA = {
    "spellcast": (0, 4), "thrust": (4, 4), "walk": (8, 4),
    "slash": (12, 4), "shoot": (16, 4), "hurt": (20, 1),
}

## Build yang dipanen. `female` ikut walau lemari memetakan perempuan ke `thin`:
## zip ini punya `pants/female` 26 warna sendiri, dan menolaknya berarti membuang
## barang yang ada karena tabel kita menamainya lain.
BUILD = ["male", "muscular", "thin", "female", "teen", "pregnant", "child"]

## Garmen yang DILEWAT: `pants` dengan build `thin` sudah ada di pustaka dari panen
## sebelumnya dengan nama sama. Ditulis ulang tak berbahaya (isinya sama), jadi tak
## disaring — yang disaring cuma garmen yang tak dipakai lemari.
LEWAT = set()


def susun(z, dasar, warna):
    im = Image.new("RGBA", (LEBAR, TINGGI_UNIV), (0, 0, 0, 0))
    for anim, (baris, arah) in TATA.items():
        nama = "%s/%s/%s.png" % (dasar, anim, warna)
        try:
            src = Image.open(io.BytesIO(z.read(nama))).convert("RGBA")
        except KeyError:
            continue
        # Tinggi KETAT (menentukan baris), lebar longgar (cuma jumlah frame).
        if src.height != arah * CELL:
            raise ValueError("%s: tinggi %d, kanon minta %d"
                             % (nama, src.height, arah * CELL))
        if src.width > LEBAR:
            raise ValueError("%s: lebar %d > %d" % (nama, src.width, LEBAR))
        im.alpha_composite(src, (0, baris * CELL))
    out = Image.new("RGBA", (LEBAR, TINGGI_KANON), (0, 0, 0, 0))
    out.alpha_composite(im, (0, 0))
    return out


def main():
    if not os.path.exists(ZIP):
        print("[GAGAL] zip tak ada: %s" % ZIP, file=sys.stderr)
        return 1
    z = zipfile.ZipFile(ZIP)
    isi = [x for x in z.namelist() if x.endswith(".png") and x.count("/") == 3]

    rencana = {}
    for x in isi:
        garmen, build, anim, warna = x.split("/")
        if anim != "walk" or build not in BUILD or garmen in LEWAT:
            continue
        rencana.setdefault((garmen, build), []).append(warna[:-4])

    total = 0
    for (garmen, build), warna in sorted(rencana.items()):
        warna = sorted(warna)
        if "--lihat" in sys.argv:
            print("  %-18s %-9s %2d warna" % (garmen, build, len(warna)))
            total += len(warna)
            continue
        for w in warna:
            lembar = susun(z, "%s/%s" % (garmen, build), w)
            lembar.save(os.path.join(
                JADI, "eulpc_legs_%s_%s_%s.png" % (garmen, build, w)))
        total += len(warna)
        print("  [TULIS] %-18s %-9s %2d warna" % (garmen, build, len(warna)))

    print("\n%s %d lembar" % ("rencana:" if "--lihat" in sys.argv else "->", total))
    return 0


if __name__ == "__main__":
    sys.exit(main())
