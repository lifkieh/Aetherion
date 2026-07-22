# -*- coding: utf-8 -*-
"""CEK ASET SCENE — tiap nama berkas yang disebut scene HARUS ada.

KENAPA ADA
----------
`Ashbrook64.gd` memilih akar aset dari POLA NAMA: berakhiran `32.png` -> `tiles/lpc32`,
sisanya -> `sprites/props`. Aturan itu benar untuk dua zaman aset, dan diam-diam salah
begitu zaman ketiga lahir (`sprites/lpc32/`). `bench_lpc.png` diarahkan ke `props/`
yang tak memilikinya, dan **bangku Merrit di bawah lampu tak pernah tergambar.**

Gejalanya nol. `_put()` memang mengeluarkan `push_warning`, tapi peringatan tenggelam
di antara ratusan baris keluaran uji — dan tak satu pun dari 1.122 uji gagal karena
sebuah sprite tak muncul.

Uji ini statis dan murah: baca skripnya, kumpulkan tiap `"*.png"` yang disebut, lalu
periksa berkasnya benar-benar ada di salah satu akar yang dipakai scene itu.

⚠ Ia sengaja TIDAK menebak akar mana yang BENAR — cuma menuntut ADA di salah satunya.
Menebak akar berarti menyalin logika `_jejak` ke sini, dan salinan itu akan berbohong
begitu aslinya berubah.

Pakai:
  python cek_aset_scene.py
"""
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))

SCENE = [
    "game/scenes/world/Ashbrook64.gd",
    "game/scenes/world/Ashbrook.gd",
]
AKAR = [
    "game/assets/game/sprites/props",
    "game/assets/game/sprites/lpc32",
    "game/assets/game/sprites/animals",
    "game/assets/game/sprites/buildings",
    "game/assets/game/sprites/characters",
    "game/assets/game/sprites/t64",
    "game/assets/game/tiles",
    "game/assets/game/tiles/lpc32",
    "game/assets/game/tiles/t64",
]

## Nama yang dirakit saat jalan (`"%s.png" % x`) tak bisa diperiksa statis, dan
## MEMAKSAKANNYA akan menuduh kode yang benar. Dilewati, dan dilaporkan berapa.
DINAMIS = re.compile(r"%[sd]")

## Bukan tiap `"...png"` di kode adalah nama berkas. `ends_with("32.png")` dan
## `"_idle.png"` adalah AKHIRAN yang dipakai membandingkan, bukan berkas yang dimuat.
## Versi pertama uji ini menuduh ketiganya hilang — uji yang menuduh kode benar akan
## dimatikan orang, dan uji yang dimatikan tak menjaga apa pun.
NAMA_BERKAS = re.compile(r"^[a-z][a-z0-9_]{2,}\.png$", re.I)


def main():
    ada = set()
    for a in AKAR:
        d = os.path.join(REPO, a)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith(".png"):
                    ada.add(f)

    gagal, dilewat, diperiksa = [], 0, 0
    for s in SCENE:
        p = os.path.join(REPO, s)
        if not os.path.exists(p):
            continue
        teks = open(p, encoding="utf-8", errors="replace").read()
        for m in re.finditer(r'"([^"\n]*\.png)"', teks):
            nama = m.group(1)
            if DINAMIS.search(nama):
                dilewat += 1
                continue
            nama = nama.split("/")[-1]
            if not NAMA_BERKAS.match(nama):
                dilewat += 1
                continue
            diperiksa += 1
            if nama not in ada:
                baris = teks[:m.start()].count("\n") + 1
                gagal.append("%s:%d  %s" % (s, baris, nama))

    print("=== ASET YANG DISEBUT SCENE ===")
    print("  diperiksa %d · dilewati (nama dirakit saat jalan) %d" % (diperiksa, dilewat))
    if gagal:
        print("\n  [GAGAL] %d nama tak punya berkas di akar mana pun:" % len(gagal))
        for g in gagal:
            print("     " + g)
        return 1
    # ── PEMERIKSAAN KEDUA: akar yang benar-benar bisa DICAPAI `_jejak` ────────
    # Yang pertama cuma menuntut berkasnya ADA di suatu tempat. Bug aslinya bukan
    # "tak ada" melainkan "ada di akar yang tak bisa dicapai pemanggilnya":
    # `bench_lpc.png` hidup di `sprites/lpc32/` sementara `_jejak` mengarahkannya ke
    # `sprites/props/`. Pemeriksaan pertama meluluskannya — berkasnya memang ada.
    # Yang ini menuntut lebih: ada di salah satu dari tiga akar yang `_jejak` sanggup
    # jangkau. Ia TIDAK meniru urutan prioritasnya (salinan urutan akan berbohong
    # begitu aslinya berubah); ia cuma menolak nama yang berada di luar ketiganya.
    jangkau = set()
    for a in ["game/assets/game/tiles/lpc32",
              "game/assets/game/sprites/props",
              "game/assets/game/sprites/lpc32"]:
        d = os.path.join(REPO, a)
        if os.path.isdir(d):
            jangkau |= set(f for f in os.listdir(d) if f.endswith(".png"))

    luar = []
    for s2 in SCENE:
        p2 = os.path.join(REPO, s2)
        if not os.path.exists(p2):
            continue
        t2 = open(p2, encoding="utf-8", errors="replace").read()
        for m in re.finditer(r'_jejak\(\s*"([^"\n]+\.png)"', t2):
            nama = m.group(1).split("/")[-1]
            if NAMA_BERKAS.match(nama) and nama not in jangkau:
                luar.append("%s:%d  %s"
                            % (s2, t2[:m.start()].count("\n") + 1, nama))
    if luar:
        print("\n  [GAGAL] %d nama _jejak() di luar jangkauan akarnya:" % len(luar))
        for x in luar:
            print("     " + x)
        return 1

    print("\n  [LULUS] tiap nama yang disebut punya berkasnya")
    print("  [LULUS] tiap nama _jejak() ada di akar yang bisa dicapainya")
    return 0


if __name__ == "__main__":
    sys.exit(main())
