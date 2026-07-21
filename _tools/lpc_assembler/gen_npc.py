# -*- coding: utf-8 -*-
"""PRESET NPC — 20 resep per kategori, dijamin sah & tak kembar.

DUA ATURAN BERBEDA UNTUK DUA JENIS KARAKTER
-------------------------------------------
    PEMAIN : bebas. Pembuat karakter memanggil `rangka.pilihan(build, slot)`
             langsung — apa pun yang muat, boleh dipakai.
    NPC    : KURASI. Diundi sekali di sini, disimpan sebagai data, lalu dipakai
             apa adanya. Bukan diundi ulang saat main.

Kenapa NPC tidak diundi saat main: NPC yang berganti baju tiap kali scene dimuat
bukan penduduk, ia gangguan. Warga yang sama harus terlihat sama besok. Preset
membuatnya begitu, dan sekaligus membuat kreditnya bisa dihitung sebelum rilis —
kombinasi yang tersimpan bisa disisir; kombinasi yang lahir saat main tidak.

KENAPA DIJAMIN TAK KEMBAR
-------------------------
Undian mentah pada `child` (72 kombinasi) akan menabrak dirinya sendiri berkali-kali
sebelum mengumpulkan 20 — dan yang menabrak diam-diam menghasilkan kembar. Di sini
keunikan dijaga dengan himpunan kunci penuh (torso+legs+feet+rambut), dan kalau ruang
kombinasinya habis, ia GAGAL KERAS alih-alih mengulang diam-diam.

Pakai:
  python gen_npc.py              # tulis npc_preset.json
  python gen_npc.py --lihat      # cetak saja
"""
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")

import rangka

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "npc_preset.json")

PER_KATEGORI = 20

## Kategori yang diminta Direktur. `teen` sengaja TIDAK termasuk — ia rangka yang ada
## di sistem tapi belum diminta jadi penduduk; menambahkannya nanti cukup satu baris.
KATEGORI = [
    ("anak",            "child"),
    ("hamil",           "pregnant"),
    ("kekar_lelaki",    "muscular"),
    ("kekar_perempuan", "muscular_female"),
    ("biasa_lelaki",    "male"),
    ("biasa_perempuan", "female"),
]

BENIH = 20260722

## Kulit yang boleh dipakai PENDUDUK. Pustaka punya 22 nada, tapi 15 di antaranya
## bukan manusia: `zombie`, `zombie_green`, `fur_*`, `lavender`, dan empat nada hijau.
## Undian mentah memberi Ashbrook 16 warga zombi — bukan karena pengundinya salah,
## melainkan karena "sah" dan "pantas" bukan pertanyaan yang sama, dan cuma yang
## pertama bisa dijawab oleh data persediaan.
##
## Pemain TIDAK dibatasi daftar ini; `rangka.kulit_sepadan()` tetap menawarkan semua.
KULIT_NPC = ["amber", "black", "bronze", "brown", "light", "olive", "taupe"]


def kunci(r):
    """Identitas resep untuk uji kembar. Warna ikut — dua warga berbaju sama warna
    beda tetap dua orang; dua warga identik seluruhnya adalah cacat."""
    p = r["pakaian"]
    return (
        r["build"],
        r.get("kulit"),
        tuple((s, (p[s]["garmen"], p[s]["warna"]) if p.get(s) else None)
              for s in sorted(p)),
        r["rambut"],
    )


def ruang(R, L, build):
    """Berapa kombinasi yang MUNGKIN untuk build ini. Dipakai gagal-keras."""
    n = 1
    for s in rangka.SLOT_PAKAIAN:
        n *= max(1, len(rangka.pilihan(R, L, build, s)))
    b = R["build"][build]
    n *= max(1, len(rangka.rambut_tersedia(b["rambut"])))
    n *= max(1, len(_kulit(R, build)))
    return n


def _kulit(R, build):
    b = R["build"][build]
    ada = rangka.kulit_sepadan(build, b["kepala"])
    pilih = [k for k in KULIT_NPC if k in ada]
    return pilih or ada          # kalau kurasi tak beririsan, jujur pakai apa adanya


def buat(R, L, kategori, build, n=PER_KATEGORI):
    maks = ruang(R, L, build)
    if maks < n:
        raise SystemExit(
            "[GAGAL] kategori '%s' (build %s) cuma punya %d kombinasi, diminta %d.\n"
            "        Tambah garmen/warna dulu — mengulang kombinasi akan melahirkan "
            "warga kembar, dan kembar terlihat jauh lebih cepat daripada yang diduga."
            % (kategori, build, maks, n))
    out, seen, i, batas = [], set(), 0, n * 400
    while len(out) < n and i < batas:
        benih = BENIH + hash(kategori) % 100000 + i
        r = rangka.undi(R, L, benih, build)
        i += 1
        # Kulit di-UNDI ULANG dari daftar kurasi. Menyaring hasil undi (buang yang
        # bukan manusia, ulangi) akan memiringkan sebaran ke kulit yang kebetulan
        # lebih sering keluar; mengundi dari daftar yang benar tidak.
        kul = _kulit(R, r["build"])
        r["kulit"] = kul[benih % len(kul)] if kul else None
        k = kunci(r)
        if k in seen:
            continue
        seen.add(k)
        r["id"] = "npc_%s_%02d" % (kategori, len(out))
        r["kategori"] = kategori
        out.append(r)
    if len(out) < n:
        raise SystemExit("[GAGAL] '%s': cuma %d unik sesudah %d undian" % (kategori, len(out), i))
    return out


def main():
    R, L = rangka.muat()
    lubang = rangka.periksa(R, L)
    if lubang:
        print("[AWAS] masih ada lubang build x slot: %s" % lubang, file=sys.stderr)

    semua, ringkas = [], []
    for kategori, build in KATEGORI:
        daftar = buat(R, L, kategori, build)
        semua.extend(daftar)
        # sebaran: berapa garmen & rambut BERBEDA yang benar-benar terpakai
        gm = {s: len({(d["pakaian"][s]["garmen"], d["pakaian"][s]["warna"])
                      for d in daftar if d["pakaian"].get(s)})
              for s in rangka.SLOT_PAKAIAN}
        rb = len({d["rambut"] for d in daftar})
        kl = len({d.get("kulit") for d in daftar})
        ringkas.append((kategori, build, ruang(R, L, build), gm, rb, kl))

    data = {
        "_doc": "PRESET NPC terkurasi. Pemain bebas berkombinasi; NPC memakai daftar "
                "ini apa adanya supaya penduduk tak berganti baju tiap muat, dan supaya "
                "kombinasi yang dipakai bisa disisir sebelum rilis.",
        "_benih": BENIH,
        "_per_kategori": PER_KATEGORI,
        "kategori": {k: b for k, b in KATEGORI},
        "npc": semua,
    }
    if "--lihat" not in sys.argv:
        with open(OUT, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=1)
        print("-> %s  (%d NPC)" % (OUT, len(semua)))

    print("\n=== SEBARAN ===")
    print("  %-17s %-16s %-8s %-34s %-7s %s"
          % ("kategori", "build", "ruang", "garmen unik dipakai", "rambut", "kulit"))
    for kategori, build, rg, gm, rb, kl in ringkas:
        print("  %-17s %-16s %-8d %-34s %-7d %d" % (kategori, build, rg, str(gm), rb, kl))

    # bukti tak kembar — lintas kategori sekalian
    ku = {kunci(d) for d in semua}
    print("\n  total NPC %d · resep unik %d · kembar %d"
          % (len(semua), len(ku), len(semua) - len(ku)))


if __name__ == "__main__":
    main()
