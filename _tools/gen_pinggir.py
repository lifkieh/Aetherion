#!/usr/bin/env python3
"""Ubin PINGGIR Ashbrook64 — jejak-kehilangan (design-time, #240, #277).

DUA SUMBER, DUA SEBAB
---------------------
1. POTONG dari `submission_daneeklu.zip` (LPC Farming tilesets, Daniel Eddeland,
   CC-BY-SA 3.0 / GPL 3.0). Sah dipakai untuk DUNIA sejak **#277** mencabut hukum
   pembatas non-viral. Atribusi WAJIB — dicatat di `ASSET_LOG.md` dan
   `_tools/lpc_assembler/credits_db.json`, dan berkas ini menuliskannya ulang ke
   `<keluaran>.credits.txt` supaya kredit tak pernah terpisah dari asetnya.

2. GAMBAR SENDIRI: fondasi rumah runtuh. Audit gudang (64 zip, tiap kandidat
   dibuka & dilihat) menemukan **NOL aset puing/fondasi bergaya LPC** — viral
   maupun tidak. Jadi ini satu-satunya yang memang harus digambar, bukan dipilih.
   Diturunkan dari `stone32.png` yang sudah ada supaya paletnya tak pernah bentrok.

PETAK, BUKAN OBJEK
------------------
Semua keluaran di sini adalah UBIN yang dihamparkan jadi PETAK — bukan sprite yang
ditempel satu-satu. Itu disengaja: dua kali dalam proyek ini terbukti bahwa mata
membaca "tempat" dari RUANG, bukan dari objek (pelataran alun-alun, lalu denah
rumah runtuh yang percobaan pertamanya cuma batu di empat sudut dan terbaca sebagai
puing tersebar). Batu sudut & pagar menyusul DI ATAS petak, tak pernah menggantikannya.

Pemakaian:
  python gen_pinggir.py
"""
import io
import os
import sys
import zipfile

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
ZIP = os.path.join(REPO, "assets_raw", "lpc_extra", "submission_daneeklu.zip")
TILES = os.path.join(REPO, "game", "assets", "game", "tiles", "lpc32")
STONE = os.path.join(TILES, "stone32.png")
CELL = 32

KREDIT_DANEEKLU = (
    "Sumber: \"[LPC] Farming tilesets, magic animations and UI elements\"\n"
    "Seniman: Daniel Eddeland (daneeklu)\n"
    "Lisensi: CC-BY-SA 3.0 / GPL 3.0 (atribusi + share-alike WAJIB)\n"
    "https://opengameart.org/content/lpc-farming-tilesets-magic-animations-and-ui-elements\n"
    "Dipakai per #277 (SA sah untuk aset visual dunia). Jangan hapus berkas ini.\n"
)

# (berkas di zip, kolom, baris, nama keluaran, keterangan)
POTONG = [
    ("plowed_soil", 1, 3, "ladang_tanah32",
     "tanah bajakan beralur — petak yang DULU ditanami"),
    ("tallgrass",   1, 5, "ladang_semak32",
     "rumput liar renggang, beralpha — ditumpuk DI ATAS tanah bajak: ladang "
     "yang berhenti digarap dan mulai ditutupi sendiri oleh rumput"),
    ("fence",       1, 0, "pagar_h32",
     "ruas pagar mendatar"),
    ("fence",       1, 1, "pagar_tiang32",
     "tiang pagar tunggal — dipakai di ujung & di tempat ruasnya sudah lapuk hilang"),
]


class PinggirError(Exception):
    """Kegagalan yang menghentikan build (bukan warning)."""


def potong():
    if not os.path.exists(ZIP):
        raise PinggirError(f"zip sumber hilang: {ZIP}")
    zf = zipfile.ZipFile(ZIP)
    hasil = []
    for berkas, cx, cy, keluar, ket in POTONG:
        entry = f"submission_daneeklu/tilesets/{berkas}.png"
        if entry not in zf.namelist():
            raise PinggirError(f"tak ada di zip: {entry}")
        im = Image.open(io.BytesIO(zf.read(entry))).convert("RGBA")
        if im.width < (cx + 1) * CELL or im.height < (cy + 1) * CELL:
            raise PinggirError(f"{entry}: {im.size} terlalu kecil untuk sel ({cx},{cy})")
        sel = im.crop((cx * CELL, cy * CELL, (cx + 1) * CELL, (cy + 1) * CELL))
        p = os.path.join(TILES, keluar + ".png")
        sel.save(p)
        with open(p.replace(".png", ".credits.txt"), "w", encoding="utf-8") as f:
            f.write(f"# {keluar}.png — {ket}\n# sel ({cx},{cy}) dari {berkas}.png\n\n")
            f.write(KREDIT_DANEEKLU)
        print(f"[POTONG] {keluar}.png  <- {berkas}.png sel ({cx},{cy})")
        hasil.append(keluar)
    return hasil


def gen_fondasi():
    """Ubin FONDASI rumah yang sudah tak ada.

    Bukan puing bertumpuk — sisa LANTAI BATU: blok tersusun, sudah pudar, sebagian
    hilang. Yang dikabarkan bukan "ada bangunan roboh di sini" melainkan "ada
    bangunan BERDIRI di sini, dan sekarang tinggal alasnya".

    Diturunkan dari `stone32.png`: digelapkan (batu yang lama tak diinjak menghitam),
    dijenuhkan ke arah cokelat-tanah, lalu diberi garis siar blok. Beberapa petak
    dibolongi transparan supaya rumput tampak menembus — fondasi yang sedang
    dimakan kembali oleh tanah.
    """
    if not os.path.exists(STONE):
        raise PinggirError(f"ubin batu hilang: {STONE}")
    src = Image.open(STONE).convert("RGBA")
    if src.size != (CELL, CELL):
        src = src.crop((0, 0, CELL, CELL))
    im = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    sp, op = src.load(), im.load()
    for y in range(CELL):
        for x in range(CELL):
            r, g, b, a = sp[x, y]
            if a == 0:
                continue
            lum = (r + g + b) // 3
            # gelap + condong ke tanah; batu yang lama ditinggalkan tak lagi cerah
            rr = int(lum * 0.62) + 26
            gg = int(lum * 0.56) + 20
            bb = int(lum * 0.48) + 16
            op[x, y] = (min(255, rr), min(255, gg), min(255, bb), 255)
    d = ImageDraw.Draw(im)
    # garis siar: susunan blok yang masih terbaca meski batunya aus
    for gy in (10, 21):
        d.line([0, gy, CELL - 1, gy], fill=(48, 40, 32, 210))
    for gx, gy0, gy1 in ((8, 0, 10), (22, 11, 21), (14, 22, CELL - 1)):
        d.line([gx, gy0, gx, gy1], fill=(48, 40, 32, 210))
    # dua bolong: tanah mengambil kembali apa yang ditinggalkan
    for bx, by, bw, bh in ((2, 24, 5, 5), (26, 3, 4, 4)):
        for y in range(by, min(by + bh, CELL)):
            for x in range(bx, min(bx + bw, CELL)):
                op[x, y] = (0, 0, 0, 0)
    p = os.path.join(TILES, "fondasi32.png")
    im.save(p)
    with open(p.replace(".png", ".credits.txt"), "w", encoding="utf-8") as f:
        f.write("# fondasi32.png — sisa lantai batu rumah yang sudah tak ada.\n"
                "# DIGAMBAR gen_pinggir.py, diturunkan dari stone32.png.\n"
                "# Alasan digambar, bukan dipilih: audit gudang (64 zip, tiap kandidat\n"
                "# dibuka & dilihat) menemukan NOL aset puing/fondasi bergaya LPC.\n"
                "# Karya turunan aset LPC -> CC-BY-SA 3.0 ikut menempel (#232/#277).\n")
    print("[GAMBAR] fondasi32.png")
    return "fondasi32"


def catat_credits_db(nama):
    """Tulis juga ke credits_db.json — SATU tempat atribusi untuk seluruh proyek.

    `<ubin>.credits.txt` ikut aset supaya kredit tak terpisah dari berkasnya; entri
    di sini supaya audit lisensi punya satu daftar untuk dibaca, bukan menyisir folder.
    """
    import json
    p = os.path.join(REPO, "_tools", "lpc_assembler", "credits_db.json")
    db = {}
    if os.path.exists(p):
        with open(p, encoding="utf-8") as f:
            db = json.load(f)
    for n in nama:
        if n == "fondasi32":
            db[n + ".png"] = {
                "author": "Proyek Aetherion (gen_pinggir.py) — turunan stone32.png (LPC)",
                "license": "CC-BY-SA 3.0", "pack": "Aetherion — lapisan gambar-sendiri",
                "url": "", "terverifikasi": True}
        else:
            db[n + ".png"] = {
                "author": "Daniel Eddeland (daneeklu)",
                "license": "CC-BY-SA 3.0 / GPL 3.0",
                "pack": "[LPC] Farming tilesets, magic animations and UI elements",
                "url": "https://opengameart.org/content/"
                       "lpc-farming-tilesets-magic-animations-and-ui-elements",
                "terverifikasi": True}
    with open(p, "w", encoding="utf-8") as f:
        json.dump(db, f, ensure_ascii=False, indent=2, sort_keys=True)
    print(f"kredit dicatat -> {p}")


def main(argv=None):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    os.makedirs(TILES, exist_ok=True)
    try:
        n = potong()
        n.append(gen_fondasi())
        catat_credits_db(n)
    except PinggirError as e:
        print(f"[GAGAL] {e}", file=sys.stderr)
        return 2
    print(f"\n{len(n)} ubin pinggir -> {TILES}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
