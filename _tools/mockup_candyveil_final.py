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


def tempel(base, im, pos, skala=1.0, bayang=True):
	if im is None:
		return
	if skala != 1.0:
		im = im.resize((int(im.width * skala), int(im.height * skala)), Image.NEAREST)
	if bayang:
		db = ImageDraw.Draw(base, "RGBA")
		w = im.width
		db.ellipse([pos[0] - w * 0.42, pos[1] - w * 0.16, pos[0] + w * 0.42, pos[1] + w * 0.10],
			fill=(40, 16, 40, 70))
	base.alpha_composite(im, (int(pos[0] - im.width / 2), int(pos[1] - im.height)))


def icing(d, x0, y0, x1, r=6):
	"""Scallop icing — DIGAMBAR SENDIRI."""
	for x in range(x0, x1 - r, r * 2 + 2):
		d.ellipse([x, y0 - r // 2, x + r * 2, y0 + r + 2], fill=(250, 246, 238, 255),
			outline=(212, 196, 188, 255))


def main():
	im = Image.new("RGBA", (W, H + 70), (16, 20, 34, 255))

	# ── TANAH: dunia fantasi, bukan papan — rumput variatif, jalan BERKELOK,
	# sungai soda (ubin repo), bunga, dan hutan permen yang MEMELUK lembah ──
	import math
	import random
	rng = random.Random(20260727)
	ga = buka("tiles/candyveil/candy_grass_a_16.png")
	gb = buka("tiles/candyveil/candy_grass_b_16.png")
	jl = buka("tiles/candyveil/candy_path_16.png")
	gel = ga.point(lambda v: int(v * 0.90))
	for ty in range(26):
		for tx in range(40):
			r = (tx * 7 + ty * 13 + (tx * ty) % 5) % 7
			tile = ga if r < 3 else (gb if r < 5 else gel)
			im.alpha_composite(tile, (tx * T, ty * T))
	def jalur_yf(tx):
		return (12.8 + 2.0 * math.sin(tx / 5.2) + 0.7 * math.sin(tx / 2.3)) * T
	def jalur_y(tx):
		return int(jalur_yf(tx) / T)
	dj0 = ImageDraw.Draw(im, "RGBA")
	titik = [(tx * T // 2 * 2, jalur_yf(tx / 1.0)) for tx in range(0, 41)]
	titik = [(tx * T, jalur_yf(tx)) for tx in range(0, 41)]
	dj0.line(titik, fill=(150, 100, 52, 255), width=62, joint="curve")
	dj0.line(titik, fill=(212, 164, 96, 255), width=52, joint="curve")
	dj0.line(titik, fill=(226, 182, 116, 255), width=40, joint="curve")
	for tx in range(15, 25):
		for ty in range(9, 17):
			if (tx - 19.5) ** 2 / 25 + (ty - 13) ** 2 / 13 <= 1.6:
				im.alpha_composite(jl, (tx * T, ty * T))
	# SUNGAI SODA barat + jembatan wafer (jembatan digambar sendiri)
	so1 = geser_rona(buka("tiles/candyveil/candy_soda_f1_16.png").resize((T, T), Image.NEAREST), 0.55, 1.6, 0.95)
	so2 = geser_rona(buka("tiles/candyveil/candy_soda_f2_16.png").resize((T, T), Image.NEAREST), 0.55, 1.6, 0.90)
	dsu = ImageDraw.Draw(im, "RGBA")
	for ty in range(26):
		sx = int(3 + 1.6 * math.sin(ty / 3.0))
		dsu.rectangle([sx * T - 6, ty * T, sx * T - 1, ty * T + T], fill=(150, 90, 130, 255))
		dsu.rectangle([(sx + 2) * T, ty * T, (sx + 2) * T + 5, ty * T + T], fill=(150, 90, 130, 255))
		for k in range(2):
			im.alpha_composite(so1 if (ty + k) % 2 else so2, ((sx + k) * T, ty * T))
		if ty % 3 == 0:
			dsu.line([(sx * T + 8, ty * T + 10), (sx * T + 20, ty * T + 10)], fill=(255, 255, 255, 170))
	dj = ImageDraw.Draw(im, "RGBA")
	yb = jalur_y(4) * T
	dj.rectangle([2 * T + 8, yb - 6, 6 * T - 8, yb + 2 * T + 6], fill=(168, 108, 62, 255),
		outline=(96, 56, 28, 255))
	for bx in range(2 * T + 12, 6 * T - 12, 12):
		dj.line([(bx, yb - 4), (bx, yb + 2 * T + 4)], fill=(120, 72, 38, 255))
	# bunga gula, semak gummy, batu mint (aset repo)
	bp = buka("sprites/props/flower_pink.png")
	bb = buka("sprites/props/flower_blue.png")
	sg = buka("tiles/candyveil/candy_gummy_bush_16.png").resize((T, T), Image.NEAREST)
	mr = buka("tiles/candyveil/candy_mint_rock_16.png").resize((T, T), Image.NEAREST)
	for _ in range(26):
		fx, fy = rng.randrange(6, 38), rng.randrange(4, 24)
		tempel(im, bp if rng.random() < 0.5 else bb, (fx * T + rng.randrange(-8, 8), fy * T), 1.0, bayang=False)
	for _ in range(10):
		im.alpha_composite(sg, (rng.randrange(7, 38) * T, rng.randrange(4, 24) * T))
	for _ in range(6):
		im.alpha_composite(mr, (rng.randrange(7, 36) * T, rng.randrange(5, 23) * T))
	# HUTAN PERMEN memeluk lembah
	tc0 = buka("sprites/props/tree_candy.png")
	tcg = tc0.point(lambda v: int(v * 0.72))
	for tx in range(-1, 41, 2):
		tempel(im, tcg, (tx * T + 16 + rng.randrange(-4, 4), int(3.6 * T) + rng.randrange(-6, 4)), 2.1, bayang=False)
	for tx in range(-1, 41, 2):
		tempel(im, tcg, (tx * T + rng.randrange(-6, 6), int(3.1 * T) + rng.randrange(-6, 4)), 2.4, bayang=False)
	for tx in range(-1, 41, 2):
		tempel(im, tcg, (tx * T + rng.randrange(-6, 6), 27 * T + rng.randrange(-14, 0)), 2.5, bayang=False)
	for tx in range(33, 40):
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

	# ── SENTUHAN DUNIA: pagar, lampu, kawat lampu peri, KILAU, senja ──
	pg = buka("sprites/lpc32/pagar_tiang32.png")
	for fx in range(7 * T, 14 * T, 40):
		tempel(im, pg, (fx, 21 * T + 8), 1.0, bayang=False)
	lt = buka("sprites/lpc32/lentera32.png")
	for pos in [(16 * T, 11 * T), (24 * T, 11 * T), (16 * T, 17 * T), (24 * T, 17 * T)]:
		tempel(im, lt, pos, 1.5, bayang=True)
		d.ellipse([pos[0] - 12, pos[1] - 54, pos[0] + 12, pos[1] - 30], fill=(255, 214, 120, 60))
	def kawat(a, b, warna_daftar):
		import math as _m
		for i2 in range(17):
			s = i2 / 16.0
			x = a[0] + (b[0] - a[0]) * s
			y = a[1] + (b[1] - a[1]) * s + _m.sin(s * _m.pi) * 26
			d.line([(x, y), (x + 1, y)], fill=(80, 60, 70, 160))
			if i2 % 2:
				w2 = warna_daftar[(i2 // 2) % len(warna_daftar)]
				d.ellipse([x - 2, y - 2, x + 3, y + 3], fill=w2 + (235,))
				d.ellipse([x - 5, y - 5, x + 6, y + 6], fill=w2 + (50,))
	warna_peri = [(255, 120, 160), (140, 220, 150), (255, 214, 120), (150, 190, 240)]
	kawat((20 * T + 4, 2 * T + 12), (10 * T, 8 * T - 20), warna_peri)
	kawat((20 * T + 4, 2 * T + 12), (30 * T, 6 * T + 10), warna_peri)
	kawat((10 * T, 8 * T - 20), (4 * T + 8, 13 * T - 30), warna_peri)
	kawat((30 * T, 6 * T + 10), (37 * T, 8 * T), warna_peri)
	for _ in range(46):
		kx2, ky2 = rng.randrange(T, W - T), rng.randrange(2 * T, H - T)
		wv = rng.choice([(255, 240, 200), (255, 190, 225), (190, 240, 255)])
		d.line([(kx2 - 3, ky2), (kx2 + 3, ky2)], fill=wv + (rng.randrange(90, 180),))
		d.line([(kx2, ky2 - 3), (kx2, ky2 + 3)], fill=wv + (rng.randrange(90, 180),))
	for fx, fy, fw in [(14 * T, 10 * T, (255, 190, 225)), (26 * T, 14 * T, (190, 240, 255)),
			(9 * T, 19 * T, (255, 240, 170))]:
		d.ellipse([fx - 10, fy - 10, fx + 10, fy + 10], fill=fw + (36,))
		d.ellipse([fx - 5, fy - 5, fx + 5, fy + 5], fill=fw + (90,))
		d.ellipse([fx - 2, fy - 3, fx + 2, fy + 2], fill=(255, 255, 250, 235))
		d.polygon([(fx - 2, fy - 1), (fx - 7, fy - 5), (fx - 3, fy + 1)], fill=(255, 255, 255, 150))
		d.polygon([(fx + 2, fy - 1), (fx + 7, fy - 5), (fx + 3, fy + 1)], fill=(255, 255, 255, 150))
	warm = Image.new("RGBA", (W, H), (255, 208, 150, 26))
	im.alpha_composite(warm, (0, 0))
	glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
	dg = ImageDraw.Draw(glow)
	for rr, aa in ((470, 0), (380, 10), (290, 18), (200, 26)):
		dg.ellipse([20 * T - rr, 13 * T - rr * 0.72, 20 * T + rr, 13 * T + rr * 0.72],
			fill=(255, 226, 168, aa))
	im.alpha_composite(glow, (0, 0))
	vig = Image.new("RGBA", (W, H), (0, 0, 0, 0))
	dv = ImageDraw.Draw(vig)
	for k2 in range(70):
		dv.rectangle([k2, k2, W - k2, H - k2], outline=(24, 10, 34, min(3, int(k2 * 1.15))))
	im.alpha_composite(vig, (0, 0))

	# ── judul + keterangan ──
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, W, 40], fill=(26, 33, 56, 235))
	d.text((14, 6), "MOCKUP FINAL v3 - LEMBAH PERMEN-PERI Candyveil: dunia fantasi (aset sungguhan, 40x26 petak)",
		font=f(24), fill=(244, 197, 66))
	d.rectangle([0, H, W, H + 70], fill=(26, 33, 56, 255))
	d.text((14, H + 6),
		"ASLI: rumah jamur CC0 (AntumDeluge) recolor frosting - LPC Candy CC0 (menara cane, bata cokelat, gummy) - ubin & props permen repo",
		font=f(15), fill=(228, 232, 245))
	d.text((14, H + 28),
		"GAMBAR SENDIRI: jembatan wafer, kawat lampu peri, peri bercahaya, kilau, senja+vignette, kerucut+lonceng menara, recolor frosting/sirup",
		font=f(15), fill=(150, 156, 178))
	d.text((14, H + 48),
		"DUNIA: hutan permen memeluk lembah - sungai soda + jembatan - jalan berkelok - bayangan + cahaya senja - timur tetap memudar (K3)",
		font=f(15), fill=(150, 156, 178))

	im.convert("RGB").save(os.path.join(MOCK, "candyveil_final.png"))
	print("-> reports/mockup/candyveil_final.png")


if __name__ == "__main__":
	main()
