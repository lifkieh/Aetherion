# TELUSUR LISENSI — `tileset_town_multi_v002.png` + tiga pohon 224×128

**Dibuat:** 2026-07-21 · **Sifat:** penelusuran sumber. **Nol perubahan `game/`. Nol aset dipakai.**
**Aturan:** penulis & lisensi **tidak boleh ditebak**. Kalau halaman sahnya tak ketemu,
asetnya tetap haram (#277 mewajibkan atribusi).

**Metode pembuktian:** bukan pencocokan nama. Berkas di gudang **diunduh ulang dari halaman
sumbernya lalu dibandingkan SHA256**. Nama bisa kebetulan sama; byte tidak.

---

## 1 — `tileset_town_multi_v002.png` → ✅ **KETEMU + AMAN**

| | |
|---|---|
| Halaman | https://opengameart.org/content/exterior-32x32-town-tileset |
| Judul | *Exterior 32x32 Town tileset* |
| Seniman | **Arthur Carvalho** (OGA: `ArthCarvalho`) |
| Pengunggah | `n2liquid` |
| Proyek | **Sonetto Commons** — pengganti bebas untuk tileset resmi RPG Maker XP, digambar dari nol |
| **Lisensi** | **CC-BY-SA 4.0** |
| Ukuran di halaman | 70,1 KB · **satu** berkas lampiran |

### Bukti — byte-identik, bukan kemiripan

```
unduhan OGA   70133 byte   sha256 1ee659861aa2290f…
berkas gudang 70133 byte   sha256 1ee659861aa2290f…
IDENTIK: True
```

Berkas di gudang **adalah** berkas di halaman itu. Nama lampiran di OGA pun persis
`tileset_town_multi_v002.png` — termasuk `_v002`-nya.

Isi juga cocok dengan yang dilihat waktu katalog: menara jam, lentera jalan, tong, atap
banyak arah, air mancur berair — semuanya disebut di deskripsi halaman.

### Teks atribusi WAJIB (disalin apa adanya dari halaman)

```
Exterior 32x32 Town tileset by Arthur Carvalho, CC-BY-SA 4.0.
https://fb.com/sonettocommons. Copyright 2017, 2018 Guilherme Vieira
```

### Akibat untuk Ashbrook

**Boleh dipakai.** #277 menerima CC-BY-SA untuk seluruh aset visual; kredit tetap wajib.
Ini menutup satu-satunya lubang di `GUDANG_UNTUK_ASHBROOK.md` §4 — **bangunan multi-arah**,
plus air mancur berair untuk cacat 🔴-4 di `POTRET_ASHBROOK.md`.

⚠ **Dua hal yang masih harus diputuskan Direktur, dan keduanya bukan soal lisensi:**
1. **Gaya.** Palet Sonetto lebih terang & bergaris lebih tegas daripada LPC. Perlu diuji
   berdampingan dengan fasad sekarang sebelum dipakai — keputusan mata, bukan hukum.
2. **CC-BY-SA 4.0 vs 3.0.** Aset LPC repo ini CC-BY-SA **3.0**. Keduanya berbagi-serupa
   tapi versinya beda; 3.0 tidak otomatis kompatibel-maju ke 4.0. Selama keduanya dikredit
   terpisah per-berkas (pola `credits_db.json` sekarang), ini tak jadi soal — tapi jangan
   digabung jadi satu lembar campuran tanpa berpikir.

---

## 2 — Tiga pohon 224×128 → ✅ **KETEMU + AMAN**

| | |
|---|---|
| Halaman | https://opengameart.org/content/lpc-tree-recolors |
| Judul | *[LPC] Tree Recolors* |
| Pohon asli | **Casper Nilsson** (OGA: `C.Nilsson`) — dari entri Liberated Pixel Cup |
| Rekolor | **William Thompson** (OGA: `williamthompsonj`) |
| **Lisensi** | **CC-BY 4.0 / CC-BY 3.0 / GPL 3.0 / GPL 2.0 / OGA-BY 3.0** (berganda — pilih salah satu) |

### Yang meyakinkan bukan namanya — daftar lampirannya

Halaman itu melampirkan **11 berkas**, dan **kesebelasnya ada di gudang dengan nama persis
sama**, termasuk yang aneh-aneh: `autumn 2.png`, `autumn 3.png`, `brown trees 2.png`,
`yellow 2.png`, `blue trees.png`, `cherry_blossom_trees.png` — **dan `credits.zip`**.

### Bukti SHA256

| berkas | hasil |
|---|---|
| `green trees.png` | ✅ **identik** (12.351 byte) |
| `brown trees.png` | ✅ **identik** (12.810 byte) |
| `cherry_blossom_trees.png` | ✅ **identik** (14.961 byte) |
| `yellow.png` | ✅ **identik** (12.567 byte) |
| `blue trees.png` | ✅ **identik** (12.453 byte) |
| `autumn.png` | ⚠ **tidak byte-terbukti** — lihat di bawah |

**Soal `autumn.png`, dilaporkan apa adanya:** semua alamat yang saya coba
(`autumn.png`, `autumn_0`, `autumn_1`, `autumn_2`) menyajikan berkas **12.077 byte**,
sedangkan salinan gudang **12.316 byte**. Bedanya nyata tapi sempit: ukuran sama
(224×128), dan piksel yang berbeda **hanya di pita bayangan di kaki pohon**
(bbox 27,91–205,128) — pola beda yang **sama persis** dengan pasangan revisi lain di pack
ini. Daftar lampiran di halaman menyebut `autumn.png` **12,3 KB**, dan itu cocok dengan
salinan gudang (12.316 B), bukan dengan yang disajikan alamat tebakan saya.

**Kesimpulan yang jujur:** `autumn.png` hampir pasti revisi lain dari pack yang sama —
**tapi saya tidak berhasil mengunduh byte yang identik**, jadi statusnya "terbukti dari
pack, tidak terbukti dari byte". Lima saudaranya terbukti penuh. Kalau Direktur mau nol
keraguan, pakai `brown trees.png` (✅ byte-terbukti) yang idiomnya sama-sama musim gugur.

### Teks atribusi WAJIB (dari `credits.zip` yang ADA DI GUDANG)

```
Pink trees originally drawn by C. Nilsson. Two recolors are provided for variety.
Casper Nilsson — OpenGameArt.org: C.Nilsson
http://opengameart.org/users/cnilsson
Liberated Pixel Cup entry: http://opengameart.org/content/lpc-cnilsson

Recolored trees — William Thompson — OpenGameArt.org: williamthompsonj
http://opengameart.org/content/lpc-tree-recolors
```

Permintaan pengunggah: *"Credit C. Nilsson for his original trees. If you want to credit me
please link my profile."*

---

## 🔎 Temuan sistemik — kenapa aset ini pernah dikira "nol lisensi"

**`credits.zip` sudah ada di gudang sejak awal.** Ia berkas lisensi untuk pack pohon ini,
dan isinya menyebut halaman OGA-nya secara langsung. Waktu katalog, ia tercatat sebagai
*"1 berkas, nol gambar"* dan dilewati — karena **tak ada gambar di dalamnya**, dan alat
sapu memang cuma mencari gambar.

Sebabnya bukan kecerobohan satu berkas melainkan **cara aset ini diunduh**: semuanya
dijatuhkan **rata ke satu folder**, sehingga PNG kehilangan hubungannya dengan berkas
kredit yang datang bersamanya. Pack yang mengemas kreditnya **di dalam zip** (rocks,
decoration_medieval, 4-season) selamat; yang lampirannya terpisah (pohon-pohon ini)
kehilangan jejaknya di folder yang sama.

**Akibatnya untuk sisa daftar ⚠CEK:** sebagian "nol lisensi" mungkin **bukan** benar-benar
tanpa lisensi — kreditnya cuma terlepas. Langkah pertama sebelum menelusuri web:
periksa berkas `credits*.txt` / `*.zip` / `README` lepas di akar gudang dan cocokkan
isinya dengan pack yang menggantung. Itu lebih murah daripada pencarian web, dan sesi ini
membuktikannya menghasilkan.

---

## Ringkas — status daftar ⚠CEK sesudah sesi ini

| aset | status |
|---|---|
| `tileset_town_multi_v002.png` | ✅ **AMAN** — CC-BY-SA 4.0, Arthur Carvalho, byte-terbukti |
| `green/brown/blue/yellow/cherry trees` | ✅ **AMAN** — CC-BY/OGA-BY/GPL berganda, C. Nilsson + W. Thompson, byte-terbukti |
| `autumn.png` | ⚠ dari pack yang sama, **byte belum terbukti** — pakai `brown trees.png` kalau mau nol ragu |
| `Slates v.2` · `plant repack` · `Castle2` · `all.7z` · `WaterFountain` · `ProjectUtumno` · `ZRPG` · `treepack*` · `lpc-revised-workshops` | ⚠ **belum ditelusuri** — coba jalur "berkas kredit lepas di gudang" dulu |

**Nol aset dipindah ke repo sesi ini.** Pemasangan + penulisan `credits_db.json` menunggu
keputusan Direktur soal gaya.
