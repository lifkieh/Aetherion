#!/usr/bin/env python3
"""Aset C4 TEPI HANTU — nisan + kabut (design-time, #240).

Digambar, bukan dipilih: sapuan gudang (111 zip) menemukan NOL nisan/pemakaman
bergaya LPC, dan pack CC0 yang punya batu nisan berskala peta-dunia 14 px.
Jalur yang sama dengan fondasi32 / pelataran32 / tunik anak.

TIGA KELUARAN
  nisan_terbaca.png  batu bernisan dengan guratan tulisan yang MASIH terbaca (D2)
  nisan_aus.png      batu polos, tulisannya habis (D3 — tak ada yang tahu siapa)
  kabut32.png        ubin kabut, ditumpuk berlapis jadi tembok yang indah

KENAPA DUA JENIS NISAN, BUKAN SATU BERVARIASI
Three Deaths (#269) dalam batu. D2 = pernah tercatat lalu berhenti disebut —
namanya masih ada, cuma tak ada lagi yang membacanya. D3 = tak pernah tercatat,
atau catatannya habis — dan batu ausnya TIDAK BISA dipulihkan, cuma dilahirkan
sekali (#270). Satu sprite bervariasi akan mengaburkan dua kematian jadi satu
gradien; dua sprite berbeda menjaga garisnya tetap tajam.

Pemakaian:
  python gen_c4.py
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
DST = os.path.join(REPO, "game", "assets", "game", "sprites", "props")
TILES = os.path.join(REPO, "game", "assets", "game", "tiles", "lpc32")

BATU = (150, 148, 142)
BATU_GELAP = (104, 102, 98)
BATU_TERANG = (178, 176, 170)
TANAH = (86, 78, 66)


def nisan(terbaca: bool):
    """Batu nisan 16x22. Berpuncak bulat, tertanam miring — bukan persegi rapi."""
    W, H = 16, 22
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    # bayangan di tanah (menjejakkan batu ke rumput, bukan menempel di udara)
    d.ellipse([1, H - 6, W - 2, H - 1], fill=(60, 66, 52, 90))
    # badan batu: puncak membulat
    d.rounded_rectangle([3, 4, W - 4, H - 4], radius=5, fill=BATU, outline=BATU_GELAP)
    # sisi kiri lebih terang — satu arah cahaya, sama dengan LPC
    d.line([4, 8, 4, H - 6], fill=BATU_TERANG)
    if terbaca:
        # GURATAN TULISAN: tiga baris pendek. Sengaja tak terbaca sebagai huruf —
        # yang perlu terbaca adalah "ada tulisan di sini", bukan tulisannya.
        for i, (x0, x1, y) in enumerate([(6, 10, 10), (6, 11, 13), (7, 9, 16)]):
            d.line([x0, y, x1, y], fill=BATU_GELAP)
    else:
        # AUS: permukaan rata, cuma noda cuaca. Nol guratan — dan ketiadaan itu
        # yang harus terbaca dari jauh, jadi batunya sedikit lebih pucat & rendah.
        d.rounded_rectangle([3, 6, W - 4, H - 4], radius=5, fill=(160, 158, 152),
                            outline=BATU_GELAP)
        d.point((7, 12), fill=(140, 138, 132))
        d.point((10, 15), fill=(140, 138, 132))
    return im


def kabut():
    """Ubin kabut 32x32, tileable. Lembut, tak berpola — pola membuatnya jadi tekstur,
    dan tekstur bisa dibaca mata sebagai permukaan yang bisa diinjak."""
    W = 32
    im = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    px = im.load()
    for y in range(W):
        for x in range(W):
            # gradasi halus dua arah + sedikit denyut, semuanya rendah-kontras
            a = 96 + int(26 * ((x * 7 + y * 11) % 13) / 13.0)
            px[x, y] = (226, 228, 232, a)
    return im


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    os.makedirs(DST, exist_ok=True)
    os.makedirs(TILES, exist_ok=True)
    for nama, im in [("nisan_terbaca", nisan(True)), ("nisan_aus", nisan(False))]:
        p = os.path.join(DST, nama + ".png")
        im.save(p)
        with open(p.replace(".png", ".credits.txt"), "w", encoding="utf-8") as f:
            f.write(f"# {nama}.png — DIGAMBAR gen_c4.py (C4 tepi hantu).\n"
                    "# Alasan digambar: sapuan 111 zip gudang menemukan NOL nisan\n"
                    "# bergaya LPC; pack CC0 yang punya berskala peta-dunia 14 px.\n"
                    "# Karya proyek, nol turunan aset pihak ketiga.\n")
        print(f"[GAMBAR] {nama}.png {im.size}")
    p = os.path.join(TILES, "kabut32.png")
    kabut().save(p)
    with open(p.replace(".png", ".credits.txt"), "w", encoding="utf-8") as f:
        f.write("# kabut32.png — DIGAMBAR gen_c4.py. Karya proyek, nol turunan.\n")
    print("[GAMBAR] kabut32.png (32, 32)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
