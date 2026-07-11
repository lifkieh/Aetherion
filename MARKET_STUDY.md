# MARKET STUDY (ATM: Amati, Tiru, Modifikasi) — Aetherion

Riset game sejenis untuk memilih fitur retention high-impact / low-cost yang cocok
dengan pilar Aetherion (langit/cuaca/waktu WIB nyata, sains-fantasi, sandbox).

## 1. Amati — kenapa mereka laku & mekanik retensi

| Game | Kenapa laku | Mekanik retensi kunci |
|---|---|---|
| **Stardew Valley** | Loop harian tenang + ikatan NPC + koleksi tak habis | Siklus hari/musim, **birthday & festival kalender**, **Community Center bundles** (koleksi), quest board harian, museum donation |
| **Terraria** | Progresi bos + eksplorasi + crafting dalam | Tier gear, event dunia (Blood Moon!), bestiary, boss-summon |
| **Palworld** | "Pokémon + survival + gun" + pal otomasi | Pal breeding/kerja, base automation, catch-collect dopamine |
| **Moonlighter** | Loop dungeon-siang / jual-malam | **Ekonomi supply-demand** (harga reaktif), notebook harga, run harian |
| **Forager** | Dopamine "satu klik lagi" | Skill tree, koleksi, quest kecil beruntun, unlock cepat |
| **Core Keeper** | Co-op mining + boss + farming | Bestiary, achievement, seasonal event, automasi |
| **Graveyard Keeper** | Sim manajemen gelap + banyak profesi | Rantai crafting dalam, tech tree, quest NPC bergaya |

## 2. Pola berulang (yang terbukti menahan pemain)
1. **Alasan login harian** (quest/festival/harga berubah) — Stardew, Moonlighter.
2. **Koleksi tak pernah selesai** (museum, bestiary, bundles) — Stardew, Terraria, Core Keeper.
3. **Prestise ringan** (title, achievement) tanpa merusak balance.
4. **Event dunia bertanda kalender** (Blood Moon, festival) — sudah jadi DNA Aetherion (langit WIB!).
5. **Ekonomi reaktif** — sudah ada (Economy supply-demand ala Moonlighter).

## 3. Tiru + Modifikasi (twist khas Aetherion = kaitkan ke langit/cuaca/WIB)

Terpilih 5 fitur high-impact/low-cost (memakai EventBus & counter yang SUDAH ada):

| Fitur | Tiru dari | Modifikasi Aetherion | Biaya |
|---|---|---|---|
| **A. Daily Quest Board** | Stardew/Forager | Quest di-*roll* dari **hari + cuaca + fase bulan WIB**: "Saat hujan, kalahkan 5 musuh basah"; reset tiap hari WIB | Rendah (data + 1 papan + UI) |
| **B. Achievement + Title (micro-buff netral)** | Core Keeper + GDD v0.2 §10.3 | Title dari counter yang sudah dilacak diam-diam (Penebang, Pemburu, "Berlumur Dosa" saat rabbits_killed tinggi → foreshadow Warren) | Rendah (hook EventBus) |
| **C. Aetherpedia (bestiary/koleksi)** | Terraria bestiary + Stardew museum | Auto-catat monster/item/cuaca yang ditemui; entri lengkap beri reward kecil; sinkron dengan sains elemen | Sedang |
| **D. Photo Mode** | Palworld/Stardew | Sembunyikan HUD + free-cam + frame; bagus untuk langit/purnama/Candyveil pastel → marketing organik | Rendah |
| **E. Fishing minigame** | Stardew | Ikan berbeda per **jam WIB & pasang-surut bulan**; umpan Star Bait → hook Hidden Scenario paus | Sedang |

## 4. Status implementasi
- ✅ **B Achievements + Titles** (micro-buff netral) — implemented (Sesi 1).
- ✅ **C Aetherpedia** — implemented (Sesi 1, menu "Pedia").
- ✅ **A Daily Quest Board** — implemented (Sesi 2, menu "Quest" + papan; roll dari tanggal WIB,
  varian ber-gate cuaca/purnama).
- ✅ **D Photo Mode** — implemented (Sesi 2, [P] toggle, foto bersih ke user://photos/).
- ⏳ **E Fishing minigame** — belum; butuh scene minigame + data ikan (per jam WIB & pasang bulan) +
  Star Bait → Hidden Scenario Star Whale. Prioritas berikutnya.

Semua tetap: data-driven, UI-free logic di systems/, verifikasi headless + test, commit per fitur.
