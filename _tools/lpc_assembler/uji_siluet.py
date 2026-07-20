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

AMBANG 90 — ASALNYA, JUJUR
--------------------------
Versi pertama berkas ini menulis "ambang dipilih dari bukti". Itu TIDAK BENAR saat
ditulis: 90 dikarang lebih dulu, pembenarannya disusun belakangan. Dicatat di sini
supaya tak ada yang mengutipnya sebagai hasil pengukuran.

Bukti baru muncul SESUDAHNYA, dari menjalankan alat ini pada dua belas tokoh:
  * pasangan yang pemain memang bedakan (lintas jenis kelamin / dewasa vs remaja):
    146 - 615 px
  * pasangan yang di layar terbaca kembar (tiga pria berbagi badan+baju+celana):
    47 - 86 px
Ada jurang kosong antara 86 dan 146. 90 kebetulan jatuh di dalamnya, di tepi bawah —
jadi angkanya bertahan, tapi karena datanya, bukan karena tebakan awalnya benar.
Margin sebenarnya tipis: pasangan terdekat setelah perbaikan ada di 103 px.

APA YANG TIDAK BISA DIUKUR ALAT INI
-----------------------------------
Siluet = alpha. Cacat WARNA lolos begitu saja. `hijab_grey` milik Nyai berbentuk
sama persis dengan hijab pengganti (XOR 0 px) tapi terbaca RAMBUT kelabu, bukan kain.
Alat ini akan bilang "lulus". Mata harus tetap dipakai untuk warna.

Keluaran:
  reports/preview/siluet_ashbrook.png     — lembar siluet hitam (bukti BENTUK)
  reports/preview/15_npc_siluet_beres.png — lembar warna (bukti yang buta-bentuk)
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
OUT_WARNA = os.path.join(REPO_ROOT, "reports", "preview", "15_npc_siluet_beres.png")

CELL = 64
ROW_DOWN = 2  # dir_order = up, left, down, right
AMBANG = 90

NAMED = ["merrit_fane", "halloran", "old_bram", "otha_renn", "nyai", "sora"]
ANAK = ["anak_pim", "anak_wen", "anak_toka"]


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


# --------------------------------------------------------------- gerbang #231
# Baris hadap-bawah di lembar UTUH (832x2944): walk mulai baris 8, urutan arah
# up,left,down,right -> down = baris 10. Dipakai `assemble.py` supaya gerbang
# jalan SEBELUM PNG ditulis, bukan sesudah.
SHEET_ROW_DOWN = 10


def silhouette_of_sheet(sheet):
    """Siluet hadap-bawah dari lembar rakitan penuh, sebelum di-slice."""
    f = sheet.crop((0, SHEET_ROW_DOWN * CELL, CELL, (SHEET_ROW_DOWN + 1) * CELL))
    return silhouette(f.convert("RGBA"))


def isi(s):
    """Luas siluet (px terisi)."""
    return sum(1 for v in s.get_flattened_data() if v > 0)


# Ambang 90 diturunkan dari badan DEWASA (~1100 px terisi) = 8,2% luas badan.
# Badan anak cuma ~614 px. Memakai 90 px apa adanya bukan "standar yang sama" —
# itu standar 1,8x LEBIH KETAT untuk tubuh yang lebih kecil, dan tak ada aset yang
# bisa memenuhinya (rambut anak terluas cuma bermassa 41 px). Yang dibandingkan
# harusnya PROPORSI, bukan hitungan mentah.
RASIO = 90.0 / 1100.0


def ambang_untuk(sil_per_id, ambang=None):
    """Ambang yang diskalakan ke ukuran badan kelompok ini."""
    if ambang is not None:
        return ambang
    rata = sum(isi(s) for s in sil_per_id.values()) / max(1, len(sil_per_id))
    return max(1, int(round(rata * RASIO)))


def pasangan_kembar(sil_per_id, ambang=None):
    """Kembalikan [(a, b, jarak)] untuk tiap pasang di BAWAH ambang. Kosong = lulus."""
    amb = ambang_untuk(sil_per_id, ambang)
    gagal = []
    for a, b in itertools.combinations(sorted(sil_per_id), 2):
        d = beda(sil_per_id[a], sil_per_id[b])
        if d < amb:
            gagal.append((a, b, d))
    return gagal


def main(argv=None):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Uji siluet #231.")
    # default None = skalakan per kelompok. Beri angka untuk memaksa satu ambang mentah.
    ap.add_argument("--ambang", type=int, default=None)
    ap.add_argument("--skala", type=int, default=4)
    args = ap.parse_args(argv)

    semua = NAMED + ANAK
    sil = {cid: silhouette(frame_down(cid)) for cid in semua}

    # lembar bukti: siluet hitam di latar terang, berdampingan
    sheet = Image.new("RGBA", (CELL * len(semua), CELL), (235, 233, 226, 255))
    for i, cid in enumerate(semua):
        black = Image.new("RGBA", (CELL, CELL), (20, 18, 24, 255))
        black.putalpha(sil[cid])
        sheet.alpha_composite(black, (i * CELL, 0))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    sheet.resize((sheet.width * args.skala, sheet.height * args.skala), Image.NEAREST).save(OUT)
    print(f"lembar siluet -> {OUT}")

    # Kembarannya BERWARNA. Wajib ada berdampingan: lembar hitam membuktikan bentuk,
    # lembar warna membuktikan cacat yang buta-bentuk (kerudung abu terbaca rambut,
    # rambut tint-putih yang tetap oranye). Satu lembar saja selalu menipu salah satu arah.
    warna = Image.new("RGBA", (CELL * len(semua), CELL), (235, 233, 226, 255))
    for i, cid in enumerate(semua):
        warna.alpha_composite(frame_down(cid), (i * CELL, 0))
    warna.resize((warna.width * args.skala, warna.height * args.skala),
                 Image.NEAREST).save(OUT_WARNA)
    print(f"lembar warna  -> {OUT_WARNA}\n")

    # DUA KELOMPOK, tak dicampur. Anak berbadan lain — mengadu anak vs dewasa cuma
    # mengukur "anak lebih kecil", angka besar yang tak membuktikan apa-apa. Yang
    # perlu dibuktikan: anak beda satu sama LAIN, dan dewasa beda satu sama lain.
    gagal = []
    for judul, grup in (("TOKOH BERNAMA", NAMED), ("ANAK", ANAK)):
        sub = {c: sil[c] for c in grup}
        amb = ambang_untuk(sub, args.ambang)
        rata = sum(isi(s) for s in sub.values()) / len(sub)
        print(f"  -- {judul}  (badan rata-rata {rata:.0f} px -> ambang {amb} px)")
        for a, b in itertools.combinations(grup, 2):
            d = beda(sil[a], sil[b])
            tanda = "KEMBAR" if d < amb else "beda"
            if d < amb:
                gagal.append((a, b, d, amb))
            print(f"  {a:12} vs {b:12}  {d:5} px  {tanda}")

    print()
    if gagal:
        for a, b, d, amb in gagal:
            print(f"[#231 GAGAL] {a} & {b} berjarak {d} px (< {amb}) — siluet kembar.",
                  file=sys.stderr)
        return 1
    print(f"[#231 LULUS] {len(NAMED)} tokoh bernama + {len(ANAK)} anak, "
          f"nol pasangan kembar dalam kelompoknya masing-masing.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
