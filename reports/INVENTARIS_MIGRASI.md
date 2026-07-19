# INVENTARIS GUDANG untuk MIGRASI VISUAL PENUH (#254)

**2026-07-19** · read-only · **nol perbaikan**. SA diterima; atribusi tetap wajib → `docs/ASSET_LOG.md`.

## Ukuran gudang

| folder | PNG | MB |
|---|---|---|
| `assets_raw/lpc` | 6.062 | 49,0 |
| `assets_raw/lpc_extra` | 5.923 | 41,7 |
| `assets_raw/lpc_extra2` | 358 | 52,1 |
| `assets_raw/Ninja_Adventure` | 1.915 | 4,0 |
| `assets_raw/objek_terpilih` | 93 | 0,3 |
| `assets_raw/_extract` | 72 | 1,4 |

**133 lembar lebar-832** di `lpc_extra` = lapisan ULPC siap dirakit `assemble.py`.

---

## Status per kebutuhan

| kebutuhan | status | sumber di gudang | lisensi | URL |
|---|---|---|---|---|
| **KARAKTER** (base·rambut·baju·ras) | ✅ **ADA, berlimpah** | `lpc_extra/eulpc_*` (133 lembar 832px) + `lpc/_ex/lpc_bases` | CC-BY-SA 3.0/4.0 + GPL + OGA-BY | `assets_publikasi/CREDITS.md` + `source_credits/` (9 berkas) |
| **DUNIA — kota/tanah** | 🟡 **SEBAGIAN** | `lpc/magecity.png` (8×45 petak 32px) — sudah dipotong 13× | **CC0** | https://opengameart.org/content/mage-city-arcanos |
| **DUNIA — terrain luas** | 🟡 **SEBAGIAN** | `lpc/hyptosis_tile-art-batch-1/3/4/5` (960×960, 30×30 petak) | CC-BY 3.0 | https://opengameart.org/content/lots-of-free-2d-tiles-and-sprites-by-hyptosis |
| **DUNIA — dungeon** | ✅ **ADA** | `lpc/DungeonCrawl_ProjectUtumnoTileset.png` (64×48 petak 32px) | **CC0** | https://opengameart.org/content/dungeon-crawl-32x32-tiles |
| **DUNIA — interior** | 🔴 **KOSONG** | — | — | kandidat: **LPC Collection** (*City inside* / *House Insides*) |
| **BANGUNAN fasad utuh** | 🔴 **KOSONG** | magecity hanya panel dinding/atap terpisah | — | kandidat: **[LPC] Terrains** / LPC Tile Atlas |
| **MONSTER** | 🟡 **SEBAGIAN** | `lpc/_ex/lpc_bases/bodies/{skeleton,zombie}` + heads `{orc,skeleton,zombie}` — **humanoid saja** · Ninja Adventure 133 sprite (16px, gaya lain) | LPC: SA/GPL/OGA-BY · Ninja: CC0 | kandidat: **[LPC] Monsters** https://opengameart.org/content/lpc-monsters |
| **EFEK / SPELL** | 🟡 **SEBAGIAN** | Ninja Adventure `FX/{Particle 15, Projectile 14, Slash 6}` (16px) · `aetherion_original/vfx` 9 | CC0 · milik sendiri | kandidat: **[LPC] Items and game effects** · **Extended LPC Magic** |
| **ITEM / IKON** | ✅ **ADA** | Ninja Adventure `Ui/Skill Icon/*` (Spell 64 · Items&Weapon 24 · Job&Action 24) · `aetherion_original/icons` 20 | CC0 · milik sendiri | — |
| **IKON ELEMEN** | ✅ **ADA & MILIK SENDIRI** | `game/assets/game/ui/icons/element_*_32.png` (17) | proyek | **jangan diganti** |
| **UI frame/dialog** | 🟡 **SEBAGIAN** | Kenney fantasy-ui-borders (128 × 48px) · Ninja `Ui/Dialog` 8 | CC0 | — |
| **UI Kitab (Chronicle)** | 🔴 **KOSONG** | `book` 21 hit semuanya **ikon skill/senjata**, bukan UI buku | — | perlu digambar sendiri atau cari |
| **PORTRAIT** | 🔴 **KOSONG** | nol | — | **#255 — ditangguhkan sengaja, buatan sendiri** |

---

## Ringkas

- **✅ ADA (4):** karakter · dungeon tileset · item/ikon · ikon elemen
- **🟡 SEBAGIAN (5):** kota/terrain · monster · efek · UI frame · *(bangunan panel-saja)*
- **🔴 KOSONG (4):** interior · fasad bangunan utuh · UI Kitab · portrait

**Nol pembelian diperlukan.** Empat yang kosong semuanya punya kandidat gratis LPC
(kecuali portrait, yang memang diputuskan buatan sendiri #255) — daftar terverifikasi
di `reports/BURU_ASET_64.md`.

⚠ **Kategori paling mendesak untuk jalur pemain nyata: KARAKTER** — dan itu satu-satunya
yang **berlimpah**. Migrasi jalur Play tidak terhambat aset sama sekali.
