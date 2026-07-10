# ASSET_LOG — Aetherion

One row per source pack. `assets_raw/` is never edited. Used assets are copied
(normalized, Nearest filter) into `game/assets/game/`. See `ASSET_CATALOG.md`
for exact per-file picks and layouts.

| Pack | Author / Source | License | Attribution req. | Used for | Status |
|---|---|---|---|---|---|
| Ninja Adventure - Asset Pack | Pixel-boy / Aleksandr Makarov (itch.io) | CC0 1.0 | No | Player (NinjaGreen), monsters (Slime/Mouse/Beast), tilesets (Field/Nature), props, UI wood theme, SFX jingles, music | In use |
| Kenney Fantasy UI Borders | Kenney (kenney.nl) | CC0 | No (appreciated) | UI 9-slice panels/borders (M8 UI) | Reserved |
| 80 CC0 RPG SFX | OpenGameArt collection | CC0 (per folder; verify src pre-release) | No | Combat/UI SFX (blade, coin, slime, hit, mine) | In use |
| Pixel Crawler - Free Pack 2.11 | Anokolisa (itch.io) | Custom — usable in-game, NOT redistributable, NOT CC0 | No | Fallback only; not shipped as raw art | Fallback |
| m5x7 font | Daniel Linssen (managore) | Free, embedding OK | Credit appreciated | HUD/UI pixel font | In use |
| Aetherion Original Assets v1 | Project-owned (this project) | Proprietary (ours) | — | 17 element icons, 8 moon phases, 12 constellations, Fluffbit/Moonbit, Candyveil tiles, fire_flow VFX, Star Whale, palette | In use |
| Aetherion Asset Generators | Project-owned | Proprietary (ours) | — | Python/Pillow procedural generators (icons, sky, world, palette) | Tooling |

## Notes
- `aetherion_palette_v1.png` is the canonical 53-colour palette; procedural assets follow it.
- Root archive `eyJleHBpcmVz...==.6lkCYto...` is an **expired itch.io download** (HTML error page, not an asset) — see BLOCKED.md.
- `.rar` VFX packs (Dark VFX 01-02, Smear VFX 01) not yet extracted (no rar tool) — see BLOCKED.md.
- CREDITS.md is generated from this log before any release.
