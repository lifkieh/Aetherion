# EVALUATION — Aetherion Fase 0

Date: 2026-07-11 (Session 1). Engine: Godot 4.3-stable. Tests: 57/57 pass, 0 headless errors.

## 1. Acceptance vs `Fase0_Desain_Teknis.md` §1 (definisi "selesai")

| # | Kriteria | Status | Bukti |
|---|---|---|---|
| 1 | Jalan-jalan di Greenvale Forest (1 wilayah seamless) | ✅ | 80×60 tile region, kamera follow, boundaries; `reports/m1_shot2.png` |
| 2 | Combat: normal attack, 2 skill, dodge, Element Flow (Fire & Lightning) | ✅ | Player.gd; skills flame_slash/spark_bolt; infusion keys 1/2; `reports/m3_elem.png` |
| 3 | Bunuh & tame monster (Fluffbit, Wolf, Slime) → pet/mount | ✅ | TamingSystem, Pet follow/fight, mount; `reports/m4_pet2.png` |
| 4 | Gathering (pohon, copper) → craft 5 resep | ✅ | GatherNode + 7 recipes; `reports/m5_craft.png` |
| 5 | Homestead mini: tanam 2 herbal real-time WIB | ✅ | 4 plots, offline growth; `reports/m6_home.png` |
| 6 | Siklus siang-malam WIB + fase bulan asli | ✅ | GameClock (synodic), CanvasModulate, 8-frame moon; HUD |
| 7 | 1 Hidden Scenario (counter kelinci diam-diam) | ✅ | rabbits_killed silent counter, Lunar Warren; `reports/m7_warren.png` |
| 8 | Save/load lokal | ✅ | 3 slots + backup + schema_version, atomic write; roundtrip tested |

**All 8 acceptance points met.** A ~30-minute loop is playable end-to-end (explore → fight → tame → gather → craft → farm → sleep-trigger scenario → save).

## 2. Konformansi arsitektur (`Fase0` §2)

- **Data-driven (Prinsip #1):** ✅ semua konten di `data/*.json` (monsters, items, skills, recipes, elements, crops, loot_tables, scenarios, sky_calendar). Menambah monster = menambah baris JSON.
- **Simulasi = calon server (Prinsip #2):** ✅ semua logika inti (CombatResolver, MonsterFactory, TamingSystem, CraftingSystem, HomesteadSystem, Economy) adalah `class_name` UI-free / autoload murni — tidak menyentuh node/UI. Siap diangkat ke server.
- **Autoload lengkap:** ✅ EventBus, Db, GameClock, WorldState, PlayerData, Economy, SaveManager (+ Audio, ScenarioManager, Settings ditambah).
- **Struktur folder res://:** ✅ mengikuti blueprint (autoload/ data/ scenes/{world,actors,systems,ui,homestead,scenarios} assets/game/).

## 3. Yang kuat
- **Langit hidup:** waktu WIB nyata + fase bulan sinodik + kalender event asli, tampil di HUD & Main Menu Sky Report. Ini pembeda inti Aetherion dan sudah terasa sejak menu.
- **Sains terlihat bekerja:** hujan → musuh Wet (penanda tetes) → Lightning chain + Fire −30%, terverifikasi visual & unit test. "Momen pintar" GDD v0.3 §1 sudah bisa dirasakan.
- **Fondasi data-driven** membuat ekspansi (64 monster, resep, area) murni pekerjaan konten.
- **Test coverage** untuk semua sistem inti (57 assert) memberi jaring pengaman untuk iterasi.

## 4. Yang lemah / disederhanakan (utang teknis jujur)
- **Sprite 4-arah** (pack hanya 4-facing); gerak 8-arah snap ke facing terdekat. Sprite "Grey Wolf" (beast.png) tampak kemerahan — kurang "grey"; kandidat re-tint/ganti orisinal.
- **Balancing draft:** angka combat di-tune untuk TTK enak, belum di-spreadsheet penuh. 4 musuh sekaligus bisa mematikan (swarm) — perlu tuning aggro/damage.
- **Homestead sun-dependency** (sunbud `needs_sun`) belum memengaruhi pertumbuhan (hanya flag). Fotosintesis-cuaca menyusul.
- **AI monster** sederhana (wander/chase/flee/attack); belum ada ranged proyektil musuh nyata (caster pakai melee fallback).
- **UI** fungsional tapi placeholder (belum pakai Kenney 9-slice panel); label interactable bisa tumpang tindih saat berdekatan.
- **Pet** tak bisa mati (Fase 0 sengaja) & tidak makan/affinity aktif.

## 5. Perubahan dari dokumen + alasan (lihat DEVLOG untuk detail)
- `DEF_FACTOR` 0.6 → **0.5** dan HP display ×4 → **×2**, plus stat hero > BST fodder: GDD stat block Grey Wolf tidak konsisten secara internal (HP naik 4.6× vs ATK 1.15×). Dokumen menyatakan angka = draft. Dipilih nilai yang memenuhi target TTK §1.3.
- Menambah autoload **Audio, ScenarioManager, Settings** (tak ada di daftar blueprint) — diperlukan & selaras prinsip.
- **Scene dibangun via kode** (bukan .tscn resource berat) untuk keandalan build otonom.

## 6. Bug ditemukan & diperbaiki (lihat BUGS.md)
- #1 (High): semua monster me-render sprite fallback (slime) karena `_ready()` build sprite sebelum `setup()` mengisi data. Fixed untuk Monster/Pet/Interactable.
- Save slot tak sinkron: quick-save & auto-save skenario kini pakai `SaveManager.current_slot`, bukan hardcode slot 1.

## 7. Rencana lanjut (§4)
MARKET_STUDY.md → pilih 3–5 fitur high-impact/low-cost (daily quest board, fishing minigame, achievement+title, Aetherpedia/koleksi, photo mode) dengan twist cuaca/langit WIB → implement → verifikasi → commit. Lalu ekspansi konten monster/area.
