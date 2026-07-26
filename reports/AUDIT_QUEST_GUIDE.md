# AUDIT & USULAN — GUIDE · PAPAN QUEST GUILD · QUEST NPC · QUEST UTAMA BERCABANG

> Perintah Direktur 2026-07-25: *"bikin guide, papan quest dari guild, quest pribadi
> dari npc, quest utama yang bercabang dengan ending berbeda-beda — audit dan diskusi
> dulu."* Dokumen ini = AUDIT keadaan nyata (diukur dari kode/data) + USULAN untuk
> didiskusikan. **NOL perubahan game/.**

---

## A. AUDIT — apa yang SUDAH ada

### A1. Guide (Onboarding)
- `Onboarding.gd`: rantai **6 langkah** (kill 2 → skill → tebang 3 → craft → tame →
  pintu dungeon) + tip kontekstual sekali-muncul. HUD "Panduan 1/6".
- ⚠ **Rantai ini lahir untuk GREENVALE** dan tampil di Ashbrook64 (start baru):
  langkah 1-2 kini jalan (babi hutan ada), tapi **langkah 4 (craft di Bengkel) BUNTU**
  — bengkel Ashbrook = *"bengkel yang berhenti"* (prop mati, kanon #206), dan
  **langkah 6 (pintu dungeon) tak ada di Ashbrook**. Pemain baru dapat panduan yang
  tak bisa diselesaikan — cacat 🔴-4 audit gameplay, masih hidup.
- Guide juga **buta terhadap loop inti** (bukti → Kitab → pulihkan). Sistem yang
  membuat game ini berbeda justru tak pernah diajarkan.

### A2. Papan quest
- `QuestSystem.gd` (151 baris): **harian ter-seed tanggal** — tiap hari 3 dari 9
  quest `quests.json` di-roll deterministik. Track satu, progress via EventBus
  (kill/gather/craft), klaim hadiah. Papan = `Interactable "board"` (Greenvale balai
  + Ashbrook?) → `board_visited` → UI di MenuUI.
- **9 quest**: 4 kill · 3 gather · 1 craft · 1 tame. Semua ANONIM (nol pemberi).
  `quest_type` taksonomi E8 terisi (Need/Fear/Dream/Ambition) — di data, bukan di rasa.
- **GUILD: TIDAK ADA** — nol entitas, nol lore in-game. Di bible cuma satu sebutan
  sambil lalu ("dibunuh oleh Guild XYZ" — konteks guild PEMAIN, fitur online GDD).

### A3. Quest pribadi NPC
- **TIDAK ADA SATU PUN.** Tak ada quest yang datang dari mulut NPC bernama.
  Ironi: kita baru saja memberi Merrit/Bram mulut (#290) — mereka bicara,
  tapi tak pernah MEMINTA apa pun.

### A4. Quest utama & ending
- **Garis utama: BELUM ADA di kode.** Yang ada = potongan loop Chronicle (A1
  setengah, A3 fondasi data #290) tanpa pembungkus quest.
- **KANON SUDAH KAYA — ini modal terbesar:**
  - Spine v0.3: Act 1 = F1 gejala (jam 1-30) → F2 dunia bicara (30-60) → F3
    penghapusan menyentuh MILIK pemain (60-100) → klimaks **bulan retak**;
    reveal Nirnama = Act 2. Ashbrook = tangga F1→F3 (A1·A2·A3-TRIASE).
  - **ENDGAME DIKUNCI (#134): HYBRID FINAL JUDGE** — bertahan → lindungi → JAWAB
    lewat bukti; **LIMA ENDING** (Dawn · Final Silence · Last Sky · Broken Answer ·
    The World Remembers), **tak ada yang sempurna**, Final Silence = dunia LUPA
    (#176), tak ada ending-dunia (#75b).
  - Jadi *"quest utama bercabang dengan ending berbeda"* = **bukan fitur baru,
    melainkan MEWUJUDKAN kanon yang sudah diketuk.** Yang belum ada: sistem
    penilaian warisan (metrik Chronicle/Domain/companion/orang-yang-ingat) dan
    percabangannya di jalan, bukan cuma di ujung.

---

## B. USULAN DESAIN (untuk didiskusikan, bukan dieksekusi)

### B1. GUIDE → "Panduan" sadar-wilayah + sadar-tesis
1. Rantai per wilayah-start: **rantai Ashbrook baru** — `kalahkan 2 babi hutan →
   bicara dengan satu penduduk → periksa satu bekas (examine) → buka Kitab →
   pulihkan halaman pertama → [lanjut bebas]`. Combat tetap diajarkan, tapi
   panduan MENGAJARKAN GAME YANG SEBENARNYA (loop Chronicle), bukan RPG generik.
2. Langkah craft/tame/dungeon pindah ke **tip kontekstual** (muncul saat pemain
   menyentuh sistemnya — mekanisme tip sudah ada, tinggal isi).
3. Gerbang pilar: BELONGING (pemain tahu tempatnya) + WONDER (bekas pertama).
   ⚠ D-3 dijaga: panduan TIDAK berkata "itu bukti!" — langkahnya "periksa
   sesuatu yang janggal", notice-nya tetap senyap.

### B2. PAPAN QUEST DARI GUILD → "Serikat Penjelajah"
1. **Nama usulan: Serikat Penjelajah** — satu keluarga dengan *Gerbang Penjelajah*
   (#43) dan kanon Valenford *"Kingdom of Open Roads"*. Cabang kecil di Greenvale
   (kota hub); **Ashbrook TIDAK punya cabang** (kota memudar — konsisten tesis;
   papan tua Ashbrook tetap papan komunitas, bukan guild).
2. Papan guild = poster **BERTANDA TANGAN**: tiap quest punya `giver` (NPC nyata,
   digenerate/di-tulis) + alasan manusiawi → memenuhi E8 *"kill/collect tanpa
   konteks manusia dilarang jadi inti"* yang sekarang cuma dipenuhi di data.
3. Struktur: harian (roll sekarang, diberi wajah) + **kontrak berperingkat**
   (F/E/D... naik dengan reputasi Serikat) + hadiah rep → diskon/akses.
   *Reputasi = OPPORTUNITY (#179), bukan kontrol NPC.*
4. Ongkos: 1 NPC penjaga cabang + data giver pada 9 quest lama + ~10 kontrak baru
   + UI papan diperluas (rep + peringkat). Sedang.

### B3. QUEST PRIBADI NPC → dari mulut yang sudah hidup
1. Pola: **quest lahir dari DIALOG** NPC bernama (bukan tanda seru — konsisten D-3
   & #122 "rekrutmen bukan menu"): baris persona tertentu membuka permintaan.
2. Gelombang 1 (v0.5, Ashbrook — 4 quest tulis-tangan, satu per jenis taksonomi):
   - **Merrit (Memory):** "antar surat ke perhentian yang tak masuk akal" — rute
     pos lama; mengubah: Merrit menunggu di lampu lebih lama malam itu.
   - **Halloran (Legacy):** "habiskan 200 roti" — bagikan roti pagi ke penduduk;
     mengubah: Halloran mulai memanggang 40. (Kejam-cuaca; pemain yang memutuskan
     apakah itu pertolongan.)
   - **Bram (Hidden):** "cari kursi ayahku" — bangku tua di reruntuhan timur;
     mengubah: Bram pindah duduk, baris gosipnya bertambah satu.
   - **Nyai (Fear):** "temani aku Kamis sore" — jalan Kamis-nya (SEKALIGUS
     membangun mekanisme jadwal-observe yang dibutuhkan `ev_otha_nyai` — dua
     burung satu batu).
3. Hukum E8 dipegang keras: **tiap quest MENGUBAH keadaan NPC-nya** — bukan
   fetch demi hadiah.
4. Ongkos per quest: dialog + 1-2 titik dunia + state kecil + test. Gelombang 1
   = sedang.

### B4. QUEST UTAMA BERCABANG → mewujudkan spine, bukan mengarang baru
1. **Bentuk: "Benang" (main thread), bukan journal quest biasa** — Act 1 Ashbrook:
   `Tiba → A1 Penghapusan Pertama (Otha) → jaringan bukti → A2 Seseorang
   Melupakanmu (Merrit) → A3 TRIASE (pilih halaman) → keluar Ashbrook (F2)`.
   #290 sudah menyiapkan data A3; A2 butuh dialog sesudah-lupa (tulisan tangan
   Direktur) + pemicunya; A1 butuh keadaan-SEBELUM (toko buka dulu).
2. **Cabang = PERILAKU, bukan pilihan menu** (konsisten #225 jalur C): sumbu
   INGIN-LUPA↔MENOLAK-LUPA diukur dari apa yang pemain KERJAKAN — halaman yang
   dipulihkan/dibiarkan, A3-pick, siapa yang masih mengingatmu. Dicatat sebagai
   **metrik warisan** (fondasi sistem penilaian endgame yang roadbook minta).
   ⚠ D-4: metrik TIDAK PERNAH tampil sebagai angka/progress ke pemain.
3. **Ending: LIMA yang sudah kanon** — cabang di jalan menentukan bobot
   PENGHAKIMAN (fase 3 HYBRID FINAL JUDGE). v0.5 TIDAK membangun endgame;
   v0.5 membangun **pencatat metriknya** supaya semua keputusan pemain dari
   sekarang sudah terhitung saat endgame lahir (v1.0).
4. Ongkos v0.5: benang Act-1-Ashbrook (state machine kecil + A1 keadaan-sebelum +
   pemicu A2 + adegan A3) + pencatat metrik senyap. Besar — tapi ini KONTEN
   utama v0.5 sesungguhnya.

---

## C. URUTAN BANGUN USULAN

| # | Paket | Kenapa duluan | Ongkos |
|---|---|---|---|
| 1 | **B1 Guide Ashbrook** | pemain baru sekarang dapat panduan buntu — luka terbuka | kecil |
| 2 | **B4a Benang Act 1 (A1-sebelum + pemicu A2*) + pencatat metrik** | jantung v0.5; A3 datanya baru saja siap (#290); metrik makin telat = makin banyak keputusan tak tercatat | besar |
| 3 | **B3 Quest pribadi gelombang 1** | menunggangi mulut #290; Nyai-quest membangun jadwal-observe | sedang |
| 4 | **B2 Serikat Penjelajah** | butuh Greenvale (sudah 32px ✓); paling terpisah, aman belakangan | sedang |

*A2 butuh tulisan tangan Direktur untuk himpunan sesudah-lupa.

## D. PERTANYAAN UNTUK DIREKTUR (blokir mulai)

1. **Nama & lore guild:** "Serikat Penjelajah" (ikatan Valenford/Gerbang) — setuju,
   atau Direktur punya nama/lore lain? Cabang HANYA di Greenvale (Ashbrook tanpa
   guild demi tesis) — setuju?
2. **Guide:** ganti rantai jadi rantai-Chronicle Ashbrook (usulan B1), atau
   pertahankan rantai RPG lama dan cuma perbaiki langkah buntu?
3. **Quest utama v0.5:** setuju lingkupnya = Act 1 Ashbrook penuh (A1+A2+A3+metrik
   senyap), endgame tetap v1.0? Dan **A2 "Selamat pagi. Butuh kamar?"** — himpunan
   dialog sesudah-lupa Merrit menunggu tulisan tanganmu (2-4 baris).
4. **Quest pribadi:** empat usulan gelombang 1 (Merrit/Halloran/Bram/Nyai) — setuju
   isinya, atau ada yang mau kau tulis sendiri?
