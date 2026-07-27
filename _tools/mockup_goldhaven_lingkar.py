# -*- coding: utf-8 -*-
"""BLOCKOUT GOLDHAVEN 6 LINGKAR (#315) — alat coretan Direktur.

Arahan: kerajaan mewah berlapis — lingkar 1 KERAJAAN · 2 bangsawan atas ·
3 bangsawan rendah · 4 warga elit · 5 rakyat biasa · 6 desa & pinggiran —
tiap lingkar dibatasi TEMBOK (gaya Attack on Titan) dengan gerbang segaris,
jalan raya silang menembus dari luar sampai istana.
Tone: fantasy, kingdom, mewah, ramai, semua ada.

Peta usulan 120x120 petak 32px (3840x3840 dunia — terbesar di Aetherion).
Skala blockout 7 px/petak. Bisa dijalankan ulang (#240).
"""
import math
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")
S = 7
N = 120
OX, OY = 46, 56
EMAS = (244, 197, 66)
TINTA = (232, 236, 248)
REDUP = (150, 156, 178)
BG = (15, 19, 33)

# (radius petak, warna zona, nama)
LINGKAR = [
	(11, (240, 214, 140), "1 KERAJAAN — istana + alun-alun timbangan"),
	(20, (216, 184, 120), "2 BANGSAWAN ATAS — mansion & taman privat"),
	(29, (196, 162, 108), "3 BANGSAWAN RENDAH — townhouse plester"),
	(38, (172, 146, 104), "4 WARGA ELIT — Serikat, Bank, Aula, Kontrak"),
	(48, (148, 128, 96), "5 RAKYAT BIASA — Pasar Agung, inn, gudang, gang segel"),
	(58, (116, 118, 88), "6 DESA PINGGIRAN — gubuk, ladang, kamp karavan (luar tembok besar)"),
]
TEMBOK = (94, 88, 82)


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def px(t):
	return OX + int(t * S)


def blockout():
	im = Image.new("RGB", (OX * 2 + N * S, OY + N * S + 210), BG)
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, im.width, 44], fill=(26, 33, 56))
	d.text((14, 8), "BLOCKOUT GOLDHAVEN 6 LINGKAR (#315) - 120x120 petak - tembok tiap lingkar, gerbang segaris 4 arah",
		font=f(22), fill=EMAS)
	cx = cy = OX + N * S // 2
	cy += OY - OX
	# padang luar
	d.rectangle([OX, OY, OX + N * S, OY + N * S], fill=(72, 84, 60))
	# lingkar dari luar ke dalam
	for r, warna, _n in reversed(LINGKAR):
		d.ellipse([cx - r * S, cy - r * S, cx + r * S, cy + r * S], fill=warna)
	# TEMBOK tiap lingkar (lingkar-6 tak bertembok — ia di LUAR tembok besar)
	for i, (r, _w, _n) in enumerate(LINGKAR[:5]):
		tebal = 5 if i == 4 else 3   # tembok terluar = tembok besar AoT
		d.ellipse([cx - r * S, cy - r * S, cx + r * S, cy + r * S],
			outline=TEMBOK, width=tebal + 2)
		d.ellipse([cx - r * S, cy - r * S, cx + r * S, cy + r * S],
			outline=(200, 196, 188), width=tebal)
	# JALAN RAYA silang: menembus semua gerbang sampai alun-alun istana
	for ang in range(4):
		a = ang * math.pi / 2
		x2 = cx + math.cos(a) * (N // 2) * S
		y2 = cy + math.sin(a) * (N // 2) * S
		d.line([(cx, cy), (x2, y2)], fill=(228, 214, 178), width=int(2.5 * S))
	# GERBANG segaris di tiap tembok (4 arah x 5 tembok)
	for r, _w, _n in LINGKAR[:5]:
		for ang in range(4):
			a = ang * math.pi / 2
			gx = cx + math.cos(a) * r * S
			gy = cy + math.sin(a) * r * S
			d.rectangle([gx - 8, gy - 8, gx + 8, gy + 8], fill=(240, 208, 130),
				outline=(120, 90, 40))
	# ISTANA lingkar-1 (utara alun-alun) + Menara Timbangan di pusat
	d.rectangle([cx - 6 * S, cy - 9 * S, cx + 6 * S, cy - 2 * S],
		fill=(246, 240, 226), outline=(140, 130, 110), width=2)
	d.text((cx - 5 * S, cy - 8 * S), "ISTANA", font=f(15), fill=(90, 70, 30))
	d.ellipse([cx - 8, cy - 8, cx + 8, cy + 8], fill=(255, 224, 120), outline=(120, 90, 40))
	d.text((cx + 12, cy - 6), "Menara Timbangan (alun-alun)", font=f(12), fill=(80, 62, 26))
	# penanda isi tiap lingkar (blok kecil skematik, DIATUR RAPI radial)
	skema = [
		(16, (238, 232, 220), 8, "mansion"),       # L2
		(25, (230, 220, 200), 12, "townhouse"),    # L3
		(33, (222, 208, 184), 12, "gedung publik"),# L4
		(43, (208, 192, 164), 16, "hunian+pasar"), # L5
		(53, (170, 160, 120), 12, "gubuk desa"),   # L6
	]
	for r, warna, n, _lbl in skema:
		for i in range(n):
			a = (i + 0.5) * math.tau / n
			if abs(math.cos(a)) > 0.93 or abs(math.sin(a)) > 0.93:
				continue   # jangan menimpa jalan raya
			bx = cx + math.cos(a) * r * S
			by = cy + math.sin(a) * r * S
			d.rectangle([bx - 9, by - 7, bx + 9, by + 7], fill=warna,
				outline=(110, 100, 84))
	# PASAR AGUNG lingkar-5 (timur jalan) + gang segel TL lingkar-5
	a = math.tau / 8
	mx = cx + math.cos(a) * 43 * S
	my = cy + math.sin(a) * 43 * S
	d.ellipse([mx - 5 * S, my - 4 * S, mx + 5 * S, my + 4 * S],
		fill=(232, 200 , 140), outline=(140, 100, 50), width=2)
	d.text((mx - 4 * S, my - 8), "PASAR AGUNG", font=f(13), fill=(90, 62, 20))
	sx = cx + math.cos(-3 * math.tau / 8) * 44 * S
	sy = cy + math.sin(-3 * math.tau / 8) * 44 * S
	d.rectangle([sx - 8, sy - 8, sx + 8, sy + 8], fill=(86, 74, 110))
	d.text((sx + 12, sy - 6), "gang pintu tersegel (TANPA penanda)", font=f(12), fill=(150, 140, 190))
	# legenda
	y0 = OY + N * S + 8
	for i, (r, warna, nama) in enumerate(LINGKAR):
		yy = y0 + i * 22
		d.rectangle([OX, yy, OX + 16, yy + 16], fill=warna)
		d.text((OX + 24, yy), nama, font=f(14), fill=TINTA)
	d.text((OX, y0 + 6 * 22 + 6),
		"TEMBOK: 5 cincin (paling luar = tembok besar, 2 petak tebal + menara jaga tiap 1/8 keliling) - gerbang 4 arah SEGARIS: masuk dari barat = menembus lapis demi lapis makin mewah",
		font=f(13), fill=REDUP)
	d.text((OX, y0 + 6 * 22 + 26),
		"Tanah: dalam tembok NOL dirt - lingkar 1-2 pelataran marmer/krem, 3-4 cobble krem (LPC Terrains), 5 cobble abu, 6 tanah+rumput. Jalan raya batu terang.",
		font=f(13), fill=REDUP)
	d.text((OX, y0 + 6 * 22 + 46),
		"Ramai: kerumunan per lingkar (padat di 4-5, anggun di 2-3), karavan antre gerbang, kios pasar, taman & air mancur bangsawan, panji di tiap gerbang.",
		font=f(13), fill=REDUP)
	im.save(os.path.join(MOCK, "goldhaven_lingkar_blockout.png"))
	print("-> goldhaven_lingkar_blockout.png")


if __name__ == "__main__":
	blockout()
