# PERAKIT_SPEC — Spec Mesin Perakit LPC (RANCANG, jangan bangun)

> **Tugas 3 (#233):** bahan terbukti cukup; rancang mesinnya. **JANGAN BANGUN — Direktur review dulu.**
> Selaras **design-time pipeline (#162/#161)**: perakit jalan **saat DEVELOP**, hasil **dipanggang &
> di-commit** — **bukan** runtime di komputer pemain. **Nol `game/` sekarang; 947 test hijau.** 2026-07-17.

## 0. Prinsip
- **Design-time only.** Output = PNG sheet yang di-commit, bisa dibaca/di-diff/dites/dihapus (#162).
- **Deterministik (#138).** Seed/JSON per-karakter → sprite yang SAMA tiap rakit. Generik = generate
  unik per-individu; **tokoh bernama = JSON tulis-tangan.**
- **Hukum pembatas #232 dikodekan:** perakit **hanya** menyentuh lapisan KARAKTER → output ke jalur
  karakter. **Dilarang** composite lapisan LPC ke tileset/UI.

## 1. INPUT — JSON per-karakter
```json
{
  "id": "merrit_fane",
  "named": true,                      // true = tokoh bernama (tulis-tangan, kena guard #231)
  "race": "human",                    // human|elf|beastfolk|astralborn|shadeborn|dryad|...
  "body": "male",                     // male|female|teen|child|muscular|pregnant
  "skin": "light",                    // dari skintone rework (Death's Darling) / palet
  "hair": null,                       // null = BOTAK (Merrit). id lapisan rambut kalau ada
  "headwear": null,                   // kerudung|topi|starhat|... (hair XOR headwear utk guard)
  "facial": { "beard": null },
  "torso": "overalls",  "legs": "pants_thin",  "feet": "shoes_thin",
  "race_overlay": [],                 // ["wing_feathered","starhat"] (Astralborn) | ["horns"] | ...
  "story_prop": ["letter"],           // surat|lantern_glow|sewing_basket|cane  (overlay cerita kami)
  "palette_shift": null,              // "shadow" (Shadeborn) | "bark_green" (Dryad) | null
  "tint": { "torso": "#5a648c" }      // recolor opsional per-lapisan
}
```
- **Generik NPC:** field diisi dari **seed deterministik** (#138) alih-alih tangan.
- **`hair` XOR `headwear`:** kalau `headwear` diisi (kerudung/topi), `hair` boleh null/di-bawah.

## 2. OUTPUT
- **Utama:** satu **sheet ULPC 832×2944** ter-flatten per karakter (`<id>.png`).
- **Opsional (untuk engine ringan):** slice per-animasi (`<id>_walk.png` 4-arah, `<id>_idle.png`, dst)
  dipotong dari sheet — supaya game tak load sheet raksasa penuh bila tak perlu.
- **Manifest kredit** `<id>.credits.txt` **ikut tiap sprite** (daftar lapisan + seniman + lisensi) —
  wajib CC-BY-SA (atribusi). Digenerate otomatis dari kredit per-lapisan.

## 3. Z-ORDER (terbukti di uji tumpuk #236 & astralborn/shadeborn/dryad)
Dari BELAKANG ke DEPAN:
```
1  race_overlay.wing_*_back        (sayap belakang)
2  palette_shift(body)             (badan; shadow/bark = recolor di sini)
3  race_overlay.tail / hooves      (ekor beastfolk, kaki faun bila ras itu)
4  legs                            (celana)  — KECUALI ras berkaki-native (faun): skip
5  feet                            (sepatu)  — idem
6  torso                           (baju)
7  facial.beard
8  palette_shift(head)  +  head
9  race_overlay.horns               (tanduk Shadeborn/demon — SPEC, belum ada)
10 hair   XOR   headwear            (rambut / kerudung / topi)
11 race_overlay.starhat / leaf_hair (topi bintang Astralborn / rambut-daun Dryad — SPEC)
12 story_prop.sewing_basket (lap)   (frame duduk)
13 story_prop.letter / lantern_glow / cane  (prop tangan; lantern GLOW paling depan)
14 race_overlay.wing_*_front        (sayap depan)
```
- **Prop tangan & sayap depan = paling depan** (menutup lengan). **Sayap belakang & badan = paling
  belakang.** Terbukti pixel-perfect karena semua lapisan 832×2944 sejajar-frame.

## 4. Prop cerita (surat/lentera/benang/tongkat) — cara sisip
- Masing-masing = **lapisan overlay ULPC** di layer 12–13. Hanya di frame yang relevan:
  - **surat/benang** → frame **duduk** saja (murah).
  - **lentera** → **carry-pose** (~4 frame) + **GLOW WAJIB (kanon Sora #237): glow tak boleh
    dihilangkan demi optimasi.** Glow = layer additive di depan.
  - **tongkat** → overlay tangan, walk+idle (garis vertikal, terbaca siluet).
- Spec detail & uji keterbacaan: `PROP_IDENTITAS_SPEC.md` (+ hasil di sana). Perakit hanya **menumpuk**
  lapisan yang sudah ada; ia tak menggambar.

## 5. Ras overlay — cara sisip
- **Astralborn:** `race_overlay=["wing_feathered","starhat"]` → layer 1+14 (sayap) + 11 (starhat).
  **Terbukti: 3 baju beda, wardrobe 0 rusak** (`astralborn_test.png`).
- **Shadeborn:** `palette_shift="shadow"` (layer 2+8) + `race_overlay=["horns"]` (layer 9, **SPEC—belum ada**).
  **Terbukti: dark-recolor + 3 baju, wardrobe 0 rusak** (`shadeborn_test.png`).
- **Dryad:** faun-body (kaki-native, **skip layer 4–5**) + `race_overlay=["leaf_hair"]` (layer 11, **SPEC**)
  + bark recolor. **Terbukti: torso wardrobe nyambung**; ⚠ **leg-wardrobe TIDAK** (faun berkaki fur) →
  Dryad = torso-bebas, kaki-native (`dryad_test.png`). *Alternatif: human-body + bark+leaf overlay =
  wardrobe penuh tapi butuh overlay digambar.*
- **Overlay yang BELUM ADA (spec, jangan gambar di perakit):** `horns` (Shadeborn), `leaf_hair`+`bark_skin`
  (Dryad). Perakit merujuknya via id; kalau id tak ada di pustaka → **error, bukan diam.**

## 6. Di mana mesin hidup
- **`_tools/lpc_assembler/`** — Python + Pillow (selaras generator proyek yang ada). CLI:
  `python assemble.py characters/merrit_fane.json --out game/assets/game/sprites/characters/`
- **Pustaka lapisan** dibaca dari `assets_raw/lpc/` + `assets_raw/lpc_extra/` (gitignored, mentah).
- **Bukan bagian build game runtime.** Dijalankan manual/CI saat aset berubah; hasilnya di-commit.

## 7. Output → `game/assets/` TANPA mencemari tileset/UI dengan SA (#232)
- Sprite karakter (SA) **HANYA** ke **`game/assets/game/sprites/characters/`** (folder khusus karakter).
- **Setiap folder karakter membawa `LICENSE-CC-BY-SA.txt` + `<id>.credits.txt`.**
- **Tileset (`.../tiles/`) & UI (`.../ui/`) = folder terpisah, lisensi masing-masing (BUKAN SA).**
- **Perakit secara struktural TAK BISA menulis ke `tiles/`/`ui/`** (output path dikunci ke `characters/`).
- **Uji CI:** test yang **gagal** bila ada PNG turunan-LPC muncul di luar `characters/` (penjaga #232).

## 8. ⚠ HUKUM #231 DIKODEKAN (bukan diharapkan) — penjaga kembar
Temuan #235/#237: Merrit↔Halloran kembar karena mesin tak mencegah rambut sama. **Perakit WAJIB
MENOLAK (bukan warning)** dua tokoh bernama berbagi lapisan rambut/tutup-kepala.
```python
# jalan saat merakit SEMUA tokoh bernama (build-time gate)
def guard_231(named_chars):
    seen = {}                                  # (hair_or_headwear_id) -> first char id
    for c in named_chars:
        key = c.headwear or c.hair             # tutup-kepala mengalahkan rambut
        if key is None:                        # botak/tanpa-tutup = hook unik tersendiri
            key = f"__bare__:{c.id}"           # botak Merrit tak bentrok siapa pun
        if key in seen:
            raise AssemblyError(               # HARD FAIL — bukan warning
              f"#231 DILANGGAR: '{c.id}' dan '{seen[key]}' berbagi hook kepala '{key}'. "
              f"Tokoh bernama WAJIB rambut/tutup-kepala berbeda-BENTUK. Rakit DITOLAK.")
        seen[key] = c.id
```
- **Aturan:** dua tokoh bernama tak boleh berbagi `hair`/`headwear` **id**. Botak (`hair=null`,
  `headwear=null`) diperlakukan **unik** (Merrit botak = hook tersendiri, tak bentrok).
- **Level:** **HARD FAIL build.** Rakit batal sampai konflik diperbaiki. **Bukan** peringatan yang bisa
  diabaikan — itulah yang meloloskan Merrit↔Halloran.
- **Test wajib:** `_test_perakit_231()` — beri 2 tokoh bernama rambut sama → **harus raise/gagal.**
  (Uji jalur pemakai: panggil perakit, bukan periksa string.)

## 9. Yang BELUM diputus (untuk Direktur)
1. Slice per-animasi vs sheet penuh di engine? (memori vs kesederhanaan)
2. Dryad: faun (kaki-native, wardrobe-torso) **atau** human+overlay (wardrobe-penuh, overlay digambar)?
3. Siapa menggambar overlay SPEC (horns/leaf_hair/bark) + 4 prop cerita?
> **Ini spec. Tak ada kode perakit ditulis. Menunggu review Direktur.**
