# BALANCE_TARGETS — Aetherion Combat Corridor

Owner "Power & Combat Calibration" round. These are the numbers the harness v2
(`AETHER_BALANCE=2`) tunes to. Written **before** tuning; see `BALANCE_REPORT_v2.md`
for the measured result and any accepted deviations.

Two-way TTK: the harness measures **both** directions —
`P→E` (player kills one same-level enemy) and `E→P` (a pack kills the player).

## 1. Player → Enemy (offense)

| Context | Same-level single-enemy TTK | Notes |
|---|---|---|
| **Open world** | **3–6 s** | "manageable / escapable" pace. |
| **Dungeon** | **+15–25% tankier** → ~3.5–7.5 s | "dangerous commitment". |
| **Rare enemy** | ~2–3× common | mini-threat. |
| **Boss** | **2–4 minutes** live (**45–120 s** pure-DPS harness proxy — no dodging downtime in the sim) | a *test*: 2–4 reasonable deaths to learn patterns. |

All three archetypes (fighter / mage / balanced) must land inside the corridor at
levels 1 / 5 / 10 / 15 with reasonable gear for that level. Archetype spread is
allowed (glass-cannon mage faster, tank fighter slower) but not outside the band.

## 2. Enemy → Player (defense / threat)

| Context | Target | Notes |
|---|---|---|
| **Open world, new player vs 3+ same-level** | player **dies within ~6–12 s** if they stand and fight | must feel threatened, fleeing is the intended answer. |
| **Open world, geared player vs 1 same-level** | survivable for **≥ 20 s** | you can win a fair 1v1. |
| **Dungeon** | **+15–25%** more incoming pressure than open world | shorter survival. |
| **Death penalty (dungeon)** | respawn at dungeon door; **lose 10% gold** (minor; final decision — no durability system yet) | no XP loss, no item loss. |

## 3. Mana economy (rev B/F — the sustain cap)

- A full-INT mage channelling a primed skill continuously runs **out of mana in ~8–12 s**
  at equal level. After that, damage falls back to basic attacks while mana regens.
- Out-of-combat mana regen **surges ×3 after 3 s** of not fighting.
- **Non-INT builds stay viable** via hold-to-attack basics + Element-Flow infusion
  (infusion drains mana slowly, ~2–2.4/s, so even fighters manage a small mana pool).
- DPS-sustain is therefore **capped by the mana pool**, not by cooldowns (there are none
  except the 3–4 element fusion recast).

## 4. Consumables matter

- Potions/food heal a meaningful chunk (minor potion ≈ 25–40% of a low-level HP bar)
  but can't be spammed to trivialise a fight: a short use-cadence + gold/craft cost keeps
  them a *decision*, not a spam button. Mana potions/food are relevant to the sustain cap.

## 5. How the harness models a fight

- **Hold-to-attack**: basic at `weapon_rate × attack_speed` (AGI).
- **Channel**: a primed skill fires at its `cast_rate`, spending `mana_cost` each cast,
  until mana is exhausted → falls back to basics; mana regenerates (base + INT) meanwhile.
- **Element/crit/accuracy** resolved through the real `CombatResolver` (miss + crit rolls,
  seeded RNG, averaged over trials).
- **Per-source hit-immunity** (rev D) is ignored in the 1v1 DPS sim (single attacker at
  weapon cadence never out-paces the 0.2 s window) but bounds the pack sims.
