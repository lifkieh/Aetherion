# -*- coding: utf-8 -*-
"""MOCKUP FINAL v5 CANDYVEIL (#299) — LEMBAH PERMEN-PERI LUAS, aset benar.

Arahan Direktur v5: "pertahankan; perbesar kotanya, perluas, perbanyak aset,
perkaya variasi rumah & dekorasi." Kanvas 56x36 petak @32 px (1792x1152).

ASET:
  * 12 rumah/bangunan permen + 3 dekor — gen_rumah_permen.py (DIGAMBAR SENDIRI)
  * rumah jamur CC0 (AntumDeluge) recolor frosting — aksen peri
  * LPC Candy CC0 (Mark Weyer): menara candy cane, gummy bear penghuni
  * ubin candy32, props permen, bunga, pagar, lentera — repo
DIGAMBAR SENDIRI selain rumah: jembatan wafer, kawat lampu peri, peri,
kilau, senja+vignette, recolor frosting/soda/sirup.
"""
import colorsys
import math
import os
import random
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
G = os.path.join(ROOT, "game", "assets", "game")
CANDY = os.path.join(ROOT, "assets_raw", "oga", "candy", "lpc_candy")
JAMUR = os.path.join(ROOT, "assets_raw", "oga", "candy", "mushroom_houses",
	"PNG", "64x64", "mushroom_houses-RGB.png")
PERMEN = os.path.join(MOCK, "aset_permen")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")
T = 32
TW, TH = 56, 36
W, H = TW * T, TH * T
rng = random.Random(20260727)


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def buka(rel, root=G):
	p = rel if os.path.isabs(rel) else os.path.join(root, rel)
	return Image.open(p).convert("RGBA") if os.path.exists(p) else None


def permen(nama):
	return buka(os.path.join(PERMEN, nama + ".png"))


def geser_rona(im, rona, sat=1.0, terang=1.0):
	out = im.copy()
	px = out.load()
	for y in range(out.height):
		for x in range(out.width):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			h_, l_, s_ = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
			dlt = (h_ - rona + 0.5) % 1.0 - 0.5
			h2 = (rona + dlt * 0.15) % 1.0
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
		db.ellipse([pos[0] - w * 0.42, pos[1] - w * 0.14, pos[0] + w * 0.42, pos[1] + w * 0.09],
			fill=(40, 16, 40, 70))
	base.alpha_composite(im, (int(pos[0] - im.width / 2), int(pos[1] - im.height)))


def icing(d, x0, y0, x1, r=6):
	for x in range(x0, x1 - r, r * 2 + 2):
		d.ellipse([x, y0 - r // 2, x + r * 2, y0 + r + 2], fill=(250, 246, 238, 255),
			outline=(214, 200, 190, 255))


def jalur_yf(tx):
	return (18.5 + 3.0 * math.sin(tx / 7.0) + 0.9 * math.sin(tx / 2.9)) * T


def main():
	im = Image.new("RGBA", (W, H + 70), (16, 20, 34, 255))

	# ── TANAH: rumput 3 varian ──
	ga = buka("tiles/candyveil/candy_grass_a_16.png")
	gb = buka("tiles/candyveil/candy_grass_b_16.png")
	jl = buka("tiles/candyveil/candy_path_16.png")
	gel = ga.point(lambda v: int(v * 0.90))
	for ty in range(TH):
		for tx in range(TW):
			r = (tx * 7 + ty * 13 + (tx * ty) % 5) % 7
			im.alpha_composite(ga if r < 3 else (gb if r < 5 else gel), (tx * T, ty * T))

	# ── JALAN KARAMEL berkelok + cabang pasar & selatan ──
	dj = ImageDraw.Draw(im, "RGBA")
	titik = [(tx * T, jalur_yf(tx)) for tx in range(0, TW + 1)]
	for wd, wr in ((62, (150, 100, 52, 255)), (52, (212, 164, 96, 255)), (40, (226, 182, 116, 255))):
		dj.line(titik, fill=wr, width=wd, joint="curve")
	cab = [(38 * T, jalur_yf(38)), (40 * T, 13 * T), (43 * T, 11 * T)]      # ke pasar
	cab2 = [(20 * T, jalur_yf(20)), (20 * T, 27 * T), (18 * T, 31 * T)]      # ke selatan/hutan
	for jalur in (cab, cab2):
		for wd, wr in ((44, (150, 100, 52, 255)), (34, (212, 164, 96, 255)), (26, (226, 182, 116, 255))):
			dj.line(jalur, fill=wr, width=wd, joint="curve")

	# ── PLAZA KARAMEL oval + air mancur ──
	for tx in range(22, 34):
		for ty in range(12, 21):
			if (tx - 27.5) ** 2 / 34 + (ty - 16.2) ** 2 / 17 <= 1.5:
				im.alpha_composite(jl, (tx * T, ty * T))

	# ── SUNGAI SODA barat + jembatan wafer ──
	so1 = geser_rona(buka("tiles/candyveil/candy_soda_f1_16.png").resize((T, T), Image.NEAREST), 0.55, 1.6, 0.95)
	so2 = geser_rona(buka("tiles/candyveil/candy_soda_f2_16.png").resize((T, T), Image.NEAREST), 0.55, 1.6, 0.90)
	dsu = ImageDraw.Draw(im, "RGBA")
	for ty in range(TH):
		sx = int(4 + 1.8 * math.sin(ty / 3.4))
		for k in range(2):
			im.alpha_composite(so1 if (ty + k) % 2 else so2, ((sx + k) * T, ty * T))
		if ty % 3 == 0:
			dsu.line([(sx * T + 8, ty * T + 10), (sx * T + 22, ty * T + 10)], fill=(255, 255, 255, 170))
	yb = int(jalur_yf(5))
	dsu.rectangle([3 * T + 4, yb - 34, 8 * T - 4, yb + 30], fill=(168, 108, 62, 255),
		outline=(96, 56, 28, 255))
	for bx in range(3 * T + 10, 8 * T - 10, 12):
		dsu.line([(bx, yb - 30), (bx, yb + 26)], fill=(120, 72, 38, 255))

	# ── dekor tanah: bunga, semak gummy, batu mint, permen mint ──
	bp = buka("sprites/props/flower_pink.png")
	bb = buka("sprites/props/flower_blue.png")
	sg = buka("tiles/candyveil/candy_gummy_bush_16.png").resize((T, T), Image.NEAREST)
	mr = buka("tiles/candyveil/candy_mint_rock_16.png").resize((T, T), Image.NEAREST)
	for _ in range(42):
		tempel(im, bp if rng.random() < 0.5 else bb,
			(rng.randrange(8, TW - 2) * T, rng.randrange(5, TH - 3) * T), 1.0, bayang=False)
	for _ in range(16):
		im.alpha_composite(sg, (rng.randrange(9, TW - 2) * T, rng.randrange(6, TH - 4) * T))
	for _ in range(9):
		im.alpha_composite(mr, (rng.randrange(9, TW - 3) * T, rng.randrange(6, TH - 4) * T))

	# ── HUTAN LOLIPOP memeluk lembah (utara 2 baris, selatan, timur tipis) ──
	tc0 = buka("sprites/props/tree_candy.png")
	tcg = tc0.point(lambda v: int(v * 0.72))
	for tx in range(-1, TW + 1, 2):
		tempel(im, tcg, (tx * T + 16 + rng.randrange(-4, 4), int(3.4 * T) + rng.randrange(-6, 4)), 2.1, bayang=False)
	for tx in range(-1, TW + 1, 2):
		tempel(im, tcg, (tx * T + rng.randrange(-6, 6), int(2.9 * T) + rng.randrange(-6, 4)), 2.4, bayang=False)
	for tx in range(-1, TW + 1, 2):
		tempel(im, tcg, (tx * T + rng.randrange(-6, 6), (TH + 1) * T + rng.randrange(-14, 0)), 2.5, bayang=False)
	for ty in range(4, TH, 3):
		tempel(im, tcg, ((TW - 1) * T + rng.randrange(-8, 8), ty * T), 2.2, bayang=False)

	# gradasi pudar timur (K3)
	for tx in range(TW - 9, TW):
		ov = Image.new("RGBA", (T, H), (120, 116, 122, int(60 * (tx - (TW - 10)) / 11.0 + 28)))
		im.alpha_composite(ov, (tx * T, 0))

	d = ImageDraw.Draw(im, "RGBA")

	# ── BANGUNAN ──
	sheet = buka(JAMUR)
	def jamur(kol, bar, rona, sat=1.2):
		rm = sheet.crop((kol * 64, bar * 64, kol * 64 + 64, bar * 64 + 64))
		return geser_rona(rm, rona, sat, 1.05)

	# landmark utara: KASTIL GULA (istana peri kota)
	tempel(im, permen("kastil_gula"), (27 * T, 10 * T), 1.5)
	# menara lonceng candy cane di sisi kastil
	cane = buka("cancycane.png", CANDY)
	batang = cane.crop((0, 64, 32, 96))
	for kx in (34 * T - 8, 35 * T + 4):
		for seg in range(7):
			im.alpha_composite(batang, (kx, 4 * T + 8 + seg * 32))
	d.polygon([(33 * T - 6, 4 * T + 12), (34 * T + 14, 3 * T - 2), (36 * T + 2, 4 * T + 12)],
		fill=(238, 120, 150, 255), outline=(150, 60, 90, 255))
	icing(d, 33 * T - 2, 4 * T + 8, 36 * T - 2, 5)
	d.ellipse([34 * T + 2, 3 * T + 16, 34 * T + 26, 4 * T + 8], fill=(244, 197, 66, 255),
		outline=(150, 110, 30, 255))

	tempel(im, permen("roti_jahe"), (14 * T, 11 * T), 1.5)       # Balai Gula
	tempel(im, permen("wafel"), (41 * T, 8 * T), 1.35)           # Penginapan Wafel
	tempel(im, permen("es_krim"), (33 * T, 24 * T), 1.3)         # Kedai Es Krim
	tempel(im, permen("kue_tart"), (9 * T, 20 * T), 1.25)        # Toko Sirup (tepi sungai)
	tempel(im, permen("kincir"), (8 * T, 8 * T), 1.35)           # Kincir permen dekat sungai
	tempel(im, permen("cokelat_batang"), (22 * T, 25 * T), 1.25) # Kedai Cokelat
	tempel(im, permen("toples"), (37 * T, 15 * T), 1.15)         # Toko Toples Permen
	tempel(im, permen("permen_karet"), (17 * T, 15 * T), 1.15)   # Rumah Gumball
	tempel(im, permen("makaron"), (13 * T, 26 * T), 1.2)         # Rumah Makaron
	tempel(im, permen("kue_mangkuk"), (19 * T, 7 * T), 1.15)     # cupcake utara
	tempel(im, permen("kue_mangkuk"), (28 * T, 27 * T), 1.0)     # cupcake selatan
	tempel(im, permen("donat"), (44 * T, 20 * T), 1.15)          # donat timur
	tempel(im, jamur(1, 1, 0.99), (23 * T, 6 * T), 1.6)          # jamur ceri — aksen
	tempel(im, jamur(1, 3, 0.07, 0.85), (11 * T, 15 * T), 1.4)   # jamur cokelat — aksen
	tempel(im, jamur(0, 1, 0.80), (39 * T, 27 * T), 1.5)         # jamur blueberry — aksen

	# pinggiran timur: yang kehilangan warna
	tempel(im, pudar(permen("donat"), 0.72), (51 * T, 12 * T), 1.05)
	tempel(im, pudar(jamur(1, 2, 0.9, 0.55)), (52 * T, 19 * T), 1.8)
	tempel(im, pudar(permen("kue_mangkuk"), 0.75), (50 * T, 26 * T), 1.0)

	# ── PASAR PERMEN (3 kios) timur-laut plaza ──
	for kpos in [(42 * T, 12 * T), (45 * T, 14 * T), (42 * T + 16, 16 * T)]:
		tempel(im, permen("kios_permen"), kpos, 1.1)

	# ── GAPURA masuk barat & timur ──
	tempel(im, permen("gapura"), (10 * T, int(jalur_yf(10)) + 22), 1.15, bayang=False)
	tempel(im, permen("gapura"), (47 * T, int(jalur_yf(47)) + 22), 1.1, bayang=False)

	# ── AIR MANCUR SIRUP ──
	tempel(im, geser_rona(buka("sprites/lpc32/fountain.png"), 0.07, 1.3, 1.05),
		(27 * T + 16, 17 * T), 1.5)

	# ── lampu lolipop sepanjang jalan + lentera plaza ──
	for lx in range(8, TW - 6, 6):
		yy = jalur_yf(lx)
		tempel(im, permen("lampu_lolipop"), (lx * T, int(yy) - 40), 1.0)
		d.ellipse([lx * T - 10, int(yy) - 96, lx * T + 10, int(yy) - 76], fill=(255, 190, 225, 45))
	lt = buka("sprites/lpc32/lentera32.png")
	for pos in [(23 * T, 14 * T), (32 * T, 14 * T), (23 * T, 20 * T), (32 * T, 20 * T)]:
		tempel(im, lt, pos, 1.5)
		d.ellipse([pos[0] - 12, pos[1] - 54, pos[0] + 12, pos[1] - 30], fill=(255, 214, 120, 60))

	# ── pagar & props permen ──
	pg = buka("sprites/lpc32/pagar_tiang32.png")
	for fx in range(12 * T, 17 * T, 40):
		tempel(im, pg, (fx, 12 * T + 8), 1.0, bayang=False)
	lp = buka("sprites/props/lollipop.png")
	cc = buka("sprites/props/candy_cane.png")
	gd = buka("sprites/props/gumdrop.png")
	for pos in [(12 * T, 17 * T), (35 * T, 21 * T), (18 * T, 23 * T), (25 * T, 8 * T), (46 * T, 24 * T)]:
		tempel(im, lp, pos, 2.0)
	for pos in [(21 * T, 11 * T), (31 * T, 9 * T), (40 * T, 22 * T)]:
		tempel(im, cc, pos, 2.0)
	for pos in [(24 * T, 21 * T), (30 * T, 15 * T), (10 * T, 24 * T), (36 * T, 12 * T), (15 * T, 19 * T)]:
		tempel(im, gd, pos, 2.0)

	# ── penghuni gummy + peri ──
	bear = buka("bear.png", CANDY)
	for i, pos in enumerate([(24 * T, 17 * T), (30 * T, 18 * T), (36 * T, 14 * T),
			(16 * T, 13 * T), (27 * T, 22 * T), (43 * T, 13 * T)]):
		satu = bear.crop(((i % 7) * 3 * 32 + 32, 0, (i % 7) * 3 * 32 + 64, 64))
		tempel(im, satu, pos, 1.0)

	def kawat(a, b, warna_daftar):
		for i2 in range(17):
			s = i2 / 16.0
			x = a[0] + (b[0] - a[0]) * s
			y = a[1] + (b[1] - a[1]) * s + math.sin(s * math.pi) * 26
			d.line([(x, y), (x + 1, y)], fill=(80, 60, 70, 160))
			if i2 % 2:
				w2 = warna_daftar[(i2 // 2) % len(warna_daftar)]
				d.ellipse([x - 2, y - 2, x + 3, y + 3], fill=w2 + (235,))
				d.ellipse([x - 5, y - 5, x + 6, y + 6], fill=w2 + (50,))
	wp = [(255, 120, 160), (140, 220, 150), (255, 214, 120), (150, 190, 240)]
	kawat((27 * T, 6 * T), (14 * T, 8 * T), wp)
	kawat((27 * T, 6 * T), (41 * T, 5 * T), wp)
	kawat((14 * T, 8 * T), (8 * T, 5 * T), wp)
	kawat((34 * T + 12, 3 * T), (37 * T, 12 * T), wp)
	kawat((17 * T, 12 * T), (22 * T, 10 * T), wp)

	for _ in range(64):
		kx2, ky2 = rng.randrange(T, W - T), rng.randrange(3 * T, H - T)
		wv = rng.choice([(255, 240, 200), (255, 190, 225), (190, 240, 255)])
		d.line([(kx2 - 3, ky2), (kx2 + 3, ky2)], fill=wv + (rng.randrange(90, 180),))
		d.line([(kx2, ky2 - 3), (kx2, ky2 + 3)], fill=wv + (rng.randrange(90, 180),))
	for fx, fy, fw in [(20 * T, 13 * T, (255, 190, 225)), (33 * T, 19 * T, (190, 240, 255)),
			(12 * T, 22 * T, (255, 240, 170)), (44 * T, 9 * T, (200, 255, 210))]:
		d.ellipse([fx - 10, fy - 10, fx + 10, fy + 10], fill=fw + (36,))
		d.ellipse([fx - 5, fy - 5, fx + 5, fy + 5], fill=fw + (90,))
		d.ellipse([fx - 2, fy - 3, fx + 2, fy + 2], fill=(255, 255, 250, 235))
		d.polygon([(fx - 2, fy - 1), (fx - 7, fy - 5), (fx - 3, fy + 1)], fill=(255, 255, 255, 150))
		d.polygon([(fx + 2, fy - 1), (fx + 7, fy - 5), (fx + 3, fy + 1)], fill=(255, 255, 255, 150))

	# ── senja + vignette ──
	im.alpha_composite(Image.new("RGBA", (W, H), (255, 208, 150, 26)), (0, 0))
	glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
	dg = ImageDraw.Draw(glow)
	for rr2, aa in ((640, 0), (520, 10), (400, 18), (280, 26)):
		dg.ellipse([27 * T - rr2, 16 * T - rr2 * 0.72, 27 * T + rr2, 16 * T + rr2 * 0.72],
			fill=(255, 226, 168, aa))
	im.alpha_composite(glow, (0, 0))
	vig = Image.new("RGBA", (W, H), (0, 0, 0, 0))
	dv = ImageDraw.Draw(vig)
	for k2 in range(80):
		dv.rectangle([k2, k2, W - k2, H - k2], outline=(24, 10, 34, min(3, int(k2 * 1.1))))
	im.alpha_composite(vig, (0, 0))

	# ── judul + keterangan ──
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, W, 40], fill=(26, 33, 56, 235))
	d.text((14, 6), "MOCKUP FINAL v5 - LEMBAH PERMEN-PERI Candyveil DIPERLUAS (56x36 petak, 15 bangunan + pasar)",
		font=f(24), fill=(244, 197, 66))
	d.rectangle([0, H, W, H + 70], fill=(26, 33, 56, 255))
	d.text((14, H + 6),
		"12 bangunan permen + kios/lampu/gapura = gen_rumah_permen.py (GAMBAR SENDIRI) - jamur CC0 aksen - LPC Candy CC0 (menara, gummy) - ubin/props repo",
		font=f(15), fill=(228, 232, 245))
	d.text((14, H + 28),
		"BARU v5: KASTIL GULA (landmark) - kincir bilah candy cane - pasar 3 kios - lampu lolipop sepanjang jalan - gapura barat/timur - toples, gumball, makaron, cokelat batang",
		font=f(15), fill=(150, 156, 178))
	d.text((14, H + 48),
		"DUNIA: hutan lolipop 3 sisi - sungai soda + jembatan - jalan karamel bercabang (pasar & selatan) - senja + kawat peri - timur memudar (K3)",
		font=f(15), fill=(150, 156, 178))

	im.convert("RGB").save(os.path.join(MOCK, "candyveil_final.png"))
	print("-> reports/mockup/candyveil_final.png (%dx%d)" % (W, H + 70))


if __name__ == "__main__":
	main()
