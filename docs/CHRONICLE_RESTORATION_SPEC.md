# SPEC — CHRONICLE RESTORATION
## Core Loop Aetherion · Draft Designer v0.1 · menunggu ratifikasi Direktur

**Dasar kanon:** NIRNAMA_BIBLE §VI (Kekuatan: Menghapus) · §XVI (Chronicle = tokoh utama kedua) ·
§XVII (akhir tanpa menang/kalah) · §XIII (Ordinary People) · §0 (Nirnama bukan protagonis)
**Keputusan yang mengikat spec ini:** #2 (lompatan naratif) · #3 (restoration = core loop) ·
#4 (satu dunia 100% dulu — Ashbrook) · #5a (kepekaan 3 lapis) · #5b (Hukum Jalur A/B/C)
**Kode yang sudah ada dan DIPAKAI ULANG:** `Chronicle.gd` · `ForestSpiritSystem.gd` (mesin pucat) ·
`WorldState.gd` (counter) · `EventBus.gd` · `RumorSystem.gd` · `Personality.gd` · `NpcSchedule.gd`

> **Penandaan:** **[KANON]** = sudah ada di bible/kode · **[BARU]** = usul Designer, boleh ditolak per item.

---

# 0. TESIS SPEC INI

> **Aetherion bukan game tentang mengalahkan seseorang.
> Aetherion adalah perang urat saraf antara dua arsiparis.**
>
> Nirnama mencoret. Pemain menulis ulang.
> **Tidak ada yang menang. Yang kalah adalah yang berhenti menulis.**

Ini bukan metafora — ini loop-nya, harfiah. Bar HP tidak pernah muncul. Yang muncul adalah
**halaman**.

**Uji spec ini (dari §0):** setiap adegan pemulihan **harus tetap kuat andaikan Nirnama tak pernah
muncul di dalamnya.** Kalau sebuah adegan hanya kuat karena Nirnama hadir, adegan itu belum jadi.
*Nirnama nyaris tidak pernah ada di layar dalam seluruh loop ini. Itu disengaja.*

---

# 1. LOOP INTI

```
        ┌──────────────────────────────────────────────────┐
        │                                                  │
        ▼                                                  │
  ┌───────────┐                                            │
  │  KABUT    │  sesuatu hilang — tanpa pengumuman         │
  │  DATANG   │  (NPC lupa · papan nama kosong ·           │
  └─────┬─────┘   halaman tercoret · wilayah memucat)      │
        │                                                  │
        ▼                                                  │
  ┌───────────┐                                            │
  │ PEMAIN    │  BUKAN notifikasi. Pemain HARUS            │
  │ MERASAKAN │  memperhatikan. Yang tidak peduli,         │
  │           │  tidak sadar apa-apa.                      │
  └─────┬─────┘                                            │
        │                                                  │
        ▼                                                  │
  ┌───────────┐                                            │
  │ MENCARI   │  BUKTI bahwa hal itu pernah ada:           │
  │  BUKTI    │  surat di laci · orang tua yang masih      │
  │           │  ingat · fondasi yang masih berdiri ·      │
  │           │  kebiasaan yang tak bisa dijelaskan        │
  └─────┬─────┘                                            │
        │                                                  │
        ▼                                                  │
  ┌───────────┐                                            │
  │  MENULIS  │  halaman pulih. Satu ingatan kembali       │
  │   ULANG   │  ke dunia. Dunia sedikit lebih terang.     │
  └─────┬─────┘                                            │
        │                                                  │
        └──────────────────────────────────────────────────┘
                    kabut datang lagi. Selalu.
```

**Kenapa loop ini benar (uji terhadap kanon):**

| Hukum | Terpenuhi karena |
|---|---|
| §XVII: ❌ kekalahan, ❌ eksekusi, ❌ kemenangan sederhana | Tidak ada yang dikalahkan. Pemain hanya **menolak berhenti menulis**. |
| §0: Nirnama bukan pusat | Ia tidak perlu hadir. Kabut datang; ia sendiri jarang di layar. |
| §XIII: Ordinary People | Yang dipulihkan **bukan raja** — tukang roti, daftar panen, nama desa. |
| §XVI: Chronicle = lawan sejati | Chronicle **adalah** medan perangnya, bukan menu statistik. |
| §VII.1: kelemahan Nirnama | *"Jika semua akan hilang, mengapa masih ada yang tetap membangun?"* — **save file pemain adalah jawabannya.** |
| The Final Silence (§XVII) | Ending tergelap = **pemain berhenti menulis.** Bukan kalah — menyerah. Nirnama menang tanpa mengangkat tangan. |

---

# 2. EMPAT WUJUD PENGHAPUSAN — dan cara melawan tiap wujud

**[KANON — §VI]** Bible sudah menetapkan 5 wujud. Spec ini memberi tiap wujud **jalur perlawanan**.

| # | Wujud (§VI) | Yang pemain lihat | Perlawanan | Sistem yang sudah ada |
|---|---|---|---|---|
| 1 | **NPC lupa pemain** | Merrit menyapa seperti orang asing. Affinity/memori = 0. | **Bukti relasi**: tunjukkan benda yang pemain terima darinya · minta NPC ketiga bersaksi · ulangi kebiasaan yang hanya kalian berdua tahu | memori NPC v0.6, `Personality.gd` |
| 2 | **Halaman Chronicle tercoret** | Entri di UI tampil **tercoret hitam**. Data asli disimpan tersembunyi. | **Kesaksian**: cari 2–3 sumber yang masih ingat → halaman ditulis ulang | `Chronicle.gd` (`record()` sudah ada) |
| 3 | **Wilayah memutih** | Tint pucat, spawn & suara memudar | **Mengembalikan alasan tempat itu ada** (lihat §5) | `ForestSpiritSystem.gd` — **mesin pucat sudah jadi, tinggal dibalik** |
| 4 | **Nama tak terucap** | NPC tergagap saat menyebut nama. Papan nama toko kosong. | **Mengucapkan namanya keras-keras** di depan orang yang mengenalnya | `RumorSystem.gd` |
| 5 | **Yang Terhapus (The Erased)** | Siluet pucat tanpa wajah | Dikalahkan = **satu ingatan kecil pulih** | musuh baru Act 1 |

**[BARU] Aturan pengikat — HORROR PERTAMA TIDAK BOLEH DIUMUMKAN:**
> Penghapusan **pertama** yang menyentuh milik pemain **dilarang** memakai toast, banner, sfx, atau
> entri quest. **Nol teks on-screen** (konsisten #210 yang sudah kamu tegakkan di Ashbrook).
> Pemain harus menemukannya sendiri. Kalau pemain tidak memperhatikan, ia **tidak akan tahu** —
> dan itulah horor-nya.

---

# 3. HUKUM BUKTI **[BARU]** — jantung sistem

Ini bagian yang paling penting, dan yang membuat loop ini bukan sekadar "fetch quest ingatan".

> ## **Ingatan tidak bisa dipulihkan dari ingatan. Hanya dari BEKAS.**

Nirnama menghapus **ingatan**. Ia **tidak bisa** menghapus **akibat** dari sesuatu yang pernah ada.
Itulah retakan di argumennya (§XIV: *ia bisa menghapus ingatan; ia tidak bisa melihat kemungkinan*).

**Empat jenis bukti** — dan tiap jenis punya rasa yang berbeda:

| Jenis | Contoh | Kenapa lolos dari kabut |
|---|---|---|
| **BENDA** | surat · mantel pos tua · kartu pinjam Wren · lentera | Benda tidak punya ingatan untuk dihapus |
| **KEBIASAAN** | Merrit menyalakan lampu tiap malam dan **tidak tahu kenapa lagi** | Tubuh ingat setelah kepala lupa |
| **AKIBAT** | jembatan terlalu lebar untuk 40 orang · gudang gandum berisi 4 ayam | Bekas tidak bisa dicoret — hanya salah dibaca |
| **ORANG** | Sora · Nyai Tuminah · siapa pun yang cukup mencintai (Hukum #5a) | Cinta = ingatan yang tidak disimpan di kepala |

**Aturan keras:**
1. **Satu bukti tidak pernah cukup.** Minimal **dua jenis berbeda**. Satu benda + satu kesaksian.
   *(Alasan desain: memaksa pemain keluar dari satu ruangan. Ingatan itu jaringan, bukan item.)*
2. **Bukti bisa berbohong.** Kesaksian boleh bertentangan (Hukum Wonder). Dua orang ingat dua versi.
   **Pemain harus memilih versi mana yang ditulis** — dan Chronicle mencatat **pilihan pemain**,
   bukan kebenaran. *(Ini TRIASE-nya Elyn, dinaikkan jadi mekanik global.)*
3. **Halaman yang ditulis ulang tidak identik dengan aslinya.** Selalu ada yang hilang.
   **[BARU]** Entri pulih ditandai halus: *"dipulihkan dari kesaksian"* — bukan *"dipulihkan"*.
   Dunia yang diingat kembali **bukan** dunia yang sama. Itu harga. (LAW OF ERAS: Loss & Continuation.)

---

# 4. HUKUM JALUR DITERAPKAN (A / B / C) **[KANON #5b]**

Tiap penghapusan digolongkan ke salah satu:

## JALUR A — Alur Pasti (kanon)
Terjadi pada semua pemain. Tulang punggung cerita.

- **A1. Nama yang tidak pemain kenal.** Penghapusan pertama menyentuh seseorang yang pemain
  tidak peduli. Papan toko kosong. Pemain lewat begitu saja. **Ini disengaja gagal** — pemain
  melewatkannya, dan itulah pelajaran pertama.
- **A2. Seseorang yang pemain kenal melupakannya.** (Bible §IX Fase 3.) Horor personal pertama.
- **A3. TRIASE.** Dua halaman tercoret, hanya cukup waktu/bukti untuk satu. **Pilih.**
  *(Elyn melakukan ini 100 tahun lalu. Sekarang pemain melakukannya.)*

## JALUR B — Alur Pemicu (non-kanon, boleh menyamar sebagai C)
Terbuka hanya kalau pemain melakukan sesuatu spesifik. Tidak semua pemain melihatnya.

**[BARU] Contoh B yang menyamar sebagai C — sesuai izin Direktur:**

> **"Lampu yang Salah"**
> **Pemicu (tersembunyi, tidak masuk akal secara logika):** pemain menyalakan lentera di kubur tak
> bernama **7 malam berturut-turut** tanpa Sora hadir, **dan** pemain belum pernah membuka
> Aetherpedia untuk entri apa pun malam itu.
> **Yang pemain alami:** pada malam ke-7 ia merasakan sesuatu — dingin, tiba-tiba, tanpa sebab.
> Seseorang di wilayah lain baru saja terhapus. **Pemain tidak diberi tahu apa-apa.**
> **Yang pemain kira:** keberuntungan. Kebetulan. "Kok bisa ya?"
> **Yang sebenarnya:** ia baru saja melewati Lapis 2 Hukum Kepekaan (#5a) — **ia melatih dirinya
> mencintai orang asing, persis seperti Sora**, dan tidak menyadarinya.
> **Biaya tulis:** mahal. Sepadan. Ini adalah tesis game yang mendarat **tanpa satu kata pun.**

## JALUR C — Alur Luck (non-kanon, lahir dari keadaan dunia)
**[KANON #5b — putusan Direktur]** C **tidak pernah** `randf()`. C lahir dari
**cuaca × waktu × siapa yang hidup × apa yang pemain pernah lakukan.**

**Rumus wajib tiap jalur C:**
```
C terjadi bila: (keadaan langit) × (keadaan dunia) × (keadaan pemain) bertemu
                pada saat yang sama — dan tak seorang pun bisa merencanakannya.
```

**[BARU] Contoh C:**
> **"Kesaksian Hujan"**
> **Keadaan:** hujan (cuaca) × malam (waktu) × Merrit masih hidup (kehidupan) ×
> pemain pernah menginap di rumah singgah minimal sekali (jejak) × sebuah nama sedang dihapus
> **saat itu juga** (keadaan dunia).
> **Yang terjadi:** Merrit, tanpa diminta, mulai bicara tentang seseorang — dan berhenti di tengah
> kalimat karena **ia lupa siapa yang sedang ia ceritakan.** Ia tertawa kecil. *"Ah. Sudah tua."*
> **Dan pemain punya jendela pendek untuk menanyakannya** — sebelum kabut selesai bekerja.
> **Kalau pemain diam:** hilang selamanya. Tidak ada penanda. Chronicle tidak mencatat apa pun.
> **Bisa direncanakan?** Tidak. **Bisa ditunjuk sebabnya setelah terjadi?** Ya — persis
> keberuntungan sungguhan.

**Uji jalur C (mengikat penulis):**
> Kalau kamu bisa menulis `if randf() < x` untuk jalur C, jalur itu **salah**.
> C harus bisa ditunjuk sebabnya **sesudah** terjadi, dan tak bisa direncanakan **sebelum** terjadi.

---

# 5. WILAYAH MEMUTIH — memakai mesin yang SUDAH JADI

**[KANON]** `ForestSpiritSystem.gd` sudah punya seluruh mesinnya: ambang → `pale` → tint →
`PALE_SPAWN_MULT` → penebusan → pulih. **Dibalik untuk horor** (§VI.3 sudah menyebutnya).

**Perbedaan pentingnya — dan ini yang membuatnya bukan reskin:**

| | Roh Hutan (sudah ada) | Wilayah Memutih (baru) |
|---|---|---|
| Sebab | **pemain menebang** — salahmu | **tak ada yang salah** — kabut datang saja |
| Penebusan | **tanam pohon** — jelas, terukur, ada angka `debt()` | **ingat kenapa tempat ini ada** — tak ada angka |
| Rasa | rasa bersalah | **rasa kehilangan yang tak bisa ditunjuk** |
| Umpan balik | *"tanam 43 pohon lagi"* | **tidak ada.** Pemain tak pernah tahu sudah cukup atau belum |

**[BARU] Penebusan wilayah = mengembalikan ALASAN tempat itu ada.**
Contoh Ashbrook (memakai kanon #206 & #210 yang sudah kamu tulis):
> Ashbrook memutih. Yang hilang bukan bangunannya — yang hilang adalah **bahwa dulu ia kota 1.500
> jiwa.** Penduduk berhenti bisa menjelaskan kenapa jembatannya terlalu lebar. Kenapa gudang
> gandumnya sebesar itu untuk 4 ayam. Kenapa ada 40 orang di tempat yang dibangun untuk 1.500.
>
> **Perlawanan:** pemain mengumpulkan **bekas** — jembatan, gudang, fondasi rumah yang tinggal
> garis di rumput, 200 roti Halloran tiap pagi untuk 40 orang (kebiasaan yang tak lagi masuk akal).
> Lalu ia **mengatakannya kepada seseorang.** Dan orang itu mengangguk pelan: *"...oh. Iya ya."*
>
> **Tint kembali. Tanpa fanfare. Tanpa Chronicle entry.** Hanya desa yang ingat lagi bahwa ia
> pernah besar. **Itulah tesis game dalam satu mekanik** (§XIII + kanon #206).

---

# 6. EMPAT COMPANION = EMPAT PERAN MEKANIK

Ini alasan **kenapa empat ini** yang dipilih (keputusan #5). Mereka bukan cuma tema — mereka
**sistem yang saling mengunci.**

| Companion | Peran dalam loop | Hukum yang ia wujudkan |
|---|---|---|
| **SORA** — detektor | **Satu-satunya alarm.** Ia merasakan penghapusan sebelum pemain sadar. Tanpa Sora, pemain baru tahu setelah terlambat. **Bukan karena ia terpilih** — karena ia melatih dirinya mencintai orang asing (#5a Lapis 2). | §XIII · L14 |
| **ELYN** — mesin pemulihan | **Satu-satunya yang bisa menulis ulang halaman.** Bukti dibawa ke dia; ia yang memutuskan cukup atau belum. **Ia juga yang menagih harga** — *"yang dipulihkan tidak pernah sama"*. | §XVI · #119 |
| **MERRIT** — jaringan bukti | **Pos = infrastruktur ingatan.** Surat lama, tulisan tangan, catatan pos 40 tahun. Ia sumber BENDA & KEBIASAAN. **Dan ia korban paling menyakitkan** — kalau Merrit dihapus, jaringannya ikut hilang. | §XIII · Hukum Bukti |
| **ARLEN** — kaki | **Bukti tersebar; seseorang harus pergi mengambilnya.** Ia yang berjalan. **Dan inilah pintunya (L14)** — pemain menyuruhnya keluar lembah demi bukti, dan itu mengubah hidupnya tanpa pemain sadar. | L14 · Opportunity |

**[BARU] Penguncian yang indah:** keempatnya **saling butuh, dan pemain yang menyambungkan.**
Sora merasakan → Arlen pergi mengambil → Merrit tahu ke mana → Elyn menulis.
**Kalau pemain tidak merekrut satu pun, loop ini tetap jalan — cuma jauh lebih buta dan lebih lambat.**
*Dunia punya lantai kesempatannya sendiri (#184). Pemain memberi jauh lebih banyak.*

---

# 7. UI — apa yang pemain lihat

**[BARU] Aturan induk: Chronicle bukan menu. Chronicle adalah BUKU.**

| Aturan | Isi |
|---|---|
| **Tulisan tangan** | Entri tampil sebagai tulisan tangan, bukan font UI. Tanggal WIB nyata (`Chronicle.gd` sudah melakukannya: *"12 Juli 2026, 23:41"*). **[KANON #159]** |
| **Coretan** | Entri terhapus = **dicoret tinta hitam**, tidak dihapus. Pemain melihat ada sesuatu di sana. **Ia tidak bisa membacanya.** |
| **Halaman kosong** | Yang tidak pernah dicatat = **halaman kosong**, bukan "0 entries". Kekosongan harus terasa. |
| **Tanpa persentase** | ❌ *"Chronicle 47% pulih"*. Tak ada progress bar. Tak ada skor. **[§XVII: penghakiman = hitungan Chronicle, bukan angka]** |
| **Entri pulih** | ditandai halus: *"dipulihkan dari kesaksian"* + **nama saksi**. Dunia tahu siapa yang mengingat. |
| **Yang tak bisa dipulihkan** | tetap tercoret **selamanya**. Buku menyimpan luka. |

---

# 8. HARGA — kenapa ini bukan power fantasy

**[BARU]** Tanpa harga, ini jadi checklist. Empat harga:

1. **WAKTU.** Memulihkan satu halaman butuh berjam-jam nyata: mencari, bertanya, berjalan.
   Sementara itu **kabut terus bekerja di tempat lain.** Yang kamu selamatkan = yang kamu pilih.
2. **TRIASE.** (Jalur A3.) Dua halaman, cukup untuk satu. **Elyn tidak akan berkomentar apa pun.**
   Ia hanya melihat, dan mengingat, dan meletakkan pilihan pemain di laci yang sama dengan
   pilihannya sendiri seratus tahun lalu. **[KANON — sheet #002]**
3. **KETIDAKSEMPURNAAN.** Halaman pulih ≠ halaman asli. Selalu ada yang hilang.
> **➡ EKSEKUSI KONKRET:** usul §8.4 ini diserap dan diratifikasi sebagai **#258** —
> lihat **`docs/SPEC_PAYOFF_SLICE.md`**, spec build vertical-slice yang mengeksekusi
> **R1** (strike/restore) + **R5** (jalur Elyn) + **HARGA ELYN** (baris :262 di bawah)
> sebagai satu sistem ruang-ingatan dua-pemilik (#256–#261, ledger 2026-07-19).

4. **HARGA ELYN.** **[BARU — usul, butuh putusan]** Tiap kali Elyn menulis ulang halaman, ia
   memberikan **tinta dan tangan dan jam-jam malamnya**. Ia sudah kehilangan isi buku-buku yang
   terbakar (sheet #002: *"ia sedang membunuh mereka pelan-pelan"*). **Semakin banyak ia menulis
   untuk pemain, semakin cepat ia melupakan miliknya sendiri.**
   Pemain **tidak pernah diberi tahu ini.** Ia hanya, suatu hari, mendengar Elyn tidak bisa
   mengingat sesuatu yang dulu ia ingat.
   *⚠ Ini kejam. Kalau Direktur menolak, spec tetap berdiri tanpanya.*

---

# 9. THE FINAL SILENCE — bagaimana loop ini mendarat di ending

**[KANON §XVII]** Ending tergelap = *"Dunia tetap ada. Tak seorang pun mengingat apa yang pernah
dibangun."* Bukan kiamat — **kelupaan.**

**Dengan loop ini, ending itu punya sebab mekanis yang sempurna:**

> **The Final Silence = pemain berhenti menulis.**
>
> Bukan kalah. Bukan mati. **Berhenti.** Pemain memutuskan halaman ini tidak sepadan waktunya.
> Lalu halaman berikutnya. Lalu semuanya. Nirnama tidak membunuh apa pun — **dunia hanya berhenti
> mencatat.**
>
> **Dan itu gelap tanpa satu pun ledakan.** Persis seperti yang kamu tulis.

**Penghakiman akhir = hitungan Chronicle (D12).** Bukan skor. **Apa yang dunia ingat, itulah
putusannya.**

**[BARU] Dan pembebasan (§XVII) mendarat begini:**
> Nirnama tidak dikalahkan. Ia **ditunjukkan buku itu.**
> Bukan diadu argumen — **dibacakan.** Nama-nama yang tak berarti apa-apa: seorang tukang roti,
> daftar panen, sebuah desa yang pernah punya 1.500 jiwa, seorang tukang pos yang menunggu 40 tahun.
> **Semuanya ditulis ulang oleh orang-orang yang tidak istimewa, setelah ia menghapusnya.**
>
> Ia tidak berkata *"kau benar"*. **Ia hanya berhenti bertanya.**
> Karena pertanyaannya — *"untuk siapa kau membangun, kalau semuanya akan hilang?"* — baru saja
> dijawab, bukan oleh argumen, melainkan oleh **seratus orang biasa yang menolak berhenti menulis.**

---

# 10. URUTAN BANGUN (Ashbrook dulu — keputusan #4)

| Tahap | Isi | Sandaran |
|---|---|---|
| **R1** | `Chronicle.gd` + `strike(id)` & `restore(id, saksi[])`. UI coretan. **Belum ada kabut.** | `Chronicle.gd` ✅ |
| **R2** | Hukum Bukti: 4 jenis bukti sebagai data. Satu halaman uji coba di Ashbrook. | `WorldState` counter ✅ |
| **R3** | Wujud #4 (nama tak terucap) + #2 (halaman tercoret) di Ashbrook. **Nol teks on-screen.** | `RumorSystem` ✅ |
| **R4** | **Jalur A1** — penghapusan pertama yang pemain lewatkan. | R3 |
| **R5** | Elyn + mekanik menulis ulang. **Jalur A3 (TRIASE).** | R2 |
| **R6** | Sora + Lapis 2 kepekaan. Alarm pertama. | R3 |
| **R7** | **Jalur A2** — seseorang yang pemain kenal melupakannya. Merrit. | memori NPC v0.6 |
| **R8** | Wilayah memutih (Ashbrook) — mesin `ForestSpiritSystem` dibalik. | ✅ mesin sudah jadi |
| **R9** | Jalur B pertama ("Lampu yang Salah"). Jalur C pertama ("Kesaksian Hujan"). | R6, R7 |
| **R10** | Lompatan Chronicle pertama. Pemain kembali 5 tahun kemudian. **Akhir Act 1.** | #2 |

**Setelah R10: Ashbrook 100% jadi. Game bisa dimainkan, punya awal-tengah-akhir. Baru Valkaris.**

---

# 11. YANG BUTUH PUTUSAN DIREKTUR

| # | Usul | Risiko kalau ditolak |
|---|---|---|
| **D-1** | **Hukum Bukti** (§3) — minimal 2 jenis bukti berbeda; bukti boleh berbohong; halaman pulih tak pernah identik | tanpa ini, loop jadi fetch quest |
| **D-2** | **Harga Elyn** (§8.4) — menulis untuk pemain mempercepat Elyn melupakan miliknya sendiri | spec tetap berdiri tanpanya; tapi kehilangan harga terberatnya |
| **D-3** | **Nol teks on-screen untuk penghapusan pertama** — pemain boleh melewatkannya sepenuhnya | tanpa ini, horornya mati |
| **D-4** | **Tanpa progress bar Chronicle selamanya** — tak ada %, tak ada skor | melanggar §XVII kalau dilanggar |
| **D-5** | **"Lampu yang Salah"** (B menyamar C) sebagai jalur B pertama | — |
| **D-6** | **"Kesaksian Hujan"** (C dari cuaca × waktu × kehidupan) sebagai jalur C pertama | — |

---

*Dokumen ini adalah draft Designer. Setiap angka & mekanik adalah usul untuk diuji, bukan nilai
final. Tidak ada kanon yang dimundurkan; tidak ada bab bible yang diubah.*
