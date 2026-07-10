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
- [ ] M3 — Elements (matrix+rules DONE in data & tested; TODO: in-world Fire/Lightning infusion VFX + rain→wet→chain demo visible)
- [ ] M4 — Taming & pet (TamingSystem DONE+tested; TODO: pet follow, mount, tame UI/feedback polish)
- [ ] M5 — Gathering & crafting (GatherNode DONE; TODO: inventory UI, crafting bench, shop NPC)
- [ ] M6 — Homestead (HomesteadSystem growth DONE+tested; TODO: homestead scene, plots, plant/harvest)
- [ ] M7 — Hidden Scenario (data DONE; TODO: ScenarioManager, counter trigger, Lunar Warren scene)
- [ ] M8 — Polish (save/load DONE+backup; TODO: 3-slot menu UI, main menu, Sky Report screen, Mode Hemat, full audio, element icons in UI)

## Now
Session 1 committed. M1 complete and visually verified. M2 combat logic complete & unit-tested.

## Next steps (exact)
1. Live-playtest M2: spawn player next to a monster, confirm attack/skill/dodge/damage-number/kill/drop/levelup loop on screen (screenshot). Fix feel issues.
2. M3: wire Element Flow VFX (fire_flow sprite on weapon swing) + spark visual; make rain→Wet→lightning-chain and fire−30% visibly demonstrable (debug overlay showing elem mult).
3. Then M4 pet-follow + mount.

## Health
- Headless: 0 errors. Test suite: **34/34 pass**.
- Known bugs: none. See BUGS.md (created at first bug).
