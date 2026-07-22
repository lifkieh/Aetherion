#!/usr/bin/env python3
"""Potong sprite HEWAN dari gudang -> repo + katalog + kredit (design-time, #240).

KENAPA SATU BENTUK UNTUK SEMUA: STRIP HADAP-KIRI
------------------------------------------------
Sumbernya beragam — `ram` bergaya LPC 4-arah (N/S/E/W), `wolf`/`deer` strip
tampak-samping satu arah. Menyimpan keduanya apa adanya berarti aktor harus tahu
dua format, dan tiap hewan baru berpotensi menambah format ketiga.

Jadi semuanya DINORMALKAN di sini menjadi satu bentuk: **strip mendatar berisi N
frame yang menghadap KIRI**. Untuk `ram`, baris hadap-barat yang diambil (baris 3 —
diverifikasi mata: 0=belakang, 1=hadap-kanan, 2=depan, 3=hadap-kiri). Aktor cukup
membalik horizontal saat hewan bergerak ke kanan. Satu format, satu jalur kode.

Direktur mengizinkan hewan kiri-kanan saja; keputusan itu yang membuat penyeragaman
ini mungkin.

KREDIT
------
Ditulis tiga tempat sekaligus supaya tak bisa terpisah dari asetnya:
`<sprite>.credits.txt` di sebelah PNG · `katalog_hewan.json` · `credits_db.json`.

Pemakaian:
  python gen_hewan.py
"""
import io
import json
import os
import sys
import zipfile

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
GUDANG = r"C:\Users\user\OneDrive\Desktop\Gudang_asset"
DST = os.path.join(REPO, "game", "assets", "game", "sprites", "animals")
KATALOG = os.path.join(REPO, "game", "data", "katalog_hewan.json")
CREDITS_DB = os.path.join(REPO, "_tools", "lpc_assembler", "credits_db.json")

PACK = {
    "stendhal_animals": {
        "nama": "Stendhal Animals (git 99362c8)",
        "pencipta": "Kimmo Rundelin (kiheru)",
        "license": "CC-BY-SA 3.0 atau lebih baru",
        "url": "https://opengameart.org/node/81251",
        "terverifikasi": True,
    },
    "seasons_forest_cc0": {
        "nama": "Seasons of Forest Animal Pack (sampel gratis v1)",
        "pencipta": "inkbubi",
        "license": "CC0 1.0 (domain publik; atribusi tak wajib, tetap dicatat)",
        "url": "https://inkbubi.itch.io/seasons-of-forest-animal-pack",
        "terverifikasi": True,
    },
    "dcss_tiles": {
        "nama": "Dungeon Crawl Stone Soup - ubin monster",
        "pencipta": "penyumbang ubin DCSS",
        "license": "CC0 1.0 (domain publik; atribusi tak wajib, tetap dicatat)",
        "url": "https://opengameart.org/content/dungeon-crawl-32x32-tiles",
        "terverifikasi": True,
    },
    "deer_rework": {
        "nama": "Deer (Rework) - 32x32, N/E/S/W, 3 frame per arah",
        "pencipta": "Calciumtrice; dikerjakan ulang untuk Stendhal oleh Jordan Irwin (AntumDeluge)",
        "license": "CC-BY 3.0 (atribusi WAJIB, TIDAK menular)",
        "url": "https://opengameart.org/content/deer-rework",
        "terverifikasi": True,
    },
    "wolfpack_cc0": {
        "nama": "Wolf Pack! 32x32 Walking Wolf Animation",
        "pencipta": "patvanmackelberg",
        "license": "CC0 1.0 (domain publik; atribusi tak wajib, tetap dicatat)",
        "url": "https://opengameart.org/content/wolf-pack-32x32-walking-wolf-animation",
        "terverifikasi": True,
    },
    "pig_rework": {
        "nama": "Pigs Rework v1.1 (sprite babi daneeklu, dirapikan untuk Stendhal)",
        "pencipta": "daneeklu (asli) · pengerjaan ulang Pigs Rework v1.1",
        "license": "CC-BY 3.0 (atribusi WAJIB, TIDAK menular)",
        "url": "https://opengameart.org/content/lpc-style-farm-animals",
        "terverifikasi": True,
    },
    "wild_animals_all": {
        "nama": "Wild Animals (berkas gudang 'All.zip')",
        "pencipta": "TIDAK TERCATAT — zip sumber tak memuat berkas kredit apa pun",
        "license": "TIDAK TERCATAT",
        "url": "",
        "terverifikasi": False,
    },
    "ninja_adventure": {
        "nama": "Ninja Adventure - Asset Pack",
        "pencipta": "Pixel-boy / Aleksandr Makarov",
        "license": "CC0 1.0",
        "url": "https://pixel-boy.itch.io/ninja-adventure-asset-pack",
        "terverifikasi": True,
    },
    # Kreditnya TIDAK ditebak: `README.txt` DI DALAM zip menyebut sumber, pengolah,
    # dan lisensinya verbatim — persis jalur yang diminta #277, dan persis yang
    # HILANG pada `wild_animals_all` di atas.
    "lpc_birds": {
        "nama": "[LPC] Birds",
        "pencipta": "bluecarrot16, dipesan oleh castelonia",
        "license": "OGA-BY 3.0 (berganda: juga CC-BY 4.0/3.0, CC-BY-SA 4.0/3.0, GPL 2/3)",
        "url": "https://opengameart.org/content/lpc-birds",
        "terverifikasi": True,
    },
    "lpc_cats_dogs": {
        "nama": "[LPC] Cats and Dogs (rilis 'cat v1.0' untuk Stendhal)",
        "pencipta": "bluecarrot16; diolah ulang untuk Stendhal oleh Jordan Irwin (AntumDeluge)",
        # Zip menyertakan teks CC-BY-SA 3.0, TAPI README-nya menyatakan karya ini boleh
        # juga diedarkan di bawah CC-BY 3.0 / GPL 2 / GPL 3 / OGA-BY 3.0. Dipilih
        # OGA-BY 3.0 karena ia TAK MENULAR: kucing ini tak menyeret sisa repo ke
        # share-alike. Pelajaran yang sama dengan penolakan `[LPC] Walls` di ASSET_LOG —
        # bedanya di sini ada pilihan sah yang tidak menular, jadi tak perlu ditolak.
        "license": "OGA-BY 3.0 (berganda: juga CC-BY-SA 3.0 / CC-BY 3.0 / GPL 2 / GPL 3)",
        "url": "https://opengameart.org/node/69399",
        "terverifikasi": True,
    },
}

## Zip sumber yang hidup DI DALAM repo — bukan di gudang Desktop. Bedanya penting:
## yang di gudang tak ikut ter-commit, jadi generatornya cuma bisa dijalankan ulang
## di mesin yang punya gudang itu. Yang di `assets_raw/` bisa dijalankan siapa pun
## yang meng-clone repo, dan itulah arti #240 yang sebenarnya.
ZIP_KUCING = os.path.join(REPO, "assets_raw", "lpc", "cat-1.0.zip")
## `assets_raw/oga/` DIKECUALIKAN dari .gitignore: sumber kecil berlisensi permisif,
## diunduh langsung dari OpenGameArt dan ikut ter-commit. Itulah arti #240 yang
## sebenarnya — apa pun yang cuma ada di gudang Desktop membuat generator ini tak bisa
## diulang oleh orang lain yang meng-clone repo.
OGA = os.path.join(REPO, "assets_raw", "oga")
## Lembar ANJING diunduh dari halaman OGA-nya langsung, lalu disimpan di repo
## BERSAMA berkas kreditnya (`.credits.txt` di sebelahnya). Kucing datang lewat zip
## Stendhal yang kebetulan memuat README; anjing tak punya zip semacam itu, jadi
## kreditnya ditulis tangan dari halaman sumber dan disertai sha256 unduhannya —
## supaya "dari mana ini?" tak pernah jadi pertanyaan tanpa jawaban lagi.
PNG_ANJING = os.path.join(REPO, "assets_raw", "lpc", "lpc_cats_and_dogs_dog.png")
PNG_BURUNG_HITAM = os.path.join(REPO, "assets_raw", "lpc", "lpc_birds_black.png")
PNG_BURUNG_PUTIH = os.path.join(REPO, "assets_raw", "lpc", "lpc_birds_white.png")

# (id, sumber, jenis, param, pack, skala, kecepatan, catatan)
#   jenis "baris" : lembar 4-arah, ambil satu baris  -> (fw, fh, baris, n_frame)
#   jenis "strip" : sudah strip satu arah            -> (fw, fh, n_frame)
#   jenis "repo"  : sudah ada di repo, tak dipotong   -> (fw, fh, n_frame)
#   jenis "blok"  : lembar banyak-warna DI DALAM ZIP -> (fw, fh, kolom0, baris, n_frame, balik_h)
#
# `kecepatan` px/detik. Ayam menyambar, domba merumput, kucing liar menyelinap lalu
# menghambur. Satu angka untuk semua membuat domba tampak meluncur di atas rumput —
# dan itu membatalkan bobot yang sudah diberikan oleh ukurannya.
JOBS = [
    ("ayam", "repo:chicken.png", "repo", (16, 16, 2), "ninja_adventure", 0.9, 26.0,
     "sprite lama sudah benar; yang salah cuma skalanya (dulu 1.6 = ayam sebesar anjing)"),
    # ⚠ DOMBA DIGANTI BABI KARENA LISENSI, BUKAN KARENA SELERA.
    #   Domba lama = `stendhal_animals/ram.png`, CC-BY-SA 3.0 (Kimmo Rundelin). SA
    #   menular ke turunannya, jadi ia melanggar #232 di luar `characters/` — dan tak
    #   ada cara mematuhinya selain mengarantina seekor ternak latar.
    #   Babi ini CC-BY 3.0: atribusi WAJIB, tapi TIDAK menular.
    #   Bonusnya aslinya sprite LPC (daneeklu), jadi gayanya lebih sepadan dengan warga
    #   Ashbrook daripada domba yang ia gantikan.
    #   Baris 3 = hadap BARAT. Urutan lembar N/E/S/W menurut README pack, dan barat
    #   itulah yang cocok dengan kebiasaan repo (sprite menghadap KIRI).
    ("babi", os.path.join(GUDANG, "pig-1.1", "PNG", "64x64", "pig.png"), "baris",
     (64, 64, 3, 3), "pig_rework", 1.0, 13.0,
     "babi ternak. Menggantikan domba CC-BY-SA yang tak bisa dipatuhi di luar "
     "characters/. Desa bekas-kota pun lebih masuk akal beternak babi: babi makan "
     "sisa, domba menuntut padang"),
    # RUSA JANTAN BERTANDUK, CC-BY 3.0. Dua sumber sebelumnya gagal dengan cara
    #   berbeda: `All/Wild Animals` lisensinya TIDAK TERCATAT, dan doe CC0
    #   penggantinya tak bertanduk sehingga WHITE STAG sempat turun jadi WHITE DOE.
    #   Menggambar tanduk sendiri dicoba dua kali lalu ditolak — pada 41x33 ia terbaca
    #   serpihan melayang. Yang membereskannya bukan teknik, melainkan berhenti
    #   menyisir gudang lokal saja dan mencari ke OpenGameArt.
    #   Format identik babi (perawat pack yang sama, AntumDeluge): N/E/S/W, baris 3 =
    #   hadap BARAT, 3 frame. Alpha sumbernya sudah bersih.
    ("rusa", os.path.join(OGA, "deer-m-run.png"), "baris", (32, 32, 3, 3),
     "deer_rework", 1.6, 22.0,
     "rusa jantan BERTANDUK. Memulihkan WHITE STAG (#D-ASH-4)"),
    # SERIGALA, CC0. Petak 8x8: empat warna x empat baris (samping-kanan,
    #   samping-kiri, depan, belakang). Diambil KELABU baris samping-kiri —
    #   kolom 4-7, baris 1. Latar tiap petak opak dan beda warna, dikupas
    #   `tanpa_latar_petak()` di generator, bukan disunting tangan.
    #   Lapis 3 (serigala malam) masih DITAHAN Direktur; asetnya sudah siap dan sah.
    ("serigala", os.path.join(OGA, "Wolfpack.png"), "petak", (32, 32, 4, 1, 4, False),
     "wolfpack_cc0", 1.5, 30.0,
     "serigala kelabu CC0. Menggantikan sumber 'All/Wild Animals' yang lisensinya "
     "TIDAK TERCATAT"),

    # ── LAPIS 2: KUCING LIAR ─────────────────────────────────────────────────
    # `PNG/cat.png` = 16x8 petak 32x32. Empat blok warna empat kolom:
    # putih 0-3 · jingga 4-7 · cokelat 8-11 · kelabu 12-15.
    # Baris 0 kolom 0-2 = jalan tampak-samping HADAP KIRI (diverifikasi mata,
    # reports/preview/blockout/L2_cat_sheet.png — bukan diandaikan dari urutan baris,
    # karena urutan baris LPC dan Stendhal TIDAK sama).
    # Kolom ke-4 tiap blok bukan frame jalan melainkan pose berbaring — itulah yang
    # dipakai kucing penunggu di bawah.
    ("kucing_kelabu", ZIP_KUCING + "|PNG/cat.png", "blok", (32, 32, 12, 0, 3, True),
     "lpc_cats_dogs", 1.0, 34.0,
     "kucing liar. Kelabu dipilih untuk tepi & distrik bekas: ia hilang di antara "
     "batu, dan kucing yang sulit dilihat lebih terbaca liar daripada kucing berwarna"),
    ("kucing_jingga", ZIP_KUCING + "|PNG/cat.png", "blok", (32, 32, 4, 0, 3, True),
     "lpc_cats_dogs", 1.0, 34.0,
     "kucing liar kedua. Warna berbeda supaya dua ekor di layar terbaca DUA EKOR, "
     "bukan satu sprite yang muncul dua kali"),

    # ── LAPIS 2: ANJING LIAR ─────────────────────────────────────────────────
    # Lembar anjing bertata letak PERSIS sama dengan lembar kucing (512x256, petak
    # 32x32, empat blok warna empat kolom: putih 0-3 · cokelat 4-7 · kuning 8-11 ·
    # kelabu 12-15) — jadi `blok` yang sama menjawab keduanya, nol kode baru.
    ("anjing_cokelat", PNG_ANJING, "blok", (32, 32, 4, 0, 3, True),
     "lpc_cats_dogs", 1.0, 30.0,
     "anjing liar. Anjing dulu SETIA pada manusia, jadi anjing yang tak lagi punya "
     "tuan menyayat dengan cara yang tak bisa dilakukan kucing liar"),
    ("anjing_kelabu", PNG_ANJING, "blok", (32, 32, 12, 0, 3, True),
     "lpc_cats_dogs", 1.0, 30.0,
     "anjing liar kedua; warna berbeda supaya dua ekor terbaca dua ekor"),

    # ── LAPIS 2.5: BURUNG ────────────────────────────────────────────────────
    # 96x256 = 3 frame x 8 baris petak 32x32. Baris 0-3 TERBANG, 4-7 BERJALAN,
    # dan baris hadap-kiri sudah ada di keduanya (0 dan 4) — jadi NOL pembalikan.
    # Diverifikasi mata (L25_burung_lembar.png), bukan diandaikan dari urutan LPC:
    # lembar kucing pack yang sama justru menghadap kanan.
    #
    # Merpati DI INTI, gagak DI BEKAS, dan itu bukan pilihan warna. Merpati hidup
    # dekat manusia karena manusia menjatuhkan makanan; gagak berkumpul di tempat
    # yang manusianya sudah pergi. Dua burung yang memilih tempat berlawanan
    # menceritakan penyusutan kota tanpa satu kata pun.
    ("merpati", PNG_BURUNG_PUTIH, "blok", (32, 32, 0, 4, 3, False),
     "lpc_birds", 1.0, 18.0,
     "merpati alun-alun — mematuk tanah dekat orang. Jinak: ia satu-satunya burung "
     "yang membiarkan pemain mendekat sebelum terbang"),
    ("merpati_terbang", PNG_BURUNG_PUTIH, "blok", (32, 32, 0, 0, 3, False),
     "lpc_birds", 1.0, 96.0,
     "frame TERBANG merpati — ditukar saat kabur, lalu ditukar balik saat mendarat"),
    ("gagak", PNG_BURUNG_HITAM, "blok", (32, 32, 0, 4, 3, False),
     "lpc_birds", 1.0, 20.0,
     "gagak tepi & distrik bekas — burung yang berkumpul di tempat ditinggalkan"),
    ("gagak_terbang", PNG_BURUNG_HITAM, "blok", (32, 32, 0, 0, 3, False),
     "lpc_birds", 1.0, 104.0,
     "frame TERBANG gagak"),
]

## Pose DIAM — bukan hewan berkelana, jadi tak masuk JOBS (nol frame jalan, nol
## kecepatan). Kucing yang duduk menunggu di depan rumah gelap harus BENAR-BENAR
## diam; memberinya `wander_radius` sekecil apa pun membatalkan seluruh maksudnya.
POSE = [
    ("kucing_menunggu.png", ZIP_KUCING + "|PNG/cat.png", (32, 32, 15, 4, False),
     "kucing kelabu DUDUK menghadap depan — dipasang di ambang rumah gelap"),
    ("kucing_meringkuk.png", ZIP_KUCING + "|PNG/cat.png", (32, 32, 15, 0, True),
     "kucing kelabu MERINGKUK — pose tidur, untuk sudut yang lebih terlindung"),
    ("anjing_menunggu.png", PNG_ANJING, (32, 32, 15, 4, False),
     "anjing kelabu DUDUK menghadap depan — menunggu tuan yang tak pulang. Pose yang "
     "sama pada kucing berkata 'aku tinggal di sini'; pada anjing ia berkata 'aku "
     "menunggu', dan bedanya datang dari hewannya, bukan dari gambarnya"),
]


class HewanError(Exception):
    """Kegagalan yang menghentikan build."""


def buka(src):
    """Buka sumber, baik berkas lepas maupun `<zip>|<jalur di dalam>`.

    Zip dibaca DI MEMORI: mengekstraknya lebih dulu meninggalkan salinan yang
    tak seorang pun tahu harus dibersihkan, dan salinan itulah yang berikutnya
    dikira sumber asli.
    """
    if "|" in src:
        zpath, inner = src.split("|", 1)
        if not os.path.exists(zpath):
            raise HewanError(f"zip hilang: {zpath}")
        with zipfile.ZipFile(zpath) as z:
            return Image.open(io.BytesIO(z.read(inner))).convert("RGBA")
    if not os.path.exists(src):
        raise HewanError(f"sumber hilang: {src}")
    return Image.open(src).convert("RGBA")


def tanpa_latar_petak(im, fw, fh):
    """Kupas latar OPAK yang warnanya BEDA TIAP PETAK.

    `Wolfpack.png` memakai papan catur warna-warni sebagai latar supaya tiap frame
    terlihat saat dilihat manusia. Mengupas satu warna global akan menyisakan tujuh
    warna lain; mengupas "warna paling sering" bisa memakan tubuh serigala putih.
    Jadi tiap petak dibaca sendiri: piksel pojoknya ADALAH latar petak itu.
    """
    out = im.copy()
    p = out.load()
    for by in range(im.height // fh):
        for bx in range(im.width // fw):
            latar = p[bx * fw, by * fh]
            if latar[3] == 0:
                continue                       # petak ini memang sudah transparan
            for y in range(by * fh, (by + 1) * fh):
                for x in range(bx * fw, (bx + 1) * fw):
                    if p[x, y][:3] == latar[:3]:
                        p[x, y] = (0, 0, 0, 0)
    return out


def potong(job):
    hid, src, jenis, par, pack, skala, kecepatan, cat = job
    if jenis == "repo":
        fw, fh, n = par
        keluar = "chicken.png"
        return keluar, fw, fh, n
    im = buka(src)
    if jenis == "petak":
        im = tanpa_latar_petak(im, par[0], par[1])
        jenis = "blok"
    if jenis == "blok":
        fw, fh, c0, baris, n, balik = par
        if im.width < (c0 + n) * fw or im.height < (baris + 1) * fh:
            raise HewanError(f"{src}: {im.size} tak memuat blok ({c0},{baris}) x{n}")
        potongan = im.crop((c0 * fw, baris * fh, (c0 + n) * fw, (baris + 1) * fh))
        if balik:
            # ⚠ DIBALIK DI SINI, BUKAN DI AKTOR. Lembar kucing Stendhal menghadap
            #   KANAN; seluruh repo bersepakat hadap-KIRI. Memperbaikinya di sisi
            #   pemanggil (`flip_h` dibalik khusus kucing) berarti satu hewan yang
            #   aturannya berbeda dari semua hewan lain — dan aturan yang berlaku
            #   untuk satu kasus adalah aturan yang akan dilanggar diam-diam oleh
            #   hewan kesebelas. Berkasnya yang dinormalkan, bukan kodenya.
            #   Membalik TIAP FRAME sendiri-sendiri, bukan seluruh strip: membalik
            #   strip utuh juga membalik URUTAN frame, dan jalannya jadi mundur.
            hasil = Image.new("RGBA", potongan.size, (0, 0, 0, 0))
            for i in range(n):
                f = potongan.crop((i * fw, 0, (i + 1) * fw, fh))
                hasil.paste(f.transpose(Image.FLIP_LEFT_RIGHT), (i * fw, 0))
            potongan = hasil
        keluar = f"{hid}_kiri.png"
        potongan.save(os.path.join(DST, keluar))
        return keluar, fw, fh, n
    if jenis == "baris":
        fw, fh, baris, n = par
        if im.height < (baris + 1) * fh:
            raise HewanError(f"{src}: {im.size} tak punya baris {baris}")
        potongan = im.crop((0, baris * fh, n * fw, (baris + 1) * fh))
    else:
        fw, fh, n = par
        if im.width < n * fw or im.height < fh:
            raise HewanError(f"{src}: {im.size} lebih kecil dari {n}x{fw}x{fh}")
        potongan = im.crop((0, 0, n * fw, fh))
    keluar = f"{hid}_kiri.png"
    potongan.save(os.path.join(DST, keluar))
    return keluar, fw, fh, n


def main(argv=None):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    os.makedirs(DST, exist_ok=True)
    katalog = {
        "_doc": "Katalog HEWAN (#240). Satu tempat untuk semua wilayah. Menambah hewan = "
                "menambah baris di sini + satu baris di gen_hewan.py — bukan skrip aktor baru.",
        "_bentuk": "Tiap sprite adalah STRIP MENDATAR berisi `frame` gambar berukuran "
                   "`fw`x`fh`, semuanya MENGHADAP KIRI. Aktor membalik horizontal saat "
                   "hewan bergerak ke kanan. Satu format, satu jalur kode.",
        "_kecepatan_doc": "px/detik saat berkelana. Ayam menyambar, domba merumput, kucing liar menyelinap. Satu angka untuk semua membuat domba tampak meluncur di atas rumput, dan itu membatalkan bobot yang diberikan ukurannya.",
        "_skala_doc": "skala relatif manusia LPC 64px. Nilai di sini sudah proporsi ternak; "
                      "JANGAN disetel ulang di sisi pemanggil — begitulah kambing dulu jadi "
                      "ayam 3x.",
        "pack": PACK,
        "hewan": {},
    }
    for job in JOBS:
        hid, src, jenis, par, pack, skala, kecepatan, cat = job
        try:
            berkas, fw, fh, n = potong(job)
        except HewanError as e:
            print(f"[GAGAL] {hid}: {e}", file=sys.stderr)
            return 2
        katalog["hewan"][hid] = {
            "sprite": f"res://assets/game/sprites/animals/{berkas}",
            "fw": fw, "fh": fh, "frame": n,
            "arah": "kiri_kanan",
            "skala": skala,
            "kecepatan": kecepatan,
            "pack": pack,
            "_catatan": cat,
        }
        p = PACK[pack]
        with open(os.path.join(DST, berkas.replace(".png", ".credits.txt")), "w",
                  encoding="utf-8") as f:
            f.write(f"# {berkas} — hewan '{hid}'\n# {cat}\n\n"
                    f"Pack   : {p['nama']}\nSeniman: {p['pencipta']}\n"
                    f"Lisensi: {p['license']}\nURL    : {p['url']}\n")
        print(f"[OK] {hid:9} -> {berkas:18} {n} frame {fw}x{fh}  skala {skala}  [{pack}]")

    # POSE DIAM — satu frame, nol animasi, nol katalog. Sengaja TIDAK masuk
    # `katalog_hewan.json`: yang masuk katalog adalah hewan yang BERKELANA, dan
    # kucing penunggu justru bercerita karena ia tidak. Menaruhnya di katalog akan
    # mengundang orang berikutnya memberinya `wander_radius`, dan itu menghapus
    # seluruh maksudnya.
    for nama, src, par, cat in POSE:
        fw, fh, c, r, balik = par
        try:
            im = buka(src)
        except HewanError as e:
            print(f"[GAGAL] {nama}: {e}", file=sys.stderr)
            return 2
        pose = im.crop((c * fw, r * fh, (c + 1) * fw, (r + 1) * fh))
        if balik:
            pose = pose.transpose(Image.FLIP_LEFT_RIGHT)
        pose.save(os.path.join(DST, nama))
        p = PACK["lpc_cats_dogs"]
        with open(os.path.join(DST, nama.replace(".png", ".credits.txt")), "w",
                  encoding="utf-8") as f:
            f.write(f"# {nama} — pose diam\n# {cat}\n\n"
                    f"Pack   : {p['nama']}\nSeniman: {p['pencipta']}\n"
                    f"Lisensi: {p['license']}\nURL    : {p['url']}\n")
        print(f"[OK] {'pose':9} -> {nama:22} 1 frame {fw}x{fh}")

    # RUSA PUTIH (#D-ASH-4). Legendanya rusa PUTIH; asetnya rusa COKELAT, dan
    # `modulate` di sisi scene tak bisa memperbaikinya — mengalikan warna cuma
    # MENERANGKAN cokelat, jadi hasilnya rusa cokelat yang silau. Yang dibutuhkan
    # penghilangan warna, dan itu operasi piksel: ia milik generator, bukan scene.
    # Sisa warna 12% ditahan dengan sengaja — putih rata terbaca sebagai siluet
    # hilang, bukan sebagai makhluk pucat.
    src_r = os.path.join(DST, "rusa_kiri.png")
    if os.path.exists(src_r):
        r = Image.open(src_r).convert("RGBA")
        px = r.load()
        for y in range(r.height):
            for x in range(r.width):
                cr, cg, cb, ca = px[x, y]
                if ca == 0:
                    continue
                abu = int(0.299 * cr + 0.587 * cg + 0.114 * cb)
                # 0.45, BUKAN 0.82. Percobaan pertama menarik terlalu jauh ke putih dan
                # seluruh bentuk hilang - yang tersisa gumpalan putih, bukan makhluk
                # pucat. Justru bayangan yang masih tertinggal itu yang membuatnya
                # terbaca sebagai penampakan.
                terang = int(abu + (255 - abu) * 0.45)
                px[x, y] = (terang, terang, min(255, terang + 8), ca)
        r.save(os.path.join(DST, "rusa_putih_kiri.png"))
        p_r = PACK["deer_rework"]
        with open(os.path.join(DST, "rusa_putih_kiri.credits.txt"), "w",
                  encoding="utf-8") as f:
            f.write(
                "# rusa_putih_kiri.png — rusa JANTAN dipucatkan untuk WHITE STAG (#D-ASH-4)\n"
                "# Sempat turun jadi WHITE DOE waktu satu-satunya sumber berlisensi\n"
                "# bersih tak bertanduk. Dipulihkan sesudah pencarian diperluas ke\n"
                "# OpenGameArt — tanduk itu yang membuat legendanya terbaca.\n"
                "# Turunan `rusa_kiri.png`: luminans + pemutihan, dikerjakan di\n"
                "# generator karena `modulate` cuma bisa MENGALIKAN warna — ia tak\n"
                "# bisa menghapusnya, jadi rusa cokelat yang di-modulate terang\n"
                "# tetap rusa cokelat, cuma silau.\n\n"
                f"Pack   : {p_r['nama']}\n"
                f"Seniman: {p_r['pencipta']}\n"
                f"Lisensi: {p_r['license']}\n")
        print("[OK] rusa      -> rusa_putih_kiri.png  3 frame 32x32 (WHITE STAG)")

    # SERIGALA versi MONSTER. `DungeonMonster._apply()` memakai satu frame PERSEGI
    # (`region = Rect2(0,0,fs,fs)`) dan membalik horizontal sendiri. Serigala tetap
    # `DungeonMonster` — ia momen #118 (boleh ditolong / diabaikan / dibunuh), dan
    # menjadikannya hewan hias akan MENGHAPUS momen itu. Yang diganti cuma gambarnya.
    # Serigala kelabu dari lembar CC0 yang sama dengan `serigala_kiri` — SATU sumber
    # untuk dua peran. Sebelumnya di sini dipakai ubin DCSS: juga CC0 dan juga
    # serigala sungguhan, tapi ia membawa BAYANGAN yang sudah dipanggang ke dalam
    # gambarnya, dan bayangan panggang di atas latar transparan terbaca sebagai
    # gumpalan hitam yang menempel. Dipakai petak DEPAN (baris 2) supaya monster
    # menghadap pemain, bukan melintasinya.
    src = os.path.join(OGA, "Wolfpack.png")
    if os.path.exists(src):
        lembar = tanpa_latar_petak(buka(src), 32, 32)
        w = lembar.crop((4 * 32, 2 * 32, 5 * 32, 3 * 32))
        kotak = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        w = w.resize((64, 64), Image.NEAREST)   # 32->64: monster seukuran petak dunia
        kotak.alpha_composite(w, (0, 0))
        kotak.save(os.path.join(DST, "serigala_monster.png"))
        p = PACK["wolfpack_cc0"]
        with open(os.path.join(DST, "serigala_monster.credits.txt"), "w",
                  encoding="utf-8") as f:
            f.write(f"# serigala_monster.png — frame persegi 64x64 untuk DungeonMonster\n\n"
                    f"Pack   : {p['nama']}\nSeniman: {p['pencipta']}\n"
                    f"Lisensi: {p['license']}\n")
        print("[OK] serigala  -> serigala_monster.png  1 frame 64x64 (DungeonMonster)")

    with open(KATALOG, "w", encoding="utf-8") as f:
        json.dump(katalog, f, ensure_ascii=False, indent=2)
    print(f"\nkatalog -> {KATALOG}")

    db = {}
    if os.path.exists(CREDITS_DB):
        with open(CREDITS_DB, encoding="utf-8") as f:
            db = json.load(f)
    for hid, h in katalog["hewan"].items():
        p = PACK[h["pack"]]
        db[os.path.basename(h["sprite"])] = {
            "author": p["pencipta"], "license": p["license"],
            "pack": p["nama"], "url": p["url"],
            "terverifikasi": p["terverifikasi"]}
    with open(CREDITS_DB, "w", encoding="utf-8") as f:
        json.dump(db, f, ensure_ascii=False, indent=2, sort_keys=True)
    print(f"kredit  -> {CREDITS_DB}")

    tak = [k for k, v in PACK.items() if not v["terverifikasi"]]
    if tak:
        print(f"\n⚠ pack TANPA kredit tercatat di zip sumber: {', '.join(tak)}")
        print("  Dipakai dengan atribusi tingkat-pack + ditandai terverifikasi=false,")
        print("  mengikuti preseden 4 pack ULPC. Penelusuran seniman = utang-rilis.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
