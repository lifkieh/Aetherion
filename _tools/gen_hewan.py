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
import json
import os
import sys

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
}

# (id, sumber, jenis, param, pack, skala, catatan)
#   jenis "baris" : lembar 4-arah, ambil satu baris  -> (fw, fh, baris, n_frame)
#   jenis "strip" : sudah strip satu arah            -> (fw, fh, n_frame)
#   jenis "repo"  : sudah ada di repo, tak dipotong   -> (fw, fh, n_frame)
JOBS = [
    ("ayam", "repo:chicken.png", "repo", (16, 16, 2), "ninja_adventure", 0.9,
     "sprite lama sudah benar; yang salah cuma skalanya (dulu 1.6 = ayam sebesar anjing)"),
    ("domba", os.path.join(GUDANG, "stendhal_animals-99362c8-1", "ram.png"), "baris",
     (48, 64, 3, 3), "stendhal_animals", 1.0,
     "domba jantan bertanduk. NOL kambing di seluruh 111 zip gudang — domba adalah "
     "ternak berkaki empat bergaya LPC satu-satunya yang ada"),
    ("serigala", os.path.join(GUDANG, "All", "Wild Animals", "Wolf", "Wolf_Walk.png"),
     "strip", (64, 40, 8), "wild_animals_all", 1.0,
     "menggantikan grey_wolf.png 16px yang terbaca sebagai serangga di dunia 64px"),
    ("rusa", os.path.join(GUDANG, "All", "Wild Animals", "Deer", "Deer_Walk.png"),
     "strip", (72, 52, 8), "wild_animals_all", 1.0,
     "rusa jantan BERTANDUK — menggantikan Image.create(6,10) kotak putih polos"),
]


class HewanError(Exception):
    """Kegagalan yang menghentikan build."""


def potong(job):
    hid, src, jenis, par, pack, skala, cat = job
    if jenis == "repo":
        fw, fh, n = par
        keluar = "chicken.png"
        return keluar, fw, fh, n
    if not os.path.exists(src):
        raise HewanError(f"sumber hilang: {src}")
    im = Image.open(src).convert("RGBA")
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
        "_skala_doc": "skala relatif manusia LPC 64px. Nilai di sini sudah proporsi ternak; "
                      "JANGAN disetel ulang di sisi pemanggil — begitulah kambing dulu jadi "
                      "ayam 3x.",
        "pack": PACK,
        "hewan": {},
    }
    for job in JOBS:
        hid, src, jenis, par, pack, skala, cat = job
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
