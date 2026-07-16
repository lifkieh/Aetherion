# ASSET_LOG (docs) — Legal per-ITEM untuk `assets_aetherion/`

> **Dasar audit legal publik.** Satu baris per item/kelompok yang **benar-benar disalin** ke
> `assets_aetherion/` (folder kurasi, di-commit). **Tak ada baris kosong.** Semua item di sini
> **CC0 atau milik proyek** → **aman untuk repo publik**. Item lisensi tak jelas / restricted
> (Cainos, Pixel Crawler, Pixel Chest, Minifantasy, AlkaKrab) **sengaja TIDAK disalin ke sini**.
>
> Beda dengan **`../ASSET_LOG.md` (root)** = log per-PACK untuk pipeline lama `game/assets/game/`.
> Dokumen ini = log per-ITEM untuk gudang kurasi `assets_aetherion/`. Disusun 2026-07-16.
>
> **Status pemakaian:** semua item = **"Terkurasi — belum di-wire ke scene"** (batas tugas: dilarang
> memasang ke scene). "Lokasi rencana" = niat desain, bukan wiring aktual.

Legend lisensi: **CC0** = domain publik, tanpa kewajiban. **Milik proyek** = dibuat Aetherion.

## ⚖ KEBIJAKAN LISENSI (Fase 1 — arahan Direktur 2026-07-16)
Aetherion **proyek komersial** (GDD §15: battle pass, Aether Shard). Karena itu:
1. **CC-BY-NC / NC apa pun = TOLAK.** NC = tak boleh dijual → mustahil untuk kita. Jebakan
   paling umum di itch.io "free assets". *(Hasil scan gudang: **nol** aset NC ditemukan.)*
2. **CC-BY-SA / GPL = FLAG KUNING, bukan hijau.** Share-alike bisa menular ke turunan.
   **Dipisah** di seksi tersendiri di bawah, **tak pernah dicampur dengan CC0.** *(Hasil scan:
   **nol** aset SA/GPL di set terkurasi saat ini.)*
3. **OpenGameArt/koleksi = cek PER-FILE, bukan per-halaman/per-folder.** Satu submission sering
   berlisensi campur. **Nama folder BUKAN lisensi.**
4. **Lisensi ada tapi ambigu ("free to use") / hanya diklaim nama = TIDAK DIKETAHUI = TOLAK.**
   "Free" bukan lisensi.
5. **Kenney = CC0, aman** — tetap dicatat.

**Verifikasi set terkurasi `assets_aetherion/`:** ketiga sumber di bawah = **CC0 dibaca dari BERKAS
lisensi di dalam pack** (bukan dari nama): Ninja `LICENSE.txt` · Kenney `License.txt` · (Abstraction
`_LICENSE.txt`, bila loop dipakai). **Set terkurasi lolos kelima aturan — nol NC, nol SA/GPL, nol ambigu.**

## Karakter — semua Ninja Adventure (Pixel-boy & AAA) · CC0 · kredit tak wajib · no share-alike
| File | Asal pack | Pembuat | Lisensi | Kredit | Share-alike | Lokasi rencana |
|---|---|---|---|---|---|---|
| `characters/Villager{,-2..6}/SpriteSheet.png` + `Faceset.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib (dihargai) | Tidak | Warga dewasa Ashbrook |
| `characters/Woman/{SpriteSheet,Faceset}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Warga dewasa (Lyra) |
| `characters/Noble/{SpriteSheet,Faceset}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Warga khas/pedagang |
| `characters/OldMan{,2,3}/{SpriteSheet,Faceset}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Merrit Fane, Old Bram |
| `characters/OldWoman/{SpriteSheet,Faceset}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Warga tua |
| `characters/Child/{SpriteSheet,Faceset}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Anak-anak bermain (3) |
| `characters/Princess/{SpriteSheet,Faceset}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Cadangan tokoh khas |

## Hewan — Ninja Adventure · CC0
| File | Asal pack | Pembuat | Lisensi | Kredit | Share-alike | Lokasi rencana |
|---|---|---|---|---|---|---|
| `animals/Chicken/SpriteSheet{Black,Brown,Cute,White}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | 4 ayam Ashbrook |
| `animals/Cow/SpriteSheetWhite{,Side}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Ternak desa |
| `animals/Pig/SpriteSheet{Black,Pink,Red}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Ternak desa |
| `animals/Dog/SpriteSheet.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Anjing desa |

## Tileset — Ninja Adventure · CC0
| File | Asal pack | Pembuat | Lisensi | Kredit | Share-alike | Lokasi rencana |
|---|---|---|---|---|---|---|
| `tilesets/TilesetVillageAbandoned.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | **Ashbrook (permata tema)** |
| `tilesets/TilesetHouse.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Rumah desa |
| `tilesets/TilesetNature.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Batas hutan, pohon |
| `tilesets/TilesetField.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Tanah rumput/kebun |
| `tilesets/TilesetWater.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Sungai Ashbrook |
| `tilesets/TilesetRelief{,Detail}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Tebing/jembatan |
| `tilesets/TilesetFloor{,Detail}.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Interior rumah singgah |

## Objek — Ninja Adventure · CC0
| File | Asal pack | Pembuat | Lisensi | Kredit | Share-alike | Lokasi rencana |
|---|---|---|---|---|---|---|
| `objects/Book.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Surat/buku Merrit |
| `objects/CrateEmpty.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Peti kosong desa |
| `objects/Bag.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Karung/barang |

## Audio — Ninja Adventure · CC0
| File | Asal pack | Pembuat | Lisensi | Kredit | Share-alike | Lokasi rencana |
|---|---|---|---|---|---|---|
| `audio/ambient/Rain.wav`, `Rain2.wav`, `Storm.wav` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Opening (hujan memimpin) |
| `audio/ambient/Wind.wav` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Ambience malam Ashbrook |
| `audio/ambient/River.wav` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Sungai/jembatan |
| `audio/music/26 - Lost Village.ogg` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Tema Ashbrook (utama) |
| `audio/music/16 - Melancholia.ogg` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Momen lampu/malam |
| `audio/music/29 - Lament.ogg` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Cadangan sedih |
| `audio/music/33 - Calm Village.ogg` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Siang hari desa |
| `audio/music/7 - Sad Theme.ogg` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Cadangan cerita |
| `audio/sfx/Accept{,2}.wav`, `Cancel{,2}.wav` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | SFX menu/UI |

## UI
| File | Asal pack | Pembuat | Lisensi | Kredit | Share-alike | Lokasi rencana |
|---|---|---|---|---|---|---|
| `ui/ninja_theme_wood/*.png` (42) | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Tema UI kayu (panel/tombol/slider) |
| `ui/kenney_fantasy_borders/panel-border-0{00..29}.png` (30) | Kenney Fantasy UI Borders | Kenney (kenney.nl) | CC0 1.0 | Tak wajib (dihargai) | Tidak | Border 9-slice panel |

## _reference (patokan, bukan aset pakai)
| File | Asal pack | Pembuat | Lisensi | Kredit | Share-alike | Lokasi rencana |
|---|---|---|---|---|---|---|
| `_reference/_HERO_abandoned_village_tileset.png` | Ninja Adventure | Pixel-boy & AAA | CC0 1.0 | Tak wajib | Tidak | Patokan mood Ashbrook |
| `_reference/aetherion_palette_v1.png` | Aetherion Original v1 | Proyek Aetherion | Milik proyek | — | Tidak | Patokan palet |
| `_reference/aetherion_candyveil_mockup.png` | Aetherion Original v1 | Proyek Aetherion | Milik proyek | — | Tidak | Patokan gaya candyveil |
| `_reference/siluet_test_ninja_cc0.png` | Ninja Adventure (komposit) | Pixel-boy & AAA + Aetherion | CC0 1.0 | Tak wajib | Tidak | Bukti tes siluet (ARCHAEOLOGY §G) |
| `_reference/README_reference.md` | — (dokumen) | Proyek Aetherion | Milik proyek | — | Tidak | Catatan referensi |

---

## Kewajiban kredit terkumpul (bila kredit disertakan di rilis — semua opsional untuk item di atas)
- **Pixel-boy & AAA** — "Ninja Adventure" asset pack (CC0, kredit dihargai).
- **Kenney (kenney.nl)** — Fantasy UI Borders (CC0, kredit dihargai).
- **Aetherion** — aset milik proyek.

## 🟡 FLAG KUNING — CC-BY-SA / GPL (dipisah dari CC0; share-alike menular)
*(Kosong. Tak ada aset SA/GPL di gudang saat ini. Seksi ini dijaga tetap ada: bila kelak masuk
aset SA/GPL, ia **wajib** dicatat DI SINI, tak pernah dicampur dengan tabel CC0 di atas.)*

## 🔴 DITOLAK / DITAHAN — TIDAK DIKETAHUI, restricted, atau NC (jangan commit/pakai tanpa keputusan)
| Item | Masalah lisensi | Aksi |
|---|---|---|
| **80-CC0-RPG-SFX** (⚠ **DI BUILD SEKARANG** `game/assets/game/audio/sfx/`) | **Nol berkas lisensi** di unduhan — "CC0" hanya di **nama folder** (aturan #3/#4: nama ≠ lisensi, koleksi = per-file). | **Minta owner: URL sumber + bukti lisensi per-file.** Bila tak ada → ganti SFX dengan CC0 terbukti (Kenney UI-audio / Ninja Sounds). |
| **Minifantasy Dungeon SFX** (di build) | Nol berkas lisensi di unduhan | Minta berkas lisensi itch (umumnya CC-BY 4.0 — belum terbukti dari unduhan). |
| **Cainos Top-Down** | Nol berkas lisensi di unduhan | Verifikasi dari halaman resmi sebelum pakai. |
| **Pixel Chest** (di build) | Nol berkas lisensi di zip | Minta bukti lisensi karsiori. |
| **AlkaKrab** ×8 (9 OGG di build) | Restricted: no redistribusi as-is / open-source tanpa izin | Ganti ke CC0 (Abstraction/Ninja) untuk repo publik, atau minta izin. |
| **Pixel Crawler** | Restricted (tak boleh redistribusi mentah) — bukan CC | Boleh di build, **jangan commit mentah**. |

> **Catatan stash kedua:** `.vscode/assets_raw_new/` memuat `48x48_Faces..._OGA.png` (OpenGameArt) —
> **wajib cek lisensi per-file** sebelum dipakai (aturan #3). Belum diinventaris.
> Detail penuh: `../reports/ASSET_ARCHAEOLOGY.md` §D + `../reports/ASSET_INVENTORY.md`.
