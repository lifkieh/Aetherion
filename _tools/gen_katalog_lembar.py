# -*- coding: utf-8 -*-
"""Lembar kontak katalog gudang — satu PNG per kategori-fungsi. (#240)

ATURAN YANG DIWUJUDKAN ALAT INI:
  Tiap petak diisi dari PNG yang SUNGGUH dibuka & dirasterisasi, bukan dari nama
  berkas. Gudang ini sudah menipu pembacanya lima kali (`tree_lpc` bukan pohon,
  `wall_ruin` pagar kayu, "kambing" ternyata ayam, `Everything.zip` ternyata ikon UI,
  `4-season_terrain` ternyata 96% berkas karakter). Kolom "apa ini SEBENARNYA"
  karenanya ditulis tangan SESUDAH melihat petaknya, dan alat ini cuma menyusun.

  Zip DIBACA DI MEMORI — nol ekstraksi. Mengekstrak sisa gudang = 52.000 berkas /
  891 MB masuk OneDrive Direktur.

Thumbnail memakai papan catur supaya alpha terlihat (berapa kali "latar transparan"
ternyata papan catur yang DILUKIS: satu kali, wisp Gemini — cukup untuk jadi aturan).
"""
import io
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw, ImageFont

GUDANG = r"C:\Users\user\OneDrive\Desktop\Gudang_asset"
OUT = r"D:\2DGAME\reports\preview\katalog"

## Dua kolom, petak besar — permintaan Direktur, dan alasannya teknis bukan selera:
## vonis "cocok gaya LPC" bergantung pada garis luar, palet, dan kebersihan piksel.
## Pada petak 340 px tiga-kolom, ubin 32 px tergambar ~11 px dan ketiganya hilang.
THUMB = 520
PAD = 16
CAP = 104            # tinggi blok keterangan
KOLOM = 2
## Lembar berbanding sisi ekstrem (Slates 1792x736, town_multi 256x2240) menyusut jadi
## pita tak terbaca kalau dipaskan utuh — dan petak yang tak terbaca melanggar seluruh
## alasan lembar ini ada. Di atas nisbah ini, yang ditampilkan POTONGAN, dan captionnya
## WAJIB mengatakannya supaya tak ada yang mengira sudah melihat seluruh lembar.
NISBAH_MAKS = 2.6

BG = (30, 32, 36)
TEKS = (232, 230, 224)
REDUP = (150, 152, 158)
VONIS = {"PAKAI": (126, 214, 130), "CEK": (232, 196, 96), "TOLAK": (226, 116, 110)}


def _font(n):
    for f in ("consola.ttf", "arial.ttf"):
        try:
            return ImageFont.truetype(f, n)
        except OSError:
            pass
    return ImageFont.load_default()


F_JUDUL, F_TEKS, F_KECIL = _font(17), _font(14), _font(12)


def potong_teks(d, t, font, lebar):
    """Potong berujung '…' berdasarkan lebar TERUKUR, bukan jumlah huruf.

    Versi pertama memotong di jumlah karakter tetap dan setengah keterangan hilang di
    tepi kanan ("Kit bangunan LPC: dinding+atap" -> "dinding+ata"). Keterangan yang
    terpenggal lebih buruk daripada keterangan pendek: pembacanya tak tahu ada yang hilang.
    """
    if d.textlength(t, font=font) <= lebar:
        return t
    while t and d.textlength(t + "…", font=font) > lebar:
        t = t[:-1]
    return t + "…"


def papan(w, h, k=10):
    im = Image.new("RGBA", (w, h), (108, 110, 114, 255))
    d = ImageDraw.Draw(im)
    for y in range(0, h, k):
        for x in range(0, w, k):
            if (x // k + y // k) % 2:
                d.rectangle([x, y, x + k - 1, y + k - 1], fill=(142, 144, 148, 255))
    return im


REPO = r"D:\2DGAME\game\assets\game"


def buka(sumber):
    """sumber = 'berkas.png' | 'repo:sprites/x.png' | ('paket.zip', 'jalur/dalam.png')"""
    if isinstance(sumber, str) and sumber.startswith("repo:"):
        return Image.open(os.path.join(REPO, sumber[5:])).convert("RGBA")
    if isinstance(sumber, tuple):
        z, jalur = sumber
        with zipfile.ZipFile(os.path.join(GUDANG, z)) as f:   # DI MEMORI, nol ekstrak
            return Image.open(io.BytesIO(f.read(jalur))).convert("RGBA")
    return Image.open(os.path.join(GUDANG, sumber)).convert("RGBA")


def petak(e):
    """Satu entri -> gambar THUMB x (THUMB+CAP). None kalau tak bisa dibuka."""
    try:
        im = buka(e["src"])
    except Exception as ex:
        print("   TAK TERLIHAT:", e["nama"], type(ex).__name__)
        return None, None
    asli = im.size
    potongan = False
    if e.get("crop"):
        im = im.crop(e["crop"])
        potongan = True
    elif max(asli) / min(asli) > NISBAH_MAKS:
        # ambil bagian TERPADAT (piksel tak-transparan terbanyak) sepanjang sisi panjang
        sisi = min(asli)
        if asli[0] > asli[1]:
            a = im.getchannel("A")
            langkah = max(1, (asli[0] - sisi) // 24)
            x = max(range(0, asli[0] - sisi + 1, langkah),
                    key=lambda k: sum(a.crop((k, 0, k + sisi, sisi)).getdata()))
            im = im.crop((x, 0, x + sisi, sisi))
        else:
            a = im.getchannel("A")
            langkah = max(1, (asli[1] - sisi) // 24)
            y = max(range(0, asli[1] - sisi + 1, langkah),
                    key=lambda k: sum(a.crop((0, k, sisi, k + sisi)).getdata()))
            im = im.crop((0, y, sisi, y + sisi))
        potongan = True
    # perbesar kalau kecil, kecilkan kalau raksasa — kisi tetap kelihatan
    s = THUMB / max(im.size)
    im = im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))),
                   Image.NEAREST if s >= 1 else Image.LANCZOS)
    sel = papan(THUMB, THUMB)
    sel.alpha_composite(im, ((THUMB - im.width) // 2, (THUMB - im.height) // 2))

    kartu = Image.new("RGBA", (THUMB, THUMB + CAP), BG)
    kartu.alpha_composite(sel)
    d = ImageDraw.Draw(kartu)
    L = THUMB - 12
    if potongan:                          # tanda di ATAS gambar, tak bisa terlewat
        d.rectangle([0, THUMB - 20, THUMB, THUMB], fill=(0, 0, 0, 170))
        d.text((6, THUMB - 18), "POTONGAN — bukan lembar utuh", font=F_KECIL,
               fill=(240, 200, 120))
    y = THUMB + 5
    d.text((6, y), potong_teks(d, e["ini"], F_JUDUL, L), font=F_JUDUL, fill=TEKS)
    y += 22
    warna = VONIS[e["vonis"]]
    tv = {"PAKAI": "PAKAI", "CEK": "CEK-lisensi", "TOLAK": "TOLAK"}[e["vonis"]]
    d.text((6, y), tv, font=F_TEKS, fill=warna)
    x2 = 6 + d.textlength(tv, font=F_TEKS) + 12
    d.text((x2, y), potong_teks(d, "%dx%d  %s" % (asli[0], asli[1], e["lisensi"]),
                                F_TEKS, L - x2 + 6), font=F_TEKS, fill=REDUP)
    y += 19
    d.text((6, y), potong_teks(d, "asal: " + e["asal"], F_KECIL, L), font=F_KECIL, fill=REDUP)
    y += 16
    if e["ini"] != e.get("nama_asli", e["ini"]):
        d.text((6, y), potong_teks(d, "nama berkas: " + e.get("nama_asli", ""), F_KECIL, L),
               font=F_KECIL, fill=(226, 160, 110))
    return kartu, asli


def lembar(judul, entri, nama_keluar):
    kartu = []
    for e in entri:
        k, _ = petak(e)
        if k:
            kartu.append(k)
            print("   ok:", e["ini"])
    baris = (len(kartu) + KOLOM - 1) // KOLOM
    W = KOLOM * THUMB + (KOLOM + 1) * PAD
    KEPALA = 64
    H = KEPALA + baris * (THUMB + CAP + PAD) + PAD
    im = Image.new("RGBA", (W, H), BG)
    d = ImageDraw.Draw(im)
    d.text((PAD, 14), judul, font=_font(28), fill=TEKS)
    d.text((PAD, 44), "tiap petak DILIHAT, bukan dibaca dari nama · papan catur = alpha",
           font=F_KECIL, fill=REDUP)
    for i, k in enumerate(kartu):
        x = PAD + (i % KOLOM) * (THUMB + PAD)
        y = KEPALA + (i // KOLOM) * (THUMB + CAP + PAD)
        im.alpha_composite(k, (x, y))
    os.makedirs(OUT, exist_ok=True)
    p = os.path.join(OUT, nama_keluar)
    im.convert("RGB").save(p)
    print("->", p, im.size)


# ═══ KATEGORI 1 — TILESET DASAR (tanah, jalan, pelataran) ═══
# Vonis & kolom "ini" ditulis SESUDAH melihat tiap lembar (sesi ini + GUDANG_UNTUK_ASHBROOK).
K1 = [
    {"ini": "Jalan tanah <-> rumput, autotile 3x3",
     "nama_asli": "Terrain/Grass-Dirt (Summer).png", "src": ("4-season_terrain.zip", "Terrain/Grass-Dirt (Summer).png"),
     "lisensi": "OGA-BY 3.0", "asal": "4-season_terrain.zip", "vonis": "PAKAI"},
    {"ini": "Tanah polos 3 varian", "nama_asli": "Terrain/Dirt (Non-Winter).png",
     "src": ("4-season_terrain.zip", "Terrain/Dirt (Non-Winter).png"),
     "lisensi": "OGA-BY 3.0", "asal": "4-season_terrain.zip", "vonis": "PAKAI"},
    {"ini": "Atlas terrain LPC: paving, tembok patah, nisan",
     "nama_asli": "terrain_atlas.png", "src": ("Atlas.zip", "terrain_atlas.png"),
     "lisensi": "CC-BY-SA 3.0/GPL", "asal": "Atlas.zip", "vonis": "PAKAI"},
    {"ini": "Kit bangunan LPC: dinding+atap+pintu sbg ubin",
     "nama_asli": "base_out_atlas.png", "src": ("Atlas.zip", "base_out_atlas.png"),
     "lisensi": "CC-BY-SA 3.0/GPL", "asal": "Atlas.zip", "vonis": "PAKAI"},
    {"ini": "Kit kota 32px terlengkap (gaya lbh pekat dr LPC)",
     "nama_asli": "Slates v.2 [32x32px orthogonal tileset by Ivan Voirol].png",
     "src": "Slates v.2 [32x32px orthogonal tileset by Ivan Voirol].png",
     "lisensi": "TAK ADA berkas", "asal": "PNG lepas di akar gudang", "vonis": "CEK"},
    {"ini": "Kit kota: atap banyak arah + air mancur BERAIR",
     "nama_asli": "tileset_town_multi_v002.png", "src": "tileset_town_multi_v002.png",
     "lisensi": "TAK ADA berkas", "asal": "PNG lepas di akar gudang", "vonis": "CEK"},
    {"ini": "Prop+cobble Mage City (SUDAH dipakai di repo)",
     "nama_asli": "magecity.png", "src": "magecity.png",
     "lisensi": "CC0 (Hyptosis)", "asal": "PNG lepas di akar gudang", "vonis": "PAKAI"},
    {"ini": "Rumput Avalon — palet kuning-pucat, bentrok",
     "nama_asli": "ground_tiles.png", "src": "ground_tiles.png",
     "lisensi": "GPL3 (tercetak di gambar)", "asal": "PNG lepas di akar gudang", "vonis": "TOLAK"},
    {"ini": "Palet GameBoy 4-warna hijau",
     "nama_asli": "fantasy-tileset.png", "src": "fantasy-tileset.png",
     "lisensi": "?", "asal": "PNG lepas di akar gudang", "vonis": "TOLAK"},
]

# ═══ KATEGORI 2 — RERUNTUHAN (fondasi berbentuk, tembok patah, puing) ═══
# Kategori paling dibutuhkan tata-ulang C3: yang dicari BUKAN "batu", melainkan bentuk
# yang terbaca "DULU INI BANGUNAN". Tiang tercecer gagal ujian itu; persegi tembok lulus.
K2 = [
    {"ini": "Tembok batu: persegi PENUH + sudut + versi RETAK",
     "nama_asli": "decoration_medieval/fence_medieval.png",
     "src": ("decoration_medieval.zip", "decoration_medieval/fence_medieval.png"),
     "crop": (224, 480, 512, 768),
     "lisensi": "CC-BY-SA 3.0/GPL", "asal": "decoration_medieval.zip", "vonis": "PAKAI"},
    {"ini": "Tembok bata RUNTUH berlubang + puing bata lepas",
     "nama_asli": "terrain_atlas.png", "src": ("Atlas.zip", "terrain_atlas.png"),
     "crop": (480, 640, 800, 960),
     "lisensi": "CC-BY-SA 3.0/GPL", "asal": "Atlas.zip", "vonis": "PAKAI"},
    {"ini": "Puing & serakan kerikil, 4 palet (beri MASSA)",
     "nama_asli": "rocks/rocks.png", "src": ("rocks.zip", "rocks/rocks.png"),
     "crop": (256, 256, 704, 704),
     "lisensi": "CC0", "asal": "rocks.zip", "vonis": "PAKAI"},
    {"ini": "Batu berdiri / dolmen — penanda lebih tua dr desa",
     "nama_asli": "rocks/rocks.png", "src": ("rocks.zip", "rocks/rocks.png"),
     "crop": (384, 0, 640, 256),
     "lisensi": "CC0", "asal": "rocks.zip", "vonis": "PAKAI"},
    {"ini": "Garis fondasi DIPAKAI di C3 — rata, nol massa",
     "nama_asli": "tiles/lpc32/fondasi32.png", "src": "repo:tiles/lpc32/fondasi32.png",
     "lisensi": "lihat fondasi32.credits.txt", "asal": "SUDAH di repo", "vonis": "PAKAI"},
    {"ini": "PAGAR KAYU UTUH — bukan reruntuhan sama sekali",
     "nama_asli": "sprites/lpc32/wall_ruin.png", "src": "repo:sprites/lpc32/wall_ruin.png",
     "lisensi": "lihat DEPRECATED.md", "asal": "SUDAH di repo — NAMA MENIPU", "vonis": "TOLAK"},
    {"ini": "Nisan SILUET HITAM, tampak samping, nol alpha",
     "nama_asli": "tombstones.png", "src": "tombstones.png",
     "lisensi": "?", "asal": "PNG lepas — utk latar parallax, bukan top-down", "vonis": "TOLAK"},
    {"ini": "Tebing Avalon — palet pucat, se-set ground_tiles",
     "nama_asli": "Cliff_tileset.png", "src": "Cliff_tileset.png",
     "lisensi": "GPL3 (tercetak di gambar)", "asal": "PNG lepas di akar gudang", "vonis": "TOLAK"},
]

LEMBAR = {
    "1": ("KATALOG 1 — TILESET DASAR (tanah · jalan · pelataran)", K1, "01_tileset_dasar.png"),
    "2": ("KATALOG 2 — RERUNTUHAN (fondasi · tembok patah · puing)", K2, "02_reruntuhan.png"),
}

if __name__ == "__main__":
    for k in (sys.argv[1:] or sorted(LEMBAR)):
        j, e, n = LEMBAR[k]
        print("==", j)
        lembar(j, e, n)
