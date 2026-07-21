# -*- coding: utf-8 -*-
"""BLOCKOUT ASHBROOK — dua peta kotak polos untuk dinilai TATA LETAKNYA.

Kenapa kotak dan bukan sprite: keputusan yang harus diambil di sini adalah "di mana
apa, menghadap ke mana". Fasad cantik justru mengganggu — mata menilai gambarnya,
bukan susunannya. Semua yang digambar di sini adalah FUNGSI berwarna, bukan aset.

A  = APA YANG ADA  — dibaca dari `game/scenes/world/Ashbrook64.gd` apa adanya.
                    Tiap angka di bawah punya nomor baris asalnya. Kalau .gd berubah,
                    peta ini BOHONG sampai angkanya disalin ulang. Itu ongkos yang
                    disengaja: menyuntik Godot untuk menggambar peta ini lebih mahal
                    daripada menyalin 40 koordinat sekali.
B  = USUL DARI SPEC — tata ulang menurut ASHBROOK_MAP_SPEC.md 4-cincin.
B' = B + tujuh koreksi Direktur. Bedanya satu kata: B RAPI, B' HIDUP.

     Rapi bukan indah, dan bedanya bisa diukur: tata letak yang simetris sempurna
     mengabarkan SATU TANGAN MEMBANGUNNYA SEKALIGUS. Ashbrook justru harus
     mengabarkan kebalikannya — tumbuh bertahun-tahun, lalu menyusut bertahun-tahun.
     Karena itu tiap ketaksempurnaan di B' DIRANCANG, bukan diacak: sumbu digeser,
     jalan dibengkokkan, tepi alun-alun dimakan, rumah direnggangkan ke luar.
     Acak murni terbaca sebagai derau; ketaksempurnaan berarah terbaca sebagai waktu.

     Semua ketaksempurnaan lahir dari RNG BERBIJI TETAP (20260721). Menjalankan
     ulang skrip ini menghasilkan peta yang sama persis — kalau tidak, "koreksi
     Direktur" jadi mustahil dirujuk dua sesi berturut-turut.

#240: skrip ini yang melahirkan reports/preview/blockout/*.png.
"""
import math
import os
import random
import sys

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw, ImageFont

TILE = 32
MAP_W, MAP_H = 60, 44
W, H = MAP_W * TILE, MAP_H * TILE          # 1920 x 1408
VC = (960.0, 704.0)
PANEL = 640                                 # keterangan samping
KEPALA = 64
FOOT_H = 40.0                               # BUILDING_FOOT_H di .gd

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, "reports", "preview", "blockout")

# ── palet FUNGSI. Sengaja tak enak dipandang: begitu blockout mulai terlihat cantik,
#    orang berhenti menilai susunannya. ──────────────────────────────────────────
C_LATAR = (24, 26, 30)
C_RUMPUT = (54, 68, 50)
C_JALAN = (168, 168, 162)
C_JALAN_PUDAR = (110, 112, 108)
C_ALUN = (206, 198, 176)
C_ALUN_AUS = (156, 150, 134)                # sisi yang paling diinjak — batu tinggal serpih
C_MERAMBAT = (96, 116, 78)                  # rumput yang menggigit balik pelataran
C_AIR = (86, 152, 200)
C_RUMAH = (124, 88, 56)
C_RUMAH_GELAP = (78, 58, 42)                # C2 tak berlentera
C_NAMA = (186, 142, 78)
C_RERUNTUHAN = (146, 78, 78)
C_MAKAM = (126, 116, 148)
C_POHON = (32, 64, 40)
C_BUKTI = (240, 208, 64)
C_LADANG = (140, 118, 68)
C_WARGA = (232, 236, 240)
C_TEKS = (232, 230, 224)
C_REDUP = (150, 152, 158)
C_CINCIN = (250, 250, 250)


def _f(n, tebal=False):
    for nama in (("consolab.ttf", "consola.ttf") if tebal else ("consola.ttf",)):
        try:
            return ImageFont.truetype(nama, n)
        except OSError:
            continue
    return ImageFont.load_default()


F_JUDUL = _f(30, True)
F_LABEL = _f(15, True)
F_KECIL = _f(12)
F_PANEL = _f(14)
F_PANEL_B = _f(15, True)


class Peta:
    def __init__(self, judul, sub):
        self.im = Image.new("RGB", (W + PANEL, H + KEPALA), C_LATAR)
        self.d = ImageDraw.Draw(self.im, "RGBA")
        self.o = (0, KEPALA)                     # asal dunia di dalam kanvas
        self.baris = []                          # keterangan samping
        self.d.rectangle([0, KEPALA, W, KEPALA + H], fill=C_RUMPUT)
        self.d.text((16, 14), judul, font=F_JUDUL, fill=C_TEKS)
        self.d.text((18, 46), sub, font=F_KECIL, fill=C_REDUP)

    # -- dasar ---------------------------------------------------------------
    def xy(self, p):
        return (p[0] + self.o[0], p[1] + self.o[1])

    def kotak(self, cx, cy, w, h, warna, garis=None, lebar=1):
        x0, y0 = self.xy((cx - w / 2, cy - h / 2))
        self.d.rectangle([x0, y0, x0 + w, y0 + h], fill=warna, outline=garis, width=lebar)

    def kotak_sudut(self, x, y, w, h, warna, garis=None, lebar=1):
        x0, y0 = self.xy((x, y))
        self.d.rectangle([x0, y0, x0 + w, y0 + h], fill=warna, outline=garis, width=lebar)

    def titik(self, p, r, warna, garis=None):
        x, y = self.xy(p)
        self.d.ellipse([x - r, y - r, x + r, y + r], fill=warna, outline=garis)

    def teks(self, p, t, font=F_LABEL, warna=C_TEKS, tengah=True):
        x, y = self.xy(p)
        w = self.d.textlength(t, font=font)
        self.d.text((x - w / 2 if tengah else x, y), t, font=font, fill=warna)

    # -- unsur peta ----------------------------------------------------------
    def jalan(self, x, y, w, h, pudar=False):
        self.kotak_sudut(x, y, w, h, C_JALAN_PUDAR if pudar else C_JALAN)

    def alun(self, pusat, r):
        x, y = self.xy(pusat)
        self.d.ellipse([x - r, y - r, x + r, y + r], fill=C_ALUN)

    def bangunan(self, foot, w, h, label=None, gelap=False, warna=None):
        """`foot` = tengah-bawah, sama dengan `_building()` di .gd.

        Digambar DUA lapis dan itu bukan hiasan: massa fasad (tembus pandang) adalah
        yang DILIHAT pemain, petak kaki (padat) adalah yang MENGHALANGINYA. Keduanya
        beda ukuran di Ashbrook — menggambar satu saja menyembunyikan separuh soal.
        """
        c = warna or (C_RUMAH_GELAP if gelap else C_RUMAH)
        fx, fy = foot
        x0, y0 = self.xy((fx - w / 2, fy - h))
        self.d.rectangle([x0, y0, x0 + w, y0 + h], fill=c + (120,), outline=c + (255,))
        k0, k1 = self.xy((fx - w / 2, fy - FOOT_H))
        self.d.rectangle([k0, k1, k0 + w, k1 + FOOT_H], fill=c + (255,))
        self.panah_pintu(foot)
        if label:
            self.teks((fx, fy - h - 20), label, F_LABEL, C_TEKS)

    def panah_pintu(self, foot):
        """Semua fasad repo berpintu SELATAN. Panah ini bukan gaya — ia satu-satunya
        cara melihat bahwa rumah 'menghadap' sesuatu atau membelakanginya."""
        x, y = self.xy((foot[0], foot[1] + 4))
        self.d.polygon([(x - 9, y), (x + 9, y), (x, y + 15)], fill=(250, 250, 250, 230))

    def reruntuhan(self, cx, cy, w, h, label=None):
        x0, y0 = self.xy((cx - w / 2, cy - h / 2))
        self.d.rectangle([x0, y0, x0 + w, y0 + h],
                         fill=C_RERUNTUHAN + (90,), outline=C_RERUNTUHAN + (220,), width=2)
        for dx, dy in ((0, 0), (w, 0), (0, h), (w, h)):
            self.d.rectangle([x0 + dx - 4, y0 + dy - 4, x0 + dx + 4, y0 + dy + 4],
                             fill=C_RERUNTUHAN + (255,))
        if label:
            self.teks((cx, cy - h / 2 - 18), label, F_KECIL, C_RERUNTUHAN)

    def bukti(self, p, nama):
        self.titik(p, 7, C_BUKTI, (40, 34, 10))
        x, y = self.xy((p[0] + 11, p[1] - 7))
        self.d.text((x, y), nama, font=F_KECIL, fill=C_BUKTI)

    def warga(self, p, n):
        for i in range(n):
            a = i * 2.399963
            r = 13 * math.sqrt(i + 0.6)
            self.titik((p[0] + math.cos(a) * r, p[1] + math.sin(a) * r), 4, C_WARGA)

    def treeline(self, x, y, w, h, usul=False):
        if usul:
            x0, y0 = self.xy((x, y))
            self.d.rectangle([x0, y0, x0 + w, y0 + h], fill=C_POHON + (110,),
                             outline=(120, 200, 130, 220), width=3)
            self.teks((x + w / 2, y + h / 2 - 9), "USUL", F_KECIL, (150, 220, 160))
        else:
            self.kotak_sudut(x, y, w, h, C_POHON)

    # -- ketaksempurnaan terancang (B') --------------------------------------
    def poli(self, pts, isi, garis=None):
        self.d.polygon([self.xy(p) for p in pts], fill=isi, outline=garis)

    def pita(self, tulang, warna):
        """Jalan BENGKOK berlebar tak rata. `tulang` = [(x, y, setengah_lebar)].

        Jalan lurus berlebar tetap adalah jalan yang DIUKUR sebelum dibangun. Jalan
        yang menyimpang beberapa piksel dan menyempit di ujung adalah jalan yang
        dibentuk kaki. Bedanya kecil di angka, besar di bacaan.
        """
        atas = [(x, y - hw) for x, y, hw in tulang]
        bawah = [(x, y + hw) for x, y, hw in reversed(tulang)]
        self.poli(atas + bawah, warna)

    def pita_tegak(self, tulang, warna):
        kiri = [(x - hw, y) for x, y, hw in tulang]
        kanan = [(x + hw, y) for x, y, hw in reversed(tulang)]
        self.poli(kiri + kanan, warna)

    def bercak(self, pusat, r, rng, warna, n=9):
        """Gumpalan tak beraturan — rumput yang merambat, cobble yang aus."""
        pts = []
        for i in range(n):
            a = 2 * math.pi * i / n
            rr = r * rng.uniform(0.58, 1.25)
            pts.append((pusat[0] + math.cos(a) * rr, pusat[1] + math.sin(a) * rr))
        self.poli(pts, warna)

    def alun_takrata(self, pusat, r_dasar, rng, n=52):
        """Tepi alun-alun yang DIMAKAN, bukan digambar jangka.

        Deraunya dihaluskan (rata-rata tiga tetangga) sebelum dipakai. Derau mentah
        menghasilkan gerigi setiap simpul — itu terbaca 'rusak', bukan 'aus'. Yang
        mengabarkan usia adalah lengkung panjang yang meleset, bukan tepi bergerigi.
        """
        mentah = [rng.uniform(-1.0, 1.0) for _ in range(n)]
        halus = [(mentah[i - 1] + mentah[i] + mentah[(i + 1) % n]) / 3.0 for i in range(n)]
        pts = []
        for i in range(n):
            a = 2 * math.pi * i / n
            r = r_dasar + halus[i] * 20.0 + 11.0 * math.sin(a * 3.0 + 0.7)
            pts.append((pusat[0] + math.cos(a) * r, pusat[1] + math.sin(a) * r))
        self.poli(pts, C_ALUN)
        return pts

    def garis_pandang(self, a, b, warna=(250, 240, 190, 130)):
        """Putus-putus: ini ALAT UKUR, bukan benda di peta. Kalau ia digambar padat,
        pembaca berikutnya akan mengira ada jalan di sana."""
        ax, ay = self.xy(a)
        bx, by = self.xy(b)
        panjang = math.hypot(bx - ax, by - ay)
        n = int(panjang / 22)
        for i in range(n):
            t0 = i / n
            t1 = t0 + 0.55 / n
            self.d.line([ax + (bx - ax) * t0, ay + (by - ay) * t0,
                         ax + (bx - ax) * t1, ay + (by - ay) * t1], fill=warna, width=2)

    def cincin(self, jari):
        """Cincin C1..C4 dari spec, digambar TIPIS. Ia alat ukur, bukan isi peta —
        begitu ia setebal jalan, mata membacanya sebagai bangunan."""
        for nama, r in jari:
            x, y = self.xy(VC)
            self.d.ellipse([x - r, y - r, x + r, y + r], outline=C_CINCIN + (70,), width=2)
            self.d.text((x - 14, y - r - 20), nama, font=F_KECIL, fill=C_CINCIN + (150,))

    # -- keterangan ----------------------------------------------------------
    def catat(self, nama, apa):
        self.baris.append((nama, apa))

    def gambar_panel(self, kunci):
        x = W + 18
        y = KEPALA + 14
        self.d.rectangle([W, KEPALA, W + PANEL, KEPALA + H], fill=(18, 20, 24))
        self.d.text((x, y), "KETERANGAN — apa & kenapa di sini", font=F_PANEL_B, fill=C_TEKS)
        y += 28
        for nama, apa in self.baris:
            self.d.text((x, y), nama, font=F_PANEL_B, fill=C_NAMA)
            y += 18
            for baris in bungkus(self.d, apa, F_PANEL, PANEL - 40):
                self.d.text((x + 10, y), baris, font=F_PANEL, fill=C_REDUP)
                y += 17
            y += 8
        y += 10
        self.d.line([x, y, W + PANEL - 18, y], fill=(60, 62, 68), width=1)
        y += 14
        self.d.text((x, y), "KUNCI WARNA", font=F_PANEL_B, fill=C_TEKS)
        y += 24
        for warna, t in kunci:
            self.d.rectangle([x, y + 2, x + 22, y + 14], fill=warna)
            self.d.text((x + 32, y), t, font=F_PANEL, fill=C_REDUP)
            y += 22

    def simpan(self, nama):
        os.makedirs(OUT, exist_ok=True)
        p = os.path.join(OUT, nama)
        self.im.save(p)
        print("->", p, self.im.size)


def bungkus(d, t, font, lebar):
    keluar, baris = [], ""
    for k in t.split():
        uji = (baris + " " + k).strip()
        if d.textlength(uji, font=font) <= lebar:
            baris = uji
        else:
            keluar.append(baris)
            baris = k
    if baris:
        keluar.append(baris)
    return keluar


KUNCI = [
    (C_JALAN, "jalan / setapak"),
    (C_ALUN, "alun-alun berperkerasan"),
    (C_AIR, "air mancur"),
    (C_RUMAH, "rumah dihuni (panah = arah pintu)"),
    (C_RUMAH_GELAP, "rumah GELAP (tak berlentera)"),
    (C_NAMA, "bangunan bernama (berlabel)"),
    (C_RERUNTUHAN, "reruntuhan / fondasi (C3)"),
    (C_MAKAM, "pemakaman (C4)"),
    (C_POHON, "treeline / tepi tertutup"),
    (C_LADANG, "ladang"),
    (C_BUKTI, "titik bukti (#226)"),
    (C_WARGA, "warga"),
]

KUNCI_AKSEN = KUNCI[:2] + [
    (C_ALUN_AUS, "cobble AUS (sisi paling diinjak)"),
    (C_MERAMBAT, "rumput MERAMBAT masuk"),
] + KUNCI[2:] + [((250, 240, 190), "garis pandang (alat ukur, bukan benda)")]

CINCIN = [("C1", 224), ("C2", 448), ("C3", 672), ("C4", 896)]


# ══════════════════════════════════════════════════════════════════════════════
# A — APA YANG ADA SEKARANG.  Angka disalin dari Ashbrook64.gd, nomor baris ikut.
# ══════════════════════════════════════════════════════════════════════════════
def versi_a():
    p = Peta("A — APA YANG ADA SEKARANG",
             "dibaca dari game/scenes/world/Ashbrook64.gd · 60x44 petak (1920x1408 px) "
             "· nol tafsir, nol perbaikan")

    # tanah & jalan (_ground, .gd:236)
    p.jalan(0, VC[1] - 48, W, 96)                                   # jalan dagang, SELEBAR PETA
    p.kotak_sudut(VC[0] - 272, VC[1] - 176, 544, 352, C_ALUN)       # cobble 544x352
    p.alun((VC[0], VC[1] - 32), 120)                                # pelataran cakram
    for a, b, lb in [((704, 452), (704, VC[1] - 176), 28), ((1216, 532), (1216, VC[1] - 176), 28),
                     ((1408, VC[1] + 48), (1408, 812), 28), ((640, VC[1] + 48), (640, 900), 28),
                     ((640, 900), (700, 900), 28), ((700, 900), (700, 1004), 28),
                     ((1408, 860), (1408, 908), 26), ((1408, 908), (1452, 908), 20),
                     ((1452, 908), (1470, 924), 13), ((1470, 924), (1484, 930), 7)]:
        x0 = min(a[0], b[0]) - lb / 2
        y0 = min(a[1], b[1]) - lb / 2
        p.jalan(x0, y0, abs(b[0] - a[0]) + lb, abs(b[1] - a[1]) + lb)
    gy = H - 96.0                                                    # _gerbang_selatan, .gd:316
    p.jalan(VC[0] - 22, VC[1] + 298, 44, (gy - 160) - (VC[1] + 320) + 44)

    # treeline selatan (.gd:400) — TABRAKAN PENUH selebar peta
    p.treeline(0, (H - 8) - 76, W, 76)

    # pemakaman (.gd:353) 460x190 di (624,1216)
    p.kotak(624, 1216, 460, 190, C_MAKAM + (150,), C_MAKAM + (255,), 2)
    p.teks((624, 1216 - 95 - 18), "PEMAKAMAN", F_LABEL, C_MAKAM)

    # ladang berhenti digarap (.gd:518)
    p.kotak(900, 995, 320, 160, C_LADANG + (170,), C_LADANG + (255,), 2)
    p.teks((900, 995 - 80 - 16), "ladang", F_KECIL, C_LADANG)

    # tujuh denah C3 (.gd:481)
    for cx, cy, w, h in [(1520, 936, 132, 92), (352, 952, 108, 80), (944, 232, 148, 104),
                         (1456, 336, 96, 76), (1664, 592, 120, 88), (288, 560, 112, 84),
                         (416, 288, 88, 72)]:
        p.reruntuhan(cx, cy, w, h)

    # bangunan (_village, .gd:647). (foot, w, h, label, gelap)
    for foot, w, h, lab, gelap in [
        ((464, 752), 160, 224, "MERRIT", False),
        ((704, 400), 160, 192, "GUDANG", True),
        ((1216, 480), 96, 192, "OTHA (tutup)", True),
        ((1408, 800), 96, 192, None, True),
        ((640, 992), 160, 192, "Lyra", False),
        ((960, 464), 160, 224, "BALAI", True),
        ((1120, 1152), 96, 192, None, True),
        ((736, 1184), 160, 192, None, True),
        ((1376, 1056), 96, 192, None, True),
    ]:
        p.bangunan(foot, w, h, lab, gelap, C_NAMA if lab else None)

    # air mancur KERING (.gd:703) + bangku
    p.titik((VC[0], VC[1] - 32), 15, (150, 148, 140), (60, 58, 54))
    p.teks((VC[0], VC[1] - 68), "air mancur KERING", F_KECIL, (190, 188, 180))
    for i in range(8):
        bp = (VC[0] - 224 + i * 64, VC[1] + (112 if i % 2 == 0 else -112))
        p.kotak(bp[0], bp[1], 28, 12, (96, 84, 68, 255))

    # gerbang selatan — dua pilar, jalan BERHENTI 160 px sebelumnya
    for dx in (-52, 52):
        p.kotak(VC[0] + dx, gy, 44, 28, (150, 132, 104, 255))
    p.teks((VC[0], gy + 22), "GERBANG SELATAN", F_LABEL, (200, 184, 150))

    # warga: 6 bernama (_folk, .gd:1223) + zona latar (.gd:1196)
    for x, y in [(512, 848), (1216, 688), (736, 800), (1120, 832), (1280, 672), (672, 1024)]:
        p.titik((x, y), 7, (255, 220, 140), (60, 50, 20))
    for (x, y), n in [((608, 506), 2), ((1310, 596), 2), ((640, 1060), 2), ((560, 704), 2),
                      ((1440, 704), 2), ((464, 830), 1), ((VC[0], VC[1] + 96), 4)]:
        p.warga((x, y), n)

    # bukti (#226) + wisp
    for pos, nama in [((704, 480), "gudang gandum"), ((1216, 560), "200 roti"),
                      ((1856, 704), "jembatan"), ((1504, 1056), "fondasi rumput"),
                      ((800, 856), "batu berpahat"), ((1216, 664), "papan Otha")]:
        p.bukti(pos, nama)
    for x, y in [(506, 1182), (670, 1242), (776, 1158), (872, 1006)]:
        p.titik((x, y), 6, (150, 220, 235, 170))

    p.cincin(CINCIN)

    p.catat("BALAI (960,464)", "Fasad terbesar repo (inn 160x224) menghadap alun-alun dari "
            "utara — satu-satunya bangunan yang benar-benar mematuhi 'rumah di sisi utara "
            "ruang publik'. Gelap: nol jendela didaftarkan.")
    p.catat("MERRIT (464,752)", "Rumah singgah + lentera abadi. Duduk di ujung BARAT jalan "
            "dagang, 496 px dari alun-alun — jangkar cerita ada di luar C1, dan lenteranya "
            "memerintah dari pinggir, bukan dari pusat.")
    p.catat("GUDANG (704,400)", "Gudang gandum C3 menurut spec, tapi berdiri di jari-jari 314 "
            "px — masih C2. Cincinnya tak terbentuk di sini.")
    p.catat("OTHA (1216,480)", "Toko tutup. Papan bekas cat 128 px di selatannya. Jari-jari 336 "
            "px = C2, benar menurut spec.")
    p.catat("Lyra (640,992)", "Satu-satunya rumah C2 yang terbaca dihuni. Setapaknya bersiku "
            "— satu-satunya jalan di peta yang menghindar alih-alih menembus.")
    p.catat("4 rumah tanpa nama", "(1408,800) · (1120,1152) · (736,1184) · (1376,1056). Semua "
            "gelap, semua berpintu selatan, dan tak satu pun menghadap jalan atau ruang publik "
            "— pintunya membuka ke rumput.")
    p.catat("Jalan dagang", "Satu pita batu 96 px SELEBAR PETA, dari x=0 sampai x=1920, lurus "
            "tanpa putus. Ia menembus tepi peta di kedua sisi — jalan yang tak berpangkal dan "
            "tak berujung.")
    p.catat("Alun-alun", "Cobble 544x352 + cakram pelataran. Air mancur KERING, dan zona warga "
            "latar (r=96, n=4) dipusatkan 128 px di bawahnya — empat orang berdiri menutupi "
            "pusat desa.")
    p.catat("7 denah C3", "Tersebar mengelilingi (utara, timur-laut, timur, barat, barat-laut, "
            "dua selatan). Ukurannya beragam, bentuknya persegi — tapi tak satu pun berdiri "
            "di garis jalan, jadi mereka membaca 'batu di rumput', bukan 'jalan yang mati'.")
    p.catat("Ladang (900,995)", "320x160 di jari-jari ~300 px — nyaris menempel inti, di tanah "
            "yang paling berharga. Spec meminta ladang di TEPI dekat rumah.")
    p.catat("PEMAKAMAN (624,1216)", "460x190, ~78 nisan, pagar selatan bolong. Berhasil: ia "
            "punya TEPI, dan tepinyalah yang membuatnya terbaca. Sudut timur-laut dikosongkan "
            "untuk Sora (#013, belum di-wire).")
    p.catat("Treeline selatan", "Empat lapis + tabrakan penuh selebar peta. Berhasil. "
            "TIMUR & BARAT tak punya padanan — di sana peta berhenti pada kehitaman.")
    p.catat("Gerbang selatan", "Dua pilar di y=1312. Jalan menuju gerbang sengaja BERHENTI 160 "
            "px sebelum bukaan. Tapi ia tak tersambung ke alun-alun juga — ada jurang rumput "
            "di antara ujung jalan dan tepi selatan alun-alun.")
    p.gambar_panel(KUNCI)
    p.simpan("A_apa_yang_ada.png")


# ══════════════════════════════════════════════════════════════════════════════
# B — USUL DARI SPEC.  Setiap penempatan menjawab satu prinsip §0-§4 spec.
# ══════════════════════════════════════════════════════════════════════════════
def versi_b():
    p = Peta("B — USUL DARI SPEC (draft, untuk dicoret)",
             "ASHBROOK_MAP_SPEC.md 4-cincin · jalan dulu, bangunan menghadap jalan · "
             "gradien hidup-mati C1 100% > C2 25% > C3 10% > C4 ~0%")

    cx, cy = VC

    # ── 1. JALAN DULU. Semua yang lain menempel padanya. ─────────────────────
    # Tulang punggung utara-selatan: gerbang -> alun-alun -> balai. Inilah jalur
    # yang dilalui pemain di menit pertama, dan ia harus LURUS supaya gerbang &
    # balai saling memandang lewat air mancur.
    # Ia BERHENTI di y=1180, 78 px sebelum pilar — aturan yang sama dengan .gd sekarang:
    # jalan yang menyentuh gerbang berkata "masih dilewati".
    p.jalan(cx - 26, cy + 150, 52, 326)                             # alun-alun -> gerbang
    p.jalan(cx - 26, 430, 52, 130)                                  # alun-alun -> balai
    # Jalan dagang timur-barat: LEBIH LEBAR (kota lama), tapi ia MEMUDAR sebelum
    # tepi. Jalan yang menembus tepi peta berkata "dunia berlanjut"; jalan yang
    # menipis lalu berhenti berkata "dulu berlanjut" — itu D2 spasial spec.
    p.jalan(360, cy - 40, 1200, 80)
    p.jalan(200, cy - 28, 160, 56, pudar=True)
    p.jalan(1560, cy - 28, 180, 56, pudar=True)
    p.jalan(1740, cy - 16, 90, 32, pudar=True)
    # Dua LORONG kecil: satu-satunya cara rumah bisa 'menghadap' sesuatu, karena
    # tiap fasad repo berpintu SELATAN. Rumah berjajar di sisi utara lorong.
    # Keduanya MENYENTUH tulang punggung, jadi terbentuk perempatan — kalau tidak,
    # empat rumah selatan jadi pulau yang cuma bisa dicapai lewat rumput.
    p.jalan(380, 1004, 556, 44)                                     # lorong selatan-barat
    p.jalan(984, 1004, 616, 44)                                     # lorong selatan-timur

    # ── 2. ALUN-ALUN: lingkaran, bukan persegi. Persegi terbaca 'lapangan'; ──
    #      lingkaran punya PUSAT, dan pusat itulah yang dicari mata.
    p.alun((cx, cy), 210)
    p.titik((cx, cy), 20, C_AIR, (30, 60, 90))
    p.teks((cx, cy - 46), "AIR MANCUR — MENGALIR (D1)", F_KECIL, (160, 210, 240))

    # ── 3. C1: TIGA BANGUNAN BERNAMA DI SISI UTARA. ──────────────────────────
    #      Pintu selatan otomatis menghadap ke dalam. Ini prinsip spec yang paling
    #      murah dan paling banyak membayar: nol aset baru, cuma koordinat.
    p.bangunan((cx, 448), 160, 224, "BALAI", False, C_NAMA)
    p.bangunan((cx - 288, 470), 160, 224, "MERRIT", False, C_NAMA)
    p.bangunan((cx + 288, 470), 160, 192, "HALLORAN", False, C_NAMA)
    # Sisi selatan alun-alun sengaja KOSONG: bangku + batu berpahat saja. Ruang
    # publik yang dikelilingi penuh terbaca 'halaman dalam'; yang terbuka ke satu
    # arah punya MULUT, dan mulutnya menghadap gerbang.
    for i in range(6):
        p.kotak(cx - 200 + i * 80, cy + 150, 30, 12, (96, 84, 68, 255))

    # ── 4. C2: DELAPAN RUMAH, DUA MENYALA (25%). Semua di sisi UTARA jalan. ──
    for x, gelap in [(330, True), (490, False), (1400, True)]:
        p.bangunan((x, cy - 44), 96 if gelap else 160, 192, None, gelap)
    p.bangunan((1560, cy - 44), 96, 192, "OTHA (tutup)", True, C_NAMA)
    for x, gelap in [(450, True), (620, True), (1250, False), (1450, True)]:
        p.bangunan((x, 1000), 96 if gelap else 160, 192, None, gelap)
    p.teks((620, 1078), "C2 — 8 rumah, 2 menyala", F_KECIL, C_REDUP)

    # ── 5. C3: RERUNTUHAN BERBENTUK — berbaris di GARIS JALAN yang mati. ─────
    #      Ini bedanya 'puing tersebar' dengan 'jalan yang tak lagi ditempuh':
    #      fondasi yang sejajar mengabarkan bahwa dulu ada JALAN di antaranya,
    #      dan mata melanjutkan jalan itu sendiri tanpa diberi tahu.
    p.jalan(120, 348, 420, 30, pudar=True)                          # jalan mati barat-laut
    p.jalan(1430, 330, 400, 30, pudar=True)                         # jalan mati timur-laut
    for x in (180, 310, 440):
        p.reruntuhan(x, 286, 104, 76)
    for x in (180, 310, 440):
        p.reruntuhan(x, 424, 96, 70)
    for x in (1490, 1630, 1760):
        p.reruntuhan(x, 268, 100, 74)
    for x in (1490, 1630):
        p.reruntuhan(x, 406, 92, 68)
    p.teks((320, 202), "C3 — DUA BARIS FONDASI MENGAPIT JALAN YANG MATI", F_KECIL, C_RERUNTUHAN)
    p.teks((1620, 184), "C3 — idem, timur", F_KECIL, C_RERUNTUHAN)
    # gudang gandum: C3 menurut spec, dan ia BESAR — sisa satu-satunya yang berdiri.
    p.bangunan((760, 320), 160, 192, "GUDANG GANDUM", True, C_NAMA)
    p.reruntuhan(1690, 690, 150, 110, "jembatan terlalu lebar")

    # ── 6. LADANG DI TEPI, DEKAT RUMAH — bukan di pusat. ─────────────────────
    p.kotak(250, 1075, 260, 150, C_LADANG + (170,), C_LADANG + (255,), 2)
    p.teks((250, 1075 - 75 - 16), "ladang — menempel rumah C2", F_KECIL, C_LADANG)
    p.kotak(1690, 1130, 200, 140, C_LADANG + (120,), C_LADANG + (255,), 2)
    p.teks((1690, 1130 - 70 - 16), "ladang timur — kalah rumput", F_KECIL, C_LADANG)

    # ── 7. C4: pemakaman TETAP DI TEMPATNYA. Ia berhasil; ia tak disentuh. ───
    p.kotak(624, 1216, 460, 190, C_MAKAM + (150,), C_MAKAM + (255,), 2)
    p.teks((624, 1216 - 95 - 18), "PEMAKAMAN — TAK DISENTUH", F_LABEL, C_MAKAM)
    p.titik((624 + 190, 1216 - 77), 8, (200, 180, 240), (60, 50, 80))
    p.teks((624 + 190, 1216 - 100), "Sora (#013)", F_KECIL, (200, 180, 240))

    # ── 8. TEPI: treeline selatan tetap; TIMUR & BARAT diusulkan. ────────────
    p.treeline(0, (H - 8) - 76, W, 76)
    p.teks((W / 2, H - 116), "TREELINE SELATAN — TAK DISENTUH", F_LABEL, (150, 220, 160))
    p.treeline(0, 0, 88, H - 84, usul=True)
    p.treeline(W - 88, 0, 88, H - 84, usul=True)
    p.treeline(88, 0, W - 176, 76, usul=True)

    # ── 9. GERBANG: jalan sampai 2 petak sebelum bukaan, seperti sekarang. ───
    gy = H - 150.0
    for dx in (-58, 58):
        p.kotak(cx + dx, gy, 48, 30, (150, 132, 104, 255))
    p.teks((cx, gy - 40), "GERBANG SELATAN — pemain masuk di sini", F_LABEL, (200, 184, 150))
    p.teks((cx, gy - 60), "jalan berhenti 78 px sebelum bukaan", F_KECIL, C_REDUP)

    # ── 10. WARGA: gradien, bukan gerombolan. C1 banyak, C4 nol. ─────────────
    for (x, y), n in [((cx - 150, cy + 60), 4), ((cx + 160, cy + 40), 3), ((cx, cy + 210), 2),
                      ((cx - 288, 540), 2), ((cx + 288, 540), 2), ((cx, 530), 2),
                      ((560, cy + 60), 2), ((1340, cy + 60), 2),
                      ((620, 1064), 1), ((1250, 1064), 1), ((760, 400), 1)]:
        p.warga((x, y), n)
    p.teks((cx, cy + 262), "C1 = 13 warga · C2 = 6 · C3 = 1 · C4 = 0", F_KECIL, C_WARGA)

    # bukti tetap berpasangan dengan bendanya
    for pos, nama in [((760, 400), "gudang gandum"), ((cx + 288, 550), "200 roti"),
                      ((1690, 690), "jembatan"), ((310, 424), "fondasi rumput"),
                      ((cx - 208, cy + 118), "batu berpahat"), ((1560, cy + 76), "papan Otha")]:
        p.bukti(pos, nama)
    for x, y in [(506, 1182), (670, 1242), (776, 1158), (310, 286), (1630, 268)]:
        p.titik((x, y), 6, (150, 220, 235, 170))

    p.cincin(CINCIN)

    p.catat("Jalan DULU", "Tulang punggung utara-selatan (gerbang > alun-alun > balai) "
            "digambar sebelum apa pun. Gerbang dan balai saling memandang lewat air mancur: "
            "langkah pertama pemain sudah memperlihatkan ketimpangan #206.")
    p.catat("Jalan dagang MEMUDAR", "Tak lagi menembus tepi peta. Ia menyempit tiga kali lalu "
            "berhenti — jalan yang MASIH ADA membuktikan dulu ada tujuan, dan tujuan itulah "
            "yang hilang. Jalan yang dihapus bersih tak membuktikan apa-apa.")
    p.catat("Alun-alun bundar", "Lingkaran punya pusat; persegi cuma punya luas. Sisi selatan "
            "sengaja tak dibangun supaya ruang ini punya MULUT yang menghadap gerbang.")
    p.catat("BALAI / MERRIT / HALLORAN", "Bertiga di sisi UTARA alun-alun. Karena tiap fasad "
            "repo berpintu selatan, ini otomatis membuat ketiganya menghadap ke dalam — nol "
            "aset baru, cuma koordinat. Lentera Merrit kini memerintah dari pusat.")
    p.catat("C2 — 8 rumah, 2 menyala", "Semua di sisi UTARA jalan atau lorong, jadi pintunya "
            "membuka ke jalan, bukan ke rumput. Dua lorong selatan diadakan justru supaya "
            "empat rumah bawah punya sesuatu untuk dihadapi.")
    p.catat("OTHA di C2 timur", "Sesuai spec: pertanyaan pertama lahir di C2. Papan bekas cat "
            "terlihat dari jalan dagang tanpa pemain perlu menyimpang.")
    p.catat("C3 — fondasi BERBARIS", "Dua baris fondasi mengapit jalan yang sudah mati, "
            "barat-laut dan timur-laut. Fondasi sejajar mengabarkan ada JALAN di antaranya; "
            "mata melanjutkan jalan itu sendiri. Puing tersebar tak pernah bisa.")
    p.catat("GUDANG GANDUM ke C3", "Dipindah keluar ke jari-jari ~450 px. Ia satu-satunya "
            "bangunan yang masih BERDIRI di antara fondasi — dan itulah yang membuat fondasi "
            "di sekitarnya terbaca sebagai rumah, bukan batu.")
    p.catat("Ladang ke TEPI", "Dua petak, keduanya menempel rumah C2. Yang barat masih "
            "berbentuk; yang timur sudah kalah rumput. Dua tahap penyerahan yang sama, "
            "terlihat dalam satu bingkai.")
    p.catat("PEMAKAMAN — tak disentuh", "Ia sudah berhasil: ia punya tepi, dan tepinya yang "
            "membuatnya terbaca. Sudut timur-laut tetap kosong menunggu Sora (#013).")
    p.catat("Treeline T & B (USUL)", "Pita hijau 88 px di timur, barat, dan utara. Bukan "
            "hiasan: tanpa ini peta berhenti pada kehitaman, dan kekosongan tanpa tepi "
            "terbaca 'belum dibangun', bukan 'ditinggalkan'. Resep treeline sekarang "
            "menggambar pita MENDATAR — sisi tegak butuh susunan baru + uji mata.")
    p.catat("Gradien warga", "C1 13 orang, C2 6, C3 1, C4 nol. Angkanya kecil dengan sengaja: "
            "empat puluh jiwa, dan yang di layar tak boleh lebih ramai dari itu. Nol warga "
            "berdiri di atas air mancur.")
    p.catat("⚠ YANG BELUM DIJAWAB", "Fasad multi-arah belum ada di repo (Sonetto CC-BY-SA 4.0 "
            "sudah legal tapi belum diuji gaya). Sampai itu diputuskan, tiap rumah di peta ini "
            "TERPAKSA berpintu selatan — dan tata letak di atas dirancang supaya batasan itu "
            "tak terasa sebagai batasan.")
    p.gambar_panel(KUNCI)
    p.simpan("B_usul_dari_spec.png")


# ══════════════════════════════════════════════════════════════════════════════
# B' — B + TUJUH KOREKSI DIREKTUR.  Nomor komentar = nomor koreksi.
# ══════════════════════════════════════════════════════════════════════════════
def versi_b_aksen():
    p = Peta("B' — TATA LETAK FINAL (aksen: ketaksempurnaan TERANCANG)",
             "B rapi; B' hidup. Tujuh koreksi Direktur · seluruh simpangan lahir dari "
             "RNG berbiji 20260721 — jalankan ulang, hasilnya sama persis")
    rng = random.Random(20260721)

    # Pusat MATEMATIS alun-alun. Air mancur SENGAJA tidak di sini (koreksi 5).
    PC = (966.0, 700.0)
    FNT = (928.0, 678.0)                     # off-center 38 px barat, 22 px utara
    SUMBU = 906.0                            # koreksi 1: sumbu tegak digeser 60 px ke BARAT

    # ── KOREKSI 1 — PECAH SIMETRI ────────────────────────────────────────────
    # Sumbu tegak digeser ke barat DAN dibengkokkan; salib sempurna adalah tanda
    # tangan satu perencana. Kota yang tumbuh tak punya perencana, cuma kebiasaan.
    p.pita_tegak([(920.0, 1186.0, 26.0), (914.0, 1090.0, 25.0), (906.0, 1000.0, 24.0),
                  (900.0, 930.0, 23.0), (902.0, 886.0, 22.0)], C_JALAN)
    p.pita_tegak([(946.0, 508.0, 23.0), (952.0, 470.0, 21.0), (958.0, 438.0, 19.0)], C_JALAN)
    # Jalan dagang: bengkok, dan lebarnya TAK RATA — melebar di tengah (paling lama
    # diinjak), menipis ke dua ujung sampai berhenti tanpa pernah menyentuh tepi peta.
    # ⚠ Penyempitannya ditahan di 60 px TERAKHIR tiap ujung, bukan disebar sepanjang
    #   jalan. Percobaan pertama meruncing dari tengah ke dua sisi dan hasilnya bentuk
    #   LENSA — mata membacanya sebagai satu benda melengkung, bukan jalan. Jalan yang
    #   memudar harus tetap terbaca berlebar TETAP sampai tepat sebelum ia menyerah.
    p.pita([(196.0, 715.0, 20.0), (286.0, 712.0, 31.0), (368.0, 707.0, 37.0)], C_JALAN_PUDAR)
    p.pita([(368.0, 707.0, 38.0), (520.0, 699.0, 42.0), (700.0, 704.0, 44.0),
            (900.0, 700.0, 45.0), (1120.0, 697.0, 43.0), (1330.0, 690.0, 41.0),
            (1520.0, 697.0, 38.0)], C_JALAN)
    p.pita([(1520.0, 697.0, 37.0), (1660.0, 703.0, 31.0), (1746.0, 707.0, 22.0),
            (1798.0, 710.0, 9.0)], C_JALAN_PUDAR)
    # Dua lorong selatan, ikut bengkok. Keduanya menyentuh sumbu jadi ada perempatan.
    p.pita([(352.0, 1020.0, 20.0), (560.0, 1012.0, 21.0), (760.0, 1007.0, 20.0),
            (906.0, 1004.0, 19.0)], C_JALAN)
    p.pita([(906.0, 1004.0, 19.0), (1120.0, 1010.0, 19.0), (1340.0, 1017.0, 16.0),
            (1520.0, 1026.0, 10.0)], C_JALAN)

    # ── KOREKSI 2 — ALUN-ALUN DIMAKAN WAKTU ──────────────────────────────────
    p.alun_takrata(PC, 206.0, rng)
    # Sisi BARAT-DAYA aus: itu sisi yang dilewati tiap orang yang datang dari gerbang,
    # dan keausan harus jatuh di tempat kaki benar-benar lewat, bukan di tempat yang
    # menyeimbangkan komposisi. Aus yang simetris tak pernah dibuat oleh kaki.
    # Keausan ditahan di PITA TEPI (r 148-192), tak pernah di tengah. Aus yang muncul
    # di tengah pelataran terbaca sebagai genangan atau lubang — cacat, bukan usia.
    for i in range(7):
        a = math.radians(140 + i * 13)
        r = rng.uniform(148, 192)
        p.bercak((PC[0] + math.cos(a) * r, PC[1] + math.sin(a) * r),
                 rng.uniform(30, 50), rng, C_ALUN_AUS + (235,))
    # Sisi TIMUR-LAUT dirambati rumput: sisi terjauh dari gerbang, paling jarang
    # diinjak. Dua sisi, dua sebab, satu arah waktu.
    for i in range(6):
        a = math.radians(-58 + i * 15)
        r = rng.uniform(158, 204)
        p.bercak((PC[0] + math.cos(a) * r, PC[1] + math.sin(a) * r),
                 rng.uniform(26, 44), rng, C_MERAMBAT + (245,))
    for pos in [(1186.0, 600.0), (1148.0, 542.0), (1206.0, 668.0)]:
        p.bercak(pos, rng.uniform(22, 34), rng, C_MERAMBAT + (200,))

    # ── KOREKSI 5 — AIR MANCUR MENGALIR, OFF-CENTER ──────────────────────────
    # Tempat tua tumbuh DI SEKITAR sesuatu; ia tak pernah dipusatkan padanya. Air
    # mancurnya lebih tua daripada pelatarannya, dan pelataran itulah yang mengalah.
    p.titik(FNT, 21, C_AIR, (30, 60, 90))
    p.teks((FNT[0] - 30, FNT[1] - 62), "AIR MANCUR — MENGALIR (D1)", F_KECIL, (140, 200, 240))
    p.teks((FNT[0] - 30, FNT[1] - 46), "WaterFountain.png · off-center 38 px",
           F_KECIL, (110, 165, 205))
    p.titik(PC, 4, (250, 250, 250, 150))
    p.teks((PC[0] + 66, PC[1] + 6), "pusat matematis", F_KECIL, (210, 210, 210))

    # ── KOREKSI 3 — TIGA BANGUNAN BERNAMA, MAJU-MUNDUR TAK SAMA ──────────────
    # Barisan rata mengabarkan 'dibangun sekaligus'. Ketiganya dibangun di dasawarsa
    # berbeda, jadi ketiganya berdiri di garis berbeda — dan BALAI paling maju karena
    # ia yang terakhir mampu membayar tanah terdepan.
    p.bangunan((966, 478), 168, 232, "BALAI", False, C_NAMA)        # maju, tertinggi
    p.bangunan((790, 440), 160, 184, "MERRIT", False, C_NAMA)       # mundur 38
    p.bangunan((1232, 452), 152, 208, "HALLORAN", False, C_NAMA)    # mundur 26
    # ── KOREKSI 7 — TITIK FOKUS JAUH ─────────────────────────────────────────
    # Puncak balai: satu-satunya benda di peta yang menonjol DI ATAS garis atap. Dari
    # gerbang ia satu-satunya yang terlihat, dan mata berjalan ke sana sebelum kaki.
    p.kotak_sudut(938, 172, 56, 76, C_NAMA + (255,))
    p.poli([(938, 172), (994, 172), (966, 122)], (214, 176, 108, 255))
    p.teks((966, 100), "PUNCAK BALAI — jangkar mata dari gerbang", F_LABEL, (232, 200, 140))
    p.garis_pandang((920, 1244), (966, 132))
    for i in range(6):
        p.kotak(966, 260 + i * 8, 30, 3, (250, 240, 190, 60))
    # Jangkar kedua, ke barat-daya: pohon tunggal di tepi pemakaman. Dua jangkar, bukan
    # satu — satu jangkar memberi arah, dua memberi RUANG di antaranya.
    # Dipasang di tepi BARAT pemakaman, bukan timur: tepi timur ditembus sumbu jalan,
    # dan pohon di atas jalan bukan jangkar melainkan penghalang. Ke barat ia juga
    # menarik mata MELEBAR dari sumbu — persis yang diminta jangkar kedua.
    p.titik((352, 1262), 44, (34, 70, 42, 255), (20, 44, 26))
    p.kotak(352, 1306, 14, 40, (52, 40, 30, 255))
    p.teks((352, 1200), "POHON TUNGGAL — jangkar kedua", F_KECIL, (150, 200, 160))

    # ── KOREKSI 4 — SATU DISTRIK RERUNTUHAN PADAT DI BARAT-LAUT ──────────────
    # Sebaran merata mengabarkan 'beberapa rumah roboh'. Konsentrasi mengabarkan
    # 'DI SINI DULU PUSATNYA' — dan itu pembalikan yang jadi tesis peta: inti yang
    # sekarang bukan inti yang dulu. Kota tak menyusut ke tengah, ia menyusut MENJAUH.
    # Lorong sempit di antara petak sengaja dipertahankan: yang membuat mata membaca
    # 'distrik' bukan jumlah puingnya, melainkan JALAN yang masih terbaca di antaranya.
    p.pita([(126.0, 268.0, 9.0), (330.0, 262.0, 11.0), (560.0, 272.0, 9.0)], C_JALAN_PUDAR)
    p.pita([(140.0, 372.0, 8.0), (360.0, 366.0, 10.0), (600.0, 376.0, 8.0)], C_JALAN_PUDAR)
    p.pita_tegak([(300.0, 190.0, 8.0), (306.0, 300.0, 9.0), (300.0, 450.0, 8.0)],
                 C_JALAN_PUDAR)
    for cx_, cy_, w_, h_ in [
        (176, 210, 108, 70), (300, 204, 92, 64), (424, 212, 118, 74), (548, 206, 86, 62),
        (168, 318, 90, 66), (286, 322, 116, 78), (420, 316, 98, 68),
        (186, 424, 118, 72), (322, 428, 94, 64), (452, 420, 104, 68),
    ]:
        p.reruntuhan(cx_, cy_, w_, h_)
    p.teks((330, 148), "DISTRIK BEKAS — PUSAT KOTA LAMA", F_LABEL, C_RERUNTUHAN)
    p.teks((330, 168), "10 fondasi rapat + lorong yang masih terbaca", F_KECIL, C_RERUNTUHAN)
    # Tiga penyintas yang MELURUH ke luar distrik: batas distrik yang tajam terbaca
    # sebagai dinding. Yang meluruh terbaca sebagai kota yang habis pelan-pelan.
    for cx_, cy_, w_, h_ in [(742, 556, 76, 58), (238, 528, 84, 60), (596, 132, 68, 52)]:
        p.reruntuhan(cx_, cy_, w_, h_)
    p.bangunan((600, 450), 160, 196, "GUDANG GANDUM", True, C_NAMA)
    p.teks((600, 476), "satu-satunya yang masih BERDIRI di sini", F_KECIL, C_REDUP)
    p.reruntuhan(1744, 700, 140, 104, "jembatan terlalu lebar")

    # ── KOREKSI 6 — GRADIEN DI RUANG: JARAK MELEBAR KE TEPI ──────────────────
    # Inilah koreksi yang paling tak terlihat dan paling banyak membayar. Kepadatan
    # yang menipis lewat JARAK terbaca sebagai kota yang meluruh; kepadatan yang
    # menipis lewat jumlah lampu saja terbaca sebagai kota utuh yang kebetulan gelap.
    # Selisih jarak sengaja MEMBESAR, bukan tetap: 148 -> 172 -> 194 px.
    for x, fy, w_, gelap in [(662, 656, 160, False), (514, 650, 96, True),
                             (342, 660, 96, True), (148, 668, 96, True)]:
        p.bangunan((x, fy), w_, 192, None, gelap)
    for x, fy, w_, gelap, lab in [(1252, 660, 96, True, "OTHA (tutup)"),
                                  (1412, 652, 96, True, None),
                                  (1602, 658, 96, True, None)]:
        p.bangunan((x, fy), w_, 192, lab, gelap, C_NAMA if lab else None)
    for x, fy, w_, gelap in [(722, 966, 160, False), (502, 972, 96, True),
                             (267, 980, 96, True)]:
        p.bangunan((x, fy), w_, 192, None, gelap)
    for x, fy, w_, gelap in [(1126, 968, 96, True), (1346, 976, 96, True)]:
        p.bangunan((x, fy), w_, 192, None, gelap)
    p.teks((420, 790), "jarak antar rumah MELEBAR ke tepi: 148 > 172 > 194 px",
           F_KECIL, C_REDUP)
    p.teks((640, 1046), "C2 — 12 rumah, 2 menyala", F_KECIL, C_REDUP)

    # ladang: tetap di tepi, dan keduanya sudah berbeda tahap kekalahannya
    p.kotak(210, 1120, 260, 140, C_LADANG + (170,), C_LADANG + (255,), 2)
    p.teks((210, 1120 - 70 - 16), "ladang — menempel rumah C2", F_KECIL, C_LADANG)
    p.kotak(1706, 1122, 196, 132, C_LADANG + (115,), C_LADANG + (255,), 2)
    p.teks((1706, 1122 - 66 - 16), "ladang timur — kalah rumput", F_KECIL, C_LADANG)

    # ── TETAP: pemakaman · treeline selatan · wisp — TAK DISENTUH ────────────
    p.kotak(624, 1216, 460, 190, C_MAKAM + (150,), C_MAKAM + (255,), 2)
    p.teks((560, 1216 - 95 - 18), "PEMAKAMAN — TAK DISENTUH", F_LABEL, C_MAKAM)
    p.titik((824, 1147), 8, (200, 180, 240), (60, 50, 80))
    p.teks((790, 1124), "Sora (#013)", F_KECIL, (200, 180, 240))
    p.treeline(0, (H - 8) - 76, W, 76)
    p.teks((W / 2, H - 116), "TREELINE SELATAN — TAK DISENTUH", F_LABEL, (150, 220, 160))
    p.treeline(0, 0, 88, H - 84, usul=True)
    p.treeline(W - 88, 0, 88, H - 84, usul=True)
    p.treeline(88, 0, W - 176, 76, usul=True)

    # gerbang: ikut bergeser ke barat bersama sumbunya, dan pilarnya TAK SEJAJAR
    gy = H - 150.0
    p.kotak(SUMBU + 8 - 58, gy - 6, 48, 30, (150, 132, 104, 255))
    p.kotak(SUMBU + 8 + 58, gy + 4, 44, 28, (150, 132, 104, 255))
    p.teks((SUMBU + 8, gy - 46), "GERBANG SELATAN — pemain masuk di sini",
           F_LABEL, (200, 184, 150))
    p.teks((SUMBU + 8, gy - 26), "jalan berhenti ~58 px sebelum bukaan", F_KECIL, C_REDUP)

    # warga: gradien C1 13 · C2 6 · C3 1 · C4 0
    for (x, y), n in [((880, 762), 4), ((1088, 742), 3), ((1010, 858), 2),
                      ((790, 512), 2), ((1232, 524), 2),
                      ((560, 728), 2), ((1330, 724), 2),
                      ((722, 1030), 1), ((1126, 1032), 1), ((600, 522), 1)]:
        p.warga((x, y), n)
    p.teks((1210, 894), "C1 = 13 warga · C2 = 6 · C3 = 1 · C4 = 0 — dan NOL di air mancur",
           F_KECIL, C_WARGA)

    for pos, nama in [((512, 504), "gudang gandum"), ((1232, 530), "200 roti"),
                      ((1744, 700), "jembatan"), ((322, 428), "fondasi rumput"),
                      ((800, 846), "batu berpahat"), ((1252, 742), "papan Otha")]:
        p.bukti(pos, nama)
    for x, y in [(506, 1182), (670, 1242), (776, 1158), (286, 322), (1602, 742)]:
        p.titik((x, y), 6, (150, 220, 235, 170))

    p.cincin(CINCIN)

    p.catat("1 · SIMETRI DIPECAH", "Sumbu tegak digeser 60 px ke BARAT dan dibengkokkan "
            "(920 > 906 > 902). Jalan dagang bengkok dan lebarnya tak rata: 44 px di tengah, "
            "8 px di ujung timur. Salib sempurna adalah tanda tangan satu perencana — "
            "Ashbrook tak pernah punya perencana, cuma kebiasaan yang mengeras jadi jalan.")
    p.catat("2 · ALUN-ALUN DIMAKAN", "Tepi tak beraturan (derau dihaluskan, bukan bergerigi: "
            "gerigi terbaca 'rusak', lengkung meleset terbaca 'aus'). Barat-daya AUS — sisi "
            "yang dilewati tiap orang dari gerbang. Timur-laut DIRAMBATI rumput — sisi "
            "terjauh dari gerbang. Dua sisi, dua sebab, satu arah waktu.")
    p.catat("3 · BERNAMA TAK SEBARIS", "BALAI maju (kaki y=478, 232 px tertinggi), HALLORAN "
            "mundur 26 px, MERRIT mundur 50 px dan paling pendek. Barisan rata mengabarkan "
            "'dibangun sekaligus'; tiga garis berbeda mengabarkan tiga dasawarsa berbeda.")
    p.catat("4 · DISTRIK BEKAS", "10 fondasi RAPAT di barat-laut dengan lorong sempit yang "
            "masih terbaca di antaranya + 3 penyintas yang meluruh ke luar. Yang membuatnya "
            "terbaca 'distrik' bukan jumlah puingnya, melainkan JALAN di antaranya. Batas "
            "yang tajam terbaca sebagai dinding — karena itu tepinya meluruh, tak berhenti.")
    p.catat("   ↳ kenapa ini paling kuat", "Konsentrasi di barat-laut berkata: inti yang "
            "SEKARANG bukan inti yang DULU. Kota tak menyusut ke tengah, ia menyusut MENJAUH "
            "dari tempat ia lahir. Sebaran merata tak pernah bisa mengabarkan itu.")
    p.catat("5 · AIR MANCUR OFF-CENTER", "MENGALIR (D1 diputus) memakai WaterFountain.png. "
            "Digeser 38 px barat & 22 px utara dari pusat matematis alun-alun. Tempat tua "
            "tumbuh DI SEKITAR sesuatu, tak pernah dipusatkan padanya: air mancurnya lebih "
            "tua daripada pelatarannya, dan pelataran itulah yang mengalah.")
    p.catat("6 · GRADIEN DI RUANG", "Jarak antar rumah C2 MELEBAR ke tepi — 148 > 172 > 194 "
            "px, selisihnya sendiri membesar. Kepadatan yang menipis lewat jarak terbaca "
            "sebagai kota yang meluruh; yang menipis lewat jumlah lampu saja terbaca sebagai "
            "kota utuh yang kebetulan gelap. Koreksi paling tak terlihat, paling membayar.")
    p.catat("7 · DUA JANGKAR MATA", "Puncak BALAI menonjol di atas garis atap — satu-satunya "
            "benda yang terlihat dari gerbang, 1.100 px jauhnya. Garis pandang melewati TEPAT "
            "di sisi timur air mancur, jadi mata menemukan pusat desa dalam perjalanan ke "
            "jangkarnya. Jangkar kedua (pohon tunggal, tepi pemakaman) memberi RUANG: satu "
            "jangkar cuma memberi arah, dua memberi lebar.")
    p.catat("TAK DISENTUH", "Pemakaman (624,1216) · treeline selatan · empat wisp. Ketiganya "
            "sudah bekerja, dan yang bekerja tak dibongkar untuk dirapikan.")
    p.catat("⚠ TAK BERGANTUNG SONETTO", "Tiap rumah di peta ini berpintu SELATAN dan tetap "
            "menghadap jalan. Kalau uji gaya Sonetto (CC-BY-SA 4.0, byte-terbukti) gagal, "
            "B' tetap berdiri utuh — fasad multi-arah cuma akan memperbaiki sudut rumah, "
            "bukan menyelamatkan tata letaknya.")
    p.catat("⚠ BELUM DIUJI KAKI", "Kotak di blockout tak tahu apa-apa soal `_solid()`. Tiga "
            "tempat wajib dilewati kaki sungguhan sebelum dipercaya: perempatan lorong-sumbu, "
            "mulut selatan alun-alun, dan celah antara distrik bekas dan gudang.")
    p.gambar_panel(KUNCI_AKSEN)
    p.simpan("B_aksen.png")


if __name__ == "__main__":
    versi_a()
    versi_b()
    versi_b_aksen()
