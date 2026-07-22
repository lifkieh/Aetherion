# -*- coding: utf-8 -*-
"""AMBIL dari generator LPC resmi -> lembar universal siap pakai lemari.

KENAPA MENGUNDUH, BUKAN MENYISIR GUDANG
---------------------------------------
Dua lubang bertahan berminggu-minggu karena pencarian dibatasi ke gudang Desktop:

  * `feet` untuk male/muscular  — semua mundur ke keluarga `thin`, jadi SETIAP warga
    lelaki memakai sepatu perempuan. Zip lokal memang cuma punya `thin`.
  * baju `child`               — ditambal overlay buatan sendiri yang terbaca ponco
    tanpa lengan.

Keduanya ADA di repo generator LPC resmi. Yang kurang bukan asetnya, melainkan
kesediaan mencari di luar gudang. Pelajaran yang sama dengan WHITE STAG.

BENTUK SUMBER, DAN KENAPA HARUS DIKOMPOSISI
-------------------------------------------
Repo menyimpan tiap animasi sebagai berkas terpisah (`walk.png` 576x256), bukan
sebagai lembar universal — jadi tak bisa dipakai perakit apa adanya. Berkas ini
menyusunnya ke tata baris kanon, dengan ukuran tiap sumber DIPERIKSA lebih dulu:
menempel tanpa memeriksa menggeser seluruh baris di bawahnya, dan geseran begitu tak
kelihatan sampai ada yang memainkan animasi yang jarang dipakai.

DUA TEMPAT, DUA ALASAN
----------------------
  assets_raw/oga/lpc/   unduhan mentah — IKUT TER-COMMIT (kecil, permisif) supaya
                        siapa pun yang meng-clone bisa menjalankan ulang ini (#240)
  assets_raw/lpc_extra/ hasil komposisi — TIDAK ter-commit; ia bisa dibuat ulang

Pakai:
  python ambil_lpc.py            # unduh yang belum ada, lalu komposisi
  python ambil_lpc.py --paksa    # unduh ulang semuanya
"""
import json
import os
import sys
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
MENTAH = os.path.join(REPO, "assets_raw", "oga", "lpc")
JADI = os.path.join(REPO, "assets_raw", "lpc_extra")

RAW = ("https://raw.githubusercontent.com/LiberatedPixelCup/"
       "Universal-LPC-Spritesheet-Character-Generator/master/spritesheets/")

CELL, LEBAR, TINGGI_UNIV, TINGGI_KANON = 64, 832, 1344, 2944

## animasi -> (baris awal, frame, arah). Sama dengan gen_kepala.py; disalin, bukan
## di-import, karena dua alat ini boleh berpisah tanpa yang satu merusak yang lain.
TATA = {
    "spellcast": (0, 7, 4), "thrust": (4, 8, 4), "walk": (8, 9, 4),
    "slash": (12, 6, 4), "shoot": (16, 13, 4), "hurt": (20, 6, 1),
}

## (nama keluar, path repo, daftar warna atau None)
##   warna None  -> sumber `<path>/<anim>.png`          (satu warna)
##   warna list  -> sumber `<path>/<anim>/<warna>.png`  (banyak warna)
## Palet warna baku ULPC. Ditulis sekali; dipakai tiap garmen yang punya 24 nada.
WARNA24 = ["black", "blue", "bluegray", "brown", "charcoal", "forest", "gray",
           "green", "lavender", "leather", "maroon", "navy", "orange", "pink",
           "purple", "red", "rose", "sky", "slate", "tan", "teal", "walnut",
           "white", "yellow"]

AMBIL = [
    # SEPATU male. Ini yang menghapus utang `feet/*` -> `thin`: sebelum ini setiap
    # warga lelaki & kekar memakai sepatu berkeluarga `thin`, dan itu terlihat sebagai
    # enam warga contoh bersepatu putih identik.
    ("eulpc_feet_shoes_male.png", "feet/shoes/basic/male", None),
    ("eulpc_feet_boots_male.png", "feet/boots/basic/male", None),
    ("eulpc_feet_boots_thin.png", "feet/boots/basic/thin", None),
    # KEMEJA ANAK asli LPC, 10 warna. Menggantikan overlay `tunik_anak_*` buatan
    # sendiri yang terbaca ponco tanpa lengan.
    # ⚠ SUMBERNYA CUMA PUNYA `walk`. Itu lubang nyata dan dicatat, bukan disembunyikan:
    #   anak yang memainkan animasi `slash` akan bertelanjang dada. Diterima karena
    #   anak Ashbrook warga, bukan petarung — kalau suatu hari mereka bertarung,
    #   lubang ini yang pertama harus dibayar.
    # TORSO PREGNANT. Utang lama: `torso/pregnant` mundur ke `female`, jadi perut
    # tokoh hamil TIDAK TERTUTUP BENAR — baju female membungkus siluet female di atas
    # badan pregnant. Hulu punya torso pregnant sendiri, cakupan animasi PENUH.
    # Ini satu-satunya slot yang benar-benar butuh bentuknya sendiri: perut adalah
    # perubahan BENTUK, bukan ukuran, dan tak ada peminjaman yang bisa mengarangnya.
    ("eulpc_torso_longsleeve_pregnant.png",
     "torso/clothes/longsleeve/longsleeve/pregnant", WARNA24),
    ("eulpc_torso_sleeveless_pregnant.png",
     "torso/clothes/sleeveless/sleeveless/pregnant", WARNA24),
    # CELANA & ROK ANAK. Pustaka lokal cuma punya 3 warna celana anak; hulu punya 9,
    # plus 10 rok yang belum pernah kita lihat. Ditemukan cuma sesudah meng-clone repo
    # tanpa blob — API GitHub kena batas laju 60/jam di tengah penyisiran, dan hasil
    # "NOL child ditemukan" waktu itu ARTEFAK, bukan data. Kalau saya melaporkannya
    # apa adanya, rok anak tak akan pernah masuk.
    ("eulpc_legs_pants_child.png", "legs/pants/child",
     ["black", "blue", "brown", "darkblue", "green", "lightblue", "maroon",
      "red", "white"]),
    ("eulpc_legs_skirt_child.png", "legs/skirts/child",
     ["black", "blue", "darkblue", "green", "lavender", "lightblue", "maroon",
      "pink", "red", "white"]),
    ("eulpc_torso_shirt_child.png", "torso/clothes/shirt/child",
     ["black", "blue", "brown", "gray", "green", "lavender", "lightblue",
      "pink", "red", "white"]),
]


def unduh(rel, tujuan, paksa=False):
    if os.path.exists(tujuan) and not paksa:
        return "ada"
    os.makedirs(os.path.dirname(tujuan), exist_ok=True)
    try:
        with urllib.request.urlopen(RAW + rel, timeout=30) as r:
            data = r.read()
    except Exception as e:
        return "GAGAL: %s" % e
    with open(tujuan, "wb") as f:
        f.write(data)
    return "unduh"


def susun(cari):
    """`cari(anim) -> path atau None` -> lembar universal + daftar animasi hilang."""
    im = Image.new("RGBA", (LEBAR, TINGGI_UNIV), (0, 0, 0, 0))
    hilang, beda = [], []
    for anim, (baris, frame, arah) in TATA.items():
        p = cari(anim)
        if p is None or not os.path.exists(p):
            hilang.append(anim)
            continue
        src = Image.open(p).convert("RGBA")
        # ⚠ YANG DIPERIKSA KETAT ADALAH TINGGI, BUKAN LEBAR.
        #   Tinggi menentukan BARIS. Salah tinggi berarti animasi ini menimpa animasi
        #   di bawahnya, dan geseran baris tak kelihatan sampai ada yang memainkan
        #   animasi yang jarang dipakai.
        #   Lebar cuma menentukan jumlah frame, dan di sini hulu memang tak konsisten:
        #   `shoes/thrust` 8 frame (512 px) tapi `boots/thrust` 9 frame (576 px).
        #   Menolak yang 9 frame berarti menolak aset yang sah hanya karena tabel kita
        #   menebak jumlahnya. Selama masih muat dalam 13 kolom lembar, ia ditempel.
        if src.height != arah * CELL:
            raise ValueError("%s: tinggi %d, tabel kanon minta %d (baris akan meleset)"
                             % (p, src.height, arah * CELL))
        if src.width > LEBAR:
            raise ValueError("%s: lebar %d melampaui lembar %d px"
                             % (p, src.width, LEBAR))
        if src.width != frame * CELL:
            beda.append("%s %d frame (tabel menebak %d)"
                        % (anim, src.width // CELL, frame))
        im.alpha_composite(src, (0, baris * CELL))
    out = Image.new("RGBA", (LEBAR, TINGGI_KANON), (0, 0, 0, 0))
    out.alpha_composite(im, (0, 0))
    return out, hilang + (["frame beda: " + "; ".join(beda)] if beda else [])


def main():
    paksa = "--paksa" in sys.argv
    catatan, n_unduh = {}, 0
    for keluar, rel, warna in AMBIL:
        dasar = os.path.join(MENTAH, rel.replace("/", os.sep))
        daftar = [(w, "%s/%s/%s.png" % (rel, a, w)) for w in (warna or [])
                  for a in TATA] if warna else [(None, "%s/%s.png" % (rel, a))
                                                for a in TATA]
        for _w, r in daftar:
            st = unduh(r, os.path.join(MENTAH, r.replace("/", os.sep)), paksa)
            if st == "unduh":
                n_unduh += 1
            elif st.startswith("GAGAL"):
                catatan.setdefault(keluar, []).append("%s %s" % (r, st))

        if warna is None:
            lembar, hilang = susun(lambda a: os.path.join(dasar, a + ".png"))
            lembar.save(os.path.join(JADI, keluar))
            tulis = [keluar]
        else:
            tulis = []
            for w in warna:
                lembar, hilang = susun(
                    lambda a, w=w: os.path.join(dasar, a, w + ".png"))
                nama = keluar.replace(".png", "_%s.png" % w)
                lembar.save(os.path.join(JADI, nama))
                tulis.append(nama)
        print("  [%s] %-34s %d lembar%s"
              % ("OK", keluar, len(tulis),
                 "  (animasi hilang: %s)" % ", ".join(hilang) if hilang else ""))
        if hilang:
            catatan.setdefault(keluar, []).append("animasi hilang: " + ", ".join(hilang))

    with open(os.path.join(MENTAH, "CREDITS.txt"), "w", encoding="utf-8") as f:
        f.write(
            "# Unduhan dari generator LPC resmi, diambil `_tools/ambil_lpc.py`.\n"
            "# Sengaja DI-COMMIT supaya alat ini bisa dijalankan ulang oleh siapa pun\n"
            "# yang meng-clone repo (#240) — bukan cuma di mesin yang punya gudang.\n\n"
            "Pack   : Universal LPC Spritesheet Character Generator\n"
            "Sumber : https://github.com/LiberatedPixelCup/"
            "Universal-LPC-Spritesheet-Character-Generator\n"
            "Lisensi: CC-BY-SA 3.0 / GPL 3.0 / OGA-BY 3.0 (berganda; DIPILIH OGA-BY 3.0\n"
            "         karena ia TIDAK menular — lihat pola yang sama pada kucing LPC)\n"
            "Catatan: kredit per-aset ada di `credits/` repo hulu; tiap aset yang dipakai\n"
            "         proyek ini juga tercatat di _tools/lpc_assembler/credits_db.json\n")

    print("\n%d berkas diunduh -> %s" % (n_unduh, MENTAH))
    print("lembar universal -> %s" % JADI)
    for k, v in sorted(catatan.items()):
        for baris in v:
            print("  [CATAT] %-32s %s" % (k, baris))
    return 0


if __name__ == "__main__":
    sys.exit(main())
