# -*- coding: utf-8 -*-
"""MONSTER 64 px dari Dungeon Crawl Stone Soup (CC0). (#240 · #277)

MASALAH
-------
Dua puluh lima sprite monster, NOL berkas kredit — pelanggaran #277 sekelas
`All/Wild Animals`. Dan seninya 16 px: `monsters.json` menulis `frame_size: 16` untuk
59 dari 60 entri, jadi yang dilihat pemain petak 16x16 di pojok kiri-atas kanvas
64x64. Itu BENAR secara teknis, dan salah secara skala — makhluk 16 px di dunia
berpetak 32 px yang dihuni karakter 64 px terbaca sebagai serangga.

Lebih buruk lagi: sebagian besar seni lama itu gumpalan warna yang sama persis
bentuknya. `frost_fox`, `ice_wolf`, `snow_owl`, `yeti_cub`, `woolly_calf` — lima nama,
satu siluet. Nama yang berbeda tak membuat makhluk yang berbeda.

KENAPA DCSS
-----------
1.310 monster, **CC0** — jadi keputusan share-alike Direktur tak perlu dipakai di
sini sama sekali. Cakupannya menutupi hampir seluruh roster: golem 9, naga 28,
beruang 5, tikus 11, jelly 13, elemental 17, serigala, kepiting, belut, ular.

Dan ia sudah di repo (`Dungeon Crawl Stone Soup Full.zip`), sudah dipakai untuk
`serigala_monster`, jadi ia bukan keluarga visual baru — ia yang sudah ada.

32 px DIPERBESAR 2x KE 64 px, dan itu bukan kemalasan: DCSS digambar untuk petak
32 px, dan dunia ini memakai petak 32 px dengan karakter setinggi dua petak. Monster
setinggi dua petak berdiri sejajar karakter — persis yang diminta Direktur.
Nearest-neighbour, bukan interpolasi: interpolasi mengaburkan piksel dan membuat seni
piksel terlihat seperti foto yang diperbesar.

Pakai:
  python gen_monster64.py            # tulis sprites/monsters/
  python gen_monster64.py --lihat    # lembar kontak, tak menulis
"""
import io
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
GUDANG = r"C:\Users\user\OneDrive\Desktop\Gudang_asset"
ZIP = os.path.join(GUDANG, "Dungeon Crawl Stone Soup Full.zip")
DALAM = "Dungeon Crawl Stone Soup Full/monster/"
DST = os.path.join(REPO, "game", "assets", "game", "sprites", "monsters")
PRATINJAU = os.path.join(REPO, "reports", "preview", "monster64.png")

## (nama kita, path DCSS relatif terhadap `monster/`)
## Dipilih menurut APA MAKHLUKNYA, bukan menurut kemiripan nama berkas. `cloud_ray`
## jadi `murray` (pari) bukan karena namanya mirip melainkan karena keduanya pari.
PETA = [
    # serigala — tiga peringkat, tiga warna nyata dari Wolfpack? Tidak: DCSS punya
    # serigala sungguhan, dan memakai satu sumber untuk seluruh monster menjaga
    # dunia ini terbaca sebagai satu tempat.
    ("grey_wolf",        "animals/wolf.png"),
    ("alpha_wolf",       "animals/warg.png"),
    ("ice_wolf",         "animals/ice_beast.png"),
    # beruang
    ("beast",            "animals/grizzly_bear.png"),
    ("choco_bear",       "animals/black_bear_new.png"),
    ("yeti_cub",         "animals/polar_bear.png"),
    # lendir & jelly
    ("slime",            "amorphous/ooze_new.png"),
    ("gummy_slime",      "amorphous/azure_jelly_new.png"),
    # tikus & makhluk kecil
    ("mouse",            "animals/grey_rat.png"),
    ("fluffbit",         "animals/green_rat.png"),
    ("volt_weasel",      "animals/giant_bat.png"),
    # rubah & burung
    ("frost_fox",        "animals/jackal_new.png"),
    ("snow_owl",         "raven.png"),
    ("thunder_hawk",     "phoenix.png"),
    # elemental
    ("frost_elemental",  "nonliving/water_elemental_new.png"),
    ("storm_elemental",  "nonliving/air_elemental_new.png"),
    ("rock_golem",       "nonliving/clay_golem.png"),
    # naga & wyvern
    ("thunder_dragon",   "dragons/dragon.png"),
    ("frost_wyvern",     "dragons/ice_dragon_new.png"),
    # air & laut
    ("storm_crab",       "animals/fire_crab.png"),
    ("volt_eel",         "aquatic/electric_eel.png"),
    ("cloud_ray",        "nonliving/insubstantial_wisp.png"),
    ("star_whale",       "aquatic/shark_new.png"),
    # gurun
    ("dune_serpent",     "animals/black_mamba_new.png"),
    # ── FROSTPEAK berbulu. `woolly_calf.png` ketinggalan di angkatan pertama alat ini
    #    dan tetap 64x64 sendirian, jadi ia satu-satunya yang masih hilang saat
    #    menghadap ke samping sesudah sisanya sembuh. Ia juga DIPAKAI BERDUA:
    #    `woolly_calf` dan `mammoth` menunjuk berkas yang sama — anak dan raksasa
    #    dengan siluet identik, persis cacat "lima nama, satu siluet" yang jadi alasan
    #    alat ini ada. Sekarang masing-masing punya seninya sendiri.
    ("woolly_calf",      "animals/yak_new.png"),
    ("mammoth",          "animals/elephant_dire_new.png"),
]

CELL = 64
KOL, BARIS = 4, 4                 # `monsters.json`: cols=4, rows=4
## Urutan baris DIKUNCI oleh `SheetUtil.DIRS` — bukan pilihan bebas.
ARAH = ["down", "up", "left", "right"]
## Angkatan kaki 4-frame: rangka 0 menapak (dipakai `idle_*`), rangka 1 & 3 terangkat.
BOB = [0, -2, 0, -2]


def lembar(sel):
    """Satu petak 64x64 -> lembar arah 256x256.

    KENAPA LEMBAR, BUKAN GAMBAR TUNGGAL
    -----------------------------------
    `monsters.json` menjanjikan `frame_size 64, cols 4, rows 4` untuk 59 dari 60
    entri, dan `SheetUtil.build_directional()` memotong `Rect2(col*64, row*64, 64, 64)`.
    Dengan berkas 64x64 cuma petak (0,0) yang ada DI DALAM gambar — sisanya di luar
    batas dan terbaca KOSONG. Diukur di mesin, bukan disimpulkan:

        idle_down    1 frame, 1 BERISI, 0 KOSONG
        idle_left    1 frame, 0 BERISI, 1 KOSONG
        walk_up      4 frame, 0 BERISI, 4 KOSONG

    Artinya monster terlihat HANYA saat diam menghadap bawah; menghadap atas, kiri,
    atau kanan ia hilang sama sekali. Ini regresi dari versi pertama alat ini, yang
    mengganti seni 16 px (yang 16*4=64 -> kebetulan PAS) dengan satu pose 64 px.

    SENI DCSS ITU SATU POSE DIAM — tak ada siklus jalan untuk dipanen, dan alat ini
    tidak mengarang satu. Yang dilakukan: pose yang sama diisikan ke keempat baris
    supaya monster SELALU terlihat, baris `right` dicerminkan (kalau seninya menghadap
    samping, kedua arah jadi benar; kalau menghadap depan, cermin nyaris tak terlihat
    dan tak merugikan), lalu rangka 1 & 3 diangkat 2 px sebagai langkah.

    ⚠ Ini BUKAN animasi jalan sungguhan, dan tak boleh dicatat sebagai itu. Ia
      menyembuhkan KEHILANGAN, bukan kekakuan. Kalau kelak dituntut siklus jalan
      betulan, sumbernya harus diganti — bukan ditambal di sini.
    """
    bb = sel.getbbox()
    tinggi = (bb[3] - bb[1]) if bb else 0
    # Bob cuma kalau ada ruang di atas kepala; sprite setinggi penuh akan terpotong.
    bob = BOB if tinggi <= CELL - 2 else [0, 0, 0, 0]
    kan = Image.new("RGBA", (CELL * KOL, CELL * BARIS), (0, 0, 0, 0))
    for r, arah in enumerate(ARAH):
        pose = sel.transpose(Image.FLIP_LEFT_RIGHT) if arah == "right" else sel
        for c in range(KOL):
            kan.alpha_composite(pose, (c * CELL, r * CELL + bob[c]))
    return kan


def main():
    if not os.path.exists(ZIP):
        print("[GAGAL] zip tak ada: %s" % ZIP, file=sys.stderr)
        return 1
    z = zipfile.ZipFile(ZIP)
    isi = set(z.namelist())

    hasil, hilang = [], []
    for nama, rel in PETA:
        p = DALAM + rel
        if p not in isi:
            hilang.append("%s <- %s" % (nama, rel))
            continue
        im = Image.open(io.BytesIO(z.read(p))).convert("RGBA")
        # kanvas 64x64, sprite diperbesar 2x lalu DIPUSATKAN & DIRATA-BAWAH:
        # monster berdiri di tanah, jadi kakinya yang harus menyentuh dasar petak.
        besar = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
        kan = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
        bb = besar.getbbox()
        if bb:
            potong = besar.crop(bb)
            x = (CELL - potong.width) // 2
            y = CELL - potong.height
            kan.alpha_composite(potong, (max(0, x), max(0, y)))
        hasil.append((nama, lembar(kan)))

    for h in hilang:
        print("  [HILANG] %s" % h)

    if "--lihat" in sys.argv:
        S, LK = 2, 8
        P = CELL * S
        baris = (len(hasil) + LK - 1) // LK
        kanv = Image.new("RGBA", (LK * P, baris * (P + 16)), (26, 24, 30, 255))
        d = ImageDraw.Draw(kanv)
        for i, (nama, im) in enumerate(hasil):
            x, y = (i % LK) * P, (i // LK) * (P + 16)
            # rangka (0,0) saja = `idle_down`; sisanya pose yang sama.
            muka = im.crop((0, 0, CELL, CELL))
            kanv.alpha_composite(muka.resize((P, P), Image.NEAREST), (x, y))
            d.text((x + 2, y + P + 2), nama[:16], fill=(230, 228, 234, 255))
        os.makedirs(os.path.dirname(PRATINJAU), exist_ok=True)
        kanv.save(PRATINJAU)
        print("-> %s  (%d monster, %d hilang)" % (PRATINJAU, len(hasil), len(hilang)))
        return 0

    os.makedirs(DST, exist_ok=True)
    for nama, im in hasil:
        im.save(os.path.join(DST, nama + ".png"))
    with open(os.path.join(DST, "monster64.credits.txt"), "w", encoding="utf-8") as f:
        f.write(
            "# Monster 64 px — dipotong `_tools/gen_monster64.py` dari ubin DCSS.\n"
            "# Menggantikan seni 16 px tanpa kredit (25 berkas, NOL provenans).\n"
            "# Keluarannya LEMBAR ARAH 256x256 (4x4 rangka 64 px), bukan gambar tunggal:\n"
            "# `monsters.json` menjanjikan cols=4/rows=4 dan `SheetUtil` memotong\n"
            "# menurut janji itu. Seni DCSS satu pose diam — pose yang sama diisikan ke\n"
            "# keempat arah (baris `right` dicerminkan) supaya monster tak hilang saat\n"
            "# menghadap selain bawah. Itu menyembuhkan KEHILANGAN, bukan kekakuan;\n"
            "# siklus jalan sungguhan menuntut sumber lain.\n"
            "# Diperbesar 2x nearest-neighbour: DCSS digambar untuk petak 32 px, dan\n"
            "# dunia ini berpetak 32 px dengan karakter setinggi dua petak.\n\n"
            "Pack   : Dungeon Crawl Stone Soup — ubin monster\n"
            "Seniman: penyumbang ubin DCSS\n"
            "Lisensi: CC0 1.0 (domain publik; atribusi tak wajib, tetap dicatat)\n"
            "URL    : https://opengameart.org/content/dungeon-crawl-32x32-tiles\n")
    print("\n-> %s   (%d monster + kredit)" % (DST, len(hasil)))
    return 1 if hilang else 0


if __name__ == "__main__":
    sys.exit(main())
