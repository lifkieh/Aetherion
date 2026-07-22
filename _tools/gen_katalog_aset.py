# -*- coding: utf-8 -*-
"""KATALOG ASET TERPAKAI — lembar kontak tiap folder di `game/assets/`. (#240)

BEDANYA DENGAN `gen_katalog_lembar.py`
--------------------------------------
Alat itu memotret GUDANG (zip pihak ketiga, 891 MB, calon aset). Alat ini memotret
yang SUDAH DIPAKAI game. Dua pertanyaan berbeda: "apa yang bisa saya ambil" vs
"apa yang sudah ada di dalam".

KENAPA ADA
----------
Direktur: *"kalau saya ingin lihat dan cari tuh gampang."* Itu keluhan tentang
KETERLIHATAN, bukan tentang struktur folder — dan pemetaan membuktikannya: nol aset
yatim, pengelompokannya sudah bermakna (`props/` 16 px, `lpc32/` 32 px, `t64/` 64 px),
tapi tak ada satu pun tempat untuk MELIHAT isinya tanpa membuka 704 berkas satu-satu.

TIGA HAL YANG DITULIS DI TIAP PETAK, DAN KENAPA
-----------------------------------------------
  nama     supaya bisa dicari
  ukuran   karena skala pernah jadi cacat berulang di proyek ini — ayam yang
           di-skala 3x jadi "kambing", rusa 41x33 yang berdiri setinggi separuh babi
  papan catur di belakang, supaya alpha TERLIHAT; "latar transparan" sudah beberapa
           kali ternyata papan catur yang DILUKIS (lihat gen_wisp.py)

Folder `characters/` diperlakukan KHUSUS: satu petak per TOKOH, bukan per berkas.
Percobaan pertama menampilkan tiap irisan (`_walk`/`_idle`/`_slash`) sendiri-sendiri
dan menghasilkan 400 strip kecil yang tak bisa dibedakan siapa pun. Yang dicari orang
di folder itu "warga nomor berapa yang berbaju hijau", bukan "irisan slash milik
warga_053". Katalog yang tak terbaca sama tak bergunanya dengan tak ada katalog.

Pakai:
  python gen_katalog_aset.py
"""
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
SRC = os.path.join(REPO, "game", "assets", "game")
OUT = os.path.join(REPO, "reports", "preview", "katalog_aset")
INDEX = os.path.join(REPO, "reports", "KATALOG_ASET.md")

PETAK = 96          # sisi thumbnail
PAD = 10
KOL = 8
TINGGI_LABEL = 26
## Folder yang isinya ratusan irisan sejenis — disampel, bukan dimuat semua.
SAMPEL = {"sprites/characters": 24}


def _font(n=11):
    for nama in ("consola.ttf", "arial.ttf"):
        try:
            return ImageFont.truetype(nama, n)
        except OSError:
            continue
    return ImageFont.load_default()


def papan(w, h, k=8):
    im = Image.new("RGBA", (w, h), (58, 58, 64, 255))
    d = ImageDraw.Draw(im)
    for y in range(0, h, k):
        for x in range(0, w, k):
            if (x // k + y // k) % 2:
                d.rectangle([x, y, x + k - 1, y + k - 1], fill=(74, 74, 82, 255))
    return im


def muat(p):
    try:
        return Image.open(p).convert("RGBA")
    except Exception:
        return None


def wajah_karakter(berkas):
    """Satu petak per TOKOH, bukan per berkas.

    Percobaan pertama menampilkan tiap irisan (`_walk`, `_idle`, `_slash`) sebagai
    petak sendiri. Hasilnya 400 strip kecil yang tak bisa dibedakan siapa pun — dan
    katalog yang tak terbaca sama tak bergunanya dengan tak ada katalog. Yang dicari
    orang di folder ini "warga nomor berapa yang berbaju hijau", bukan "irisan slash
    milik warga_053".

    Diambil frame hadap-BAWAH dari strip `_walk`: itu satu-satunya arah yang
    memperlihatkan wajah.
    """
    C = 64
    out = []
    for nama, path in berkas:
        if not nama.endswith("_walk"):
            continue
        im = muat(path)
        if im is None or im.height < 3 * C:
            continue
        # dir_order [up,left,down,right] -> hadap-bawah = baris ke-2, frame ke-1
        out.append((nama[:-5], im.crop((C, 2 * C, 2 * C, 3 * C))))
    return out


def lembar(judul, berkas, catatan="", potong=None):
    n = len(berkas)
    baris = (n + KOL - 1) // KOL
    W = KOL * (PETAK + PAD) + PAD
    H = 52 + baris * (PETAK + TINGGI_LABEL + PAD) + PAD
    kan = Image.new("RGBA", (W, H), (26, 24, 30, 255))
    d = ImageDraw.Draw(kan)
    f, fk = _font(13), _font(10)
    d.text((PAD, 12), judul, fill=(232, 206, 148, 255), font=f)
    if catatan:
        d.text((PAD, 30), catatan, fill=(150, 146, 158, 255), font=fk)

    for i, isi in enumerate(berkas):
        if potong:
            nama, im = isi
        else:
            nama, path = isi
            im = muat(path)
        if im is None:
            continue
        cx = PAD + (i % KOL) * (PETAK + PAD)
        cy = 52 + (i // KOL) * (PETAK + TINGGI_LABEL + PAD)
        kan.alpha_composite(papan(PETAK, PETAK), (cx, cy))
        # muat ke dalam petak TANPA meregangkan — proporsi aset adalah datanya
        s = min(PETAK / im.width, PETAK / im.height, 4.0)
        w, h = max(1, int(im.width * s)), max(1, int(im.height * s))
        kan.alpha_composite(im.resize((w, h), Image.NEAREST),
                            (cx + (PETAK - w) // 2, cy + (PETAK - h) // 2))
        d.rectangle([cx, cy, cx + PETAK - 1, cy + PETAK - 1], outline=(96, 94, 104, 255))
        pendek = nama if len(nama) <= 17 else nama[:15] + ".."
        d.text((cx, cy + PETAK + 3), pendek, fill=(226, 224, 230, 255), font=fk)
        d.text((cx, cy + PETAK + 14), "%dx%d" % (im.width, im.height),
               fill=(138, 136, 148, 255), font=fk)
    return kan


def main():
    os.makedirs(OUT, exist_ok=True)
    grup = {}
    for root, _dirs, fs in os.walk(SRC):
        png = sorted(f for f in fs if f.endswith(".png"))
        if not png:
            continue
        rel = os.path.relpath(root, SRC).replace("\\", "/")
        grup[rel] = [(f[:-4], os.path.join(root, f)) for f in png]

    baris_index = []
    for rel, berkas in sorted(grup.items()):
        penuh = len(berkas)
        catatan = ""
        if rel == "sprites/characters":
            wajah = wajah_karakter(berkas)
            nama_keluar = "sprites__characters.png"
            lembar("game/assets/game/%s   (%d tokoh, %d berkas)"
                   % (rel, len(wajah), penuh), wajah,
                   "satu wajah per tokoh (frame hadap-bawah dari strip _walk)",
                   potong=True).save(os.path.join(OUT, nama_keluar))
            baris_index.append((rel, penuh, nama_keluar,
                                "%d tokoh, satu wajah masing-masing" % len(wajah)))
            print("  [%3d] %-28s -> %s  (%d tokoh)"
                  % (penuh, rel, nama_keluar, len(wajah)))
            continue
        batas = SAMPEL.get(rel)
        if batas and penuh > batas:
            # ambil MERATA, bukan 24 pertama: 24 pertama semuanya warga_000..023 dan
            # itu menyembunyikan seluruh ekor daftar.
            langkah = penuh / float(batas)
            berkas = [berkas[int(i * langkah)] for i in range(batas)]
            catatan = "disampel %d dari %d — merata, bukan yang pertama" % (batas, penuh)
        nama_keluar = rel.replace("/", "__") + ".png"
        lembar("game/assets/game/%s   (%d berkas)" % (rel, penuh),
               berkas, catatan).save(os.path.join(OUT, nama_keluar))
        baris_index.append((rel, penuh, nama_keluar, catatan))
        print("  [%3d] %-28s -> %s" % (penuh, rel, nama_keluar))

    with open(INDEX, "w", encoding="utf-8") as f:
        f.write("# KATALOG ASET TERPAKAI\n\n")
        f.write("Dihasilkan `_tools/gen_katalog_aset.py`. **Jangan disunting tangan.**\n\n")
        f.write("Isi `game/assets/game/` — yang SUDAH dipakai game. Untuk calon aset\n"
                "di gudang, lihat katalog terpisah dari `gen_katalog_lembar.py`.\n\n")
        f.write("Tiap petak menulis **nama** dan **ukuran**. Ukuran ikut karena skala\n"
                "sudah beberapa kali jadi cacat di proyek ini — ayam yang di-skala 3x\n"
                "terbaca sebagai kambing, rusa 41x33 berdiri setinggi separuh babi.\n\n")
        f.write("| folder | berkas | lembar kontak |\n|---|---|---|\n")
        tot = 0
        for rel, n, keluar, catatan in baris_index:
            tot += n
            f.write("| `%s` | %d | [lihat](preview/katalog_aset/%s) %s |\n"
                    % (rel, n, keluar, "· " + catatan if catatan else ""))
        f.write("| **total** | **%d** | |\n" % tot)
    print("\n-> %s\n-> %s" % (OUT, INDEX))
    return 0


if __name__ == "__main__":
    sys.exit(main())
