# INDEX — ARSIP BIBLE AETHERION

**Status:** arsip sumber (**tidak diedit**). **9 berkas · 50.435 baris**. Dibaca sebagai
satu korpus 2026-07-13 (Direktif Bible Folder Ingestion).

> ⚠ **CATATAN EJAAN (WAJIB DIBACA):** sumber-sumber ini menulis **"Nirmana"**.
> **Ejaan resmi proyek tetap "Nirnama"** (Q1, Decision Log #108). Jangan menyalin
> ejaan sumber ke kode, data, dialog, atau dokumen turunan. Arsip sengaja **tidak
> diperbaiki** agar tetap otentik sebagai sumber.

> ⚠ **DUA "WORLD BIBLE PART 02" BERBEDA** (risiko kanon ganda — pertanyaan Q19 di
> REPORT-05): (a) berkas utama FILE 10 (scope: Intelligent Races + Civilization —
> inilah rujukan `docs/RAS_KANON.md`); (b) part 5 Part 02 (scope: Civilization
> Philosophy). Penomoran perlu diputuskan Direktur.

---

## Peta berkas

| Berkas | Baris | Isi | Status vs game | Sistem terdampak |
|---|---|---|---|---|
| **Aetherion_blueprint_reasoning and design.txt** | 16.510 | Konsepsi induk: World Philosophy, Story Foundation, **Nirnama Bible (FILE 04)**, Companion Philosophy (05), **Companion Bible Part 02 = 10 Great Companion (FILE 13)**, kategori Companion, Social Archetypes (Oddwalkers, Hidden Legends, Keepers of Names), Netherdeep Syndicate, **8 Ras (FILE 10)** | **Sudah dikanonisasi** (#67, #86, #102–#114) | CharGen, ras, companion, Nirnama Bible |
| **…part 2.txt** | 6.931 | **16 Bible**: Monster (32–33), Geopolitics (34), Recruitment (35), Time & Legacy (36), Death & Consequence (37), Magic (38), Artifact (39), Dungeon (40), Companion (41), Early Game (42), Living World (43), Monster Taming (44), Class & Skill Tree (45), Profession (46), Economy & Trade (47) | **Konflik besar → K1–K9 (#115–#123)**; sisanya di REPORT-05 | Enchant/crafting, pohon skill, class, dungeon, revive, opening, ekonomi, profesi |
| **…part 3.txt** | 12.990 | Kingdom War (48), Religion & Faith (49), World History (50), **Mystery & Discovery (51)**, **Dragon Bible (52)**, Great Monster (53), **Faction Bible 01–06 (54–59)**, **Nirmana Bible (60+)** | **Sebagian besar BARU** (faksi, agama, perang, naga) + konflik taming-naga & mukjizat | Faksi/reputasi, taming, MiracleSystem, Chronicle, Paladin |
| **…part 4.txt** | 3.889 | **Nirmana Bible Part 07–11** (FILE 68–72): The Final Answer, Children of the Void, **The Last Dragon**, The Return of the End, **5 ENDING** | **Konflik dengan NIRNAMA_BIBLE.md kita** (sumbu konflik, sejarah, nasib naga) | Story v0.5+, ending, Chronicle-as-judge |
| **…part 5.txt** | 6.884 | **WORLD BIBLE v1.0 (TIER S #02, LOCKED)** — 10 bab filosofi: Core, Civilization, Exploration, Life & Death, Conflict, Progression, Freedom, Legacy, Time, Synthesis | **Konstitusi.** Nol konten baru, **19 hukum mengikat** — menabrak 8 keputusan kita | Permadeath, Ecology, 5 atribut kerajaan, 7 tahap permukiman, fusion, penjaga abadi |
| **Menurutku Aetherion Harus Punya 3 P.txt** | 904 | **3 Pilar** (Wonder/Belonging/Legacy), Living Sky, The World Remembers, **daftar tahan** (Racing/Gambling/Marketplace/MMO), urutan produksi Bible, target = **v0.5 STORY & SOUL** | **Sebagian sudah jadi kanon** (#34–#37, #67 menambah STEWARDSHIP jadi 4 pilar) | Piagam, roadmap |
| **Aetherion_pelengkap.txt** | 1.135 | **META — taksonomi dokumen**: Tier A (10 System Bible) · **Tier A+ META** (Player Motivation, Retention, **Endgame**, Content Longevity, **Emotional Design**) · Tier B/B+/C/D · **5 fase penulisan** (Phase 0 THE SOUL ✅ → THE PAST → THE PRESENT → THE FUTURE) · **Content Pyramid** (Lore → Systems → Content → Data) · **4 Bible yang "masih hilang"**: Mythology · Language · Emotion · Mystery | **Bukan konten dunia** — ia mengatur *cara menulis*. Berbenturan dengan urutan gerbang kita (B17) | Perencanaan dokumen |
| **Game_Design_System.txt** | 741 | **META — STANDAR PRODUKSI (Tier A–D)**: aturan mengikat per jenis konten — *monster wajib punya habitat/diet/perilaku/peran ekologi/asal-usul* · *boss = **peristiwa**, bukan HP besar* · *dungeon wajib menceritakan sesuatu* · *quest wajib menjawab "kenapa pemain peduli?"* · *lokasi wajib punya alasan dibangun / alasan masih ada / alasan pemain datang* · *item wajib punya fungsi+sumber+nilai* · *skill wajib punya identitas+kegunaan+**counterplay*** · **skill tree HORIZONTAL dulu, vertikal kemudian** · *tidak boleh ada ekonomi palsu* · *multiplayer tanpa saling membunuh* | **Sebagian sudah kita patuhi** (DUNGEON_ORIGINS, Hukum Quest); sebagian **belum** (monster tanpa habitat/diet; skill tanpa counterplay) | monsters.json, skills.json, items.json, wilayah |
| **game design roadmap.txt** | 451 | Audit Tier S–E + **MASTER DESIGN ROADMAP** (roadmap **kelengkapan DOKUMEN**, bukan rilis): prioritas Faction → Companion → Nirmana → World Map → Main Story; total dokumen 150–250 file | **Beda jenis** dari roadmap rilis kita (v0.5→v1.0) — 5 titik beda, lihat REPORT-05 | Perencanaan |

---

## Baris penting (rujukan cepat)

**Berkas induk**
- FILE 04 Nirnama Bible — b.492 · FILE 05 Companion Philosophy — b.710
- FILE 10 World Bible Part 02 (8 Ras) — b.4703 · FILE 13 10 Great Companion — b.7108
- Kategori Companion (8 kategori + kuota) — b.6776 · Oddwalkers/Hidden Legends — b.5312

**Part 2**
- Monster: 10 spesies naga × 5 = **≈50 naga** — b.362 · Dragon Exception — b.355
- Artifact Bible (larangan tangga angka) — FILE 39, b.2911 · 6 tier artefak
- Class & Skill Tree: **6 Knowledge Tree**, larangan "skill tree per class" — FILE 45, b.5599
- Early Game: **NO DESTINY**, monster pertama ≠ legendaris — FILE 42, b.4142
- Death: **kebangkitan selalu berharga** — FILE 37, b.2021

**Part 3**
- **50 naga** (konfirmasi kedua) — b.1027, b.1755 · **7 tipe naga** (3 belum bernama) — b.1890
- **Naga MEMILIH, bukan ditangkap** — b.1989 · Great Monster 6 kategori — b.2185
- Mukjizat **sangat langka** — b.634 · Dewa Absolut tanpa gereja — b.523 · **5 Tahta Ilahi belum dikunci** — b.547
- Faction: skala 5 tingkat — b.3135 · **Influence 6 sumbu** — b.3365 · larangan "faksi baik vs jahat" — b.3027
- **"Not everything should be found"** — b.1385 · "kalau pemain tahu semuanya, Aetherion GAGAL" — b.1664
- Kontradiksi internal: perang peradaban-vs-monster (b.220) **vs** "tak pernah ada perang besar manusia–monster" (b.1188, b.6499)

**Part 4**
- 5 kelompok pewaris kehampaan (FILE 69) · **The Last Dragon = The Watcher** (FILE 70)
- **5 ENDING** (Dawn / Final Silence / Last Sky / Broken Answer / **The World Remembers**) — FILE 72
- Larangan: **tidak ada ending sempurna**; **jawaban bukan sebuah kalimat dialog**

**Part 5 (WORLD BIBLE — konstitusi)**
- 4 Pilar — b.49 · **Player is NOT chosen** — b.4121 · **Permadeath + Replacement Rule** — b.288
- **5 Atribut Kerajaan** (termasuk **Ecology**) — b.814 · **7 tahap permukiman** — b.544
- Ecology bukan dekorasi — b.933 · **Monsters are not enemies** — b.2880
- **LOCKED: semua skill bisa dipelajari; kecuali Ultimate/Class Exclusive** — b.3526
- **LOCKED: Fusion = monster menyatu dengan PEMILIKNYA** (bukan fusi elemen) — b.3798
- Loss must be real: companion mati **tak bisa kembali** — b.2141

---

## Cara memakai arsip ini

1. **Jangan mengedit berkas sumber.** Koreksi/keputusan hidup di `PLAN_LEDGER.md`.
2. Konflik yang sudah diputus Direktur: **#115–#123** (K1–K9).
3. Konflik yang **belum** diputus: `reports/REPORT-05_KONFLIK_BIBLE.md`.
4. Rencana eksekusi: `docs/IMPLEMENTATION_ROADBOOK.md`.
5. Kebutuhan aset: `docs/ASSET_MANIFEST.md`.
