# -*- coding: utf-8 -*-
"""MOCKUP GOLDHAVEN 6 LINGKAR — POLIGON + RUKO MODULAR (#318, spek Direktur).

Cincin bukan lingkaran melainkan POLIGON N sisi (N ikut keliling: 8 sisi di
lingkar istana → 32 sisi di tembok besar) — sisi lurus berarti deret ruko
MODULAR (ujung-kiri + N×tengah + ujung-kanan, tembok bersama, atap layer
menyambung) menempel rapat tanpa celah baji. Tiap belokan (vertex) diisi
BANGUNAN SUDUT (menara). Arah hadap: konvensi semua-hadap-kamera.

Peta 160×160 petak 32px. Render 1:1, simpan setengah skala. Koordinat &
geometri poligon di sini = koordinat eksekusi. Bisa dijalankan ulang (#240).
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
G = os.path.join(ROOT, "game", "assets", "game", "sprites")
RAW = os.path.join(ROOT, "assets_raw", "lpc_castle")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")

T = 32
N = 200   # 160 membuat tembok besar (R5=92) keluar peta di 4 poros (mata #319)
C = N // 2

# (radius petak, jumlah sisi poligon) — makin luar makin banyak sisi
R1, S1 = 20, 8
R2, S2 = 36, 12
R3, S3 = 52, 16
R4, S4 = 70, 24
R5, S5 = 92, 32
LEBAR_JALAN = 3


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def verts(r, n):
	"""Vertex poligon (px). Rotasi tau/2n → SISI datar tepat di 4 poros jalan."""
	cx = cy = C * T
	rot = math.tau / (2 * n)
	return [(cx + math.cos(rot + k * math.tau / n) * r * T,
		cy + math.sin(rot + k * math.tau / n) * r * T) for k in range(n)]


def muat_sprite():
	S = {}
	nama = ["fasad_serikat", "fasad_bank", "fasad_kontrak", "fasad_balai_gh",
		"fasad_aula", "fasad_mansion", "fasad_gudang_gh", "menara_timbangan",
		"gerbang_batu", "kios_dagang", "kios_dagang_b", "segel_pintu", "menara_sudut"]
	for w in ["krem", "biru", "maroon", "tan"]:
		for b in ["kiri", "tengah", "pintu", "kanan", "atap_kiri", "atap_tengah",
				"atap_kanan"]:
			nama.append("ruko_%s_%s" % (w, b))
	for n in nama:
		S[n] = Image.open(os.path.join(G, "goldhaven", n + ".png")).convert("RGBA")
	S["gerobak"] = Image.open(os.path.join(G, "lpc32", "gerobak32.png")).convert("RGBA")
	S["lentera"] = Image.open(os.path.join(G, "lpc32", "lentera32.png")).convert("RGBA")
	sys.path.insert(0, HERE)
	from gen_goldhaven_potong import muat, potong
	S["_P"] = potong(muat())
	return S


def muat_tanah():
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
	krem = amb(320, 96)
	rumput = Image.open(os.path.join(ROOT, "game", "assets", "game", "tiles",
		"lpc32", "grass32.png")).convert("RGBA")
	tanah = Image.open(os.path.join(ROOT, "game", "assets", "game", "tiles",
		"lpc32", "ladang_tanah32.png")).convert("RGBA")
	return {
		"L1": terang(krem, 1.18), "L2": terang(krem, 1.08), "L3": krem,
		"L4": terang(krem, 0.93), "L5": terang(krem, 0.88),
		"L6": tanah, "luar": rumput, "jalan": terang(krem, 1.30),
	}


def istana(P):
	base = Image.open(os.path.join(G, "goldhaven", "fasad_serikat.png")).convert("RGBA")
	tw = Image.open(os.path.join(G, "goldhaven", "fasad_kontrak.png")).convert("RGBA")
	inti = base.resize((int(base.width * 1.7), int(base.height * 1.7)), Image.NEAREST)
	im = Image.new("RGBA", (inti.width + 2 * tw.width - 30,
		max(inti.height, tw.height) + 30), (0, 0, 0, 0))
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

	def tiled(tile):
		tt = Image.new("RGBA", (W, W))
		for yy in range(0, W, tile.height):
			for xx in range(0, W, tile.width):
				tt.paste(tile, (xx, yy))
		return tt

	# ── TANAH: poligon fill per lingkar ──
	im.paste(tiled(TN["luar"]), (0, 0))
	m6 = Image.new("L", (W, W), 0)
	ImageDraw.Draw(m6).polygon(verts(R5 + 10, S5), fill=255)
	im.paste(tiled(TN["L6"]), (0, 0), m6)
	for r_t, n_s, kunci in [(R5, S5, "L5"), (R4, S4, "L4"), (R3, S3, "L3"),
			(R2, S2, "L2"), (R1, S1, "L1")]:
		m = Image.new("L", (W, W), 0)
		ImageDraw.Draw(m).polygon(verts(r_t, n_s), fill=255)
		im.paste(tiled(TN[kunci]), (0, 0), m)
	# jalan raya silang
	jalan_t = tiled(TN["jalan"])
	m_j = Image.new("L", (W, W), 0)
	dj = ImageDraw.Draw(m_j)
	dj.rectangle([(C - LEBAR_JALAN) * T, 0, (C + LEBAR_JALAN + 1) * T, W], fill=255)
	dj.rectangle([0, (C - LEBAR_JALAN) * T, W, (C + LEBAR_JALAN + 1) * T], fill=255)
	im.paste(jalan_t, (0, 0), m_j)
	# jalan cincin: band poligon
	RING_ROAD = [((R1 + R2) / 2, S2), ((R2 + R3) / 2, S3),
		((R3 + R4) / 2, S4), ((R4 + R5) / 2 - 3, S5)]
	for rr, n_s in RING_ROAD:
		m_r = Image.new("L", (W, W), 0)
		dr_ = ImageDraw.Draw(m_r)
		dr_.polygon(verts(rr + 1.2, n_s), fill=255)
		dr_.polygon(verts(rr - 1.2, n_s), fill=0)
		im.paste(jalan_t, (0, 0), m_r)

	sprites = []
	def taruh(img, cx, kaki_y, skala=1.0):
		if skala != 1.0:
			img = img.resize((int(img.width * skala), int(img.height * skala)),
				Image.NEAREST)
		sprites.append((kaki_y, img, int(cx - img.width / 2), int(kaki_y - img.height)))

	# ── TEMBOK POLIGON: band lurus + merlon + MENARA JAGA tiap vertex ──
	wall_t = tiled(P["wall_batu"].crop((T, T, 2 * T, 2 * T)))
	dd = ImageDraw.Draw(im, "RGBA")
	for r, n_s in [(R1, S1), (R2, S2), (R3, S3), (R4, S4), (R5, S5)]:
		tebal = 3 if r == R5 else 2
		m_w = Image.new("L", (W, W), 0)
		dw = ImageDraw.Draw(m_w)
		dw.polygon(verts(r + tebal, n_s), fill=255)
		dw.polygon(verts(r, n_s), fill=0)
		dw.rectangle([(C - LEBAR_JALAN) * T, 0, (C + LEBAR_JALAN + 1) * T, W], fill=0)
		dw.rectangle([0, (C - LEBAR_JALAN) * T, W, (C + LEBAR_JALAN + 1) * T], fill=0)
		im.paste(wall_t, (0, 0), m_w)
		vo = verts(r + tebal, n_s)
		vi = verts(r, n_s)
		dd.line(vo + [vo[0]], fill=(58, 52, 46, 255), width=4)
		dd.line(vi + [vi[0]], fill=(58, 52, 46, 255), width=3)
		vm = verts(r + tebal - 0.22, n_s)
		for k in range(n_s):
			x0, y0 = vm[k]
			x1, y1 = vm[(k + 1) % n_s]
			L = math.hypot(x1 - x0, y1 - y0)
			vx, vy = (x1 - x0) / L, (y1 - y0) / L
			ux, uy = -vy, vx
			for t_ in range(10, int(L) - 10, 26):
				mx0, my0 = x0 + vx * t_, y0 + vy * t_
				if abs(mx0 - C * T) <= (LEBAR_JALAN + 1.6) * T \
						or abs(my0 - C * T) <= (LEBAR_JALAN + 1.6) * T:
					continue
				pts = [(mx0 + vx * sx + ux * sy, my0 + vy * sx + uy * sy)
					for sx, sy in [(-6, -4), (6, -4), (6, 8), (-6, 8)]]
				dd.polygon(pts, fill=(196, 192, 184, 255), outline=(58, 52, 46, 255))
		for x0, y0 in verts(r + tebal / 2, n_s):
			taruh(P["tower_kotak"], x0, y0 + 40)
		for k in range(4):
			a = k * math.tau / 4
			gx = C * T + math.cos(a) * (r + tebal / 2) * T
			gy = C * T + math.sin(a) * (r + tebal / 2) * T
			taruh(S["gerbang_batu"], gx, gy + 46)

	# ── DERET RUKO MODULAR per sisi poligon (+ menara sudut tiap vertex) ──
	VW = ["krem", "biru", "maroon", "tan"]
	def jauh(fn, px_, py_):
		return fn is None or fn(px_, py_)
	def deret_sisi(r_row, n_s, skala, benih=0, bebas=None):
		vv = verts(r_row, n_s)
		for k in range(n_s):
			x0, y0 = vv[k]
			x1, y1 = vv[(k + 1) % n_s]
			L = math.hypot(x1 - x0, y1 - y0)
			vx, vy = (x1 - x0) / L, (y1 - y0) / L
			warna = VW[(k + benih) % 4]
			mw = int(64 * skala)
			m_c = int((L - 30) / mw)
			if m_c < 2:
				continue
			pad = (L - m_c * mw) / 2
			terpakai = []
			for i in range(m_c):
				px_ = x0 + vx * (pad + (i + 0.5) * mw)
				py_ = y0 + vy * (pad + (i + 0.5) * mw)
				if abs(px_ - C * T) <= 5.5 * T or abs(py_ - C * T) <= 5.5 * T \
						or not jauh(bebas, px_, py_):
					terpakai.append(None)
				else:
					terpakai.append((px_, py_))
			i = 0
			while i < m_c:
				if terpakai[i] is None:
					i += 1
					continue
				j = i
				while j + 1 < m_c and terpakai[j + 1] is not None:
					j += 1
				for q in range(i, j + 1):
					px_, py_ = terpakai[q]
					if q == i:
						b = "kiri"
					elif q == j:
						b = "kanan"
					elif (q - i) % 3 == 2:
						b = "pintu"
					else:
						b = "tengah"
					mod = S["ruko_%s_%s" % (warna, b)]
					atap = S["ruko_%s_atap_%s" % (warna,
						"kiri" if b == "kiri" else ("kanan" if b == "kanan" else "tengah"))]
					mod_s = mod.resize((mw, int(mod.height * skala)), Image.NEAREST)
					gab = Image.new("RGBA", (mw, mod_s.height + int(30 * skala)),
						(0, 0, 0, 0))
					gab.alpha_composite(atap.resize((mw, int(33 * skala)),
						Image.NEAREST), (0, 0))
					gab.alpha_composite(mod_s, (0, int(30 * skala)))
					taruh(gab, px_, py_)
				i = j + 1
		for x0, y0 in vv:
			if abs(x0 - C * T) <= 5.5 * T or abs(y0 - C * T) <= 5.5 * T \
					or not jauh(bebas, x0, y0):
				continue
			taruh(S["menara_sudut"], x0, y0 + 8, skala)

	# ── LINGKAR 1: istana + Menara Timbangan ──
	taruh(istana(P), C * T, (C - 6) * T)
	taruh(S["menara_timbangan"], C * T, (C + 5) * T + 16, 1.1)   # ketutup istana di C+1 (mata)
	for a8 in range(8):
		a = (a8 + 0.5) * math.tau / 8
		taruh(S["lentera"], (C + math.cos(a) * 6) * T, (C + math.sin(a) * 5) * T)

	# ── LINGKAR 2: mansion di tengah sisi poligon ──
	vv2 = verts((R1 + R2) / 2 + 3.4, S2)
	for k in range(S2):
		x0, y0 = vv2[k]
		x1, y1 = vv2[(k + 1) % S2]
		mxm, mym = (x0 + x1) / 2, (y0 + y1) / 2
		if abs(mxm - C * T) <= 6 * T or abs(mym - C * T) <= 6 * T:
			continue
		taruh(S["fasad_mansion"], mxm, mym)

	# ── LINGKAR 3: dua baris ruko modular ──
	deret_sisi((R2 + R3) / 2 - 3.4, S3, 0.82)
	deret_sisi((R2 + R3) / 2 + 3.6, S3, 0.82, 2)

	# ── LINGKAR 4: gedung publik landmark + ruko baris luar ──
	publik = ["fasad_bank", "fasad_aula", "fasad_kontrak", "fasad_balai_gh"]
	vv4 = verts((R3 + R4) / 2 - 3.6, S4)
	pi = 0
	for k in range(0, S4, 2):
		x0, y0 = vv4[k]
		x1, y1 = vv4[(k + 1) % S4]
		mxm, mym = (x0 + x1) / 2, (y0 + y1) / 2
		if abs(mxm - C * T) <= 6 * T or abs(mym - C * T) <= 6 * T:
			continue
		taruh(S[publik[pi % len(publik)]], mxm, mym, 0.9)
		pi += 1
	deret_sisi((R3 + R4) / 2 + 3.8, S4, 0.9, 1)

	# ── LINGKAR 5: PASAR AGUNG + tiga baris ruko + gudang + segel ──
	a_p = math.tau / 8
	mx = C * T + math.cos(a_p) * (R4 + 11) * T
	my = C * T + math.sin(a_p) * (R4 + 11) * T
	m_p = Image.new("L", (W, W), 0)
	ImageDraw.Draw(m_p).ellipse([mx - 7 * T, my - 6 * T, mx + 7 * T, my + 6 * T],
		fill=255)
	im.paste(jalan_t, (0, 0), m_p)
	def bebas_pasar(px_, py_):
		return math.hypot(px_ - mx, py_ - my) > 8.5 * T
	deret_sisi((R4 + 4.5), S5, 0.72, 0, bebas_pasar)
	deret_sisi((R4 + 11), S5, 0.72, 1, bebas_pasar)
	deret_sisi((R4 + 17.5), S5, 0.72, 3, bebas_pasar)
	for i in range(10):
		aa = i * math.tau / 10
		taruh(S["kios_dagang" if i % 2 else "kios_dagang_b"],
			mx + math.cos(aa) * 5 * T, my + math.sin(aa) * 4 * T)
	taruh(S["gerobak"], mx - 2 * T, my + T)
	taruh(S["gerobak"], mx + 3 * T, my - 2 * T)
	taruh(S["fasad_gudang_gh"], (C - 8) * T, (R5 + C - 6) * T)
	taruh(S["fasad_gudang_gh"], (C + 8) * T, (R5 + C - 6) * T)
	sa = -3 * math.tau / 8
	taruh(S["segel_pintu"], C * T + math.cos(sa) * (R4 + 6) * T,
		C * T + math.sin(sa) * (R4 + 6) * T, 1.3)

	# ── LINGKAR 6: desa pinggiran + kamp karavan ──
	for i in range(20):
		a = (i + 0.5) * math.tau / 20
		rr = R5 + 7
		tx, ty = C + math.cos(a) * rr, C + math.sin(a) * rr
		if abs(tx - C) <= 5 or abs(ty - C) <= 5 or ty > N - 4 or ty < 4 \
				or tx > N - 4 or tx < 4:
			continue
		taruh(S["ruko_tan_kiri"], tx * T, ty * T, 0.62)
	for k in range(4):
		a = k * math.tau / 4 + 0.12
		taruh(S["gerobak"], C * T + math.cos(a) * (R5 + 5) * T,
			C * T + math.sin(a) * (R5 + 5) * T, 1.2)

	for kaki, img, x, y in sorted(sprites, key=lambda s: s[0]):
		im.alpha_composite(img, (x, max(0, y)))

	out = im.resize((W // 2, W // 2), Image.NEAREST).convert("RGB")
	d = ImageDraw.Draw(out)
	d.rectangle([0, 0, out.width, 40], fill=(26, 33, 56))
	d.text((12, 6), "MOCKUP GOLDHAVEN POLIGON (#318) - 160x160 petak - ruko modular menyambung, menara di tiap belokan, gerbang segaris",
		font=f(21), fill=(244, 197, 66))
	out.save(os.path.join(MOCK, "goldhaven_lingkar_mockup.png"))
	print("-> goldhaven_lingkar_mockup.png (%dx%d)" % out.size)


if __name__ == "__main__":
	main()
