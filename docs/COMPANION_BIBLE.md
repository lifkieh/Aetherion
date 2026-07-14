# COMPANION BIBLE — Aetherion *(dokumen induk & indeks)*

**Status:** DIMULAI (B17, gerbang v0.5). **Progres: 15 / 50 Great Companion.** *(Gelombang 2 TERKUNCI — #190.)*
**Sumber kanon:** `docs/Aetherion_blueprint_reasoning_and_design.txt` (FILE 05 Companion
Philosophy; FILE 13 Companion Bible Part 02). Dikanonisasi 2026-07-13 (Decision Log G3 / #104).

> ### 📁 SHEET TOKOH PINDAH KE `docs/Companion_bible/` (#189)
> Dokumen ini **tidak lagi memuat sheet**. Ia memuat **hukum, kuota, indeks, dan konsistensi
> silang**. Setiap tokoh kini punya **berkasnya sendiri, detail-penuh** (~80 baris, 16 bagian) —
> mengikuti patokan yang ditulis Direktur sendiri: **`companion_11_merrit_fane.md`**.
>
> **Alasannya:** kedalaman karakter tak muat dalam tujuh baris bullet. Yang membuat companion
> terasa hidup bukan daftar stat — melainkan **konflik internal, ketakutan, kesempatan yang
> tak pernah datang, dan apa yang tersisa setelah ia mati.**

> ⚠ **SPEC-ONLY.** Tidak ada kode yang dibangun atas dokumen ini. **B17 baru terbuka bagi v0.5
> setelah 50 tokoh lengkap.**

---

## Hukum Companion (dari FILE 05 — mengikat)

1. **Setiap Companion adalah protagonis dari hidupnya sendiri.** Ia bukan follower, bukan pet,
   bukan alat combat.
2. **Companion bukan hadiah.** Tidak direkrut hanya karena dikalahkan, dibayar, atau
   diselesaikan quest-nya. **REKRUTMEN BUKAN MENU** (#122) — dilarang UI `Rekrut? [Y/N]`.
3. **Tidak semua Companion harus menyukai pemain.** Beberapa boleh **menolak**. Beberapa boleh
   menjadi **musuh** — dan itu **disengaja**.
4. **Companion tidak boleh terkumpul** seperti koleksi. Kekuatannya tidak ditentukan kelangkaannya.
5. **Companion berubah tanpa pemain** (Life Events, relasi antar-companion, kematian & reaksi
   berantai). Mereka punya relasi satu sama lain **yang tak melibatkanmu**.
6. **HUKUM KEMAUAN NPC (#179):** *"The player influences lives. The player does not own them."*
   Pemain **tidak** mengontrol Effort. Yang pemain ubah adalah **Opportunity** — *jumlah pintu
   yang terbuka*.
7. **ECHO ≠ ORIGIN.** Companion boleh **bergema** dengan tema Sang Nirnama (menunggu, melupakan,
   kehilangan) — tetapi **DILARANG** menjadi sebab, akibat, atau petunjuk plot menuju Nirnama.
   *Luka yang sama tumbuh di mana-mana, pada orang-orang biasa yang tak pernah saling bertemu.
   Itulah yang membuat pertanyaan Nirnama terasa universal tanpa menjadikan semua orang bidaknya.*

---

## Framework 8 Kategori (kuota resmi — total 50)

| # | Kategori | Isi | Kuota |
|---|---|---|---|
| 01 | **Explorers** | Orang yang mengubah peta dunia (pulau baru, reruntuhan, jalur dagang) | 6–8 |
| 02 | **Warriors** | Jenderal, ksatria, pemburu monster | 6–8 |
| 03 | **Scholars** | Ilmuwan, sejarawan, pencipta teknologi, peneliti sihir | 6–8 |
| 04 | **Leaders** | Raja, pemimpin kota, pemimpin faksi | 6–8 |
| 05 | **Reformers** | Pengubah masyarakat (penghapus perbudakan, pendiri sekolah, pembaru hukum) | 4–6 |
| 06 | **Outsiders** | Kriminal, penyelundup, bandit, penipu | 4–6 |
| 07 | **Mystics** | Peramal, penafsir mimpi, pencari kebenaran | 4–6 |
| 08 | **Wild Cards** | Tak terkategori: kolektor monster, petani, penyair, tukang roti — yang suatu hari mengubah dunia | 4–6 |

**Alasan kanon:** *"Sejarah tidak hanya dibentuk pedang. Kadang sejarah berubah karena buku,
lagu, atau seseorang yang menolak pergi."*

---

## INDEKS TOKOH — `docs/Companion_bible/`

> **✅ LOKASI TERPETAKAN (Q2/Q3, #109/#110):** lembah = **Greenhollow Valley**; kota utama tetap
> **Greenvale**; **Ashbrook** = desa kecil dekat Greenvale (**konten beku** sampai Companion pass
> v0.5/0.6). Sylvara = **benua Sylvara**; Thalassar (laut resmi, #90) ⊂ **benua Azhur**. Semua
> wilayah yang sudah dibangun ada di benua **Eldoria**. *(Pemetaan #110 masih **draft yang bisa
> diveto**.)*

| # | Nama | Julukan | Ras | Kategori | **Potensi (tersembunyi)** | Berkas |
|---|---|---|---|---|---|---|
| 001 | **Arlen Vale** | *The Boy Who Wanted The Horizon* | Human | Explorers | **340** · berbakat | `companion_01_arlen_vale.md` |
| 002 | **Elyn Thornewood** | *The Keeper of Forgotten Books* | Elf | Scholars | **690** · elite | `companion_02_elyn_thornewood.md` |
| 003 | **Torgrim Ironvein** | *The Last Great Builder* | Dwarf | Leaders/Reformers | **610** · elite | `companion_03_torgrim_ironvein.md` |
| 004 | **Seraphine Voss** | *The Woman Who Heard The Stars* | Astralborn | Mystics | **830** · jenius | `companion_04_seraphine_voss.md` |
| 005 | **Kain Blacktide** | *The Smiling Smuggler* | Human | Outsiders | **260** · berbakat | `companion_05_kain_blacktide.md` |
| 006 | **Maira Willowstep** | *The Monster Shepherd* | Dryad | Wild Cards | **940** · jenius | `companion_06_maira_willowstep.md` |
| 007 | **Varko Drenn** | *The Fool Who Challenged Death* | Human | Warriors | **120** · **mayoritas** | `companion_07_varko_drenn.md` |
| 008 | **Neriah Saltwind** | *The Cartographer of Impossible Seas* | Tidekin | Explorers | **480** · elite | `companion_08_neriah_saltwind.md` |
| 009 | **Cael Morrow** | *The Nameless Knight* | Human | Warriors/Mystics | **`???` — TAK TERBACA** | `companion_09_cael_morrow.md` |
| 010 | **Luna Vesper** | *The Child Who Remembered Tomorrow* | Shadeborn | Mystics | **1150** · **fenomena** | `companion_10_luna_vesper.md` |
| 011 | **Merrit Fane** | *Yang Menunggu Surat Balasan* | Human | Wild Cards | **110** · **mayoritas** | `companion_11_merrit_fane.md` |
| 012 | **Veshka Ironvein** | *(lihat berkas)* | Dwarf | — | **620** · elite | `companion_12_veshka_ironvein.md` |
| 013 | **Sora Lanternwick** | *(lihat berkas)* | — | — | **780** · jenius | `companion_13_sora_lanternwick.md` |
| 014 | **Dr. Halen Vosk** | *Tabib yang Menyembuhkan Semua Kecuali Satu* | Astralborn | **Scholars** (#195) | **850** · jenius | `companion_14_halen_vosk.md` |
| 015 | **Kessler Dray** | *Jenderal yang Menolak Perang Berikutnya* | Beastfolk *(wolfkin)* | **REFORMERS** (#195) | **700** · elite/jenius | `companion_15_kessler_dray.md` |

> **#014 & #015 = versi FINAL Direktur** (menimpa total draf agent). **DIRATIFIKASI kanon (#190).**
> ✅ **KATEGORI DITETAPKAN (#195):** **Halen = SCHOLARS** · **Kessler = REFORMERS** — *"jenderal yang
> menolak perang berikutnya"* adalah definisi Reformer, dan **kuota Reformers yang selama ini NOL
> akhirnya terisi (1/4–6).**

### ⚠ Cael Morrow (#009) — potensinya TIDAK TERBACA
Satu-satunya tokoh yang **Item Penglihat Potensi pun gagal membaca**. **Jangan dijelaskan.**
Ia juga **kandidat** identitas humanoid **The Last Witness** — **Q7 BELUM DIPUTUS**, dilindungi
**MISTERI_ABADI M5**. Sheet-nya ditulis agar **tetap utuh pada kedua kemungkinan**.

---

## SEBARAN POTENSI — dan mengapa ia begini

**Hukum 8 (Ordinary People) berlaku bahkan untuk Great Companion.** Roster yang semua anggotanya
berpotensi jenius adalah **roster yang berbohong** — dan kebohongan itu **memenangkan Nirnama**
(kalau hanya yang hebat yang berarti, maka yang biasa **pantas** dilupakan).

| Lapis | Tokoh |
|---|---|
| **Mayoritas (50–150)** | **Varko (120)** · **Merrit (110)** |
| **Berbakat (150–400)** | Kain (260) · Arlen (340) |
| **Elite (400–700)** | Neriah (480) · Torgrim (610) · Veshka (620) · Elyn (690) · **Kessler (700)** |
| **Jenius (700–1000)** | Sora (780) · Seraphine (830) · **Halen (850)** · Maira (940) |
| **Fenomena (1000+)** | **Luna (1150)** |
| **Tak terbaca** | **Cael (`???`)** — Item Penglihat pun gagal |

**Sebaran 15 tokoh: 2 mayoritas · 2 berbakat · 5 elite · 4 jenius · 1 fenomena · 1 tak terbaca.**
*Terverifikasi patuh skala K2 (#185).*

**Tiga pernyataan desain yang disengaja:**
1. **Varko (120)** — pemberani yang **tidak punya apa-apa selain nyali**, dan hidup karena
   keberuntungan yang absurd. *Jangan pernah "diselamatkan" dengan twist bahwa ia ternyata berbakat.*
2. **Arlen (340)** — tokoh yang **mewakili pemain** justru **tidak dijamin** menjadi legenda.
3. **Luna (1150) & Sora (780)** — potensi tertinggi ada pada **seorang anak** dan **seorang yatim**,
   keduanya **tanpa satu pun pintu terbuka**. *Pemain memegang pintunya.* **Itulah L14, telanjang.**

---

## Sisa pekerjaan B17 (35 tokoh) — **arahan gelombang 3–4 (#193)**

| Kategori | Kuota | Terisi | Sisa | Catatan |
|---|---|---|---|---|
| **Explorers** | 6–8 | 2 (Arlen, Neriah) | **4–6** | ⚠ **masih tipis — prioritas gelombang 3** |
| Warriors | 6–8 | 1–2 (Varko, Cael?) | 4–7 | |
| Scholars | 6–8 | **2** (Elyn, **Halen**) | 4–6 | |
| **Leaders** | 6–8 | 1 (Torgrim?) | **5–7** | ⚠ **masih tipis — prioritas gelombang 3** |
| **Reformers** | 4–6 | **1** (**Kessler**) | **3–5** | ✅ kuota **tidak lagi NOL** (#195) |
| Outsiders | 4–6 | 1 (Kain) | 3–5 | |
| Mystics | 4–6 | 2–3 (Seraphine, Luna, Cael?) | 1–4 | |
| Wild Cards | 4–6 | 3 (Maira, Merrit, Sora?) | 1–3 | |

### ⚠ KETIMPANGAN RAS (gelombang 3–4 wajib menutupinya)

| Ras | Terisi | Catatan |
|---|---|---|
| **Human** | 5 (Arlen, Kain, Varko, Cael, Merrit) | **terlalu dominan** |
| Elf | 1 (Elyn) | wajar untuk sekarang |
| Dwarf | 2 (Torgrim, Veshka) | cukup |
| Astralborn | 2 (Seraphine, Halen) | cukup |
| **Dryad** | **1** (Maira) | 🔴 **tipis** |
| **Tidekin** | **1** (Neriah) | 🔴 **tipis** |
| **Shadeborn** | **1** (Luna) | 🔴 **tipis** |
| **Beastfolk** | **1** (Kessler) | 🔴 **tipis** |

**Aturan gelombang 3–4:** utamakan **Explorers · Leaders · Reformers**, dan **Dryad · Tidekin ·
Shadeborn · Beastfolk**. *Ras bukan stat — ia budaya (#86); roster yang 1/3-nya manusia membuat
tujuh ras lain terasa seperti dekorasi.*

**Gerbang v0.5 tetap tertutup sampai 50 tokoh lengkap** (B17 #64).

**Format wajib tiap tokoh baru:** ikuti `companion_11_merrit_fane.md` — 15 bagian + Catatan
Desainer, ~80–120 baris: IDENTITAS INTI · ROLE DUNIA · PERSONALITY (5 lapis) · HIDDEN POTENTIAL ·
AMBITION · FEAR · KONFLIK INTERNAL · KONFLIK EKSTERNAL · RELASI PENTING · LIFE EVENT CHAIN ·
AGING PATH · LEGACY PATH · COMPANION ARC · OUTCOME POSSIBILITIES · CATATAN DESAINER.

**Wajib lolos gerbang QA:** skala potensi K2 · **tiap tokoh punya jalur "hidup kecil / mati /
dilupakan"** (Hukum 8) · **Echo ≠ Origin** · relasi antar-companion **dua arah** · lokasi cocok
**#110** · **NO DESTINY** · nol kebocoran rahasia produksi.
