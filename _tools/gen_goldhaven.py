# -*- coding: utf-8 -*-
"""ASET GOLDHAVEN v3 — dirakit dari [LPC] Castle Mega-Pack (#313).

v2 (rakitan LPC Revised + ornamen gambar-sendiri) DITOLAK Direktur ("jelek
banget") sekaligus putusan lisensi baru: CC-BY-SA DIPERBOLEHKAN (menular
diterima, termasuk peta & kota). Maka bahan naik kelas:

  "[LPC] Castle Mega-Pack" oleh bluecarrot16 — CC-BY-SA 3.0
  http://opengameart.org/content/lpc-castle-mega-pack
  berdasarkan karya: Hyptosis, Zabin, Daniel Cook; Evert, Xenodora,
  Lanea Zimmerman (Sharm); theidiotmachine; Daniel Armstrong (HughSpectrum).

Potongan bernama + rect kalibrasi mata: _tools/gen_goldhaven_potong.py.
Sprite turunan di game/assets/game/sprites/goldhaven ikut CC-BY-SA 3.0.
Gambar-sendiri yang TERSISA (deklarasi): panji kota, lambang timbangan,
kios_dagang, segel_pintu. #240: generator ter-commit.
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gen_goldhaven_potong import muat, potong

REPO = os.path.abspath(os.path.join(HERE, ".."))
OUT = os.path.join(REPO, "game", "assets", "game", "sprites", "goldhaven")

G1 = (255, 224, 130, 255)
G2 = (230, 182, 74, 255)
G3 = (158, 116, 38, 255)
NILA = (46, 64, 120, 255)
NILA_G = (30, 42, 84, 255)


# ─────────────────────────────────────────────── perkakas rakit
def ubin(piece, w, h):
	"""Isi bidang w×h dengan piece diulang (potong sisa di tepi)."""
	im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	for y in range(0, h, piece.height):
		for x in range(0, w, piece.width):
			im.alpha_composite(piece.crop((0, 0, min(piece.width, w - x),
				min(piece.height, h - y))), (x, y))
	return im


def baris(piece, w):
	"""Satu baris piece diulang mendatar selebar w."""
	return ubin(piece, w, piece.height)


def tempel_kaki(kanvas, im, cx, y_kaki):
	"""Tempel dengan titik tengah-bawah di (cx, y_kaki)."""
	kanvas.alpha_composite(im, (cx - im.width // 2, y_kaki - im.height))


def panji(h=34):
	"""Panji kota (GAMBAR SENDIRI): biru royal + lambang timbangan emas."""
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


def lambang_timbangan(s=22):
	"""GAMBAR SENDIRI — jiwa kota."""
	im = Image.new("RGBA", (s, s), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	c = s // 2
	d.line([(3, c - 4), (s - 4, c - 4)], fill=G2, width=2)
	d.line([(c, c - 7), (c, c + 5)], fill=G2, width=2)
	for cx in (4, s - 5):
		d.arc([cx - 4, c - 4, cx + 4, c + 4], 0, 180, fill=G1, width=2)
	return im


def menara_pengapit(P, tinggi_badan, kerucut_key="kerucut_biru", lebar_kerucut=76):
	"""Menara kotak diperpanjang + kerucut pack + panji."""
	t = P["tower_kotak"]
	badan_w = t.width
	kr = P[kerucut_key].resize((lebar_kerucut,
		int(P[kerucut_key].height * lebar_kerucut / P[kerucut_key].width)), Image.NEAREST)
	kr_h = min(kr.height, 150)
	kr = kr.crop((0, 0, kr.width, kr_h)) if kr.height > kr_h else kr
	im = Image.new("RGBA", (max(badan_w, kr.width) + 14, tinggi_badan + kr_h - 10),
		(0, 0, 0, 0))
	x0 = (im.width - badan_w) // 2
	# badan: isian dinding lalu mahkota menara asli (battlement ikut)
	isi = ubin(P["wall_batu"].crop((0, 0, badan_w, P["wall_batu"].height)),
		badan_w, tinggi_badan)
	im.alpha_composite(isi, (x0, im.height - tinggi_badan))
	im.alpha_composite(t, (x0, im.height - tinggi_badan - 0))
	im.alpha_composite(kr, ((im.width - kr.width) // 2, 0))
	im.alpha_composite(panji(30), (im.width - 13, kr_h - 24))
	return im


# ─────────────────────────────────────────────── gedung-gedung
def serikat(P):
	"""Serikat Pusat: istana plester + cornice + 2 gotik putih + pintu agung,
	diapit dua menara kastil berkerucut biru."""
	bw, bh = 160, 232
	badan = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
	badan.alpha_composite(ubin(P["wall_plester"], bw, bh), (0, 0))
	badan.alpha_composite(baris(P["balustrade"], bw), (0, 0))
	badan.alpha_composite(baris(P["cornice"], bw), (0, 30))
	g = P["gotik_putih"]
	badan.alpha_composite(g.resize((66, 117), Image.NEAREST), (8, 44))
	badan.alpha_composite(g.resize((66, 117), Image.NEAREST), (bw - 74, 44))
	tempel_kaki(badan, P["pintu_agung"], bw // 2, bh)
	badan.alpha_composite(lambang_timbangan(24), (bw // 2 - 12, 44))
	mn = menara_pengapit(P, 190)
	im = Image.new("RGBA", (bw + 2 * mn.width - 24, max(bh + 40, mn.height)),
		(0, 0, 0, 0))
	im.alpha_composite(badan, ((im.width - bw) // 2, im.height - bh))
	im.alpha_composite(mn, (0, im.height - mn.height))
	im.alpha_composite(mn, (im.width - mn.width, im.height - mn.height))
	return im


def bank(P):
	"""Bank: plester + balustrade + jendela besar ×2 + pintu kofer + kerucut emas kecil."""
	bw, bh = 160, 250
	im = Image.new("RGBA", (bw, bh + 40), (0, 0, 0, 0))
	im.alpha_composite(ubin(P["wall_plester"], bw, bh), (0, 40))
	im.alpha_composite(baris(P["balustrade"], bw), (0, 40))
	im.alpha_composite(baris(P["cornice"], bw), (0, 40 + 32))
	jb = P["jendela_besar"]
	im.alpha_composite(jb, (8, 84))
	im.alpha_composite(jb, (bw - jb.width - 8, 84))
	tempel_kaki(im, P["pintu_kofer"], bw // 2, bh + 40)
	im.alpha_composite(P["jendela_tirai"].resize((50, 78), Image.NEAREST), (10, bh - 62))
	im.alpha_composite(P["jendela_tirai"].resize((50, 78), Image.NEAREST), (bw - 60, bh - 62))
	# kerucut sudut = kerucut emas BESAR diperkecil — crop "_s" di baris atlas
	# rapat selalu membawa sliver tetangga (mata v3)
	ke = P["kerucut_emas"].resize((44, 108), Image.NEAREST)
	im.alpha_composite(ke, (2, 40 - ke.height + 16))
	im.alpha_composite(ke, (bw - ke.width - 2, 40 - ke.height + 16))
	im.alpha_composite(lambang_timbangan(22), (bw // 2 - 11, 52))
	return im


def rumah_kontrak(P):
	"""Rumah Kontrak: menara bundar tinggi + kerucut biru + lancet biru."""
	t = P["tower_bundar"]
	badan_h = 220
	kr = P["kerucut_biru"].resize((84, 208), Image.NEAREST).crop((0, 0, 84, 150))
	im = Image.new("RGBA", (max(t.width, kr.width) + 12, badan_h + 140), (0, 0, 0, 0))
	x0 = (im.width - t.width) // 2
	silinder = t.crop((0, 40, t.width, 120))
	for y in range(im.height - badan_h, im.height, silinder.height):
		im.alpha_composite(silinder, (x0, y))
	im.alpha_composite(t, (x0, im.height - badan_h - 24))
	im.alpha_composite(kr, ((im.width - kr.width) // 2, 0))
	im.alpha_composite(panji(38), (im.width - 13, 116))
	gb = P["gotik_biru"].resize((66, 62), Image.NEAREST)
	im.alpha_composite(gb, ((im.width - gb.width) // 2, im.height - 140))
	pd = P["pintu_ganda_kayu"]
	tempel_kaki(im, pd, im.width // 2, im.height)
	return im


def balai(P):
	"""Balai Kota: keep kastil asli + pintu ganda + lambang."""
	k = P["keep"]
	im = Image.new("RGBA", (k.width, k.height + 30), (0, 0, 0, 0))
	im.alpha_composite(k, (0, 30))
	tempel_kaki(im, P["pintu_ganda_kayu"], k.width // 2, im.height)
	im.alpha_composite(lambang_timbangan(24), (k.width // 2 - 12, 66))
	im.alpha_composite(panji(30), (2, 8))
	im.alpha_composite(panji(30), (k.width - 14, 8))
	return im


def aula(P):
	"""Aula Dagang: dinding batu + battlement + sepasang jendela lengkung + gapura."""
	bw, bh = 160, 196
	im = Image.new("RGBA", (bw, bh + 16), (0, 0, 0, 0))
	im.alpha_composite(ubin(P["wall_batu"], bw, bh), (0, 16))
	im.alpha_composite(baris(P["battlement"], bw), (0, 0))
	jl = P["jendela_lengkung"]
	im.alpha_composite(jl, ((bw - jl.width) // 2, 40))
	tempel_kaki(im, P["gerbang_lengkung"], bw // 2, bh + 16)
	tempel_kaki(im, P["pintu_ganda_kayu"].resize((48, 48), Image.NEAREST),
		bw // 2, bh + 14)
	im.alpha_composite(P["jendela_tirai"].resize((44, 68), Image.NEAREST), (6, bh - 72))
	im.alpha_composite(P["jendela_tirai"].resize((44, 68), Image.NEAREST), (bw - 50, bh - 72))
	return im


def hunian_a(P):
	"""Townhouse plester mewah: balustrade + jendela besar + pintu kofer."""
	bw, bh = 128, 196
	im = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
	im.alpha_composite(ubin(P["wall_plester"], bw, bh), (0, 0))
	im.alpha_composite(baris(P["balustrade"], bw), (0, 0))
	im.alpha_composite(baris(P["cornice"], bw), (0, 30))
	jb = P["jendela_besar"].resize((58, 78), Image.NEAREST)
	im.alpha_composite(jb, (8, 42))
	im.alpha_composite(jb, (bw - jb.width - 8, 42))
	# pintu di TENGAH — versi offset menabrak jendela kanan (mata v3)
	tempel_kaki(im, P["pintu_kofer"].resize((60, 88), Image.NEAREST), bw // 2, bh)
	return im


def hunian_b(P):
	"""Townhouse batu cokelat hangat: battlement + lancet biru + pintu kayu."""
	bw, bh = 96, 180
	im = Image.new("RGBA", (bw, bh + 14), (0, 0, 0, 0))
	im.alpha_composite(ubin(P["brn_wall"], bw, bh), (0, 14))
	im.alpha_composite(baris(P["brn_battlement"], bw), (0, 0))
	gb = P["gotik_biru"].resize((70, 66), Image.NEAREST)
	im.alpha_composite(gb, ((bw - gb.width) // 2, 34))
	tempel_kaki(im, P["pintu_ganda_kayu"].resize((52, 52), Image.NEAREST), bw // 2, bh + 14)
	im.alpha_composite(P["jendela_tirai"].resize((36, 56), Image.NEAREST), (bw // 2 - 18, 104))
	return im


def gudang(P):
	"""Gudang karavan: batu kastil polos + battlement + gerbang lengkung lebar."""
	bw, bh = 160, 150
	im = Image.new("RGBA", (bw, bh + 16), (0, 0, 0, 0))
	im.alpha_composite(ubin(P["wall_batu"], bw, bh), (0, 16))
	im.alpha_composite(baris(P["battlement"], bw), (0, 0))
	tempel_kaki(im, P["gerbang_lengkung"].resize((80, 80), Image.NEAREST), bw // 2, bh + 16)
	tempel_kaki(im, P["pintu_ganda_kayu"].resize((64, 64), Image.NEAREST), bw // 2, bh + 14)
	d = ImageDraw.Draw(im)
	d.rectangle([bw // 2 + 44, bh - 44, bw // 2 + 58, bh - 32], fill=G2, outline=G3)
	return im


def menara_timbangan(P):
	"""MENARA TIMBANGAN: menara kastil tinggi + kerucut EMAS + jam-lambang + panji."""
	t = P["tower_kotak"]
	badan_h = 210
	kr = P["kerucut_emas"].resize((92, 228), Image.NEAREST).crop((0, 0, 92, 158))
	im = Image.new("RGBA", (t.width + 40, badan_h + 148), (0, 0, 0, 0))
	x0 = (im.width - t.width) // 2
	isi = ubin(P["wall_batu"].crop((0, 0, t.width, P["wall_batu"].height)),
		t.width, badan_h)
	im.alpha_composite(isi, (x0, im.height - badan_h))
	im.alpha_composite(t, (x0, im.height - badan_h - 20))
	im.alpha_composite(kr, ((im.width - kr.width) // 2, 0))
	im.alpha_composite(panji(34), (x0 - 12, 130))
	im.alpha_composite(panji(34), (x0 + t.width - 2, 130))
	# wajah jam = lambang timbangan dalam cakram batu
	d = ImageDraw.Draw(im)
	cx, cy = im.width // 2, im.height - badan_h + 34
	d.ellipse([cx - 18, cy - 18, cx + 18, cy + 18], fill=(232, 226, 214, 255),
		outline=(120, 112, 100, 255), width=2)
	im.alpha_composite(lambang_timbangan(26), (cx - 13, cy - 13))
	gb = P["gotik_biru"].resize((54, 50), Image.NEAREST)
	im.alpha_composite(gb, (cx - 27, cy + 30))
	tempel_kaki(im, P["pintu_ganda_kayu"].resize((50, 50), Image.NEAREST),
		im.width // 2, im.height)
	return im


def gerbang_batu(P):
	"""Gerbang karavan: dua menara kastil mengapit tembok-ambang bergerigi
	di atas gapura — battlement DUDUK di tembok, bukan melayang (mata v3)."""
	t = P["tower_kotak"]
	ga = P["gerbang_lengkung"].resize((72, 72), Image.NEAREST)
	im = Image.new("RGBA", (2 * t.width + ga.width - 16, 176), (0, 0, 0, 0))
	x_t = (im.width - ga.width) // 2
	ambang = ubin(P["wall_batu"], ga.width + 24, 34)
	im.alpha_composite(ambang, (x_t - 12, im.height - ga.height - 34))
	im.alpha_composite(baris(P["battlement"], ga.width + 24),
		(x_t - 12, im.height - ga.height - 34 - 18))
	tempel_kaki(im, ga, im.width // 2, im.height)
	kb = P["kerucut_biru_s"]
	for x0 in (0, im.width - t.width):
		im.alpha_composite(t, (x0, im.height - t.height))
		im.alpha_composite(kb, (x0 + (t.width - kb.width) // 2,
			im.height - t.height - kb.height + 14))
	im.alpha_composite(panji(28), (t.width - 10, im.height - t.height - 30))
	return im


def kios_dagang(warna, warna2):
	"""Kios Pasar Agung (GAMBAR SENDIRI): kanopi royal + tiang emas."""
	im = Image.new("RGBA", (52, 48), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	GARIS = (52, 44, 34, 255)
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
	"""Pintu besi bawah-kota (GAMBAR SENDIRI) — sengaja kusam, HIDDEN."""
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
	P = potong(muat())
	out = {
		"fasad_serikat": serikat(P),
		"fasad_bank": bank(P),
		"fasad_kontrak": rumah_kontrak(P),
		"fasad_balai_gh": balai(P),
		"fasad_aula": aula(P),
		"fasad_hunian_a": hunian_a(P),
		"fasad_hunian_b": hunian_b(P),
		"fasad_gudang_gh": gudang(P),
		"menara_timbangan": menara_timbangan(P),
		"gerbang_batu": gerbang_batu(P),
		"kios_dagang": kios_dagang(NILA, (246, 238, 220, 255)),
		"kios_dagang_b": kios_dagang((160, 60, 60, 255), G1),
		"segel_pintu": segel_pintu(),
	}
	for nama, im in out.items():
		im.save(os.path.join(OUT, nama + ".png"))
		print("  %-18s %dx%d" % (nama, im.width, im.height))
	with open(os.path.join(OUT, "goldhaven.credits.txt"), "w", encoding="utf-8") as fh:
		fh.write("""# Kredit sprite Goldhaven v3 (#313)
# Lisensi: CC-BY-SA 3.0 (turunan Castle Mega-Pack) + gambar-sendiri
- fasad_* / menara_timbangan / gerbang_batu: dirakit dari
  "[LPC] Castle Mega-Pack" oleh bluecarrot16. Lisensi: CC-BY-SA 3.0.
  http://opengameart.org/content/lpc-castle-mega-pack
  Berdasarkan karya: Hyptosis, Zabin, Daniel Cook (Castle Tiles for RPGs,
  CC-BY 3.0); Evert, Xenodora, Lanea Zimmerman/Sharm (LPC castle, CC-BY 3.0);
  Xenodora, Lanea Zimmerman (LPC Style Well); theidiotmachine (Another LPC
  style castle, CC-BY-SA 3.0); Daniel Armstrong/HughSpectrum (LPC Base
  Assets, CC-BY 3.0). Sprite turunan ini ikut CC-BY-SA 3.0.
- GAMBAR SENDIRI (milik Aetherion): panji kota, lambang timbangan,
  kios_dagang(_b), segel_pintu.
Lisensi: CC-BY-SA 3.0
""")
	print("-> %s (14 berkas)" % OUT)


if __name__ == "__main__":
	main()
