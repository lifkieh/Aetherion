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
| 🔴 **WONDER TIER-LEGENDA (Piagam, DIKEMBALIKAN — #155)**: **The Nameless Door** · **The Forgotten Musician** · **The Sleeping Giant** | **PIAGAM Bag.0** (tier-legenda pertama = v0.5) | Rumor ✅, Cutscene ✅ | 1,5 sesi | **Isi Piagam — bukan pilihan agent** |
| **First Mystery lokal** ("lonceng tengah malam yang tak punya lonceng") + **First Legend** ("Bukit Kabut") | Early Game (42), Mystery (51) | Rumor system ✅ | 0,5 sesi | **TAMBAHAN, bukan pengganti** (#155): sempat menggantikan tiga Wonder Piagam secara diam-diam — pelanggaran aturan-B, dicatat di GAP_AUDIT |
| **SOFT-CAP EXP (#69/#152)** — ✅ **SUDAH DIBANGUN** (band wilayah = data kanon; EXP menciut brutal di luar band; UI jujur) | K2 (#69) | — | ✅ selesai | Dieksekusi #152 |
| **CURSE (status ke-6) + PEN (penetration)** | GDD §6.3/§6.4 | StatusFx ✅ | 0,7 sesi | Ditugaskan Designer (#156) |
| **20 RESEP FUSION SISA** (15/35 → 35/35) | GDD §5.3 | Fusion ✅ | 0,5 sesi | Ditugaskan Designer (#156) — Grimoire butuh amunisi |
| **STAR WHALE ENTITY** (tubuhnya, bukan cuma perutnya) — **wajib tameable** (B9/#54) | B9 (#54), Skenario "Belly of the Star Whale" | Taming ✅ | 0,7 sesi | Ditugaskan Designer (#156) |
| **GUARD ARTEFAK (#115)** — kode + test yang MENOLAK `enchant_level`/grade pada artefak | K2 (#115) | gear_meta ✅ | 0,3 sesi | Utang murah: kunci **sebelum** artefak pertama lahir |
| **PROGRESSION NON-LEVEL YANG TERLIHAT (#152b)** — reputasi tampil · milestone profesi dirayakan · hitungan Chronicle di HUD-lite | World Bible ("level bukan sumbu kekuatan") | reputasi slot ✅ | 1 sesi | Requirement Designer (#152): kalau level bukan sumbunya, sumbunya harus **punya angka yang terlihat naik** |
| **Companion v1**: 3–5 tokoh Tier-S hidup di dunia; **rekrutmen BUKAN menu** (diyakinkan lewat perbuatan); Life Quest; **Argument System** (boleh tak setuju, boleh pergi) | Companion (41), Recruitment (35) | **B17 50/50** | 1,5–2 sesi | Siapa **First Companion** (wajib **bukan** yang terkuat) |
| **Act 1 Nirnama**: gejala penghapusan — wilayah memutih (mesin Forest Spirit dibalik), NPC tergagap, **The Erased** (musuh baru), satu pertemuan tanpa nama | NIRNAMA_BIBLE §VI, §IX | Cutscene ✅, StatusFx ✅ | 1,5 sesi | Sumbu konflik final (**Q18**) |
| **Chronicle: entri fragmen/rusak** + sembunyikan % penyelesaian | Mystery (51) b.1508/1664 | Chronicle ✅ | 0,3 sesi | **C7** |
| **Hidden Dungeon** pertama (dungeon utuh yang tersembunyi) + asal-usul 5 dungeon masuk ke dalam game (jurnal, artefak bercerita) | Dungeon (40) + `DUNGEON_ORIGINS.md` | — | 1 sesi | — |
| **Dual Class** (spec → implementasi) | Class & Skill Tree (45) + #117 | — | 1 sesi | Sudah diputus (#117) |
| **NPC DEPTH PIPELINE** (#162) — pool dialog kontekstual **8–12 varian/NPC/konteks, dwibahasa sejak lahir** (8 tag konteks, **bukan** perkalian silang); draft Life Event chain (**draft, bukan kanon**); reaksi bencana/keajaiban & gosip lebih kaya | `docs/NPC_DEPTH_PIPELINE.md` | ⚠ **#164 harus diputus dulu** (inline dwibahasa vs Loc) | 2–3 sesi | Resmi (#162); **3 gerbang wajib: kanon · test rahasia · review** |
| **LOKALISASI GELOMBANG 2** (#146): **nama item · nama monster · lore/Pedia → EN**; teks cerita v0.5 **ditulis dwibahasa sejak lahir** | B15 (#62/#100) | Loc ✅ | 1 sesi | Sudah diputus (#146) |
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
| **LIFE EVENTS + GROWTH ENGINE** (mesin kepribadian penuh, #139): opportunity events (**pemain memberi kesempatan → takdir berubah**, L14), growth tick lewat PERISTIWA, moral drift (kejatuhan & penebusan), mental_state memengaruhi keputusan hidup NPC | Personality (#136–#138), Recruitment (35) | Profil ✅ (sudah ditanam) | 2 sesi | Sudah diputus (#139) |
| **Rune / Runesmith**, profesi bible (Hunter, Tailor, Farmer, Rancher, Merchant, Scholar, Explorer) | Profession (46) + #122 | — | 1,5 sesi | Cook tetap (#122) |
| ⏳ **World history ledger** (peristiwa ireversibel offline) | World Bible b.5704 | **K1** | — | ⏳ **K1 #123** |

---

## v0.7 — HORIZON (Emberfall · Kerajaan Thalassar · Wildhearth)

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| **Benua & budaya baru**: Azhur (Thalassar/Tidekin), Nethrak (Wildhearth/Beastfolk), Sylvara (Elf/Ancient Jungle) | World Bible, Ras (#86), #110 | Aset (lihat MANIFEST) | 3–4 sesi | Fairy Realm → benua mana? |
| **CUACA PER-WILAYAH** (#147): cuaca global dipecah per wilayah/benua — badai di laut ≠ badai di gurun | v0.1 §4.3 | Wilayah baru | 0,5 sesi | Sudah diputus (#147) |
| **REQUIREMENT DESAIN DUNGEON** (#148): dungeon BARU **wajib mengisi tipe kanon yang masih kosong lebih dulu** — **Raid (III)** · **Companion (VI)** · **Kingdom (VII)** — sebelum menambah Ancient Ruins ke-4 | Dungeon Bible (40), `DUNGEON_ORIGINS.md` | Companion v1 (VI), Domain (VII), entourage (III) | — | Sudah diputus (#148) |
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
| **Religion v1** (Gereja, Holy Order, Inquisitor, mukjizat ULTRA-langka) + rename `MiracleSystem` → **Wonder/Omen** | Religion (49) + **DIVINE_BIBLE (#140–#143)** | ✅ nama dewa **sudah dikunci** | 1,5 sesi | Butuh sesi penulisan: kepribadian/agenda/gereja tiap dewa |
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

### ENDGAME: **HYBRID FINAL JUDGE** — dikunci (#134, D2)

**Hukum bible dipertahankan penuh: Sang Nirnama TIDAK mati di tangan pemain.**
Tapi klimaksnya **tetap pertarungan gameplay besar** — hanya saja objektifnya dibalik:

| Fase | Isi | Objektif |
|---|---|---|
| **1. Badai Penghapusan** | *Expedition encounter*: gelombang **Yang Terhapus** + wilayah yang mulai memutih | **BERTAHAN** |
| **2. Melindungi** | Domain-mu, companion-mu, halaman Chronicle-mu **dijadikan objektif hidup** — merekalah yang bisa hilang, bukan HP musuh | **LINDUNGI apa yang kau bangun** |
| **3. PENGHAKIMAN** | Dunia menjawab pertanyaannya **lewat bukti**: Chronicle yang pulih, orang-orang yang masih mengingatmu, **save file-mu sebagai argumen** | **JAWAB** |

**Kemenangan bukan membunuh.** Level tanpa batas tak pernah jadi jawaban — karena
pertanyaannya bukan pertanyaan tempur. **Nasib akhir Nirnama (pergi / tinggal / berubah
/ menunggu era berikutnya) SENGAJA TIDAK DIKUNCI** — itu keputusan penulisan Act 2.

- **5 ENDING** (Dawn / Final Silence / Last Sky / Broken Answer / **The World Remembers**) + **hukum: tidak ada ending sempurna**.
- Butuh **sistem penilaian warisan** (metrik: Chronicle, Domain, companion yang hidup, orang yang mengingat).
- 10 checklist experience hijau → demo publik.

### KEMATIAN & REVIVE — dikunci (#133, D1)
Berlaku sejak sistem companion lahir (v0.5+):
- **1× seumur hidup**, per NPC/companion bernama (termasuk 50 Great Companion).
- **Tubuh harus utuh/ditemukan** — hancur/hilang/dilupakan = **mustahil selamanya**.
- **Mati wajar karena usia = TIDAK BISA direvive** (*kematian karena waktu adalah hukum
  dunia, bukan luka*). Mati tragis/dibunuh/kecelakaan = jalur **per-kasus, ditulis
  tangan, selalu sulit**.
- **Harga = INGATAN**, tanpa kecuali. **Kematian kedua = final mutlak.**

---

## Yang harus dilakukan LEBIH AWAL daripada fasenya (utang murah)

1. **Reserve slot data reputasi/faksi di `PlayerData`** (C17) — menambahkannya setelah save beredar jauh lebih mahal.
2. **Reserve format entri Chronicle** untuk entri NPC/dunia & fragmen (C7/C8).
3. **Rename istilah Sinkronisasi** (C4) sebelum kata "fusion" makin tertanam.
4. **Whitelist non-orb** untuk Naga Kuno/Great Monster (C5/C18) — belum ada satu pun di game, jadi **gratis** dikunci sekarang.
5. **Guard artefak (#115)** — kunci **sekarang**, selagi belum ada satu artefak pun. Setelah artefak pertama lahir sebagai `type: "weapon"` biasa, kanon sudah bocor diam-diam.

---

## YANG SEMPAT HILANG DARI ROADBOOK — dikembalikan (#156)

Tiga janji ini hidup di TRACKBACK/ledger tetapi **tidak punya satu baris pun di dokumen
eksekusi**. Itulah cara sebuah janji mati tanpa ada yang memutuskan membunuhnya.

| Janji | Sumber | Fase | Catatan |
|---|---|---|---|
| **10 CAPSTONE per class** (Worldbreaker, Astral Genesis, Throne of Souls, …) | #57 / #116 | **v0.9** (bersama rebase kurva) | Kode hari ini hanya punya test yang **MELARANG** capstone menempel di pohon — tak ada yang **membuatnya**. 6 capstone sisa belum bernama (butuh Direktur, D-butir 3). |
| **Sistem Rival** | #38b | **v0.6** (World Remembers v1) | Rival = memori dunia yang berjalan; tempatnya di sana. |
| **B7 Perayaan Legacy & festival** | #52 / #81 | **v0.6** | Chronicle hari ini **mencatat** tanpa pernah **merayakan**. Legacy yang tak dirayakan cuma basis data. |

---

## BACKLOG PENULISAN BIBLE — meja Direktur + Designer (#132)

**Jadwal: PASCA-B17** — agar tidak menggeser gerbang v0.5 (#128).

| Dokumen | Lapisan | Kenapa dibutuhkan |
|---|---|---|
| **Mythology Bible** | Tier S/A | Legenda, dongeng, ramalan — *"dunia hidup tidak hanya dibangun oleh fakta, tapi oleh cerita yang dipercaya"* |
| **Language Bible** | Tier A | Bahasa kuno, bahasa naga, simbol — dibutuhkan **Knowledge Gates** (pintu yang dibuka pemahaman, bukan kunci) |
| **Emotion Bible** | Tier A+ | Apa yang harus **dirasakan** pemain: Wonder → Belonging → Responsibility → Loss → Legacy |
| **Mystery Bible** | Tier A | Daftar rahasia terbesar dunia — melengkapi `MISTERI_ABADI.md` |
| **Divine Bible** — *lanjutan* | Tier S | ✅ **seed selesai** (#143: nama, domain, hukum gema). Sisa: **kepribadian · agenda · gereja** tiap dewa + apakah ada dewa bawahan + relasi Lima dengan 17 elemen |
| **Ancient History Bible** | Tier S | Bertaut **M8** (#126) — Kebohongan Sejarah Terbesar |
| **Player Motivation / Retention / Endgame / Content Longevity / Emotional Design** | **Tier A+** | Lapisan meta yang **belum pernah kita sentuh**: kenapa pemain masih main di jam ke-500? Apa yang dilakukan setelah semuanya selesai? |
| **Multiplayer Bible** | Tier A | Boleh **ditulis** sebagai spec pasca-v1.0; **implementasi tetap beku** (B14 gratis-penuh, daftar tahan MMO) |
