# BURU ASET LPC (#254) — survei terarah per kategori

**Sifat:** SURVEI. Nol unduh massal. Lisensi dibaca dari halaman sumber, bukan ditebak dari nama.
**Prioritas urut (perintah Direktur):** gratis dulu → LPC dunia (SA kini boleh) → beli → gambar sendiri.

---

## ⚠ TEMUAN YANG MENGUBAH ARTI "#254 = 64px"

**Tidak ada tileset LPC 64px. Tidak akan pernah ada.**

Standar LPC = **ubin dunia 32×32** + **frame karakter 64×64**. Angka 64 mengacu pada
kanvas karakter, bukan petak dunia. Diverifikasi dua arah:

- Seluruh terrain keluarga LPC di gudang berkisi 32px (`hyptosis_tile-art-batch-*` 960×960 = 30×30 petak;
  `DungeonCrawl_ProjectUtumnoTileset` 2048×1536 = 64×48 petak; `magecity` 256×1450 = 8×45 petak).
- Halaman [LPC Tile Atlas](https://opengameart.org/content/lpc-tile-atlas) menyatakan eksplisit **32×32**.

**Jadi "LPC = sumber tunggal karakter DAN dunia" berarti: petak 32px + karakter berframe 64px.**
Itu bukan kompromi — itu tampilan LPC kanonik, dan **sudah terbukti menyatu** di
`reports/preview/bukti254_lpc_dunia.png`. Dibanding hari ini: petak 16→32 (**2×**),
karakter 32→64 frame (**2×**). Bukan 4×.

Konsekuensi baiknya: **ongkosnya separuh dari yang diperkirakan**, dan bahannya **ada sekarang**.

---

## 🌍 DUNIA / TILESET — kategori paling terpenuhi

| Pack | LPC-native | Lisensi | Ukuran | Cakupan | URL |
|---|---|---|---|---|---|
| **[LPC] Terrains** — bluecarrot16, Zabin | ✅ **ya** | CC-BY-SA 3.0/4.0 | 32px | pasir · tanah · batu · rumput · air · salju · es · lava · lumpur · cobble · rawa · pantai. Punya *terrain-map* untuk Tiled | [tautan](https://opengameart.org/content/lpc-terrains) |
| **[LPC] Terrain Repack** | ✅ ya | CC-BY-SA 3.0 + GPL 3.0 | 32px | kemasan ulang terrain | [tautan](https://opengameart.org/content/lpc-terrain-repack) |
| **LPC Tile Atlas** — adrix89 | ✅ ya | CC-BY-SA 3.0 **atau** GPL 3.0 | **32×32**, atlas 1024² | `base_out` (luar ruang) + `terrain` (terrain/tani/vegetasi) | [tautan](https://opengameart.org/content/lpc-tile-atlas) |
| **LPC Collection** | ✅ ya | campuran LPC | 32px | memuat **LPC City inside** & **House Insides** → **interior** | [tautan](https://opengameart.org/content/lpc-collection) |
| **LPC: Modified base tiles** | ✅ ya | CC-BY 3 / CC-BY-SA 3 / **OGA-BY 3** / GPL — pilih | 32px | ubin dasar; wajib kredit Lanea Zimmerman (Sharm) | [tautan](https://opengameart.org/content/lpc-modified-base-tiles) |
| **[LPC Revised] 4-Seasons Tilesets** | ✅ ya | **OGA-BY** (proyek Revised sengaja seragam OGA-BY) | 32px | 4 musim, siap Tiled | [tautan](https://opengameart.org/content/lpc-revised-fully-configured-4-seasons-tilesets-for-tiled-map-editor) |
| **Mage City Arcanos** — Hyptosis | kompatibel | **CC0** | 32px | kota: perkerasan, dinding batu, pagar, air mancur, bangku, tong, pohon | [tautan](https://opengameart.org/content/mage-city-arcanos) |
| **Dungeon Crawl 32×32** — Chris Hamons dkk | kompatibel | **CC0** | 32px | 3.000+ ubin, ortografis 3/4, perabot & fitur dungeon | [tautan](https://opengameart.org/content/dungeon-crawl-32x32-tiles) |
| **Hyptosis tile-art batches** | kompatibel | CC-BY 3.0 | 32px | campuran hutan/gurun/dungeon | [tautan](https://opengameart.org/content/lots-of-free-2d-tiles-and-sprites-by-hyptosis) |

**✅ SUDAH DI GUDANG (tak perlu diunduh):** `magecity.png` · `hyptosis_tile-art-batch-1/3/4/5` ·
`hyptosis_sprites-and-tiles-for-you` · `DungeonCrawl_ProjectUtumnoTileset` · `ground_tiles` ·
`Cliff_tileset` · `tilesetStart5` — semuanya di `assets_raw/lpc/`.

> ⚠ **Koreksi laporan lama saya.** Dua kali saya tulis "nol ubin 32px bersih di gudang".
> Salah dua kali: (1) Cainos "Pixel Art Top Down Basic" di `assets_raw/_extract/`,
> (2) seluruh daftar di atas di `assets_raw/lpc/`. Saya melewatkannya karena memindai nama
> pack tingkat atas dan **membuang seluruh folder `lpc/` sebagai "karakter LPC"** — padahal
> di dalamnya ada tileset non-karakter. Kesalahan menilai dari nama folder, lagi.

## 👹 MONSTER

| Pack | LPC-native | Lisensi | Ukuran | Catatan | URL |
|---|---|---|---|---|---|
| **[LPC] Monsters** — Charles Sanchez (CharlesGabriel) | ✅ **ya** | CC-BY-SA 3.0 (kontribusi penyumbang: OGA-BY 3.0) | LPC | animasi **serang** untuk monster basis LPC | [tautan](https://opengameart.org/content/lpc-monsters) |
| **50+ Monsters Pack 2D** | ✗ | **CC0** | — | 56 monster, sprite depan **dan** belakang | [tautan](https://opengameart.org/content/50-monsters-pack-2d) |
| **64×64 Creature Sprites** | ✗ | — (perlu dicek) | 64px | 10 makhluk | [tautan](https://opengameart.org/content/64x64-creature-sprites) |
| **5 Monsters Pack [64×64]** | ✗ | CC-BY 4.0 | 64px | idle/move/jump | [tautan](https://opengameart.org/content/5-monsters-pack-idle-move-jump-64x64) |

## ✨ EFEK / SPELL

| Pack | LPC-native | Lisensi | Ukuran | URL |
|---|---|---|---|---|
| **[LPC] Items and game effects** — Reemax dkk | ✅ **ya** | CC-BY-SA 3.0 · GPL 3.0/2.0 (bagian Reemax juga OGA-BY 3.0+) | **32×32** | [tautan](https://opengameart.org/content/lpc-items-and-game-effects) |
| **Extended LPC Magic pack** | ✅ ya | perlu dibaca | **128×128**, 16 frame | [tautan](https://opengameart.org/content/extended-lpc-magic-pack) |
| **2D Spell Effects** | kompatibel | perlu dibaca | — | [tautan](https://opengameart.org/content/2d-spell-effects) |

## 🎒 ITEM / IKON

| Pack | Lisensi | Catatan | URL |
|---|---|---|---|
| **[LPC] Items and game effects** | CC-BY-SA / GPL / OGA-BY | item tanah **dan** inventori, 32px — LPC-native | [tautan](https://opengameart.org/content/lpc-items-and-game-effects) |
| **700+ RPG Icons** | perlu dibaca | hitam-putih, mudah diwarnai ulang | [tautan](https://opengameart.org/content/700-rpg-icons) |
| **RPG Inventory Icons** | **CC0** | sedikit tapi bersih | [tautan](https://opengameart.org/content/rpg-inventory-icons) |
| **Basic RPG Item Icons (Free)** | perlu dibaca | ramuan, gulungan, peti | [tautan](https://opengameart.org/content/basic-rpg-item-icons-free) |

## 🔥 ELEMEN / STATUS

**Sudah lengkap & milik sendiri — jangan diganti.** `game/assets/game/ui/icons/element_*_32.png`
(17 elemen, 32px, dari `assets_raw/aetherion_original_assets_v1`). Sweep kemarin memverifikasi
17/17 ada. Ini satu-satunya kategori yang **tidak** perlu diburu.

---

## 🎯 GAP — apa yang gratis TIDAK tutup

| Kategori | Status gratis | Perlu beli? |
|---|---|---|
| Terrain luar ruang | ✅ **tertutup penuh** (LPC Terrains + Mage City + gudang) | tidak |
| Interior rumah | 🟡 **tipis** — hanya "LPC City inside"/"House Insides" di LPC Collection | **mungkin** |
| Bangunan desa (fasad utuh, bukan potongan dinding) | 🟡 **tipis** — LPC menyediakan ubin dinding/atap, **bukan** rumah jadi | **mungkin** |
| Monster | ✅ cukup (LPC Monsters + 50+ CC0) | tidak |
| Efek/spell | ✅ cukup | tidak |
| Ikon item | ✅ cukup | tidak |
| Ikon elemen | ✅ sudah milik sendiri | tidak |

**Rekomendasi beli — hanya satu, dan hanya kalau interior terasa kurang:**
**Tiny Tales** (Mega Tiles). Sebabnya: ia dijual untuk **RPG Maker MZ = petak 48×48**, paling
dekat ke 32px LPC (skala 1,5×, bukan 3×), dan lininya memang lengkap untuk interior + bangunan jadi.
**Time Fantasy** saya sarankan **jangan** — gayanya 16px, akan bentrok dengan LPC 32px.

⚠ Tapi **jangan beli dulu.** Interior LPC belum diuji berdampingan. Uji dulu
"LPC City inside"/"House Insides" di satu layar interior; beli hanya kalau gagal.

---

## Kepatuhan lisensi (Tugas 3)

`assets_publikasi/` **sudah siap** — 19 berkas: `LICENSE.txt` (CC-BY-SA 3.0), `LICENSE-4.0.txt`,
`CREDITS.md`, `README.md`, `characters/props/` (4 prop) dan `source_credits/` (9 berkas kredit verbatim).

**Yang belum:** aset **dunia** belum punya jalurnya. Struktur yang perlu ditambah begitu pack dunia masuk:
- `assets_publikasi/world/` + `source_credits/CREDITS_<pack>.txt` verbatim per pack
- baris per pack di `docs/ASSET_LOG.md` — **saat ini nol baris untuk magecity** (saya cek: 0 kecocokan)

⚠ **Perangkap SA yang harus disadari sejak sekarang:** [LPC] Terrains dan LPC Tile Atlas
**CC-BY-SA**. Begitu ubin itu dipakai, **tileset Aetherion dan setiap turunannya ikut SA** —
termasuk seni asli kita yang di-composite bersamanya. Mage City (**CC0**) dan LPC Revised
(**OGA-BY**) tidak menular. **Kalau ingin fleksibilitas maksimum, dahulukan CC0/OGA-BY
dan pakai CC-BY-SA hanya untuk celah yang benar-benar tak tertutup.** Ini bukan menolak
putusan #254 — hanya cara menjalankannya dengan pilihan tersisa sebanyak mungkin.

---

## Status `_charsys` (diminta: laporkan, jangan hapus)

**Tidak dihapus.** Masih dipanggil **7 berkas, 30 tempat** — `Player.gd` · `Villager.gd` ·
`Interactable.gd` (8 jenis NPC) · `CharacterCreator.gd` · `PlayerData.gd` (**bentuk simpanan!**) ·
`Main.gd` · `TestRunner.gd` (8 assertion mematok lebar 96px & 6 rambut).
Urutan migrasi aman + jebakannya: `reports/MIGRASI_CHARSYS.md`.
**Gerbang tetap 1026 lulus, 0 gagal.**
