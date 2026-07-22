# -*- coding: utf-8 -*-
"""LISENSI — baca berkas kredit, putuskan apakah ia viral. Murni, nol I/O gambar.

KENAPA ADA
----------
Dua hukum proyek saling tabrak kalau dibaca harfiah:

    #277  tiap aset WAJIB punya kredit
    #232  tak boleh ada berkas kredit / SA di luar `characters/`

Dibaca harfiah, aset hewan yang benar (punya kredit) langsung melanggar #232 hanya
karena kreditnya ADA. Penjaga lama memang begitu: ia memeriksa NAMA berkas, jadi ia
menghukum kejujuran.

Tapi yang sebenarnya dijaga #232 bukan keberadaan berkas kredit — melainkan
**keviralan**: lisensi share-alike menular ke turunannya, jadi ia dikarantina di
`characters/` supaya sisa proyek tetap bebas. Maka yang harus diperiksa adalah ISI
kreditnya, bukan namanya.

TIGA PUTUSAN, BUKAN DUA
-----------------------
    aman          ada lisensi non-viral yang dinyatakan (CC0 / OGA-BY / CC-BY)
    viral         HANYA share-alike — tak ada jalan keluar non-viral
    tak_tercatat  lisensinya tak diketahui

`tak_tercatat` sengaja TIDAK disamakan dengan `viral`, dan sengaja tidak dianggap
aman. Ia kelas tersendiri karena risikonya jenis lain: yang viral bisa DIPATUHI —
cukup ikut syaratnya. Yang tak tercatat tak bisa dipatuhi maupun dilanggar dengan
sadar; ia cuma tak boleh dirilis. Menggabungkannya ke salah satu kelas lain akan
menyembunyikan mana yang bisa diperbaiki dengan membaca dan mana yang menuntut
mencari sumber aslinya.

LISENSI BERGANDA
----------------
Banyak aset OpenGameArt ditawarkan berganda ("OGA-BY 3.0 / CC-BY-SA 3.0 / GPL 2").
Penerima BOLEH memilih satu. Kalau salah satunya non-viral, aset itu `aman` — tapi
kreditnya harus menyebut lisensi mana yang diambil, karena tawaran berganda yang tak
pernah dipilih bukan izin, cuma daftar kemungkinan.
"""
import re

## Penanda non-viral. `oga-by` dan `cc-by` TANPA akhiran `-sa`.
NON_VIRAL = [
    r"\bcc0\b",
    r"\bpublic\s+domain\b",
    r"\boga[-\s]?by\b(?![-\s]*sa)",
    r"\bcc[-\s]?by\b(?![-\s]*sa)(?![-\s]*\d+\.\d+[-\s]*sa)",
]
VIRAL = [r"\bcc[-\s]?by[-\s]?sa\b", r"\bshare[-\s]?alike\b", r"\bgpl\b"]

TAK_TERCATAT = [r"tidak\s+tercatat", r"\bunknown\b", r"\btidak\s+diketahui\b"]

## Karya proyek sendiri. Bukan pihak ketiga, jadi tak mungkin viral — keviralan adalah
## syarat yang dilekatkan PEMBERI lisensi, dan di sini tak ada pemberi lain.
KARYA_SENDIRI = [r"karya\s+proyek", r"buatan\s+sendiri", r"hasil\s+ai\b"]

## ⚠ PENYANGKALAN BUKAN PENGAKUAN. `wisp.credits.txt` menulis
##     "Lisensi: bukan CC-BY-SA, bukan LPC, bukan aset pihak ketiga"
## dan versi pertama pengklasifikasi ini membacanya sebagai pengakuan CC-BY-SA —
## menuduh viral justru berkas yang menyatakan dirinya TIDAK viral. Pencocokan pola
## yang buta pada kata ingkar akan selalu membalik arti kalimat semacam ini.
INGKAR = r"(?:bukan|tanpa|non|not|no)\s+[a-z0-9 .\-]{0,24}"


def _buang_ingkar(teks):
    """Hapus klausa yang DIINGKARI supaya namanya tak terbaca sebagai pernyataan."""
    return re.sub(INGKAR, " ", teks, flags=re.I)


def _baris_lisensi(teks):
    """Ambil baris yang MENYATAKAN lisensi. Baris lain (judul, catatan generator)
    bisa menyebut nama lisensi tanpa menyatakannya — memindai seluruh berkas akan
    membaca komentar 'bukan CC-BY-SA' sebagai pengakuan CC-BY-SA."""
    out = []
    for baris in teks.splitlines():
        b = baris.strip()
        if b.startswith("#"):
            continue                       # komentar generator, bukan pernyataan
        if re.match(r"^\s*(lisensi|license|licence)\s*:", b, re.I):
            out.append(b)
    return out


## ⚖ PUTUSAN DIREKTUR 2026-07-23 — SHARE-ALIKE DIIZINKAN UNTUK SELURUH ASET GAMBAR.
##
##   "seluruh asset bergambar dalam project ini diperbolehkan untuk sa, saya tidak
##    mempermasalahkan harus publikasi asset2"
##
## Sebelum ini `viral` ditolak di luar `characters/` (#232 sebagai KARANTINA). Itu
## masuk akal selama proyek berharap menahan sisa repo tetap non-viral — tapi proyek
## ini SUDAH mengirim 130 karakter LPC di bawah CC-BY-SA, jadi karantinanya menjaga
## garis yang sebenarnya sudah dilewati.
##
## Yang BERUBAH: `viral` tak lagi menggagalkan penjaga #232 untuk aset GAMBAR.
## Yang TIDAK berubah, dan ini yang penting:
##   * `tak_tercatat` TETAP menggagalkan. Izin memakai SA bukan izin memakai yang
##     provenansnya tak diketahui — yang viral bisa DIPATUHI, yang tak tercatat tak
##     bisa dipatuhi maupun dilanggar dengan sadar.
##   * atribusi TETAP wajib (#277). SA menuntutnya lebih keras, bukan lebih longgar.
##   * konsekuensinya MENEMPEL: apa pun yang menurunkan dari aset SA ikut SA. Itu
##     harga yang Direktur pilih sadar, dan dicatat di sini supaya orang berikutnya
##     tak mengira ia kecelakaan.
SA_DIIZINKAN = True


def klasifikasi(teks):
    """-> ('aman'|'viral'|'tak_tercatat', alasan). Tak pernah melempar."""
    baris = _baris_lisensi(teks)
    if not baris:
        return "tak_tercatat", "tak ada baris `Lisensi:` sama sekali"
    gabung = " ; ".join(baris)
    low = _buang_ingkar(gabung.lower())

    if any(re.search(p, low) for p in TAK_TERCATAT):
        return "tak_tercatat", gabung

    non = [p for p in NON_VIRAL + KARYA_SENDIRI if re.search(p, low)]
    vir = [p for p in VIRAL if re.search(p, low)]

    if non:
        # Berganda: ada jalan keluar non-viral. Sah, dan itulah yang kita ambil.
        return "aman", gabung
    if vir:
        return "viral", gabung
    return "tak_tercatat", "baris lisensi ada tapi tak dikenali: %s" % gabung


def periksa_berkas(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            return klasifikasi(f.read())
    except OSError as e:
        return "tak_tercatat", "tak terbaca: %s" % e
