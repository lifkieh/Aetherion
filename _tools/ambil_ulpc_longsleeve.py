# -*- coding: utf-8 -*-
"""LENGKAPI BARIS EXPANDED GARMEN LONGSLEEVE dari repo ULPC hulu. (#284 · #278-2)

MASALAH
-------
Keluarga `eulpc_torso_longsleeve_*` di pustaka kosong di baris 21+ (climb/idle/
jump/SIT/run) — lima tokoh dewasa + banyak warga kehilangan slice sit/run/jump
(penjaga anti-telanjang melewatinya). Menukar baju tokoh = mengubah identitas
visual; melengkapi lapisannya = bukan.

SUMBER
------
Repo generator ULPC (LiberatedPixelCup/Universal-LPC-Spritesheet-Character-
Generator) menyediakan animasi expanded longsleeve per-build:
  spritesheets/torso/clothes/longsleeve/longsleeve/<build>/{climb,idle,jump,sit,run}.png
Berkas unduhan dibekukan ke assets_raw/oga/lpc/... (#240). Lisensi sama
(CC-BY-SA/OGA-BY, kredit di ulpc_credits.csv — sudah dipetakan isi_kredit.py).

CARA
----
Anim hulu = warna DASAR. Varian warna kita (slate/forest/dst.) diwarnai lewat
LUT yang dipelajari dari baris KLASIK yang sejajar piksel (pola
lengkapi_expanded_skin.py). Baris tujuan (kalibrasi 2026-07-24):
  climb=21 · idle=22-25 · jump=26-29 · sit=30-33 · run=34-37
Urutan baris anim hulu = LPC baku [up,left,down,right] = urutan sheet kita.

Pakai:
  python ambil_ulpc_longsleeve.py          # unduh (sekali) + tambal semua varian
Sesudahnya: assemble.py --all + rakit_npc.py --pasang --tokoh.
"""
import os
import sys
import urllib.request
from collections import Counter, defaultdict

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
LIB = os.path.join(REPO, "assets_raw", "lpc_extra")
SIMPAN = os.path.join(REPO, "assets_raw", "oga", "lpc", "torso", "clothes",
                      "longsleeve", "longsleeve")
URL = ("https://raw.githubusercontent.com/LiberatedPixelCup/"
       "Universal-LPC-Spritesheet-Character-Generator/master/"
       "spritesheets/torso/clothes/longsleeve/longsleeve/%s/%s.png")

CELL = 64
H_PENUH = 2944
## anim -> (baris awal, jumlah baris). Kalibrasi #278-2 (expanded_rows_0/1.png).
TATA = {"climb": (21, 1), "idle": (22, 4), "jump": (26, 4), "sit": (30, 4), "run": (34, 4)}
BUILDS = ["male", "female", "teen", "pregnant"]


def unduh(build):
    d = os.path.join(SIMPAN, build)
    os.makedirs(d, exist_ok=True)
    out = {}
    for anim in TATA:
        p = os.path.join(d, anim + ".png")
        if not os.path.exists(p):
            try:
                urllib.request.urlretrieve(URL % (build, anim), p)
                print("  unduh %s/%s.png" % (build, anim))
            except Exception as e:
                # pregnant di hulu memang belum punya expanded — jujur, bukan gagal
                print("  [ABSEN] %s/%s (%s)" % (build, anim, e))
                continue
        out[anim] = Image.open(p).convert("RGBA")
    return out


def blok_expanded(anims):
    """Susun blok 832 x (17*64): climb..run pada offset kalibrasi (relatif baris 21)."""
    blok = Image.new("RGBA", (832, 17 * CELL), (0, 0, 0, 0))
    for anim, (r0, n) in TATA.items():
        im = anims[anim]
        h = min(im.height, n * CELL)
        blok.alpha_composite(im.crop((0, 0, min(im.width, 832), h)),
                             (0, (r0 - 21) * CELL))
    return blok


def _lut(sumber, target, y_max):
    """LUT warna sumber->target dari piksel klasik sejajar (suara terbanyak)."""
    suara = defaultdict(Counter)
    sp, tp = sumber.load(), target.load()
    for y in range(0, y_max):
        for x in range(min(sumber.width, target.width)):
            sa, ta = sp[x, y], tp[x, y]
            if sa[3] > 40 and ta[3] > 40:
                suara[sa[:3]][ta[:3]] += 1
    return {k: c.most_common(1)[0][0] for k, c in suara.items()}


def terapkan(blok, lut):
    im = blok.copy()
    px = im.load()
    keys = list(lut.keys())
    cache = dict(lut)
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            w = (r, g, b)
            if w not in cache:
                cache[w] = lut[min(keys, key=lambda k: (k[0]-w[0])**2 + (k[1]-w[1])**2 + (k[2]-w[2])**2)]
            nr, ng, nb = cache[w]
            px[x, y] = (nr, ng, nb, a)
    return im


def main():
    import glob
    total = 0
    for build in BUILDS:
        anims = unduh(build)
        if "sit" not in anims:
            print("  [LEWAT] %s: hulu tak punya expanded" % build)
            continue
        blok = blok_expanded(anims)
        # referensi klasik warna-dasar: walk.png hulu (baris 8-11 di sheet kita)
        wp = os.path.join(SIMPAN, build, "walk.png")
        if not os.path.exists(wp):
            urllib.request.urlretrieve(URL % (build, "walk"), wp)
        walk_dasar = Image.open(wp).convert("RGBA")
        pola = os.path.join(LIB, "eulpc_torso_longsleeve_%s_*.png" % build)
        for p in sorted(glob.glob(pola)):
            im = Image.open(p).convert("RGBA")
            if im.size != (832, H_PENUH):
                continue
            if im.crop((0, 30 * CELL, im.width, 31 * CELL)).getbbox():
                continue                      # sudah berisi
            # LUT: walk hulu (warna dasar) vs baris walk berkas warna ini (8..12)
            target_walk = im.crop((0, 8 * CELL, 832, 12 * CELL))
            lut = _lut(walk_dasar, target_walk, min(walk_dasar.height, 4 * CELL))
            if not lut:
                print("  [LEWAT] %s: nol piksel sejajar" % os.path.basename(p))
                continue
            im.alpha_composite(terapkan(blok, lut), (0, 21 * CELL))
            im.save(p)
            total += 1
            print("  [TAMBAL] %s (%d warna)" % (os.path.basename(p), len(lut)))
    print("\n%d berkas longsleeve dilengkapi." % total)
    return 0


if __name__ == "__main__":
    sys.exit(main())
