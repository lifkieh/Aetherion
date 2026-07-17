# LPC_STRUKTUR — Peta lapisan LPC (untuk spec mesin perakit)

> **Tugas #232-3:** JANGAN bangun mesin perakit dulu — **laporkan struktur**. Ini petanya.
> Lokasi: **`assets_raw/lpc/`** (dipindah dari `.vscode/`, kini gitignored). Survei 2026-07-17.
> ⚠ **Nol sprite dibuat, nol wire, nol perubahan `game/`.** Laporan + struktur saja.

## 1. KANVAS & ARAH
- **Frame: 64×64 px.** Semua lapisan sejajar pada kanvas ini (kepala/tangan sinkron antar body,
  kecuali `child` yang punya offset sendiri).
- **Sheet "universal": 832×1344** = **13 kolom × 21 baris** dari 64px. Berisi animasi standar LPC:
  **spellcast · thrust · walk · slash · shoot · hurt/death** — masing-masing **4 arah**
  (atas · kiri · bawah · kanan), plus baris tambahan.
- **Sheet kecil terpisah:** `idle` (128×256 = 2×4), `run`, `jump`, `sit`, `climb` — per body/head.
- **4 arah penuh** ✓. Walk-cycle ✓ (di dalam sheet universal). Diagonal via pack run/diagonal terpisah.

## 2. KONVENSI PENAMAAN
```
bodies/<tipe>/<animasi>/<warna>.png       mis. bodies/male/universal/light.png
heads/<ras_sex_usia>/<animasi>/<warna>.png mis. heads/human_male_elderly/idle/light.png
```
- `<tipe badan>` = male · female · child · **teen** · muscular · pregnant · skeleton · zombie
- `<warna kulit>` = light · amber · bronze · brown · black · … (+ warna fantasi: bright_green, dsb.)
- `<animasi>` = universal · idle · run · jump · sit (walk ada DI DALAM universal)
- Pack lapisan luar (rambut/baju) mengikuti pola **layer PNG transparan 64×64 yang di-composite
  DI ATAS body** pada urutan-z: body → head → mata → baju bawah → baju atas → rambut → topi → gear.

## 3. LAPISAN YANG **ADA** ✅

| Lapisan | Sumber di `assets_raw/lpc/` | Catatan |
|---|---|---|
| **Badan/kulit** | `lpc-character-bases-v3_1/bodies/*` | 8 tipe badan × banyak warna |
| **Kepala (modular)** | `.../heads/*` | human male/female + **elderly** + child; **RAS:** orc · lizard · wolf · boarman · minotaur · skeleton · zombie (masing-masing child/dewasa) |
| **Mata** | `spare eyes 2..png` (lepas) | terbatas; mata umumnya sudah menyatu di kepala v3 |
| **Rambut** | `credits(expanded-hair)`, `hairstyles-2024`, `lpc-2024-topknot` | puluhan gaya |
| **Janggut** | `whitebeard.png` dan lapisan sejenis | untuk sosok tua |
| **Baju atas** | `Androgynous Long-Sleeve Shirt`, `Clothes00`, `lpc_revised_character_basics/Clothing`, `gentleman`, `Legion armor`, `LPC Dark Elves`, `modular-kimono` | banyak |
| **Baju bawah/celana** | `Androgynous Pants`, kimono, obi | ✓ |
| **Sepatu/boots** | `male-obi-boots` | ✓ (varian terbatas) |
| **Jubah/cape** | `cape_white.png`, `capeclip_*`, `capetie_*`, `trimcape_*` (lepas) | ✓ |
| **Senjata/gear** | `lpc_medieval_weapons`, `lpc_male_item_animations/spritesheets`, `ItemsAndEffects` | ✓ |
| **Aksesori** | `accessories.xcf`, `elvenears_light.png` (telinga elf) | ✓ sebagian |

## 4. LAPISAN yang **TIDAK ADA / TIPIS** (GAP) 🔴

- **Portrait/wajah ekspresi** — LPC **tidak punya sistem portrait.** GAP besar untuk dialog.
  *(Kandidat penambal: Kushnariova 24×32 punya portrait — CC-BY, tapi gaya beda; atau produksi sendiri.)*
- **Topi/helm sebagai pack mandiri** — hanya tertanam di `gentleman` (topi tinggi) & `Legion armor`
  (helm). **Tak ada pack topi lengkap** → variasi tutup-kepala terbatas.
- **Mata modular (warna terpisah)** — nyaris tak ada; mata menyatu di kepala.
- **Sepatu** — variasi sangat sedikit (praktis hanya obi-boots).
- **Ras Aetherion belum tercakup:** dari 8 ras kanon — **Human ✓, Beastfolk ✓** (wolf/boarman/lizard),
  **Elf ✓** (Dark Elves + telinga elf). **Dryad · Dwarf · Astralborn · Tidekin · Shadeborn = GAP**
  (harus recolor/mod dari base; Dwarf ≈ badan pendek + janggut, relatif mudah).

## 5. HEWAN & MONSTER (ekosistem LPC ini)

- **Hewan ✓ — termasuk AYAM:** `chicken.png` ✓ · `pig-1.1` · `horse-1.1` · `cat-1.0` ·
  `cabbit-bases` · `bunnysheet` · `wolfsheet1-6` · burung `bird_1/2/3_*` (bluejay/cardinal/eagle/
  robin/sparrow/…). **GAP hewan:** **sapi/kambing/domba** (Ninja punya; LPC-stash ini tidak).
- **Monster ✓:** `lpc-monsters.zip` · `Combat Media (Monsters, Attacks)` · `airmonster` + lepas
  (`goblins2` · `red_orc` · `minotaur_alpha` · `wraith` · `icy_demon` · `Dragon - Fully Animated` ·
  `terrex` · `enemies` · `rpgcritters2`). Cakupan monster **baik**.

## 6. CATATAN UNTUK SPEC MESIN PERAKIT (bukan dibangun sekarang)
- **Model perakitan = composite lapisan 64×64 ber-urutan-z** (body→head→eyes→bawah→atas→rambut→
  topi→gear), lalu potong per-frame untuk animasi. Selaras dengan generator Python proyek yang ada.
- **Determinisme (#138):** seed per-NPC → pilih lapisan → cache PNG hasil di `assets_publikasi/
  characters/`. Setiap sprite hasil **wajib menuliskan manifest kredit lapisannya** (format kredit
  per-lapisan LPC sudah menyediakan baris siap-salin).
- **⚠ Pembatas SA (#232):** perakit **hanya** menyentuh lapisan karakter → output ke
  `assets_publikasi/`. **Dilarang** menggabungkan lapisan LPC dengan tileset/UI/ikon.

## 7. RINGKAS
LPC di gudang: **64×64, 4-arah, walk penuh, modular badan/kepala/ras/usia + rambut/baju/gear +
hewan(ayam)+monster.** Cukup untuk **inti karakter Aetherion**. GAP nyata: **portrait**, **topi
lengkap**, **5 ras kanon**, **sapi/kambing** — semua bisa ditambal (produksi/recolor) di bawah
keputusan lanjutan. Struktur `assets_publikasi/` sudah berdiri; menunggu **spec mesin perakit Designer.**
