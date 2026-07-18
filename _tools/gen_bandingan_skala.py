#!/usr/bin/env python3
"""Gambar SATU pembanding skala: Aetherion sekarang (16px/_charsys) vs skala LPC.

Untuk keputusan Direktur "apakah pindah ke 64px", HUKUM REPRODUKSI #240.
⚠ Script ini TIDAK mengubah apa pun. Ia hanya membaca dan menyusun gambar.
   Nol `game/`. Nol wire LPC. Tidak menyentuh `_charsys/`.

Keluaran: reports/preview/skala_16_vs_lpc64.png

Tiga baris, sengaja dipisah karena mengukur hal berbeda:
  BARIS 1 — LUAS LAYAR YANG SAMA. Dua panel berukuran piksel identik, zoom kamera
            sama (2x). Di sinilah ongkos sesungguhnya terlihat: pada skala LPC,
            dunia yang muat di layar tinggal ~1/4.
  BARIS 2 — SENI MURNI, tanpa tint malam. Panel scene kiri terlihat gelap semata
            karena `GameClock` memakai jam WIB NYATA dan CanvasModulate meredupkan
            dunia — bukan karena seninya. Membandingkan kualitas lewat panel gelap
            itu curang, jadi kedua karakter ditaruh lagi di latar netral.
  CATATAN  — atribusi CC-BY-SA untuk karakter LPC.

Sumber (semuanya sudah ada di repo, nol aset baru dibuat):
  _work/shot_bench.png              tangkapan scene Ashbrook sungguhan (alun-alun)
  _charsys/sheets/human_m_32x32.png lembar 96x128 = 3 frame x 4 arah, sel 32px
  reports/preview/final_merrit.png  rakitan lapisan ULPC (CC-BY-SA), upscale 4x
                                    -> dikembalikan ke piksel asli 34x47
"""
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
OUT = os.path.join(REPO, "reports", "preview", "skala_16_vs_lpc64.png")

PW, PH = 600, 420   # tiap panel = luas layar yang sama
ZOOM = 2            # zoom kamera game (Player.gd:33)
TILE_NOW = 16       # Ashbrook.gd:15 const TILE := 16
TILE_LPC = 32       # LPC: ubin 32px, FRAME karakter 64px
BG = (26, 28, 32, 255)


def _font(sz, bold=False):
    for n in (("consolab.ttf" if bold else "consola.ttf"), "arial.ttf"):
        try:
            return ImageFont.truetype(n, sz)
        except OSError:
            pass
    return ImageFont.load_default()


def main():
    p = lambda *a: os.path.join(REPO, *a)
    shot = Image.open(p("_work", "shot_bench.png")).convert("RGBA")
    lpc4 = Image.open(p("reports", "preview", "final_merrit.png")).convert("RGBA")
    lpc = lpc4.resize((lpc4.width // 4, lpc4.height // 4), Image.NEAREST)   # -> 34x47 asli
    cs_sheet = Image.open(p("_charsys", "sheets", "human_m_32x32.png")).convert("RGBA")
    cs = cs_sheet.crop((32, 0, 64, 32))          # frame tengah (diam), baris 0 = hadap bawah
    cs = cs.crop(cs.getbbox())                   # rapatkan ke badan supaya adil

    # ---------- BARIS 1 ----------
    left = shot.crop((340, 150, 340 + PW, 150 + PH))
    right = Image.new("RGBA", (PW, PH), (58, 62, 54, 255))
    d = ImageDraw.Draw(right)
    step = TILE_LPC * ZOOM
    for g in range(0, max(PW, PH) + step, step):
        d.line([(0, g), (PW, g)], fill=(78, 84, 72, 255))
        d.line([(g, 0), (g, PH)], fill=(78, 84, 72, 255))
    cw, chh = lpc.width * ZOOM, lpc.height * ZOOM
    big = lpc.resize((cw, chh), Image.NEAREST)
    right.paste(big, (PW // 2 - cw // 2, PH // 2 - chh // 2 + 20), big)

    # ---------- BARIS 2: seni murni, latar netral ----------
    ART_H, Z2 = 210, 4
    art = Image.new("RGBA", (PW * 2 + 24, ART_H), (74, 80, 70, 255))
    ad = ImageDraw.Draw(art)
    a_cs = cs.resize((cs.width * Z2, cs.height * Z2), Image.NEAREST)
    a_lp = lpc.resize((lpc.width * Z2, lpc.height * Z2), Image.NEAREST)
    base_y = ART_H - 26
    art.paste(a_cs, (150, base_y - a_cs.height), a_cs)
    art.paste(a_lp, (150 + a_cs.width + 190, base_y - a_lp.height), a_lp)
    ad.line([(0, base_y + 2), (art.width, base_y + 2)], fill=(120, 126, 118, 255))

    # ---------- susun ----------
    GAP, TOP, MID, BOT = 24, 78, 58, 74
    W = 40 + PW * 2 + GAP
    H = TOP + PH + 96 + MID + ART_H + BOT
    out = Image.new("RGBA", (W, H), BG)
    out.paste(left, (20, TOP))
    out.paste(right, (20 + PW + GAP, TOP))
    dd = ImageDraw.Draw(out)
    for x0 in (20, 20 + PW + GAP):
        dd.rectangle([x0 - 1, TOP - 1, x0 + PW, TOP + PH], outline=(120, 126, 120, 255))

    fb, fm, fs = _font(19, True), _font(14), _font(12)
    dd.text((20, 14), "AETHERION — SKALA SEKARANG  vs  SKALA LPC", font=fb, fill=(255, 224, 140, 255))
    dd.text((20, 40), "BARIS 1: kedua panel = LUAS LAYAR YANG SAMA (600x420 px, zoom kamera 2x). Selisih ukurannya NYATA.",
            font=fs, fill=(190, 195, 190, 255))
    dd.text((20, 56), "KIRI: tangkapan scene Ashbrook sungguhan.   KANAN: mockup — nol wire, nol sistem diubah.",
            font=fs, fill=(190, 195, 190, 255))

    y = TOP + PH + 10
    dd.text((20, y), "KIRI — SEKARANG", font=fb, fill=(150, 220, 150, 255))
    for i, t in enumerate([
        "ubin %d px  ->  %d px layar" % (TILE_NOW, TILE_NOW * ZOOM),
        "karakter _charsys: sel 32 px, badan tampak %dx%d px" % (cs.width, cs.height),
        "prop: int_table 24x20 · bench 20x11 · lantern 12x20",
        "SUDAH ADA & JALAN — 264 PNG di game/assets.",
    ]):
        dd.text((20, y + 24 + i * 17), t, font=fm, fill=(205, 210, 205, 255))
    x2 = 20 + PW + GAP
    dd.text((x2, y), "KANAN — SKALA LPC", font=fb, fill=(255, 180, 120, 255))
    for i, t in enumerate([
        "ubin %d px  ->  %d px layar   (LPC: ubin 32, FRAME karakter 64)" % (TILE_LPC, TILE_LPC * ZOOM),
        "karakter LPC: badan tampak %dx%d px di dalam frame 64x64" % (lpc.width, lpc.height),
        "TILESET & PROP 32px BELUM ADA — latar itu kisi placeholder, bukan seni.",
        "Akibat: dunia yang muat di layar tinggal ~1/4 pada zoom yang sama.",
    ]):
        dd.text((x2, y + 24 + i * 17), t, font=fm, fill=(205, 210, 205, 255))

    ay = TOP + PH + 96 + MID
    dd.text((20, ay - 22), "BARIS 2 — SENI MURNI (zoom 4x, latar netral). Panel kiri di atas gelap karena JAM WIB NYATA + CanvasModulate, bukan karena seninya.",
            font=fs, fill=(190, 195, 190, 255))
    out.paste(art, (20, ay))
    dd.rectangle([19, ay - 1, 20 + art.width, ay + ART_H], outline=(120, 126, 120, 255))
    dd.text((36, ay + 8), "_charsys  %dx%d px" % (cs.width, cs.height), font=fm, fill=(150, 220, 150, 255))
    dd.text((36 + 190 + a_cs.width, ay + 8), "LPC  %dx%d px" % (lpc.width, lpc.height), font=fm, fill=(255, 180, 120, 255))
    dd.text((36, ay + ART_H - 20), "tinggi badan %d px  ->  %d px  =  %.1fx piksel per karakter"
            % (cs.height, lpc.height, lpc.height / cs.height), font=fm, fill=(225, 228, 225, 255))

    dd.text((20, H - 40), "Karakter LPC = reports/preview/final_merrit.png (rakitan lapisan ULPC, CC-BY-SA; atribusi di reports/preview/README.md).",
            font=fs, fill=(160, 165, 170, 255))
    dd.text((20, H - 24), "Dibuat _tools/gen_bandingan_skala.py (#240). Nol perubahan game/. Nol wire LPC. _charsys tidak disentuh.",
            font=fs, fill=(160, 165, 170, 255))

    out.convert("RGB").save(OUT)
    print("-> %s  %dx%d" % (OUT, out.width, out.height))


if __name__ == "__main__":
    main()
