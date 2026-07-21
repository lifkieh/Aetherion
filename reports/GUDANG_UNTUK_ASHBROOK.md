# GUDANG UNTUK TATA-ULANG ASHBROOK — bahan, bukan rencana

**Dibuat:** 2026-07-21 · **Sifat:** inventaris terarah. **Nol perubahan `game/`. Nol ekstrak massal.**
**Metode:** tiap kandidat **dirasterisasi di atas papan catur + kisi 32 px lalu DILIHAT**
(`_tools/pandang_gudang.py`, #240). Kisi digambar supaya "berkisi 32 atau bukan" dijawab
oleh mata — kanvas 1024×1024 bisa berkisi 16, 32, atau bukan kisi sama sekali.
**Lembar kontak:** `reports/preview/gudang_ashbrook/`

> **⚠ TEMUAN DI LUAR TUGAS, PENTING:** `ASHBROOK_MAP_SPEC.md` **ADA** — di gudang
> (`Desktop\Gudang_asset\ASHBROOK_MAP_SPEC.md`), bukan di repo. POTRET_ASHBROOK.md kemarin
> menulis "tak ada di disk"; itu benar untuk `docs/`+`reports/`, salah untuk mesin ini.
> Ia memuat prinsip pendiri, tesis geografis ("berjalan ke tepi = berjalan mundur"), dan
> §0. **Baca ini sebelum tata ulang** — kolom SPEC di POTRET perlu dibaca ulang terhadapnya.

---

## RINGKAS — jawaban 5 kebutuhan

| # | kebutuhan | jawabannya | status |
|---|---|---|---|
| 1 | Jalan/path 32px | `4-season_terrain.zip` → `Terrain/Grass-Dirt (*).png` | 🎯 **langsung pakai** |
| 2 | Reruntuhan berbentuk | `decoration_medieval.zip` → `fence_medieval.png` (tembok batu + tembok RUSAK) + `rocks.zip` | 🎯 **langsung pakai** |
| 3 | Dekorasi ruang mati | `decoration_medieval.zip` + `4-season` Terrain Objects | 🎯 **langsung pakai** |
| 4 | Bangunan multi-arah | **NOL fasad multi-arah di mana pun.** Ada KIT modular (`Atlas.zip`) | ⚠ **keputusan, bukan aset** |
| 5 | Treeline timur/barat | **sudah ada di repo** (`pinus_isi/pinus_atas/pohon_gundul`) | 🎯 **nol aset baru** |

---

## 1 — JALAN / PATH 32 px

### 🎯 `4-season_terrain.zip` → `Terrain/Grass-Dirt (Summer|Spring|Autumn|Winter).png`
`reports/preview/gudang_ashbrook/s_grassdirt.png` · 96×224 · **OGA-BY 3.0**
(Sharm + Eliza Wyatt, `Terrain/Credits.txt` ada di dalam zip)

**Dilihat:** blob-autotile 3×3 **lengkap** — rumput ke tanah, semua sudut & tepi, plus
rumput-di-tanah dan sisipan tuft. Hijaunya **persis** hijau LPC (ini memang `grass32.png`
yang sama, direkolor Eliza), jadi nol risiko palet.

**Kenapa ini yang benar untuk prinsip 1:** jalan Ashbrook sekarang `stone32.png` berbentuk
**persegi panjang keras** (`_setapak()` menggambar `Rect2`). Lempeng batu bertepi tajam di
tengah rumput terbaca "ubin dipasang", bukan "tanah yang diinjak ribuan kaki". Blob
grass-dirt punya tepi berumbai — ia terbaca sebagai **jalan yang aus**, dan itu justru
tesis kota yang menyusut. Batu boleh tetap dipakai di alun-alun (seremonial); tanah untuk
jalan desa.

**Ongkos:** satu potongan 3×3 + penulis autotile sederhana. Pack sudah dipakai (treeline C4)
jadi jalur ekstraksi & kredit sudah berdiri.

### Cadangan (bukan pilihan pertama)
| aset | dilihat | putusan |
|---|---|---|
| `Atlas.zip` → `terrain_atlas.png` | LPC asli; kerikil, flagstone, batu-bata paving beberapa pola | 🎯 dipakai kalau butuh **pelataran** varian, bukan jalan tanah |
| `magecity.png` (sudah di repo) | **ada jalan kerikil berkelok** melintasi rumput, sekitar baris 13 | 🎯 murah — sumber sudah ada, tinggal iris |
| `Slates v.2 [...].png` | jalan tanah & cobble lengkap | ⚠ lihat catatan gaya di §4 |
| `ground_tiles.png` | Avalon grassland | ❌ palet kuning-pucat, bentrok total |

---

## 2 — RERUNTUHAN BERBENTUK (bukan tiang tercecer)

### 🎯 `decoration_medieval.zip` → `fence_medieval.png`
`g_fence_medieval.png` · 512×1024 · **CC-BY-SA 3.0 / GPL** (Reemax, Sharm, Johann C,
Hyptosis, Redshrike, wulax — `CREDITS-decorations-medieval.txt` di dalam zip)

**Dilihat, dan ini kunci prinsip 3:** selain pagar kayu (banyak gaya, **berikut sudut &
gerbang**), lembar ini punya **tembok batu rendah lengkap dengan potongan SUDUT** — artinya
**persegi fondasi bisa digambar sungguhan**, bukan disugestikan. Dan di baris bawah ada
**tembok batu RUSAK**: segmen bergerigi dengan celah, tepi patah, sisa menara.

Inilah yang tak dipunyai `wall_ruin.png` (yang ternyata **pagar kayu utuh** — nama menipu,
sudah tercatat di `DEPRECATED.md`) maupun `fondasi32.png` (garis rata, nol massa).

**Resep yang tersedia:** persegi tembok batu → hilangkan sebagian ruas → timpa `rocks.zip`
di celahnya. Hasilnya terbaca "**dulu ini bangunan**", bukan "batu berserakan".

### 🎯 `rocks.zip`
`g_rocks.png` · 1024×1024 · **CC0** (kurasi bluecarrot16; `CREDITS-rocks.txt` ada)

**Dilihat:** 4 palet (putih / abu / gelap / batu-pasir) × bongkah besar, **tumpukan puing**,
**serakan kerikil**, stalagmit, dan **dolmen/trilithon** (batu berdiri berambang). Kisi 32
lurus. CC0 = nol beban lisensi.

Puing & kerikil memberi **massa** pada garis fondasi; dolmen adalah penanda "jauh lebih tua
daripada desanya" untuk tepi terluar.

### 🎯 `Atlas.zip` → `terrain_atlas.png`
`a_terrain.png` · 1024×1024 · **CC-BY-SA 3.0 / GPL 3.0** (`Attribution.txt` ada)
**Dilihat:** segmen tembok batu patah, puing, **nisan + salib**, jembatan batu & kayu.
LPC asli. Kandidat kedua kalau `fence_medieval` kurang ragam.

---

## 3 — DEKORASI PENGISI RUANG MATI

### 🎯 `decoration_medieval.zip` → `decorations-medieval.png` — **panen terbesar sesi ini**
`g_decorations-medieval.png` · 512×2048 · **CC-BY-SA 3.0 / GPL** · LPC asli

**Dilihat satu per satu** (bukan dari nama):

| kelompok | isi |
|---|---|
| tanda gantung | papan INN, pedang, roti, sepatu, gulungan — **papan kosong juga ada** |
| lentera dinding | menyala & padam, beberapa gaya |
| **kubur** | nisan salib, lempeng, sarkofagus (pelengkap C4 kalau perlu) |
| **air** | palung minum, **kolam/air mancur bundar BERAIR**, patung |
| **sumur batu bundar** + ember + engkol | ⭐ penanda pusat desa klasik |
| pertanian | **gerobak dorong**, garu/sabit/garpu, **bal jerami**, tumpukan kayu, gerobak kayu bakar, kandang kayu |
| pasar | **tenda bergaris** banyak warna, meja lapak, rak, kursi, bangku |
| lain | panji/bendera, roda pedati, sasaran panah, api unggun (beranimasi), kuali, **tenda besar** |

**Kenapa penting:** prinsip 6 minta ruang mati diberi **tepi**, bukan ditaburi. Gerobak
terbalik, tumpukan kayu yang tak pernah diangkut, lapak pasar yang tinggal rangkanya —
semua ini **jejak kegiatan yang berhenti**, bukan hiasan. Itu bahasa yang sama dengan
pemakaman & fondasi yang sudah berhasil.

### 🎯 `4-season_terrain.zip` → `Terrain Objects/`
**OGA-BY 3.0** · sudah dipakai (treeline), jalur ekstraksi berdiri

| berkas | dilihat |
|---|---|
| `Grasses, Tall.png` (224×192) | rumput tinggi **6 ukuran × 3 musim**, bayangan sudah menyatu. **Varian musim gugur (kuning kering) tepat untuk Ashbrook** |
| `Rocks, Grasslands.png` (192×384) | batu padang rumput 3 palet × 8 ukuran — dari bongkah sampai kerikil |
| `Bush - Seasonal A/B/C` | semak berdaun & gundul |
| `Trees, Trunks.png` | **tunggul & batang patah** |
| `Flowers - Wildflowers (Autumn).png` | bunga liar musim gugur |
| `Mushrooms.png` | jamur |

---

## 4 — BANGUNAN MULTI-ARAH → **NOL. Ini keputusan penempatan.**

### Yang ADA di repo, dilihat langsung (`g_fasad_repo.png`)
Kelima fasad (`fasad_inn` 160×224, `fasad_gudang` 160×192, `fasad_shop` 96×192,
`fasad_kosong` 96×192, `fasad_rumah` 160×192) **seluruhnya atap-limas + dinding depan +
pintu + jendela, MENGHADAP SELATAN**. Nol varian samping, nol varian belakang, nol sudut.
Pintu menghadap kamera karena hanya itu yang digambar.

**Nol pack di gudang punya fasad LPC menghadap arah lain.** Sudah diperiksa: `magecity.png`
(sumber fasad ini) tak punya; `oldvillage.zip` painterly (❌); `adobe building set` gurun (❌).

### Yang ADA sebagai gantinya: **KIT MODULAR**

**🎯 `Atlas.zip` → `base_out_atlas.png`** · 1024×1024 · **CC-BY-SA 3.0 / GPL 3.0** · LPC asli
**Dilihat:** dinding bata & batu **sebagai ubin**, atap jerami & genteng **sebagai ubin**,
pintu, jendela, tangga batu, lengkung, jembatan kayu. Artinya bangunan **dirakit**, bukan
ditempel — dan bangunan rakitan bisa menghadap ke mana saja.

⚠ **Tapi ini bukan pekerjaan tata-letak.** Merakit bangunan dari ubin = pipeline baru
(aturan atap, y-sort per-lapis, tabrakan per-bagian). **Usul: jangan tempuh sekarang.**

### Jalan murah yang tetap patuh prinsip 2
Fasad menghadap selatan **tidak melarang** rumah menghadap ruang publik — ia hanya menuntut
rumah diletakkan **di sisi UTARA** ruang itu. Alun-alun bisa dikelilingi rumah yang semuanya
"benar" kalau: utara = fasad langsung menghadap alun-alun; timur & barat = fasad digeser
sehingga **pintunya membuka ke jalan yang lewat di depannya**; selatan = **jangan taruh
rumah** — itu tempat pemakaman/ladang/reruntuhan, dan kebetulan memang di situ sekarang.

**Ini keputusan Direktur+designer, bukan kekurangan aset.**

---

## 5 — TREELINE TIMUR/BARAT → **aset sudah di repo**

`pinus_isi.png`, `pinus_atas.png` (`game/assets/game/tiles/lpc32/`) dan
`pinus_pohon.png`, `pohon_gundul.png` (`sprites/props/`) — semuanya dari
`4-season_terrain.zip`, **OGA-BY 3.0**, kredit sudah tercatat.

Resep 4 lapis yang berhasil di selatan sudah tertulis lengkap di
`Ashbrook64.gd:_pemakaman_dan_kabut()` (fondasi digelapkan → kanopi jauh → kanopi tengah
digeser 20 px → baris depan berjarak tak rata). **Nol aset baru.**

⚠ Satu hal yang **belum** ada: resep itu menggambar pita **mendatar** (`Rect2(0, y, w, h)`).
Untuk sisi timur/barat butuh pita **tegak** — dan ubin pinus punya arah. Perlu diperiksa
apakah ubinnya bisa diputar tanpa terlihat salah, atau perlu susunan berbeda. **Itu
pertanyaan render, dijawab dengan melihat, bukan dengan menebak.**

---

## ⚠ NAMA MENIPU YANG DITEMUKAN SESI INI (untuk `DEPRECATED.md`)

| berkas | namanya berjanji | isinya sebenarnya |
|---|---|---|
| `Everything.zip` | "semuanya" — terdengar seperti tileset besar | **105 ikon UI/musik** (Fire/Gold/…). Nol ubin |
| `lpc_entry.zip` | terdengar tileset LPC | **184 lembar karakter** (zirah/senjata per-animasi). Nol ubin |
| `expansion_pack-0.04.zip` | terdengar ekspansi ubin | **animasi senjata** (longsword/rapier/spear) + xcf |
| `4-season_terrain.zip` | terdengar murni terrain | **2.621 berkas, mayoritas `Characters/`**. Terrain-nya hanya **81 berkas** — dan itu bagian yang berharga |
| `fantasy-tileset.png` | terdengar tileset fantasy | palet **GameBoy 4-warna hijau**. ❌ |
| `ground_tiles.png` | terdengar ubin tanah netral | Avalon grassland, **GPL3 tercetak di dalam gambar** ("BY: LEN PABIN 2009"), palet kuning-pucat |

## ⚠ LISENSI TIDAK DIKETAHUI (PNG lepas, nol berkas kredit di gudang)

| berkas | isinya (dilihat) | kenapa disayangkan |
|---|---|---|
| `Slates v.2 [32x32px orthogonal tileset by Ivan Voirol].png` (1792×736) | **kit kota 32px terlengkap di gudang** — jalan, cobble, dinding kayu-silang, atap banyak sudut, sumur, roda pedati, tenda pasar, papan INN/SHOP, peti, pohon, pagar, akuaduk | ⚠ nol berkas lisensi. **Dan gayanya lebih pekat & bergaris hitam** daripada LPC — dipakai bersama fasad sekarang akan terlihat dua permainan berbeda |
| `tileset_town_multi_v002.png` (256×2240) | atap limas & pelana **banyak arah**, **air mancur berair**, sumur, lentera jalan, tenda pasar, tangga, tong | ⚠ nol lisensi. Ini jawaban paling langsung untuk kebutuhan 4 — **kalau lisensinya bisa dipastikan** |
| `treepack.png` / `treepacknewest.png` (1024×1024) | oak bertajuk besar + pinus, akar oranye mencolok | ⚠ nol lisensi; palet lebih ramai daripada LPC |

**Aturan #277:** kredit wajib untuk semua aset. Tiga berkas di atas **tak bisa dipakai**
sampai penulisnya ditelusuri — bukan karena viral/non-viral, melainkan karena kreditnya
tak bisa ditulis. Ini utang penelusuran, bukan penolakan.

---

## Yang TIDAK dilakukan sesi ini (sengaja)

- **Nol ekstrak massal** — semua isi zip dibaca lewat `zipfile` dan dirasterisasi di memori.
  Nol berkas baru masuk OneDrive.
- **Nol perubahan `game/`.**
- **Nol tata ulang.** Ini bahan; penempatan menunggu Direktur + designer.
- Zip yang masih belum dilihat tetap ~83 (`GUDANG_INVENTARIS.md`) — sesi ini **terarah**,
  bukan menambah cakupan inventaris umum.

## Kalau tata ulang jadi dijalankan — urutan termurah lebih dulu

1. **Kepadatan warga + air mancur** — nol aset baru, murni angka zona. Paling merusak, paling murah.
2. **Ladang pindah ke tepi** — nol aset baru, pindah koordinat.
3. **Jalan tanah tulang-punggung** — 1 potongan dari `4-season` + penulis autotile.
4. **Reruntuhan diberi bentuk persegi** — `fence_medieval` + `rocks`.
5. **Ruang mati diberi tepi** — `decorations-medieval` + Terrain Objects.
6. **Treeline timur/barat** — nol aset baru, tapi perlu uji-mata rotasi ubin lebih dulu.

**Bangunan multi-arah TIDAK masuk daftar** — itu pipeline, bukan tata letak.
