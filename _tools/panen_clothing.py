# -*- coding: utf-8 -*-
"""PANEN `lpc-2024-10-15-expanded-ulpc-clothing.zip` -> pustaka lemari.

KENAPA INI HAMPIR TERLEWAT
--------------------------
Zip ini sudah ada di disk sejak lama dan tak pernah dibongkar. Isinya 18 garmen torso
x 24 warna untuk female/teen — lebih banyak daripada seluruh isi lemari waktu itu.
Lemari melaporkan `female torso: 5` selama berminggu-minggu, dan angka itu benar
tentang PUSTAKA sekaligus salah tentang APA YANG TERSEDIA.

Pelajaran yang sama tiga kali sekarang: sepatu male, kemeja anak, dan sekarang ini.
Yang membatasi bukan aset, melainkan kesediaan memeriksa apa yang sudah dipegang.

BEDANYA DENGAN `ambil_lpc.py`
-----------------------------
Zip ini menyimpan LEMBAR UNIVERSAL 832x2944 utuh — siap pakai, nol komposisi. Yang
diunduh dari repo generator disimpan per-animasi dan harus disusun dulu. Karena itu
dua alat, bukan satu: menyatukannya akan memaksa satu jalur kode berpura-pura
menangani dua bentuk sumber yang tak punya kesamaan apa pun selain tujuannya.

Pakai:
  python panen_clothing.py            # tulis ke assets_raw/lpc_extra/
  python panen_clothing.py --lihat    # cetak rencananya, tak menulis
"""
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
ZIP = os.path.join(REPO, "assets_raw", "lpc_extra",
                   "lpc-2024-10-15-expanded-ulpc-clothing.zip")
JADI = os.path.join(REPO, "assets_raw", "lpc_extra")

## Build sumber -> keluarga lemari. `adult` dilewat: itu penanda tutup-kepala yang
## tak punya keluarga badan, dan memasukkannya akan melahirkan keluarga palsu.
KELUARGA = {"female": "female", "male": "male", "teen": "teen", "thin": "thin"}

## Slot yang dipanen. `hat` dilewat — lemari belum punya slot tutup-kepala, dan
## menambah berkas untuk slot yang tak dibaca siapa pun cuma menumpuk yatim.
SLOT = {"torso", "legs"}

## Garmen yang DILEWAT karena pustaka sudah memuatnya dengan nama lain; memanennya
## akan melahirkan dua garmen berbeda nama yang gambarnya sama persis.
LEWAT = {"longsleeves", "shortsleeves"}


def rencana():
    z = zipfile.ZipFile(ZIP)
    out = []
    for x in z.namelist():
        if not x.endswith(".png"):
            continue
        bagian = x.split("/")
        if len(bagian) != 5:
            continue                       # 3-4 tingkat = lembar pratinjau, bukan aset
        slot, _kategori, garmen, build, warna = bagian
        if slot not in SLOT or build not in KELUARGA or garmen in LEWAT:
            continue
        nama = "eulpc_%s_%s_%s_%s" % (slot, garmen, KELUARGA[build], warna)
        out.append((x, nama))
    return z, out


def main():
    if not os.path.exists(ZIP):
        print("[GAGAL] zip tak ada: %s" % ZIP, file=sys.stderr)
        return 1
    z, daftar = rencana()

    # ⚠ RINGKASAN INI MEMBACA NAMA DENGAN CARA YANG SAMA PERSIS DENGAN `gen_lemari`:
    #   cari TOKEN KELUARGA, jangan hitung posisi garis-bawah. Versi pertama memakai
    #   posisi dan melaporkan `longsleeve2_buttoned` sebagai garmen "longsleeve2"
    #   berkeluarga "buttoned" — keluarga yang tak pernah ada. Nama berkasnya sendiri
    #   sebenarnya benar; yang salah cuma laporannya, dan laporan yang salah tentang
    #   data yang benar adalah cara paling cepat memperbaiki hal yang tidak rusak.
    ringkas = {}
    for _src, nama in daftar:
        bagian = nama[len("eulpc_"):-4].split("_")
        slot, sisa = bagian[0], bagian[1:]
        i = next((k for k, b in enumerate(sisa) if b in KELUARGA.values()), None)
        if i is None:
            continue
        ringkas.setdefault((slot, "_".join(sisa[:i])), set()).add(sisa[i])
    print("=== RENCANA (%d berkas) ===" % len(daftar))
    for (slot, garmen), kel in sorted(ringkas.items()):
        print("  %-6s %-24s keluarga: %s" % (slot, garmen, sorted(kel)))

    if "--lihat" in sys.argv:
        return 0
    for src, nama in daftar:
        with open(os.path.join(JADI, nama), "wb") as f:
            f.write(z.read(src))
    print("\n-> %s   (%d berkas)" % (JADI, len(daftar)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
