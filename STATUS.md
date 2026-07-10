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
- [ ] M4 — Taming & pet (TamingSystem DONE+tested; TODO: pet follow, mount, tame UI/feedback polish)
- [ ] M5 — Gathering & crafting (GatherNode DONE; TODO: inventory UI, crafting bench, shop NPC)
- [ ] M6 — Homestead (HomesteadSystem growth DONE+tested; TODO: homestead scene, plots, plant/harvest)
- [ ] M7 — Hidden Scenario (data DONE; TODO: ScenarioManager, counter trigger, Lunar Warren scene)
- [ ] M8 — Polish (save/load DONE+backup; TODO: 3-slot menu UI, main menu, Sky Report screen, Mode Hemat, full audio, element icons in UI)

## Now
M1, M2, M3 complete & verified (screenshots in reports/). Next: M4 taming/pets.

## Next steps (exact)
1. M4: pet follows player + assists in combat; mount toggle for Medium+ rideable; tame feedback UI. TamingSystem + roll already done+tested.
2. M5: inventory UI, crafting bench, shop NPC (Economy done+tested; GatherNode done).
3. M6: homestead scene + plots (HomesteadSystem growth done+tested).

## Health
- Headless: 0 errors. Test suite: **34/34 pass**.
- Known bugs: none. See BUGS.md (created at first bug).
