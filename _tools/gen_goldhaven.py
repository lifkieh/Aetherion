# -*- coding: utf-8 -*-
"""ASET GOLDHAVEN (#309 — kota 002, Crossroads of Aurelia).

Fasad = recolor batu-pasir/emas dari set fasad repo (asal: LPC Revised
4-Seasons, OGA-BY 3.0, dirakit gen_fasad.py — kredit hulu tetap berlaku).
DIGAMBAR SENDIRI (deklarasi): MENARA TIMBANGAN, gerbang batu kota, kios
dagang, segel pintu bawah-kota. Keluaran -> game/assets/game/sprites/goldhaven/.
#240: generator ter-commit = aset bisa dilahirkan ulang.
"""
import colorsys
import os
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
G = os.path.join(HERE, "..", "game", "assets", "game", "sprites")
OUT = os.path.join(G, "goldhaven")

GARIS = (52, 40, 28, 255)
PASIR = (216, 188, 132, 255)
PASIR_T = (234, 210, 160, 255)
PASIR_G = (178, 150, 100, 255)
EMAS = (232, 186, 80, 255)
EMAS_G = (170, 130, 50, 255)
KAYU = (140, 100, 60, 255)
MERAH_T = (196, 92, 70, 255)
KRIM = (246, 238, 220, 255)


def rona(im, target, sat=1.0, terang=1.0):
	out = im.copy()
	px = out.load()
	for y in range(out.height):
		for x in range(out.width):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			h_, l_, s_ = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
			d = (h_ - target + 0.5) % 1.0 - 0.5
			h2 = (target + d * 0.35) % 1.0
			l2 = min(1.0, l_ * terang)
			s2 = min(1.0, s_ * sat)
			r2, g2, b2 = colorsys.hls_to_rgb(h2, l2, s2)
			px[x, y] = (int(r2 * 255), int(g2 * 255), int(b2 * 255), a)
	return out


def menara_timbangan():
	im = Image.new("RGBA", (72, 176), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	# badan menara batu-pasir
	d.rectangle([16, 40, 56, 172], fill=PASIR, outline=GARIS)
	d.rectangle([18, 42, 34, 170], fill=PASIR_T)
	for yy in range(48, 168, 14):
		d.line([(17, yy), (55, yy)], fill=PASIR_G)
	for yy in range(48, 168, 28):
		for xx in range(20, 54, 12):
			d.line([(xx, yy), (xx, yy + 14)], fill=PASIR_G)
	# jendela sempit
	for yy in (70, 108, 146):
		d.rounded_rectangle([32, yy, 40, yy + 16], 3, fill=(70, 90, 120, 255), outline=GARIS)
	# balkon lonceng + kubah emas
	d.rectangle([12, 30, 60, 42], fill=PASIR_G, outline=GARIS)
	d.polygon([(10, 30), (36, 6), (62, 30)], fill=EMAS, outline=GARIS)
	d.polygon([(16, 30), (36, 12), (30, 30)], fill=(250, 220, 130, 255))
	d.line([(36, 6), (36, 0)], fill=GARIS)
	d.ellipse([33, -2, 39, 4], fill=EMAS, outline=GARIS)
	# EMBLEM TIMBANGAN — jiwa kotanya
	d.line([(26, 88), (46, 88)], fill=EMAS_G, width=2)
	d.line([(36, 84), (36, 92)], fill=EMAS_G, width=2)
	for cx in (26, 46):
		d.arc([cx - 5, 88, cx + 5, 98], 0, 180, fill=EMAS_G, width=2)
	# gerbang dasar
	d.rounded_rectangle([28, 148, 44, 172], 7, fill=(60, 46, 34, 255), outline=GARIS)
	return im


def gerbang_batu():
	im = Image.new("RGBA", (112, 84), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	for x0 in (0, 88):
		d.rectangle([x0, 8, x0 + 24, 82], fill=PASIR, outline=GARIS)
		for yy in range(14, 78, 12):
			d.line([(x0 + 1, yy), (x0 + 23, yy)], fill=PASIR_G)
		d.polygon([(x0 - 2, 10), (x0 + 12, 0), (x0 + 26, 10)], fill=PASIR_G, outline=GARIS)
	d.rectangle([20, 8, 92, 24], fill=PASIR_T, outline=GARIS)
	d.line([(24, 16), (88, 16)], fill=PASIR_G)
	# emblem timbangan kecil di ambang
	d.line([(50, 14), (62, 14)], fill=EMAS_G, width=2)
	for cx in (50, 62):
		d.arc([cx - 3, 14, cx + 3, 20], 0, 180, fill=EMAS_G)
	return im


def kios_dagang(warna=MERAH_T):
	im = Image.new("RGBA", (52, 46), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([6, 26, 46, 42], fill=KAYU, outline=GARIS)
	d.rectangle([6, 26, 46, 30], fill=KRIM)
	import random
	rr = random.Random(11)
	for _ in range(7):
		x = rr.randrange(9, 40)
		w = rr.choice([(226, 186, 90, 255), (150, 170, 110, 255), (180, 120, 80, 255),
			(200, 200, 210, 255)])
		d.ellipse([x, 31 + rr.randrange(0, 6), x + 6, 37 + rr.randrange(0, 6)], fill=w, outline=GARIS)
	d.rectangle([6, 12, 8, 28], fill=GARIS)
	d.rectangle([44, 12, 46, 28], fill=GARIS)
	for i, x in enumerate(range(2, 50, 8)):
		d.polygon([(x, 16), (x + 8, 16), (x + 6, 8), (x + 2, 8)],
			fill=warna if i % 2 else KRIM, outline=GARIS)
	d.rectangle([2, 14, 50, 17], fill=EMAS_G)
	return im


def segel_pintu():
	"""Pintu besi bawah-kota — tersegel. Netral, tanpa lambang apa pun (HIDDEN)."""
	im = Image.new("RGBA", (36, 46), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rounded_rectangle([2, 2, 34, 44], 5, fill=(88, 92, 100, 255), outline=(40, 42, 48, 255))
	for yy in (10, 22, 34):
		d.line([(4, yy), (32, yy)], fill=(60, 63, 70, 255))
	for xy in ((6, 6), (30, 6), (6, 40), (30, 40)):
		d.ellipse([xy[0] - 2, xy[1] - 2, xy[0] + 2, xy[1] + 2], fill=(120, 124, 132, 255))
	# palang segel — dilas, bukan digembok: tak dimaksudkan untuk dibuka lagi
	d.rectangle([0, 16, 36, 21], fill=(130, 100, 60, 255), outline=(70, 50, 30, 255))
	d.rectangle([0, 27, 36, 32], fill=(130, 100, 60, 255), outline=(70, 50, 30, 255))
	return im


def main():
	os.makedirs(OUT, exist_ok=True)
	# fasad recolor batu-pasir/emas (variasi rona per gedung supaya tak seragam)
	src = os.path.join(G, "lpc32")
	resep = [
		("fasad_balai.png", "fasad_serikat.png", 0.10, 1.1, 1.10),
		("fasad_inn.png", "fasad_bank.png", 0.115, 1.25, 1.12),
		("fasad_datar_tinggi.png", "fasad_kontrak.png", 0.09, 1.0, 1.05),
		("fasad_datar_lebar.png", "fasad_aula.png", 0.105, 1.1, 1.08),
		("fasad_rumah.png", "fasad_hunian_a.png", 0.08, 0.9, 1.02),
		("fasad_shop.png", "fasad_hunian_b.png", 0.11, 0.95, 1.0),
		("fasad_gudang.png", "fasad_gudang_gh.png", 0.07, 0.8, 0.98),
		("fasad_adobe_pudar.png", "fasad_balai_gh.png", 0.10, 1.05, 1.06),
	]
	for asal, tujuan, r, s, l in resep:
		p = os.path.join(src, asal)
		if os.path.exists(p):
			rona(Image.open(p).convert("RGBA"), r, s, l).save(os.path.join(OUT, tujuan))
	menara_timbangan().save(os.path.join(OUT, "menara_timbangan.png"))
	gerbang_batu().save(os.path.join(OUT, "gerbang_batu.png"))
	kios_dagang().save(os.path.join(OUT, "kios_dagang.png"))
	kios_dagang((110, 140, 180, 255)).save(os.path.join(OUT, "kios_dagang_b.png"))
	segel_pintu().save(os.path.join(OUT, "segel_pintu.png"))
	with open(os.path.join(OUT, "goldhaven.credits.txt"), "w", encoding="utf-8") as fh:
		fh.write("""# Kredit sprite Goldhaven (#309)
# Lisensi: OGA-BY 3.0 (turunan) + gambar-sendiri (milik Aetherion)
- fasad_*.png: RECOLOR batu-pasir/emas dari fasad repo — asal LPC Revised
  4-Seasons (OGA-BY 3.0, JaidynReiman dkk; dirakit _tools/gen_fasad.py;
  pintu digambar sendiri). Kredit hulu tetap berlaku.
- menara_timbangan / gerbang_batu / kios_dagang / segel_pintu:
  DIGAMBAR SENDIRI — _tools/gen_goldhaven.py — milik Aetherion.
Lisensi: OGA-BY 3.0
""")
	print("-> game/assets/game/sprites/goldhaven/ (13 berkas)")


if __name__ == "__main__":
	main()
