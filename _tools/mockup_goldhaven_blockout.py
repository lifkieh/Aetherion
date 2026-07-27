# -*- coding: utf-8 -*-
"""BLOCKOUT GOLDHAVEN (#308 — kota 002, Crossroads of Aurelia) + strip gaya.

Tata CINCIN dari kartu konsep yang di-ACC: 4 gerbang karavan -> jalan raya
silang -> Pasar Agung radial + Menara Timbangan -> deret serikat & bank ->
blok hunian padat -> pintu bawah-kota tersegel (TL; Netherdeep HIDDEN).

Skala: 1 petak = 8 px blockout. Peta 80x56 petak (2560x1792 dunia).
Strip gaya: fasad repo (LPC Revised) di atas ubin batu — bahasa visual kota
batu-pasir/emas. Alat coretan Direktur. Bisa dijalankan ulang (#240).
"""
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
G = os.path.join(ROOT, "game", "assets", "game")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")
S = 8
OX, OY = 40, 60
TW, TH = 80, 56

EMAS = (244, 197, 66)
TINTA = (232, 236, 248)
REDUP = (150, 156, 178)
BG = (15, 19, 33)
TANAH = (78, 66, 54)
JALAN = (168, 148, 112)
PLAZA = (208, 180, 128)
CINCIN1 = (120, 100, 70)
CINCIN2 = (96, 84, 66)
GERBANG = (190, 160, 90)
BAWAH = (86, 74, 110)


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def px(tx, ty):
	return (OX + tx * S, OY + ty * S)


def kotak(d, t0, t1, warna, alpha=255, outline=None):
	a, b = px(*t0), px(*t1)
	d.rectangle([a[0], a[1], b[0], b[1]], fill=warna + (alpha,),
		outline=(outline or tuple(max(0, c - 40) for c in warna)) + (255,))


BANGUNAN = [
	# cincin-1: serikat & bank menghadap plaza (fasad TINGGI)
	("menara_timbangan", 38, 24, 42, 31, (240, 208, 130), "1 MENARA TIMBANGAN (landmark, 4 jalan bertemu di bawahnya)"),
	("serikat_pusat", 28, 18, 35, 24, (200, 150, 70), "2 KANTOR PUSAT SERIKAT PENJELAJAH"),
	("bank_emas", 45, 18, 52, 24, (222, 178, 92), "3 Bank Goldhaven"),
	("rumah_kontrak", 45, 33, 52, 38, (196, 160, 100), "4 Rumah Kontrak"),
	("balai_kota", 28, 33, 35, 38, (170, 140, 90), "5 Balai Kota"),
	("penginapan_karavan", 22, 24, 27, 31, (180, 130, 80), "6 Penginapan Karavan"),
	("aula_dagang", 53, 24, 58, 31, (190, 150, 85), "7 Aula Dagang"),
	# cincin-2: blok hunian padat (BARIS, bukan taburan)
	("hunian_a1", 12, 12, 17, 17, (140, 120, 96), "8-13 blok hunian utara (2 baris x 3)"),
	("hunian_a2", 20, 12, 25, 17, (140, 120, 96), ""),
	("hunian_a3", 55, 12, 60, 17, (140, 120, 96), ""),
	("hunian_a4", 63, 12, 68, 17, (140, 120, 96), ""),
	("hunian_a5", 12, 20, 17, 25, (132, 114, 92), ""),
	("hunian_a6", 63, 20, 68, 25, (132, 114, 92), ""),
	("hunian_b1", 12, 38, 17, 43, (140, 120, 96), "14-19 blok hunian selatan"),
	("hunian_b2", 20, 38, 25, 43, (140, 120, 96), ""),
	("hunian_b3", 55, 38, 60, 43, (140, 120, 96), ""),
	("hunian_b4", 63, 38, 68, 43, (140, 120, 96), ""),
	("gudang_1", 12, 46, 19, 51, (120, 108, 90), "20-21 gudang karavan (dekat gerbang selatan)"),
	("gudang_2", 61, 46, 68, 51, (120, 108, 90), ""),
]


def blockout():
	im = Image.new("RGBA", (OX * 2 + TW * S, OY + TH * S + 120), BG + (255,))
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, im.width, 44], fill=(26, 33, 56, 255))
	d.text((14, 8), "BLOCKOUT GOLDHAVEN 80x56 petak (#308) - tata CINCIN - 1 kotak = 1 petak dunia 32px",
		font=f(23), fill=EMAS)

	kotak(d, (0, 0), (TW, TH), TANAH)
	# tembok kota (persegi, gerbang di tengah sisi)
	d.rectangle([px(2, 2)[0], px(2, 2)[1], px(78, 54)[0], px(78, 54)[1]],
		outline=(60, 52, 44, 255), width=5)
	# jalan raya silang (lebar 3 petak) + cincin jalan
	kotak(d, (38, 2), (42, 54), JALAN)
	kotak(d, (2, 26), (78, 30), JALAN)
	# cincin jalan dalam (mengitari plaza)
	for box in [((26, 16), (54, 17)), ((26, 39), (54, 40)), ((26, 16), (27, 40)), ((53, 16), (54, 40))]:
		kotak(d, box[0], box[1], JALAN)
	# PASAR AGUNG radial
	c = px(40, 28)
	d.ellipse([c[0] - 11 * S, c[1] - 9 * S, c[0] + 11 * S, c[1] + 9 * S],
		fill=PLAZA + (255,), outline=(150, 120, 70, 255), width=3)
	d.text((c[0] - 44, c[1] + 50), "PASAR AGUNG", font=f(15), fill=(90, 66, 30))
	# kios pasar radial (12 kios melingkar)
	import math
	for i in range(12):
		a = i * math.tau / 12
		kx = c[0] + int(math.cos(a) * 7.5 * S)
		ky = c[1] + int(math.sin(a) * 6 * S)
		d.rectangle([kx - 6, ky - 5, kx + 6, ky + 5], fill=(226, 140, 90, 255), outline=(120, 70, 40, 255))
	# gerbang 4 arah
	for nama, box in [("GERBANG UTARA", ((37, 1), (43, 4))), ("GERBANG SELATAN", ((37, 52), (43, 55))),
			("GERBANG BARAT", ((1, 25), (4, 31))), ("GERBANG TIMUR", ((76, 25), (79, 31)))]:
		kotak(d, box[0], box[1], GERBANG)
		p0 = px(*box[0])
		d.text((p0[0] - 8, p0[1] - 16), nama, font=f(12), fill=TINTA)
	# bangunan
	for nama, x0, y0, x1, y1, w, label in BANGUNAN:
		kotak(d, (x0, y0), (x1, y1), w)
	# nomor pada bangunan berlabel
	n = 1
	for nama, x0, y0, x1, y1, w, label in BANGUNAN:
		if label:
			p0 = px(x0, y0)
			d.text((p0[0] + 3, p0[1] + 2), label.split()[0], font=f(14), fill=(20, 16, 24))
	# BAWAH-KOTA (TL) — HIDDEN: pintu tersegel di gang, TANPA penanda mencolok
	kotak(d, (57, 7), (60, 10), BAWAH)
	d.text(px(45, 6), "pintu bawah-kota TERSEGEL (Netherdeep - HIDDEN, tanpa penanda)", font=f(13), fill=(150, 140, 190))
	# karavan di gerbang (gerobak)
	for gx, gy in [(36, 6), (44, 50), (7, 27), (72, 29)]:
		d.rectangle([px(gx, gy)[0], px(gx, gy)[1], px(gx + 2, gy + 1)[0], px(gx + 2, gy + 1)[1]],
			fill=(150, 110, 70, 255), outline=(80, 55, 30, 255))
	# legenda
	y0 = OY + TH * S + 10
	leg = [l for *_x, l in BANGUNAN if l]
	d.text((OX, y0), " | ".join(leg[:5]), font=f(13), fill=TINTA)
	d.text((OX, y0 + 20), " | ".join(leg[5:]), font=f(13), fill=TINTA)
	d.text((OX, y0 + 44),
		"35.000 jiwa = ILUSI KEPADATAN: fasad menjulang (Suikoden, pipeline gen_fasad) + kerumunan TownFolk + karavan + 12 kios radial",
		font=f(14), fill=REDUP)
	d.text((OX, y0 + 66),
		"Kanon dijaga: Netherdeep HIDDEN (pintu tersegel, nol penanda) - kantor pusat Serikat - 'pemain sadar dunia jauh lebih besar' = masuk gerbang barat dari Ashbrook, plaza terlihat MENJULANG",
		font=f(14), fill=REDUP)
	im.convert("RGB").save(os.path.join(MOCK, "goldhaven_blockout.png"))
	print("-> goldhaven_blockout.png")


def strip_gaya():
	"""Strip gaya: fasad repo di ubin batu — bahasa visual Goldhaven."""
	im = Image.new("RGBA", (1280, 400), BG + (255,))
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, 1280, 40], fill=(26, 33, 56, 255))
	d.text((14, 6), "STRIP GAYA GOLDHAVEN - fasad menjulang (pipeline gen_fasad, LPC Revised) di ubin batu",
		font=f(22), fill=EMAS)
	batu = Image.open(os.path.join(G, "tiles", "lpc32", "stone32.png")).convert("RGBA") \
		if os.path.exists(os.path.join(G, "tiles", "lpc32", "stone32.png")) else None
	if batu:
		for ty in range(40, 400, batu.height):
			for tx in range(0, 1280, batu.width):
				im.alpha_composite(batu, (tx, ty))
	fasad_dir = os.path.join(G, "sprites", "lpc32")
	x = 30
	for nama in ["fasad_balai.png", "fasad_inn.png", "fasad_datar_tinggi.png",
			"fasad_shop.png", "fasad_rumah.png", "fasad_datar_lebar.png"]:
		p = os.path.join(fasad_dir, nama)
		if not os.path.exists(p):
			continue
		fa = Image.open(p).convert("RGBA")
		im.alpha_composite(fa, (x, 388 - fa.height))
		x += fa.width + 26
	d = ImageDraw.Draw(im, "RGBA")
	d.text((24, 356), "warna final: recolor batu-pasir/emas via gen_fasad_goldhaven.py + MENARA TIMBANGAN & gerbang batu digambar-rakit (deklarasi)",
		font=f(14), fill=TINTA)
	im.convert("RGB").save(os.path.join(MOCK, "goldhaven_gaya.png"))
	print("-> goldhaven_gaya.png")


if __name__ == "__main__":
	blockout()
	strip_gaya()
