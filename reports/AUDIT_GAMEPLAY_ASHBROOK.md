# AUDIT GAMEPLAY ASHBROOK — apa yang BENAR-BENAR bisa dilakukan pemain

**Dibuat:** 2026-07-22 · **Sifat:** audit baca-saja. **NOL perubahan `game/`.**
**Aturan §0 yang dipakai:** sesuatu dihitung "BISA" hanya kalau **ter-wire ke pemain** —
bisa disentuh dengan tombol saat bermain, mulai dari Main Baru. Ada di test, di dokumen,
atau di kode yang tak terjangkau = **BUKAN bisa**.

**Cara diverifikasi:** membaca scene & autoload di disk, lalu menjalankan tiga gerbang —
`PlayWalk64` (berjalan sungguhan dengan WASD), `PlayLoop64` (rantai Chronicle),
`CekJalur` (banjir BFS keterjangkauan). Bukan asumsi.

---

## RINGKAS SATU LAYAR

| | |
|---|---|
| Dunia yang bisa dicapai pemain baru | **1** — Ashbrook64. Sisanya terkunci |
| Titik-periksa aktif | **6** dari 14 bukti yang ada di data |
| Halaman Chronicle yang bisa dipulihkan | **1** dari 3 |
| Pemulihan terbaik yang mungkin | **selalu yang cacat** — lihat 🔴-1 |
| NPC bernama yang bisa diajak bicara | **0** dari 6 |
| Companion yang bisa direkrut | **0** dari 4 yang direncanakan |
| Musuh | **1** ekor |
| Langkah tutorial yang bisa diselesaikan di Ashbrook | **0** dari 6 |

---

# BAGIAN 1 — APA YANG BISA PEMAIN LAKUKAN

## 1.1 GERAK — **BISA**

| aksi | tombol | vonis | catatan |
|---|---|---|---|
| Jalan | WASD | **BISA** | `Player.gd` · tabrakan nyata |
| Dodge | Space | **BISA** | terdaftar di bilah bantuan |
| Buka tas | I | **BISA** | |
| Buka peta | M | **BISA** | isinya terkunci — §1.7 |
| Tanam bibit | G | **TAK ADA di sini** | butuh item `tree_sapling` (tak ada di inventaris awal) **dan** diblokir di dalam SafeZone; `Ashbrook64` menyetel dirinya SafeZone |
| Tame | T | **SETENGAH** | sistemnya ter-wire, sasarannya cuma satu ekor serigala |

**Keterjangkauan terbukti**: banjir BFS dari titik lahir menemukan **8276 petak bebas,
8276 terjangkau (100,0%)** — nol kantong terisolasi. Seluruh peta bisa dijalani.

## 1.2 INTERAKSI — titik-periksa: **6 aktif, semuanya BISA**

Tombol **E** dalam radius 44 px. Keenamnya dijalankan lewat harness dan **tercatat**:

| # | titik-periksa | posisi | halaman | jenis | teks yang muncul |
|---|---|---|---|---|---|
| 1 | **papan Otha** | (1252, 752) | `person_otha_renn` | akibat | teks periksa + bukti tercatat |
| 2 | **jembatan terlalu lebar** | (1856, 704) | `place_ashbrook_besar` | akibat | idem |
| 3 | **200 roti Halloran** | (1310, 500) | `place_ashbrook_besar` | kebiasaan | idem |
| 4 | **batu fondasi berpahat** | (800, 856) | `place_ashbrook_besar` | benda | idem |
| 5 | **gudang gandum** | (578, 490) | `place_ashbrook_besar` | akibat | idem |
| 6 | **fondasi rumput** | (322, 462) | `place_ashbrook_besar` | akibat | idem |

Semuanya memakai satu-satunya `kind` yang dipakai Ashbrook: `examine`.
`Interactable.gd` mendukung **17 kind** (workbench · shop · inn · board · astrologer ·
pond · dungeon · house_door · mirror · guide · trainer · enchanter · auctioneer ·
tree_keeper · **world_gate** …). **16 di antaranya tak dipakai sama sekali** di
satu-satunya peta yang dimainkan.

## 1.3 INTERAKSI — pintu & benda bercerita: **BISA (10 buah)**

Delapan pintu di luar + dua benda di kamar Merrit, semuanya `setup_bicara`
(teks muncul, **tidak** mencatat bukti):
toko Otha · rumah kosong · gudang gandum · rumah Lyra · balai desa · rumah terkunci ·
rumah terbuka · rumah berpapan · surat · botol.

Plus **1 pintu masuk** (kamar Merrit) + **1 pintu keluar** + **1 gerbang**.

> ⚠ **Pintu-pintunya bicara; orang-orangnya tidak.** Lihat §1.5.

## 1.4 CHRONICLE — **BISA, dan lingkarannya benar-benar tertutup**

Terverifikasi lewat `PlayLoop64` di **ketiga jalur** — hasil `rantai UTUH`:

1. Halaman `place_ashbrook_besar` **lahir lalu langsung dicoret** saat pemain tiba
   (`WorldState` → `Chronicle.record_person` → `Chronicle.strike`), **tanpa suara**.
2. Pemain memungut bukti dengan E.
3. Buka **Kitab** (tab di menu) → kartu halaman tercoret → tombol **"tulis ulang"**.
4. Pilih jalur juru tulis → halaman **pulih**, dengan `loss`.

**Tiga jalur juru tulis** (`Chronicle.gd:44-52`):

| jalur | butuh | ter-wire? |
|---|---|---|
| **SELF** — pemain sendiri | 3 jenis bukti | ✅ **BISA** — `restore_self` dipanggil dari Kitab |
| **ELYN** | 2 jenis | ✅ **BISA** — `restore_elyn` dipanggil dari Kitab |
| **SORA** | 2 jenis | ❌ **TAK BISA** — konstantanya disebut di UI, tapi tak ada pemanggilan `restore_sora` di scene mana pun |

### 🔴-1 — TEMUAN TERBESAR AUDIT INI

**Pemulihan yang sempurna MUSTAHIL. Selamanya.**

Hukum Bukti (#226) punya empat jenis: `benda` · `kebiasaan` · `akibat` · `orang`.
Halaman pulih **selalu kehilangan sesuatu**, dan yang hilang ditentukan oleh jenis yang
**tidak** dibawa. Yang bisa dipungut di Ashbrook:

```
benda      ✓ batu fondasi berpahat
kebiasaan  ✓ 200 roti Halloran
akibat     ✓ jembatan / gudang / fondasi rumput
orang      ✗ TIDAK ADA SATU PUN
```

Bukti jenis `orang` di data ada tiga — `ev_ashbrook_bram_ingat_ayahnya`,
`ev_otha_nyai_tuminah_kamis`, `ev_merrit_arlen_ingat` — dan **ketiganya menuntut
berbicara dengan orang.** Tak satu pun terpasang di dunia.

Akibatnya baris penutup permainan **sudah ditentukan sebelum pemain mulai**. Yang muncul
di harness, tiap kali, di ketiga jalur:

> *"Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus orang."*

Itu **persis** teks `loss_by_missing_kind.orang` di `chronicle_losses.json`. Pemain tak
pernah bisa mendapat yang lain, karena tak ada cara memungut jenis yang keempat.

### Peta bukti — 6 dari 14 terpasang

| halaman | kematian | bukti di data | terpasang | bisa dipulihkan? |
|---|---|---|---|---|
| `place_ashbrook_besar` | campuran | 6 | **5** | ✅ ya, **selalu cacat** (kurang `orang`) |
| `person_otha_renn` | **d3** | 4 | **1** | ❌ tidak — kurang 3 |
| `person_merrit_fane` | **d2** | 4 | **0** | ❌ tidak — **nol bukti terpasang** |

Delapan bukti yang tidak terpasang di mana pun:
`ev_otha_bangku_cekungan` · `ev_otha_jahitan_mantel_merrit` · `ev_otha_nyai_tuminah_kamis` ·
`ev_merrit_kartu_pos_kosong` · `ev_merrit_cangkir_kedua` · `ev_merrit_rute_pos_berubah` ·
`ev_merrit_arlen_ingat` · `ev_ashbrook_bram_ingat_ayahnya`.

## 1.5 NPC — **SETENGAH, dan pembagiannya terbalik**

| kelompok | jumlah | bisa bicara? |
|---|---|---|
| Warga **berjadwal** (persona + dialog) | 5 | ✅ **BISA** — 4 baris tiap orang, berganti menurut jam WIB |
| Warga **latar** | 15 | ❌ sengaja tidak (agar tak merebut tombol E) |
| **NPC BERNAMA** — Merrit Fane · Halloran · Old Bram · Nyai · Otha Renn · **Sora** | 6 | ❌ **TIDAK BISA — nol interaksi** |

### 🔴-2 — enam tokoh kanon adalah gambar tempel

`Ashbrook64._folk()` membangun keenamnya sebagai **`Sprite2D` polos**: nol skrip, nol
grup `interactable`, nol tabrakan, nol dialog. Mereka digambar dengan seni potret yang
dibuat khusus, berdiri di tempat yang bermakna — dan pemain **tidak bisa menyentuh
satu pun**.

Ini juga **sebab langsung 🔴-1**: bukti jenis `orang` datang dari kesaksian, dan tak ada
seorang pun untuk bersaksi.

### 🔴-3 — dua Merrit dan dua Halloran hidup berdampingan

Persona di `town_npcs.json` bernama **"Merrit Fane"**, **"Old Bram"**, **"Halloran Muda"**,
"Lyra", "Spoon Man". Mereka dipasang sebagai `Villager` **berwajah generik**
(`warga_00…19`) — **dan merekalah yang bisa diajak bicara.**

Jadi di alun-alun yang sama berdiri:
- **Merrit berwajah generik** yang bisa bicara, dan
- **Merrit berwajah asli** yang bisu.

## 1.6 COMBAT — **BISA, tapi setipis mungkin**

| unsur | vonis |
|---|---|
| Serang (tahan klik kiri) | **BISA** |
| Bilah skill 1–5, prime + cast, FUSION | **BISA** — terisi sejak awal, HUD merefleksikannya |
| **Musuh di Ashbrook** | **1 ekor** — anak serigala terluka (#118) di (1700, 980) |
| Dungeon / bos / mode sisi-samping | **TAK TERJANGKAU** |

### 🔴-4 — tutorial menyuruh hal yang mustahil di sini

`Onboarding.gd` menampilkan rantai 6 langkah di HUD, dan langkah pertamanya terpampang
di **tiap tangkapan layar sesi ini**:

> `COMBAT — Kalahkan 2 monster di luar gerbang (0/2)`

Di Ashbrook **hanya ada 1 monster**, dan gerbangnya tidak menuju "luar" — ia kembali ke
Main Menu. Enam langkah tutorial itu:

| langkah | bisa di Ashbrook? |
|---|---|
| Kalahkan **2** monster | ❌ cuma ada 1 |
| Pakai skill ke musuh | ⚠ hanya pada 1 ekor itu |
| Tebang **3** pohon pinus | ❌ nol `GatherNode` di Ashbrook |
| Ramu di **Bengkel pandai besi** | ⚠ tab Craft bisa dari menu, tapi **tak ada bengkel** |
| Tame monster | ⚠ sasaran cuma 1 |
| Kunjungi **Papan Quest di balai kota** | ❌ tak ada papan quest |

Tutorialnya milik **Greenvale**. Ia tampil di Ashbrook dan **tak satu langkah pun bisa
diselesaikan sebagaimana tertulis**.

## 1.7 EKOLOGI — **latar murni, dan itu memang disengaja**

27 makhluk hidup ter-wire (ternak, kucing & anjing liar, burung, satu anjing yang
mengikuti lalu berhenti, kucing penunggu, rusa putih). **Nol interaksi** — tak ada E, tak
ada bukti, tak ada dialog. Mereka mengubah **bacaan** tempat, bukan **aksi** pemain.

Vonis: **BISA dilihat, TAK ADA yang bisa dilakukan.** Sesuai maksudnya, dicatat supaya
tak disangka isi gameplay.

## 1.8 SISTEM LAIN

| sistem | vonis | sebab |
|---|---|---|
| Tas / item / pakai-lengkapi | **BISA** | inventaris awal berisi ramuan, orb, tunik, bibit |
| **Craft** | **BISA** | tab Craft jalan tanpa workbench |
| **Toko** | **SETENGAH** | tab ada dan bisa diklik — **tanpa pedagang di dunia** |
| Tab lain (Status, Jurnal, Quest, Skill, Pohon, Grimoire, Pet, Profesi, Pedia, Panduan) | **BISA dibuka** | isinya bergantung sistem yang sebagian tak terjangkau |
| **Peta dunia (M)** | **SETENGAH** | UI terbuka, **semua region lain `🔒 ? ? ?`** — `visited_regions` cuma berisi "ashbrook" |
| **Pindah region** | **TAK ADA** | satu-satunya "keluar" = gerbang selatan → **kembali ke Main Menu** (diakui SEMENTARA di komentar kode) |
| **Homestead / tanam-panen** | **TAK ADA di sini** | kode lengkap, portalnya **hanya ada di Greenvale** |
| **Companion / party manusia** | **TAK ADA** | party **pet** ada, tapi butuh taming dulu |
| **R3 pembusukan bukti** | **TIDUR** | `is_decayed()` **dibaca** oleh `Interactable`, tapi jam pembusukannya **tak pernah dimulai** oleh siapa pun |

---

# BAGIAN 2 — BANDINGKAN DENGAN RENCANA

## 2.1 CORE LOOP (#221 Chronicle Restoration)

Loop resmi lima langkah: **kabut datang → pemain merasakan → mencari bukti → menulis
ulang → kabut datang lagi.**

| langkah | vonis | catatan |
|---|---|---|
| 1. Kabut datang (halaman dicoret senyap) | ✅ **TER-WIRE** | terjadi saat tiba, nol pengumuman — D-3 dipatuhi |
| 2. Pemain merasakan | ⚠ **SETENGAH** | isyaratnya ada (papan kosong, jendela gelap, fondasi) tapi **NPC tak pernah lupa** karena tak bisa diajak bicara |
| 3. Mencari bukti | ⚠ **SETENGAH** | 6 dari 14; **seluruh jenis `orang` hilang** |
| 4. Menulis ulang | ✅ **TER-WIRE** | Kitab → pilih jalur → pulih dengan `loss` |
| **5. Kabut datang LAGI** | ❌ **TAK ADA** | tak ada pencoretan kedua. Loopnya **garis lurus, bukan lingkaran** |

**Vonis loop: berputar satu kali, lalu berhenti.** Empat dari lima langkah punya sesuatu;
yang menjadikannya *loop* — kabut yang datang lagi — belum ada.

## 2.2 EMPAT COMPANION ACT 1 (#223)

| companion | rencana | kenyataan |
|---|---|---|
| **Merrit** | jaringan bukti; "menunggu 40 tahun" | sprite bisu + persona berwajah generik. **Tak bisa direkrut** |
| **Arlen** | "kaki"; satu-satunya ber-gate `requires_npc` | **TIDAK ADA sama sekali** — nol sprite, nol penempatan. Cuma disebut di satu id bukti |
| **Elyn** | mesin pemulihan | **bukan tokoh** — cuma tombol jalur di Kitab + angka `elyn_burden`. Tak pernah muncul |
| **Sora** | detektor/alarm | sprite bisu di (672,1024). Jalur juru tulisnya **tak ter-wire** |

**Nol dari empat bisa direkrut. Rantai rencana "Sora merasakan → Arlen mengambil →
Merrit tahu ke mana → Elyn menulis" tidak ada satu mata rantai pun yang hidup.**

## 2.3 TIGA ADEGAN A1 / A2 / A3

| adegan | rencana | vonis |
|---|---|---|
| **A1 — Penghapusan Pertama** (Otha) | Dirancang **untuk dilewatkan**: toko yang tadinya buka jadi tutup, papan jadi kosong, Halloran berhenti menyapa & **rutenya berubah**, pintu **tak merespons sama sekali** | ⚠ **SETENGAH — yang ada cuma sesudahnya.** Papan bekas cat & pintu tertutup ada dan bisa diperiksa. Tapi keadaan **sebelum** tak pernah ada, jadi tak ada yang berubah di depan mata pemain. Dan pintunya **menjawab** dengan teks — rencananya justru diam total. Ini **pemandangan**, bukan adegan |
| **A2 — Seseorang Melupakanmu** (Merrit menyapa pemain seperti orang asing) | "Tidak bisa dilewatkan" | ❌ **TAK ADA.** Merrit tak punya dialog sama sekali, jadi ia tak bisa lupa. Bukti pemulihnya (kartu pos kosong, cangkir kedua) **nol terpasang** |
| **A3 — PILIH** (pilih satu dari dua halaman tercoret) | Bukti cuma cukup untuk satu; bekas Otha membusuk, bekas Merrit tidak | ❌ **TAK ADA.** Butuh dua halaman yang **bisa** dipulihkan; Merrit 0/4 dan Otha 1/4. Tak ada pilihan karena tak ada yang bisa dipilih. Pembusukan (R3) pun tidur |

## 2.4 SPEC R1 / R2 / R3

| spec | janji | vonis |
|---|---|---|
| **R1** — `strike()` / `restore()`, entri tak pernah dihapus, selalu ada `loss` | ✅ **TER-WIRE PENUH** | terverifikasi di ketiga jalur |
| **R2** — Hukum Bukti sebagai data: 14 bukti, 3 halaman, jenis bukan jumlah | ⚠ **DATANYA ADA, DUNIANYA BELUM** — 6 dari 14 terpasang; 2 dari 3 halaman mustahil dipulihkan |
| **R3** — pembusukan bukti; lomba melawan dunia yang melupakan | ❌ **TIDUR** — pembacanya ada, pemicunya tak pernah dipanggil |

## 2.5 DIRENCANAKAN TAPI BELUM TER-WIRE

- Kabut kedua / pencoretan berulang (**penutup loop**)
- Bukti jenis `orang` — **seluruhnya**
- Dialog NPC bernama; NPC yang **lupa**
- Rekrutmen companion (keempatnya) · Arlen sebagai tokoh · Elyn sebagai tokoh
- A2 & A3 sebagai adegan yang dimainkan
- Pembusukan R3 (pemicunya)
- "Yang Terhapus" (musuh baru Act 1) · wilayah memutih · nama tak terucap
- Perpindahan region · homestead · Life Events · Living Sky · dungeon

## 2.6 ADA TAPI TAK DIRENCANAKAN (untuk Ashbrook)

- **Rantai tutorial 6 langkah Greenvale** yang tampil di HUD Ashbrook dan mustahil
  diselesaikan (🔴-4)
- **Bilah skill penuh + FUSION** sejak menit pertama — di peta yang punya 1 musuh
- **Tab Toko & Craft** yang bisa dibuka tanpa pedagang maupun bengkel
- **Ekologi 27 makhluk** — lapisan atmosfer yang tak ada di spec mana pun
- Titik pandang #218, hutan tepi, rusa putih, variasi fasad — semua **presentasi**

---

# BAGIAN 3 — VONIS JUJUR

**Ashbrook hari ini adalah panggung yang sangat matang untuk sebuah adegan yang belum
punya pemain lawan bicara.** Lingkaran inti secara teknis tertutup — halaman dicoret
tanpa suara saat pemain tiba, enam bekas bisa dipungut dengan kaki sendiri (terbukti:
100% peta terjangkau, rantai utuh di ketiga jalur), Kitab bisa dibuka, dan nama Ashbrook
benar-benar bisa ditulis ulang. Itu bukan kulit; itu isi, dan itu berjalan. Tapi tepat di
titik yang paling menentukan, isinya berhenti: **dari empat jenis bukti yang jadi seluruh
tesis Hukum Bukti, jenis `orang` tidak ada satu pun di dunia** — karena keenam tokoh
bernama dibangun sebagai gambar tempel tanpa dialog. Maka pemulihan terbaik yang bisa
dicapai pemain **sudah ditentukan sebelum ia menekan tombol pertama**, dan kalimat
penutupnya selalu sama: *"Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus
orang."* Kalimat itu dirancang sebagai **hukuman karena melewatkan kesaksian** — sekarang
ia jadi **satu-satunya akhir yang ada**, dan hukuman yang tak bisa dihindari berhenti
terasa sebagai hukuman.

Jadi jawabannya: **core loop bisa dialami, tapi baru separuh dalamnya, dan baru satu
putaran.** Tesisnya — *menulis nama yang terlupa* — sampai ke pemain sebagai **tindakan**
(ia benar-benar menulis) tapi belum sebagai **kehilangan** (ia tak pernah kenal siapa pun
untuk kehilangan mereka, tak pernah dilupakan oleh siapa pun, dan tak pernah harus
memilih siapa yang diselamatkan). A1 hadir sebagai pemandangan, A2 dan A3 belum ada sama
sekali, keempat companion tak bisa direkrut, dan kabut tak pernah datang untuk kedua
kalinya. Yang paling dekat dengan "kulit tanpa isi" bukan Chronicle-nya — melainkan
**lapisan sosialnya**: enam potret yang dibuat dengan susah payah, berdiri di tempat yang
tepat, dan bisu; sementara pintu-pintu kayu di sebelah mereka justru punya suara.

**Satu perbaikan mengubah paling banyak:** membuat keenam NPC bernama bisa diajak bicara
dan memasang tiga bukti jenis `orang`. Itu sekaligus membuka pemulihan penuh, memberi
Merrit mulut untuk melupakan pemain (A2), dan memberi halaman kedua yang layak dipilih
(A3). Semua sistem penopangnya — `Stage.say`, `interactable`, `Evidence.find`,
`Chronicle.restore` — **sudah berjalan hari ini**; yang kurang cuma sambungannya.
