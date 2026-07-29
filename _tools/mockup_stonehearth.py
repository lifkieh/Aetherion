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
		"Aset: snow/ice repo · [LPC] Mountains (gletser/gua, CC-BY-SA) · Castle Mega-Pack (benteng) · [LPC] Monsters (aberasi) · frost-beast RECOLOR mutasi · obelisk gambar-sendiri",
		font=f(13), fill=REDUP)
	out.save(os.path.join(MOCK, "stonehearth_mockup.png"))


def main():
	kartu()
	blockout()
	mockup()
	print("-> stonehearth_konsep.png + stonehearth_blockout.png + stonehearth_mockup.png")


if __name__ == "__main__":
	main()
