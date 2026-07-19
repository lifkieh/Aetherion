# TARIKAN FINAL — sebelum spine v0.3 + ratifikasi

**2026-07-20** · read-only · **nol keputusan naratif, nol ratifikasi**.
Kutipan verbatim; komentar agent ▸.

| # | Simpul | Status |
|---|---|---|
| **1** | THREE DEATHS | 🔴 **TERKUBUR** — dan versi sederhananya sudah menyebar salah |
| **2** | LEGACY SCORE | 🟡 **DUA SISTEM, bukan satu** — dan ROADBOOK:197 mencampurnya |
| **3** | Sinkronisasi A3 | 🟢 **DUA BARIS** yang perlu disamakan, sisanya sudah benar |
| **4** | Identitas garis #267 | 🔴 **RAS CAMPURAN NOL KANON** — ini batasan terkeras, bukan lokasi |

---

# 1 — THREE DEATHS

## Tempelan verbatim — `Aetherion_blueprint_reasoning_and_design.txt:9843-9871`

Konteks sekitarnya ikut, karena ia yang menjelaskan kenapa blok ini ada:

> Tetapi:
> **Apa yang dia tinggalkan?**
> Karena seluruh dunia dibangun di atas jejak orang yang sudah tidak ada.
>
> **THE CHRONICLE**
> **THE MEMORY OF THE WORLD**
>
> Chronicle bukan buku.
> **Chronicle adalah sistem.**
> Jaringan catatan terbesar di dunia.
>
> **Dikelola oleh:**
> Chronicle Order
> Memory Keepers
> Scholar
> Archivists
>
> Tujuan: **Mengingat.**
> **Filosofi: Apa yang diingat akan hidup lebih lama.**
>
> **THE THREE DEATHS**
> Menurut Chronicle.
> **Seseorang mati tiga kali.**
>
> **Death 1 — Biological Death**
> Tubuh berhenti hidup.
>
> **Death 2 — Social Death**
> Tidak ada lagi yang menyebut namanya.
>
> **Death 3 — Historical Death**
> Tidak ada catatan bahwa ia pernah ada.
> **Inilah kematian terbesar.**
>
> **Design Reasoning**
> Sangat selaras dengan tema Aetherion.

## Status kanon: **terkubur, dan tak pernah diratifikasi**

**Nol hasil** untuk `"THREE DEATHS"` / `"Historical Death"` / `"Social Death"` di seluruh
`docs/*.md`, seluruh sheet companion, dan `Aetherion_bible/INDEX.md`. Ia hanya ada di arsip
mentah **LOCKED**, tak pernah diekstrak seperti FACTION_BIBLE (#194) atau KINGDOM_BIBLE (#211).

## 🔴 Dan versi sederhananya SUDAH menyebar — dengan makna yang bergeser

Yang menyebar adalah **"Second Death"**, model **dua** kematian, dari bagian lain arsip yang
sama (`:576-580`):

> **KETAKUTAN TERBESAR**
> Bukan kematian. **Pelupaan. Second Death.**
> **Tubuh mati. Lalu nama ikut mati.**
> Itulah yang ditakuti Nirnama.

Ia dipakai di lima tempat — dan **dua di antaranya sebenarnya menggambarkan Death 3, bukan
Death 2**:

| Dokumen | Baris | Kutipan | Sebenarnya |
|---|---|---|---|
| `NIRNAMA_BIBLE_PUBLIC` | 153 | *"tubuh boleh hidup, tapi yang dilupakan sudah mati kedua kalinya"* | Death 2 ✅ |
| `MASTER_BLUEPRINT` | 141 | *"kematian kedua (dilupakan) hanya lewat Chronicle"* | Death 2 ✅ |
| `IMPLEMENTATION_ROADBOOK` | 207 | *"**Kematian kedua = final mutlak.**"* | Death 2 ✅ |
| `DUNGEON_ORIGINS` | 48-49 | *"Nama-nama diukir di dinding. Sebagian ukiran **sudah aus** — dan itu, di dunia ini, adalah **kematian kedua**"* | ⚠ **Death 3** — catatannya yang hilang, bukan penyebutnya |
| `REGION_ORIGINS` | 56 | kota *"hilang karena **tak ada yang menuliskannya**"* (bertaut *Second Death*) | ⚠ **Death 3** — tak pernah ada catatan sama sekali |

▸ **Bukan salah tulis — konsekuensi dari model yang hilang.** Tanpa Death 3, "dilupakan" dan
"tak pernah tercatat" runtuh jadi satu kata. Padahal seluruh mekanik R1 berdiri di atas
bedanya: `strike()` = halaman **ada lalu dicoret** (Death 2). `#229.3` = *"yang tak pernah
dicatat tak meninggalkan apa-apa — **bukan entri kosong, tidak ada apa-apa**"* (Death 3).
**Otha Renn adalah Death 3. Merrit adalah Death 2.** A3 menaruh keduanya di meja yang sama
dan menyuruh pemain memilih — dan itu justru **inti** adegan itu.

▸ Tangga eskalasi §4 spine dibangun dari nol. **Kanon sudah punya tiga anak tangganya**,
bernama, terkunci, dan milik Chronicle sendiri. Keputusan Designer: pakai, atau biarkan
terkubur — tapi **jangan diputuskan tanpa tahu ia ada**.

---

# 2 — LEGACY SCORE

## Tempelan verbatim — `…design.txt:9872-9899`

> **LEGACY SCORE**
>
> **DECISION**
> Dunia diam-diam menghitung pengaruh.
> **Tetapi bukan dalam bentuk angka yang dilihat pemain.**
>
> **REASONING**
> Kita tidak ingin: `Legacy +5`
> Karena **merusak imersi**.
> Sebaliknya. **Dunia mengingat secara organik.**
>
> **Example**
> Pemain membangun jembatan.
> **20 jam kemudian.** Pedagang menggunakan jembatan itu.
> **50 jam kemudian.** Desa berkembang.
> **100 jam kemudian.** Peta resmi berubah.
> **150 jam kemudian.** Anak-anak belajar bahwa: jembatan itu dibangun oleh seseorang.
> **Mungkin nama pemain. Mungkin tidak.**

Blok berikutnya, `:9900-9910`, masih satu tarikan napas:

> **MEMORY SYSTEM — PEOPLE REMEMBER DIFFERENTLY**
> **DECISION:** Tidak semua NPC mengingat hal yang sama. **REASONING:** Manusia bias.
> **Example:** Pemain menyelamatkan kota. Penduduk: **Pahlawan.** Bangsawan: **Ancaman
> politik.** Kriminal: **Masalah baru.** Pedagang: **Peluang bisnis.**
> **Consequence:** Satu tindakan. **Banyak interpretasi.**
>
> **FALSE HISTORY — DECISION:** **Sejarah dapat salah.** REASONING: Dunia nyata juga demikian.

## 🟡 Jawaban: **DUA sistem, bukan satu.** Dan `ROADBOOK:197` mencampurnya.

**`IMPLEMENTATION_ROADBOOK:197`, verbatim:**

> - Butuh **sistem penilaian warisan** (metrik: Chronicle, Domain, companion yang hidup, orang
>   yang mengingat).

| | **LEGACY SCORE** (arsip) | **Empat metrik** (ROADBOOK:197) |
|---|---|---|
| **Kapan** | **sepanjang permainan**, terus-menerus | **sekali**, di penghakiman akhir |
| **Apa** | pengaruh yang **menyebar sendiri** — jembatan → pedagang → desa → peta → anak-anak | **keadaan** yang dibaca pada satu titik |
| **Siapa melihat** | **dunia**, lewat perubahan yang terjadi | **game**, untuk memilih satu dari lima ending |
| **Ciri khas** | *"Mungkin nama pemain. Mungkin tidak."* — pengaruh **melepas** dari namanya | metrik menyebut **pemilik**: Chronicle-**mu**, Domain-**mu** |

▸ **Keduanya tunduk pada larangan yang sama** — *"bukan dalam bentuk angka yang dilihat
pemain"* (`:9874`) adalah **leluhur D-4**, dan ia mendahuluinya. Empat metrik endgame terikat
juga.

▸ **Tapi menyamakannya akan merusak satu hal.** LEGACY SCORE punya kalimat yang tak bisa
diterjemahkan jadi metrik: **"Mungkin nama pemain. Mungkin tidak."** Warisan yang **lepas dari
namanya** justru wujud paling murni dari Ordinary People (`B18:217-219`) dan bantahan terkuat
pada Nirnama — dan ia **tak terhitung**, secara definisi. Empat metrik menghitung apa yang
masih menempel pada pemain. LEGACY SCORE menggambarkan apa yang **tak lagi** menempel.

▸ Sambungan yang belum tertulis: **World Remembers v0.6** (`PROPOSAL:106`) adalah mesin
memori NPC; **MEMORY SYSTEM / FALSE HISTORY** di atas adalah spec-nya, dan mereka
**belum pernah dikaitkan**. `FALSE HISTORY` (*"sejarah dapat salah"*) juga langsung menopang
#226 #2 (*"bukti boleh berbohong"*) tanpa pernah dirujuk.

---

# 3 — SINKRONISASI A3

## Tempelan verbatim

**`A3_TRIASE.md:150-165` — jalur SORA:**

> # 4. ADEGANNYA — jalur SORA
>
> Sora bisa menulis. Ia tidak menolak apa pun.
> Ia melihat kedua halaman. Ia mengerti. Dan ia berkata, pelan:
>
> > **"Aku bisa coba dua-duanya."**
>
> **Ia tidak bisa.** Buktinya tidak cukup. Kalau pemain mengizinkannya mencoba, ia gagal —
> dan gagal itu memakan sesuatu darinya (**#229.1: tiap halaman menguatkan kepekaannya**).
>
> Kalau pemain menghentikannya, Sora menulis satu, dan tidak bertanya kenapa.
>
> ⚠ **Ini jebakan yang benar.** Pemain yang membiarkan Sora mencoba dua-duanya sedang
> **mematahkannya sedikit lebih cepat — dengan niat baik.** Dan tidak ada yang memberitahunya.

**`A3_TRIASE.md:169-180` — HARGA:**

> # 5. HARGA — yang tidak pemain lihat **[D-2]**
>
> **Jalur Elyn:** ia menulis satu halaman untuk pemain. Dan malam itu, **ia kehilangan satu hal
> kecil dari buku-bukunya sendiri.** Pemain tidak akan pernah tahu.
>
> *(Jauh kemudian: pemain menyebutkan detail yang dulu Elyn ceritakan. Elyn berhenti sebentar.
> **"...aku tidak ingat pernah mengatakan itu."** Lalu ia menyalin lagi.)*
>
> **Jalur Sora:** ia merasakan lebih banyak, lebih jauh, lebih sering. Satu langkah lebih dekat
> ke *"Aku capek ingat."*
>
> **Jalur sendiri:** pemain kehilangan **waktu**. Berjam-jam mencari bukti ketiga.
> Dan selama itu, **bekas Otha terus membusuk.**

## Yang harus disamakan: **DUA baris. Bukan lebih.**

| | Isi A3 | vs #258/#267 | Tindakan |
|---|---|---|---|
| **(a)** | *"ia kehilangan satu hal kecil dari buku-bukunya sendiri"* | #258 lama = **ingatan terdesak**. #267 menambah **tahun elf**. | **TAMBAH**, jangan ganti — lihat catatan |
| **(b)** | harga Elyn berhenti di ingatan | #267 juga menambah **beban diwariskan ke keturunan** | **TAMBAH** satu lapis |

**Yang TIDAK perlu disentuh, dan penting untuk dikatakan:**

- **Jalur SORA** — utuh. Ongkosnya (`kepekaan menguat`) tak pernah diklaim #258/#267.
- **Jalur SENDIRI** — utuh. Ongkos = waktu + pembusukan; itu R3, bukan #258.
- **Bingkai D-2** (*"harga — yang tidak pemain lihat"*) — utuh, dan **justru bertentangan
  dengan #259** hanya di permukaan: #259 mewajibkan ongkos **Elyn** diberitahu **sebelum**
  memilih; D-2 di sini soal ongkos yang **tak pernah** pemain lihat. Keduanya bisa hidup:
  pemain diberi tahu **bahwa** Elyn membayar, tak pernah diberi tahu **apa persisnya** yang
  hilang malam itu. **Adegan "...aku tidak ingat pernah mengatakan itu" adalah pembayarannya,
  bukan pemberitahuannya.**

▸ **Catatan penting soal (a):** #267 **tidak mencabut** ingatan-terdesak. `CHRONICLE_RESTORATION_SPEC:262`
(usul asli) dan `companion_02:76-78` sama-sama mengunci ingatan sebagai ongkos, dan #267
menambahkan umur + warisan di atasnya. Jadi A3 **tidak salah** — ia **belum lengkap**.
Mengganti kalimat itu akan membuang gambar terbaik yang dimiliki mekanik ini.

---

# 4 — CONSTRAINT IDENTITAS GARIS #267

## Yang sudah ditetapkan sebelumnya

| Batasan | Sumber |
|---|---|
| **Garis BARU**, bukan realokasi Wren | `#267` + `VERIFIKASI_WREN.md` |
| **Jauh dari kartu Wren** — supaya kartu tetap kubur orang asing | `reports/SIMPUL_SPINE_V02.md` §3 |
| **Mewarisi BEBAN, bukan arsip** | `#258`/`#267`; arsip = `LEGACY PATH` butir 1–3 |

## 🔴 Batasan terkeras yang belum disebut: **RAS CAMPURAN NOL KANON**

**Pencarian menyeluruh** (`RAS_KANON.md`, `KINGDOM_BIBLE.md`, arsip mentah): **nol hasil**
untuk *campuran · half-elf · setengah elf · kawin antar-ras · pernikahan antar-ras*.

**Delapan ras ada. Percampurannya tidak pernah dibahas — sekali pun.**

▸ **Artinya:** memutuskan ras garis darah Elyn **memutuskan kanon baru untuk seluruh dunia**,
bukan cuma untuk satu tokoh. Elf murni = aman, tak membuka apa pun. Campuran = **membuka
pertanyaan ras-campuran untuk delapan ras sekaligus**, dan itu jauh lebih besar dari #267.

## Batasan lain yang mengikat

**(a) `RAS_KANON:9-14` — dua hukum yang mengikat semua ras:**

> 1. **"Races Are Cultures, Not Stats."** Ras **tidak pernah** memberi bonus stat.
> 2. **"No Race Is Monolithic."** Tiap ras punya perpecahan internal. **Tak ada ras yang
>    bersuara satu.**

▸ Garis Elyn tak boleh jadi "elf yang benar" melawan "elf yang salah". Hukum 2 melarangnya.

**(b) Arsip mentah `:4827-4847` — filosofi elf, verbatim:**

> **ELF** · Julukan: **The Long Remembering**
> Persepsi Dunia: **Manusia hidup terlalu cepat.**
> Filosofi Ras: **Apa yang terburu-buru biasanya rusak.**
> Budaya: Elf menghargai **kesabaran · seni · sejarah · pengetahuan**
> Konflik Internal: **Elf sering gagal beradaptasi terhadap perubahan.**
> **Design Reasoning: Elf bukan ras superior. Elf adalah ras yang terlalu lama mengingat.
> Kadang itu menjadi kekuatan. Kadang menjadi beban.**

▸ *"Ras yang terlalu lama mengingat… kadang menjadi beban"* — garis darah yang **mewarisi
beban ingatan** adalah tema elf yang dituliskan sendiri. **Nol tabrakan.** Ini penopang, bukan
penghalang.

**(c) `companion_02:90` — elf muda Sylvara sudah punya suara, dan ia bertentangan dengan Elyn:**

> *"Untuk apa menyimpan catatan bangsa yang mati begitu cepat? Mereka lahir dan hilang sebelum
> kita sempat menghafal namanya."* — *"Ini bukan kejahatan; ini **budaya** … diucapkan dengan
> sopan, di meja rapat, oleh orang-orang baik."*

▸ Garis Elyn lahir **ke dalam budaya yang menolak pekerjaan leluhurnya.** Itu konflik siap
pakai — dan `RAS_KANON:20` (*"yang ingin melupakan agar bisa hidup vs yang menolak melupakan
apa pun"*) mengizinkannya persis.

**(d) Geografi:** `companion_02:72` menempatkan Elyn di **benua Sylvara**.
⚠ `RAS_KANON:39` menyatakan **"Elf ← Ancient Jungle"** sebagai wilayah asal ras, dibuka **v0.7
HORIZON**. Bukan tabrakan (tanah asal ras ≠ tempat tiap anggotanya tinggal), tapi kalau garis
Elyn diberi tanah, **dua kandidat sudah ada** dan pilihannya bermakna berbeda.

**(e) `TIME_LEGACY_SPEC:199-200` — masih terbuka, dan #267 bergerak melawannya:**

> **Elf & pewarisan:** … **Rekomendasi: tidak — ia mewariskan lewat MURID, bukan anak.**
> Itu justru memperkuat L14 (kesempatan, bukan darah).

▸ **Belum diratifikasi**, tapi ia satu-satunya baris kanon yang menyentuh pewarisan elf secara
langsung. Ia harus dicabut, dibatasi, atau didampingkan — **tak bisa diabaikan diam-diam**.

**(f) `TIME_LEGACY_SPEC:198` — companion boleh mati karena usia:**

> **Rekomendasi: ya — tapi HANYA di lompatan, dan selalu dengan adegan, tak pernah lewat
> notifikasi.**

▸ Kalau garis Elyn hendak muncul di layar, ia tunduk aturan yang sama: **lompatan + adegan**.

## Ringkas — daftar constraint untuk sesi penulisan

1. Garis **baru**, bukan Wren. *(terkunci)*
2. **Jauh** dari ruang baca — kartu Wren harus tetap kubur orang asing. *(kuat)*
3. Mewarisi **beban**, bukan arsip. *(terkunci #258/#267)*
4. **Ras: elf murni aman.** Campuran = membuka kanon baru untuk delapan ras. *(terkeras)*
5. Tak boleh jadi "elf yang benar" — `RAS_KANON` Hukum 2. *(terkunci)*
6. Tanah: **Sylvara** (tempat Elyn) vs **Ancient Jungle** (asal ras, v0.7). *(pilihan bermakna)*
7. **Darah-vs-murid harus diputus bersamaan** — `TIME_LEGACY_SPEC:199-200`. *(terbuka)*
8. Kemunculan di layar: **lompatan + adegan**, tak pernah notifikasi. *(aturan ada)*

---

**Nol keputusan naratif diambil. Nol ratifikasi.**
