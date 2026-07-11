# DEVLOG — Aetherion (autonomous build)

Format: newest first. Decisions not dictated by docs are recorded here with rationale.

## 2026-07-11 — UI/UX §6: SKILL_AUDIT.md + fixes (DONE)

Full audit written to `SKILL_AUDIT.md` (5 axes). Fixes applied:
- **Bug — top-down attack ignored the weapon.** `PlayerPlatformer` already branched on `weapon_type`, but the
  overworld `Player._do_attack` always did a facing-cone `strike` — a bow/wand still swung a sword. Rewrote it to aim at
  the cursor and branch (bow→arrow, wand→projectile+mana, spear→long thrust, sword→wide arc), matching the side-view so
  the prime→left-click language is truly one language.
- **Balance — DPS-per-mana.** `flame_slash` mp 8→9 (it is melee *and* AoE, shouldn't also be most mana-efficient) and
  `spark_bolt` mp 10→9 (the safe ranged option was underpowered). The three mana damage skills now sit within ±17 % of
  their mean (was a 67 % gap between best/worst).
- **Cleanup — removed the dead `element_flow` skill** (kind `buff`, element `none`); superseded by the four `flow_*`
  skills, referenced nowhere, and would have mis-fired as a melee swing if ever slotted.
- **Verified already-correct:** every skill element valid; Element Flow + platformer rules (wind double-jump, ice
  freeze) + elemental science all survive the refactor; fusion recipes order-independent (1+2==2+1) across all 9.
- New `[Skill Audit §6]` regression suite (12 checks). 229/229 headless tests pass.

## 2026-07-11 — UI/UX §5: Onboarding & guide (DONE)

- New **`Onboarding` autoload** (non-blocking CanvasLayer, never pauses):
  - **6 contextual one-time tips** — town, tree, monster, levelup, orb, dungeon-door. Each shows once (guarded by
    `PlayerData.onboarding_seen`, persisted), queued so two never overlap, rendered in a gold-framed popup below the
    area banner that fades in → holds 6 s → fades out. Triggers wired to their natural moments: town on spawn, tree on
    proximity to a `GatherNode`, monster on first aggro (`Monster` CHASE), levelup on `player_leveled_up`, orb on
    `item_gained` of an `*_orb`, dungeon-door on proximity to the dungeon `Interactable`.
  - **5-step opening quest chain** — chop 3 trees → craft 1 → kill 2 → tame 1 → visit the Quest Board. Sequential;
    advanced by EventBus (`node_harvested`/`item_crafted`/`monster_killed`/`pet_added`/new `board_visited`). Progress
    persisted in `PlayerData.guide_step`/`guide_progress` and shown in an always-on top-right tracker
    ("📜 Panduan n/5 … (x/y)"). Graduation pays 100 G + 3 basic orbs.
- **Pemandu NPC** — new `Interactable` kind `guide` (friendly green), placed right by the Greenvale spawn; talks via the
  Stage dialog and opens the guide book.
- **"Panduan" menu tab** — a full Bahasa how-to-play reference (movement, combat, fusion, gathering/crafting, taming,
  town/dungeon, time/weather, saving), 8 gold-headed wrapped sections in the unified UiTheme window.
- Verified renders: `reports/onboarding.png` (tip popup + tracker + Pemandu) and `reports/panduan.png` (guide tab).
  217/217 tests pass (+13 `[Onboarding + Guide chain]`: tip-once gating, unknown-id no-op, per-step chain advancement,
  wrong-kind/failed events ignored, post-completion ignored).

## 2026-07-11 — UI/UX §4: Town safe zone + immortal gate guards (DONE)

- **`game/data/towns.json`** — per-town data with a `center`, a `safe_zone` polygon (points relative to center) and
  `gates` (guard posts). Greenvale ships a 5-point pentagon covering the plaza.
- **`SafeZone` autoload** — holds the ACTIVE town's polygon in global coords: `set_region(id)` / `clear()` /
  `contains(p)` (Geometry2D point-in-polygon) / `gates()` / `escape_vector(p)` (outward from town center). Every
  non-town scene (Candyveil, Desert, DungeonBase, Homestead, the 3 scenario scenes) calls `clear()` on `_ready` so a
  stale Greenvale polygon can never leak into another map (all maps share one coordinate origin).
- **Monster AI** (`Monster.gd`): the spawner rejects any position inside the zone; a chasing monster can't step across
  the edge (velocity zeroed at the boundary) and after ~0.6 s pressed against it gives up and cools off for 2.5 s
  (loses aggro); a monster somehow caught inside walks straight out along `escape_vector`; added a `knockback()` impulse
  (decays over time) used by guards.
- **`Guard.gd`** — self-building immortal NPC at each gate. No HP, can't be hit. Repels any monster within 66 px, always
  shoving it **outward** (`SafeZone.escape_vector`), never toward the center — this was the key fix: a radial
  push-from-guard bounced escaping monsters back inward and left one stuck oscillating at the north gate. Also talks
  (Stage dialog) when the player presses E.
- Verified by a headless probe (`AETHER_SAFEZONE=1`): 3 wolves force-spawned inside → **0 remain inside after 9 s**.
  204/204 tests pass (+13 new `[Safe Zone + Guards]` checks: data loaded, contains in/out, gates at perimeter,
  unknown-region clears, knockback direction + aggro suppression).

## 2026-07-11 — UI/UX §3: FF-style overworld (DONE)

- New **`Stage`** autoload — a persistent high-layer CanvasLayer overlay (survives scene changes) that owns all the
  Final-Fantasy presentation:
  - `say(lines, speaker, portrait)` — dark-blue gold-framed dialog box anchored to the bottom, with a speaker name
    tab, a pixel-art portrait frame, per-letter typing (`Label.visible_characters` @ 42 cps + soft blip SFX), a
    blinking ▼ arrow, and click/E/Space to advance (first press skips typing, second advances). Awaitable; pauses the
    tree while shown. NPCs (`Interactable`: shop/board/astrologer/inn/bench) now speak a short Bahasa-Indonesia line
    *before* opening their menu.
  - `banner()` / `enter_region(title, subtitle, music)` — an elegant gold-ruled area-name banner that fades+slides in
    on region entry, plus the per-region explore track. Wired into Greenvale, Candyveil, Desert and every dungeon
    (`DungeonBase.cfg().name`). Music map (only 3 tracks exist): Greenvale/dungeon-forest → Clearing, Candyveil →
    Lost Village, Desert/dungeon → Road.
  - `go_to_scene(path)` — fade-to-black → `change_scene_to_file` → fade-in. Replaced every gameplay
    `change_scene_to_file` (Interactable dungeon door, Homestead/region Portals, ScenarioManager enter/resolve,
    MainMenu new-game/continue, MenuUI return/load) so all transitions are smooth.
- **Tidy Greenvale plaza**: service NPCs laid out in two even rows (Papan Quest/Bengkel/Pedagang/Astrolog north;
  Penginapan/Rumah/Gua south), region gates pushed to the plaza corners, ponds moved well outside town, and
  `_scatter_props()` now skips anything within `PLAZA_RADIUS` (210 px) so boulders never clutter the town center.
  Added `_place_interactable()`/`_place_portal()` helpers to de-duplicate the spawn code.
- FF-window menus/shop already share one look via §1 `UiTheme`; the dialog box reuses its palette (WINDOW/ACCENT/TEXT).
- Verified renders: `reports/dialog.png` (dialog + banner), `reports/town.png` (cleared plaza). 191/191 tests pass.

## 2026-07-11 — UI/UX §2: Skill hotbar + element fusion (DONE)

- New shared `Hotbar` (RefCounted) drives BOTH `Player` (top-down) and `PlayerPlatformer` (side-view) — one control
  language, no duplication. PRIME a slot with a number key → LEFT-CLICK releases it toward the cursor. Normal weapon
  attack is unchanged when nothing is primed.
- **Fusion**: two number keys within `COMBO_WINDOW` (1.5 s) arm a fusion. `elements.json` now has **9 recipes**
  (Firestorm, Thunder Rain, Steam Burst, Thermal Shock, Blizzard, Typhoon, Eclipse, Magma Surge, Supernova). Lookup is
  order-independent (`Db.elem_combo` — 1+2 == 2+1). Valid recipe → `fusion_bolt` projectile (element+mult override) +
  impact arc, mana 2×, first discovery announced and recorded in `PlayerData.discovered_fusions`. No recipe → fizzle
  (smoke + toast hint, 0.3× mana) so combos are *discovered*, never listed.
- HUD hotbar UI: 5 element-icon slots (original `element_*_32` icons), gold prime-glow border, top-down cooldown
  shade, number labels, and a "⚡ FUSION — klik kiri!" indicator when a fusion is armed. Verified render in
  `reports/hotbar.png`.
- **Bug fixed**: an earlier edit had displaced the `_build_hotbar()` call and the `toast_box` creation block into the
  tail of `_refresh_hotbar()`, which returns early while `hotbar_slots` is empty — so the hotbar (and toasts) were
  never built at runtime. Moved both back into `_build()`. Root-caused via screenshot after discovering the real
  project path is `game/` (main scene `MainMenu.tscn`); direct-scene run `--path game res://scenes/Main.tscn` with
  `AETHER_HOTBAR=1 AETHER_SHOT=1` confirmed the fix.
- 191/191 headless tests pass (incl. the `[Hotbar + fusion]` suite: ≥8 recipes, order-independent lookup, single
  prime+cast, valid fusion first-discovery + 2× mana, fizzle discovers nothing, expired window = single prime).

## 2026-07-11 — REPO PURGE (owner-approved): assets_raw removed from history

- Backup first: `git bundle create _tools/aetherion-backup-<sha>.bundle --all` (93 MB, all refs).
- `python -m git_filter_repo --path assets_raw --invert-paths --force` rewrote all 38 commits.
- Result: **`.git` 104 MB → 5.7 MB**; `assets_raw` in **0 commits**; our `game/assets/` (202 files) intact.
- Re-added origin, `git push origin --all --force` → remote `main` = a56a78b (verified `git ls-remote`).
- Loose end: the `v0.1-alpha` tag re-push hit an intermittent credential-helper failure; the remote tag still
  points at the pre-purge orphan. Will be reconciled when `v0.2-alpha` is pushed at the end of this UI/UX round.

## 2026-07-11 — GitHub connected + PERMANENT RULE

- Remote: `origin = https://github.com/lifkieh/Aetherion.git`. Default branch renamed **master → main**.
- `.gitignore` now excludes `assets_raw/` (third-party extracted packs — repo slim + license-safe; only
  `ASSET_LOG.md` records them), plus `export/ build/ *.exe *.pck *.tpz .godot/`. Our ORIGINAL assets in
  `game/assets/` stay versioned. `git rm --cached -r assets_raw` untracked them going forward.
- **PERMANENT RULE (binding):** at the end of **every milestone or session**, push then verify:
  `git push origin --all && git push origin --tags && git ls-remote origin`. Never skip.
  (Note: git rejects `--all --tags` combined in one invocation — use the two commands above.)
- History note: `assets_raw` remains in earlier history (~90 MB; largest single file 4.4 MB, **none >50 MB**,
  so no rewrite-blocker). Not rewriting history (per owner rule). A `git filter-repo` purge is available on
  request if a slimmer/cleaner-license history is wanted — see STATUS.

## 2026-07-11 — OFFICIAL DECISION: Fase-0 level compression (stretch-ready)

Fase 0 uses **compressed level caps** so early content is reachable, but every cap is a **named constant**
and every curve is a **single-divisor formula** — the full GDD 1–99 scale is reached later by editing
constants only, **no code refactor**.

| Domain | Fase 0 cap | GDD full | How to stretch |
|---|---|---|---|
| Profession UTAMA | **50** (`ProfessionSystem.MAIN_CAP`) | 99 | raise MAIN_CAP |
| Profession SUB | **30** (`SUB_CAP`) = 60% of main | 60 | raise SUB_CAP (keep ~60% ratio) |
| Player combat level | soft ~1–30 (curve `50·lvl^1.5`) | 99 | tune `exp_to_next` divisor/exponent |
| Monster content level | 1–25 (roster data) | 1–99 | data only (monsters.json `level`) |

Profession XP curve: `prof_level = floor(sqrt(xp/20)) + 1`, clamped to cap. To stretch the curve without
touching call sites, change the `/20` divisor (bigger = slower) and the cap constants. The **ratio**
sub≈60% of main is intentional and preserved across the stretch (GDD 60/99 ≈ Fase-0 30/50 = 60%).

## 2026-07-11 — Profession XP + perks (GDD v0.2 §3)

- **ProfessionSystem** autoload awards XP off existing signals (node_harvested→lumberjack/miner,
  block_mined→miner, crop_harvested→herbalist, item_crafted→recipe's profession, fish_caught→fisherman,
  tame_attempted→tamer). **+50% XP** when the profession == `PlayerData.professions.main`. Level = floor(sqrt(xp/20))+1.
- **professions.json** defines milestone perks; `perk_value(prof, type)` is queried by systems. Wired:
  miner **faster** (−hits, lazy `_hp` init in DungeonTerrain) + **bonus_yield** ore; lumberjack/herbalist/cook
  **bonus_yield**; fisherman **bite_window** (+30% in FishingUI). Level-ups + perk unlocks toast.
- **Profesi** menu tab: 9 professions with level/XP/next-perk + "Jadikan Utama" (set main). Persisted via prof_xp.
- Fixed a MenuUI regression where inserting the prof case displaced the sky/echo match cases (parse error).
  17 → 18 autoloads. Suite 146 → 153.

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
