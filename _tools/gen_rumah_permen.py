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
