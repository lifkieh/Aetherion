# -*- coding: utf-8 -*-
"""LENGKAPI BARIS EXPANDED pada badan per-warna-kulit. (#278-2 lanjutan · #240)

MASALAH
-------
`assets_raw/lpc_extra/bases/<build>/<skin>.png` setinggi 2944 tapi baris expanded
(21-45: climb/idle/jump/SIT/run) KOSONG — hanya `eulpc_body_<build>.png` (satu nada
kulit) yang penuh. Akibatnya skintone (#278-2) membuat slice `sit`/`run` kehilangan
badannya: topi dan rambut duduk sendirian di bangku (bukti:
reports/preview/sit_slice_proof.png sebelum perbaikan).

CARA
----
Deterministik, tanpa menggambar: baris KLASIK (0-20) ada di KEDUA berkas dan
pose-nya sejajar piksel. Dari pasangan piksel yang sama-sama berisi dipelajari
LUT warna donor->skin (suara terbanyak). LUT diterapkan ke baris expanded donor,
hasilnya ditulis ke baris expanded berkas skin. Warna donor yang tak pernah muncul
di baris klasik dipetakan ke warna ter-DEKAT yang dikenal (jarak RGB) — bukan
dibiarkan salah nada.

Pakai:
  python lengkapi_expanded_skin.py          # tambal SEMUA bases yang kosong
  python lengkapi_expanded_skin.py --cek    # lapor saja, tak menulis
Sesudahnya: jalankan gen_chargen_lapis.py (menyalin bases -> game/) lalu
assemble.py --all (merakit ulang tokoh bernama).
"""
import os
import sys
from collections import Counter, defaultdict

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
LIB = os.path.join(REPO, "assets_raw", "lpc_extra")
BASES = os.path.join(LIB, "bases")

CELL = 64
ROW_KLASIK_AKHIR = 21          # baris 0..20 = klasik (sejajar antar berkas)
H_PENUH = 2944


def _lut_dari_klasik(donor, target):
    """Pelajari pemetaan warna donor->target dari piksel klasik yang sejajar."""
    suara = defaultdict(Counter)
    dp, tp = donor.load(), target.load()
    for y in range(0, ROW_KLASIK_AKHIR * CELL):
        for x in range(donor.width):
            da, ta = dp[x, y], tp[x, y]
            if da[3] > 40 and ta[3] > 40:
                suara[da[:3]][ta[:3]] += 1
    return {k: c.most_common(1)[0][0] for k, c in suara.items()}


def _terdekat(lut_keys, warna):
    return min(lut_keys, key=lambda k: (k[0]-warna[0])**2 + (k[1]-warna[1])**2 + (k[2]-warna[2])**2)


def tambal(build, skin_path, donor):
    im = Image.open(skin_path).convert("RGBA")
    if im.size != (donor.width, H_PENUH):
        return "lewat (ukuran %sx%s)" % im.size
    # sudah berisi? — jangan tambal dua kali
    if im.crop((0, 30 * CELL, im.width, 31 * CELL)).getbbox():
        return "sudah berisi"
    if donor.height < H_PENUH:
        return "lewat (donor %dx%d tak punya baris expanded)" % donor.size
    lut = _lut_dari_klasik(donor, im)
    if not lut:
        return "GAGAL: nol piksel klasik sejajar"
    keys = list(lut.keys())
    dp, ip = donor.load(), im.load()
    cache = {}
    for y in range(ROW_KLASIK_AKHIR * CELL, min(H_PENUH, donor.height)):
        for x in range(min(im.width, donor.width)):
            r, g, b, a = dp[x, y]
            if a == 0:
                continue
            w = (r, g, b)
            if w not in cache:
                cache[w] = lut.get(w) or lut[_terdekat(keys, w)]
            nr, ng, nb = cache[w]
            ip[x, y] = (nr, ng, nb, a)
    im.save(skin_path)
    return "DITAMBAL (%d warna dipetakan)" % len(lut)


def main():
    cek = "--cek" in sys.argv
    total, tambah = 0, 0
    for build in sorted(os.listdir(BASES)):
        if not os.path.isdir(os.path.join(BASES, build)):
            continue
        donor_path = os.path.join(LIB, "eulpc_body_%s.png" % build)
        if not os.path.exists(donor_path):
            # build tanpa donor eulpc (mis. muscular memakai male) — cari padanannya
            alias = {"muscular": "male", "muscular_female": "female", "pregnant": "female"}
            donor_path = os.path.join(LIB, "eulpc_body_%s.png" % alias.get(build, "male"))
        donor = Image.open(donor_path).convert("RGBA")
        d = os.path.join(BASES, build)
        for f in sorted(os.listdir(d)):
            if not f.endswith(".png"):
                continue
            total += 1
            p = os.path.join(d, f)
            if cek:
                im = Image.open(p).convert("RGBA")
                isi = bool(im.crop((0, 30 * CELL, im.width, 31 * CELL)).getbbox())
                print("  %-18s %-24s sit30=%s" % (build, f, isi))
                continue
            hasil = tambal(build, p, donor)
            if hasil.startswith("DITAMBAL"):
                tambah += 1
            print("  %-18s %-24s %s" % (build, f, hasil))
    print("\n%d berkas, %d ditambal." % (total, tambah))
    return 0


if __name__ == "__main__":
    sys.exit(main())
