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
## Lembar ANJING diunduh dari halaman OGA-nya langsung, lalu disimpan di repo
## BERSAMA berkas kreditnya (`.credits.txt` di sebelahnya). Kucing datang lewat zip
## Stendhal yang kebetulan memuat README; anjing tak punya zip semacam itu, jadi
## kreditnya ditulis tangan dari halaman sumber dan disertai sha256 unduhannya —
## supaya "dari mana ini?" tak pernah jadi pertanyaan tanpa jawaban lagi.
PNG_ANJING = os.path.join(REPO, "assets_raw", "lpc", "lpc_cats_and_dogs_dog.png")

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
    ("domba", os.path.join(GUDANG, "stendhal_animals-99362c8-1", "ram.png"), "baris",
     (48, 64, 3, 3), "stendhal_animals", 1.0, 13.0,
     "domba jantan bertanduk. NOL kambing di seluruh 111 zip gudang — domba adalah "
     "ternak berkaki empat bergaya LPC satu-satunya yang ada"),
    ("serigala", os.path.join(GUDANG, "All", "Wild Animals", "Wolf", "Wolf_Walk.png"),
     "strip", (64, 40, 8), "wild_animals_all", 1.0, 30.0,
     "menggantikan grey_wolf.png 16px yang terbaca sebagai serangga di dunia 64px"),
    ("rusa", os.path.join(GUDANG, "All", "Wild Animals", "Deer", "Deer_Walk.png"),
     "strip", (72, 52, 8), "wild_animals_all", 1.0, 22.0,
     "rusa jantan BERTANDUK — menggantikan Image.create(6,10) kotak putih polos"),

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


def potong(job):
    hid, src, jenis, par, pack, skala, kecepatan, cat = job
    if jenis == "repo":
        fw, fh, n = par
        keluar = "chicken.png"
        return keluar, fw, fh, n
    im = buka(src)
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

    # SERIGALA versi MONSTER. `DungeonMonster._apply()` memakai satu frame PERSEGI
    # (`region = Rect2(0,0,fs,fs)`) dan membalik horizontal sendiri. Serigala tetap
    # `DungeonMonster` — ia momen #118 (boleh ditolong / diabaikan / dibunuh), dan
    # menjadikannya hewan hias akan MENGHAPUS momen itu. Yang diganti cuma gambarnya.
    src = os.path.join(GUDANG, "All", "Wild Animals", "Wolf", "Wolf_Walk.png")
    if os.path.exists(src):
        w = Image.open(src).convert("RGBA").crop((0, 0, 64, 40))
        kotak = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        kotak.alpha_composite(w, (0, 64 - 40))          # rata-bawah: kaki di dasar frame
        kotak.save(os.path.join(DST, "serigala_monster.png"))
        p = PACK["wild_animals_all"]
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
