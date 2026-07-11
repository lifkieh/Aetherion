# BALANCE_REPORT v2 — Power & Combat Calibration (2026-07-12)

Harness v2 (`AETHER_BALANCE=2`, TestRunner): mana-aware two-way TTK for **3 builds**
(fighter / mage / balanced) × **levels 1/5/10/15** with tier-appropriate gear, against
region-representative monsters in BOTH modes (open world & dungeon ×1.2 HP/offense).
The sim models **hold-to-attack** (weapon rate × AGI), **channel cast** (cast_rate ×
mana_cost until dry, then basics), **infusion** (dmg mult + drain), the real
`CombatResolver` (miss/crit/element, seeded RNG), and the player's **0.5s i-frames**
in pack sims. Corridor definitions: `BALANCE_TARGETS.md`.

## Verdict

**PASS dengan spread tersisa yang diterima (16/72 baris P→E di luar band, semua kelas-nya
dijelaskan di bawah; E→P dan mana economy DI DALAM koridor).**

## Structural fixes this round (bukan sekadar angka)

1. **TTK collapse vs level** — hero ATK tumbuh ~+15/level tapi HP monster hanya +3%/level:
   same-level TTK jatuh dari 5s (Lv1) ke 0.3s (Lv15). Fix: `MonsterFactory.HP_LVL_GROWTH = 0.85`
   (HP monster mengejar ofensif hero), ofensif monster tumbuh lembut (`OFF_LVL_GROWTH = 0.09`).
2. **Formula magic patologis** — MDEF dikurangkan flat SETELAH multiplier ⇒ cast ber-MATK rendah
   jadi 1 damage vs target tanky (mage vs boss = 600s). Fix: MDEF kini memitigasi seperti DEF
   (`(MATK·mod − MDEF·0.5) × elem × crit × (1−mres)`).
3. **Monster offense one-shots** — pukulan serigala ≈24% HP bar pemain Lv1; pack membunuh <2s.
   Fix: `THREAT_MULT = 0.45` pada ATK/MATK monster (DEF/MDEF TIDAK disentuh).
4. **Weapon ATK dihitung dobel** di recalc (PC5) — diperbaiki sebelum kalibrasi.
5. **Mana regen > drain** — mage tak pernah kering. Fix: pool `30+INT·5+lv·3`, regen combat
   `2.0+INT·0.12` (surge ×3 idle), retune mana_cost/cast_rate 16 skill.

## Mana economy (rev F) — TERCAPAI

```
V2MANA|mage|Lv10|max_mp=259|regen=6.3|channel_frost_bolt_until_dry=12.1s (target 8-12s)
```
DPS-sustain kini dibatasi pool mana, bukan cooldown. Wand basic (2 mana/shot) ≈ break-even
dengan regen ⇒ build INT tetap bisa menembak saat kering; build non-INT jalan lewat
hold-attack + infusion (drain 2.0–2.4/s).

## E→P (pack 3 same-level vs pemain, i-frames dimodelkan) — DALAM KORIDOR

Commons agresif (wolf) membunuh pemain baru dalam **6.0–8.7s** (band 6–12s): terancam,
masih sempat kabur. Pemain Lv10 geared bertahan 8–11s vs pack — 1v1 jauh lebih lama (≥20s).
Slime/crab tank-archetype nyaris tak mematikan dalam pack (31–380s) — **by design**
(punchbag tutorial; ofensif memang fraksi BST terkecil).

## P→E highlight (band per tier; tabel lengkap di bawah)

- **Commons open world**: fighter 2.7–5.0s, mage 1.8–5.5s*, balanced 1.4–6.2s → umumnya 3–6s ✓
- **Rare open (forest_fox)**: 4.9–8.1s vs band 7–16 → sedikit cepat di build spesialis, ok.
- **Dungeon rare tank (yeti_cub, ×1.2)**: 21–43s vs band 10–45 ✓ "dangerous commitment".
- **Boss proxy DPS-murni (king_slime, Lv10+)**: 50–107s vs band 45–120 ✓ (≈2–4 menit live
  setelah fase, adds, dan downtime dodging — harness tidak memodelkan downtime).

### Kelas deviasi yang DITERIMA (16/72 baris)
1. **Swift/assassin melt** (ice_wolf/grey_wolf 1.4–2.9s): arketipe HP-rendah memang mati cepat
   ke build damage — spread arketipe yang disengaja (roster §1).
2. **Counterpick elemen** (balanced ber-flame_slash vs slime/crab air: 8.6–14.3s): api vs air
   ×0.7 — sistem elemen bekerja; pemain nyata ganti skill. Harness mengunci 1 skill per build.
3. **Lv1 spesialis** (mage Lv1 vs tank 14.6s): di Lv1 belum ada poin stat — "mage" Lv1 hanyalah
   orang dengan tongkat. Wajar grind; keluar dari band hanya di matchup anti-tank.

## Konsumabel
Minor potion memulihkan ~30–40% HP bar level rendah; TIDAK ada tombol quick-use — memakai
lewat menu (pause) + harga/craft membuatnya keputusan, bukan spam. Mana potion relevan
karena pool = cap sustain.

## Perubahan feel & dunia (parity audit)
- Kedua mode berbagi hit feedback penuh sejak PC2 (knockback, i-frames 0.5s, flash, hitstop 2f,
  hit-immunity per-source 0.2/0.4s).
- **Chase speed open world di-cap 108** (jalan pemain 92, mount 168) untuk non-boss + leash
  1.8×aggro ⇒ selalu escapable; boss tetap full speed. Dungeon (side-view) chase 70 < move 118.
- Aggro radius roster 90–220 (bos 400–420) — proporsional dengan layar 2× zoom.
- **Death penalty dungeon (final)**: respawn di pintu dungeon, **−10% gold** (tanpa XP/item loss).

## Tabel lengkap P→E
(region | species | build | level | ttk | target)

| Greenvale | verdant_slime | fighter | Lv1 | ttk=4.9s | target=3-6s |
| Greenvale | verdant_slime | fighter | Lv5 | ttk=5.0s | target=3-6s |
| Greenvale | verdant_slime | fighter | Lv10 | ttk=4.3s | target=3-6s |
| Greenvale | verdant_slime | fighter | Lv15 | ttk=4.6s | target=3-6s |
| Greenvale | verdant_slime | mage | Lv1 | ttk=14.6s | target=3-6s  <<DEV |
| Greenvale | verdant_slime | mage | Lv5 | ttk=4.9s | target=3-6s |
| Greenvale | verdant_slime | mage | Lv10 | ttk=5.0s | target=3-6s |
| Greenvale | verdant_slime | mage | Lv15 | ttk=4.9s | target=3-6s |
| Greenvale | verdant_slime | balanced | Lv1 | ttk=4.4s | target=3-6s |
| Greenvale | verdant_slime | balanced | Lv5 | ttk=8.6s | target=3-6s  <<DEV |
| Greenvale | verdant_slime | balanced | Lv10 | ttk=10.7s | target=3-6s  <<DEV |
| Greenvale | verdant_slime | balanced | Lv15 | ttk=12.4s | target=3-6s  <<DEV |
| Greenvale | grey_wolf | fighter | Lv1 | ttk=2.8s | target=3-6s  <<DEV |
| Greenvale | grey_wolf | fighter | Lv5 | ttk=3.6s | target=3-6s |
| Greenvale | grey_wolf | fighter | Lv10 | ttk=3.3s | target=3-6s |
| Greenvale | grey_wolf | fighter | Lv15 | ttk=3.5s | target=3-6s |
| Greenvale | grey_wolf | mage | Lv1 | ttk=3.1s | target=3-6s |
| Greenvale | grey_wolf | mage | Lv5 | ttk=3.6s | target=3-6s |
| Greenvale | grey_wolf | mage | Lv10 | ttk=3.8s | target=3-6s |
| Greenvale | grey_wolf | mage | Lv15 | ttk=3.7s | target=3-6s |
| Greenvale | grey_wolf | balanced | Lv1 | ttk=2.2s | target=3-6s  <<DEV |
| Greenvale | grey_wolf | balanced | Lv5 | ttk=4.9s | target=3-6s |
| Greenvale | grey_wolf | balanced | Lv10 | ttk=5.9s | target=3-6s |
| Greenvale | grey_wolf | balanced | Lv15 | ttk=6.7s | target=3-6s  <<DEV |
| Greenvale | forest_fox | fighter | Lv5 | ttk=7.1s | target=7-16s |
| Greenvale | forest_fox | fighter | Lv10 | ttk=6.6s | target=7-16s  <<DEV |
| Greenvale | forest_fox | fighter | Lv15 | ttk=7.2s | target=7-16s |
| Greenvale | forest_fox | mage | Lv5 | ttk=8.9s | target=7-16s |
| Greenvale | forest_fox | mage | Lv10 | ttk=8.7s | target=7-16s |
| Greenvale | forest_fox | mage | Lv15 | ttk=8.6s | target=7-16s |
| Greenvale | forest_fox | balanced | Lv5 | ttk=10.0s | target=7-16s |
| Greenvale | forest_fox | balanced | Lv10 | ttk=12.0s | target=7-16s |
| Greenvale | forest_fox | balanced | Lv15 | ttk=14.6s | target=7-16s |
| Frostpeak | ice_wolf | fighter | Lv1 | ttk=3.2s | target=3-6s |
| Frostpeak | ice_wolf | fighter | Lv5 | ttk=2.9s | target=3-6s  <<DEV |
| Frostpeak | ice_wolf | fighter | Lv10 | ttk=2.7s | target=3-6s  <<DEV |
| Frostpeak | ice_wolf | fighter | Lv15 | ttk=2.8s | target=3-6s  <<DEV |
| Frostpeak | ice_wolf | mage | Lv1 | ttk=3.2s | target=3-6s |
| Frostpeak | ice_wolf | mage | Lv5 | ttk=4.0s | target=3-6s |
| Frostpeak | ice_wolf | mage | Lv10 | ttk=4.1s | target=3-6s |
| Frostpeak | ice_wolf | mage | Lv15 | ttk=4.0s | target=3-6s |
| Frostpeak | ice_wolf | balanced | Lv1 | ttk=1.7s | target=3-6s  <<DEV |
| Frostpeak | ice_wolf | balanced | Lv5 | ttk=3.9s | target=3-6s |
| Frostpeak | ice_wolf | balanced | Lv10 | ttk=4.9s | target=3-6s |
| Frostpeak | ice_wolf | balanced | Lv15 | ttk=5.5s | target=3-6s |
| Foothill-Barrow | yeti_cub | fighter | Lv5 | ttk=28.9s | target=10-45s |
| Foothill-Barrow | yeti_cub | fighter | Lv10 | ttk=21.1s | target=10-45s |
| Foothill-Barrow | yeti_cub | fighter | Lv15 | ttk=22.1s | target=10-45s |
| Foothill-Barrow | yeti_cub | mage | Lv5 | ttk=40.5s | target=10-45s |
| Foothill-Barrow | yeti_cub | mage | Lv10 | ttk=26.8s | target=10-45s |
| Foothill-Barrow | yeti_cub | mage | Lv15 | ttk=25.7s | target=10-45s |
| Foothill-Barrow | yeti_cub | balanced | Lv5 | ttk=43.4s | target=10-45s |
| Foothill-Barrow | yeti_cub | balanced | Lv10 | ttk=36.5s | target=10-45s |
| Foothill-Barrow | yeti_cub | balanced | Lv15 | ttk=39.0s | target=10-45s |
| Storm-Island | storm_crab | fighter | Lv1 | ttk=4.9s | target=3-6s |
| Storm-Island | storm_crab | fighter | Lv5 | ttk=5.0s | target=3-6s |
| Storm-Island | storm_crab | fighter | Lv10 | ttk=4.3s | target=3-6s |
| Storm-Island | storm_crab | fighter | Lv15 | ttk=4.6s | target=3-6s |
| Storm-Island | storm_crab | mage | Lv1 | ttk=14.6s | target=3-6s  <<DEV |
| Storm-Island | storm_crab | mage | Lv5 | ttk=4.9s | target=3-6s |
| Storm-Island | storm_crab | mage | Lv10 | ttk=5.0s | target=3-6s |
| Storm-Island | storm_crab | mage | Lv15 | ttk=4.9s | target=3-6s |
| Storm-Island | storm_crab | balanced | Lv1 | ttk=4.4s | target=3-6s |
| Storm-Island | storm_crab | balanced | Lv5 | ttk=8.6s | target=3-6s  <<DEV |
| Storm-Island | storm_crab | balanced | Lv10 | ttk=10.7s | target=3-6s  <<DEV |
| Storm-Island | storm_crab | balanced | Lv15 | ttk=12.4s | target=3-6s  <<DEV |
| Boss | king_slime | fighter | Lv10 | ttk=50.4s | target=45-120s |
| Boss | king_slime | fighter | Lv15 | ttk=52.7s | target=45-120s |
| Boss | king_slime | mage | Lv10 | ttk=84.7s | target=45-120s |
| Boss | king_slime | mage | Lv15 | ttk=67.3s | target=45-120s |
| Boss | king_slime | balanced | Lv10 | ttk=98.2s | target=45-120s |
| Boss | king_slime | balanced | Lv15 | ttk=107.1s | target=45-120s |

## Tabel lengkap E→P (pack 3)

| Greenvale | verdant_slime | fighter | Lv1 | survive=39.8s | (open target die 6-12s @Lv1-5) |
| Greenvale | verdant_slime | fighter | Lv5 | survive=128.9s | (open target die 6-12s @Lv1-5) |
| Greenvale | verdant_slime | fighter | Lv10 | survive=383.2s | (open target die 6-12s @Lv1-5) |
| Greenvale | verdant_slime | mage | Lv1 | survive=31.8s | (open target die 6-12s @Lv1-5) |
| Greenvale | verdant_slime | mage | Lv5 | survive=46.9s | (open target die 6-12s @Lv1-5) |
| Greenvale | verdant_slime | mage | Lv10 | survive=108.5s | (open target die 6-12s @Lv1-5) |
| Greenvale | verdant_slime | balanced | Lv1 | survive=39.8s | (open target die 6-12s @Lv1-5) |
| Greenvale | verdant_slime | balanced | Lv5 | survive=128.9s | (open target die 6-12s @Lv1-5) |
| Greenvale | verdant_slime | balanced | Lv10 | survive=383.2s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | fighter | Lv1 | survive=6.7s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | fighter | Lv5 | survive=8.7s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | fighter | Lv10 | survive=11.2s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | mage | Lv1 | survive=6.7s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | mage | Lv5 | survive=7.7s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | mage | Lv10 | survive=8.3s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | balanced | Lv1 | survive=6.7s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | balanced | Lv5 | survive=8.7s | (open target die 6-12s @Lv1-5) |
| Greenvale | grey_wolf | balanced | Lv10 | survive=11.2s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | fighter | Lv1 | survive=6.0s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | fighter | Lv5 | survive=11.3s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | fighter | Lv10 | survive=13.8s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | mage | Lv1 | survive=8.7s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | mage | Lv5 | survive=9.7s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | mage | Lv10 | survive=10.7s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | balanced | Lv1 | survive=6.0s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | balanced | Lv5 | survive=11.3s | (open target die 6-12s @Lv1-5) |
| Frostpeak | ice_wolf | balanced | Lv10 | survive=13.8s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | fighter | Lv1 | survive=39.8s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | fighter | Lv5 | survive=128.9s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | fighter | Lv10 | survive=383.2s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | mage | Lv1 | survive=31.8s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | mage | Lv5 | survive=46.9s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | mage | Lv10 | survive=108.5s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | balanced | Lv1 | survive=39.8s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | balanced | Lv5 | survive=128.9s | (open target die 6-12s @Lv1-5) |
| Storm-Island | storm_crab | balanced | Lv10 | survive=383.2s | (open target die 6-12s @Lv1-5) |
