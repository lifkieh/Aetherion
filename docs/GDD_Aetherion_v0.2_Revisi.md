# GDD AETHERION — REVISI v0.2
Dokumen ini merevisi & menambah GDD v0.1. Bagian yang tidak disebut = tetap berlaku.

---

# 1. ARAH PRODUK (DIKUNCI)

- **Model:** Free-to-Play penuh. Revenue hanya kosmetik + battle pass kosmetik + QoL non-power (lihat GDD v0.1 Bagian 15).
- **Game harus RINGAN:**
  - Target spek minimum: PC kentang (Intel HD Graphics, RAM 4GB) & HP Android RAM 2–3GB.
  - Pixel art 16×16/32×32, cap partikel, chunk streaming per layar, audio compressed.
  - Ukuran unduhan awal < 400–500 MB, konten wilayah diunduh bertahap.
  - Mode Hemat: matikan weather VFX, dynamic light, 30fps lock.
- **Mode Open World:** dunia per wilayah seamless (tanpa loading dalam wilayah), transisi antar wilayah via gerbang/kapal/balon udara.
- **Multiplayer:** DITUNDA sesuai keputusan. Rencana rilis:
  - **Fase 1 (launch):** Open-world RPG *online-lite* — main sendiri di dunia, tapi terhubung server untuk: marketplace async, leaderboard, event global, kios pemain lain (statue/ghost vendor). Ini memangkas biaya server & netcode secara drastis = realistis untuk indie.
  - **Fase 2:** Party co-op 2–5 pemain (dungeon & world boss).
  - **Fase 3:** Fitur MMO penuh (open world bersama, guild war, racing live).
- **Waktu game = real time WIB.** Detail di Bagian 6.

---

# 2. SISTEM TIER ITEM (REVISI TOTAL)

Skala tier baru: **F → E → D → C → B → A → S → SS → SSS**

## 2.1 Dua kelas tier
| Kelas | Tier | Cara dapat |
|---|---|---|
| **Umum** | F, E, D, C, B | Drop monster, quest, craft normal (success 100–60%) |
| **Transenden** | A, S, SS, SSS | **HANYA craft**, butuh material kunci spesifik, **success 1%** |

## 2.2 Aturan Tier Transenden
- Tidak pernah drop jadi. Boss/event hanya menjatuhkan **material kunci** (mis. Heart of the Volcano, Moon Tear, Star Core).
- Resep A+ hanya bisa dikerjakan oleh **profesi produksi UTAMA** (bukan sub) level 80+.
- **Struktur piramida (sink alami):**
  - Craft A: butuh 1 item B sebagai bahan dasar + material kunci
  - Craft S: butuh 1 item A + material kunci lebih langka
  - Craft SS: butuh 1 item S | Craft SSS: butuh 1 item SS
  - Artinya SSS secara statistik hanya akan ada segelintir di seluruh server → legenda hidup.
- **Anti-frustrasi (tanpa mengubah 1%):**
  - Gagal craft: bahan dasar (item tier bawah) TIDAK hancur, hanya material pendukung yang hangus; material kunci hangus.
  - Tiap kegagalan resep yang sama memberi 1 stack **Insight** (+0,2% permanen untuk resep itu, cap +9%) → progres terasa, ekspektasi tetap ratusan percobaan.
  - Craft A+ menampilkan animasi ritual + pengumuman server saat sukses (nama crafter tercatat: *maker's mark*).
- **Dampak ekonomi (disengaja):** permintaan material kunci & item tier B/A jadi masif → seluruh rantai profesi (gathering → produksi) hidup. Item S+ menjadi *chase item* jangka panjang khas MMO.

## 2.3 Pemetaan konten → tier
| Tier | Sumber material kunci | Contoh |
|---|---|---|
| A | Dungeon elite, world boss mingguan | "Ashen Blade [A]" |
| S | Hidden Scenario, Ancient monster, event langka | "Carrot of Calamity [S]" |
| SS | Kombinasi multi-event (mis. material dari 3 world boss berbeda) | "Tidebreaker [SS]" |
| SSS | Material era-event (setahun sekali) + rantai SS | "Aetherion, the World's Memory [SSS]" |

---

# 3. PROFESI: UTAMA + 2 SUB (REVISI 3.2)

| Aspek | Profesi Utama (1) | Sub-Profesi (2) |
|---|---|---|
| Level cap | 99 | 60 |
| Efisiensi aktivitas | 100% | 75% (hasil/kecepatan) |
| Perk milestone | Semua (tiap 10 lvl) | Hanya sampai lvl 50 |
| Akses tier | Semua (termasuk resep/node A–SSS) | Maks tier B |
| Master Quest & gelar | Ya | Tidak |

**Bonus profesi utama non-combat:** +50% EXP profesi pada aktivitas intinya.
Contoh: Lumberjack utama → +50% EXP setiap menebang pohon; Miner utama → +50% EXP menambang; Fisherman utama → +50% EXP memancing; Herbalist utama → +50% EXP memanen; profesi produksi utama → +50% EXP crafting bidangnya.

**Bonus profesi utama combat:** akses Ultimate Skill, Advanced Class Quest (lvl 60), dan Arena rank penuh.

**Implikasi desain yang bagus dari aturan ini:** "Blacksmith sejati" (utama) benar-benar berbeda dari fighter yang nyambi blacksmith (sub, mentok tier B) → crafter profesional punya tempat terhormat di ekonomi, sesuai Pilar 3.

Ganti profesi utama: quest "Reawakening" + biaya gold besar + cooldown 30 hari (level lama disimpan 50%).

---

# 4. DUNIA (REVISI 4.1) — 13 WILAYAH

Tiga wilayah baru + rework:

| Wilayah baru | Level | Tema | Detail |
|---|---|---|---|
| **Candyveil Meadows** | 18–32 | Dunia pink cotton candy | Padang gula kapas, sungai soda, pohon lolipop, hujan permen saat "Sugar Rain". Material: Sugar Crystal, Caramel Ore, Choco Wood (bahan Cook premium). Monster imut tapi menipu (Gummy Mimic). Estetika pastel → magnet konten sosial/screenshot |
| **Ocean Kingdom (diperluas)** | 55–70 | Underwater penuh | Kota Atlantis-style, terumbu, palung gelap. Butuh Breathing Charm (craft). **Pasang-surut nyata** (lihat elemen Moon) membuka/menutup area |
| **Skyreach → "Skyveil"** (rework ala Skypiea) | 70–90 | Lautan awan | Pulau di atas awan, sungai awan yang bisa "direnangi", White Sea, kuil langit, lumba-lumba awan. Naik ke sini via updraft raksasa/balon/mount terbang |

Homestead (dunia pribadi pemain) → Bagian 5.

---

# 5. HOMESTEAD — LAHAN PRIBADI (SISTEM BARU)

Dunia instance pribadi milik pemain (offline-friendly, sejalan konsep game ringan).

## 5.1 Aturan lahan
- Dibuka lvl 10 via quest "A Place to Call Home".
- **Luas mengikuti level + ekonomi:**

| Tier lahan | Syarat level | Biaya gold | Ukuran |
|---|---|---|---|
| Gubuk & kebun | 10 | 5.000 | 16×16 tile |
| Ladang kecil | 25 | 50.000 | 32×32 |
| Pertanian | 45 | 400.000 | 48×48 |
| Perkebunan besar | 65 | 2.000.000 | 64×64 |
| Estate | 85 + reputasi | 10.000.000 | 96×96 + bioma pilihan |

## 5.2 Aktivitas
- **Bercocok tanam:** herbal & tanaman obat (input profesi Herbalist/Alchemist), sayur (Cook). Tumbuh **real-time WIB** (tetap tumbuh saat offline). Musim memengaruhi apa yang bisa ditanam → greenhouse craftable untuk lintas musim.
- **Beternak:** hewan ternak (ayam, sapi, domba wol) + **monster jinak** dari taming bisa dilepas di ranch → produk pasif (telur, susu, wol, essence monster) + affinity naik perlahan.
- **Breeding pen, apiari (madu), kolam ikan, workshop crafting pribadi, dekorasi** (kosmetik = monetisasi sehat).
- Hasil homestead 100% tradeable → pemain "petani/peternak" bisa kaya tanpa combat. Ini gaya main yang valid penuh.
- Kunjungan pemain lain (fase 2): showroom + kios di lahan.

---

# 6. WAKTU REAL WIB, SIKLUS LANGIT & EVENT

## 6.1 Jam dunia = jam WIB asli
- Siang/malam in-game mengikuti jam nyata. Server tunggal berbasis WIB (target awal pasar Indonesia/SEA — masuk akal untuk indie).
- **Fase bulan mengikuti kalender lunar NYATA** (purnama in-game = purnama sungguhan). Gerhana mengikuti jadwal astronomi asli → event gerhana jadi momen komunitas yang bisa dinanti berbulan-bulan (marketing gratis).

## 6.2 Event berbasis waktu
| Waktu | Event |
|---|---|
| Pagi (05.00–07.00) | Morning Dew: herb kualitas +1, ikan pagi, NPC pasar pagi |
| Sore (17.00–18.30) | Golden Hour: EXP +10%, foto mode bonus, monster senja |
| Malam (19.00–04.00) | Monster nokturnal, bintang terlihat (navigasi Star), tarif penginapan |
| **Purnama** | Pasang tinggi (spring tide): area pantai banjir, monster laut naik ke darat, Werebeast spawn, buff Moon +20% |
| **Bulan sabit/baru** | Surut ekstrem: **dasar laut terbuka** → jalur & gua rahasia, harta karam bisa dijarah jalan kaki |
| **Gerhana bulan/matahari (jadwal asli)** | Blood Moon versi kosmik / Eclipse: gerbang Abyss, monster Void, drop ×2 |
| Meteor shower (kalender asli: Perseid dll.) | Star Ore jatuh, Star Whale bisa muncul |

**Catatan keadilan:** event harian penting diberi 2 window (pagi & malam) agar pelajar/pekerja tidak terkunci; event langit (purnama/gerhana) memang eksklusif — itulah nilainya.

---

# 7. ELEMEN (REVISI 5.1–5.3): TIER 4 + FISIKA-KIMIA NYATA

## 7.1 Struktur final: 17 elemen, 4 lapis
- Tier 1 (8): Fire, Water, Wind, Earth, Lightning, Ice, Light, Darkness
- Tier 2 (4): Poison, Metal, Wood, Spirit
- Tier 3 (2): Void, Sky
- **Tier 4 — Celestial (3): Star, Sun, Moon** — hanya via questline epik / Hidden Scenario / fusion monster Celestial. Maks 1 elemen Celestial per karakter (pilihan identitas).

## 7.2 Prinsip: "Sains dibungkus fantasi"
Setiap elemen mengikuti hukum kimia/fisika nyata, disederhanakan jadi aturan gameplay:

| Elemen | Dasar sains | Aturan gameplay |
|---|---|---|
| Fire | Pembakaran butuh oksigen & bahan bakar | Di bawah air: damage −50%. Wind aktif di area: Fire +25% (suplai O₂). Membakar Wood/rumput menyebar |
| Water | Pelarut & konduktor | Target basah (status Wet): Lightning ke target itu +30% & chain; Fire −30% |
| Lightning | Konduksi & grounding | Merambat lewat air & armor Metal (chain ke musuh ber-armor logam). Musuh/pemain menyentuh tanah dengan skill Earth = *grounded* (imun chain) |
| Ice | Perubahan fasa & suhu | Air bisa dibekukan jadi jembatan; Freeze lalu dipukul Fire = Thermal Shock ×1.5 (ekspansi termal) |
| Earth | Massa, grounding, tektonik | Menetralkan Lightning; medan berbatu memperlambat |
| Wind | Tekanan & aliran udara | Memadamkan api kecil ATAU membesarkan api besar; mendorong proyektil; racun gas tertiup |
| Metal | Konduktor, magnetisme, korosi | Ditarik skill Magnet; kena Poison (asam) lama-lama korosi (DEF turun bertahap) |
| Poison | Kimia asam/basa & toksin | Asam mengorosi Metal; penawar = crafting basa (Alchemist); dosis bertumpuk |
| Wood | Biologi & fotosintesis | Siang/terkena Sun: regen & growth skill +25%; sangat terbakar oleh Fire |
| Light | Foton & radiasi tampak | Cepat, akurat, mengusir Darkness; pantulan via permukaan Crystal/Ice |
| Darkness | Absorpsi & bayangan | Kuat di malam/gua; menyerap proyektil Light lemah |
| Spirit | Energi non-materi | Bypass 50% pertahanan fisik; lemah ke wadah kosong (golem tanpa jiwa imun) |
| Void | Vakum & gravitasi ekstrem | Menyedot proyektil & entitas; hampa udara: Fire mati total di zona Void |
| Sky | Atmosfer, tekanan, cuaca | Manipulasi cuaca lokal singkat; jatuh bebas & updraft |
| **Sun** | Energi radiasi, fusi hidrogen, fotosintesis | Buff siang (puncak 11.00–13.00 WIB). Skill: Solar Lance, Flare Blind, mempercepat tanaman homestead, mengisi "Solar Charge" saat cerah |
| **Moon** | **Gravitasi & pasang surut**, siklus lunar | Kekuatan mengikuti fase bulan asli (purnama = puncak). Skill: Tidal Pull (tarik massa air/musuh), Gravity Well (perlambat area), Moonlight Veil (stealth malam). **Pengendali Moon dapat memicu pasang/surut lokal → membuka secret quest, jalur dasar laut, scenario & trait khusus** |
| **Star** | Plasma, fusi bintang, navigasi astronomi | Skill: Plasma Nova (properti Fire+Lightning), Starfall (delay meteor), Celestial Map (mengungkap secret di sekitar). Kuat saat langit cerah malam; mati rasa saat mendung |

## 7.3 Interaksi rantai (contoh emergent, semuanya dari sains)
- Hujan → semua target Wet → tim Lightning pesta chain, tim Fire menderita → **cuaca benar-benar mengubah meta harian** (Pilar 1).
- Moon user surutkan laut → party masuk gua dasar laut → di dalam ada dungeon yang hanya eksis saat surut → naik pasang = dungeon banjir (timer alami tanpa UI timer).
- Fire + Water = **Steam** (resep kombinasi baru): awan uap menutup pandangan (Accuracy −20% area) — sains: penguapan.
- Sun + Wood = Overgrowth: sulur raksasa (fotosintesis dipercepat).
- Moon + Water = Tsunami Kecil (hanya saat purnama, di dekat perairan).
- Star + Void = Supernova→Blackhole combo (ultimate langka, lore akhir game).

## 7.4 Revisi taming rate (5.3)
| Rarity | Rate baru |
|---|---|
| Legendary | **1,5%** |
| Mythic | **0,5%** |
| Ancient | **0,01%** |
(Pity ringan tetap: +0,05% per kegagalan pada individu monster yang sama, reset saat despawn. Ancient tetap praktis mustahil = benar-benar legenda.)

---

# 8. DUNGEON (DIPERLUAS) & HIDDEN SCENARIO

## 8.1 Dungeon berdasarkan lokasi
| Dungeon | Lokasi | Level | Gimmick |
|---|---|---|---|
| Foothill Barrow | Kaki gunung Frostpeak | 20–30 | Makam kuno, puzzle cahaya |
| Magma Heart | **Dalam gunung berapi** Emberfall | 55–65 | Lantai lava naik-turun, heat gauge (butuh potion pendingin) |
| Sunken Cathedral | **Bawah air**, Ocean Kingdom | 58–68 | Kantong udara terbatas, arus; saat surut (Moon) lantai bawah terbuka |
| Zephyr Spire | **Di udara**, menara angin | 62–72 | Platforming updraft, jatuh = ulang lantai |
| Temple of the White Sea | **Di dalam awan**, Skyveil | 75–85 | Awan padat/rapuh, petir kuil |
| **Belly of the Star Whale** | **Perut paus** raksasa | 70+ | HIDDEN: hanya bisa masuk jika tertelan (lihat 8.2). Ekosistem dalam perut, asam lambung naik tiap 5 menit |
| Abyss Rift | Abyss Realm | 85+ | Zona Void: Fire mati, gravity aneh |

## 8.2 Hidden Scenario System (terinspirasi Rabituza / Shangri-La Frontier)
Event unik server dengan aturan keras:

**Aturan sistem:**
1. **Trigger absurd & spesifik** — tidak tertulis di quest log; hanya petunjuk samar di lore/NPC/lingkungan.
2. **No-Fail Rule:** sekali masuk skenario, GAGAL = terkunci PERMANEN untuk karakter itu (badge "Scenario Failed" — kegagalan pun jadi cerita).
3. Reward: item tier **S**/unique trait/skill Celestial/akses area — semuanya tak bisa didapat jalur lain.
4. **First Clear server** diumumkan global + patung di Celestia Kingdom.
5. Tim konten menambah 2–3 skenario per season secara diam-diam (tanpa patch note!) → komunitas berburu misteri terus-menerus.

**Contoh skenario launch:**
| Nama | Trigger | Isi skenario | Reward |
|---|---|---|---|
| **Warren of the Moon Rabbit** | Bunuh **10.000 kelinci** (lifetime), lalu tidur di penginapan saat purnama | Ditarik ke Lunar Warren. Quest: bertahan 60 menit dikejar Moon Rabbit Berserker **tanpa membunuh satu kelinci pun** (dosa harus ditebus). Mati/membunuh = gagal permanen | Senjata **[S] Carrot of Calamity** + trait "Moon-Marked" (Moon element unlock path) |
| **Belly of the Star Whale** | Memancing di laut terbuka saat meteor shower dengan umpan Star Bait | Ditelan paus → dungeon perut → keluar dalam 45 menit sebelum "dicerna" | Akses permanen dungeon + material [S] Ambergris Star |
| **The Sugar Queen's Tea Party** | Makan 100 permen berbeda dalam satu hari di Candyveil | Diundang jamuan teh; ujian etiket & teka-teki 3 babak, salah 3× = diusir selamanya | Resep Cook [S] + pet Peppermint Fairy |
| **Gravekeeper's Debt** | Menguburkan (bukan loot) 500 monster yang dibunuh pemain lain | NPC Gravekeeper menagih bantuan satu malam penuh | Skill Spirit unik "Last Rites" |
| **The Thousandth Tree** | Menanam kembali 1.000 pohon (lawan dari trigger Forest Spirit!) | Forest Spirit datang bukan untuk perang, tapi memberi ujian | Mount [S] Ancient Treant Sapling |

Desain penting: sebagian trigger adalah **penebusan/kebalikan** dari perilaku destruktif → dunia terasa punya moral & memori (Pilar 1).

---

# 9. DAFTAR ASSET GRATIS (HASIL RISET WEB, Juli 2026)

> Lisensi harus dicek ulang per pack sebelum rilis komersial. Prioritaskan CC0. Daftar ini titik awal — bisa diperluas lagi lewat Claude di browser.

## 9.1 Hub utama
| Sumber | Isi | Catatan |
|---|---|---|
| itch.io — Free Pixel Art (itch.io/game-assets/free/tag-pixel-art) | Ribuan pack gratis | Filter lisensi CC0 tersedia |
| itch.io — CC0 only (itch.io/game-assets/assets-cc0) | Pack full CC0 | Paling aman komersial |
| OpenGameArt.org — koleksi CC0 | 2D, audio, ikon | Bisa auto-generate file kredit |
| CraftPix.net — Freebies | Tileset & sprite kualitas premium, sebagian gratis | Cek lisensi per item |
| Kenney.nl / "Kenney Game Assets All-in-1" | 60.000+ asset CC0 (UI, ikon, audio, 2D) | Wajib punya — UI & prototipe |

## 9.2 Karakter, monster, dunia (paling relevan Aetherion)
| Pack | Kegunaan di Aetherion |
|---|---|
| **Ninja Adventure Asset Pack** (CC0, itch.io) | Basis besar: tiles, karakter animasi, monster, senjata, musik — fondasi prototipe |
| **Anokolisa — Pixel Art Topdown 16×16** (500 sprite, 3 hero, 8 musuh, 50 senjata) | Prototipe combat & dungeon |
| **Sprout Lands** (Cup Nooble) — pastel farming pack | **Homestead & Candyveil** (gaya pastel imutnya pas sekali) |
| **Cute Fantasy RPG 16×16** | Overworld & desa |
| **Tiny Swords** (Pixel Frog) | Unit perang/guild war, VFX |
| **PIPOYA Free RPG Monster Pack** (50 monster + 4 boss) & PIPOYA Character Sprites 32×32 | Roster monster awal |
| **LuizMelo — Monsters Creatures Fantasy / Fire Worm / boss packs** | Boss & elite side-view |
| **Elthen's Pixel Art Shop** (golem, worm, spider, dwarf, dll.) | Variasi monster per wilayah |
| **Aekashics Librarium** (battler gratis) | Ilustrasi bestiary/Aetherpedia |
| **Time Fantasy RPG Sprites free** | NPC & kota |
| **Super Retro World free packs** (Gif) | Karakter & environment |
| **Pocket Creature Tamer Adventure Kit** (Josee) | Referensi/dasar sistem taming-evolusi 16×16 |
| **The Mana Seed Character Base** | Basis sprite karakter pemain (gender-netral, banyak animasi) |
| **Free Dragon Sprites Pack** (The Art Of Nemo), **FREE Goblin Monsters** (SolaarNoble), **Fantasy RPG Creatures Free Pack** (Electric Lemon), **Free 30 Enemy Pack** (cogabushi), **Fantasy Pixel Art Eggs** (Frostwindz — untuk breeding!) | Pelengkap roster |

## 9.3 Audio
| Pack | Kegunaan |
|---|---|
| **80 CC0 RPG SFX** + **CC0 Sound Effects collection** (OpenGameArt) | SFX blade, coin, creature, spell |
| **High Quality 16-bit RPG Music** — HydroGene (28 track, CC0) | BGM wilayah |
| **alkakrab free packs** (25 Fantasy RPG Tracks Vol.1–3, Medieval, Boss Battle, Ambient) | BGM & boss |
| **TomMusic — 200+ Fantasy SFX** | SFX umum |
| **Minifantasy Dungeon Audio** (Leohpaz) | Dungeon |
| **lentikula — Basic & Healing Spell Impacts (CC0)** | SFX elemen (fire/ice/lightning/water — pas dengan sistem elemen!) |
| **Free RPG Music Pack** (Gianni Canetti), **CC0 Fantasy Music & Sounds** (OGA) | Cadangan BGM |
| **RPG Essentials SFX Free**, **Interface SFX Pack (CC0)** | UI |

## 9.4 Tools gratis
Godot 4 (engine) • **LDtk / Tiled** (map editor) • Libresprite/Piskel (pixel art, alternatif gratis Aseprite) • Lospec (palet warna) • Audacity (audio) • jsfxr/ChipTone (SFX generator).

## 9.5 Strategi asset (penting)
1. **Prototipe 100% asset gratis** → validasi fun dulu, nol biaya art.
2. Kunci **palet warna & resolusi tunggal** (mis. 32×32 + palet 64 warna) supaya pack campuran tetap terlihat satu game.
3. Beta → ganti bertahap dengan asset orisinal untuk identitas visual (mulai dari karakter pemain, monster ikonik, UI).
4. Simpan `CREDITS.md` sejak hari pertama (lisensi CC-BY wajib atribusi).

---

# 10. IDE PENYEMPURNAAN TAMBAHAN (OPSIONAL, DARI SAYA)

1. **Aetherpedia** — bestiary + jurnal otomatis: monster, resep, cuaca yang pernah ditemui; melengkapi entri memberi reward kecil → memuaskan explorer & collector.
2. **Photo Mode** sederhana + frame kosmetik → konten sosial gratis (marketing organik, cocok dengan dunia pastel Candyveil).
3. **Title system dengan micro-buff netral** (mis. "Penebang 10.000 Pohon": +2% kecepatan menebang) — prestise tanpa merusak balance.
4. **NPC Astrologer + kalender langit in-game** yang menampilkan fase bulan & meteor shower asli — pemain merencanakan hidupnya di sekitar langit sungguhan; fitur paling unik game ini.
5. **Dynamic music layering ringan**: track dasar + layer intensitas saat combat/cuaca (hemat performa, terasa hidup).
6. **Sistem "Echo Vendor"**: karena multiplayer ditunda, pemain lain muncul sebagai "gema" statis di kota membawa kios & outfit mereka — dunia terasa ramai tanpa netcode real-time.
7. **Event mingguan server-wide berbasis kontribusi** (mis. "kumpulkan 1 juta Sugar Crystal") dengan reward semua partisipan → komunitas terbentuk bahkan sebelum multiplayer penuh.
8. **Daily "Sky Report"** saat login: cuaca, fase bulan, event aktif hari ini → langsung memberi tujuan sesi.
