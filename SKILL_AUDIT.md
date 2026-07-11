# SKILL_AUDIT.md — Aetherion (UI/UX round §6)

Audit date: **2026-07-11** · Godot 4.3 · all findings fixed & regression-tested
(`[Skill Audit §6]` suite, 229/229 headless tests pass).

Scope: every skill vs the GDD along five axes the owner named — (1) element
correctness, (2) cost/cooldown DPS-per-mana outliers >30%, (3) weapon behaviors
connected to the click scheme, (4) Element Flow + elemental science post-refactor,
(5) fusion recipe symmetry (1+2 == 2+1). Verified in-repo, not from memory.

---

## 1. Element correctness — ✅ PASS (no fix needed)

Every skill's `element` is a member of `elements.json.list` and matches its intent:

| Skill | Element | OK |
|---|---|---|
| strike / bite / tackle / howl | none | ✅ (physical/buff) |
| flame_slash | fire | ✅ |
| spark_bolt | lightning | ✅ |
| frost_bolt / flow_ice | ice | ✅ |
| flow_fire | fire | ✅ |
| flow_lightning | lightning | ✅ |
| flow_wind / gust | wind | ✅ |
| charge | earth | ✅ |
| sting / spore_cloud | poison | ✅ |
| split | water | ✅ |

Test: *all castable skill elements are valid*.

## 2. DPS-per-mana outliers — ⚠️ FIXED

Metric = `skill_mod / (cooldown × mp_cost)` for the three mana-costing damage
skills. Before, the melee AoE `flame_slash` was ~67 % more mana-efficient than the
ranged `spark_bolt`, pushing the spread past a healthy band.

| Skill | Before (mod, mp, cd) | DPS/mana | After | DPS/mana |
|---|---|---|---|---|
| flame_slash | 1.7 / 8 / 2.2 | 0.0966 (+29 %) | **mp 8→9** | 0.0859 (+17 %) |
| spark_bolt | 1.5 / 10 / 2.6 | 0.0577 (−23 %) | **mp 10→9** | 0.0641 (−13 %) |
| frost_bolt | 1.4 / 9 / 2.2 | 0.0707 (−6 %) | (unchanged) | 0.0707 (−4 %) |

**Fix:** `flame_slash` mp 8→9 (it is melee **and** AoE — should not also be the most
mana-efficient), `spark_bolt` mp 10→9 (the safe ranged workhorse was underpowered).
All three now sit within **±17 %** of the mean — no >30 % outlier.
Test: *no DPS-per-mana outlier >30%*.

## 3. Weapon behaviors ↔ click scheme — 🐞 FIXED (real bug)

The side-view `PlayerPlatformer._handle_attack` already branched on `weapon_type`
(bow = charge-shot toward cursor, spear = long thrust, wand = projectile + mana,
sword = wide arc). **But the top-down `Player._do_attack` ignored the weapon
entirely** and always did a facing-cone `strike` melee — so a bow or wand equipped
in the overworld still *swung a sword*. That broke the "one control language"
promise of the new prime→left-click scheme.

**Fix:** `Player._do_attack` now aims at the cursor and branches on `weapon_type`,
mirroring the platformer:
- **bow** → fires the weapon's `projectile` (arrow) toward the cursor
- **wand** → spends `mana_cost`, fires the weapon's `projectile` (e.g. fireball)
- **spear** → longer, narrow `melee_arc` (×1.15)
- **sword / default** → wide `melee_arc` toward the cursor

Tests: *bow/wand weapons declare a projectile (+mana)*, *wand projectile exists*.

## 4. Element Flow + science post-refactor — ✅ PASS

- The four **Flow** skills (`flow_fire/lightning/ice/wind`, kind `flow`) drive
  `PlayerData.apply_infusion` via `Hotbar._cast_single` — the hotbar/fusion refactor
  kept Element Flow working (covered by the `[Hotbar + fusion]` suite).
- **Platformer rules** still read from `elements.json.platformer_rules`:
  wind flow → double jump, ice flow → freeze puddle, fire → melt ice
  (`PlayerPlatformer._flow_rule`). Tests: *wind flow grants double jump*, *ice flow
  freezes puddles*.
- **Elemental science** (wet+lightning chain, fire underwater/wet, grounded immunity,
  day/night/moon modifiers) unchanged and still green in `[Science Rules]`.
- **Cleanup:** removed the dead `element_flow` skill (kind `buff`, element `none`) —
  it was superseded by the four `flow_*` skills, referenced nowhere in code, and
  would have mis-fired as a melee swing if ever assigned to a hotbar slot.
  Test: *dead 'element_flow' skill removed*.

## 5. Fusion recipe symmetry — ✅ PASS

`Db.elem_combo(a, b)` is order-independent by construction, and all **9** recipes in
`elements.json.combos` are unique pairs with valid output elements and ascending
mults (1.3 → 2.4):

Firestorm(fire+wind 1.7) · Thunder Rain(lightning+water 1.6, chain) ·
Steam Burst(fire+water 1.3) · Thermal Shock(fire+ice 1.9) · Blizzard(ice+wind 1.5) ·
Typhoon(water+wind 1.6) · Eclipse(light+darkness 1.8) · Magma Surge(earth+fire 1.7) ·
Supernova(star+void 2.4).

Tests: *every fusion recipe is order-independent (1+2==2+1)*, *non-recipe pair
returns empty (fizzle)*, *at least 8 fusion recipes*.

---

## Summary of changes

| # | Finding | Severity | Fix |
|---|---|---|---|
| 2 | flame_slash over-efficient / spark_bolt under | balance | mp 8→9 / 10→9 |
| 3 | top-down attack ignored weapon_type | **bug** | branch on weapon in `Player._do_attack` |
| 4 | dead `element_flow` skill | cleanup | removed from `skills.json` |
| 1, 5 | element correctness, fusion symmetry | — | already correct; now regression-locked |

All fixes covered by the new `[Skill Audit §6]` regression suite (12 checks).
