#!/usr/bin/env python3
"""Tiga ubin tanah Ashbrook 16px: grass_0 · grass_1 · dirt_0 (#240 HUKUM REPRODUKSI).

KENAPA ADA: `Ashbrook.gd:104` sudah meminta ketiganya sejak lama, tapi berkasnya
TAK PERNAH DIBUAT. Penjaga `ResourceLoader.exists` di baris 107 membuat sumber 0/1/2
tak pernah didaftarkan ke TileSet — jadi `_build_ground()` dan `_build_road()` memasang
sel yang tak sah dan **tak menggambar apa pun**. Ashbrook berdiri di atas kehitaman.
Ini memperbaikinya. Konsumen sudah ada; yang hilang seninya (pola sama dgn `lantern.png`).

Hanya Ashbrook yang memakai ketiga nama ini (Town memakai cobble_0/cobble_1/dirt_path),
jadi berkas ini **tidak mengubah wilayah lain**.

═══ ARAH ART DIRECTOR (#206 desa-bekas-kota · #253 "seni, bukan piksel") ═══

**HANGAT-PUDAR, BUKAN HIJAU CERAH.** Ashbrook dulu 1.500 jiwa, kini 40. Tanahnya harus
terasa seperti tempat yang pernah lebih ramai — hijau yang sedikit lelah, olive kekuningan,
rendah saturasi. SENGAJA lebih pudar dari dedaunan yang sudah ada
(`tree_oak #549648`, `bush #3F7F36`): pohon-pohon tetap hidup dan **menonjol** di atas
tanah yang lelah. Itu Hukum Tertinggi Ashbrook secara warna — keruntuhan berpasangan
dengan kehidupan, bukan semuanya kelabu.

**grass_0 vs grass_1 = variasi HALUS, bukan dua hijau berbeda.** Palet keduanya IDENTIK.
Yang berbeda hanya letak helai, kerapatannya, dan satu bercak kering di `grass_1`.
Ashbrook memanggil `grass_1` sekitar 25% (`randf() < 0.25`) — jadi bercak keringnya
tersebar acak di peta, terbaca sebagai padang tak rata, bukan sebagai pola.

**dirt_0 = jalan yang SUDAH LAMA dilewati**, bukan tanah baru digali: dua alur roda yang
sudah licin dan pucat, kerikil tertanam (bukan tercecer di atas), permukaan padat.

═══ ANTI-"STAMPING" (syarat uji Direktur) ═══
1. **Kontras rendah.** Semua detail dalam pita nilai sempit — bintik kontras tinggi
   itulah yang ditangkap mata sebagai kisi berulang.
2. **Nol penanda unik.** Tak ada satu bunga terang atau batu mencolok; apa pun yang
   "berkarakter" akan terbaca berulang tiap 16 px.
3. **Kerapatan merata** lewat kisi-terjitter (satu helai per sel 4×4), bukan acak murni —
   acak murni menggumpal, dan gumpalan itu yang terbaca sebagai bentuk berulang.
4. **Jahitan mulus.** Semua penggambaran lewat `_put()` yang membungkus modulo 16, jadi
   helai yang melewati tepi muncul kembali di sisi seberang.
5. **Alur jalan berperioda 16** (sinus penuh per ubin) → menyambung sempurna antar-ubin
   tanpa terlihat mekanis.
"""
import math
import os
import random

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
OUT = os.path.join(REPO, "game", "assets", "game", "tiles")

S = 16

# --- palet: hangat, pudar, rendah saturasi (olive, bukan hijau musim semi) ---
G_SHADOW = (74, 85, 51)
G_BASE = (94, 107, 61)
G_MID = (107, 120, 69)
G_LIGHT = (124, 138, 80)
G_DRY = (138, 135, 87)

# --- tanah: sekeluarga dengan dirt_path.png (#927450) tapi lebih pudar & padat ---
D_SHADOW = (110, 86, 56)
D_BASE = (134, 106, 71)
D_PALE = (158, 134, 97)
D_STONE = (146, 132, 112)   # sengaja LEBIH REDUP dari D_PALE: kerikil tak boleh
                            # mengalahkan alur roda. Revisi-1: versi terang membuat
                            # jalan terbaca sebagai bintik ramai, alurnya hilang.


def _put(px, x, y, c):
    """Tulis piksel dengan pembungkusan modulo — inilah yang membuat jahitannya mulus."""
    px[x % S, y % S] = c + (255,)


def _noise(px, rng, amp):
    """Getar nilai seragam per piksel: tekstur tanpa pola, hue tak bergeser."""
    for y in range(S):
        for x in range(S):
            r, g, b, _ = px[x, y]
            n = rng.randint(-amp, amp)
            px[x, y] = (max(0, min(255, r + n)), max(0, min(255, g + n)),
                        max(0, min(255, b + n)), 255)


def _jitter_grid(rng, step, pad=0):
    """Titik-titik tersebar RATA (satu per sel) — bukan acak murni yang menggumpal."""
    pts = []
    for cy in range(0, S, step):
        for cx in range(0, S, step):
            pts.append((cx + rng.randint(pad, step - 1 - pad),
                        cy + rng.randint(pad, step - 1 - pad)))
    return pts


def grass(seed, blades_step, tufts_step, dry=False):
    rng = random.Random(seed)
    im = Image.new("RGBA", (S, S), G_BASE + (255,))
    px = im.load()
    # REVISI-1: getar dinaikkan 3 -> 5. Tekstur harus datang dari DERAU (tak berbentuk),
    # bukan dari tanda-tanda diskret — sekumpulan tanda terang membentuk "rasi bintang"
    # yang langsung dikenali mata saat ubinnya berulang.
    _noise(px, rng, 5)

    # rumpun gelap dulu (kedalaman), lalu helai di atasnya
    for (x, y) in _jitter_grid(rng, tufts_step):
        if rng.random() < 0.7:
            _put(px, x, y, G_SHADOW)

    # REVISI-1: helai dijarangkan dan diredupkan. Versi pertama memakai 16 helai/ubin
    # dengan 45% G_LIGHT -> terbaca sebagai bintik berpola. Kini ~9 helai, G_LIGHT
    # hanya ~18%, dan mayoritas cuma 2 px.
    for (x, y) in _jitter_grid(rng, blades_step):
        if rng.random() < 0.22:
            continue                                # sebagian sel sengaja kosong
        h = rng.choice((2, 2, 2, 3))
        c = G_LIGHT if rng.random() < 0.18 else G_MID
        lean = rng.choice((-1, 0, 0, 1))
        for i in range(h):
            _put(px, x + (lean if i == h - 1 else 0), y - i, c)

    if dry:
        # bercak kering: HANYA satu langkah nilai, tanpa tepi keras.
        # Muncul ~25% ubin di peta -> terbaca "padang tak rata", bukan pola.
        cx, cy = rng.randint(3, 12), rng.randint(3, 12)
        for dy in range(-2, 3):
            for dx in range(-3, 4):
                if dx * dx + dy * dy * 1.6 <= 6 and rng.random() < 0.75:
                    _put(px, cx + dx, cy + dy, G_DRY)
    return im


def dirt():
    rng = random.Random(1607)
    im = Image.new("RGBA", (S, S), D_BASE + (255,))
    px = im.load()
    _noise(px, rng, 3)   # REVISI-1: diturunkan dari 4 — derau tinggi menenggelamkan alur

    # DUA ALUR RODA — sinus berperioda tepat 16 px supaya menyambung antar-ubin.
    # Pucat & licin: jejak yang sudah lama dilewati, bukan galian baru.
    # REVISI-1: alur dibuat TEBAL & PASTI (2 px penuh, bukan 1 px acak). Versi pertama
    # alurnya tipis dan kalah oleh kerikil terang — jalan terbaca sebagai bintik ramai,
    # bukan sebagai jalan yang dilewati bertahun-tahun.
    # REVISI-2: satu sinus murni terbaca sebagai gelombang rapi yang berulang. Ditambah
    # harmonik kedua (perioda 8) — keduanya tetap membungkus sempurna di 16 px, tapi
    # bentuknya tak lagi seperti gelombang buatan. Dua alur diberi amplitudo berbeda
    # supaya tak sejajar seperti rel.
    for base_y, phase, amp1, amp2 in ((5, 0.0, 1.1, 0.5), (11, math.pi, 0.8, 0.7)):
        for x in range(S):
            t = 2 * math.pi * x / S
            y = base_y + int(round(amp1 * math.sin(t + phase) + amp2 * math.sin(2 * t + phase * 0.5)))
            _put(px, x, y, D_PALE)
            _put(px, x, y + 1, D_PALE)
            _put(px, x, y + 2, D_SHADOW)           # cekungan tipis di bawah alur

    # KERIKIL TERTANAM: batu + bayangan di bawahnya = duduk DI DALAM tanah, bukan di atasnya.
    # REVISI-1: dijarangkan (kisi 5 -> 8) dan diredupkan supaya alur tetap yang memimpin.
    for (x, y) in _jitter_grid(rng, 8):
        if rng.random() < 0.6:
            _put(px, x, y, D_STONE)
            _put(px, x, y + 1, D_SHADOW)
    return im


def main():
    os.makedirs(OUT, exist_ok=True)
    # grass_1 SENGAJA lebih jarang helainya + satu bercak kering. Palet IDENTIK
    # dengan grass_0 — yang berbeda hanya tekstur, bukan warna (arahan Direktur).
    files = {
        "grass_0": grass(seed=1601, blades_step=6, tufts_step=7, dry=False),
        "grass_1": grass(seed=1602, blades_step=7, tufts_step=6, dry=True),
        "dirt_0": dirt(),
    }
    for name, im in files.items():
        im.save(os.path.join(OUT, name + ".png"))
    print("3 ubin 16x16 -> %s" % OUT)
    print("  " + " · ".join(sorted(files)))


if __name__ == "__main__":
    main()
