# BUGS — Aetherion

Tracked defects. Status: OPEN / FIXED. Newest first.

| # | Status | Severity | Description | Fix |
|---|---|---|---|---|
| 1 | FIXED | High (visual) | **All monsters rendered the slime fallback sprite.** `Monster._ready()` (fires on `add_child`) built the sprite from an empty `inst`, because `setup(inst)` is called *after* `add_child`. Same for `Pet`. | Build sprite in `setup()` when already in-tree; `_ready()` only builds if data present. Sprites now correct project-wide. (Session 1) |
| 2 | FIXED | Med | **Monster leash `_home` captured as (0,0)** — `_ready` read `global_position` before the spawner set it, so idle monsters drifted to the top-left corner. | Lazy-capture `_home` on the first `_physics_process` frame (position finalized by then). |
| 3 | FIXED | Med | **GatherNode ignored `setup()`** — ore nodes built with the default `kind="tree"` (wrong sprite, 3 hits instead of 4) and the save-restore check used an empty id. | `setup()` re-runs `_apply()` (build + depletion check) when in-tree; `_ready` skips until id known. |
| 4 | FIXED | Low | **`CraftingSystem.insight` static var bled across New Game / Load** and wasn't persisted. | Moved to `PlayerData.craft_insight` (saved, reset on new_game). |
| 5 | FIXED | Low | **`mounted`/`infusion` not reset on load** — loading with a non-rideable/absent pet left the player stuck at mount speed. | `from_save()` clears `mounted=false` and `infusion={}`. |
| 6 | FIXED | Low | **Scenario auto-save could persist `hp=0`** after a death-fail (respawn is skipped during scenarios). | `ScenarioManager.resolve()` respawns if dead before saving. |
| 7 | FIXED | Cosmetic | HUD toast cap used immediate `free()` on a node with a live tween → possible "freed instance" warning. | Use `remove_child` + `queue_free()`. |

All found bugs fixed. Regression tests added for #2–#5 (72/72 pass). No known open bugs.
