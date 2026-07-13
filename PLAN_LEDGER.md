# PLAN_LEDGER — Dokumen Induk Proyek Aetherion
**Dibuat:** 2026-07-12 atas perintah owner (obat sistemik: tidak ada lagi sistem yang hilang senyap).

**Hierarki dokumen resmi (Decision Log #45): PLAN_LEDGER > MASTER_BLUEPRINT (file menunggu, BD-2) > MASTER_IMPROVEMENT_PLAN > STATUS.**

**Aturan permanen (juga di DEVLOG):**
(a) Setiap arahan owner baru = baris baru di Decision Log SEBELUM dikerjakan.
(b) Setiap penyimpangan implementasi dari GDD yang diputuskan agent sendiri = baris baru + alasan.
(c) Awal sesi: baca ledger ini. Akhir ronde: update KEDUA bagian. Item baru owner → langsung masuk.
(d) Implementasi yang bertentangan dengan ledger tanpa baris keputusan = **BUG DESAIN** → laporkan di GAP_AUDIT.
(e) Ledger di-commit dan di-push seperti kode.

Status: **Ada** / **Sebagian** / **Belum** / **Ditunda-sengaja** / **MENYIMPANG**.

---

## BAGIAN 0 — PIAGAM PENGALAMAN (amandemen identitas, Decision Log #34–37)

**Identitas resmi: "THE WORLD REMEMBERS."**
> "Aetherion bukan dunia yang menunggu pemain datang. Aetherion adalah dunia yang
> terus berjalan, menyimpan rahasia, dan mengingat apa yang dilakukan pemain."

**Living Sky = sistem gameplay TERBESAR** (Tahun Langit, eclipse, meteor shower,
Celestial Alignment membuka pohon tersembunyi). Setiap fitur baru wajib bertanya:
apakah ia berjalan sendiri, menyimpan rahasia, atau mengingat pemain?

### 4 Pilar Pengalaman (blueprint v1.0.1 #67 menambah STEWARDSHIP; di atas 3 pilar sistem GDD v0.1 §1.2)

| Pilar | Isi | Status |
|---|---|---|
| **WONDER** | Rahasia bertingkat: **tier-remah** solo-findable via rumor Penjaga Pohon / ramalan Astrolog / gosip NPC yang SUDAH ada; **tier-legenda** nyaris tanpa petunjuk. Kandidat tercatat: **The Nameless Door** (03:33 WIB + bulan baru + musim dingin), **The Forgotten Musician** (lagu musiman, ikuti 3 musim berturut), **The Sleeping Giant** (gunung = boss hidup, raid-class) | Kandidat terdaftar; tier-legenda pertama = v0.5 |
| **BELONGING** | Homestead berevolusi jadi **LIVING HEADQUARTERS → kerajaan**: buka lahan → bangunan → rekrut puluhan penduduk (syarat unik per orang) → markas tumbuh TERLIHAT. **= Evolusi resmi Pact System** (menggantikan #Pact sebagai konten beku terpisah) | Spec v0.6 "Hearth & Legacy" |
| **LEGACY (dua-lapis)** | Offline: **Kitab Sejarah Dunia** (chronicle otomatis) + aula patung + maker's mark + first-personal terukir. Online nanti: sistem SAMA menyala jadi first-discovery/first-kill/first-craft global | Benih chronicle = v0.5; v1 = v0.6 |
| **STEWARDSHIP** (baru, blueprint §1) | Dunia *menanggapi*: pilihan ber-trade-off (eksploitasi vs keseimbangan); kerajaan = cermin moral pemain; tidak ada pilihan sepenuhnya benar | Terhubung Stability (B12) & reaksi dunia (World Remembers v1) |

### Aturan boss masa depan (#36)
Boss **raid-class** (Sleeping Giant, world boss, boss cerita besar) = butuh entourage
2–4 rekrutan markas (multi-aktor). **Boss reguler tetap solo-able** — penyendiri tidak dihukum.

### Roadmap resmi (#37) — detail di TRACKBACK.md
`v0.4.2 Gear & Economy → v0.5 STORY & SOUL (terbesar; + Wonder tier-legenda pertama + benih chronicle) → v0.6 HEARTH & LEGACY (Living HQ + rekrutan + companion AI + World Remembers v1 + Rune) → v0.7 Emberfall/Ocean → v0.8 Celestia → v0.9 demo publik`. Racing/gambling/marketplace/MMO tetap beku.

---

## BAGIAN 1 — STATUS SEMUA SISTEM

### 1. Identitas, karakter, profesi

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| 6 combat class sebagai pilihan pemain | v0.1 §3.3 | **Ada** (2026-07-12) | 6 class + 3 skill awal beda + 2 varian senjata + bonus stat + afinitas; ClassSelect di New Game. Sebelumnya MENYIMPANG (tidak ada) — lihat Decision Log #14. |
| Advanced Class Quest Lv60 | v0.2 §3 | Belum | Baru teaser teks di ClassSelect/Status. |
| Stat 6 attr + 5 poin/level + respec | v0.1 §3.5 | Ada | Ronde 4 (PC1). |
| Profesi utama + 2 sub (cap/efisiensi/tier akses) | v0.2 §3 | Ada | ProfessionSystem + Reawakening cost. |
| Profesi gathering (Miner/Lumberjack/Fisherman/Herbalist) | v0.1 §3.3 | Ada | + XP + perk milestone. |
| Profesi produksi: Blacksmith/Alchemist/Cook | v0.1 §3.3 | Ada | +Carpenter (tambahan non-GDD, Decision Log #20). |
| Profesi produksi: **Enchanter** | v0.1 §3.3 | **Ada** (v0.4.2) | professions.json + NPC layanan di kota + perk enchant_bonus; sistem Enchant +1..+10 hidup (ledger #72). |
| Profesi utility: Tamer | v0.1 §3.3 | Ada | |
| Profesi utility: **Merchant, Treasure Hunter** | v0.1 §3.3 | Belum | Fase v0.4.2+. |
| **Rumor tidak akurat** (E5 #77) | Konsepsi GPT D025 | **Ada** (2026-07-13) | rumors.json (truth + distortions + accuracy); gosip warga boleh keliru; Penjaga Pohon tetap akurat. |
| **NPC berkepribadian 5/kota** (E6 #78) | Konsepsi GPT | **Ada** (2026-07-13) | 25 NPC di 5 pemukiman (aneh/misterius/lucu/tragis/tak-masuk-akal); 3 Oddwalker tanpa payoff. |
| **Miracle System v1** (E7 #79) | Konsepsi GPT | **Ada** (2026-07-13) | 4 keajaiban harian tak-dipicu-pemain; pengumuman HANYA via gosip esok hari. |
| **Taksonomi quest + Hukum Quest** (E8 #80) | Konsepsi GPT | **Ada** (2026-07-13) | quest_type 11 label + 9 quest diberi konteks manusia; hukum di CLAUDE.md. |
| **Rumah Lelang NPC** (B8 #53) | Blueprint §10 | **Ada** (v0.4.2) | Lot harian + istimewa purnama; bidding vs 4 rival berkepribadian; maks tier A (S+ difilter + test 120 hari); lot tawanan → dibebaskan = kandidat rekrut loyal (ledger #73). |
| **Crafting Transenden A→S→SS→SSS sebagai MOMEN** (#25) | MASTER_PLAN v0.4.2 | **Ada** (v0.4.2) | 13 resep piramida + ritual TranscendentRitual + pengumuman penempa; material kunci selamat saat gagal (ledger #71). |
| **Quality roll + maker's mark + Enchant +1..+10 + Coating** | REPORT-04 #2-4 | **Ada** (v0.4.2) | gear_meta per item_id; Adikarya +10%; enchant +3%/lv, gagal ≥+7 turun 1 (tak hancur), Gulungan Perlindungan; coating +25% elemen sekunder (ledger #72). |
| Character creator (rupa) | Owner (charsys v2) | Ada | CharGen modular 7 ras, per-bagian. |
| Rasi Kelahiran (birth sign) | v0.3 §3.3 | **Ada** kecuali Trial (#91) | Bonus tematik kecil (2–3%) aktif di recalculate_stats; **Trial of the Rasi** masih v0.4.4. |
| 3 slot karakter/akun, Account Bank | v0.1 §3.1 | Ditunda-sengaja | Butuh akun/online (Fase 2+). |

### 2. Combat & elemen

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Model combat: hold-attack + channel mana (TANPA cooldown) + fusion bertingkat + anti-melt + infusion reach | Owner rev A–F (2026-07-12) | Ada | MENIMPA struktur cooldown GDD §6.2 — Decision Log #8. |
| Struktur skill: 6 slot + Ultimate slot + Combo window | v0.1 §6.2 | Sebagian | Hotbar 5 slot; Ultimate baru flag (meteor); **Combo window ADA (v0.4.1): 2 skill beda <2 dtk = +30%**. |
| Formula fisik/magic + miss ACC-vs-EVA | v0.1 §6.3 | Ada (dimodifikasi) | MDEF mitigasi-dalam-multiplier (#11); hit-clamp beda dari GDD; PEN belum; **cap & formula kini DIPUBLIKASIKAN di tab Status (v0.4.1)**. |
| Status effect (Burn/Freeze/Paralyze/Poison/Blind/Curse) | v0.1 §6.4 | **Ada** (v0.4.1, kecuali Curse) | StatusFx: DoT/stun/lock/blind + interaksi sains (Thermal Shock, konduksi basah, pemadaman); ikon di musuh & pemain. Curse menyusul. |
| 17 elemen 4 tier + matrix + aturan sains data-driven | v0.2 §7 | Ada | Termasuk Tier 2 (Poison/Metal/Wood/Spirit) ✓ terverifikasi. |
| Fusion elemen + discovery + Grimoire | v0.1 §5.3 + owner rev C + owner 2g | Ada | 15 resep (target launch 35 — sisa = konten bertahap). |
| Element Flow 4 jalur: Infusion / Coating / Enchant / Fusion-monster | v0.3 §7 | Sebagian | Infusion + **Coating (v0.4.2: Minyak Bisa/Salut Beku, +25% sekunder)** + **Enchant (v0.4.2: +1..+10, gagal ≥+7 turun 1, Gulungan Perlindungan)**; fusion-monster ditunda-sengaja. |
| Weapon moveset per tipe + arc VFX + afinitas class | Owner FF-2b | Ada | 8 tipe. |
| Kalibrasi TTK dua arah + ekonomi mana (harness v2) | Owner ronde 4 | Ada | BALANCE_TARGETS/REPORT_v2. |

### 3. Dunia, waktu, langit

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Waktu = jam WIB asli + fase bulan lunar asli | v0.2 §6 | Ada | Jantung Aetherion, sehat. |
| **MUSIM 4 × 2 minggu** | v0.1 §4.2, Fase0 §3 | **Ada** (v0.4.3, #83) | Siklus 56 hari terikat tanggal WIB; tint dunia, drop_mult, bias spawn elemen, pertumbuhan tanaman per musim + **Rumah Kaca** sebagai jalan keluar; HUD menampilkan musim & hari ke-n/14. |
| Cuaca per wilayah + efek gameplay | v0.1 §4.3 | Sebagian | 5 cuaca; **Blood Moon PENUH (v0.4.1)**: malam acak jarang + purnama, aggro ×1.5, drop ×2, langit merah, gerbang evolusi (boar). Per-wilayah masih global. |
| Event harian: Golden Hour / Morning Dew / nokturnal | v0.2 §6.2 | **Ada** (v0.4.1) | Golden Hour EXP+10% nyata; Morning Dew panen +1; nokturnal gating spawn di 5 wilayah. |
| sky_calendar tanggal astronomi nyata | Fase0 §3 | Ada | 11 event 2026–2027 (solstice/equinox/meteor). |
| Ramalan Rasi (12 Rasi Agung + prophecy mingguan) | v0.3 §3 | **Ada** (v0.4.3, #91) | 12 aset rasi dipakai; rasi naik mingguan + teka-teki terhubung konten aktif; bonus rasi kelahiran 2–3%. |
| Prakiraan cuaca Astrologer 24 jam (80%) | v0.1 §4.3 | **Ada** (v0.4.3, #91) | Rencana langit deterministik; rol cuaca mengikutinya 80% — akurasi 80% nyata, bukan kosmetik. |
| Wilayah: Greenvale, Candyveil, Desert, Frostpeak(+desa), Storm Island | v0.1 §4.1+v0.2 §4 | Ada | 5 dari 13; sisanya = konten (beku). |
| Celestia Kingdom = ibukota SEMUA ras | Owner (kanon baru) | Ditunda-sengaja | Decision Log #7; dibangun saat konten dibuka. |
| Homestead + tanam real-time WIB | v0.2 §5 | Ada | Ternak/apiari/kolam/breeding-pen belum (bertahap); cek musim belum (A4). |
| Kompresi level Fase 0 (monster L1–55) | Keputusan implementasi | Ada — **SEMENTARA** | #19; per **B10 (#55): level final TANPA batas**, target all-in-one ±500 jam. |

### 4. Monster, taming, pet

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Roster BST × arketipe × rarity (60 spesies) | Roster §1–2 | Ada | Kalibrasi ulang growth (Decision Log #10). |
| Rank bintang 1–5 saat spawn | v0.1 §7.2 | **Ada** (v0.4.1) | Tampil ★ di atas HP bar (kedua mode) + Pedia + tab Pet. |
| Trait 1–2 per individu dengan efek | v0.1 §7.2 | **Ada** (v0.4.1) | Pool individu (Kekar/Liat/Gesit/Beruntung/Berbisa) berefek stat/racun nyata + tampil di UI; trait spesies (Pack Hunter dll.) menyusul. |
| **Affinity** pet (naik lewat interaksi, gerbang konten) | v0.1 §7.2, §8.3 | **Ada** (v0.4.1) | +1/kill dibantu, +5 diberi makan (cap 100); tampil di tab Pet (ranch UI). |
| **Mutation 1/500** | v0.1 §7.2 | **Ada** (v0.4.1) | Recolor emas, +10% stat, nama ✦, drop +10%. |
| Growth Type (Early/Balanced/Late) | v0.1 §7.2 | Belum | Prioritas rendah. |
| Taming (rate, pity, enrage, orb) | v0.1 §8.1 + v0.2 §7.4 | Ada (B9 diberlakukan) | **SEMUA spesies tameable (#54)** — tame_base 0 dihapus (gummy_mimic, peppermint_fairy → rate ekstrem kecil); Star Whale belum ber-entitas dunia, wajib tameable saat dibuat. |
| Pet-mount Size Class + saddle | v0.3 §6 | Ada | |
| Evolution bertingkat + syarat dunia | v0.1 §8.4 | Ada | Purnama dll.; jalur bercabang belum. |
| Secret monster + trigger dunia | v0.1 §7.3 | Sebagian | Thunder Dragon ✓, Star Whale ✓; **Forest Spirit belum** (counter jalan, trigger tidak — A8). |
| Breeding & mutation pasar | v0.1 §8.5 | Ditunda-sengaja | S2 pasca-launch (MVP cut §18). |
| Fusion player × monster | v0.1 §8.3 | Ditunda-sengaja | S2. |
| Pact System (rekrut boss/NPC legendaris) | v0.3 §5 | Ditunda-sengaja + BEKU | Menunggu owner buka konten. |

### 5. Item, crafting, ekonomi

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Tier F–B umum (drop/craft normal) | v0.2 §2 | Ada | Rantai craft F→E→D + tier scaling. |
| **Tier Transenden A/S/SS/SSS** (craft-only 1%, piramida, Insight, ritual+pengumuman) | v0.2 §2 | **Sebagian — dangkal** | Insight ✓, 1 resep S; piramida/maker's mark/quality/pengolah material [A][S] drop: belum — addendum A1. |
| Maker's mark + quality roll | v0.1 §9.2 | Belum | v0.4.2. |
| **Enchant +1..+10** (gagal turun 1, tak hancur) | v0.1 §9.3 | **Belum** | v0.4.2 + profesi Enchanter. |
| **Rune System** (pemain 4 slot, monster 2, grade I–V merge 3) | v0.1 §8.6 | **Ditunda-sengaja** | Decision Log #28: ke fase pembukaan konten (dipasangkan loot dungeon & slot monster Epic+). |
| **Durability & repair gear** | v0.1 §10.2 (sink "Repair gear") | Belum — prioritas rendah | Decision Log #29; relevan saat ekonomi sink diperdalam. Death penalty dungeon sementara −10% gold (tanpa durability, #12). |
| Mode Hemat + target performa game ringan | v0.2 §1, Fase0 §9 | **Ada** | 30fps lock + VFX cuaca off; perf diaudit per ronde. **Dijaga saat juice pass** (partikel/VFX baru wajib murah & dimatikan di Mode Hemat bila berat). |
| Equipment 3 slot + tooltip banding | Owner ronde 4 (PC5) | Ada | |
| Ekonomi NPC supply-demand + log | Fase0 §7 | Ada | |
| Skill book / trainer / boss-unlock skill | v0.1 §6.2, §11.1 | Ada | Ronde 4 (PC4). |
| Marketplace pemain / auction / kios | v0.1 §10.3 | Ditunda-sengaja | Fase 2 online-lite. **B8 (#53): RUMAH LELANG NPC offline (maks tier A, tawanan-dibebaskan) masuk v0.4.2.** |
| Gambling / racing betting | v0.1 §10.5, §11.5 | Ditunda-sengaja | S3+. |

### 6. Konten & presentasi

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Dungeon side-view Terraria + bos 2 fase | Owner 2026-07-11 | Ada (bos di-upgrade v0.4.1) | 5 bos: 3+ pola/fase terkoreografi + telegraf, arena hazard per bos, intro bar+nama+stinger, perayaan kill slow-mo+loot shower. Chest/rahasia/trap: v0.4.3. |
| Hidden Scenario engine + no-fail | v0.2 §8.2 | Ada | 3 skenario. **Perayaan first-clear belum** (A8). |
| Quest: daily board + panduan pembuka | v0.1 §11.1 | Ada | Pembuka dirombak FF-2g (reward/langkah). Quest journal terpusat: belum. |
| Intro/opening + cutscene dasar | Benchmark | Sebagian | Intro 4 layar ✓ (FF-2g); cutscene engine belum. |
| Title screen + Continue + autosave + metadata | Benchmark/owner FF-2e | Ada | |
| Aetherpedia, Photo Mode, Titles, Echo Vendor, Sky Report, music layering | v0.2 §10 | Ada | |
| Settings lengkap (volume per channel/keybind/fullscreen) + gamepad | Benchmark | Sebagian (v0.4.1) | Pause menu layak + volume Musik/SFX terpisah + fullscreen ADA (tarikan review i). Keybind remap + gamepad: v0.4.4. |
| UI feel (motion/hover/press/breathing/celebration) | Benchmark / #44 | **Ada** (v0.4.1c) | UiFx + ui_feel.json tunable; semua layar utama; hormat Mode Hemat. |
| Lokalisasi ID/EN (B15 #62) | Blueprint | **Sebagian** | Konvensi string-key + Loc helper + translations/ terpasang; retrofit teks lama & pilihan bahasa UI = v0.4.4. |
| Active Loadout 20–30 skill (B10-A #56) | Amandemen Direktur | Belum — spec terkunci | Ganti di zona aman, preset bernama; dirancang bersama v0.5 (butuh skill pool membesar dulu). |
| Life Events domain 5-tier (B1 #46) | Blueprint | Belum — spec | v0.5/v0.6 (lihat REPORT-02 risiko). |
| Monster bekerja (B2 #47) · Legacy Family (B3 #48) · Dunia-maju (B4 #49) · Autonomous Kingdom (B11 #58) · Stability (B12 #59) · Expansion (B13 #60) | Blueprint | Belum — spec v0.6 Hearth & Legacy | Payung pilar BELONGING/LEGACY. |
| Celestial Crisis = FF Moment (B5 #50) | Blueprint + GDD v0.3 §2.2 | Belum — spec v0.5+ | Disatukan dengan supernova live-event. |
| Naratif Memori-vs-Pelupaan + Nirnama (B6 #51) · nada gelap (B16 #63) | Blueprint | Belum — GERBANG: Companion Bible (#64) & Nirnama Bible (#65) | v0.5 Story & Soul. |
| World Personality: Enam Lingkup Budaya (B19 #66) | Blueprint §3.9 (file menunggu) | Belum — spec | Tabel penuh menunggu file blueprint. |
| Tangga dungeon modern (gantung/lompat-lepas) | Owner #42 | **Ada** (v0.4.1c) | Menempel W-sekali, menggantung, SPACE lompat-lepas, anti-nyangkut puncak. |
| World map + fast travel | Benchmark | **Sebagian** (v0.4.1c) | **Gerbang Penjelajah "Pilih Dunia"** di 5 pemukiman (#43): kartu wilayah dikunjungi + siluet terkunci + 25G (gratis 1×/hari). World map visual penuh: v0.4.3. |
| PvP / guild / racing / world boss / co-op | v0.1 §11 | Ditunda-sengaja | Fase 2–4 online. |
| Monetisasi kosmetik / battle pass | v0.1 §15 | **DIBATALKAN (B14 #61)** | **GRATIS PENUH** — tanpa monetisasi. |

---

### 7. Skill Tree terikat lokasi (Decision Log #30) — pemetaan resmi

| Lokasi | Status lokasi | Pohon |
|---|---|---|
| Greenvale (Penjaga Pohon pemula) | **Hidup** | Semua pohon common (Dasar Bertarung, Pertahanan), Senjata Tier Dasar, pohon kehidupan dasar (Menebang, Menambang, Bertani, Memancing, Meramu, Memasak, Menjinakkan Dasar) |
| Pos Pendaki Frostpeak | **Hidup** | Es Tingkat Tinggi |
| Storm Island (menara Zephyr) | **Hidup** | Petir Tingkat Tinggi |
| Desert of Ruins (reruntuhan) | **Hidup** | Tanah & Logam Kuno |
| Candyveil (istana Sugar Queen) | **Hidup** | Patiseri Agung (Memasak lanjut) |
| Homestead | **Hidup** | Bertani/Beternak Menengah |
| Menara Astrologer | **Hidup (tampil-terkunci)** | CELESTIAL Sun/Moon/Star — hanya terlihat di sini; buka butuh clear Hidden Scenario (Sun/Moon ← Lunar Warren, Star ← Star Whale) |
| Celestia Kingdom | Terkunci-konten | Senjata Grandmaster (tukar buku advanced class), Cahaya Tingkat Tinggi |
| Emberfall Volcano | Terkunci-konten | Api Tingkat Tinggi + Menempa Lanjut (kuil tempa) |
| **Kerajaan Thalassar** (id data: `ocean_kingdom`, #90) | Terkunci-konten | Air Tingkat Tinggi |
| Ancient Jungle | Terkunci-konten | Kayu & Racun Purba |
| Skyveil | Terkunci-konten | Angin & Langit |
| Abyss Realm | Terkunci-konten | Gelap & Hampa |
| **Wildhearth (kota beastfolk — KONTEN BEKU, #31)** | Terkunci-konten | Pohon BEAST & TRANSFORMATION (menjinakkan lanjut, kebuasan, jalur transformasi/fusion-monster) + Beternak Lanjut |

Aturan: buka HANYA di lokasi (rumor berarah di Penjaga Pohon); upgrade node di mana pun
setelah dimiliki; `content_locked` dilepas otomatis saat wilayahnya dibangun.

### 8. SPEC v0.6 — "WORLD REMEMBERS v1" (Decision Log #38 — JANGAN dibangun sebelum v0.6)

**(a) Memori NPC personal** — field memori per NPC:
- Dipukul pemain → diingat: dialog dingin/takut, harga +20%, memanggil penjaga jika
  diulang; pulih setelah waktu lama ATAU permintaan maaf berbiaya.
- Ditolong (quest pribadi / diselamatkan dari monster) → diingat baik: sapaan hangat,
  diskon kecil, **prioritas kandidat rekrutan markas** (terhubung pilar Belonging).
- **Reputasi kota** = agregat memori-memori NPC-nya.

**(b) Sistem RIVAL** — musuh Rare+ yang lolos dari combat aktif (HP<50% lalu leash/kabur):
- Status Rival: respawn beberapa waktu kemudian, **pangkat +1★ (maks +2)**, nama julukan,
  aura visual, baris isyarat saat bertemu ("Kamu menyesal membiarkanku kabur.").
- Mengalahkan Rival = reward lebih + entri Kitab Sejarah. **Batas 2–3 Rival hidup**
  bersamaan (yang terlama memudar). Kematian pemain oleh Rival menaikkan pangkatnya
  (cap tetap). Desain sederhana & khas Aetherion — terikat counter/langit kita sendiri,
  **bukan tiruan sistem berpaten game lain**.

**(c) Reaksi dunia v1**: Forest Spirit (trigger trees_cut — gap A8), migrasi monster
akibat overhunt, kota berkembang karena sering diselamatkan.

## BAGIAN 2 — DECISION LOG (riwayat keputusan; retroaktif dari DEVLOG/STATUS)

| # | Tanggal | Sistem | Keputusan awal (sumber) | Diubah menjadi | Alasan | Oleh |
|---|---|---|---|---|---|---|
| 1 | 2026-07-11 | Arah produk | MMORPG penuh (v0.1) | **Offline-first Fase 0** single-player; online bertahap Fase 2–4 | Realistis untuk indie; simulasi = calon server | Owner (v0.2 §1, v0.3 §4) |
| 2 | 2026-07-11 | Dungeon | Dungeon top-down (implisit v0.1 §11.2) | **SEMUA dungeon side-view Terraria-style**; overworld tetap top-down | Rasa eksplorasi + identitas | Owner |
| 3 | 2026-07-11 | Kamera | Zoom 3× | 2× (AETHER_WIDE=1 untuk 1×) | Dunia terasa kosong di 3× (hanya ~427×240 unit terlihat) | Agent (dicatat DEVLOG) |
| 4 | 2026-07-11 | Pohon | Semua pohon bisa ditebang | **Hanya pinus berjenjang & batang telanjang** yang choppable; lainnya dekorasi | Koreksi feedback owner (kejelasan visual) | Owner |
| 5 | 2026-07-11 | Sistem karakter | Asset LPC (rencana sementara) | **LPC DITOLAK** → Aetherion Character System (CharGen modular, 7 ras per-bagian) | Lisensi share-alike + identitas orisinal | Owner |
| 6 | 2026-07-11 | Demografi kota | (tidak diatur) | Greenvale = 100% human; desa Frostpeak = frostkin/wolfkin/human | Identitas tematik per pemukiman | Owner |
| 7 | 2026-07-11 | Kanon dunia | Celestia = "ibukota manusia" (v0.1 §4.1) | **Celestia Kingdom = ibukota tempat SEMUA ras bersatu** | Kanon baru; kota terbesar, dibangun nanti | Owner |
| 8 | 2026-07-12 | Model combat | Skill cooldown 3–30 dtk (v0.1 §6.2) | **TANPA cooldown** — channel hold, ekonomi mana_cost×cast_rate; fusion 3–4 elemen = satu-satunya recast | Rev B/C owner (rasa Terraria/Magicka) | Owner (rev A–F) |
| 9 | 2026-07-12 | Element Flow | Infusion berdurasi 30–60 dtk (v0.3 §7) | Infusion persisten ber-drain mana/dtk + **mengubah reach/arc melee per elemen** | Rev E owner | Owner |
| 10 | 2026-07-12 | Balancing monster | Growth +3%/level (Roster §1.1) | HP +85%/level, ofensif +9%/level, THREAT_MULT 0.45 | Harness v2: TTK kolaps & pack one-shot; korridor owner terpenuhi | Agent (BALANCE_REPORT_v2) |
| 11 | 2026-07-12 | Formula magic | `(MATK×mod)×elem×crit×(1−mres) − MDEF flat` (v0.1 §6.3) | MDEF mitigasi seperti DEF di dalam multiplier | Flat post-multiplier membuat cast lemah = 1 dmg vs tank (patologis) | Agent |
| 12 | 2026-07-12 | Death penalty dungeon | "minor penalty — define it" (arahan) | Respawn di pintu dungeon, **−10% gold**, tanpa XP/item loss | Durability belum ada; definisi final | Agent (mandat owner) |
| 13 | 2026-07-12 | Konten | Lanjut konten v0.3+ | **SEMUA konten baru BEKU** sampai fondasi layak | Playtest: game hampa | Owner (Foundation First) |
| 14 | 2026-07-12 | Class | 6 combat class = profesi (v0.1 §3.3) — tidak pernah diimplementasi | Diimplementasikan penuh sebagai pilihan New Game + kit unik | Perintah langsung 2a | Owner |
| 15 | 2026-07-12 | Senjata | weapon_type kosmetik | 8 tipe ber-moveset & VFX beda + afinitas class (+8%/+5%) | Perintah langsung 2b | Owner |
| 16 | 2026-07-12 | Fusion UX | Discovery buta murni (v0.1 §5.3) | + **Grimoire** (temuan + baris misteri dari fizzle) + tutorial + perayaan | Perintah langsung 2d — discovery hidup, pemain punya peta | Owner |
| 17 | 2026-07-12 | Save | 3 slot manual (Fase0 §8) | + autosave berkala/transisi, Continue, metadata kaya | Perintah langsung 2e | Owner |
| 18 | 2026-07-12 | Loot | Drop langsung masuk tas | **Loot burst fisik** + magnet ke pemain | Perintah langsung 2f (juice) | Owner |
| 19 | ~2026-07-11 | Skala level Fase 0 | Wilayah level 1–99 (v0.1 §4.1) | Konten Fase 0 dikompresi ke ±L1–55 (Greenvale 1–15 … Storm 40–55) | Scope Fase 0; kurva penuh menunggu konten launch | Agent (retroaktif — implisit di roster) |
| 20 | ~2026-07-11 | Profesi | Daftar GDD §3.3 tanpa Carpenter | +Carpenter (kayu→plank→furniture) | Kebutuhan rantai craft awal | Agent (retroaktif) |
| 21 | 2026-07-12 | Dokumentasi | (tidak ada) | **PLAN_LEDGER = dokumen induk** + 5 aturan permanen (DEVLOG) | Sistem hilang senyap (musim, rune, enchant, affinity…) ketahuan di telaah designer | Owner (addendum) |
| 22 | 2026-07-12 | Roadmap | MASTER_IMPROVEMENT_PLAN v0.4.1–v0.4.4 (draft agent) | **DISETUJUI** dengan 3 penyesuaian (baris 23–25); v0.4.1 dieksekusi penuh sekarang | Review owner + designer | Owner |
| 23 | 2026-07-12 | Modern meta | Pause menu + volume per channel + fullscreen di v0.4.4 | **Ditarik maju ke v0.4.1** | Owner akan playtest berulang — butuh sekarang | Owner (review i) |
| 24 | 2026-07-12 | Blood Moon | Event cuaca + drop ×2 (v0.1 §4.3) | v0.4.1 + **disambungkan sebagai syarat evolusi/scenario kedua** (pola Alpha Wolf purnama) | Event langit harus menggerakkan konten, bukan sekadar modifier | Owner (review ii) |
| 25 | 2026-07-12 | Craft Transenden | Resep success 1% + pengumuman (v0.2 §2) | v0.4.2: dibuat sebagai **MOMEN** — animasi ritual + jeda dramatis + pengumuman, bukan sekadar resep | Chase item butuh dramaturgi | Owner (review iii) |

| 26 | 2026-07-12 | Pola musuh | "minimal 3 arketipe perilaku per wilayah" (arahan) | Pola diturunkan dari ARKETIPE roster (lunge/flank/burst) + telegraf universal — semua 60 spesies otomatis kebagian, override per spesies via data `pattern` | Lebih skalabel daripada menulis pola per wilayah; memenuhi "0% jalan-nabrak" | Agent (eksekusi v0.4.1) |
| 27 | 2026-07-12 | Nokturnal | (belum diatur teknis) | Flag data `nocturnal` + gating spawner; 4 spesies awal (owl/bat/jackal/snow_owl) | Minimal-invasif, konten data-driven | Agent (eksekusi v0.4.1) |

| 28 | 2026-07-12 | Rune System | Direncanakan v0.4.2 #5 DAN v0.4.4 #6 (duplikasi di plan) | **DITUNDA ke fase pembukaan konten** — dipasangkan dengan loot dungeon & slot monster Epic+; v0.4.2 fokus Transenden+Enchant+Coating+Quality+Enchanter | Review designer (i): hapus duplikasi; rune butuh sumber loot yang belum ada | Owner/Designer |
| 29 | 2026-07-12 | Ledger | (dua sistem tak terdaftar) | Baris baru Bagian 1: **durability & repair gear** (GDD §10.2, Belum — prioritas rendah) & **Mode Hemat/target performa** (v0.2 §1, Ada — dijaga saat juice pass) | Review designer (ii): kelengkapan ledger | Owner/Designer |

| 30 | 2026-07-12 | **Skill Tree terikat lokasi** (SISTEM BARU) | (belum ada sistem pohon skill) | `skill_trees.json` + `unlock_location`: pohon hanya DIBUKA di lokasinya (upgrade node bebas di mana pun setelah dimiliki); Penjaga Pohon menampilkan pohon luar-lokasi sebagai RUMOR berarah; pemetaan resmi 14 lokasi (lihat Bagian 1 §7); lokasi yang wilayahnya belum ada = terkunci-konten, aktif otomatis saat wilayah dibuka | Addendum owner: perjalanan untuk membuka = insentif eksplorasi, bukan bolak-balik | Owner |
| 31 | 2026-07-12 | Kota Beast "Wildhearth" | (tidak ada di GDD) | Pemukiman beastfolk BARU didaftarkan sebagai **konten beku**: pohon BEAST & TRANSFORMATION (menjinakkan lanjut, kebuasan, jalur transformasi/fusion-monster) + Beternak lanjut | Addendum owner (pemetaan pohon) | Owner |
| 32 | 2026-07-12 | Class/profesi Penjinak | +50% EXP profesi utama pada "aktivitas intinya" (v0.2 §3) | Ditegaskan: bonus berlaku juga saat AKSI TAMING itu sendiri — sukses MAUPUN percobaan (XP percobaan lebih kecil), bukan hanya progres affinity | Addendum owner (3) | Owner |

| 33 | 2026-07-12 | **ClassSelect: dua JALUR** | 6 class combat saja (FF-2a) | New Game = **tab JALUR TEMPUR** (6 class combat) + **tab JALUR KEHIDUPAN** (4 class konsolidasi: **Perajin/Petani/Peramu/Penjinak** — +50% EXP domain, starting kit, perk khas, **pilih 1 combat sub**: 1 senjata + 2 skill, aturan sub berlaku); quest pembuka bercabang ringan; intro variasi 1 layar; Status/Profesi menampilkan jalur; class kehidupan = **diskon 50% + 1 node gratis** di pohon skill domainnya | Koreksi owner yang HILANG sebelum masuk ledger (BUG DESAIN BD-1 di GAP_AUDIT) — dicatat retroaktif saat verifikasi kepatuhan, dikerjakan hari ini | Owner |

| 34 | 2026-07-12 | **PIAGAM PENGALAMAN** (amandemen identitas) | 3 pilar sistem (GDD v0.1 §1.2) | + **3 Pilar Pengalaman** di atasnya: **WONDER** (rahasia bertingkat: tier-remah solo-findable via rumor/ramalan/gosip; tier-legenda nyaris tanpa petunjuk; kandidat: Nameless Door 03:33 WIB+bulan baru+musim dingin, Forgotten Musician 3 musim, Sleeping Giant gunung=boss hidup), **BELONGING** (Homestead → LIVING HEADQUARTERS → kerajaan; rekrut puluhan penduduk ber-syarat; = evolusi resmi Pact System), **LEGACY dua-lapis** (offline: Kitab Sejarah Dunia + aula patung + maker's mark + first-personal; online nanti: sistem sama jadi first-global) | Piagam owner — dokumen identitas, BUKAN perintah membangun | Owner |
| 35 | 2026-07-12 | Identitas proyek | "Dunia bereaksi terhadap pemain" (v0.1 §1.1) | Resmi: **"THE WORLD REMEMBERS"** + slogan: "Aetherion bukan dunia yang menunggu pemain datang. Aetherion adalah dunia yang terus berjalan, menyimpan rahasia, dan mengingat apa yang dilakukan pemain." **Living Sky ditegaskan = sistem gameplay TERBESAR** (Tahun Langit, eclipse, meteor shower, Celestial Alignment membuka pohon tersembunyi) | Piagam owner | Owner |
| 36 | 2026-07-12 | Desain boss masa depan | Boss = solo/party generik (v0.1 §11.2) | Boss **RAID-CLASS** (Sleeping Giant, world boss, boss cerita besar) didesain butuh **entourage 2–4 rekrutan markas** (mekanik multi-aktor); **boss reguler tetap solo-able** — jangan menghukum penyendiri | Piagam owner §3 | Owner |
| 37 | 2026-07-12 | Roadmap | v0.4.x (MASTER_PLAN) tanpa v0.5+ terinci | **REVISI:** v0.5 STORY & SOUL (target terbesar + Wonder tier-legenda pertama + benih chronicle) → **v0.6 "HEARTH & LEGACY"** (Living HQ/kerajaan + rekrutan + companion AI + World Remembers v1 + Rune [selaras #28]) → v0.7 Emberfall/Ocean → v0.8 Celestia → v0.9 demo publik; racing/gambling/marketplace/MMO tetap beku. Dicatat di TRACKBACK.md (dibuat baru — belum ada di repo) + MASTER_IMPROVEMENT_PLAN | Piagam owner §4 | Owner |
| 38 | 2026-07-12 | **World Remembers v1** (spec) | (belum ada) | Spec masuk ledger untuk **v0.6 — JANGAN dibangun sekarang**: (a) memori NPC personal (dipukul→dingin/harga+20%/panggil penjaga/pulih via waktu-maaf berbiaya; ditolong→hangat/diskon/prioritas rekrutan; reputasi kota agregat), (b) **Sistem RIVAL** (Rare+ lolos HP<50%→respawn +1★ maks +2, julukan, aura, baris isyarat; kalahkan=reward+chronicle; 2–3 hidup bersamaan, terlama memudar; mati oleh Rival→pangkat naik cap tetap; desain khas Aetherion terikat counter/langit, bukan tiruan sistem berpaten), (c) reaksi dunia v1 (Forest Spirit, migrasi overhunt, kota berkembang) | Arahan owner II | Owner |
| 39 | 2026-07-12 | Penjaga gerbang | Penjaga MENDORONG monster keluar (UI/UX §4) | Penjaga **DATANG & MEMBUNUH SATU PUKULAN** monster yang mendekati batas kota (animasi serang + juice normal); **pemain nol reward** dari kill penjaga: nol EXP, nol drop, nol progres quest/counter (cegah exploit pancing-ke-gerbang); multi-monster ditangani satu per satu; penjaga tetap abadi | Arahan owner III — satu-satunya kerja kode sekarang | Owner |

| 40 | 2026-07-12 | **GERBANG 0** | Menunggu playtest owner | **LULUS — "sudah tidak hampa"**; gerbang terbuka. Owner belum puas penuh → ronde perbaikan **v0.4.1c** sebelum v0.4.2 | Hasil playtest owner | Owner |
| 41 | 2026-07-12 | ClassSelect Jalur Kehidupan | (bug) panel kehidupan tanpa tombol Lanjut | **BUG P0**: tombol "Lanjut" hanya dibuat di builder panel tempur → jalur kehidupan BUNTU. Fix: alur penuh Kehidupan→sub→Lanjut→Creator→intro→in-world + audit navigasi semua layar creator | v0.4.1c (1) | Owner |
| 42 | 2026-07-12 | Tangga dungeon | Memanjat hanya saat hold W/S (jatuh saat lepas) | Standar platformer modern: sentuh+W/S = menempel; lepas tombol = MENGGANTUNG; SPACE = lompat lepas (boleh berarah); menjauh/mendarat = lepas otomatis; tidak nyangkut di ujung atas | v0.4.1c (2) | Owner |
| 43 | 2026-07-12 | **"Pilih Dunia"** travel hub | Fast travel direncanakan v0.4.3 | **Ditarik maju sebagian**: GERBANG PENJELAJAH di 5 pemukiman/titik masuk; UI kartu wilayah yang PERNAH dikunjungi (nama+level+cuaca live), klik = fade travel; belum dikunjungi = siluet terkunci (kunjungan pertama tetap jalan kaki); biaya kecil gold, travel pertama per hari GRATIS | v0.4.1c (3) — menyelesaikan "tidak ada jalan pulang" | Owner |
| 44 | 2026-07-12 | UI/UX feel | UI statis fungsional | **Pass modern & playful** (tetap pixel + palet resmi): motion tween panel/tombol/tab, idle breathing halus, SFX konsisten semua interaksi, micro-celebration konfirmasi penting, microcopy berkepribadian; SEMUA nilai di **ui_feel.json**; hormati Mode Hemat | v0.4.1c (4) | Owner |

| 45 | 2026-07-12 | Dokumen kompas | (blueprint dirujuk direktif) | **BD-2**: file `docs/MASTER_BLUEPRINT_AETHERION.md v1.0.1` TIDAK sampai ke workspace — keputusan dikanonisasi dari TEKS DIREKTIF; file menunggu kiriman ulang. **Hierarki resmi tetap dicatat: PLAN_LEDGER > MASTER_BLUEPRINT > MASTER_IMPROVEMENT_PLAN > STATUS** | Integritas: tidak memfabrikasi dokumen kanonik | Agent (lapor) |
| 46 | 2026-07-12 | **B1** Domain & Life Events | Profesi level 1–99 (v0.1 §3.4) | Domain keahlian **5-tier** + **LIFE EVENTS** (peristiwa hidup bermakna per domain) | Blueprint v1.0.1 (via direktif) | Owner/Direktur |
| 47 | 2026-07-12 | **B2** Monster bekerja | Pet = combat/mount/pasif (v0.1 §8.2) | Monster jinak bisa BEKERJA (tugas produktif markas/homestead) | Blueprint | Owner/Direktur |
| 48 | 2026-07-12 | **B3** Legacy Family | (tidak ada) | Sistem keluarga/penerus **tanpa-makan-slot** (tidak mengambil slot karakter) | Blueprint | Owner/Direktur |
| 49 | 2026-07-12 | **B4** Dunia maju saat ditinggal | Offline growth hanya tanaman | DUNIA berjalan maju saat pemain pergi (konsisten THE WORLD REMEMBERS) | Blueprint | Owner/Direktur |
| 50 | 2026-07-12 | **B5** Celestial Crisis | Supernova live-event (GDD v0.3 §2.2) | **Celestial Crisis = FF Moment**, DISATUKAN dengan supernova GDD v0.3 §2.2 (satu klimaks, bukan dua sistem) | Blueprint | Owner/Direktur |
| 51 | 2026-07-12 | **B6** Naratif inti | (belum ada cerita utama) | Tema **Memori-vs-Pelupaan**; antagonis **Sang Nirnama**; **TANPA Chosen One**; boss = MEKANIKA (bukan gimmick cerita); **expedition encounter** sebagai bentuk pertemuan konten | Blueprint | Owner/Direktur |
| 52 | 2026-07-12 | **B7** Perayaan Legacy | Chronicle pasif (Piagam #34) | Momen LEGACY DIRAYAKAN aktif (seremoni, bukan hanya tercatat) | Blueprint | Owner/Direktur |
| 53 | 2026-07-12 | **B8** Rumah Lelang NPC | Marketplace ditunda online (v0.1 §10.3) | **Rumah Lelang NPC offline**: maks tier A; sumber barang tematik termasuk **tawanan-dibebaskan**; masuk v0.4.2 | Blueprint | Owner/Direktur |
| 54 | 2026-07-12 | **B9** Taming semua | Beberapa spesies terlarang (tame_base 0; Star Whale tak ber-entitas) | **SEMUA spesies dapat dijinakkan** (rate boleh ekstrem); larangan dihapus; Star Whale saat jadi entitas dunia wajib tameable | Blueprint | Owner/Direktur |
| 55 | 2026-07-12 | **B10** Level & durasi | Cap 99 (v0.1 §3.4); Fase 0 kompresi L1–55 (#19) | **Level TANPA batas**; target pengalaman **all-in-one ±500 jam**; kompresi Fase 0 = SEMENTARA | Blueprint | Owner/Direktur |
| 56 | 2026-07-12 | **B10-A** Active Loadout | 5 slot hotbar; semua skill dibawa | **Semua ilmu dapat dipelajari, tidak semua dibawa**: skill aktif ter-equip 20–30, slot pasif/ultimate/fusion terbatas, ganti hanya di ZONA AMAN, preset bernama | Amandemen Direktur v1.0.1 | Owner/Direktur |
| 57 | 2026-07-12 | **B10-B** Capstone class | Advanced class teaser | **Capstone EKSKLUSIF per class** (node puncak pohon class; class lain bisa buka seluruh pohon KECUALI capstone; tak bisa di-grinding lintas-class). **10 nama lengkap (blueprint §4, dilengkapi #67):** Warrior WORLDBREAKER · Mage ASTRAL GENESIS · Archer Panah Cakrawala · Assassin Seribu Bayang · Paladin Sumpah Fajar · Necromancer THRONE OF SOULS (ditenagai Chronicle) · Perajin Karya Agung Sejati · Petani Panen Raya Abadi · Peramu Ramuan Sang Filsuf · Penjinak ANCIENT BEAST PACT. Default diterima bila tak diveto owner sebelum v0.5 | Amandemen Direktur | Owner/Direktur |
| 58 | 2026-07-12 | **B11** Autonomous Kingdom | Living HQ (Piagam #34) | Kerajaan markas berjalan OTONOM (produksi/keputusan tanpa micromanage) | Blueprint | Owner/Direktur |
| 59 | 2026-07-12 | **B12** Stability | (tidak ada) | Metrik **Stability 3 ukuran** untuk kerajaan/markas | Blueprint | Owner/Direktur |
| 60 | 2026-07-12 | **B13** Expansion | (tidak ada) | **3 jalur ekspansi** kerajaan | Blueprint | Owner/Direktur |
| 61 | 2026-07-12 | **B14** Model bisnis | F2P + kosmetik (v0.1 §15) | **GRATIS PENUH** (tanpa monetisasi) | Blueprint | Owner/Direktur |
| 62 | 2026-07-12 | **B15** Lokalisasi | UI hardcode Bahasa Indonesia | **Pilihan bahasa ID/EN**; konvensi string-key WAJIB untuk teks baru mulai commit berikutnya; infra masuk v0.4.4 | Blueprint | Owner/Direktur |
| 63 | 2026-07-12 | **B16** Nada | Ramah semua umur (implisit) | Nada naratif **BERANI GELAP** | Blueprint | Owner/Direktur |
| 64 | 2026-07-12 | **B17** Companion Bible | (tidak ada) | WAJIB sebelum v0.5 penuh: **50 tokoh** (15 Tier-S companion, 15 Tier-A tokoh dunia, 20 Tier-B rekrutan) — tiap tokoh: identitas/relasi/tujuan/konflik/Life-Event-chain. **= GERBANG v0.5** | Amandemen Direktur | Owner/Direktur |
| 65 | 2026-07-12 | **B18** Nirnama Bible | (tidak ada) | WAJIB sebelum Act 1: nama asli, sejarah, kerajaan asal, penyebab kejatuhan, hubungan Crisis lama & Chronicle, alasan memilih pelupaan. **= GERBANG Act 1** | Amandemen Direktur | Owner/Direktur |
| 66 | 2026-07-12 | **B19** World Personality | Wilayah = bioma + monster | **Enam Lingkup Budaya** (tabel §3.9 LENGKAP via #67): **Aetheria** (Greenvale/Candyveil/Frostpeak/Storm — Peradaban·Kerajaan·Rumah) · **Wildhearth** (+Ancient Jungle — Kebebasan·Naluri·Monster) · **Celestia** (+Menara Astrologer — Pengetahuan·Langit·Takdir) · **Undersea** (Ocean — Adaptasi·Eksplorasi·Peradaban Hilang) · **Underground** (Desert Ruins/tambang/Abyss — Keserakahan·Ambisi·Rahasia) · **Sky Realm** (Skyveil — Harapan·Transendensi·Keabadian). Berpindah wilayah = berpindah budaya (arsitektur/musik/dialek/quest/hukum/pohon). **KOREKSI PENOMORAN tercatat: Direktur menulis "B14"; nomor benar B19** | Amandemen Direktur | Owner/Direktur |

| 67 | 2026-07-13 | **BD-2 RESOLVED** | File blueprint hilang (#45) | `docs/MASTER_BLUEPRINT_AETHERION.md` v1.0.1 DITERIMA & di-commit (+ `AETHERION_PROPOSAL_LENGKAP_FINAL.md` sebagai dokumen warisan). Teks penuh mengungkap tambahan yang kini sah: **4 PILAR Pengalaman** (WONDER/BELONGING/**STEWARDSHIP** baru/LEGACY), roadmap bernama v0.7 HORIZON · v0.8 CELESTIA & CRISIS · v0.9 GENERATION, North Star "pendiri sejarah", detail Rumah Lelang (lot harian + istimewa purnama, bidding lawan NPC berkepribadian), capstone & tabel budaya lengkap (→ #57/#66 dilengkapi) | Kiriman Direktur | Owner/Direktur |
| 68 | 2026-07-13 | **K1** Loadout vs Hotbar | Konflik REPORT-01 #2 | **Arsitektur TIGA LAPIS**: DIPELAJARI (tak terbatas) → LOADOUT ter-equip (20–30 aktif + slot pasif/ultimate/fusion terbatas; ganti hanya zona aman/Domain; preset bernama) → HOTBAR 5 (prime dari isi loadout, ganti kapan pun). Hotbar-prime yang ada TIDAK berubah; loadout = lapisan baru di atasnya. **Spec dikunci sekarang; implementasi penuh v0.9** | Klarifikasi Direktur | Owner/Direktur |
| 69 | 2026-07-13 | **K2** Level-tanpa-batas vs kalibrasi | Konflik REPORT-01 #1 | Kompresi Fase 0 = **"band level aktif"** — harness v2 valid di band itu; melewati band konten = **soft-cap EXP menanjak tajam** (pemain tak bisa lari jauh dari kurva konten); tiap wilayah baru memperluas band; **rebase kurva final + harness di v0.9 GENERATION** | Klarifikasi Direktur | Owner/Direktur |
| 70 | 2026-07-13 | Blocker lunak v0.4.2 | REPORT-04 (a)/(b) | **DEFAULT DISETUJUI**: (a) tawanan-dibebaskan = NPC minor hasil CharGen dengan tag latar sederhana + sesekali kandidat bernama dari pool placeholder (kelak diganti tokoh Tier-B Companion Bible); (b) daftar item C/B pengisi piramida disusun agent dari data yang ada, review designer pasca-implementasi. **GAS v0.4.2** — mandat otonom penuh, gerbang playtest owner di ujung | Direktur | Owner/Direktur |
| 71 | 2026-07-13 | Draft konten v0.4.2 oleh agent (per default #70b) | — | **8 item C/B**: Bilah Gletser, Tongkat Percik Beku, Zirah Kulit Kayu Hidup, Selendang Sutra Awan [C]; Batang Aether, Pedang Taring Naga, Zirah Sisik Naga, Jubah Sutra Badai [B] — semua dari material existing. **Piramida Transenden**: Mata Pedang Everfrost + Aegis Ankh [A] → Taring Badai [S] → Pembelah Aurora [SS] → Bintang Aetherion [SSS]; rate 0.5/0.35/0.2/0.1; material kunci selamat saat gagal; ritual MOMEN (TranscendentRitual overlay + pengumuman nama penempa). MENUNGGU review designer pasca-implementasi | Agent (mandat #70) | Agent |
| 72 | 2026-07-13 | Keputusan desain agent — Gear Meta v0.4.2 (aturan b) | Spec REPORT-04 #2/#3/#4 | (i) **gear_meta per item_id** (bukan per-instance): kualitas/maker/enchant dibagi semua salinan item_id sama — kompromi sadar demi model inventory stack "game ringan"; wajar untuk gear yang biasanya dimiliki 1; (ii) kualitas = Normal 1.0 / Halus 1.05 / Adikarya 1.10 (roll 65/25/10%, kualitas terbaik dipertahankan); (iii) enchant **+3% stat/level**, biaya emas 6%×nilai×level tujuan (gold sink), layanan NPC Enchanter TERBUKA semua pemain — profesi Enchanter aktif = diskon 30% + perk peluang (agar profesi tetap bernilai tanpa mengunci sistem); (iv) coating 180 dtk, +25% damage elemen sekunder per pukulan + roll status | Agent (mandat #70) | Agent |
| 73 | 2026-07-13 | Keputusan desain agent — Rumah Lelang (aturan b, spec B8 #53) | Blueprint §10 | (i) Model bidding LANGSUNG (bukan tunggu tutup hari): pemain menawar → rival NPC berkepribadian membalas atau menyerah; menyerah = palu jatuh, pemain bayar & menang — ramah sesi pendek, tetap terasa "perang tawar"; (ii) 4 rival placeholder (Havel agresif / Lirael kolektor / Bram pelit / Sera pemburu senjata) — kelak diganti tokoh Tier-B Companion Bible; (iii) lot: 4/hari + 2 istimewa purnama (bias B/A), buyout 140–180% nilai (gold sink); S+ difilter keras di kode + test 120 hari; (iv) tawanan: lot 🔗 (nada gelap B16), menang = MEMBEBASKAN → WorldState.freed_captives {nama, tag latar, loyal:true} = kandidat rekrut markas v0.6; 30% bernama dari pool 5 placeholder, sisanya NPC minor generik + tag (#70a) | Agent (mandat #70) | Agent |
| 74 | 2026-07-13 | **DEVIASI B15 diakui**: string UI baru v0.4.2 belum via Loc.t() | B15 #62 | String v0.4.2 = format dinamis berparameter; Loc.gd belum punya infra parameter (dijadwalkan v0.4.4 bersama TranslationServer). Seluruh string v0.4.2 masuk daftar retrofit v0.4.4. Detail di GAP_AUDIT "DEVIASI-B15" | Agent (aturan b/d — laporan jujur) | Agent |
| 75 | 2026-07-13 | **E1 HUKUM DIREKTUR #1 — Gerbang Pilar** | Piagam 4 Pilar (#67) | Setiap fitur baru WAJIB memperkuat ≥1 pilar (Wonder/Belonging/Stewardship/Legacy) atau **DITOLAK**. Ditulis di CLAUDE.md sebagai gerbang review fitur; sebelum menulis kode fitur baru, tulis 1 kalimat di Decision Log menyebut pilar yang dikuatkan. Fitur yang hanya "menambah angka" tidak lolos | Ekstrak konsepsi GPT (file `docs/Aetherion_blueprint_reasoning_and_design.txt`) | Owner/Direktur |
| 75b | 2026-07-13 | **E2 LAW OF ERAS** | — | TIDAK ADA ending dunia — hanya ending karakter/keluarga/dinasti/**era**. Struktur cerita = ERA; **Era 1 = "The Age of Memory"**. Echo Principle + dua emosi resmi baru: **Loss** & **Continuation**. Pesan inti: "segala sesuatu akan berakhir, namun itu bukan alasan berhenti membangun" (D040-042: konflik manusia > monster; harapan HARUS mungkin menang — pelengkap B16, bukan pembatalnya) | Ekstrak konsepsi | Owner/Direktur |
| 76 | 2026-07-13 | **E3 OPENING KANON v0.5** + **E4 WONDER LAWS** | Intro 4-layar sekarang | (E3) Pemain pindah dunia **SUKARELA** — tanpa ramalan, tanpa paksaan, tanpa Chosen One; jatuh dari langit; diselamatkan **PEGASUS** yang hanya berkata **"Carilah aku"** lalu hilang. Pegasus = SIMBOL (bukan mount, bukan tutorial NPC); kemunculannya wajib langka & bermakna; hubungan Pegasus–Nirnama = MISTERI BESAR RESMI. **Intro 4-layar saat ini = PLACEHOLDER, di-rework v0.5.** (E4) Great Unknown: **10% dunia tidak pernah dijelaskan SELAMANYA** → `docs/MISTERI_ABADI.md` dibuat (M1 asal Pegasus, M2 isi Nameless Door, M3 siapa The Waiters, M4 relasi Pegasus–Nirnama); **Wonder Preservation Law** masuk CLAUDE.md | Ekstrak konsepsi | Owner/Direktur |
| 77 | 2026-07-13 | **E5 [BANGUN] RUMOR TIDAK AKURAT (D025)** | Gosip warga sebelumnya selalu benar | **World Remembers TIDAK sempurna**: `rumors.json` data-driven (truth + 1–2 `distortions` + `accuracy`); gosip warga boleh melenceng/membesar-besarkan; **rumor Penjaga Pohon TETAP AKURAT** (fungsional — mengarahkan ke lokasi pohon, sengaja dikecualikan). Keajaiban (E7) hanya diumumkan lewat gosip ini dan justru paling sering diceritakan keliru | Ekstrak konsepsi | Owner/Direktur |
| 78 | 2026-07-13 | **E6 [BANGUN] HUKUM NPC ANEH** | Warga hanya 5 rute generik (Greenvale/Frostpeak); 3 wilayah tanpa warga | Tiap kota/desa WAJIB ≥5 NPC berkepribadian: **1 Aneh, 1 Misterius, 1 Lucu, 1 Tragis, 1 Tak-masuk-akal** — dibuat untuk 5 pemukiman (Greenvale, Pos Pendaki Frostpeak, Candyveil, Reruntuhan Gurun, Storm Island) = **25 NPC** (`town_npcs.json`, 3–4 baris dialog bergilir, sebagian sadar-langit). **Oddwalker/Hidden Legend**: 3 dari 25 (~10%) menyimpan isyarat samar — **TANPA payoff sekarang, hanya benih** (disengaja). Dijaga test `_test_town_folk` | Ekstrak konsepsi | Owner/Direktur |
| 79 | 2026-07-13 | **E7 [BANGUN] MIRACLE SYSTEM v1** | Tidak ada peristiwa dunia yang tak dipicu pemain | Scheduler harian deterministik (seed = hash tanggal WIB, 28% peluang/hari) untuk 4 keajaiban ringan: (i) **Bunga Purba** mekar semalam (item unik, bisa dipetik), (ii) **migrasi kawanan** burung/kunang lintas layar, (iii) **pelangi ganda** pasca-hujan (buff EXP +5% / 10 menit), (iv) **bintang jatuh** malam cerah (jejak + Serpihan Bintang di titik jatuh). **TIDAK PERNAH ada popup** — satu-satunya pengumuman = gosip NPC keesokan harinya ("kudengar semalam...") lewat RumorSystem, dan gosip itu boleh salah | Ekstrak konsepsi | Owner/Direktur |
| 80 | 2026-07-13 | **E8 [BANGUN] QUEST TAXONOMY + HUKUM QUEST** | quests.json tanpa dimensi manusia | Taksonomi 11 label (Need/Dream/Fear/Ambition/Memory/Legacy/Hidden/Chronicle/Myth/World/Era) + label kecil di daftar quest. **HUKUM QUEST (CLAUDE.md): setiap quest harus MENGUBAH sesuatu; kill/collect tanpa konteks manusia DILARANG sebagai inti quest.** Audit: **9 quest existing diberi konteks manusia** (bukan hanya 3 pembuka — ternyata semuanya telanjang). **DEVIASI TEKNIS (aturan b):** field `type` sudah dipakai untuk MEKANIK (kill/gather/craft/tame) sejak Fase 0, jadi taksonomi memakai nama field **`quest_type`** | Ekstrak konsepsi (+deviasi nama field oleh agent) | Owner/Direktur + Agent |
| 81 | 2026-07-13 | **E9 SPEC-ONLY (JANGAN DIBANGUN)** | — | Dicatat sebagai spec masa depan, **tidak diimplementasikan sekarang**: kuburan = arsip + **Book of Fools** (bagian Chronicle v0.5); kepribadian NPC = Temperament + BigFive + trauma (Companion Bible B17); **Netherdeep Syndicate** = faksi besar underground (v0.7+); crime → bounty/manhunt (v0.6 World Remembers); faksi = interest (bukan moral); kematian NPC → reaksi berantai (v0.6); companion = protagonis hidupnya sendiri, punya relasi tanpa pemain, **tidak semua menyukai pemain** (Companion Bible); monster multi-elemen & mutasi-jadi-spesies-baru (fase konten); festival per wilayah (v0.6 B7) | Ekstrak konsepsi | Owner/Direktur |
| 82 | 2026-07-13 | **E10 P1–P5** | Lima pertanyaan konflik | **DIPUTUS OWNER 2026-07-13 → lihat #86–#90.** Tanda [PENDING OWNER] DIBUKA; larangan implementasi turunan dicabut — namun P1–P5 semuanya tetap **SPEC-ONLY** (tidak dibangun sekarang) | Owner | Owner/Direktur |
| 83 | 2026-07-13 | **v0.4.3 #7 / Addendum A4 — MUSIM v1** (gap "NOL" ditutup) | v0.1 §4.2 & Fase0 §3 tak pernah dibangun | **Pilar (Hukum #1 #75): STEWARDSHIP** (musim memaksa trade-off nyata: tanam di luar musim = merambat 2.5×, atau bayar 3500G untuk Rumah Kaca) **+ WONDER** (dunia berganti rupa tanpa diminta). Implementasi: 4 musim × **2 minggu NYATA** (siklus 56 hari) terikat tanggal WIB — berjalan walau game ditutup, seperti bulan & jam; `seasons.json` (tint dunia via GameClock.ambient_color → semua wilayah ikut, drop_mult, elemen favorit spawn, crop_growth_mult); Gugur = drop +15%; bias spawn elemen musim; benih di luar musim tetap boleh ditanam tapi jujur diberitahu lambat; **Rumah Kaca** (item toko) = jalan keluar; HUD menampilkan musim + hari ke-n/14 | Rencana v0.4.3 (MASTER_IMPROVEMENT_PLAN) | Agent |
| 84 | 2026-07-13 | **v0.4.3 #1 Jurnal Quest + #5 Stinger musik** | Quest hanya hidup di Papan; momen besar hanya terlihat, tak terdengar | **Pilar: BELONGING** (pemain selalu tahu ia sedang mengejar apa & untuk SIAPA — deskripsi manusiawi ikut tampil di Jurnal) **+ LEGACY ringan** (momen besar ditandai bunyi). Jurnal: tab baru (tujuan aktif + label taksonomi + alasan manusia + tombol **Lacak**); quest terlacak tampil permanen di layar dengan **arah + jarak** ke sasaran terdekat (panah 8-arah). **DEVIASI/BATAS JUJUR (aturan b):** stinger v1 disusun dari sampel SFX yang sudah ada (urutan pendek + pitch), bukan aset musik baru — aset stinger asli menyusul bila owner menyediakan audio; penanda arah ada di HUD, belum di minimap (menyusul bersama World Map #2) | Rencana v0.4.3 | Agent |
| 85 | 2026-07-13 | **v0.4.3 #6 — Dungeon: peti, RUANG RAHASIA, jebakan** | Dungeon = koridor + bos, tak ada alasan menjelajah | **Pilar: WONDER** (ruang rahasia tak punya pintu & tak punya petunjuk — hanya yang menggali yang menemukannya; penemuan pertama dicatat permanen) **+ STEWARDSHIP** (jebakan = risiko yang bisa dibaca). Semua di DungeonBase → **5 dungeon langsung dapat**: 3 peti/lantai (reset harian WIB → dungeon layak didatangi lagi) + 1 peti rahasia (loot ~3× lebih kaya, glow lembut, gold ×3); jebakan **paku terlihat** & **panah dengan telegraf 0.5 dtk** (bunyi + warna) — damage di-cap 25% max HP: jebakan tak pernah membunuh dari full HP (jebakan tanpa peringatan = desain malas). **Batas jujur:** parallax bg & ambience khas per-dungeon BELUM (masuk sisa v0.4.3) | Rencana v0.4.3 | Agent |
| 86 | 2026-07-13 | **P1 = a — DELAPAN RAS BESAR = kanon peradaban** (SPEC-ONLY) | CharGen 7 ras teknis tanpa kanon peradaban | **8 Ras Besar** (World Bible Part 02): **Human** *The Builders* · **Elf** *The Long Remembering* · **Dryad** *Children of the Living Forest* · **Dwarf** *Keepers of Stone* · **Beastfolk** *Children of Instinct* · **Astralborn** *The Sky Watchers* · **Tidekin** *People of the Endless Sea* · **Shadeborn** *The Forgotten Ones* — lengkap filosofi/budaya/konflik-internal. **DUA HUKUM RAS:** (1) **"Races Are Cultures, Not Stats"** — ras TIDAK memberi bonus stat; ia memberi budaya, sejarah, hukum, prasangka; (2) **"No Race Is Monolithic"** — tiap ras punya perpecahan internal. **Pemetaan ras CharGen (garis keturunan, BUKAN rework):** wolfkin & lizardkin ⊂ Beastfolk; frostkin = manusia utara berdarah Astralborn; undead ↔ kasus khusus terkait Shadeborn (detail di World Bible pass); candyfolk = ras minor lokal Candyveil. **Ras playable BERTAMBAH BERTAHAP mengikuti wilayah yang lahir** (Elf ← Ancient Jungle, Dwarf ← Underground, Tidekin ← Thalassar). **TIDAK ADA rework CharGen sekarang** | Keputusan owner P1 | Owner/Direktur |
| 87 | 2026-07-13 | **P2 = a — REVIVE NPC bersyarat** (SPEC-ONLY, v0.6+/Bible) | Bertabrakan dengan Loss & Chronicle | **Kematian PERTAMA** setiap NPC/companion bernama dapat dibatalkan **MAKSIMAL 1× per NPC**, **selalu kondisional** (cara khusus & sulit, ditulis per kasus di Bible), dan **MUSTAHIL bila tubuh hancur/hilang**. **Kematian KEDUA = dilupakan**: tak bisa dibatalkan kecuali oleh **Chronicle**. Loss tetap nyata tanpa menutup pintu penebusan | Keputusan owner P2 | Owner/Direktur |
| 88 | 2026-07-13 | **P3 = c — PEWARISAN DINASTI dua jalur** (SPEC-ONLY; sistem nikah = v0.9 GENERATION) | Legacy Family (B3) tanpa mekanisme pewaris | Dua jalur SAMA-SAMA sah: **(i) pernikahan pemain** dengan companion/NPC — **lahir dari hubungan, BUKAN checklist affinity** (D029) → **anak sebagai INDIVIDU** dengan sifat & kehendak sendiri (D030) → kandidat pewaris; **(ii) murid / anak angkat** — jalur penuh bagi pemain yang tak menikah (tidak dihukum) | Keputusan owner P3 | Owner/Direktur |
| 89 | 2026-07-13 | **P4 = a — SIMULASI DUNIA = SAAT-LOGIN** (PRINSIP ARSITEKTUR PERMANEN) | B4 "dunia maju saat ditinggal" tanpa arsitektur | Dunia **TIDAK** di-tick real-time penuh. Saat load, dunia **menghitung kejadian dari selisih waktu WIB nyata** sejak terakhir main: panen, Life Events, perkembangan kerajaan, quest yang selesai/gagal sendiri, surat menunggu. **Berlaku untuk SEMUA sistem "dunia berjalan tanpa pemain"** — desain yang menuntut tick terus-menerus harus dirancang ulang jadi model selisih-waktu. Preseden yang sudah patuh: pertumbuhan tanaman, fase bulan, musim (#83), lot lelang harian (#73), keajaiban harian (#79) | Keputusan owner P4 | Owner/Direktur |
| 90 | 2026-07-13 | **P5 = a — THALASSAR & wilayah masa depan** | "Ocean Kingdom" = label sementara | **THALASSAR = nama resmi LAUTAN dunia Aetherion.** Undersea / "Ocean Kingdom" kini = **Kerajaan Thalassar**; **TIDEKIN** = ras penghuninya (#86). Label diganti di seluruh dokumen + UI. **Negeri Elf, Negeri Dwarf, Fairy Realm** didaftarkan sebagai **wilayah masa-depan pasca-v1.0 / Era berikutnya** di peta konten beku. **DEVIASI TEKNIS (aturan b):** id data internal tetap `ocean_kingdom` (dipakai skill_trees.json & save lama) — yang berganti adalah semua LABEL tampil + dokumen; rename id ditunda ke migrasi data v0.7 agar save tak pecah | Keputusan owner P5 (+deviasi id oleh agent) | Owner/Direktur + Agent |
| 91 | 2026-07-13 | **v0.4.3 #8 / Addendum A5 + Audit B — 12 RASI penuh + prakiraan Astrolog** | 12 aset rasi menganggur; ramalan = teks kosong; prakiraan 24 jam tak pernah ada | **Pilar: WONDER** (langit punya suara: **rasi naik** berganti tiap minggu NYATA — sama untuk semua pemain — dan ramalannya = teka-teki yang menunjuk konten aktif: skenario tersembunyi, keajaiban semalam) **+ LEGACY ringan** (rasi kelahiran = jejak tanggal kau memulai). `rasi.json` 12 rasi (aset `rasi_*_96.png` AKHIRNYA dipakai) + filosofi + teka-teki + **bonus tematik KECIL 2–3%** (identitas, bukan power spike — dijaga test: tak ada rasi >3%). **Prakiraan cuaca Astrolog 24 jam, akurasi ~80% (janji GDD dibayar):** langit kini punya RENCANA harian deterministik (seed tanggal+blok 3 jam); rol cuaca mengikuti rencana 80% waktu, 20% langit berubah pikiran — jadi 80% itu NYATA, bukan angka kosmetik | Rencana v0.4.3 | Agent |
| 92 | 2026-07-13 | **Gelombang aset baru: musik, SFX Minifantasy, Pixel Chest Pack** (v0.4.3 #5 tuntas) | Musik: 3 track Ninja Adventure dipakai berulang; peti = kotak prosedural; stinger = sampel SFX | **Pilar: WONDER + BELONGING** (dunia terdengar berbeda di tiap tanah). **KURASI KETAT (perintah owner):** pack mentah WAV bergiga TIDAK masuk build — 9 track terpilih + 5 stinger dipotong, di-encode ulang OGG (musik q1 ≈80-96kbps, stinger/SFX q3). **Total audio build ≈11 MB** (batas 25 MB). Musik khas: menu · greenvale (hangat) · town/plaza · candyveil (manis) · desert · frostpeak (dingin) · storm (dramatis) · dungeon · boss (otomatis saat boss_engaged) + **crossfade 1,2 dtk** antar scene. **Stinger v1 di-rework memakai potongan musik ASLI** (Victory/Complete/Strange) — fallback sampel lama tetap ada bila file hilang. Peti dungeon kini memakai **Pixel Chest Pack** (umum=Retro · langka=Metal + tabel loot `chest_rare` baru · rahasia=Golden); SFX **Minifantasy** (Leohpaz): peti terbuka, pintu batu ruang rahasia, paku, panah, peti kayu, langkah batu. **Disimpan (dicatat di ASSET_LOG):** Pirate → Thalassar (v0.7), Sci-fi Space → Celestial/Void (v0.8), Piano → momen cerita (v0.5), Kenney UI-audio & input-prompts → v0.4.4, Abstraction loops & Cainos props → **belum dipakai** (bank AlkaKrab sudah cukup; dinilai ulang saat pass parallax/dressing — dicatat jujur, bukan diklaim terpakai). **Ukuran exe: 85,5 MB → 92,5 MB (+7 MB)** | Aset owner + rencana v0.4.3 | Agent |
| 93 | 2026-07-13 | **v0.4.3 #1 — PETA (wilayah + dunia) & fast travel** | Hanya minimap radar; travel hanya lewat gerbang fisik | **Pilar: BELONGING** (pemain selalu tahu di mana ia berdiri dan apa yang ada di sekitarnya). Peta dua tingkat (M / tab Peta): **peta wilayah** = posisi pemain live + marker yang DIBACA DARI NODE HIDUP di scene (dungeon/gerbang/Penjaga Pohon/bengkel/pedagang/lelang/peti/rumah) + **sasaran quest yang dilacak** dari Jurnal — peta tak bisa berbohong karena ia membaca dunia itu sendiri; **peta dunia** = kartu semua wilayah, belum dikunjungi = siluet. Gaya parchment (UiTheme). **PENTING (perintah owner dipatuhi):** TIDAK ada sistem travel kedua — `TravelUI.do_travel()` di-refactor jadi SATU jalur yang dipakai gerbang fisik maupun peta (syarat pernah dikunjungi, gratis sekali sehari lalu 25G — identik; dijaga test) | Rencana v0.4.3 | Agent |
| 94 | 2026-07-13 | **v0.4.3 #3 — CUTSCENE MINI ENGINE** (data-driven) | Adegan hanya bisa ditulis di kode | Stage diperluas jadi pemutar skrip `cutscenes.json`: 14 perintah (move_actor/face/camera_pan/camera_zoom/dialog/wait/fade/play_music/play_stinger/sfx/spawn/despawn/shake/banner). **Input pemain TERKUNCI** selama cutscene (`cutscene_lock` di Player & PlayerPlatformer) + **skip dengan MENAHAN ESC 0,6 dtk** (hold, bukan tap — agar tak terlewat tak sengaja). Headless melewati langkah berbasis tween (test tak boleh menggantung; dijaga watchdog 600 frame). **Bukti kerja = 3 cutscene nyata:** (a) `intro_arrival` — opening di-rework memakai engine (pemain JATUH dari langit lalu disambut; **masih placeholder pra-v0.5**, opening kanon Pegasus #76 menyusul), (b) `forest_spirit_wrath`/`forgiven` (butir 4), (c) `first_clear` = template perayaan | Rencana v0.4.3 | Agent |
| 95 | 2026-07-13 | **v0.4.3 #9 — FOREST SPIRIT (Hidden Scenario #4) + penebusan** | GDD v0.2 §8.2 tak pernah dibangun | **Pilar: STEWARDSHIP** — dan ini implementasi paling literal darinya. Menebang >200 pohon (env `AETHER_SPIRIT` untuk uji) membangunkan Roh Hutan. **Ia tidak menyerang dan tidak bisa dilawan** — ia BERHENTI MEMBERI: hutan Greenvale **memucat** (tint) dan **lebih sepi** (spawn ×0,6 — sepi, bukan lebih ganas). **Penebusan:** tanam bibit pohon (tombol G, di LUAR kota; bibit dari drop menebang 35% & toko) sampai rasio pulih → Roh kembali damai: **berkah** (+15% hasil kayu/herbal) + **node rahasia pohon Kehidupan** terbuka. **Aturan no_fail dipatuhi: tidak pernah soft-lock** — dunia hanya jadi lebih miskin sampai kau memperbaikinya | GDD v0.2 §8.2 + rencana v0.4.3 | Agent |
| 96 | 2026-07-13 | **v0.4.3 #9b — PERAYAAN FIRST-CLEAR + "Pencapaian Tercatat" (BENIH CHRONICLE)** | Clear pertama tak berbeda dari clear ke-100 | **Pilar: LEGACY.** `Chronicle` autoload: setiap first-clear (skenario, **bos**, ruang rahasia, penebusan Roh Hutan) dicatat **PERMANEN dengan tanggal & jam WIB NYATA** + musim + level + nama penempanya — bukan "hari ke-12 dalam game", melainkan hari sungguhan saat kau melakukannya. Perayaan: banner + cutscene template + **jingle kemenangan dari bank musik** (#92); warga membicarakannya beberapa hari (lewat RumorSystem — dan boleh saja salah menceritakannya). Tampil di tab Pedia "✦ Pencapaian Tercatat". Clear kedua TIDAK dirayakan dua kali (dijaga test) | Piagam LEGACY + rencana v0.4.3 | Agent |
| 97 | 2026-07-13 | **v0.4.3 #4 — JADWAL NPC (3 slot waktu)** | NPC berkeliling rute yang sama 24 jam | **Pilar: BELONGING.** Slot WIB: pagi 05–11 · sore 12–18 · malam 19–04. **25 NPC berkepribadian** punya posisi DAN aktivitas berbeda per slot (Kakek Warno: menunggu ikan menjawab pagi → duduk di bawah lampu bicara sendiri malam; Nyai Tuminah: menjemur dua porsi pakaian → menyalakan lentera untuk yang tak pulang). **NPC fungsional** (bengkel/pedagang/enchanter/juru lelang/guru skill) bekerja siang, **berkumpul di penginapan malam hari — layanan tetap bisa diakses di sana** (dunia hidup ≠ dunia menyusahkan). **Pintu rumah warga terkunci 22:00–05:00.** Dialog kontekstual per slot + apa yang sedang ia kerjakan. **Gerakan murah:** kalau pemain melihat (radius 420) NPC BERJALAN ke pos barunya; kalau tidak, ia dipindah saja — sejalan hukum simulasi saat-login (#89) | Rencana v0.4.3 | Agent |

> Baris berikutnya ditambahkan SEBELUM implementasi keputusan baru. Jangan hapus baris; koreksi = baris baru.
