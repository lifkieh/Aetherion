# LPC_EXTRA_KURASI — Kurasi `assets_raw/lpc_extra/` (dulu `D:\assets_raw_new_2`)

> **Tugas:** saring per-UKURAN, buktikan LPC-compat dengan **menumpuk lapisan** (bukan baca nama),
> pretelin jadi lapisan, petakan. **⚠ NOL hapus** — yang tak lolos tetap di gudang, cukup dilabeli.
> **NOL perubahan `game/`, nol sprite dirakit, nol wire. 947 test utuh.** Survei 2026-07-17.

## FASE 1 — PINDAH & AMAN ✅
`D:\assets_raw_new_2` **disalin** → **`assets_raw/lpc_extra/`** (437 item). Terverifikasi
**gitignored** (via `assets_raw/`). Asli di `D:\` dibiarkan (salin, bukan pindah). Aset mentah
**tak mungkin ter-commit.**

## TEMUAN INDUK
Gudang ini = **koleksi ULPC (Universal LPC) modern** — jauh lebih kaya dari `assets_raw/lpc/`.
Ia **menutup banyak GAP** yang dilaporkan `LPC_STRUKTUR.md`: **sayap, topi, elder, lebih banyak ras,
sapi/kambing.** Format lapisan barunya (`eulpc_*`, 832×2944) **stack pixel-perfect** — dibuktikan.

---

## FASE 2 — UJI UKURAN (dengan BUKTI tumpukan, bukan nama file)

**Uji sungguhan dijalankan:** menumpuk `wing_feathered_back + body + head + legs + feet + torso(overalls)
+ hair(jewfro) + wing_feathered_front` (semua `eulpc_*`, 832×2944) lalu meng-crop frame beranimasi.
**HASIL (screenshot `scratchpad/ulpc_stack.png`, tak di-commit — turunan SA):** **rambut duduk PAS di
kepala · sayap membingkai badan (belakang di belakang, depan di depan) · overalls/celana/sepatu
nyambung — di SETIAP frame, nol melayang, nol meleset.** ULPC-compat **TERBUKTI**, bukan diasumsikan.

| Kelas ukuran | Contoh | Kanvas | Verdikt |
|---|---|---|---|
| **ULPC expanded (atomic layer)** | `eulpc_body/head/hair/torso/legs/feet/wing_*` | **832×2944** (64-grid, 46 baris) | ✅ **LOLOS** — terbukti stack |
| **LPC standard universal** | `wizard_hat_*`, `lpc faun.png`, `LPC_Sara` | 832×1344 (64-grid, 21 baris) | ✅ **LOLOS** utk anim standar; ⚠ tak punya baris anim expanded-only |
| **Walkcycle compound (MERGED)** | `male_ivory_normal_human_..compound`, `BODY_FEMALE_ORC`, `female_drakegreen_lizard_..compound`, ogre | 576×256 (64-grid, walk saja) | 🟡 **DITAHAN** — on-grid tapi **menyatu** (badan+kulit di-bake) & walk-only |
| **Non-64-grid** | `frogman` (480×864), `npcs_faceset` (750×450) | bukan kelipatan 64 | 🟡 **DITAHAN** (re-anchor mahal) / bukan LPC |
| **Isometric / side / battler** | `2DPIXX`, Monster RPG 2, `Battlers` | beda sudut | 🔴 **DITOLAK** (sudut pandang salah) |

---

## FASE 3 — PRETELIN (pecah jadi lapisan)

**Kabar baik: mayoritas SUDAH terpretelin by-design.** Format `eulpc_*` = **satu file per lapisan
atomik** (body · head · hair · torso · legs · feet · wing terpisah). Itu **tepat** yang diminta —
tak perlu dipecah lagi.

**Lapisan atomik yang tersedia** (siap composite z-order: `wing_back → body → head → eyes → legs →
feet → torso → hair → hat → wing_front → prop`):
- **kepala/ras** ✅ · **rambut** ✅ (Hair00 + eulpc_hair_* + xlong + k-idol + ponytail) · **mata** ✅
  (`eyes.png`, `eulpc` facial 2024) · **badan** ✅ (child/female/male/teen/muscular/pregnant) ·
  **torso/baju** ✅ (overalls/cardigan/sleeveless/aprons/bandages/maternity/women's-shirt/long-short-sleeveless) ·
  **kaki/celana** ✅ (pants/hose/shorts/skirt/maternity) · **sepatu** ✅ (shoes/high-socks/obi-boots/socks-shoes) ·
  **topi** ✅ (hat-bundle · starhat · stetson · wizard M/F · hijab · lizard-headwear) ·
  **sayap** ✅ (bat/feathered/lizard back+front · fairy) · **cape** ✅ · **prop/senjata** ✅
  (lpc_weapons_pack · weapons-extended · hand-tools · staff · backpacks).

**TIDAK bisa dipretelin → DITOLAK untuk pipeline modular (tetap di gudang, dilabeli):**
`*_walkcycle_compound.png` (badan+kulit menyatu), `BODY_FEMALE_ORC` (merged, walk-only),
`characters.png`/`sheet.png` (lembar jadi), `frogman` (non-grid + menyatu), semua battler/monster jadi.
*Alasan: seluruh nilai LPC = modularitas; sprite menyatu = mati untuk perakit.*

---

## FASE 4 — PETA LAPISAN (gabung `assets_raw/lpc/` + `lpc_extra/`)

### Yang kini kita punya (LOLOS, modular)
Badan (6 tipe) · kepala human+**elder**(elders-pack)+anak · **rambut** (banyak) · janggut · **mata** ·
torso/celana/sepatu (banyak varian) · **TOPI** (bundle+starhat+stetson+wizard+hijab) · **SAYAP** ·
cape · senjata/tool/backpack · **hewan** (chicken/pig/horse/cat/dog/**bull/goat/ram**/birds/wolf/bunny/cabbit) ·
**monster** (imp/daemon/orc/ogre/minotaur/goblin/wraith/dragon/werewolf).

### 🔴 5 RAS KANON — status di gudang baru
| Ras kanon | Bahan di gudang | Verdikt |
|---|---|---|
| **Dryad** (roh pohon) | `lpc faun` (roh alam bertanduk/berkuku) — terdekat; tak ada dryad-tumbuhan sejati | 🟡 **parsial** (faun + recolor hijau/daun) |
| **Dwarf** | tak ada dedikasi — badan pendek + janggut (janggut ✅, badan-pendek belum) | 🔴 **GAP** (rakit dari base + skala) |
| **Astralborn** (langit) | **feathered wings ✅ + starhat ✅** → rakit celestial | 🟡 **parsial** (via sayap; tanpa badan khas) |
| **Tidekin** (air) | `frogman` (amfibi) tapi **non-64-grid** | 🟡 **parsial** (frogman perlu re-anchor) |
| **Shadeborn** (bayang) | `imp` · `daemon` · `icy_demon` (makhluk gelap) | 🟡 **parsial** (recolor bayang) |

**Beastfolk** (bukan gap, tapi kini SANGAT kaya): wolf/boarman/minotaur/faun/**furry-ears-tails**/cat-ears-tail.
**Elf**: Long-ears + elvenears + Dark Elves ✅. **Lizard/Drakon**: lizard/drake compounds ✅.

### SAYAP — ada? ✅ **BANYAK**
- Lapisan ULPC: **bat · feathered · lizard** (back+front, 832×2944, **terbukti stack**).
- **Fairy wings** (`foremansfairywings` pack1+variations, `fairy.xcf`) — OGA-BY 4.0/CC-BY-SA 4.0.
- Pack animasi sayap 2024 (converted-wings, expanded-wing-animations). **Cukup untuk Astralborn + Fairy Realm.**

### PORTRAIT — ada? 🟡 **parsial, bukan LPC-native**
- `emotions.png`/`Expressions.png` = **overlay ekspresi kecil (64-grid)** untuk wajah sprite — bukan portrait dialog.
- `48x48_Faces..._OGA.png`, `npcs_faceset.png` = **faceset kecil** (non-LPC, 48×48/non-grid).
- **Portrait dialog besar ala LPC tetap GAP.** (Kandidat: Kushnariova CC-BY, atau produksi.)

### Masih kurang apa
Portrait dialog besar · **Dwarf** & **Dryad-tumbuhan** & **badan Astralborn/Tidekin** khas ·
Tidekin canvas benar (frogman non-grid) · konsistensi versi SA (3.0 vs 4.0).

---

## LISENSI (dibaca, tidak ditebak)
Ekosistem ULPC = **CC-BY-SA 3.0 / GPL 3.0 / OGA-BY 3.0** (banyak), sebagian **CC-BY-SA 4.0 / OGA-BY 4.0**
(mis. fairy wings). **SA diterima (#232).** **Bukan GPL-only** — selalu dual dengan CC/OGA → aman untuk gambar.
- ⚠ **Beberapa zip TANPA berkas lisensi di dalamnya** (`Hair00`, `ElizasLpcSkintones`, `hat-bundle`,
  wing-animations 2024) → lisensinya **ada di kredit generator ULPC**, bukan di zip. **Tandai: verifikasi
  kredit ULPC per-lapisan sebelum sprite dikirim** (aturan #4: jangan tebak). Bukan ditolak — **ditahan-verifikasi.**
- ⚠ **Campuran SA 3.0 & 4.0:** turunan gabungan sebaiknya dirilis **CC-BY-SA 4.0** (3.0 boleh naik ke 4.0,
  tidak sebaliknya). **Usul: tambah `LICENSE-4.0.txt` di `assets_publikasi/`** saat lapisan 4.0 dipakai.
- **Non-LPC di gudang ini** (DCSS=CC0 · Kushnariova=CC-BY · 2DPIXX=isometric · CraftPix=restricted ·
  hyptosis=CC-BY · Monster RPG2) — **JANGAN diperlakukan LPC**; tetap kandidat/monster terpisah.
- **Non-aset** (Aetherion-main.zip=backup repo · *.md Chronicle · *.crdownload) — abaikan; bukan aset.

---

## FASE 5 — REKOMENDASI

Gudang ini menutup gap terbesar audit sebelumnya (sayap, topi, elder, ras, ternak) **dan** membuktikan
lapisan ULPC modern stack sempurna. Keputusan nyata yang tersisa: **format kanvas kanonik** — **ULPC
EXPANDED (`eulpc_*`, 832×2944)** vs **LPC STANDARD (832×1344)**. Layer terbaru & terlengkap (sayap,
furry, facial, pants/feet 2024–2025) **hanya hidup di format expanded**; format standar akan memaksa
menambal ulang justru bagian yang baru saja terisi.

**Rekomendasi saya: jadikan ULPC EXPANDED (832×2944, `eulpc_*`) sebagai format lapisan kanonik
Aetherion, dan pretelin/simpan seluruh lapisan atomik `lpc_extra/` sebagai perpustakaan lapisan resmi
(compound merged & non-grid → DITAHAN sebagai referensi, jangan masuk pipeline). Kalau Direktur memilih
lain — mematok format STANDARD 832×1344 demi "lebih sederhana" — risiko terbesarnya adalah kehilangan
akses ke sayap, furry-ears, facial, dan seluruh layer 2024–2025 yang HANYA ada di expanded, sehingga
gap ras & sayap yang baru saja tertutup di sini terbuka lagi, dan Astralborn/Fairy/Beastfolk kehilangan
satu-satunya bahan yang membuatnya mungkin tanpa menggambar dari nol.**
