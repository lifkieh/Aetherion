# STATUS — Aetherion Fase 0

**Last update:** 2026-07-12 (BD-1 dua jalur ClassSelect selesai)
**Exe terakhir:** 2026-07-13 10:43 WIB — berisi hingga: **v0.4.4 SELESAI** (settings lengkap + keybind remap, gamepad penuh + glyph, lokalisasi ID/EN penuh + retrofit, Advanced Class Lv60 + Trial of the Rasi) di atas v0.4.3 penuh. Ukuran exe 92,6 MB. *(Aturan permanen: baris ini WAJIB diperbarui setiap export.)*
**Engine:** Godot 4.3-stable · GDScript · run via `run_godot.bat`
**How to run:** `run_godot.bat` (editor) · `run_godot.bat --headless res://tests/TestRunner.tscn --quit-after 30` (tests)

---

## Milestones
- [x] **M1 — Foundation** ✅ DONE
  - Godot project + 8 autoloads (EventBus, Db, GameClock, WorldState, PlayerData, Economy, SaveManager, Audio)
  - GameClock: real WIB time, day/night CanvasModulate curve, synodic moon phase (8-frame sprite), sky_calendar events
  - Player: 8-dir movement, 4-facing anim, camera; Greenvale region from Field/Nature tilesets; props; boundaries
  - HUD: clock/moon/weather, HP/MP/EXP, gold/level, Sky Report, toasts
  - Weather system + rain particles
- [x] **M2 — Combat** ✅ DONE
  - CombatResolver (GDD formulas), MonsterFactory (BST×archetype), 3+ monsters (Fluffbit/Wolf/Slime + 7 Greenvale)
  - Geometric melee (facing cone), 2 skills (flame_slash/spark_bolt), dodge, projectile, HP bars, damage numbers, death→drop+EXP+levelup, slime split
  - Verified in headless combat demo: player↔monster damage, **kill→loot→levelup chain confirmed**
- [x] **M3 — Elements** ✅ DONE
  - elements.json matrix (1.3/1.0/0.7) + science rules; elem_mod + chain tested
  - Element Flow infusion (Fire/Lightning, keys 1/2) with pulsing aura + HUD indicator
  - Fire swing uses fire_flow VFX; lightning chain draws arcs between **wet** monsters only
  - Rain → monsters show wet droplet markers → Lightning chains (verified: 1 direct + 3 chain hits/swing); Fire −30% vs wet (unit-tested)
- [x] **M4 — Taming & pet** ✅ DONE
  - TamingSystem roll (rarity×orb×weather×skill + pity), HP<5% gate, orb consume, enrage on fail — tested
  - Pet follows player + auto-fights nearby enemies (ally marker); PetManager keeps active pet spawned
  - Mount toggle (R) for Medium+ rideable pets → speed boost, pet hides
  - Fixed critical sprite bug (see BUGS.md #1) that affected all monsters
- [x] **M5 — Gathering & crafting** ✅ DONE
  - GatherNode: chop trees / mine copper with respawn (real-time), hits + drops
  - MenuUI overlay (pauses game): Inventory (equip/use), Crafting (7 recipes, success%, insight on fail), Shop (buy/sell)
  - CraftingSystem (consume/roll/base-preserve on fail) + Economy supply-demand — tested
  - Bench + Shop NPC interactables (E to open)
- [x] **M6 — Homestead** ✅ DONE
  - Separate Homestead instance (portal travel both ways), day/night, HUD/menu
  - 4 plots: plant mint/sunbud seeds → grow in real WIB time (offline growth via planted_at_unix delta) → harvest → product (sellable)
  - Growth stages visible; HomesteadSystem tested (backdated plots ready, young not)
- [x] **M7 — Hidden Scenario** ✅ DONE
  - Silent `rabbits_killed` counter (no UI); ScenarioManager trigger = threshold + full moon + sleep_at_inn
  - Shipping threshold **10000** (verified); debug 10 via AETHER_DEBUG_SCENARIO env
  - Inn interactable (sleep) triggers; Lunar Warren: survive 60s, don't kill rabbits, chased by Moon Rabbit Berserker
  - no_fail: cleared/failed written permanently to save; clear → Carrot of Calamity [S] + Moon element unlock (tested)
- [x] **M8 — Polish** ✅ DONE
  - Main Menu (New Game / Load 3 slots / Mode Hemat / Mute / Quit) with live Sky Report + moon icon + birth-sign
  - Save/Load 3 slots + backup rotation + schema_version + atomic write (roundtrip tested)
  - In-game system menu (Esc): Save/Load slots, Options, back to Main Menu
  - Mode Hemat (30fps cap, weather VFX off), persisted to user://settings.cfg
  - Element icons (original assets) in HUD; per-scene music; full HUD

## Now
**ALL 8 MILESTONES COMPLETE + §4 continuous development ongoing.** Fase 0 feature-complete.
**153/153 tests**, 0 headless errors, **zero known bugs**. 18 autoloads. **3 overworld regions + 3 side-view
dungeons, 31 monsters (incl. 3 dungeon bosses), 2 Hidden Scenarios.** Terraria-style dungeon combat +
**Profession XP/perks** (harvest/mine/fish/craft/tame → XP, +50% main, milestone perks, Profesi menu tab).

Session 2 round 3 added: **Star Whale hidden scenario**, **6 Cook recipes**, **dynamic music layering**,
**Echo Vendors** + **proximity labels**.

**OWNER DIRECTIVE DONE (2026-07-11): side-view platformer dungeons + Terraria-style combat.**
Overworld stays top-down; ALL dungeons are Terraria-style side-view. Pilot **Greenvale Depths** (King Slime,
3 floors + boss arena). **144/144 tests** incl. physics + combat (arc/pooling/knockback/i-frames/boss phases).

### Dungeon combat (all 9 reqs done — see DEVLOG)
Mouse aim (L=arc melee/weapon, R=skill), data-driven pooled projectiles (player+enemies), combat feel
(knockback/i-frames/hitstop/shake), contact damage, weapon_type behaviors (sword/spear/bow/wand), King Slime
2-phase telegraphed boss, enemy behaviors walker/jumper/shooter/flyer.

### ⚙ Perf audit (full Greenvale Depths dungeon) — req #8
| Metric | Value | Budget |
|---|---|---|
| Scene nodes | **372** | < 1000 ✅ |
| Collision shapes | **105 merged strips** (was ~600 per-cell) | — ✅ |
| FPS | **60** | ≥ 60 ✅ |
| Lights | 21 | cheap PointLight2D ✅ |
No chunking needed; per-row strip merge already well within budget. Mining rebuilds only the affected row.

### How to build the NEXT dungeon (reuse this pattern)
- New scene `res://scenes/world/<Name>.gd/.tscn` modeled on `GreenvaleDepths.gd`.
- Build an ASCII layout (`_layout()` returns Array[String]); chars: `B`=bedrock(hard), `#`=stone(soft),
  `D`=dirt(soft), `O`=ore(soft→material+MinerXP), `=`=one-way platform, `H`=ladder, ` `=empty.
- `DungeonTerrain.build_from(layout)` handles collision/mining/ladders. Add torches via `_add_light` +
  torch sprite; a dark `CanvasModulate`. Spawn `DungeonMonster` (side-view AI) + a boss.
- Player = `PlayerPlatformer.tscn` (reuses PlayerData/PlayerCombat). Exit = `Portal` back to the overworld.
- Overworld entrance = `Interactable` kind `"dungeon"` with `dungeon_scene` set (sets `pending_return_pos`).
- New block drops/monsters/bosses/tiles are data — extend monsters.json/loot_tables/items + generate tiles.

Session 2 (per LAPORAN_PROYEK_AETHERION.md backlog §7) added:
- **Candyveil Meadows** (region 2, original candy tiles, 8 monsters) + **Desert of Ruins** (region 3,
  procedural sand tiles, 7 monsters incl. Rock Golem lightning-immunity = grounding science).
- **Daily Quest Board** (3 quests/day from WIB date, weather/moon-gated).
- **Fishing minigame** (fish gated by WIB hour+tide+moon+bait; Star Bait hooks Star Whale).
- **Astrologer + Sky Calendar** (moon/tide/weather now, weekly prophecy riddle, real upcoming events w/ countdowns).
- **Photo Mode** ([P], clean screenshots to user://photos/) + **Evolution** (Fluffbit→Moonbit on full moon).
- Monster **resist** system (data-driven, powers grounding science). Combat swarm re-tune (bulk + iframes).
Session 1 (§4): EVALUATION.md (8/8 acceptance), MARKET_STUDY.md, Achievements+Titles, Aetherpedia,
full bug sweep (7 bugs fixed, BUGS.md).

Note: headless test run may report OS exit 255 (Godot exit-cleanup artifact re: tweens/timers) — the
printed `RESULT: N passed, 0 failed` line is authoritative, not the process exit code.
**When adding new image assets, run `godot --headless --path game --import` before referencing them.**

## Dungeons (side-view, via DungeonBase — thin cfg() per dungeon, no dup)
- **Greenvale Depths** (King Slime) · **Gummy Cavern** (Candyveil, Gummy Titan) · **Desert Barrow**
  (Anubis Warden [A] Ankh Fragment). Each has a door in its overworld region + return-to-door.
- To add another: new `X.gd extends DungeonBase` overriding `cfg()` (theme/spawns/boss/return) + a `.tscn`
  + an `Interactable` kind `"dungeon"` door (set `dungeon_scene`/`dungeon_label`). Boss adds via `add_species`.

## Repo / GitHub
- Remote `origin = github.com/lifkieh/Aetherion.git`, default branch **main**. **PERMANENT RULE:** at every
  milestone/session end run `git push origin --all && git push origin --tags && git ls-remote origin`
  (two separate pushes — git rejects `--all --tags` combined).
- `assets_raw/` (third-party packs) is now **git-ignored & untracked** going forward (license-safe, slim).
- ⚠ **History note (no action taken):** `assets_raw` still exists in commits before this change (~90 MB;
  largest file 4.4 MB, **none >50 MB** so GitHub-safe). Per owner rule, history was NOT rewritten. If a
  slimmer / license-cleaner history is desired, a `git filter-repo --path assets_raw --invert-paths` purge
  can be run **on owner approval** (force-push required afterward).

## Backlog audit (owner request 2026-07-11) — positions
| Item | Status |
|---|---|
| Evolution system (Grey Wolf→Dire Wolf) | ✅ DONE — level-based (Lv≥8) + Fluffbit→Moonbit (full moon); dire_wolf monster; tested |
| Aetherpedia / bestiary | ✅ DONE — menu "Pedia" tab (auto-log monsters/items/weathers), collection reward hooks |
| BALANCE_REPORT.md (TTK vs target, dev>30%) | ✅ DONE — headless probe `AETHER_BALANCE=1`; tanks on-target, fragile archetypes documented |
| EVALUATION.md / MARKET_STUDY.md | ✅ DONE (Session 1) |
| Windows .exe export pipeline | ✅ DONE — templates installed; `game/export_presets.cfg`; **exports `export/Aetherion.exe` 84.8 MB** (embedded PCK, <150 MB target), **runs standalone** (Db loads, exit 0). Build: `run_godot.bat --headless --export-release "Windows Desktop" ../export/Aetherion.exe` |
| Profession 1 main + 2 sub (GDD §3) | ✅ DONE this session (gating/efficiency/caps/recipe-gate tested) |
| Level compression decision | ✅ DONE — documented in DEVLOG with stretch table |

## 🎨 UI/UX ROUND (owner directive 2026-07-11) — content frozen, tag v0.2-alpha at end
- **(0) Repo purge** ✅ assets_raw removed from history (104MB→5.7MB), main force-pushed. Tag reconcile pending.
- **(1) Unified UI Kit** ✅ `UiTheme` autoload (JRPG blue window + gold border + m5x7 + palette), applied to
  MenuUI/MainMenu/FishingUI. One panel style everywhere.
- **(2) Skill hotbar + element fusion** ✅ DONE — `Hotbar` shared class (top-down + side-view); 5 slots (keys 1-5)
  from Skill Book; PRIME (number) → LEFT-CLICK cast to cursor; two numbers <1.5s = FUSION (9 recipes in elements.json,
  mana 2x, order-independent lookup); no recipe = fizzle+smoke (discovery, first-discovery announced); HUD hotbar UI
  = 5 element-icon slots + prime glow + cooldown shade + fusion indicator (verified render `reports/hotbar.png`);
  normal attack stays without prime. Fixed edit-displacement bug that had `_build_hotbar()`/toast_box orphaned inside
  `_refresh_hotbar()` (hotbar never built). 191/191 headless tests pass.
- **(3) FF-style overworld** ✅ DONE — new `Stage` autoload (persistent CanvasLayer overlay): `say()` dark-blue JRPG
  dialog box (gold-framed, speaker name tab, portrait, per-letter typing + blinking ▼, click/E/Space to advance/skip);
  `banner()`/`enter_region()` elegant gold-ruled area-name banner + per-region music (Greenvale/Candyveil/Desert/
  dungeons); `go_to_scene()` fade-out→swap→fade-in used by all transitions (dungeon, homestead, region gates, scenarios,
  main-menu, load). NPCs (shop/board/astrologer/inn/bench) now converse before opening their menu. Tidy Greenvale plaza:
  service NPCs in two even rows, region gates at corners, props cleared within `PLAZA_RADIUS`. FF-window menus/shop
  already unified by §1 UiTheme. Verified renders `reports/dialog.png`, `reports/town.png`. 191/191 tests pass.
- **(4) Town = safe zone + guards** ✅ DONE — `towns.json` safe_zone **polygon** per town + `SafeZone` autoload
  (`set_region`/`clear`/`contains`/`escape_vector`); spawner rejects spawns inside; Monster AI can't path across the
  edge (stops + loses aggro w/ cooldown) and any monster caught inside walks straight out; **immortal gate-guard** NPCs
  (`Guard.gd`, self-built) at each gate shove nearby monsters *outward* (never inward). Non-town scenes call `clear()`
  so no stale polygon leaks. Headless probe: **0 monsters inside the zone** after 9 s (3 force-spawned inside all
  ejected). 204/204 tests (+13 SafeZone).
- **(5) Onboarding & guide** ✅ DONE — `Onboarding` autoload (non-blocking layer): 6 contextual **one-time tip popups**
  (town/tree/monster/levelup/orb/dungeon-door, queued, gold-framed, auto-dismiss, persisted in
  `PlayerData.onboarding_seen`); **5-step opening quest chain** (chop3→craft1→kill2→tame1→visit-board) with an always-on
  top-right **tracker**, advanced via EventBus, persisted (`guide_step`/`guide_progress`), 100G+3 orb graduation reward;
  **Pemandu NPC** (green, by spawn) that talks + opens the guide; **"Panduan" menu tab** = full Bahasa how-to-play
  reference. All Bahasa Indonesia, short, friendly. Verified renders `reports/onboarding.png`, `reports/panduan.png`.
  217/217 tests (+13 onboarding).
- **(6) SKILL_AUDIT.md** ✅ DONE — full audit on 5 axes. Findings fixed: (bug) top-down `Player._do_attack` ignored
  `weapon_type` (bow/wand/spear all swung a sword) → now aims at cursor + branches like the side-view; (balance)
  flame_slash mp 8→9 & spark_bolt 10→9 so DPS-per-mana spread ≤±17% (no >30% outlier); (cleanup) removed dead
  `element_flow` skill (flow_* supersede it). Verified PASS: element correctness, Element Flow + platformer rules +
  science post-refactor, fusion symmetry 1+2==2+1 (9 recipes). New `[Skill Audit §6]` suite (12 checks). 229/229 tests.
- **(7) Asset & polish** ✅ DONE — **5 original monster sprites** (grey_wolf, gummy_slime, choco_bear, rock_golem,
  dune_serpent — directional 4×4 sheets, wired in monsters.json); **5 original UI SFX** (prime/fusion/fizzle/menu/blip,
  procedurally generated, wired to hotbar prime/fusion/fizzle, dialog typing+advance, menu buttons); **deco variety**
  (Greenvale flowers/bush/mushroom/pebbles + Candyveil gumdrop/lollipop/candy_cane); **21 original item icons** +
  keyword resolver (`Db.item_icon`) shown in inventory/shop rows; **enterable interior** ("Rumah Warga" — warm
  plank room, furniture, lamps, exit portal, reached via a plaza house door). Shikashi/Caz packs are external (not in
  the purged repo) → made original icons instead. **FPS 60 maintained** (134 props, 680 nodes — still ringan). Verified
  renders `reports/{monster_preview,item_icons,inventory_icons,interior}.png`. 229/229 tests.

**Round status: parts 0–7 all ✅ DONE. Tagged `v0.2-alpha`.**

### Penutupan v0.2-alpha (2026-07-11)
- **Tag `v0.1-alpha` direkonsiliasi** — dibuat ulang di commit in-history `4b2ae50` (commit Fase-0 terakhir sebelum
  ronde UI/UX), anotasi mencatat kesetaraan pasca-purge; force-push. Ternyata tag lama **sudah** menunjuk commit valid
  di riwayat (bukan yatim lagi) — DEVLOG lama kadaluarsa; kini bersih & jelas. `v0.2-alpha` → `8451f55`.
- **Balance re-verify** — probe TTK di-run ulang pasca SKILL_AUDIT: **angka identik dengan baseline** (audit hanya
  ubah biaya mana + rute serangan, bukan matematika damage). Deviasi >30% tersisa = arketipe rapuh by-design (tank
  on-target). **Tidak retune** — perubahan balance menunggu playtest. Lihat `BALANCE_REPORT.md` bagian v0.2-alpha.
- **Re-export `.exe`** — `export/Aetherion.exe` **84.9 MB** (embedded PCK, <150 MB), **boot standalone OK** (Godot 4.3
  init, `[Db] Loaded: 33 monsters/72 items/16 skills…`, tanpa script error).

## 🌆 RONDE 2 — WORLD DENSITY & VISUAL RICHNESS (v0.2.1-alpha) — SELESAI
Menanggapi playtest owner ("world building kurang, kurang bangunan, UI kurang banget"). Konten baru tetap beku;
ronde ini memperkaya yang sudah ada. Semua aset ORISINAL (PIL / prosedural).
- **(1) Kota Greenvale nyata** ✅ `Town.gd` — 9 bangunan berfasad (bengkel+cerobong, balai kota, penginapan 2
  lantai, menara astrolog, toko ber-etalase, 3 rumah, kandang) + sumur, jalan batu, pagar, lampu jalan (nyala
  malam), stall pasar, peti/tong/pot/jemuran, 6 bangunan enterable (interior varian), NPC di posnya, 5 warga
  berjalan (dialog sadar-langit), ayam/kucing. Kamera 3x→2x. Isi taman padat: tak ada rumput polos.
- **(2) 3 wilayah padat** ✅ `WildDresser` — scatter flora bertema (12-20 obj/layar), edge band alami, 4 landmark
  arah (pohon raksasa/patung/gerbang batu/reruntuhan), jalur tanah ke POI. `Ambience` — kupu-kupu/kunang
  (hutan), gula melayang (candy), debu (gurun). Greenvale + Candyveil + Desert.
- **(3) UI diperkaya** ✅ panel karakter (potret + bar HP/MP/XP bertema), widget jam/bulan/cuaca, minimap radar
  dari data, hotbar berbingkai, inventory grid ikon + tooltip (nama/tier/stat/flavor), toast ber-ikon, damage
  number outline+bounce, main menu latar dunia blur + logo + versi.
- **(4) Flavor text** ✅ 72 item dapat 1 kalimat flavor (tooltip); dialog warga bergilir menyebut kondisi langit
  saat itu + gosip kota.
- **(5) Verifikasi** ✅ screenshot per area di `reports/` (self-eval vs kota JRPG padat), **60 fps** semua wilayah
  (Greenvale 1558 / Candyveil 896 / Desert 789 node — tanpa culling), 229/229 test, commit+push per bagian,
  **tag v0.2.1-alpha**, export `export/Aetherion.exe` **85.1 MB** (boot standalone OK, Db load, tanpa error).

## 🧬 RONDE 3 — AETHERION CHARACTER SYSTEM + KONTEN v0.3-alpha — SELESAI
- **Sistem karakter modular** (LPC DITOLAK): `CharGen` autoload port dari gen_charsys_v2 — komposisi per-bagian
  (kepala/badan/kaki) 7 ras + chimera, kulit/rambut/baju per-parameter. Character Creator saat New Game (preview 4
  arah live, acak), NPC **Cermin Jiwa** (re-custom 150G). Player + warga + NPC pakai sistem ini (Greenvale 100%
  human). **Kanon Celestia Kingdom** (ibukota semua ras) di DEVLOG + Aetherpedia. Frame serang 2-arah + rambut
  mohawk/sanggul. Semua 343 kombinasi ras×bagian ter-compose tanpa crash.
- **Frostpeak tuntas:** 7 spesies (§2.4) + evolusi; **pos pendaki** (desa safe-zone, NPC frostkin/wolfkin/human via
  CharGen); **Foothill Barrow** + bos **Frost Titan** 2-fase (Everfrost Core [A]).
- **Storm Island (§2.5):** region badai (hujan + kilat), 6 spesies + evolusi, **Thunder Dragon** secret (badai malam),
  **Zephyr Spire** + bos **Storm Sovereign** (Tempest Heart [S]). Akses via dermaga Greenvale.
- **Thermal Shock** (Api+Es) teruji; **Dire Wolf → Alpha Wolf** saat purnama.
- **60 monster**, screenshot self-check di `reports/`, balance probe (pola arketipe konsisten, lihat BALANCE_REPORT),
  **264 test lulus**, commit+push per bagian, **tag v0.3-alpha**, export `export/Aetherion.exe` **85.2 MB**
  (boot standalone OK, `[Db] Loaded: 60 monsters, 87 items`, tanpa error).

## ⚔️ RONDE 4 — POWER & COMBAT CALIBRATION — SELESAI
7 bagian + 6 revisi desain combat owner (A–F, keputusan FINAL, dicatat di DEVLOG):
- **PC1 Stat:** 6 atribut STR/AGI/VIT/INT/DEX/LUK, +5 poin bebas/level, tab **Status** ([+] alokasi,
  deskripsi 1 baris), wiring penuh ke CombatResolver (miss roll akurasi-vs-evasion), respec berbayar.
- **PC2 Model combat:** (A) hold-to-attack di rate senjata×AGI; (B) **semua cooldown skill DIHAPUS** —
  channel tahan-klik, mana_cost×cast_rate, mana habis = klik kosong, regen surge ×3 idle;
  (D) hit-immunity per-SOURCE (0.2s/0.4s bos) anti-melt; (E) infusion mengubah reach/arc/dmg melee
  per elemen (data `infusion_melee`), upkeep drain mana/dtk, toggle bebas. Kedua mode paritas feel penuh.
- **PC3 Fusion bertingkat:** 2-elemen holdable tanpa CD (mana 2.5×); **3–4 elemen = recast 0.7/dtk**
  (satu-satunya "cooldown"), 4 resep triple + 2 quad (Plasma Storm, Blizzard Lokal, Magma Wall,
  Sanctuary, Genesis Tempest, Entropy Collapse); HUD prime-chain ("1+2+5") + recast bar.
- **PC4 Akuisisi skill:** mulai 3 skill dasar; sisanya dari milestone level (gust Lv3, quake Lv8),
  **kitab skill** (drop/toko, klik untuk belajar), **NPC Guru Skill** (gold+level), first-kill bos
  (holy_ray ← King Slime; **Meteor ★ULTIMATE** ← Frost Titan). Tab Skill Book (dikuasai vs belum + hint).
- **PC5 Equipment:** 3 slot berfungsi nyata (armor→DEF+HP, aksesori→MATK+MP), rantai craft F→E→D
  (tunik/rompi/zirah, cincin tembaga/perak/emas, pedang besi), +27–36%/tier, tooltip banding hijau/merah,
  gear awal tier F. Fix bug ATK senjata dihitung dobel.
- **PC6 Kalibrasi total (rev F):** `BALANCE_TARGETS.md` (ditulis sebelum tuning) + **harness v2**
  (`AETHER_BALANCE=2`; TTK dua-arah, 3 build × Lv1/5/10/15, kedua mode, sadar-mana). Temuan struktural
  diperbaiki: HP monster kini mengejar pertumbuhan hero (TTK tak lagi kolaps), formula magic MDEF
  dimitigasi seperti DEF, ofensif monster ditemper (pack membunuh 6–8.7s, bukan <2s), **mage kering
  di 12.1s channel** (target 8–12). Bos proxy 50–107s (=2–4 mnt live). Hasil: `BALANCE_REPORT_v2.md`.
  Chase open world di-cap (selalu escapable), **death penalty dungeon = respawn di pintu −10% gold**,
  **F9 debug overlay** (dev only). **330 test lulus**, export `export/Aetherion.exe` **89.4 MB** boot OK.

## 🏗️ RONDE 5 — FOUNDATION FIRST (direktif besar owner) — SELESAI
Playtest owner: "game terasa HAMPA". Semua konten baru DIBEKUKAN. Dua tahap:
- **Tahap 1 (audit)**: `GAP_AUDIT.md` — kepatuhan 30 sistem GDD (temuan terbesar: 6 combat
  class GDD tak pernah jadi pilihan pemain = MENYIMPANG) + benchmark genre skor 0–2
  (overworld 7/18, combat 6/16, dungeon 3/12, meta 4/14 = **20/60**) + 5 akar rasa hampa.
  `MASTER_IMPROVEMENT_PLAN.md` — fase v0.4.0–v0.4.4 terprioritas + estimasi (±5–6 sesi).
  **Menunggu review owner & designer untuk fase berikutnya.**
- **Tahap 2 (langsung dikerjakan = v0.4.0 "Identity & Juice")**:
  (2a) **6 class combat** dipilih di New Game — 3 skill awal beda/class (10 skill baru),
  2 varian senjata awal, bonus stat, teaser advanced Lv60, `classes.json`, class = profesi
  combat utama; (2b) **8 tipe senjata ber-moveset & arc-slash VFX berbeda nyata** di kedua
  mode + afinitas class; (2c) prime toggle/klik-kanan/ESC batal; (2d) **Grimoire** fusion
  (ditemukan + misteri dari fizzle + tutorial + perayaan banner); (2e) **save modern**
  (autosave berkala+transisi, indikator, playtime, metadata slot, tombol Continue);
  (2f) **juice pass** (impact particles, death burst+dissolve, **loot menyembur fisik &
  magnet**, dodge afterimage, crit pitch); (2g) **30 menit pertama** (intro lore 4 layar
  ber-class, quest pembuka 6 langkah satu-sistem-satu-reward).
  **361 test lulus**, export `export/Aetherion.exe` **89.5 MB** boot standalone bersih.

## ⚔️ RONDE 6 — FASE v0.4.1 "COMBAT DEPTH" — SELESAI
Review owner+designer atas MASTER_IMPROVEMENT_PLAN: DISETUJUI + 3 penyesuaian
(Decision Log #22–25, dicatat sebelum kerja). Eksekusi penuh:
- **Status effects** Burn/Freeze/Paralyze/Poison/Blind + interaksi sains (Thermal Shock,
  konduksi basah, air memadamkan burn, poison potong heal) + ikon musuh & pemain.
- **Pola serangan musuh**: 0% jalan-nabrak — lunge/flank/burst per arketipe + telegraf
  universal di kedua mode (audit roster 60 spesies lulus test).
- **Boss upgrade 5 bos**: 3+ pola terkoreografi per fase, arena hazard per bos, intro
  bar+nama+stinger, perayaan kill slow-mo + jingle + hujan loot + banner.
- **Combo Skill** (2 skill beda <2 dtk = +30%) + publikasi cap/formula di tab Status.
- **Kedalaman monster TAMPAK**: ★1–5 di atas HP bar + Pedia, trait individu berefek,
  affinity pet hidup (tab Pet/ranch baru), MUTASI 1/500 emas.
- **Event harian berisi**: Golden Hour EXP+10%, Morning Dew +1, monster nokturnal,
  **Blood Moon penuh** (aggro ×1.5, drop ×2, langit merah, gerbang evolusi Ironhide Boar).
- **Tarikan review (i)**: PauseMenu layak + slider Musik/SFX terpisah + fullscreen.
**405 test lulus**, export `export/Aetherion.exe` **89.5 MB** boot bersih,
PLAN_LEDGER kedua bagian ter-update.

### ➕ Addendum Skill Tree Terikat Lokasi (Decision Log #30–32) — SELESAI
28 pohon di `skill_trees.json`; buka HANYA di lokasinya (rumor berarah di Penjaga Pohon),
upgrade di mana pun; Penjaga terpasang di 5 lokasi hidup + Homestead; Celestial tampil-terkunci
di Menara Astrologer (butuh buku Hidden Scenario); Wildhearth (kota beast) terdaftar konten beku;
XP Tamer pada aksi taming (sukses+percobaan). Pemetaan penuh: PLAN_LEDGER §7. 421 test, exe 89.5 MB.

### ➕ BD-1 (bug desain): DUA JALUR ClassSelect — SELESAI
Koreksi owner yang hilang sebelum masuk ledger (GAP_AUDIT BD-1, Decision Log #33) kini
terimplementasi penuh: tab ⚔ JALUR TEMPUR (6 class) + 🌾 JALUR KEHIDUPAN (Perajin/Petani/
Peramu/Penjinak — +50% EXP domain, kit awal, perk khas, pilih 1 combat sub = 1 senjata +
2 skill aturan sub); quest pembuka bercabang (langkah 2 = aktivitas domain); intro layar 3
bervariasi per jalur; Status & Profesi menampilkan jalur + sub; class kehidupan = diskon
50% + 1 node GRATIS di pohon skill domainnya. 437 test (end-to-end kedua jalur + persist).

### ➕ Piagam Pengalaman + Koreksi Penjaga Gerbang (Decision Log #34–39) — SELESAI
Dokumen: PLAN_LEDGER **Bagian 0 PIAGAM PENGALAMAN** (THE WORLD REMEMBERS; Wonder/Belonging/
Legacy; Living Sky = sistem terbesar; boss raid-class vs solo-able) + **spec World Remembers
v1 terkunci untuk v0.6** (§8: memori NPC, Rival, reaksi dunia — TIDAK dibangun sekarang) +
**TRACKBACK.md** (roadmap resmi v0.4.2→v0.9; Emberfall/Ocean→v0.7, Celestia→v0.8).
Kode (satu-satunya): **penjaga gerbang kini mendatangi & membunuh monster SATU PUKULAN**
(telegraf ayunan + juice) — pemain **nol EXP/drop/counter** dari kill penjaga (anti-exploit,
`guard_kill()` tanpa `monster_killed`); multi-monster satu per satu; penjaga tetap abadi.
444 test (kill penjaga nol reward + AI datang-dan-bunuh end-to-end).

### ✅ GERBANG 0: LULUS ("sudah tidak hampa", Decision Log #40)
### ➕ Ronde v0.4.1c (Decision Log #41–44) — SELESAI
BUG P0 jalur kehidupan buntu diperbaiki (tombol Lanjut di kedua panel + audit navigasi);
tangga dungeon modern (menempel/menggantung/lompat-lepas/anti-nyangkut); **Gerbang
Penjelajah "Pilih Dunia"** di 5 pemukiman (kartu wilayah dikunjungi + siluet terkunci,
25G, gratis 1×/hari — jalan pulang dari Frost/Storm beres); UI feel pass modern &
playful (UiFx + ui_feel.json: motion/hover/press/breathing/spring/celebration/microcopy,
Mode Hemat aman). **467 test.**

### ➕ Kanonisasi MASTER BLUEPRINT v1.0.1 (Decision Log #45–66) — SELESAI (dengan catatan BD-2)
⚠ **BD-2**: file `docs/MASTER_BLUEPRINT_AETHERION.md` TIDAK sampai ke workspace — TIDAK
difabrikasi; semua keputusan B1–B19 dikanonisasi dari teks direktif (termasuk koreksi
penomoran B19). Hierarki resmi tercatat: PLAN_LEDGER > MASTER_BLUEPRINT > MASTER_PLAN >
STATUS. Sinkron: ledger Bagian 1, TRACKBACK (v0.4.2 += Rumah Lelang; v0.4.4 += lokalisasi;
v0.5 gerbang B17+B18), MASTER_PLAN. Kode: B9 taming semua spesies (tame_base 0 dihapus) +
konvensi lokalisasi (autoload Loc + translations/id|en.json + contoh PauseMenu; teks baru
WAJIB ber-key). **4 LAPORAN AUDIT di reports/**: REPORT-01 Sinkronisasi (+peta cakupan
fitur, 6 fitur KOSONG teridentifikasi, 6 konflik antar keputusan), REPORT-02 Scope Risk
(Life Events & Kingdom = XL, pecahan milestone), REPORT-03 Story Readiness (kekosongan
naratif terbesar: Nirnama), REPORT-04 v0.4.2 Readiness (SIAP GAS, 2 blocker lunak). 472 test.

## ⏸️ STATUS: **Bible tercerna** (48.559 baris, 7 berkas → INDEX + REPORT-05 + ROADBOOK + ASSET_MANIFEST + DUNGEON_ORIGINS) — menunggu: **jawaban K1 (skala waktu, #123)** + **review REPORT-05** (25 konflik, 30 pertanyaan) + **playtest owner v0.4.3–v0.4.4**. Keputusan K1–K9 tercatat (#115–#123). Gerbang v0.5: B18 ✅ · **B17 Companion 10/50 ❌**
v0.4.2 siap (REPORT-04): Transenden sebagai MOMEN #25, Enchant+Enchanter, Coating,
quality roll + maker's mark, + Rumah Lelang NPC (B8).
Fase v0.4.1 tuntas. Feedback playtest v0.4.0/v0.4.1 owner akan diterima sebagai koreksi
di tengah tanpa menghentikan fase. Berikutnya sesuai plan: v0.4.2 "Gear & Economy Depth"
(Transenden sebagai MOMEN per Decision Log #25, Enchant+Enchanter, Coating, Rune,
quality roll + maker's mark).

### Konten BEKU tersisa — setelah playtest lolos
- **Pact System** — mekanik pakta/kontrak entitas (buff besar + biaya/risiko).
- **Roster monster lanjutan** — spesies tahap berikut + evolusi lanjutan.
- **Celestia Kingdom** — ibukota semua ras (kanon baru), kota terbesar.
Saat diaktifkan: pola data-driven yang ada (towns.json/monsters.json/DungeonBase, sprite orisinal),
**monster baru WAJIB dikalibrasi harness v2 sejak lahir** (`AETHER_BALANCE=2`), target game ringan (ukur FPS).
- **Definition of done:** a brand-new player with zero explanation understands how to play within 10 minutes.

## Next steps (exact) — for the next session, resume here
0. **Profession polish**: profession-gated recipe access (main-only A+ tier), reawaken/change-main quest,
   profession-level EXP display in HUD. (Core XP+perks already done.)
1. ✅ **Sugar Queen Tea Party** — DONE (eat 100 candies [debug 5] → 3-round etiquette quiz → 3 wrong = expelled
   permanent; clear → Royal Tea Cake [S] + Peppermint Fairy pet + sugar_blessed). Generic scenario counters now.
   ~~trigger "eat 100 different candies in a day"~~
   (track candy-eating in a daily counter) → etiquette quiz scene (3-round Q&A, 3 wrong = fail permanent) →
   reward Cook [S] recipe + Peppermint Fairy pet. ScenarioManager.trigger_scenario supports the entry.
2. **Frostpeak Mountain** region (Monster_Roster §2.4, 7 monsters incl. Ice element; blizzard weather that
   makes Fire −, Ice +). Generate snow/ice tiles procedurally like Desert. Ice→Thermal-Shock combo demo.
3. **Profession XP + perks** (GDD v0.2 §3): track per-activity XP (chop/mine/fish/cook/craft), levels, the
   +50% main-profession bonus. Ties titles + Aetherpedia together.
4. **Polish sprites**: replace beast.png "Grey Wolf" with a greyer canine (Ninja pack Dog/Hyena or generate);
   original candy/desert monster sprites (12 iconic list, report §7). Original UI Sky Report / title logo.
5. More regions from GDD (Storm Island §2.5, Emberfall §2.6) using the Candyveil/Desert region pattern.

## Verification recipes
- Tests: `run_godot.bat --headless res://tests/TestRunner.tscn --quit-after 40` → expect `90 passed`.
- Region screenshots: `godot --path game res://scenes/world/Candyveil.tscn` (env `AETHER_SHOT=1`).
- Demos (env=1 on Main.tscn): AETHER_COMBAT / AETHER_ELEM / AETHER_PET / AETHER_MENU(+AETHER_MENU_TAB=
  quest|shop) / AETHER_PHOTO / AETHER_HOME(Homestead) / AETHER_WARREN_SHOT(LunarWarren).

## How to run (reminder)
- Game: `run_godot.bat`  (boots MainMenu)
- Tests: `run_godot.bat --headless res://tests/TestRunner.tscn --quit-after 40`  (expect 63 passed)
- Verify a scene + screenshot: `godot --path game res://scenes/Main.tscn` with env `AETHER_SHOT=1`
  (demos: AETHER_COMBAT / AETHER_ELEM / AETHER_PET / AETHER_MENU / AETHER_HOME / AETHER_WARREN_SHOT)
- Hidden Scenario debug (threshold 10, bypass full-moon): env `AETHER_DEBUG_SCENARIO=1`

## Health
- Headless: 0 errors. Test suite: **34/34 pass**.
- Known bugs: none. See BUGS.md (created at first bug).
