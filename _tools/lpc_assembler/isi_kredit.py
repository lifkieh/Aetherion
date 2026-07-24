#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ISI credits_db.json dari CREDITS.csv resmi ULPC. (#278-3 · kewajiban SA #277)

MASALAH
-------
Manifest kredit tiap sprite penuh `[TODO kredit]` — zip pustaka yang diunduh hanya
berisi PNG, daftar seniman per-lapisan tak ikut. SA tanpa atribusi = pelanggaran
lisensi, bukan utang kosmetik.

SUMBER
------
CREDITS.csv dari repo generator ULPC (LiberatedPixelCup/Universal-LPC-Spritesheet-
Character-Generator) — 13.7k baris `filename,notes,authors,licenses,urls` per PATH
lapisan. Salinan dibekukan di folder ini (`ulpc_credits.csv`) supaya alat ini
deterministik (#240), tak bergantung jaringan.

CARA COCOK
----------
Nama berkas kita (mis. `eulpc_torso_longsleeve2_cardigan_female_tan.png`) dipecah
jadi token, path CSV juga; entri CSV dengan irisan token terbanyak menang. WARNA
dan token bising (eulpc, thin, dst.) dibuang dari kedua sisi — warna adalah varian
recolor, kreditnya sama. Skor 0 = tak ditulis (biar TODO tetap berteriak, bukan
diberi kredit karangan).

Pakai:
  python isi_kredit.py           # perbarui credits_db.json (merge, tak menimpa isi)
  python isi_kredit.py --cek     # lapor cakupan tanpa menulis
Sesudahnya: assemble.py --all + rakit_npc.py --pasang --tokoh (regen manifest).
"""
import csv
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
CSV = os.path.join(HERE, "ulpc_credits.csv")
DB = os.path.join(HERE, "credits_db.json")
CHARS = os.path.join(HERE, "..", "..", "game", "assets", "game", "sprites", "characters")

## token yang tak membedakan lapisan (warna, build-suffix teknis, bising)
WARNA = {
    "black", "blue", "bluegray", "brown", "charcoal", "forest", "gray", "green",
    "lavender", "leather", "maroon", "navy", "orange", "pink", "purple", "red",
    "rose", "sky", "slate", "tan", "teal", "walnut", "white", "yellow", "light",
    "amber", "bronze", "olive", "taupe", "bright", "dark", "pale", "zombie",
    "fur", "copper", "gold", "grey", "chestnut", "polos",
}
BISING = {"eulpc", "png", "thin", "male", "female", "child", "teen", "muscular",
          "pregnant", "adult", "universal", "walk", "spellcast", "thrust", "slash",
          "shoot", "hurt", "idle", "jump", "sit", "run", "climb", "emote",
          "bg", "fg", "npc", "tokoh"}
## male/female/child DIBUANG dari pencocokan garmen (potongan sama, kredit sama),
## tapi DIPAKAI untuk badan/kepala — CSV memisah body per build.
TOKEN_BUILD = {"male", "female", "child", "teen", "muscular", "pregnant"}


def tokens(s, keep_build=False):
    t = set(re.split(r"[^a-z0-9]+", s.lower())) - {""}
    t -= WARNA
    t -= (BISING - TOKEN_BUILD) if keep_build else BISING
    return t


def muat_csv():
    idx = []
    with open(CSV, encoding="utf-8") as f:
        for row in csv.DictReader(f):
            p = row["filename"]
            idx.append((p, tokens(p, keep_build=True),
                        row["authors"].strip(), row["licenses"].strip(),
                        row["urls"].strip().split(",")[0]))
    return idx


def cari(idx, nama):
    dasar = os.path.splitext(nama)[0].lower()
    # basename warna polos = badan dari `bases/<build>/<warna>.png` — token warnanya
    # sengaja dibuang pencocok, jadi diarahkan eksplisit ke keluarga body ULPC
    if dasar in WARNA or all(t in WARNA for t in re.split(r"[^a-z]+", dasar) if t):
        tk = {"body", "bodies"}
    elif "beard" in dasar:
        tk = {"beard", "facial"}
    else:
        keep = any(b in nama for b in ("body_", "head_", "bases", "kepala"))
        tk = tokens(nama, keep_build=keep)
    best, bs = None, 0
    for p, pt, a, l, u in idx:
        s = len(tk & pt)
        if s > bs or (s == bs and best and len(pt) < len(best[1])):
            best, bs = (p, pt, a, l, u), s
    return (best, bs) if bs > 0 else (None, 0)


def butuh():
    """Basename semua lapisan yang muncul di manifest characters/."""
    out = set()
    pat = re.compile(r"- [^:]+:[^:]+: (\S+\.png)")
    for f in os.listdir(CHARS):
        if not f.endswith(".credits.txt"):
            continue
        for line in open(os.path.join(CHARS, f), encoding="utf-8"):
            m = pat.search(line)
            if m:
                out.add(m.group(1))
    return sorted(out)


def main():
    cek = "--cek" in sys.argv
    idx = muat_csv()
    db = json.load(open(DB, encoding="utf-8")) if os.path.exists(DB) else {}
    perlu = butuh()
    isi, kosong, sudah = 0, [], 0
    for nama in perlu:
        ada = db.get(nama)
        if ada and "TODO" not in str(ada) and "belum" not in str(ada.get("author", "")):
            sudah += 1
            continue
        hasil, skor = cari(idx, nama)
        if hasil is None:
            kosong.append(nama)
            continue
        p, _t, a, l, u = hasil
        if cek:
            print("  %-52s <- %-40s (skor %d)" % (nama, p, skor))
        else:
            db[nama] = {"author": a, "license": l, "url": u, "sumber_csv": p}
        isi += 1
    for nama in kosong:
        print("  [TANPA-COCOK] %s" % nama)
    if not cek:
        json.dump(db, open(DB, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print("\ncredits_db.json: %d diisi, %d sudah ada, %d tanpa cocokan (TODO tetap)" %
              (isi, sudah, len(kosong)))
    else:
        print("\n[CEK] %d bisa diisi, %d sudah ada, %d tanpa cocokan" % (isi, sudah, len(kosong)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
