# -*- coding: utf-8 -*-
"""POTONGAN Castle Mega-Pack untuk Goldhaven v3 (#313) — tahap kalibrasi.

Sumber: assets_raw/lpc_castle/castle8_0.png (+brn) & castle-extras_0.png
"[LPC] Castle Mega-Pack" bluecarrot16 dkk — CC-BY-SA 3.0 (putusan #313: sah).
Skrip ini MEMOTONG piece bernama + menulis kontak sheet untuk diperiksa mata.
Rect dikoreksi di sini sampai bersih, lalu gen_goldhaven.py memakainya.
"""
import os
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "..", "assets_raw", "lpc_castle")
OUT = os.path.join(RAW, "potongan")

# (sheet, x0, y0, x1, y1)
PIECES = {
	# ── castle8: batu putih ──
	"tower_kotak":      ("c", 96, 96, 160, 224),    # menara persegi + battlement
	"tower_bundar":     ("c", 448, 96, 512, 224),   # menara silinder + battlement
	"keep":             ("c", 192, 0, 320, 224),    # benteng besar bergable putih
	"wall_batu":        ("c", 0, 96, 96, 192),      # isian dinding batu
	"battlement":       ("c", 96, 96, 160, 128),    # strip merlon
	"pintu_ganda_kayu": ("c", 352, 448, 416, 512),  # pintu ganda cokelat lengkung
	"gerbang_lengkung": ("c", 416, 448, 480, 512),  # gapura batu polos
	# ── castle8: istana plester ──
	"wall_plester":     ("c", 512, 152, 607, 264),  # isian dinding beige (y1 264:
	                                                # 300 memungut lengkung arch bawah — mata)
	"cornice":          ("c", 616, 324, 896, 336),  # lis dentil
	"balustrade":       ("c", 832, 128, 928, 160),  # pagar putih atap
	"pintu_agung":      ("c", 800, 0, 856, 116),    # pintu lengkung oranye tinggi
	"pintu_kofer":      ("c", 632, 216, 704, 320),  # pintu oranye + bingkai + undak
	"jendela_besar":    ("c", 920, 216, 992, 312),  # jendela panel putih besar
	"jendela_lengkung": ("c", 896, 336, 1024, 440), # sepasang jendela lengkung
	"jendela_tirai":    ("c", 864, 0, 926, 96),     # jendela tirai merah
	"gotik_putih":      ("c", 512, 256, 600, 412),  # lancet ganda kaca putih
	"gotik_biru":       ("c", 512, 424, 606, 512),  # lancet ganda kaca biru
	# ── castle8brn: batu cokelat hangat (varian hunian) ──
	"brn_wall":         ("b", 0, 96, 96, 192),
	"brn_tower":        ("b", 96, 96, 160, 224),
	"brn_battlement":   ("b", 96, 96, 160, 128),
	# ── extras: kerucut menara ──
	"kerucut_biru":     ("e", 0, 264, 100, 512),
	"kerucut_hitam":    ("e", 104, 264, 204, 512),
	"kerucut_merah":    ("e", 208, 264, 308, 512),
	"kerucut_emas":     ("e", 300, 264, 392, 512),  # 412 memungut sliver hijau (mata)
	"kerucut_hijau":    ("e", 416, 264, 512, 512),
	"kerucut_biru_s":   ("e", 0, 248, 64, 310),
	"kerucut_emas_s":   ("e", 316, 250, 376, 310),  # 352-416 kena kerucut hijau (mata)
}


def muat():
	return {
		"c": Image.open(os.path.join(RAW, "castle8_0.png")).convert("RGBA"),
		"b": Image.open(os.path.join(RAW, "castle8brn.png")).convert("RGBA"),
		"e": Image.open(os.path.join(RAW, "castle-extras_0.png")).convert("RGBA"),
	}


def _komponen_terbesar(im):
	"""Sisakan komponen piksel terbesar — crop kerucut selalu memungut sliver
	kerucut tetangga di atlas rapat (blob melayang, ketahuan mata v3)."""
	w, h = im.size
	px = im.load()
	lihat = [[False] * w for _ in range(h)]
	terbaik = []
	for sy in range(h):
		for sx in range(w):
			if lihat[sy][sx] or px[sx, sy][3] <= 8:
				continue
			antre = [(sx, sy)]
			lihat[sy][sx] = True
			isi = []
			while antre:
				x, y = antre.pop()
				isi.append((x, y))
				for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
					if 0 <= nx < w and 0 <= ny < h and not lihat[ny][nx] \
							and px[nx, ny][3] > 8:
						lihat[ny][nx] = True
						antre.append((nx, ny))
			if len(isi) > len(terbaik):
				terbaik = isi
	out = Image.new("RGBA", im.size, (0, 0, 0, 0))
	qx = out.load()
	for x, y in terbaik:
		qx[x, y] = px[x, y]
	return out


def potong(sheets=None):
	sheets = sheets or muat()
	out = {}
	for n, (s, x0, y0, x1, y1) in PIECES.items():
		im = sheets[s].crop((x0, y0, x1, y1))
		if n.startswith("kerucut"):
			im = _komponen_terbesar(im)
		out[n] = im
	return out


def main():
	os.makedirs(OUT, exist_ok=True)
	ps = potong()
	for n, im in ps.items():
		im.save(os.path.join(OUT, n + ".png"))
	W = sum(i.width + 10 for i in ps.values()) + 10
	H = max(i.height for i in ps.values()) + 40
	c = Image.new("RGBA", (min(W, 2400), H * ((W // 2400) + 1)), (44, 48, 62, 255))
	d = ImageDraw.Draw(c)
	x, row = 10, 0
	for n, im in ps.items():
		if x + im.width > 2380:
			x = 10
			row += 1
		y = row * H
		c.alpha_composite(im, (x, y + 36 + (H - 40 - im.height)))
		d.text((x, y + 4), n[:15], fill=(230, 230, 240, 255))
		d.text((x, y + 16), "%dx%d" % im.size, fill=(160, 160, 175, 255))
		x += im.width + 10
	c.convert("RGB").save(os.path.join(RAW, "v_potongan.png"))
	print("-> v_potongan.png (%d piece)" % len(ps))


if __name__ == "__main__":
	main()
