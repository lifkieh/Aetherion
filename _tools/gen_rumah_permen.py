# -*- coding: utf-8 -*-
"""RUMAH PERMEN Candyveil (#299 revisi-2 Direktur) — DIGAMBAR SENDIRI, deklarasi penuh.

Direktur: "rumahnya jangan mushroom doang, kan temanya candy."
Aset rumah permen top-down CC0 tidak ditemukan di buruan (OGA/itch) — maka
enam tipe digambar prosedural, gaya pixel 2x (gambar kecil -> upscale NEAREST):

  kue_mangkuk  — cupcake: wrapper lipit + frosting menara + ceri
  roti_jahe    — gingerbread hall: badan cokelat + icing scallop + kancing
  kue_tart     — kue dua tingkat, frosting menetes + stroberi
  donat        — cincin glasir taburan; lubangnya = pintu
  es_krim      — kios: cone wafel + dua scoop + ceri
  wafel        — cottage dinding wafel + atap cokelat batang

Keluaran -> reports/mockup/aset_permen/*.png (tahap mockup; saat eksekusi
di-promosikan ke game/assets lewat jalur #240 yang sama).
"""
import os
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..",
	"reports", "mockup", "aset_permen")

# palet permen
GARIS = (74, 34, 54, 255)
PINK = (244, 150, 185, 255)
PINK_T = (252, 186, 210, 255)
PINK_G = (206, 104, 146, 255)
KRIM = (252, 244, 232, 255)
KRIM_G = (222, 206, 188, 255)
COKL = (150, 96, 58, 255)
COKL_T = (176, 122, 78, 255)
COKL_G = (110, 66, 38, 255)
MINT = (152, 216, 186, 255)
MINT_G = (104, 170, 140, 255)
KUNING = (246, 214, 120, 255)
KUNING_G = (198, 160, 76, 255)
MERAH = (226, 74, 92, 255)
PUTIH = (255, 255, 252, 255)
TABUR = [(255, 110, 150, 255), (120, 200, 255, 255), (255, 220, 100, 255),
	(150, 230, 150, 255), (200, 140, 255, 255)]


def kanvas(w, h):
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	return im, ImageDraw.Draw(im)


def pintu(d, cx, y1, tinggi=13, lebar=10, warna=KRIM, gagang=PINK_G):
	d.rounded_rectangle([cx - lebar // 2, y1 - tinggi, cx + lebar // 2, y1], 4,
		fill=warna, outline=GARIS)
	d.point((cx + lebar // 2 - 3, y1 - tinggi // 2), fill=gagang)


def jendela(d, cx, cy, r=4, kaca=(170, 220, 250, 255)):
	d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=kaca, outline=GARIS)
	d.line([(cx - r, cy), (cx + r, cy)], fill=GARIS)
	d.line([(cx, cy - r), (cx, cy + r)], fill=GARIS)


def taburan(d, box, n, rng_seed=7):
	import random
	rr = random.Random(rng_seed)
	for _ in range(n):
		x = rr.randrange(box[0], box[2])
		y = rr.randrange(box[1], box[3])
		w = rr.choice(TABUR)
		d.line([(x, y), (x + 2, y - 1)], fill=w, width=1)


def kue_mangkuk():
	im, d = kanvas(52, 60)
	# wrapper lipit
	d.polygon([(8, 34), (44, 34), (40, 56), (12, 56)], fill=PINK, outline=GARIS)
	for i, x in enumerate(range(11, 42, 5)):
		x2 = 12 + (x - 10) * 28 // 36
		d.line([(x, 35), (x2 + 1, 55)], fill=PINK_G if i % 2 else PINK_T)
	d.line([(8, 34), (44, 34)], fill=GARIS)
	# frosting tiga gulung
	d.ellipse([6, 24, 46, 40], fill=KRIM, outline=GARIS)
	d.ellipse([10, 14, 42, 30], fill=KRIM, outline=GARIS)
	d.ellipse([16, 6, 36, 21], fill=KRIM, outline=GARIS)
	d.ellipse([12, 26, 24, 34], fill=PUTIH)
	d.ellipse([18, 9, 26, 14], fill=PUTIH)
	taburan(d, (12, 10, 40, 34), 10, 3)
	# ceri
	d.ellipse([22, 1, 30, 9], fill=MERAH, outline=GARIS)
	d.point((25, 3), fill=PUTIH)
	pintu(d, 26, 55)
	jendela(d, 15, 46, 3)
	jendela(d, 37, 46, 3)
	return im


def roti_jahe():
	im, d = kanvas(84, 62)
	# badan
	d.rounded_rectangle([6, 24, 78, 58], 4, fill=COKL, outline=GARIS)
	d.rectangle([6, 24, 78, 30], fill=COKL_T)
	# atap
	d.polygon([(2, 26), (42, 4), (82, 26)], fill=COKL_G, outline=GARIS)
	# icing scallop tepi atap + tetesan dinding
	for x in range(6, 76, 8):
		d.ellipse([x, 22, x + 9, 31], fill=PUTIH, outline=KRIM_G)
	for x, ln in ((14, 6), (30, 9), (52, 5), (66, 8)):
		d.rectangle([x, 28, x + 4, 28 + ln], fill=PUTIH)
	# jalur icing zigzag di atap
	d.line([(10, 24), (18, 18), (26, 22), (34, 12), (42, 16), (50, 10),
		(58, 18), (66, 16), (74, 24)], fill=PUTIH, width=2)
	# kancing permen
	for x, w in ((18, TABUR[0]), (42, TABUR[3]), (66, TABUR[1])):
		d.ellipse([x - 4, 40, x + 4, 48], fill=w, outline=GARIS)
	pintu(d, 42, 57, 15, 12, KRIM)
	d.polygon([(42, 34), (39, 38), (42, 41), (45, 38)], fill=MERAH)   # hati
	jendela(d, 18, 33, 4)
	jendela(d, 66, 33, 4)
	return im


def kue_tart():
	im, d = kanvas(60, 66)
	# tingkat bawah
	d.rounded_rectangle([4, 38, 56, 62], 3, fill=MINT, outline=GARIS)
	for x in range(8, 52, 9):
		d.ellipse([x, 34, x + 10, 46], fill=MINT, outline=GARIS)
	d.rectangle([6, 44, 54, 60], fill=MINT)
	d.line([(4, 62), (56, 62)], fill=GARIS)
	# tingkat atas
	d.rounded_rectangle([14, 18, 46, 40], 3, fill=KRIM, outline=GARIS)
	for x in range(16, 44, 7):
		d.ellipse([x, 15, x + 8, 25], fill=KRIM, outline=GARIS)
	# frosting puncak + stroberi
	d.ellipse([20, 8, 40, 20], fill=PINK, outline=GARIS)
	d.ellipse([25, 1, 35, 11], fill=MERAH, outline=GARIS)
	d.point((28, 4), fill=PUTIH)
	d.point((31, 6), fill=KUNING)
	taburan(d, (8, 40, 52, 58), 8, 11)
	pintu(d, 30, 61, 14, 11)
	jendela(d, 13, 52, 4)
	jendela(d, 47, 52, 4)
	return im


def donat():
	im, d = kanvas(58, 54)
	# cincin
	d.ellipse([3, 6, 55, 52], fill=KUNING, outline=GARIS)
	# glasir
	d.ellipse([5, 7, 53, 40], fill=PINK, outline=None)
	d.arc([3, 6, 55, 52], 180, 360, fill=GARIS)
	for x, y in ((10, 34), (20, 40), (34, 41), (46, 33)):
		d.ellipse([x, y - 4, x + 8, y + 4], fill=PINK)
	d.ellipse([12, 12, 24, 20], fill=PINK_T)
	taburan(d, (8, 10, 50, 34), 12, 5)
	# lubang = pintu
	d.ellipse([21, 22, 37, 46], fill=(96, 62, 40, 255), outline=GARIS)
	pintu(d, 29, 46, 14, 11, KRIM)
	jendela(d, 12, 26, 3)
	jendela(d, 46, 26, 3)
	return im


def es_krim():
	im, d = kanvas(46, 78)
	# cone terbalik jadi menara
	d.polygon([(9, 40), (37, 40), (27, 76), (19, 76)], fill=KUNING, outline=GARIS)
	for i in range(4):
		d.line([(11 + i * 7, 40), (20 + i * 4, 74)], fill=KUNING_G)
	for i in range(3):
		d.line([(9, 48 + i * 9), (36 - i * 3, 48 + i * 9)], fill=KUNING_G)
	# dua scoop
	d.ellipse([5, 20, 41, 46], fill=KRIM, outline=GARIS)
	d.ellipse([10, 6, 36, 28], fill=PINK, outline=GARIS)
	d.ellipse([12, 24, 22, 32], fill=PUTIH)
	d.ellipse([14, 9, 22, 15], fill=PINK_T)
	taburan(d, (10, 10, 34, 26), 7, 9)
	d.ellipse([19, 0, 27, 8], fill=MERAH, outline=GARIS)
	pintu(d, 23, 74, 12, 10)
	jendela(d, 23, 33, 4)
	return im


def wafel():
	im, d = kanvas(64, 58)
	# dinding wafel
	d.rounded_rectangle([6, 22, 58, 54], 3, fill=KUNING, outline=GARIS)
	for x in range(12, 56, 9):
		d.line([(x, 23), (x, 53)], fill=KUNING_G)
	for y in range(28, 52, 8):
		d.line([(7, y), (57, y)], fill=KUNING_G)
	# atap batang cokelat + icing
	d.polygon([(2, 24), (32, 6), (62, 24)], fill=COKL, outline=GARIS)
	d.polygon([(8, 22), (32, 9), (56, 22)], fill=COKL_T)
	for x in range(8, 56, 8):
		d.ellipse([x, 20, x + 9, 28], fill=PUTIH, outline=KRIM_G)
	# mentega di puncak
	d.rectangle([27, 2, 37, 9], fill=(255, 232, 140, 255), outline=GARIS)
	pintu(d, 32, 53, 14, 11, KRIM)
	jendela(d, 16, 38, 4)
	jendela(d, 48, 38, 4)
	return im



# ═══════════════ GELOMBANG 2 (#299 v5 — "perbanyak variasi") ═══════════════
UNGU = (196, 150, 228, 255)
UNGU_G = (150, 104, 186, 255)
BIRU = (150, 200, 240, 255)
KACA = (222, 240, 250, 200)
PERAK = (216, 220, 228, 255)


def kastil_gula():
	im, d = kanvas(110, 92)
	# dua menara sudut bergaris permen
	for tx in (4, 90):
		d.rectangle([tx, 30, tx + 16, 84], fill=PUTIH, outline=GARIS)
		for yy in range(32, 82, 8):
			d.polygon([(tx + 1, yy + 6), (tx + 15, yy), (tx + 15, yy + 4), (tx + 1, yy + 10)], fill=MERAH)
		d.polygon([(tx - 3, 32), (tx + 8, 14), (tx + 19, 32)], fill=PINK, outline=GARIS)
		d.line([(tx + 8, 14), (tx + 8, 8)], fill=GARIS)
		d.polygon([(tx + 8, 8), (tx + 16, 11), (tx + 8, 14)], fill=KUNING)
	# badan utama
	d.rectangle([18, 38, 92, 86], fill=PINK_T, outline=GARIS)
	d.rectangle([18, 38, 92, 46], fill=PINK)
	# benteng icing (crenellation)
	for x in range(18, 90, 10):
		d.rectangle([x, 32, x + 6, 40], fill=PUTIH, outline=KRIM_G)
	# atap tengah + bendera
	d.polygon([(34, 38), (55, 20), (76, 38)], fill=UNGU, outline=GARIS)
	d.line([(55, 20), (55, 12)], fill=GARIS)
	d.polygon([(55, 12), (65, 15), (55, 18)], fill=MERAH)
	# gerbang lengkung + jendela
	d.rounded_rectangle([46, 60, 64, 86], 8, fill=COKL_G, outline=GARIS)
	d.rounded_rectangle([49, 64, 61, 86], 6, fill=KRIM, outline=GARIS)
	jendela(d, 30, 56, 4)
	jendela(d, 80, 56, 4)
	jendela(d, 55, 50, 3)
	taburan(d, (20, 40, 90, 58), 8, 21)
	return im


def kincir():
	im, d = kanvas(64, 84)
	# badan wafel silinder
	d.polygon([(18, 34), (46, 34), (42, 80), (22, 80)], fill=KUNING, outline=GARIS)
	for yy in range(40, 78, 9):
		d.line([(20, yy), (44, yy)], fill=KUNING_G)
	for xx in range(24, 42, 7):
		d.line([(xx, 36), (xx, 78)], fill=KUNING_G)
	# kubah frosting
	d.ellipse([14, 24, 50, 42], fill=KRIM, outline=GARIS)
	# empat bilah candy cane
	import math as m
	cx, cy = 32, 30
	for a in (35, 125, 215, 305):
		x2 = cx + int(26 * m.cos(m.radians(a)))
		y2 = cy + int(26 * m.sin(m.radians(a)))
		d.line([(cx, cy), (x2, y2)], fill=PUTIH, width=5)
		d.line([(cx, cy), (x2, y2)], fill=MERAH, width=2)
	d.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=KUNING, outline=GARIS)
	pintu(d, 32, 79, 13, 10)
	jendela(d, 32, 56, 4)
	return im


def cokelat_batang():
	im, d = kanvas(66, 56)
	# lempeng cokelat 3x2
	d.rounded_rectangle([4, 16, 62, 54], 3, fill=COKL, outline=GARIS)
	for i, x in enumerate(range(6, 60, 19)):
		for j, y in enumerate(range(18, 52, 18)):
			d.rounded_rectangle([x, y, x + 17, y + 16], 2, fill=COKL_T, outline=COKL_G)
	# foil perak terkelupas sudut kiri-atas
	d.polygon([(4, 16), (30, 16), (4, 38)], fill=PERAK, outline=GARIS)
	d.line([(8, 20), (24, 20)], fill=(180, 186, 196, 255))
	d.line([(8, 26), (18, 26)], fill=(180, 186, 196, 255))
	pintu(d, 33, 53, 14, 11, KRIM)
	jendela(d, 14, 44, 3)
	jendela(d, 52, 44, 3)
	return im


def makaron():
	im, d = kanvas(56, 58)
	# tiga keping makaron + krim
	for (y1, y2, w) in ((40, 56, UNGU), (24, 40, PINK), (8, 26, MINT)):
		d.ellipse([6, y1, 50, y2 + 2], fill=w, outline=GARIS)
		d.ellipse([8, y1 + 10, 48, y2 + 4], fill=KRIM, outline=GARIS)
	d.ellipse([6, 40, 50, 58], fill=UNGU, outline=GARIS)
	d.ellipse([10, 26, 46, 42], fill=PINK, outline=GARIS)
	d.ellipse([14, 10, 42, 28], fill=MINT, outline=GARIS)
	d.ellipse([18, 13, 28, 18], fill=(200, 240, 220, 255))
	pintu(d, 28, 56, 12, 10)
	jendela(d, 28, 34, 4)
	return im


def toples():
	im, d = kanvas(50, 66)
	# toples kaca berisi permen
	d.rounded_rectangle([6, 16, 44, 62], 8, fill=KACA, outline=GARIS)
	import random
	rr = random.Random(9)
	for _ in range(14):
		x, y = rr.randrange(10, 36), rr.randrange(30, 54)
		w = rr.choice(TABUR)
		d.ellipse([x, y, x + 6, y + 6], fill=w, outline=GARIS)
	d.rounded_rectangle([6, 16, 44, 28], 8, fill=KACA)
	d.line([(10, 20), (26, 18)], fill=PUTIH, width=2)   # kilau kaca
	# tutup
	d.rounded_rectangle([4, 8, 46, 20], 5, fill=MERAH, outline=GARIS)
	d.rectangle([4, 13, 46, 15], fill=(190, 50, 66, 255))
	pintu(d, 25, 61, 13, 10)
	return im


def permen_karet():
	im, d = kanvas(54, 62)
	# mesin gumball: kubah kaca penuh bola
	d.ellipse([5, 4, 49, 46], fill=KACA, outline=GARIS)
	import random
	rr = random.Random(4)
	for _ in range(16):
		x, y = rr.randrange(11, 38), rr.randrange(12, 36)
		w = rr.choice(TABUR)
		d.ellipse([x, y, x + 7, y + 7], fill=w, outline=GARIS)
	d.ellipse([12, 8, 24, 18], fill=(255, 255, 255, 120))
	# badan merah
	d.rounded_rectangle([8, 40, 46, 60], 4, fill=MERAH, outline=GARIS)
	d.rectangle([8, 44, 46, 46], fill=(190, 50, 66, 255))
	pintu(d, 27, 59, 12, 10, KRIM)
	jendela(d, 15, 51, 3)
	jendela(d, 39, 51, 3)
	return im


# ─────────────── DEKORASI ───────────────
def lampu_lolipop():
	im, d = kanvas(20, 40)
	d.rectangle([9, 14, 11, 38], fill=(150, 120, 140, 255), outline=None)
	d.ellipse([2, 2, 18, 18], fill=PINK, outline=GARIS)
	# spiral
	d.arc([4, 4, 16, 16], 0, 270, fill=PUTIH, width=2)
	d.arc([7, 7, 13, 13], 90, 360, fill=PUTIH, width=2)
	return im


def kios_permen():
	im, d = kanvas(52, 46)
	# meja
	d.rectangle([6, 26, 46, 42], fill=COKL_T, outline=GARIS)
	d.rectangle([6, 26, 46, 30], fill=KRIM)
	import random
	rr = random.Random(6)
	for _ in range(8):
		x = rr.randrange(9, 40)
		w = rr.choice(TABUR)
		d.ellipse([x, 31 + rr.randrange(0, 6), x + 5, 36 + rr.randrange(0, 6)], fill=w, outline=GARIS)
	# tiang + tenda garis
	d.rectangle([6, 12, 8, 28], fill=GARIS)
	d.rectangle([44, 12, 46, 28], fill=GARIS)
	for i, x in enumerate(range(2, 50, 8)):
		d.polygon([(x, 16), (x + 8, 16), (x + 6, 8), (x + 2, 8)],
			fill=PINK if i % 2 else PUTIH, outline=GARIS)
	d.rectangle([2, 14, 50, 17], fill=PINK_G)
	return im


def gapura():
	im, d = kanvas(84, 64)
	# dua candy cane melengkung jadi gerbang
	for x0, arah in ((6, 1), (78, -1)):
		d.line([(x0, 62), (x0, 22)], fill=PUTIH, width=7)
		d.line([(x0, 62), (x0, 22)], fill=MERAH, width=3)
	d.arc([6, 4, 78, 42], 180, 360, fill=PUTIH, width=7)
	d.arc([6, 4, 78, 42], 180, 360, fill=MERAH, width=3)
	# spanduk
	d.rectangle([18, 24, 66, 36], fill=KRIM, outline=GARIS)
	for i, x in enumerate(range(20, 64, 6)):
		d.ellipse([x, 27, x + 4, 31], fill=TABUR[i % len(TABUR)])
	return im


def main2():
	os.makedirs(OUT, exist_ok=True)
	daftar = [("kastil_gula", kastil_gula()), ("kincir", kincir()),
		("cokelat_batang", cokelat_batang()), ("makaron", makaron()),
		("toples", toples()), ("permen_karet", permen_karet()),
		("lampu_lolipop", lampu_lolipop()), ("kios_permen", kios_permen()),
		("gapura", gapura())]
	lebar = sum(im.width * 2 + 8 for _, im in daftar) + 8
	kontak = Image.new("RGBA", (lebar, 210), (24, 20, 34, 255))
	x = 8
	for nama, im in daftar:
		im2 = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
		im2.save(os.path.join(OUT, nama + ".png"))
		kontak.alpha_composite(im2, (x, 200 - im2.height))
		x += im2.width + 8
	kontak.save(os.path.join(OUT, "_kontak2.png"))
	print("-> aset_permen gelombang 2 (9 sprite + _kontak2.png)")


def main():
	os.makedirs(OUT, exist_ok=True)
	daftar = [("kue_mangkuk", kue_mangkuk()), ("roti_jahe", roti_jahe()),
		("kue_tart", kue_tart()), ("donat", donat()), ("es_krim", es_krim()),
		("wafel", wafel())]
	lebar = sum(im.width * 2 + 8 for _, im in daftar) + 8
	kontak = Image.new("RGBA", (lebar, 180), (24, 20, 34, 255))
	x = 8
	for nama, im in daftar:
		im2 = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
		im2.save(os.path.join(OUT, nama + ".png"))
		kontak.alpha_composite(im2, (x, 170 - im2.height))
		x += im2.width + 8
	kontak.save(os.path.join(OUT, "_kontak.png"))
	print("-> reports/mockup/aset_permen/ (6 rumah + _kontak.png)")


if __name__ == "__main__":
	main()
	main2()
