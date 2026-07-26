# -*- coding: utf-8 -*-
"""MOCKUP FINAL v6 CANDYVEIL (#299) — KOTA PERMEN-PERI TERTATA, 64x40 petak.

Arahan Direktur v6: aset ACC; "mockup dirapikan — di dalam game jangan
berantakan penempatannya" + perluas kota.

TATA KOTA (bukan taburan):
  * BOULEVARD GULA lurus barat-timur (y 20-21) + JALAN SILANG utara-selatan
    (x 31-32) + SPUR PASAR (y 15, x 41-54) — grid jelas
  * POROS UTARA: kastil gula di ujung jalan silang, diapit dua menara candy
    cane SIMETRIS + barisan bendera
  * CINCIN PLAZA: 4 toko menghadap plaza (balai, toples, es krim, cokelat)
  * DISTRIK HUNIAN BARAT (2 baris sejajar) - PASAR TIMUR (kios grid 2x2)
  * HUNIAN SELATAN sejajar - PINGGIRAN PUDAR di ujung timur
  * tiap bangunan: SETAPAK dari pintu ke jalan + lampu lolipop berjarak tetap
Aset: gen_rumah_permen.py (ACC) + jamur CC0 aksen + LPC Candy + repo.
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
TW, TH = 64, 40
W, H = TW * T, TH * T
JY = 20            # baris boulevard (y 20-21)
JX = 31            # kolom jalan silang (x 31-32)
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


def main():
	im = Image.new("RGBA", (W, H + 70), (16, 20, 34, 255))

	# ── TANAH ──
	ga = buka("tiles/candyveil/candy_grass_a_16.png")
	gb = buka("tiles/candyveil/candy_grass_b_16.png")
	jl = buka("tiles/candyveil/candy_path_16.png")
	gel = ga.point(lambda v: int(v * 0.90))
	for ty in range(TH):
		for tx in range(TW):
			r = (tx * 7 + ty * 13 + (tx * ty) % 5) % 7
			im.alpha_composite(ga if r < 3 else (gb if r < 5 else gel), (tx * T, ty * T))

	# ── SUNGAI SODA barat (kolom tetap x4-5) + tanggul ──
	so1 = geser_rona(buka("tiles/candyveil/candy_soda_f1_16.png").resize((T, T), Image.NEAREST), 0.55, 1.6, 0.95)
	so2 = geser_rona(buka("tiles/candyveil/candy_soda_f2_16.png").resize((T, T), Image.NEAREST), 0.55, 1.6, 0.90)
	dsu = ImageDraw.Draw(im, "RGBA")
	for ty in range(TH):
		for k in range(2):
			im.alpha_composite(so1 if (ty + k) % 2 else so2, ((4 + k) * T, ty * T))
		if ty % 3 == 0:
			dsu.line([(4 * T + 8, ty * T + 10), (4 * T + 22, ty * T + 10)], fill=(255, 255, 255, 170))

	# ── JALAN: boulevard + silang + spur pasar (LURUS, grid) ──
	for tx in range(TW):
		for ty in (JY, JY + 1):
			im.alpha_composite(jl, (tx * T, ty * T))
	for ty in range(9, 37):
		for tx in (JX, JX + 1):
			im.alpha_composite(jl, (tx * T, ty * T))
	for tx in range(JX, 55):
		im.alpha_composite(jl, (tx * T, 15 * T))
	# tepi jalan (garis karamel gelap rapi)
	dj = ImageDraw.Draw(im, "RGBA")
	dj.line([(0, JY * T - 1), (W, JY * T - 1)], fill=(150, 100, 52, 255), width=2)
	dj.line([(0, (JY + 2) * T), (W, (JY + 2) * T)], fill=(150, 100, 52, 255), width=2)
	dj.line([(JX * T - 1, 9 * T), (JX * T - 1, 37 * T)], fill=(150, 100, 52, 255), width=2)
	dj.line([((JX + 2) * T, 9 * T), ((JX + 2) * T, 37 * T)], fill=(150, 100, 52, 255), width=2)
	dj.line([(JX * T, 15 * T - 1), (55 * T, 15 * T - 1)], fill=(150, 100, 52, 255), width=2)
	dj.line([(JX * T, 16 * T), (55 * T, 16 * T)], fill=(150, 100, 52, 255), width=2)

	# jembatan wafer di sungai (selebar boulevard)
	dsu.rectangle([3 * T + 2, JY * T - 6, 6 * T + 30, (JY + 2) * T + 6],
		fill=(168, 108, 62, 255), outline=(96, 56, 28, 255))
	for bx in range(3 * T + 8, 6 * T + 26, 12):
		dsu.line([(bx, JY * T - 2), (bx, (JY + 2) * T + 2)], fill=(120, 72, 38, 255))

	# ── PLAZA bundar di persilangan ──
	for tx in range(JX - 5, JX + 7):
		for ty in range(JY - 4, JY + 6):
			if (tx - (JX + 0.5)) ** 2 / 30 + (ty - (JY + 0.5)) ** 2 / 20 <= 1.35:
				im.alpha_composite(jl, (tx * T, ty * T))
	dj.ellipse([(JX - 5) * T, (JY - 4) * T, (JX + 7) * T, (JY + 6) * T],
		outline=(150, 100, 52, 255), width=3)

	# ── SETAPAK: SELALU dipanggil SEBELUM rumahnya ditempel (koreksi mata v6:
	# setapak yang digambar belakangan menembus atap) ──
	def setapak(cx, y0, y1):
		dj.rectangle([cx - 7, min(y0, y1), cx + 7, max(y0, y1)], fill=(212, 164, 96, 255),
			outline=(150, 100, 52, 255))

	# ── HUTAN LOLIPOP keliling (jarak tetap = rapi) ──
	tc0 = buka("sprites/props/tree_candy.png")
	tcg = tc0.point(lambda v: int(v * 0.72))
	for tx in range(0, TW + 1, 2):
		tempel(im, tcg, (tx * T + 16, int(3.0 * T)), 2.2, bayang=False)
		tempel(im, tcg, (tx * T, int(2.5 * T)), 2.4, bayang=False)
	for tx in range(0, TW + 1, 2):
		tempel(im, tcg, (tx * T, (TH + 1) * T - 8), 2.5, bayang=False)
	for ty in range(4, TH - 1, 2):
		tempel(im, tcg, ((TW - 1) * T + 8, ty * T), 2.2, bayang=False)
		tempel(im, tcg, (T, ty * T), 2.2, bayang=False)

	# gradasi pudar timur (K3)
	for tx in range(TW - 10, TW):
		ov = Image.new("RGBA", (T, H), (120, 116, 122, int(60 * (tx - (TW - 11)) / 12.0 + 26)))
		im.alpha_composite(ov, (tx * T, 0))

	d = ImageDraw.Draw(im, "RGBA")
	sheet = buka(JAMUR)
	def jamur(kol, bar, rona, sat=1.2):
		rm = sheet.crop((kol * 64, bar * 64, kol * 64 + 64, bar * 64 + 64))
		return geser_rona(rm, rona, sat, 1.05)

	CX = (JX + 1) * T   # sumbu tengah jalan silang

	# (setapak dieksekusi paling akhir bagian jalan — lihat gambar_setapak di bawah)
	# ── POROS UTARA: kastil + dua menara candy cane SIMETRIS ──
	cane = buka("cancycane.png", CANDY)
	batang = cane.crop((0, 64, 32, 96))
	setapak(CX, 9 * T - 6, 10 * T)
	for kx in (CX - 8 * T, CX + 7 * T):
		for seg in range(6):
			im.alpha_composite(batang, (kx, 4 * T + seg * 32))
		d.polygon([(kx - 10, 4 * T + 2), (kx + 16, 3 * T - 6), (kx + 42, 4 * T + 2)],
			fill=(238, 120, 150, 255), outline=(150, 60, 90, 255))
		d.ellipse([kx + 8, 4 * T + 6, kx + 24, 4 * T + 24], fill=(244, 197, 66, 255),
			outline=(150, 110, 30, 255))   # lonceng MENGGANTUNG di bawah kerucut
	tempel(im, permen("kastil_gula"), (CX, 9 * T), 1.6)

	# ── CINCIN PLAZA: 4 toko menghadap plaza ──
	setapak(24 * T, 17 * T, JY * T)
	tempel(im, permen("roti_jahe"), (24 * T, 17 * T), 1.4)     # Balai — barat-laut plaza
	setapak(40 * T, 17 * T, JY * T)
	tempel(im, permen("toples"), (40 * T, 17 * T), 1.2)        # Toples — timur-laut
	tempel(im, permen("cokelat_batang"), (24 * T, 26 * T), 1.25)  # Cokelat — barat-daya
	setapak(24 * T, (JY + 2) * T, 26 * T)
	tempel(im, permen("es_krim"), (40 * T, 27 * T), 1.3)       # Es krim — tenggara
	setapak(40 * T, (JY + 2) * T, 27 * T)

	# ── DISTRIK HUNIAN BARAT: dua baris sejajar (y 15 & y 27) ──
	for hx in (9, 14, 19):
		setapak(hx * T, 15 * T, JY * T)
	tempel(im, permen("kincir"), (9 * T, 15 * T), 1.35)
	tempel(im, permen("makaron"), (14 * T, 15 * T), 1.2)
	tempel(im, permen("permen_karet"), (19 * T, 15 * T), 1.15)
	tempel(im, permen("kue_tart"), (10 * T, 27 * T), 1.25)
	tempel(im, permen("kue_mangkuk"), (15 * T, 27 * T), 1.15)
	tempel(im, jamur(1, 3, 0.07, 0.85), (19 * T + 16, 27 * T), 1.5)
	# gang hunian barat-bawah + konektor tegak ke boulevard (grid, bukan tembus atap)
	dj.rectangle([8 * T, 27 * T + 10, 21 * T, 27 * T + 24], fill=(212, 164, 96, 255),
		outline=(150, 100, 52, 255))
	dj.rectangle([12 * T + 9, (JY + 2) * T, 12 * T + 23, 27 * T + 10], fill=(212, 164, 96, 255),
		outline=(150, 100, 52, 255))
	for hx in (10, 15):
		setapak(hx * T, 27 * T, 27 * T + 10)
	setapak(19 * T + 16, 27 * T, 27 * T + 10)
	# pagar halaman baris selatan-barat (rapi, satu garis)
	pg = buka("sprites/lpc32/pagar_tiang32.png")
	for fx in range(8 * T, 22 * T, 40):
		tempel(im, pg, (fx, 28 * T + 8), 1.0, bayang=False)

	# ── PASAR TIMUR: kios grid 2x2 di spur y15 ──
	for kpos in [(44 * T, 14 * T), (49 * T, 14 * T)]:
		setapak(kpos[0], kpos[1], 15 * T)
		tempel(im, permen("kios_permen"), kpos, 1.1)
	for kpos in [(44 * T, 18 * T + 16), (49 * T, 18 * T + 16)]:
		setapak(kpos[0], 16 * T, kpos[1] - 30)
		tempel(im, permen("kios_permen"), kpos, 1.1)
	setapak(53 * T + 16, 13 * T, 15 * T)
	tempel(im, permen("wafel"), (53 * T + 16, 13 * T), 1.3)     # Penginapan di ujung pasar

	# ── HUNIAN SELATAN: baris sejajar y 32 menghadap jalan silang/boulevard ──
	tempel(im, permen("donat"), (26 * T, 33 * T), 1.15)
	tempel(im, permen("kue_mangkuk"), (37 * T, 33 * T), 1.1)
	tempel(im, jamur(1, 1, 0.99), (42 * T, 33 * T), 1.6)
	for hx2 in (26, 37, 42):
		setapak(hx2 * T, 31 * T + 14, 33 * T - 40)
	dj.rectangle([26 * T - 7, 31 * T, 42 * T + 7, 31 * T + 14], fill=(212, 164, 96, 255),
		outline=(150, 100, 52, 255))   # gang kecil penghubung baris selatan

	# ── PINGGIRAN PUDAR timur (baris rapi juga — kota yang sama, warnanya pergi) ──
	setapak(57 * T, 17 * T, JY * T)
	tempel(im, pudar(permen("donat"), 0.72), (57 * T, 17 * T), 1.05)
	tempel(im, pudar(jamur(1, 2, 0.9, 0.55)), (60 * T, 17 * T + 16), 1.7)
	setapak(57 * T, (JY + 2) * T, 26 * T)
	tempel(im, pudar(permen("kue_mangkuk"), 0.75), (57 * T, 26 * T), 1.0)

	# ── GAPURA: gerbang barat (setelah jembatan) & gerbang pinggiran ──
	tempel(im, permen("gapura"), (8 * T, (JY + 2) * T + 10), 1.2, bayang=False)
	tempel(im, permen("gapura"), (54 * T, (JY + 2) * T + 10), 1.1, bayang=False)

	# ── AIR MANCUR SIRUP di pusat plaza ──
	tempel(im, geser_rona(buka("sprites/lpc32/fountain.png"), 0.07, 1.3, 1.05),
		(CX, (JY + 1) * T + 8), 1.5)

	# ── LAMPU LOLIPOP: berjarak TETAP dua sisi boulevard + jalan silang ──
	for lx in range(10, TW - 6, 5):
		if abs(lx - JX) <= 6:
			continue   # zona plaza pakai lentera
		tempel(im, permen("lampu_lolipop"), (lx * T, JY * T - 6), 1.0)
		tempel(im, permen("lampu_lolipop"), ((lx + 2) * T, (JY + 2) * T + 26), 1.0)
	for ly in range(11, 35, 6):
		if abs(ly - JY) <= 4:
			continue
		tempel(im, permen("lampu_lolipop"), (JX * T - 12, ly * T), 1.0)
		tempel(im, permen("lampu_lolipop"), ((JX + 2) * T + 12, (ly + 3) * T), 1.0)
	lt = buka("sprites/lpc32/lentera32.png")
	for pos in [(CX - 3 * T, JY * T - 24), (CX + 3 * T, JY * T - 24),
			(CX - 3 * T, (JY + 2) * T + 24), (CX + 3 * T, (JY + 2) * T + 24)]:
		tempel(im, lt, pos, 1.5)
		d.ellipse([pos[0] - 12, pos[1] - 54, pos[0] + 12, pos[1] - 30], fill=(255, 214, 120, 60))

	# ── taman kecil: petak bunga SIMETRIS di empat sisi plaza (bukan acak) ──
	bp = buka("sprites/props/flower_pink.png")
	bb = buka("sprites/props/flower_blue.png")
	for sx in (-4, 4):
		for sy in (-3, 4):
			bxp = CX + sx * T
			byp = (JY + 1) * T + sy * T
			for i2, (ox, oy) in enumerate([(-14, 0), (0, -8), (14, 0), (0, 8)]):
				tempel(im, bp if i2 % 2 else bb, (bxp + ox, byp + oy), 1.0, bayang=False)
	# gumdrop menandai empat pintu plaza (simetris)
	gd = buka("sprites/props/gumdrop.png")
	for pos in [(CX - 5 * T, (JY + 1) * T), (CX + 6 * T, (JY + 1) * T),
			(CX, (JY - 4) * T), (CX, (JY + 6) * T)]:
		tempel(im, gd, pos, 2.0)

	# ── penghuni gummy (di plaza & pasar — tempat orang berkumpul) ──
	bear = buka("bear.png", CANDY)
	for i, pos in enumerate([(CX - 2 * T, JY * T + 8), (CX + T, (JY + 1) * T + 20),
			(CX + 2 * T + 16, JY * T - 8), (45 * T, 15 * T + 20), (50 * T, 15 * T + 20),
			(CX - T, 10 * T)]):
		satu = bear.crop(((i % 7) * 3 * 32 + 32, 0, (i % 7) * 3 * 32 + 64, 64))
		tempel(im, satu, pos, 1.0)

	# ── kawat lampu peri: SIMETRIS dari kastil ke dua menara + plaza ──
	def kawat(a, b, warna_daftar):
		for i2 in range(17):
			s = i2 / 16.0
			x = a[0] + (b[0] - a[0]) * s
			y = a[1] + (b[1] - a[1]) * s + math.sin(s * math.pi) * 24
			d.line([(x, y), (x + 1, y)], fill=(80, 60, 70, 160))
			if i2 % 2:
				w2 = warna_daftar[(i2 // 2) % len(warna_daftar)]
				d.ellipse([x - 2, y - 2, x + 3, y + 3], fill=w2 + (235,))
				d.ellipse([x - 5, y - 5, x + 6, y + 6], fill=w2 + (50,))
	wp = [(255, 120, 160), (140, 220, 150), (255, 214, 120), (150, 190, 240)]
	kawat((CX - 7 * T + 16, 3 * T + 20), (CX - 2 * T, 5 * T + 10), wp)
	kawat((CX + 2 * T, 5 * T + 10), (CX + 6 * T + 16, 3 * T + 20), wp)
	kawat((24 * T, 13 * T), (CX - 2 * T, 15 * T), wp)
	kawat((CX + 2 * T, 15 * T), (40 * T, 13 * T + 16), wp)

	# ── debu peri + 4 peri (di taman & pasar) ──
	for _ in range(56):
		kx2, ky2 = rng.randrange(2 * T, W - 2 * T), rng.randrange(4 * T, H - 2 * T)
		wv = rng.choice([(255, 240, 200), (255, 190, 225), (190, 240, 255)])
		d.line([(kx2 - 3, ky2), (kx2 + 3, ky2)], fill=wv + (rng.randrange(90, 170),))
		d.line([(kx2, ky2 - 3), (kx2, ky2 + 3)], fill=wv + (rng.randrange(90, 170),))
	for fx, fy, fw in [(CX - 4 * T, (JY - 3) * T, (255, 190, 225)),
			(CX + 5 * T, (JY + 4) * T, (190, 240, 255)),
			(47 * T, 16 * T, (255, 240, 170)), (12 * T, 18 * T, (200, 255, 210))]:
		d.ellipse([fx - 10, fy - 10, fx + 10, fy + 10], fill=fw + (36,))
		d.ellipse([fx - 5, fy - 5, fx + 5, fy + 5], fill=fw + (90,))
		d.ellipse([fx - 2, fy - 3, fx + 2, fy + 2], fill=(255, 255, 250, 235))
		d.polygon([(fx - 2, fy - 1), (fx - 7, fy - 5), (fx - 3, fy + 1)], fill=(255, 255, 255, 150))
		d.polygon([(fx + 2, fy - 1), (fx + 7, fy - 5), (fx + 3, fy + 1)], fill=(255, 255, 255, 150))

	# ── senja + vignette ──
	im.alpha_composite(Image.new("RGBA", (W, H), (255, 208, 150, 24)), (0, 0))
	glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
	dg = ImageDraw.Draw(glow)
	for rr2, aa in ((760, 0), (620, 9), (470, 16), (320, 24)):
		dg.ellipse([CX - rr2, (JY + 1) * T - rr2 * 0.72, CX + rr2, (JY + 1) * T + rr2 * 0.72],
			fill=(255, 226, 168, aa))
	im.alpha_composite(glow, (0, 0))
	vig = Image.new("RGBA", (W, H), (0, 0, 0, 0))
	dv = ImageDraw.Draw(vig)
	for k2 in range(84):
		dv.rectangle([k2, k2, W - k2, H - k2], outline=(24, 10, 34, min(3, int(k2))))
	im.alpha_composite(vig, (0, 0))

	# ── judul + keterangan ──
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, W, 40], fill=(26, 33, 56, 235))
	d.text((14, 6), "MOCKUP FINAL v6 - KOTA PERMEN-PERI TERTATA (64x40 petak) - boulevard + poros kastil + distrik jelas",
		font=f(24), fill=(244, 197, 66))
	d.rectangle([0, H, W, H + 70], fill=(26, 33, 56, 255))
	d.text((14, H + 6),
		"TATA: boulevard lurus + jalan silang + spur pasar - kastil di poros utara diapit 2 menara simetris - 4 toko cincin plaza - hunian barat/selatan berbaris - pasar kios 2x2 - pinggiran pudar timur",
		font=f(15), fill=(228, 232, 245))
	d.text((14, H + 28),
		"RAPI: tiap pintu ber-SETAPAK ke jalan - lampu lolipop berjarak tetap dua sisi - taman bunga simetris 4 sisi plaza - pagar satu garis - kawat peri simetris dari kastil",
		font=f(15), fill=(150, 156, 178))
	d.text((14, H + 48),
		"Aset ACC Direktur: 12 bangunan + 3 dekor gambar-sendiri - jamur CC0 aksen - LPC Candy (menara/gummy) - ubin & props repo",
		font=f(15), fill=(150, 156, 178))

	im.convert("RGB").save(os.path.join(MOCK, "candyveil_final.png"))
	print("-> reports/mockup/candyveil_final.png (%dx%d)" % (W, H + 70))


if __name__ == "__main__":
	main()
