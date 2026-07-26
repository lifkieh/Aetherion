# RENCANA — COMPANION IRISAN v0.5: SORA & ARLEN
**Status: DIKETOK Direktur 2026-07-26 (#295)** — K1 proxy-Ashbrook · K2 kejam-penuh · K3 loss_by_missing_kind · K4 bangun-sekarang · K5 surat-lamaran-kurir · K6 S1→S4 · K7 draft-provisional.
Sumber kanon: `companion_13_sora_lanternwick.md` · `companion_01_arlen_vale.md` ·
bible A2 §5 (sinyal Sora) · bible A3 §4 (jalur Sora) · #122 · #224 · #228 · #229.1 · D-3/D-4.

> Tandai langsung di dokumen ini / balas nomor keputusannya (K1–K7).
> Setiap ⚖ = titik yang bisa kamu benarkan sebelum eksekusi.

---

## 0. YANG SUDAH ADA (tidak dibangun ulang)

| Sudah ada | Di mana |
|---|---|
| Sprite Sora (teen, swoop_side, lentera+glow) | `characters/sora.json`, terpasang statis di Ashbrook (672,1024) |
| Sprite Arlen (teen, parted2) + kesaksian `orang` | #294 — berdiri (726,570), titik "Arlen [E]" |
| `SCRIBE_SORA` (2 jenis bukti) di Chronicle | `Chronicle.gd:46` — belum ada UI/jalurnya |
| Mesin jadwal-observe (temani = berada dekat N detik) | `QuestPribadi.nyai_temani` — khusus Nyai, belum generik |
| Sudut timur-laut pemakaman SENGAJA kosong nisan | `Ashbrook64.gd:598` — dirancang untuk ritual Sora |
| Pemakaman Ashbrook: pm=(624,1216), 460×190 | `_pemakaman_dan_kabut()` |

---

## 1. LINGKUP — apa yang v0.5 BANGUN dan TIDAK

**Bangun:** Sora sebagai ORANG (ritual, rekrut lewat tindakan, sinyal A2, jalur juru-tulis
Sora + jebakannya) · Arlen langkah 1–2 dari Life Event Chain (pertemuan + pintu pertama
murah) · batu penanda utara.

**TIDAK bangun (v0.6+, dicatat utang):** follower tempur/party · kegagalan Arlen (uji
Effort, chain #3) · jangkar Corvin (chain #4) · penggusuran makam Candyveil · Item
Penglihat Potensi · umur NPC penuh · Domain.

⚖ **K1 — LOKASI SORA.** Kanon: pemakaman pinggiran **Candyveil**. Realita v0.5: satu-satunya
dunia hidup = Ashbrook, dan sudut kosong pemakamannya sudah disiapkan untuknya.
- **(a) REKOMENDASI:** v0.5 Sora beritual di pemakaman **Ashbrook**; dicatat di ledger
  sebagai proxy — saat Candyveil punya dunia 32px, ia PULANG ke kanonnya, dan versi
  Ashbrook dibaca "ia berkeliling; makam terlupakan ada di mana-mana".
- (b) Tulis ulang kanonnya: Sora memang anak Ashbrook (mengedit sheet #013 — mahal,
  menyentuh relasi Candyveil/penggusuran).
- (c) Tunda seluruh Sora sampai Candyveil dibangun.

---

## 2. SORA — layout & rantai

### 2.1 Kehadiran (jam WIB nyata, #159)
- **Malam (19–24 WIB):** Sora di sudut TIMUR-LAUT pemakaman — `Vector2(814, 1139)` *(koordinat kanonik yang sudah menunggu di kode — `Ashbrook64.gd:598`)*
  (dalam pagar, sudut yang dikosongkan nisan). Di dekatnya 2–3 lampu kecil menyala
  (sprite `lentera32` skala kecil + PointLight redup). Ini satu-satunya cahaya pemakaman.
- **Siang:** posisi lamanya (672,1024), duduk/berdiri diam — figur latar, D-3, tak
  menonjol. (Pemain yang tak pernah keluar malam TIDAK pernah tahu ritualnya — sah, #228.)
- Label interaksi netral: `"Anak berlentera [E]"` — namanya baru dipakai SETELAH kenal.

### 2.2 Rekrut = MENEMANI RITUAL (bukan menu — #122)
Mesin `nyai_temani` digenerikkan: `Temani.mulai(id, pos, detik)` (radius 120, menjauh = ulang).
1. **Malam pertama bicara:** dialog ganjil (draft, provisional):
   - *"Yang ini belum. Sebentar."* (ia menyalakan lampu dulu, baru menoleh)
   - *"Kau bukan orang sini. Orang sini tidak datang malam-malam."*
   - *"...Kau boleh ikut. Asal tidak bilang lampunya buang-buang minyak."*
2. **Menemani:** berada ≤120 px selama **10 detik** × **2 nisan** (ia berpindah sekali;
   titik kedua `(624, 1240)` — tengah pemakaman, baris nisan terbuka). Selesai → `sora_kenal = 1` (senyap).
3. **Sesudah kenal:** baris barunya terbuka (E8) — termasuk baris kunci #224:
   - *"Kadang aku bangun dan tahu ada yang harus dinyalakan. Jangan tanya dari mana tahunya."*

### 2.3 Sinyal A2 (bible A2 §5 — verbatim)
Bila `a2_sudah == 1` **dan** `sora_kenal == 1` **dan** halaman Merrit masih tercoret:
malam itu ada **satu lampu ekstra** di titik ritualnya (visual saja). Ditanya:
- *"Nggak tahu. Cuma... ada yang perlu."*
⛔ Ia TIDAK tahu itu Merrit. Tak ada penjelasan, selamanya (#229.4). Pemain tanpa Sora
tak mendapat isyarat apa pun (#228 — sah).

### 2.4 Jalur juru-tulis SORA di Kitab (bible A3 §4)
- Gerbang: `sora_kenal == 1` (pola sama dengan `elyn_kenal` #294).
- Tombol ketiga di layar pilih-jalur: **"Minta Sora menuliskannya"** — 2 jenis bukti,
  loss sedang. Keterbukaan pra-konfirmasi (#259, sejajar Elyn): *"Sora akan menulis ini.
  Ia merasakan lebih banyak dari yang ia ceritakan, dan tiap halaman menambah beratnya."*
- **JEBAKAN "coba dua" (inti adegan):** bila KEDUA halaman orang tercoret dan bukti
  cukup untuk ≥1 halaman, muncul tawaran Sora (bukan tombol pemain — kalimatnya):
  *"Aku bisa coba dua-duanya."* Pilihan pemain:
  - **Membiarkannya mencoba** → ia menulis SATU (yang buktinya cukup), GAGAL pada yang
    kedua. Tanpa pengumuman kegagalan. Ongkos senyap: `sora_beban += 2` (D-4).
  - **Menghentikannya** (memilihkan satu) → ia menulis satu, `sora_beban += 1`,
    *"...Oke."* — dan tidak bertanya kenapa.
- `sora_beban` = pencatat #229.1 ("tiap halaman menguatkan kepekaannya") — TIDAK PERNAH
  tampil; dibaca arc Sora v1.0 (cabang "Aku capek ingat" / retak).

⚖ **K2 — JEBAKAN SORA.** Konfirmasi bentuk di atas (membiarkan = niat baik yang
mematahkannya lebih cepat, tanpa diberi tahu). Alternatif lunak: sesudah gagal, SATU
kalimat samar dari Sora ("Kepalaku... berat, sedikit."). Rekomendasi: **tanpa kalimat** —
bible menulis "tidak ada yang memberitahunya".

⚖ **K3 — LOSS TEKS SORA.** `chronicle_losses.json` belum punya varian scribe-sora.
Rekomendasi: loss sedang = pakai `loss_by_missing_kind` yang sudah ada (jenis yang tak
dibawa), TANPA `loss_self` (itu khusus tangan pemain). Atau kamu tulis tangan 2 baris
khusus Sora (Otha + Merrit).

### 2.5 Adegan Nyai × Sora (kanon relasi paling lembut)
Kamis sore Nyai masih hidup + `sora_kenal`: malam Kamis itu **dua figur** di pemakaman —
Nyai dan Sora, lampu bersebelahan, TANPA dialog. Satu titik periksa netral:
*"Dua lampu. Tak ada yang bicara. Tak ada yang perlu."*
⚖ **K4 — bangun sekarang (ongkos kecil, payoff besar) atau simpan v0.6?** Rekomendasi: sekarang.

---

## 3. ARLEN — layout & rantai (langkah 1–2 saja)

### 3.1 Batu penanda utara (adegan pertemuan — chain #1)
- Prop baru `batu_penanda` di ujung jalan utara: `Vector2(820, 96)` — SEGARIS dengan
  titik "Tanah lapang" Merrit (820,240): rute utara jadi punya dua jangkar cerita.
  Sprite: `nisan_aus32` diperbesar? TIDAK — batu penanda ≠ nisan. Generator kecil
  `gen_batu_penanda.py` (#240): batu tegak polos + satu sisi aus.
- Teks periksa: *"Batu batas desa. Sisi utaranya lebih aus — disentuh, ribuan kali,
  oleh tangan yang sama."* (D-3: tak menyebut Arlen.)
- Arlen PINDAH: dari (726,570) ke sisi batu penanda `(868, 140)` siang hari *(koreksi mockup: (760,300) jatuh di fasad rumah Merrit)* —
  kurir memandangi rute. (Kesaksian `orang` Merrit ikut pindah — masih <130 px dari
  rumah singgah? TIDAK: kesaksiannya justru "melihat dari jalan" — jalan utara MASIH
  memandang teras rumah singgah? Tidak. → titik kesaksian TETAP (726,598) sebagai
  posisi MALAM-nya; siang di jalan utara. Dua posisi by jam, pola Nyai.)
- Dialognya (prop BICARA, E6 tak terlanggar — bukan persona ke-6):
  - *"Kau datang dari arah mana? Di sana seperti apa?"*
  - *"Aku kurir. Sebelas jalan. Hafal sampai lubang-lubangnya."*
  - *"Sampai batu itu. Aku selalu sampai batu itu."*

### 3.2 Pintu pertama yang murah (chain #2 — #122: dari dialog, menerima = melakukan)
- Bicara ke-3 dengan Arlen → ia menitipkan **paket kecil untuk Sela** (cabang Serikat
  Greenvale): *"Kalau kau ke Greenvale... ini. Bukan apa-apa. Cuma belum pernah ada
  yang kubawa sampai sana."* → `arlen_titipan = 1` + item `paket_arlen` (berat 0).
- Serahkan ke Sela (dialog Sela bertambah satu baris saat membawa paket) →
  `arlen_titipan = 2`, item hilang.
- **Pulang ke Ashbrook:** Arlen BERUBAH (E8): dua hari WIB nyata sesudahnya baris-barisnya
  diganti set "bicara tanpa henti" (*"Sela bilang tanganku cepat. SELA. Yang di
  Greenvale!"*), lalu kembali normal + satu baris permanen baru:
  *"Suratnya sampai. Aku yang membawanya."*
⚖ **K5 — ISI TITIPAN.** Rekomendasi: surat lamaran kurir Serikat yang tak pernah berani
ia kirim (SELARAS Serikat #291-4 & mimpi kurirnya; membuka chain #3 "kegagalan" di v0.6
= kontrak Serikat pertamanya). Alternatif: sekadar paket dagang.

---

## 4. TEKNIS

| Komponen | Bentuk |
|---|---|
| State | `WorldState.counters`: `sora_kenal` · `sora_temani_n` · `sora_beban` · `arlen_bicara_n` · `arlen_titipan` (0/1/2) · `arlen_pulang_hari` (stempel hari WIB) |
| Mesin temani | Generalisasi `QuestPribadi.nyai_temani` → `func temani(id, pos, detik, on_selesai)`; Nyai dimigrasikan ke mesin yang sama (perilaku TIDAK berubah — test #291-3 harus tetap hijau) |
| Sora scribe UI | `MenuUI._kitab_prompt_path`: tombol ketiga bergerbang `sora_kenal`; layar keterbukaan `#259` sendiri; `restore(id, w, SCRIBE_SORA)` + `sora_beban` |
| Jam kehadiran | pola dua-posisi by `GameClock.wib_hour()` (siang/malam) — sudah ada preseden `NpcSchedule` |
| Sprite baru | HANYA `batu_penanda` (generator) + lampu kecil (pakai `lentera32` yang ada). Nol tokoh baru |
| Data | `town_npcs`? TIDAK — Sora & Arlen bukan persona Villager (E6 tetap 5); dialog lewat prop BICARA yang barisnya dipilih saat build scene dari state |
| Save | nol field baru (semua di counters yang sudah persisted) |

## 5. TEST (perkiraan 20–24 cek, #151b)
1. Sora malam ada di sudut TL pemakaman, siang tidak; label netral sebelum kenal.
2. Temani 2 titik → `sora_kenal`; menjauh = ulang; SENYAP (saring toast).
3. Sinyal A2: lampu ekstra HANYA bila a2+kenal+struck; baris "Nggak tahu. Cuma... ada yang perlu."
4. Kitab: tombol Sora tak ada sebelum kenal; ada sesudah; restore 2 jenis jalan; `sora_beban` bertambah; jebakan dua-halaman: biarkan → 1 pulih + beban 2 + NOL pengumuman gagal.
5. Nyai×Sora Kamis malam (bila K4=ya): dua figur + titik periksa.
6. Arlen: batu penanda ada + teks; dialog rotasi; bicara ke-3 → paket; Sela terima → titipan=2; pulang → baris berubah 2 hari → baris permanen. E6: persona ashbrook tetap 5.
7. Regresi: `_test_quest_pribadi_291` (Nyai via mesin temani baru) tetap hijau.

## 6. URUTAN & ONGKOS
| Paket | Isi | Ongkos |
|---|---|---|
| S1 | Mesin temani generik + kehadiran Sora siang/malam + rekrut ritual | sedang |
| S2 | Jalur Sora Kitab + jebakan + ongkos senyap + sinyal A2 | sedang |
| S3 | Batu penanda + Arlen dua-posisi + titipan Sela | sedang |
| S4 | Nyai×Sora Kamis malam (bila K4=ya) | kecil |

⚖ **K6 — URUTAN.** Rekomendasi: S1→S2→S3→S4 (Sora dulu — ia menyentuh A2/A3 yang baru
hangat). Alternatif: Arlen dulu (lebih murah, payoff cepat).

⚖ **K7 — DIALOG.** Semua baris di dokumen ini = draft provisional (sebagian verbatim
bible). Pakai dulu + kamu timpa kapan saja (data-driven), atau tunggu tulisan tanganmu
untuk: (a) 3 baris pertemuan Sora, (b) 3 baris Arlen, (c) 2 baris loss Sora (K3)?
Rekomendasi: pakai dulu, tandai `_provisional` di data.

---
## RINGKASAN KEPUTUSAN
| # | Soal | Rekomendasi |
|---|---|---|
| K1 | Lokasi Sora v0.5 | (a) proxy pemakaman Ashbrook, utang kanon dicatat |
| K2 | Jebakan "coba dua" | kejam penuh — tanpa kalimat sesudah gagal |
| K3 | Teks loss Sora | pakai `loss_by_missing_kind` yang ada (atau tulis tanganmu) |
| K4 | Adegan Nyai×Sora | bangun sekarang |
| K5 | Isi titipan Arlen | surat lamaran kurir Serikat |
| K6 | Urutan | S1→S2→S3→S4 |
| K7 | Dialog | draft provisional dipakai dulu |
