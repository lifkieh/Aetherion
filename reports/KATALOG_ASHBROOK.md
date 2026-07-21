# KATALOG ASHBROOK — seluruh gameplay, mekanik, pemicu, event, dan cerita

**Dibuat:** 2026-07-22 · **Sifat:** katalog rujukan, baca-saja. **NOL perubahan `game/`.**
**Cakupan:** semua yang ADA di Ashbrook64 — yang sudah hidup maupun yang tertulis tapi belum.
Status tiap butir ditandai: **● HIDUP** (pemain bisa menyentuhnya) · **◐ SETENGAH** ·
**○ BELUM** (ada di data/dokumen, belum tersambung).

**Peta:** 60 × 44 petak = 1920 × 1408 px · pusat alun-alun (960, 704) · pemain lahir di
gerbang selatan (960, 1194) · seluruh peta terjangkau berjalan (terbukti banjir BFS: 100%).

---

# 1 · KERANGKA — apa itu Ashbrook

**Kanon #206: desa-bekas-kota.** Dulu ~1.500 jiwa, kini ~40. Jalur dagang Valenford
bergeser. Semua yang terlalu besar di peta ini adalah **sisa ukuran lama**, bukan
kesalahan skala.

**Prinsip pendiri:** *"Ashbrook tidak boleh terasa BESAR. Ia harus terasa PERNAH besar."*

**Struktur 4 cincin** — makin jauh dari alun-alun = makin mundur ke masa 1.500 jiwa:

| cincin | isi | kepadatan hidup |
|---|---|---|
| **C1 inti** | alun-alun, air mancur, balai, Merrit, Halloran | 13 warga · 100% |
| **C2 tepi huni** | rumah gelap, toko Otha tutup, rumah Lyra | 6 warga · 25% |
| **C3 bekas** | distrik reruntuhan barat-laut, gudang gandum, jembatan | 1 warga · 10% |
| **C4 tepi hantu** | pemakaman, treeline, wisp | 0 warga |

**Tesis geografis:** berjalan dari pusat ke tepi = berjalan mundur dari SEKARANG ke DULU.
Peta itu sendiri adalah Chronicle — inti masih ditulis, tepi sudah tercoret.

---

# 2 · MEKANIK

## 2.1 Gerak & kendali — ● HIDUP

| aksi | tombol | catatan |
|---|---|---|
| Jalan | WASD | tabrakan nyata; kaki bangunan padat 40 px |
| Dodge | Space | |
| Interaksi | **E** | radius 44 px; prioritas: gather → interactable |
| Tas | I | |
| Peta dunia | M | terbuka, **semua tujuan terkunci** |
| Menu / Kitab | Esc | |
| Skill 1–5 | 1–5 | prime lalu tahan klik-kiri; dua prime = **FUSION** |
| Serang | tahan klik-kiri | |
| Tame | T | |
| Tanam | G | ◐ diblokir SafeZone + tak punya bibit pohon |

## 2.2 Chronicle — ● HIDUP, lingkaran tertutup

Inti permainan. Terverifikasi tertutup di **ketiga jalur**.

```
tiba di Ashbrook
   └─ halaman `place_ashbrook_besar` LAHIR lalu langsung DICORET — tanpa suara
pungut bukti dengan E   (6 titik)
buka Kitab (Esc → tab Kitab)
   └─ kartu halaman tercoret → tombol "tulis ulang"
pilih juru tulis
   ├─ SELF  — butuh 3 jenis bukti · loss terbesar · selalu tersedia   ● HIDUP
   ├─ ELYN  — butuh 2 jenis · loss terkecil · harga: Elyn melupakan miliknya  ● HIDUP
   └─ SORA  — butuh 2 jenis · loss sedang · harga: Sora menanggungnya   ○ BELUM
halaman PULIH — selalu dengan `loss`
```

**Empat jenis bukti (#226 Hukum Bukti):** `benda` · `kebiasaan` · `akibat` · `orang`.
*"Ingatan tidak bisa dipulihkan dari ingatan. Hanya dari BEKAS."*

**Aturan keras:** halaman pulih **tidak pernah identik**. Yang hilang ditentukan oleh jenis
yang **tidak** dibawa.

⚠ **Di Ashbrook, jenis `orang` mustahil dipungut** (lihat §7.1) — jadi loss-nya selalu:
> *"Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus orang."*

## 2.3 Sistem lain

| sistem | status | catatan |
|---|---|---|
| Tas / item / pakai-lengkapi | ● | awal: 3 ramuan · 2 orb · tunik · 3 bibit mintleaf + senjata class |
| Craft | ● | jalan dari menu, tanpa workbench |
| Combat | ● | **1 musuh** di seluruh peta |
| Taming | ● | sasaran: 1 ekor serigala yang sama |
| Toko | ◐ | tab bisa dibuka, **nol pedagang di dunia** |
| Peta dunia | ◐ | UI terbuka, semua region `🔒 ? ? ?` |
| Pindah region | ○ | gerbang selatan → **kembali ke Main Menu** (diakui SEMENTARA) |
| Homestead / tanam-panen | ○ | kode lengkap, portal hanya ada di Greenvale |
| Companion / party manusia | ○ | party **pet** ada (butuh taming) |
| Pembusukan bukti (R3) | ○ | `is_decayed()` dibaca, **jam pembusukan tak pernah dimulai** |

---

# 3 · PEMICU (TRIGGER)

## 3.1 Waktu — jam WIB nyata

| pemicu | akibat | status |
|---|---|---|
| **Jam berganti** | `CanvasModulate` langit berubah — siang → senja → malam | ● |
| **17:00** | jendela mulai menyala | ● |
| **19 · 20 · 21** | jendela **padam satu per satu** menurut `off_hour` masing-masing | ● |
| Kapan pun | **lentera Merrit tak pernah padam** — siang maupun malam | ● |
| Kapan pun | **jendela toko Otha tak pernah menyala** — kosong, bukan jam | ● |
| Pagi | jadwal warga berjadwal berganti (#97) | ● |
| `kamis_sore` | Nyai berjalan ke depan toko Otha, berdiri, pulang | ○ |

> **Beacon lintas-jarak (#218):** lentera Merrit punya titik cahaya ber-z 4000 supaya tetap
> terlihat dari seberang peta pada malam hari.

## 3.2 Jarak & zona

| pemicu | jarak | akibat | status |
|---|---|---|---|
| Dekati **titik-periksa** | 44 px | label `[E]` muncul | ● |
| Dekati **prop bercerita** | 72 px | label muncul | ● |
| Masuk **titik pandang #218** | 130 px | kamera **mundur ke zoom 0,55** | ● |
| Keluar titik pandang | 240 px | kamera kembali 1,00 (**pita mati 110 px** anti-yo-yo) | ● |
| Dekati **ternak** | 84 px | kabur | ● |
| Dekati **hewan liar** | 116 px | kabur lebih cepat (×3,2) | ● |
| Dekati **burung** | 116 px | **TERBANG** — lembar sprite ditukar, mendarat di tempat baru | ● |
| Dekati **anjing pengikut** | 168 px | **mendekat**, berhenti pada 52 px, ikut 5 detik, lalu **diam 4 detik** | ● |

## 3.3 Sekali-jalan (saat tiba)

| pemicu | akibat |
|---|---|
| Scene dimuat | `WorldState.mark_visited("ashbrook")` · SafeZone aktif |
| Scene dimuat | halaman `place_ashbrook_besar` **lahir lalu dicoret**, senyap |
| Scene dimuat | rantai tutorial 6 langkah muncul di HUD ⚠ (§7.3) |

## 3.4 Acak

| pemicu | peluang | akibat |
|---|---|---|
| **Rusa putih (#D-ASH-4)** | 0,5% per frame, **hanya bila pemain di paruh selatan** | melintas 11 detik di pita rumput depan hutan, memudar masuk & keluar, lalu hilang |
| Kelahiran anak | saat muat | 3 anak lahir di cincin acak sekeliling alun-alun (diuji tak jatuh di benda padat) |

## 3.5 Kail harness (bukan untuk pemain)

`AETHER_PIN_DAY=1` patok siang · `AETHER_RUSA=1` paksa rusa muncul ·
`AETHER_SHOT_*` tangkap-layar · `AETHER_PLAY_PATH=self|elyn|penuh` jalur Chronicle.

---

# 4 · EVENT & ADEGAN

| adegan | rencana | status |
|---|---|---|
| **Tiba di Ashbrook** | halaman dicoret tanpa pengumuman; pemain harus menyadari sendiri | ● **HIDUP** |
| **A1 — Penghapusan Pertama** (Otha) | dirancang **untuk dilewatkan**: toko yang tadinya buka jadi tutup, papan jadi kosong, Halloran berhenti menyapa, pintu **tak merespons sama sekali** | ◐ **hanya SESUDAHNYA** — papan bekas cat & pintu tertutup ada; keadaan **sebelum** tak pernah ada, jadi tak ada yang berubah di depan mata. Dan pintunya **menjawab** dengan teks, padahal rencananya diam total |
| **A2 — Seseorang Melupakanmu** (Merrit menyapa pemain seperti orang asing) | *"tidak bisa dilewatkan"* | ○ **BELUM** — Merrit tak punya dialog, jadi ia tak bisa lupa |
| **A3 — PILIH** (satu dari dua halaman tercoret) | bukti cuma cukup untuk satu; bekas Otha membusuk, bekas Merrit tidak | ○ **BELUM** — butuh dua halaman yang bisa dipulihkan; Merrit 0/4, Otha 1/4 |
| **Anak serigala terluka (#118)** | boleh **dibantu · diabaikan · dibunuh**; dunia tak menghakimi | ◐ ada & bisa dilawan/di-tame; **jalur "dibantu" belum ada** |
| **Kabut datang lagi** | penutup loop | ○ **BELUM** — loop berputar satu kali lalu berhenti |

---

# 5 · CERITA — seluruh teks yang bisa dibaca pemain

## 5.1 Enam bukti (E → tercatat di Chronicle)

**1 · Papan Otha** — `akibat` → halaman Otha
> *Kayunya pudar oleh tiga puluh empat musim panas — kecuali satu persegi panjang di tengah.*

**2 · Jembatan terlalu lebar** — `akibat`
> *Jembatan ini muat enam gerobak berdampingan. Ashbrook punya dua gerobak.*

**3 · Gudang gandum** — `akibat`
> *Gudang gandum sebesar ini menyimpan panen untuk seribu orang. Di dalamnya ada empat ayam.*

**4 · 200 roti Halloran** — `kebiasaan`
> *Dua ratus roti. Tiap pagi. Untuk empat puluh orang. Ia membuang yang sisa, dan besok memanggang dua ratus lagi.*

**5 · Fondasi di rumput** — `akibat`
> *Rumputnya tumbuh dalam garis-garis lurus. Persegi. Berpetak. Ada rumah-rumah di sini, dan tanahnya belum lupa.*

**6 · Batu fondasi berpahat** — `benda`
> *Ada pahatan di batu itu, hampir habis dimakan lumut: DARI SERIBU LIMA RATUS TANGAN. Hurufnya sudah bukan huruf yang dipakai sekarang. Tak ada yang bisa membacanya lagi.*

## 5.2 Sepuluh pintu & benda bercerita (E → teks, tidak mencatat bukti)

**Pintu toko Otha**
> *Terkunci. Debu di ambangnya rata — tak ada yang membukanya sejak dua musim.*
> *Tak ada papan nama. Cuma persegi yang catnya lebih gelap, tempat sesuatu dulu tergantung.*

**Rumah kosong**
> *Pintunya tak terkunci. Engselnya masih diminyaki — seseorang merawatnya sampai hari terakhir.*
> *Di dalam gelap. Perabotnya masih ada, tertata, menunggu orang yang tak pulang.*

**Pintu gudang**
> *Palang pintunya dilepas sejak lama. Di dalam, empat ekor ayam dan ruang untuk empat ratus karung.*

**Rumah Lyra** — satu-satunya yang dihuni
> *Ada suara di dalam. Seseorang sedang memasak, dan tak menyadari kau berdiri di sini.*

**Balai desa**
> *Pintunya terbuka. Tak pernah dikunci — tak ada lagi yang perlu dikunci dari siapa.*
> *Empat puluh kursi dirapatkan ke satu sudut, menghadap mimbar. Sisa lantainya kosong,*
> *dan langkahmu kembali kepadamu sebelum kau sempat berhenti berjalan.*

**Tiga rumah gelap — tiga sebab berbeda, dan itu disengaja:**
- **Rumah terkunci:** *Terkunci dari LUAR. Siapa pun yang terakhir keluar berniat kembali.*
- **Rumah terbuka:** *Pintunya menganga. Daun jatuh masuk sampai ke tengah ruangan, bertahun-tahun tebalnya.* / *Tak ada yang dibawa pergi, dan tak ada pula yang diambil orang. Bahkan pencuri berhenti datang.*
- **Rumah berpapan:** *Jendelanya dipaku papan dari DALAM. Palunya masih tergeletak di ambang.*

**Di dalam kamar Merrit** (masuk lewat pintu rumah singgah):

**Surat di meja**
> *Sepucuk surat, dibuka dan dilipat kembali sampai lipatannya menipis.*
> *Tanggalnya empat puluh tahun lalu. Isinya cuma satu kalimat: **"Tunggu aku, jangan pindah."***
> *Tak ada nama pengirim. Merrit tak pernah menyebutkannya kepada siapa pun.*

**Botol berjajar**
> *Botol minyak lampu, kosong semua, berjajar rapi menurut tahun.*
> *Kau berhenti menghitung di baris ketiga. Ada lebih banyak botol di sini daripada orang di Ashbrook.*

## 5.3 Warga yang bisa diajak bicara — 5 persona × 4 baris

**Merrit Fane** *(tragis)* ⚠ dipasang pada warga berwajah **generik**, bukan potret aslinya
> *Kamar-kamar itu masih kusapu. Bukan karena ada yang datang. Karena kalau berdebu, aku akan terbiasa.*
> *Tulisan tanganmu jelek. Bagus. Yang jelek biasanya jujur.*
> *Dulu aku hafal tulisan tangan setiap keluarga di sini. Sekarang aku hafal semuanya karena tinggal sedikit.*
> *Kalau kau pergi ke Greenvale, jangan menoleh. Atau menolehlah. Terserah. Lampunya tetap menyala.*

**Old Bram** *(lucu)*
> *Dulu di bangku itu, tukang roti Halloran duduk tiap sore. Ia bilang rotinya lebih enak kalau didinginkan angin sungai. Bohong. Tapi anginnya memang enak.*
> *Kau tahu kenapa alun-alun ini kebesaran? Karena dulu penuh. Itu saja. Bukan misteri.*
> *Anak-anak itu berisik sekali. Bagus. Kalau sepi, aku yang harus berisik sendiri.*
> *Jangan dengarkan aku terlalu serius. Aku ini cuma orang tua yang punya kursi favorit.*

Ditambah **Lyra** *(misterius)*, **Spoon Man** *(aneh)*, **Halloran Muda** *(tak masuk akal)*
— Hukum NPC Aneh terpenuhi. Dialog berganti menurut jam WIB.

## 5.4 Loss — akhir yang tertulis untuk tiap jenis yang hilang

| kurang | kalimatnya |
|---|---|
| `benda` | *Tercatat bahwa ia pernah besar. Tak ada satu pun benda yang membuktikannya, dan dua generasi lagi orang akan menyebutnya lebih-lebihan.* |
| `kebiasaan` | *Kotanya tercatat. Kenapa Halloran memanggang dua ratus roti tiap pagi untuk empat puluh orang — tidak. Ia pun tak akan pernah tahu.* |
| `akibat` | *Angkanya tercatat: seribu lima ratus. Jembatan itu tetap terlalu lebar, dan sekarang tak seorang pun bertanya kenapa.* |
| **`orang`** | ***Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus orang.*** ← **satu-satunya yang bisa terjadi sekarang** |

---

# 6 · EKOLOGI & ATMOSFER — 27 makhluk, nol interaksi

Semuanya **latar murni**: mengubah bacaan tempat, bukan aksi pemain.

| lapis | isi | aturan yang membuatnya bercerita |
|---|---|---|
| **Ternak** | 2 domba + 3 ayam di kandang samping rumah Lyra · 2 ayam lepas di rumah C2 yang menyala · 4 ayam di gudang gandum | **kepemilikan, bukan zona** — ternak hanya di sebelah rumah berpenghuni. Ketiadaannya di tepi = tak ada lagi yang memelihara |
| **Liar** | 6 kucing (3 distrik bekas · 2 tepi timur · **1 di inti**) · 2 anjing · 1 domba tersesat di jembatan | gradien **berlawanan arah** dengan ternak. Yang satu di inti disengaja: batas yang sudah kabur |
| **Anjing pengikut** | 1 | satu-satunya makhluk yang **mendekat**. Ikut 5 detik, lalu **berdiri diam 4 detik** — kau bukan orang yang ditunggunya |
| **Penunggu** | 2 kucing duduk di ambang rumah gelap · 1 kucing meringkuk tidur di antara fondasi | nol teks. Yang memperhatikan mengerti sendiri |
| **Burung** | 3 merpati di alun-alun · 3 gagak di distrik bekas · 2 melintas langit | merpati dekat manusia (remah), gagak di tempat yang manusianya pergi |
| **Rusa putih** | 1, acak & langka | legenda; tak wajib ditemukan |
| **Wisp** | 4 — 3 di pemakaman, 1 di C3, **0 di inti** | di tepi yang hidup cuma cahaya yang tak bisa diraih |

**Atmosfer lain:** hutan menutup dari **barat · utara · timur · selatan**, terbuka hanya di
gerbang → *alam merebut kota yang menyusut* · air mancur **kering**, off-center 38 px ·
alun-alun yang tepinya aus di barat-daya (sisi yang dilewati tiap orang dari gerbang) dan
dirambati rumput di timur-laut (sisi terjauh) · distrik reruntuhan barat-laut: **inti yang
SEKARANG bukan inti yang DULU** · pemakaman untuk 1.500 di desa 40 jiwa, pagar selatan
bolong · gerbang megah **tak berpenjaga**, jalannya berhenti 78 px sebelum bukaan.

---

# 7 · YANG TERTULIS TAPI BELUM HIDUP

## 7.1 Delapan bukti tak terpasang — dan `orang` seluruhnya hilang

| halaman | ada di data | terpasang | bisa dipulihkan? |
|---|---|---|---|
| `place_ashbrook_besar` | 6 | **5** | ✅ ya, **selalu cacat** |
| `person_otha_renn` (d3) | 4 | **1** | ❌ |
| `person_merrit_fane` (d2) | 4 | **0** | ❌ |

**Tiga bukti `orang` dan saksinya:**
- `ev_ashbrook_bram_ingat_ayahnya` → **Old Bram**, `dialog_bram`
  > *"Ayahku dulu ngeluh soal antrean di penggilingan. Antrean! Di sini! Orang tua memang suka melebih-lebihkan."*
  > ⚠ *Bram TIDAK sedang membantu pemain. Ia sedang bergosip.*
- `ev_otha_nyai_tuminah_kamis` → **Nyai**, `observe` tiap `kamis_sore` (bukan dialog)
  > *Ia berhenti di depan pintu yang tertutup itu. Berdiri. Lalu pulang. Ia melakukannya tiap Kamis, dan ia tidak tahu kenapa.*
- `ev_merrit_arlen_ingat` → **Arlen**, `dialog_arlen` — **Arlen tak ada di game sama sekali**

**Empat bukti Merrit lain** (semua di rumah singgahnya, teks sudah ditulis): kartu pos
kosong bertanggal hari pertama pemain tiba · cangkir kedua yang dituang tiap pagi untuk
yang tak datang · rute pos dengan satu perhentian tanpa rumah, ditambahkan berbulan lalu
dengan tulisan tangannya sendiri. **Tubuh ingat setelah kepala lupa.**

## 7.2 Enam NPC bernama bisu

Merrit · Halloran · Old Bram · Nyai · Otha Renn · Sora dibangun sebagai **`Sprite2D`
polos** — nol skrip, nol grup, nol dialog. **Pintunya bicara; orangnya tidak.**

## 7.3 Tutorial yang mustahil di sini

Rantai 6 langkah Greenvale tampil di HUD Ashbrook. **Nol yang bisa diselesaikan:**
kalahkan **2** monster (peta ini punya 1) · tebang 3 pinus (nol `GatherNode`) · ramu di
**bengkel** (tak ada) · kunjungi **papan quest** (tak ada).

## 7.4 Lain

Companion **0 dari 4** (Merrit sprite bisu · **Arlen tak ada** · Elyn cuma tombol + angka
`elyn_burden` · Sora sprite bisu) · Sora di pemakaman (#013) — sudut timur-laut sudah
dikosongkan untuk dia · jalur juru tulis Sora · pembusukan R3 · kabut kedua · "Yang
Terhapus" · wilayah memutih · 16 dari 17 `kind` Interactable tak dipakai, termasuk
`world_gate`.

---

# 8 · ANGKA

| | |
|---|---|
| Titik-periksa aktif | **6** dari 14 bukti di data |
| Prop bercerita | **10** |
| Pintu masuk/keluar + gerbang | **3** |
| Halaman Chronicle bisa dipulihkan | **1** dari 3 |
| Jalur juru tulis hidup | **2** dari 3 |
| NPC bisa diajak bicara | **5** (persona) · **0** dari 6 bernama |
| Warga di layar | 20 (5 berjadwal + 15 latar) + 6 potret bisu + 3 anak |
| Makhluk hidup | 27 |
| Musuh | **1** |
| Bangunan | 15 · 9 bentuk fasad · 2 bertingkat |
| Kotak padat | 49 |
| Keterjangkauan berjalan | **100%** (8276 / 8276 petak) |
| Gerbang uji | jalan-kaki 32/32 · rantai §0 utuh (3 jalur) · suite 1119/0 |
