# PLAN_LEDGER — Dokumen Induk Proyek Aetherion
**Dibuat:** 2026-07-12 atas perintah owner (obat sistemik: tidak ada lagi sistem yang hilang senyap).

**Aturan permanen (juga di DEVLOG):**
(a) Setiap arahan owner baru = baris baru di Decision Log SEBELUM dikerjakan.
(b) Setiap penyimpangan implementasi dari GDD yang diputuskan agent sendiri = baris baru + alasan.
(c) Awal sesi: baca ledger ini. Akhir ronde: update KEDUA bagian. Item baru owner → langsung masuk.
(d) Implementasi yang bertentangan dengan ledger tanpa baris keputusan = **BUG DESAIN** → laporkan di GAP_AUDIT.
(e) Ledger di-commit dan di-push seperti kode.

Status: **Ada** / **Sebagian** / **Belum** / **Ditunda-sengaja** / **MENYIMPANG**.

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
| Profesi produksi: **Enchanter** | v0.1 §3.3 | **Belum** | Prasyarat sistem Enchant (addendum A3). |
| Profesi utility: Tamer | v0.1 §3.3 | Ada | |
| Profesi utility: **Merchant, Treasure Hunter** | v0.1 §3.3 | Belum | Fase v0.4.2+. |
| Character creator (rupa) | Owner (charsys v2) | Ada | CharGen modular 7 ras, per-bagian. |
| Rasi Kelahiran (birth sign) | v0.3 §3.3 | Sebagian | Tercatat dari tanggal; bonus tematik & Trial of the Rasi belum. |
| 3 slot karakter/akun, Account Bank | v0.1 §3.1 | Ditunda-sengaja | Butuh akun/online (Fase 2+). |

### 2. Combat & elemen

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Model combat: hold-attack + channel mana (TANPA cooldown) + fusion bertingkat + anti-melt + infusion reach | Owner rev A–F (2026-07-12) | Ada | MENIMPA struktur cooldown GDD §6.2 — Decision Log #8. |
| Struktur skill: 6 slot + Ultimate slot + Combo window | v0.1 §6.2 | Sebagian/MENYIMPANG | Hotbar 5 slot; Ultimate baru flag (meteor); **Combo Skill window belum ada**. |
| Formula fisik/magic + miss ACC-vs-EVA | v0.1 §6.3 | Ada (dimodifikasi) | MDEF kini mitigasi-dalam-multiplier (Decision Log #11); hit-clamp beda dari GDD; PEN belum; publikasi cap di UI belum. |
| Status effect (Burn/Freeze/Paralyze/Poison/Blind/Curse) | v0.1 §6.4 | **Belum** (kecuali Wet) | Prioritas v0.4.1. |
| 17 elemen 4 tier + matrix + aturan sains data-driven | v0.2 §7 | Ada | Termasuk Tier 2 (Poison/Metal/Wood/Spirit) ✓ terverifikasi. |
| Fusion elemen + discovery + Grimoire | v0.1 §5.3 + owner rev C + owner 2g | Ada | 15 resep (target launch 35 — sisa = konten bertahap). |
| Element Flow 4 jalur: Infusion / Coating / Enchant / Fusion-monster | v0.3 §7 | Sebagian | Hanya Infusion. Coating+Enchant = v0.4.2; fusion-monster ditunda-sengaja. |
| Weapon moveset per tipe + arc VFX + afinitas class | Owner FF-2b | Ada | 8 tipe. |
| Kalibrasi TTK dua arah + ekonomi mana (harness v2) | Owner ronde 4 | Ada | BALANCE_TARGETS/REPORT_v2. |

### 3. Dunia, waktu, langit

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Waktu = jam WIB asli + fase bulan lunar asli | v0.2 §6 | Ada | Jantung Aetherion, sehat. |
| **MUSIM 4 × 2 minggu** | v0.1 §4.2, Fase0 §3 | **Belum — NOL** | Luput dari laporan sebelumnya (addendum A4). v0.4.3. |
| Cuaca per wilayah + efek gameplay | v0.1 §4.3 | Sebagian | 5 cuaca ada; **Blood Moon hanya nama** (tanpa spawn agresif/drop ×2/tint) — addendum A6. |
| Event harian: Golden Hour / Morning Dew / nokturnal | v0.2 §6.2 | Sebagian | Jam & sinyal ada; **bonus gameplay-nya belum ada satu pun** — addendum A6. |
| sky_calendar tanggal astronomi nyata | Fase0 §3 | Ada | 11 event 2026–2027 (solstice/equinox/meteor). |
| Ramalan Rasi (12 Rasi Agung + prophecy mingguan) | v0.3 §3 | Sebagian | **Aset 12 rasi SUDAH ADA & belum dipakai kode**; prophecy = teks belum terhubung konten; addendum A5. |
| Prakiraan cuaca Astrologer 24 jam (80%) | v0.1 §4.3 | **Belum** | Addendum B. |
| Wilayah: Greenvale, Candyveil, Desert, Frostpeak(+desa), Storm Island | v0.1 §4.1+v0.2 §4 | Ada | 5 dari 13; sisanya = konten (beku). |
| Celestia Kingdom = ibukota SEMUA ras | Owner (kanon baru) | Ditunda-sengaja | Decision Log #7; dibangun saat konten dibuka. |
| Homestead + tanam real-time WIB | v0.2 §5 | Ada | Ternak/apiari/kolam/breeding-pen belum (bertahap); cek musim belum (A4). |
| Kompresi level Fase 0 (monster L1–55, bukan 1–99) | Keputusan implementasi | Ada | Decision Log #19. |

### 4. Monster, taming, pet

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Roster BST × arketipe × rarity (60 spesies) | Roster §1–2 | Ada | Kalibrasi ulang growth (Decision Log #10). |
| Rank bintang 1–5 saat spawn | v0.1 §7.2 | Sebagian | Dirol ±6% tapi **tak tampil di UI/Pedia** — addendum A7. |
| Trait 1–2 per individu dengan efek | v0.1 §7.2 | Sebagian | Trait = data spesies; mayoritas tanpa efek; per-individu belum. |
| **Affinity** pet (naik lewat interaksi, gerbang konten) | v0.1 §7.2, §8.3 | **Belum (beku di 0)** | addendum A7; gerbang Pact/fusion masa depan. |
| **Mutation 1/500** | v0.1 §7.2 | **Belum** | addendum A7. |
| Growth Type (Early/Balanced/Late) | v0.1 §7.2 | Belum | Prioritas rendah. |
| Taming (rate, pity, enrage, orb) | v0.1 §8.1 + v0.2 §7.4 | Ada | |
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
| **Rune System** (pemain 4 slot, monster 2, grade I–V merge 3) | v0.1 §8.6 | **Belum** | v0.4.2. |
| Equipment 3 slot + tooltip banding | Owner ronde 4 (PC5) | Ada | |
| Ekonomi NPC supply-demand + log | Fase0 §7 | Ada | |
| Skill book / trainer / boss-unlock skill | v0.1 §6.2, §11.1 | Ada | Ronde 4 (PC4). |
| Marketplace pemain / auction / kios | v0.1 §10.3 | Ditunda-sengaja | Fase 2 online-lite. |
| Gambling / racing betting | v0.1 §10.5, §11.5 | Ditunda-sengaja | S3+. |

### 6. Konten & presentasi

| Sistem | Sumber | Status | Catatan |
|---|---|---|---|
| Dungeon side-view Terraria + bos 2 fase | Owner 2026-07-11 | Ada | 5 dungeon. Chest/rahasia/trap/parallax: belum (v0.4.3). |
| Hidden Scenario engine + no-fail | v0.2 §8.2 | Ada | 3 skenario. **Perayaan first-clear belum** (A8). |
| Quest: daily board + panduan pembuka | v0.1 §11.1 | Ada | Pembuka dirombak FF-2g (reward/langkah). Quest journal terpusat: belum. |
| Intro/opening + cutscene dasar | Benchmark | Sebagian | Intro 4 layar ✓ (FF-2g); cutscene engine belum. |
| Title screen + Continue + autosave + metadata | Benchmark/owner FF-2e | Ada | |
| Aetherpedia, Photo Mode, Titles, Echo Vendor, Sky Report, music layering | v0.2 §10 | Ada | |
| Settings lengkap (volume per channel/keybind/fullscreen) + gamepad | Benchmark | Belum | v0.4.4. |
| World map + fast travel | Benchmark | Belum | v0.4.3. |
| PvP / guild / racing / world boss / co-op | v0.1 §11 | Ditunda-sengaja | Fase 2–4 online. |
| Monetisasi kosmetik / battle pass | v0.1 §15 | Ditunda-sengaja | Pasca-launch. |

---

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

> Baris berikutnya ditambahkan SEBELUM implementasi keputusan baru. Jangan hapus baris; koreksi = baris baru.
