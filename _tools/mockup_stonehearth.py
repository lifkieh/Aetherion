# -*- coding: utf-8 -*-
"""STONEHEARTH / FROSTPEAK — kartu konsep + blockout + mockup aset (#321).

Arahan Direktur: ladang es dingin, LUAS (segede Goldhaven), banyak kehidupan
MUTAN / monster termutasi; dunia visual indah; boleh CC-BY-SA. Konsep BEDA dari
Goldhaven: bukan kota cincin — WILDERNESS BEKU. Benteng Stonehearth (bibit
Durnhold "Jantung Batu" #004) = satu pos aman; sekeliling hamparan es +
gletser retak + gua es + reruntuhan + ZONA MUTASI berpendar.

Tiga keluaran ke reports/mockup/. Alat coretan Direktur — belum aset game,
belum scene. Bisa dijalankan ulang (#240).

Bahan aset yang DITENTUKAN (semua CC-BY-SA / repo):
  * tanah es    : snow_0/snow_1/ice_patch (repo) + [LPC] Terrains snow/ice
  * gletser+gua : [LPC] Mountains snowy (bluecarrot16 dkk, CC-BY-SA) —
                  tebing bersalju + mulut gua es biru = pintu dungeon
  * benteng     : [LPC] Castle Mega-Pack castle8dark (batu gelap)
  * MUTAN       : [LPC] Monsters (CharlesGabriel/bagzie/bluecarrot16, CC-BY-SA)
                  eyeball · big_worm · man_eater_flower · slime = aberasi murni
                  + frost-beast repo di-RECOLOR palet mutasi (gambar-sendiri)
  * inti mutasi : obelisk berpendar — DIGAMBAR SENDIRI (deklarasi)
"""
import math
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
G = os.path.join(ROOT, "game", "assets", "game")
RAW = os.path.join(ROOT, "assets_raw", "lpc_castle")
FONT = os.path.join(G, "fonts", "m5x7.ttf")

ES = (196, 224, 240)
TINTA = (232, 238, 248)
REDUP = (150, 164, 186)
BG = (12, 18, 30)
MUT = (150, 240, 170)     # pendar mutasi bio


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


# ─────────────────────────────────────────────── KARTU KONSEP
ZONA = [
	("BENTENG STONEHEARTH (pos aman)", (120, 130, 150),
		"batu gelap Durnhold; gerbang menghadap ladang; penambang, inn, world gate"),
	("LADANG ES (hamparan luas)", (206, 226, 240),
		"salju + tambalan es + kolam beku; angin; bangkai karavan setengah terkubur"),
	("PUNGGUNG GLETSER (dinding alam)", (150, 178, 200),
		"tebing bersalju memotong peta; MULUT GUA ES biru = pintu dungeon"),
	("DANAU BEKU (barat)", (120, 170, 200),
		"lembar es raksasa; retakan; pemancing-es tua yang membatu"),
	("KAWAH MUTASI (timur-laut, bahaya puncak)", (150, 240, 170),
		"salju ternoda pendar; aberasi padat; INTI MUTASI berdenyut"),
	("RERUNTUHAN TERKUBUR (tersebar)", (150, 150, 160),
		"tembok tua muncul dari es; sisa peradaban sebelum beku"),
]


def kartu():
	im = Image.new("RGB", (760, 460), BG)
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, 760, 46], fill=(24, 34, 54))
	d.text((14, 6), "004 STONEHEARTH — Durnhold · Ladang Es Termutasi", font=f(25), fill=ES)
	d.text((14, 52), "wilderness beku LUAS · lv 22–38 · benteng + hamparan + kawah mutasi",
		font=f(15), fill=REDUP)
	for i, (nama, w, ket) in enumerate(ZONA):
		y = 82 + i * 56
		d.rectangle([16, y, 40, y + 24], fill=w + (255,), outline=(255, 255, 255, 60))
		d.text((52, y - 2), nama, font=f(17), fill=TINTA)
		d.text((52, y + 20), ket, font=f(13), fill=REDUP)
	d.text((16, 430), "AROMA: udara tajam beku + ozon + bau amis-manis mutasi (asing, salah)",
		font=f(13), fill=(180, 230, 200))
	im.save(os.path.join(MOCK, "stonehearth_konsep.png"))
	return im


# ─────────────────────────────────────────────── BLOCKOUT ZONA (skematik)
N = 200
S = 6
OX, OY = 44, 56


def px(t):
	return (OX + t * S, OY + t * S)


def blockout():
	W = OX * 2 + N * S
	im = Image.new("RGB", (W, OY + N * S + 150), BG)
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, W, 44], fill=(24, 34, 54))
	d.text((14, 8), "BLOCKOUT STONEHEARTH 200x200 petak (#321) — wilderness beku (bukan kota cincin)",
		font=f(22), fill=ES)
	# dasar ladang es
	d.rectangle([px(0)[0], px(0)[1], px(N)[0], px(N)[1]], fill=(206, 224, 238))
	def poly(pts, w, a=255):
		d.polygon([px(t)[0:1][0] if False else (OX + t[0] * S, OY + t[1] * S) for t in pts],
			fill=w + (a,), outline=(255, 255, 255, 70))
	# DANAU BEKU barat
	poly([(6, 60), (52, 48), (60, 110), (30, 150), (4, 130)], (150, 190, 214))
	d.text((OX + 16 * S, OY + 96 * S), "DANAU BEKU", font=f(15), fill=(30, 60, 90))
	# PUNGGUNG GLETSER diagonal (dua pita)
	poly([(70, 8), (96, 14), (150, 120), (128, 130), (60, 30)], (150, 176, 200))
	poly([(150, 40), (176, 30), (196, 96), (168, 108), (140, 70)], (150, 176, 200))
	d.text((OX + 96 * S, OY + 60 * S), "PUNGGUNG GLETSER", font=f(14), fill=(40, 60, 84))
	# mulut gua es (titik biru) sepanjang gletser
	for gx, gy in [(88, 40), (120, 80), (168, 66), (110, 118)]:
		d.ellipse([px((gx, gy) if False else gx)[0] - 7, OY + gy * S - 7,
			OX + gx * S + 7, OY + gy * S + 7], fill=(90, 200, 230, 255),
			outline=(20, 60, 90, 255))
	# KAWAH MUTASI timur-laut (pendar)
	cx, cy = 150, 40
	for rr, aa in [(30, 60), (22, 120), (14, 200)]:
		d.ellipse([OX + (cx - rr) * S, OY + (cy - rr) * S, OX + (cx + rr) * S,
			OY + (cy + rr) * S], fill=MUT + (aa,))
	d.text((OX + (cx - 18) * S, OY + (cy - 4) * S), "KAWAH MUTASI", font=f(14),
		fill=(20, 60, 30))
	d.ellipse([OX + cx * S - 6, OY + cy * S - 6, OX + cx * S + 6, OY + cy * S + 6],
		fill=(200, 255, 210, 255), outline=(20, 80, 40, 255))
	# BENTENG STONEHEARTH selatan-tengah (pos aman)
	d.rectangle([OX + 84 * S, OY + 168 * S, OX + 116 * S, OY + 196 * S],
		fill=(120, 130, 150, 255), outline=(230, 236, 248, 255), width=2)
	d.text((OX + 86 * S, OY + 176 * S), "BENTENG STONEHEARTH", font=f(14), fill=(232, 238, 248))
	d.text((OX + 90 * S, OY + 190 * S), "(pos aman · masuk dari selatan)", font=f(11),
		fill=(210, 216, 230))
	# jalur rintis benteng -> ladang (bukan jalan mulus, jejak di salju)
	d.line([(OX + 100 * S, OY + 168 * S), (OX + 100 * S, OY + 120 * S),
		(OX + 130 * S, OY + 70 * S)], fill=(180, 196, 214, 255), width=4)
	# reruntuhan tersebar
	for rx, ry in [(40, 30), (70, 150), (120, 150), (176, 140), (150, 170), (30, 90)]:
		d.rectangle([OX + rx * S, OY + ry * S, OX + (rx + 6) * S, OY + (ry + 5) * S],
			fill=(150, 150, 160, 255), outline=(90, 90, 100, 255))
	# monster mutan: kepadatan meningkat ke KAWAH (titik hijau makin rapat)
	import random
	rr = random.Random(4)
	for _ in range(120):
		mx = rr.randint(4, N - 4)
		my = rr.randint(4, N - 4)
		dk = math.hypot(mx - cx, my - cy)
		if rr.random() > max(0.08, 1.2 - dk / 90.0):
			continue
		if 84 <= mx <= 116 and 168 <= my <= 196:
			continue   # benteng bersih
		d.ellipse([OX + mx * S - 3, OY + my * S - 3, OX + mx * S + 3, OY + my * S + 3],
			fill=(120, 220, 140, 230))
	# legenda
	y0 = OY + N * S + 8
	d.text((OX, y0), "hijau = monster termutasi (padat menuju kawah) · biru = mulut gua es (dungeon) · abu = reruntuhan",
		font=f(14), fill=REDUP)
	d.text((OX, y0 + 22), "Loop: benteng aman -> rintis ladang -> gletser & gua -> makin ke timur-laut makin termutasi -> KAWAH (puncak bahaya).",
		font=f(14), fill=REDUP)
	d.text((OX, y0 + 44), "Skala 200x200 = 6400px (segede Goldhaven). Terbuka & berangin — bukan koridor.",
		font=f(14), fill=REDUP)
	im.save(os.path.join(MOCK, "stonehearth_blockout.png"))


# ─────────────────────────────────────────────── MOCKUP ASET (adegan nyata)
def geser_rona(im, dr, dg, db):
	out = im.copy()
	pxs = out.load()
	for y in range(out.height):
		for x in range(out.width):
			r, g, b, a = pxs[x, y]
			if a == 0:
				continue
			pxs[x, y] = (min(255, max(0, r + dr)), min(255, max(0, g + dg)),
				min(255, max(0, b + db)), a)
	return out


def frame0(path, sel=64):
	im = Image.open(path).convert("RGBA")
	return im.crop((0, 0, min(sel, im.width), min(sel, im.height)))


def mockup():
	TW, THh = 40, 26        # petak layar
	T = 32
	W, H = TW * T, THh * T
	im = Image.new("RGBA", (W, H), (0, 0, 0, 255))
	snow = [Image.open(os.path.join(G, "tiles", "snow_%d.png" % i)).convert("RGBA")
		for i in (0, 1)]
	ice = Image.open(os.path.join(G, "tiles", "ice_patch.png")).convert("RGBA")
	import random
	rr = random.Random(7)
	for ty in range(THh):
		for tx in range(TW):
			t = snow[rr.randint(0, 1)]
			im.alpha_composite(t, (tx * T, ty * T))
	# tambalan es acak
	for _ in range(24):
		im.alpha_composite(ice, (rr.randint(0, TW - 1) * T, rr.randint(0, THh - 1) * T))
	# noda mutasi timur-laut
	nd = Image.new("RGBA", (W, H), (0, 0, 0, 0))
	dn = ImageDraw.Draw(nd)
	dn.ellipse([W - 15 * T, -3 * T, W + 3 * T, 12 * T], fill=(120, 240, 150, 60))
	im.alpha_composite(nd)

	ms = Image.open(os.path.join(RAW, "mountains", "submission",
		"mountains-v6-snow.png")).convert("RGBA")
	gua = ms.crop((128, 160, 192, 288))       # mulut gua es biru
	tebing = ms.crop((0, 512, 96, 704))       # tebing bersalju tinggi
	# PUNGGUNG gletser membentang atas
	for gx in range(0, W, tebing.width - 6):
		im.alpha_composite(tebing, (gx, -60))
	im.alpha_composite(gua, (5 * T, 1 * T))
	im.alpha_composite(gua, (26 * T, 0))

	# benteng: potong castle8dark (batu gelap)
	cd = Image.open(os.path.join(RAW, "castle8dark.png")).convert("RGBA")
	keep = cd.crop((192, 0, 320, 224))
	tower = cd.crop((96, 96, 160, 224))
	im.alpha_composite(keep, (int(1.5 * T), int(15.5 * T)))
	im.alpha_composite(tower, (0, int(17 * T)))
	im.alpha_composite(tower, (int(5.2 * T), int(17 * T)))

	# reruntuhan setengah terkubur
	ruin = cd.crop((0, 96, 96, 168))
	im.alpha_composite(geser_rona(ruin, 20, 26, 32), (13 * T, 19 * T))

	def taruh(img, tx, ty, skala=1.0):
		if skala != 1.0:
			img = img.resize((int(img.width * skala), int(img.height * skala)),
				Image.NEAREST)
		im.alpha_composite(img, (int(tx * T - img.width / 2), int(ty * T - img.height)))

	MON = os.path.join(RAW, "monsters", "lpc-monsters")
	# ABERASI MUTAN (LPC Monsters) — padat ke timur-laut
	taruh(frame0(os.path.join(MON, "eyeball.png")), 33, 5, 1.4)
	taruh(frame0(os.path.join(MON, "big_worm.png")), 30, 8, 1.3)
	taruh(frame0(os.path.join(MON, "man_eater_flower.png"), 96).crop((16, 16, 96, 96)),
		36, 9, 1.2)
	taruh(frame0(os.path.join(MON, "slime.png")), 28, 6, 1.2)
	taruh(frame0(os.path.join(MON, "eyeball.png")), 37, 4, 1.0)
	# frost-beast repo DI-RECOLOR palet mutasi (bio-hijau) — mutan terkorupsi
	fw = Image.open(os.path.join(G, "sprites", "monsters", "frost_wyvern.png")).convert("RGBA")
	taruh(geser_rona(fw.crop((0, 0, 128, 128)), -30, 40, -20), 22, 11, 1.1)
	ff = Image.open(os.path.join(G, "sprites", "monsters", "frost_fox.png")).convert("RGBA")
	taruh(geser_rona(ff.crop((0, 0, 64, 64)), -20, 50, -10), 18, 8, 1.3)
	taruh(geser_rona(ff.crop((0, 0, 64, 64)), -20, 50, -10), 25, 13, 1.2)
	# beast normal (belum termutasi) di dekat benteng
	taruh(ff.crop((0, 0, 64, 64)), 9, 22, 1.2)

	# INTI MUTASI (obelisk pendar — DIGAMBAR SENDIRI)
	ob = Image.new("RGBA", (40, 96), (0, 0, 0, 0))
	do = ImageDraw.Draw(ob)
	do.polygon([(20, 0), (34, 20), (30, 90), (10, 90), (6, 20)], fill=(40, 70, 60, 255),
		outline=(18, 34, 30, 255))
	for yy in range(16, 88, 10):
		do.line([(12, yy), (28, yy - 4)], fill=(150, 240, 170, 255))
	do.ellipse([12, 30, 28, 54], fill=(180, 255, 200, 220))
	taruh(ob, 35, 3, 1.3)

	# figur pemain kecil (skala rasa) di depan benteng
	pl = Image.open(os.path.join(G, "sprites", "characters", "sora_idle.png")).convert("RGBA") \
		if os.path.exists(os.path.join(G, "sprites", "characters", "sora_idle.png")) else None
	if pl:
		taruh(pl.crop((0, 128, 64, 192)), 6, 22, 1.0)

	out = im.resize((W * 2, H * 2), Image.NEAREST).convert("RGB")
	d = ImageDraw.Draw(out)
	d.rectangle([0, 0, out.width, 40], fill=(24, 34, 54))
	d.text((12, 6), "MOCKUP ASET STONEHEARTH — ladang es + gletser & gua es + benteng + KAWAH MUTASI (aberasi + beast terkorupsi)",
		font=f(20), fill=ES)
	d.text((12, out.height - 24),
		"Aset: [LPC] Terrains salju+es (CC-BY-SA) · [LPC] Mountains gletser+gua · Castle Mega-Pack benteng · [LPC] Monsters aberasi · pohon gundul/pinus repo · frost-beast RECOLOR mutasi · kristal+obelisk gambar-sendiri",
		font=f(13), fill=REDUP)
	out.save(os.path.join(MOCK, "stonehearth_mockup.png"))


def peta():
	"""MOCKUP PETA PENUH 200x200 (6400px) — aset nyata di seluruh zona blockout.
	Koordinat = koordinat eksekusi. Render 1:1 lalu simpan skala kecil."""
	import random
	T = 32
	NN = 200
	W = NN * T
	im = Image.new("RGBA", (W, W), (0, 0, 0, 255))
	rr = random.Random(11)
	# TANAH ES KAYA dari [LPC] Terrains (bukan snow_0 polos) — center-tile seragam
	tv = Image.open(os.path.join(RAW, "terrains", "lpc-terrains",
		"terrain-v7.png")).convert("RGBA")
	snow_a = tv.crop((608, 320, 640, 352))     # salju biru-putih
	snow_b = tv.crop((704, 320, 736, 352))     # salju kelabu
	ice_full = tv.crop((736, 480, 768, 512))   # es beku retak
	ice_dark = tv.crop((608, 480, 640, 512))   # es tebal gelap
	snow = [snow_a, snow_a, snow_b]
	ice = Image.open(os.path.join(G, "tiles", "ice_patch.png")).convert("RGBA")

	def tiled(tile, mask=None):
		tt = Image.new("RGBA", (W, W))
		for yy in range(0, W, tile.height):
			for xx in range(0, W, tile.width):
				tt.paste(tile, (xx, yy))
		return tt

	# hamparan salju kaya (dua nada LPC acak)
	for ty in range(NN):
		for tx in range(NN):
			im.alpha_composite(snow[rr.randint(0, 2)], (tx * T, ty * T))

	def poly_px(pts):
		return [(x * T, y * T) for x, y in pts]

	# DANAU BEKU barat — lembar es tebal LPC + retakan
	danau = [(6, 60), (52, 48), (60, 110), (30, 150), (4, 130)]
	m = Image.new("L", (W, W), 0)
	ImageDraw.Draw(m).polygon(poly_px(danau), fill=255)
	lembar = tiled(ice_full)
	# selingi es gelap supaya kedalaman terbaca
	dpx = lembar.load()
	im.paste(lembar, (0, 0), m)
	dd0 = ImageDraw.Draw(im, "RGBA")
	dd0.line(poly_px(danau) + [poly_px(danau)[0]], fill=(120, 160, 190, 220), width=8)
	for _ in range(34):
		cx = rr.randint(8, 56); cy = rr.randint(52, 145)
		dd0.line([(cx * T, cy * T), (cx * T + rr.randint(-46, 46), cy * T + rr.randint(-46, 46))],
			fill=(210, 232, 244, 200), width=2)

	# GUNDUKAN SALJU (drift) — blotch lebih terang, memecah datar
	drift = Image.new("RGBA", (W, W), (0, 0, 0, 0))
	dd_dr = ImageDraw.Draw(drift)
	for _ in range(70):
		dx = rr.randint(0, W); dy = rr.randint(0, W); dr2 = rr.randint(40, 130)
		dd_dr.ellipse([dx - dr2, dy - int(dr2 * 0.5), dx + dr2, dy + int(dr2 * 0.5)],
			fill=(255, 255, 255, 26))
	im.alpha_composite(drift)
	# SAPUAN ANGIN halus (streak diagonal)
	dw_ = ImageDraw.Draw(im, "RGBA")
	for _ in range(120):
		wx = rr.randint(0, W); wy = rr.randint(0, W); ln = rr.randint(30, 90)
		dw_.line([(wx, wy), (wx + ln, wy - int(ln * 0.25))], fill=(255, 255, 255, 30), width=1)

	# NODA MUTASI timur-laut (radial hijau di atas salju)
	cxm, cym = 150, 40
	nd = Image.new("RGBA", (W, W), (0, 0, 0, 0))
	dn = ImageDraw.Draw(nd)
	for rad, a in [(46, 70), (32, 90), (20, 130)]:
		dn.ellipse([(cxm - rad) * T, (cym - rad) * T, (cxm + rad) * T, (cym + rad) * T],
			fill=(120, 240, 150, a))
	im.alpha_composite(nd)

	sprites = []
	def taruh(img, cx, kaki, skala=1.0):
		if skala != 1.0:
			img = img.resize((max(1, int(img.width * skala)), max(1, int(img.height * skala))),
				Image.NEAREST)
		sprites.append((kaki * T, img, int(cx * T - img.width / 2), int(kaki * T - img.height)))

	ms = Image.open(os.path.join(RAW, "mountains", "submission",
		"mountains-v6-snow.png")).convert("RGBA")
	tebing = ms.crop((0, 512, 96, 700))
	gua = ms.crop((128, 160, 192, 288))
	# PUNGGUNG GLETSER: dua pita diagonal — deret tebing sepanjang garis
	def punggung(a, b, n):
		for i in range(n):
			t = i / float(n - 1)
			x = a[0] + (b[0] - a[0]) * t
			y = a[1] + (b[1] - a[1]) * t
			taruh(tebing, x, y + 1.5, 1.0)
	punggung((60, 30), (150, 120), 18)
	punggung((140, 70), (196, 96), 10)
	# mulut gua es (dungeon)
	for gx, gy in [(88, 42), (120, 82), (168, 68), (110, 118)]:
		taruh(gua, gx, gy, 1.0)

	# BENTENG STONEHEARTH selatan-tengah
	cd = Image.open(os.path.join(RAW, "castle8dark.png")).convert("RGBA")
	keep = cd.crop((192, 0, 320, 224))
	tower = cd.crop((96, 96, 160, 224))
	wall = cd.crop((0, 96, 96, 168))
	# tembok benteng (kotak) + keep + menara sudut
	for wx in range(86, 116, 3):
		taruh(wall, wx, 170, 1.0)
		taruh(wall, wx, 196, 1.0)
	taruh(keep, 100, 190, 1.2)
	for tx2 in (85, 116):
		taruh(tower, tx2, 172, 1.0)
		taruh(tower, tx2, 196, 1.0)

	# RERUNTUHAN tersebar (batu gelap didinginkan)
	for rx, ry in [(40, 30), (70, 150), (120, 150), (176, 140), (150, 168), (30, 92)]:
		taruh(geser_rona(wall, 16, 22, 30), rx, ry, 0.8)

	# INTI MUTASI (obelisk pendar) di kawah
	ob = Image.new("RGBA", (48, 120), (0, 0, 0, 0))
	do = ImageDraw.Draw(ob)
	do.polygon([(24, 0), (40, 26), (34, 112), (14, 112), (8, 26)], fill=(40, 70, 60, 255),
		outline=(18, 34, 30, 255))
	for yy in range(20, 108, 12):
		do.line([(14, yy), (34, yy - 5)], fill=(150, 240, 170, 255))
	do.ellipse([14, 38, 34, 70], fill=(190, 255, 205, 230))
	taruh(ob, cxm, cym + 1, 1.2)

	# MONSTER: mutan makin padat ke kawah; beast normal dekat benteng
	MON = os.path.join(RAW, "monsters", "lpc-monsters")
	ab = {n: frame0(os.path.join(MON, n + ".png")) for n in
		["eyeball", "big_worm", "small_worm", "slime", "snake"]}
	man = frame0(os.path.join(MON, "man_eater_flower.png"), 96).crop((16, 16, 96, 96))
	fw = Image.open(os.path.join(G, "sprites", "monsters", "frost_wyvern.png")).convert("RGBA").crop((0, 0, 128, 128))
	ff = Image.open(os.path.join(G, "sprites", "monsters", "frost_fox.png")).convert("RGBA").crop((0, 0, 64, 64))
	mut_fw = geser_rona(fw, -30, 40, -20)
	mut_ff = geser_rona(ff, -20, 50, -10)
	for _ in range(150):
		mx = rr.randint(6, NN - 6); my = rr.randint(6, NN - 6)
		dk = math.hypot(mx - cxm, my - cym)
		if rr.random() > max(0.05, 1.25 - dk / 85.0):
			continue
		if 82 <= mx <= 118 and 166 <= my <= 198:
			continue
		if dk < 60:                     # dekat kawah = aberasi + beast mutasi
			pick = rr.choice([ab["eyeball"], ab["big_worm"], man, ab["slime"],
				mut_fw, mut_ff, mut_ff])
			taruh(pick, mx, my, 1.1 if pick is man or pick is mut_fw else 1.2)
		elif dk < 110:                  # sedang = campur mutasi & beast
			pick = rr.choice([mut_ff, ff, ab["small_worm"], ab["snake"], ff])
			taruh(pick, mx, my, 1.1)
		else:                            # jauh = beast normal jarang
			if rr.random() < 0.5:
				taruh(ff, mx, my, 1.0)

	# KOLAM BEKU kecil tersebar (es LPC, bukan tambalan polos)
	for _ in range(14):
		px0 = rr.randint(10, NN - 14); py0 = rr.randint(10, NN - 14)
		if math.hypot(px0 - cxm, py0 - cym) < 30 or (82 <= px0 <= 118 and 160 <= py0 <= 200):
			continue
		rw = rr.randint(4, 8); rh = rr.randint(3, 6)
		mk = Image.new("L", (W, W), 0)
		ImageDraw.Draw(mk).ellipse([px0 * T, py0 * T, (px0 + rw) * T, (py0 + rh) * T], fill=255)
		im.paste(tiled(ice_full), (0, 0), mk)
		ImageDraw.Draw(im, "RGBA").ellipse([px0 * T, py0 * T, (px0 + rw) * T, (py0 + rh) * T],
			outline=(150, 180, 205, 180), width=4)

	# HUTAN GUNDUL BEKU — pohon gundul (repo) memberi siluet ke ladang kosong;
	# rumpun jarang, menjauhi benteng & kawah
	gundul = Image.open(os.path.join(G, "sprites", "props", "pohon_gundul.png")).convert("RGBA")
	pinus = Image.open(os.path.join(G, "sprites", "props", "pinus_pohon.png")).convert("RGBA")
	def di_danau(tx0, ty0):
		# uji kasar poligon danau (bounding + sisi kiri)
		return tx0 < 62 and 46 < ty0 < 152 and (tx0 - 4) * 1.0 < (60 - abs(ty0 - 100))
	for _ in range(60):
		tx0 = rr.randint(4, NN - 4); ty0 = rr.randint(4, NN - 4)
		dk = math.hypot(tx0 - cxm, ty0 - cym)
		if dk < 55 or (78 <= tx0 <= 120 and 158 <= ty0 <= 200) or di_danau(tx0, ty0):
			continue
		pohon = gundul if rr.random() < 0.7 else pinus
		# pinus disepuh salju (dipucatkan)
		if pohon is pinus:
			pohon = geser_rona(pohon, 40, 46, 50)
		taruh(pohon, tx0, ty0, rr.choice([0.8, 1.0, 1.1]))

	# KRISTAL ES (DIGAMBAR SENDIRI) — rumpun sian di gletser & sekitar kawah
	def kristal(besar):
		k = Image.new("RGBA", (int(20 * besar), int(30 * besar)), (0, 0, 0, 0))
		dk = ImageDraw.Draw(k)
		w2 = k.width
		for off, tint in [(-4, (120, 210, 236)), (3, (170, 232, 248)), (0, (200, 246, 255))]:
			cx2 = w2 // 2 + int(off * besar)
			dk.polygon([(cx2, 2), (cx2 + int(5 * besar), k.height - 4),
				(cx2 - int(5 * besar), k.height - 4)], fill=tint + (235,),
				outline=(60, 130, 160, 255))
		return k
	for _ in range(40):
		kx = rr.randint(4, NN - 4); ky = rr.randint(4, NN - 4)
		dk = math.hypot(kx - cxm, ky - cym)
		# padat dekat kawah (kristal terkorupsi) + acak di gletser
		if dk < 50:
			kk = geser_rona(kristal(rr.choice([1.0, 1.4])), -40, 40, -30)  # kristal mutasi hijau
			taruh(kk, kx, ky, 1.0)
		elif rr.random() < 0.25:
			taruh(kristal(rr.choice([0.8, 1.0, 1.2])), kx, ky, 1.0)

	# BATU ES (repo rock disepuh biru) + BANGKAI karavan (gambar-sendiri)
	rock = Image.open(os.path.join(G, "sprites", "props", "rock.png")).convert("RGBA")
	rock_es = geser_rona(rock, 6, 22, 40)
	for _ in range(50):
		rx0 = rr.randint(4, NN - 4); ry0 = rr.randint(4, NN - 4)
		if 80 <= rx0 <= 118 and 160 <= ry0 <= 200:
			continue
		taruh(rock_es, rx0, ry0, rr.choice([0.7, 1.0, 1.3]))
	def bangkai():
		b = Image.new("RGBA", (40, 26), (0, 0, 0, 0))
		db = ImageDraw.Draw(b)
		db.line([(4, 20), (36, 20)], fill=(210, 214, 210, 255), width=2)      # tulang belakang
		for rx2 in range(8, 34, 5):
			db.line([(rx2, 20), (rx2 - 4, 10)], fill=(198, 202, 198, 255))    # iga
			db.line([(rx2, 20), (rx2 + 4, 10)], fill=(198, 202, 198, 255))
		db.ellipse([2, 14, 12, 24], outline=(210, 214, 210, 255))             # tengkorak
		return b
	for _ in range(9):
		bx = rr.randint(10, NN - 10); by = rr.randint(10, NN - 10)
		if math.hypot(bx - cxm, by - cym) < 40 or (80 <= bx <= 118 and 160 <= by <= 200):
			continue
		taruh(bangkai(), bx, by, rr.choice([1.0, 1.3]))

	for kaki, img, x, y in sorted(sprites, key=lambda s: s[0]):
		im.alpha_composite(img, (x, max(0, y)))

	# AURORA — pita hijau-ungu tembus di langit utara (kesan dingin fantasi)
	aur = Image.new("RGBA", (W, W), (0, 0, 0, 0))
	da = ImageDraw.Draw(aur)
	for i, (col, yb) in enumerate([((90, 240, 170, 40), 6), ((150, 130, 240, 32), 22),
			((100, 220, 220, 28), 40)]):
		for x in range(0, W, 6):
			yy = yb * T + int(math.sin(x / 220.0 + i) * 5 * T)
			da.line([(x, yy - 4 * T), (x, yy + 4 * T)], fill=col, width=7)
	im.alpha_composite(aur)

	out = im.resize((W // 4, W // 4), Image.LANCZOS).convert("RGB")
	d = ImageDraw.Draw(out)
	d.rectangle([0, 0, out.width, 34], fill=(24, 34, 54))
	d.text((10, 5), "MOCKUP PETA PENUH STONEHEARTH 200x200 (#321) - benteng selatan -> ladang -> gletser+gua -> KAWAH MUTASI timur-laut",
		font=f(16), fill=ES)
	out.save(os.path.join(MOCK, "stonehearth_peta.png"))
	print("-> stonehearth_peta.png (%dx%d)" % out.size)


def main():
	kartu()
	blockout()
	mockup()
	peta()
	print("-> stonehearth_konsep.png + stonehearth_blockout.png + stonehearth_mockup.png")


if __name__ == "__main__":
	main()
