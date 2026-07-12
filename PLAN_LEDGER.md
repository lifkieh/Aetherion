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

## BAGIAN 0 — PIAGAM PENGALAMAN (amandemen identitas, Decision Log #34–37)

**Identitas resmi: "THE WORLD REMEMBERS."**
> "Aetherion bukan dunia yang menunggu pemain datang. Aetherion adalah dunia yang
> terus berjalan, menyimpan rahasia, dan mengingat apa yang dilakukan pemain."

**Living Sky = sistem gameplay TERBESAR** (Tahun Langit, eclipse, meteor shower,
Celestial Alignment membuka pohon tersembunyi). Setiap fitur baru wajib bertanya:
apakah ia berjalan sendiri, menyimpan rahasia, atau mengingat pemain?

### 3 Pilar Pengalaman (di atas 3 pilar sistem GDD v0.1 §1.2)

| Pilar | Isi | Status |
|---|---|---|
| **WONDER** | Rahasia bertingkat: **tier-remah** solo-findable via rumor Penjaga Pohon / ramalan Astrolog / gosip NPC yang SUDAH ada; **tier-legenda** nyaris tanpa petunjuk. Kandidat tercatat: **The Nameless Door** (03:33 WIB + bulan baru + musim dingin), **The Forgotten Musician** (lagu musiman, ikuti 3 musim berturut), **The Sleeping Giant** (gunung = boss hidup, raid-class) | Kandidat terdaftar; tier-legenda pertama = v0.5 |
| **BELONGING** | Homestead berevolusi jadi **LIVING HEADQUARTERS → kerajaan**: buka lahan → bangunan → rekrut puluhan penduduk (syarat unik per orang) → markas tumbuh TERLIHAT. **= Evolusi resmi Pact System** (menggantikan #Pact sebagai konten beku terpisah) | Spec v0.6 "Hearth & Legacy" |
| **LEGACY (dua-lapis)** | Offline: **Kitab Sejarah Dunia** (chronicle otomatis) + aula patung + maker's mark + first-personal terukir. Online nanti: sistem SAMA menyala jadi first-discovery/first-kill/first-craft global | Benih chronicle = v0.5; v1 = v0.6 |

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
| Struktur skill: 6 slot + Ultimate slot + Combo window | v0.1 §6.2 | Sebagian | Hotbar 5 slot; Ultimate baru flag (meteor); **Combo window ADA (v0.4.1): 2 skill beda <2 dtk = +30%**. |
| Formula fisik/magic + miss ACC-vs-EVA | v0.1 §6.3 | Ada (dimodifikasi) | MDEF mitigasi-dalam-multiplier (#11); hit-clamp beda dari GDD; PEN belum; **cap & formula kini DIPUBLIKASIKAN di tab Status (v0.4.1)**. |
| Status effect (Burn/Freeze/Paralyze/Poison/Blind/Curse) | v0.1 §6.4 | **Ada** (v0.4.1, kecuali Curse) | StatusFx: DoT/stun/lock/blind + interaksi sains (Thermal Shock, konduksi basah, pemadaman); ikon di musuh & pemain. Curse menyusul. |
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
| Cuaca per wilayah + efek gameplay | v0.1 §4.3 | Sebagian | 5 cuaca; **Blood Moon PENUH (v0.4.1)**: malam acak jarang + purnama, aggro ×1.5, drop ×2, langit merah, gerbang evolusi (boar). Per-wilayah masih global. |
| Event harian: Golden Hour / Morning Dew / nokturnal | v0.2 §6.2 | **Ada** (v0.4.1) | Golden Hour EXP+10% nyata; Morning Dew panen +1; nokturnal gating spawn di 5 wilayah. |
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
| Rank bintang 1–5 saat spawn | v0.1 §7.2 | **Ada** (v0.4.1) | Tampil ★ di atas HP bar (kedua mode) + Pedia + tab Pet. |
| Trait 1–2 per individu dengan efek | v0.1 §7.2 | **Ada** (v0.4.1) | Pool individu (Kekar/Liat/Gesit/Beruntung/Berbisa) berefek stat/racun nyata + tampil di UI; trait spesies (Pack Hunter dll.) menyusul. |
| **Affinity** pet (naik lewat interaksi, gerbang konten) | v0.1 §7.2, §8.3 | **Ada** (v0.4.1) | +1/kill dibantu, +5 diberi makan (cap 100); tampil di tab Pet (ranch UI). |
| **Mutation 1/500** | v0.1 §7.2 | **Ada** (v0.4.1) | Recolor emas, +10% stat, nama ✦, drop +10%. |
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
| **Rune System** (pemain 4 slot, monster 2, grade I–V merge 3) | v0.1 §8.6 | **Ditunda-sengaja** | Decision Log #28: ke fase pembukaan konten (dipasangkan loot dungeon & slot monster Epic+). |
| **Durability & repair gear** | v0.1 §10.2 (sink "Repair gear") | Belum — prioritas rendah | Decision Log #29; relevan saat ekonomi sink diperdalam. Death penalty dungeon sementara −10% gold (tanpa durability, #12). |
| Mode Hemat + target performa game ringan | v0.2 §1, Fase0 §9 | **Ada** | 30fps lock + VFX cuaca off; perf diaudit per ronde. **Dijaga saat juice pass** (partikel/VFX baru wajib murah & dimatikan di Mode Hemat bila berat). |
| Equipment 3 slot + tooltip banding | Owner ronde 4 (PC5) | Ada | |
| Ekonomi NPC supply-demand + log | Fase0 §7 | Ada | |
| Skill book / trainer / boss-unlock skill | v0.1 §6.2, §11.1 | Ada | Ronde 4 (PC4). |
| Marketplace pemain / auction / kios | v0.1 §10.3 | Ditunda-sengaja | Fase 2 online-lite. |
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
| Tangga dungeon modern (gantung/lompat-lepas) | Owner #42 | **Ada** (v0.4.1c) | Menempel W-sekali, menggantung, SPACE lompat-lepas, anti-nyangkut puncak. |
| World map + fast travel | Benchmark | **Sebagian** (v0.4.1c) | **Gerbang Penjelajah "Pilih Dunia"** di 5 pemukiman (#43): kartu wilayah dikunjungi + siluet terkunci + 25G (gratis 1×/hari). World map visual penuh: v0.4.3. |
| PvP / guild / racing / world boss / co-op | v0.1 §11 | Ditunda-sengaja | Fase 2–4 online. |
| Monetisasi kosmetik / battle pass | v0.1 §15 | Ditunda-sengaja | Pasca-launch. |

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
| Ocean Kingdom | Terkunci-konten | Air Tingkat Tinggi |
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

> Baris berikutnya ditambahkan SEBELUM implementasi keputusan baru. Jangan hapus baris; koreksi = baris baru.
