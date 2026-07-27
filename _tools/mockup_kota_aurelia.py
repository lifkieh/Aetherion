# -*- coding: utf-8 -*-
"""KARTU KONSEP 9 KOTA AURELIA + PETA DUNIA (#307) — alat coretan Direktur.

Satu kartu per kota (zona skematik + palet + aroma + landmark) dari sheet
CITY_BIBLE 002-010, plus peta dunia usulan pemetaan kerajaan -> wilayah
engine. Bukan aset game. Bisa dijalankan ulang (#240).
"""
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")
EMAS = (244, 197, 66)
TINTA = (230, 234, 246)
REDUP = (150, 156, 178)
BG = (15, 19, 33)


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


KOTA = [
	("002 GOLDHAVEN", "Valenford - Crossroads of Aurelia - 35.000", (222, 178, 92),
		"debu jalan + rempah karavan + koin berpindah tangan",
		[("gerbang karavan x4 (cincin luar)", (222, 178, 92)),
		("PASAR AGUNG (jantung, radial)", (240, 208, 130)),
		("deret serikat & bank", (188, 148, 82)),
		("bawah-kota: bayang NETHERDEEP", (96, 82, 120))],
		"landmark: MENARA TIMBANGAN - empat jalan bertemu di bawahnya"),
	("003 AURELIS", "Lumeria - City of Ten Thousand Books - 52.000", (168, 196, 236),
		"kertas tua + lilin baca + hujan di pualam",
		[("PERPUSTAKAAN AGUNG (spiral pusat)", (222, 230, 246)),
		("teras akademi berundak", (168, 196, 236)),
		("kampung juru salin", (140, 160, 200)),
		("dermaga sungai tinta", (100, 120, 170))],
		"landmark: menara-spiral buku; lampu baca tak pernah padam"),
	("004 STONEHEARTH", "Durnhold - Jantung Batu - 28.000", (170, 150, 140),
		"arang + besi panas + air tambang dingin",
		[("gerbang benteng (satu-satunya)", (170, 150, 140)),
		("kota bertingkat KE DALAM gunung", (140, 120, 112)),
		("aula tempa (cahaya bara)", (226, 120, 70)),
		("mulut tambang tua", (90, 80, 76))],
		"landmark: PALU LELUHUR tergantung di aula — tak pernah diayun lagi"),
	("005 ROSECOURT", "Rosenhal - Taman Berpedang - 31.000", (226, 140, 168),
		"mawar penuh + minyak asah pedang",
		[("boulevard taman mawar", (226, 140, 168)),
		("GELANGGANG DUEL (tengah)", (200, 200, 210)),
		("distrik bangsawan", (180, 120, 150)),
		("kampung penempa bilah", (150, 150, 160))],
		"landmark: gelanggang marmer — petak duel dikelilingi mawar putih"),
	("006 THORNWATCH", "Thornreach - Mata Perbatasan - 9.000", (150, 130, 90),
		"resin pinus + kulit samak + darah kering di papan misi",
		[("palisade kayu (semua menghadap KELUAR)", (150, 130, 90)),
		("aula pemburu + papan misi", (120, 104, 74)),
		("kandang & samak", (104, 90, 66)),
		("gerbang tanah liar (ke gurun)", (190, 160, 110))],
		"landmark: MENARA JAGA TUNGGAL - loncengnya cuma dibunyikan mundur"),
	("007 TIDEGATE", "Veskar - Gerbang Pasang - 44.000", (110, 150, 190),
		"garam + tar kapal + tinta kontrak basah",
		[("dermaga raksasa berjajar", (110, 150, 190)),
		("deret bank & rumah kontrak", (190, 170, 120)),
		("pasar ikan & gudang", (140, 150, 160)),
		("kampung pelaut", (90, 110, 140))],
		"landmark: GERBANG PASANG - pintu laut raksasa yang ikut naik-turun air"),
	("008 VEILMARK", "Astraveil - Kota Bertirai - 22.000", (168, 140, 200),
		"kabut dingin + dupa + lilin baru dipadamkan",
		[("kanal berkabut (jalan = perahu)", (140, 150, 190)),
		("rumah-rumah bertirai kain", (168, 140, 200)),
		("ISTANA TIRAI (tak pernah terlihat utuh)", (120, 100, 150)),
		("pasar bisik", (100, 90, 120))],
		"landmark: jembatan seribu tirai - tiap tirai satu rahasia yang dibeli"),
	("009 HOLLOWSPIRE", "INDEPENDEN - Menara Berongga - 12.000", (120, 170, 170),
		"batu basah + angin dalam yang bernyanyi",
		[("kota VERTIKAL di dinding rongga", (120, 170, 170)),
		("lift & tangga spiral", (150, 190, 185)),
		("puncak: cincin bangsawan", (190, 210, 200)),
		("dasar: belum terpetakan", (60, 80, 84))],
		"landmark: RONGGA itu sendiri - menara purba, pembuatnya tak dikenal"),
	("010 SKYREST", "INDEPENDEN - Peristirahatan Langit - 6.000", (190, 210, 235),
		"angin tipis + tali basah + teh mendidih di ketinggian",
		[("plato tinggi + menara pandang", (190, 210, 235)),
		("kota tali & kanvas", (210, 200, 180)),
		("penginapan para pendaki", (170, 180, 200)),
		("tepi jurang: altar angin", (140, 160, 190))],
		"landmark: TIANG LANGIT - tambatan balon & doa dalam satu tiang"),
]


def kartu(idx, nama, sub, warna, aroma, zona, landmark):
	im = Image.new("RGB", (640, 420), BG)
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, 640, 46], fill=(26, 33, 56))
	d.text((14, 6), nama, font=f(26), fill=EMAS)
	d.text((14, 50), sub, font=f(15), fill=REDUP)
	# skema zona: cincin/blok sederhana per kota
	x0, y0 = 20, 84
	for i, (label, w) in enumerate(zona):
		pad = i * 26
		d.rounded_rectangle([x0 + pad, y0 + pad, 330 - pad, 330 - pad], 10,
			outline=w + (255,), width=4, fill=w + (36,))
	for i, (label, w) in enumerate(zona):
		d.rectangle([352, 96 + i * 34, 368, 112 + i * 34], fill=w + (255,))
		d.text((376, 94 + i * 34), label, font=f(14), fill=TINTA)
	d.text((20, 344), "AROMA: " + aroma, font=f(14), fill=(240, 208, 150))
	d.text((20, 368), landmark, font=f(14), fill=TINTA)
	d.text((20, 394), "status: SHEET kanon siap (CITY_BIBLE) - menunggu coretan -> blockout -> eksekusi",
		font=f(12), fill=REDUP)
	im.save(os.path.join(MOCK, "kota_%s.png" % nama.split()[0]))
	return im


def peta_dunia(kartu_list):
	im = Image.new("RGB", (1280, 760), BG)
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, 1280, 44], fill=(26, 33, 56))
	d.text((14, 6), "PETA DUNIA AURELIA (usulan #307) - 7 kerajaan -> wilayah engine - o=hidup +=menunggu",
		font=f(23), fill=EMAS)
	wil = [
		("VALENFORD (sabuk hijau)", (140, 190, 120), (60, 90, 560, 400),
			["o Ashbrook (001)", "o Greenvale (hub)", "+ GOLDHAVEN (002)"]),
		("CANDYVEIL - tanah tak-diklaim", (233, 150, 190), (60, 430, 350, 660),
			["o Kota Gula + pemakaman Sora"]),
		("DURNHOLD -> Frostpeak", (170, 160, 200), (600, 60, 900, 240),
			["+ STONEHEARTH (004)", "wilayah SUDAH ada"]),
		("THORNREACH -> Desert", (200, 170, 110), (600, 270, 900, 440),
			["+ THORNWATCH (006)", "wilayah SUDAH ada"]),
		("VESKAR -> Storm Island", (110, 150, 190), (600, 470, 900, 660),
			["+ TIDEGATE (007)", "wilayah SUDAH ada"]),
		("LUMERIA (baru)", (168, 196, 236), (940, 60, 1220, 220),
			["+ AURELIS (003)"]),
		("ASTRAVEIL (baru)", (168, 140, 200), (940, 250, 1220, 400),
			["+ VEILMARK (008)"]),
		("INDEPENDEN (baru)", (150, 180, 175), (940, 430, 1220, 660),
			["+ HOLLOWSPIRE (009)", "+ SKYREST (010)"]),
	]
	for nama, w, box, isi in wil:
		d.rounded_rectangle(box, 12, outline=w + (255,), width=3, fill=w + (34,))
		d.text((box[0] + 12, box[1] + 8), nama, font=f(17), fill=TINTA)
		for i, b in enumerate(isi):
			d.text((box[0] + 16, box[1] + 36 + i * 24), b, font=f(15),
				fill=(140, 220, 150) if b.startswith("o") else (240, 208, 150))
	d.text((60, 690), "Urutan eksekusi usulan: GOLDHAVEN -> Stonehearth/Thornwatch/Tidegate (menunggangi wilayah yang sudah ada) -> Aurelis -> Veilmark -> Hollowspire/Skyrest",
		font=f(15), fill=REDUP)
	d.text((60, 714), "Tiap kota: sheet (sudah) -> KARTU KONSEP (halaman ini) -> coretan Direktur -> blockout -> mockup aset -> eksekusi (#240 + #151b)",
		font=f(15), fill=REDUP)
	im.save(os.path.join(MOCK, "peta_dunia_aurelia.png"))


def main():
	kartu_ims = []
	for i, k in enumerate(KOTA):
		kartu_ims.append(kartu(i, *k))
	# lembar kontak 3x3
	kontak = Image.new("RGB", (640 * 3 + 32, 420 * 3 + 32), BG)
	for i, im in enumerate(kartu_ims):
		kontak.paste(im, (8 + (i % 3) * 648, 8 + (i // 3) * 428))
	kontak.save(os.path.join(MOCK, "kota_kontak_9.png"))
	peta_dunia(kartu_ims)
	print("-> reports/mockup/kota_*.png + kota_kontak_9.png + peta_dunia_aurelia.png")


if __name__ == "__main__":
	main()
