# -*- coding: utf-8 -*-
"""RANGKA — resolver + pengundi karakter. Lapis DOMAIN sistem karakter.

TIGA LAPIS
----------
    LAPIS 1  rangka.json      build badan  -> kepala · keluarga pakaian · ukuran rambut
    LAPIS 2  lemari.json      garmen       -> berkas[keluarga][warna]
    LAPIS 3  characters/*.json  resep tokoh -> build + id garmen + warna

Berkas ini LAPIS DOMAIN yang menyatukan ketiganya, dan ia **murni**: nol I/O gambar,
nol Godot, nol efek samping. Itu disengaja — yang murni bisa diuji, dan yang bisa
diuji tak diam-diam rusak.

SATU JANJI YANG DITEGAKKAN DI SINI
----------------------------------
**Pasangan mustahil tak bisa ditulis.** Resep tokoh menyebut GARMEN ("longsleeve",
"navy"), tak pernah nama berkas. Keluarga berkasnya dipilih dari `build`. Jadi
"celana female di badan male" — cacat "kaki kelebaran" yang dilaporkan Direktur —
bukan lagi kesalahan yang mungkin dilakukan; ia jadi kalimat yang tak bisa diucapkan.

Sebelum ini resep menulis `"legs": "pants_thin"` langsung, dan lima tokoh dewasa
berbadan `male` memakai berkas female tanpa satu pun lapis yang menyadarinya.

MENAMBAH BARANG BARU
--------------------
  rangka baru : tambah satu entri di `rangka.json`          -> nol perubahan kode
  garmen baru : taruh PNG berpola, jalankan `gen_lemari.py` -> nol perubahan kode
  tokoh baru  : satu resep, atau `undi()` untuk NPC acak    -> nol perubahan kode

Pakai:
  python rangka.py --periksa           # laporan kesehatan: lubang build x slot
  python rangka.py --undi 5            # cetak 5 resep NPC acak
  python rangka.py --undi 5 --build male
"""
import json
import os
import random
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
LIB = os.path.join(REPO, "assets_raw", "lpc_extra")

SLOT_PAKAIAN = ["torso", "legs", "feet"]


# ─────────────────────────────────────────────────────────────── muat data
def muat():
    with open(os.path.join(HERE, "rangka.json"), encoding="utf-8") as f:
        rangka = json.load(f)
    with open(os.path.join(HERE, "lemari.json"), encoding="utf-8") as f:
        lemari = json.load(f)
    return rangka, lemari


def rambut_tersedia(ukuran):
    """Rambut ikut UKURAN BATOK, bukan build badan.

    Batok cuma dua ukuran, jadi mengunci rambut per-build akan membuang ratusan
    berkas tanpa sebab: badan `muscular` memakai kepala `male` yang sama persis
    dengan badan `male`, jadi tiap rambut yang muat di satu pasti muat di lainnya.
    """
    if not os.path.isdir(LIB):
        return []
    out = []
    for f in sorted(os.listdir(LIB)):
        if not f.startswith("eulpc_hair_") or not f.endswith(".png"):
            continue
        anak = "_child_" in f
        if (ukuran == "child") == anak:
            out.append(f[len("eulpc_hair_"):-4])
    return out


# ─────────────────────────────────────────────────────────── inti resolver
def kulit_tersedia(build):
    """Nada kulit yang punya BADAN untuk build ini.

    Sumbernya persediaan badan, bukan daftar terpisah: kepala punya 22 nada dan badan
    punya 22 nada, tapi kalau suatu hari salah satunya bertambah, daftar terpisah akan
    berbohong sampai ada yang menyadarinya di layar.
    """
    d = os.path.join(LIB, "bases", build)
    if not os.path.isdir(d):
        return []
    return sorted(f[:-4] for f in os.listdir(d) if f.endswith(".png"))


def kulit_sepadan(build, kepala):
    """Kulit yang punya BADAN build ini DAN KEPALA varian ini.

    Irisan, bukan gabungan. Badan bernada `amber` dengan kepala bernada `light` adalah
    persis cacat leher-pucat yang selama ini ditambal `tint` — dan tambalan itu bocor
    tiap kali seseorang memakai nada yang tak dimiliki kepala.
    """
    return sorted(set(kulit_tersedia(build)) & set(_kulit_kepala(kepala)))


def _kulit_kepala(varian):
    d = os.path.join(LIB, "heads", varian)
    if not os.path.isdir(d):
        return []
    return sorted(f[:-4] for f in os.listdir(d) if f.endswith(".png"))


def keluarga(rangka, build, slot):
    b = rangka["build"].get(build)
    if b is None:
        raise KeyError("build tak dikenal: %s" % build)
    return b["keluarga"].get(slot)


def rantai(rangka, build, slot):
    """Keluarga yang diminta, lalu rantai mundurnya. Urutan = urutan coba."""
    kel = keluarga(rangka, build, slot)
    if kel is None:
        return []
    return [kel] + list(rangka.get("mundur", {}).get(slot, {}).get(kel, []))


def pilihan(rangka, lemari, build, slot):
    """Semua (garmen, warna) yang SAH untuk build ini di slot ini.

    Kesahihan datang dari persediaan, bukan dari daftar izin terpisah — daftar izin
    yang terpisah dari berkasnya akan berbohong begitu satu berkas dihapus.
    """
    out = []
    for kel in rantai(rangka, build, slot):
        for garmen, g in sorted(lemari["garmen"].get(slot, {}).items()):
            for warna in sorted(g["berkas"].get(kel, {})):
                if (garmen, warna) not in out:
                    out.append((garmen, warna))
        if out:
            break            # keluarga pertama yang berisi menang; jangan dicampur
    return out


def resolve(rangka, lemari, build, slot, garmen, warna):
    """(build, slot, garmen, warna) -> nama berkas. None + sebab kalau tak ada.

    Mengembalikan SEBAB, bukan sekadar None: kegagalan senyap adalah cara cacat
    bertahan berbulan-bulan di proyek ini, dan resolver adalah tempat paling mudah
    untuk gagal senyap.
    """
    rt = rantai(rangka, build, slot)
    if not rt:
        return None, None, "build '%s' tak punya slot '%s'" % (build, slot)
    g = lemari["garmen"].get(slot, {}).get(garmen)
    if g is None:
        return None, None, "garmen '%s' tak ada di slot '%s'" % (garmen, slot)
    for i, kel in enumerate(rt):
        per_kel = g["berkas"].get(kel)
        if not per_kel:
            continue
        berkas = per_kel.get(warna)
        if berkas is None:
            return None, kel, ("garmen '%s' keluarga '%s' tak punya warna '%s' (ada: %s)"
                               % (garmen, kel, warna, ", ".join(sorted(per_kel))))
        # MUNDUR SELALU DILAPORKAN. Peminjaman yang senyap adalah utang yang hilang
        # dari pandangan, dan utang yang tak terlihat tak pernah dibayar.
        return berkas, kel, ("" if i == 0 else "MUNDUR: %s -> %s" % (rt[0], kel))
    return None, None, "garmen '%s' nol berkas untuk rantai %s (build '%s')" % (
        garmen, rt, build)


# ─────────────────────────────────────────────────────────────── pengundi
def undi(rangka, lemari, benih, build=None, wajib_lengkap=True):
    """Satu resep NPC acak yang DIJAMIN sah.

    Dijamin bukan karena diperiksa sesudahnya, melainkan karena tiap pilihan diambil
    dari daftar yang sudah disaring build. Pengundi yang memilih dulu lalu memvalidasi
    akan menghasilkan kombinasi gagal yang harus diulang — dan pengulangan itu tempat
    bug bersembunyi.
    """
    rng = random.Random(benih)
    if build is None:
        build = rng.choice(sorted(rangka["build"]))
    b = rangka["build"][build]
    # SATU nada kulit dipakai badan DAN kepala. Mengundi keduanya terpisah akan
    # melahirkan leher pucat di badan gelap — bukan sesekali, melainkan pada 21 dari
    # 22 kemungkinan.
    kul = kulit_sepadan(build, b["kepala"])
    resep = {
        "build": build,
        "badan": b["badan"],
        "kepala": b["kepala"],
        "kulit": rng.choice(kul) if kul else None,
        "pakaian": {},
        "rambut": None,
    }
    for slot in SLOT_PAKAIAN:
        opsi = pilihan(rangka, lemari, build, slot)
        if not opsi:
            if wajib_lengkap:
                resep["pakaian"][slot] = None      # dilaporkan, bukan disembunyikan
            continue
        garmen, warna = rng.choice(opsi)
        resep["pakaian"][slot] = {"garmen": garmen, "warna": warna}
    r = rambut_tersedia(b["rambut"])
    resep["rambut"] = rng.choice(r) if r else None

    # DALAMAN. `overalls` & `suspenders` di ULPC memang TANPA LENGAN — mereka tali dan
    # kain depan, dirancang dipakai di atas kemeja. Mengundinya tanpa dalaman
    # menghasilkan warga berdada telanjang, dan itu bukan kegagalan resolver: tiap
    # lapisnya sah, cuma kombinasinya tak pernah dimaksudkan berdiri sendiri.
    # Daftarnya di `rangka.json`, bukan di sini, supaya garmen semacam ini nanti bisa
    # ditambah tanpa menyentuh kode.
    resep["dalaman"] = None
    d = rangka.get("dalaman") or {}
    t = resep["pakaian"].get("torso")
    if t and t["garmen"] in (d.get("butuh") or []):
        opsi = [(g, w) for g, w in pilihan(rangka, lemari, build, "torso")
                if g == d.get("pakai_garmen")]
        if opsi:
            g, w = rng.choice(opsi)
            resep["dalaman"] = {"garmen": g, "warna": w}
    return resep


def ke_resep_lama(rangka, lemari, resep):
    """Terjemahkan ke bentuk yang dimengerti `assemble.py` (nama berkas mentah).

    Adapter, dan sengaja hanya SATU arah: lapis domain tak pernah membaca bentuk lama.
    Kalau perakit suatu hari diganti, yang dibuang cuma fungsi ini.
    """
    # Badan & kepala dirujuk sebagai PATH BERKAS, bukan id katalog. Katalog cuma punya
    # satu nada kulit per build; menambahkan 7x22 entri ke sana akan menjadikannya
    # tempat ketiga yang harus disunting tiap pustaka bertambah — persoalan yang baru
    # saja dibongkar, cuma berpindah tempat.
    kul = resep.get("kulit")
    out = {
        "body": ("bases/%s/%s.png" % (resep["build"], kul)) if kul else resep["badan"],
        "head": ("heads/%s/%s.png" % (resep["kepala"], kul)) if kul else resep["kepala"],
        "hair": resep["rambut"],
    }
    for slot, p in resep["pakaian"].items():
        if p is None:
            out[slot] = None
            continue
        berkas, _kel, sebab = resolve(rangka, lemari, resep["build"], slot,
                                      p["garmen"], p["warna"])
        if berkas is None:
            raise ValueError("resep tak bisa diresolusi: %s" % sebab)
        out[slot] = berkas
    return out


# ─────────────────────────────────────────────────────────────── kesehatan
def periksa(rangka, lemari):
    """Laporan lubang: build x slot yang nol pilihan. Dipakai CI & manusia."""
    lubang = []
    for build in sorted(rangka["build"]):
        for slot in SLOT_PAKAIAN:
            if not pilihan(rangka, lemari, build, slot):
                lubang.append((build, slot, keluarga(rangka, build, slot)))
    return lubang


def _cli():
    rangka, lemari = muat()
    if "--periksa" in sys.argv:
        print("=== PILIHAN PER BUILD ===")
        for build in sorted(rangka["build"]):
            b = rangka["build"][build]
            n = {s: len(pilihan(rangka, lemari, build, s)) for s in SLOT_PAKAIAN}
            print("  %-16s kepala=%-7s rambut=%-7s pilihan=%s"
                  % (build, b["kepala"], b["rambut"], n))
        print("  rambut dewasa=%d · anak=%d"
              % (len(rambut_tersedia("dewasa")), len(rambut_tersedia("child"))))
        lb = periksa(rangka, lemari)
        print("\n=== LUBANG (%d) ===" % len(lb))
        for build, slot, kel in lb:
            print("  %-16s slot %-6s -> keluarga '%s' KOSONG, rantai mundur pun habis"
                  % (build, slot, kel))
        return 0 if not lb else 1
    if "--undi" in sys.argv:
        i = sys.argv.index("--undi")
        n = int(sys.argv[i + 1]) if len(sys.argv) > i + 1 else 3
        paksa = None
        if "--build" in sys.argv:
            paksa = sys.argv[sys.argv.index("--build") + 1]
        for k in range(n):
            r = undi(rangka, lemari, 20260722 + k, paksa)
            print(json.dumps(r, ensure_ascii=False))
        return 0
    print(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(_cli())
