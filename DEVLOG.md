# DEVLOG — Aetherion (autonomous build)

Format: newest first. Decisions not dictated by docs are recorded here with rationale.

## 2026-07-11 — Session 1: Setup + M1 (Foundation) + M2 systems

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
