# ARSITEKTUR SISTEM KARAKTER — tiga lapis

**Dibuat:** 2026-07-22 · **Nol perubahan `game/`.**
Tujuan: menambah rangka, garmen, atau NPC **tanpa menyentuh kode**.

---

## Masalah yang dipecahkan

Sebelum ini semuanya bercampur di `catalog.json`: **build ditanam di dalam nama
berkas** (`eulpc_legs_pants_thin.png`), dan resep tokoh menyebut nama berkas itu
langsung (`"legs": "pants_thin"`).

Dua ongkosnya nyata:

1. **Menambah rangka baru menuntut menyentuh setiap entri pakaian.**
2. **Resep bisa menulis pasangan yang mustahil — dan memang terjadi.** Lima tokoh
   dewasa berbadan `male` memakai `pants_thin`, yaitu berkas untuk **female/teen**.
   Itulah cacat *"kaki kelebaran"* yang dilaporkan Direktur (16 px vs 20 px). Tak ada
   lapis yang menahannya, karena tak ada lapis yang **tahu** bahwa `thin` bukan milik
   `male`.

---

## Tiga lapis

```
LAPIS 1   rangka.json        build badan  → kepala · keluarga pakaian · ukuran rambut
LAPIS 2   lemari.json        garmen       → berkas[keluarga][warna]
LAPIS 3   characters/*.json  resep tokoh  → build + id garmen + warna
          ─────────────────────────────────────────────────────────────
DOMAIN    rangka.py          resolver · pengundi · pemeriksa   (murni, nol I/O gambar)
ADAPTER   ke_resep_lama()    → bentuk yang dimengerti assemble.py
RENDER    assemble.py        tak disentuh
```

**Janji intinya: resep tak pernah menyebut nama berkas.** Ia menyebut garmen
(`longsleeve`, `navy`); resolver memilih berkasnya dari `build`. Pasangan mustahil
berhenti jadi kesalahan yang mungkin dilakukan — ia jadi **kalimat yang tak bisa
diucapkan**.

### Kenapa lapis domain murni

`rangka.py` nol I/O gambar, nol Godot, nol efek samping. Yang murni bisa diuji, dan
yang bisa diuji tak diam-diam rusak. 35 uji invarian berjalan dalam sepersekian detik
tanpa membuka satu PNG pun.

---

## Tabel rangka — dari hulu, bukan karangan

Disalin dari `sheet_definitions` generator ULPC resmi:

| build | kepala | torso | legs | feet | rambut |
|---|---|---|---|---|---|
| `child` | child | child | child | child | child |
| `teen` | female | teen | thin | female | dewasa |
| `female` | female | female | thin | female | dewasa |
| `muscular_female` | female | female | thin | female | dewasa |
| `male` | male | male | male | male | dewasa |
| `muscular` | male | **male** | **male** | **male** | dewasa |
| `pregnant` | female | **pregnant** | thin | female | dewasa |

**Muscular meminjam male seluruhnya** — itu desain hulu, bukan kekurangan kita.
**Pregnant dapat torso sendiri** karena perut adalah perubahan **bentuk**, bukan
ukuran; tak ada peminjaman yang bisa mengarangnya.

### Tiga aturan yang berbeda

1. **Pakaian ikut build** — dikunci keras.
2. **Kepala ikut build** — tapi LPC cuma punya tiga bentuk kepala; tujuh rangka
   dipetakan ke tiga itu.
3. **Rambut ikut ukuran batok, BUKAN build.** Batok cuma dua ukuran. Badan
   `muscular` memakai kepala `male` yang sama persis dengan badan `male`, jadi tiap
   rambut yang muat di satu pasti muat di lainnya. Mengunci rambut per-build akan
   membuang 28 gaya dewasa tanpa sebab.

---

## Rantai mundur — peminjaman yang ditulis, bukan disembunyikan

Kalau keluarga yang diminta belum punya berkas, resolver mencoba rantai `mundur`.
Hulu pun melakukannya; bedanya di sini peminjaman **tercatat di data**, dan resolver
**selalu melaporkan** bahwa ia mundur.

> Peminjaman yang senyap adalah utang yang hilang dari pandangan, dan utang yang tak
> terlihat tak pernah dibayar.

Rantai yang aktif sekarang tercatat di `rangka.json → _utang`, masing-masing dengan
cara membayarnya.

---

## Cara menambah barang

| yang ditambah | caranya | sentuh kode? |
|---|---|---|
| **Rangka baru** | satu entri di `rangka.json` | **tidak** |
| **Garmen baru** | taruh PNG berpola `eulpc_<slot>_<garmen>_<keluarga>[_<warna>].png`, jalankan `gen_lemari.py` | **tidak** |
| **Warna baru** | idem — cukup berkasnya | **tidak** |
| **Tokoh baru** | satu resep, atau `undi()` | **tidak** |
| **Slot baru** (mis. `cape`) | tambah ke `SLOT_PAKAIAN` + entri keluarga | ya, satu baris |

## NPC acak

```bash
python rangka.py --undi 20              # 20 NPC acak, semua build
python rangka.py --undi 20 --build male # kunci ke satu rangka
```

Hasilnya **dijamin sah** — bukan karena diperiksa sesudahnya, melainkan karena tiap
pilihan diambil dari daftar yang **sudah disaring build**. Pengundi yang memilih dulu
lalu memvalidasi akan menghasilkan kombinasi gagal yang harus diulang, dan pengulangan
itu tempat bug bersembunyi.

Deterministik per benih: benih sama → resep sama, selamanya.

---

## Kesehatan

```bash
python rangka.py --periksa      # lubang build × slot; keluar 1 kalau ada
python test_rangka.py           # 35 invarian
```

Uji nomor 4 adalah **regresi untuk cacat yang benar-benar terjadi**: kalau suatu hari
celana keluarga `thin` bisa mendarat di badan `male` lagi, uji itu yang berteriak
lebih dulu.

### Persediaan sekarang

| build | torso | legs | feet |
|---|---|---|---|
| child | **0** | 3 | 2 ↩ |
| teen | 3 | 7 | 2 ↩ |
| female · muscular_female | 5 | 7 | 2 ↩ |
| male · muscular | 6 | 4 | 2 ↩ |
| pregnant | 5 ↩ | 7 | 2 ↩ |

↩ = lewat rantai mundur · rambut: 28 dewasa · 4 anak

**Satu lubang tersisa: `child` torso** — sengaja tanpa mundur. Anak adalah rangka
lain, dan meminjam baju dewasa akan terlihat salah. **Kosong yang jujur lebih baik
daripada salah yang diam.**

---

## Utang tercatat

| utang | cara membayar |
|---|---|
| `feet/*` semua mundur ke `thin` | `lpc-2024-10-15-expanded-ulpc-set.zip` **punya** feet male/female/child — tinggal diekstrak, lalu hapus rantai mundurnya |
| `torso/pregnant` mundur ke `female` | hulu punya torso pregnant sendiri; belum ada di pustaka lokal. Sementara perutnya tak tertutup benar |
| `torso/child` kosong | perlu baju anak; hulu pun tak mendaftarkan `child` di definisi bajunya |
| resep 10 tokoh masih bentuk lama | belum dimigrasikan ke resep berbasis garmen — lihat di bawah |

---

## Yang BELUM dikerjakan (sengaja)

**Sepuluh resep tokoh masih memakai bentuk lama** (`"legs": "pants_thin"`). Arsitektur
barunya sudah berdiri dan teruji, tapi migrasi resep berarti **merakit ulang sepuluh
lembar karakter** — dan itu menyentuh `game/assets/` serta harus melewati penjaga
siluet #231. Dikerjakan terpisah, dengan tangkap-layar sebelum/sesudah.

Artinya cacat "kaki kelebaran" **belum hilang dari layar** — yang sudah berdiri adalah
sistem yang membuatnya tak bisa terulang begitu resepnya dimigrasikan.
