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
**ALL 8 MILESTONES (M1–M8) COMPLETE.** Fase 0 feature-complete, 57/57 tests, 0 errors.
Entering §4 continuous development: acceptance review, bug sweep, EVALUATION.md, market study, content expansion.

## Next steps (exact)
1. §5 acceptance check vs Fase0 §1 (8 points) — verify a full ~30-min loop end to end.
2. §4.1 bug sweep: play full flow via demos + code review → BUGS.md → fix to zero.
3. §4.2 EVALUATION.md vs docs; §4.3 MARKET_STUDY.md (ATM) → pick 3-5 features → implement.
4. Expand content: more monsters/recipes/areas from Monster_Roster & GDD.

## Health
- Headless: 0 errors. Test suite: **34/34 pass**.
- Known bugs: none. See BUGS.md (created at first bug).
