# ASSET_LOG — Aetherion

One row per source pack. `assets_raw/` is never edited. Used assets are copied
(normalized, Nearest filter) into `game/assets/game/`. See `ASSET_CATALOG.md`
for exact per-file picks and layouts.

| Pack | Author / Source | License | Attribution req. | Used for | Status |
|---|---|---|---|---|---|
| Ninja Adventure - Asset Pack | Pixel-boy / Aleksandr Makarov (itch.io) | CC0 1.0 | No | Player (NinjaGreen), monsters (Slime/Mouse/Beast), tilesets (Field/Nature), props, UI wood theme, SFX jingles, music | In use |
| Kenney Fantasy UI Borders | Kenney (kenney.nl) | CC0 | No (appreciated) | UI 9-slice panels/borders (M8 UI) | Reserved |
| 80 CC0 RPG SFX | OpenGameArt collection | CC0 (per folder; verify src pre-release) | No | Combat/UI SFX (blade, coin, slime, hit, mine) | In use |
| Pixel Crawler - Free Pack 2.11 | Anokolisa (itch.io) | Custom — usable in-game, NOT redistributable, NOT CC0 | No | Fallback only; not shipped as raw art | Fallback |
| m5x7 font | Daniel Linssen (managore) | Free, embedding OK | Credit appreciated | HUD/UI pixel font | In use |
| Aetherion Original Assets v1 | Project-owned (this project) | Proprietary (ours) | — | 17 element icons, 8 moon phases, 12 constellations, Fluffbit/Moonbit, Candyveil tiles, fire_flow VFX, Star Whale, palette | In use |
| Aetherion Asset Generators | Project-owned | Proprietary (ours) | — | Python/Pillow procedural generators (icons, sky, world, palette) | Tooling |
| **Pixel Chest Pack** | karsiori (itch.io) | Free asset pack — penggunaan komersial diizinkan; redistribusi mentah TIDAK | Kredit dianjurkan | Sprite peti dungeon: Retro=umum, Metal=langka, Golden=rahasia (tutup+buka) | **In use** (v0.4.3 #92) |
| **Pixel Art Top Down — Basic v1.2.3** | Cainos (itch.io) | Free (CC-BY-style; kredit dianjurkan) — cek berkas lisensi pack sebelum rilis | Ya (kredit Cainos) | — | **DINILAI ULANG & DITOLAK untuk parallax dungeon (#98):** pack ini **top-down**, dungeon kita **side-view** — dindingnya tak punya sisi yang terlihat dari samping. Parallax dibuat prosedural. Tetap **Reserved** sebagai kandidat dressing untuk area top-down (kota/overworld) bila palet diselaraskan |
| **Minifantasy — Dungeon SFX** | Leohpaz (itch.io) | Free untuk pemakaian di game (komersial OK); redistribusi mentah TIDAK | Kredit dianjurkan | SFX: peti terbuka, pintu batu (ruang rahasia), jebakan paku, jebakan panah, peti kayu, langkah batu | **In use** (v0.4.3 #92) |
| **kenney_ui-audio** | Kenney (kenney.nl) | CC0 | Tidak (dihargai) | SFX antarmuka (klik/hover/konfirmasi) | **Reserved → v0.4.4** (UI transition pass) |
| **kenney_input-prompts 1.5** | Kenney (kenney.nl) | CC0 | Tidak (dihargai) | Glyph tombol keyboard/gamepad | **Reserved → v0.4.4** (gamepad + keybind remap) |
| **AlkaKrab — Fantasy RPG Music Vol. 2** | AlkaKrab (itch.io) | Lisensi pack (PDF disertakan): pakai di game OK, kredit wajib; redistribusi mentah TIDAK | **Ya — wajib kredit AlkaKrab** | Musik: `greenvale` (Light Ambient 1), `desert` (Ambient 6), `storm` (Action 2), `dungeon` (Night Ambient 3), `boss` (Action 4) + **stinger** (Victory/Complete/Strange dipotong) | **In use** (v0.4.3 #92) |
| **AlkaKrab — Free JRPG Music Pack** | AlkaKrab (itch.io) | Sda. | **Ya** | Musik: `menu` (Immortal Dream), `frostpeak` (Frostfire Tales) | **In use** |
| **AlkaKrab — Pixel RPG Music Pack** | AlkaKrab (itch.io) | Sda. | **Ya** | Musik: `town` (Pixel 3), `candyveil` (Pixel 5) | **In use** |
| **AlkaKrab — 10 Ambient RPG Tracks** | AlkaKrab (itch.io) | Sda. | **Ya** | Cadangan ambience wilayah (belum dipakai) | **Reserved** |
| **AlkaKrab — Piano Instrumental Loops / 8 Piano Vol.2** | AlkaKrab (itch.io) | Sda. | **Ya** | Cadangan: momen cerita/Chronicle (v0.5) | **Reserved → v0.5** |
| **AlkaKrab — Pirate Music Pack Vol. 2** | AlkaKrab (itch.io) | Sda. | **Ya** | **Disimpan untuk Kerajaan Thalassar** (v0.7 HORIZON, #90) | **Reserved → v0.7** |
| **AlkaKrab — 30 Sci-fi Space Tracks** | AlkaKrab (itch.io) | Sda. | **Ya** | **Disimpan untuk tema Celestial / Void / supernova** (v0.8 CELESTIA & CRISIS) | **Reserved → v0.8** |
| **Abstraction — music-loop-bundle** (pre2023, 2024 Q1–Q4, 2025 Q4, 2026 Q2, chiptune) | Abstraction (abstractionmusic.com) | Free untuk pemakaian komersial dengan kredit | **Ya — kredit Abstraction** | Cadangan ambience overworld per bioma | **Reserved** — belum dipakai (bank musik AlkaKrab sudah menutupi kebutuhan v0.4.3; dinilai ulang saat pass ambience) |

## Kebijakan audio (v0.4.3 #92)
- **Pack musik mentah = WAV bergiga; tak pernah masuk build.** Kurasi ketat: 9 track
  terpilih + 5 stinger dipotong, di-encode ulang ke **OGG Vorbis** (musik `-q:a 1`
  ≈ 80–96 kbps; stinger/SFX `-q:a 3`). Sisanya tetap di gudang `assets_raw/`.
- **Total audio di build: ~11 MB** (batas yang ditetapkan owner: <25 MB). Rincian:
  musik 9 track ≈ 10 MB · stinger 5 ≈ 0,26 MB · SFX ≈ 1 MB.
- **Kredit WAJIB di layar kredit rilis:** AlkaKrab (musik), Leohpaz (Minifantasy SFX),
  karsiori (Pixel Chest Pack), Kenney (UI/input prompts), Cainos (bila props dipakai),
  Abstraction (bila loop dipakai), Pixel-boy (Ninja Adventure).
- 3 track lama Ninja Adventure (`11 - Clearing`, `23 - Road`, `26 - Lost Village`)
  **dihapus dari build** — digantikan bank musik baru (menghemat ~3,2 MB).

## #277 — ATURAN LISENSI VISUAL (berlaku 2026-07-20, mengamandemen #232)

**Semua aset VISUAL boleh CC-BY-SA — karakter, dunia, DAN prop.** Hukum pembatas
lama (*“SA cuma untuk sprite karakter; dunia harus non-viral”*) **DICABUT**.

Sebabnya terukur, bukan preferensi: audit gudang (64 zip, tiap kandidat dibuka dan
dilihat) menemukan aset dunia bergaya LPC **hampir seluruhnya CC-BY-SA/GPL**,
sementara yang non-viral gugur karena **gaya**, bukan lisensi — pack CC0 berskala
peta-dunia 14–16 px, isometrik 128 px, atau bukan pixel art sama sekali. Hukum
pembatas lama tidak menjaga apa pun; ia melarang satu-satunya pilihan yang ada.

**Yang TETAP mengikat:**
- **Kode dan naratif TIDAK SA.** Itu garis yang membuat amandemen ini aman.
- **Atribusi wajib untuk TIAP aset**, tanpa kecuali — `_tools/lpc_assembler/credits_db.json`
  (per-lapisan) + tabel di berkas ini (per-pack) + `LICENSE-CC-BY-SA.txt` yang terbit
  bersama sprite.
- **UI / musik / SFX / ikon TIDAK ikut dibebaskan** oleh baris ini; tetap dinilai per-pack.

| Pack | Author / Source | License | Attribution req. | Used for | Status |
|---|---|---|---|---|---|
| **[LPC] Farming tilesets, magic animations and UI elements** | Daniel Eddeland (daneeklu) — opengameart.org | CC-BY-SA 3.0 / GPL 3.0 | **Ya — WAJIB: “Daniel Eddeland (daneeklu)” + tautan OpenGameArt** | Ashbrook64 pinggir (#277): `fence.png` pagar lapuk · `plowed_soil.png` ladang berhenti digarap · `tallgrass.png` rumput yang menutupinya | **In use** |
| **LPC Character Bases v3.1** | BenCreating, Redshrike, dalonedrau, Durrani, ElizaWy, wulax, kheftel, madmarcel, makrohn, MuffinElZangano, Nila122, bluecarrot16, castelonia, pvigier, Evert, William.Thompsonj, Zi Ye | CC-BY-SA 3.0 / GPL 3.0 | **Ya** | Badan/kepala 6 NPC bernama + 3 anak + 20 warga | **In use** |
| **[LPC Expanded] Hair** | JaidynReiman, bluecarrot16, ElizaWy, Nila122, Fabzy, thecilekli, dkk. | CC-BY-SA 3.0 | **Ya** | Rambut semua tokoh LPC (kolam warna seimbang) | **In use** |
| **Universal LPC Spritesheet Generator — pakaian & topi modular** | Kontributor ULPC (daftar per-lapisan belum terbaca dari disk — zip hanya berisi PNG) | CC-BY-SA 3.0 / GPL 3.0 | **Ya (tingkat-pack; penelusuran seniman = utang-rilis)** | Kemeja, celana, sepatu, topi, hood, hijab | **In use** |
| **Aetherion — lapisan gambar-sendiri** | Proyek (gen_overlays.py / gen_pelataran.py) | CC-BY-SA 3.0 (KARYA TURUNAN dari siluet LPC — SA ikut menempel) | — | Tunik anak, pelataran alun-alun, fondasi rumah runtuh | **In use** |

## Hewan (katalog `_tools/katalog_hewan.json`, generator `_tools/gen_hewan.py`)

| Pack | Author / Source | License | Attribution req. | Used for | Status |
|---|---|---|---|---|---|
| **Stendhal Animals** (git 99362c8) | **Kimmo Rundelin (kiheru)** — https://opengameart.org/node/81251 | CC-BY-SA 3.0 atau lebih baru | **Ya — WAJIB** | `domba` (domba jantan bertanduk) — menggantikan "kambing" yang sebenarnya sprite ayam di-tint | **In use** |
| **Wild Animals** (berkas gudang `All.zip`) | **TIDAK TERCATAT** — zip sumber nol berkas kredit | **TIDAK TERCATAT** | tak bisa ditentukan | `serigala` (hias + `DungeonMonster` #118), `rusa` (white stag) | **In use — UTANG KREDIT** |
| Ninja Adventure - Asset Pack | Pixel-boy / Aleksandr Makarov | CC0 1.0 | Tidak | `ayam` | **In use** |

> ⚠ **`All.zip` tak memuat berkas lisensi maupun kredit apa pun.** Dipakai dengan
> atribusi tingkat-pack dan ditandai `terverifikasi: false`, mengikuti preseden empat
> pack ULPC yang Direktur terima sebagai utang-rilis. **Bedanya penting dan tak boleh
> dikaburkan:** pack ULPC lisensinya DIKETAHUI (CC-BY-SA) dan cuma daftar senimannya
> yang belum ditelusuri; `All.zip` **lisensinya sendiri tidak diketahui**. Ini harus
> diselesaikan sebelum rilis — cari sumber asli, atau ganti aset serigala & rusa.
>
> **NOL kambing di seluruh 111 zip gudang** (sisiran nama berkas). Domba adalah ternak
> berkaki empat bergaya LPC satu-satunya yang benar-benar ada.

## Notes
- `aetherion_palette_v1.png` is the canonical 53-colour palette; procedural assets follow it.
- Root archive `eyJleHBpcmVz...==.6lkCYto...` is an **expired itch.io download** (HTML error page, not an asset) — see BLOCKED.md.
- `.rar` VFX packs (Dark VFX 01-02, Smear VFX 01) not yet extracted (no rar tool) — see BLOCKED.md.
- CREDITS.md is generated from this log before any release.
