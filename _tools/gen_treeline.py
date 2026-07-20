#!/usr/bin/env python3
"""Potong TREELINE C4 dari 4-season_terrain.zip (design-time, #240, #277).

MENGGANTIKAN KABUT
`kabut32` gambar-sendiri terbaca sebagai PITA PUCAT: rata, terang, nol kedalaman.
Sapuan gudang untuk kabut sungguhan menemukan NOL — yang ada cuma VFX awan racun
DCSS (hijau asam/biru) dan partikel asap platformer.

Yang ADA justru lebih baik: kanopi pinus LPC hijau-tua-nyaris-hitam, berpola-sambung.
Kedalaman datang dari TUMPANG-TINDIH DAN GELAP, bukan dari tebal pita — jadi ia muat
di ~98 px sisa ruang selatan tanpa menggeser pemakaman.

  pinus_isi.png     sel (5,2) — kanopi PENUH (alpha 100%), ubin isi massa hutan
  pinus_atas.png    sel (5,1) — tepi atas kanopi (93%), batas hutan ke rumput
  pinus_pohon.png   sel (0..2, 0..2) — satu pohon utuh, siluet baris depan
  pohon_gundul.png  Trees Generic sel (1..3, 10..14) — pohon TELANJANG musim dingin

Yang gundul bukan hiasan musim: kota mati dikelilingi hutan mati. Pohon berdaun
saja akan mengabarkan "alam sehat mengambil alih" — cerita yang berbeda.

KREDIT (#277 — wajib): Lanea Zimmerman (Sharm) + Eliza Wyatt (DeathsDarling),
OGA-BY 3.0, https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles
Dibaca dari `Terrain Objects/Credits.txt` di dalam zip, bukan ditebak.

Pemakaian:
  python gen_treeline.py
"""
import io
import os
import sys
import zipfile

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
ZIP = r"C:\Users\user\OneDrive\Desktop\Gudang_asset\4-season_terrain.zip"
TILES = os.path.join(REPO, "game", "assets", "game", "tiles", "lpc32")
PROPS = os.path.join(REPO, "game", "assets", "game", "sprites", "props")

KREDIT = (
    "Sumber : LPC Base Assets (map tiles) via pack \"4 Season Terrain\"\n"
    "Seniman: Lanea Zimmerman (Sharm), Eliza Wyatt (DeathsDarling)\n"
    "Lisensi: OGA-BY 3.0 (atribusi WAJIB, non-viral)\n"
    "URL    : https://opengameart.org/content/"
    "liberated-pixel-cup-lpc-base-assets-sprites-map-tiles\n"
    "Dipakai per #277. Jangan hapus berkas ini.\n"
)

# (berkas di zip, kotak potong px, folder tujuan, nama keluaran, keterangan)
POTONG = [
    ("Terrain Objects/Trees, Pine.png", (160, 64, 192, 96), TILES, "pinus_isi",
     "kanopi PENUH — ubin isi massa hutan"),
    ("Terrain Objects/Trees, Pine.png", (160, 32, 192, 64), TILES, "pinus_atas",
     "tepi atas kanopi — batas hutan ke rumput"),
    ("Terrain Objects/Trees, Pine.png", (0, 0, 96, 96), PROPS, "pinus_pohon",
     "satu pohon pinus utuh — siluet baris depan"),
    ("Terrain Objects/Trees, Generic.png", (32, 320, 128, 480), PROPS, "pohon_gundul",
     "pohon TELANJANG musim dingin — hutan mati mengelilingi kota mati"),
]


class TreelineError(Exception):
    """Kegagalan yang menghentikan build."""


def main(argv=None):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    if not os.path.exists(ZIP):
        print(f"[GAGAL] zip sumber hilang: {ZIP}", file=sys.stderr)
        return 2
    zf = zipfile.ZipFile(ZIP)
    for entry, kotak, folder, keluar, ket in POTONG:
        if entry not in zf.namelist():
            print(f"[GAGAL] tak ada di zip: {entry}", file=sys.stderr)
            return 2
        im = Image.open(io.BytesIO(zf.read(entry))).convert("RGBA")
        if kotak[2] > im.width or kotak[3] > im.height:
            print(f"[GAGAL] {entry}: {im.size} lebih kecil dari {kotak}", file=sys.stderr)
            return 2
        sel = im.crop(kotak)
        os.makedirs(folder, exist_ok=True)
        p = os.path.join(folder, keluar + ".png")
        sel.save(p)
        with open(p.replace(".png", ".credits.txt"), "w", encoding="utf-8") as f:
            f.write(f"# {keluar}.png — {ket}\n# potongan {kotak} dari {entry}\n\n{KREDIT}")
        print(f"[POTONG] {keluar}.png {sel.size}  <- {os.path.basename(entry)} {kotak}")

    # credits_db — satu daftar atribusi untuk seluruh proyek
    import json
    dbp = os.path.join(REPO, "_tools", "lpc_assembler", "credits_db.json")
    db = {}
    if os.path.exists(dbp):
        with open(dbp, encoding="utf-8") as f:
            db = json.load(f)
    for _, _, _, keluar, _ in POTONG:
        db[keluar + ".png"] = {
            "author": "Lanea Zimmerman (Sharm), Eliza Wyatt (DeathsDarling)",
            "license": "OGA-BY 3.0",
            "pack": "LPC Base Assets (map tiles) via 4 Season Terrain",
            "url": "https://opengameart.org/content/"
                   "liberated-pixel-cup-lpc-base-assets-sprites-map-tiles",
            "terverifikasi": True,
        }
    with open(dbp, "w", encoding="utf-8") as f:
        json.dump(db, f, ensure_ascii=False, indent=2, sort_keys=True)
    print(f"\nkredit -> {dbp}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
