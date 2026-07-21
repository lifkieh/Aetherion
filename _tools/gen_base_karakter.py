# -*- coding: utf-8 -*-
"""Pisahkan BADAN DASAR karakter 1-per-1 supaya bisa diundi bebas (#240).

TUJUAN
------
Perakit sekarang cuma mengenal EMPAT badan (`eulpc_body_{male,female,teen,child}`),
dan dua slot lain (`muscular`, `pregnant`) cuma ALIAS yang menunjuk male/female —
jadi tokoh "muscular" diam-diam berbadan male biasa. Berkas ini memisahkan tiap
badan jadi berkasnya sendiri, satu per (build x warna kulit), plus manifes, supaya
pembuat acak tinggal memilih dua sumbu: BUILD dan KULIT.

MUSCULAR FEMALE — TIDAK ADA DI PACK, JADI DITURUNKAN
----------------------------------------------------
Pack ULPC v3.1 punya `muscular` (berpostur male) tapi TIDAK punya padanan female.
Ia diturunkan di sini, dan cara menurunkannya dipilih supaya kesalahannya kecil:

    SILUET  diambil dari `female`   (otoritas proporsi: bahu, pinggul, dada)
    ISI     diambil dari `muscular` (otoritas bayangan: definisi otot)

Artinya tiap piksel yang ada DI DALAM alfa female diisi warna muscular bila muscular
punya piksel di titik itu; sisanya tetap female. Garis luar tak pernah berubah, jadi
badan hasilnya tetap muat di semua lapisan pakaian yang dibuat untuk female.

⚠ Ini TURUNAN, bukan gambar tangan seniman. Ia harus dilihat sebelum dipakai —
`BASE_03_muscular_female.png` dibuat justru untuk itu. Kalau matanya menolak,
buang; badan dasar yang salah merusak SETIAP tokoh yang menumpuk di atasnya.

FORMAT
------
Pack memberi `universal.png` 832x1344 (21 baris: spellcast/thrust/walk/slash/shoot/
hurt). Kanon perakit #233 adalah 832x2944 (46 baris). Berkas ditempel RATA-ATAS,
persis aturan README perakit, jadi baris 0-20 sejajar dan walk/idle/slash — satu-
satunya yang dipakai Ashbrook — jatuh di tempat yang benar. Baris 21+ kosong: badan
ini memang tak punya sit/jump/run/climb.

⚠ SUMBERNYA TIDAK IKUT TER-COMMIT. `assets_raw/` ada di `.gitignore` baris 56, jadi
zip pack, PNG hasil pisahan, dan seluruh pustaka `lpc_extra` HANYA ada di mesin yang
punya salinannya. Skrip ini ter-commit; bahannya tidak. Itu keadaan yang sudah
berlaku untuk `gen_fasad.py` dan `gen_hewan.py` juga — dicatat di sini supaya tak ada
yang mengira "generator ter-commit" berarti "bisa dijalankan ulang di clone kosong".

Pemakaian:
  python gen_base_karakter.py            # pisahkan + turunkan + lembar
  python gen_base_karakter.py --lembar   # lembar saja (tak menulis ulang badan)
"""
import io
import json
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
ZIP = os.path.join(REPO, "assets_raw", "lpc", "lpc-character-bases-v3_1.zip")
DST = os.path.join(REPO, "assets_raw", "lpc_extra", "bases")
PREVIEW = os.path.join(REPO, "reports", "preview", "karakter")
MANIFES = os.path.join(DST, "_manifes.json")

CELL = 64
TINGGI_KANON = 2944          # #233 — 46 baris
ROW_WALK_DOWN = 10

## Build yang diambil apa adanya dari pack.
BUILD = ["male", "female", "muscular", "pregnant", "teen", "child"]
## Build yang DITURUNKAN di sini karena pack tak punya.
TURUNAN = {"muscular_female": ("female", "muscular")}


def _f(n, tebal=False):
    for nama in (("consolab.ttf", "consola.ttf") if tebal else ("consola.ttf",)):
        try:
            return ImageFont.truetype(nama, n)
        except OSError:
            continue
    return ImageFont.load_default()


def papan(w, h, k=8):
    im = Image.new("RGBA", (w, h), (104, 106, 110, 255))
    d = ImageDraw.Draw(im)
    for y in range(0, h, k):
        for x in range(0, w, k):
            if (x // k + y // k) % 2:
                d.rectangle([x, y, x + k - 1, y + k - 1], fill=(138, 140, 144, 255))
    return im


def kanon(im):
    """Tempel RATA-ATAS ke tinggi kanon. Bukan diregangkan — diregangkan akan
    menggeser tiap baris animasi dan seluruh pustaka pakaian jadi meleset."""
    if im.height == TINGGI_KANON:
        return im
    out = Image.new("RGBA", (im.width, TINGGI_KANON), (0, 0, 0, 0))
    out.alpha_composite(im, (0, 0))
    return out


def turunkan(dasar, otot):
    """SILUET dari `dasar`, ISI dari `otot`. Garis luar dasar tak pernah diubah.

    Kenapa bukan sebaliknya: pakaian dibuat mengikuti siluet. Kalau siluet diambil
    dari muscular, tiap baju & celana female jadi meleset — dan itu persis cacat
    yang sedang kita perbaiki, cuma berpindah tempat.
    """
    a = dasar.convert("RGBA")
    b = otot.convert("RGBA")
    if b.size != a.size:
        b = b.crop((0, 0, a.width, a.height))
    pa, pb = a.load(), b.load()
    out = Image.new("RGBA", a.size, (0, 0, 0, 0))
    po = out.load()
    for y in range(a.height):
        for x in range(a.width):
            ca = pa[x, y]
            if ca[3] == 0:
                continue                      # di luar siluet dasar -> tetap kosong
            cb = pb[x, y]
            po[x, y] = cb if cb[3] > 0 else ca
    return out


def pisahkan():
    if not os.path.exists(ZIP):
        print("[GAGAL] pack tak ada: %s" % ZIP, file=sys.stderr)
        return None
    z = zipfile.ZipFile(ZIP)
    os.makedirs(DST, exist_ok=True)
    manifes = {"_doc": "Badan dasar dipisah 1-per-1 oleh gen_base_karakter.py. "
                       "Dua sumbu untuk pengundi: build x kulit.",
               "_format": "832x%d, rata-atas dari universal 832x1344" % TINGGI_KANON,
               "build": {}, "kulit": []}

    kulit = None
    for b in BUILD:
        pref = "lpc-character-bases-v3_1/bodies/%s/universal/" % b
        warna = sorted(x[len(pref):-4] for x in z.namelist()
                       if x.startswith(pref) and x.endswith(".png")
                       and "__MACOSX" not in x)
        if not warna:
            print("  [lewat] %s — nol varian kulit" % b)
            continue
        if kulit is None:
            kulit = warna
        os.makedirs(os.path.join(DST, b), exist_ok=True)
        for w in warna:
            im = kanon(Image.open(io.BytesIO(z.read(pref + w + ".png"))).convert("RGBA"))
            im.save(os.path.join(DST, b, w + ".png"))
        manifes["build"][b] = {"kulit": warna, "asal": "pack ULPC v3.1"}
        print("  [OK] %-16s %d warna kulit" % (b, len(warna)))

    # --- yang diturunkan ---
    for nama, (dasar, otot) in TURUNAN.items():
        if dasar not in manifes["build"] or otot not in manifes["build"]:
            print("  [lewat] %s — bahan turunannya tak lengkap" % nama)
            continue
        os.makedirs(os.path.join(DST, nama), exist_ok=True)
        n = 0
        for w in manifes["build"][dasar]["kulit"]:
            pa = os.path.join(DST, dasar, w + ".png")
            pb = os.path.join(DST, otot, w + ".png")
            if not (os.path.exists(pa) and os.path.exists(pb)):
                continue
            turunkan(Image.open(pa), Image.open(pb)).save(
                os.path.join(DST, nama, w + ".png"))
            n += 1
        manifes["build"][nama] = {
            "kulit": manifes["build"][dasar]["kulit"],
            "asal": "TURUNAN — siluet %s + isi %s (gen_base_karakter.py)" % (dasar, otot),
            "_awas": "bukan gambar tangan seniman; wajib dilihat sebelum dipakai",
        }
        print("  [OK] %-16s %d warna kulit  (TURUNAN dari %s + %s)" % (nama, n, dasar, otot))

    manifes["kulit"] = kulit or []
    with open(MANIFES, "w", encoding="utf-8") as f:
        json.dump(manifes, f, ensure_ascii=False, indent=1)
    print("manifes -> %s" % MANIFES)
    return manifes


def sel(path, kolom=0, baris=ROW_WALK_DOWN):
    im = Image.open(path).convert("RGBA")
    if im.height < (baris + 1) * CELL:
        baris = 0
    return im.crop((kolom * CELL, baris * CELL, (kolom + 1) * CELL, (baris + 1) * CELL))


def lembar_semua(manifes, kulit="bronze"):
    """Semua build berdampingan pada satu warna kulit — inilah 'apa yang kita punya'."""
    urut = [b for b in ["child", "teen", "female", "muscular_female", "male",
                        "muscular", "pregnant"] if b in manifes["build"]]
    ZM, PAD, HDR, CAP = 4, 18, 62, 44
    CW = CELL * ZM
    out = Image.new("RGBA", (len(urut) * (CW + PAD) + PAD, HDR + CW + CAP),
                    (22, 23, 26, 255))
    d = ImageDraw.Draw(out)
    d.text((PAD, 14), "BADAN DASAR — dipisah 1-per-1, siap diundi (kulit '%s')" % kulit,
           font=_f(19, True), fill=(245, 244, 240))
    x = PAD
    for b in urut:
        p = os.path.join(DST, b, kulit + ".png")
        if not os.path.exists(p):
            continue
        c = papan(CW, CW)
        c.alpha_composite(sel(p).resize((CW, CW), Image.NEAREST))
        out.alpha_composite(c, (x, HDR))
        tur = "TURUNAN" in manifes["build"][b].get("asal", "")
        d.text((x, HDR + CW + 6), b, font=_f(15, True),
               fill=(255, 200, 120) if tur else (250, 240, 200))
        d.text((x, HDR + CW + 24), "%d kulit" % len(manifes["build"][b]["kulit"]),
               font=_f(12), fill=(200, 200, 205))
        x += CW + PAD
    p = os.path.join(PREVIEW, "BASE_03_semua_build.png")
    out.convert("RGB").save(p)
    print("->", p, out.size)


def lembar_muscular_female(kulit="bronze"):
    """Uji mata khusus: female · muscular · TURUNAN, tiga frame jalan."""
    trio = [("female", "asal"), ("muscular", "asal"), ("muscular_female", "TURUNAN")]
    KOL = [0, 2, 4]
    ZM, PAD, HDR, CAP = 6, 16, 60, 32
    CW = CELL * ZM
    w = len(trio) * (len(KOL) * CW + PAD * 2) + PAD
    out = Image.new("RGBA", (w, HDR + CW + CAP), (22, 23, 26, 255))
    d = ImageDraw.Draw(out)
    d.text((PAD, 12), "MUSCULAR FEMALE — turunan: SILUET female + ISI muscular",
           font=_f(20, True), fill=(245, 244, 240))
    d.text((PAD, 36), "pack ULPC tak punya padanan female untuk muscular; ini bukan gambar seniman",
           font=_f(13), fill=(200, 190, 170))
    x = PAD
    for b, tag in trio:
        for kol in KOL:
            p = os.path.join(DST, b, kulit + ".png")
            c = papan(CW, CW)
            if os.path.exists(p):
                c.alpha_composite(sel(p, kol).resize((CW, CW), Image.NEAREST))
            out.alpha_composite(c, (x, HDR))
            x += CW
        d.text((x - len(KOL) * CW, HDR + CW + 6), "%s  (%s)" % (b, tag),
               font=_f(15, True),
               fill=(255, 200, 120) if tag == "TURUNAN" else (250, 240, 200))
        x += PAD * 2
    p = os.path.join(PREVIEW, "BASE_04_muscular_female.png")
    out.convert("RGB").save(p)
    print("->", p, out.size)


if __name__ == "__main__":
    os.makedirs(PREVIEW, exist_ok=True)
    if "--lembar" in sys.argv and os.path.exists(MANIFES):
        m = json.load(open(MANIFES, encoding="utf-8"))
    else:
        m = pisahkan()
    if m:
        lembar_semua(m)
        lembar_muscular_female()
