# -*- coding: utf-8 -*-
"""GROUND + TEMBOK POLIGON GOLDHAVEN (#319) — pre-render 4 kuadran.

Geometri = SALINAN mockup_goldhaven_lingkar_aset (poligon N sisi, per-piksel,
ACC Direktur #318). Ubin dasar dari LPC Terrains (CC-BY-SA) + dinding
Castle Mega-Pack. Keluaran: sprites/goldhaven/ground/q{0..3}.png (2560²)
— scene menyusunnya jadi lantai 5120², bangunan & warga di atasnya.
#240: generator ter-commit.
"""
import math
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mockup_goldhaven_lingkar_aset import (
	C, LEBAR_JALAN, N, R1, R2, R3, R4, R5, S1, S2, S3, S4, S5, T,
	muat_tanah, verts)
from gen_goldhaven_potong import muat, potong

OUT = os.path.join(HERE, "..", "game", "assets", "game", "sprites",
	"goldhaven", "ground")


def main():
	P = potong(muat())
	TN = muat_tanah()
	W = N * T
	im = Image.new("RGBA", (W, W), (0, 0, 0, 255))

	def tiled(tile):
		tt = Image.new("RGBA", (W, W))
		for yy in range(0, W, tile.height):
			for xx in range(0, W, tile.width):
				tt.paste(tile, (xx, yy))
		return tt

	im.paste(tiled(TN["luar"]), (0, 0))
	m6 = Image.new("L", (W, W), 0)
	ImageDraw.Draw(m6).polygon(verts(R5 + 10, S5), fill=255)
	im.paste(tiled(TN["L6"]), (0, 0), m6)
	for r_t, n_s, kunci in [(R5, S5, "L5"), (R4, S4, "L4"), (R3, S3, "L3"),
			(R2, S2, "L2"), (R1, S1, "L1")]:
		m = Image.new("L", (W, W), 0)
		ImageDraw.Draw(m).polygon(verts(r_t, n_s), fill=255)
		im.paste(tiled(TN[kunci]), (0, 0), m)
	jalan_t = tiled(TN["jalan"])
	m_j = Image.new("L", (W, W), 0)
	dj = ImageDraw.Draw(m_j)
	dj.rectangle([(C - LEBAR_JALAN) * T, 0, (C + LEBAR_JALAN + 1) * T, W], fill=255)
	dj.rectangle([0, (C - LEBAR_JALAN) * T, W, (C + LEBAR_JALAN + 1) * T], fill=255)
	im.paste(jalan_t, (0, 0), m_j)
	for rr, n_s in [((R1 + R2) / 2, S2), ((R2 + R3) / 2, S3),
			((R3 + R4) / 2, S4), ((R4 + R5) / 2 - 3, S5)]:
		m_r = Image.new("L", (W, W), 0)
		dr_ = ImageDraw.Draw(m_r)
		dr_.polygon(verts(rr + 1.2, n_s), fill=255)
		dr_.polygon(verts(rr - 1.2, n_s), fill=0)
		im.paste(jalan_t, (0, 0), m_r)
	# plaza pasar (tenggara lingkar-5) — posisi sama dgn scene
	a_p = math.tau / 8
	mx = C * T + math.cos(a_p) * (R4 + 11) * T
	my = C * T + math.sin(a_p) * (R4 + 11) * T
	m_p = Image.new("L", (W, W), 0)
	ImageDraw.Draw(m_p).ellipse([mx - 7 * T, my - 6 * T, mx + 7 * T, my + 6 * T],
		fill=255)
	im.paste(jalan_t, (0, 0), m_p)

	# tembok poligon + merlon (visual; collision dibangun scene dari verts sama)
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

	os.makedirs(OUT, exist_ok=True)
	H = W // 2
	for qy in range(2):
		for qx in range(2):
			im.crop((qx * H, qy * H, (qx + 1) * H, (qy + 1) * H)).convert("RGB") \
				.save(os.path.join(OUT, "q%d%d.png" % (qx, qy)))
	with open(os.path.join(OUT, "ground.credits.txt"), "w", encoding="utf-8") as fh:
		fh.write("""# Ground pre-render Goldhaven (#319)
# Lisensi: CC-BY-SA (turunan)
- Ubin tanah/jalan: "[LPC] Terrains" — bluecarrot16, Lanea Zimmerman,
  Daniel Eddeland, Richard Kettering, Zachariah Husiar dkk (CC-BY-SA 3.0/4.0;
  rincian CREDITS-terrain.txt). https://opengameart.org/content/lpc-terrains
- Dinding tembok: "[LPC] Castle Mega-Pack" — bluecarrot16 dkk (CC-BY-SA 3.0).
Lisensi: CC-BY-SA 3.0
""")
	print("-> %s (q00 q10 q01 q11, 2560x2560)" % OUT)


if __name__ == "__main__":
	main()
