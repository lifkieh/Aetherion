# -*- coding: utf-8 -*-
"""ASET GOLDHAVEN v2 — KERAJAAN MAKMUR (#311; menggantikan recolor v1 #309).

Arahan Direktur: "bernuansa kerajaan besar dan fantasy... sangat mewah dan
megah, kerajaan yang makmur." Tata letak #308 tetap; bahasa visual baru:
MARMER PUTIH + AKSEN EMAS + ATAP NILA ROYAL + menara kerucut + panji + kubah.

Bahan & lisensi (putusan #254 dipertahankan — nol CC-BY-SA):
  * dinding/atap/jendela : atlas LPC Revised 4-Seasons — OGA-BY 3.0
    (JaidynReiman dkk) — dirakit lewat pipeline _tools/gen_fasad.py.
    [LPC] Castle Mega-Pack DIBURU lalu DITOLAK: CC-BY-SA 3.0 menular.
  * SEMUA ORNAMEN DIGAMBAR SENDIRI (deklarasi #311): lis & pilaster emas,
    menara kerucut, panji kota, kubah bank, pedimen, jendela agung lengkung,
    balustrade, lambang timbangan, menara_timbangan, gerbang_batu,
    kios_dagang, segel_pintu, pintu ganda emas.

Keluaran -> game/assets/game/sprites/goldhaven/ (nama file = v1, scene tak
berubah). #240: generator ter-commit = aset bisa dilahirkan ulang.
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import gen_fasad as F   # pipeline fasad Suikoden (atlas + nine-slice + atap)

REPO = os.path.abspath(os.path.join(HERE, ".."))
OUT = os.path.join(REPO, "game", "assets", "game", "sprites", "goldhaven")
T = 32

# palet EMAS + ROYAL (milik Aetherion)
G1 = (255, 224, 130, 255)   # emas terang
G2 = (230, 182, 74, 255)    # emas
G3 = (158, 116, 38, 255)    # emas gelap
G0 = (92, 66, 20, 255)      # outline emas
NILA = (46, 64, 120, 255)   # kerucut royal
NILA_T = (74, 100, 172, 255)
NILA_G = (30, 42, 84, 255)
KACA = (96, 140, 200, 255)
KACA_T = (150, 190, 236, 255)
MARMER = (226, 222, 210, 255)
MARMER_G = (168, 162, 148, 255)
GARIS = (52, 44, 34, 255)


# ─────────────────────────────────────────────── ORNAMEN (digambar sendiri)
def lis_emas(im, y, x0=0, x1=None):
	"""Sabuk emas mendatar — kemakmuran yang terbaca dari jauh."""
	d = ImageDraw.Draw(im)
	if x1 is None:
		x1 = im.width
	d.rectangle([x0, y, x1 - 1, y + 2], fill=G2)
	d.line([(x0, y), (x1 - 1, y)], fill=G1)
	d.line([(x0, y + 2), (x1 - 1, y + 2)], fill=G3)


def kerucut(w, h):
	"""Atap menara kerucut nila + finial emas."""
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	px, py = w // 2, 9
	d.polygon([(0, h - 1), (px, py), (w - 1, h - 1)], fill=NILA, outline=NILA_G)
	d.polygon([(px, py), (0, h - 1), (w // 3, h - 1)], fill=NILA_T)
	d.polygon([(px, py), (w - 1, h - 1), (w * 3 // 4, h - 1)], fill=NILA_G)
	for k in range(1, 4):
		yy = py + (h - py) * k // 4
		lx = px - (px * (yy - py)) // (h - py)
		rx = px + ((w - 1 - px) * (yy - py)) // (h - py)
		d.line([(lx, yy), (rx, yy)], fill=NILA_G)
	d.line([(px, py), (px, 3)], fill=G3)
	d.ellipse([px - 3, 0, px + 3, 6], fill=G2, outline=G0)
	return im


def panji(h=34):
	"""Panji kota: biru royal, lambang timbangan emas, ekor walet."""
	im = Image.new("RGBA", (12, h), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.polygon([(0, 0), (11, 0), (11, h - 8), (6, h - 3), (0, h - 8)],
		fill=NILA, outline=NILA_G)
	d.rectangle([0, 0, 11, 2], fill=G2)
	d.line([(3, 12), (8, 12)], fill=G1)
	d.line([(5, 9), (5, 14)], fill=G1)
	d.point((3, 14), fill=G1)
	d.point((8, 14), fill=G1)
	return im


def jendela_agung(w=44, h=84):
	"""Jendela lengkung tinggi berkaca biru + tiang tengah emas — katedral."""
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rounded_rectangle([0, 0, w - 1, h - 1], w // 2 - 1, fill=MARMER_G)
	d.rounded_rectangle([2, 2, w - 3, h - 1], w // 2 - 3, fill=MARMER)
	d.rounded_rectangle([5, 5, w - 6, h - 1], w // 2 - 6, fill=KACA)
	d.rounded_rectangle([5, 5, w - 6, h - 1], w // 2 - 6, outline=G3)
	# kilau kaca miring
	d.polygon([(8, 26), (16, 10), (22, 10), (10, 34)], fill=KACA_T)
	# tiang tengah + palang emas
	d.line([(w // 2, 6), (w // 2, h - 2)], fill=G2)
	d.line([(6, h // 2), (w - 7, h // 2)], fill=G2)
	d.rectangle([0, h - 3, w - 1, h - 1], fill=G3)
	return im


def pedimen(w):
	"""Segitiga kuil di atas pintu — bank & balai."""
	im = Image.new("RGBA", (w, w // 3 + 6), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	h = w // 3
	d.polygon([(0, h + 4), (w // 2, 0), (w - 1, h + 4)], fill=MARMER, outline=MARMER_G)
	d.polygon([(6, h + 2), (w // 2, 6), (w - 7, h + 2)], outline=G3)
	d.line([(3, h + 4), (w - 4, h + 4)], fill=G2)
	d.line([(3, h + 5), (w - 4, h + 5)], fill=G3)
	return im


def kubah(w=72, h=44):
	"""Kubah emas — mahkota bank."""
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.pieslice([0, 10, w - 1, 10 + (h - 12) * 2], 180, 360, fill=G2, outline=G0)
	d.pieslice([6, 14, w // 2 + 8, 10 + (h - 16) * 2], 180, 300, fill=G1)
	for k in (0.25, 0.5, 0.75):
		x = int(w * k)
		d.arc([x - w // 3, 10, x + w // 3, 10 + (h - 12) * 2], 200, 340, fill=G3)
	d.line([(w // 2, 10), (w // 2, 3)], fill=G3)
	d.ellipse([w // 2 - 3, 0, w // 2 + 3, 6], fill=G1, outline=G0)
	return im


def balustrade(w):
	"""Pagar tiang emas untuk atap datar."""
	im = Image.new("RGBA", (w, 12), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	for x in range(2, w - 2, 8):
		d.rectangle([x, 3, x + 2, 11], fill=G2, outline=G3)
	d.rectangle([0, 0, w - 1, 2], fill=G2)
	d.line([(0, 0), (w - 1, 0)], fill=G1)
	d.line([(0, 2), (w - 1, 2)], fill=G3)
	return im


def pintu_ganda(w=48, h=64):
	"""Pintu ganda kayu tua berlengkung, ornamen emas — pintu orang penting."""
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rounded_rectangle([0, 0, w - 1, h - 1], w // 2 - 1, fill=MARMER_G)
	d.rounded_rectangle([2, 2, w - 3, h - 1], w // 2 - 3, fill=(70, 50, 30, 255))
	for x in range(6, w - 4, 6):
		d.line([(x, 8), (x, h - 4)], fill=(52, 38, 22, 255))
	d.line([(w // 2, 4), (w // 2, h - 2)], fill=G3)
	d.arc([6, 4, w - 7, 40], 180, 360, fill=G2)
	for y in (h // 3, 2 * h // 3):
		d.ellipse([w // 2 - 8, y - 1, w // 2 - 6, y + 1], fill=G2)
		d.ellipse([w // 2 + 6, y - 1, w // 2 + 8, y + 1], fill=G2)
	d.rectangle([0, h - 3, w - 1, h - 1], fill=(110, 106, 98, 255))
	return im


def lambang_timbangan(s=22):
	im = Image.new("RGBA", (s, s), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	c = s // 2
	d.line([(3, c - 4), (s - 4, c - 4)], fill=G2, width=2)
	d.line([(c, c - 7), (c, c + 5)], fill=G2, width=2)
	for cx in (4, s - 5):
		d.arc([cx - 4, c - 4, cx + 4, c + 4], 0, 180, fill=G1, width=2)
	return im


def menara_sisi(src, rows):
	"""Menara marmer 1 petak + kerucut nila — pengapit gedung agung."""
	badan = F.wall(src, "krem", 1, rows)
	atap = kerucut(T + 16, 54)
	im = Image.new("RGBA", (T + 16, rows * T + 50), (0, 0, 0, 0))
	im.alpha_composite(badan, (8, 50))
	for k in range(rows - 1):
		pass
	im.alpha_composite(atap, (0, 0))
	p = panji(30)
	im.alpha_composite(p, (T + 4, 26))
	return im


# ─────────────────────────────────────────────── GEDUNG-GEDUNG
def serikat(src):
	"""Kantor Pusat Serikat: marmer 5 petak + 2 menara kerucut + jendela agung."""
	rows_w = 7
	inti = F.facade(src, F.MAT_INDIGO, F.GABLE5, 5, "krem", rows_w,
		F.WIN_PANEL, (), door=False, name="serikat_inti", sabuk=(3,))
	tw = T + 16
	kanvas = Image.new("RGBA", (5 * T + 2 * tw - 16, inti.height + 26), (0, 0, 0, 0))
	x0 = tw - 8
	kanvas.alpha_composite(inti, (x0, 26))
	m = menara_sisi(src, rows_w + 1)
	kanvas.alpha_composite(m, (0, kanvas.height - m.height))
	kanvas.alpha_composite(m, (kanvas.width - tw, kanvas.height - m.height))
	ja = jendela_agung()
	kanvas.alpha_composite(ja, (x0 + int(0.7 * T), 26 + 3 * T - 6))
	kanvas.alpha_composite(ja, (x0 + 5 * T - ja.width - int(0.7 * T), 26 + 3 * T - 6))
	lis_emas(kanvas, 26 + 2 * T + 2, x0 + 2, x0 + 5 * T - 2)
	lis_emas(kanvas, 26 + 5 * T + 8, x0 + 2, x0 + 5 * T - 2)
	kanvas.alpha_composite(lambang_timbangan(26), (kanvas.width // 2 - 13, 26 + T + 10))
	pd = pintu_ganda()
	kanvas.alpha_composite(pd, (kanvas.width // 2 - pd.width // 2, kanvas.height - pd.height))
	return kanvas


def bank(src):
	"""Bank Goldhaven: marmer, atap datar berbalustrade emas, KUBAH, pedimen."""
	inti = F.facade(src, F.MAT_INDIGO, F.GABLE5, 5, "krem", 6, F.WIN_PANEL,
		(1, 3), win_row=(1, 3), win_state="terang", door=False,
		name="bank_inti", atap="datar", sabuk=(2,))
	kb = kubah()
	kanvas = Image.new("RGBA", (inti.width, inti.height + 34), (0, 0, 0, 0))
	kanvas.alpha_composite(inti, (0, 34))
	kanvas.alpha_composite(balustrade(inti.width), (0, 34 - 4))
	kanvas.alpha_composite(kb, (inti.width // 2 - kb.width // 2, 0))
	# pilaster emas mengapit pintu
	d = ImageDraw.Draw(kanvas)
	for x in (2 * T - 6, 3 * T + 4):
		d.rectangle([x, kanvas.height - 3 * T, x + 2, kanvas.height - 4], fill=G2)
		d.line([(x, kanvas.height - 3 * T), (x + 2, kanvas.height - 3 * T)], fill=G1)
	pm = pedimen(2 * T + 24)
	kanvas.alpha_composite(pm, (kanvas.width // 2 - pm.width // 2,
		kanvas.height - 2 * T - pm.height - 20))
	pd2 = pintu_ganda(44, 60)
	kanvas.alpha_composite(pd2, (kanvas.width // 2 - pd2.width // 2, kanvas.height - pd2.height))
	lis_emas(kanvas, 34 + 2 * T)
	return kanvas


def rumah_kontrak(src):
	"""Rumah Kontrak: menara nila ramping + kerucut tinggi + panji."""
	inti = F.facade(src, F.MAT_INDIGO, F.GABLE3, 3, "nila", 7, F.WIN_PANEL,
		(1,), win_row=(1, 4), door=False, name="kontrak_inti", atap="datar",
		atap_rows=1, sabuk=(3,))
	kr = kerucut(3 * T + 12, 64)
	kanvas = Image.new("RGBA", (3 * T + 12, inti.height + 58), (0, 0, 0, 0))
	kanvas.alpha_composite(inti, (6, 58))
	kanvas.alpha_composite(kr, (0, 0))
	kanvas.alpha_composite(panji(38), (3 * T + 0, 34))
	lis_emas(kanvas, 58 + 3 * T + 6, 8, 3 * T + 4)
	pd = pintu_ganda(40, 58)
	kanvas.alpha_composite(pd, (kanvas.width // 2 - pd.width // 2, kanvas.height - pd.height))
	return kanvas


def balai(src):
	"""Balai Kota: marmer + pedimen besar + lambang timbangan emas."""
	inti = F.facade(src, F.MAT_INDIGO, F.GABLE3, 3, "krem", 5, F.WIN_KISI,
		(0, 2), win_row=1, win_state="terang", door=False, name="balai_inti")
	kanvas = Image.new("RGBA", (inti.width, inti.height + 10), (0, 0, 0, 0))
	kanvas.alpha_composite(inti, (0, 10))
	lis_emas(kanvas, 10 + 2 * T + 2)
	kanvas.alpha_composite(lambang_timbangan(20), (kanvas.width // 2 - 10, 10 + 2 * T + 14))
	pd = pintu_ganda(40, 56)
	# pedimen TEPAT di atas pintu — versi pertama melayang di tengah fasad (mata)
	pm = pedimen(pd.width + 16)
	kanvas.alpha_composite(pd, (kanvas.width // 2 - pd.width // 2, kanvas.height - pd.height))
	kanvas.alpha_composite(pm, (kanvas.width // 2 - pm.width // 2,
		kanvas.height - pd.height - pm.height + 4))
	return kanvas


def aula(src):
	"""Aula Dagang: lebar, jendela agung ganda, sabuk emas."""
	inti = F.facade(src, F.MAT_INDIGO, F.GABLE5, 5, "krem", 5, F.WIN_PANEL,
		(), door=False, name="aula_inti", sabuk=(2,))
	kanvas = inti.copy()
	ja = jendela_agung(40, 72)
	kanvas.alpha_composite(ja, (int(0.6 * T), 2 * T + 24))
	kanvas.alpha_composite(ja, (5 * T - ja.width - int(0.6 * T), 2 * T + 24))
	lis_emas(kanvas, 2 * T + 4)
	pd = pintu_ganda(52, 62)
	kanvas.alpha_composite(pd, (kanvas.width // 2 - pd.width // 2, kanvas.height - pd.height))
	return kanvas


def hunian_a(src):
	"""Townhouse makmur A: marmer krem, 2 lantai, kisi menyala, kotak bunga."""
	im = F.facade(src, F.MAT_INDIGO, F.GABLE5, 5, "krem", 5, F.WIN_KISI,
		(1, 3), win_row=(1, 3), win_state="terang", name="hunian_a", sabuk=(2,))
	lis_emas(im, 2 * T + 4 * T // 2 + 2)
	d = ImageDraw.Draw(im)
	for x in (1, 3):   # kotak bunga di jendela lantai atas
		bx = x * T
		d.rectangle([bx + 2, 2 * T + 2 * T - 6, bx + T - 3, 2 * T + 2 * T - 1],
			fill=(120, 84, 48, 255), outline=GARIS)
		for fx in range(bx + 4, bx + T - 4, 5):
			d.point((fx, 2 * T + 2 * T - 8), fill=(214, 80, 100, 255))
			d.point((fx + 2, 2 * T + 2 * T - 7), fill=(240, 150, 170, 255))
	return im


def hunian_b(src):
	"""Townhouse makmur B: bata nila royal, atap hitam, lis emas."""
	# jendela satu kolom TENGAH lantai ATAS saja — kolom tepi menempel bingkai,
	# kolom tengah lantai bawah menabrak pintu (dua-duanya ketahuan mata)
	im = F.facade(src, F.MAT_BLACK, F.GABLE3, 3, "nila", 5, F.WIN_PANEL,
		(1,), win_row=(1,), win_state="terang", name="hunian_b", sabuk=(2,))
	lis_emas(im, 2 * T + 4 * T // 2 + 2)
	im.alpha_composite(panji(26), (im.width - 13, 2 * T - 8))
	return im


def gudang(src):
	"""Gudang karavan kerajaan: batu abu rapi, atap datar nila, plakat emas."""
	im = F.facade(src, F.MAT_INDIGO, F.GABLE5, 5, "abu", 4, F.WIN_PANEL,
		(0, 4), win_row=1, name="gudang_gh", atap="datar", door=False)
	d = ImageDraw.Draw(im)
	# gerbang muat lebar
	d.rectangle([3 * T // 2, im.height - 2 * T + 6, 3 * T // 2 + 2 * T, im.height - 1],
		fill=(70, 52, 34, 255), outline=GARIS)
	for x in range(3 * T // 2 + 5, 3 * T // 2 + 2 * T - 3, 7):
		d.line([(x, im.height - 2 * T + 9), (x, im.height - 3)], fill=(52, 38, 24, 255))
	d.rectangle([3 * T // 2 + 26, im.height - 2 * T - 6, 3 * T // 2 + 38,
		im.height - 2 * T + 2], fill=G2, outline=G3)   # plakat nomor petak
	return im


# ─────────────────────────────── LANDMARK & PERABOT (digambar sendiri penuh)
def menara_timbangan(src):
	"""MENARA TIMBANGAN v2: badan marmer atlas + kubah emas + panji + emblem."""
	rows = 5
	badan = F.wall(src, "krem", 2, rows)
	im = Image.new("RGBA", (96, rows * T + 84), (0, 0, 0, 0))
	x0 = (96 - badan.width) // 2
	y0 = 84
	im.alpha_composite(badan, (x0, y0))
	lis_emas(im, y0 + T + 2, x0, x0 + badan.width)
	lis_emas(im, y0 + 3 * T + 2, x0, x0 + badan.width)
	# balkon lonceng + kubah emas besar
	d = ImageDraw.Draw(im)
	d.rectangle([x0 - 8, y0 - 12, x0 + badan.width + 7, y0], fill=MARMER, outline=MARMER_G)
	lis_emas(im, y0 - 12, x0 - 8, x0 + badan.width + 8)
	kb = kubah(badan.width + 24, 46)
	im.alpha_composite(kb, (48 - kb.width // 2, y0 - 12 - 44))
	im.alpha_composite(panji(34), (x0 - 13, y0 - 30))
	im.alpha_composite(panji(34), (x0 + badan.width + 1, y0 - 30))
	# jendela sempit + EMBLEM
	for yy in (y0 + 6, y0 + 2 * T + 6):
		d.rounded_rectangle([44, yy, 52, yy + 20], 4, fill=KACA, outline=MARMER_G)
	im.alpha_composite(lambang_timbangan(26), (48 - 13, y0 + int(1.55 * T)))
	pd = pintu_ganda(36, 52)
	im.alpha_composite(pd, (48 - pd.width // 2, im.height - pd.height))
	return im


def gerbang_batu(src):
	"""Gerbang karavan v2: pilon marmer bergerigi + ambang emas + panji."""
	im = Image.new("RGBA", (128, 96), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	pil = F.wall(src, "krem", 1, 2)
	for x0 in (0, 96):
		im.alpha_composite(pil, (x0, 28))
		# crenellation
		for k in range(3):
			d.rectangle([x0 + k * 12, 18, x0 + k * 12 + 8, 28], fill=MARMER,
				outline=MARMER_G)
	d.rectangle([24, 28, 104, 44], fill=MARMER, outline=MARMER_G)
	lis_emas(im, 30, 26, 103)
	im.alpha_composite(lambang_timbangan(18), (55, 27))
	im.alpha_composite(panji(30), (2, 0))
	im.alpha_composite(panji(30), (114, 0))
	return im


def kios_dagang(warna, warna2):
	"""Kios Pasar Agung v2: kanopi royal + tiang emas + dagangan."""
	im = Image.new("RGBA", (52, 48), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rectangle([6, 28, 46, 44], fill=(140, 100, 60, 255), outline=GARIS)
	d.rectangle([6, 28, 46, 32], fill=(246, 238, 220, 255))
	import random
	rr = random.Random(17)
	for _ in range(7):
		x = rr.randrange(9, 40)
		w = rr.choice([G2, (150, 170, 110, 255), (180, 120, 80, 255),
			(200, 200, 210, 255), (196, 92, 70, 255)])
		d.ellipse([x, 33 + rr.randrange(0, 5), x + 6, 39 + rr.randrange(0, 5)],
			fill=w, outline=GARIS)
	for x in (6, 44):
		d.rectangle([x, 12, x + 2, 30], fill=G3)
		d.point((x + 1, 12), fill=G1)
	for i, x in enumerate(range(2, 50, 8)):
		d.polygon([(x, 18), (x + 8, 18), (x + 6, 8), (x + 2, 8)],
			fill=warna if i % 2 else warna2, outline=GARIS)
	d.rectangle([2, 16, 50, 19], fill=G2)
	d.line([(2, 16), (50, 16)], fill=G1)
	return im


def segel_pintu():
	"""Pintu besi bawah-kota — tersegel, netral, nol lambang (HIDDEN). Tetap v1:
	satu-satunya benda di kota ini yang TIDAK ikut memakmur — disengaja."""
	im = Image.new("RGBA", (36, 46), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.rounded_rectangle([2, 2, 34, 44], 5, fill=(88, 92, 100, 255), outline=(40, 42, 48, 255))
	for yy in (10, 22, 34):
		d.line([(4, yy), (32, yy)], fill=(60, 63, 70, 255))
	for xy in ((6, 6), (30, 6), (6, 40), (30, 40)):
		d.ellipse([xy[0] - 2, xy[1] - 2, xy[0] + 2, xy[1] + 2], fill=(120, 124, 132, 255))
	d.rectangle([0, 16, 36, 21], fill=(130, 100, 60, 255), outline=(70, 50, 30, 255))
	d.rectangle([0, 27, 36, 32], fill=(130, 100, 60, 255), outline=(70, 50, 30, 255))
	return im


def main():
	os.makedirs(OUT, exist_ok=True)
	src = Image.open(F.SRC).convert("RGBA")
	out = {
		"fasad_serikat": serikat(src),
		"fasad_bank": bank(src),
		"fasad_kontrak": rumah_kontrak(src),
		"fasad_balai_gh": balai(src),
		"fasad_aula": aula(src),
		"fasad_hunian_a": hunian_a(src),
		"fasad_hunian_b": hunian_b(src),
		"fasad_gudang_gh": gudang(src),
		"menara_timbangan": menara_timbangan(src),
		"gerbang_batu": gerbang_batu(src),
		"kios_dagang": kios_dagang(NILA, (246, 238, 220, 255)),
		"kios_dagang_b": kios_dagang((160, 60, 60, 255), G1),
		"segel_pintu": segel_pintu(),
	}
	for nama, im in out.items():
		im.save(os.path.join(OUT, nama + ".png"))
		print("  %-18s %dx%d" % (nama, im.width, im.height))
	with open(os.path.join(OUT, "goldhaven.credits.txt"), "w", encoding="utf-8") as fh:
		fh.write("""# Kredit sprite Goldhaven v2 — KERAJAAN MAKMUR (#311)
# Lisensi: OGA-BY 3.0 (turunan) + gambar-sendiri (milik Aetherion)
- fasad_* / badan menara & gerbang: dirakit dari atlas LPC Revised 4-Seasons
  (OGA-BY 3.0 — JaidynReiman, dari LPC Revised Eliza Wyatt dkk) lewat pipeline
  _tools/gen_fasad.py. Kredit hulu tetap berlaku.
- SEMUA ORNAMEN DIGAMBAR SENDIRI (_tools/gen_goldhaven.py — milik Aetherion):
  lis/pilaster emas, menara kerucut, panji, kubah, pedimen, balustrade,
  jendela agung, pintu ganda, lambang timbangan, kios_dagang, segel_pintu.
- [LPC] Castle Mega-Pack diburu lalu DITOLAK: CC-BY-SA 3.0 menular (#254).
Lisensi: OGA-BY 3.0
""")
	print("-> %s (14 berkas)" % OUT)


if __name__ == "__main__":
	main()
