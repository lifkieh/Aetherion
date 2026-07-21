# -*- coding: utf-8 -*-
"""KEPALA per-KULIT — komposisi lembar universal dari berkas per-animasi.

KENAPA ADA
----------
Pustaka kerja cuma punya TIGA kepala (`eulpc_head_male/female/child.png`), masing-masing
SATU nada kulit. Badan punya 22 nada. Akibatnya variasi kulit selama ini ditambal lewat
`tint.body` di perakit — dan tambalan itu bocor: badan cokelat di atas leher pucat,
cacat yang cuma muncul kalau tint dipakai.

`lpc-2025-03-08-fixed-body-head-assets.zip` memuat 3.441 kepala: 10 varian bentuk x 23
kulit x 15 animasi. Tapi ia menyimpannya PER-ANIMASI (`walk/light.png`, 576x256), bukan
sebagai lembar universal — jadi tak bisa dipakai perakit apa adanya. Berkas ini yang
mengomposisinya.

TATA BARIS KANON LPC (21 baris = 1344 px)
-----------------------------------------
    baris  0-3    spellcast   7 frame
    baris  4-7    thrust      8 frame
    baris  8-11   walk        9 frame
    baris 12-15   slash       6 frame
    baris 16-19   shoot      13 frame
    baris 20      hurt        6 frame, SATU arah
Ukuran sumber diperiksa terhadap tabel ini sebelum ditempel. Menempel tanpa memeriksa
akan menggeser seluruh baris di bawahnya, dan geseran begitu tak kelihatan sampai
seseorang memainkan animasi yang jarang dipakai.

Pakai:
  python gen_kepala.py            # tulis assets_raw/lpc_extra/heads/<varian>/<kulit>.png
  python gen_kepala.py --lihat    # cek isi zip, tak menulis
"""
import json
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
ZIP = os.path.join(REPO, "assets_raw", "lpc_extra",
                   "lpc-2025-03-08-fixed-body-head-assets.zip")
DST = os.path.join(REPO, "assets_raw", "lpc_extra", "heads")
MANIFES = os.path.join(DST, "_manifes.json")

CELL = 64
LEBAR = 832
TINGGI_UNIV = 1344
TINGGI_KANON = 2944          # #233

## animasi -> (baris awal, jumlah frame, jumlah arah)
TATA = {
    "spellcast": (0, 7, 4),
    "thrust":    (4, 8, 4),
    "walk":      (8, 9, 4),
    "slash":     (12, 6, 4),
    "shoot":     (16, 13, 4),
    "hurt":      (20, 6, 1),
}

## Varian bentuk kepala yang dipakai proyek. Sisanya (zombie, boarman, dll) sengaja
## dilewat — mengekstrak yang tak dipakai cuma menambah berkas yang harus dijelaskan.
VARIAN = ["male", "female", "child", "male_elderly", "female_elderly",
          "male_gaunt", "male_plump"]


def susun(z, varian, kulit):
    """Rakit satu lembar universal 832x1344 dari berkas per-animasi.

    Mengembalikan (gambar, daftar animasi yang hilang). Animasi hilang TIDAK membuat
    gagal — ia dicatat. Kepala tanpa `shoot` masih kepala yang berguna; yang berbahaya
    bukan lubangnya, melainkan lubang yang tak dilaporkan.
    """
    im = Image.new("RGBA", (LEBAR, TINGGI_UNIV), (0, 0, 0, 0))
    hilang = []
    for anim, (baris, frame, arah) in TATA.items():
        nama = "heads/human/%s/%s/%s.png" % (varian, anim, kulit)
        try:
            src = Image.open(z.open(nama)).convert("RGBA")
        except KeyError:
            hilang.append(anim)
            continue
        harap = (frame * CELL, arah * CELL)
        if src.size != harap:
            raise ValueError("%s: ukuran %s, tabel kanon minta %s"
                             % (nama, src.size, harap))
        im.alpha_composite(src, (0, baris * CELL))
    return im, hilang


def kanon(im):
    """Rata-ATAS ke tinggi kanon. Bukan diregangkan — diregangkan menggeser tiap baris
    animasi dan seluruh pustaka pakaian jadi meleset."""
    out = Image.new("RGBA", (im.width, TINGGI_KANON), (0, 0, 0, 0))
    out.alpha_composite(im, (0, 0))
    return out


def main():
    if not os.path.exists(ZIP):
        print("[GAGAL] zip tak ada: %s" % ZIP, file=sys.stderr)
        return 1
    z = zipfile.ZipFile(ZIP)
    ada = set(z.namelist())

    manifes = {"_doc": "Kepala per-KULIT, dikomposisi gen_kepala.py dari berkas "
                       "per-animasi. Sumbu pengundi: varian bentuk x kulit.",
               "_format": "832x%d, rata-atas dari universal 832x%d"
                          % (TINGGI_KANON, TINGGI_UNIV),
               "varian": {}}
    total, catat_hilang = 0, {}

    for v in VARIAN:
        pref = "heads/human/%s/walk/" % v
        kulit = sorted(x[len(pref):-4] for x in ada
                       if x.startswith(pref) and x.endswith(".png"))
        if not kulit:
            print("  [LEWAT] varian '%s' tak ada di zip" % v)
            continue
        if "--lihat" in sys.argv:
            print("  %-16s %d kulit" % (v, len(kulit)))
            manifes["varian"][v] = {"kulit": kulit}
            continue
        os.makedirs(os.path.join(DST, v), exist_ok=True)
        for k in kulit:
            im, hilang = susun(z, v, k)
            kanon(im).save(os.path.join(DST, v, k + ".png"))
            total += 1
            if hilang:
                catat_hilang.setdefault(v, sorted(set(hilang)))
        manifes["varian"][v] = {"kulit": kulit, "animasi_hilang": catat_hilang.get(v, [])}
        print("  [TULIS] %-16s %d kulit" % (v, len(kulit)))

    if "--lihat" in sys.argv:
        print(json.dumps(manifes["varian"], ensure_ascii=False)[:400])
        return 0

    os.makedirs(DST, exist_ok=True)
    with open(MANIFES, "w", encoding="utf-8") as f:
        json.dump(manifes, f, ensure_ascii=False, indent=1)
    print("\n-> %s   (%d lembar)" % (DST, total))
    for v, h in sorted(catat_hilang.items()):
        print("  [LUBANG] %-16s animasi tak ada di zip: %s" % (v, ", ".join(h)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
