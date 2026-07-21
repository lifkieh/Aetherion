# PETA KECOCOKAN KARAKTER — badan × pakaian × kepala × rambut

**Dibuat otomatis** oleh `_tools/gen_peta_kecocokan.py`. **Nol perubahan `game/`.**

## Tiga aturan, dan bedanya penting

1. **PAKAIAN ikut BUILD BADAN** — dikunci keras. Salah pasang langsung terlihat;
   itulah cacat "kaki kelebaran" (celana `thin` di badan `male`).
2. **KEPALA ikut BADAN** — tapi LPC cuma punya **tiga** bentuk kepala
   (male/female/child). Tujuh build dipetakan ke tiga kepala itu.
3. **RAMBUT ikut KEPALA, BUKAN BADAN** — rambut duduk di batok, dan batok cuma
   punya dua ukuran. Badan `muscular` boleh memakai **semua** rambut dewasa;
   mengunci rambut per-build akan membuang ratusan berkas tanpa sebab.

## Tabel kunci — pilih badan, ini yang boleh menyertainya

| badan | kepala | build pakaian | rambut |
|---|---|---|---|
| `child` | `child` | `child` | `child` |
| `teen` | `female` | `teen` | `adult` |
| `female` | `female` | `female` | `adult` |
| `muscular_female` | `female` | `female` | `adult` |
| `male` | `male` | `male` | `adult` |
| `muscular` | `male` | `muscular` | `adult` |
| `pregnant` | `female` | `pregnant` | `adult` |

## Persediaan nyata per slot (jumlah berkas)

| slot | `muscular` | `pregnant` | `male` | `female` | `teen` | `child` | `thin` |
|---|---|---|---|---|---|---|---|
| **torso** | — | — | 4186 | 10607 | 10606 | — | 150 |
| **legs** | 500 | 168 | 4992 | 181 | 169 | 18 | 4960 |
| **feet** | — | — | 46 | 46 | 23 | 225 | 143 |

## Rambut — nol build, dua ukuran

| ukuran | berkas |
|---|---|
| `adult` | 810 |
| `child` | 324 |

Gaya: `jewfro`, `left_braid`, `longknot`, `right_braid`, `shortknot`, `side_swoop`

Sudah dipotong ke pustaka kerja: **36** berkas `eulpc_hair*`

## 🔴 LUBANG — badan yang punya tapi pakaiannya tidak

| badan | slot kosong | build pakaian yang dicari |
|---|---|---|
| `child` | **torso** | `child` |
| `muscular` | **torso** | `muscular` |
| `muscular` | **feet** | `muscular` |
| `pregnant` | **torso** | `pregnant` |
| `pregnant` | **feet** | `pregnant` |
