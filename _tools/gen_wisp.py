# -*- coding: utf-8 -*-
"""Wisp Gemini -> spritesheet 4 frame. FINAL.

RIWAYAT KEGAGALAN — ditulis supaya tak diulang, ketiganya ketahuan karena DILIHAT:
  v1  kunci `lum-132` -> inti dua frame redup BERBINTIK: papan catur terang (116)
      tertimpa cahaya tipis ikut lewat ambang, jadi pola caturnya masuk ke alpha.
  v2  kunci B-R saja -> wisp jadi DONAT: inti nyaris putih punya B-R kecil, jadi
      justru intinya yang terkunci keluar.
  v3  gabungan (B-R, lum>150) -> frame terang BERSIH, frame redup MASIH berbintik.
      Sebab akhirnya jelas: pada wisp tipis, lapisan biru menempel di atas dua abu
      catur yang berbeda, dan B-R ikut berayun mengikuti kisi. Tak ada ambang yang
      bisa memisahkan itu — cacatnya ada di bahan, bukan di ambangnya.

OBAT: keempatnya adalah CAHAYA YANG SAMA pada terang berbeda. Jadi BENTUK diambil
dari satu frame terbersih (yang paling terang, di sana catur tertimbun total), lalu
alpha-nya diskalakan jadi empat tingkat. Hasilnya denyut yang bernapas di tempat —
bentuk identik, terang berubah — dan itu justru LEBIH benar daripada empat gambar
yang sedikit berbeda bentuknya.

Percikan kecil di pojok kanan-bawah (bonus tak diminta) tak pernah ikut: ia di luar
kotak potong.
"""
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageFilter

D = r"C:\Users\user\OneDrive\Desktop"
SRC = os.path.join(D, "Gemini_Generated_Image_v6t7c0v6t7c0v6t7.png")
DST = r"D:\2DGAME\game\assets\game\sprites\props\wisp.png"
WARNA = (198, 230, 255)
SISI = 48
R = 150
TINGKAT = [0.42, 0.70, 1.00, 0.74]     # denyut bernapas, bukan kedip

im = Image.open(SRC).convert("RGB")
W, H = im.size
px = im.load()

raw = Image.new("L", (W, H), 0)
rp = raw.load()
for y in range(H):
    for x in range(W):
        r, g, b = px[x, y]
        v = max((b - r) * 3.6, (((r * 2 + g * 5 + b) / 8.0) - 150.0) * 4.2)
        if v > 0:
            rp[x, y] = int(min(255.0, v))
raw = raw.filter(ImageFilter.GaussianBlur(2.2))

# pusat wisp TERBERSIH = kolom dengan alpha total terbesar
kolom = [sum(raw.getpixel((x, y)) for y in range(0, H, 3)) for x in range(W)]
cx = max(range(W), key=lambda k: kolom[k])
kol = [raw.getpixel((cx, y)) for y in range(H)]
cy = max(range(H), key=lambda k: kol[k])
print("bentuk diambil dari wisp di (%d, %d)" % (cx, cy))

bentuk = raw.crop((cx - R, cy - R, cx + R, cy + R)).resize((SISI, SISI), Image.LANCZOS)
bentuk = bentuk.filter(ImageFilter.GaussianBlur(0.6))       # falloff tetap lembut di 48px
puncak = max(bentuk.get_flattened_data())
bentuk = bentuk.point(lambda v: min(255, int(v * 255.0 / puncak)))

sheet = Image.new("RGBA", (SISI * 4, SISI), (0, 0, 0, 0))
for i, t in enumerate(TINGKAT):
    a = bentuk.point(lambda v: int(v * t))
    f = Image.new("RGBA", (SISI, SISI), WARNA + (0,))
    f.putalpha(a)
    sheet.alpha_composite(f, (i * SISI, 0))
    print(f"  frame {i}: alpha-maks {max(a.get_flattened_data())}")

os.makedirs(os.path.dirname(DST), exist_ok=True)
sheet.save(DST)
with open(DST.replace(".png", ".credits.txt"), "w", encoding="utf-8") as f:
    f.write(
        "# wisp.png — roh/cahaya melayang C4 (atmosfer, bukan makhluk)\n"
        "# 4 frame 48x48, hadap-netral, denyut alpha 0.42/0.70/1.00/0.74\n\n"
        "Asal   : GAMBAR HASIL AI (Google Gemini), diminta Direktur\n"
        "Lisensi: karya proyek (bukan aset pihak ketiga, bukan turunan LPC)\n"
        "Proses : latar 'transparan' bawaan ternyata papan catur yang DILUKIS\n"
        "         (alpha berkas asli 255 rata). Alpha dikunci ulang dari warna,\n"
        "         lalu keempat frame dibangun dari SATU bentuk terbersih karena\n"
        "         frame redup tercemar pola catur. _tools/gen_wisp.py\n"
        "Catatan: dicatat sebagai AI-generated untuk kejelasan sesi mendatang —\n"
        "         status hukum aset AI berbeda dari aset berlisensi, dan itu\n"
        "         keputusan Direktur, bukan asumsi berkas ini.\n")

bg = Image.new("RGBA", (SISI * 16, SISI * 4), (58, 74, 48, 255))
bg.alpha_composite(sheet.resize((SISI * 16, SISI * 4), Image.NEAREST))
bg.convert("RGB").save("wisp_final_pratinjau.png")
print("->", DST, sheet.size)
