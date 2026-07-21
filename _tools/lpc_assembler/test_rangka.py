# -*- coding: utf-8 -*-
"""Uji invarian sistem karakter (lapis domain). Nol gambar, nol Godot — murni data.

Yang diuji bukan "apakah kodenya jalan" melainkan **apakah janjinya masih dipegang**.
Janji utamanya satu: *pasangan mustahil tak bisa ditulis*. Uji nomor 4 adalah uji
REGRESI untuk cacat yang benar-benar terjadi — lima tokoh dewasa berbadan `male`
memakai `pants_thin`, yaitu berkas untuk female/teen. Kalau suatu hari seseorang
"merapikan" rangka.json dan celana female bisa mendarat di badan male lagi, uji ini
yang berteriak lebih dulu.

Pakai:  python test_rangka.py
"""
import sys

import rangka

sys.stdout.reconfigure(encoding="utf-8")

_lulus = 0
_gagal = 0


def ok(label, cond, detail=""):
    global _lulus, _gagal
    if cond:
        _lulus += 1
    else:
        _gagal += 1
    print("  [%s] %s%s" % ("LULUS" if cond else "GAGAL", label,
                           "" if detail == "" else "  -> " + detail))


def main():
    R, L = rangka.muat()
    builds = sorted(R["build"])
    print("===== INVARIAN SISTEM KARAKTER =====")

    # 1 — tiap build menunjuk kepala yang benar-benar ada
    for b in builds:
        k = R["build"][b]["kepala"]
        ok("kepala build '%s' terdaftar" % b, k in R["kepala"], k)

    # 2 — tiap build punya keluarga untuk tiap slot pakaian
    for b in builds:
        for s in rangka.SLOT_PAKAIAN:
            ok("build '%s' punya keluarga slot '%s'" % (b, s),
               R["build"][b]["keluarga"].get(s) is not None)

    # 3 — pengundi DETERMINISTIK: benih sama -> resep sama
    a = rangka.undi(R, L, 1234)
    b2 = rangka.undi(R, L, 1234)
    ok("undi deterministik (benih sama -> resep sama)", a == b2)

    # 4 — REGRESI "kaki kelebaran": berkas keluarga female TAK PERNAH mendarat di
    #     badan male. Diuji lewat resolver, bukan lewat membaca nama berkas resep.
    bocor = []
    for b in ("male", "muscular"):
        for garmen, g in L["garmen"].get("legs", {}).items():
            for warna in g["berkas"].get("thin", {}):
                berkas, kel, _sebab = rangka.resolve(R, L, b, "legs", garmen, warna)
                if berkas is not None and kel == "thin":
                    bocor.append((b, garmen, warna, berkas))
    ok("celana keluarga 'thin' TAK BISA mendarat di badan male/muscular",
       not bocor, str(bocor[:3]))

    # 5 — tiap hasil undi PASTI bisa diresolusi. Ini janji intinya.
    gagal_resolusi = []
    for i in range(200):
        r = rangka.undi(R, L, 90000 + i)
        for slot, p in r["pakaian"].items():
            if p is None:
                continue
            berkas, _k, sebab = rangka.resolve(R, L, r["build"], slot,
                                               p["garmen"], p["warna"])
            if berkas is None:
                gagal_resolusi.append((r["build"], slot, p, sebab))
    ok("200 undi acak: semuanya bisa diresolusi", not gagal_resolusi,
       str(gagal_resolusi[:2]))

    # 6 — `pilihan()` tak pernah menawarkan garmen di luar rantai keluarga build
    salah_tawar = []
    for b in builds:
        for s in rangka.SLOT_PAKAIAN:
            rt = rangka.rantai(R, b, s)
            for garmen, warna in rangka.pilihan(R, L, b, s):
                g = L["garmen"][s][garmen]
                if not any(warna in g["berkas"].get(k, {}) for k in rt):
                    salah_tawar.append((b, s, garmen, warna))
    ok("pilihan() selalu di dalam rantai keluarga", not salah_tawar,
       str(salah_tawar[:3]))

    # 7 — MUNDUR selalu dilaporkan, tak pernah senyap
    diam = []
    for b in builds:
        for s in rangka.SLOT_PAKAIAN:
            rt = rangka.rantai(R, b, s)
            if len(rt) < 2:
                continue
            for garmen, warna in rangka.pilihan(R, L, b, s):
                berkas, kel, sebab = rangka.resolve(R, L, b, s, garmen, warna)
                if berkas is not None and kel != rt[0] and "MUNDUR" not in sebab:
                    diam.append((b, s, garmen, kel))
    ok("peminjaman keluarga SELALU dilaporkan (nol mundur senyap)", not diam,
       str(diam[:3]))

    # 8 — rambut ikut ukuran batok, bukan build: dua build sekepala -> rambut sama
    sekepala = {}
    for b in builds:
        sekepala.setdefault(R["build"][b]["kepala"], []).append(b)
    beda = []
    for kepala, grup in sekepala.items():
        himp = {tuple(rangka.rambut_tersedia(R["build"][b]["rambut"])) for b in grup}
        if len(himp) > 1:
            beda.append((kepala, grup))
    ok("build sekepala berbagi daftar rambut yang sama", not beda, str(beda))

    # 9 — lubang yang tersisa HARUS tercatat sebagai utang, bukan kejutan
    lb = rangka.periksa(R, L)
    tercatat = set(R.get("_utang", {}))
    tak_tercatat = [(b, s) for b, s, _k in lb
                    if "%s/%s" % (s, b) not in tercatat and "%s/*" % s not in tercatat]
    ok("tiap lubang tercatat di `_utang`", not tak_tercatat, str(tak_tercatat))

    print("\n===== RANGKA: %d lulus, %d gagal =====" % (_lulus, _gagal))
    return 0 if _gagal == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
