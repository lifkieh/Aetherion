# DELAPAN HUKUM KEDALAMAN NPC — spec v0.6

> **Status: KANON** (Decision Log #170). **Implementasi: v0.6** (bersama personality engine,
> trait spesies, Growth Type, Life Events). Ini **bukan** fitur baru — ini **hukum yang mengikat**
> setiap sistem NPC yang kita bangun setelahnya.

**Kenapa ini ada di kanon, bukan di dokumen tuning:** kedelapan hukum ini adalah **jawaban
mekanis atas Pertanyaan Nirnama** (`NIRNAMA_BIBLE_PUBLIC.md` §XII–XV). Kalau NPC hanyalah
angka yang naik, maka Nirnama benar — tidak ada yang layak diteruskan. Kedelapan hukum inilah
yang membuatnya salah.

## MODEL POTENSI — kanon (#179). **Semua = SPEC v0.6.**

> # `Outcome = Potential × Effort × (1 + Opportunity) × Time × Luck`
> *(rumus dikoreksi #184 — lihat "Lantai Kesempatan Dunia" di bawah)*

**POTENTIAL = CEILING BAWAAN** — batas teoritis seseorang.
**Ia TIDAK PERNAH sama dengan kemampuan sekarang. Ia TIDAK PERNAH sama dengan Outcome.**

### Skala tersembunyi (tak pernah tampil — hanya TIER lewat Item Penglihat, #175)

| Lapis | Rentang | Catatan |
|---|---|---|
| **Mayoritas** | **50–150** | *Orang biasa (~80–120) tetap bisa sukses, bahagia, dan bermakna.* **Ceiling rendah BUKAN vonis.** |
| **Berbakat** | **150–400** | |
| **Elite** | **400–700** | kalibrasi: **atlet** |
| **Jenius** | **700–1000** | kalibrasi: **~900** |
| **Fenomena langka** | **1000+** | *(contoh Direktur: **Potensi 1200 yang berakhir sebagai petani**)* |

*(Skala diperlebar #185 — skala lama 300–600/600+ membuat **atlet terbaca sebagai jenius**.)*

### ⚖ HUKUM PENGUNCI: **"Legendary bukan SIFAT. Legendary adalah HASIL."**

Potensi tinggi lahir **hanya sebagai ceiling** — **bukan jaminan apa pun**:
- **NPC ber-Potential 1200 bisa berakhir sebagai PETANI** — tanpa kesempatan, mati muda,
  depresi, perang, kemiskinan. **Dan itu bukan bug. Itu dunia.**
- **NPC ber-Potential 90 bisa menjadi FOUNDER** — kerja keras + mentor + kesempatan + nasib.

**Potensi baru terasa di JANGKA PANJANG** (terikat Chronicle Clock, #154):
- **Tahun 1:** **effort menang.** Yang rajin mengungguli yang berbakat. Selalu.
- **Tahun 20–40:** ceiling tinggi **mulai melampaui** — bila (dan **hanya bila**) pintu-pintunya
  pernah terbuka.

*Inilah mengapa game ini butuh jam kronik. Tanpa waktu panjang, potensi hanyalah angka mati.*

### Lima faktor — siapa yang memegang apa

| Faktor | Sumber | Bisakah pemain mengubahnya? |
|---|---|---|
| **POTENTIAL** | bawaan lahir | ❌ **TIDAK PERNAH** |
| **EFFORT** | personality (Discipline + Ambition) × kondisi mental (Hukum 5) | ❌ **TIDAK dikontrol pemain** — lihat Hukum Kemauan |
| **OPPORTUNITY** | **dunia + PEMAIN** — *"jumlah pintu yang terbuka"*: rekrut · mentor · ekspedisi · perlengkapan · jaringan | ✅ **INILAH yang pemain ubah** |
| **TIME** | umur + pengalaman | 🟡 tak langsung (pemain memberi **kesempatan lebih awal**) |
| **LUCK** | acak | ❌ |

### ⚖ HUKUM KEMAUAN NPC (mengunci **Belonging**)

> ## **"The player influences lives. The player does not own them."**

- **Pemain TIDAK mengontrol Effort.** NPC punya **kehendak sendiri** dan **boleh menolak**:
  *"aku capek." · "aku ingin pulang." · "aku tidak suka perang." · "aku ingin buka toko."*
- **Effort naik lewat mentor, inspirasi, dan hubungan — BUKAN lewat paksaan.**
  Tak ada tombol "latih paksa". Tak ada slider disiplin.
- **Effort & Opportunity WAJIB lahir dari SIMULASI DUNIA** — **bukan angka acak dari langit.**
  Kalau seorang NPC tiba-tiba rajin tanpa sebab yang bisa ditunjuk, sistemnya salah.

*Kalau pemain bisa memaksa siapa pun bekerja keras, maka NPC adalah alat — dan Belonging mati
pada detik itu juga.*

---

## ⚖ LANTAI KESEMPATAN DUNIA (#184) — dan mengapa rumusnya dikoreksi

**Cacat yang ditutup:** dalam rumus perkalian murni, `Opportunity` yang **lahir = 0** membuat
**Outcome = NOL MUTLAK** bagi setiap orang yang tak pernah disentuh pemain. Itu **membunuh Hukum 8
secara matematis**: ~90% dunia akan bernilai **nol** di dalam mesin yang seharusnya membuktikan
bahwa mereka **menopang dunia**.

**Koreksi (kanon):**

> ### `Outcome = Potential × Effort × (1 + Opportunity) × Time × Luck`

- **Opportunity lahir = 0 TETAP** (Hukum 3 **utuh** — kesempatan **hanya** datang dari peristiwa).
- Tetapi `(1 + 0) = 1` → **Outcome tetap mengalir** dari `Potential × Effort × Time`.
- **Opportunity 0 kini berarti "HIDUP KECIL" — bukan "TIDAK ADA".**

**LANTAI KESEMPATAN DUNIA:** dunia **selalu** memberi sedikit pintu — **desa · pekerjaan ·
keluarga** — bahkan **tanpa pemain**. **Pemain memberi jauh lebih banyak.** Itulah sebabnya pemain
tetap **sumber kesempatan terbesar** (L14) **tanpa** menjadi **satu-satunya** sumber.

> **Alasan kanon (#184):** *Hukum 8 harus benar **secara matematis di dalam mesin**, bukan hanya di
> dalam dokumen. Tukang roti yang tak pernah kau sentuh adalah **hidup kecil yang bermakna** —
> bukan Outcome nol.* Kalau mesinnya bilang nol, maka **Nirnama benar** — dan seluruh kitab runtuh.

## STATUS PELAKSANAAN — apa yang SUDAH terkode vs apa yang masih SPEC

| Hukum | Status hari ini | Di mana |
|---|---|---|
| **1. POTENTIAL = ???** | ✅ **terkode** (nilai ada, **tak pernah tampil** — dijaga test anti-bocor UI `_test_potential_not_exposed`) · **Item Penglihat = SPEC v0.6** | `Personality.gd` |
| **2. HIDDEN TALENT TIER** | ✅ **terkode** — `talent_tier()` (Average/Gifted/Exceptional/Legendary) + kelangkaan **struktural** (`talent` = **nilai terkecil dari 3 lemparan**). **Terverifikasi test: Legendary <5%, Average >60%** | `Personality.gd` |
| **3. OPPORTUNITY** | ✅ **terkode** — `opportunity` **lahir = 0** dan **hanya** naik lewat peristiwa (L14) | `Personality.gd` |
| **4. LUCK** | ✅ **terkode** — seed per individu, deterministik | `Personality.gd` |
| **5. MENTAL HEALTH** | 🔴 **SPEC** — yang ada baru `trauma[]` + `mental_state`. Depresi · burnout · kecanduan · kehilangan tujuan hidup · kecemasan **belum ada** | **v0.6** |
| **6. GROWTH RATE** | 🔴 **SPEC** — variasi kecepatan tumbuh per individu belum ada | **v0.6** |
| **7. TRAINING PHILOSOPHY** | 🟡 **separuh** — bobot rumus **sudah** menegakkan *Training→Progress selalu, Training ≠ Legendary*; **mesin latihannya belum ada** | **v0.6** |
| **8. ORDINARY PEOPLE** | 🔴 **SPEC** — belum ada apa pun yang **menjamin ~90% tetap biasa** | **v0.6** |

*Aturan integrasi (#172): kedelapan hukum **menyambung** ke model kepribadian 5 lapis & L14–L18
yang **sudah kanon** — **JANGAN duplikasi**. Tidak ada "sistem bakat" kedua, tidak ada
"sistem keberuntungan" kedua.*

---

## 1. POTENTIAL = ??? *(hukum induk — mengikat tujuh sisanya)*

**Masa depan setiap NPC adalah `???`, dan itu TIDAK PERNAH boleh diketahui — oleh pemain,
oleh penulis, bahkan oleh Sang Nirnama.**

- **POTENSI ITU NYATA — ia ADA sebagai nilai di data** (#175). Ia harus ada: itulah yang
  membedakan orang yang **mentok-biasa** dari orang yang **mentok-Legendary**. Menghapusnya =
  membuat semua orang sama, dan itu **kebohongan yang berbeda**.
- Ia **TERSEMBUNYI secara default**: tak ada bintang, tak ada "bakat: A", tak ada bar yang bocor
  lewat tooltip. **Pemain biasa melihat `???` seumur hidup NPC itu.**
- **Tak ada NPC yang dijamin sukses. Tak ada yang dijamin gagal** — sebab potensi hanyalah satu
  suku dari empat (rumus induk), dan **Opportunity lahir = 0**.
- **Uji desain:** kalau seorang pemain bisa menyortir NPC **tanpa berburu apa pun**, hukum ini
  sudah mati.

### ⚖ SATU PENGECUALIAN KANON — **ITEM PENGLIHAT POTENSI** (#175, spec v0.6)

**Satu-satunya jalan** melihat potensi seseorang: sebuah **item langka** (nama menyusul) yang,
bila diarahkan kepada seseorang, menampilkan **TIER**-nya.

| Aturan item | |
|---|---|
| **Menampilkan** | **TIER saja** (Average / Gifted / Exceptional / Legendary) — dan, bila melampaui pandangannya, **isyarat samar**: *"potensinya melampaui yang bisa kulihat."* |
| **TIDAK PERNAH menampilkan** | **angka mentah** · `outcome_projection` · rincian talent/effort/luck |
| **Kelangkaan** | item **langka** — mengintip masa depan seseorang **harus mahal** |
| **Status** | **SPEC v0.6** (bersama mesin NPC Depth). **JANGAN dibangun sekarang.** |

**Kenapa ini MEMPERKUAT Hukum 1, bukan melanggarnya:** pengetahuan itu **sendiri menjadi
kekuatan**. Pemain yang berburu item langka lalu tahu bahwa **anak petani ini berpotensi
Legendary** kini punya **alasan untuk memberinya kesempatan** (L14) — dan **kesempatan itulah
yang benar-benar mengubah takdirnya**, bukan angkanya. *Potensi yang diketahui tetap tak berarti
apa-apa sampai seseorang berbuat sesuatu untuknya.*

**Dan sisi gelapnya sengaja dibiarkan:** pemain **boleh** memakai item itu untuk **memilih siapa
yang layak** — lalu mengabaikan sisanya. Dunia **tidak menghukumnya**, dan **tidak memaafkannya**.
Chronicle hanya **mencatat siapa yang kau lewati.**

## 2. HIDDEN TALENT TIER

Bakat **ada** dan **tidak merata** — tapi ia **tersembunyi**, dan **sering tidak diketahui oleh
pemiliknya sendiri**.

**Empat tier (kanon — nama internal, TIDAK PERNAH tampil):**

| Tier | Kira-kira | Bagaimana dunia mengetahuinya |
|---|---|---|
| **Average** | mayoritas | tidak pernah — dan itu wajar |
| **Gifted** | tidak umum | terungkap lewat **perbuatan**, bukan tooltip |
| **Exceptional** | langka | orang mulai **membicarakannya** (rumor — dan rumor boleh salah) |
| **Legendary** | sangat langka | hanya **Chronicle** yang akhirnya mencatatnya |

- **Kelangkaannya sudah STRUKTURAL, bukan tabel drop:** `talent` = **nilai terkecil dari tiga
  lemparan** (`Personality.gd:69`) → ekor atas menipis dengan sendirinya. *Genius langka karena
  matematikanya, bukan karena kita menahannya.*
- Tier **tidak pernah ditampilkan** — ia hanya **tersirat** lewat perilaku, kecepatan belajar,
  dan komentar orang lain (*"anak itu… cepat sekali menangkap."*).
  **⚖ SATU PENGECUALIAN:** **Item Penglihat Potensi** (Hukum 1, #175) — dan ia menampilkan
  **tier saja**, tak pernah angka. Di luar itu: tetap `???`, selamanya.
- **Bakat besar di tempat yang salah = tetap tak menjadi apa-apa** (Hukum 3 & ENVIRONMENT).
- **GENIUS IS RARE** (L17): Talent + Effort **>** Talent. Talent + Effort + Opportunity + Luck
  = **pengubah sejarah**. Sisanya: orang berbakat yang tak pernah terdengar.

## 3. OPPORTUNITY *(hukum terpenting bagi gameplay)*

**Bakat tanpa kesempatan tidak menjadi apa-apa.** Dan:

> **PEMAIN ADALAH SUMBER KESEMPATAN TERBESAR DI DUNIA.**

Merekrut · mementor · menempatkan seseorang · memberi alat · memberi kepercayaan =
**mengubah takdirnya**. Ini **bukan** metafora — ini harus jadi **mekanik yang bisa dilacak**:
Chronicle mencatat *siapa yang kau beri kesempatan*, dan **apa jadinya mereka**.

*Inilah senjata sesungguhnya melawan Nirnama: memberi orang lain kesempatan yang tak pernah ia
berikan kepada dirinya sendiri.*

## 4. LUCK

Sebagian orang berdiri di tempat yang tepat pada hari yang tepat. Sebagian tidak.

- Luck **hanya bergerak lewat PERISTIWA** (#138) — **tak pernah** lewat timer kosong.
  *Keberuntungan yang di-tick tiap detik bukan keberuntungan; itu cuaca.*
- Luck **tidak boleh** ditampilkan sebagai stat NPC. Ia hanya terlihat **setelah** kejadian.
- **Dua tafsir atas fakta yang sama:** Nirnama membaca keberuntungan sebagai bukti dunia **tak
  berarti**; Aetherion membacanya sebagai bukti dunia **tidak ditentukan sebelumnya**.

## 5. MENTAL HEALTH *(PEOPLE CAN BREAK — L15)*

**Kekuatan mental adalah bagian dari kekuatan.**

**MELAMPAUI trauma yang sudah terkode.** Lima keadaan baru (spec v0.6) — masing-masing **keadaan**,
bukan debuff bertimer:

| Keadaan | Pemicu khas |
|---|---|
| **Depresi** | kehilangan berulang · terisolasi · kegagalan yang dianggap salahnya sendiri |
| **Burnout** | bekerja/dilatih terus **tanpa jeda dan tanpa hasil yang terlihat** |
| **Kecanduan** | pelarian dari salah satu di atas |
| **Kehilangan tujuan hidup** | tujuannya tercapai — atau **direnggut** *(inilah keadaan Sang Nirnama)* |
| **Kecemasan** | hidup di bawah ancaman yang tak berujung (perang, wabah, penghapusan) |

**EFEK (ketiganya wajib):** **Growth Rate ↓** · **Motivation ↓** · **Learning Speed ↓**.

**PEMULIHAN:**
- **Dapat dirawat SEBAGIAN** — lewat **waktu**, **kedekatan** (seseorang yang tinggal), dan
  **Life Event**. **TIDAK PERNAH instan. TIDAK PERNAH lewat item.** *Tak ada potion untuk duka.*
- **Sebagian MENETAP** — dan **itu per tokoh**, bukan per lemparan dadu. Sebagian orang **tidak
  pulih**, dan kitab dilarang berpura-pura sebaliknya (§XV Tragedy).
- **Sinkron dengan luka pasca-revive (amandemen D1):** yang bangkit **membawa sesuatu yang tidak
  kembali utuh**. Luka itu **memakai sistem yang sama** — bukan sistem kedua.
  ⚠ *Prasyarat: sistem revive & harga-ingatan (#119/#133) belum ada di kode; sinkronisasi ini
  baru bisa dikerjakan setelah ia lahir.*

*Kalau seorang pemain bisa "menyembuhkan" depresi seorang NPC dengan mengklik item, Hukum 5 mati —
dan bersamanya, satu-satunya alasan Nirnama terasa manusiawi.*

## 6. GROWTH RATE

Orang tumbuh dengan **kecepatan berbeda**, dan **kurva yang berbeda** (Early / Balanced / Late).

- **Late bloomer harus ada** — dan pemain **tidak boleh bisa mengenalinya di awal** (Hukum 1).
  Seseorang yang tampak biasa selama 50 jam **boleh** menjadi luar biasa di jam ke-200.
- Growth **hanya bergerak lewat peristiwa & latihan**, tak pernah lewat idle.

## 7. TRAINING PHILOSOPHY *(L16)*

> **TRAINING CREATES STRENGTH — tapi Stronger ≠ Exceptional.**

- **Latihan MENJAMIN kemajuan.** Siapa pun yang dilatih **akan** membaik. Ini janji yang kita tepati.
- **Latihan TIDAK MENJAMIN kehebatan.** Tak ada jumlah latihan yang mengubah orang biasa menjadi
  legenda — dan **itu bukan kegagalan sistem, itu kejujurannya.**
- Karena itu: **mentoring selalu bernilai** (Hukum 3), **tanpa** menjadi mesin cetak pahlawan.

## 8. ORDINARY PEOPLE *(L18 — dan jawaban atas nihilisme)*

**Mayoritas NPC bekerja, berkeluarga, menua, dan meninggal tanpa menjadi legenda — DAN ITU BUKAN
KEGAGALAN.**

- **~90% penduduk hidup biasa**: bekerja, berkeluarga, menua, mati — **tidak dikenang, tidak
  masuk Chronicle, tidak diceritakan siapa pun setelah dua generasi.** *Dan dunia berdiri karena
  mereka.* **Chronicle menghormati yang biasa.**
- **Dilarang:** sistem apa pun yang memperlakukan NPC biasa sebagai **bahan mentah** (angka yang
  dioptimalkan, unit yang dibuang saat statnya turun).
- **Uji desain:** kalau seorang pemain optimal **tidak punya alasan** untuk peduli pada tukang
  roti, kita sudah gagal — dan Nirnama menang.

---

## MENTOR SYSTEM — siklus hidup companion (MEJA-3, #182 · spec v0.6/v0.9)

> **Companion → Veteran → Mentor → Retired → Death → Legacy**

Ini jawaban resmi atas T6 (companion yang menua di samping pemain yang tak menua, #165).

| Fase | Yang terjadi |
|---|---|
| **Companion** | bertarung di sisimu |
| **Veteran** | masih kuat, tapi tubuhnya mulai bicara |
| **MENTOR** | **berhenti dari garis depan** — dan mulai **MELATIH generasi baru**: mewariskan **skill**, **filosofi**, dan **kenangan**. **Pengaruh & pengetahuannya NAIK** (L14) — ia menjadi **sumber Opportunity** bagi orang lain |
| **Retired** | pensiun penuh — **hanya bila pemain memilih**; opsi ini tetap ada |
| **Death** | sebagai **peristiwa** (D1), tak pernah sebagai notifikasi |
| **Legacy** | apa yang ia tinggalkan **tetap bekerja** — murid, filosofi, Chronicle |

> ### ⛔ **MEMENSIUNKAN COMPANION KARENA STATNYA TURUN = DILARANG.**
> Itu pelanggaran langsung **L18** (*"most people are ordinary — dan itu bukan kegagalan"*) dan
> **T6**. Companion yang menua **tidak menjadi beban** — ia **berpindah peran**, dan perannya yang
> baru **lebih penting** daripada DPS-nya: **ia membuka pintu untuk orang lain.**

**Terhubung ke:** Legacy Family (B3, v0.9) · "The World Remembers" (v0.6) · Hukum 3 (Opportunity).

---

## Konsekuensi silang yang WAJIB dijaga

| Hukum | Sistem yang menyentuhnya | Bahaya bila dilanggar |
|---|---|---|
| 1, 2 | UI NPC / Domain / rekrutmen | Pemain menyortir manusia seperti loot |
| 3 | Rekrutmen · mentoring · Domain · Chronicle | Belonging mati; pemain jadi turis |
| 4, 6 | Life Events · growth engine | Timer kosong menggantikan peristiwa (#138) |
| 5 | Life Events · companion | Trauma jadi debuff yang di-*dispel* |
| 7 | Training / Domain | Mesin cetak pahlawan |
| 8 | Semua | **Nirnama menang** |

**Companion yang menua melampaui prima (T6, menunggu Direktur):** rekomendasi tetap — ia
**berpindah peran menjadi MENTOR** (jadi **sumber kesempatan** bagi yang lebih muda, Hukum 3),
**tidak dipensiunkan diam-diam karena statnya turun**. Memensiunkannya karena angka = melanggar
Hukum 8 secara langsung.
