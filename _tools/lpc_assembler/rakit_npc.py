# -*- coding: utf-8 -*-
"""RAKIT NPC — dari preset (data) jadi lembar sprite (gambar).

JEMBATAN, BUKAN PERAKIT BARU
----------------------------
`assemble.py` tak disentuh. Yang kurang cuma satu: resolver menghasilkan NAMA BERKAS
(`eulpc_legs_pants_thin_navy.png`) sedangkan perakit menerima ID KATALOG (`pants_thin`),
dan katalog itu daftar kurasi kecil — ia tak memuat sebagian besar berkas yang dikenal
lemari.

Jalan yang TIDAK ditempuh: menambah entri ke `catalog.json` untuk tiap berkas. Itu
akan menghidupkan lagi persoalan yang baru saja dibongkar — katalog jadi tempat ketiga
yang harus disunting tiap kali pustaka bertambah.

Yang ditempuh: katalog SEMENTARA di memori. Tiap slot preset didaftarkan dengan kunci
sintetis tepat sebelum dirakit, lalu dibuang. Katalog di disk tetap sebagaimana adanya,
dan perakit tetap menerima bentuk yang sudah dimengertinya.

BATAS YANG DISENGAJA
--------------------
Keluarannya masuk `reports/preview/npc/`, BUKAN `game/assets/`. Menulis ke sana
menyentuh penjaga siluet #231 dan menuntut persetujuan visual lebih dulu. Contoh dulu,
baru seratus dua puluh.

Pakai:
  python rakit_npc.py --contoh          # satu per kategori -> lembar kontak
  python rakit_npc.py --semua           # 120 (belum disetujui; sengaja tak diam-diam)
"""
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")

from PIL import Image, ImageDraw

import assemble as A
import rangka

HERE = os.path.dirname(os.path.abspath(__file__))
PRATINJAU = os.path.join(A.REPO_ROOT, "reports", "preview", "npc")

## Baris sheet LPC yang dipakai pratinjau: hadap-selatan (ke arah pemain) dan
## hadap-timur. Satu arah saja menyembunyikan cacat yang cuma muncul dari samping —
## dan siluet samping justru tempat "kaki kelebaran" paling terlihat.
SEL, TIM = "walk", None
SKALA = 2


def preset():
    with open(os.path.join(HERE, "npc_preset.json"), encoding="utf-8") as f:
        return json.load(f)


def ke_char(R, L, p, cat):
    """Preset -> (char dict untuk assemble, katalog yang sudah ditambahi).

    Katalognya DISALIN, tak diubah di tempat: perakit yang diam-diam menumbuhkan
    katalog global akan membuat hasil rakit bergantung pada urutan pemanggilan.
    """
    lama = rangka.ke_resep_lama(R, L, p)
    cat = {k: (dict(v) if isinstance(v, dict) else v) for k, v in cat.items()}
    char = {"id": p["id"], "body": p["build"], "head": lama["head"], "hair": None}

    # Badan & kepala datang sebagai PATH (`bases/muscular/amber.png`), bukan id
    # katalog — lihat `rangka.ke_resep_lama`. Didaftarkan dengan kunci sintetis supaya
    # `assemble.py` tetap menerima bentuk yang sudah dimengertinya.
    #
    # Ini yang menghidupkan `muscular`. Katalog memetakannya ke `eulpc_body_male.png`,
    # padahal badan muscular asli beda 51.918 piksel dari male — jadi selama ini tiap
    # tokoh muscular dirender berbadan biasa, buildnya mati kosmetik.
    cat.setdefault("body", {})[p["build"]] = lama["body"]
    kunci_kepala = "_npc_kepala_%s" % p["build"]
    cat.setdefault("head", {})[kunci_kepala] = lama["head"]
    char["head"] = kunci_kepala

    for slot in rangka.SLOT_PAKAIAN:
        berkas = lama.get(slot)
        if not berkas:
            char[slot] = None
            continue
        kunci = "_npc_" + os.path.splitext(os.path.basename(str(berkas)))[0]
        cat.setdefault(slot, {})[kunci] = berkas
        char[slot] = kunci
    if lama.get("hair"):
        kunci = "_npc_" + lama["hair"]
        cat.setdefault("hair", {})[kunci] = "eulpc_hair_%s.png" % lama["hair"]
        char["hair"] = kunci
    return char, cat


def petik(sheet, fmap, baris, kolom):
    c = fmap["cell"]
    return sheet.crop((kolom * c, baris * c, kolom * c + c, baris * c + c))


def lembar_kontak(hasil, fmap, keluar, judul):
    """Satu gambar: tiap tokoh satu baris, empat arah. Diberi label supaya laporan
    tak perlu dicocokkan dengan gambar dari ingatan."""
    c = fmap["cell"]
    arah = fmap["dir_order"]
    baris_jalan = fmap["animations"]["walk"]["rows"]
    kolom = fmap["animations"]["walk"]["frames"][0]

    lebar_label = 190
    w = lebar_label + len(arah) * c * SKALA
    h = len(hasil) * c * SKALA
    kanvas = Image.new("RGBA", (w, h), (26, 24, 30, 255))
    d = ImageDraw.Draw(kanvas)

    for i, (p, sheet) in enumerate(hasil):
        y = i * c * SKALA
        if i % 2:
            d.rectangle([0, y, w, y + c * SKALA], fill=(34, 32, 40, 255))
        for j, a in enumerate(arah):
            if a not in baris_jalan:
                continue
            sel = petik(sheet, fmap, baris_jalan[a], kolom)
            sel = sel.resize((c * SKALA, c * SKALA), Image.NEAREST)
            kanvas.alpha_composite(sel, (lebar_label + j * c * SKALA, y))
        pk = p["pakaian"]
        d.text((10, y + 14), p["id"], fill=(236, 232, 226, 255))
        d.text((10, y + 32), "%s / %s" % (p["build"], p["rambut"] or "-"),
               fill=(150, 146, 158, 255))
        d.text((10, y + 48), " · ".join(
            "%s %s" % (pk[s]["garmen"], pk[s]["warna"]) for s in rangka.SLOT_PAKAIAN
            if pk.get(s)), fill=(150, 146, 158, 255))

    d.text((10, 4), judul, fill=(210, 180, 120, 255))
    os.makedirs(os.path.dirname(keluar), exist_ok=True)
    kanvas.save(keluar)
    return keluar


KELUAR = os.path.join(A.REPO_ROOT, "game", "assets", "game", "sprites", "characters")


def pasang(R, L, cat, fmap, data, cdb):
    """Tulis 120 lembar + irisannya ke `characters/`. Nama `warga_NNN` berurutan.

    TIGA DIGIT, bukan dua. `TownFolk` dulu memakai `warga_%02d` untuk dua puluh warga;
    seratus dua puluh tak muat, dan `%02d` pada indeks 100 menghasilkan "warga_100"
    yang kebetulan MASIH terbaca — jadi kegagalannya bukan galat melainkan warga yang
    diam-diam salah. Formatnya diseragamkan ke `%03d` di kedua sisi.

    Penjaga #231 sengaja TIDAK dipanggil: ia menguji tokoh BERNAMA. Seratus dua puluh
    warga latar memang boleh bersiluet mirip — di LPC cuma tutup-kepala yang berdaya
    bentuk, dan menuntut 120 siluet unik mustahil sekaligus salah sasaran.
    """
    A.guard_232(KELUAR)
    os.makedirs(KELUAR, exist_ok=True)
    tulis, gagal = 0, []
    for i, p in enumerate(data["npc"]):
        nama = "warga_%03d" % i
        try:
            char, catx = ke_char(R, L, p, cat)
            sheet, dipakai = A.assemble_sheet(char, catx)
        except Exception as e:
            gagal.append((nama, p["id"], "%s: %s" % (type(e).__name__, e)))
            continue
        for anim, strip in A.slice_sheet(sheet, fmap).items():
            strip.save(os.path.join(KELUAR, "%s_%s.png" % (nama, anim)))
        A.write_credits(KELUAR, nama, dipakai, cdb)
        tulis += 1
    return tulis, gagal


def tokoh_ke_char(R, L, c, cat):
    """Resep tokoh bentuk BARU -> (char, katalog+). Ekstra hand-tuned dipertahankan.

    Bedanya dari `ke_char` NPC: tokoh bernama punya barang yang tak pernah diundi —
    `tint`, `facial`, `story_prop`, `headwear`, `palette_shift`, `race_overlay`.
    Semua itu dibiarkan lewat apa adanya. Yang diambil alih resolver HANYA tiga slot
    pakaian, karena cuma di situ pasangan mustahil pernah bisa ditulis.
    """
    build = c["build"]
    cat = {k: (dict(v) if isinstance(v, dict) else v) for k, v in cat.items()}
    char = dict(c)
    char["body"] = build
    b = R["build"][build]

    # Badan & kepala TETAP dari katalog kurasi, bukan dari `bases/`: tokoh bernama
    # punya `tint.body` yang disetel tangan, dan menukar sumber badannya akan
    # mengubah warna kulit sepuluh tokoh sekaligus tanpa diminta.
    if build in cat.get("body", {}):
        char["body"] = build
    char["head"] = c.get("head", b["kepala"])

    for slot, g in (c.get("garmen") or {}).items():
        berkas, kel, sebab = rangka.resolve(R, L, build, slot, g["garmen"], g["warna"])
        if berkas is None:
            raise ValueError("%s: %s" % (c["id"], sebab))
        kunci = "_tokoh_" + os.path.splitext(os.path.basename(str(berkas)))[0]
        cat.setdefault(slot, {})[kunci] = berkas
        char[slot] = kunci
    return char, cat


def tokoh(R, L, cat, fmap, cdb):
    """Rakit ulang sepuluh resep tokoh yang sudah dimigrasikan."""
    import glob
    A.guard_232(KELUAR)
    siap, gagal = [], []
    for f in sorted(glob.glob(os.path.join(HERE, "characters", "*.json"))):
        with open(f, encoding="utf-8") as fh:
            c = json.load(fh)
        if "garmen" not in c:
            gagal.append((c.get("id", f), "belum dimigrasikan (tak punya `garmen`)"))
            continue
        try:
            char, catx = tokoh_ke_char(R, L, c, cat)
            sheet, dipakai = A.assemble_sheet(char, catx)
            siap.append((c, sheet, dipakai))
        except Exception as e:
            gagal.append((c.get("id"), "%s: %s" % (type(e).__name__, e)))

    # #231 BERLAKU DI SINI, tak seperti pada warga latar: ini tokoh BERNAMA, dan
    # kembar-siluet di antara mereka persis yang gerbang itu dibuat untuk menahan.
    bernama = {c["id"]: sh for c, sh, _ in siap if c.get("named")}
    if len(bernama) > 1:
        A.guard_231(bernama)

    for c, sheet, dipakai in siap:
        for anim, strip in A.slice_sheet(sheet, fmap).items():
            strip.save(os.path.join(KELUAR, "%s_%s.png" % (c["id"], anim)))
        sheet.save(os.path.join(KELUAR, "%s.png" % c["id"]))
        A.write_credits(KELUAR, c["id"], dipakai, cdb)
    return len(siap), gagal


def main():
    R, L = rangka.muat()
    cat = A._catalog()
    fmap = A._frame_map()
    data = preset()

    if "--tokoh" in sys.argv:
        n, gagal = tokoh(R, L, cat, fmap, A._credits_db())
        for cid, sebab in gagal:
            print("  [GAGAL] %-16s %s" % (cid, sebab))
        print("-> %s   (%d tokoh, %d gagal)" % (KELUAR, n, len(gagal)))
        return 1 if gagal else 0

    if "--pasang" in sys.argv:
        n, gagal = pasang(R, L, cat, fmap, data, A._credits_db())
        for nm, pid, sebab in gagal:
            print("  [GAGAL] %-12s %-24s %s" % (nm, pid, sebab))
        print("-> %s   (%d warga, %d gagal)" % (KELUAR, n, len(gagal)))
        return 1 if gagal else 0

    contoh = "--semua" not in sys.argv
    if contoh:
        # satu per kategori — yang PERTAMA, bukan yang terbaik. Memilih yang paling
        # bagus untuk pratinjau adalah cara paling mudah menyetujui yang belum dilihat.
        pilih, sudah = [], set()
        for p in data["npc"]:
            if p["kategori"] not in sudah:
                sudah.add(p["kategori"])
                pilih.append(p)
    else:
        pilih = data["npc"]

    hasil, gagal = [], []
    for p in pilih:
        try:
            char, catx = ke_char(R, L, p, cat)
            sheet, _used = A.assemble_sheet(char, catx)
            hasil.append((p, sheet))
        except Exception as e:
            gagal.append((p["id"], "%s: %s" % (type(e).__name__, e)))

    for pid, sebab in gagal:
        print("  [GAGAL] %-24s %s" % (pid, sebab))
    if not hasil:
        print("nol lembar terakit."), sys.exit(1)

    keluar = os.path.join(PRATINJAU, "contoh_6.png" if contoh else "semua_120.png")
    lembar_kontak(hasil, fmap,
                  keluar, "PRATINJAU NPC — %d lembar%s" % (
                      len(hasil), "  (GAGAL %d)" % len(gagal) if gagal else ""))
    print("\n-> %s   (%d terakit, %d gagal)" % (keluar, len(hasil), len(gagal)))
    return 1 if gagal else 0


if __name__ == "__main__":
    sys.exit(main())
