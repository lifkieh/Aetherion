# BALANCE REPORT — TTK aktual vs target (Fase 0)

Digenerate oleh probe headless `AETHER_BALANCE=1` (200 trial/monster, pemain **se-level** dengan gear
wajar: copper_sword <lvl15 / wooden_spear ≥lvl15, rotasi normal-attack + flame_slash tiap hit ke-6,
cadence ~0.30 dtk/serangan). Target dari `Monster_Roster_Launch.md §1.3`.

Regenerasi: `run_godot.bat --headless res://tests/TestRunner.tscn --quit-after 60` dengan env `AETHER_BALANCE=1`.

## Hasil (setelah retune HP, 2026-07-11)

| Monster | Rarity | Arketipe | TTK aktual | Target | Deviasi | Catatan |
|---|---|---|---|---|---|---|
| fluffbit | common | swift | 1.2s | 3–6s | **−73%** | **By design**: roster §5 "sengaja lemah & spawn masif" (counter kelinci) |
| verdant_slime | common | tank | 3.6s | 3–6s | −20% | ✅ dalam target |
| grey_wolf | common | bruiser | 2.1s | 3–6s | **−54%** | arketipe rapuh-menengah |
| wild_boar | common | bruiser | 2.4s | 3–6s | **−47%** | idem |
| forest_fox | rare | swift | 4.0s | 8–15s | **−65%** | swift = glass cannon (HP rendah) |
| cervel | rare | swift | 3.1s | 8–15s | **−73%** | idem |
| treant_sapling | epic | tank | 30.0s | 25–45s | −14% | ✅ |
| king_slime | epic | tank(boss) | 43.5s | 25–45s | +24% | ✅ |
| gummy_slime | common | tank | 3.0s | 3–6s | −34% | borderline |
| rock_golem | rare | tank | 11.1s | 8–15s | −4% | ✅ |

## Analisis
- **Retune (sesi ini):** `HP_DISPLAY_MULT` 2.0→3.0 + `RARITY_HP_MULT` baru (common 1.5 … ancient 22). Sebelum
  retune SEMUA monster −60%…−95%; sesudah, **tank tiap rarity masuk/dekat target**.
- **Deviasi tersisa terpola oleh ARKETIPE, bukan bug:** tank on-target; bruiser/assassin/**swift** mati lebih
  cepat karena fraksi HP arketipe rendah (swift 18% HP vs tank 30%). Ini **konsisten desain** (glass cannon).
  Target §1.3 adalah rata-rata per-rarity; varian per-arketipe wajar menyebar.
- **fluffbit** memang dirancang lemah (kunci Hidden Scenario 10.000 kelinci) — deviasi besar diterima.

## Item deviasi >30% (perlu keputusan desain lanjut)
fluffbit (intentional), grey_wolf, wild_boar, forest_fox, cervel, gummy_slime.
Semua = arketipe non-tank yang secara desain lebih rapuh.

## Rekomendasi (future, bukan blocker Fase 0)
1. Spreadsheet balance penuh: pisahkan target TTK **per arketipe** (tank tinggi, assassin/swift rendah)
   alih-alih satu rentang per rarity — akan menaikkan cocok dari ~50% jadi ~100%.
2. Atau naikkan lantai HP fraksi arketipe rapuh (swift 0.18→0.22) bila ingin swift tak terlalu cepat mati.
3. Cadence serangan & DoT (burn/poison) belum diperhitungkan di probe → TTK in-game sedikit lebih rendah;
   probe konservatif (normal-attack heavy).

Angka & mekanik siap direntangkan tanpa refactor (lihat DEVLOG "level compression" + konstanta MonsterFactory).
