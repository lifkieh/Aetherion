# STATUS — Aetherion Fase 0

**Last update:** 2026-07-11 (Session 1)
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
- **(3) FF-style overworld** ⏳ NEXT — NPC dialog box (dark-blue JRPG frame, speaker name, per-letter typing, portrait),
  FF-window menus/shop, fade transitions, elegant area-name banner on entry, per-region music/ambience, tidy town layout.
- **(4) Town = safe zone + guards** ⏳ safe_zone polygon per town (data); monsters can't enter/spawn, lose aggro at
  edge; immortal gate-guard NPC that knockbacks approaching monsters.
- **(5) Onboarding & guide** ⏳ contextual one-time popups (tree/monster/levelup/orb/dungeon-door/town), Pemandu NPC
  in Greenvale plaza, "Panduan" menu tab, 5-step opening quest chain (chop3→craft1→kill2→tame1→visit board).
- **(6) SKILL_AUDIT.md** ⏳ all skills vs GDD (element/cost/cooldown/DPS-per-mana outliers>30%; weapon behaviors on
  new click scheme; Element Flow+science post-refactor; fusion recipe symmetry 1+2==2+1); fix findings.
- **(7) Asset & polish** ⏳ more Greenvale/Candyveil deco variety, interiors, Shikashi/Caz item icons; original
  sprites: Grey Wolf + 2 candy + 2 desert monsters; SFX: prime/fusion/fizzle/menu/dialog-blip.
- Rule: game ringan (measure FPS before/after), headless test per system, commit+push per part, **tag v0.2-alpha** at end.
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
