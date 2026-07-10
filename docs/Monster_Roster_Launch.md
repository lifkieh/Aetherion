# AETHERION — MONSTER ROSTER LAUNCH (v1.0)
Target launch: **64 spesies** + 8 boss + 6 secret. Balancing berbasis arketipe (metode standar industri) agar 64 monster bisa dibalance oleh 1 designer.

---

# 1. KERANGKA BALANCING

## 1.1 Base Stat Total (BST) per rarity
Semua stat monster diturunkan dari BST — satu angka yang mudah dikontrol:

| Rarity | BST (lvl 1) | Growth per level | Catatan |
|---|---|---|---|
| Common | 300 | +3,0% dari base | Fodder & tame awal |
| Rare | 360 | +3,2% | Elite lapangan |
| Epic | 440 | +3,4% | Mini-boss / tame bagus |
| Legendary | 540 | +3,6% | Spawn khusus |
| Mythic | 660 | +3,8% | Sangat langka |
| Ancient | 800 | +4,0% | Event/kondisi |

**Rank bintang (kualitas individu, acak saat spawn):** 1★ −6%, 2★ −3%, 3★ baseline, 4★ +3%, 5★ +6% dari BST. Distribusi: 15/25/35/20/5%.

## 1.2 Arketipe (distribusi BST ke 6 stat: HP/ATK/DEF/MATK/MDEF/SPD)
| Arketipe | HP | ATK | DEF | MATK | MDEF | SPD | Identitas |
|---|---|---|---|---|---|---|---|
| Tank | 30% | 12% | 25% | 5% | 20% | 8% | Lambat, dinding |
| Bruiser | 25% | 25% | 18% | 4% | 13% | 15% | Serba bisa fisik |
| Assassin | 15% | 30% | 8% | 5% | 10% | 32% | Cepat, rapuh |
| Caster | 17% | 5% | 10% | 32% | 20% | 16% | Nuker elemen |
| Support | 24% | 8% | 15% | 20% | 23% | 10% | Buff/heal/debuff |
| Swift (racing/scout) | 18% | 15% | 10% | 8% | 11% | 38% | Kandidat mount/racing |

Contoh perhitungan: Wolf (Common, Bruiser, lvl 1, 3★) → HP 75, ATK 75, DEF 54, MATK 12, MDEF 39, SPD 45 (HP dikali 4 untuk nilai tampil: 300 HP).

## 1.3 Target Time-to-Kill (pemain se-level, gear tier wajar)
| Musuh | TTK solo | Catatan |
|---|---|---|
| Common | 3–6 dtk | Ritme farming |
| Rare | 8–15 dtk | Butuh skill rotation |
| Epic (elite) | 25–45 dtk | Mekanik dodge wajib |
| Legendary lapangan | 60–120 dtk | Persiapan (food/potion) |
| Boss dungeon | 3–6 mnt | Fase & mekanik |
| World boss | 10–20 mnt (banyak pemain) | HP scaling |

## 1.4 Reward & drop template
- EXP = `BST_efektif × 0,2 × modifier rarity (Common 1× … Ancient 12×)`
- Drop: 1 material umum (60–100%), 1 material profesi (25%), 1 material langka (3–8%), material kunci tier A+ hanya dari Epic+ (0,5–2%).
- **Aturan taming vs loot:** monster yang di-tame TIDAK memberi drop & EXP → dua ekonomi tidak saling memakan.

## 1.5 Stat racing (terpisah, hanya spesies Swift/mount)
Speed / Accel / Handling / Stamina masing-masing 1–100, dibagikan dari "Racing BST" = 240 (Common) … 330 (Legendary), + 1 Special Skill.

---

# 2. ROSTER PER WILAYAH

Format: **Nama | Rarity | Elemen | Arketipe | Trait khas | Evolusi | Peran tame**

## 2.1 Greenvale Forest (lvl 1–15) — 10 spesies
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| **Fluffbit** (kelinci) | Common | Wood | Swift | Lucky Foot (drop +2%) | → Moonbit (purnama, lore Moon Rabbit) | Pet ikonik; kunci Hidden Scenario 10.000 kelinci |
| Verdant Slime | Common | Water | Tank | Split (pecah 2 saat mati) | → King Slime (Epic) | Pet pemula, panen jelly |
| Grey Wolf | Common | — | Bruiser | Pack Hunter (+5%/wolf sekutu) | → Dire → Alpha → Bloodfang | Mount darat awal, racing land |
| Wild Boar | Common | Earth | Bruiser | Charge | → Ironhide Boar | Ternak homestead (daging) |
| Honeybuzz | Common | Wind | Assassin | Sting (poison kecil) | → Queen Buzz | Apiari homestead (madu) |
| Sporeling | Common | Poison | Caster | Spore Cloud | → Myconid Sage | Farm jamur |
| Forest Fox | Rare | Wind | Swift | Keen Nose (deteksi herb) | → Ninetail Kit | Pet gathering (buff Herbalist) |
| Cervel (rusa) | Rare | Wood | Swift | Graceful | → Sylvan Stag | Mount, racing land |
| Treant Sapling | Epic | Wood | Tank | Rooted (regen diam) | → Elder Treant | Companion tank |
| Timberwing Owl | Rare | Wind | Caster | Night Sight | → Strix Sage | Pet malam (visi malam +) |

## 2.2 Candyveil Meadows (lvl 18–32) — 8 spesies
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| Gummy Slime | Common | Water | Tank | Sticky (slow saat pukul) | → Gummy Titan | Panen gummy (Cook) |
| Candyfloss Sheep | Common | Sky | Support | Fluffy (wol gula) | → Nimbus Sheep | **Ternak wol gula** homestead |
| Jellybean Bunny | Common | Wood | Swift | Sugar Rush (burst SPD) | — | Racing land ringan |
| Choco Bear | Rare | Earth | Bruiser | Sweet Tooth | → Dark Choco Bear | Companion |
| Lollipop Sprite | Rare | Light | Caster | Sugar Shield | → Peppermint Fairy | Support healer kecil |
| Caramel Golem | Epic | Earth | Tank | Molten Caramel (melambat saat panas) | — | Tank |
| Gummy Mimic | Epic | Darkness | Assassin | Ambush (nyamar jadi chest permen) | — | — (musuh jebakan) |
| Soda Serpent | Rare | Water | Caster | Fizz Burst (AoE) | → Cola Leviathan? (cross-breed rahasia) | Racing air junior |

## 2.3 Desert of Ruins (lvl 12–25) — 7 spesies
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| Sand Scarab | Common | Earth | Tank | Hard Shell | → Khepri Guard | Panen chitin |
| Dune Viper | Common | Poison | Assassin | Venom Fang | → Sidewinder Lord | — |
| Vulture | Common | Wind | Swift | Scavenger (loot +) | — | Pet auto-loot |
| Jackal Shade | Rare | Darkness | Assassin | Night Prowl | → Anubis Warden | Companion |
| Rock Golem | Rare | Earth | Tank | Grounded (imun Lightning — sains: grounding) | → Obsidian Golem | Tank tambang (buff Miner) |
| Dune Serpent | Epic | Earth | Bruiser | Sand Dive | → Desert Wyrm | Mount gurun |
| Cactus Fiend | Rare | Wood | Support | Thorns | — | Farm air/duri |

## 2.4 Frostpeak Mountain (lvl 22–38) — 7 spesies
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| Frost Fox | Common | Ice | Swift | Snow Walker | → Aurora Fox | Pet, racing salju |
| Ice Wolf | Common | Ice | Bruiser | Pack Hunter | → Frost Dire Wolf | Mount |
| Snow Owl | Common | Wind | Caster | Blizzard Sight (visi saat blizzard) | — | Pet navigasi |
| Frost Elemental | Rare | Ice | Caster | Freeze Touch | → Glacier Core | Companion caster |
| Yeti Cub | Rare | Ice | Tank | Thick Fur | → Yeti → Frost Titan | Tank |
| Woolly Calf | Rare | Earth | Tank | Warm Wool | → Mammoth | **Ternak wol premium** + mount |
| Frost Wyvern | Epic | Ice/Wind | Bruiser | Frost Breath | → Blizzard Wyvern | Mount terbang awal |

## 2.5 Storm Island (lvl 40–55) — 7 spesies
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| Volt Weasel | Common | Lightning | Assassin | Static Fur | → Raiju | Pet (charge alat) |
| Storm Crab | Common | Water | Tank | Conductive Shell (kena chain — sains!) | → Tempest Crab | Panen shell |
| Thunder Hawk | Rare | Lightning | Swift | Storm Rider (SPD + saat badai) | → Storm Roc | **Racing udara** inti |
| Cloud Ray | Rare | Sky | Swift | Glide | → Nimbus Ray | Mount layang |
| Volt Eel | Rare | Lightning | Caster | Chain Shock | → Levia-Eel | Racing air |
| Storm Elemental | Epic | Lightning/Wind | Caster | Overcharge | — | Companion nuker |
| **Thunder Dragon** | Legendary | Lightning | Bruiser | Tempest Heart | → Storm Sovereign | SECRET spawn (badai+petir+malam); mount prestise |

## 2.6 Emberfall Volcano (lvl 50–65) — 7 spesies
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| Fire Imp | Common | Fire | Caster | Pyromaniac | → Flame Fiend | Companion |
| Magma Slime | Common | Fire | Tank | Molten Body (melee attacker kena burn) | — | Panen magma jelly |
| Lava Hound | Rare | Fire | Bruiser | Burning Bite | → Cerberus Pup? (breeding rahasia) | Mount tahan lava |
| Salamander | Rare | Fire | Assassin | Heat Skin | → Salamander King | Companion |
| Ash Vulture | Rare | Fire/Wind | Swift | Updraft | — | Racing udara |
| Magma Golem | Epic | Fire/Earth | Tank | Eruption Slam | → Volcanic Colossus | Tank raid |
| **Ember Phoenix Chick** | Mythic | Fire/Light | Support | Rebirth (revive diri 1×) | → Phoenix (quest Sun) | Fusion Phoenix; jalur elemen Sun |

## 2.7 Ocean Kingdom (lvl 55–70) — 8 spesies
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| Coral Crab | Common | Water | Tank | Reef Armor | — | Panen coral |
| Moonfin Dolphin | Common | Water | Swift | Tide Sense (buff saat purnama — Moon!) | → Lunar Dolphin | **Racing air** inti |
| Anglerfish | Rare | Darkness | Assassin | Lure (tarik target) | — | — |
| Merrow | Rare | Water/Spirit | Support | Siren Song | → Sea Oracle | Support healer |
| Pearl Mimic | Rare | Water | Assassin | Ambush | — | Panen mutiara (jika ditundukkan) |
| Sea Serpent | Epic | Water | Bruiser | Coil Crush | → Leviathan Spawn | Mount laut |
| **Leviathan Hatchling** | Legendary | Water | Bruiser | Abyssal Blood | → Leviathan (endgame) | Racing air prestise |
| Tide Turtle | Epic | Water/Earth | Tank | Tidal Shell (DEF + saat pasang) | → Island Turtle | Tank; homestead pond |

## 2.8 Skyveil (lvl 70–90) — 6 spesies
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| Cloud Sheep | Common | Sky | Support | Soft Landing | — | Ternak wol awan |
| Wind Sprite | Rare | Wind | Caster | Zephyr | → Sylph | Companion |
| Griffin | Epic | Wind/Light | Swift | Sky King's Pride | → Royal Griffin | **Racing udara** inti + mount |
| Sky Serpent | Epic | Sky | Bruiser | Cloud Swim | → Quetzal Sovereign | Mount |
| Baby Cloud Dragon | Legendary | Sky/Water | Caster | Rainmaker (panggil hujan lokal!) | → Cloud Dragon | Utility cuaca — sangat dicari |
| **Star Whale** | Ancient | Star | Tank | Cosmic Bulk | — | Tidak bisa tame; Hidden Scenario (perut paus) |

## 2.9 Abyss Realm (lvl 85–99) — 4 spesies (launch minimal)
| Monster | Rarity | Elemen | Arketipe | Trait | Evolusi | Tame |
|---|---|---|---|---|---|---|
| Void Imp | Rare | Void | Assassin | Blink | — | Companion |
| Shadow Stalker | Epic | Darkness | Assassin | Fear Aura | — | — |
| Abyss Maw | Epic | Void | Tank | Devour (makan proyektil — sains vakum) | — | Tank unik |
| **Void Herald** | Mythic | Void/Darkness | Caster | Gatekeeper | — | Pra-boss Void Emperor |

---

# 3. BOSS LAUNCH (8)
| Boss | Lokasi | Lvl | Mekanik inti | Drop kunci |
|---|---|---|---|---|
| King Slime | Greenvale (dungeon 1) | 15 | Split & bounce | Resep tier C |
| Sugar Queen | Candyveil (event/skenario) | 30 | Ujian etiket + fase combat | Resep Cook [S] path |
| Anubis Warden | Desert Barrow | 25 | Kutukan cermin (pantulkan damage saat debuff) | Material A: Ankh Fragment |
| Frost Titan | Foothill Barrow/Frostpeak | 38 | Ice floor phase, hancurkan pilar | Material A: Everfrost Core |
| Storm Sovereign | Zephyr Spire | 55 | Petir kejar-kejaran, grounding puzzle (pakai Earth!) | Material S: Tempest Heart |
| Volcanic Colossus | Magma Heart | 65 | Lantai lava naik, heat gauge | Material S: Heart of the Volcano |
| Sea Oracle Leviathan | Sunken Cathedral | 68 | Fase pasang-surut (Moon mempermudah) | Material S: Moon Tear |
| Cloud Dragon Matriarch | Temple of the White Sea | 85 | Terbang antar platform awan | Material SS path: Skyveil Scale |

# 4. SECRET/CONDITIONAL (6 di launch)
Thunder Dragon, Forest Spirit, Blood Moon Beast, Mirage Serpent, Star Whale, Moon Rabbit Berserker (Hidden Scenario). Detail trigger di GDD v0.1 §7.3 & v0.2 §8.2.

---

# 5. CONTOH STAT BLOCK PENUH (untuk implementasi)

**Grey Wolf** — Common, Bruiser, lvl 5, 3★
HP 1.392 | ATK 87 | DEF 62 | MATK 14 | MDEF 45 | SPD 52 | TTK target: 4 dtk
Skill: Bite (110% ATK), Howl (buff pack). Drop: Wolf Pelt 80%, Wolf Fang 25%, Beast Essence 5%. EXP 69. Tame base 80%.

**Thunder Hawk** — Rare, Swift, lvl 45, 3★
HP 4.968 | ATK 745 | DEF 496 | MATK 397 | MDEF 546 | SPD 1.888
Racing: SPD 78 / ACC 70 / HND 55 / STA 57 | Special: Storm Dash (burst 2 dtk, sekali per lap)
Skill combat: Dive Talon (140%), Static Wing (AoE kecil). Tame 40%.

**Thunder Dragon** — Legendary, Bruiser, lvl 60, spawn 4–5★ saja
HP 41.400 | ATK 3.850 | DEF 2.770 | MATK 620 | MDEF 2.000 | SPD 2.300
Fase lapangan: 1) Sky barrage 2) turun & melee (window taming saat HP <5% dan sedang grounded).
Tame 1,5% (Master Orb). Drop (jika dibunuh): Tempest Heart 100% (material S), Dragon Scale ×3–5, resep [A] Stormfang Blade 10%.

**Fluffbit** — Common, Swift, lvl 2 — HP 236 | ATK 21 | SPD 41. Sengaja lemah & spawn masif: counter "10.000 kelinci" berjalan diam-diam per karakter sejak level 1.

---

# 6. ATURAN PRODUKSI KONTEN MONSTER
1. Setiap spesies wajib punya: peran ekonomi (drop dipakai resep nyata), alasan di-tame ATAU alasan dihindari, dan 1 kalimat lore.
2. Rasio arketipe per wilayah ± seimbang (jangan satu wilayah semua tank).
3. Palet warna monster mengikuti elemen (pembacaan cepat di layar kecil — game ringan/mobile).
4. Varian musiman = recolor + 1 trait (murah diproduksi, terasa segar): Frost Fluffbit di winter, dst.
5. Sprite: mulai dari pack gratis (PIPOYA/LuizMelo/Elthen — lihat GDD v0.2 §9) → ganti orisinal untuk 12 monster ikonik dulu (Fluffbit, Wolf line, Thunder Dragon, Phoenix, Griffin, Moonfin Dolphin, King Slime, Sugar Queen, Star Whale, Treant, Frost Fox, Cloud Sheep).
