# OBJEK_KURASI2 — Kurasi Objek/Prop dari `assets_raw_new_2`

**Tanggal:** 2026-07-18 · **Sifat:** ARSIP TERARAH, bukan produksi
**Batas dipatuhi:** nol perubahan `game/`, nol gambar baru, nol wire, nol scene.
Keluaran = laporan ini + `assets_raw/objek_terpilih/` (gitignored).

Lingkup: **objek / prop / tileset / FX** saja. Lapisan karakter dari batch ini
sudah diaudit di `reports/LPC_EXTRA_KURASI.md` (#233) — tidak diaudit ulang.

---

## FASE 0 — AMANKAN ✅

| Hal | Hasil |
|---|---|
| Asal | `C:\Users\user\OneDrive\Desktop\assets_raw_new_2` (**tetap utuh**, disalin bukan dipindah) |
| Tujuan | `assets_raw/lpc_extra2/` |
| Salin | **72 berkas · 467,46 MB · 0 gagal** (robocopy) |
| Gitignore | ✅ terbukti — `git check-ignore` → `.gitignore:29: assets_raw/` |
| Ekstrak kerja | `assets_raw/lpc_extra2/_extract/` (5 pack kandidat, 343 berkas) |
| Terpilih | `assets_raw/objek_terpilih/` — ✅ juga gitignored (terbukti) |

**Rusak / tak terbaca (catat, jangan buang):**
`Tidak dipastikan 279939.crdownload` (25,5 MB) dan `Tidak dipastikan 62631.crdownload` (26,4 MB)
— unduhan Chrome **belum selesai**. Header ZIP `50-4B-03-04` ada, tapi *End of Central Directory*
tidak ada → arsip terpotong, tak bisa dibuka. Isinya tak diketahui. **Perlu diunduh ulang** kalau penting.

---

## ⚠ DUA KOREKSI PREMIS (penting — mengubah semua vonis)

**1. Kanon objek Ashbrook BUKAN 64 px, tapi `TILE = 16`.**
Perintah tugas menyebut "64px grid ULPC (#233)". Itu benar untuk **karakter**, bukan objek.
Bukti kode: `const TILE := 16` di `Ashbrook.gd:15`, `Main.gd`, `Desert.gd:6`, `Candyveil.gd:5`,
`Frostpeak.gd:6`, `DungeonBase.gd:7`; `ts.tile_size = Vector2i(TILE, TILE)`.
Sel karakter dunia = **32×32** (`CharGen.gd:9-10`). Tak ada grid 64 di mana pun kecuali UI.
Lembar LPC 832×2944 = lapisan sumber, bukan ukuran in-world.

Ukuran prop nyata: `signboard 16×14` · `int_table 24×20` · `int_shelf 20×28` · `barrel 13×16` ·
`crate 15×15` · `ruins 40×28` · `stall 40×34` · `well 34×38` · `street_lamp 12×44`.

**Akibat:** menilai kandidat terhadap 64 px akan meloloskan aset yang 4× terlalu besar.
Semua vonis di bawah dipatok ke **16 px**.

**2. "Art tanpa konsumen = art mati" bukan #240.**
`#240` = **HUKUM REPRODUKSI** ("tiap gambar wajib bawa script pembuatnya", `CLAUDE.md:371-383`).
Kalimat art-mati ada di **#244** ("Menggambar 5 sprite tanpa konsumen = art mati") dan
**#248** ("Laci tanpa ruangan = art tanpa konsumen"). #248 sendiri salah mengutipnya sebagai #240.
Prinsipnya tetap berlaku penuh di tugas ini — hanya nomornya yang perlu dibetulkan di sumber.

---

## FASE 1+3 — TABEL VONIS

Uji dilakukan **BERSEBELAHAN** pada satu kanvas zoom 5×, bukan baca nama berkas:
prop Ashbrook (`int_table`, `barrel`, `crate`, `signboard`, `ruins`, `stall`, `int_shelf`,
`laundry`, `street_lamp`, `well`, `statue`, `chest_common`) berbaris di atas kandidat.

| Pack / objek | Kategori | Skala mentah | vs 16px | Vonis | Lisensi | #232 | Membuka adegan | URL sumber |
|---|---|---|---|---|---|---|---|---|
| **superpowers `medieval-fantasy/objects`** (21: kastil, kemah, gubuk, pohon, patung, tunggul menara) | objek dunia | 12–30 px | ~0,7–1,0× | **DITAHAN** | **CC0 1.0** (LICENSE.txt verbatim di dalam pack) | ✅ bukan LPC, tanpa SA | tak ada — Ashbrook sudah punya bangunan sendiri | github.com/sparklinlabs/superpowers-asset-packs |
| **superpowers `medieval-fantasy/items`** (~60: barrel 9×9, crate 8×9, peti kayu/emas, ramuan, permata, senjata) | ikon barang | 3–22 px | 0,6–0,7× | **DITAHAN** | **CC0 1.0** | ✅ aman | tak ada — barrel/crate/chest sudah ada di `game/assets` | idem · cermin: opengameart.org/content/superpowers-assets-various-2d |
| superpowers `0-tileset.png` | tileset | 320×192 (sel 16) | **1,0× PAS** | **DITAHAN** | CC0 1.0 | ✅ aman | tak ada — tileset dunia sudah jalan | idem |
| `rpg-battle-system-part-2` (latar tempur, ikon barang) | latar/UI tempur | besar | — | **TOLAK** | CC0 1.0 (terbukti) | ✅ aman | tak ada — Aetherion bukan JRPG tempur-berlatar | idem (repo sama) |
| **craftpix "Free Ruined Temple"** — `Objects_interior` (guci, panji, patung gargoyle, puing, tengkorak, peti), `Exterior_objects` (kolom, patung, pohon, fasad kuil), `Tiles_exterior`, `Walls_floor`, `Fire_animation`, `Lever`, `Spikes`, `lattice` | objek+tileset top-down | sel ~32 px | ~2× | **TOLAK** (gaya) + **TAHAN** (lisensi) | 🟡 `License.txt` **hanya berisi URL** craftpix.net/file-licenses/ — teks syarat TIDAK disertakan. Bukan CC0, bukan CC-BY | ✅ bukan turunan LPC, bukan SA — **tapi juga bukan daftar-putih** | — | craftpix.net/freebies/ (URL di `Free Assets Craftpix!.url`) |
| **Overland Sprites** `objects/` (peti, pintu, gerbang, altar, api 144×48, batu, pohon, kunci, portal) | objek | 16×16 / 16×32 | **1,0× PAS** | **TAHAN** | 🔴 **NOL berkas lisensi** di dalam zip | tak terverifikasi | — | tak ada — perlu URL dari owner (indikasi: Monster RPG 2, Trent Gamblin) |
| **Overland Tiles** (4096 ubin `0-0.png`…) | tileset | 16 px | **1,0× PAS** | **TAHAN** | 🔴 nol berkas lisensi | tak terverifikasi | — | idem |
| Monster RPG 2 `.tar.gz` ×5 (latar tempur, media, ikon, TGA) | latar/UI | besar, TGA | — | **TOLAK** | nol berkas lisensi | — | — | idem |
| **jatstory** (39 PNG: kastil, menara, jembatan, sungai, peta 3000×2350) | ilustrasi | 100–3000 px, painterly | 6–180× | **TOLAK** | nol berkas lisensi | — | — | tak ada |
| `Everything.zip` | FX not-musik | kecil | — | **TOLAK** | nol berkas lisensi | — | — | tak ada |
| `painterly-spell-icons-1/-3` | ikon sihir | painterly | — | **TOLAK** (bukan piksel) | hanya README | — | — | — |
| `Combat Backgrounds` · `Combat Media` · `Battlers` | latar/monster tempur | — | — | **TOLAK** | Readme, tanpa lisensi | — | — | — |
| `Ronnan-game-minimap.zip` | 1 berkas `.psd` | — | — | **TOLAK** | — | — | — | — |
| **`Aetherion-main.zip` (52,9 MB)** | — | — | — | **BUKAN ASET BARU** | — | — | — | **Ini snapshot repo Aetherion sendiri** (unduhan GitHub). Isinya `game/assets/game/sprites/props/*` = prop kita sendiri. Abaikan sebagai kandidat |

**Lapisan karakter baru (catat sebaris, tidak diaudit ulang per perintah):**
`lpc-character-bases-v3_1.zip` ×2 (kembar identik 33,9 MB), `lpc_revised_character_basics.zip` (83,5 MB),
`lpc_male_*` ×3, `cabbit-bases-0.3`, `24x32 black characters pack`, `customizable_characters_w_samples`,
`airmonster-002-recolor`, `Dragon - Fully Animated` (139 MB), `monster2animcharsprites.7z`,
serta ~20 PNG/GIF base lepas di akar. Ranah `LPC_EXTRA_KURASI.md`.

---

## Kenapa craftpix DITOLAK padahal cantik

Ini keputusan gaya, dan hanya terlihat saat berdampingan:

- **Ashbrook** = piksel datar, **4–7 warna**, garis-tepi gelap keras
  (`signboard` 5 warna, `ruins` 4, `barrel` 5, `int_table` 6).
- **Craftpix** = bergradasi halus, marmer bertingkat-tingkat, **tanpa garis-tepi hitam**,
  palet dingin-pucat. Di samping `ruins.png` (4 batang abu-abu), puing craftpix
  terbaca seperti dari game lain.
- Skala 2× berarti turun-skala 50% — pada piksel-art itu **menghancurkan** garis 1-px.

**Nuansa jujur:** peti Ashbrook sendiri sudah menyimpang —
`chest_common_closed.png` punya **1118 warna unik dalam 1306 piksel** (hampir foto, anti-alias),
dan 43×40 melanggar kelipatan-16. Craftpix akan duduk manis di samping peti itu,
tapi bentrok dengan **semua prop lainnya**. Cacat yang sudah ada bukan izin menambah cacat.

---

## FASE 2 — 🎯 KEBUTUHAN NYATA: ADA atau TIDAK

| 🎯 Kebutuhan | Ada di batch ini? | Keterangan |
|---|---|---|
| **BANGKU / bench lepas** (bench Otha, A1) | ❌ **TIDAK** | Nol di 72 berkas. Nol juga di seluruh gudang lama — satu-satunya kecocokan nama: `Pixel_Crawler_Free_2.11\...\Stations\Workbench.png` (meja kerja tempa, **bukan** bangku duduk) |
| **kain / cloth / fabric lepas** (prop Otha) | ❌ **TIDAK** | Yang terdekat = panji dinding craftpix (TOLAK gaya). **Catatan penting: `props/laundry.png` 32×18 — kain jemuran — SUDAH ADA di `game/assets` dan sudah dipakai `Town.gd:184`** |
| **gunting / bantalan jarum** | ❌ **TIDAK** | Nol. Ikon senjata superpowers ada pisau/pedang, bukan gunting penjahit |
| **rak buku / meja arsip / laci** (laci Elyn, A3) | ❌ **TIDAK** | Nol laci di batch. `props/int_shelf.png` 20×28 (rak) sudah ada dan dipakai HouseInterior ×6 |
| **lentera / lampu gantung** (hook Merrit) | ❌ **TIDAK** | Nol lentera lepas. Api craftpix 128×480 dan `overland/fire.png` 144×48 = **FX api**, bukan objek lentera |
| **objek desa: pagar, sumur, gerobak, peti** | ⚠ **SEBAGIAN, tapi mubazir** | pagar `fence_h`/`fence_post`, sumur `well.png` 34×38, peti ×3 pasang — **semua sudah ada di `game/assets`**. Batch cuma menawarkan versi duplikat berlisensi lebih lemah. **Gerobak: TIDAK ADA** di mana pun |

**Skor jujur: 0 dari 6 kebutuhan nyata terpenuhi batch ini.**

---

## 🔥 TEMUAN TERBESAR SESI INI (bukan dari batch — dari kode)

Saat memasang patokan skala, dua konsumen **yang sudah ter-wire** ternyata menunjuk seni yang **tidak ada**:

1. **`Ashbrook.gd:164` memuat `props/lantern.png` — berkas itu TIDAK ADA.**
   Lentera Merrit — pusat emosi adegan itu — sekarang tampil sebagai
   **blok warna 6×8** dari `Image.create()`, ditambah `PointLight2D` dengan `texture_scale = 9.0`.
   Dijaga `ResourceLoader.exists`, jadi gagal diam-diam, tak ada error.

2. **8 bangku Ashbrook = `Interactable.setup("bench")`** yang jatuh ke sprite generik.
   Bangku sudah jadi objek interaktif **dan** stasiun kerajinan di `recipes.json`.
   Seninya saja yang belum ada.

3. Bonus: `AshbrookChicken.gd:45` memuat `props/chicken.png` (tidak ada) →
   blok 8×8, padahal ayam asli ada di `sprites/animals/chicken.png` 32×16. **Salah jalur, bukan seni hilang.**

**Ini membalik kekhawatiran #244/#248.** Untuk lentera dan bangku, kita **tidak** menghadapi
"art tanpa konsumen" — kita menghadapi kebalikannya: **konsumen tanpa art**, sudah ter-wire,
sedang menampilkan kotak warna kepada pemain hari ini.

---

## FASE 4 — RINGKASAN & YANG DIARSIPKAN

| Hitungan | Jumlah |
|---|---|
| Pack/berkas ditinjau | 72 berkas · 467,5 MB |
| **COCOK + AMAN (siap pakai langsung)** | **0** |
| DITAHAN — CC0 terbukti, tapi skala/isi mubazir | **3** (superpowers objects · items · tileset) |
| TAHAN — lisensi tak terverifikasi | **3** (Overland Sprites · Overland Tiles · craftpix) |
| 🔴 HARAM-LPC (CC-BY-SA turunan LPC dipakai sebagai objek) | **0** — tak satu pun kandidat objek berasal dari LPC. **#232 tidak terlanggar** |
| TOLAK | **9** |
| Arsip rusak, perlu unduh ulang | **2** `.crdownload` |

**Diarsipkan ke `assets_raw/objek_terpilih/`** (gitignored, BUKAN `game/assets/`):
`superpowers_medieval_cc0/` — 100 berkas: `objects/` + `items/` + `LICENSE.txt` + `CREDIT.txt` verbatim,
plus `SUMBER.md` berisi URL sumber & cermin.
Alasan disimpan: **satu-satunya set dengan CC0 tertulis di dalam pack** dan gaya terdekat.
Alasan **belum** produksi: butuh naik-skala non-integer ~1,4× dan menduplikasi prop yang sudah ada.

Craftpix **sengaja TIDAK** dimasukkan ke folder "aman" — pelajaran `80-CC0-RPG-SFX` berlaku:
URL lisensi ≠ berkas lisensi, dan craftpix bukan CC0/CC-BY.

---

## FASE 5 — REKOMENDASI (memihak)

Batch ini **tidak** membuka satu pun adegan tertunda. Dari 6 kebutuhan 🎯, **nol** terpenuhi.
Nilainya sebagai gudang objek mendekati nol — nilainya nyata ada di lapisan **karakter**,
dan itu sudah dipanen `LPC_EXTRA_KURASI.md`.

**Tidak, tidak ada yang cukup untuk membangun bench Otha atau laci Elyn tanpa menggambar.**
Bangku, kain lepas, gunting, laci, dan lentera semuanya nol — di batch ini maupun di gudang lama.

**Rekomendasi saya: berhenti menambang gudang untuk objek, dan gambar `lantern.png` lebih dulu — satu berkas, ~12×20 px.**

Alasannya menang telak atas semua alternatif:

1. **Konsumennya sudah ada dan sudah ter-wire.** `Ashbrook.gd:164` sudah memanggilnya.
   Tak perlu scene baru, tak perlu wire baru — hanya menaruh berkas pada jalur yang sudah diminta kode.
   Ini kebalikan sempurna dari "art tanpa konsumen": **hari ini pemain melihat kotak warna 6×8
   di tempat lentera Merrit berada.**
2. **Ongkosnya terkecil di seluruh papan.** Satu sprite, palet 5 warna, ~12×20 px,
   selaras `street_lamp.png` 12×44 dan `int_lamp.png` 12×24 yang sudah jadi patokan gaya.
3. **Memenuhi #240 dengan murah.** Ukuran sekecil ini wajar dibuat prosedural,
   jadi script generatornya ikut ter-commit sejak awal — bukan hutang.
4. **Bangku menyusul kedua** (8 konsumen ter-wire + stasiun `recipes.json`), lalu laci —
   dan laci tetap tunggu scene perpustakaan A3 sesuai #248.

Yang **tidak** saya rekomendasikan: memaksa craftpix masuk lewat turun-skala 50%
(merusak piksel + lisensi belum terbukti), atau menaikkan skala superpowers 1,4×
untuk barrel/crate yang sudah kita punya versinya sendiri.

**Dua permintaan ke Direktur:**
- URL sumber untuk **Overland Sprites/Tiles** — 4096 ubin **16 px pas** tersandera hanya karena nol berkas lisensi. Ini satu-satunya aset di batch yang skalanya benar-benar cocok.
- Unduh ulang dua `.crdownload` yang terpotong, atau izin hapus.
