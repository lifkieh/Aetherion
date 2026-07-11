# DEVLOG — Aetherion (autonomous build)

Format: newest first. Decisions not dictated by docs are recorded here with rationale.

## 2026-07-11 — Dungeons scaled out (Gummy Cavern, Desert Barrow) via DungeonBase

- Extracted **DungeonBase** (`class_name`) holding all shared side-view dungeon logic (terrain build, 3-floor+
  arena layout, dark+torch lighting, player carried-light, monster/boss spawn, exit portal, HUD hint, perf
  probe). Each dungeon is now a **thin `cfg()` override** — no duplication.
- **GreenvaleDepths** refactored to extend DungeonBase (kept its puddles). **Gummy Cavern** (Candyveil,
  pink candy theme, **Gummy Titan** boss) and **Desert Barrow** (sand theme, **Anubis Warden** boss [A]
  Ankh Fragment). Boss adds are configurable via `add_species` (King Slime→verdant, Titan→gummy, Anubis→jackal).
- `DungeonTerrain.build_from(layout, tile_tint)` themes tiles per dungeon. Dungeon doors (`Interactable`
  kind `dungeon`, configurable `dungeon_scene`/`dungeon_label`) added to Candyveil & Desert; all overworld
  regions restore the player at the door on return (`pending_return_pos`). Suite 146/146.

## 2026-07-11 — OWNER PRIORITY: Terraria-style dungeon combat (9 reqs) — DONE

1. **Mouse aim**: dungeon attacks aim at the cursor. Left-click = melee **arc swing** (multi-hit all in a
   cone toward cursor) or weapon behavior; right-click = skill (spark bolt to cursor). Hint bar updated
   (`HUD.set_hint`).
2. **projectiles.json** (speed/gravity_scale/pierce/bounce/lifetime/element/on_hit_effect) + **ProjectilePool**
   autoload (object pooling, prewarmed 40). Used by player AND enemies (`target_group`).
3. **combat_feel.json** + **CombatFeel** autoload: knockback weighted by archetype (both parties), i-frames
   0.5s + flash, **hitstop** (time_scale blip, ignore-time-scale restore), **screen shake** (camera tween).
4. **Contact damage** from enemies (skips `passive` species).
5. **Weapon behaviors** by `weapon_type`: sword=fast wide arc, spear=long narrow thrust, bow=hold-charge
   (0.5→1.5× dmg on release), wand=mana-cost elemental projectile. Element Flow still applies to melee.
6. **King Slime 2-phase** (telegraphed): phase 1 jump-chase with a **landing shadow** + spawns 2 Verdant
   Slimes at each 25% HP threshold; phase 2 (<40% HP) shrinks, faster, higher jumps, **gel-glob** projectile
   burst on landing. Death split disabled for the boss (adds replace it).
7. **3+ enemy behaviors**: walker, **jumper** (verdant_slime), **shooter** (cave_spitter → enemy_bolt),
   plus flyer (cave_bat). `MonsterFactory.make` now propagates is_boss/behavior/projectile/passive.
8. **Perf audit** (full dungeon): switched per-cell collision → **merged row strips**. Measured:
   **372 scene nodes (<1000), 105 collision strips (was ~600), 60 FPS, 21 lights.** No chunking needed.
9. **Headless tests**: arc multi-hit, pooling (spawn/reuse), knockback velocity, i-frames value, boss
   phase-2 + threshold adds — all pass. Suite now **144/144**.

## 2026-07-11 — OWNER DECISION (locked): dungeons are side-view platformers

**Directive:** open world stays **top-down**, but **ALL dungeons use a side-view Terraria-style platformer
perspective.** Rationale (owner): distinct dungeon feel + mining/verticality depth. Binding for all current
and future dungeons.

Implementation contract (must follow):
1. New `PlayerPlatformer` controller (gravity, jump, coyote time, jump buffer, ladders, one-way platforms)
   that **REUSES PlayerData / CombatResolver / element logic** — no combat-logic duplication (shared via
   `PlayerCombat` helper).
2. Transition: a dungeon door in the top-down world → side-view scene; exiting returns to the exact door
   position in the overworld.
3. Dungeon TileMap with a **soft mineable** block layer (dirt/stone) + **ore veins** embedded in walls (copper
   in the Greenvale dungeon) giving material + **Miner EXP**; **hard blocks are undiggable** so level design
   stays controlled.
4. Dark lighting + torches (CanvasModulate + cheap Light2D point lights, performance-friendly).
5. Convert the **King Slime dungeon** to this format as the pilot: 3 vertical floors + boss arena at the bottom.
6. Dungeon monsters use side-view sprites (assets_raw LuizMelo etc.) with simple platformer AI (edge patrol,
   small hops).
7. Platformer element rules (as DATA): Wind infusion = brief double jump; Ice freezes puddles into platforms.
8. Headless tests for basic physics (fall, jump, mine block, scene transition).
After the pilot passes, resume remaining STATUS.md priorities with **all future dungeons in this side-view format.**

**PILOT DELIVERED & VERIFIED (same day):**
- `PlayerCombat` helper extracted; top-down `Player` refactored to delegate to it → `PlayerPlatformer`
  reuses the exact same combat/element logic (no duplication). Confirmed via tests + refactor.
- `PlayerPlatformer`: gravity, jump (coyote 0.1s + 0.1s buffer), Wind-flow **double jump** (data rule),
  one-way platform drop (down+jump), ladder climb; attack/skills/mining share PlayerCombat.
- `DungeonTerrain`: ASCII-layout → visual TileMapLayer + **per-cell StaticBody collision** (robust; the
  code-built TileSet physics-layer approach tunneled, so switched to per-cell shapes which also make mining
  remove the exact cell). Soft dirt/stone/copper diggable; **bedrock undiggable**; copper vein → copper +
  Miner XP (`PlayerData.gain_prof_xp`).
- `DungeonMonster`: side-view platformer AI (edge/wall patrol via raycasts, small hops; flyer bob for bats);
  reuses `CombatResolver` + `MonsterFactory.grant_rewards` (shared with top-down Monster).
- `GreenvaleDepths` (King Slime pilot): 3 floors + ladders + platforms + ore veins + **boss arena** at the
  bottom (King Slime, split); dark `CanvasModulate` + torch **PointLight2D** + a light carried by the player.
- Transition: overworld dungeon door sets `WorldState.pending_return_pos` → side-view scene; exit Portal →
  overworld spawns the player back at the door.
- Element platformer rules in `elements.json.platformer_rules`; `Puddle` freezes solid under Ice-flow.
- Infuse keys added: 3=Ice, 4=Wind. Headless physics tests (fall/jump/mine/ladder/transition): **all pass**.
- Assets: LuizMelo not in the extracted packs → used perspective-neutral slime + a procedurally-generated
  bat + procedurally-generated dungeon tiles/torch (asset-fallback order honored; original side-view monster
  art remains a backlog swap).

## 2026-07-11 — Session 2 (round 3): Star Whale, Cook, music, Echo Vendors

- **Star Whale hidden scenario** — 2nd Hidden Scenario, fully wired to the fishing Star-Bait hook:
  `FishingSystem.can_hook_starwhale` (needs meteor-shower sky) → `FishingUI._hook` → new
  `ScenarioManager.trigger_scenario(id)` (action-triggered, respects no_fail lock) → `StarWhaleBelly` scene
  (survive 60s dodging welling stomach acid + parasites) → reward Ambergris Star [S]. Reused the survival
  pattern from LunarWarren.
- **Cook recipes** — 6 recipes (grilled fish, sushi, candy cake, cactus juice, jerky, moonfish feast) turning
  fish/candy/desert materials into consumables. Reuses the crafting bench + CraftingSystem.
- **Dynamic music layering** — Audio gained a 2nd player (`_combat`) crossfaded over the base explore track
  (base keeps playing underneath → seamless resume). `MusicDirector` autoload raises it on any `damage_dealt`
  and lowers it after 5s of calm.
- **Echo Vendors** — data-driven ghost kiosks (`echo_vendors.json`) placed in the hub; semi-transparent bobbing
  player sprites; interact → `MenuUI` "echo" panel with fixed-price wares. Lived-in hub without netcode (GDD §10.6).
- **Proximity labels** — Interactable/Portal/EchoVendor now only show their `[E]` label when the player is near,
  decluttering the busy hub.
- Autoloads 14 → 16 (MusicDirector; FishingUI counted earlier). Tests 112 → 119. 2 Hidden Scenarios now.

## 2026-07-11 — Session 2 (cont.): Fishing, Astrologer, Desert region

- **Fishing minigame** — FishingSystem (fish eligibility by WIB hour + lunar tide band + full moon + bait;
  `eligible()` is param-driven so it's unit-testable without touching the clock). Cast→bite→timing UI
  (autoload FishingUI, pause-immune). 3 ponds in Greenvale (generated pond sprite). Star Bait → Star Whale
  hook (`can_hook_starwhale` requires meteor-shower sky) sets counter for a future belly scenario.
- **Astrologer + Sky Calendar** — GameClock.days_until / upcoming_events (uses
  Time.get_unix_time_from_datetime_string on the real sky_calendar.json dates). Panel shows moon/tide/weather,
  a rotating **weekly prophecy** (scenario `hint`, week-indexed), and real upcoming events with day countdowns.
  Verified: Perseid shows "32 hari lagi" etc. This is the "langit sungguhan" pillar made tangible.
- **Desert of Ruins** (region 3) — sand/stone/rock/cactus/obelisk tiles **generated procedurally** (Pillow,
  per asset mandate). 7 monsters (Monster_Roster §2.3). Added a **resist** field to monster data +
  MonsterFactory; **Rock Golem `{lightning:0.9}`** = grounding science (near-immune to Lightning), verified
  by test (lightning dmg to golem << to a normal target). Sandstone gather nodes.
- **Combat swarm re-tune**: player max_hp 140→165 base curve, post-hit iframes 0.4→0.55s (caps swarm burst).
- Autoloads 14 (FishingUI added). Tests 90 → 112. 3 regions, 26 monsters. All pass, 0 errors.

## 2026-07-11 — Session 2: continuation per LAPORAN_PROYEK_AETHERION.md

The handover report `docs/LAPORAN_PROYEK_AETHERION.md` restates the Session-1 mandate (already done) and
its backlog §7. Continued into content + approved-feature backlog:
- **Candyveil Meadows** region — built from the original Aetherion candy tiles (grass/path/lollipop/
  gummy-bush/mint-rock/soda). 8 candy monsters (Monster_Roster §2.2) added as JSON with tinted placeholder
  sprites (original candy-monster sprites are a noted §7 backlog item). Pink "Sugar Rain" particles. Portal
  from Greenvale. NOTE: new PNGs need `godot --headless --path game --import` before first reference.
- **Daily Quest Board** — QuestSystem autoload; 3 quests/day chosen deterministically from a WIB-date seed;
  sky-gated variants (rain/full-moon) only appear when the real sky matches; progress via existing EventBus
  signals; claim rewards. Menu "Quest" tab + board interactable.
- **Photo Mode** — autoload CanvasLayer; [P] freezes + hides HUD (HUD now in group "hud") + frame; [E] saves
  a clean PNG to user://photos/.
- **Evolution** — EvolutionSystem (Fluffbit→Moonbit under full moon) + Moonbit monster; hooked to
  full_moon_began; PetManager now detects in-place species change (tracks a copied species string).
- Autoloads 11 → 14 (QuestSystem, PhotoMode; +Achievements from S1). Tests 72 → 90, all pass.

## 2026-07-11 — Session 1 (cont.): M2–M8 complete + §4 post-launch

### Milestones M2–M8
All eight milestones delivered and verified in one session (see per-milestone commits + STATUS.md).
Each milestone: playable build, headless verify, screenshot in `reports/`, unit tests, commit.
Notable fixes: sprite `_ready`-before-`setup` bug (BUGS.md #1, affected all monsters), save `current_slot` tracking.

### Combat tuning decision
GDD Grey Wolf stat block is internally inconsistent (HP ×4.6 vs ATK ×1.15 over 4 levels). Treated GDD
numbers as draft (doc says so). `DEF_FACTOR` 0.6→0.5, `HP_DISPLAY_MULT` ×4→×2, hero stats > BST fodder
→ common TTK ~7 basic hits (Monster_Roster §1.3). Verified by unit test.

### §4 continuous development (post-Fase 0)
- **Acceptance (§5):** all 8 points of Fase0 §1 met → EVALUATION.md.
- **Market study (§4.3):** MARKET_STUDY.md (Stardew/Terraria/Palworld/Moonlighter/Forager/Core Keeper/
  Graveyard Keeper) → picked retention features. Implemented first: **Achievements + Titles** (neutral
  micro-buffs) and **Aetherpedia** (bestiary/collection) — both pure EventBus/counter hooks (lowest cost,
  reuses silent counters incl. rabbits_killed which foreshadows the Warren). Menu "Pedia" tab.
- **Added autoloads:** Settings (Mode Hemat), ScenarioManager, Achievements.
- Test suite grew 34 → 63 assertions; all pass. 0 headless errors.

### Session 1 — Setup + M1 (Foundation)

### Environment
- Detected: Git 2.45, Python 3.14 (Pillow installed), VS Code. Godot absent.
- Installed Godot **4.3-stable** (win64) to `_tools/godot/` (direct download, not winget — more reliable for headless CI). Helper `run_godot.bat` at root. Chose 4.3 (not .NET) — `TileMapLayer` API available, stable, matches GDScript blueprint.
- Extracted all root zips to `assets_raw/{pack}/`. Found `aetherion_original_assets_v1.zip` inside `files (1).zip` → extracted (element icons, moon phases, constellations, Fluffbit, fire VFX, Candyveil tiles, palette).

### Architecture (per Fase0_Desain_Teknis)
- Autoloads implemented in dependency order: EventBus, Db, GameClock, WorldState, PlayerData, Economy, SaveManager, + **Audio** (added; not in blueprint list but needed and harmless).
- Data-driven: all content in `game/data/*.json` (elements, monsters, items, skills, recipes, crops, loot_tables, scenarios, sky_calendar).
- `systems/` classes (CombatResolver, MonsterFactory, TamingSystem, HomesteadSystem, SheetUtil) are UI-free `class_name` RefCounted — the future server-authoritative path.

### Decisions
- **Code-driven scenes**: world/HUD/sprites built in GDScript rather than hand-authored `.tscn` resources (SpriteFrames, TileSet). Rationale: solo autonomous build — code is more reliable to generate/verify than fragile binary-ish resource wiring. Player/Monster/Projectile keep thin `.tscn` shells.
- **4-direction sprites**: packs only ship 4-facing art. Movement is full 8-direction; animation snaps to nearest 4-facing (standard top-down approach). Noted vs prompt's "8 arah".
- **Combat tuning vs GDD draft**: GDD's own Grey Wolf stat block is internally inconsistent (HP grows 4.6× while ATK grows 1.15× over 4 levels). Treated GDD numbers as draft (doc says so). Set `HP_DISPLAY_MULT=2.0`, `DEF_FACTOR=0.5` (from draft 0.6), and gave the hero higher per-point stats than BST fodder so common-monster TTK lands in the Monster_Roster §1.3 target (verified ~7 basic hits in unit test).
- **Warnings-as-errors** disabled in project.godot (inference-on-variant etc.) to keep velocity; real parse errors still fail the build.
- Grass tileset: picked tiles by scanning `field.png` pixels (grass primary (1,7); green detail variants (3,6)/(4,6)) instead of guessing atlas coords. Trees scanned from `nature.png` region (16,48,32,32).

### Verification
- Headless import: 0 script errors.
- Headless run (90 frames): clean, Db loads 10 monsters / 32 items / 12 skills / 7 recipes / 2 crops / 1 scenario.
- **Test suite: 34/34 pass** (`tests/TestRunner.tscn`): Db, elem_mod matrix, science rules (lightning+wet chain, fire+wet/underwater, grounded), CombatResolver exact damage, MonsterFactory archetype distribution, TTK sanity, taming roll + orb consumption, homestead growth, economy pricing.
- Windowed screenshot verified visually (`reports/m1_shot2.png`): grass/trees/props, player, rain particles, moon-phase icon, clock/weather, HP/MP/EXP bars, Sky Report.
