# ASSET_INVENTORY — Inventaris Detail `assets_raw/`

> Katalog per-pack: sumber, pembuat, **LISENSI** (dicari di LICENSE/README/txt/PDF di dalam arsip),
> kategori, ukuran sprite, animasi, arah, perspektif, mutu, komentar. Survei 2026-07-16.
> **Aturan:** *lisensi tak ditemukan di dalam unduhan = "LISENSI TIDAK DIKETAHUI = JANGAN PAKAI"*.
> `assets_raw/` di-`.gitignore` (gudang mentah, tak pernah masuk build). Total gudang **5,6 GB**.

## Ringkasan arsip & folder
| Item | Ukuran | Entri | Audio | Status ekstraksi |
|---|---|---|---|---|
| Ninja_Adventure/ (folder) | 109 MB | 2234 | 188 | ✅ ter-ekstrak |
| Pixel_Crawler_Free_2.11/ (folder) | 3,9 MB | 372 | 0 | ✅ ter-ekstrak |
| kenney_fantasy-ui-borders/ (folder) | 726 KB | 286 | 0 | ✅ ter-ekstrak |
| 80-CC0-RPG-SFX/ (folder) | 2,1 MB | 80 | 80 | ✅ ter-ekstrak |
| aetherion_original_assets_v1/ (folder) | 253 KB | 69 | 0 | ✅ ter-ekstrak (milik proyek) |
| aetherion_asset_generators/ (folder) | 44 KB | 6 | 0 | ✅ ter-ekstrak (tooling) |
| files_1/ (folder) | 276 KB | 7 | 0 | ✅ ter-ekstrak (preview/mockup) |
| Pixel Art Top Down - Basic v1.2.3.zip | 2,6 MB | 17 | 0 | ✅ ekstrak → `_extract/` |
| Pixel Chest Pack.zip | 272 KB | 78 | 0 | ✅ ekstrak → `_extract/` |
| Minifantasy_Dungeon_SFX.zip | 5,3 MB | 62 | 62 | ⧗ list saja |
| kenney_ui-audio.zip (+dup " (1)") | 404 KB | 56 | 52 | ⧗ list + lisensi |
| kenney_input-prompts_1.5.zip | 4,9 MB | 4752 | 0 | ⧗ list saja |
| music-loop-bundle-*.zip (×9) | ~467 MB | ~286 | ~264 | ⧗ list + lisensi |
| 10 Ambient RPG Tracks.zip | 366 MB | 34 | 30 | ⧗ list + lisensi PDF |
| Free JRPG Music Pack.zip | 848 MB | 75 | 66 | ⧗ list + lisensi PDF |
| Fantasy RPG Music Vol. 2.zip | 755 MB | 91 | 87 | ⧗ list + lisensi PDF |
| Pixel RPG Music Pack.zip | 237 MB | 41 | 36 | ⧗ list + lisensi PDF |
| 8 Piano Tracks vol.2.zip | 239 MB | 28 | 24 | ⧗ list + lisensi PDF |
| Piano Instumental Loops.zip | 246 MB | 28 | 24 | ⧗ list + lisensi PDF |
| Pirate Music Pack Vol. 2.zip | 685 MB | 70 | 60 | ⧗ list + lisensi PDF |
| 30 Sci-fi Space Trakcs Music Pack.zip | 1,7 GB | 190 | 180 | ⧗ list + lisensi PDF |

> **Catatan metode:** pack musik multi-ratus-MB **tidak diekstrak penuh** (buang disk sia-sia untuk
> katalog). Nama track + berkas lisensi diambil via `unzip -l` / ekstrak-selektif berkas lisensi.
> Pack sprite/UI kecil **diekstrak penuh** untuk inspeksi visual. Semua tetap di `assets_raw/`
> (gitignored) — bisa diekstrak penuh kapan pun dibutuhkan.

---

## 1. Ninja Adventure — Asset Pack
- **Sumber/pembuat:** Pixel-boy (Aleksandr Makarov) & AAA — itch.io/ninja-adventure-asset-pack
- **LISENSI:** ✅ **CC0 1.0** (LICENSE.txt + README.md di dalam pack). Atribusi *dihargai, tak wajib*.
- **Kategori:** karakter · animal · boss/monster · tileset · item/weapon/food · UI · FX · audio (all-in-one)
- **Ukuran sprite:** **16×16** (dasar). Walk sheet 64×112 (4×7 dari 16px). Faceset/portrait **38×38**.
  Tileset 16px (mis. VillageAbandoned 320×192, Nature 384×336). Boss lebih besar (32–48px).
- **Animasi:** ✅ walk (4 frame/arah), idle, attack, dead; **4 arah** (down/up/left/right); SeparateAnim tersedia.
- **Perspektif:** **top-down tiga-perempat ringan**. **Mutu:** tinggi & sangat konsisten.
- **Komentar:** pack terlengkap & terkoheren di gudang; **gaya rumah de-facto** (dipakai build).
  Punya `TilesetVillageAbandoned` on-tema Ashbrook, OldMan/OldWoman untuk tokoh tua, Chicken/Cow/Pig/Dog,
  188 audio (Rain/Storm/Wind/River + 40 musik berlabel termasuk Lost Village/Melancholia/Lament).

## 2. Pixel Crawler — Free Pack 2.11
- **Sumber/pembuat:** Anokolisa — itch.io (Terms.txt di dalam pack)
- **LISENSI:** ⚠ **Custom (BUKAN CC)**. Boleh dipakai & diubah di proyek komersial/non-komersial;
  **TIDAK boleh dijual sebagai produk final**; **TIDAK boleh redistribusi aset mentah**. Kredit tak wajib.
  → **Aman untuk build game, TIDAK aman di-commit mentah ke repo publik.**
- **Kategori:** karakter modular (paper-doll), mob, NPC, tileset, props, ikon, senjata
- **Ukuran sprite:** ~**32px** (base body idle sheet 256×64 = 4 frame). **Animasi:** kaya —
  Idle/Walk/Run/Carry/Collect/Fishing/Death/Hit/Pierce, **4 arah**. **Perspektif:** top-down.
- **Mutu:** tinggi. **Komentar:** modular ideal untuk sistem berpakaian, TAPI 32px bentrok skala dengan
  Ninja 16px. Cadangan strategis, bukan untuk dicampur sekarang.

## 3. Pixel Art Top Down — Basic v1.2.3 (Cainos)
- **Sumber:** Cainos — docs.cainos.net/pixel-art-top-down-basic (Documentation.url)
- **LISENSI:** ❌ **TIDAK DITEMUKAN di unduhan** (hanya Changelog.txt + .url + .unitypackage).
  → **"LISENSI TIDAK DIKETAHUI = JANGAN PAKAI"** sampai diverifikasi dari halaman resmi.
- **Kategori:** tileset (grass/stone/wall), props, struct, plant, 1 player, shadow
- **Ukuran:** tile **32px** (grass tileset 256×256; player 128×128). **Animasi:** minim (player saja).
  **Perspektif:** **top-down tiga-perempat kuat** — paling dekat referensi Suikoden. **Mutu:** sangat tinggi.
- **Komentar:** paket **format Unity** (.unitypackage). **Tanpa karakter.** Kandidat REFERENSI GAYA,
  bukan aset pakai — kecuali lisensi jelas & tim siap re-art karakter senada.

## 4. Pixel Chest Pack (karsiori)
- **Sumber:** karsiori — itch.io. **LISENSI:** ❌ **tak ada berkas lisensi di dalam zip** →
  **TIDAK DIKETAHUI = JANGAN PAKAI (commit)** sampai diverifikasi. *(ASSET_LOG root menandainya "free,
  komersial OK, redistribusi mentah TIDAK" — sumber klaim itu perlu dikonfirmasi ulang; bukan dari file.)*
- **Kategori:** peti beranimasi (Golden×3, Metal, Retro, Wooden×2). **Animasi:** buka/tutup (4–11 frame).
  **Ukuran:** ~32–48px. **Mutu:** tinggi. **Komentar:** dipakai build (v0.4.3) — verifikasi lisensi.

## 5. kenney_fantasy-ui-borders
- **Sumber:** Kenney (kenney.nl), 2023. **LISENSI:** ✅ **CC0** (License.txt). Kredit dihargai, tak wajib.
- **Kategori:** UI 9-slice border/panel (282 PNG). **Perspektif:** UI. **Mutu:** tinggi, netral.
- **Komentar:** lapisan UI aman di atas gaya apa pun.

## 6. kenney_input-prompts 1.5
- **Sumber:** Kenney. **LISENSI:** ✅ **CC0** (pola Kenney). **Kategori:** glyph tombol keyboard/mouse/
  gamepad (4752 file, banyak varian konsol). **Komentar:** ⚠ glyph konsol (Switch/PS/Xbox) membawa
  **merek dagang pihak ketiga** — pakai set generik/keyboard untuk aman; hindari logo konsol di rilis.

## 7. kenney_ui-audio (ada duplikat "kenney_ui-audio (1).zip" — identik)
- **Sumber:** Kenney. **LISENSI:** ✅ **CC0** (License.txt). **Kategori:** 52 SFX UI (klik/hover/konfirmasi).
- **Komentar:** hapus salah satu duplikat. Aman repo publik.

## 8. 80-CC0-RPG-SFX
- **Sumber:** koleksi OpenGameArt (nama folder). **LISENSI:** ✅ **CC0** (klaim per-koleksi; **verifikasi
  sumber asli tiap file sebelum rilis** — koleksi CC0 kadang mengandung item lisensi campuran).
- **Kategori:** 80 SFX (blade/coin/gem/creature/spell_fire). **Mutu:** baik. **Komentar:** dipakai build.

## 9. Minifantasy — Dungeon SFX
- **Sumber:** Leohpaz/Krishna Palacio (nama pack). **LISENSI:** ❌ **TIDAK ADA berkas lisensi di dalam
  zip** → **"LISENSI TIDAK DIKETAHUI = JANGAN PAKAI (commit)"**. *(Minifantasy umumnya CC-BY 4.0 di
  halaman itch, tapi TIDAK dibuktikan oleh isi unduhan ini — minta owner sertakan berkas lisensinya.)*
- **Kategori:** 62 SFX dungeon (chest/door/trap/step/human-atk). **Komentar:** dipakai build — perlu bukti lisensi.

## 10. AlkaKrab — 8 pack musik
*(Free JRPG · Fantasy RPG Vol.2 · Pixel RPG · 10 Ambient RPG · 8 Piano Vol.2 · Piano Instrumental Loops ·
Pirate Vol.2 · 30 Sci-fi Space)*
- **Sumber/pembuat:** AlkaKrab — itch.io (alkakrab04@gmail.com). **LISENSI:** ⚠ **"Music License
  Agreement" PDF** di tiap pack: royalty-free, **komersial OK, kredit dihargai tak wajib**, **TAPI**:
  *No reselling/redistribution of the track as-is; **untuk game open-source hubungi penulis untuk izin**;
  no upload ke platform streaming; remix/sampling perlu izin.*
- **Kategori:** musik (fantasy/piano/pirate/sci-fi). **Mutu:** produksi tinggi.
- **Komentar:** 🔴 **KONFLIK REPO PUBLIK** — file mentah AlkaKrab ter-commit di build = redistribusi
  as-is dalam proyek open-source → butuh izin/privat. Lihat peringatan legal di ASSET_ARCHAEOLOGY §D.

## 11. Abstraction — Music Loop Bundle (pre2023, 2024 Q1–Q4, 2025 Q4, 2026 Q2, chiptune, song-browser)
- **Sumber/pembuat:** Abstraction / Tallbeard Studios (Benjamin Burnes) — tallbeard.itch.io/music-loop-bundle
- **LISENSI:** ✅ **CC0** (_LICENSE.txt). Kredit "Abstraction" dihargai, tak wajib. *(Penulis meminta —
  bukan syarat legal — tidak dipakai untuk NFT/AI/resale-mentah.)*
- **Kategori:** ~264 loop musik (mis. "Ludum Dare 28/30/32…", chiptune). **Mutu:** tinggi. OGG+MP3.
- **Komentar:** ✅ **bank musik teraman & terbesar** — pengganti CC0 langsung untuk AlkaKrab pada apa pun
  yang perlu ter-commit ke repo publik.

## 12. Aetherion Original Assets v1 + Asset Generators (milik proyek)
- **Sumber:** proyek ini (README_ASSET_AETHERION.txt / README_GENERATOR.txt). **LISENSI:** milik proyek
  (perlakukan CC0-kita). **Kategori:** 17 ikon elemen · 12 rasi (96px) · 8 fase bulan · tileset candyveil ·
  fire_vfx · palette · generator Python. **Mutu:** placeholder-ke-baik. **Komentar:** ikon elemen & rasi
  **unik (tak ada padanan di pack lain)** — pertahankan; candyveil tileset = placeholder.

## 13. files_1/ (preview & duplikat)
- Berisi `aetherion_original_assets_v1.zip` (duplikat folder #12) + mockup/preview PNG. **Bukan aset baru.**
