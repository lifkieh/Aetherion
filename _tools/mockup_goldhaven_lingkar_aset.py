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
			"fasad_aula", "fasad_hunian_a", "fasad_hunian_b", "fasad_gudang_gh",
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

	# ── TANAH per lingkar (NOL dirt di dalam tembok — arahan #315) ──
	for ty in range(N):
		for tx in range(N):
			d = math.hypot(tx - C, ty - C)
			L = lingkar_dari(d)
			if L == 6:
				t = TN["L6"] if d <= R5 + 10 else TN["luar"]
			else:
				t = TN["L%d" % L]
			if di_jalan(tx, ty) and d <= R5 + 12:
				t = TN["jalan"]
			im.alpha_composite(t, (tx * T, ty * T))

	sprites = []   # (foot_y, Image, x_kiri, y_kaki)
	def taruh(img, cx, kaki_y, skala=1.0):
		if skala != 1.0:
			img = img.resize((int(img.width * skala), int(img.height * skala)),
				Image.NEAREST)
		sprites.append((kaki_y, img, int(cx - img.width / 2), int(kaki_y - img.height)))

	# ── JALAN CINCIN di tengah tiap lingkar — tulang punggung keramaian ──
	RING_ROAD = [(R1 + R2) / 2, (R2 + R3) / 2, (R3 + R4) / 2, (R4 + R5) / 2 - 3]
	for rr in RING_ROAD:
		for ty in range(N):
			for tx in range(N):
				d = math.hypot(tx - C, ty - C)
				if rr - 1.2 <= d < rr + 1.2:
					im.alpha_composite(TN["jalan"], (tx * T, ty * T))

	# ── TEMBOK 5 cincin: band ubin RAPI (tanpa jitter battlement per ubin) ──
	# isian tembok pakai crop TENGAH (crop sudut membawa bayangan tepi ->
	# band terbaca berkolom-kolom, mata); outline gelap dua sisi supaya
	# tembok terbaca TEMBOK, bukan tanah abu
	wall_fill = P["wall_batu"]
	batt = P["battlement"]
	dd = ImageDraw.Draw(im, "RGBA")
	for ri, r in enumerate([R1, R2, R3, R4, R5]):
		tebal = 3 if r == R5 else 2      # tembok besar AoT paling tebal
		for ty in range(N):
			for tx in range(N):
				d = math.hypot(tx - C, ty - C)
				if r <= d < r + tebal and not di_jalan(tx, ty):
					im.alpha_composite(wall_fill.crop((T, T, 2 * T, 2 * T)), (tx * T, ty * T))
		for rr2, w2 in [(r, 3), (r + tebal, 3)]:
			dd.ellipse([(C - rr2) * T, (C - rr2) * T, (C + rr2) * T, (C + rr2) * T],
				outline=(70, 64, 58, 200), width=w2)
		# battlement SATU baris bersih di tepi luar (bukan offset acak tiap ubin)
		for ty in range(N):
			for tx in range(N):
				d = math.hypot(tx - C, ty - C)
				if r + tebal - 0.9 <= d < r + tebal and not di_jalan(tx, ty):
					im.alpha_composite(batt.crop((0, 0, T, batt.height)),
						(tx * T, ty * T + 8))
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

	# ── LINGKAR 2: mansion bangsawan atas (bank & serikat sebagai mansion) ──
	for i, key in enumerate(["fasad_bank", "fasad_serikat", "fasad_bank",
			"fasad_serikat", "fasad_bank", "fasad_serikat"]):
		a = (i + 0.5) * math.tau / 6
		rr = (R1 + R2) / 2
		tx, ty = C + math.cos(a) * rr, C + math.sin(a) * rr
		if abs(tx - C) <= 6 or abs(ty - C) <= 6:
			continue
		taruh(S[key], tx * T, ty * T, 0.9)

	# ── LINGKAR 3: townhouse RAPAT dua baris menghadap jalan cincin ──
	for sisi, rr in [(-1, (R2 + R3) / 2 - 3.4), (1, (R2 + R3) / 2 + 3.6)]:
		nb = 26 if sisi < 0 else 30
		for i in range(nb):
			a = (i + 0.5) * math.tau / nb
			tx, ty = C + math.cos(a) * rr, C + math.sin(a) * rr
			if abs(tx - C) <= 5 or abs(ty - C) <= 5:
				continue
			taruh(S["fasad_hunian_a" if i % 3 else "fasad_balai_gh"],
				tx * T, ty * T, 0.82)

	# ── LINGKAR 4: gedung publik warga elit ──
	publik = ["fasad_bank", "fasad_aula", "fasad_kontrak", "fasad_balai_gh",
		"fasad_hunian_a", "fasad_hunian_a", "fasad_aula", "fasad_hunian_a",
		"fasad_kontrak", "fasad_hunian_a", "fasad_hunian_a", "fasad_hunian_a",
		"fasad_bank", "fasad_hunian_a"]
	for sisi, rr in [(-1, (R3 + R4) / 2 - 3.6), (1, (R3 + R4) / 2 + 3.8)]:
		nb = 30 if sisi < 0 else 36
		for i in range(nb):
			a = (i + 0.5) * math.tau / nb
			tx, ty = C + math.cos(a) * rr, C + math.sin(a) * rr
			if abs(tx - C) <= 5 or abs(ty - C) <= 5:
				continue
			taruh(S[publik[(i * 3 + (0 if sisi < 0 else 1)) % len(publik)]],
				tx * T, ty * T, 0.9)

	# ── LINGKAR 5: rakyat — hunian PADAT 3 baris (ramai!) + PASAR + gudang + segel ──
	a = math.tau / 8
	mx, my = C + math.cos(a) * (R4 + 11), C + math.sin(a) * (R4 + 11)
	for baris_r in [(R4 + 4.5), (R4 + 11), (R4 + 17.5)]:
		nb = int(baris_r * 0.72)
		for i in range(nb):
			aa2 = (i + 0.5) * math.tau / nb
			tx, ty = C + math.cos(aa2) * baris_r, C + math.sin(aa2) * baris_r
			if abs(tx - C) <= 5 or abs(ty - C) <= 5:
				continue
			if math.hypot(tx - mx, ty - my) < 8.5:
				continue   # plaza pasar bersih dari hunian
			taruh(S["fasad_hunian_b" if (i + int(baris_r)) % 2 else "fasad_hunian_a"],
				tx * T, ty * T, 0.72)
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
