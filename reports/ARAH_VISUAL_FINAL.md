# ARAH VISUAL FINAL — riset penentu (#254)

**2026-07-19** · riset, **nol migrasi**, `_charsys` utuh. Bukti gambar dijalankan, bukan dikira.

---

# P1 — BISAKAH LPC RAS-MODULAR?

## JAWABAN TEGAS: **BISA — dan sambungannya MULUS. Tapi sumbunya berbeda dari visi Direktur.**

### Struktur yang ditemukan

`assets_raw/lpc/_ex/lpc_bases/lpc-character-bases-v3_1/`

| folder | isi | artinya |
|---|---|---|
| **`heads/`** | boarman · human_male/female/child/elderly · lizard · minotaur · orc · wolf · skeleton · zombie (**21 varian**) | **RAS hidup di KEPALA** |
| **`bodies/`** | child · female · male · muscular · pregnant · teen · skeleton · zombie (**8**) | **POSTUR, bukan ras** |
| palet kulit | 115 varian per badan, 68 per kepala — **namespace sama** (amber·black·blue·bright_green·bronze·brown·dark_green·fur_\*) | kepala & badan bisa dicocokkan warnanya |

Lembar `idle` = **128×256** (2 kolom × 4 arah @64px).

### Uji sungguhan — 5 rakitan lintas-ras, frame diam hadap-bawah

| rakitan | hasil |
|---|---|
| human murni (kontrol) | mulus |
| **kepala ORC + badan human** | **MULUS** — nol leher putus |
| **kepala LIZARD + badan human** | **MULUS** |
| **kepala WOLF + badan muscular** | **MULUS** |
| **kepala MINOTAUR + badan child** | **MULUS** — bahkan tanduk besar di badan anak tetap menyambung |

**Nol sambungan pecah.** LPC memang dirancang begitu: kepala digambar dengan jangkar leher tetap,
jadi ras apa pun bisa duduk di postur apa pun. Yang terlihat "loncat" hanyalah **warna** bila
palet kepala ≠ palet badan — itu pilihan, bukan cacat struktur. Pilih palet sama → sempurna.

### ⚠ TIGA BATAS YANG HARUS DIKETAHUI

1. **Ras hanya ada di KEPALA.** Tak ada "ras badan" dan tak ada "ras kaki".
2. **`legs_race` MUSTAHIL.** Tak ada lapisan kaki terpisah sama sekali — kaki bagian dari badan.
   Pemutar **"Kaki (ras)"** di creator **tak punya padanan di LPC**.
3. **Tak ada ELF.** `heads/` tidak memuat elf. Elf = overlay telinga
   (`assets_raw/lpc_extra/elvenears_light.png`), ditempel di kepala human.

### Pemetaan visi Direktur → LPC

| pemutar creator sekarang | di LPC |
|---|---|
| Kepala (ras) | ✅ **native** — 8 ras |
| Badan & Tangan (ras) | 🔄 **berubah sumbu** → **postur** (child·teen·male·female·muscular·pregnant) |
| Kaki (ras) | ❌ **tidak ada** |

**Visi 3-pemutar tidak mati — ia berubah bentuk:** dari *ras×3-bagian* menjadi
**ras-kepala × postur-badan × palet-kulit**. Ruang kombinasinya justru **lebih besar**
(21 kepala × 8 postur × 115 palet), tapi **bukan** sumbu yang sekarang ada di UI.

---

# P2 — LPC DIKECILKAN 50%: JELEK ATAU TIDAK?

## JAWABAN: **JELEK. Detailnya hilang, keunggulannya lenyap.**

Ukuran badan sebenarnya (bbox, bukan kanvas):

| | ukuran | hasil di layar |
|---|---|---|
| **LPC 64px penuh** | **30×48** | bayangan otot, lipatan baju, mata, helai rambut — semuanya terbaca |
| **LPC dikecilkan 50% (halus)** | 15×24 | **wajah hilang**, jadi noda buram |
| **LPC 50% (nearest)** | 15×24 | sedikit lebih tajam, tapi wajah tetap hancur; garis jadi kasar |
| **`_charsys` 32px** | 12×27 | datar, tapi **terbaca**: siluet jelas, warna tegas, wajah masih blok yang bisa dibedakan |

**LPC-kecil TIDAK jelas lebih baik dari `_charsys`.** Ia kehilangan justru apa yang membuatnya
layak dipilih. `_charsys` di 12×27 **digambar untuk ukuran itu**; LPC di 15×24 adalah seni
64px yang dihancurkan.

➡ **Opsi (B) gugur oleh buktinya sendiri.**

---

# P3 — ONGKOS DUNIA 64px DENGAN ASET GUDANG

## Fakta keras: **tak ada satu pun tileset 64px di gudang. Nol.**

- `magecity` (CC0) = **32px** · `hyptosis` batch (CC-BY) = **32px** · `DungeonCrawl/Utumno` (CC0) = **32px**
- 60 berkas di `assets_raw/lpc` berukuran kelipatan-64, **tapi semuanya grid 32px** (sudah diverifikasi berkas-per-berkas sesi lalu)
- Survei OpenGameArt: **nol pack dunia 64px CC0/CC-BY yang lengkap** (`reports/BURU_64PX_HASIL.md`)

**Sebabnya struktural:** standar LPC = **ubin 32×32 + frame karakter 64×64**. Angka 64 mengacu
pada kanvas karakter. **"Dunia 64px" bukan sesuatu yang ada di ekosistem LPC.**

## Persentase dunia yang bisa dipenuhi GUDANG (nol beli)

Target realistis = **dunia 32px** (bukan 64), memakai magecity + hyptosis + DCSS:

| kebutuhan | dari gudang | harus dicari/gambar |
|---|---|---|
| tanah/terrain | ✅ ~90% | — |
| perkerasan/jalan kota | ✅ ~90% | — |
| dungeon | ✅ ~95% | — |
| prop desa (tong·bangku·pohon·air mancur) | ✅ ~70% | ~30% |
| **bangunan fasad utuh** | 🔴 ~20% (hanya panel dinding/atap terpisah) | **~80%** |
| **interior** | 🔴 **0%** | **100%** |

**Kasar: ~65% dunia bisa dari gudang, ~35% harus dicari/dirakit** — dan yang 35% itu
terkonsentrasi di dua hal termahal: **fasad bangunan** dan **interior**.

## Ongkos upscale Greenvale (dunia utama pemain) ke 32px

Greenvale memakai `cobble_0/1` · `dirt_path` · `field` · `nature` + 10 bangunan +
**30 prop** lewat `WildDresser`/`Town`.

| bagian | unit |
|---|---|
| ubin dasar (4–6) dari magecity/hyptosis | 3–5 |
| 10 bangunan — **perlu perakitan fasad**, bahan terpisah | **10–16** |
| ~30 prop (sebagian ada, sebagian dirakit) | 8–12 |
| koordinat + zoom + z_index (pola sama dgn Ashbrook64) | 6–10 |
| interior rumah (`HouseInterior`) — **nol bahan** | 8–12 |
| test + verifikasi | 3–5 |
| **Greenvale total** | **≈38–60 unit** |

Sebagai pembanding: Ashbrook64 (desa kecil, tanpa interior) ≈ 56–86 unit — **Greenvale lebih
padat konten**, tapi Ashbrook menanggung ongkos belajar yang kini sudah lunas.

---

# REKOMENDASI

## Rekomendasi saya: **(A), dengan satu koreksi wajib — targetnya dunia 32px, bukan 64px.**

Ketiga opsi seperti dirumuskan tak ada yang tepat, jadi saya sebut yang benar:

> **(A′) — Karakter LPC 64px penuh + dunia 32px.** Itulah bentuk LPC kanonik,
> dan satu-satunya yang bahannya benar-benar ada.

**Kenapa (A′), bukan yang lain:**

1. **P1 membalikkan kekhawatiran terbesar.** Ras-modular **hidup** di LPC — bahkan lebih luas
   (21 kepala × 8 postur × 115 palet). Alasan utama mempertahankan `_charsys` **runtuh**.
2. **P2 membunuh (B).** LPC-dikecilkan bukan kompromi — ia kehilangan seluruh keunggulannya.
   Membayar ongkos LPC lalu membuang detailnya adalah pilihan terburuk dari ketiganya.
3. **P3 menunjukkan (A) versi 64px mustahil**, tapi versi **32px sangat mungkin** — ~65%
   bahan sudah di gudang, nol pembelian.
4. Perbandingan mentah tak seimbang: `_charsys` 12×27 vs LPC 30×48 = **LPC punya ~4,4×
   luas piksel**. Itu bukan selisih yang bisa dikejar dengan "menggambar lebih baik" di 12×27.

## Risiko terbesar kalau pilih lain

**Kalau pilih (C) `_charsys` diperhalus:** Anda mempertahankan sumbu ras-per-bagian yang
**ternyata tidak unik** — LPC punya modularitas yang setara-atau-lebih. Yang benar-benar Anda
pertahankan hanyalah **`legs_race`**, satu pemutar yang tak seorang pemain pun akan menyebutnya
alasan menyukai game ini. Harganya: menggambar ulang **seluruh** karakter, ras, animasi, dan
wardrobe **sendirian**, selamanya — sementara LPC menawarkan itu gratis dan sudah jadi.
**Itu risiko terbesarnya: membayar bertahun-tahun untuk mempertahankan satu pemutar.**

**Kalau pilih (B):** ongkos LPC dibayar penuh, hasilnya tak lebih baik dari yang sudah ada.
Terbukti di P2.

## Yang harus disiapkan kalau (A′) diambil

1. **Creator ditulis ulang** — 3 pemutar ras → **ras-kepala · postur-badan · palet-kulit**.
   Ini pekerjaan terbesar (≈23–38 unit) dan menyentuh `char_config` di save (`PlayerData.gd:714`).
2. **`legs_race` dihapus dari visi** — atau diganti sesuatu yang LPC punya (mis. **sepatu/wardrobe**).
3. **Elf lewat overlay telinga**, bukan kepala ras.
4. **Dunia 32px** dibangun bertahap dari magecity/hyptosis/DCSS; **fasad & interior** adalah
   dua lubang nyata yang perlu diselesaikan lebih dulu.
5. **`_charsys` TETAP** sebagai cadangan sampai creator LPC terbukti di jalur pemain.

⚠ **Satu hal yang belum terjawab dan sebaiknya diuji sebelum mengunci:** karakter LPC 64px
di dunia **32px** — apakah proporsinya benar? Uji Ashbrook64 sudah menunjukkan **ya, menyatu**
(`reports/preview/bukti254_lpc_dunia.png`). Itu satu-satunya kombinasi yang sudah terbukti
dengan mata, dan kebetulan ia persis (A′).
