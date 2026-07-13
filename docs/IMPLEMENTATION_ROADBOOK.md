# IMPLEMENTATION ROADBOOK — Bible → Game

**Aturan yang dipatuhi:** **tidak menciptakan fase baru** — hanya mengisi fase yang
sudah ada (v0.5 → v1.0). **Gerbang dihormati: B17 Companion Bible 10/50 tetap menahan
v0.5.** Semua yang bergantung pada **K1 (skala waktu, #123)** ditandai ⏳ dan **tidak
boleh dibangun** sebelum owner menjawab.

**Kondisi awal:** Fase 0 (v0.4.x) **tuntas** — 753 test, 0 gagal. Yang sudah berdiri:
combat, 10 class, 28 pohon (kini ber-domain), profesi, taming, crafting/enchant,
Rumah Lelang, musim, rasi, dungeon (peti/rahasia/jebakan/parallax), jadwal NPC,
Chronicle (benih), cutscene engine, peta, lokalisasi, gamepad.

---

## v0.5 — STORY & SOUL
**Gerbang:** ✅ B18 Nirnama Bible (#114) · ❌ **B17 Companion Bible 10/50 — masih menahan**

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| **Companion Bible 50/50** (dokumen) | Companion Philosophy (05), Companion Bible (13, 41) | — | 2–3 sesi penulisan **bersama Direktur** | Kategori/kuota sudah ada; butuh 40 tokoh |
| **Opening kanon** (rework intro): pemain jatuh → **anak serigala terluka** (First Monster) → **Pegasus = First Mystery** | Early Game (42) + #118 | Cutscene engine ✅ | 0,5 sesi | — |
| **First Mystery lokal** ("lonceng tengah malam yang tak punya lonceng") + **First Legend** ("Bukit Kabut") | Early Game (42), Mystery (51) | Rumor system ✅ | 0,5 sesi | — |
| **Companion v1**: 3–5 tokoh Tier-S hidup di dunia; **rekrutmen BUKAN menu** (diyakinkan lewat perbuatan); Life Quest; **Argument System** (boleh tak setuju, boleh pergi) | Companion (41), Recruitment (35) | **B17 50/50** | 1,5–2 sesi | Siapa **First Companion** (wajib **bukan** yang terkuat) |
| **Act 1 Nirnama**: gejala penghapusan — wilayah memutih (mesin Forest Spirit dibalik), NPC tergagap, **The Erased** (musuh baru), satu pertemuan tanpa nama | NIRNAMA_BIBLE §VI, §IX | Cutscene ✅, StatusFx ✅ | 1,5 sesi | Sumbu konflik final (**Q18**) |
| **Chronicle: entri fragmen/rusak** + sembunyikan % penyelesaian | Mystery (51) b.1508/1664 | Chronicle ✅ | 0,3 sesi | **C7** |
| **Hidden Dungeon** pertama (dungeon utuh yang tersembunyi) + asal-usul 5 dungeon masuk ke dalam game (jurnal, artefak bercerita) | Dungeon (40) + `DUNGEON_ORIGINS.md` | — | 1 sesi | — |
| **Dual Class** (spec → implementasi) | Class & Skill Tree (45) + #117 | — | 1 sesi | Sudah diputus (#117) |
| **Rename**: fusi elemen tetap *Fusion*; penyatuan pemain–monster = **Sinkronisasi** | World Bible b.3798 | — | 0,1 sesi | **C4 / Q6** |

---

## v0.6 — HEARTH & LEGACY
**Tema:** dunia yang hidup tanpa pemain + markas yang tumbuh.

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| **Living HQ / Domain 5→7 tahap** (tambah Kingdom Capital & Great Civilization) | World Bible b.544, B1 (#46) | — | 2 sesi | **C15** (setuju 7 tahap?) |
| **5 Atribut Kerajaan** (Prosperity/Stability/Loyalty/Security/**Ecology**) menggantikan Stability 3-metrik | World Bible b.814 | — | 1 sesi | 🔴 **C3 / Q5** |
| **ECOLOGY v1**: populasi terbatas per wilayah, over-hunting → predator lapar → menyerang desa (perluasan mesin Forest Spirit) | World Bible b.933 | 5 atribut | 1,5 sesi | 🔴 **C3 / Q5** |
| **Reputasi & Faksi v1**: reputasi **lokal** (6 tingkat), **Influence 6 sumbu**, relasi faksi, reputasi **tidak universal** | Faction 01–08 (54–61) | **Reserve slot data (lakukan lebih awal!)** | 2–3 sesi | **C17 / Q27** |
| **World Remembers v1**: memori NPC, kematian & **Replacement Rule**, suksesi pemimpin | World Bible b.288/5704, Faction 08 | Reputasi | 2 sesi | **C1/C2/Q3/Q4** |
| **Chronicle menerima entri NPC/dunia** (bukan hanya pemain) | World Bible b.1097 | Reputasi | 0,5 sesi | **C8** |
| **BLACK MARKET** (barang > tier A, artefak ilegal, informasi) — terhubung Netherdeep | Faction 03 (56) + #121 | Reputasi | 1 sesi | Sudah diputus (#121) |
| **Companion Dungeon** (tipe VI) + **Raid Dungeon** (tipe III, butuh entourage) | Dungeon (40) | Companion v1, rekrutan | 1,5 sesi | — |
| **Rune / Runesmith**, profesi bible (Hunter, Tailor, Farmer, Rancher, Merchant, Scholar, Explorer) | Profession (46) + #122 | — | 1,5 sesi | Cook tetap (#122) |
| ⏳ **World history ledger** (peristiwa ireversibel offline) | World Bible b.5704 | **K1** | — | ⏳ **K1 #123** |

---

## v0.7 — HORIZON (Emberfall · Kerajaan Thalassar · Wildhearth)

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| **Benua & budaya baru**: Azhur (Thalassar/Tidekin), Nethrak (Wildhearth/Beastfolk), Sylvara (Elf/Ancient Jungle) | World Bible, Ras (#86), #110 | Aset (lihat MANIFEST) | 3–4 sesi | Fairy Realm → benua mana? |
| **Ras playable bertambah** (Elf ← Sylvara, Tidekin ← Azhur) — **ras = budaya, bukan stat** | RAS_KANON (#86) | CharGen | 1 sesi | — |
| **Monster multi-elemen** (1–3 elemen; 4+ langka) | Monster (32), Taming (44) + #122 | — | 1 sesi | — |
| **Monster cerdas** (tier 4–5): tidak masuk tabel loot; taming lewat **persetujuan**; membunuhnya berkonsekuensi | Faction 06, Taming (44) | Reputasi | 1,5 sesi | **C18/C19 / Q23/Q24** |
| **Naga Kuno (10 spesies × 5)**: **jalur Pact — mereka memilih**, keluar dari pipeline orb | Dragon (52) | Reputasi, monster cerdas | 2 sesi | **C5 / Q7** |
| ⏳ **Naval / laut** (Leviathan, kapal) | dirujuk, **Naval Bible belum ada** | Bible belum lahir | — | **Q14** |

---

## v0.8 — CELESTIA & CRISIS

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| **Celestial Crisis** (bulan retak / supernova) — B5 | Nirnama Bible, GDD v0.3 | Act 1 | 2 sesi | — |
| **World Dungeon** (tipe IV: *The Hollow Sky* — sudah terlihat dari Zephyr Spire) | Dungeon (40), DUNGEON_ORIGINS | Raid | 2 sesi | — |
| **Great Monsters** (Leviathan/Titan/Phoenix/World Beast/Ancient Predator/Void Colossus) — **peristiwa dunia, bukan boss** | Great Monster (53) | Ekologi | 2–3 sesi | — |
| **Religion v1** (Gereja, Holy Order, Inquisitor, mukjizat ULTRA-langka) + rename `MiracleSystem` → **Wonder/Omen** | Religion (49) | — | 1,5 sesi | 🔴 **Q21/Q22** (nama dewa belum dikunci!) |
| **Heirs of Nothingness** (5 kelompok pewaris kehampaan) | Nirnama Bible part 4 (69) | Act 1 | 1,5 sesi | — |

---

## v0.9 — GENERATION
⏳ **SELURUH fase ini terkunci di belakang K1 (#123).** Tanpa keputusan skala waktu,
penuaan/generasi/suksesi **tidak akan pernah terpicu** (Tahun 120 = ~18,5 tahun nyata).

| Sistem | Bible sumber | Prasyarat | Keputusan owner |
|---|---|---|---|
| Aging, generasi, **Succession** (pewaris = individu baru, bukan salinan) | World Bible (Time), Time & Legacy (36) | **K1** | ⏳ 🔴 **K1 #123** |
| Legacy Family (B3), pernikahan pemain (P3 #88) | — | **K1** | ⏳ |
| Kurva level rebase + loadout penuh (K1/K2 lama: #68/#69) | — | — | — |
| **Catatan:** roadmap owner menaruh Multi-Generation di **Tier E (pasca-rilis)** — kita di v0.9 | `game design roadmap.txt` | — | **C12 / Q10** |

---

## v1.0 — RILIS
- **Endgame Nirnama**: 🔴 **dikunci sebagai NON-KOMBAT** bila Q25 disetujui — ia *final judge*, bukan final boss; pemain menjawab **dengan hidupnya** (kerajaan, warisan, orang yang diselamatkan).
- **5 ENDING** (Dawn / Final Silence / Last Sky / Broken Answer / **The World Remembers**) + **hukum: tidak ada ending sempurna**.
- Butuh **sistem penilaian warisan** (metrik apa? — **Q16**).
- 10 checklist experience hijau → demo publik.

---

## Yang harus dilakukan LEBIH AWAL daripada fasenya (utang murah)

1. **Reserve slot data reputasi/faksi di `PlayerData`** (C17) — menambahkannya setelah save beredar jauh lebih mahal.
2. **Reserve format entri Chronicle** untuk entri NPC/dunia & fragmen (C7/C8).
3. **Rename istilah Sinkronisasi** (C4) sebelum kata "fusion" makin tertanam.
4. **Whitelist non-orb** untuk Naga Kuno/Great Monster (C5/C18) — belum ada satu pun di game, jadi **gratis** dikunci sekarang.
