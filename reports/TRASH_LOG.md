# TRASH_LOG — apa yang dipindah, dari mana, kenapa

**Dibuat:** 2026-07-21 · **Sifat:** catatan pemindahan. **NOL berkas dihapus.**
**Tujuan:** `assets_raw/_TRASH/` (di dalam repo; `assets_raw/` ada di `.gitignore`,
jadi ia tak ikut ter-commit dan tak membengkakkan git).
**Asal:** `C:\Users\user\OneDrive\Desktop\Gudang_asset\` (akar).

| | |
|---|---|
| Dipindah ke `_TRASH` | **23 berkas · 149,5 MB** |
| Dipindah ke `_SUMBER` | **2 berkas** (.psd/.xcf — aturan berkas-sumber) |
| Ukuran `_TRASH` akhir | **144 MB** |
| Gudang akar: sebelum → sesudah | 461 → **436** entri |
| Ragu, **DITINGGAL** untuk Direktur | **7** (daftar di bawah) |

**Cara membalik:** setiap berkas dipindah **apa adanya, nama tak diubah**. Kembalikan
dengan memindah dari `assets_raw/_TRASH/<grup>/` ke akar gudang. Manifes mesin (nama,
byte, sha256) ada di `assets_raw/_TRASH/_pindah.json`.

**Penjagaan yang dipakai saat memindah** (bukan formalitas — ini yang membuat pemindahan
aman): tiap berkas di-SHA256 sebelum pindah; untuk grup duplikat, **kembarannya diperiksa
ulang masih ada dan masih byte-identik tepat sebelum pindah** (memindah "duplikat" yang
pasangannya ternyata hilang = menghapus satu-satunya salinan); sesudah pindah, hash di
tujuan dicocokkan lagi dan keberadaan sumber dipastikan sudah nihil.

---

## A. DUPLIKAT BYTE-IDENTIK — 20 berkas · 36,8 MB

> **Koreksi setelah aturan berkas-sumber ditambahkan:** dua di antaranya —
> `treesv6_0 (1).psd` dan `easter_bunny-24x32 (1).xcf` — **dipindahkan lagi** dari
> `_TRASH/duplikat_byte/` ke **`assets_raw/_SUMBER/`**. Keduanya tetap kembar
> byte-identik, tapi berkas sumber tak boleh masuk tong sampah walau kembar.

Bukan dinilai dari nama "(1)". **Dibuktikan dengan SHA256**: isi kedua berkas sama persis.
Yang ditinggal selalu yang bernama polos.

| dipindah | kembaran yang DITINGGAL | ukuran | alasan |
|---|---|---|---|
| `lpc-character-bases-v3_1 (1).zip` | `lpc-character-bases-v3_1.zip` | 33,96 MB | sha256 identik — dan ini pack badan yang dipakai 6 NPC + 3 anak + 20 warga |
| `submission_daneeklu (1).zip` | `submission_daneeklu.zip` | 0,56 MB | sha256 identik — sumber ladang & pagar C3 |
| `Androgynous Pants (1).zip` | `Androgynous Pants.zip` | 0,61 MB | sha256 identik |
| `treesv6_0 (1).psd` | `treesv6_0.psd` | 0,37 MB | sha256 identik (psd sumber tetap ada 1 salinan) |
| `kobold-0.5 (1).zip` | `kobold-0.5.zip` | 0,32 MB | sha256 identik |
| `ground_tiles (1).png` | `ground_tiles.png` | 0,23 MB | sha256 identik |
| `magecity (1).png` | `magecity.png` | 0,17 MB | sha256 identik — sumber prop lpc32 yang dipakai |
| `Cliff_tileset (1).png` | `Cliff_tileset.png` | 0,10 MB | sha256 identik |
| `crops-v2.1 (1).zip` | `crops-v2.1.zip` | 0,08 MB | sha256 identik |
| `graphics-tiles-waterflow (1).png` | `graphics-tiles-waterflow.png` | 0,07 MB | sha256 identik |
| `crops (1).zip` | `crops.zip` | 0,06 MB | sha256 identik |
| `iso-64x64-outside (1).png` | `iso-64x64-outside.png` | 0,06 MB | sha256 identik |
| `easter_bunny-24x32 (1).xcf` | `easter_bunny-24x32.xcf` | 0,04 MB | sha256 identik |
| `Extra_Unfinished4 (1).png` | `Extra_Unfinished4.png` | 0,04 MB | sha256 identik |
| `object- layer (1).png` | `object- layer.png` | 0,03 MB | sha256 identik |
| **`fluffy_wolf_tail_back.png`** | `wolf_tail_back.png` | 0,02 MB | ⭐ **nama berbeda, isi SAMA PERSIS** — ketahuan dari hash, mustahil dari nama |
| **`fluffy_wolf_tail_front.png`** | `wolf_tail_front.png` | 0,01 MB | ⭐ idem |
| `goblins2 (1).png` | `goblins2.png` | 0,01 MB | sha256 identik |
| `evidence (1).json` | `evidence.json` | 0,01 MB | sha256 identik (berkas repo yang nyasar ke Desktop, bukan aset) |
| `credits (1).txt` | `credits.txt` | ~0 MB | sha256 identik |

## B. RUSAK SECARA DATA — 2 berkas · 51,9 MB

| dipindah | ukuran | alasan |
|---|---|---|
| `Tidak dipastikan 279939.crdownload` | 25,47 MB | **unduhan terputus.** 4 byte awal `PK\x03\x04` (zip) tapi `zipfile` menolak: *"File is not a zip file"* — direktori pusat zip tak pernah sampai. Tak bisa dibuka, tak bisa diperbaiki |
| `Tidak dipastikan 62631.crdownload` | 26,39 MB | idem — header zip ada, isi terpotong |

## C. SALAH GAYA / UKURAN EKSTREM — 3 berkas · 61,3 MB

**Ketiganya dirasterisasi dan DILIHAT lebih dulu** (lembar kontak ada di scratchpad sesi).
Bukan "beda dikit" — ketiganya bukan pixel art sama sekali.

| dipindah | ukuran | alasan (dari melihat) |
|---|---|---|
| `jatstory_all_separated_files.zip` | 50,91 MB | **ilustrasi tinta kartun**, bukan pixel art. Contoh: arena 745×631 bergaris tangan, kartu joker, ketapel. Nol kisi |
| `oldvillage.zip` | 9,02 MB | **vektor-kartun bergaris hitam tebal**, 219–2000 px per berkas (satu sungai 2000×1567). Dua kriteria terpenuhi sekaligus: gaya + ukuran |
| `2DPIXX_-_Free_2D_Isometric_Fantasy_Pack.zip` | 1,36 MB | **isometrik 128 px, berbayang halus** (bukan pixel art): karakter 128×160, ubin dungeon 128×128 belah-ketupat. Proyeksi belah-ketupat tak bisa dipetakan ke kisi ortogonal 32 |

---

## ⚠ RAGU — DITINGGAL DI GUDANG, keputusan Direktur

Semuanya **lolos** dari pembuangan karena tidak memenuhi kriteria tegas. Dicatat supaya
tak diperiksa ulang dari nol tiap sesi.

| berkas | kenapa terlihat seperti sampah | kenapa TETAP DITINGGAL |
|---|---|---|
| `Dungeon Crawl Stone Soup Full.zip` · `crawl-tiles Oct-5-2010.zip` | palet & garis beda dari LPC | **tetap pixel art 32px.** Kriteria "salah gaya total" menyebut realistis/3D/vektor — DCSS bukan itu. Beda-tipis = keputusan Direktur |
| `superpowers-asset-packs-various_2d.zip` | ubin 14–16 px, rumah seukuran satu petak | CC0, dan 14–16 px **bukan** "8px atau 128px+". Di luar kriteria |
| `nes_tile_set_cemetery_files.zip` | palet NES 8-bit 16×16 | idem — ukuran di luar pita kriteria |
| `Denzi_32x32_isometric.zip` (+varian transparan) | isometrik | **berkisi 32 dan pixel art.** Prop tunggalnya mungkin terpakai; hanya ubin tanahnya yang mustahil. Ragu = tinggal |
| `stone-bridge.png` · `stone-bridge2.png` | viaduk **tampak samping** | **Direktur: sudut pandang bukan alasan buang.** Prop samping sering pas di top-down |
| `craftpix-net-160005-free-ruined-temple-...zip` | lisensi **proprietary** (tautan craftpix) | **lisensi = ⚠CEK, bukan sampah.** Bukan kriteria buang |
| `Slates v.2 [...].png` · `tileset_town_multi_v002.png` · `treepack*.png` | nol berkas lisensi | **lisensi tak jelas = mungkin berharga.** `tileset_town_multi` malah kandidat terkuat untuk bangunan multi-arah (`GUDANG_UNTUK_ASHBROOK.md` §4) |

## Yang sengaja TIDAK disentuh

- **Berkas repo yang nyasar ke gudang**: `ASHBROOK_MAP_SPEC.md` (⭐ baru ditemukan, dipakai
  untuk tata ulang), `Evidence.gd`, `A3_TRIASE.md`, `PASANG_R2.md`, `R3_SPEC_PEMBUSUKAN.md`,
  `TestRunner_R2_tests.gd`, `evidence.json` — **bukan aset, dan sebagiannya berharga.**
- **Berkas `.psd`/`.xcf` sumber** — hanya salinan **kembar byte-identik** yang dipindah;
  tiap sumber tetap punya satu salinan di gudang.
- **`Gudang_asset\_extracted\`** — jaring pengaman lisensi, tak disentuh.
- **`game/`** — nol perubahan.
