# -*- coding: utf-8 -*-
"""Peta KECOCOKAN badan x pakaian x kepala x rambut — untuk pembuat karakter (#240).

MASALAH YANG DIPECAHKAN
-----------------------
Pemain memilih badan. Begitu badan dipilih, pilihan pakaian TIDAK BOLEH bebas: baju
yang digambar untuk badan `male` akan meleset di badan `muscular`, dan itulah cacat
"kaki kelebaran" yang sudah ditemukan (celana `thin` di badan `male`). Berkas ini
memindai seluruh pack dan menjawab satu pertanyaan per slot: **build apa saja yang
benar-benar punya berkasnya?**

TIGA ATURAN YANG BEDA, DAN MEMBEDAKANNYA PENTING
------------------------------------------------
1. **PAKAIAN ikut BUILD BADAN.** Baju & celana digambar per-postur; salah pasang
   langsung terlihat. Ini yang dikunci keras.
2. **KEPALA ikut BADAN**, tapi bukan satu-satu: LPC cuma punya TIGA bentuk kepala
   (male/female/child). Tujuh build dipetakan ke tiga kepala itu.
3. **RAMBUT ikut KEPALA, BUKAN BADAN.** Rambut duduk di batok, dan batok cuma punya
   dua ukuran: dewasa & anak. Artinya badan `muscular` boleh memakai SEMUA rambut
   dewasa — mengunci rambut per-build akan membuang 810 berkas tanpa sebab.

Keluaran:
  _tools/lpc_assembler/kecocokan.json   — dibaca pembuat karakter / pengundi
  reports/PETA_KECOCOKAN_KARAKTER.md    — versi yang dibaca manusia

Pemakaian:
  python gen_peta_kecocokan.py
"""
import collections
import json
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
EXTRA = os.path.join(REPO, "assets_raw", "lpc_extra")
OUT_JSON = os.path.join(HERE, "lpc_assembler", "kecocokan.json")
OUT_MD = os.path.join(REPO, "reports", "PETA_KECOCOKAN_KARAKTER.md")

## Tujuh badan yang kita punya sesudah pemisahan (gen_base_karakter.py).
## `kepala` = bentuk kepala LPC yang dipakai; `pakaian` = build pakaian yang cocok.
##
## ⚠ `muscular_female` memakai pakaian FEMALE, dan itu bukan kompromi: siluetnya
##   sudah dibuktikan identik piksel-per-piksel dengan female (0 beda), jadi tiap
##   lapisan female dijamin pas.
BADAN = {
    "child":           {"kepala": "child",  "pakaian": "child",    "rambut": "child"},
    "teen":            {"kepala": "female", "pakaian": "teen",     "rambut": "adult"},
    "female":          {"kepala": "female", "pakaian": "female",   "rambut": "adult"},
    "muscular_female": {"kepala": "female", "pakaian": "female",   "rambut": "adult"},
    "male":            {"kepala": "male",   "pakaian": "male",     "rambut": "adult"},
    "muscular":        {"kepala": "male",   "pakaian": "muscular", "rambut": "adult"},
    "pregnant":        {"kepala": "female", "pakaian": "pregnant", "rambut": "adult"},
}

BUILD = ["muscular", "pregnant", "male", "female", "teen", "child", "thin"]

## Sumber per slot. `(nama zip, slot)` — jalur di dalam zip berpola
## `<garmen>/<varian>/<build>/...`, jadi build dibaca dari segmen jalur.
SUMBER = [
    ("lpc-2025-02-03-expanded-ulpc-pants-cleaned-split.zip", "legs"),
    ("lpc-2024-12-31-expanded-ulpc-pants.zip",               "legs"),
    ("longsleeve-shirts.zip",                                "torso"),
    ("lpc-2025-03-02-fixed-shirt-assets.zip",                "torso"),
    ("lpc-2024-10-15-expanded-ulpc-clothing.zip",            "torso"),
    ("lpc-2024-10-15-expanded-ulpc-set.zip",                 "feet"),
]


def build_dari(jalur):
    low = jalur.lower()
    for b in BUILD:
        if "/" + b + "/" in low or low.endswith("/" + b + ".png"):
            return b
    return None


def pindai():
    slot = collections.defaultdict(lambda: collections.Counter())
    sumber_slot = collections.defaultdict(set)
    for nama, s in SUMBER:
        p = os.path.join(EXTRA, nama)
        if not os.path.exists(p):
            print("  [lewat] %s — tak ada" % nama)
            continue
        try:
            z = zipfile.ZipFile(p)
        except Exception:
            print("  [lewat] %s — tak terbaca" % nama)
            continue
        n = 0
        for x in z.namelist():
            if not x.endswith(".png") or "__MACOSX" in x:
                continue
            b = build_dari(x)
            if b:
                slot[s][b] += 1
                n += 1
        sumber_slot[s].add(nama)
        print("  [OK] %-52s slot=%-6s %d berkas berbuild" % (nama, s, n))

    # rambut: TIDAK berbuild — dua ukuran batok saja
    rambut = collections.Counter()
    gaya = set()
    pr = os.path.join(EXTRA, "hairstyles-2024-03-10.zip")
    if os.path.exists(pr):
        z = zipfile.ZipFile(pr)
        for x in z.namelist():
            if not x.endswith(".png") or "__MACOSX" in x:
                continue
            low = x.lower()
            rambut["child" if "child" in low else "adult"] += 1
            gaya.add(x.split("/")[0])
    # rambut yang sudah dipotong ke pustaka kerja
    lokal = [f for f in os.listdir(EXTRA) if f.startswith("eulpc_hair")]
    return slot, dict(rambut), sorted(gaya), sorted(lokal), sumber_slot


def main():
    print("=== pindai pack ===")
    slot, rambut, gaya, lokal, sumber_slot = pindai()

    data = {
        "_doc": "Peta kecocokan untuk pembuat karakter. Pilih badan -> slot pakaian "
                "TERKUNCI ke build yang tercantum; kepala mengikuti badan; rambut "
                "mengikuti UKURAN KEPALA (dewasa/anak), bukan build badan.",
        "badan": BADAN,
        "tersedia": {s: dict(c) for s, c in slot.items()},
        "rambut": {"aturan": "ikut ukuran kepala, bukan build badan",
                   "jumlah": rambut, "gaya": gaya,
                   "sudah_dipotong_ke_pustaka": lokal},
        "sumber": {s: sorted(v) for s, v in sumber_slot.items()},
    }

    # --- lubang: build yang punya badan tapi TAK punya pakaian ---
    lubang = []
    for b, cfg in BADAN.items():
        pk = cfg["pakaian"]
        for s in ("torso", "legs", "feet"):
            if slot.get(s, {}).get(pk, 0) == 0:
                lubang.append({"badan": b, "slot": s, "build_pakaian": pk})
    data["lubang"] = lubang

    os.makedirs(os.path.dirname(OUT_JSON), exist_ok=True)
    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)
    print("\n-> %s" % OUT_JSON)

    # --- laporan manusia ---
    L = []
    A = L.append
    A("# PETA KECOCOKAN KARAKTER — badan × pakaian × kepala × rambut\n")
    A("**Dibuat otomatis** oleh `_tools/gen_peta_kecocokan.py`. **Nol perubahan `game/`.**\n")
    A("## Tiga aturan, dan bedanya penting\n")
    A("1. **PAKAIAN ikut BUILD BADAN** — dikunci keras. Salah pasang langsung terlihat;")
    A("   itulah cacat \"kaki kelebaran\" (celana `thin` di badan `male`).")
    A("2. **KEPALA ikut BADAN** — tapi LPC cuma punya **tiga** bentuk kepala")
    A("   (male/female/child). Tujuh build dipetakan ke tiga kepala itu.")
    A("3. **RAMBUT ikut KEPALA, BUKAN BADAN** — rambut duduk di batok, dan batok cuma")
    A("   punya dua ukuran. Badan `muscular` boleh memakai **semua** rambut dewasa;")
    A("   mengunci rambut per-build akan membuang ratusan berkas tanpa sebab.\n")
    A("## Tabel kunci — pilih badan, ini yang boleh menyertainya\n")
    A("| badan | kepala | build pakaian | rambut |")
    A("|---|---|---|---|")
    for b, cfg in BADAN.items():
        A("| `%s` | `%s` | `%s` | `%s` |" % (b, cfg["kepala"], cfg["pakaian"], cfg["rambut"]))
    A("\n## Persediaan nyata per slot (jumlah berkas)\n")
    kolom = [b for b in BUILD]
    A("| slot | " + " | ".join("`%s`" % k for k in kolom) + " |")
    A("|---" * (len(kolom) + 1) + "|")
    for s in ("torso", "legs", "feet"):
        baris = ["**%s**" % s]
        for k in kolom:
            v = slot.get(s, {}).get(k, 0)
            baris.append(str(v) if v else "—")
        A("| " + " | ".join(baris) + " |")
    A("\n## Rambut — nol build, dua ukuran\n")
    A("| ukuran | berkas |")
    A("|---|---|")
    for k, v in sorted(rambut.items()):
        A("| `%s` | %d |" % (k, v))
    A("\nGaya: " + ", ".join("`%s`" % g for g in gaya))
    A("\nSudah dipotong ke pustaka kerja: **%d** berkas `eulpc_hair*`\n" % len(lokal))
    if lubang:
        A("## 🔴 LUBANG — badan yang punya tapi pakaiannya tidak\n")
        A("| badan | slot kosong | build pakaian yang dicari |")
        A("|---|---|---|")
        for x in lubang:
            A("| `%s` | **%s** | `%s` |" % (x["badan"], x["slot"], x["build_pakaian"]))
        A("")
    with open(OUT_MD, "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    print("-> %s" % OUT_MD)

    print("\n=== ringkas ===")
    for s in ("torso", "legs", "feet"):
        print("  %-6s %s" % (s, dict(slot.get(s, {}))))
    print("  rambut %s · gaya %d" % (rambut, len(gaya)))
    print("  LUBANG: %d" % len(lubang))
    for x in lubang:
        print("     %s -> slot %s (build %s) KOSONG" % (x["badan"], x["slot"], x["build_pakaian"]))


if __name__ == "__main__":
    main()
