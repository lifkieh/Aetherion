# -*- coding: utf-8 -*-
"""BATU PENANDA batas desa (#295 S3 · sheet #001 Arlen Vale).

Batu tegak polos di ujung jalan utara Ashbrook. Satu detail yang memikul seluruh
sheet: SISI UTARANYA LEBIH AUS — disentuh ribuan kali oleh tangan yang sama,
oleh kurir yang selalu berhenti di sini. Bukan nisan (beda bentuk: tegak-lonjong
membulat, bukan lempeng), bukan monumen (tanpa ukiran).

#240: generator ter-commit = aset bisa dilahirkan ulang.
"""
import os
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..",
	"game", "assets", "game", "sprites", "props")

BATU = (118, 116, 108, 255)      # granit lumutan
BATU_T = (140, 138, 128, 255)    # sisi kena cahaya
AUS = (166, 162, 150, 255)       # sisi utara — licin, lebih terang: aus tangan
TEPI = (58, 56, 50, 255)
LUMUT = (86, 104, 74, 255)
TANAH = (70, 60, 44, 255)


def main() -> None:
	im = Image.new("RGBA", (22, 34), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	# badan batu: tegak, membulat di puncak, sedikit miring — ditanam, bukan dipahat
	d.rounded_rectangle([3, 2, 18, 31], 6, fill=BATU, outline=TEPI)
	d.rounded_rectangle([5, 4, 11, 29], 5, fill=BATU_T)
	# SISI UTARA (kiri-atas) yang aus — pita licin vertikal, inti sheet #001
	d.rounded_rectangle([5, 6, 9, 22], 3, fill=AUS)
	d.point([(7, 8), (6, 12), (8, 16), (7, 20)], fill=BATU_T)
	# lumut di kaki sisi selatan — sisi yang TIDAK disentuh
	d.point([(14, 26), (16, 27), (15, 29), (13, 28), (17, 25)], fill=LUMUT)
	# tanah terinjak di kakinya
	d.ellipse([2, 29, 19, 33], fill=TANAH)
	d.rounded_rectangle([3, 2, 18, 31], 6, outline=TEPI)   # tepi digambar ulang di atas
	p = os.path.join(OUT, "batu_penanda.png")
	im.save(p)
	print("->", p)


if __name__ == "__main__":
	main()
