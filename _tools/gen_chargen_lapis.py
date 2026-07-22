# -*- coding: utf-8 -*-
"""EKSPOR LAPIS PEMBUAT KARAKTER — dari pustaka kerja ke `game/assets/`. (#240)

MASALAH YANG DIPECAHKAN
-----------------------
120 warga Ashbrook memakai lembar LPC 64 px yang dirakit dari `rangka`+`lemari`.
PEMAIN tidak: ia digambar `CharGen.gd`, penggambar prosedural 32 px yang menawarkan
enam gaya rambut dan warna baju sebagai SWATCH — bukan garmen. Jadi pemain berdiri di
dunia yang seluruh penduduknya memakai sistem lain, dan ia tak bisa memakai satu pun
pakaian yang dipakai tetangganya.

Yang menghalangi bukan resolvernya — itu sudah ada dan teruji (36 invarian). Yang
menghalangi: lapisannya hidup di `assets_raw/`, yang **gitignored dan tak ikut
dikirim**. Game tak bisa membaca berkas yang tak ada di build.

KENAPA DIKURASI, BUKAN DIKIRIM SEMUA
------------------------------------
Seluruh pustaka = 102 MB (torso saja 985 berkas / 66 MB). Mengirim semuanya berarti
melipatgandakan ukuran game demi kombinasi yang takkan pernah dilihat pemain.

Yang dikirim: SELURUH badan, kepala, dan rambut (itu identitas — pemain harus bebas),
tapi pakaian DIPILIH: beberapa keluarga garmen dengan palet warna terbatas. Pemain
kehilangan warna ke-19 dari sebuah kemeja; ia tidak kehilangan kemampuan menjadi
seseorang.

⚠ BUKAN pemisahan mutu — NPC dan pemain menarik dari pustaka yang SAMA. Yang dibatasi
cuma apa yang ikut dikirim, dan batas itu ada di SATU tempat (berkas ini), bukan
tersebar di kode UI.

Pakai:
  python gen_chargen_lapis.py            # ekspor + tulis manifes
  python gen_chargen_lapis.py --lihat    # rencana + ukuran, tak menulis
"""
import json
import os
import shutil
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
LIB = os.path.join(REPO, "assets_raw", "lpc_extra")
DST = os.path.join(REPO, "game", "assets", "game", "sprites", "chargen")
MANIFES = os.path.join(REPO, "game", "data", "chargen.json")

sys.path.insert(0, os.path.join(HERE, "lpc_assembler"))
import rangka  # noqa: E402

## Warna yang ikut dikirim. Dipilih supaya tiap nada kulit punya lawan yang terbaca —
## uji kontras `gen_npc.py` menolak kain yang jaraknya <40 dari kulit, dan palet yang
## semuanya gelap akan membuat separuh build kehabisan pilihan.
## DELAPAN warna, bukan empat belas. Percobaan pertama memakai 14 dan menghasilkan
## 55 MB — hampir tiga kali lipat seluruh `game/assets` yang sekarang. Delapan sudah
## memberi tiap nada kulit beberapa lawan yang terbaca, dan itu syarat yang sebenarnya;
## sisanya cuma pilihan yang menambah berkas tanpa menambah keputusan.
PALET = ["black", "brown", "charcoal", "forest", "maroon", "navy", "sky", "white"]

## Keluarga garmen yang ikut. Satu wakil per SILUET, bukan satu per nama — `tshirt`
## dan `tshirt_scoop` beda leher tapi sama bentuknya dari jauh, dan pembuat karakter
## yang menawarkan dua puluh kemeja yang tampak sama cuma melelahkan.
GARMEN = {
    "torso": ["longsleeve", "longsleeve2", "sleeveless2", "overalls", "shirt",
              "sleeveless"],
    "legs": ["pants", "hose", "shorts", "skirt"],
    "feet": ["shoes", "boots", "high_socks"],
}


def salin(src, nama, rencana, ukuran):
    p = os.path.join(LIB, src) if not os.path.isabs(src) else src
    if not os.path.exists(p):
        return False
    rencana.append((p, nama))
    ukuran[0] += os.path.getsize(p)
    return True


def main():
    R, L = rangka.muat()
    rencana, ukuran = [], [0]
    manifes = {
        "_doc": "Manifes lapis pembuat karakter. Dihasilkan `_tools/gen_chargen_lapis.py` "
                "— JANGAN disunting tangan. Berkasnya di sprites/chargen/, dinamai "
                "menurut konvensi supaya runtime bisa merakit path tanpa tabel kedua.",
        "build": {},
        "rambut": {},
        # Aturan DALAMAN ikut dikirim, bukan ditulis ulang di GDScript. `overalls` &
        # `suspenders` di ULPC memang tanpa lengan — dirancang dipakai DI ATAS kemeja.
        # NPC sudah dijaga aturan ini (`gen_npc.py`); pemain belum, dan membiarkannya
        # berarti pemain satu-satunya orang di dunia yang bisa berdada telanjang.
        "dalaman": R.get("dalaman", {}),
    }

    # ── BADAN + KEPALA: SELURUHNYA. Ini identitas, bukan hiasan.
    for build in sorted(R["build"]):
        b = R["build"][build]
        kulit = rangka.kulit_sepadan(build, b["kepala"])
        for k in kulit:
            salin(os.path.join("bases", build, k + ".png"),
                  "body_%s_%s.png" % (build, k), rencana, ukuran)
            salin(os.path.join("heads", b["kepala"], k + ".png"),
                  "head_%s_%s.png" % (b["kepala"], k), rencana, ukuran)

        # ── PAKAIAN: dikurasi per slot
        slot_out = {}
        for slot in rangka.SLOT_PAKAIAN:
            opsi = []
            for garmen, warna in rangka.pilihan(R, L, build, slot):
                if garmen not in GARMEN[slot]:
                    continue
                if warna not in PALET and warna != "polos":
                    continue
                berkas, _kel, _s = rangka.resolve(R, L, build, slot, garmen, warna)
                if berkas is None or str(berkas).startswith("@"):
                    continue          # overlay: bentuk lain, tak ikut jalur ini
                nama = "%s_%s_%s.png" % (slot, garmen, warna)
                if salin(berkas, nama, rencana, ukuran):
                    opsi.append([garmen, warna])
            slot_out[slot] = opsi

        manifes["build"][build] = {
            "kepala": b["kepala"],
            "kulit": kulit,
            "rambut": b["rambut"],
            "pakaian": slot_out,
        }

    # ── RAMBUT: seluruhnya, kedua ukuran batok
    for ukur in ("dewasa", "child"):
        daftar = rangka.rambut_tersedia(ukur)
        manifes["rambut"][ukur] = daftar
        for h in daftar:
            salin("eulpc_hair_%s.png" % h, "hair_%s.png" % h, rencana, ukuran)

    # buang duplikat (badan/kepala dipakai beberapa build)
    unik = {}
    for src, nama in rencana:
        unik[nama] = src

    print("=== RENCANA ===")
    for build, v in sorted(manifes["build"].items()):
        n = {s: len(v["pakaian"][s]) for s in v["pakaian"]}
        print("  %-16s kulit=%-3d pakaian=%s" % (build, len(v["kulit"]), n))
    print("  rambut dewasa=%d anak=%d" % (len(manifes["rambut"]["dewasa"]),
                                          len(manifes["rambut"]["child"])))
    print("\n  %d berkas unik · %.1f MB" % (len(unik), ukuran[0] / 1048576))

    if "--lihat" in sys.argv:
        return 0

    os.makedirs(DST, exist_ok=True)
    for nama, src in unik.items():
        shutil.copyfile(src, os.path.join(DST, nama))
    with open(MANIFES, "w", encoding="utf-8") as f:
        json.dump(manifes, f, ensure_ascii=False, indent=1)
    print("\n-> %s\n-> %s" % (DST, MANIFES))
    return 0


if __name__ == "__main__":
    sys.exit(main())
