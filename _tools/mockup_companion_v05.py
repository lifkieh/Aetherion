# -*- coding: utf-8 -*-
"""MOCKUP RENCANA #295 — Companion irisan v0.5 (Sora & Arlen).

Komposit DI ATAS tangkap layar dunia sungguhan: sprite asli repo ditempel pada
koordinat yang direncanakan `reports/RENCANA_COMPANION_V05.md`, plus anotasi.
Bukan aset game — alat pratinjau keputusan Direktur. Bisa dijalankan ulang (#240).

Pakai: python _tools/mockup_companion_v05.py
Butuh: reports/mockup/base_{pemakaman,utara,wide}.png (ShotScene:
  pemakaman warp 790,1190 zoom 1.5 · utara warp 800,220 zoom 1.5 ·
  wide warp 1000,700 zoom 0.5)
"""
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
MOCK = os.path.join(ROOT, "reports", "mockup")
CHAR = os.path.join(ROOT, "game", "assets", "game", "sprites", "characters")
SPR = os.path.join(ROOT, "game", "assets", "game", "sprites")
FONT = os.path.join(ROOT, "game", "assets", "game", "fonts", "m5x7.ttf")

EMAS = (244, 197, 66, 255)
BIRU = (26, 33, 56, 235)
TINTA = (225, 230, 245, 255)
REDUP = (150, 158, 180, 255)
MERAH = (235, 120, 110, 255)
HIJAU = (140, 220, 150, 255)


def f(sz):
	return ImageFont.truetype(FONT, sz) if os.path.exists(FONT) else ImageFont.load_default()


def layar(warp, zoom, world):
	return (640 + (world[0] - warp[0]) * zoom, 360 + (world[1] - warp[1]) * zoom)


def frame_idle(tokoh):
	im = Image.open(os.path.join(CHAR, tokoh + "_idle.png")).convert("RGBA")
	return im.crop((0, 128, 64, 192))     # baris hadap-bawah, frame 0


def tempel(base, im, pos, skala):
	im = im.resize((int(im.width * skala), int(im.height * skala)), Image.NEAREST)
	base.alpha_composite(im, (int(pos[0] - im.width / 2), int(pos[1] - im.height)))


def label(d, pos, teks, warna=EMAS, sz=17, anchor="ma"):
	fo = f(sz)
	bb = d.textbbox(pos, teks, font=fo, anchor=anchor)
	d.rectangle([bb[0] - 5, bb[1] - 3, bb[2] + 5, bb[3] + 3], fill=BIRU, outline=warna)
	d.text(pos, teks, font=fo, fill=warna, anchor=anchor)


def panah(d, a, b, warna=EMAS):
	d.line([a, b], fill=warna, width=2)
	d.ellipse([b[0] - 4, b[1] - 4, b[0] + 4, b[1] + 4], fill=warna)


def judul(im, teks):
	d = ImageDraw.Draw(im)
	d.rectangle([0, 0, im.width, 40], fill=BIRU)
	d.text((16, 8), teks, font=f(24), fill=EMAS)


# ── 1. RITUAL SORA (malam) + adegan Nyai×Sora ────────────────────────────────
def m_ritual():
	warp, z = (790, 1190), 1.5
	im = Image.open(os.path.join(MOCK, "base_pemakaman.png")).convert("RGBA")
	d = ImageDraw.Draw(im, "RGBA")

	t1 = layar(warp, z, (814, 1139))       # titik ritual 1 — koordinat kanonik di kode (Ashbrook64:598)
	t2 = layar(warp, z, (624, 1240))       # titik ritual 2 (tengah pemakaman, baris nisan terbuka)
	# radius temani 120 px dunia
	r = 120 * z
	d.ellipse([t1[0] - r, t1[1] - r, t1[0] + r, t1[1] + r], outline=(244, 197, 66, 140), width=2)
	tempel(im, frame_idle("sora"), t1, 1.5)
	lent = Image.open(os.path.join(SPR, "lpc32", "lentera32.png")).convert("RGBA")
	for w in [(788, 1148), (842, 1134), (624, 1248)]:
		tempel(im, lent, layar(warp, z, w), 1.0)
	nyai_pos = layar(warp, z, (852, 1152))
	tempel(im, frame_idle("nyai"), nyai_pos, 1.5)

	d = ImageDraw.Draw(im, "RGBA")
	judul(im, "MOCKUP S1+S4 - Ritual Sora, pemakaman Ashbrook (malam 19-24 WIB)")
	label(d, (t1[0], t1[1] - 108), "SORA - titik ritual 1 (814,1139) - sudut TL yang dikosongkan nisan")
	label(d, (t1[0], t1[1] + 30), "lingkar temani 120px - 10 dtk - menjauh = ulang", REDUP, 15)
	label(d, (t2[0], t2[1] - 8), "titik ritual 2 (624,1240)", REDUP, 15)
	panah(d, (t1[0] - 40, t1[1] + 62), t2)
	label(d, (nyai_pos[0] - 30, nyai_pos[1] - 120),
		"S4: Kamis malam - NYAI di sebelahnya, dua lampu, NOL dialog", HIJAU, 15, "ma")
	label(d, (640, 660), "\"Anak berlentera [E]\" - nama keluar SETELAH kenal (D-3)", TINTA, 16)
	im.convert("RGB").save(os.path.join(MOCK, "mock_1_ritual_sora.png"))


# ── 2. UTARA: batu penanda + Arlen siang ─────────────────────────────────────
def m_utara():
	warp, z = (800, 220), 1.5
	im = Image.open(os.path.join(MOCK, "base_utara.png")).convert("RGBA")
	batu = layar(warp, z, (820, 96))
	arlen = layar(warp, z, (868, 140))
	surat = layar(warp, z, (820, 240))

	# batu penanda: mock — balok batu tegak (aset final dari gen_batu_penanda.py)
	d = ImageDraw.Draw(im, "RGBA")
	bx, by = batu
	d.rectangle([bx - 12, by - 42, bx + 12, by], fill=(120, 118, 112, 255),
		outline=(60, 58, 54, 255), width=2)
	d.rectangle([bx - 8, by - 34, bx - 2, by - 12], fill=(150, 148, 140, 255))  # sisi aus
	tempel(im, frame_idle("arlen"), arlen, 1.5)

	d = ImageDraw.Draw(im, "RGBA")
	judul(im, "MOCKUP S3 - Batu penanda & Arlen siang, jalan utara")
	label(d, (bx, by - 64), "BATU PENANDA (820,96) - \"sisi utaranya lebih aus\"")
	label(d, (arlen[0], arlen[1] - 108), "ARLEN siang (868,140) - di sisi batu, memandangi rute")
	label(d, (arlen[0], arlen[1] + 14),
		"bicara 3x -> titip SURAT LAMARAN KURIR ke Sela (K5)", HIJAU, 15)
	label(d, (surat[0], surat[1] + 10), "titik surat Merrit (820,240) - SEGARIS: rute utara", REDUP, 15)
	panah(d, (bx, by + 6), (surat[0], surat[1] - 8), REDUP)
	label(d, (640, 660), "malam: Arlen kembali ke (726,598) - kesaksian orang Merrit tetap di sana", TINTA, 15)
	im.convert("RGB").save(os.path.join(MOCK, "mock_2_arlen_utara.png"))


# ── 3. PETA LETAK (wide) ─────────────────────────────────────────────────────
def m_wide():
	warp, z = (1000, 700), 0.5
	im = Image.open(os.path.join(MOCK, "base_wide.png")).convert("RGBA")
	d = ImageDraw.Draw(im, "RGBA")
	judul(im, "MOCKUP - Peta letak companion v0.5 di Ashbrook (#295)")
	titik = [
		((820, 96),  "batu penanda", EMAS),
		((868, 140), "Arlen siang", EMAS),
		((726, 598), "Arlen malam + kesaksian", REDUP),
		((814, 1139), "ritual Sora (malam)", HIJAU),
		((624, 1240), "titik ritual 2", HIJAU),
		((672, 1024), "Sora siang", REDUP),
		((1480, 560), "perpustakaan Elyn (#294)", REDUP),
	]
	for w, t, c in titik:
		p = layar(warp, z, w)
		d.ellipse([p[0] - 6, p[1] - 6, p[0] + 6, p[1] + 6], outline=c, width=3)
		label(d, (p[0], p[1] + 10), t, c, 15)
	im.convert("RGB").save(os.path.join(MOCK, "mock_3_peta_letak.png"))


# ── 4. UI KITAB: tiga juru tulis + jebakan Sora ──────────────────────────────
def m_kitab():
	W, H = 1280, 720
	im = Image.new("RGB", (W, H), (14, 18, 32))
	d = ImageDraw.Draw(im)
	judul_im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	d.text((16, 10), "MOCKUP S2 - Kitab: layar pilih juru tulis + jebakan Sora (K2 kejam penuh)",
		font=f(24), fill=EMAS)

	def panel(x, y, w, h, jud):
		d.rounded_rectangle([x, y, x + w, y + h], 8, fill=(24, 30, 52), outline=EMAS, width=2)
		d.text((x + 18, y + 12), jud, font=f(21), fill=EMAS)

	def tombol(x, y, teks, w=380, warna=TINTA):
		d.rounded_rectangle([x, y, x + w, y + 34], 6, fill=(38, 46, 76), outline=(90, 100, 140))
		d.text((x + 12, y + 8), teks, font=f(18), fill=warna)

	# panel kiri: pilih jalur (3 tombol)
	panel(40, 70, 560, 380, "Rumah Singgah Fane - tercoret")
	d.text((58, 108), "Menulis ulang butuh bekas. Pilih tangan yang menulis:", font=f(16), fill=REDUP)
	tombol(58, 140, "Tulis dengan tanganmu sendiri   (3 jenis bekas)")
	d.text((58, 180), "loss terbesar - selalu tersedia (#228)", font=f(14), fill=REDUP)
	tombol(58, 210, "Biarkan Elyn menanggung   (2 jenis)")
	d.text((58, 250), "gerbang: elyn_kenal (#294) - umurnya berkurang", font=f(14), fill=REDUP)
	tombol(58, 280, "Minta Sora menuliskannya   (2 jenis)", warna=HIJAU)
	d.text((58, 320), "BARU - gerbang: sora_kenal - keterbukaan #259 dulu:", font=f(14), fill=HIJAU)
	d.text((58, 342), '"Ia merasakan lebih banyak dari yang ia ceritakan,', font=f(15), fill=TINTA)
	d.text((58, 362), ' dan tiap halaman menambah beratnya."', font=f(15), fill=TINTA)
	d.text((58, 402), "belum kenal -> tombol TIDAK ADA:", font=f(14), fill=REDUP)
	d.text((58, 422), '"Tak ada juru tulis lain yang kau kenal."', font=f(15), fill=REDUP)

	# panel kanan: jebakan
	panel(660, 70, 580, 500, "JEBAKAN - dua halaman tercoret sekaligus")
	d.text((678, 110), "Sora (bukan tombol — kalimatnya sendiri):", font=f(15), fill=REDUP)
	d.text((678, 134), '"Aku bisa coba dua-duanya."', font=f(22), fill=TINTA)
	tombol(678, 180, "Biarkan ia mencoba", 250)
	tombol(958, 180, "Pilihkan satu", 250)
	d.line([(800, 226), (800, 258)], fill=MERAH, width=2)
	d.text((678, 262), "-> menulis SATU (yang buktinya cukup),", font=f(16), fill=TINTA)
	d.text((678, 284), "   GAGAL pada yang kedua.", font=f(16), fill=MERAH)
	d.text((678, 310), "   NOL pengumuman. NOL kalimat. (K2)", font=f(16), fill=MERAH)
	d.text((678, 332), "   sora_beban += 2   [D-4: tak pernah tampil]", font=f(15), fill=REDUP)
	d.line([(1080, 226), (1080, 258)], fill=HIJAU, width=2)
	d.text((958, 262), "-> menulis satu.", font=f(16), fill=TINTA)
	d.text((958, 284), '   "...Oke." — tak bertanya kenapa.', font=f(16), fill=HIJAU)
	d.text((958, 306), "   sora_beban += 1", font=f(15), fill=REDUP)
	d.text((678, 380), "Halaman yang tak tertulis: TETAP TERCORET.", font=f(16), fill=TINTA)
	d.text((678, 402), "Bekas Otha terus membusuk (R3). Dunia tidak menunggu.", font=f(15), fill=REDUP)
	d.text((678, 440), "loss scribe-Sora = loss_by_missing_kind yang ada (K3)", font=f(14), fill=REDUP)
	d.text((678, 462), "sinyal A2 (bila kenal): lampu ekstra malam itu +", font=f(14), fill=REDUP)
	d.text((678, 482), '"Nggak tahu. Cuma... ada yang perlu."', font=f(15), fill=TINTA)

	d.text((40, 620), "Semua baris = _provisional (K7) — Direktur timpa lewat data kapan saja.",
		font=f(16), fill=REDUP)
	im.save(os.path.join(MOCK, "mock_4_kitab_sora.png"))


if __name__ == "__main__":
	m_ritual()
	m_utara()
	m_wide()
	m_kitab()
	print("-> reports/mockup/mock_{1..4}*.png")
