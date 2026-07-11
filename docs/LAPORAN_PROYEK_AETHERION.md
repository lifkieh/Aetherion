# LAPORAN PROYEK AETHERION — FILE SERAH-TERIMA KONTEKS
Tanggal: 11 Juli 2026 | Untuk: Claude (sesi baru) & pemilik proyek
**CARA PAKAI:** upload file ini di awal chat baru + tulis "lanjutkan proyek Aetherion sesuai laporan ini". Claude akan memegang seluruh konteks di bawah. Dokumen desain lengkap ada di `D:\2DGAME\docs\` (bisa ikut di-upload jika butuh detail penuh).

---

# 1. APA PROYEK INI
**Aetherion** — game 2D open-world sandbox action RPG, pixel art, dibangun di **Godot 4 (GDScript)** oleh tim solo/indie. Awalnya dikonsep sebagai MMORPG (gabungan Terraria, Ragnarok, Palworld, Pokémon, Monster Hunter, Magicka, RuneScape); kami putuskan **fondasi offline dulu**, online menyusul bertahap. **F2P, harus ringan** (PC kentang & HP RAM 2–3GB, pixel art 16/32px, target 60fps iGPU, build <150MB Fase 0).

## Tiga Pilar Desain (filter semua keputusan)
1. **Living World** — dunia bereaksi: cuaca, musim, langit, dan aksi pemain memicu event & monster rahasia.
2. **Identity Through Combination** — kekuatan dari kombinasi profesi × elemen × monster × rune; tidak ada build tunggal terbaik.
3. **Player-Driven Everything** — ekonomi & crafting digerakkan pemain (item terbaik = crafted; boss drop material+resep, bukan gear jadi).

## Fitur pembeda paling khas (jangan pernah dihapus)
- **Waktu game = jam WIB asli**; siang-malam nyata; **fase bulan mengikuti kalender lunar asli**; gerhana/solstice/meteor shower mengikuti kalender astronomi nyata.
- **Sains dibungkus fantasi (aturan 80/20)**: 80% dunia mengikuti fisika-kimia nyata yang disederhanakan (api butuh oksigen → lemah di air, kuat dengan angin; petir merambat via air/logam & di-ground oleh Earth; asam mengorosi Metal; Moon mengendalikan pasang-surut → surut ekstrem membuka jalur dasar laut & secret quest; cahaya bintang = pesan masa lalu), 20% dijelaskan oleh energi fantasi "Aether".
- **Hidden Scenario** (terinspirasi Rabituza/Shangri-La Frontier): trigger absurd tersembunyi (mis. bunuh 10.000 kelinci + tidur di penginapan saat purnama → Lunar Warren), **no-fail** (gagal = terkunci permanen), reward item tier S, first-clear diumumkan.
- **Ramalan Rasi**: 12 Rasi Agung (Serigala, Paus, Pedang, Timbangan, Naga, Kelinci, Mahkota, Jangkar, Obor, Cermin, Benih, Gerbang) mengikuti langit musiman asli; ramalan mingguan Astrologer = teka-teki petunjuk Hidden Scenario; rasi kelahiran per karakter.

---

# 2. KEPUTUSAN DESAIN KUNCI (hasil diskusi, sudah final)
1. **Tier item F→E→D→C→B (umum) | A→S→SS→SSS (Transenden)**: A+ hanya bisa di-CRAFT, success **1%**, butuh material kunci spesifik; struktur piramida (craft S butuh item A, SS butuh S, dst); anti-frustrasi: bahan dasar tidak hancur saat gagal + stack Insight +0,2%/gagal (cap +9%).
2. **Profesi: 1 UTAMA + 2 SUB** per karakter (maks 3 karakter/akun). Sub: cap lvl 60, efisiensi 75%, mentok tier B. Utama non-combat: **+50% EXP aktivitas intinya** (Lumberjack +50% saat menebang). Utama combat: akses Ultimate + Advanced Class. Maks 1 combat profession per karakter.
3. **17 elemen, 4 tier**: 8 dasar (Fire, Water, Wind, Earth, Lightning, Ice, Light, Darkness), 4 lanjut (Poison, Metal, Wood, Spirit), 2 langka (Void, Sky), **3 Celestial (Sun, Moon, Star)** — maks 1 Celestial per karakter. Matriks efektivitas ×1.3/×1.0/×0.7 + aturan sains sebagai data. Kombinasi elemen gaya Magicka (35 resep launch, discovery system).
4. **Taming**: syarat level pemain ≥ monster, HP<5%, Taming Orb. Rate: Common 80%, Rare 40%, Epic 15%, **Legendary 1,5%, Mythic 0,5%, Ancient 0,01%** + pity ringan. Gagal = enrage.
5. **Pet = Mount**: size Medium+ dengan saddle bisa ditunggangi KAPAN SAJA tanpa ganti peran (pasif tetap 50%).
6. **Element Flow**: senjata melee bisa dialiri elemen via 4 jalur (skill infusi lvl 20, coating Alchemist, enchant permanen, fusion) — hanya elemen dominan penuh, sekunder 25%; konsekuensi sains berlaku (petir + basah + zirah logam = nyetrum diri; solusi Grounding Boots).
7. **Pact System**: boss/NPC hebat bisa DIREKRUT dengan syarat sangat berat berlapis (prestasi + persembahan + ujian karakter no-fail + syarat langit); maks 1 Legendary Ally; dilarang di Arena.
8. **Homestead**: lahan pribadi instance offline; luas mengikuti level+gold (16×16 s/d 96×96 tile); tanam herbal/obat (tumbuh real-time WIB, offline growth), ternak hewan & monster jinak, breeding pen; hasil 100% tradeable.
9. **Dunia 13 wilayah** termasuk tambahan: **Candyveil Meadows** (pink cotton candy), Ocean Kingdom (underwater penuh, pasang-surut nyata), **Skyveil** (lautan awan ala Skypiea). Dungeon di: kaki gunung, dalam gunung berapi, bawah air, udara, dalam awan, **perut paus** (Star Whale, hidden).
10. **Rilis bertahap**: Fase 0 = offline single-player penuh (FONDASI, sekarang) → Fase 1 konten → Fase 2 online-lite (marketplace async, leaderboard, Echo Vendor) → Fase 3 co-op → Fase 4 MMO. Semua logika ditulis server-authoritative-style sejak awal.
11. **Monetisasi**: F2P; hanya kosmetik + battle pass kosmetik + QoL non-power; anti-P2W mutlak (tidak menjual power dalam bentuk apa pun); gambling in-game gold-only dengan house edge & batas harian.
12. **Balancing monster**: BST per rarity (Common 300 → Ancient 800) × 6 arketipe (Tank/Bruiser/Assassin/Caster/Support/Swift) + rank bintang 1–5; roster launch 64 spesies + 8 boss + 6 secret (detail di Monster_Roster_Launch.md). Fluffbit (kelinci) = maskot & kunci Hidden Scenario.

---

# 3. YANG SUDAH DIKERJAKAN HARI INI (deliverable)

## A. Dokumen desain (ada di D:\2DGAME\docs\)
1. `GDD_Aetherion.md` — GDD v0.1 lengkap 18 bagian (pilar, loop, profesi, dunia, elemen, combat formula, monster, taming/fusion/evolusi/breeding, crafting, ekonomi faucet-sink, NPC, dungeon, PvP, racing, endgame, **database schema PostgreSQL + class diagram**, teknologi, monetisasi, roadmap 18–24 bln, 12 kelemahan+solusi, MVP cut).
2. `GDD_Aetherion_v0.2_Revisi.md` — tier F–SSS, profesi utama/sub, Candyveil/Skyveil, Homestead, waktu WIB & siklus langit, 17 elemen + tabel sains, dungeon lokasi unik, **Hidden Scenario system + 5 contoh**, daftar asset gratis, 8 ide penyempurnaan (semua disetujui user).
3. `GDD_Aetherion_v0.3_Revisi.md` — aturan sains-fantasi 80/20, **tabel sains Sun & Star untuk skenario** (solar noon, sundial, solstice, fotosintesis Sun Seed, aurora; navigasi bintang, rasi musiman, Letter from a Dead Star, live event supernova→black hole), **Ramalan Rasi**, fase rilis offline-first, **Pact System**, pet-mount, **Element Flow**, workflow pencarian asset.
4. `Monster_Roster_Launch.md` — kerangka balancing (BST, arketipe, TTK target, drop template) + 64 spesies per wilayah + 8 boss + contoh stat block siap implementasi.
5. `Fase0_Desain_Teknis.md` — **cetak biru Godot**: struktur res://, 7 autoload, data-driven JSON, **kode GameClock fase bulan (siklus sinodik)**, arsitektur combat+ctx sains, scenario engine, ekonomi NPC, save system, target performa, milestone 12 minggu, definisi selesai (8 poin).
6. `Daftar_Download_Asset.md` — master list ±90 pack asset gratis per kategori dengan prioritas.
7. `PROMPT_CLAUDE_CODE.md` — instruksi eksekusi otonom untuk Claude Code (lihat §5).

## B. Asset orisinal buatan Claude (prosedural, milik proyek, sudah di-download user)
- `aetherion_palette_v1.png` — palet resmi 53 warna per ramp wilayah.
- Konsep **Fluffbit** 32×32, 3 varian (normal/Frost/Moonbit).
- `aetherion_original_assets_v1.zip`: **17 ikon elemen** 32×32 gaya badge konsisten; **8 frame fase bulan** 48×48; **12 Rasi Agung** 96×96; **tileset Candyveil** 16×16 (grass 2 varian, path+edge, sungai soda animasi 2 frame, pohon lolipop 32×48, gummy bush, mint rock, choco log, tilesheet gabungan); **Star Whale** 128×80; **Fire Flow VFX** 8 frame 32×32; README integrasi Godot (import Nearest/Filter OFF; frame bulan = round(moon_phase()*8)%8).

## C. Asset gratis yang SUDAH di-download user (19 pack, di D:\2DGAME sebagai zip)
Pixel Crawler/Anokolisa, Ninja Adventure (CC0), 80 CC0 RPG SFX, HydroGene 28 musik (CC0), Free Mana Seed RPG Starter, Pipoya Monster Pack + Character 32×32, Sprout Lands basic + UI, **Mana Seed Character Base Demo 2.0** (karakter pemain), Pixel_Poem RPG Hero, Shikashi Icons v2, Kenney Fantasy UI Borders (CC0), Cryo's Mini GUI, Caz MV Icons free, Nieobie Game Icon Pack (CC0), Frostwindz Lightning VFX, TomMusic Fantasy SFX, lentikula Basic Spell Impacts (CC0).
**Masih kurang untuk Fase 0:** font pixel (unduh Abaddon/m5x7/m6x11 — WAJIB, tidak bisa digenerate) ; opsional: pimen fire/ice/water/earth (VFX fire sudah ada penggantinya buatan kami), Minifantasy Dungeon Audio, RPG Essentials SFX.

---

# 4. STATUS TERKINI (titik terakhir percakapan)
- Semua asset (zip) + `aetherion_original_assets_v1.zip` sudah di **D:\2DGAME**.
- User sudah mengunduh `AETHERION_docs.zip` (berisi folder docs\ + PROMPT) untuk diekstrak ke D:\2DGAME.
- User punya **Claude Code di terminal (auto mode ON)**, siap menjalankan build otonom.
- **Langkah berikutnya user:** ekstrak AETHERION_docs.zip ke D:\2DGAME → `cd /d D:\2DGAME` → `claude` → paste **Bagian B** dari PROMPT_CLAUDE_CODE.md (hanya Bagian B) → agent mulai M1. Sesi berikutnya cukup: "lanjutkan sesuai STATUS.md".

# 5. RINGKASAN ISI PROMPT CLAUDE CODE (agar sesi baru paham mandatnya)
Agent = Lead Developer otonom penuh, TANPA konfirmasi: (§1) setup winget Git+Godot4+Python/Pillow, ekstrak zip ke assets_raw, git init, ASSET_LOG.md; (§2) milestone **M1** fondasi+GameClock WIB+bulan → **M2** combat (Fluffbit, Grey Wolf, Verdant Slime) → **M3** elemen + demo sains hujan→Wet→Lightning chain → **M4** taming+pet+mount → **M5** gathering+crafting+ekonomi NPC → **M6** homestead real-time → **M7** Hidden Scenario kelinci (debug 10, final 10.000) → **M8** polish+save+Sky Report+audio; (§3) verifikasi Godot headless tiap fitur, perbaiki error saat itu juga, commit per fitur, asset kurang→pakai yang ada→generate prosedural (palet resmi)→download hanya sumber tanpa-login (Kenney/OGA CC0), BLOCKED.md jika butuh manusia; (§4) setelah M8: bug sweep → EVALUATION.md → **MARKET_STUDY.md** (ATM: Stardew, Terraria, Palworld, Moonlighter, Forager, Core Keeper) → implement 3–5 fitur retention dimodifikasi khas Aetherion → siklus berkelanjutan; (§5) selesai = 8 acceptance Fase0 + nol error + loop 30 menit.

# 6. PREFERENSI & GAYA KERJA USER (penting dipertahankan)
- Bahasa: **Indonesia**, santai tapi teknis; user suka jawaban konkret + file deliverable.
- User memberi arahan bertahap dan menyetujui cepat ("oke boleh", "setuju semua") — Claude diharapkan proaktif mengeksekusi penuh, mengambil keputusan desain sendiri dengan alasan, membuat asset sendiri bila perlu, dan selalu menutup dengan usulan langkah paling produktif berikutnya.
- Peran Claude di proyek: Lead Game Designer + Economy Designer + Technical Consultant + Asset Producer + penulis prompt untuk Claude Code.
- Peran user: eksekutor download/ekstrak, playtest "rasa" game tiap milestone, keputusan pembelian asset berbayar.

# 7. HAL YANG BELUM DIKERJAKAN / BACKLOG IDE
- File JSON konten awal (monsters/items/elements/recipes/scenarios) — sengaja TIDAK dibuat di chat (user memilih agent Claude Code yang membuatnya saat build).
- Asset orisinal lanjutan: 12 monster ikonik versi polesan, UI Sky Report, logo & title screen, interior perut paus.
- Konten fase lanjut: breeding, fusion player-monster, racing, territory war, guild, marketplace pemain, mobile port.
- Ide disetujui yang menunggu implementasi: Aetherpedia, Photo Mode, title micro-buff, kalender langit in-game, dynamic music layering, Echo Vendor, event kontribusi server, Sky Report login.

— Akhir laporan. Dengan file ini + folder docs, konteks proyek pulih 100%. —
