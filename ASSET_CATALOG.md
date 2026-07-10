# ASSET_CATALOG.md — Pixel-Art Asset Reference

Primary source: **Ninja Adventure** pack (CC0, 16x16 top-down, 4-direction).
Layout convention: character/monster walk sheet = **64x64 = 4 cols x 4 rows of 16x16**,
rows top→bottom = **DOWN / UP / LEFT / RIGHT**, 4 walk frames per row.
Diagonal movement uses nearest 4-dir facing (no true 8-dir art exists in packs).

Base pack path: `D:\2DGAME\assets_raw\Ninja_Adventure\Ninja Adventure - Asset Pack\`

## Player — NinjaGreen
- `Actor\Character\NinjaGreen\SpriteSheet.png` (64x112, 4x7 of 16x16, all anims stacked)
- `Actor\Character\NinjaGreen\SeparateAnim\Walk.png` (64x64, 4x4 walk, rows down/up/left/right)
- `...\SeparateAnim\Attack.png` (64x16, 4 frames = one per direction)
- `...\SeparateAnim\Idle.png` (64x16), `Dead.png` (16x16)
- Alternates same layout: NinjaRed, NinjaBlue, Boy, Knight.

## Monsters (all 64x64, 4x4 grid of 16x16, rows down/up/left/right)
- **Verdant Slime**: `Actor\Monster\Slime\Slime.png` (green). Variants Slime2/3/4.
- **Fluffbit**: `Actor\Monster\Mouse\SpriteSheet.png` (small critter).
- **Grey Wolf**: `Actor\Monster\Beast\Beast.png` (grey predator, 4-dir walk).

## Tilesets (Greenvale) — 16x16 grid
- `Backgrounds\Tilesets\TilesetField.png` (80x240) — grass/dirt ground.
- `Backgrounds\Tilesets\TilesetNature.png` (384x336) — trees, bushes, rocks.

## Props / Pickups (16x16 unless noted)
- `Items\Resource\Grass.png`, `Rock.png`, `Branch.png`
- Coin: `Items\Treasure\Coin2.png` (40x10, 4-frame spin, 10x10/frame)
- Gems: `Items\Treasure\GemGreen/Red/Purple/Yellow.png`

## UI (9-slice)
- Kenney: `D:\2DGAME\assets_raw\kenney_fantasy-ui-borders\PNG\Default\Panel\panel-000.png` (48x48, 32 variants), `Border\panel-border-000.png`.
- Ninja Wood theme: `Ui\Theme\Theme Wood\nine_path_panel.png` (16x16), buttons, `inventory_cell.png`.
- Dialog: `Ui\Dialog\DialogBox.png`.

## SFX — `D:\2DGAME\assets_raw\80-CC0-RPG-SFX\` (.ogg)
- Hit: `blade_01..03.ogg`, `creature_hurt_01..02.ogg`, `metal_01..03.ogg`
- Coin: `item_coins_01..04.ogg`; gems `item_gem_01..04.ogg`
- Slime: `creature_slime_01..04.ogg`; death `creature_die_01.ogg`, `creature_monster_01..04.ogg`
- UI/misc: `misc_01..03.ogg`, `wood_01..05.ogg`, `stones_01..04.ogg`
- Ninja jingles: `Audio\Jingles\LevelUp1..3.wav`, `GameOver1..4.wav`, `Success1..4.wav`, `Secret1..4.wav`
- Ninja music: `Audio\Musics\11 - Clearing.ogg`, `23 - Road.ogg` (forest zone)

## Original Aetherion assets — `assets_raw\aetherion_original_assets_v1\assets_gen\`
- 17 element icons `icons\element_*_32.png`; `icons\fluffbit_32.png`, `frost_fluffbit_32.png`, `moonbit_32.png`
- Moon phases `moon\moon_0_new.png .. moon_7_waning_crescent.png` (8 frames)
- Constellations `constellations\rasi_*_96.png` (12)
- Fire VFX `vfx\fire_flow_strip_32x32x8.png` (8-frame strip) + `fire_flow_f0..f7.png`
- Candyveil tileset `candyveil\candyveil_tilesheet_16.png`
- `star_whale_128x80.png`, `aetherion_palette_v1.png`
- Generators: `assets_raw\aetherion_asset_generators\asset_generators\*.py`

## Licenses
- Ninja Adventure: **CC0** (`LICENSE.txt`) — commercial OK, no attribution.
- Kenney Fantasy UI Borders: **CC0** — credit appreciated not required.
- 80-CC0-RPG-SFX: **CC0** (per folder name; no license file shipped — verify source before release).
- Pixel Crawler Free: **Custom (Anokolisa)** — usable in-game, NOT redistributable as art; not CC0. Fallback only.
- Aetherion original assets: **project-owned (original)**.
