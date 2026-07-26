# -*- coding: utf-8 -*-
"""MOCKUP FINAL CANDYVEIL (#299) — potongan kota gula, ASET SUNGGUHAN, skala penuh.

Bukan skema: lukisan 40x26 petak @32 px (1280x832) memakai aset yang benar:
  * ubin candy 32 repo (candy_grass_a/b, candy_path — asli Aetherion)
  * props permen repo (tree_candy, lollipop, candy_cane, gumdrop)
  * LPC Candy (Mark Weyer, CC0): candy cane tileable -> MENARA LONCENG;
    bata cokelat -> dinding Kedai Cokelat; gummy bear -> penghuni
  * fasad repo (LPC Revised OGA-BY) di-RECOLOR permen = pratinjau fasad final
    (aset jadi lewat gen_fasad_candy.py saat eksekusi)
DIGAMBAR SENDIRI di sini (deklarasi): trim icing, kerucut atap menara,
air mancur sirup (recolor fountain), gradasi pudar pinggiran.
"""
import colorsys
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
G = os.path.join(ROOT, "game", "assets", "game")
CANDY = os.path.join(ROOT, "assets_raw", "oga", "candy", "lpc_candy")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")
T = 32
W, H = 40 * T, 26 * T


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def buka(rel, root=G):
	p = os.path.join(root, rel)
	return Image.open(p).convert("RGBA") if os.path.exists(p) else None


def geser_rona(im, rona, sat=1.0, terang=1.0):
	"""Recolor pratinjau: putar rona piksel ke arah `rona` (0..1), jaga tekstur."""
	out = im.copy()
	px = out.load()
	for y in range(out.height):
		for x in range(out.width):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			h_, l_, s_ = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
			h2 = (rona + (h_ - rona) * 0.15) % 1.0  # 85% menuju target — permen tegas
			l2 = min(1.0, l_ * terang)
			s2 = min(1.0, max(s_ * sat, 0.30 if s_ > 0.08 else s_ * 0.6))
			r2, g2, b2 = colorsys.hls_to_rgb(h2, l2, s2)
			px[x, y] = (int(r2 * 255), int(g2 * 255), int(b2 * 255), a)
	return out


def pudar(im, kadar=0.55):
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


def icing(d, x0, y0, x1):
	"""Trim icing gula di tepi atap — DIGAMBAR SENDIRI."""
	for x in range(x0, x1 - 8, 14):
		d.ellipse([x, y0 - 3, x + 12, y0 + 7], fill=(250, 246, 238, 255),
			outline=(214, 200, 190, 255))


def main():
	im = Image.new("RGBA", (W, H + 70), (16, 20, 34, 255))
	d = ImageDraw.Draw(im, "RGBA")

	# ── TANAH: ubin candy asli repo ──
	ga = buka("tiles/candyveil/candy_grass_a_16.png")
	gb = buka("tiles/candyveil/candy_grass_b_16.png")
	jl = buka("tiles/candyveil/candy_path_16.png")
	for ty in range(26):
		for tx in range(40):
			t = ga if (tx * 7 + ty * 13) % 3 else gb
			im.alpha_composite(t, (tx * T, ty * T))
	# jalan gula: barat->timur + plaza
	for tx in range(40):
		for ty in (12, 13):
			im.alpha_composite(jl, (tx * T, ty * T))
	for tx in range(15, 25):
		for ty in range(9, 17):
			im.alpha_composite(jl, (tx * T, ty * T))
	# gradasi PUDAR di ujung timur (K3): kota kehilangan gula pelan-pelan
	for tx in range(33, 40):
		kadar = (tx - 32) / 9.0
		ov = Image.new("RGBA", (T, H), (120, 116, 122, int(60 * kadar + 30)))
		im.alpha_composite(ov, (tx * T, 0))

	d = ImageDraw.Draw(im, "RGBA")

	# ── FASAD (recolor permen dari fasad repo — pratinjau) ──
	balai = buka("sprites/lpc32/fasad_balai.png")
	inn = buka("sprites/lpc32/fasad_inn.png")
	shop = buka("sprites/lpc32/fasad_shop.png")
	rumah = buka("sprites/lpc32/fasad_rumah.png")
	tinggi = buka("sprites/lpc32/fasad_datar_tinggi.png")
	lapuk = buka("sprites/lpc32/fasad_lapuk.png")

	tempel(im, geser_rona(balai, 0.95, 1.5, 1.12), (10 * T, 9 * T))       # Balai Gula — pink
	tempel(im, geser_rona(inn, 0.10, 1.35, 1.10), (29 * T, 9 * T))        # Penginapan Wafel — karamel
	tempel(im, geser_rona(shop, 0.45, 1.25, 1.1), (5 * T, 16 * T))        # Toko Sirup — mint
	tempel(im, geser_rona(rumah, 0.99, 1.45, 1.15), (9 * T, 22 * T))     # Rumah Permen — stroberi
	tempel(im, geser_rona(rumah, 0.87, 1.3, 1.12), (31 * T, 20 * T))     # Rumah Permen — anggur muda
	# pinggiran pudar masuk dari timur
	tempel(im, pudar(lapuk), (37 * T, 10 * T))
	tempel(im, pudar(rumah, 0.7), (37 * T, 21 * T))

	# ── KEDAI COKELAT: dinding bata cokelat LPC Candy (aset asli) ──
	cokelat = buka("milkchocolate.png", CANDY)
	if cokelat:
		bata = cokelat.crop((0, 64, 96, 160))    # blok bata utuh
		badan = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
		for yy in range(0, 128, 96):
			for xx in range(0, 128, 96):
				badan.alpha_composite(bata, (xx, yy))
		tempel(im, badan, (24 * T, 22 * T))
		d = ImageDraw.Draw(im, "RGBA")
		d.polygon([(24 * T - 74, 18 * T + 4), (24 * T, 16 * T - 10), (24 * T + 74, 18 * T + 4)],
			fill=(214, 168, 110, 255), outline=(140, 100, 60, 255))     # atap wafel (gambar sendiri)
		icing(d, 24 * T - 70, 18 * T + 2, 24 * T + 70)
		d.rectangle([24 * T - 14, 22 * T - 40, 24 * T + 14, 22 * T], fill=(90, 58, 38, 255))

	# ── MENARA LONCENG PERMEN: candy cane tileable LPC Candy ──
	cane = buka("cancycane.png", CANDY)
	if cane:
		batang = cane.crop((0, 64, 32, 96))    # segmen tengah murni — sambungan mulus
		for bx in (19 * T - 8, 20 * T + 4, 21 * T + 16):   # TIGA batang rapat = badan menara
			for seg in range(8):
				im.alpha_composite(batang, (bx, 4 * T + seg * 32 - 28))
		d = ImageDraw.Draw(im, "RGBA")
		d.polygon([(18 * T - 10, 4 * T - 16), (20 * T + 4, 2 * T - 28), (22 * T + 18, 4 * T - 16)],
			fill=(238, 120, 150, 255), outline=(150, 60, 90, 255))       # kerucut (gambar sendiri)
		icing(d, 18 * T - 6, 4 * T - 18, 22 * T + 14)
		d.ellipse([20 * T - 12, 3 * T - 12, 20 * T + 16, 3 * T + 16], fill=(244, 197, 66, 255),
			outline=(150, 110, 30, 255))                                  # lonceng gula

	# ── AIR MANCUR SIRUP (recolor fountain repo — gambar sendiri recolornya) ──
	ftn = buka("sprites/lpc32/fountain.png")
	tempel(im, geser_rona(ftn, 0.07, 1.3, 1.05), (20 * T, 14 * T + 10), 1.4)

	# ── PROPS permen repo + penghuni gummy LPC Candy ──
	tc = buka("sprites/props/tree_candy.png")
	lp = buka("sprites/props/lollipop.png")
	cc = buka("sprites/props/candy_cane.png")
	gd = buka("sprites/props/gumdrop.png")
	for pos in [(3 * T, 6 * T), (14 * T, 5 * T), (26 * T, 6 * T), (33 * T, 16 * T), (3 * T, 20 * T)]:
		tempel(im, tc, pos, 2.0)
	for pos in [(7 * T, 12 * T), (26 * T, 17 * T), (12 * T, 18 * T)]:
		tempel(im, lp, pos, 2.0)
	for pos in [(16 * T, 8 * T), (24 * T, 9 * T)]:
		tempel(im, cc, pos, 2.0)
	for pos in [(18 * T, 17 * T), (22 * T, 11 * T), (6 * T, 22 * T)]:
		tempel(im, gd, pos, 2.0)
	bear = buka("bear.png", CANDY)
	if bear:
		for i, pos in enumerate([(17 * T, 15 * T), (23 * T, 16 * T), (28 * T, 13 * T)]):
			satu = bear.crop((i * 3 * 32 + 32, 0, i * 3 * 32 + 64, 64))
			tempel(im, satu, pos, 1.0)

	# ── judul + keterangan ──
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, W, 40], fill=(26, 33, 56, 235))
	d.text((14, 6), "MOCKUP FINAL - potongan KOTA GULA Candyveil (aset sungguhan, 40x26 petak @32px)",
		font=f(24), fill=(244, 197, 66))
	d.rectangle([0, H, W, H + 70], fill=(26, 33, 56, 255))
	d.text((14, H + 6),
		"ASLI: ubin candy32 + props permen repo - LPC Candy CC0 (menara candy cane, bata cokelat, gummy bear) - fasad repo di-RECOLOR (final: gen_fasad_candy)",
		font=f(15), fill=(228, 232, 245))
	d.text((14, H + 28),
		"GAMBAR SENDIRI: trim icing, kerucut menara, lonceng, atap kedai, recolor sirup - timur: gradasi PUDAR (K3) masuk ke pinggiran",
		font=f(15), fill=(150, 156, 178))
	d.text((14, H + 48), "Layout mengikuti blockout #299 (menara 1 - balai 2 - penginapan 3 - toko sirup 4 - kedai 5 - plaza karamel)",
		font=f(15), fill=(150, 156, 178))

	im.convert("RGB").save(os.path.join(MOCK, "candyveil_final.png"))
	print("-> reports/mockup/candyveil_final.png")


if __name__ == "__main__":
	main()
