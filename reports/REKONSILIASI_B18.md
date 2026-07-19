# REKONSILIASI STORY_SPINE v0.1 ↔ KANON B18

**2026-07-20** · read-only · **spine TIDAK diubah** (commit `6b57aa0`, disimpan apa adanya).
Temuan untuk Designer. **Nol ratifikasi #263–266 sampai K1–K3 ditutup.**

Sumber yang dibaca penuh: `NIRNAMA_BIBLE_PUBLIC.md` (B18 v2.1) · `FACTION_BIBLE.md` ·
`Companion_bible/companion_02_elyn_thornewood.md` · `IMPLEMENTATION_ROADBOOK.md` ·
`SPEC_PAYOFF_SLICE.md` · `CHRONICLE_RESTORATION_SPEC.md` · `A3_TRIASE.md` ·
`RAS_KANON.md` · `ADVANCED_CLASS_DEEDS.md` · `CANON_219-230_FINAL.md` ·
`REGION_ORIGINS.md` · `KINGDOM_BIBLE.md` · `CITY_BIBLE.md` · `DUNGEON_ORIGINS.md` ·
`DIVINE_BIBLE.md` · `MISTERI_ABADI.md` · `Aetherion_bible/…part 4.txt` (Heirs of Nothingness).

---

# RINGKASAN: 3 KONFLIK BERAT · 4 SEDANG · 1 TEMUAN DI LUAR SPINE

| | Isi | Berat |
|---|---|---|
| **K1** | Chronicle Order ditaruh di kutub yang SALAH | 🔴 berat — membatalkan §2 |
| **K2** | Harga Elyn = umur + keturunan **menabrak sheet #002** — dan sudah ter-*ratifikasi* di #258 **dan sudah masuk kode + UI Kitab** | 🔴 berat — kanon vs kanon |
| **K3** | Endgame kanon (**HYBRID FINAL JUDGE**, dikunci #134/D2) + **5 ending bernama** tak muncul sama sekali di §3-IV/§6 | 🔴 berat |
| **K4** | B18 punya struktur Act sendiri; lima gerakan tak dipetakan padanya | 🟠 sedang |
| **K5** | 4 dari 6 tahap Life Event Elyn tak punya tempat di spine; TRIASE salah waktu | 🟠 sedang |
| **K6** | Tak ada wilayah endgame kanon — dan panggungnya bukan wilayah sama sekali | 🟠 sedang |
| **K7** | §2 melewatkan ±60 pemegang kutub kanon, termasuk **kutub ketiga** yang sudah kanon | 🟠 sedang |
| **K8** | Pertanyaan dramatik punya **tiga rumusan kanon** berbeda | 🟡 ringan |

---

# §8.1 — APAKAH B18 SUDAH PUNYA STRUKTUR BUSUR?

**YA.** B18 punya struktur Act, dan ia **berbasis jam main**, bukan berbasis eskalasi taruhan.

**`NIRNAMA_BIBLE_PUBLIC.md:164-165` — "ARC ACT 1 — RESMI FINAL (MEJA-1 diratifikasi #180)":**

| Fase | Jam | Isi |
|---|---|---|
| Fase 1 | 1–30 | gejala: wilayah memutih · NPC tergagap · Yang-Terhapus pertama · Nirnama Cult memuja *"Keheningan yang Baik"* |
| Fase 2 | 30–60 | penyintas bersuara (Old Elder · Silent One · Underground Elite) · **satu pertemuan tanpa nama** (pengelana tua) |
| Fase 3 | 60–100 | penghapusan menyentuh MILIK pemain → klimaks **Celestial Crisis: bulan retak** (B5), Nirnama terungkap |

Act 2 = reveal nama, di reruntuhan Aetheria Prima (`:165`). Act 1–4 dirujuk eksplisit di `:125`.
Klimaks Act 1 **dipindah ke v0.8** — `IMPLEMENTATION_ROADBOOK.md:134`.

### 🔶 K4 — KONFLIK STRUKTUR (sedang)

Lima gerakan §3 **tidak bertabrakan isi**, tapi **tak punya sambungan sama sekali** ke Act/Fase:

- Spine Gerakan I = Ashbrook = **v0.4.x**, yaitu **SEBELUM Act 1 ada** (Act 1 bergerbang v0.5).
- Spine Gerakan IV disebut "Endgame" = v1.0. Act berapa? Tak dinyatakan.
- B18 mengukur dengan **jam main** (1–30/30–60/60–100). Spine mengukur dengan **eskalasi taruhan**.
  Dua sumbu berbeda, dan dokumen manapun belum menyatakan mana yang mengikat.

**Yang Designer harus putuskan:** apakah lima gerakan itu **di dalam** Act 1–4, **melintasi**-nya,
atau **menggantikan** penomoran act. Spine §7 bilang "B18 menang" — maka lima gerakan harus
dipetakan ke act, bukan berdiri sendiri.

---

# §8.2 — FILOSOFI CHRONICLE ORDER + ARC #205 ELYN

## 🔴 K1 — KONFLIK BERAT: SPINE MENARUH CHRONICLE ORDER DI KUTUB YANG SALAH

**`STORY_SPINE.md:25`:** *"**INGIN-LUPA — diwakili Chronicle Order.**"*

**Setiap sumber kanon menyatakan kebalikannya:**

| Sumber | Baris | Verbatim |
|---|---|---|
| FACTION_BIBLE | **31** | *"Ini adalah **benteng utama melawan pelupaan**."* |
| FACTION_BIBLE | **30** | *"Musuh alami: **NIRNAMA CULT** · **Pemalsu Sejarah**."* |
| FACTION_BIBLE | **38** | *"Chronicle Order adalah **wajah kelembagaan** dari tokoh utama kedua kita."* |
| FACTION_BIBLE | **162** | *"**Dua filosofi mengingat — dua-duanya melawan pelupaan Nirnama**, dari sudut yang berbeda"* |
| B18 | **300** | tabel §XVI: **Nirnama = INGIN LUPA · Chronicle = MENOLAK LUPA** |
| companion_02 | **24** | *"CHRONICLE ORDER \| sejarah yang **PENTING** \| **institusi** — arsip, ordo, **benteng melawan pelupaan**"* |

**Ironinya:** spine mengutip `FACTION_BIBLE:144-167` sebagai jangkarnya — dan **rentang itu
sendiri** (`:162`) adalah kalimat yang membantahnya.

**Pemegang INGIN-LUPA yang sebenarnya:** **Sang Nirnama** (B18:300) dan **NIRNAMA CULT**
(FACTION_BIBLE:30 · B18:165 · ROADBOOK:50).

### Yang bisa diselamatkan dari niat §2

Sisi gelap Order **memang** condong ke pelupaan — tapi **pelupaan selektif**, bukan ingin-lupa:

> `FACTION_BIBLE:29` — *"kadang **memutuskan sejarah mana yang layak diingat**."*
> `FACTION_BIBLE:40` — *"organisasi yang memutuskan apa yang layak diingat sedang melakukan
> **versi sopan** dari apa yang Nirnama lakukan dengan kasar."*

**Itulah bahan HN-6 yang spine cari** ("argumen Order harus menang sekali") — tapi ia
**bukan kutub**; ia **skisma di dalam kutub menolak-lupa.**

## #205 — cocok, dan lebih tajam daripada yang spine tulis

`FACTION_BIBLE:157-167` **DIPUTUS (MEJA-ELYN = b, #205): ELYN = PEMBANGKANG CHRONICLE ORDER.**
Spine §2 benar di sini. Tapi jembatan tematiknya hilang dari spine:

> `FACTION_BIBLE:161-162` — *"Chronicle Order menjaga sejarah **PENTING** · Elyn + Sora (#013)
> menjaga sejarah **ORANG BIASA**."*
> `FACTION_BIBLE:166-167` — *"kalau Ordo adalah **benteng**, Elyn adalah **lilin di jendela** —
> dan Nirnama meniup keduanya."*

**Sora (#013) hilang total dari spine.** Ia separuh dari pasangan ini di kanon.

---

# §8.3 — KONSEP ENDING/ENDGAME KANON

## 🔴 K3 — KONFLIK BERAT: ENDGAME SUDAH DIKUNCI, DAN §6 TIDAK MENYENTUHNYA

**`IMPLEMENTATION_ROADBOOK.md:158` — "ENDGAME: HYBRID FINAL JUDGE — dikunci (#134, D2)".**
Bukan usul. **Dikunci.**

> `:160-161` — *"Hukum bible dipertahankan penuh: Sang Nirnama TIDAK mati di tangan pemain.
> Tapi klimaksnya **tetap pertarungan gameplay besar** — hanya saja objektifnya dibalik"*

| Fase | Isi | Objektif |
|---|---|---|
| 1. Badai Penghapusan | gelombang Yang Terhapus + wilayah memutih | **BERTAHAN** |
| 2. Melindungi | **Domain-mu, companion-mu, halaman Chronicle-mu** jadi objektif hidup | **LINDUNGI** |
| 3. Penghakiman | *"**save file-mu sebagai argumen**"* | **JAWAB** |

**Tabrakan langsung:**

| Spine | Kanon |
|---|---|
| `:45` *"**Tak ada bos.**"* | `ROADBOOK:161` *"klimaksnya **tetap pertarungan gameplay besar**"* |
| `:45` Gerakan IV = *"halaman yang loss-nya adalah **Elyn**"* | `ROADBOOK:166` objektif = **Domain · companion · halaman Chronicle** (jamak, milik pemain) |
| `:15` *"**Tak ada momen 'pilih ending A/B'**"* | `ROADBOOK:173` **5 ENDING bernama**: Dawn · **Final Silence** · Last Sky · Broken Answer · **The World Remembers** |
| `:87` metrik = elyn_age_spent · halaman direlakan · memory_held · elyn_burden | `ROADBOOK:178` metrik = **Chronicle · Domain · companion yang hidup · orang yang mengingat** |

**Dan yang paling besar — Sang Nirnama tidak ada sama sekali di §6.** Kanon menaruh satu
detak emosi wajib di ujung:

> `B18:347` — *"**Pemain membebaskan Sang Nirnama dari pertanyaannya — sehingga ia akhirnya
> boleh BERHENTI.**"*
> `B18:359-362` — katarsisnya: *"ia menyelamatkan **seseorang**, bukan mengalahkan sesuatu.
> **Membebaskan musuhmu lebih berat daripada membunuhnya**"*

Spine §6 menggantinya dengan penimbangan ledger Elyn. **Itu ending yang berbeda, bukan
ending yang sama dirumuskan ulang.**

**Yang COCOK:** spine `:87` *"Tak ada ending baik/buruk"* ↔ `ROADBOOK:173` *"tidak ada ending
sempurna"*. Spine HN-1 (nol villain) ↔ `B18:327-331` tiga penggambaran terlarang. Spine HN-2
(loss permanen) ↔ `B18:363` LAW OF ERAS Loss & Continuation.

**Catatan halus — HN-3.** Spine `:97`: *"game tak memegang satu pun posisi"*. Tapi `B18:323`
menyatakan posisi dengan huruf kapital: **"NIRNAMA TIDAK SALAH. DUNIA TIDAK SALAH."** Kitab
**memang** menyatakan sesuatu; yang tak dinyatakan adalah **jawabannya**, bukan bingkainya.
HN-3 perlu dipersempit atau ia melanggar B18.

---

# §8.4 — ARC ELYN: ENAM TAHAP

Yang dimaksud "6 tahap" = **LIFE EVENT CHAIN**, `companion_02:101-111`.

| # | Tahap | Isi | Tempat di lima gerakan? |
|---|---|---|---|
| 1 | **Pertemuan** | pemain masuk, Elyn menyalin, tak mendongak — *"Semua yang diucapkan pemain, dicatat."* | ❌ tak ada |
| 2 | **Fragmen pertama (uji diam-diam)** | traktat vs daftar cucian; *"**Reaksinya terhadap daftar cucian jauh lebih keras.**"* | ❌ tak ada |
| 3 | **Pengakuan** | ia menceritakan kebakaran — *"Bukan apinya. **Pilihannya.**"* | ❌ tak ada |
| 4 | **Gerbang — TRIASE** | *"Pilih."* Dua pecahan, cukup untuk satu | ⚠ ada isinya (Gerakan III), **salah waktu** |
| 5 | **Pintu untuk orang lain (L14)** | pemain memperkenalkan **Sora** — *"titik cabang terpenting **bagi dua tokoh sekaligus**"* | ❌ tak ada |
| 6 | **Resolusi (4 cabang)** | Arsip Orang Biasa · Sarjana salah dikenang · **Api yang lebih lambat** · **Kebakaran kedua** | ❌ Gerakan V memakai cabang **kelima yang tak ada di kanon** |

## 🔶 K5 — apa yang putus

**(a) Empat dari enam tahap tak punya tempat.** Arc Elyn adalah **arc relasi bergerbang
kunjungan**, bukan arc eskalasi dunia. Ia tak bisa dipetakan 1:1 ke lima gerakan — dan spine
tak menyediakan slot untuknya sama sekali.

**(b) TRIASE salah waktu.** `A3_TRIASE.md:6` menaruhnya di **Act 1 Fase 3, Ashbrook**.
Spine `:36` menaruh Ashbrook sebagai *"Ongkos rendah: ruang ingatan masih lapang"*.
**Adegan triase terberat kanon terjadi tepat di tempat yang spine sebut ongkos-rendah.**

**(c) Gerakan V memakai cabang yang tidak ada.** Spine `:48`: *"Keturunan Elyn [KANON: Wren +
tiga keturunan, companion_02:39/99] mewarisi apa yang dilimpahkan"* — **salah baca kanon:**

> `companion_02:39` — *"Ada seorang gadis **manusia** bernama **Wren**"* — pembaca perpustakaan.
> `companion_02:99` — *"**Wren (dan tiga keturunannya):** relasi yang **seluruhnya sudah selesai
> sebelum pemain tiba**"*

**Wren adalah manusia pengunjung perpustakaan. Tiga keturunan itu keturunan WREN, bukan ELYN.**
`companion_02:120-124` LEGACY PATH mendaftar seluruh warisan Elyn — **Arsip Orang Biasa ·
Metode Thornewood · Sora · tidak ada** — **nol anak, nol keturunan.**

**(d) Cabang tergelap kanon tak dipakai.** `companion_02:110` *"**Api yang lebih lambat**: …
ia hanya **berhenti menyalin**. Perpustakaan tetap berdiri, utuh, teratur, dan mati. Ia duduk di
dalamnya selama empat abad. **Ini cabang tergelap, dan ia harus tetap ada.**"* Runtuhnya Elyn
di kanon adalah **depresi**, bukan umur habis.

---

# 🔴 K2 — KONFLIK BERAT DI LUAR SPINE: #258 SUDAH MENABRAK SHEET #002

**Ini bukan salah spine. Spine hanya mewarisinya.** Tapi ia mengunci §3-III, §3-IV, §4, §6 —
jadi ia harus ditutup lebih dulu.

**Usul aslinya benar.** `CHRONICLE_RESTORATION_SPEC.md:262`:

> *"**HARGA ELYN.** Tiap kali Elyn menulis ulang halaman, ia memberikan tinta dan tangan dan
> jam-jam malamnya. … **Semakin banyak ia menulis untuk pemain, semakin cepat ia melupakan
> miliknya sendiri.**"*

Itu **persis** sheet #002:

> `companion_02:76` — *"ia **tidak lagi bisa mengingat isi** sebagian buku yang terbakar …
> **ia sedang membunuh mereka pelan-pelan**, dengan cara yang paling wajar di dunia: dengan
> menjadi makhluk yang punya **ingatan terbatas** dan **umur yang terlalu panjang**."*
> `companion_02:78` — *"**Umur panjang, bagi Elyn, bukan berkah. Ia adalah ruang yang lebih
> besar untuk lupa.**"*

**Lalu #258 mengubahnya saat ratifikasi.** `SPEC_PAYOFF_SLICE.md:46-49`:

> *"mempercepat lupa Elyn (**umur berkurang**), dan **mewariskan beban ke keturunannya**"*

| Yang ditambahkan #258 | Dibantah oleh |
|---|---|
| **"umur berkurang"** | `companion_02:113-114` — *"Elf, 134, **awal prima** … **Ia tidak akan menua di depan pemain. Ia akan mengubur semua orang.**"* · `:118` — *"ia **tidak akan pernah pensiun karena tubuhnya melemah**; perannya memang tidak pernah tentang tubuh."* |
| **"keturunannya"** | `companion_02:99` (Wren manusia, keturunan Wren) · `:120-124` (LEGACY PATH: nol keturunan) |

**Harga kanon Elyn = ingatannya sendiri terdesak keluar, bukan tahun hidupnya.** Itu jauh
lebih tajam: ia **menjadi api kedua** (`:76`), yang persis ketakutannya.

**Sudah masuk kode dan sudah tayang ke pemain:**
- `PlayerData.elyn_age_spent` · `Chronicle.ELYN_YEARS_PER_PAGE := 1`
- Teks keterbukaan Kitab (§4.G, tayang di LANGKAH 6/7):
  *"**Umurnya berkurang** tiap kali ia menolak lupa. Dan ruang yang penuh diwariskan —
  **keturunannya** memikul apa yang tak sanggup kaubawa sendiri."*

**Dua kalimat itu menyalahi sheet #002 pada dua titik sekaligus.**

---

# §8.5 — GEOGRAFI: GREENVALE + WILAYAH ENDGAME

## Greenvale — ✅ COCOK

| Klaim | Baris | Verbatim |
|---|---|---|
| kota utama | `REGION_ORIGINS.md:13` | *"GREENVALE — kota utama, Greenhollow Valley"* |
| = rumah | `REGION_ORIGINS.md:28` | *"gameplay = **rumah**: bengkel, lelang, gerbang, pohon skill pertama"* |
| kerajaan awal | `KINGDOM_BIBLE.md:112` | *"Greenvale \| **VALENFORD** \| hub manusia, **kerajaan awal**"* |

⚠ **Koreksi kecil:** kota **awal** adalah **Ashbrook**, bukan Greenvale
(`KINGDOM_BIBLE.md:211,213` · `CITY_BIBLE.md:46` "**Starting Town**"). Spine benar menaruh
Greenvale sebagai tulang punggung Gerakan II–III, tapi jangan sebut ia titik mulai.

## 🔶 K6 — Wilayah endgame: **TIDAK ADA, DAN MEMANG TIDAK BOLEH ADA**

Spine `:73` bertanya *"[CEK-B18: adakah wilayah akhir yang sudah kanon?]"* — **jawabannya tidak,
dan pertanyaannya sendiri berangkat dari asumsi yang salah.**

| Temuan | Baris |
|---|---|
| **Panggung endgame = Domain PEMAIN**, bukan wilayah karangan | `ROADBOOK:166` — *"**Domain-mu, companion-mu, halaman Chronicle-mu** dijadikan objektif hidup"* |
| Penghakiman terjadi di save file | `ROADBOOK:167` — *"**save file-mu sebagai argumen**"* |
| **The Nameless Door TIDAK BOLEH jadi dungeon akhir** | `MISTERI_ABADI.md:45` — *"Tidak boleh: peta interior kanonik … **boss di dalamnya sebagai jawaban**"* |
| Nameless Door = prop tunggal + ambience | `ASSET_MANIFEST.md:77` |
| Celestia = hub aman lv 60–80, **bukan** area akhir | `GDD_Aetherion.md:151` |
| Aetheria Prima = tempat reveal **nama** (Act 2), bukan konfrontasi | `B18:165` |
| Klimaks Act 1 = **peristiwa** (bulan retak), nol lokasi | `B18:165` · `ROADBOOK:134` |

**Nol lokasi konfrontasi Nirnama ada di seluruh kanon — dan itu disengaja.**

⚠ **Angka wilayah:** spine `:72` menulis *"7 wilayah + 5 dungeon"*. Kanon = **13 wilayah**
(`MASTER_BLUEPRINT:40` · `PROPOSAL:79` · `CANON_219-230_FINAL:92`), 5 hidup, 5 dungeon dibangun.
Angka 7 tak cocok dengan apa pun kecuali **7 benua**. Perlu dikoreksi atau dijelaskan.

⚠ **Catatan lokasi Elyn:** `A3_TRIASE.md:2` menaruh adegan di *"Perpustakaan **Ashbrook**"*
dengan Elyn hadir; `companion_02:37` menempatkan Elyn di **Sylvara**. A3 masih "Draft Penulis
v0.1" — perlu putusan Designer, bukan tambalan agent.

---

# §8.6 — PEMEGANG KUTUB YANG BELUM MASUK §2

Spine memakai **model dua pemegang**. Kanon punya **±60**, dan **satu kutub ketiga yang sudah
matang**. Yang paling menanggung beban:

## Yang seharusnya memegang INGIN-LUPA (dan tak ada di spine)

| Nama | Baris | Verbatim |
|---|---|---|
| **NIRNAMA CULT** | `ROADBOOK:50` | memuja *"**Keheningan yang Baik**"* |
| **Pemalsu Sejarah** | `FACTION_BIBLE:30` | musuh alami Chronicle Order |
| **HEIRS OF NOTHINGNESS** — 5 kelompok, status **LOCKED**, dijadwalkan v0.8 | `ROADBOOK:139` · `Aetherion_bible/…part 4.txt:720-1060` | *"IDEAS SURVIVE THEIR CREATOR … tidak ada ide yang lebih berbahaya daripada ide yang lahir dari **kebenaran sebagian**"* |
| ↳ **The Angry Ones** | part 4 | *"Dunia menyakitiku. Maka dunia pantas dihancurkan."* — *"Nirmana akan **membenci** kelompok ini"* |
| ↳ **The Broken Ones** | part 4 | *"Tidak ada yang penting."* — *"Mereka hanya **berhenti peduli**"* |
| ↳ **Scholars of the Void** | part 4 | *"Mereka tidak menyembahnya. Mereka **mempelajarinya**."* |
| ↳ **Cults of the End** | part 4 | *"Jika akhir pasti datang. **Mari percepat.**"* |
| **ASTRAVEIL** (kerajaan) | `KINGDOM_BIBLE:32` | *"**Tidak semua kebenaran perlu diketahui.**"* |
| **Elf muda Sylvara** | `companion_02:90` | *"Untuk apa menyimpan catatan bangsa yang mati begitu cepat?"* — **ini "argumen yang meyakinkan" yang HN-6 cari, dan ia sudah ditulis** |

> ⚠ **`part 4:1091` — SECOND LAW: sebagian pewaris kehampaan JUSTRU ingin membuktikan Nirnama
> salah.** *"Secara teknis ia tetap pewaris Nirnama, karena hidupnya dibentuk oleh pertanyaan
> yang sama."* Model dua-kutub tak bisa menampung ini.

## MENOLAK-LUPA selain Elyn

`CANON_219-230_FINAL.md:117-124` **sudah menetapkan empat pemegang untuk Act 1:**

| | Menolak melupakan | Statusnya |
|---|---|---|
| **Merrit** | satu orang | menunggu 40 tahun |
| **Sora** | orang asing | tak ada yang memintanya |
| **Elyn** | orang tak penting | pernah gagal sekali |
| **Arlen** | — | dialah yang akan dilupakan bila tak ada yang membuka pintu |

> *"**Tiga penjaga ingatan dan satu orang yang butuh diingat.** Seluruh tesis dari 4 orang di
> 2 lokasi."*

**Spine menyimpan satu dari empat.** Tambahan lain: **Memory Keepers** (`B18:131`, ⚠ belum punya
entri faksi — `FACTION_BIBLE:182-184`) · **Seekers of the Last Truth** (`FACTION_BIBLE:82`
*"Tidak ada rahasia yang layak dikubur selamanya"*) · **LUMERIA** (`KINGDOM_BIBLE:29`) ·
**SEVRIN**, dewa Penghakiman (`DIVINE_BIBLE:51` *"Setiap sumpah … Termasuk sumpah yang
dilanggar"*) · **Kain #05** (`companion_05:113` — cermin terbalik Nirnama:
*"Nirnama memilih **melupakan** agar tak sakit. Kain **tidak sanggup melupakan**"*).

## Ras — dua kutub sudah dikodekan ke dalam budaya

| Ras | Baris | Verbatim |
|---|---|---|
| **Shadeborn** *The Forgotten Ones* | `RAS_KANON:26` | *"Menerima pelupaan vs merebut kembali nama — **poros tema Memori-vs-Pelupaan**"* |
| **Elf** *The Long Remembering* | `RAS_KANON:20` | *"**Yang ingin melupakan agar bisa hidup vs yang menolak melupakan apa pun**"* |
| **Human** *The Builders* | `RAS_KANON:19` | *"Membangun, mewariskan, **melupakan**"* |

**Kedua kutub sudah hidup di dalam satu ras** — spine memperlakukannya sebagai dua tokoh.

## Kutub KETIGA — sudah kanon, tak ada di spine

Bukan "netral". Sebuah posisi utuh: **mencatat bentuk dari yang tak kau tahu, dan menolak
menamai.**

| Pemegang | Baris | Verbatim |
|---|---|---|
| **Neriah #08** | `companion_08:19` | *"Neriah meninggalkan **kosong**, dan menulis satu kata di dalam kekosongan itu: **'belum.'**"* |
| **SILENT ONE #017** | `COMPANION_BIBLE:166` | *"**MENOLAK BICARA** — dan penolakannya sendiri adalah kesaksian"* |
| **Torgrim #03** | `companion_03:26` | *"**Ia tak peduli namanya diukir. Ia peduli bangunannya berdiri.**"* |
| **Maira #06** | `companion_06:60` | *"**Kehati-hatiannya adalah bentuk lain dari pemusnahan, dan ia mulai mencurigainya.**"* |
| **CAEVAEL** | `DIVINE_BIBLE:52` | *"**Yang Absolut tidak meninggalkan jejak** … apakah ia tak ada, atau ia terlalu ada?"* |
| **~90% Ordinary People** | `B18:217-219` | *"tidak dikenang, tidak masuk Chronicle … **Dan dunia berdiri karena mereka.** Sepuluh persen sisanya tidak menopang dunia; mereka hanya **tercatat**."* |

> **Ordinary People adalah bantahan resmi kanon terhadap Nirnama** (`B18:221-223`), dan ia
> memegang posisi yang membatalkan asumsi diam-diam spine bahwa menolak-lupa = kutub berbudi.
> Di B18, **bermakna tanpa dicatat** adalah sah. §2 dan §4 belum menyediakan tempat untuk itu.

## Dan pemain sudah bisa memilih kutub lewat kelas

`ADVANCED_CLASS_DEEDS.md:66-70` — **"Necromancer adalah poros kitab ini":**

> *"**Lich** membayar apa pun agar tidak kehilangan *(dan itu adalah **Nirnama muda**)*.
> **Reaper** menerima bahwa yang berakhir memang berakhir *(dan itu adalah **tesis Aetherion**)*.
> **Tak satu pun dari keduanya salah.**"*

Plus **Phantom** (`:59`) — *"Chronicle mencatatnya sebagai **peristiwa tanpa pelaku** … kau
**memilih tak dikenang**"*.

**Spine `:15` menyatakan jawaban pemain muncul HANYA dari akumulasi ingat/lupa/limpah.
Gerbang kelas sudah mengodekannya lebih dulu.**

---

# 🟡 K8 — PERTANYAAN DRAMATIK PUNYA TIGA RUMUSAN

Spine `:13` menandai rumusannya **[KANON]**. Ada tiga, dan tak ada baris yang menyatakan mana
yang mengikat:

| Rumusan | Sumber |
|---|---|
| *"Apakah sesuatu tetap layak dibangun walaupun suatu hari akan hilang?"* | `PROPOSAL:112` ← yang dipakai spine |
| *"Apakah dunia ini layak diteruskan?"* | `B18:44` |
| *"Untuk siapa kau membangun itu — kalau semuanya akan hilang juga?"* | `B18:198` — ditandai **"bunyi pertanyaannya (kanon — boleh dikutip NPC mana pun)"** |

`B18:198` satu-satunya yang menyebut dirinya bunyi kanon untuk dikutip. Perlu satu putusan.

---

# APA YANG SPINE SUDAH BENAR

Jangan hilang di antara konflik:

- **§1 pertanyaan dramatik & "Nirnama = pertanyaan bukan protagonis"** ↔ `B18:36-52` HUKUM INDUK. Tepat.
- **§2 Elyn = pembangkang Chronicle Order** ↔ `FACTION_BIBLE:157` #205. Tepat.
- **HN-1 nol villain** ↔ `B18:327-331`. Tepat.
- **HN-2 loss permanen** ↔ `B18:363` · #260. Tepat.
- **HN-5 pelupaan berjalan tanpa pemain** ↔ Chronicle bertanggal WIB nyata, `B18:316`. Tepat.
- **§6 "tak ada ending baik/buruk"** ↔ `ROADBOOK:173` *"tidak ada ending sempurna"*. Tepat.
- **§4 tangga eskalasi** — nol tabrakan kanon. Ini sumbangan asli spine yang paling kuat.
- **§5 Greenvale = tulang punggung** ↔ `REGION_ORIGINS:28`. Tepat.

---

# URUTAN YANG SAYA SARANKAN (putusan Designer + Direktur)

1. **Tutup K2 lebih dulu** — ia satu-satunya yang **sudah tayang ke pemain**. Sampai harga Elyn
   diputuskan (umur vs ingatan-terdesak; keturunan ada vs tidak), §3-III, §3-IV, §4 tangga 5,
   dan §6 semuanya berdiri di atas angka yang mungkin dicabut.
2. **Balik K1.** §2 perlu ditulis ulang, bukan ditambal: kutub INGIN-LUPA = Nirnama + Nirnama
   Cult + Heirs of Nothingness. Chronicle Order pindah ke menolak-lupa, dan skisma
   Ordo↔Elyn jadi **konflik di dalam kutub** — yang justru lebih tajam.
3. **Sambungkan K3.** §6 harus menyerap HYBRID FINAL JUDGE, 5 ending bernama, dan detak
   "membebaskan Nirnama". Metrik §6 harus tambah **Domain** dan **companion yang hidup**.
4. **Petakan K4/K5.** Lima gerakan → Act 1–4; enam tahap Elyn → slot yang jelas.
5. **K6/K7/K8** menyusul — koreksi angka, tambah pemegang kutub, pilih satu rumusan pertanyaan.

**Sampai (1)–(3) ditutup: #263–266 tidak boleh diketuk.** #263 mengunci lima gerakan yang
puncaknya (Gerakan IV) menabrak endgame terkunci; #266 mengunci Chronicle Order pada kutub
yang salah.
