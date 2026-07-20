#!/usr/bin/env python3
"""Uji siluet #231 — dua tokoh bernama tak boleh terbaca kembar.

KENAPA ALAT, BUKAN PEMERIKSAAN MATA SEKALI PAKAI
------------------------------------------------
`guard_231` di `assemble.py` membandingkan **string id** hook kepala. Itu menangkap
`curly_short` vs `curly_short` — tapi meloloskan `curly_short` vs `curly_short2`, dua
rambut keriting yang bentuknya nyaris identik. Old Bram dan Halloran lolos gerbang itu
selama berbulan-bulan dan tetap kembar di layar. **Gerbang yang membandingkan nama tak
pernah bisa menangkap kemiripan bentuk.**

Alat ini membandingkan BENTUK: tiap sprite dijadikan siluet hitam (alpha > 0), lalu
dihitung beda piksel antar-pasangan pada frame hadap-bawah. Angka kecil = dua tokoh
menempati ruang yang sama = pemain tak bisa membedakan mereka dari jauh.

AMBANG dipilih dari bukti, bukan selera: pasangan yang jelas berbeda di lembar sebelum
perbaikan (mis. Nyai berkerudung vs Merrit botak) berjarak ratusan piksel; pasangan
kembar (Bram vs Halloran) berada di bawah 60. Ambang 90 memberi ruang aman di antaranya.

Keluaran:
  reports/preview/siluet_ashbrook.png   — lembar siluet hitam bersebelahan (bukti mata)
  kode keluar 1 bila ada pasangan di bawah ambang (bisa dipakai gerbang)

Pemakaian:
  python uji_siluet.py
  python uji_siluet.py --ambang 90
"""
import argparse
import itertools
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
SPRITES = os.path.join(REPO_ROOT, "game", "assets", "game", "sprites", "characters")
OUT = os.path.join(REPO_ROOT, "reports", "preview", "siluet_ashbrook.png")

CELL = 64
ROW_DOWN = 2  # dir_order = up, left, down, right
AMBANG = 90

NAMED = ["merrit_fane", "halloran", "old_bram", "otha_renn", "nyai", "sora"]


def frame_down(cid):
    """Ambil frame hadap-bawah dari slice walk (frame 0 = berdiri)."""
    p = os.path.join(SPRITES, f"{cid}_walk.png")
    if not os.path.exists(p):
        raise SystemExit(f"sprite hilang: {p}")
    im = Image.open(p).convert("RGBA")
    return im.crop((0, ROW_DOWN * CELL, CELL, (ROW_DOWN + 1) * CELL))


def silhouette(frame):
    """Siluet = mask alpha. Warna dibuang total — yang diuji BENTUK, bukan palet.

    Dua tokoh boleh saja berbaju merah dan biru; kalau bentuknya sama, dari jauh
    (dan bagi pemain buta-warna) mereka tetap orang yang sama.
    """
    a = frame.getchannel("A").point(lambda v: 255 if v > 0 else 0)
    return a


def beda(s1, s2):
    """Jumlah piksel yang isi di satu siluet tapi kosong di yang lain (XOR)."""
    p1, p2 = s1.load(), s2.load()
    n = 0
    for y in range(s1.height):
        for x in range(s1.width):
            if (p1[x, y] > 0) != (p2[x, y] > 0):
                n += 1
    return n


def main(argv=None):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Uji siluet #231.")
    ap.add_argument("--ambang", type=int, default=AMBANG)
    ap.add_argument("--skala", type=int, default=4)
    args = ap.parse_args(argv)

    sil = {cid: silhouette(frame_down(cid)) for cid in NAMED}

    # lembar bukti: siluet hitam di latar terang, berdampingan
    sheet = Image.new("RGBA", (CELL * len(NAMED), CELL), (235, 233, 226, 255))
    for i, cid in enumerate(NAMED):
        black = Image.new("RGBA", (CELL, CELL), (20, 18, 24, 255))
        black.putalpha(sil[cid])
        sheet.alpha_composite(black, (i * CELL, 0))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    sheet.resize((sheet.width * args.skala, sheet.height * args.skala), Image.NEAREST).save(OUT)

    print(f"lembar siluet -> {OUT}\n")
    gagal = []
    for a, b in itertools.combinations(NAMED, 2):
        d = beda(sil[a], sil[b])
        tanda = "KEMBAR" if d < args.ambang else "beda"
        if d < args.ambang:
            gagal.append((a, b, d))
        print(f"  {a:12} vs {b:12}  {d:5} px  {tanda}")

    print()
    if gagal:
        for a, b, d in gagal:
            print(f"[#231 GAGAL] {a} & {b} berjarak {d} px (< {args.ambang}) — siluet kembar.",
                  file=sys.stderr)
        return 1
    print(f"[#231 LULUS] {len(NAMED)} tokoh, nol pasangan di bawah {args.ambang} px.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
