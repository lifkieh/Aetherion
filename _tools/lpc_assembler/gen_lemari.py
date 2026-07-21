# -*- coding: utf-8 -*-
"""LEMARI — pindai pustaka, hasilkan `lemari.json`. LAPIS 2 dari sistem karakter.

TIGA LAPIS, DAN KENAPA DIPISAH
------------------------------
    LAPIS 1  rangka.json   — build badan: kepala apa, keluarga pakaian apa, rambut apa
    LAPIS 2  lemari.json   — GARMEN: identitas bebas-build ("Longsleeve, navy")
    LAPIS 3  characters/   — RESEP tokoh: build + id garmen + warna

Sebelum ini ketiganya tercampur di `catalog.json`: build ditanam DI DALAM nama berkas
(`eulpc_legs_pants_thin.png`), dan resep tokoh menyebut nama berkas itu langsung
(`"legs": "pants_thin"`). Akibatnya dua hal yang mahal:

  1. Menambah rangka baru menuntut menyentuh SETIAP entri pakaian.
  2. Resep bisa menuliskan pasangan yang mustahil — dan memang terjadi: lima tokoh
     dewasa berbadan `male` memakai `pants_thin`, yaitu berkas untuk female/teen.
     Itulah cacat "kaki kelebaran" yang dilaporkan Direktur. Tak ada yang menahannya
     karena tak ada lapis yang tahu bahwa `thin` bukan milik `male`.

Sesudah pemisahan, resep TAK PERNAH menyebut nama berkas. Ia menyebut garmen; lapis
resolver yang memilih berkasnya menurut build. Pasangan mustahil jadi TAK BISA DITULIS.

CARA MEMBACA NAMA BERKAS PUSTAKA
--------------------------------
Pustaka kerja memakai pola `eulpc_<slot>_<garmen>_<keluarga>[_<warna>].png`, tapi
polanya tak konsisten (warisan): `pants_thin.png` tanpa warna, `pants_thin_navy.png`
dengan warna, `overalls_male.png` tanpa warna. Pemindai di bawah karena itu memakai
DAFTAR KELUARGA yang diketahui, bukan menebak dari posisi garis bawah — menebak
posisi akan memecah `high_socks_thin` jadi garmen "high" keluarga "socks".

Pemakaian:
  python gen_lemari.py            # pindai -> lemari.json
  python gen_lemari.py --lihat    # cetak isinya, tak menulis
"""
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
LIB = os.path.join(REPO, "assets_raw", "lpc_extra")
OUT = os.path.join(HERE, "lemari.json")

## Keluarga berkas yang dikenal. URUTAN PENTING: yang lebih panjang diuji lebih dulu
## supaya `child` tak tertelan oleh pencocokan `hi`/`d` mana pun.
KELUARGA = ["child", "female", "male", "teen", "thin", "pregnant", "muscular"]

## Slot yang dianggap PAKAIAN (ikut keluarga build). Slot lain (hair/hat/wing) tidak.
SLOT_PAKAIAN = ["torso", "legs", "feet"]


def urai(nama):
    """`eulpc_legs_pants_thin_navy.png` -> (slot, garmen, keluarga, warna).

    Mengembalikan None kalau bukan berkas pakaian — itu BUKAN kegagalan, cuma
    berkas yang bukan urusan lemari (rambut, sayap, kepala, badan).
    """
    m = re.match(r"^eulpc_([a-z]+)_(.+)\.png$", nama)
    if not m:
        return None
    slot, sisa = m.group(1), m.group(2)
    if slot not in SLOT_PAKAIAN:
        return None
    bagian = sisa.split("_")
    # ⚠ PUSTAKA MEMAKAI DUA URUTAN, dan mengabaikannya menghasilkan garmen palsu.
    #   akhiran : eulpc_legs_pants_thin_navy   -> pants  | thin  | navy
    #   awalan  : eulpc_legs_child_pants_brown -> pants  | child | brown
    #   Percobaan pertama memakai satu aturan saja dan melahirkan garmen bernama
    #   "child" berwarna "pants_brown" — nama yang tak pernah ada di dunia, dan
    #   tak ada yang menahannya karena ia tetap terurai "berhasil".
    for i, b in enumerate(bagian):
        if b not in KELUARGA:
            continue
        if i == 0:                       # keluarga di DEPAN
            if len(bagian) < 2:
                continue
            return slot, bagian[1], b, "_".join(bagian[2:]) or "polos"
        return slot, "_".join(bagian[:i]), b, "_".join(bagian[i + 1:]) or "polos"
    # tanpa keluarga tertulis -> dianggap keluarga 'thin' (warisan pustaka lama)
    return slot, "_".join(bagian), "thin", "polos"


## Garmen yang hidup sebagai OVERLAY (digambar `gen_overlays.py`), bukan sebagai
## berkas `eulpc_*`. Pemindaian pertama melewatkannya seluruhnya, dan akibatnya
## `child` dilaporkan NOL torso — padahal tiga tunik anak sudah ada sejak lama.
## Pelajaran: pemindai yang cuma mengenal SATU pola akan menyatakan barang yang ada
## sebagai tak ada, dan itu lebih berbahaya daripada tak memindai sama sekali.
OVERLAY_KELUARGA = [("_anak_", "child")]


def urai_overlay(kunci, ref):
    """`tunik_anak_forest` + `@overlay/...` -> (slot, garmen, keluarga, warna)."""
    for tanda, kel in OVERLAY_KELUARGA:
        if tanda in kunci:
            garmen, _, warna = kunci.partition(tanda)
            return garmen, kel, (warna or "polos")
    return None


def pindai():
    lemari = {}
    lain = []
    for f in sorted(os.listdir(LIB)):
        if not f.startswith("eulpc_") or not f.endswith(".png"):
            continue
        u = urai(f)
        if u is None:
            lain.append(f)
            continue
        slot, garmen, keluarga, warna = u
        g = lemari.setdefault(slot, {}).setdefault(garmen, {"slot": slot, "berkas": {}})
        g["berkas"].setdefault(keluarga, {})[warna] = f

    # --- garmen berbasis overlay, dibaca dari catalog.json ---
    kat = os.path.join(HERE, "catalog.json")
    if os.path.exists(kat):
        with open(kat, encoding="utf-8") as fh:
            cat = json.load(fh)
        for slot in SLOT_PAKAIAN:
            for kunci, ref in (cat.get(slot) or {}).items():
                if not (isinstance(ref, str) and ref.startswith("@overlay")):
                    continue
                u = urai_overlay(kunci, ref)
                if u is None:
                    lain.append(kunci)
                    continue
                garmen, kel, warna = u
                g = lemari.setdefault(slot, {}).setdefault(
                    garmen, {"slot": slot, "berkas": {}})
                g["berkas"].setdefault(kel, {})[warna] = ref
    return lemari, lain


def main():
    lemari, lain = pindai()
    data = {
        "_doc": "LEMARI — garmen sebagai identitas BEBAS-BUILD. `berkas[keluarga][warna]` "
                "= nama berkas nyata. Resolver memilih keluarga dari rangka build, bukan "
                "dari resep tokoh. Dihasilkan gen_lemari.py; jangan disunting tangan.",
        "_cara_tambah_garmen": "Taruh berkasnya di assets_raw/lpc_extra dengan pola "
                               "eulpc_<slot>_<garmen>_<keluarga>[_<warna>].png lalu jalankan "
                               "ulang gen_lemari.py. Nol perubahan kode.",
        "garmen": lemari,
    }
    if "--lihat" not in sys.argv:
        with open(OUT, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=1)
        print("-> %s" % OUT)

    print("\n=== LEMARI ===")
    for slot in SLOT_PAKAIAN:
        for garmen, g in sorted(lemari.get(slot, {}).items()):
            kel = {k: len(v) for k, v in sorted(g["berkas"].items())}
            print("  %-6s %-16s keluarga: %s" % (slot, garmen, kel))
    print("\nbukan pakaian (dilewat): %d berkas" % len(lain))


if __name__ == "__main__":
    main()
