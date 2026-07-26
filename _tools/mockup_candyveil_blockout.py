# -*- coding: utf-8 -*-
"""BLOCKOUT CANDYVEIL v0.6b (#299) — tata letak PER-BANGUNAN, skala petak nyata.

Keputusan Direktur #299: gabungan A+B (gradasi barat→timur + pemakaman
tersembunyi di balik ladang), kota gula BESAR (14 bangunan, fasad permen baru),
manis-cerah vs pudar. Peta diperluas 120×86 petak; padang liar 70×52 yang ada
menjadi sisi barat-daya.

Skala gambar: 1 petak (32 px dunia) = 10 px blockout → kanvas 1200×860 + margin.
Alat persetujuan Direktur SEBELUM eksekusi. Bisa dijalankan ulang (#240).
"""
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")

S = 10          # 1 petak -> 10 px
OX, OY = 40, 60  # margin kanvas

EMAS = (244, 197, 66)
TINTA = (232, 236, 248)
REDUP = (150, 156, 178)
BG = (15, 19, 33)

# palet zona (K3: jenuh = hidup, pudar = dilupakan)
TANAH_KOTA = (86, 60, 78)
TANAH_PINGGIR = (66, 54, 62)
TANAH_MAKAM = (52, 60, 52)
TANAH_LIAR = (58, 46, 68)
JALAN = (188, 158, 108)
PLAZA = (222, 176, 128)
LADANG = (196, 142, 178)
PAGAR = (120, 96, 70)


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def px(tx, ty):
	return (OX + tx * S, OY + ty * S)


def kotak(d, t0, t1, warna, outline=None, alpha=255):
	a = px(*t0)
	b = px(*t1)
	d.rectangle([a[0], a[1], b[0], b[1]], fill=warna + (alpha,),
		outline=(outline or tuple(max(0, c - 40) for c in warna)) + (255,))


# ── 14 BANGUNAN KOTA (id, petak x0,y0,x1,y1, warna fasad, label) ─────────────
BANGUNAN = [
	("menara_lonceng", 34, 4, 40, 12, (240, 120, 150), "MENARA LONCENG PERMEN (landmark, tertinggi)"),
	("balai_gula", 24, 8, 33, 15, (236, 150, 96), "Balai Gula"),
	("penginapan_wafel", 42, 8, 52, 15, (214, 168, 110), "Penginapan Wafel"),
	("toko_sirup", 16, 14, 23, 20, (150, 200, 120), "Toko Sirup"),
	("kedai_cokelat", 54, 12, 61, 18, (146, 96, 70), "Kedai Cokelat"),
	("toko_roti_jahe", 10, 20, 17, 26, (196, 130, 80), "Toko Roti Jahe"),
	("rumah_permen_1", 20, 26, 26, 31, (238, 140, 180), "Rumah Pembuat Permen 1"),
	("rumah_permen_2", 46, 22, 52, 27, (170, 150, 220), "Rumah Pembuat Permen 2"),
	("rumah_permen_3", 55, 24, 61, 29, (120, 190, 200), "Rumah Pembuat Permen 3"),
	("gudang_gula", 6, 8, 14, 15, (206, 206, 190), "Gudang Gula"),
	("kios_karamel_1", 28, 20, 32, 23, (232, 190, 120), "Kios 1"),
	("kios_karamel_2", 40, 20, 44, 23, (232, 190, 120), "Kios 2"),
	("rumah_warga_1", 8, 28, 14, 33, (222, 160, 150), "Rumah Warga 1"),
	("rumah_warga_2", 58, 6, 64, 11, (200, 170, 130), "Rumah Warga 2"),
]

PINGGIRAN = [
	("p1", 72, 10, 78, 15, "dihuni"), ("p2", 82, 8, 88, 13, "dihuni"),
	("p3", 92, 12, 98, 17, "KOSONG"), ("p4", 74, 20, 80, 25, "dihuni — warga tua"),
	("p5", 86, 18, 92, 23, "KOSONG"), ("p6", 94, 24, 100, 29, "dihuni — warga tua"),
]


def blockout():
	im = Image.new("RGBA", (OX * 2 + 120 * S, OY + 86 * S + 90), BG + (255,))
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, im.width, 44], fill=(26, 33, 56, 255))
	d.text((16, 8), "BLOCKOUT CANDYVEIL 120 x 86 petak (#299 - gabungan A+B, kota besar) - 1 kotak = 1 petak dunia 32px",
		font=f(23), fill=EMAS)

	# tanah zona
	kotak(d, (0, 0), (70, 36), TANAH_KOTA)          # kota
	kotak(d, (70, 0), (104, 36), TANAH_PINGGIR)     # pinggiran
	kotak(d, (96, 36), (120, 58), LADANG)           # ladang gula (tirai)
	kotak(d, (100, 60), (120, 80), TANAH_MAKAM)     # pemakaman tersembunyi
	kotak(d, (0, 36), (70, 86), TANAH_LIAR)         # padang liar existing (70x52 -> digeser)
	kotak(d, (70, 36), (96, 86), TANAH_LIAR)        # liar timur jalur memutar
	kotak(d, (104, 0), (120, 36), TANAH_PINGGIR)

	# kisi petak halus
	for gx in range(0, 121, 10):
		a = px(gx, 0); b = px(gx, 86)
		d.line([a, b], fill=(255, 255, 255, 18))
	for gy in range(0, 87, 10):
		a = px(0, gy); b = px(120, gy)
		d.line([a, b], fill=(255, 255, 255, 18))

	# jalan gula utama: gerbang barat -> plaza -> pinggiran timur
	kotak(d, (0, 16), (30, 19), JALAN)
	kotak(d, (44, 16), (104, 19), JALAN)
	# plaza karamel + air mancur sirup
	kotak(d, (30, 12), (44, 24), PLAZA)
	c = px(37, 18)
	d.ellipse([c[0] - 14, c[1] - 14, c[0] + 14, c[1] + 14], fill=(150, 190, 230, 255), outline=(60, 90, 130))
	d.text((c[0] - 30, c[1] + 18), "air mancur sirup", font=f(13), fill=(70, 50, 30))
	# cabang selatan ke padang liar + jalur MEMUTAR ke pemakaman (A+B!)
	kotak(d, (36, 24), (39, 36), JALAN)
	kotak(d, (86, 19), (89, 60), JALAN)              # turun di pinggiran
	kotak(d, (86, 60), (100, 63), JALAN)             # belok timur DI BAWAH ladang
	d.text(px(64, 62), "jalur MEMUTAR: pemakaman tak terlihat dari kota (B)", font=f(15), fill=TINTA)

	# ladang gula = tirai penggusuran
	for lx in range(98, 119, 3):
		for ly in range(38, 57, 3):
			p = px(lx, ly)
			d.ellipse([p[0] - 3, p[1] - 3, p[0] + 3, p[1] + 3], fill=(240, 200, 230, 255))
	d.text(px(97, 34), "LADANG GULA - maju SEPETAK ke selatan tiap musim (papan kota di tepinya)", font=f(15), fill=(90, 40, 70))

	# pemakaman + gubuk Sora
	for nx in range(103, 118, 3):
		for ny in range(64, 77, 4):
			p = px(nx, ny)
			d.rectangle([p[0] - 2, p[1] - 4, p[0] + 2, p[1]], fill=(180, 186, 178, 255))
	kotak(d, (114, 74), (118, 78), (110, 90, 70))
	d.text(px(101, 80), "PEMAKAMAN TUA + GUBUK SORA (114,74) - lampu2 kecil = satu-satunya jenuh di sini", font=f(15), fill=TINTA)

	# bangunan kota
	for bid, x0, y0, x1, y1, warna, label in BANGUNAN:
		kotak(d, (x0, y0), (x1, y1), warna)
	# pinggiran
	for bid, x0, y0, x1, y1, ket in PINGGIRAN:
		warna = (108, 96, 104) if "KOSONG" in ket else (140, 120, 128)
		kotak(d, (x0, y0), (x1, y1), warna)
		d.text(px(x0, y1), ket, font=f(12), fill=REDUP)

	# label bangunan bernomor
	for i, (bid, x0, y0, x1, y1, warna, label) in enumerate(BANGUNAN, 1):
		p = px(x0, y0)
		d.text((p[0] + 3, p[1] + 2), str(i), font=f(17), fill=(20, 16, 24))
	d.text(px(0, 88 - 88), "", font=f(10), fill=REDUP)

	# legenda bawah
	y0 = OY + 86 * S + 8
	leg = " | ".join("%d %s" % (i, l.split(" (")[0]) for i, (_, _, _, _, _, _, l) in enumerate(BANGUNAN, 1))
	d.text((OX, y0), leg[:170], font=f(14), fill=TINTA)
	d.text((OX, y0 + 22), leg[170:], font=f(14), fill=TINTA)
	d.text((OX, y0 + 46),
		"Gerbang: barat=Greenvale - selatan=padang liar (map lama 70x52, digeser jadi barat-daya) - pinggiran timur: 6 rumah (2 KOSONG)",
		font=f(14), fill=REDUP)
	im.convert("RGB").save(os.path.join(MOCK, "candyveil_blockout.png"))
	print("-> candyveil_blockout.png")


if __name__ == "__main__":
	blockout()
