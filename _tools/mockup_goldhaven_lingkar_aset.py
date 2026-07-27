# -*- coding: utf-8 -*-
"""MOCKUP ASET GOLDHAVEN 6 LINGKAR (#315b) — blockout di-ACC, ini penempatan
dengan SPRITE SUNGGUHAN. Peta dinaikkan 120→160 petak ("peta ini boleh besar
banget kok") = 5120x5120 px dunia, terbesar di Aetherion.

Render 1:1 (32 px/petak) lalu disimpan setengah skala supaya bisa dilihat;
koordinat petak di script ini = koordinat eksekusi (mockup = penempatan).

Bahan: sprites/goldhaven (Castle Mega-Pack, #314) + LPC Terrains (cobble
krem/abu — CC-BY-SA) + lpc32 (gerobak, lentera). Bisa dijalankan ulang (#240).
"""
import math
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
G = os.path.join(ROOT, "game", "assets", "game", "sprites")
RAW = os.path.join(ROOT, "assets_raw", "lpc_castle")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")

T = 32
N = 160                      # 160x160 petak
C = N // 2                   # pusat (80,80)

# radius lingkar (petak) — dari blockout ACC, diskala 120→160
R1, R2, R3, R4, R5 = 20, 36, 52, 70, 92     # tepi luar tiap lingkar (tembok di sini)
LEBAR_JALAN = 3              # setengah-lebar jalan raya silang


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def muat_sprite():
	S = {}
	for n in ["fasad_serikat", "fasad_bank", "fasad_kontrak", "fasad_balai_gh",
			"fasad_aula", "fasad_hunian_a", "fasad_hunian_b", "fasad_hunian_c",
			"fasad_hunian_d", "fasad_mansion", "fasad_gudang_gh",
			"menara_timbangan", "gerbang_batu", "kios_dagang", "kios_dagang_b",
			"segel_pintu"]:
		S[n] = Image.open(os.path.join(G, "goldhaven", n + ".png")).convert("RGBA")
	S["gerobak"] = Image.open(os.path.join(G, "lpc32", "gerobak32.png")).convert("RGBA")
	S["lentera"] = Image.open(os.path.join(G, "lpc32", "lentera32.png")).convert("RGBA")
	# potongan kastil untuk tembok & menara jaga
	import sys
	sys.path.insert(0, HERE)
	from gen_goldhaven_potong import muat, potong
	S["_P"] = potong(muat())
	return S


def muat_tanah():
	"""Fill 32px dari LPC Terrains + rumput repo."""
	tv = Image.open(os.path.join(RAW, "terrains", "lpc-terrains",
		"terrain-v7.png")).convert("RGBA")
	def amb(x, y):
		return tv.crop((x, y, x + T, y + T))
	def terang(im, k):
		out = im.copy()
		px = out.load()
		for y in range(T):
			for x in range(T):
				r, g, b, a = px[x, y]
				px[x, y] = (min(255, int(r * k)), min(255, int(g * k)),
					min(255, int(b * k)), a)
		return out
	krem = amb(320, 96)      # cobble krem pucat
	abu = amb(432, 96)       # cobble abu
	tan = amb(48, 96)        # cobble tan
	rumput = Image.open(os.path.join(ROOT, "game", "assets", "game", "tiles",
		"lpc32", "grass32.png")).convert("RGBA")
	tanah = Image.open(os.path.join(ROOT, "game", "assets", "game", "tiles",
		"lpc32", "ladang_tanah32.png")).convert("RGBA")
	# palet GRADASI HALUS satu keluarga krem — v1 (tan oranye + abu gelap)
	# tabrakan keras antar cincin, tanah kembali mendominasi (mata #315b)
	return {
		"L1": terang(krem, 1.18),    # pelataran istana — paling terang
		"L2": terang(krem, 1.08),
		"L3": krem,
		"L4": terang(krem, 0.93),
		"L5": terang(krem, 0.88),   # tetap keluarga krem — abu menyatu dgn tembok (mata)
		"L6": tanah,
		"luar": rumput,
		"jalan": terang(krem, 1.30),  # jalan raya batu terang
		"tanah_tan": tan,
	}


def lingkar_dari(d):
	if d <= R1: return 1
	if d <= R2: return 2
	if d <= R3: return 3
	if d <= R4: return 4
	if d <= R5: return 5
	return 6


def di_jalan(tx, ty):
	return abs(tx - C) <= LEBAR_JALAN or abs(ty - C) <= LEBAR_JALAN


def istana(P):
	"""Kompleks istana untuk mockup: serikat diperbesar + 2 menara kontrak.
	(Eksekusi nanti merakit sprite istana sendiri dari potongan yang sama.)"""
	base = Image.open(os.path.join(G, "goldhaven", "fasad_serikat.png")).convert("RGBA")
	tw = Image.open(os.path.join(G, "goldhaven", "fasad_kontrak.png")).convert("RGBA")
	inti = base.resize((int(base.width * 1.7), int(base.height * 1.7)), Image.NEAREST)
	im = Image.new("RGBA", (inti.width + 2 * tw.width - 30, max(inti.height, tw.height) + 30),
		(0, 0, 0, 0))
	im.alpha_composite(tw, (0, im.height - tw.height))
	im.alpha_composite(tw, (im.width - tw.width, im.height - tw.height))
	im.alpha_composite(inti, ((im.width - inti.width) // 2, im.height - inti.height))
	return im


def main():
	S = muat_sprite()
	P = S["_P"]
	TN = muat_tanah()
	W = N * T
	im = Image.new("RGBA", (W, W), (0, 0, 0, 255))

	# ── TANAH per-PIKSEL (#317b): mask ellipse — lingkar BULAT sungguhan,
	# bukan tangga 32px ("kotak-kotak melingkar", mata Direktur) ──
	def tiled(tile):
		tt = Image.new("RGBA", (W, W))
		for yy in range(0, W, tile.height):
			for xx in range(0, W, tile.width):
				tt.paste(tile, (xx, yy))
		return tt
	def cakram(r_t):
		m = Image.new("L", (W, W), 0)
		ImageDraw.Draw(m).ellipse([C * T - r_t * T, C * T - r_t * T,
			C * T + r_t * T, C * T + r_t * T], fill=255)
		return m
	im.paste(tiled(TN["luar"]), (0, 0))
	im.paste(tiled(TN["L6"]), (0, 0), cakram(R5 + 10))
	for r_t, kunci in [(R5, "L5"), (R4, "L4"), (R3, "L3"), (R2, "L2"), (R1, "L1")]:
		im.paste(tiled(TN[kunci]), (0, 0), cakram(r_t))
	# jalan raya silang lurus (per-piksel)
	jalan_t = tiled(TN["jalan"])
	m_j = Image.new("L", (W, W), 0)
	dj = ImageDraw.Draw(m_j)
	dj.rectangle([(C - LEBAR_JALAN) * T, 0, (C + LEBAR_JALAN + 1) * T, W], fill=255)
	dj.rectangle([0, (C - LEBAR_JALAN) * T, W, (C + LEBAR_JALAN + 1) * T], fill=255)
	im.paste(jalan_t, (0, 0), m_j)

	sprites = []   # (foot_y, Image, x_kiri, y_kaki)
	def taruh(img, cx, kaki_y, skala=1.0):
		if skala != 1.0:
			img = img.resize((int(img.width * skala), int(img.height * skala)),
				Image.NEAREST)
		sprites.append((kaki_y, img, int(cx - img.width / 2), int(kaki_y - img.height)))

	# ── JALAN CINCIN annulus per-piksel ──
	RING_ROAD = [(R1 + R2) / 2, (R2 + R3) / 2, (R3 + R4) / 2, (R4 + R5) / 2 - 3]
	for rr in RING_ROAD:
		m_r = Image.new("L", (W, W), 0)
		dr_ = ImageDraw.Draw(m_r)
		dr_.ellipse([(C - rr - 1.2) * T, (C - rr - 1.2) * T,
			(C + rr + 1.2) * T, (C + rr + 1.2) * T], fill=255)
		dr_.ellipse([(C - rr + 1.2) * T, (C - rr + 1.2) * T,
			(C + rr - 1.2) * T, (C + rr - 1.2) * T], fill=0)
		im.paste(jalan_t, (0, 0), m_r)

	# ── TEMBOK 5 cincin: band ubin RAPI (tanpa jitter battlement per ubin) ──
	# ── TEMBOK BULAT per-piksel (#317b): annulus tekstur batu + tepi gelap +
	# merlon mengikuti keliling (tangensial) — nol tangga petak ──
	wall_t = tiled(P["wall_batu"].crop((T, T, 2 * T, 2 * T)))
	dd = ImageDraw.Draw(im, "RGBA")
	for ri, r in enumerate([R1, R2, R3, R4, R5]):
		tebal = 3 if r == R5 else 2      # tembok besar AoT paling tebal
		m_w = Image.new("L", (W, W), 0)
		dw = ImageDraw.Draw(m_w)
		dw.ellipse([(C - r - tebal) * T, (C - r - tebal) * T,
			(C + r + tebal) * T, (C + r + tebal) * T], fill=255)
		dw.ellipse([(C - r) * T, (C - r) * T, (C + r) * T, (C + r) * T], fill=0)
		dw.rectangle([(C - LEBAR_JALAN) * T, 0, (C + LEBAR_JALAN + 1) * T, W], fill=0)
		dw.rectangle([0, (C - LEBAR_JALAN) * T, W, (C + LEBAR_JALAN + 1) * T], fill=0)
		im.paste(wall_t, (0, 0), m_w)
		for rr2, warna, w2 in [(r + tebal, (58, 52, 46, 255), 4),
				(r, (58, 52, 46, 255), 3), (r + 0.28, (214, 210, 200, 160), 2)]:
			dd.ellipse([(C - rr2) * T, (C - rr2) * T, (C + rr2) * T, (C + rr2) * T],
				outline=warna, width=w2)
		kel = math.tau * (r + tebal) * T
		n_m = int(kel / 26)
		for k in range(n_m):
			a = k * math.tau / n_m
			if abs(math.cos(a)) * (r + tebal) <= LEBAR_JALAN + 1.6 \
					or abs(math.sin(a)) * (r + tebal) <= LEBAR_JALAN + 1.6:
				continue
			mx0 = C * T + math.cos(a) * (r + tebal - 0.22) * T
			my0 = C * T + math.sin(a) * (r + tebal - 0.22) * T
			ux, uy = math.cos(a), math.sin(a)
			vx, vy = -uy, ux
			pts = []
			for sx, sy in [(-6, -4), (6, -4), (6, 8), (-6, 8)]:
				pts.append((mx0 + vx * sx + ux * sy, my0 + vy * sx + uy * sy))
			dd.polygon(pts, fill=(196, 192, 184, 255), outline=(58, 52, 46, 255))
		# menara jaga tiap 1/8 keliling (lewati poros jalan)
		for k in range(8):
			a = (k + 0.5) * math.tau / 8
			tx = C + math.cos(a) * (r + tebal / 2)
			ty = C + math.sin(a) * (r + tebal / 2)
			taruh(P["tower_kotak"], tx * T, ty * T + 40)
		# gerbang 4 arah segaris
		for k in range(4):
			a = k * math.tau / 4
			gx = C + math.cos(a) * (r + tebal / 2)
			gy = C + math.sin(a) * (r + tebal / 2)
			taruh(S["gerbang_batu"], gx * T, gy * T + 46, 1.0)

	# ── LINGKAR 1: istana (utara) + Menara Timbangan (pusat alun-alun) ──
	taruh(istana(P), C * T, (C - 6) * T)
	taruh(S["menara_timbangan"], C * T, (C + 1) * T + 16, 1.1)
	for a8 in range(8):
		a = (a8 + 0.5) * math.tau / 8
		taruh(S["lentera"], (C + math.cos(a) * 6) * T, (C + math.sin(a) * 5) * T)

	# ── LINGKAR 2: MANSION Victorian bangsawan atas (#317) ──
	for i in range(8):
		a = (i + 0.5) * math.tau / 8
		rr = (R1 + R2) / 2
		tx, ty = C + math.cos(a) * rr, C + math.sin(a) * rr
		if abs(tx - C) <= 6 or abs(ty - C) <= 6:
			continue
		taruh(S["fasad_mansion"], tx * T, ty * T)

	# ── strip rowhouse: rumah DISATUKAN berbagi dinding (#317b) ──
	def strip_rumah(kunci_list, skala=1.0):
		imgs = [S[k] for k in kunci_list]
		imgs = [i.resize((int(i.width * skala), int(i.height * skala)),
			Image.NEAREST) for i in imgs]
		w = sum(i.width for i in imgs) - 6 * (len(imgs) - 1)
		h = max(i.height for i in imgs)
		out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
		x = 0
		for i in imgs:
			out.alpha_composite(i, (x, h - i.height))
			x += i.width - 6
		return out
	VAR = ["fasad_hunian_a", "fasad_hunian_c", "fasad_hunian_b", "fasad_hunian_d"]
	def busur_strip(rr, skala, panjang, mulai=0.0):
		kel = math.tau * rr
		n_s = max(6, int(kel / panjang))
		for i in range(n_s):
			a = (i + 0.5 + mulai) * math.tau / n_s
			tx, ty = C + math.cos(a) * rr, C + math.sin(a) * rr
			if abs(tx - C) <= 5.5 or abs(ty - C) <= 5.5:
				continue
			st = strip_rumah([VAR[(i + j) % 4] for j in range(3)], skala)
			taruh(st, tx * T, ty * T)

	# ── LINGKAR 3: dua busur rowhouse menyambung ──
	busur_strip((R2 + R3) / 2 - 3.4, 0.82, 10.2)
	busur_strip((R2 + R3) / 2 + 3.6, 0.82, 10.2, 0.5)

	# ── LINGKAR 4: gedung publik warga elit ──
	publik = ["fasad_bank", "fasad_aula", "fasad_kontrak", "fasad_balai_gh",
		"fasad_hunian_a", "fasad_hunian_c", "fasad_aula", "fasad_hunian_d",
		"fasad_kontrak", "fasad_hunian_a", "fasad_hunian_b", "fasad_hunian_c",
		"fasad_bank", "fasad_hunian_d"]
	# gedung publik tetap berdiri sendiri (landmark), busur rowhouse di baris luar
	for i, key in enumerate(publik):
		a = (i + 0.5) * math.tau / len(publik)
		rr = (R3 + R4) / 2 - 3.6
		tx, ty = C + math.cos(a) * rr, C + math.sin(a) * rr
		if abs(tx - C) <= 5 or abs(ty - C) <= 5:
			continue
		taruh(S[key], tx * T, ty * T, 0.9)
	busur_strip((R3 + R4) / 2 + 3.8, 0.9, 11.5, 0.5)

	# ── LINGKAR 5: rakyat — hunian PADAT 3 baris (ramai!) + PASAR + gudang + segel ──
	a = math.tau / 8
	mx, my = C + math.cos(a) * (R4 + 11), C + math.sin(a) * (R4 + 11)
	for bi, baris_r in enumerate([(R4 + 4.5), (R4 + 11), (R4 + 17.5)]):
		kel = math.tau * baris_r
		n_s = int(kel / 8.6)
		for i in range(n_s):
			aa2 = (i + 0.5 + bi * 0.4) * math.tau / n_s
			tx, ty = C + math.cos(aa2) * baris_r, C + math.sin(aa2) * baris_r
			if abs(tx - C) <= 5 or abs(ty - C) <= 5:
				continue
			if math.hypot(tx - mx, ty - my) < 9.5:
				continue   # plaza pasar bersih dari hunian
			st = strip_rumah([VAR[(i + j + bi) % 4] for j in range(3)], 0.72)
			taruh(st, tx * T, ty * T)
	# PASAR AGUNG tenggara — plaza terang + kios radial + gerobak
	for ty in range(N):
		for tx in range(N):
			if math.hypot(tx - mx, ty - my) < 7:
				im.alpha_composite(TN["jalan"], (tx * T, ty * T))
	for i in range(10):
		aa = i * math.tau / 10
		taruh(S["kios_dagang" if i % 2 else "kios_dagang_b"],
			(mx + math.cos(aa) * 5) * T, (my + math.sin(aa) * 4) * T)
	taruh(S["gerobak"], (mx - 2) * T, (my + 1) * T)
	taruh(S["gerobak"], (mx + 3) * T, (my - 2) * T)
	# gudang dekat gerbang selatan + gang segel timur-laut
	taruh(S["fasad_gudang_gh"], (C - 8) * T, (R5 + C - 6) * T)
	taruh(S["fasad_gudang_gh"], (C + 8) * T, (R5 + C - 6) * T)
	sa = -3 * math.tau / 8
	taruh(S["segel_pintu"], (C + math.cos(sa) * (R4 + 6)) * T,
		(C + math.sin(sa) * (R4 + 6)) * T, 1.3)

	# ── LINGKAR 6: desa pinggiran — gubuk kecil + kamp karavan + ladang ──
	for i in range(20):
		a = (i + 0.5) * math.tau / 20
		rr = R5 + 7
		tx, ty = C + math.cos(a) * rr, C + math.sin(a) * rr
		if abs(tx - C) <= 5 or abs(ty - C) <= 5 or ty > N - 4 or ty < 4 \
				or tx > N - 4 or tx < 4:
			continue
		taruh(S["fasad_hunian_b"], tx * T, ty * T, 0.62)
	for k in range(4):
		a = k * math.tau / 4 + 0.12
		taruh(S["gerobak"], (C + math.cos(a) * (R5 + 5)) * T,
			(C + math.sin(a) * (R5 + 5)) * T, 1.2)

	# komposit sprite urut kaki-y (y-sort dunia)
	for kaki, img, x, y in sorted(sprites, key=lambda s: s[0]):
		im.alpha_composite(img, (x, max(0, y)))

	out = im.resize((W // 2, W // 2), Image.NEAREST).convert("RGB")
	d = ImageDraw.Draw(out)
	d.rectangle([0, 0, out.width, 40], fill=(26, 33, 56))
	d.text((12, 6), "MOCKUP ASET GOLDHAVEN 6 LINGKAR (#315b) - 160x160 petak 32px - sprite sungguhan, koordinat = eksekusi",
		font=f(21), fill=(244, 197, 66))
	d.text((12, out.height - 22),
		"L1 istana+alun-alun - L2 mansion - L3 townhouse - L4 Serikat/Bank/Aula/Kontrak - L5 hunian padat+PASAR+gudang+segel - L6 desa & karavan. Tembok 5 cincin bermenara jaga, gerbang segaris.",
		font=f(14), fill=(210, 214, 228))
	out.save(os.path.join(MOCK, "goldhaven_lingkar_mockup.png"))
	print("-> goldhaven_lingkar_mockup.png (%dx%d)" % out.size)


if __name__ == "__main__":
	main()
