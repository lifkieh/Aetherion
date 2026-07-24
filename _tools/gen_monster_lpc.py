# -*- coding: utf-8 -*-
"""MONSTER LPC 64px BERANIMASI — pengganti pose-statis DCSS. (#278 · #240 · #277)

MASALAH YANG DITUTUP
--------------------
`gen_monster64.py` menyembuhkan monster yang HILANG (satu pose DCSS 32px disalin ke
empat arah), bukan monster yang KAKU. Direktur: "kenapa monsternya jelek dan gaada
animasi" — sebabnya langit-langit sumber, bukan bug. Alat ini menggantinya dengan
seni yang ASLI 64px (atau ukuran aslinya — makhluk kecil BOLEH kecil, 32px pada
kepadatan piksel yang sama) dan ASLI beranimasi empat arah.

⚠ URUTAN BARIS BERBEDA ANTAR PAKET — masing-masing DIPETAKAN, tidak ditebak
  (pelajaran 0f7fbde: menebak tak menghasilkan galat, cuma monster yang berjalan
  memunggungi pemain). Peta per paket ada di extractor masing-masing.

KELUARAN
--------
`game/assets/game/sprites/monsters/<id>.png` — lembar N kolom x 4 baris, sel persegi,
baris berurutan `SheetUtil.DIRS` = [down, up, left, right], frame 0 tiap baris = idle.
Frame non-persegi di-pad ke sel persegi RATA-KAKI (kaki menyentuh dasar sel).
`monsters.json` diperbarui per entri (frame_size / cols / rows) oleh --tulis-json.

KEJUJURAN VISUAL (dilaporkan, tidak disembunyikan — mandat #278)
---------------------------------------------------------------
Sebagian spesies memakai PENDEKATAN karena sumber beranimasi sejatinya belum ada:
  - belut (volt_eel/levia_eel)          = ular re-warna    [ular ≈ belut]
  - pari (cloud_ray/nimbus_ray)         = hantu re-warna   [melayang, bukan pari]
  - elemental (frost/storm)             = hantu re-warna   [wujud roh, bukan elemental]
  - peri (peppermint_fairy/lollipop)    = hantu re-warna   [melayang]
  - musang (volt_weasel/raiju)          = tikus raksasa re-warna
  - burung (owl/vulture/hawk/roc)       = burung 32px      [KECIL untuk hawk/roc]
  - frost_titan                         = beruang kutub    [boss; butuh skala engine]
Daftar ini ditulis ke CREDITS keluaran. Mengganti pendekatan = cari sumber baru,
bukan menambal di sini.

Pakai:
  python gen_monster_lpc.py --lihat        # lembar kontak pratinjau, tak menulis
  python gen_monster_lpc.py                # tulis sprites/monsters/ + kredit
  python gen_monster_lpc.py --tulis-json   # + perbarui monsters.json
"""
import colorsys
import io
import json
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
SRC = os.path.join(REPO, "assets_raw", "oga", "monsters")
FARM = os.path.join(REPO, "assets_raw", "oga", "farm")
DST = os.path.join(REPO, "game", "assets", "game", "sprites", "monsters")
JSON_PATH = os.path.join(REPO, "game", "data", "monsters.json")
PRATINJAU = os.path.join(REPO, "reports", "preview", "monster_lpc.png")

DIRS = ["down", "up", "left", "right"]          # SheetUtil.DIRS — kontrak engine


# ───────────────────────────────────────────────────────────── util gambar
def _kosong(im):
    bb = im.getbbox()
    return bb is None


def _grid(im, fw, fh, peta_baris, cols=None):
    """Potong grid seragam -> {dir: [frame]} menurut peta_baris (list 4 nama arah,
    urutan baris SUMBER). Frame kosong di ekor baris dibuang."""
    cols = cols or (im.width // fw)
    out = {}
    for r, arah in enumerate(peta_baris):
        frames = []
        for c in range(cols):
            f = im.crop((c * fw, r * fh, (c + 1) * fw, (r + 1) * fh))
            frames.append(f)
        while frames and _kosong(frames[-1]):
            frames.pop()
        out[arah] = frames
    return out


def _hue(im, h_deg=None, h_set=None, sat=1.0, val=1.0, abu=False, tint=None):
    """Re-warna deterministik. `h_deg` = ROTASI hue; `h_set` = GANTI hue (derajat
    absolut) untuk piksel bersaturasi — dipakai saat varian harus benar-benar
    berbeda warna, bukan sekadar bergeser (pelajaran: keluarga hantu yang digeser
    hue-nya tetap terbaca "hantu hijau semua"). `abu=True` = buang saturasi.
    Alpha tak disentuh."""
    im = im.convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
            if abu:
                s = 0.0
            elif h_set is not None and s > 0.15:
                h = (h_set / 360.0) % 1.0
            elif h_deg is not None:
                h = (h + h_deg / 360.0) % 1.0
            s = min(1.0, s * sat)
            v = min(1.0, v * val)
            r2, g2, b2 = colorsys.hsv_to_rgb(h, s, v)
            r3, g3, b3 = int(r2 * 255), int(g2 * 255), int(b2 * 255)
            if tint:
                # campur menuju warna target — satu-satunya cara mewarnai piksel
                # ber-saturasi nol (gajah abu-abu tak tersentuh hue apa pun)
                tr, tg, tb, k = tint
                r3 = int(r3 * (1 - k) + tr * k)
                g3 = int(g3 * (1 - k) + tg * k)
                b3 = int(b3 * (1 - k) + tb * k)
            px[x, y] = (r3, g3, b3, a)
    return im


def _mirror(frames):
    return [f.transpose(Image.FLIP_LEFT_RIGHT) for f in frames]


# ───────────────────────────────────────────────────────────── extractor paket
_CACHE = {}


def _buka(path_zip, dalam):
    kunci = (path_zip, dalam)
    if kunci not in _CACHE:
        with zipfile.ZipFile(path_zip) as z:
            _CACHE[kunci] = Image.open(io.BytesIO(z.read(dalam))).convert("RGBA")
    return _CACHE[kunci]


def lpcm(nama):
    """[LPC] Monsters — sel 64, baris b0 belakang(up) · b1 kiri · b2 depan(down) ·
    b3 kanan. Diverifikasi mata (CREDITS.txt sumber)."""
    im = _buka(os.path.join(SRC, "lpc-monsters.zip"), "lpc-monsters/%s.png" % nama)
    return _grid(im, 64, 64, ["up", "left", "down", "right"])


def lpcm32(nama):
    """[LPC] Monsters sel 32 (bee) — baris sama dengan lpcm."""
    im = _buka(os.path.join(SRC, "lpc-monsters.zip"), "lpc-monsters/%s.png" % nama)
    return _grid(im, 32, 32, ["up", "left", "down", "right"])


def lpcm128(nama):
    """[LPC] Monsters sel 128 (man_eater_flower 768x512 = 6x4). Terbaca rusak saat
    dipotong 64 — bunganya memang selebar dua petak."""
    im = _buka(os.path.join(SRC, "lpc-monsters.zip"), "lpc-monsters/%s.png" % nama)
    return _grid(im, 128, 128, ["up", "left", "down", "right"])


def golem():
    """[LPC] Golem Redshrike — golem-walk.png 448x256 = 7x4 sel 64. Urutan baris
    LPC baku (diverifikasi lewat pratinjau mata sebelum ditulis)."""
    im = Image.open(os.path.join(SRC, "golem-walk.png")).convert("RGBA")
    return _grid(im, 64, 64, ["up", "left", "down", "right"])


def a22(nama, fw, fh):
    """lpc animals 2022 (bagian tapatilorenzo) — bukti-arah 2026-07-24
    (reports/preview/monster_arah_proof): b0 DEPAN · b1 kiri · b2 kanan · b3 BELAKANG."""
    im = _buka(os.path.join(SRC, "lpc_animals_2022_v1.1.zip"),
               "lpc animals 2022 v1.1/individual creature spritesheets/%s.png" % nama)
    return _grid(im, fw, fh, ["down", "left", "right", "up"])


def a22_sev(nama, fw, fh):
    """lpc animals 2022 — lembar SEVARIHK (giant rat, mushroom, shiba, shark).
    Urutan BEDA dari bagian tapatilorenzo: b0 BELAKANG (ekor tikus menghadap kamera
    di pratinjau saat dipetakan sebagai depan) · b1 kiri · b2 kanan · b3 depan."""
    im = _buka(os.path.join(SRC, "lpc_animals_2022_v1.1.zip"),
               "lpc animals 2022 v1.1/individual creature spritesheets/%s.png" % nama)
    return _grid(im, fw, fh, ["up", "left", "right", "down"])


def boar():
    """[LPC] Wild Boar — bukti-arah 2026-07-24: b0 DEPAN (taring terlihat) · b1 kiri ·
    b2 BELAKANG (ekor keriting) · b3 kanan. Catatan lama "b0 belakang" terbalik."""
    im = _buka(os.path.join(SRC, "wild_boar.zip"), "Wild Boar/Boar/Boar Walk.png")
    return _grid(im, 64, 64, ["down", "left", "up", "right"])


def sten(warna):
    """Stendhal dragons — 288x512 = 3 kolom x 4 baris sel 96x128, urutan N/E/S/W
    (format Stendhal) = [up, right, down, left]."""
    im = _buka(os.path.join(SRC, "stendhal_dragons.zip"), "PNG/96x128/%s_dragon.png" % warna)
    return _grid(im, 96, 128, ["up", "right", "down", "left"])


def kobold():
    """Kobold soldier — 144x256 = 3x4 sel 48x64, urutan N/E/S/W (format Stendhal)."""
    im = Image.open(os.path.join(SRC, "kobold-soldier-001.png")).convert("RGBA")
    return _grid(im, 48, 64, ["up", "right", "down", "left"])


def elephant():
    """Elephant Rework — 288x384 = 3x4 sel 96x96, urutan N/E/S/W (nama berkasnya)."""
    im = Image.open(os.path.join(SRC, "elephant-NESW.png")).convert("RGBA")
    return _grid(im, 96, 96, ["up", "right", "down", "left"])


def farm(nama):
    """LPC farm daneeklu — 512x512 = 4x4 sel 128. Bukti-arah 2026-07-24: LPC baku
    [up, left, down, right] (b0 = punggung/kepala-atas, b2 = menghadap kamera)."""
    im = Image.open(os.path.join(FARM, "%s_walk.png" % nama)).convert("RGBA")
    return _grid(im, 128, 128, ["up", "left", "down", "right"])


def _komponen(im, min_wh=8, alpha_min=10):
    """Bounding-box tiap gumpalan piksel (8-connected). Untuk lembar TAK-SERAGAM
    (wolfsheet, bunnysheet) yang kisi 32/64-nya membelah sprite."""
    from collections import deque
    W, H = im.size
    a = im.load()
    seen = bytearray(W * H)
    out = []
    for y in range(H):
        for x in range(W):
            if seen[y * W + x] or a[x, y][3] < alpha_min:
                continue
            q = deque([(x, y)])
            seen[y * W + x] = 1
            x0 = x1 = x
            y0 = y1 = y
            while q:
                cx, cy = q.popleft()
                x0 = min(x0, cx); x1 = max(x1, cx)
                y0 = min(y0, cy); y1 = max(y1, cy)
                for dx in (-1, 0, 1):
                    for dy in (-1, 0, 1):
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < W and 0 <= ny < H and not seen[ny * W + nx] \
                                and a[nx, ny][3] >= alpha_min:
                            seen[ny * W + nx] = 1
                            q.append((nx, ny))
            if (x1 - x0) >= min_wh and (y1 - y0) >= min_wh:
                out.append((x0, y0, x1 + 1, y1 + 1))
    return out


def wolf(sheet, ice=None):
    """[LPC] Wolf Animation Redshrike — lembar TAK-SERAGAM (pose depan/belakang 32px,
    samping 64px, dalam satu berkas). Wilayah dipetakan MATA dari
    reports/preview/wolf_region_proof*.png (2026-07-24):
      depan  = y192 x0..160  (5 frame 32x64)   belakang = y192 x160..320 (5 frame)
      kiri   = y128 [x320, x384, x576] (3 frame 64x32)   kanan = cermin kiri
    `ice` = kwargs re-warna."""
    im = Image.open(os.path.join(SRC, "wolfsheet%d.png" % sheet)).convert("RGBA")
    down = [im.crop((x, 192, x + 32, 256)) for x in (0, 32, 64, 96, 128)]
    up = [im.crop((x, 192, x + 32, 256)) for x in (160, 192, 224, 256, 288)]
    left = [im.crop((x, 128, x + 64, 160)) for x in (320, 384, 576)]
    return {"down": down, "up": up, "left": left, "right": _mirror(left)}


def bunny():
    """Bunnysheet5 — lembar tak-seragam; frame diambil lewat deteksi komponen lalu
    dikelompokkan per pita-y (bukti: reports/preview/bunny_region_proof.png):
      depan y96..160 kiri · belakang y96..160 kanan · kanan y192..256 · kiri y256+ kanan."""
    im = Image.open(os.path.join(SRC, "bunnysheet5.png")).convert("RGBA")
    comps = _komponen(im)
    def ambil(cond):
        fr = [im.crop(b) for b in sorted(comps, key=lambda b: b[0]) if cond(b)]
        return fr
    down = ambil(lambda b: 96 <= b[1] < 160 and b[0] < 150)
    up = ambil(lambda b: 96 <= b[1] < 160 and b[0] >= 150)
    right = ambil(lambda b: 192 <= b[1] < 256)
    left = ambil(lambda b: b[1] >= 256 and b[0] >= 150)
    if not left:
        left = _mirror(right)
    return {"down": down, "up": up, "left": left, "right": right}


def beetle():
    """LPC beetle Redshrike — latar MAGENTA (bukan alpha), kisi ~50px tak-persis.
    Magenta dibuang dulu, lalu komponen dikelompokkan per baris:
    r0 depan(bawah) · r1 belakang(atas) · r2 kanan · r3 kiri (bukti kontak 2026-07-24)."""
    im = Image.open(os.path.join(SRC, "beetle5.png")).convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if r > 200 and b > 200 and g < 100:
                px[x, y] = (0, 0, 0, 0)
    # Garis kisi PUTIH ikut tersisa dan menyatukan semua sel jadi satu komponen —
    # maka potong per SEL EKSAK (5 kolom x 4 baris, 49.6 x 49.75 px) lalu trim bbox.
    def sel(c, r):
        x0 = round(c * im.width / 5.0)
        x1 = round((c + 1) * im.width / 5.0)
        y0 = round(r * im.height / 4.0)
        y1 = round((r + 1) * im.height / 4.0)
        f = im.crop((x0 + 3, y0 + 3, x1 - 3, y1 - 3))
        bb = f.getbbox()
        return f.crop(bb) if bb else None
    def baris(r):
        return [f for f in (sel(c, r) for c in range(5)) if f is not None]
    return {"down": baris(0), "up": baris(1), "right": baris(2), "left": baris(3)}


def crab():
    """Big Red Crab rapidpunches — crab-walk.png 64x32 = 2 frame 32. Kepiting bergerak
    menyamping; frame yang sama dipakai keempat arah (siluetnya simetris)."""
    im = Image.open(os.path.join(SRC, "crab-walk.png")).convert("RGBA")
    fr = [im.crop((i * 32, 0, (i + 1) * 32, 32)) for i in range(2)]
    return {d: list(fr) for d in DIRS}


def burung(berkas, terbang=True):
    """lpc_birds / bird_2_eagle — 96x256 = 3 kolom x 8 baris sel 32.
    Baris 0-3 TERBANG, 4-7 BERJALAN. Bukti-arah 2026-07-24 (reports/preview/bird_rows):
    tiap kelompok berurutan [KIRI, BELAKANG, DEPAN, KANAN]."""
    im = Image.open(os.path.join(SRC, berkas)).convert("RGBA")
    off = 0 if terbang else 4
    out = {}
    for i, arah in enumerate(["left", "up", "down", "right"]):
        r = off + i
        out[arah] = [im.crop((c * 32, r * 32, (c + 1) * 32, (r + 1) * 32)) for c in range(3)]
    return out


# ───────────────────────────────────────────────────────────── tabel spesies
## (id, sumber_callable, recolor_kwargs|None, catatan_pendekatan|None)
SPESIES = [
    # ── lendir & jamur & tumbuhan (LPC Monsters + animals2022)
    ("verdant_slime",   lambda: lpcm("slime"),            None, None),
    ("gummy_slime",     lambda: lpcm("slime"),            {"h_deg": 210, "sat": 1.1}, None),
    ("king_slime",      lambda: lpcm("slime"),            {"h_deg": 150, "val": 1.1}, None),
    ("gummy_titan",     lambda: lpcm("slime"),            {"h_deg": 250, "sat": 1.2}, "boss: skala engine"),
    ("gummy_mimic",     lambda: lpcm("slime"),            {"h_deg": 60, "val": 1.15}, None),
    ("sporeling",       lambda: a22_sev("mushroom walker (Sevarihk)", 32, 32), None, None),
    ("treant_sapling",  lambda: lpcm128("man_eater_flower"), None, None),
    ("cactus_fiend",    lambda: lpcm128("man_eater_flower"), {"h_deg": -40, "sat": 0.8, "val": 0.9}, None),
    # ── serangga & gua
    ("honeybuzz",       lambda: lpcm32("bee"),            None, None),
    ("cave_bat",        lambda: lpcm("bat"),              None, None),
    ("cave_spitter",    lambda: lpcm("big_worm"),         None, None),
    # ── ular & 'belut'
    ("dune_viper",      lambda: lpcm("snake"),            {"h_deg": -60, "sat": 0.85, "val": 1.1}, None),
    ("dune_serpent",    lambda: lpcm("snake"),            {"h_deg": -90, "sat": 0.9, "val": 0.85}, None),
    ("soda_serpent",    lambda: lpcm("snake"),            {"h_deg": 90, "sat": 1.1}, None),
    ("volt_eel",        lambda: lpcm("snake"),            {"h_deg": 130, "sat": 1.2, "val": 1.1}, "ular ≈ belut"),
    ("levia_eel",       lambda: lpcm("snake"),            {"h_deg": 170, "sat": 1.1, "val": 0.9}, "ular ≈ belut"),
    # ── roh (hantu re-warna — pendekatan yang DILAPORKAN)
    ("cloud_ray",       lambda: lpcm("ghost"),            {"h_set": 200, "sat": 0.6, "val": 1.15}, "hantu ≈ pari awan"),
    ("nimbus_ray",      lambda: lpcm("ghost"),            {"h_set": 230, "sat": 1.1, "val": 0.8}, "hantu ≈ pari badai"),
    ("frost_elemental", lambda: lpcm("ghost"),            {"h_set": 185, "sat": 1.2, "val": 1.1}, "hantu ≈ elemental es"),
    ("storm_elemental", lambda: lpcm("ghost"),            {"h_set": 270, "sat": 1.2, "val": 0.95}, "hantu ≈ elemental badai"),
    ("peppermint_fairy",lambda: lpcm("ghost"),            {"h_set": 330, "sat": 0.9, "val": 1.2}, "hantu ≈ peri"),
    ("lollipop_sprite", lambda: lpcm("ghost"),            {"h_set": 45, "sat": 1.2, "val": 1.15}, "hantu ≈ sprite permen"),
    # ── golem (Redshrike; aslinya biru-es)
    ("glacier_core",    golem,                            None, None),
    ("rock_golem",      golem,                            {"abu": True, "val": 0.9}, None),
    ("caramel_golem",   golem,                            {"h_deg": 190, "sat": 0.9, "val": 0.95}, None),
    # ── gurun
    ("anubis_warden",   kobold,                           {"val": 0.9}, None),
    ("jackal_shade",    lambda: a22("fox, woods", 64, 64), {"sat": 0.4, "val": 0.45}, None),
    ("sand_scarab",     beetle,                           {"tint": (194, 160, 90, 0.3)}, None),
    ("vulture",         lambda: burung("lpc_birds_black.png"), None, "burung 32px"),
    # ── rubah & rusa & beruang
    ("forest_fox",      lambda: a22("fox, woods", 64, 64), None, None),
    ("frost_fox",       lambda: a22("fox, arctic", 64, 64), None, None),
    ("aurora_fox",      lambda: a22("fox, arctic", 64, 64), {"h_deg": 160, "sat": 1.3, "val": 1.05}, None),
    ("cervel",          lambda: a22("deer, light buck", 64, 96), None, None),
    ("choco_bear",      lambda: a22("bear, black", 64, 64), {"h_deg": -15, "sat": 1.2, "val": 1.05}, None),
    ("yeti_cub",        lambda: a22("bear, polar", 64, 64), None, None),
    ("frost_titan",     lambda: a22("bear, polar", 64, 64), {"sat": 1.2, "val": 1.05}, "boss: butuh skala engine"),
    # ── tikus & 'musang'
    ("volt_weasel",     lambda: a22_sev("giant rat (Sevarihk)", 80, 64), {"h_deg": 30, "sat": 1.3, "val": 1.15}, "tikus ≈ musang"),
    ("raiju",           lambda: a22_sev("giant rat (Sevarihk)", 80, 64), {"h_deg": 170, "sat": 0.7, "val": 1.3}, "tikus ≈ raiju"),
    # ── ternak & raksasa
    ("woolly_calf",     lambda: farm("cow"),              {"sat": 0.35, "val": 1.25}, None),
    ("candyfloss_sheep",lambda: farm("sheep"),            {"h_deg": 300, "sat": 1.4, "val": 1.1}, None),
    ("mammoth",         elephant,                         {"tint": (112, 72, 40, 0.4), "val": 0.9}, None),
    ("wild_boar",       boar,                             None, None),
    # ── naga (Stendhal, 96x128)
    ("thunder_dragon",  lambda: sten("blue"),             None, None),
    ("storm_sovereign", lambda: sten("purple"),           None, None),
    ("frost_wyvern",    lambda: sten("green"),            {"h_set": 195, "sat": 0.65, "val": 1.2}, None),
    ("blizzard_wyvern", lambda: sten("blue"),             {"sat": 0.35, "val": 1.25}, None),
    # ── burung besar (32px — KECIL; gap dilaporkan)
    ("timberwing_owl",  lambda: burung("lpc_birds_black.png"), {"h_deg": 30, "sat": 0.8, "val": 1.2}, "burung 32px ≈ burung hantu"),
    ("snow_owl",        lambda: burung("lpc_birds_white.png"), None, "burung 32px ≈ burung hantu"),
    ("thunder_hawk",    lambda: burung("bird_2_eagle.png"), None, "burung 32px KECIL utk hawk"),
    ("storm_roc",       lambda: burung("bird_2_eagle.png"), {"h_deg": 40, "sat": 1.2, "val": 0.8}, "burung 32px KECIL utk roc"),
    # ── kepiting
    ("storm_crab",      crab,                             None, None),
    ("tempest_crab",    crab,                             {"h_deg": 160, "val": 0.85}, None),
    # ── serigala (wolfsheet Redshrike, wilayah dipetakan mata)
    ("grey_wolf",       lambda: wolf(3),                  None, None),
    ("alpha_wolf",      lambda: wolf(1),                  {"val": 0.95}, "boss-kecil: skala engine"),
    ("dire_wolf",       lambda: wolf(2),                  None, None),
    ("ice_wolf",        lambda: wolf(3),                  {"sat": 0.35, "val": 1.2, "tint": (190, 220, 255, 0.25)}, None),
    ("frost_dire_wolf", lambda: wolf(2),                  {"val": 1.1, "tint": (200, 225, 255, 0.35)}, None),
    # ── kelinci (bunnysheet, deteksi komponen)
    ("fluffbit",        bunny,                            None, None),
    ("moonbit",         bunny,                            {"tint": (200, 190, 255, 0.3)}, None),
    ("jellybean_bunny", bunny,                            {"tint": (255, 150, 200, 0.35)}, None),
]


# ───────────────────────────────────────────────────────────── perakitan
def _sel_persegi(frames_per_arah):
    """Ukuran sel keluaran: persegi terkecil yang memuat frame terbesar."""
    m = 0
    for fr in frames_per_arah.values():
        for f in fr:
            m = max(m, f.width, f.height)
    return m


def rakit(arah_frames, recolor):
    """{dir:[frame]} -> (lembar PNG, sel, cols). Baris keluaran urut DIRS engine;
    tiap baris di-loop-isi sampai cols seragam; frame dipad rata-kaki ke sel persegi."""
    sel = _sel_persegi(arah_frames)
    cols = max(len(v) for v in arah_frames.values())
    kan = Image.new("RGBA", (sel * cols, sel * 4), (0, 0, 0, 0))
    for r, d in enumerate(DIRS):
        fr = arah_frames.get(d) or []
        if not fr:
            raise SystemExit("arah %s kosong" % d)
        for c in range(cols):
            f = fr[c % len(fr)]
            if recolor:
                f = _hue(f, **recolor)
            x = c * sel + (sel - f.width) // 2
            y = r * sel + (sel - f.height)          # rata-kaki
            kan.alpha_composite(f, (x, y))
    return kan, sel, cols


def main():
    lihat = "--lihat" in sys.argv
    tulis_json = "--tulis-json" in sys.argv
    hasil, lewat = [], []
    for sid, sumber, recolor, catatan in SPESIES:
        if sumber is None:
            lewat.append((sid, catatan))
            continue
        af = sumber()
        lembar, sel, cols = rakit(af, recolor)
        hasil.append((sid, lembar, sel, cols, catatan))
        print("  [OK] %-18s sel=%-3d cols=%d%s" % (sid, sel, cols,
              ("  ~ " + catatan) if catatan else ""))
    for sid, cat in lewat:
        print("  [TUNDA] %-15s %s" % (sid, cat))

    if lihat:
        # lembar kontak: 1 frame idle_down + 1 frame walk tiap spesies, skala 2
        S = 2
        P = 128 * S
        LK = 8
        baris = (len(hasil) + LK - 1) // LK
        kanv = Image.new("RGBA", (LK * P, baris * (P + 16)), (26, 24, 30, 255))
        d = ImageDraw.Draw(kanv)
        for i, (sid, lembar, sel, cols, _c) in enumerate(hasil):
            x, y = (i % LK) * P, (i // LK) * (P + 16)
            f0 = lembar.crop((0, 0, sel, sel))                # idle_down
            f1 = lembar.crop((min(1, cols - 1) * sel, 2 * sel, min(1, cols - 1) * sel + sel, 3 * sel))  # walk_left f1
            sc = min(P // 2 / sel, 2.0)
            for j, f in enumerate([f0, f1]):
                ff = f.resize((int(sel * sc), int(sel * sc)), Image.NEAREST)
                kanv.alpha_composite(ff, (x + j * P // 2, y + P - ff.height))
            d.text((x + 2, y + P + 2), sid[:20], fill=(230, 228, 234, 255))
        os.makedirs(os.path.dirname(PRATINJAU), exist_ok=True)
        kanv.save(PRATINJAU)
        print("-> %s  (%d spesies, %d ditunda)" % (PRATINJAU, len(hasil), len(lewat)))
        return 0

    os.makedirs(DST, exist_ok=True)
    meta = {}
    for sid, lembar, sel, cols, _c in hasil:
        lembar.save(os.path.join(DST, sid + ".png"))
        meta[sid] = (sel, cols)

    with open(os.path.join(DST, "monster_lpc.credits.txt"), "w", encoding="utf-8") as f:
        f.write(KREDIT)

    if tulis_json:
        with open(JSON_PATH, encoding="utf-8") as f:
            data = json.load(f)
        for e in data:
            if e["id"] in meta:
                sel, cols = meta[e["id"]]
                e["sprite"] = "res://assets/game/sprites/monsters/%s.png" % e["id"]
                e["frame_size"] = sel
                e["cols"] = cols
                e["rows"] = 4
        with open(JSON_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
        print("-> monsters.json diperbarui (%d entri)" % len(meta))

    print("-> %s  (%d lembar + kredit; %d ditunda wave-2)" % (DST, len(hasil), len(lewat)))
    return 0


KREDIT = """# Monster LPC beranimasi — dirakit `_tools/gen_monster_lpc.py` (#278).
# Lembar N kolom x 4 baris, baris = SheetUtil.DIRS [down, up, left, right],
# frame 0 = idle. Makhluk kecil DIBIARKAN kecil (32px) — kepadatan piksel sama,
# tanpa pembesaran blok.
#
# SUMBER (semua tercantum di assets_raw/oga/monsters/CREDITS.txt dengan URL):
#   [LPC] Monsters — CharlesGabriel, bagzie, bluecarrot16 (CC-BY-SA 3.0/GPL 3.0)
#     slime* bat snake* big_worm ghost* man_eater_flower* bee
#   [LPC] bears, deer, lions and more — tapatilorenzo (CC0) + Sevarihk (CC-BY 4.0)
#     fox* deer bear* giant-rat* mushroom-walker
#   [LPC] Wild Boar — BenCreating, daneeklu, Sharm (CC-BY-SA 3.0/GPL 3.0)
#   [LPC] Golem — Redshrike + William.Thompsonj (CC-BY/OGA-BY 3.0): golem*
#   Stendhal dragons — Kimmo Rundelin (CC-BY-SA 3.0): naga & wyvern*
#   Kobolds (Dog Soldier Rework) — yolkati, Cabbit/Svetlana Kushnariova,
#     diamonddmgirl, GrumpyDiamond, AntumDeluge (CC-BY-SA 3.0): anubis_warden
#   Elephant Rework — Kimmo Rundelin, dari lawnjelly (CC-BY 3.0): mammoth
#   LPC style farm animals — daneeklu (CC-BY 3.0): woolly_calf candyfloss_sheep
#   Big Red Crab — rapidpunches (CC-BY 3.0/4.0): storm_crab tempest_crab
#   LPC Raven and Seagull — Tuomo Untinen (CC-BY 3.0): vulture owl*
#   Bird sprites (bird_2_eagle) — lihat lpc_birds credits: thunder_hawk storm_roc
#   (* = termasuk varian re-warna hue-shift deterministik oleh generator)
#
# PENDEKATAN VISUAL YANG DILAPORKAN (bukan disembunyikan):
#   volt_eel/levia_eel = ular re-warna · cloud_ray/nimbus_ray = hantu re-warna
#   frost/storm_elemental = hantu re-warna · peppermint_fairy/lollipop_sprite = hantu
#   volt_weasel/raiju = tikus raksasa re-warna · frost_titan = beruang kutub (boss)
#   thunder_hawk/storm_roc/owl/vulture = burung 32px (KECIL untuk hawk/roc)
# WAVE-2 (belum diganti, masih seni lama): grey_wolf alpha_wolf ice_wolf dire_wolf
#   frost_dire_wolf fluffbit moonbit jellybean_bunny sand_scarab
"""


if __name__ == "__main__":
    sys.exit(main())
