# INFO PRA-v0.5 — laporan status untuk Direktur + Designer

**2026-07-14 · MURNI LAPORAN — tidak ada kanon yang diubah, tidak ada yang dibangun.**
Cakupan: `docs/` · `docs/Aetherion_bible/` (berkas mentah) · `game/data` · `game/autoload` ·
`PLAN_LEDGER` (193 keputusan) · ROADBOOK.

> ## ⚠ TIGA TEMUAN YANG MENGUBAH RENCANA — baca ini dulu
> 1. **FACTION BIBLE SUDAH ADA — dan belum pernah kita baca.** Ia duduk di berkas mentah Direktur
>    (`FACTION_BIBLE_PART_01`, **status: LOCKED**) dengan **7 Great Powers bernama lengkap** +
>    Netherdeep Syndicate. **Nol ekstraksi ke `docs/`.** Kita nyaris menulis Faction Bible dari nol
>    di atas kanon yang sudah terkunci.
> 2. **C1 & C2 TIDAK PUNYA BARIS KEPUTUSAN.** Tidak ada "sidang" yang tercatat. Baris terakhir yang
>    menyebut keduanya adalah **#160 = MENUNGGU DIREKTUR**. Menurut aturan (a), **keputusan yang
>    tak tercatat = belum ada** → **nol eksekusi, dan itu benar.**
> 3. ~~**GATING LOKASI POHON SKILL (#116) TERNYATA TIDAK ADA DI DATA.**~~
>    🔴 **KOREKSI (#198) — TEMUAN INI SALAH, DAN SALAHNYA MILIK SAYA.** Gating lokasi **ADA dan
>    sudah lama hidup**: field-nya bernama **`unlock_location`** — **ada di 28/28 pohon**, lengkap
>    dengan **`rumor`** berarah. Skrip cek saya memotong daftar key di **10 pertama secara
>    alfabetis**, sehingga `unlock_location` & `rumor` tak terlihat. **Konsekuensi framing:**
>    keadaan sebelum C1 bukan "tanpa gating" melainkan **opsi (b) — gating lokasi PENUH**; dan
>    pilihan Direktur **(a)** adalah **PELONGGARAN**, bukan penambahan. *Dicatat sebagai kesalahan
>    analisis agent, bukan disembunyikan.*

---

# (A) STORY / ACT 1

## A1. Dokumen struktur Act 1 / story outline — **TIDAK ADA**

`docs/` memuat 22 berkas `.md`. **Tidak satu pun** adalah story outline / struktur Act.
Yang menyentuh cerita:

| Berkas | Isi | Status |
|---|---|---|
| `NIRNAMA_BIBLE_PUBLIC.md` (v2.1) | Kitab antagonis + **§IX = arc Act 1** | **kanon, FINAL (#180)** |
| `MISTERI_ABADI.md` | 10 misteri yang tak pernah dijawab | kanon |
| `COMPANION_BIBLE.md` + 15 sheet | tokoh & Life Event Chain per tokoh | **15/50** |
| `DUNGEON_ORIGINS.md`, `REGION_ORIGINS.md` | alasan tempat ada | kanon |
| `IMPLEMENTATION_ROADBOOK.md` | antrean v0.5 (bukan cerita) | dokumen eksekusi |

→ **Struktur Act 1 hanya hidup di §IX** — satu paragraf. **Tidak ada beat sheet, tidak ada urutan
quest, tidak ada peta adegan.** *Itu pekerjaan yang belum ada tuannya.*

## A2. NIRNAMA_BIBLE §IX — apa yang SUDAH tertulis

- **Fase 1 (jam 1–30) — hanya GEJALA:** rumor tempat yang "memutih" · NPC yang **tergagap** ·
  **satu Yang-Terhapus (The Erased) pertama** · **Nirnama Cult** memuja *"Keheningan yang Baik"*.
- **Fase 2 (jam 30–60) — para penyintas bersuara:** Old Elder memberi kesaksian · Silent One
  **menolak bicara** · Underground Elite **menjual info** · **satu pertemuan tanpa nama**:
  pengelana tua lembut yang bertanya hal-hal aneh tentang apa yang pemain bangun — **tidak diungkap
  siapa**.
- **Fase 3 (jam 60–100) — eskalasi menyentuh MILIK pemain:** **satu NPC yang pemain kenal
  melupakannya** (momen horor personal pertama) → klimaks **Celestial Crisis: bulan retak (B5)** →
  Sang Nirnama berdiri terungkap, **dan pengelana tua itu adalah dia**.
- **Gerbang Crisis:** klimaks Act 1 **= Celestial Crisis (B5)** — yang **belum dibangun** (ROADBOOK:
  **v0.8**). ⚠ **Ini konflik jadwal yang nyata** — lihat §D.
- **Reveal nama = BUKAN Act 1.** Itu harta Act 2.

**Yang TIDAK ada di §IX:** jumlah quest, urutan, wilayah mana, siapa Old Elder/Silent One/
Underground Elite (**tiga kelompok penyintas belum punya satu tokoh pun**), bagaimana "wilayah
memutih" dipicu secara mekanis.

## A3. Opening kanon (Pegasus + anak serigala) — **terdokumentasi, tipis**

| Butir | Di mana | Kedalaman |
|---|---|---|
| **Pegasus = FIRST MYSTERY** (bukan First Monster); terlihat sekilas; **tidak menandai pemain sebagai terpilih**; boleh diabaikan selamanya | `CLAUDE.md` (#118) · `NIRNAMA_BIBLE §…` · ROADBOOK v0.5 | **aturan jelas, adegan belum ditulis** |
| **"Carilah aku."** | **hanya di berkas mentah Direktur** (baris 340) + disebut di `MISTERI_ABADI` (*"apa arti 'Carilah aku'"* = **misteri abadi**) | ⚠ **kalimatnya kanon, artinya HARAM dijawab** |
| **Anak serigala terluka = monster pertama** (boleh dibantu / diabaikan / **dibunuh** — semuanya sah) | `CLAUDE.md` (#118) · ROADBOOK v0.5 | aturan jelas, **adegan belum ditulis** |
| Cutscene opening | `cutscenes.json` = **4 entri** (bukan opening kanon) | **belum dibuat** |

→ **Opening kanon = ATURAN, bukan NASKAH.** Yang ada: apa yang boleh & tidak. Yang belum ada:
adegan, dialog, pemicu.

## A4. Sistem yang SUDAH ADA & bisa dipakai cerita

| Sistem | Status | Catatan |
|---|---|---|
| **Cutscene engine** | ✅ **HIDUP** (`Cutscene` autoload, data-driven) | **4 cutscene** terdaftar. Siap dipakai; isinya yang belum ada |
| **Chronicle** | ✅ **HIDUP** (`Chronicle` autoload, bertanggal WIB nyata) | **Tokoh utama kedua** (#168). Sudah mencatat; **belum bisa DICORET** (kekuatan Nirnama) |
| **Quest taxonomy** | ✅ **HIDUP** — **9/9 quest punya `quest_type`** | Taksonomi (#80) ditegakkan test |
| **Boss-gating / skill unlock** | ✅ HIDUP (`on_boss_killed` → skill) | |
| **Rumor system (boleh salah)** | ✅ HIDUP — mesin Fase-1 §IX **sudah ada** | *"tempat yang memutih"* bisa disebarkan lewat ini **hari ini** |
| **Roh Hutan (wilayah memucat)** | ✅ HIDUP — **mesin "wilayah memutih" SUDAH ADA, tinggal dibalik** | Ini aset terbesar Act 1 |
| **Miracle/Omen + bencana** | ✅ HIDUP (7 entri: 4 terang, 3 gelap) | |
| **The Erased (musuh baru)** | ❌ **SPEC** | belum ada di `monsters.json` |
| **Nirnama Cult** | ❌ **SPEC** | belum ada faksi/NPC |
| **Celestial Crisis (B5)** | ❌ **SPEC — dijadwalkan v0.8** | ⚠ **klimaks Act 1 bergantung padanya** |
| **Memori NPC (World Remembers)** | ❌ **SPEC — v0.6** | ⚠ **"NPC melupakanmu" mustahil tanpanya** |

## A5. Wilayah — **5 HIDUP**, sisanya spec

**HIDUP** (`data/regions.json` + scene nyata): **Greenvale** (1–15) · **Desert of Ruins** (12–25) ·
**Candyveil Meadows** (18–32) · **Frostpeak Mountain** (22–38) · **Storm Island** (40–55).
*(+ dungeon side-view: Greenvale Depths, Gummy Cavern, Foothill Barrow, Zephyr Spire, dll.)*

**BELUM ADA (spec):** **Ashbrook** *(rumah Arlen & Merrit — **konten beku**!)* · Emberfall Volcano
(v0.7) · **Thalassar** (v0.7 — rumah Kain) · **Wildhearth** (v0.7) · Celestia (v0.8) ·
**Sylvara** (rumah Elyn) · Azhur · Nethrak *(rumah Kessler)* · Vorum · Valkaris · **Astrael**
*(benua yang HILANG — misteri)*.

> ### 🔴 KONSEKUENSI KERAS UNTUK ACT 1
> **Dari 15 companion, hanya SEBAGIAN KECIL tinggal di wilayah yang benar-benar ada.** Merrit &
> Arlen tinggal di **Ashbrook — yang belum dibangun**. Elyn di **Sylvara** (tak ada). Kain di
> **Thalassar** (v0.7). Kessler di **Nethrak** (tak ada). **Act 1 hanya boleh berdiri di 5 wilayah
> yang hidup** — dan itu berarti **Ashbrook harus lahir di v0.5**, atau separuh gelombang 2 tak
> bisa ditemui.

---

# (B) FACTION / DUNIA SOSIAL

## B1. Faction Bible — **ADA di berkas mentah, NOL di `docs/`**

`docs/Aetherion_bible/Aetherion_blueprint_reasoning and design.txt` **baris ~7546+**:

```
FACTION_BIBLE_PART_01 — THE SEVEN GREAT POWERS OF AETHERION
Status: LOCKED
Scope: Major World Powers · Political Balance · Influence Structure · Conflict Engine
DESIGN LAW: FACTIONS ARE IDEAS WITH ARMIES
```

**Belum pernah diekstrak, diringkas, atau dimasukkan ledger.** *(Pola yang sama dengan Nirnama
Bible sebelum #114 — sumbernya ada, kita tak membacanya.)*

## B2. Seven Great Powers — **SUDAH BERNAMA LENGKAP** (kanon LOCKED)

| # | Great Power | Catatan dari sumber |
|---|---|---|
| 01 | **THE CHRONICLE ORDER** — *Keepers of Memory* | pengaruh **global**; **musuh alami: Nirnama Cult** & *"Pemalsu Sejarah"*; punya **Sisi Terang & Sisi Gelap** |
| 02 | **THE WAYFARER LEAGUE** — *The Endless Road* | |
| 03 | **THE MONSTER CONSERVANCY** | ⚠ **rumah alami Maira (#006)** |
| 04 | **THE MERCHANT'S CONSTELLATION** | |
| 05 | **THE ASTRAL OBSERVATORY** | ⚠ **rumah alami Seraphine (#004)** |
| 06 | **NETHERDEEP SYNDICATE** | *"Netherdeep bukan area rahasia — Netherdeep adalah **konsekuensi sosial**"*; ⚠ **rumah alami Kain (#005)** |
| 07 | **THE SEEKERS OF THE LAST TRUTH** | |

**Yang belum:** ekstraksi ke `docs/FACTION_BIBLE.md`, ringkasan agenda per faksi, peta relasi
(sumber menyebut *"aliansi dan konflik selalu berubah"*), dan **baris ledger**.

> **Penemuan yang paling menyenangkan:** **THE CHRONICLE ORDER** sudah menjadi **musuh alami
> Nirnama Cult** di kanon yang terkunci — **tanpa kita rencanakan**, ia **persis** poros
> *ingin-lupa vs menolak-lupa* (#168/§XVI). Kanon lama dan kanon baru **bertemu sendiri.**

## B3. Institusi yang SUDAH DISEBUT di 15 sheet (Faction Bible tak boleh mengontradiksi)

| Institusi | Muncul di | Catatan |
|---|---|---|
| **Nirnama Cult** | 6× (Seraphine, Luna, dll.) | juga di §IX Act 1 |
| **Klan/serikat Ironvein** | Torgrim (#003), Veshka (#012) | **serikat dwarf** dengan **antrean Karya Besar** (Torgrim baru dapat giliran di usia 120) |
| **Rumah Lelang (B8)** | Kain (#005), Merrit (#011) | **sudah HIDUP di kode** (v0.4.2) |
| **Kuil / gereja** | Seraphine (gereja Ottren Hask), Luna | **gereja lahir dari kesalahan ramalan** |
| **Guild tabib** | Halen (#014) | |
| **Guild petualang / ordo kecil** | beberapa | belum bernama |
| **Militer perbatasan Nethrak** | Kessler (#015) | |
| **Memory Keepers** | NIRNAMA_BIBLE §III | *"leluhur filosofis"* — ⚠ **kemungkinan besar = Chronicle Order** |

## B4. Divine Bible — **SEED. Kolom agenda/gereja SENGAJA KOSONG**

`docs/DIVINE_BIBLE.md`: *"Status: **SEED**. Nama & domain **DIKUNCI**. Kepribadian, agenda, dan
gereja masing-masing… **§V. YANG SENGAJA MASIH KOSONG** — untuk tiap dewa: kepribadian · agenda ·
gereja & ordo · apa yang mereka minta."*
→ **5 dewa + Caevael bernama & bergema di peta. Isi keagamaannya: nol.**

---

# (C) C1 & C2 — status eksekusi

## C1 (#116, gating pohon skill) — **KINI DIPUTUS: (a)** *(bagian di bawah = keadaan SEBELUM putusan; satu butirnya SALAH — lihat koreksi #198)*

- **Baris terakhir: #160 = "MENUNGGU DIREKTUR — JANGAN eksekusi apa pun."** Tak ada baris sesudahnya.
- **Usulan saya** (node dasar di mana pun · node master di tanah asal) **masih usulan**.
- 🔴 ~~`skill_trees.json` = 28 pohon, NOL field region/lokasi.~~ **KELIRU (#198).** Field
  **`unlock_location` ADA di 28/28 pohon**, dan `SkillTreeSystem.can_unlock()` **menegakkannya**.
  Gating lokasi **PENUH sudah hidup sejak #30**. **Kesalahan analisis saya** (skrip memotong daftar
  key di 10 pertama). **Keputusan (a) = pelonggaran**, bukan pembangunan dari nol.
- Domain: magic 12 · survival 6 · combat 4 · craft 3 · taming 3 · **leadership 0** *(masih kosong,
  REPORT-06 §B7)*.

## C2 (#101, gerbang Advanced Class) — **BELUM dieksekusi**

- Yang **sudah** ada: **patch konsistensi #153** — gerbang mengikuti **band** (kini 55), bukan angka
  mati 60. Ujian = **30 monster ≥Lv40 tanpa mati**.
- Yang **belum**: **perubahan LEVEL → PERBUATAN**. Tak ada baris keputusan; **#160 masih berlaku**.
- **Peta "perbuatan-gerbang per class" untuk 6 class: BELUM DITULIS SAMA SEKALI.**
  *(Usulan saya di REPORT-06 hanya memberi 4 contoh, bukan peta.)* → **ini pekerjaan yang tersisa.**

## C3. UTANG EKSEKUSI — semua keputusan yang masih SPEC

| # | Keputusan | Fase | Catatan |
|---|---|---|---|
| **#160** | **C1 + C2 + 15 butir §D** | — | **MENUNGGU DIREKTUR** |
| #164/#166 | migrasi konten lama → dwibahasa | v0.5 | helper `Loc.c()` **sudah hidup** |
| #162 | **NPC Depth Pipeline** | v0.5 | terblokir sampai #164 dieksekusi |
| #156 | Curse · PEN · 20 resep fusion · **Star Whale entity** · guard artefak | **v0.5** | |
| #152b | progression non-level yang **terlihat** | v0.5–0.6 | |
| #170/#172/#179 | **8 Hukum NPC Depth + model potensi** | **v0.6** | `talent` kode masih **1–100 (INTERIM)** |
| #175 | **Item Penglihat Potensi** | v0.6 | |
| #182 | **Mentor System** | v0.6/v0.9 | |
| #181 | harga kematian per Act (**Act 1 = memory fade**) | v0.5+ | |
| #188 | **durability** | **prasyarat keras Act 4** | |
| #59 | **Stability 3-metrik** | v0.6–0.7 | **nol kode** |
| #154/#165 | **`chronicle_year`** (jam kronik) | v0.9 | **nol kode** |
| #146 | lokalisasi gelombang 2 | v0.5 | |
| #147/#148 | cuaca per-wilayah · 3 tipe dungeon kosong | v0.7 | |

---

# (D) PENDAPAT SAYA — 5 hal yang HARUS ada sebelum gelombang 3 (tokoh #16–50)

> **Alasan pokoknya satu:** menulis 35 tokoh lagi **tanpa peta faksi & wilayah** = menulis 35 tokoh
> yang tinggal **di tempat yang tak ada**, bekerja untuk **institusi yang belum bernama**. Itulah
> yang sudah terjadi pada gelombang 2 — dan kita **beruntung** karena Faction Bible ternyata
> **sudah ada**, cuma belum dibaca.

### 1. 🔴 **EKSTRAK FACTION BIBLE — sekarang, sebelum satu tokoh pun ditulis lagi**
7 Great Powers **sudah terkunci** di berkas mentah. Setiap tokoh gelombang 3 akan punya **majikan,
musuh, atau pelindung** — dan kalau kita menulisnya sebelum membaca kanon yang ada, kita mengulang
**tepat** kesalahan yang melahirkan 15 janji yatim di REPORT-06.
**Bonus:** tiga tokoh gelombang 2 **langsung menemukan rumahnya** (Maira → Monster Conservancy ·
Seraphine → Astral Observatory · Kain → Netherdeep Syndicate) **tanpa menulis apa pun yang baru**.

### 2. 🔴 **PUTUSKAN ASHBROOK — bangun di v0.5, atau pindahkan Merrit & Arlen**
**Merrit Fane — patokan yang Direktur tulis sendiri — tinggal di wilayah yang tidak ada, dan
berstatus KONTEN BEKU.** Begitu pula Arlen. Ini bukan detail: Merrit dirancang sebagai **companion
pembuka tema**, ditemui **paling awal**. Kalau Ashbrook tidak lahir di v0.5, **tokoh pertama yang
memperkenalkan tesis game tidak bisa ditemui pemain.**

### 3. 🟠 **SELESAIKAN KONFLIK JADWAL: klimaks Act 1 = Celestial Crisis (v0.8)**
§IX mengunci klimaks Act 1 pada **bulan retak (B5)** — yang dijadwalkan **v0.8**, tiga versi setelah
v0.5. **Salah satu harus mengalah:** (a) tarik B5 ke v0.5 (mahal), (b) Act 1 v0.5 hanya sampai
**Fase 2** (dan klimaksnya menunggu), atau (c) ganti klimaks Act 1. *Rekomendasi saya: **(b)** —
Act 1 dirilis bertahap, persis seperti dunia yang perlahan memutih.*

### 4. 🟠 **"NPC MELUPAKANMU" MUSTAHIL TANPA MEMORI NPC (v0.6)**
Momen horor personal pertama (§IX Fase 3) menuntut **World Remembers v1** — **spec, v0.6**. Kalau
Act 1 dikirim di v0.5, **senjata utama Nirnama tidak bisa ditunjukkan.** Perlu keputusan: tarik
memori NPC ke v0.5, atau Act 1 v0.5 berhenti sebelum fase itu.

### 5. 🟡 **NAMAI TIGA KELOMPOK PENYINTAS + isi kuota REFORMERS (masih NOL)**
§IX Fase 2 memanggil **Old Elder · Silent One · Underground Elite** — **tak satu pun punya tokoh.**
Ketiganya **adalah** slot companion gelombang 3 yang sudah dipesan cerita. Dan **Reformers = 0/4–6**
sementara **Human sudah 5/15**. Gelombang 3 sebaiknya **dibentuk oleh kebutuhan cerita**, bukan
diisi acak lalu dicarikan tempat.

---

## Ringkasan satu kalimat

**Fondasi kanon v0.5 sudah lengkap dan konsisten; yang belum ada adalah TEMPAT dan LEMBAGA tempat
cerita itu berdiri — dan Faction Bible yang kita kira harus ditulis, ternyata sudah terkunci di
laci Direktur sejak awal.**
