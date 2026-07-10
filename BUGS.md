# BUGS — Aetherion

Tracked defects. Status: OPEN / FIXED. Newest first.

| # | Status | Severity | Description | Fix |
|---|---|---|---|---|
| 1 | FIXED | High (visual) | **All monsters rendered the slime fallback sprite.** `Monster._ready()` (fires on `add_child`) built the sprite from an empty `inst`, because `setup(inst)` is called *after* `add_child`. Same for `Pet`. | Build sprite in `setup()` when already in-tree; `_ready()` only builds if data present. Sprites now correct project-wide. (Session 1) |

No known open bugs.
