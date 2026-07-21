#!/usr/bin/env python3
"""Fasad TINGGI bergaya Suikoden untuk Ashbrook64 (#254 - LANGKAH 5c - HUKUM #240).

Putusan lisensi Direktur - opsi (1), nol CC-BY-SA, nol beli:
  * atap + dinding + jendela : LPC Revised 4-Seasons - **OGA-BY 3.0** (atribusi, TAK menular)
                     JaidynReiman, dari LPC Revised (Eliza Wyatt/DeathsDarling dkk)
                     https://opengameart.org/content/lpc-revised-fully-configured-4-seasons-tilesets-for-tiled-map-editor
                     Kredit resmi: https://github.com/ElizaWy/LPC/blob/main/Credits.txt
                     Diverifikasi verbatim: "This pack is licensed OGA-BY 3.0."
  * PINTU          : **DIGAMBAR SENDIRI di berkas ini** - milik penuh Aetherion.
                     bluecarrot16 ([LPC] Windows & Doors) DITOLAK: CC-BY-SA menular.

KENAPA DIRAKIT, BUKAN DIPAKAI APA ADANYA
LPC Revised memberi potongan - atap pelana, dinding nine-slice, jendela - tapi
tak memberi "rumah jadi". Bangunan yang menjulang harus disusun. Itu isi berkas ini.

CARA POTONGAN ATAP DITEMUKAN (percobaan-1 gagal karena ini dilewati)
Percobaan-1 memakai ubin PERMUKAAN atap yang diulang mendatar - hasilnya pita
bergaris, bukan atap. Sebabnya: atlas 64x64 petak itu tidak berlabel, dan blok
warna di kolom 38+ hanya contoh warna, bukan potongan bangun.
Percobaan-2 membaca `lpc-tileset-buildings.tsx` yang ikut dalam zip. Berkas Tiled
itu memuat empat wangset - "Angled Roof", "Flat Roofs", "Brick Walls",
"Adobe Walls" - yang menyebutkan tileid + wangid tiap potongan. Dari sana:
  * dinding  : "Brick Walls" bertipe corner, 24 warna. Nine-slice tiap warna
               diturunkan dari wangid sudut (lihat WALL di bawah).
  * atap     : pelana ("gable") TIDAK ada di wangset mana pun - ia potongan
               manual. Ditemukan dengan merender tiap petak terisolasi berlabel
               lalu memilih dengan mata: baris 0 = punggung + dua lereng,
               baris 1 = badan sirap. Lebar 5 di kolom 10-14, lebar 3 di kolom 7-9.

Enam pasang bahan tersusun blok 18 kolom x 8 baris di dalam atlas, jadi satu
offset (dc, dr) memindahkan seluruh potongan ke bahan lain. Lihat ROOF.

Keluaran -> game/assets/game/sprites/lpc32/
  fasad_inn.png   - rumah singgah Merrit (5x7 petak = 160x224 px)
  fasad_shop.png  - toko Otha, tinggi & ramping (3x6 petak = 96x192 px)
  pintu.png       - pintu papan berpalang, digambar sendiri (32x64)

Proporsi sasaran: karakter LPC ~1,5 petak (5b). Fasad 6-7 petak -> bangunan
**4-5x tinggi karakter**. Itu rasa Suikoden: kota yang menjulang di atas orang.

Uji siluet: jalankan dengan argumen `siluet` untuk menulis bukti siluet hitam ke
reports/preview/ - bentuk atap harus terbaca sebagai atap, bukan kotak.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
SRC = os.path.join(REPO, "assets_raw", "lpc_revised", "lpc-tileset-buildings.png")
OUT = os.path.join(REPO, "game", "assets", "game", "sprites", "lpc32")
PREVIEW = os.path.join(REPO, "reports", "preview")
T = 32

# --- bahan: offset blok di dalam atlas (dc, dr) ---
# Enam pasang atap+dinding tersusun 18 kolom x 8 baris.
MAT_SLATE = (0, 0)     # batu tulis abu kebiruan
MAT_OLIVE = (18, 0)    # sirap zaitun
MAT_INDIGO = (0, 8)    # batu tulis nila
MAT_BROWN = (18, 8)    # sirap cokelat hangat
MAT_BLACK = (0, 16)    # batu tulis hitam
MAT_RED = (18, 16)     # genteng merah

# --- ATAP PELANA: baris 0 = punggung + lereng, baris 1 = badan sirap ---
GABLE5 = 10   # kolom awal, lebar 5 (kolom 10-14)
GABLE3 = 7    # kolom awal, lebar 3 (kolom 7-9)

# --- DINDING: nine-slice, diturunkan dari wangset "Brick Walls" (tipe corner) ---
# Kunci = sudut kiri-atas nine-slice; delapan petak sisanya bersebelahan.
# Urutan baris: TL T TR / L C R / BL B BR
#
# Tiap warna punya empat garapan: w/Shadow, w/Border, w/Edge, w/Jagged.
# Dipilih **w/Border**: baris atasnya memberi lis mendatar yang terbaca sebagai
# ikat pinggang di bawah cucuran atap. w/Shadow menaruh bayangan membundar di
# situ - pada fasad utuh ia terbaca sebagai kubah aneh, bukan bayangan.
WALL = {
    "krem": (6, 24),     # White Brick w/Border
    "abu": (24, 24),     # Gray Brick w/Border
    "nila": (6, 27),     # Blue Brick w/Border
    "cokelat": (24, 27),  # Brown Brick w/Border
    "hitam": (6, 30),    # Black Brick w/Border
    "merah": (24, 30),   # Red Brick w/Border
}

# --- ADOBE (wangset "Adobe Walls") — DINDING YANG SELAMA INI MENGANGGUR ---------
#
# Atlas ini mendaftarkan EMPAT wangset: Angled Roof · Flat Roofs · Brick Walls ·
# Adobe Walls. Sampai revisi ini generator cuma memakai DUA, jadi lima fasad
# Ashbrook lahir dari satu resep dan berbagi satu siluet — kotak + atap pelana.
# Dua wangset sisanya sudah ada di repo dan lisensinya sudah dibayar (OGA-BY 3.0).
#
# ⚠ ADOBE TAK BISA DIPAKAI `WALL` APA ADANYA. Nine-slice bata lebarnya TIGA petak
#   berurutan, jadi `c0 + rx` cukup. Blok adobe lebarnya EMPAT (kiri, dua tengah,
#   kanan), dan menebak `c0+2` sebagai tepi kanan mengambil petak TENGAH — hasilnya
#   dinding tanpa sisi kanan, dan cacat itu cuma terlihat pada bangunan lebar.
#   Karena itu kolomnya disebut satu per satu, bukan dihitung.
ADOBE = {
    #            (kiri, tengah, kanan), baris atas
    "pasir": ((0, 1, 3), 33),    # adobe tanah terang — hangat, masih dirawat
    "lembayung": ((0, 1, 3), 36),  # adobe kelabu-ungu — pudar, sudah lama
}

# --- ATAP DATAR (wangset "Flat Roofs") ----------------------------------------
# Nine-slice 3x3 di (1,5), dan ia mengikuti offset bahan 18x8 yang sama dengan
# atap pelana — diuji dengan merender keenam offset berdampingan sebelum dipakai
# (reports/preview/blockout/T17a_flat_bahan.png), bukan diandaikan.
#
# INI YANG MEMBERI VARIASI SILUET, bukan variasi warna: atap pelana berpuncak
# SEGITIGA, atap datar bertepi LURUS. Dari kejauhan, di mana warna sudah menyatu,
# perbedaan itu yang masih terbaca.
FLAT = (1, 5)

# --- JENDELA: 1 petak lebar x 2 petak tinggi. Kolom 37 = siang, 38 = berlampu ---
WIN_KISI = (37, 20)   # kisi belah ketupat berbingkai kayu - hangat, rasa kedai
WIN_PANEL = (37, 14)  # jendela panel berkusen batu - rapi, rasa toko

# --- palet PINTU (milik sendiri; diambil dari kayu Aetherion yang sudah ada) ---
D_OUT = (0x1E, 0x16, 0x12, 255)   # outline - sama dgn signboard/street_lamp
D_DARK = (0x46, 0x32, 0x1E, 255)
D_MID = (0x5A, 0x42, 0x28, 255)
D_LIT = (0x78, 0x54, 0x30, 255)
D_IRON = (0x46, 0x42, 0x4A, 255)  # engsel/gagang - logam street_lamp
D_STEP = (0x6E, 0x6A, 0x62, 255)  # ambang batu


def tile(src, c, r):
    return src.crop((c * T, r * T, (c + 1) * T, (r + 1) * T))


def draw_door(w=32, h=64):
    """PINTU - digambar sendiri, bukan diambil dari pack (putusan lisensi #254).

    Papan vertikal + dua palang + engsel besi + ambang batu. Sengaja gelap &
    sederhana supaya terbaca sebagai LUBANG MASUK pada jarak main, bukan ornamen.
    Tinggi 2 petak: karakter (48 px) lewat di bawahnya tanpa terlihat sempit.
    """
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    body = h - 3  # tiga baris terbawah jadi ambang batu
    for y in range(body):
        for x in range(w):
            px[x, y] = D_MID
    # papan vertikal: garis gelap tiap 6 px
    for x in range(0, w, 6):
        for y in range(body):
            px[x, y] = D_DARK
    # dua palang mendatar
    for y in (body // 3, 2 * body // 3):
        for x in range(w):
            px[x, y] = D_LIT
            px[x, y + 1] = D_DARK
    # lengkung bahu di puncak - memecah persegi supaya tidak terbaca papan
    for x in range(w):
        d = abs(x - (w - 1) / 2.0) / ((w - 1) / 2.0)
        for y in range(int(4 * d * d)):
            px[x, y] = (0, 0, 0, 0)
    # bingkai
    for x in range(w):
        px[x, body - 1] = D_OUT
    for y in range(body):
        px[0, y] = D_OUT
        px[w - 1, y] = D_OUT
    for x in range(w):
        for y in range(body):
            if px[x, y][3] and (px[x, max(0, y - 1)][3] == 0):
                px[x, y] = D_OUT
    # engsel + gagang besi
    for y in (body // 4, 3 * body // 4):
        for x in range(2, 7):
            px[x, y] = D_IRON
    px[w - 7, body // 2] = D_IRON
    px[w - 6, body // 2] = D_IRON
    # ambang batu
    for y in range(body, h):
        for x in range(w):
            px[x, y] = D_STEP if y < h - 1 else D_OUT
    return im


def roof(src, mat, gable_col, cols):
    """Atap pelana: baris 0 punggung+lereng, baris 1 badan sirap."""
    dc, dr = mat
    im = Image.new("RGBA", (cols * T, 2 * T), (0, 0, 0, 0))
    for i in range(cols):
        im.paste(tile(src, gable_col + dc + i, dr), (i * T, 0))
        im.paste(tile(src, gable_col + dc + i, dr + 1), (i * T, T))
    return im


def nine(src, kolom, r0, cols, rows, sabuk=(), r_dasar=None):
    """Nine-slice umum. `kolom` = (kiri, tengah, kanan) — disebut, bukan dihitung.

    `sabuk` = baris-baris di TENGAH badan yang digambar memakai petak BARIS ATAS.

    Kenapa itu cukup untuk membuat lantai: petak baris atas nine-slice ini varian
    "w/Border", dan lis mendatarnya yang selama ini terbaca sebagai ikat pinggang di
    bawah cucuran atap. Ditaruh di tengah dinding, lis yang sama terbaca sebagai
    PEMISAH LANTAI. Bangunan bertingkat karena itu tak menuntut petak baru sama
    sekali — cuma menuntut petak yang sudah ada dipasang di tempat kedua.
    """
    im = Image.new("RGBA", (cols * T, rows * T), (0, 0, 0, 0))
    for y in range(rows):
        if y == 0:
            ry = 0
        elif y == rows - 1:
            ry = 2
        elif y in sabuk:
            ry = 0
        else:
            ry = 1
        ry_abs = r_dasar if (r_dasar is not None and y == rows - 1) else r0 + ry
        for x in range(cols):
            kx = kolom[0] if x == 0 else (kolom[2] if x == cols - 1 else kolom[1])
            im.paste(tile(src, kx, ry_abs), (x * T, y * T))
    return im


def wall(src, key, cols, rows, sabuk=(), r_dasar=None):
    """Badan bangunan. `key` boleh nama bata (WALL) atau nama adobe (ADOBE)."""
    if key in ADOBE:
        kolom, r0 = ADOBE[key]
        return nine(src, kolom, r0, cols, rows, sabuk, r_dasar)
    c0, r0 = WALL[key]
    return nine(src, (c0, c0 + 1, c0 + 2), r0, cols, rows, sabuk, r_dasar)


# --- LUBANG DINDING (adobe rusak, kolom 7-8 baris 39-40) ----------------------
# Dua petak x dua petak: tepinya bergerigi dan TENGAHNYA TEMBUS.
LUBANG = (7, 39)
# Gelap yang dipasang DI BALIK lubang. Ini bagian terpenting dari seluruh langkah:
# lubang yang benar-benar tembus akan menampakkan RUMPUT di baliknya, dan dinding
# yang menampakkan rumput terbaca sebagai CACAT GAMBAR, bukan sebagai rumah yang
# bolong. Yang membuatnya bercerita bukan lubangnya — melainkan gelap di dalamnya.
GELAP_DALAM = (26, 21, 18, 255)


def pasang_lubang(im, src, di, atap_rows):
    """Tempel lubang 2x2 pada dinding, berlatar gelap ruang dalam."""
    for (cx, wy) in di:
        x, y = cx * T, (atap_rows + wy) * T
        im.paste(Image.new("RGBA", (2 * T, 2 * T), GELAP_DALAM), (x, y))
        for dx in range(2):
            for dy in range(2):
                im.alpha_composite(tile(src, LUBANG[0] + dx, LUBANG[1] + dy),
                                   (x + dx * T, y + dy * T))
    return im


def flat_roof(src, mat, cols, rows=2):
    """Atap DATAR bertembok pengaman. `rows` 2 = tepi atas + bibir bawah saja.

    Tiga baris memberi bidang atap yang lebar — benar untuk bangunan besar, tapi
    pada bangunan sempit ia menelan dindingnya sendiri dan bangunan itu berhenti
    terbaca sebagai rumah. Ketinggian atap ikut lebar bangunan, bukan sebaliknya.
    """
    dc, dr = mat
    c0, r0 = FLAT[0] + dc, FLAT[1] + dr
    return nine(src, (c0, c0 + 1, c0 + 2), r0, cols, rows)


# Keadaan jendela = geser kolom. 36 gelap (tak berpenghuni), 37 siang, 38 berlampu.
WIN_STATE = {"gelap": -1, "siang": 0, "terang": 1}


def window(src, kind, state="siang"):
    c, r = kind
    c += WIN_STATE[state]
    im = Image.new("RGBA", (T, 2 * T), (0, 0, 0, 0))
    im.alpha_composite(tile(src, c, r), (0, 0))
    im.alpha_composite(tile(src, c, r + 1), (0, T))
    return im


def facade(src, mat, gable_col, cols, wall_key, wall_rows, win_kind, win_cols,
           win_row=1, win_state="siang", door=True, name="", atap="pelana",
           atap_rows=2, sabuk=(), r_dasar=None, lubang=()):
    """Susun fasad menjulang: atap -> dinding -> jendela -> pintu.

    `atap`  = "pelana" (puncak segitiga) atau "datar" (tepi lurus bertembok).
    `win_row` boleh satu angka atau BEBERAPA — beberapa baris jendela + `sabuk`
    di antaranya adalah seluruh isi "bangunan bertingkat".
    """
    rows = atap_rows + wall_rows
    im = Image.new("RGBA", (cols * T, rows * T), (0, 0, 0, 0))
    if atap == "datar":
        im.alpha_composite(flat_roof(src, mat, cols, atap_rows), (0, 0))
    else:
        im.alpha_composite(roof(src, mat, gable_col, cols), (0, 0))
    im.alpha_composite(wall(src, wall_key, cols, wall_rows, sabuk, r_dasar),
                       (0, atap_rows * T))
    if lubang:
        pasang_lubang(im, src, lubang, atap_rows)
    baris_jendela = win_row if isinstance(win_row, (tuple, list)) else (win_row,)
    for wr in baris_jendela:
        for x in win_cols:
            im.alpha_composite(window(src, win_kind, win_state),
                               (x * T, (atap_rows + wr) * T))
    if door:  # pintu di tengah, menempel tanah
        im.alpha_composite(draw_door(T, 2 * T), ((cols // 2) * T, (rows - 2) * T))
    print("  %-14s %3dx%-3d  (%dx%d petak)" % (name, im.width, im.height, cols, rows))
    return im


def silhouette(im):
    """Uji siluet: seluruh piksel tak-tembus jadi hitam. Bentuk harus terbaca."""
    out = Image.new("RGBA", im.size, (0, 0, 0, 0))
    px, qx = im.load(), out.load()
    for y in range(im.height):
        for x in range(im.width):
            if px[x, y][3] > 8:
                qx[x, y] = (0, 0, 0, 255)
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    src = Image.open(SRC).convert("RGBA")

    # Lima fasad, lima bahan. Bahan dibedakan supaya Ashbrook bisa dibaca dari
    # jauh: bangunan yang hidup hangat (cokelat, merah), yang mati dingin
    # (hitam, jendela gelap). Itu keterangan cerita, bukan hiasan.
    made = {}
    for nm, kw in (
        # rumah singgah Merrit — lebar, hangat, jendela kisi menyala siang
        ("fasad_inn", dict(mat=MAT_BROWN, gable_col=GABLE5, cols=5, wall_key="krem",
                           wall_rows=5, win_kind=WIN_KISI, win_cols=(1, 3))),
        # toko Otha — tinggi & ramping, batu tulis; TUTUP dua musim, jendela gelap
        ("fasad_shop", dict(mat=MAT_SLATE, gable_col=GABLE3, cols=3, wall_key="abu",
                            wall_rows=4, win_kind=WIN_PANEL, win_cols=(0, 2),
                            win_state="gelap")),
        # gudang gandum — lebar, tanpa jendela: gudang tak butuh cahaya
        ("fasad_gudang", dict(mat=MAT_OLIVE, gable_col=GABLE5, cols=5, wall_key="cokelat",
                              wall_rows=4, win_kind=WIN_PANEL, win_cols=())),
        # rumah kosong — hitam, jendela gelap. Pintunya TETAP ada: rumah tanpa
        # pintu terbaca "belum jadi", bukan "ditinggalkan". Yang bercerita di sini
        # jendela gelapnya, bukan lubang yang hilang.
        ("fasad_kosong", dict(mat=MAT_BLACK, gable_col=GABLE3, cols=3, wall_key="hitam",
                              wall_rows=4, win_kind=WIN_PANEL, win_cols=(0, 2),
                              win_state="gelap")),
        # rumah Lyra — masih dihuni: genteng merah, jendela berlampu
        ("fasad_rumah", dict(mat=MAT_RED, gable_col=GABLE5, cols=5, wall_key="merah",
                             wall_rows=4, win_kind=WIN_KISI, win_cols=(1, 3),
                             win_state="terang")),

        # ══ EMPAT BENTUK BARU (1.7a) — dari dua wangset yang menganggur ═══════
        #
        # Sengaja EMPAT, bukan sepuluh. Sembilan bentuk untuk lima belas bangunan
        # berarti ada yang terulang, dan pengulangan itu yang membuatnya terbaca
        # SATU DESA. Desa yang tiap rumahnya berbeda tidak terbaca beragam — ia
        # terbaca sebagai pameran, dan tak seorang pun tinggal di pameran.
        #
        # Variasinya diberi ALASAN, bukan diundi: bahan mengikuti keadaan penghuni.
        # Adobe pasir = masih dirawat. Adobe lembayung = pudar. Atap datar = gaya
        # kota lama yang lebih tua daripada rumah pelana di sekitarnya.

        # rumah singgah Merrit — adobe pasir hangat, dan LEBIH PENDEK dari balai.
        # Ini membayar utang koreksi 3 di B': Merrit seharusnya yang terpendek,
        # tapi ia memakai `fasad_inn` yang justru tertinggi (224). Sekarang 192,
        # dan bahannya beda sehingga ia tak lagi kembar dengan balai di sebelahnya.
        ("fasad_singgah", dict(mat=MAT_BROWN, gable_col=GABLE5, cols=5,
                               wall_key="pasir", wall_rows=4, win_kind=WIN_KISI,
                               win_cols=(1, 3))),
        # MENARA TEPI — atap datar, sempit, TINGGI (96x256). Satu-satunya bangunan
        # yang memecah garis atap desa. Ditaruh di tepi timur: sisa kota lama yang
        # menjulang, dilihat dari jauh sebelum dicapai.
        ("fasad_datar_tinggi", dict(mat=MAT_SLATE, gable_col=GABLE3, cols=3,
                                    wall_key="abu", wall_rows=6, win_kind=WIN_PANEL,
                                    win_cols=(0, 2), win_state="gelap",
                                    atap="datar", atap_rows=2,
                                    win_row=(1, 4), sabuk=(3,))),
        # RUMAH LEBAR-PENDEK (160x160) — kebalikan menara. Dua siluet ekstrem di
        # peta yang sama membuat yang di antaranya terbaca sebagai "biasa"; tanpa
        # keduanya, semua ukuran terasa sama.
        ("fasad_datar_lebar", dict(mat=MAT_BROWN, gable_col=GABLE5, cols=5,
                                   wall_key="lembayung", wall_rows=3,
                                   win_kind=WIN_KISI, win_cols=(1, 3),
                                   atap="datar", atap_rows=2)),
        # ADOBE PUDAR — atap datar hitam + adobe lembayung, jendela gelap.
        # Bahan yang berbeda DAN mati: rumah yang ditinggalkan lebih dulu daripada
        # tetangganya, dan bahannya mengabarkan ia juga dibangun lebih dulu.
        ("fasad_adobe_pudar", dict(mat=MAT_BLACK, gable_col=GABLE3, cols=3,
                                   wall_key="lembayung", wall_rows=4,
                                   win_kind=WIN_PANEL, win_cols=(0, 2),
                                   win_state="gelap", atap="datar", atap_rows=2)),

        # ══ BERTINGKAT (1.7b-1) — LANGKA DENGAN SENGAJA ═══════════════════════
        # Bertingkat adalah PENANDA, dan penanda hanya bekerja kalau jarang. Kalau
        # separuh desa bertingkat, tingkat berhenti berarti "penting" dan mulai
        # berarti "gaya rumah di sini". Cuma dua bangunan yang mendapatkannya:
        # balai (satu-satunya yang masih dipakai bersama) dan menara tepi timur
        # (satu-satunya yang tak lagi dipakai siapa pun). Dua kutub yang sama:
        # keduanya dibangun waktu Ashbrook masih mampu membangun ke ATAS.
        #
        # 160x288 = sembilan petak. Ia jadi bangunan tertinggi di peta dengan
        # selisih 64 px dari mana pun — itu yang membuatnya jadi jangkar mata dari
        # gerbang (koreksi 7 B'), dan sekarang jangkarnya punya sebab: ia bertingkat.
        ("fasad_balai", dict(mat=MAT_BROWN, gable_col=GABLE5, cols=5, wall_key="krem",
                             wall_rows=7, win_kind=WIN_KISI, win_cols=(1, 3),
                             win_row=(1, 4), sabuk=(3,))),

        # ══ LAPUK DITINGGALKAN (1.7b-2) — dinding retak + BOLONG ══════════════
        # Ini yang paling naratif dari seluruh 1.7, dan paling murah.
        #
        # Tiga hal harus benar bersamaan supaya ia terbaca "ditinggalkan" dan bukan
        # "rusak/bug", dan menghilangkan satu saja membatalkan dua sisanya:
        #   1. dinding masih BERDIRI dan masih rapi di atas — kalau seluruhnya hancur
        #      ia terbaca reruntuhan, dan reruntuhan sudah punya tempatnya sendiri
        #      (denah fondasi di distrik bekas). Yang diceritakan di sini beda:
        #      rumah yang MASIH RUMAH, tapi tak ada lagi yang menambalnya.
        #   2. keretakan mulai dari BAWAH — lembap naik dari tanah, dan atap yang
        #      masih menahan air membuat kerusakan berjalan dari kaki, bukan puncak.
        #   3. lubangnya berlatar GELAP, bukan tembus. Lubang yang benar-benar tembus
        #      menampakkan rumput di baliknya, dan itu terbaca cacat gambar.
        #
        # Jendelanya sengaja TIDAK gelap-mati melainkan `siang`: kaca yang masih
        # memantulkan langit di rumah yang dindingnya sudah bolong lebih menyayat
        # daripada dua-duanya mati. Sesuatu di sini masih bertahan, dan itu bukan
        # penghuninya.
        ("fasad_lapuk", dict(mat=MAT_OLIVE, gable_col=GABLE3, cols=3, wall_key="pasir",
                             wall_rows=4, win_kind=WIN_KISI, win_cols=(0,),
                             r_dasar=40, lubang=((2, 2),))),
    ):
        made[nm] = facade(src, name=nm, **kw)
        made[nm].save(os.path.join(OUT, nm + ".png"))
    draw_door(T, 2 * T).save(os.path.join(OUT, "pintu.png"))
    print("fasad + pintu -> %s" % OUT)

    if "siluet" in sys.argv:
        os.makedirs(PREVIEW, exist_ok=True)
        for nm, im in made.items():
            p = os.path.join(PREVIEW, "5c_siluet_%s.png" % nm.replace("fasad_", ""))
            silhouette(im).save(p)
            print("  siluet -> %s" % p)

    if "lembar" in sys.argv:
        sheet(made).save(os.path.join(PREVIEW, "5c_fasad_lembar.png"))
        print("  lembar -> %s" % os.path.join(PREVIEW, "5c_fasad_lembar.png"))


def sheet(made, zoom=2):
    """Lembar bukti: tiap fasad + siluetnya + karakter LPC sebagai tolok tinggi.

    Siluet ikut karena itu ujinya: kalau bentuk hitam masih terbaca sebagai rumah
    beratap, bentuknya benar. Kalau ia kotak, warna sedang menutupi kegagalan.
    """
    ch_path = os.path.join(REPO, "game", "assets", "game", "sprites", "characters",
                           "merrit_fane_walk.png")
    ch = Image.open(ch_path).convert("RGBA").crop((0, 2 * 64, 64, 3 * 64))
    items = [(n.replace("fasad_", ""), im) for n, im in made.items()]
    items = [(n, im) for n, im in items] + [("siluet " + n, silhouette(im)) for n, im in items]
    items.append(("karakter", ch))
    pad, top = 18, 30
    w = sum(im.width * zoom + pad for _, im in items) + pad
    h = max(im.height for _, im in items) * zoom + top + pad
    s = Image.new("RGB", (w, h), (118, 166, 108))
    d = ImageDraw.Draw(s)
    try:
        f = ImageFont.truetype("consolab.ttf", 14)
    except OSError:
        f = ImageFont.load_default()
    x = pad
    for n, im in items:
        q = im.resize((im.width * zoom, im.height * zoom), Image.NEAREST)
        s.paste(q, (x, h - pad - q.height), q)
        d.text((x, 8), n, font=f, fill=(255, 255, 255))
        x += q.width + pad
    return s


if __name__ == "__main__":
    main()
