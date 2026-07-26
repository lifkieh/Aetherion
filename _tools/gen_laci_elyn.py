# -*- coding: utf-8 -*-
"""LACI ELYN (#291 / bible A3 §2) — prop paling penting adegan TRIASE.

Dua frame, satu kanon:
  laci_elyn_tutup.png  — laci meja kayu, tertutup. Netral. D-3: tak menonjol.
  laci_elyn_buka.png   — terbuka SEKEJAP: tumpukan kertas terlipat, PULUHAN,
                         semuanya sama bentuk. Kanon laci = JUMLAH terbaca,
                         bukan detail per lembar (ledger #248, hukum bekas).

Digambar prosedural dari palet kayu peti repo (chest_common) supaya duduk di
bahasa visual interior yang sama. #240: generator ini = bukti yang bisa
dijalankan ulang.
"""
import os
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "game", "assets", "game", "sprites", "props")

# palet kayu selaras chest_common (dicuplik mata, bukan disalin berkas)
KAYU_G = (110, 74, 42, 255)     # badan kayu gelap
KAYU_T = (146, 100, 58, 255)    # muka kayu terang
KAYU_S = (84, 55, 30, 255)      # sisi/bayangan
GARIS = (52, 34, 18, 255)       # tepi
PEGANG = (196, 168, 96, 255)    # pegangan kuningan pudar
DALAM = (38, 26, 16, 255)       # rongga
KERTAS = (216, 205, 178, 255)   # kertas tua
KERTAS_B = (188, 176, 148, 255) # bayangan lipatan
CORET = (96, 88, 76, 255)       # coretan tipis — cukup untuk terbaca "tercoret"


def _badan(d: ImageDraw.ImageDraw) -> None:
	# kotak laci 26x16 di kanvas 28x22, sudut tegas era 32px
	d.rectangle([1, 5, 26, 20], fill=KAYU_G, outline=GARIS)
	d.rectangle([2, 6, 25, 8], fill=KAYU_T)          # bibir atas kena cahaya
	d.line([(2, 20), (25, 20)], fill=KAYU_S)


def tutup() -> Image.Image:
	im = Image.new("RGBA", (28, 22), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	_badan(d)
	d.rectangle([4, 9, 23, 17], fill=KAYU_T, outline=GARIS)   # muka laci
	d.rectangle([12, 12, 15, 14], fill=PEGANG, outline=GARIS)  # pegangan
	# kayu licin di pegangannya — sering dibuka, selalu tertutup (aus 2 px)
	d.point([(11, 13), (16, 13)], fill=KAYU_G)
	return im


def buka() -> Image.Image:
	im = Image.new("RGBA", (28, 22), (0, 0, 0, 0))
	d = ImageDraw.Draw(im)
	_badan(d)
	# laci ditarik: rongga terlihat, muka laci turun ke depan-bawah
	d.rectangle([3, 8, 24, 15], fill=DALAM, outline=GARIS)
	# TUMPUKAN — baris demi baris lipatan yang sama; jumlah yang bercerita
	y = 14
	for baris in range(4):
		for x0 in range(4, 23, 5):
			d.rectangle([x0, y - baris * 2 - 1, x0 + 3, y - baris * 2],
				fill=KERTAS if (baris + x0) % 2 else KERTAS_B)
	# beberapa coretan tipis melintang — tercoret, bukan kosong
	for x0, y0 in ((5, 9), (15, 11), (10, 13)):
		d.line([(x0, y0), (x0 + 3, y0)], fill=CORET)
	# muka laci yang tertarik keluar
	d.rectangle([5, 16, 22, 20], fill=KAYU_T, outline=GARIS)
	d.rectangle([12, 17, 15, 19], fill=PEGANG, outline=GARIS)
	return im


def main() -> None:
	os.makedirs(OUT, exist_ok=True)
	for nama, im in (("laci_elyn_tutup", tutup()), ("laci_elyn_buka", buka())):
		p = os.path.join(OUT, nama + ".png")
		im.save(p)
		print("->", p)


if __name__ == "__main__":
	main()
