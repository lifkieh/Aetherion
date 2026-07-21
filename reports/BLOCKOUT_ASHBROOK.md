# BLOCKOUT ASHBROOK — dua peta kotak polos

**Dibuat:** 2026-07-21 · **Sifat:** DRAFT untuk dicoret Direktur. Bukan keputusan.
**Berjangkar:** `ASHBROOK_MAP_SPEC.md` (Gudang_asset) + `game/scenes/world/Ashbrook64.gd`
**Nol perubahan `game/`. Nol aset dipasang.** Yang lahir cuma dua PNG + skrip pelahirnya.

| | |
|---|---|
| A — apa yang ada | `reports/preview/blockout/A_apa_yang_ada.png` |
| B — usul dari spec | `reports/preview/blockout/B_usul_dari_spec.png` |
| **B′ — TATA LETAK FINAL** | **`reports/preview/blockout/B_aksen.png`** ← keputusan Direktur |
| Skrip (#240) | `_tools/gen_blockout_ashbrook.py` |
| Skala | 1:1 dunia — 60×44 petak = **1920×1408 px**, ditambah panel keterangan 640 px |

**Kenapa kotak dan bukan sprite.** Yang harus diputuskan di sini adalah *di mana apa,
menghadap ke mana*. Fasad yang bagus mengganggu penilaian itu: mata menilai gambarnya,
lalu menyimpulkan tata letaknya ikut baik. Blockout sengaja tak enak dipandang.

**Cara membacanya.** Tiap bangunan digambar **dua lapis**: massa fasad (tembus pandang,
yang DILIHAT pemain) dan petak kaki 40 px yang padat (yang MENGHALANGINYA). Di Ashbrook
keduanya berbeda ukuran — menggambar satu saja menyembunyikan separuh soal. Panah putih
di bawah tiap kotak = arah pintu. Semua fasad repo berpintu **selatan**, dan itu batasan
yang membentuk seluruh versi B.

⚠ **Peta A disalin tangan dari `.gd`, bukan dirender dari Godot.** Kalau `Ashbrook64.gd`
berubah, A bohong sampai koordinatnya disalin ulang. Ongkos itu disengaja: menyuntik
Godot untuk memuntahkan peta ini lebih mahal daripada menyalin 40 angka sekali.

---

## A — APA YANG ADA SEKARANG

Cermin, bukan penilaian. Semua angka dari `Ashbrook64.gd`.

| zona | apa & kenapa di sini |
|---|---|
| **BALAI** (960,464) | Fasad terbesar repo (inn 160×224) menghadap alun-alun dari utara. **Satu-satunya bangunan yang benar-benar mematuhi "rumah di sisi utara ruang publik".** Gelap: nol jendela didaftarkan. |
| **MERRIT** (464,752) | Rumah singgah + lentera abadi. Di ujung **barat** jalan dagang, 496 px dari alun-alun. Jangkar cerita berdiri di luar C1, dan lenteranya memerintah dari pinggir. |
| **GUDANG** (704,400) | Gudang gandum — spec menaruhnya di C3, ia berdiri di jari-jari 314 px = masih C2. |
| **OTHA** (1216,480) | Toko tutup, papan bekas cat 128 px di selatannya. Jari-jari 336 px = C2, **benar menurut spec**. |
| **Lyra** (640,992) | Satu-satunya rumah C2 yang terbaca dihuni. Setapaknya bersiku — satu-satunya jalan di peta yang menghindar alih-alih menembus. |
| **4 rumah tanpa nama** | (1408,800) · (1120,1152) · (736,1184) · (1376,1056). Semua gelap, semua berpintu selatan, **tak satu pun menghadap jalan atau ruang publik** — pintunya membuka ke rumput. |
| **Jalan dagang** | Satu pita batu 96 px **selebar peta**, x=0→1920, lurus tanpa putus, menembus tepi di kedua sisi. Jalan yang tak berpangkal dan tak berujung. |
| **Alun-alun** | Cobble 544×352 + cakram pelataran. Air mancur **kering**. Zona warga latar (r=96, n=4) dipusatkan 128 px di bawahnya — empat orang berdiri menutupi pusat desa. |
| **7 denah C3** | Tersebar keliling (U, TL, T, B, BL, 2× S). Ukuran beragam, bentuk persegi — tapi **tak satu pun berdiri di garis jalan**, jadi terbaca "batu di rumput", bukan "jalan yang mati". |
| **Ladang** (900,995) | 320×160 di jari-jari ~300 px — nyaris menempel inti, di tanah paling berharga. Spec meminta ladang di **tepi** dekat rumah. |
| **PEMAKAMAN** (624,1216) | 460×190, ~78 nisan, pagar selatan bolong. **Berhasil**: ia punya TEPI, dan tepinya yang membuatnya terbaca. Sudut timur-laut kosong menunggu Sora (#013). |
| **Treeline selatan** | Empat lapis + tabrakan penuh selebar peta. **Berhasil.** Timur & barat tak punya padanan — di sana peta berhenti pada kehitaman. |
| **Gerbang selatan** | Dua pilar di y=1312. Jalan menuju gerbang sengaja berhenti 160 px sebelum bukaan — tapi ia **juga tak tersambung ke alun-alun**: ada jurang rumput di antara ujung jalan dan tepi selatan alun-alun. |

### Yang paling terbaca dari bentuk kotaknya

Sekali digambar sebagai kotak, tiga hal muncul yang tak terlihat di tangkapan layar:

1. **Bangunan ditabur, bukan dijajarkan.** Sembilan fasad, sembilan panah pintu, dan
   panah-panah itu menunjuk ke sembilan arah yang tak berhubungan. Hanya BALAI yang
   pintunya menghadap sesuatu.
2. **Satu-satunya jalan sungguhan membelah peta jadi dua.** Pita 96 px selebar 1920 px
   itu memotong utara dari selatan, dan tak ada yang menyeberanginya kecuali empat taji
   pendek.
3. **Reruntuhan mengelilingi, tapi tak menyusun.** Tujuh persegi merah membentuk cincin
   yang rapi di peta — dan justru keteraturan itu yang membuat mereka terbaca sebagai
   dekorasi tersebar, bukan sebagai sisa kota.

---

## B — USUL DARI SPEC

Tiap penempatan menjawab satu prinsip spec. Urutan pengerjaannya = urutan gambarnya:
**jalan dulu.**

| zona | apa & kenapa di sini |
|---|---|
| **Tulang punggung U-S** | Gerbang → alun-alun → balai, lurus di x=960. Gerbang dan balai **saling memandang lewat air mancur**: langkah pertama pemain sudah memperlihatkan ketimpangan #206. Berhenti 78 px sebelum pilar, aturan yang sama dengan `.gd` sekarang. |
| **Jalan dagang MEMUDAR** | Tak lagi menembus tepi. Menyempit tiga kali lalu berhenti. Jalan yang **masih ada** membuktikan dulu ada tujuan, dan tujuan itulah yang hilang; jalan yang dihapus bersih tak membuktikan apa-apa. |
| **Alun-alun bundar** r=210 | Lingkaran punya pusat; persegi cuma punya luas. Sisi selatan sengaja **tak dibangun** supaya ruang ini punya MULUT yang menghadap gerbang. |
| **BALAI · MERRIT · HALLORAN** | Bertiga di sisi **utara** alun-alun. Karena tiap fasad berpintu selatan, ini otomatis membuat ketiganya menghadap ke dalam — **nol aset baru, cuma koordinat**. Lentera Merrit pindah dari pinggir ke pusat. |
| **C2 — 8 rumah, 2 menyala** | Semua di sisi **utara** jalan atau lorong, jadi pintunya membuka ke jalan. Dua lorong selatan (y=1004) diadakan justru supaya empat rumah bawah punya sesuatu untuk dihadapi; keduanya menyentuh tulang punggung, jadi terbentuk perempatan alih-alih pulau. |
| **OTHA** di C2 timur | Sesuai spec: pertanyaan pertama lahir di C2. Papan bekas cat terlihat dari jalan dagang tanpa pemain perlu menyimpang. |
| **C3 — fondasi BERBARIS** | Dua baris fondasi **mengapit jalan yang sudah mati**, barat-laut dan timur-laut. Fondasi sejajar mengabarkan ada JALAN di antaranya, dan mata melanjutkan jalan itu sendiri. Puing tersebar tak pernah bisa. |
| **GUDANG GANDUM ke C3** | Digeser keluar ke jari-jari ~450 px. Ia **satu-satunya bangunan yang masih berdiri** di antara fondasi — dan itulah yang membuat fondasi di sekitarnya terbaca sebagai rumah, bukan batu. |
| **Ladang ke TEPI** | Dua petak, keduanya menempel rumah C2. Barat masih berbentuk; timur sudah kalah rumput. **Dua tahap penyerahan yang sama, dalam satu bingkai.** |
| **PEMAKAMAN** | Koordinat tak disentuh. Ia sudah berhasil. Sudut timur-laut tetap kosong menunggu Sora. |
| **Treeline T & B (USUL)** | Pita 88 px di timur, barat, utara. Tanpa ini peta berhenti pada kehitaman, dan kekosongan tanpa tepi terbaca "belum dibangun", bukan "ditinggalkan". |
| **Gradien warga** | C1 = 13 · C2 = 6 · C3 = 1 · C4 = 0. Kecil dengan sengaja: empat puluh jiwa. **Nol warga berdiri di atas air mancur.** |
| **Air mancur MENGALIR** | Rekomendasi D1 spec diambil di draft ini. Mengalir untuk tak seorang pun lebih menyayat daripada kering; kering cuma berkata "mati". ⚠ Ongkosnya animasi air — kalau Direktur mau murah, kering tetap sah dan sisa tata letaknya tak berubah. |

### Yang B ubah, diringkas jadi enam gerakan

1. Jalan digambar **dulu**; semua bangunan menempel padanya.
2. Tiga bangunan bernama naik ke **sisi utara alun-alun** — pintunya jadi benar tanpa aset baru.
3. Jalan dagang **berhenti sebelum tepi** alih-alih menembusnya.
4. Reruntuhan **berbaris mengapit jalan mati** alih-alih tersebar melingkar.
5. Ladang & gudang **keluar** dari inti; kepadatan menipis ke tepi.
6. Tepi timur, barat, utara **dibingkai** treeline.

---

## B′ — TATA LETAK FINAL (keputusan Direktur: B menang + 7 koreksi)

> **B rapi; B′ hidup.** Bedanya bisa diukur, bukan soal rasa: tata letak simetris
> sempurna mengabarkan **satu tangan membangunnya sekaligus**. Ashbrook harus
> mengabarkan kebalikannya — tumbuh bertahun-tahun, lalu menyusut bertahun-tahun.
> Karena itu tiap ketaksempurnaan di B′ **dirancang, bukan diacak**: acak murni
> terbaca sebagai derau; ketaksempurnaan **berarah** terbaca sebagai waktu.

Seluruh simpangan lahir dari **RNG berbiji tetap `20260721`**. Jalankan ulang skripnya,
hasilnya sama persis — kalau tidak, "koreksi Direktur" mustahil dirujuk dua sesi
berturut-turut.

| # | koreksi | bagaimana dijalankan | kenapa begitu |
|---|---|---|---|
| **1** | pecah simetri | Sumbu tegak digeser **60 px ke barat** (x=966 → 906) **dan dibengkokkan** (920 → 906 → 902). Jalan dagang bengkok, lebarnya tak rata: 45 px di tengah, 9 px di ujung timur. Dua pilar gerbang pun **tak sejajar** (selisih 10 px). | Salib sempurna adalah tanda tangan satu perencana. Ashbrook tak pernah punya perencana — cuma kebiasaan yang mengeras jadi jalan. |
| **2** | alun-alun dimakan | Tepi tak beraturan (52 simpul, derau **dihaluskan** rata-rata tiga tetangga). **Barat-daya AUS**, **timur-laut dirambati rumput**. | Gerigi terbaca "rusak"; lengkung yang meleset terbaca "aus". Barat-daya = sisi yang dilewati tiap orang dari gerbang; timur-laut = sisi terjauh dari gerbang. **Dua sisi, dua sebab, satu arah waktu.** |
| **3** | bernama tak sebaris | BALAI maju (kaki y=478, massa 232 px — tertinggi) · HALLORAN mundur 26 px · MERRIT mundur 38 px dan **paling pendek** (184 px). | Barisan rata mengabarkan "dibangun sekaligus". Tiga garis berbeda mengabarkan tiga dasawarsa berbeda. |
| **4** | distrik bekas | **10 fondasi rapat** di barat-laut + **lorong sempit yang masih terbaca** di antaranya + **3 penyintas yang meluruh** ke luar. GUDANG GANDUM berdiri di tepinya. | Yang membuat mata membaca "distrik" bukan jumlah puingnya melainkan **JALAN di antaranya**. Batas yang tajam terbaca sebagai dinding — karena itu tepinya meluruh, tak berhenti. |
| **5** | air mancur | **MENGALIR** (D1 diputus), `WaterFountain.png`. Digeser **38 px barat, 22 px utara** dari pusat matematis alun-alun (pusat itu tetap ditandai di peta sebagai pembanding). | Tempat tua tumbuh **di sekitar** sesuatu, tak pernah dipusatkan padanya. Air mancurnya lebih tua daripada pelatarannya — dan pelataran itulah yang mengalah. |
| **6** | gradien di ruang | Jarak antar rumah C2 **melebar** ke tepi: 148 → 172 → 194 px, **selisihnya sendiri membesar**. 12 rumah, 2 menyala. | Kepadatan yang menipis lewat **jarak** terbaca sebagai kota yang meluruh. Yang menipis lewat jumlah lampu saja terbaca sebagai kota utuh yang kebetulan gelap. Koreksi paling tak terlihat, paling banyak membayar. |
| **7** | dua jangkar mata | **Puncak BALAI** menonjol di atas garis atap, terlihat dari gerbang 1.100 px jauhnya. Garis pandangnya lewat **tepat di sisi timur air mancur**. Jangkar kedua: **pohon tunggal** di tepi **barat** pemakaman. | Satu jangkar cuma memberi arah; dua memberi **lebar**. Mata menemukan pusat desa dalam perjalanan ke jangkarnya, bukan karena diarahkan ke sana. |

### Koreksi 4 adalah yang paling kuat, dan alasannya bukan visual

Konsentrasi reruntuhan di barat-laut berkata: **inti yang SEKARANG bukan inti yang DULU.**
Kota tak menyusut ke tengah — ia menyusut **menjauh dari tempat ia lahir**. Sebaran merata
tak pernah bisa mengabarkan itu; ia cuma bisa berkata "beberapa rumah roboh".

### Yang tak disentuh, sesuai perintah

Pemakaman (624,1216) · treeline selatan · empat wisp. **Yang bekerja tak dibongkar untuk
dirapikan.** Pohon jangkar sengaja ditaruh di tepi **barat** pemakaman, bukan timur: tepi
timur ditembus sumbu jalan, dan pohon di atas jalan bukan jangkar melainkan penghalang.

### Dua catatan jujur soal B′

**B′ tak bergantung pada Sonetto.** Tiap rumah di peta ini berpintu **selatan** dan tetap
menghadap jalan. Kalau uji gaya Sonetto (CC-BY-SA 4.0, byte-terbukti — `TELUSUR_LISENSI.md`)
gagal, B′ tetap berdiri utuh; fasad multi-arah cuma akan memperbaiki **sudut rumah**, bukan
menyelamatkan tata letaknya.

**B′ belum diuji kaki.** Kotak di blockout tak tahu apa-apa soal `_solid()`. Tiga tempat
wajib dilewati kaki sungguhan sebelum dipercaya: **perempatan lorong–sumbu**, **mulut
selatan alun-alun**, dan **celah antara distrik bekas dan gudang**.

---

## ⚠ YANG BELUM DIJAWAB — dan tak boleh disamarkan

**Fasad multi-arah belum ada di repo.** Sonetto (`tileset_town_multi_v002.png`,
CC-BY-SA 4.0, byte-terbukti — `TELUSUR_LISENSI.md`) sudah **legal**, tapi belum diuji
gaya berdampingan dengan fasad LPC sekarang. Sampai itu diputuskan, tiap rumah di B
**terpaksa** berpintu selatan. Tata letak B dirancang supaya batasan itu tak terasa
sebagai batasan — tapi ia tetap batasan, bukan pilihan.

**Treeline sisi tegak butuh kerja baru.** Resep sekarang (`_pemakaman_dan_kabut()`)
menggambar pita **mendatar** `Rect2(0, y, w, h)`. Sisi timur/barat butuh susunan tegak
plus uji mata — memutar aset 90° akan memutar arah cahayanya juga.

**B belum diuji tabrakan.** Kotak di blockout tak tahu apa-apa soal `_solid()`. Perempatan
lorong-tulang punggung dan mulut selatan alun-alun harus dilewati kaki sungguhan sebelum
dipercaya.

---

## Langkah termurah kalau B (atau coretan di atasnya) disetujui

Urut dari yang paling banyak membayar per baris kode:

| # | gerakan | ongkos |
|---|---|---|
| 1 | Geser zona warga alun-alun keluar dari air mancur | 1 baris (`_folk_berjadwal`) |
| 2 | Sambungkan jalan gerbang ke tepi selatan alun-alun | 1 `_setapak()` |
| 3 | Ladang ke tepi barat | 1 koordinat |
| 4 | Tiga bangunan bernama ke sisi utara alun-alun | 3 koordinat + cek `_solid` |
| 5 | Jalan dagang berhenti sebelum tepi | ganti 1 `_tile` jadi 3-4 `_setapak` menyempit |
| 6 | Fondasi C3 dibariskan mengapit jalan mati | tulis ulang daftar `denah` |
| 7 | Treeline timur & barat | aset + resep baru — **paling mahal, kerjakan terakhir** |

Nomor 1–3 bisa dikerjakan dalam satu sesi dan sudah memperbaiki tiga cacat 🔴/🟡 di
`POTRET_ASHBROOK.md` tanpa menyentuh satu aset pun.

**Tambahan sesudah B′ menang**, disisipkan menurut ongkosnya:

| # | gerakan B′ | ongkos |
|---|---|---|
| 1b | Air mancur ganti `WaterFountain.png` + geser 38 px | 1 baris + 1 aset (lisensi ⚠ belum ditelusuri) |
| 4b | Sumbu digeser & dibengkokkan; jalan dagang berlebar tak rata | tulis ulang `_ground()` — `_setapak()` sekarang cuma bisa lurus & bersumbu; butuh varian **poligon** |
| 6b | Distrik bekas barat-laut menggantikan 7 denah tersebar | tulis ulang daftar `denah` + 3 lorong pudar |
| 7b | Puncak balai (jangkar mata) | 1 sprite + z tetap (**jangan** y-sort — ia harus menembus garis atap) |
| 8b | Tepi alun-alun tak rata + bercak aus/rumput | butuh generator ubin baru (#240), **paling mahal setelah treeline** |

⚠ **Yang paling mudah diremehkan: 4b.** `_setapak()` menggambar `Rect2` bersumbu, jadi ia
**mustahil** menghasilkan jalan bengkok berlebar tak rata. Koreksi 1 bukan pemindahan
koordinat — ia menuntut alat gambar jalan yang baru. Rencanakan sebagai kerja tersendiri,
bukan sebagai penyesuaian angka.
