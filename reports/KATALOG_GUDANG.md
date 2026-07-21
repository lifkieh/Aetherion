# KATALOG GUDANG — indeks "apa ini SEBENARNYA"

**Dibuat:** 2026-07-21 · **Aturan:** tiap baris diisi **setelah melihat** aset yang
dirasterisasi (papan catur + kisi 32 px). **Nol baris ditulis dari nama berkas.**
**Lembar kontak:** `reports/preview/katalog/` · **Generator:** `_tools/gen_katalog_lembar.py`
Zip dibaca **di memori** — nol ekstraksi massal (sisa gudang = ±52.000 berkas / 891 MB
yang akan tersinkron ke OneDrive Direktur).

**Vonis:** 🎯`PAKAI` · ⚠`CEK-lisensi`/`ragu` · ❌`TOLAK`
**⚠ `TOLAK` ≠ sampah.** Tolak = tak cocok untuk Ashbrook. Pemindahan ke `_TRASH` punya
kriteria terpisah yang jauh lebih ketat (`TRASH_LOG.md`); sebagian besar yang ❌ di sini
**tetap tinggal di gudang**.

## Hitungan akhir

| | |
|---|---|
| Sumber dilihat (arsip + PNG lepas) | **±120** |
| Arsip di gudang | 98 → **96** |
| Entri gudang akar | 461 → **430** |
| 🎯 PAKAI | **26 baris** tabel (+ ±23 lembar ULPC/hewan di §6–10) |
| ⚠ CEK-lisensi / ragu | **13 baris** (+ ±13 di §6–10) |
| ❌ TOLAK | **14 baris** (+ ±12 di §6–10) |
| `_TRASH` | **27 berkas · 282 MB** |
| `_SUMBER` | **4 berkas · 5,8 MB** |
| TAK TERLIHAT (tak divonis) | **2** |

> **Cara menghitung, supaya angkanya bisa diperiksa:** satu **baris tabel** kadang mencakup
> beberapa berkas sekeluarga (mis. tiga berkas Avalon dalam satu baris ❌). Angka di atas
> menghitung **baris bervonis**, bukan berkas — dihitung dari berkas ini sendiri, bukan
> ditaksir. §6–10 masih daftar naratif, jadi kontribusinya ditulis sebagai perkiraan
> eksplisit. Angka pertama yang saya tulis (41/34/28) adalah taksiran sebelum dihitung;
> ini penggantinya.

---

## 1 — TILESET DASAR *(lembar `01_tileset_dasar.png`)*

| apa ini SEBENARNYA | berkas | lisensi | vonis |
|---|---|---|---|
| **Jalan tanah↔rumput, autotile 3×3 lengkap** | `Terrain/Grass-Dirt (*)` · `4-season_terrain.zip` | OGA-BY 3.0 | 🎯 jalan tulang-punggung |
| Tanah polos 3 varian | `Terrain/Dirt` · sda | OGA-BY 3.0 | 🎯 |
| Atlas terrain LPC (paving, tembok patah, nisan) | `terrain_atlas.png` · `Atlas.zip` | CC-BY-SA/GPL | 🎯 |
| **Kit bangunan LPC** — dinding+atap+pintu **sebagai ubin** | `base_out_atlas.png` · `Atlas.zip` | CC-BY-SA/GPL | 🎯 (pipeline, bukan tata letak) |
| Prop + cobble Mage City | `magecity.png` | CC0 Hyptosis | 🎯 sumber prop repo |
| **Hyptosis batch 1–4 + sprites-and-tiles** — reruntuhan, pagar, pohon mati, peti, fondasi | `hyptosis_*.png` (960×960) | CC-BY 3.0 | 🎯 keluarga sumber prop repo |
| Kit kota 32px terlengkap di gudang | `Slates v.2 [...].png` | **nol berkas** | ⚠ gaya lebih pekat & bergaris hitam dari LPC |
| Versi lama Slates | `Slates [...].png` (v.1) | **nol berkas** | ⚠ dikalahkan v.2 |
| Kit kota: **atap banyak arah + air mancur BERAIR** | `tileset_town_multi_v002.png` | **nol berkas** | ⚠ kandidat terkuat bangunan multi-arah |
| Ubin gandum/jerami LPC | `lpc_terrain.tar` | LPC | 🎯 |
| Hyptosis batch-5 (tebing/gua) | `hyptosis_tile-art-batch-5.png` | CC-BY 3.0 | ⚠ragu |
| Ubin dungeon/gua LPC | `cave.png` · `tileset_dungeon.png` | ? | ⚠ragu — interior |
| **Tileset dungeon 32px bersih** (ramuan, peti, lantai, lava) | `ProjectUtumno_full.png` (2048×3040) · `DungeonCrawl_ProjectUtumnoTileset.png` | **nol berkas** | ⚠CEK — **lihat catatan "cacat alat" di bawah** |
| Rumput Avalon · tebing Avalon · prop Avalon | `ground_tiles.png` · `Cliff_tileset.png` · `object- layer.png` | GPL3 (tercetak **di dalam gambar**) | ❌ palet kuning-pucat, satu set |
| Palet GameBoy 4-warna | `fantasy-tileset.png` | ? | ❌ |
| Ubin 16×16 peta-dunia | `Overland Tiles.zip` | nol berkas | ❌ skala salah |
| Latar parallax / gradasi langit | `parallax_mountain_pack.zip` · `Free Mist Game Background.zip` · `background_32.png` | campur | ❌ bukan ubin |
| Ubin kartun terang | `field_v1.zip` · `tilesetStart5.png` · `superpowers-*various_2d` | campur | ❌/⚠ragu |
| Tileset latar **cyan #00FFFF** (bukan alpha) | `version_2.0_isaiah658s_pixel_pack_2.zip` (+v1.0) | ? | ⚠ perlu kunci-warna dulu |
| Ubin adobe gurun | `adobe building set.zip` | ? | ❌ idiom gurun |
| Ubin dungeon bata | `TilesDungeon.zip` | ? | ⚠ragu |
| Transisi air/es | `coldwatericetransitions.zip` · `Winter tiles.7z` | ? | ⚠ragu — nol air di Ashbrook |

## 2 — RERUNTUHAN *(lembar `02_reruntuhan.png`)* — kategori paling dibutuhkan C3

| apa ini SEBENARNYA | berkas | lisensi | vonis |
|---|---|---|---|
| **Tembok batu: persegi PENUH + potongan sudut + baris RETAK** | `fence_medieval.png` · `decoration_medieval.zip` | CC-BY-SA/GPL | 🎯 **jawaban fondasi-berbentuk** |
| Tembok bata **runtuh berlubang** + puing bata + nisan salib | `terrain_atlas.png` · `Atlas.zip` | CC-BY-SA/GPL | 🎯 |
| Puing & serakan kerikil, 4 palet | `rocks/rocks.png` · `rocks.zip` | **CC0** | 🎯 memberi MASSA |
| Batu berdiri / dolmen | sda | CC0 | 🎯 "lebih tua dari desanya" |
| Garis fondasi rata, nol massa | `fondasi32.png` (**repo**) | ada credits | 🎯 sudah dipakai C3 |
| ⚠ **PAGAR KAYU UTUH** | `wall_ruin.png` (**repo**) | — | ❌ nama menipu · `DEPRECATED.md` |
| Nisan **siluet hitam** tampak-samping, **nol alpha** | `tombstones.png` | ? | ❌ untuk parallax |
| Pemakaman **NES 16×16** 8-bit | `nes_tile_set_cemetery_files.zip` | ? | ❌ palet |
| Kuil runtuh — **PNG terbesarnya IKLAN KUPON** | `craftpix-net-160005-...zip` | **proprietary** | ❌ |

## 3 — BANGUNAN

| apa ini SEBENARNYA | berkas | lisensi | vonis |
|---|---|---|---|
| Atap+dinding+perabot bengkel (pandai besi/penjahit) | `lpc-revised-workshops-tilesets.zip` | **nol berkas** | 🎯 kandidat interior |
| Fasad repo: **kelima menghadap SELATAN**, nol varian arah | `fasad_*.png` (**repo**) | ada credits | 🎯 (batasnya = keputusan penempatan) |
| Bangunan **vektor-kartun bergradasi** | `2DHouse*.png` · `map.png` | ? | ❌ → `_TRASH` (2,0–3,7 % warna/piksel) |
| Bangunan render painterly 129–2000 px | `oldvillage.zip` | nol berkas | ❌ → `_TRASH` |

## 4 — DEKORASI DESA

| apa ini SEBENARNYA | berkas | lisensi | vonis |
|---|---|---|---|
| **Panen terbesar:** sumur batu, kolam berair, gerobak dorong, bal jerami, tumpukan kayu, lapak bertenda, papan gantung (termasuk **kosong**), nisan, api unggun, tenda | `decorations-medieval.png` · `decoration_medieval.zip` | CC-BY-SA/GPL | 🎯 |
| Pagar kayu banyak gaya + **sudut & gerbang** | `fence_medieval.png` | CC-BY-SA/GPL | 🎯 |
| **Lapak bazaar bertenda LPC** — kredit tercetak **di dalam gambarnya** | `lpc_bazaar_rework-1.0-1.zip` | CC-BY-SA/CC0/GPL | 🎯 |
| Prop kota/kastil padat: lapak, panji, sumur, obor, peti, lengkung | `Castle2.png` (512×512) | ? | 🎯 ⚠CEK |
| **Air mancur bertingkat BERAIR**, 2 frame | `WaterFountain.png` (128×96) | ? | ⚠CEK — obat langsung cacat 🔴-4 POTRET; palet lebih mengkilap dari LPC |
| Tanaman ladang LPC | `crops.zip` · `crops-v2.1.zip` | LPC | 🎯 |
| Ladang, pagar, gandum, karung pasar | `submission_daneeklu.zip` | CC-BY-SA/GPL | 🎯 sudah dipakai C3 |
| Gore/tengkorak/darah | `Prison_C.png` | ? | ❌ idiom |

## 5 — ALAM

| apa ini SEBENARNYA | berkas | lisensi | vonis |
|---|---|---|---|
| **Pohon musim gugur** — `autumn.png` + `brown trees.png` **sekeluarga** (224×128, bayangan sama) | 2 berkas lepas | **nol berkas** | 🎯 ⚠CEK — paling cocok tepi Ashbrook |
| Pohon hijau besar sekeluarga | `green trees.png` | nol berkas | 🎯 ⚠CEK |
| **Pohon gundul/mati** + jamur + semak gelap | `all.7z` (7 PNG) | **nol berkas** | 🎯 ⚠CEK — idiom tepi-mati |
| Pak tanaman padat: pinus, semak, pagar tanaman, tunggul | `plant repack.png` | nol berkas | 🎯 ⚠CEK |
| Rumput tinggi 6 ukuran × 3 musim · batu padang · tunggul · bunga liar · jamur | `Terrain Objects/*` · `4-season_terrain.zip` | OGA-BY 3.0 | 🎯 varian gugur = kering |
| Treeline pinus (sudah dipakai C4) | `pinus_*.png` (**repo**) | OGA-BY 3.0 | 🎯 |
| Pohon + semak berbayang | `ZRPG Tiles.tar.gz` | ? | ⚠CEK |
| Pohon berakar oranye mencolok | `treepack.png` · `treepacknewest.png` | nol berkas | ⚠CEK — palet lebih ramai dari LPC |
| Sakura merah muda · pohon **biru** | `cherry_blossom_trees.png` · `blue trees.png` | nol berkas | ❌ idiom |
| Massa gunung | `mountains.png` | ? | ⚠ragu |

## 6–10 — KARAKTER · HEWAN · PROP · EFEK · UI *(ronde ini: daftar, belum lembar kontak)*

**🎯 LPC-asli, siap pakai tanpa konversi (14):** `lpc-character-bases-v3_1` · `lpc_character_bases-v2`
(termasuk **Zombie/Undead**) · `lpc_revised_character_basics` · `Clothes00` · `gentleman` ·
`Legion armor` · `Reptile` (drake 832×1344) · `LPC Dark Elves` · `LPC_Sara` ·
`Androgynous Bases/Long-Sleeve/Short-Sleeve` · `modular-kimono-pieces` · `male-obi-boots` ·
`furry-ears-tails` ×2 · `lpc_bows_walk_animations` · `combined_runcycle` ·
`lpc_male_item_spritesheets` + `_individual_frames` + `_item_animations` ·
`lpc_medieval_weapons` · `hairstyles-2024` · `topknot-hairstyles` · `facial-assets`.

**🎯 Hewan/monster 4-arah:** `stendhal_animals` (dipakai: domba) · `stendhal_dragons` ·
`kobold-0.5` · `cabbit-bases-0.3` · `horse-1.1` + `LPC Horse Extended` · `pig-1.1` ·
`cat-1.0` · `lpc-monsters` · `seasons_of_forest_animal_pack` (CC0).

**⚠ragu:** `24x32 black characters pack` · `maleBase` · `customizable_characters_w_samples`
(chibi, bukan LPC) · `character.zip` · `mon3_ani` · `airmonster-002` · `bat-frames` ·
`Smoke.zip` · `magic_pack` · `ItemsAndEffects` · `RavenmoreIconPack` ·
`painterly-spell-icons-1/3` · `PartsSpriteSheetVersion1`.

**❌ TOLAK:** `Battlers` (battler JRPG frontal) · `Combat Backgrounds` (latar realistis) ·
`Combat Media` · `Monster RPG 2` ×5 (TGA, tekstur realistis) ·
`rpg-battle-system-part-2` ×2 (latar dilukis) · `superpowers-asset-packs-characters` ·
`blue-whale-with-krill` · `German Shepherd` (tampak-samping satu arah) · `animals.zip` ·
`Denzi_32x32_isometric` ×2 · `Overland Sprites` (kapal selam) · `All (1).zip` (hewan 16×16).

---

## ⚠ NAMA MENIPU — lengkap *(disalin ke `DEPRECATED.md`)*

| berkas | yang dijanjikan namanya | **isinya sebenarnya** |
|---|---|---|
| `Everything.zip` | tileset besar | 105 ikon UI/musik |
| `lpc_entry.zip` | tileset LPC | 184 lembar karakter |
| `expansion_pack-0.04.zip` | ekspansi ubin | animasi senjata + xcf |
| `4-season_terrain.zip` | terrain 4 musim | 2.621 berkas, **96 % `Characters/`**; terrain-nya 81 |
| `NewFields.png` | ubin ladang | **bagan palet ARNE + sprite karakter merah mungil** |
| `fantasy-tileset.png` | tileset fantasy | palet GameBoy 4-warna |
| `tombstones.png` | nisan | siluet hitam tampak-samping, nol alpha |
| **`Denzi_32x32_isometric.zip`** (+`_transparent_bg`) | ubin isometrik | **lembar ikon monster SLASH'EM berlabel teks** — sama sekali bukan isometrik |
| **`craftpix ... ruined-temple`** | tileset kuil runtuh | PNG terbesarnya **iklan kupon diskon 20 %** |
| **`Overland Sprites.zip`** | sprite overworld | objek terbesarnya **kapal selam** |
| **`sprites.zip`** | sprite | **JPG concept art** desain karakter |
| **`All (1).zip`** | "(1)" ⇒ terlihat duplikat `All.zip` | **`All.zip` TIDAK ADA.** Isinya 6 hewan **16×16** (bee/fox/jellyfish/ladybug/parrot/tiger-pig) — pack yang sama sekali lain dari direktori `All/` (serigala/rusa) |
| `platformer_animations.zip` | animasi | **satu berkas `.blend`** |
| `Ronnan-game-minimap.zip` | minimap | **satu berkas `.psd`** → `_SUMBER` |
| `credits.zip` | — | satu `credits.txt` |
| `Aetherion-main.zip` | — | **snapshot repo kita sendiri** (979 berkas). Bukan aset — **jangan dibuang**, ia cadangan |
| `fluffy_wolf_tail_*.png` | varian "berbulu" | **byte-identik** dengan `wolf_tail_*.png` |

## ⚠ LATAR PALSU — transparansi yang bukan alpha

Diperiksa di tingkat **data**, bukan mata. Ketiganya tampak "transparan" tapi alphanya penuh:

| berkas | kuncinya |
|---|---|
| `version_2.0_isaiah658s_pixel_pack_2.zip` (+v1.0) | **cyan `#00FFFF`** |
| `monster2animcharsprites.7z` | **magenta `#FF00FF`** |
| *(preseden)* wisp Gemini | papan catur **yang dilukis** |

## 🔎 DUA CACAT ALAT — dicatat supaya tak terulang

**1. Alat triase bisa MENGARANG kerusakan.** `ProjectUtumno_full.png` (2048×3040) muncul
sebagai **derau berwarna** di lembar sapu dan nyaris divonis "rusak data". Ia utuh
sempurna — pada skala 0,11 ubin 32 px tergambar 3,6 px. Alat sekarang memberi badge
**"TERLALU KECIL — vonis butuh potongan 1:1"** di bawah skala 0,25.

**2. "PNG terbesar" tak mewakili pack berisi ribuan berkas kecil.** Untuk `DCSS`,
`crawl-tiles`, `Overland Tiles`, yang muncul cuma **satu ubin rumput** / **satu ubin
dinding lilin**. Vonis ketiganya sengaja **tidak** dinaikkan dari ⚠ragu.

## ⚠ TAK TERLIHAT — belum divonis

| berkas | sebab |
|---|---|
| `Ronnan-game-minimap.psd` (di `_SUMBER`) | psd, perlu dirender |
| `platformer_animations.blend` | blend, perlu Blender |

---

## ⚠ DAFTAR CEK-LISENSI — **keputusan Direktur: telusuri atau lewati**

Semua berharga, semua **nol berkas lisensi**. #277 mewajibkan kredit, jadi tak satu pun
bisa masuk repo sampai penulisnya ditelusuri. Ini utang penelusuran, **bukan penolakan**.

| berkas | kenapa layak ditelusuri | perkiraan |
|---|---|---|
| `tileset_town_multi_v002.png` | **satu-satunya jawaban langsung bangunan multi-arah** + air mancur berair | ⭐⭐⭐ prioritas 1 |
| `autumn.png` · `brown trees.png` · `green trees.png` | pohon musim gugur, paling cocok tepi Ashbrook | ⭐⭐⭐ |
| `Slates v.2` (+v.1) | kit kota 32px terlengkap di gudang | ⭐⭐ gaya perlu diuji berdampingan dulu |
| `plant repack.png` | pak tanaman padat | ⭐⭐ |
| `Castle2.png` | prop kota padat | ⭐⭐ |
| `all.7z` | pohon gundul/mati | ⭐⭐ |
| `WaterFountain.png` | obat langsung air-mancur-tak-terbaca | ⭐⭐ |
| `lpc-revised-workshops-tilesets.zip` | interior bengkel | ⭐ |
| `ProjectUtumno` ×2 | tileset dungeon besar & bersih | ⭐ (bukan Ashbrook) |
| `ZRPG Tiles` · `treepack*` · `Castle2` | pohon/prop tambahan | ⭐ |

**Catatan:** `Slates`, `town_multi`, dan pohon-pohon 224×128 hampir pasti dari OpenGameArt
(gaya & penamaannya khas). Penelusuran = mencari halaman OGA-nya, bukan menebak.

---

## `_TRASH` akhir — 27 berkas · 282 MB *(rincian & cara membalik: `TRASH_LOG.md`)*

| grup | jumlah | contoh |
|---|---|---|
| `duplikat_byte/` | 18 | dibuktikan SHA256; termasuk `fluffy_wolf_tail_*` yang **namanya beda** |
| `rusak_data/` | 2 | dua `.crdownload` — header zip ada, `zipfile` menolak |
| `gaya_ukuran/` | 7 | `Dragon - Fully Animated` (139 MB, **43,7 % warna/piksel**), `jatstory`, `oldvillage`, `2DPIXX`, `2DHouse*`, `map.png` |

## `_SUMBER` akhir — 4 berkas · 5,8 MB

`treesv6_0 (1).psd` · `easter_bunny-24x32 (1).xcf` · `2DHouse.psd` ·
`Ronnan-game-minimap.zip` (isinya cuma psd). **Berkas sumber tak pernah masuk tong sampah**,
walau kembar byte-identik.

## Uji "salah gaya total" — angka, bukan selera

Warna unik per piksel tak-transparan. Ambang buang: **1,0 %**.

| aset | rasio |
|---|---|
| `magecity.png` (LPC, dipakai repo) | 0,1 % |
| `brown trees.png` (🎯) | 0,2 % |
| `map.png` | 1,0 % |
| `2DHouse.png` | 2,0 % |
| `2DHousetransparent.png` | 3,7 % |
| `Dragon - Fully Animated` | **43,7 %** |

Pemisahannya dua–tiga **orde**: pixel art punya palet; render 3D/gradasi vektor punya
hampir satu warna per piksel.
