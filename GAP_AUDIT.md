# GAP_AUDIT — Aetherion "Foundation First" (2026-07-12)

Audit menyeluruh atas perintah owner setelah playtest "game terasa HAMPA". Sumber:
seluruh `docs/` (GDD v0.1, v0.2, v0.3, Fase0_Desain_Teknis, Monster_Roster_Launch)
dibaca ulang penuh, dicocokkan dengan kode aktual (bukan dengan STATUS.md).

Status: **Ada** (sesuai desain) / **Sebagian** (ada tapi dangkal/tidak lengkap) /
**Belum** (tidak ada) / **MENYIMPANG** (ada tapi melanggar desain).

---

## 1. KEPATUHAN DOKUMEN (per sistem GDD)

### 1.1 Scope catatan: apa yang WAJAR belum ada
GDD v0.3 §4 menetapkan **Fase 0 = single-player offline**: marketplace pemain, PvP,
guild, racing, breeding, fusion player-monster, world boss multiplayer, monetisasi —
semua **DITUNDA BY DESIGN**. Item-item itu dicatat "Belum (by design)" dan TIDAK
dihitung sebagai gap. Audit fokus pada apa yang seharusnya SUDAH ada di Fase 0 + apa
yang ada tapi menyimpang.

### 1.2 Tabel kepatuhan

| # | Sistem (sumber) | Status | Catatan |
|---|---|---|---|
| 1 | **6 Combat Class — Warrior/Mage/Archer/Assassin/Paladin/Necromancer (v0.1 §3.3)** | **MENYIMPANG — GAP TERBESAR** | Tidak pernah diimplementasikan sebagai pilihan pemain. ProfessionSystem hanya berisi profesi gathering/produksi; kolom "combat" ada di enum tapi TIDAK ada class combat yang bisa dipilih. Pemain mulai tanpa identitas — akar langsung rasa "hampa & tidak RPG". |
| 2 | Struktur serangan (v0.1 §6.2): normal + 6 slot skill + **Ultimate** + **Combo Skill** window | Sebagian / MENYIMPANG | Hotbar hanya 5 slot; Ultimate baru "flag ultimate" 1 skill (meteor) tanpa slot/aturan sendiri; **Combo Skill (rantai 2-3 skill dalam 2 dtk) tidak ada sama sekali**. Catatan: revisi owner ronde 4 (no-cooldown) menimpa kolom cooldown v0.1 — itu SAH (keputusan lebih baru). |
| 3 | Stat dasar 6 attr + 5 poin/level + respec (v0.1 §3.5) | **Ada** | Ronde 4 (PC1). Wiring lengkap, Status tab, respec berbayar. |
| 4 | Formula combat + **Hit Chance clamp 75%+(ACC−EVA)** + **PEN** + **publikasi cap ke pemain** (v0.1 §6.3) | Sebagian | Formula fisik/magic ada (magic direvisi PC6, dicatat DEVLOG). Hit chance memakai rumus sendiri (clamp 0.2–1.0, bukan 60–100%); **Penetration tidak ada**; **cap TIDAK dipublikasikan di UI mana pun**. |
| 5 | **Status Effect: Burn/Freeze/Paralyze/Poison/Blind/Curse (v0.1 §6.4)** | **Belum (kecuali Wet)** | Hanya status **Wet** yang benar-benar berfungsi. `apply_status: "poison"` ada di data skill/monster tapi TIDAK ada sistem status yang membaca & men-tick-nya. Freeze/Burn/Paralyze/Blind/Curse tidak ada. Combat kehilangan seluruh lapisan taktis ini. |
| 6 | Elemen 17 + matrix + aturan sains (v0.2 §7) | **Ada** | Matrix + rules ctx data-driven, teruji. Salah satu sistem paling sehat. |
| 7 | Fusion elemen + discovery + first-discovery announce (v0.1 §5.3) | Ada (di-upgrade ronde 4) | 2-elem holdable, 3–4 elem recast, fizzle, discovery. Gap kecil: **tidak ada Grimoire/jurnal resep** — pemain tidak punya peta discovery (→ Tahap 2d). Resep baru 15 dari target 35 launch (wajar Fase 0). |
| 8 | Element Flow 4 jalur: Infusion / **Coating (Alchemist)** / **Enchant (Enchanter)** / Fusion (v0.3 §7) | Sebagian | Hanya Infusion yang ada (bagus, direvisi ronde 4). **Coating & Enchant tidak ada** — dua sink ekonomi + kedalaman build hilang. Aturan anti double-dip belum relevan karena cuma 1 jalur. |
| 9 | Monster roster & BST arketipe (Roster §1) | Ada | 60 spesies, arketipe, bintang 1–5, evolusi bertahap. Kalibrasi v2 (ronde 4) menyimpang dari growth %-kecil Roster §1.1 — SAH, dicatat sebagai keputusan kalibrasi di DEVLOG/BALANCE_REPORT_v2. |
| 10 | Atribut monster: **Affinity, Trait aktif, Mutation, Growth Type** (v0.1 §7.2) | Sebagian | Trait = string data tanpa efek gameplay untuk sebagian besar (Pack Hunter dll. tidak dihitung); Affinity ada di data tame tapi tidak pernah naik/dipakai; Mutation & Growth Type tidak ada. Monster terasa "statistik", bukan individu. |
| 11 | Taming + pity + enrage (v0.1 §8.1, rate v0.2 §7.4) | **Ada** | Teruji. |
| 12 | Pet-mount Size Class (v0.3 §6) | Ada | Rideable + saddle + mount. Pasif pet 50% saat mounted belum dicek — minor. |
| 13 | Evolution bertingkat + syarat dunia (v0.1 §8.4) | Ada | EvolutionSystem + kondisi purnama dll. |
| 14 | Breeding (v0.1 §8.5) | Belum (by design — S2) | Sesuai MVP cut. |
| 15 | Fusion player×monster (v0.1 §8.3) | Belum (by design — S2) | Sesuai MVP cut. |
| 16 | **Rune System (v0.1 §8.6)** | **Belum** | Tidak ada sama sekali. GDD memasukkannya di MVP; kedalaman gear hilang. Boleh jadi fase v0.4+. |
| 17 | Gathering + profesi XP + perks (v0.1 §9.1, v0.2 §3) | Ada | Miner/Lumberjack/Fisherman/Herbalist + XP + perk + main/sub. |
| 18 | Crafting: success, **Insight**, **quality roll (Normal/Fine/Masterwork)**, **maker's mark** (v0.1 §9.2, v0.2 §2) | Sebagian | Success+Insight ada. **Quality roll & maker's mark tidak ada** — loot craft selalu identik = hambar. Tier F–B ada; A+ (transenden 1%) belum diuji ujung-ke-ujung (belum ada resep A+ nyata di data selain item unik skenario). |
| 19 | **Enchant +1..+10 (v0.1 §9.3)** | **Belum** | Tidak ada. Progression gear mati setelah craft — tidak ada alasan kembali ke blacksmith. |
| 20 | Ekonomi NPC supply-demand (Fase0 §7) | Ada | Economy.gd + log transaksi. |
| 21 | Homestead + tanaman real-time WIB (v0.2 §5) | Ada | 4 plot + offline growth. Beternak/apiari/kolam belum (wajar bertahap). |
| 22 | Waktu WIB + bulan asli + sky_calendar + event window (v0.2 §6) | **Ada** | GameClock + purnama + pasang + golden hour. Sistem paling khas Aetherion, sehat. |
| 23 | Hidden Scenario engine + no-fail (v0.2 §8.2) | Ada | 3 skenario (Lunar Warren, Tea Party, Star Whale). |
| 24 | Ramalan Rasi: weekly prophecy, birth sign, trial rasi (v0.3 §3) | Sebagian | Birth sign + weekly prophecy teks ada di Astrologer/Sky. **Bonus tematik birth sign & "Trial of the [Rasi]" tidak ada** — birth sign murni kosmetik teks. |
| 25 | Dungeon per lokasi + gimmick (v0.2 §8.1) | Sebagian | 5 dungeon side-view + bos 2 fase. Tapi gimmick khas per dungeon (puzzle cahaya Barrow, updraft Spire yang menghukum jatuh) baru sebagian; **tidak ada chest, ruang rahasia, trap** (lihat benchmark). |
| 26 | NPC penting: Trainer/Master, **Overpowered NPC (Kael)** (v0.1 §11.1) | Sebagian | Guru Skill baru ada (ronde 4). Master quest per profesi & NPC lore Lv999 belum. |
| 27 | Aetherpedia, Photo Mode, Title+micro-buff, Echo Vendor, Sky Report, music layering (v0.2 §10) | Ada | Semua ada versi fungsional. |
| 28 | Save: 3 slot + backup + schema_version (Fase0 §8) | Sebagian | Slot+backup+schema ada. **Autosave tidak ada; tidak ada Continue; metadata slot minim** (→ Tahap 2e). |
| 29 | Performa game ringan (Fase0 §9) | Ada | Diaudit per ronde (372 node, 60 fps dungeon penuh). |
| 30 | **Advanced Class Quest lvl 60 (v0.2 §3)** | Belum | Bergantung #1 — tidak ada class sama sekali. |

**Kesimpulan kepatuhan:** fondasi *sistemik* (waktu, elemen, data-driven, ekonomi,
taming) kuat dan sesuai desain. Yang bolong justru lapisan **identitas & kedalaman
RPG yang menghadap pemain**: class (#1), status effect (#5), combo (#2), enchant/
coating/quality/rune (#8/18/19/16), dan trait monster yang hidup (#10). Persis pola
"100% sistem dengan kedalaman 40%" yang dilarang GDD Bagian 18.

---

## 2. BENCHMARK GENRE (skor 0 = tidak ada, 1 = ada tapi dangkal, 2 = layak)

### 2.1 OVERWORLD vs Suikoden / FF klasik / Stardew — **7/18**

| Item | Skor | Kurang di bagian apa |
|---|---|---|
| Title screen layak | **1** | Ada menu + Sky Report, tapi tanpa logo/keyart, tanpa **Continue**, tanpa Settings di title, tidak ada animasi/latar hidup. Kesan pertama = program, bukan game. |
| Intro/opening konteks & motivasi | **0** | New Game → langsung spawn di rumput. Tidak ada satu layar pun yang menjawab "aku siapa, di mana, mau apa". |
| Pemilihan class & identitas awal | **0** | Character creator hanya rupa. Tidak ada pilihan gaya main. (GDD #1 di atas.) |
| Quest journal + penunjuk arah | **1** | Panduan (guide_step) + daily quest ada, tapi tidak ada jurnal terpusat dengan tujuan aktif + penanda arah/ikon di dunia; pemain mengandalkan teks toast. |
| World map / fast travel | **0** | Tidak ada peta dunia; minimap saja. Antar-region jalan kaki/dermaga tanpa peta konteks. |
| Cutscene dasar (NPC bergerak + dialog terarah) | **1** | Stage.say ada (dialog + potret), tapi tidak ada aktor yang digerakkan skrip, tidak ada kamera pan — semua peristiwa "diberitakan", tidak "terjadi". |
| Transisi musik & stinger event | **1** | Layer combat ada. Tidak ada stinger (level-up/quest/discovery), tidak ada crossfade antar scene, boss tanpa track khusus. |
| Kepadatan interaksi NPC (jadwal/dialog kontekstual) | **1** | Villager berjalan rute + dialog statis. Tidak ada jadwal harian, dialog tidak berubah dengan waktu/cuaca/progress. |
| Reward loop 5–10 menit pertama | **1** | Panduan memberi arah, tapi reward pertama kecil & tak seremonial; tidak ada "wow" dalam 10 menit. |

### 2.2 COMBAT vs Terraria / Hades / Dead Cells — **6/16**

| Item | Skor | Kurang di bagian apa |
|---|---|---|
| Animasi serangan TERLIHAT | **0** | Ini akar "hampa" #1: swing = `Line2D` 3 titik yang memudar 0.22s. Tidak ada arc slash tersprite, tidak ada anticipation/follow-through, tidak beda per senjata. Player punya anim "attack_" tapi 3-frame walk-cycle reuse. |
| Impact layering (hitstop+partikel+SFX+damage pop) | **1** | Hitstop/knockback/flash/number ADA (ronde 4) tapi tipis: partikel impact nyaris tak terlihat (2×2 px), SFX satu lapis, damage number kecil tanpa pop-scale. Komponennya ada, *rasa*-nya belum dirakit. |
| Reaksi musuh kena hit (flash, stagger, death anim + loot burst) | **1** | Flash & knockback ada. Death = fade alpha 0.35s — tanpa death anim/dissolve/ledakan; **loot langsung masuk tas tanpa visual** — membunuh rasa reward. |
| Dodge terasa | **1** | Dodge + i-frames ada, tanpa VFX/afterimage/SFX khas — tidak "terasa". |
| Variasi attack pattern musuh | **0** | **32 dari 60 monster = "melee" (jalan-nabrak)**, 15 ranged, 11 skittish, 2 flyer/shooter. Tidak ada telegraf, lompatan pola, atau skill musuh yang terlihat (howl/charge cuma modifier damage). |
| Boss: telegraf, multi-pola, fase drastis, arena, perayaan kill | **1** | 2 fase + adds ada. Telegraf minim (tint), pola serangan 1–2, fase = angka bukan koreografi; tidak ada intro bar/nama, tidak ada perayaan kill (slow-mo/jingle/loot shower). |
| — Class fantasy saat bertarung (tambahan konteks) | **1** | Semua orang main identik: klik kiri + skill sama. |
| — Feedback miss/crit dibedakan | **1** | "meleset" & angka crit ada; crit tanpa SFX/zoom khas. |

### 2.3 DUNGEON vs Terraria — **3/12**

| Item | Skor | Kurang |
|---|---|---|
| Variasi blok & bioma dalam dungeon | **1** | 2–3 jenis blok per dungeon, satu palet per dungeon; tidak ada sub-bioma/lapisan kedalaman. |
| Chest / ruang rahasia / trap | **0** | Tidak ada satu pun. Eksplorasi tidak pernah dibayar. |
| Background parallax & lighting berlapis | **1** | CanvasModulate gelap + torch point light; tidak ada parallax bg, tidak ada lapisan kabut/depth. |
| Ambience audio | **1** | Ambience global ada; dungeon tanpa suara khas (tetes air, gemuruh, angin). |
| Alasan eksplorasi (loot unik per dungeon) | **1** | Material bos unik ada; selain jalur bos tidak ada alasan menyimpang. |
| Platforming variety | **1** | One-way + ladder + double-jump wind; tanpa moving platform/updraft nyata/bahaya lingkungan. |

### 2.4 MODERN META — **4/14**

| Item | Skor | Kurang |
|---|---|---|
| Settings: volume per channel | **1** | Hanya music_volume + mute master. Tidak ada SFX/ambience slider terpisah. |
| Keybind remap | **0** | Tidak ada. |
| Fullscreen/vsync | **0** | Tidak ada opsi tampilan sama sekali. |
| Pause menu layak | **1** | Esc = MenuUI (bagus) tapi campur aduk inventory vs sistem; tidak ada layar pause khusus (Resume/Settings/Save/Quit). |
| Save slots + autosave | **1** | 3 slot manual; **tanpa autosave** = kematian bisa menghapus 30 menit progres. |
| Gamepad support | **0** | Nol binding joypad. |
| UI tween/animasi transisi | **1** | UI muncul-hilang instan; tanpa fade/slide; scene change tanpa transisi (kecuali Stage fade dasar?). |
| Feedback audio setiap interaksi UI | **1** | Sebagian tombol ber-SFX (menu), banyak yang senyap; tanpa hover state konsisten. |

### 2.5 Skor total benchmark: **20/60** — dan distribusinya menjelaskan keluhan owner:
komponen *sistem* dapat nilai, komponen *presentasi & identitas* hampir semuanya 0–1.

---

## 3. DIAGNOSIS AKAR "HAMPA" (ranking dampak)

1. **Tidak ada identitas pemain.** Tanpa class, semua playthrough dimulai identik dan
   berkembang identik. RPG tanpa "aku memilih menjadi apa" = hampa secara definisi.
2. **Combat tidak punya bahasa visual.** Damage terjadi di angka, bukan di layar:
   swing garis, death fade, loot teleport, dodge sunyi. Sistem ronde 4 (hold/channel/
   fusion) sudah dalam — tapi *tak terlihat*.
3. **Tidak ada dramaturgi.** Nol intro, nol cutscene, nol stinger, bos tanpa panggung,
   discovery tanpa perayaan yang layak. Peristiwa besar dan kecil terasa sama.
4. **Kedalaman RPG yang dijanjikan GDD dipangkas diam-diam.** Status effect, combo,
   enchant, coating, quality roll, trait monster hidup — semua lapisan yang membuat
   loot & build "berbicara" belum ada.
5. **Meta modern minim.** Tanpa autosave/Continue/settings layak/gamepad, game terasa
   prototipe walau kontennya banyak.

Rencana perbaikan bertahap: lihat `MASTER_IMPROVEMENT_PLAN.md`.

---

# ADDENDUM (2026-07-12) — telaah designer & keputusan owner, DIVERIFIKASI di kode

## A. Sistem yang direncanakan & disetujui tapi tidak pernah dilaporkan ada

| # | Sistem | Status verifikasi | Bukti di kode |
|---|---|---|---|
| A1 | **Crafting Transenden A/S/SS/SSS** (v0.2 §2) | **Sebagian — dangkal** | Insight ✓ (CraftingSystem, +stack per gagal). Hanya 1 resep S (`cook_royal_cake` 1%). TIDAK ada: piramida A→S→SS→SSS, **maker's mark**, **quality roll**, animasi ritual + pengumuman, dan — paling parah — **material kunci [A]/[S] yang SUDAH drop (Everfrost Core [A], Tempest Heart [S], Ankh Fragment [A]) tidak punya resep pengolah apa pun** = loot bos berakhir jadi pajangan tas. |
| A2 | **Rune System** (v0.1 §8.6) | **Belum — nol** | Tidak ada satu baris kode/data pun. |
| A3 | **Enchant +1..+10 & Coating** (v0.1 §9.3, v0.3 §7) | **Belum — nol** | Element Flow baru 1 dari 4 jalur (Infusion). Enchanter tidak ada, coating Alchemist tidak ada. |
| A4 | **MUSIM 4×2 minggu** (v0.1 §4.2, Fase0 §3) | **Belum — NOL, gap yang luput dari audit awal** | `grep season` di GameClock/WorldState = kosong. Padahal Fase0 §3 eksplisit menyebut GameClock memuat musim. Tanaman homestead pun tidak dicek musim. |
| A5 | **Ramalan Rasi** (v0.3 §3) | **Sebagian** | **ASET 12 RASI SUDAH ADA** (`assets/game/sky/constellations/rasi_*.png`, 12 file) tapi **TIDAK PERNAH direferensikan satu kali pun oleh kode** — aset orisinal owner terbuang sia-sia. Weekly prophecy = teks teka-teki di tab Sky ✓ tapi tidak terhubung konten aktif minggu itu. Birth sign ✓ tercatat tapi **tanpa bonus tematik**. `sky_calendar.json` ✓ 11 event astronomi nyata 2026–2027 (solstice/equinox/meteor — melebihi minimal 2). |
| A6 | **Event waktu harian** (v0.2 §6.2) | **Sebagian — kulit tanpa isi** | Golden Hour ✓ ada (sinyal + warna langit) tapi **EXP+10% tidak diimplementasikan**. Morning Dew ✓ fungsi jam ada, efek herb+1 tidak ada. **Blood Moon ada hanya sebagai NAMA cuaca** — tanpa spawn agresif, tanpa drop ×2, tanpa gerbang evolusi/scenario. Monster nokturnal: tidak ada gating spawn siang/malam. |
| A7 | **Kedalaman monster** (v0.1 §7.2) | **Sebagian** | Rank bintang 1–5 ✓ dirol saat spawn (±6% stat) tapi **tidak pernah ditampilkan di UI target/Pedia** — pemain tak mungkin tahu sistem ini ada. Trait = properti spesies statis (bukan 1–2 per individu) dan mayoritas tanpa efek. **Affinity pet beku** (tidak pernah naik; `affinity_mod` taming di-hardcode 1.0). **Mutation 1/500: nol.** |
| A8 | **Forest Spirit + first-clear** | **Sebagian** | Counter `trees_cut` ✓ berjalan (dipakai unlock woodcutter) tapi **trigger Forest Spirit tidak ada** di scenarios.json. **Perayaan first-clear scenario tidak ada** (clear cuma toast biasa). |

## B. Verifikasi status yang diminta

| Item | Status | Detail |
|---|---|---|
| Elemen Tier 2 (Poison/Metal/Wood/Spirit) | **Ada** | Lengkap di matrix + list elements.json (bahkan Tier 3–4 ikut terdaftar); skill poison/wood aktif dipakai. |
| Pemetaan profesi vs GDD | **Sebagian** | Ada 9: miner, lumberjack, fisherman, herbalist, blacksmith, alchemist, cook, tamer, +carpenter (tambahan non-GDD, wajar). **BELUM: Enchanter, Merchant, Treasure Hunter.** Enchanter paling mendesak (prasyarat A3). |
| Prakiraan cuaca Astrologer 24 jam (akurasi 80%) | **Belum** | Tab Sky hanya menampilkan kondisi SEKARANG + prophecy; tidak ada prakiraan. Padahal GDD menyebutnya "kunci retention/planning". |
| Rotasi daily quest | **Ada** | 3 quest/hari, seed dari tanggal WIB, gated cuaca/bulan. |

Semua temuan A/B sudah dimasukkan `MASTER_IMPROVEMENT_PLAN.md` (prioritas tinggi)
dan `PLAN_LEDGER.md` (dokumen induk baru — lihat aturan permanen di DEVLOG).

---

# 🐞 BUG DESAIN (aturan ledger d) — dicatat 2026-07-12

## BD-2: File MASTER_BLUEPRINT_AETHERION.md v1.0.1 TIDAK PERNAH SAMPAI ke workspace
**Direktif kanonisasi** memerintahkan membaca `docs/MASTER_BLUEPRINT_AETHERION.md v1.0.1`
dan commit ke repo. **Verifikasi jujur:** file tidak ada di docs/, seluruh repo, maupun
folder unduhan user (pencarian rekursif; satu-satunya .md yang berubah hari ini adalah
tulisan agent sendiri). Pola BD-1 terulang: artefak Direktur hilang sebelum sampai.
**Tindakan:** agent TIDAK memfabrikasi dokumen kompas kanonik. Semua keputusan B1–B19
yang termuat dalam TEKS DIREKTIF dicatat & dikanonisasi di Decision Log (#46–#66);
pekerjaan yang membutuhkan TEKS PENUH blueprint (peta cakupan fitur per pasal, tabel
§3.9 Enam Lingkup Budaya, 6 draft capstone) ditandai MENUNGGU FILE di REPORT-01.
**Butuh dari owner:** kirim ulang file blueprint ke `docs/`.
**✅ RESOLVED 2026-07-13:** file diterima di `docs/MASTER_BLUEPRINT_AETHERION.md`
(+ `AETHERION_PROPOSAL_LENGKAP_FINAL.md` warisan), di-commit; semua butir
[MENUNGGU FILE] dilengkapi (ledger #67, REPORT-01 addendum §5).

## DEVIASI-B15 (v0.4.2): teks UI baru belum via Loc.t() — ✅ **DITUTUP 2026-07-13 (Decision Log #100, v0.4.4)**: infra TranslationServer + parameter selesai; 39 string v0.4.2–0.4.3 di-retrofit ke key; test menjaga paritas ID/EN. Sisa (nama item/monster/lore) = gelombang terjemahan berikutnya.
**Temuan (self-report):** string UI baru v0.4.2 (ritual Transenden, panel Enchanter,
Rumah Lelang, toast) ditulis Bahasa Indonesia langsung, TIDAK lewat `Loc.t("key")`
— padahal konvensi B15 (#62) berlaku untuk teks baru. **Alasan teknis:** mayoritas
string v0.4.2 adalah format dinamis ("%s kini +%d!") yang butuh dukungan parameter
di Loc — infra itu dijadwalkan v0.4.4 (migrasi TranslationServer). **Tindakan:**
seluruh string v0.4.2 masuk daftar retrofit v0.4.4 bersama teks lama; dicatat di
Decision Log #74. Bukan fabrikasi kepatuhan — deviasi diakui terbuka.

## BD-1: Koreksi "dua tab jalur + 4 class kehidupan" HILANG sebelum masuk ledger
**Temuan verifikasi owner:** layar ClassSelect masih versi 6 class combat saja.
**Verifikasi kode (jujur):** `ClassSelect.gd` tidak punya tab/jalur sama sekali;
`classes.json` hanya 6 class combat; **Decision Log tidak memiliki baris** untuk
koreksi tersebut. Kesimpulan: koreksi owner tidak pernah sampai ke sesi agent —
hilang SEBELUM tercatat (kegagalan proses yang persis ingin dicegah PLAN_LEDGER;
ledger baru dibuat SETELAH koreksi itu diberikan, jadi tak sempat menangkapnya).
**Tindakan:** dicatat retroaktif sebagai Decision Log #33 lalu diimplementasikan
penuh hari ini (tab Jalur Tempur + Jalur Kehidupan, 4 class kehidupan, combat sub,
integrasi skill tree). **Pelajaran proses:** mulai sekarang STATUS.md mencantumkan
"Exe terakhir: [waktu] — berisi hingga fitur X" agar owner selalu tahu build yang
diuji, dan mismatch build-vs-arahan ketahuan lebih cepat.

## CATATAN INTEGRITAS (2026-07-13): file "part 2" berukuran 0 byte
Saat mengambil file konsepsi v2 (16.510 baris — DITERIMA & di-commit), ditemukan
juga `Aetherion_blueprint_reasoning and design part 2.txt` di Desktop owner dengan
ukuran **0 byte (kosong)**. Agent **tidak** menebak isinya dan **tidak** memasukkannya
ke docs/. Bila part 2 memang berisi materi lanjutan (misalnya jawaban Q1–Q7 atau
Bible lain), **mohon kirim ulang** — pola BD-1/BD-2 mengajarkan: artefak yang tak
sampai tidak boleh difabrikasi.

**✅ DITUTUP 2026-07-13 (#135):** part 2 kemudian dikirim lengkap (6.931 baris), disusul part 3–5 + dua berkas meta. Verifikasi owner: **tidak ada FILE 73–75** — sisa 8% Nirnama Bible sumber sudah termuat di `docs/NIRNAMA_BIBLE.md` v1.0. **B18 SELESAI.**

## RISIKO DITERIMA (2026-07-13): jejak rahasia produksi di riwayat git
**Fakta:** nama asli Sang Nirnama sempat tertulis di beberapa commit sebelum
Decision Log #143/#144 (di `PLAN_LEDGER.md`, `MISTERI_ABADI.md` M8, dan commit message
lama). Isi **working tree** sudah bersih — nama itu kini **hanya** ada di
`docs_private/NIRNAMA_BIBLE.md`, yang **tidak pernah ter-commit**.

**Yang TIDAK dilakukan & alasannya (keputusan Direktur #144):** **tidak ada rewrite
history**. Menulis ulang riwayat repo publik berisiko merusak referensi, tag, dan salinan
lokal — dan **risiko operasional itu dinilai melebihi risiko kebocorannya**: repo ini minim
pengunjung, dan menemukan jejak lama menuntut **arkeologi git yang disengaja**, bukan
sekadar membuka halaman GitHub.

**Status:** **RISIKO DITERIMA, bertanggal.** Bila repo kelak dibuka luas **sebelum reveal
Act 2**, keputusan ini **wajib ditinjau ulang** — dan peninjauan itu adalah keputusan
Direktur, bukan agent.

---

## BUG PROSES (2026-07-14, #155): janji Piagam diganti tanpa baris keputusan

**Fakta.** Piagam Pengalaman (Bag. 0) menetapkan **Wonder tier-legenda pertama** untuk v0.5
dengan tiga nama: **The Nameless Door · The Forgotten Musician · The Sleeping Giant**. Saat
`docs/IMPLEMENTATION_ROADBOOK.md` disusun (#132), baris itu **diganti** oleh dua Wonder lain
("lonceng tengah malam yang tak punya lonceng", "Bukit Kabut") — **tanpa satu pun baris
Decision Log**. Aturan permanen ledger **(b)** mewajibkan: *setiap penyimpangan agent dari
GDD/blueprint = baris + alasan*.

**Klasifikasi: BUG PROSES, bukan bug orang.** Penggantinya bukan ide buruk — keduanya justru
bagus dan **dipertahankan sebagai TAMBAHAN**. Yang salah adalah **caranya**: substitusi
terjadi di dalam pekerjaan penulisan dokumen, di mana tidak ada gerbang yang memaksa penulis
berhenti dan bertanya *"apakah aku sedang mengganti janji kanon?"*

**Kenapa berbahaya.** Ini adalah **cara sebuah janji mati tanpa ada yang memutuskan
membunuhnya**: dokumen eksekusi menjadi satu-satunya yang dibaca ronde berikutnya, dan
sesuatu yang tak pernah ditolak pun **lenyap** hanya karena tak tersalin. Pola yang sama
membunuh 15 janji lain (REPORT-06 §A).

**Koreksi (#155):** ketiga Wonder Piagam **dikembalikan** ke slot v0.5 persis sesuai Piagam;
penggantinya mendapat **barisnya sendiri** (tambahan, bukan substitusi).

**Pencegahan yang diusulkan (butuh keputusan Direktur):** dokumen eksekusi (ROADBOOK) tidak
boleh **menghapus atau mengganti** butir bernama dari dokumen kanon. Ia boleh **menambah**,
boleh **menunda** — tetapi penundaan wajib ditulis sebagai **DITUNDA-SADAR + alasan + fase
tinjau**, bukan sebagai ketiadaan.


---

## RISIKO DITERIMA (2026-07-14, #169): potongan nama rahasia di BERKAS MENTAH Direktur

**Fakta.** `docs/Aetherion_bible/Aetherion_pelengkap.txt` — berkas **mentah milik Direktur**
yang ter-commit apa adanya — memuat **nama depan** rahasia di dalam sebuah daftar nama NPC.
Nama itu **tidak diberi konteks** di sana (ia hanya satu baris di antara nama-nama lain), dan
**marganya sudah diredaksi** dari seluruh dokumen lain (#169), sehingga **nama utuh tidak lagi
dapat dirakit dari repo**.

**Yang TIDAK dilakukan & alasannya:** berkas mentah Direktur **tidak diubah** — menyunting
sumber mentah **merusak provenance** (kita kehilangan kemampuan membuktikan apa yang benar-benar
dikirim owner, dan itu pelajaran BD-1/BD-2). Berkas ini **dikecualikan** dari guard rahasia.

**✅ PUTUSAN DIREKTUR (2026-07-14, BOCOR-1 = a, #177): BIARKAN APA ADANYA.**
Provenance sumber mentah **lebih berharga** daripada risiko yang tersisa: setelah **marga
diredaksi** (#169), **nama depan tanpa konteks tidak dapat dirakit menjadi nama utuh** — ia hanya
satu baris dalam daftar nama NPC.

**RENCANA OWNER:** repo akan **DI-PRIVATE-kan**. Setelah itu, risiko ini **praktis nol**.

> ### ⚠ SYARAT PENINJAUAN ULANG (mengikat)
> **Bila repo MASIH PUBLIK menjelang reveal Act 2 — keputusan ini WAJIB ditinjau ulang.**
> Ini bukan catatan sopan; ini **utang bertanggal**. Yang meninjau: **Direktur**, bukan agent.

**Yang BERUBAH hari ini (bukan risiko, melainkan perbaikan):** guard rahasia dulu **hanya
menyisir `res://`**. Kini ia menyisir **`docs/` + 5 dokumen hukum** untuk **potongan** nama —
karena kebocoran nyata ini **lolos dari test yang hijau selama berminggu-minggu**.
