# -*- coding: utf-8 -*-
"""POTONG PROP 32 px dari `[LPC] Medieval Village Decorations`. (#240 · #277)

KENAPA PACK INI, SESUDAH EMPAT DITOLAK
--------------------------------------
Ashbrook memakai petak 32 px, tapi lima belas propnya masih seni 16 px zaman lama —
dan dua belas di antaranya NOL berkas kredit (#277 dilanggar diam-diam di peta yang
benar-benar dimainkan).

Lima sumber disisir sebelum yang ini:
    lpc_terrain.tar        cuma transisi tanah, nol prop
    Buch Outdoor 32x32     CC0, tapi palet GUA — salah rasa untuk desa
    Kenney Roguelike       CC0, tapi 16x16 — salah ukuran
    Utumno (sudah di repo) CC0, tapi ikon roguelike, bukan dekorasi desa
    daneeklu Farming       isinya cocok — CC-BY-SA + GPL

Polanya bukan kegagalan mencari melainkan BENTUK EKOSISTEMNYA: prop desa 32 px
bergaya LPC hampir seluruhnya CC-BY-SA, karena basis LPC aslinya memang CC-BY-SA.

⚖ PUTUSAN DIREKTUR 2026-07-23 membuka jalan ini: share-alike diizinkan untuk seluruh
aset gambar. Proyek ini memang SUDAH mengirim 130 karakter LPC di bawah CC-BY-SA;
menahan `props/` tetap non-viral berarti menjaga garis yang sudah lama dilewati.

KOORDINAT DIBACA MATA, BUKAN DITEBAK
------------------------------------
Lembarnya 16x64 petak tanpa indeks apa pun. Tiap potongan di bawah dipilih sesudah
merender lembarnya dengan garis petak bernomor — nama berkas di pack ini tak
menjanjikan apa-apa, dan menebak baris/kolom dari urutan sudah berkali-kali salah di
proyek ini (urutan baris LPC dan Stendhal tidak sama).

Pakai:
  python gen_prop32.py            # potong -> sprites/lpc32/
  python gen_prop32.py --lihat    # lembar kontak hasil potongan, tak menulis
"""
import io
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
ZIP = os.path.join(REPO, "assets_raw", "oga", "props", "decoration_medieval.zip")
DALAM = "decoration_medieval/decorations-medieval.png"
PAGAR = "decoration_medieval/fence_medieval.png"
DST = os.path.join(REPO, "game", "assets", "game", "sprites", "lpc32")
PRATINJAU = os.path.join(REPO, "reports", "preview", "prop32.png")

C = 32

## (nama keluar, kolom, baris, lebar_petak, tinggi_petak)
## Nama keluar SENGAJA sama dengan prop 16 px yang digantikannya — supaya penggantian
## di scene cuma soal AKAR, bukan menulis ulang lima belas pemanggilan. Akhiran `32`
## dipakai supaya `_jejak()` mengarahkannya ke P_T/P_S, bukan ke props/ lama.
POTONG = [
    # ── nisan: tegak & retak. Dua bentuk, karena kuburan yang seragam terbaca
    #    sebagai dipasang sekaligus — dan Ashbrook menguburkan orangnya satu per satu.
    ("nisan_terbaca32", 2, 2, 1, 1),
    ("nisan_aus32",     0, 4, 1, 1),
    ("salib_kayu32",    5, 0, 1, 2),
    # ── tanda & papan
    ("papan_kayu32",    6, 4, 1, 2),
    ("papan_gantung32", 8, 0, 1, 1),
    # ── lentera & obor (lampu Merrit dan tetangganya)
    ("lentera32",      13, 2, 1, 1),
    ("obor_dinding32", 13, 6, 1, 1),
    # ── sumur: dua petak, satu-satunya sumber air desa
    ("sumur32",         0, 13, 2, 2),
    ("ember32",         2, 14, 1, 1),
    # ── kerja: gerobak, alat, landasan
    ("gerobak32",       6, 16, 2, 2),
    # ── jerami & pakan
    ("jerami_bal32",    0, 20, 2, 2),
    ("jerami_tumpuk32", 2, 20, 1, 1),
    ("palung32",       15, 17, 1, 2),
    # ── kayu tebangan
    ("kayu_tumpuk32",  13, 20, 1, 2),
    ("kayu_batang32",  14, 21, 1, 1),
    # ── patung: sisa zaman ketika Ashbrook mampu memesan patung
    ("patung32",        0, 9, 1, 2),
    ("patung_anjing32", 2, 9, 1, 2),
]


def ambil(im, c, r, w, h):
    return im.crop((c * C, r * C, (c + w) * C, (r + h) * C))


def main():
    if not os.path.exists(ZIP):
        print("[GAGAL] zip tak ada: %s" % ZIP, file=sys.stderr)
        return 1
    z = zipfile.ZipFile(ZIP)
    im = Image.open(io.BytesIO(z.read(DALAM))).convert("RGBA")

    hasil = []
    for nama, c, r, w, h in POTONG:
        sel = ambil(im, c, r, w, h)
        bb = sel.getbbox()
        if bb is None:
            print("  [AWAS] %-18s petak (%d,%d) KOSONG — koordinatnya salah" % (nama, c, r))
            continue
        # dipotong rapat: petak sumber punya banyak ruang kosong, dan ruang kosong
        # membuat tiap perhitungan skala di sisi pemanggil berbohong.
        hasil.append((nama, sel.crop(bb)))

    if "--lihat" in sys.argv:
        S, KOL = 3, 6
        petak = 96
        baris = (len(hasil) + KOL - 1) // KOL
        kan = Image.new("RGBA", (KOL * petak, baris * (petak + 18)), (26, 24, 30, 255))
        d = ImageDraw.Draw(kan)
        for i, (nama, sel) in enumerate(hasil):
            x, y = (i % KOL) * petak, (i // KOL) * (petak + 18)
            s = min(petak / sel.width, petak / sel.height, 3.0)
            r2 = sel.resize((max(1, int(sel.width * s)), max(1, int(sel.height * s))),
                            Image.NEAREST)
            kan.alpha_composite(r2, (x + (petak - r2.width) // 2,
                                     y + (petak - r2.height) // 2))
            d.text((x + 2, y + petak + 2), nama[:16], fill=(226, 224, 230, 255))
        os.makedirs(os.path.dirname(PRATINJAU), exist_ok=True)
        kan.save(PRATINJAU)
        print("-> %s  (%d potongan)" % (PRATINJAU, len(hasil)))
        return 0

    os.makedirs(DST, exist_ok=True)
    for nama, sel in hasil:
        sel.save(os.path.join(DST, nama + ".png"))
        print("  [POTONG] %-18s %dx%d" % (nama, sel.width, sel.height))

    # KREDIT — satu berkas untuk seluruh potongan, isinya disalin dari CREDITS pack.
    kredit = z.read("decoration_medieval/CREDITS-decorations-medieval.txt").decode(
        "utf-8", "replace")
    with open(os.path.join(DST, "prop32.credits.txt"), "w", encoding="utf-8") as f:
        f.write(
            "# Prop 32 px Ashbrook — dipotong `_tools/gen_prop32.py` dari\n"
            "# [LPC] Medieval Village Decorations.\n"
            "#\n"
            "# Menggantikan prop 16 px zaman lama, dua belas di antaranya NOL kredit.\n\n"
            "Pack   : [LPC] Medieval Village Decorations\n"
            "Seniman: bluecarrot16 dkk (daftar lengkap di bawah)\n"
            "Lisensi: CC-BY-SA 3.0 / CC-BY-SA 4.0 / GPL 3.0\n"
            "URL    : https://opengameart.org/content/lpc-medieval-village-decorations\n"
            "Catatan: share-alike DIIZINKAN untuk seluruh aset gambar proyek ini\n"
            "         (putusan Direktur 2026-07-23). Turunannya ikut share-alike.\n\n"
            "--- CREDITS pack asli, verbatim ---\n" + kredit)
    print("\n-> %s   (%d potongan + kredit)" % (DST, len(hasil)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
