# -*- coding: utf-8 -*-
"""Petakan aset -> siapa yang memakainya. Untuk `reports/RAPIKAN_ASET.md`.

⚠ KENAPA GREP PATH SAJA TIDAK CUKUP, dan ini inti seluruh berkas ini:
Ashbrook menyusun path saat jalan, bukan menuliskannya utuh:

    _put(P_S + "fasad_inn.png", ...)          # awalan konstanta
    _jejak("rock.png", pos)                   # awalan DIPILIH dari akhiran nama
    v.lpc_sheet = "warga_%02d" % (awal + n)   # nama DIBENTUK dari angka

Mencari "res://assets/game/sprites/props/rock.png" akan menemukan NOL, lalu
menyimpulkan rock.png yatim — padahal ia dipakai di sepuluh tempat. Karena itu
pencarian dilakukan atas NAMA DASAR, dan pola `%s`/`%d` dilaporkan terpisah
sebagai bahaya yang tak bisa dijawab grep.

Keluaran: JSON + ringkasan layar. TIDAK memindah apa pun.
"""
import collections
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AKAR_ASET = os.path.join(REPO, "game", "assets")
EXT_ASET = {".png", ".jpg", ".jpeg", ".ogg", ".wav", ".ttf", ".svg", ".webp"}
EXT_SUMBER = {".gd", ".tscn", ".tres", ".json", ".cfg", ".import", ".py", ".md"}
# .import & .md ikut dibaca: .import memuat UID, .md memuat kredit per-aset —
# keduanya ikut putus kalau berkasnya pindah, dan keduanya sering terlupa.


def kumpulkan_aset():
    out = []
    for dp, _, fns in os.walk(AKAR_ASET):
        for f in fns:
            if os.path.splitext(f)[1].lower() in EXT_ASET:
                out.append(os.path.relpath(os.path.join(dp, f), REPO).replace("\\", "/"))
    return sorted(out)


# Berkas yang HARUS diabaikan supaya alat ini tak mencemari hasilnya sendiri.
# Putaran pertama melaporkan "nol yatim" — dan itu bukan kabar baik, itu cacat:
# `_peta_aset.json` memuat SELURUH daftar jalur aset, jadi tiap aset menemukan
# dirinya sendiri di sana dan menyatakan dirinya terpakai. Alat yang membaca
# keluarannya sendiri selalu setuju dengan dirinya sendiri.
ABAIKAN = ("_tools/peta_aset.py", "_tools/_peta_aset.json")


def kumpulkan_sumber():
    out = []
    for base in ("game", "_tools", "docs", "reports"):
        akar = os.path.join(REPO, base)
        if not os.path.isdir(akar):
            continue
        for dp, dns, fns in os.walk(akar):
            dns[:] = [d for d in dns if d not in (".godot", "preview")]
            for f in fns:
                if os.path.splitext(f)[1].lower() not in EXT_SUMBER:
                    continue
                p = os.path.join(dp, f)
                rel = os.path.relpath(p, REPO).replace("\\", "/")
                if rel in ABAIKAN:
                    continue
                try:
                    out.append((rel, open(p, encoding="utf-8", errors="ignore").read()))
                except OSError:
                    pass
    return out


def kelas(rel):
    """KODE = yang benar-benar memuat aset saat jalan. DOK = yang cuma menyebutnya.

    Bedanya menentukan segalanya: `KATALOG_GUDANG.md` menyebut ratusan nama berkas,
    dan menghitungnya sebagai pemakaian akan menyatakan seluruh gudang terpakai.
    Disebut di dokumen bukan dipakai di permainan.
    """
    if rel.endswith(".import"):
        return "import"
    if rel.endswith(".md"):
        return "dok"
    if rel.startswith("_tools/"):
        return "alat"          # generator: MELAHIRKAN aset, bukan memuatnya
    return "kode"


POLA_DINAMIS = re.compile(r'"[^"\n]*%[sd0-9][^"\n]*\.(png|ogg|wav)"')


def yatim_sementara(aset, dipakai, ragu):
    return [a for a in aset if not dipakai[a] and a not in ragu]


def main():
    aset = kumpulkan_aset()
    sumber = kumpulkan_sumber()
    print("aset: %d · berkas sumber: %d" % (len(aset), len(sumber)))

    dipakai = collections.defaultdict(list)
    disebut = collections.defaultdict(list)      # cuma dokumen/alat
    for jalur in aset:
        nama = os.path.basename(jalur)
        for rel, teks in sumber:
            if nama not in teks:
                continue
            k = kelas(rel)
            if k == "import":
                continue                          # .import milik aset itu sendiri
            (dipakai if k == "kode" else disebut)[jalur].append(rel)

    # ── PUTARAN KEDUA: NAMA TELANJANG ────────────────────────────────────────
    # Putaran pertama mencari "rock.png". Tapi `Main.gd` memanggil
    # `"res://assets/game/sprites/props/%s.png" % "rock"` — yang tertulis di kode
    # cuma `"rock"`, tanpa ekstensi. Melewatkan putaran ini menghasilkan 207
    # "yatim" yang sebagian besar PALSU, dan kalau daftar itu dipercaya, memindah
    # isinya akan mematikan dua puluh warga, seluruh fase bulan, dan tiap ikon
    # elemen sekaligus — semuanya tanpa satu galat pun.
    #
    # ⚠ TAPI PUTARAN INI TIDAK BOLEH DIPERCAYA SEBAGAI VONIS. Nama telanjang
    #   "cat", "coin", "nature" cocok dengan teks apa pun yang kebetulan memuat
    #   kata itu. Terlalu ketat menghasilkan yatim palsu; terlalu longgar
    #   menghasilkan "semua terpakai" yang sama tak bergunanya. Karena itu
    #   hasilnya masuk keranjang KETIGA — bukan "dipakai", bukan "yatim",
    #   melainkan "harus dilihat manusia".
    batang = re.compile(r'["\']([A-Za-z0-9_\-]+)["\']')
    kutip = collections.defaultdict(set)
    for rel, teks in sumber:
        if kelas(rel) == "kode":
            for m in batang.finditer(teks):
                kutip[m.group(1)].add(rel)
    ragu = {}
    for jalur in aset:
        if dipakai[jalur]:
            continue
        stem = os.path.splitext(os.path.basename(jalur))[0]
        if stem in kutip:
            ragu[jalur] = sorted(kutip[stem])

    # ── PUTARAN KETIGA: PENYUSUNAN DUA TINGKAT ───────────────────────────────
    # Yang paling berbahaya, karena namanya tak pernah muncul utuh DI MANA PUN —
    # bahkan potongannya pun berasal dari variabel:
    #
    #   Villager.gd:95    P_LPC + lpc_sheet + "_walk.png"   <- lpc_sheet = "warga_%02d"
    #   Ashbrook64.gd     P_C + str(spec[0]) + "_idle.png"  <- spec[0] = "merrit_fane"
    #   AshbrookKid.gd:42 P_ANAK + VARIAN[i] + "_idle.png"
    #   CharGen.gd:299    LPC_DIR + id + "_walk.png"
    #   HUD.gd:39         "moon_%d_%s.png" % [i, [daftar fase]]
    #
    # Mencari "warga_07_walk.png" menemukan NOL. Memindahkannya akan mematikan dua
    # puluh warga, dan `ResourceLoader.exists()` akan mengembalikan false dengan
    # tenang — persis cacat lentera-jadi-kotak. Karena itu batang & akhiran
    # dicocokkan TERPISAH, dan pemanggilnya sudah dibaca satu per satu.
    # Pola `"..._%s_32.png"` diubah jadi regex bercelah, lalu tiap aset diuji
    # kepadanya. Celah yang tertangkap dicek: apakah ia kata yang terkutip di kode
    # atau data? Kalau ya, aset itu dipakai — meski namanya tak pernah ditulis utuh.
    # Ini menggantikan tambalan khusus per-kasus; satu aturan menjawab warga, bulan,
    # ikon elemen, ikon barang, dan setiap pola yang belum lahir.
    pola = []
    for rel, teks in sumber:
        if kelas(rel) not in ("kode", "alat"):
            continue
        for m in re.finditer(r'"([^"\n]*%[sd0-9][^"\n]*\.(?:png|ogg|wav))"', teks):
            lit = m.group(1)
            # celah NON-SERAKAH. Serakah, "moon_%d_%s.png" akan memotong
            # "moon_1_waxing_crescent" jadi ("1_waxing", "crescent") — dan
            # "crescent" tak pernah terkutip di mana pun, jadi berkas yang jelas
            # terpakai divonis yatim. Potongan yang salah lebih berbahaya daripada
            # tak memotong sama sekali, karena ia tetap menghasilkan angka.
            rx = "^" + "".join(
                r"([A-Za-z0-9_\-]+?)" if bagian.startswith("%") else re.escape(bagian)
                for bagian in re.split(r"(%\d*[sd])", lit) if bagian
            ) + "$"
            pola.append((rel, lit, re.compile(rx)))

    # Pola PEMBUAT-POTONGAN: string berformat yang BUKAN nama berkas, misalnya
    # `"warga_%02d"` di TownFolk. Ia melahirkan potongan yang lalu dipakai penyusun
    # lain ("warga_07" + "_walk.png"). Tanpa lapisan ini, enam puluh lembar warga
    # divonis yatim — dan memindahkannya akan mengosongkan seluruh kota tanpa satu
    # galat pun.
    pembuat = []
    for rel, teks in sumber:
        if kelas(rel) != "kode":
            continue
        for m in re.finditer(r'"([A-Za-z0-9_\-]*%\d*[sd][A-Za-z0-9_\-]*)"', teks):
            lit = m.group(1)
            rx = "^" + "".join(
                r"[A-Za-z0-9_\-]+?" if b.startswith("%") else re.escape(b)
                for b in re.split(r"(%\d*[sd])", lit) if b
            ) + "$"
            pembuat.append(re.compile(rx))

    def celah_sah(g):
        return (g in kutip or g.isdigit()
                or any(p.match(g) for p in pembuat))
    # ditambah dua penyusun yang potongannya pun datang dari variabel, jadi tak
    # pernah muncul sebagai literal berformat (Villager/Ashbrook64/AshbrookKid/CharGen)
    for akh in ("_walk.png", "_idle.png", "_slash.png"):
        pola.append(("Villager.gd/Ashbrook64.gd/AshbrookKid.gd/CharGen.gd",
                     "<awalan-variabel>" + akh,
                     re.compile(r"^([A-Za-z0-9_\-]+)" + re.escape(akh) + "$")))

    for jalur in list(ragu) + list(yatim_sementara(aset, dipakai, ragu)):
        nama = os.path.basename(jalur)
        res = "res://" + jalur.split("game/assets/", 1)[1] if "game/assets/" in jalur else nama
        res = res.replace("res://", "res://assets/") if not res.startswith("res://assets/") else res
        for rel, lit, rx in pola:
            for calon in (nama, res):
                m = rx.match(calon)
                if not m:
                    continue
                celah = [g for g in m.groups() if g]
                if all(celah_sah(g) for g in celah):
                    dipakai[jalur].append("<pola '%s' di %s>" % (lit, rel))
                    ragu.pop(jalur, None)
                    break
            if dipakai[jalur]:
                break

    yatim = [a for a in aset if not dipakai[a] and a not in ragu]

    print("\n=== RAGU — nama telanjang terkutip, WAJIB dilihat manusia : %d ===" % len(ragu))
    rd = collections.defaultdict(list)
    for j, w in ragu.items():
        rd[os.path.dirname(j)].append((os.path.basename(j), w))
    for d in sorted(rd):
        print("  %s" % d)
        for nm, w in sorted(rd[d]):
            print("     %-34s <- %s" % (nm, ", ".join(w[:3])))

    print("\n=== YATIM (nol rujukan di kode/scene/dok) : %d ===" % len(yatim))
    per_dir = collections.defaultdict(list)
    for y in yatim:
        per_dir[os.path.dirname(y)].append(os.path.basename(y))
    for d in sorted(per_dir):
        print("  %s" % d)
        print("     " + " ".join(sorted(per_dir[d])))

    print("\n=== PENYUSUNAN NAMA DINAMIS (grep TAK BISA menjawab ini) ===")
    for rel, teks in sumber:
        if not rel.endswith((".gd", ".py")):
            continue
        for m in set(POLA_DINAMIS.findall(teks)):
            pass
        hits = set(POLA_DINAMIS.finditer(teks))
        for h in sorted({x.group(0) for x in hits}):
            print("  %-46s %s" % (rel, h))

    json.dump({"aset": aset,
               "dipakai": {k: v for k, v in dipakai.items() if v},
               "yatim": yatim},
              open(os.path.join(REPO, "_tools", "_peta_aset.json"), "w"), indent=1)
    print("\n-> _tools/_peta_aset.json")


if __name__ == "__main__":
    main()
