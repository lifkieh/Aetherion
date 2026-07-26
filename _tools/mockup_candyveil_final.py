# -*- coding: utf-8 -*-
"""MOCKUP FINAL CANDYVEIL (#299, revisi Direktur) — kota permen-PERI, aset benar.

Putusan Direktur: rumah BUKAN gaya Ashbrook — permen-permenan + peri, lucu &
aesthetic; tone kota bebas. Susunan aset:
  * RUMAH JAMUR — "Mushroom Houses" (AntumDeluge/Stendhal, CC0), sel 64x64,
    di-recolor frosting pastel (bintik putih = taburan gula)
  * LPC Candy (Mark Weyer, CC0): candy cane -> menara lonceng;
    gummy bear -> penghuni (bata cokelat disimpan untuk interior/pagar)
  * ubin candy32 + props permen repo (asli Aetherion)
DIGAMBAR SENDIRI (deklarasi): icing scallop, kerucut & lonceng menara, atap
kedai/balai, recolor air mancur sirup, gradasi pudar pinggiran.
"""
import colorsys
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
G = os.path.join(ROOT, "game", "assets", "game")
CANDY = os.path.join(ROOT, "assets_raw", "oga", "candy", "lpc_candy")
JAMUR = os.path.join(ROOT, "assets_raw", "oga", "candy", "mushroom_houses",
	"PNG", "64x64", "mushroom_houses-RGB.png")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")
T = 32
W, H = 40 * T, 26 * T


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def buka(rel, root=G):
	p = rel if os.path.isabs(rel) else os.path.join(root, rel)
	return Image.open(p).convert("RGBA") if os.path.exists(p) else None


def geser_rona(im, rona, sat=1.0, terang=1.0):
	"""Recolor: putar rona menuju target DENGAN WRAP (0.0 dan 1.0 bertetangga)."""
	out = im.copy()
	px = out.load()
	for y in range(out.height):
		for x in range(out.width):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			h_, l_, s_ = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
			dlt = (h_ - rona + 0.5) % 1.0 - 0.5        # selisih terpendek melingkar
			h2 = (rona + dlt * 0.15) % 1.0             # 85% menuju target
			l2 = min(1.0, l_ * terang)
			s2 = min(1.0, max(s_ * sat, 0.30 if s_ > 0.08 else s_ * 0.6))
			r2, g2, b2 = colorsys.hls_to_rgb(h2, l2, s2)
			px[x, y] = (int(r2 * 255), int(g2 * 255), int(b2 * 255), a)
	return out


def pudar(im, kadar=0.6):
	out = im.copy()
	px = out.load()
	for y in range(out.height):
		for x in range(out.width):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			abu = (r + g + b) // 3
			px[x, y] = (int(r + (abu - r) * kadar), int(g + (abu - g) * kadar),
				int(b + (abu - b) * kadar), a)
	return out


def tempel(base, im, pos, skala=1.0):
	if im is None:
		return
	if skala != 1.0:
		im = im.resize((int(im.width * skala), int(im.height * skala)), Image.NEAREST)
	base.alpha_composite(im, (int(pos[0] - im.width / 2), int(pos[1] - im.height)))


def icing(d, x0, y0, x1, r=6):
	"""Scallop icing — DIGAMBAR SENDIRI."""
	for x in range(x0, x1 - r, r * 2 + 2):
		d.ellipse([x, y0 - r // 2, x + r * 2, y0 + r + 2], fill=(250, 246, 238, 255),
			outline=(212, 196, 188, 255))


def main():
	im = Image.new("RGBA", (W, H + 70), (16, 20, 34, 255))

	# ── TANAH ──
	ga = buka("tiles/candyveil/candy_grass_a_16.png")
	gb = buka("tiles/candyveil/candy_grass_b_16.png")
	jl = buka("tiles/candyveil/candy_path_16.png")
	for ty in range(26):
		for tx in range(40):
			im.alpha_composite(ga if (tx * 7 + ty * 13) % 3 else gb, (tx * T, ty * T))
	for tx in range(40):
		for ty in (12, 13):
			im.alpha_composite(jl, (tx * T, ty * T))
	for tx in range(15, 25):
		for ty in range(9, 17):
			im.alpha_composite(jl, (tx * T, ty * T))
	for tx in range(33, 40):   # gradasi pudar timur (K3)
		ov = Image.new("RGBA", (T, H), (120, 116, 122, int(60 * (tx - 32) / 9.0 + 30)))
		im.alpha_composite(ov, (tx * T, 0))

	d = ImageDraw.Draw(im, "RGBA")

	# ── RUMAH JAMUR FROSTING (CC0, sel 64x64) ──
	sheet = buka(JAMUR)
	def jamur(kol, bar, rona, sat=1.2):
		rm = sheet.crop((kol * 64, bar * 64, kol * 64 + 64, bar * 64 + 64))
		return geser_rona(rm, rona, sat, 1.05)

	tempel(im, jamur(1, 0, 0.45), (13 * T, 8 * T), 2.0)     # mint
	tempel(im, jamur(2, 0, 0.12), (30 * T, 9 * T), 2.2)     # lemon
	tempel(im, jamur(0, 1, 0.80), (4 * T, 16 * T), 2.0)     # blueberry
	tempel(im, jamur(1, 1, 0.99), (31 * T, 20 * T), 1.9)    # ceri
	tempel(im, jamur(2, 1, 0.06), (9 * T, 23 * T), 1.7)     # jeruk
	tempel(im, jamur(0, 2, 0.93), (30 * T, 24 * T), 1.7)    # gulali
	# pinggiran timur: frosting yang kehilangan warna
	tempel(im, pudar(jamur(1, 2, 0.9, 0.55)), (37 * T, 11 * T), 1.9)
	tempel(im, pudar(jamur(2, 2, 0.9, 0.5), 0.72), (37 * T, 21 * T), 1.7)

	# ── BALAI GULA & KEDAI COKELAT = keluarga jamur juga (revisi mata:
	# konstruksi bata bolong dibuang; kota peri = SEMUA cendawan) ──
	tempel(im, jamur(0, 0, 0.97, 1.3), (10 * T, 11 * T), 3.4)   # BALAI — jamur stroberi raksasa
	tempel(im, jamur(1, 3, 0.07, 0.85), (25 * T, 21 * T), 2.6)  # KEDAI — jamur cokelat susu
	cok = buka("milkchocolate.png", CANDY)

	# ── MENARA LONCENG PERMEN (candy cane LPC Candy) ──
	cane = buka("cancycane.png", CANDY)
	batang = cane.crop((0, 64, 32, 96))
	for kx in (19 * T - 8, 20 * T + 4, 21 * T + 16):
		for seg in range(9):
			im.alpha_composite(batang, (kx, 2 * T + 8 + seg * 32))
	d = ImageDraw.Draw(im, "RGBA")
	d.polygon([(18 * T - 12, 2 * T + 10), (20 * T + 4, T - 6), (22 * T + 20, 2 * T + 10)],
		fill=(238, 120, 150, 255), outline=(150, 60, 90, 255))
	icing(d, 18 * T - 8, 2 * T + 6, 22 * T + 16, 5)
	d.ellipse([20 * T - 10, T + 18, 20 * T + 18, T + 46], fill=(244, 197, 66, 255),
		outline=(150, 110, 30, 255))

	# ── AIR MANCUR SIRUP ──
	tempel(im, geser_rona(buka("sprites/lpc32/fountain.png"), 0.07, 1.3, 1.05),
		(20 * T, 14 * T + 10), 1.4)

	# ── PROPS + PENGHUNI ──
	tc = buka("sprites/props/tree_candy.png")
	lp = buka("sprites/props/lollipop.png")
	cc = buka("sprites/props/candy_cane.png")
	gd = buka("sprites/props/gumdrop.png")
	for pos in [(2 * T, 7 * T), (16 * T, 5 * T), (26 * T, 6 * T), (34 * T, 17 * T), (2 * T, 21 * T)]:
		tempel(im, tc, pos, 2.0)
	for pos in [(7 * T, 12 * T), (26 * T, 16 * T), (13 * T, 18 * T), (17 * T, 22 * T)]:
		tempel(im, lp, pos, 2.0)
	for pos in [(15 * T, 10 * T), (24 * T, 8 * T)]:
		tempel(im, cc, pos, 2.0)
	for pos in [(18 * T, 16 * T), (22 * T, 11 * T), (6 * T, 21 * T), (29 * T, 14 * T)]:
		tempel(im, gd, pos, 2.0)
	bear = buka("bear.png", CANDY)
	for i, pos in enumerate([(17 * T, 15 * T), (23 * T, 16 * T), (28 * T, 12 * T), (11 * T, 14 * T)]):
		satu = bear.crop(((i % 5) * 3 * 32 + 32, 0, (i % 5) * 3 * 32 + 64, 64))
		tempel(im, satu, pos, 1.0)

	# ── judul + keterangan ──
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, W, 40], fill=(26, 33, 56, 235))
	d.text((14, 6), "MOCKUP FINAL v2 - KOTA PERMEN-PERI Candyveil (aset sungguhan, 40x26 petak @32px)",
		font=f(24), fill=(244, 197, 66))
	d.rectangle([0, H, W, H + 70], fill=(26, 33, 56, 255))
	d.text((14, H + 6),
		"ASLI: rumah jamur CC0 (AntumDeluge) recolor frosting - LPC Candy CC0 (menara cane, bata cokelat, gummy) - ubin & props permen repo",
		font=f(15), fill=(228, 232, 245))
	d.text((14, H + 28),
		"GAMBAR SENDIRI: kerucut+lonceng+icing menara, recolor frosting jamur & sirup, gradasi pudar - lainnya aset CC0/repo apa adanya",
		font=f(15), fill=(150, 156, 178))
	d.text((14, H + 48),
		"Tone lepas dari Ashbrook (putusan Direktur): cottage peri, bukan kota menjulang - timur tetap memudar (K3)",
		font=f(15), fill=(150, 156, 178))

	im.convert("RGB").save(os.path.join(MOCK, "candyveil_final.png"))
	print("-> reports/mockup/candyveil_final.png")


if __name__ == "__main__":
	main()
