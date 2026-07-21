# CANON — PUTUSAN #219–#230
## Sesi Direktur × Designer, Juli 2026 · **SELURUHNYA DIRATIFIKASI**
### Untuk disisipkan ke `docs/CANON_CHANGE_LOG.md`

> **Ringkas sesi:** ditutup **lubang naratif terbesar proyek** — REPORT-03 kekosongan #2
> (*"tidak ada struktur Act"*) & #4 (*"tema kuat tapi belum ada satu mekanik yang
> MENGEKSPRESIKANNYA"*). **Aetherion sekarang punya core loop yang mengucapkan tesisnya.**
>
> **Tidak ada bab bible yang diubah · tidak ada kanon dimundurkan · tidak ada fitur GDD dipotong.**

---

# ⚖ EMPAT HUKUM INDUK BARU

> ## #219 — **Bible adalah HUKUM DUNIA. GDD adalah ISI DUNIA.**
> Semua isi boleh ada. Tak ada isi yang boleh melanggar hukum.
> Bila bertabrakan — **ISINYA yang dibengkokkan, bukan hukumnya.**

> ## #228 — **HUKUM TAGLINE: "Be yourself in another world."**
> Tak ada companion, fitur, atau sistem yang boleh menjadi **SATU-SATUNYA** jalan.
> Setiap jalur utama wajib punya minimal dua cara — dan salah satunya bisa ditempuh
> **sendirian, tanpa merekrut siapa pun.**

> ## #229 — **HUKUM KEKEJAMAN**
> Aetherion boleh **sekejam dunia nyata**. Dua jenis kekejaman diizinkan.
> **Kejam-berpenulis mahal — pakai sedikit** (saran: 1× per Act).

> ## #221 — **CHRONICLE RESTORATION = CORE LOOP**
> Nirnama mencoret. Pemain menulis ulang.
> **Tidak ada yang menang. Yang kalah adalah yang berhenti menulis.**

---

## #219 — BIBLE = HUKUM · GDD = ISI

**Sebab:** dua dokumen menuntut dua game (GDD = MMO sandbox · Bible = RPG ingatan).
**Putusan Direktur: keduanya ada** — *"pemain bebas menjadi apa yang dia mau di Aetherion."*
**Penyelesaian: bukan pemotongan — hierarki.**

**Uji 7 pertanyaan** (wajib untuk setiap fitur, selamanya) → `docs/HUKUM_KEPATUHAN_FITUR.md`

**⚠ Pelanggar terparah yang ditemukan:** `rank` **bintang 1–5** pada monster (GDD §7.2) =
**potensi yang ditampilkan** — melanggar §XIV. Ironi: `Personality.potential` dijaga test
anti-bocor, sementara monster memamerkan potensinya di UI.
**Diputus: `???` selamanya.** Nilai tetap ada di data. Pemain membaca **perilaku**, bukan UI.
*(→ langsung menjadi alasan mekanis keberadaan Maira #006.)*

**Catatan produksi (bukan kanon):** tulis kode single-player sederhana. Multiplayer = Fase 4.
Menyeret abstraksi server bertahun-tahun lebih mahal daripada menulis ulang sekali.

---

## #220 — CHRONICLE CLOCK = LOMPATAN NARATIF

**Cacat aritmetika yang ditemukan:** #165 mengunci 56 hari WIB = 1 tahun. Sheet Arlen menuntut
*"tujuh tahun, tiga lompatan"* = **392 hari nyata**. Merrit mati-usia ≈ **1.120 hari**.
NPC_DEPTH_LAWS: *"Tahun 20–40: ceiling mulai melampaui"* → **potensi baru terasa setelah ~1.120
hari nyata.** Jam & busur ditulis terpisah, tak pernah saling cek.

**Diputus:**
- Chronicle Clock 56 hari **TETAP** — untuk hal kecil (tanaman, musim, cuaca).
- **Busur hidup NPC digerakkan LOMPATAN yang ditulis tangan, bukan tick.** Satu chapter boleh
  melompat bertahun-tahun.
- **Setiap lompatan wajib berbiaya** (LAW OF ERAS). Pemain kembali — seseorang sudah tidak ada.
  **Beradegan, tak pernah notifikasi.**

Konsisten #154. Sheet companion **tidak diubah** — hanya cara membacanya: pemain tidak
*menyaksikan* Arlen menua; ia **melewati pintu**.

---

## #221 — CHRONICLE RESTORATION = CORE LOOP

**Sebab:** §XVII melarang kekalahan/eksekusi/kemenangan sederhana. §0 melarang Nirnama mendominasi
layar. **Maka pemain melakukan apa selama 300 jam sesudah reveal?** Bible bisu.

**Jawabannya sudah ada di §VI.2 & §XVI** — *"halaman bisa DIPULIHKAN lewat perlawanan"* ·
*"memulihkan satu halaman = kemenangan kecil yang terasa — jauh lebih tepat daripada bar HP"* —
**belum pernah diangkat jadi sistem. Sekarang diangkat.**

```
KABUT DATANG → PEMAIN MERASAKAN → MENCARI BUKTI → MENULIS ULANG → kabut datang lagi
```

**Menutup REPORT-03 kekosongan #4.**
**Spec:** `docs/CHRONICLE_RESTORATION_SPEC.md` · **Teknis:** `docs/R1_SPEC_TEKNIS.md`

---

## #222 — URUTAN: SATU DUNIA 100% JADI, BARU BERIKUTNYA

**Tanpa pemotongan.** 15 companion · 13 wilayah · semua fitur **tetap kanon**.
**Yang berubah: URUTAN, bukan isi.**

```
TAHUN 1–2  ASHBROOK + Greenvale — 100% JADI
           4 companion penuh · 1 lompatan · restoration loop bekerja
           → BISA DIMAINKAN. Utuh. Awal–tengah–akhir.
TAHUN 3–4  Valkaris — Torgrim + Veshka
TAHUN 5–6  Sylvara / Azhur — Maira · Kain · Seraphine · Luna
```

**Sebab (GDD Bagian 18, sudah kanon):** *"luncurkan 40% sistem dengan kedalaman 100%, bukan 100%
sistem dengan kedalaman 40%."* GAP_AUDIT sudah mendiagnosis pelanggarannya. **Ini obatnya.**

**Modal:** Ashbrook **sudah berdiri** (#216–#218, 947 test lulus). Merrit sudah menyalakan lampu
tiap malam. **Bukan mulai dari nol — berhenti mengerjakan hal lain.**

---

## #223 — COMPANION ACT 1 = EMPAT

**Merrit · Arlen · Elyn · Sora.** Sebelas sisanya = Act 2+.

**Sebab — sistem tematik tertutup, bukan 4 yang termurah:**

| | Menolak melupakan | Statusnya |
|---|---|---|
| **Merrit** | satu orang | menunggu 40 tahun |
| **Sora** | orang asing | tak ada yang memintanya |
| **Elyn** | orang tak penting | **pernah gagal sekali** |
| **Arlen** | — | **dialah yang akan dilupakan bila tak ada yang membuka pintu** |

**Tiga penjaga ingatan dan satu orang yang butuh diingat.** Seluruh tesis dari 4 orang di 2 lokasi.

**Peran mekanik (#221):** Sora = **detektor** · Elyn = **mesin pemulihan** · Merrit = **jaringan
bukti** · Arlen = **kaki**. Saling mengunci; **pemain yang menyambungkan.** Tanpa mereka loop tetap
jalan — lebih buta, lebih lambat (lantai kesempatan #184, dan **#228**).

---

## #224 — HUKUM KEPEKAAN — TIGA LAPIS *(mengunci NO DESTINY)*

**Masalah yang ditutup:** Sora = satu-satunya di dunia yang bisa merasakan penghapusan. Melarangnya
menang (*"saksi, bukan pahlawan"*) **tidak menghapus keunikan kosmiknya** — itu Chosen One berlabel
lain. Preseden Luna #10 berarti **dua** Chosen One, bukan pembelaan.

| Lapis | Hukum | Siapa |
|---|---|---|
| **1 — PASTI** | **Siapa pun yang cukup mencintai seseorang akan merasakan lubangnya bila orang itu dihapus.** Bukan bakat — **akibat dari mencintai.** | Nyai Tuminah · Merrit · siapa pun |
| **2 — PEMICU** | Merasakan penghapusan atas **orang tak dikenal** — dicapai lewat **PRAKTIK**. Sora bisa **karena bertahun-tahun menyalakan lampu untuk orang asing.** Kepekaan = **hasil, bukan bakat.** | Sora — **dan PEMAIN** |
| **3 — LUCK** | Sebagian merasakannya **tanpa sebab apa pun.** Tak bisa dicari, tak bisa dijelaskan. | Luna Vesper |

Konsisten hukum induk: *"Legendary bukan SIFAT. Legendary adalah HASIL."*

**Konsekuensi terkuat: Lapis 2 terbuka untuk pemain.** Yang repot mencintai orang asing **mulai
merasakannya juga.** Yang tidak repot: dunia memutih di sekitarnya dan **ia tidak tahu.**

**⛔ Sheet #013:** Sora **tidak boleh tahu** ini hasil kerjanya sendiri. Kalimat *"Ini mungkin
berkah. Ini mungkin penyakit"* **dipertahankan.** Pemain yang menyadarinya sendiri.

---

## #225 — HUKUM JALUR: A / B / C

| | Jenis | Status | Sifat |
|---|---|---|---|
| **A** | **Alur Pasti** | **KANON** | pasti terjadi; semua pemain melihatnya; tulang punggung |
| **B** | **Alur Pemicu** | **NON-KANON** | butuh perbuatan spesifik; **BOLEH MENYAMAR SEBAGAI C** |
| **C** | **Alur Luck** | **NON-KANON** | lahir dari **keadaan dunia** |

> ### ⛔ HUKUM JALUR C
> **C tidak pernah `randf()` telanjang.** C lahir dari
> `cuaca × waktu × siapa yang hidup × apa yang pemain pernah lakukan`.
>
> **Uji:** kalau penulis bisa menulis `if randf() < x` untuk sebuah jalur C — **jalur itu salah.**
> C harus bisa **ditunjuk sebabnya SESUDAH terjadi**, dan **tak bisa direncanakan SEBELUM terjadi.**
> *Persis keberuntungan sungguhan.*

**Non-kanon:** dunia tetap utuh tanpanya. Cerita tidak bolong bila pemain tak menemukannya.
**Preseden:** Hidden Scenario (GDD v0.2 §8.2) sudah melakukan ini sejak v0.2.

---

## #226 — HUKUM BUKTI

> ## **Ingatan tidak bisa dipulihkan dari ingatan. Hanya dari BEKAS.**

Nirnama menghapus **ingatan**. Ia **tidak bisa** menghapus **akibat**.
**Itulah retakan di argumennya** (§XIV: *ia bisa menghapus ingatan; ia tidak bisa melihat kemungkinan*).

| `kind` | Kenapa lolos dari kabut | Contoh Ashbrook |
|---|---|---|
| **`benda`** | benda tak punya ingatan untuk dihapus | surat Merrit · kartu pinjam Wren |
| **`kebiasaan`** | tubuh ingat setelah kepala lupa | Halloran memanggang 200 roti untuk 40 orang |
| **`akibat`** | bekas tak bisa dicoret — hanya salah dibaca | jembatan terlalu lebar · gudang gandum 4 ayam |
| **`orang`** | mencintai = ingatan yang tak disimpan di kepala (#224) | Sora · Nyai Tuminah |

**Tiga aturan keras:**
1. **Minimal dua `kind` BERBEDA.** *(Ingatan itu jaringan, bukan item.)*
2. **Bukti boleh berbohong.** Kesaksian boleh bertentangan. **Chronicle mencatat pilihan pemain,
   bukan kebenaran.** *(TRIASE Elyn → mekanik global.)*
3. **Halaman yang ditulis ulang TIDAK PERNAH identik.** `loss` ditentukan oleh **jenis bukti yang
   TIDAK pemain bawa.**

---

## #227 — DUA JALUR PERTAMA

**"Lampu yang Salah"** *(B menyamar C)* — lentera di kubur tak bernama **7 malam berturut-turut
tanpa Sora**. Malam ke-7 pemain merasakan sesuatu. **Ia mengira keberuntungan.** Sebenarnya: ia
melewati **#224 Lapis 2** — melatih dirinya mencintai orang asing, persis Sora, tanpa sadar.

**"Kesaksian Hujan"** *(C dari keadaan dunia)* — `hujan × malam × Merrit hidup × pemain pernah
menginap × sebuah nama sedang dihapus`. Merrit bercerita, lalu **berhenti di tengah kalimat karena
lupa siapa yang ia ceritakan.** *"Ah. Sudah tua."* **Diam = hilang selamanya, tanpa penanda.**

---

## #228 — HUKUM TAGLINE **[BARU — hukum induk]**

> ### **"BE YOURSELF IN ANOTHER WORLD"**
>
> **Tak ada companion, fitur, atau sistem yang boleh menjadi SATU-SATUNYA jalan.**
> Setiap jalur utama wajib punya **minimal dua cara** — dan salah satunya bisa ditempuh
> **sendirian, tanpa merekrut siapa pun.**
>
> Jalan sendirian boleh **lebih mahal, lebih lama, lebih jelek hasilnya.**
> Ia **tidak boleh mustahil.**
>
> **Uji:** bila pemain yang tak merekrut siapa pun terkunci dari cerita utama —
> **hukum ini mati, dan tagline-nya bohong.**

**Kenapa ini hukum induk, bukan fitur:** seluruh bible sudah menegakkannya tanpa pernah menamainya.
NO DESTINY (§0) = *kamu tak bisa jadi dirimu sendiri bila dunia sudah memutuskan siapa kamu.*
§XIV = *kalau tak ada yang tahu masa depanmu, kamu boleh jadi apa saja.*
§XIII = *kamu boleh jadi orang biasa. Itu sah.*
Hukum Kemauan NPC = **tagline yang berlaku dua arah — NPC juga boleh jadi diri mereka sendiri.**

> **Dan Sang Nirnama adalah tagline yang GAGAL** — ribuan tahun jadi pahlawan, pendiri, penyelamat,
> sampai tak ada lagi "dirinya" di bawah semua itu. §XVII: pemain membebaskannya **sehingga ia boleh
> berhenti.** Boleh jadi bukan siapa-siapa lagi.
> **Pemain adalah tagline yang masih punya kesempatan.**

### Turunan: TIGA JALUR PEMULIHAN (menutup D-2)

| | **ELYN** | **SENDIRI** | **SORA** |
|---|---|---|---|
| **Syarat** | rekrut Elyn | **tak ada — selalu tersedia** | rekrut Sora |
| **Bukti** | 2 jenis | **3 jenis** | 2 jenis |
| **`loss`** | paling sedikit | **paling besar** | sedang |
| **Harga** | **Elyn melupakan bukunya sendiri** | **waktumu** | **Sora menanggungnya** |
| **Tulisan di buku** | tangan Elyn, rapi | **tanganmu sendiri** — berantakan, kadang salah eja | tangan anak-anak, hati-hati sekali |

**Jalur SENDIRI bukan hukuman — ia pernyataan tesis paling telanjang:**
*kamu tidak butuh ahli untuk menolak melupakan seseorang. Kamu cuma butuh **repot**.*
Halaman tampil dengan tulisan tangan pemain. Nama kadang salah eja. Tanggal kadang meleset setahun.
**Dan itu tetap sah. Dunia mengingat versi pemain.** (§XIII)

---

## #229 — HUKUM KEKEJAMAN **[BARU — hukum induk]**

> **Aetherion boleh sekejam dunia nyata. Dua jenis kekejaman diizinkan.**

| Jenis | Sifat | Aturan |
|---|---|---|
| **Kejam-cuaca** | tidak punya penulis. *"Dunia hanya tidak sedang memperhatikan"* (sheet Maira) | **default.** Sebagian besar kekejaman Aetherion harus jenis ini |
| **Kejam-berpenulis** | tangan penulis terasa | **diizinkan — tapi MAHAL.** Saran: **1× per Act** |

**Kenapa kejam-berpenulis dibatasi (saran Designer, bukan larangan):** bila tiap adegan punya tangan
penulis, pemain berhenti percaya dunia dan mulai menebak naskah. Kekuatan Aetherion justru bahwa
**kebanyakan kekejamannya tidak punya siapa-siapa untuk disalahkan.** Yang satu itu jadi jauh lebih
keras justru karena sekelilingnya tidak.

**Kalibrasi kejam-cuaca (kanon sheet #006):**
> *"kawanan yang ia selamatkan memakan kulit pohonnya. Ia mati karena yang ia lindungi.
> **Dan ini bukan fabel. Tidak ada pelajarannya.** Dunia tidak sedang menghukumnya karena naif;
> **dunia hanya tidak sedang memperhatikan.**"*

### Turunan yang diratifikasi

**1. HARGA SORA.** Tiap halaman yang ia tulis **menguatkan kepekaannya** (#224 Lapis 2). Ia mulai
merasakan terlalu jauh, terlalu banyak. Pemain tak diberi tahu. Yang ia lihat: Sora makin sering
tak tidur, lalu berhenti bicara, lalu tangannya gemetar — **dan ia tetap menulis, karena Sora tak
pernah menolak.** Bila pemain terus:
> Sora, 19 tahun. Lenteranya mati. Ia tidak menyalakannya.
> **"Aku capek ingat."**
>
> *Kalimat Nirnama, diucapkan anak yang paling menolak jadi Nirnama.*

Sheet #013 sudah menyiapkannya: *"Ia tak akan menjadi Nirnama — tapi ia akan mengerti Nirnama,
dan itu lebih menyayat."* **Pemain melakukannya. Dengan niat baik. Sambil menyelamatkan orang.**

**2. MERRIT MATI SEBELUM SURATNYA TERPECAHKAN.** Kematiannya **tidak menunggu pemain**. Ia mati di
lompatan, saat pemain mengurus hal lain. Pemain kembali ke rumah yang **lampunya sudah padam** —
bukan cutscene, bukan pemberitahuan. **Lampunya cuma tidak menyala lagi.**
Suratnya masuk Chronicle sebagai *"Surat yang Tak Pernah Dibuka"* — **dan tidak bisa dibuka.**
Bukan karena terkunci. **Karena orang yang berhak membukanya sudah tidak ada, dan pemain bukan
orang itu.**

**3. PEMAIN MENGHAPUS DENGAN TIDAK PEDULI.** *(Bukan membunuh.)*
Pemain tak pernah bicara dengan seorang NPC, tak pernah tanya namanya. Lompatan. NPC mati wajar.
**Chronicle tidak mencatat apa-apa.** Bukan entri kosong — **tidak ada apa-apa.**
> **Nirnama menghapus dengan kabut — perlu kekuatan ribuan tahun.
> Pemain menghapus dengan punya urusan lain.**
> Jauh lebih mudah. Jauh lebih biasa. **Hasilnya sama persis.**

Kanon sheet #001 sudah menuliskannya: *"Chronicle tidak mencatat apa-apa tentangnya.
**Dan ketiadaan catatan itu adalah dakwaannya.**"*

**4. TIDAK SEMUA KABUT DATANG DARI NIRNAMA.** Sebagian penghapusan **bukan Nirnama sama sekali** —
cuma orang tua yang mati, toko yang tutup, desa yang mengecil, waktu.
**Pemain tidak akan pernah bisa membedakan.**
Kanon sheet #002 sudah menguncinya: *"Seorang pemain **boleh** curiga sebaliknya. Seorang pemain
**boleh** salah. Biarkan kecurigaan itu hidup dan **jangan pernah menjawabnya, ke arah mana pun.**
**Kengerian terbesar penghapusan adalah bahwa ia tak bisa dibedakan dari kelupaan biasa.**"*
> **Musuhnya berhenti jadi musuh. Musuhnya jadi dunia. Dan dunia tidak berhenti.**
> *(§0 mendarat: Nirnama bahkan tidak bertanggung jawab atas semua yang pemain salahkan padanya.)*

---

## #230 — CHRONICLE = SATU BUKU, DUA JENIS HALAMAN

**Masalah yang ditutup:** `Chronicle.gd` hari ini mencatat **pencapaian** (boss, first-clear).
Tapi §XIII bilang *"Chronicle menghormati yang biasa — dan Chronicle-lah yang membantah argumennya,
bukan pedang."*
**Chronicle yang cuma mencatat boss kill tidak membantah Nirnama — ia SETUJU dengannya:
cuma yang hebat yang layak dicatat.**

**`Chronicle.gd` TIDAK diganti. Ia diperluas.**

| Jenis | Isi | Yang menulis | Bisa dicoret? |
|---|---|---|---|
| **PENCAPAIAN** *(sudah ada ✅)* | first-clear, boss, skenario | sistem, otomatis | ya |
| **ORANG** *(baru)* | *"Otha Renn, penjahit, tiga puluh empat tahun"* | **harus ada yang repot** — pemain/Elyn/Sora | ya |

**Keduanya di buku yang sama, urut tanggal WIB.** Boss kill di sebelah penjahit.

> **Dan itu tepat maksudnya.** Buku itu **tidak menghakimi** (§XVI). Ia tidak tahu mana yang penting.
> Ia cuma mencatat apa yang ada.
>
> **Pemain yang lihat bedanya.** Suatu hari ia buka buku, melihat *"Ancient Dragon dikalahkan"*
> di sebelah *"Otha Renn, penjahit"* — **dan sadar yang kedua lebih sulit didapat.**
> **Karena boss kill datang sendiri. Otha butuh seseorang yang repot.**

### D-4 — CHRONICLE TIDAK PERNAH PUNYA ANGKA *(diratifikasi)*

⛔ **DILARANG:** persen penyelesaian · hitungan (23/49) · sisa tercoret · badge/notif ·
sortir "belum pulih" · completion % di menu/save/ending.
**Intinya: apa pun yang bisa dipakai pemain untuk tahu "tinggal berapa lagi".**

**Tiga alasan:**
1. **Angka bikin pemain berhenti melihat orang.** Merrit jadi **3%**. Otha jadi **satu centang**.
2. **Angka itu bohong.** Berapa penyebutnya? Otha tak pernah punya halaman. *"49 total"* berbohong —
   ada ribuan yang tak masuk hitungan. **Persen hanya bisa menghitung yang sudah tercatat.
   Yang tidak pernah tercatat justru inti masalahnya.**
3. **Menghitung ADALAH kesalahan Nirnama** (§XIII: *"Kekeliruannya pada SKALANYA"*).
   **Progress bar mengajari pemain berpikir seperti Nirnama.**

**100% mustahil, dan itu tokohnya:** Elyn bangun tiap pagi mengerjakan sesuatu yang **matematis
mustahil**. Kalau ada 100%, Elyn cuma pemalas yang belum kelar.
**Tidak ada yang pernah selesai mengingat.**

**Penghakiman akhir (§XVII):** Chronicle "dihitung" **sekali** — di adegan terakhir, oleh dunia,
**bukan oleh UI**. Bentuknya: **buku itu dibacakan.** Bukunya tipis → adegan pendek. Tebal → panjang.
**Pemain merasakan bobotnya lewat berapa lama pembacaan berlangsung.**
Bukunya kosong → **The Final Silence.** Tak ada yang dibacakan, karena tak ada yang ditulis.

**Pengganti angka:** buku yang menebal · coretan yang tetap hitam selamanya · halaman kosong yang
terasa kosong.
**Uji:** bila pemain bisa **menyortir** halaman berdasarkan yang belum ia pulihkan — **D-4 mati.**

---

## D-3 — NOL TEKS UNTUK PENGHAPUSAN PERTAMA *(diratifikasi)*

Penghapusan pertama **dilarang** memakai toast · banner · stinger · musik · cutscene · entri quest ·
penanda peta. **Pemain boleh melewatkannya seumur hidup dan tidak pernah tahu.**

**Preseden — sudah kamu lakukan dan berhasil:** #210 (*"NOL teks on-screen di Ashbrook"*, dijaga
mesin) · #216 (*"White Stag 0,5% — tanpa trigger/marker/musik/toast/Chronicle, dijaga test"*).
**D-3 cuma menerapkan hukum yang sama pada kabut.**

**Bukan simulasi penghapusan — penghapusan yang sungguhan terjadi, pada pemain.**
**Pengaman:** A1 memang dirancang untuk dilewatkan. A2 (seseorang yang pemain kenal melupakannya)
tidak bisa dilewatkan.

**Dikodekan lewat test, bukan disiplin:** `_test_strike_is_silent()` · `_test_a1_is_silent()` ·
`_test_no_chronicle_score()`. **Gagal test = gagal build.**

---

# 📄 DOKUMEN BARU SESI INI

| Berkas | Isi |
|---|---|
| `docs/CHRONICLE_RESTORATION_SPEC.md` | core loop · 5 wujud penghapusan · Hukum Bukti · jalur A/B/C · peran 4 companion · UI · harga · urutan R1–R10 |
| `docs/R1_SPEC_TEKNIS.md` | `strike()` · `restore()` · struktur data · 8 test wajib · migrasi save |
| `docs/A1_PENGHAPUSAN_PERTAMA.md` | adegan Jalur A pertama — Toko Kain Otha. **Nol dialog.** |
| `docs/HUKUM_KEPATUHAN_FITUR.md` | uji 7 pertanyaan · versi patuh seluruh fitur GDD |

# ✍ SUNTINGAN DOKUMEN LAMA

| Berkas | Suntingan |
|---|---|
| `CLAUDE.md` | + **#219** · **#228** · **#229** (3 baris hukum induk) |
| `NPC_DEPTH_LAWS.md` | + **#224** sebagai Hukum ke-9 |
| `Companion_bible/companion_13_sora_lanternwick.md` | + ratifikasi **#224** & **harga Sora (#229)** · **pertahankan** *"mungkin berkah, mungkin penyakit"* |
| `Companion_bible/companion_02_elyn_thornewood.md` | + **tiga jalur pemulihan (#228)** — Elyn bukan satu-satunya |
| `Companion_bible/companion_11_merrit_fane.md` | + **#229.2** — mati sebelum terpecahkan; surat tak bisa dibuka |
| `NIRNAMA_BIBLE.md` §VI | + rujukan **#221** · + **#229.4** (tidak semua kabut darinya) |
| `docs/Monster_Roster_Launch.md` | ⚠ **bintang 1–5 → `???`** (#219 — pelanggar terparah §XIV) |
| `STATUS.md` | + ringkas #219–#230 |

---

> ## KALIMAT PENUTUP SESI
>
> **Aetherion tidak mengalahkan Sang Nirnama. Sang Nirnama tidak mengalahkan Aetherion.**
> **Dunia hanya memilih jawaban yang berbeda — lalu terus membangun.**
>
> Dan sekarang, untuk pertama kalinya, **ada mekaniknya**:
> seseorang membuka buku, mencelupkan pena, dan menulis nama seorang penjahit
> yang tidak pernah cukup penting untuk dicatat.
>
> *Be yourself in another world.*
