# AETHERION — SNAPSHOT KONTEKS PROYEK

**Dibuat:** 2026-07-19 · **Untuk:** Direktur · Designer · sesi baru mana pun
**Tujuan:** memahami seluruh keadaan proyek **tanpa** membaca ulang 244 baris ledger.
**Aturan dokumen ini:** jujur. Yang belum dikode disebut belum dikode. Konflik disebut konflik.

---

## 1 — IDENTITAS & TESIS

**Aetherion** — RPG 2D top-down *offline-first*, **Godot 4.3**, GDScript, teks dua jalur ID/EN.
Dunia hidup terikat **waktu WIB nyata** (jam, musim 14-hari, fase bulan, cuaca) — dunia berjalan
walau game ditutup.

**Tesis: MEMORI vs PELUPAAN.** Pertanyaan sentral: *"Apakah sesuatu tetap layak dibangun walau
akan hilang?"* **Sang Nirnama adalah sebuah PERTANYAAN, bukan protagonis** — ia percaya segala
sesuatu akan hilang, dan pemain **tidak dipaksa membantahnya**. Konflik sentral bukan
pemain-vs-Nirnama, melainkan **INGIN-LUPA vs MENOLAK-LUPA**.

**Pilar:** (a) **Chronicle** — halaman dunia bisa **tercoret** dan **ditulis ulang dari bukti**;
(b) **Hukum Bukti (#226)** — pemain menyimpulkan dari objek, bukan dari papan info;
(c) **50 Great Companion** bergaya Suikoden; (d) **Legacy/generasi**; (e) **dunia yang tetap HIDUP
meski kehilangan** — tiap detail keruntuhan wajib berpasangan dengan detail kehidupan.

---

## 2 — STATUS BUILD SEKARANG

**Fase: v0.5 (STORY & SOUL).** Suite: **1026 assertion lulus, 0 gagal** (diukur 2026-07-19).
> ⚠ Angka test **tidak deterministik lintas tanggal** — sebagian test bercabang menurut kalender
> WIB (#249). **Gerbang = `0 gagal`, bukan jumlah lulus.** "947" adalah angka hantu lama.

### ✅ HIDUP — sudah dikode, dijalankan, terlihat di layar
Diverifikasi dengan menjalankan & men-screenshot **21 scene** (2026-07-19, `reports/SWEEP_GAME.md`):
nol crash, nol error muat aset.

| | |
|---|---|
| **Wilayah** | Ashbrook (desa-bekas-kota) · Greenvale/`Main` · Frostpeak · Desert · Candyveil · StormIsland · HouseInterior |
| **Dungeon** | GreenvaleDepths · GummyCavern · Barrow · FoothillBarrow · ZephyrSpire (side-view, terrain bisa ditambang) |
| **Skenario** | LunarWarren · StarWhaleBelly · TeaParty |
| **UI** | MainMenu · ClassSelect · CharacterCreator · Intro · HUD · PauseMenu · WorldMap · TravelUI · 11 tab menu (inventory · crafting · shop · quest · skill · sky · trees · enchant · auction · echo · panduan) |
| **Data hidup** | 60 monster · 126 item · 35 skill · 37 resep · 2 tanaman · 3 skenario |
| **Sistem** | tempur+elemen+fusion · profesi (1 main + 2 sub) · homestead/tani · memancing · pet/evolusi · enchant +1..+10 · lelang · jadwal NPC (#97) · musim · rasi+ramalan · cuaca+prakiraan · fase bulan · Advanced Class · foto-mode · lokalisasi ID/EN |
| **Chronicle (parsial)** | `Evidence.find()` **jalan** — 6 titik-periksa Ashbrook bisa diperiksa dan menandai bukti |

### 📄 SPEC / DOKUMEN — belum dikode
`CHRONICLE_RESTORATION_SPEC.md` · `PERAKIT_SPEC.md` · `PROP_IDENTITAS_SPEC.md` ·
`A1_PENGHAPUSAN_PERTAMA.md` · `A3_TRIASE.md` · `DUNGEON_ORIGINS.md` · Domain 5-tier ·
Legacy/generasi · breeding · rival · online/co-op.

### 🔴 DIBANGUN TAPI TAK TER-WIRE (temuan sweep — paling menentukan)
- **Payoff core loop tak punya jalan pemain.** `Chronicle.strike()`, `Chronicle.restore()`,
  `Evidence.enough_for()` dipanggil dari **NOL** scene produksi. Pemain bisa memeriksa 6 objek
  lalu **tidak terjadi apa-apa selamanya**. 3 halaman `chronicle_losses.json` → pemain mencapai **0**.
  Test-nya hijau karena memanggil API **langsung**, bukan lewat pintu pemain.
  *(Mesinnya terbukti jalan di scene LPC — lihat §9 — tapi belum di scene 16px yang dimainkan.)*
- **Elyn tidak ada di dunia** — nol NPC, nol perpustakaan, nol laci (A3 = 0%).
- **8 dari 14 bukti tak ter-wire** — A1 Otha 1/4, A2 Merrit 0/4.
- **Homestead:** 4 label `Tanam [E]` bertumpuk → tak terbaca.
- **`props/chicken.png` hilang** (jalur salah; seninya ada di `sprites/animals/`).

---

## 3 — ROADMAP

**Baru selesai (14 sesi terakhir):** Ashbrook v0.5 (desa + bukti + jadwal NPC) · papan Otha 3 varian ·
lentera & bangku Merrit · 3 ubin tanah Ashbrook · pemisahan bench/workbench · pemulihan HUKUM
REPRODUKSI #240 · sweep 21 scene · migrasi Ashbrook ke LPC (kandidat).

**Sedang dikerjakan:** migrasi visual ke LPC (#254) — **satu scene dulu**, Ashbrook64 sebagai template.

**Berikutnya (urut dampak ke pemain):**
1. **Sambungkan payoff core loop** — tanpa ini seluruh tesis tak tersentuh pemain.
2. Fasad bangunan LPC (dinding+atap+pintu) agar terbaca sebagai rumah.
3. Perbaiki siluet **Halloran ↔ Old Bram** (#231 dilanggar).
4. Label Homestead + `chicken.png` (murah, terlihat).
5. Bukti A1/A2 sisa (teks sudah ada, objek belum).

**Gerbang yang MENAHAN v0.5:**
| Gerbang | Status |
|---|---|
| **B17 Companion Bible** | **15 / 50** — gelombang 2 terkunci (#190) |
| **B18 Nirnama Bible** | `NIRNAMA_BIBLE_PUBLIC.md` **v2.1** ada (versi redaksi; 3 hal di `docs_private/`) |

---

## 4 — KEPUTUSAN KANON PALING MENENTUKAN

| # | Isi |
|---|---|
| **#75** | Hukum Direktur #1 — Gerbang Pilar (E1) |
| **#78** | Hukum NPC Aneh — warga tak boleh generik |
| **#89** | Hukum Simulasi Dunia — dunia jalan tanpa pemain |
| **#97** | Jadwal NPC — malam mereka pulang; kota yang menutup pintu |
| **#104** | Companion Bible dikanonisasi (B17) |
| **#137** | Hukum Pertumbuhan NPC — masa depan tiap NPC = "???" |
| **#144** | Rahasia produksi hanya di `docs_private/` (tak pernah di-commit) |
| **#151 / #151b** | **Test wajib lewat pintu pemain, dan wajib MENGUKUR DUNIA** — bukan string/data |
| **#166** | Lokalisasi dua jalur ID/EN |
| **#187** | Hukum Penulisan Nirnama — kerapian sebab-akibat DILARANG |
| **#204** | Hukum Peta Dunia — jalan antar kota harus hidup |
| **#206/#216** | Ashbrook = desa-bekas-kota; **hidup, bukan hanya sedih** |
| **#210** | **TUNJUKKAN, JANGAN PAPAN-INFORMASIKAN** |
| **#219** | Hukum Direktur #2 — Bible = HUKUM, GDD = ISI |
| **#226** | **HUKUM BUKTI** — bukti dari objek; D-3 nol penanda, D-4 nol angka |
| **#228** | Hukum Direktur #3 — **pemain SENDIRIAN bisa memulihkan** (butuh 3 jenis bukti) |
| **#229** | Hukum Direktur #4 — KEKEJAMAN; hook siluet |
| **#231** | Dua tokoh bernama **tak boleh berbagi hook siluet** (HARD-FAIL di perakit) |
| **#240** | **HUKUM REPRODUKSI** — tiap gambar wajib membawa script pembuatnya, ter-commit |
| **#244/#248** | "Art tanpa konsumen = art mati" |
| **#249** | **Gerbang = 0 gagal, bukan jumlah lulus** (angka test terikat kalender) |
| **#250→#253→#254** | Skala visual: LPC → 16px → **LPC lagi** (lihat §7 "kanon menggantung") |
| **#251** | Koreksi: `_tools/` ter-gitignore → **nol generator pernah ter-commit**; diperbaiki |
| **#254** | **#232 DICABUT** — seluruh aset boleh publik/CC-BY-SA. LPC = sumber tunggal |
| **#255** | Portrait = gap identitas, **buatan sendiri, ditangguhkan sengaja** |

---

## 5 — DUNIA & CERITA

| Kitab | Status |
|---|---|
| **Nirnama Bible** | **v2.1**, versi redaksi publik. 3 hal (nama asli dll) hanya di `docs_private/` (#108/#144) |
| **Companion Bible** | **15 / 50** — B17 belum tertutup. Gelombang 2 terkunci (#190) |
| **Kingdom / Faction** | `FACTION_BIBLE.md` **LOCKED** — The First Seven Kingdoms of Aurelia |
| **City Bible** | **LOCKED** |
| **Divine Bible** | **SEED** — nama & domain dikunci; kepribadian/agenda/gereja **masih terbuka** |
| **Dungeon Origins** | teks kanon (spec), sebagian sudah dibangun (peti, jebakan, ruang rahasia) |

**Kanon kuat:** tesis Memori-vs-Pelupaan · Nirnama sebagai pertanyaan · Ashbrook (Merrit · Otha ·
Old Bram · Nyai Tuminah · Halloran · Sora · Lyra · Arlen) · Celestia = semua ras · Act 2 dibuka
oleh **bulan retak** (v0.8).

**Masih terbuka:** 35 companion sisa · kepribadian dewa · identitas *The Last Witness* ·
peran Elyn dalam Chronicle (ada di kode, nol di dunia).

---

## 6 — ASET

| | |
|---|---|
| `assets_raw/` | ~**5,6 GB** gudang mentah, **gitignored**, tak pernah masuk build |
| `assets_aetherion/` | **141 berkas** terkurasi (CC0 / milik proyek) |
| `game/assets/` | **264 PNG** + audio (18 musik · 48 sfx · 10 stinger) — semua terverifikasi ada |
| `assets_publikasi/` | 19 berkas — LICENSE CC-BY-SA 3.0 & 4.0, CREDITS.md, 9 `source_credits/` |

**Terverifikasi lengkap:** font `m5x7` · 126/126 ikon item (per-kategori) · 17 ikon elemen ·
8 fase bulan · 27 glyph input.

**Baru masuk (#254):** Mage City Arcanos (Hyptosis, **CC0**) → 13 potongan dunia 32px ·
6 tokoh ULPC dirakit `_tools/lpc_assembler/`.

**⚠ Skala — fakta yang sering disalahpahami:** **tak ada tileset LPC 64px.**
Standar LPC = **ubin dunia 32×32 + frame karakter 64×64**. "64" mengacu pada kanvas karakter.
Jadi migrasi #254 = petak **16→32**, karakter **32→64 frame**. Bukan 4×.

**Belum terpenuhi:** portrait (ditangguhkan sengaja, #255) · fasad bangunan LPC utuh ·
interior LPC belum diuji · **nol pembelian aset diperlukan** — LPC menutup dunia/monster/efek/item.

---

## 7 — UTANG & PENDING

**Menunggu putusan Direktur:**
1. **Siluet Halloran ↔ Old Bram kembar** (#231 dilanggar) — usul: Bram diberi topi, atau botak-berjanggut.
2. **Lisensi Cainos "Pixel Art Top Down Basic"** (32px, di `assets_raw/_extract/`) — nol berkas
   lisensi; perlu email `support@cainos.net`.
3. Apakah Ashbrook64 (LPC) **menggantikan** Ashbrook 16px, atau keduanya hidup sementara.
4. `_charsys` — kapan dipensiunkan sungguhan (masih dipanggil **7 berkas / 30 tempat**,
   termasuk **bentuk simpanan** `PlayerData.char_config` → butuh migrasi save).

**Playtest yang belum dilakukan:** v0.4.2 · v0.4.3 · v0.4.4 semuanya bergerbang "playtest" —
**tak ada catatan playtest manusia** di repo. 10 checklist "SIAP DIMAINKAN" (§6.1 proposal) belum diuji.

**Kanon menggantung / konflik:**
- **Skala visual berbalik tiga kali** dalam dua hari: #250 (LPC) → #253 (tetap 16px) → #254 (LPC lagi).
  Sekarang berlaku **#254**, tapi `Ashbrook.gd` 16px masih scene yang dimainkan. Perlu satu putusan penutup.
- **#248 salah mengutip** "art tanpa konsumen" sebagai #240; sebenarnya #244/#248.
- **43 dari 45 PNG di `reports/preview/` tak punya generator** — melanggar #240 secara surut,
  tak bisa dipulihkan (script sekali-pakai lenyap).
- **`_work/tmp/*.ogg`** (14 berkas) sudah terlanjur ter-commit sebelum `_work/` di-gitignore.

---

## 8 — HUKUM PROYEK (jangan dilanggar sesi baru)

1. **#151b** — test wajib **mengukur dunia nyata** (scene terinstansiasi, posisi, state runtime),
   bukan string/data. Memeriksa array = **hijau-palsu**.
2. **#151** — test wajib masuk lewat **pintu yang dipakai pemain**.
3. **#249** — gerbang = **`0 gagal`**. Jumlah lulus **dilarang** jadi gerbang.
4. **#240** — tiap gambar prosedural wajib membawa **script pembuatnya, ter-commit**.
   Klaim "ter-commit" **wajib** dibuktikan `git ls-files`, bukan keberadaan berkas di disk.
5. **#210 / D-3 / D-4** — tunjukkan jangan papan-informasikan; nol penanda "!"; nol angka progres.
6. **Aturan ledger** — tiap arahan owner = **baris Decision Log sebelum dikerjakan**;
   koreksi = **baris baru**, jangan hapus baris lama.
7. **Lisensi** — cek **PER-BERKAS**; **nama folder BUKAN lisensi**; "free to use" = TIDAK DIKETAHUI = TOLAK
   (pelajaran `80-CC0-RPG-SFX`).
8. **#231** — dua tokoh bernama tak boleh berbagi hook siluet. Uji **siluet hitam bersebelahan**.
9. **#144** — rahasia produksi hanya `docs_private/`, tak pernah di-commit.
10. **Agen tak menghapus apa pun di luar repo** — repo punya git; Desktop tidak.
11. **Pelajaran berulang:** hal rusak di game ini **selalu ketemu dari LAYAR**, bukan dari kode.
    Lentera=kotak · Ashbrook=kehitaman · grass=hilang · core loop tak tersambung — **semua lolos test.**

---

## 9 — TITIK MEJA SEKARANG

**Yang baru saja selesai (commit `8aaa014`):** Ashbrook dimigrasikan ke LPC sebagai **kandidat**
(`game/scenes/world/Ashbrook64.tscn`) — dunia Mage City 32px, 6 NPC ULPC 64px, lentera menyala,
6 titik-periksa. **`Ashbrook.tscn` 16px tidak disentuh** dan masih scene yang dimainkan.

**Terbukti dengan menjalankan** (`game/tests/VerifyLoop64.gd`), bukan diasumsikan:
```
6/6 titik-periksa terbaca · 3 jenis bukti (akibat·benda·kebiasaan)
halaman tercoret · cukup jalur SENDIRI (#228) · PULIH
loss: "Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus orang."
lampu Merrit menyala
```
Artinya: **core loop utuh di scene LPC** — logika tak rusak oleh pergantian wajah.
Tapi di scene 16px yang **dimainkan**, payoff itu **masih tak punya jalan pemain**.

**Langkah berikutnya yang sudah disepakati:** Ashbrook64 jadi **template** untuk scene lain —
**satu scene dulu**, nol migrasi massal sampai layar bukti meyakinkan.

**Tiga hal yang menunggu Anda sebelum melangkah:**
1. Siluet **Halloran ↔ Bram** kembar — perlu putusan bentuk.
2. Fasad bangunan LPC masih terbaca sebagai dinding, bukan rumah.
3. Ashbrook64 **menggantikan** atau **mendampingi** Ashbrook 16px?
