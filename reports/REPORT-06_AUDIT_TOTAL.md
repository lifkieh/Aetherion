# REPORT-06 — AUDIT TOTAL AETHERION

**Tanggal:** 2026-07-13 · **Mandat:** audit menyeluruh + **hak berpendapat** (Direktur).
**Cakupan:** PLAN_LEDGER (148 keputusan) · seluruh Bible (`docs/` + `docs/Aetherion_bible/`,
50.435 baris) · ROADBOOK · GAP_AUDIT · REPORT-01…05 · **21.372 baris GDScript** ·
26 berkas data · 822 test (kini **846**).

**Cara membaca:** (A) fakta · (B) cacat desain menurut saya · (C) **pendapat saya, termasuk
ketidaksetujuan** · (D) pertanyaan · (E) urutan kerja. **Keputusan tetap milik Direktur.**

> ### ⚠ TEMUAN PALING KERAS DULU
> **Tiga sistem yang "SELESAI" di ledger ternyata rusak di runtime**, dan **822 test tidak
> menangkapnya** karena test-nya menulis state langsung, bukan melewati jalur nyata:
> 1. **Pemain bisa MATI di dalam menu jeda** — monster dungeon tetap memukul saat pause.
> 2. **Pemain gamepad TIDAK BISA memakai skill sama sekali** — D-Pad terpasang ke aksi
>    (`skill_N`) yang **tidak pernah dibaca** kode (yang dibaca `slot_N`). "Gamepad penuh"
>    (#99) **tidak pernah benar**.
> 3. **"Hutan memucat" (Stewardship, #95) tak pernah terlihat** — tint-nya ditimpa ulang
>    setiap frame.
>
> Ketiganya **sudah saya perbaiki** (bagian F), plus 7 bug lain. **846 test hijau.**

---

## (A) TERLEWAT / BELUM TERIMPLEMENTASI

### A1. Janji yang **BENAR-BENAR MENGGANTUNG** (tak ada di kode DAN tak ada di antrean mana pun)

| # | Janji | Sumber | Bukti kosong |
|---|---|---|---|
| 1 | **Curse** (status ke-6) | GDD v0.1 §6.4; ledger menulis *"Curse menyusul"* | `StatusFx.DEFS` = 5 status. Nol hit `curse` |
| 2 | **PEN (penetration)** | GDD v0.1 §6.3; ledger: *"PEN belum"* | `CombatResolver` tanpa PEN |
| 3 | **Durability & repair** (#29) | Baris ledger dibuat **khusus agar tak hilang senyap** — lalu hilang senyap | Nol kode. Ironisnya #12 (death penalty) beralasan *"durability belum ada"* → alasan itu jadi permanen |
| 4 | **Stability 3 metrik** (B12 #59) | Blueprint | **Nol kode.** #127 menyatakan *"Stability v1 3-metrik TETAP sekarang"* — **pernyataan itu tidak benar**; yang "tetap" adalah sesuatu yang tak pernah ada |
| 5 | **B2 Monster bekerja** (#47) | Blueprint | Nol kode, nol baris antrean |
| 6 | **B13 Expansion 3 jalur** (#60) | Blueprint | Hilang dari ROADBOOK (masih di TRACKBACK v0.8 → **dua dokumen antrean beda fase**) |
| 7 | **B7 Perayaan Legacy + festival** (#52/#81) | Blueprint | Chronicle hanya *mencatat*; tak ada seremoni |
| 8 | **Wonder tier-legenda Piagam**: *The Nameless Door · The Forgotten Musician · The Sleeping Giant* | Piagam Bag.0 (*"tier-legenda pertama = v0.5"*) | ROADBOOK v0.5 diam-diam **mengganti** dengan "lonceng tengah malam" + "Bukit Kabut". **Tak ada baris keputusan** → melanggar aturan permanen (b) |
| 9 | **Aturan ARTEFAK terlindung** (#115) | Keputusan Direktur K2 | Nol `artifact` di kode/data; **aturan proteksinya tak punya baris antrean maupun test** |
| 10 | **Fusion 20 resep sisa** (15/35) | GDD target launch | `elements.combos` = 15 |
| 11 | **Treasure Hunter** | GDD §3.3 | Merchant selamat ke v0.6; Treasure Hunter **jatuh diam-diam** |
| 12 | **Trait spesies berefek** (Pack Hunter dll.) | GDD §7.2 | Data ada di 60 monster; **kode hanya membaca `split`** |
| 13 | **Star Whale sebagai entitas dunia** (#54) | Janji eksplisit B9 | `star_whale` **tidak ada** di `monsters.json` |
| 14 | **Homestead: ternak/apiari/kolam/breeding** | GDD v0.2 §5 | Nol kode, nol antrean |
| 15 | **Growth Type · Evolusi bercabang · B11 otonomi kerajaan** | GDD/blueprint | Nol kode, nol antrean (B11: ROADBOOK hanya menjadwalkan *pertumbuhan* HQ, bukan **otonomi**-nya) |

### A2. Hilang dari ROADBOOK, selamat hanya di TRACKBACK *(ROADBOOK = dokumen eksekusi aktif)*
- **10 CAPSTONE per class** (#57 — Worldbreaker, Astral Genesis, Throne of Souls…). Di kode
  **hanya ada test yang MELARANG** capstone menempel di pohon; **tak ada yang membuatnya**.
- **Sistem Rival** (#38b).

### A3. Memang **TERJADWAL** (bukan terlewat)
Loadout (v0.9) · Domain/Life Events (v0.6) · Rune (v0.6) · Black Market (v0.6) · Dual Class
(v0.5) · Multi-elemen (v0.7) · Ecology (v0.7, **fondasi data #130 sudah ditanam**) ·
Lokalisasi gel.2 (v0.5) · Legacy Family (v0.9, **terkunci K1**) · Cuaca per-wilayah (v0.7) ·
Celestial Crisis (v0.8).

### A4. **Dokumen hukum yang memuat status PALSU** (bug dokumen, aturan (d))
1. **TRACKBACK** masih menulis v0.4.2 *"⏭ berikutnya"* — padahal v0.4.4 selesai. Ini
   **sumber kebenaran roadmap** dalam hierarki resmi.
2. **CLAUDE.md** masih menyatakan **Q1–Q7 semuanya pending** — padahal Q1–Q6 sudah diputus.
   Hukum yang dibaca tiap sesi **melarang lebih luas daripada kenyataan**.
3. **PLAN_LEDGER** masih menulis blueprint *"file menunggu (BD-2)"* & B19 *"menunggu file"*.
4. **PLAN_LEDGER §5** masih menandai *maker's mark, enchant +1..+10, Transenden* = **"Belum"**
   — padahal ketiganya **jalan sejak v0.4.2**.
5. **STATUS bagian bawah** menyebut *"153/153 test"*, *"34/34 pass"*, dan menyuruh membangun
   Frostpeak (sudah lama selesai).

---

## (B) IDE BERLUBANG — cacat desain menurut saya

### B1. 🔴 **Level tanpa batas × band L1–55 × Chronicle Clock — tiga hukum yang saling meniadakan**
**Fakta:** monster level maks **55** (data). Soft-cap EXP yang dijanjikan K2 (#69) **tidak ada
di kode** (`gain_exp` hanya punya Golden Hour + bonus pohon). Jadi hari ini: lewat level ~60,
**seluruh dunia jadi tak relevan** — tak ada yang bisa melukai pemain, dan tak ada rem.

**Kenapa ini lebih dalam dari sekadar balancing:** kanon punya **tiga** hukum yang bertabrakan:
(1) level tanpa batas (B10), (2) *"Nirnama tak bisa dibunuh siapa pun"* (#134), (3) *"level bukan
sumbu kekuatan; pemahaman-lah sumbunya"* (World Bible). Kalau level tak dibatasi **dan** tak
pernah jadi jawaban, maka **level adalah sumbu progres yang paling terlihat dan paling tidak
bermakna** — pemain menghabiskan ratusan jam menaikkan angka yang, menurut kanon Anda sendiri,
tidak menentukan apa pun.

**Usul tambalan:** jadikan level **eksplisit sebagai sumbu sekunder**. Terapkan soft-cap #69
sekarang (EXP mengecil tajam di luar band konten), dan pindahkan progres nyata ke **Mastery /
Understanding** (yang sudah dikunci World Bible tapi belum pernah kita bangun). Dengan begitu
"level tanpa batas" tetap benar — ia hanya berhenti menjadi hal yang penting.

### B2. 🔴 **Revive-harga-INGATAN (#119/#133) belum punya benda bernama "ingatan"**
Tidak ada sistem memori pemain/NPC di kode. Sementara **Cermin Jiwa** membiarkan pemain
mengganti rupa seharga **150 gold** — murah, kosmetik, tanpa jejak. Kalau nanti "membayar
dengan ingatan" diimplementasikan sebagai *"−1 entri Chronicle"* atau *"satu NPC melupakanmu"*,
maka **Chronicle dan memori NPC menjadi mata uang** — dan itu **bertabrakan langsung dengan
kekuatan Sang Nirnama** (ia MENGHAPUS ingatan; pemain akan melakukan hal yang sama untuk
menyelamatkan temannya).

**Pendapat saya: itu bukan bug — itu peluang terbaik yang dimiliki cerita ini.** Tapi harus
**disengaja**: revive = *"kau memakai senjatanya untuk melawan dia"*, dan Chronicle harus
menampilkan halaman yang **kau sendiri** yang mencoret. Kalau tidak disengaja, ia akan jadi
kebetulan yang canggung.

### B3. 🟠 **Lelang tawanan × reputasi — insentifnya terbalik**
Membebaskan tawanan = biaya emas + reputasi (setelah #145). Tapi **tidak ada konsekuensi apa
pun kalau pemain MENGABAIKANNYA** — lot-nya hilang diam-diam saat hari berganti, dan tak ada
yang mengingat. Padahal kanon B16 (nada gelap) dan Chronicle ("mencatat tanpa menghakimi")
menyediakan tempat sempurna: **tawanan yang tak dibebaskan seharusnya dibeli orang lain** — dan
**Chronicle mencatat bahwa kau melihatnya, lalu pergi**. Sekarang: nol jejak.

### B4. 🟠 **Loadout 20–30 × hotbar 5 × gamepad — aritmetikanya tidak berfungsi**
Gamepad hanya punya **D-Pad (4) + RB** = **5 slot** — persis hotbar, **nol slot cadangan**.
Padahal loadout (v0.9) mengandaikan pemain **sering menukar** isi hotbar dari kolam 20–30 skill.
Di keyboard itu berarti buka menu; di gamepad, tanpa **radial menu** atau **modifier (LB + D-Pad
= slot 6–10)**, sistem loadout akan terasa jauh lebih buruk. **Ini harus diputuskan sebelum v0.9
dibangun, bukan sesudah.**

### B5. 🟠 **Advanced Class menjanjikan bonus yang tidak ada**
`AdvancedClass.gd` mendokumentasikan *"memberi gelar + bonus kecil permanen"*, tapi
`recalculate_stats()` **tidak pernah membaca `advanced_class`**. Ujian 30 monster tanpa tumbang
→ hadiahnya **hanya sebuah string**. Entah bonusnya dibuat, entah dokumentasinya dikoreksi.

### B6. 🟠 **Kematian pemain = gratis di overworld**
Dungeon memotong 10% gold; **overworld: nol biaya, nol konsekuensi** (respawn HP penuh). Dengan
#119 (*"kebangkitan selalu berharga — tanpa kecuali"*) sebagai hukum, **pemain adalah satu-satunya
makhluk di dunia yang bisa bangkit gratis, tanpa batas**. Entah kita akui itu sebagai pengecualian
sadar (dan tulis alasannya), entah kita beri harga.

### B7. 🟡 **`leadership` = 0 pohon** dari 6 domain kanon (#116) — domainnya ada, isinya kosong.

---

## (C) PENDAPAT SAYA

### C1. Yang saya **TIDAK setujui**

**(i) Keputusan #116 — gating lokasi dipertahankan "di atas" limiter-waktu bible.**
Saya paham alasannya (identitas Aetherion), dan saya akan mengeksekusinya penuh. Tapi saya
tidak setuju, dan alasan saya: **gating lokasi menghukum pemain yang tak bisa bepergian, bukan
pemain yang belum belajar.** Bible mengunci **WAKTU** sebagai limiter karena waktu itu adil —
semua orang punya jumlah yang sama. Geografi tidak: ia jadi tembok tiket, dan di game
single-player ia berubah jadi **checklist perjalanan**, bukan pilihan.
**Alternatif:** pohon tetap "lahir" di tanahnya (rumor, guru, atmosfer) — tapi yang dikunci
adalah **kedalaman**, bukan pintu: node dasar bisa dibuka di mana pun, node master **hanya di
tanah asal**. Identitas terjaga, hukuman perjalanan hilang.
**Taruhannya bila tetap:** saat 8 benua lahir (v0.7+), pemain akan menghadapi **28+ pohon di 8
tempat** — dan "pergi ke sana dulu" akan menjadi keluhan nomor satu playtest.

**(ii) Keputusan #101 — Advanced Class digerbangi Level 60.**
Bible sendiri menolak angka sebagai penentu identitas (*"Hidden Class tidak dipilih — DITEMUKAN"*).
Lv60 + 30 kill adalah **gerbang grinding**, bukan gerbang makna. Ujian "tanpa tumbang" bagus —
tapi ia mengukur ketekunan, bukan siapa dirimu.
**Alternatif:** ganti syarat level dengan **syarat perbuatan** (mis. Warrior → melindungi
seseorang sampai selesai; Necromancer → menolak satu kebangkitan). **Taruhannya:** kita menghabiskan
sebuah momen besar untuk sesuatu yang terasa seperti quest harian.

**(iii) Cara kita memakai test.**
846 hijau, tapi **tiga sistem rusak total** lolos. Penyebabnya struktural: **test kita menulis
state langsung** (`WorldState.counters["trees_cut"] = 260`) alih-alih **melewati jalur nyata**
(`EventBus.node_harvested.emit(...)`). Test seperti itu menguji *getter*, bukan *game*. Saya
sudah menambahkan 24 test regresi yang melewati jalur nyata — tapi ini perlu jadi **aturan**:
*setiap test sistem wajib masuk lewat pintu yang dipakai pemain.*

### C2. **Kelebihan proyek yang harus DILINDUNGI dari perubahan**

1. **Waktu WIB nyata + fase bulan + musim 2 minggu.** Ini jiwa game ini. Purnama di jendela
   pemain adalah purnama yang sama di Aetherion. **Jangan pernah** menukarnya demi kenyamanan
   sistem generasi — kalau K1 harus mengorbankan sesuatu, **korbankan yang lain** (opsi dua-jam).
2. **Rumor yang boleh salah + gosip yang diwarnai watak.** Ini yang membuat dunia terasa punya
   penduduk, bukan papan pengumuman. Jangan pernah "diperbaiki" jadi akurat.
3. **Chronicle dengan tanggal WIB sungguhan.** *"Tahun 842"* tidak akan pernah menyentuh siapa
   pun; *"12 Juli 2026, 23:41"* menyentuh.
4. **Roh Hutan.** Satu-satunya sistem yang membuat konsekuensi **terlihat** tanpa menghukum
   dengan game-over. Pola inilah (bukan HP bar) yang harus dipakai untuk Ecology, penghapusan
   Nirnama, dan bencana.
5. **Aturan bahwa kanon tidak berubah tanpa baris keputusan.** Proyek ini punya 148 keputusan
   yang bisa ditelusuri — itu **sangat langka**, dan itulah alasan audit ini bisa menemukan
   sembilan janji yang hilang. Jangan pernah longgarkan.

---

## (D) BUTUH KONFIRMASI

**Veto/keputusan yang menggantung (berjalan sebagai asumsi):**
1. **K1 skala waktu** (#123) — memblokir SELURUH v0.9. Opsi: (a) buang real-clock; (b) buang
   aging/generasi; (c) **dua jam terpisah**. *(Rekomendasi saya: c.)*
2. **Pemetaan lingkup→benua** (#110) — draft saya, **belum diveto**. Companion Bible & ASSET_MANIFEST
   sudah terlanjur memakainya. **Fairy Realm = TBD.**
3. **6 capstone sisa** + veto 10 capstone (#57) — **default diterima bila tak diveto sebelum v0.5**.
   v0.5 sudah di depan. Setelah itu, pembongkaran mahal.
4. **First Scar = guru** (#111) & **arc Act 1** (#114 §IX) — keduanya **"diterima sementara"**,
   dan v0.5 dijadwalkan berdiri di atasnya.
5. **Rename "Sinkronisasi"** (C4), **rename MiracleSystem → Wonder/Omen** (C6), **Paladin &
   Divine Magic** (C9) — rekomendasi saya, **belum diratifikasi**.
6. **3 spesies naga** belum dinamai · **Naval Bible** belum lahir (Thalassar v0.7).
7. **Divine Bible**: kepribadian/agenda/gereja 5 dewa masih kosong.
8. **LAW OF ERAS vs "The Final Silence"** — hukum kita berkata *tidak ada ending dunia*; daftar
   5 ending memuat **dunia berakhir**. **Belum ada baris resolusi.**
9. **Metrik penilaian warisan** (endgame #134) — belum ditentukan.
10. **Multi-Generation: Tier E (pasca-rilis) atau v0.9?** (C12/Q10 tak pernah dijawab.)

**Pertanyaan baru dari audit ini:**
11. **Soft-cap EXP (#69)** — bangun sekarang, atau level dibiarkan bebas sampai v0.9?
12. **Kematian pemain di overworld** — beri harga, atau akui sebagai pengecualian sadar?
13. **Bonus Advanced Class** — dibuat, atau dokumentasinya dikoreksi?
14. **Gamepad & loadout** (B4) — radial menu, modifier, atau loadout memang keyboard-first?
15. **Tawanan yang diabaikan** (B3) — dicatat Chronicle, atau memang tanpa jejak?

---

## (E) KALAU SAYA DIREKTUR SEMINGGU — 5 hal pertama

1. **Playtest v0.4.4 sekarang, dengan gamepad.** Tiga bug fatal lolos 822 test; hanya tangan
   manusia yang menemukan hal seperti itu. **Satu jam bermain > seratus test baru.**
2. **Jawab K1 (skala waktu).** Ia memblokir v0.9 **dan** menyandera Ecology, world-history,
   suksesi. Tanpa itu, separuh roadmap adalah fiksi.
3. **Bersihkan empat dokumen yang berbohong** (A4). Proyek ini dijalankan oleh dokumen; dokumen
   yang salah **akan** melahirkan sistem yang salah — persis seperti dark-miracle.
4. **Tutup Companion Bible (B17, 40 tokoh).** Ia satu-satunya gerbang v0.5, dan ia juga memblokir
   Companion Dungeon, rekrutan, Life Events, dan penggantian 4 rival lelang placeholder.
5. **Tambal utang murah sebelum jadi mahal:** soft-cap EXP, rename Sinkronisasi, artefak diberi
   *guard* + test (sebelum artefak pertama lahir sebagai `type: "weapon"` dan melanggar kanon
   secara diam-diam).

---

## (F) BUG YANG SUDAH SAYA PERBAIKI (izin: "bug nyata boleh langsung diperbaiki")

| # | Bug | Parah | Perbaikan |
|---|---|---|---|
| 1 | **Monster memukul saat game DI-PAUSE** — pemain bisa mati di dalam menu jeda (`create_timer` default `process_always=true`) | 🔴 | `create_timer(..., false)` di `DungeonMonster.gd:389,470` |
| 2 | **Bencana kedua TIDAK PERNAH datang** — `dark_event` tak dibersihkan saat kedaluwarsa → sistem #145 mati setelah sekali pakai | 🔴 | dibersihkan di `MiracleSystem._refresh()` |
| 3 | **Gamepad tak bisa memakai skill** — D-Pad terpasang ke `skill_N` yang tak pernah dipoll (Player membaca `slot_N`); `skill_3/4/5` bahkan tak ada di InputMap | 🔴 | `Keybinds`/`InputGlyphs` dipindah ke `slot_1..slot_5` |
| 4 | **`trees_cut` dihitung 2–4×** — dua listener menaikkan counter yang sama → Roh Hutan murka di ~50 pohon, bukan 200 | 🔴 | `ForestSpiritSystem` kini **membaca**, tidak menaikkan |
| 5 | **Quest `q_candy` MUSTAHIL** + panen permen dihitung sebagai menebang pohon (`report_kind` selalu "tree") | 🔴 | jenis node dilaporkan benar; toast diperbaiki |
| 6 | **Gagal-tame membuat monster JINAK 10 menit** (kebalikan dari maksudnya); gagal "tak punya orb"/"pact-only" ikut menghukum | 🟠 | enrage dipisah; hanya `failed_roll` yang menghukum, dan monster **menyerang** |
| 7 | **"Hutan memucat" tak pernah terlihat** — tint ditimpa tiap frame | 🟠 | `world_tint()` masuk ke `_ambient_now()` |
| 8 | **Warga membicarakan first-clear yang sama SELAMANYA** (`TALK_DAYS` = kode mati) | 🟠 | kedaluwarsa nyata (3 hari) |
| 9 | **Buff & status "hantu" menembus load** | 🟠 | `buffs`/`statuses` direset di `from_save()` |
| 10 | **Restock toko tidak hitung-saat-login** (melanggar HUKUM SIMULASI DUNIA #89) | 🟠 | `Economy.catch_up()` dari selisih hari WIB |

**+24 test regresi** yang **melewati jalur nyata** (EventBus, InputMap, save/load) — bukan menulis
state langsung. **846 test, 0 gagal.**

**Belum diperbaiki (butuh keputusan, bukan kode):** bonus Advanced Class (B5) · kematian pemain
gratis (B6) · `leadership` kosong (B7) · soft-cap EXP (B1) · guard artefak (A1 #9).
