# ASSET_BEKAS — Objek-Bukti A1 & A2 (bekas = MEKANIK, bukan dekorasi)

> **Konteks:** 4 objek di `docs/A1_PENGHAPUSAN_PERTAMA.md` & `docs/Aetherion_bible/A2_SESEORANG_MELUPAKANMU.md`
> bukan properti estetik — mereka **`evidence`** yang dikonsumsi `restore()` (`kind`: `akibat` ·
> `kebiasaan` · `benda`). **Uji kurasi bukan "cukup bagus?" melainkan:**
> **"apakah BEKAS-nya terlihat pemain TANPA dijelaskan?"** (D-3: nol teks · #210: tunjukkan).
> Bekas mati = mekanik mati. Survei gudang 2026-07-16, dengan **melihat gambar**.

## Verdikt ringkas
| # | Objek | `kind` bekas | Ada di gudang? | Verdikt |
|---|---|---|---|---|
| 1 | **Papan nama** (2 varian) | `akibat` (bekas cat) | Sign in-family ADA, **pasangan tulisan/kosong + bekas-cat TIDAK** | 🔴 **GAP — produksi** |
| 2 | **Bangku + 4 cekungan** | `kebiasaan` (tanah ingat) | Bangku TIDAK, cekungan TIDAK | 🔴 **GAP — produksi** |
| 3 | **Cangkir ×2 di meja** | `kebiasaan` (cangkir kedua) | Hanya piala harta (`GoldCup/SilverCup`) — **salah register** | 🔴 **GAP — produksi** |
| 4 | **Kartu pos kosong** | `benda` (tulisan di sudut) | `Letter.png` = amplop bersegel — **bukan kartu kosong** | 🔴 **GAP — produksi** |

**Keempatnya GAP.** Tak satu pun lolos uji "bekas terlihat tanpa dijelaskan" dari aset gudang apa adanya.
Bukan ditolak karena jelek — **ditolak karena bekasnya tidak ada atau tidak terbaca.**

---

## 1. PAPAN NAMA — `akibat` (bekas cat persegi panjang) 🔴 GAP
**Butuh (A1 §2–3):** varian **bertulisan** ("OTHA — JAHIT & TAMBAL", cat biru pudar) **+** varian
**KOSONG** (kayu polos · **2 lubang paku** · **persegi panjang lebih gelap di tengah** = kayu di bawah
cat tak ikut pudar oleh matahari). **Ini bekas paling penting di Act 1** — momen (b) bergantung padanya.

**Di gudang:** sign hanya menempel di tileset — hanging-sign **"DOJO"** (`TilesetHouse`) dan papan
pudar di `TilesetVillageAbandoned`. **Tidak ada pasangan tulisan↔kosong, dan tak ada bekas-cat.**
Bentuk Ashbrook = **papan tiang berpaku**, bukan sign gantung — DOJO pun beda bentuk.

**Uji bekas:** ❓ tak bisa diuji — sprite-nya belum ada.

**✅ Usul produksi (murah, sangat terbaca):** buat dari **1 tile kayu polos** (mis. 24×16) + overlay:
- *Bertulisan:* papan + blok warna cat biru-pudar (huruf tak terbaca di 16px — **tak apa, "ada tulisan" cukup terbaca**) + 2 titik paku gelap.
- *Kosong:* papan **sama** + **1 rect gelap** (paint-ghost, ~10×6, offset dari tengah) + 2 titik paku.
**Legibilitas:** **TINGGI.** Rect gelap di kayu pudar adalah salah satu sinyal "dulu ada sesuatu di
sini" paling terbaca di pixel-art — **lolos uji tanpa-teks.** Kandidat **paling layak langsung dibuat.**

## 2. BANGKU + 4 CEKUNGAN — `kebiasaan` (tanah ingat 34 tahun) 🔴 GAP
**Butuh (A1 §3):** bangku depan pintu + **4 cekungan di tanah** tempat kaki bangku, "sedalam tiga
puluh empat tahun". Bangku **tetap ada sesudah** penghapusan (kosong).

**Di gudang:** tak ada sprite bangku berdiri sendiri; tak ada cekungan tanah. Pagar kayu ada
(`TilesetHouse`) tapi bukan bangku.

**Uji bekas:** ❓ belum ada.

**⚠ Usul produksi + PERINGATAN JUJUR:** bangku = plank kayu sederhana (16×8, mudah). **Cekungan =
4 tile tanah lebih gelap** di posisi kaki (bukan sprite terpisah — decal/tile). **TAPI:** di 16px, di
atas tekstur rumput/tanah yang ramai, **4 titik gelap kecil berisiko terbaca sebagai kerikil/bayangan,
bukan "aus".** Ini **bekas paling rapuh** dari keempatnya. **Rekomendasi:** pakai **4 tile tanah
gundul lebih gelap** (bukan titik) agar kontras cukup, **dan tandai untuk playtest** — kalau pemain
yang teliti pun tak menangkapnya, cekungan perlu dibesarkan/dipergelap. Mekaniknya sah; keterbacaannya
di skala ini **belum tentu**.

## 3. CANGKIR ×2 DI MEJA — `kebiasaan` (Merrit menyisihkan cangkir kedua) 🔴 GAP
**Butuh (A2 §6):** Merrit **masih menyisihkan cangkir kedua tiap pagi** — tak tahu untuk siapa.

**Di gudang:** hanya **`GoldCup.png`/`SilverCup.png`** = **piala harta emas/perak** → **register salah:**
piala berkilau terbaca sebagai **loot/hadiah**, bukan kebiasaan pagi orang tua kesepian. `TeaLeaf.png`
ada (daun teh), cangkir keramik sederhana **tidak**.

**Uji bekas — WAWASAN KUNCI:** bekasnya **BUKAN pada detail cangkir**, melainkan pada **JUMLAH** —
**dua cangkir di meja satu penghuni**, dan yang kedua **tak pernah tersentuh.** Maka **mug sederhana
mana pun cukup**, asalkan scene menampilkan **dua** dan satu tak dipakai. **Legibilitas:** sedang —
pemain teliti menangkap "kenapa dua?", ~90% lewat (sesuai desain, seperti A1). **Lolos** bila
penempatan benar.

**✅ Usul produksi:** 1 sprite **mug/cangkir keramik polos** (~6–8px, palet hangat-pudar senada Ninja).
Tempatkan **dua** di meja pagi Merrit; yang kedua statis-selamanya = bukti.

## 4. KARTU POS KOSONG — `benda` (tulisan tangan Merrit di sudut) 🔴 GAP
**Butuh (A2 §2, §6):** kartu pos **kosong** di laci ("Aku beli waktu kau pertama datang"). Saat
ditunjukkan, Merrit mengernyit — **tapi itu tulisan tangannya di sudut: harga, tanggal.**

**Di gudang:** `Letter.png/Letter2/Letter3` = **amplop bersegel (lilin merah)** → terbaca "surat berisi",
**kebalikan** dari "kartu kosong". Tak ada kartu polos.

**Uji bekas — BATAS SKALA (temuan penting):** bekas `benda` di sini = **tulisan tangan di sudut** —
**itu sub-piksel di 16px.** **Tidak bisa dilukis ke sprite pada skala gaya kanon.** Artinya bekas ini
**harus pindah ke lapisan interaksi/close-up** (saat pemain menunjukkan kartu, detail muncul di panel
inspeksi), **bukan di sprite dunia.** Kartu di dunia hanya perlu terbaca **kosong**.

**✅ Usul produksi:** 1 sprite **kartu polos pucat** (~10×7, tanpa segel — sengaja beda dari `Letter`
yang bersegel). "Tulisan tangan di sudut" = teks/close-up di lapisan interaksi, bukan piksel dunia.

---

## TEMUAN LINTAS-OBJEK (untuk Direktur)

1. **Gaya 16px membebani bekas halus.** Dua dari empat bekas (**cekungan bangku**, **tulisan di kartu**)
   berada **di/atau di bawah batas keterbacaan 16px**. Ini konsekuensi langsung pilihan gaya Ninja
   (lihat `ASSET_ARCHAEOLOGY.md` §F — "16px membebani detail halus"). **Solusi bukan mengganti gaya**,
   melainkan: **bekas yang lebih besar dari piksel** (rect cat, tile-gelap) hidup di dunia; **bekas yang
   lebih kecil dari piksel** (tulisan tangan) hidup di **lapisan inspeksi**. Ini keputusan arsitektur
   kecil yang mengunci cara SEMUA `evidence` masa depan disajikan.
2. **Bekas terkuat = KONTRAS & JUMLAH, bukan detail.** Papan (rect gelap) dan cangkir (dua vs satu)
   lolos justru karena bekasnya **struktural**, bukan halus. **Panduan produksi bekas berikutnya:**
   utamakan bukti yang terbaca lewat **kontras nilai** atau **jumlah/ketidakcocokan**, hindari bukti
   yang bergantung pada **detail sub-piksel**.
3. **Tak satu pun perlu pack baru.** Keempatnya bisa lahir dari **tile kayu/tanah polos + overlay
   sederhana** — sejalan generator Python proyek (`assets_raw/aetherion_asset_generators/`). Biaya
   kecil, tapi **butuh sign-off desain** ("apakah rect ini terbaca sebagai bekas cat?") sebelum dibaptis.

## Rekomendasi urutan produksi (bila Direktur setuju)
1. **Papan nama 2 varian** — paling penting (klimaks A1), paling terbaca. Buat dulu.
2. **Cangkir mug polos** — murah, bekas = penempatan (dua).
3. **Kartu polos** — murah; putuskan lapisan-inspeksi untuk tulisan sudut.
4. **Bangku + cekungan** — buat, lalu **playtest keterbacaan cekungan** sebelum dikunci.

> **Batas tugas dihormati:** tak ada yang di-wire ke scene, tak ada sprite dibuat tanpa persetujuan.
> Ini audit + usul. Siap mengeksekusi produksi keempatnya begitu Direktur mengangguk.
