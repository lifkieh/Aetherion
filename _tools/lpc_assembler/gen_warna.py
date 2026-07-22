# -*- coding: utf-8 -*-
"""WARNA RATA — cache nada rata tiap lembar, untuk uji kontras pakaian vs kulit.

MASALAH YANG DIPECAHKAN
-----------------------
`sleeveless2_scoop` warna `walnut` di atas kulit `bronze` menghasilkan warga yang
tampak BUGIL. Garmennya tergambar dengan benar — diuji dengan merender garmen yang
sama dalam putih, merah, dan hitam: ketiganya jelas tank top. Yang salah cuma satu:
nada kainnya nyaris sama dengan nada kulit pemakainya.

Ini bukan cacat yang bisa ditangkap penjaga mana pun yang sudah ada. Resolver tak
salah (garmen sah untuk build itu), lemari tak salah (berkasnya ada), dan penjaga
siluet #231 buta warna menurut rancangannya. Yang dibutuhkan ukuran yang tak pernah
diambil siapa pun: JARAK WARNA antara kain dan kulit.

KENAPA CACHE, BUKAN DIUKUR SAAT MENGUNDI
----------------------------------------
`rangka.py` dan `gen_npc.py` sengaja MURNI — nol I/O gambar. Mengukur saat mengundi
akan menyeret PIL ke lapis domain dan membuat 35 uji invarian bergantung pada berkas
PNG. Jadi pengukuran dilakukan sekali di sini, hasilnya data biasa, dan pengundi
tetap membaca data.

Cache ini BOLEH usang tanpa bahaya: kalau sebuah berkas tak ada di cache, pengundi
melewati ujinya alih-alih menolak. Uji yang hilang lebih baik daripada uji yang
menolak barang yang benar karena cache-nya ketinggalan.

Pakai:
  python gen_warna.py            # tulis warna_rata.json
"""
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
LIB = os.path.join(REPO, "assets_raw", "lpc_extra")
OUT = os.path.join(HERE, "warna_rata.json")

CELL = 64
## Petak hadap-bawah baris `walk`, frame pertama. Satu petak cukup: nada rata sebuah
## garmen tak berubah antar-frame, dan memindai 46 baris x 13 kolom untuk tiap berkas
## akan membuat alat ini berjalan berjam-jam tanpa menghasilkan angka yang berbeda.
PETAK = (CELL, 10 * CELL, 2 * CELL, 11 * CELL)


def rata(path):
    """Nada rata piksel yang TERLIHAT. Piksel transparan tak ikut — memasukkannya
    akan menarik tiap nada ke hitam sebanding luas kosongnya, dan garmen kecil jadi
    tampak gelap semata-mata karena ia kecil."""
    try:
        im = Image.open(path).convert("RGBA").crop(PETAK)
    except Exception:
        return None
    r = g = b = n = 0
    for px in im.getdata():
        if px[3] < 128:
            continue
        r += px[0]; g += px[1]; b += px[2]; n += 1
    if n < 12:                      # terlalu sedikit piksel -> angkanya tak berarti
        return None
    return [r // n, g // n, b // n, n]


def main():
    hasil = {}
    # pakaian
    for f in sorted(os.listdir(LIB)):
        if f.startswith("eulpc_") and f.endswith(".png"):
            v = rata(os.path.join(LIB, f))
            if v:
                hasil[f] = v
    # kulit: badan per build x nada
    bases = os.path.join(LIB, "bases")
    if os.path.isdir(bases):
        for build in sorted(os.listdir(bases)):
            d = os.path.join(bases, build)
            if not os.path.isdir(d):
                continue
            for f in sorted(os.listdir(d)):
                if f.endswith(".png"):
                    v = rata(os.path.join(d, f))
                    if v:
                        hasil["bases/%s/%s" % (build, f)] = v

    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump({
            "_doc": "Nada rata (R,G,B,jumlah piksel) petak walk-hadap-bawah. Dipakai "
                    "menolak pakaian yang warnanya nyaris sama dengan kulit pemakainya "
                    "— cacat yang membuat warga tampak bugil padahal berpakaian.",
            "_petak": list(PETAK),
            "warna": hasil,
        }, fh, ensure_ascii=False)
    print("-> %s   (%d lembar terukur)" % (OUT, len(hasil)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
