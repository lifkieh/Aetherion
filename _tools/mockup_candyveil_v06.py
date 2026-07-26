# -*- coding: utf-8 -*-
"""MOCKUP PERLUASAN CANDYVEIL (v0.6b · roadmap #298) — DUA VARIAN TATA LETAK.

Kanon sheet #013: Sora lahir di PINGGIRAN Candyveil — bukan di bagian manis
kota gula, melainkan tepiannya yang terlupakan, dekat pemakaman tua; konflik:
kota ingin MENGGUSUR pemakaman itu. Candyveil sekarang = padang liar permen
(70x52 petak, nol kota). Perluasan menambah KOTA + PINGGIRAN + PEMAKAMAN.

Skematik zona + sprite asli repo sebagai bahasa visual. Alat keputusan
Direktur, bukan aset game. Bisa dijalankan ulang (#240).
"""
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
PROP = os.path.join(ROOT, "game", "assets", "game", "sprites", "props")
CHAR = os.path.join(ROOT, "game", "assets", "game", "sprites", "characters")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")

EMAS = (244, 197, 66)
TINTA = (228, 232, 245)
REDUP = (146, 152, 175)
BG = (16, 20, 34)

# palet zona — bahasa: makin manis makin jenuh; yang dilupakan kehilangan warna
Z_KOTA = (233, 140, 176)      # kota gula — pink jenuh
Z_PLAZA = (247, 196, 145)     # plaza karamel
Z_PINGGIR = (146, 112, 132)   # pinggiran — pink yang kehilangan gula
Z_MAKAM = (96, 108, 96)       # pemakaman — kelabu lumut
Z_LIAR = (128, 96, 148)       # padang liar (map sekarang)
Z_JALAN = (196, 168, 118)
Z_LADANG = (214, 170, 200)    # ladang gula — mesin penggusuran


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def spr(nama, dari=PROP):
	p = os.path.join(dari, nama)
	return Image.open(p).convert("RGBA") if os.path.exists(p) else None


def tempel(base, im, pos, skala=2.0):
	if im is None:
		return
	im = im.resize((int(im.width * skala), int(im.height * skala)), Image.NEAREST)
	base.alpha_composite(im, (int(pos[0] - im.width / 2), int(pos[1] - im.height)))


def tokoh(nama):
	p = os.path.join(CHAR, nama + "_idle.png")
	if not os.path.exists(p):
		return None
	return Image.open(p).convert("RGBA").crop((0, 128, 64, 192))


def zona(d, box, warna, judul_z, sub=""):
	d.rounded_rectangle(box, 10, fill=warna + (70,), outline=warna + (255,), width=3)
	d.text((box[0] + 12, box[1] + 8), judul_z, font=f(21), fill=TINTA)
	if sub:
		d.text((box[0] + 12, box[1] + 34), sub, font=f(14), fill=REDUP)


def dasar(judul_teks):
	im = Image.new("RGBA", (1280, 760), BG + (255,))
	d = ImageDraw.Draw(im, "RGBA")
	d.rectangle([0, 0, 1280, 42], fill=(26, 33, 56, 255))
	d.text((16, 8), judul_teks, font=f(25), fill=EMAS)
	return im, d


def hias(im, d):
	# bahasa visual: sprite permen asli repo di zona kota, nisan di pemakaman
	for pos in [(150, 210), (240, 165), (330, 225)]:
		tempel(im, spr("lollipop.png"), pos, 1.6)
	tempel(im, spr("candy_cane.png"), (200, 250), 1.6)
	tempel(im, spr("gumdrop.png"), (285, 255), 1.6)


def varian_a():
	im, d = dasar("VARIAN A - GRADASI MEMUDAR  (barat manis -> timur dilupakan; jalan lurus = garis waktu)")
	# zona barat->timur
	zona(d, (60, 100, 420, 420), Z_KOTA, "KOTA GULA", "8-10 bangunan permen jenuh - toko sirup, balai, penginapan wafel")
	zona(d, (180, 420, 360, 520), Z_PLAZA, "plaza karamel", "air mancur sirup")
	zona(d, (420, 140, 760, 420), Z_PINGGIR, "PINGGIRAN", "rumah kusam warna luntur - 2 kosong - warga tua")
	zona(d, (760, 100, 1120, 340), Z_MAKAM, "PEMAKAMAN TUA + GUBUK SORA", "nisan aus - pagar patah - RUMAH SORA menempel tembok")
	zona(d, (420, 470, 1120, 600), Z_LADANG, "LADANG GULA BARU", "mesin penggusuran: tiap musim MAJU SEPETAK ke utara")
	zona(d, (60, 620, 1120, 720), Z_LIAR, "PADANG LIAR (map sekarang, 70x52)", "monster + lolipop liar - jadi SELATAN wilayah")
	# jalan
	d.rectangle([60, 430, 1120, 452], fill=Z_JALAN + (230,))
	d.text((560, 430), "jalan gula", font=f(14), fill=(70, 55, 30))
	d.rectangle([1120, 380, 1200, 452], fill=Z_JALAN + (230,))
	d.text((1124, 456), "-> Greenvale", font=f(15), fill=REDUP)
	hias(im, d)
	d = ImageDraw.Draw(im, "RGBA")
	for pos in [(830, 220), (900, 260), (980, 210), (1050, 250)]:
		tempel(im, spr("nisan_aus.png"), pos, 1.6)
	tempel(im, tokoh("sora"), (1080, 190), 1.4)
	d = ImageDraw.Draw(im, "RGBA")
	d.text((1010, 120), "SORA pulang ke sini (v0.6b)", font=f(15), fill=(140, 220, 150))
	# papan penggusuran
	d.rectangle([778, 350, 1000, 372], fill=(60, 45, 25, 255))
	d.text((786, 353), "PAPAN KOTA: \"LAHAN PERLUASAN - MUSIM DEPAN\"", font=f(13), fill=(240, 220, 170))
	d.text((60, 730), "Tesis A: pelupaan = GARIS. Berjalan ke timur = berjalan mundur di ingatan kota. Penggusuran mendorong dari selatan.", font=f(15), fill=REDUP)
	im.convert("RGB").save(os.path.join(MOCK, "candyveil_varian_a.png"))


def varian_b():
	im, d = dasar("VARIAN B - LINGKAR GULA  (kota manis di tengah; pinggiran melingkar; pemakaman terjepit ladang)")
	# cincin dulu, kota di atasnya — urutan gambar = urutan makna
	zona(d, (200, 120, 1080, 560), Z_PINGGIR, "", "")
	d.text((230, 130), "CINCIN PINGGIRAN - makin keluar makin pudar", font=f(17), fill=TINTA)
	zona(d, (420, 180, 860, 470), Z_KOTA, "KOTA GULA (pusat)", "8-10 bangunan permen - warna paling jenuh")
	zona(d, (560, 330, 740, 430), Z_PLAZA, "plaza karamel", "")
	zona(d, (860, 470, 1180, 660), Z_MAKAM, "PEMAKAMAN + GUBUK SORA", "TERJEPIT: ladang gula sudah memakan pagarnya")
	zona(d, (560, 560, 860, 680), Z_LADANG, "LADANG GULA", "mengunyah dari barat")
	zona(d, (60, 590, 520, 720), Z_LIAR, "PADANG LIAR (map sekarang)", "barat-daya wilayah")
	d.rectangle([100, 300, 420, 322], fill=Z_JALAN + (230,))
	d.text((110, 326), "<- Greenvale", font=f(15), fill=REDUP)
	hias(im, d)
	d = ImageDraw.Draw(im, "RGBA")
	for pos in [(940, 560), (1010, 600), (1090, 555)]:
		tempel(im, spr("nisan_aus.png"), pos, 1.6)
	tempel(im, tokoh("sora"), (1130, 540), 1.4)
	d = ImageDraw.Draw(im, "RGBA")
	d.text((880, 480), "SORA", font=f(15), fill=(140, 220, 150))
	d.text((60, 730), "Tesis B: pelupaan = TEPI. Kota tak pernah melihat pemakamannya sendiri — pemain harus MEMUTARI gula untuk menemukannya.", font=f(15), fill=REDUP)
	im.convert("RGB").save(os.path.join(MOCK, "candyveil_varian_b.png"))


if __name__ == "__main__":
	varian_a()
	varian_b()
	print("-> reports/mockup/candyveil_varian_{a,b}.png")
