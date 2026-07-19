# PERBURUAN ASET 32px — target terarah

**Putusan yang dilayani:** dunia = **32px, CC0/CC-BY, BUKAN tileset LPC**. #232 tetap berdiri.
Karakter LPC 64px boleh masuk lebih dulu di dunia 16px lama (aneh sementara, benar selamanya).

⚠ **Nomor ledger:** Direktur menyebut putusan ini "#251", tapi **#251 sudah terpakai**
(koreksi #240, commit `25ede9b`). Saya mencatatnya sementara sebagai **#252** —
baris ledger belum ditulis, menunggu konfirmasi nomor.

---

## 1 — Dari 148 aset dunia: mana WAJIB, mana bisa ditunda

Jawaban singkatnya: **bukan 148. Untuk Ashbrook, angkanya ~28.**
Sisanya biome yang belum jadi panggung cerita mana pun.

### 🔴 TIER 1 — Ashbrook (wajib 32px lebih dulu) · ±28 aset

| Kelompok | Berapa | Isi |
|---|---|---|
| **Ubin tanah** | **4** | `grass_0` · `grass_1` · `dirt_0` · `cobble_0` |
| Bangunan | 4 | `inn` (rumah Merrit + gudang gandum) · `house_blue` · `house_green` · `store` (tungku Halloran) |
| Prop cerita Ashbrook | 5 | `ruins` · `otha_sign_fadedmark` · `lantern` · `lantern_glow` · `bench` |
| Prop interior (`HouseInterior._deco`) | 11 | `int_bed` · `int_lamp` · `int_rug` · `int_shelf` · `int_table` · `workbench` · `barrel` · `crate` · `sack` · `stall` · `flower_pot` |
| Deko desa (`Town.gd`) | 4 baru | `hay` · `laundry` · `trough` · `fence_h` |

### 🔴🔴 Temuan yang mengubah urutannya

**3 dari 4 ubin tanah Ashbrook TIDAK ADA HARI INI.**

`Ashbrook.gd:104` meminta `grass_0`, `grass_1`, `dirt_0`, `cobble_0`.
Di `game/assets/game/tiles/` hanya ada **`cobble_0`**. Yang lain tak pernah dibuat —
namanya pun tak cocok (`dirt_path` ada, `dirt_0` tidak).

Akibatnya, karena `ResourceLoader.exists` menjaga di baris 107, sumber **0, 1, dan 2 tak pernah
didaftarkan** ke TileSet. Lalu `_build_ground()` memasang sel dengan sumber 0/1 dan `_build_road()`
dengan sumber 2 — **ketiganya tak sah, jadi tak menggambar apa pun.** Ashbrook hari ini
**tidak punya rumput dan tidak punya jalan**; yang terlihat cuma alun-alun cobble (sumber 3).
Terlihat jelas di `_work/shot_bench.png`: petak cobble di tengah, sisanya kosong gelap.

Ini **pola yang sama persis dengan `lantern.png`**: konsumen ter-wire, seni tak ada, gagal diam-diam.
Ketiganya kini sudah muncul dua kali di sesi ini — patut dicurigai ada lagi.

**Artinya untuk perburuan:** 3 ubin itu **bukan migrasi, melainkan pembuatan.**
Tak ada versi 16px yang perlu dibuang. Kalau dunia memang menuju 32px,
**buat langsung di 32px** — nol pekerjaan terbuang, dan sekaligus memperbaiki bug yang sudah ada.
Ini titik masuk termurah yang tersedia.

### 🟡 TIER 2 — menyusul (setelah Ashbrook terbukti) · ±60

Greenvale/Town (`well`, `blacksmith`, `tower`, `townhall`, `stable`, `signboard`, `street_lamp`,
`statue`, `stone_gate`, pagar), pohon (14 varian), semak/batu/bunga sebaran, `chests` (6).

### ⚪ TIER 3 — tunda lama · ±60

- **Candyveil 11 ubin + prop permen** — wilayah belum jadi panggung cerita.
- **Desert 6 ubin + kaktus/batu gurun** — idem.
- **Dungeon 7 ubin + `torch`/`bat`/`proj`** — bisa pakai satu pack dungeon 32px sekaligus nanti.
- **25 monster** — terikat pertarungan, bukan tileset; boleh tetap 16/32 jauh lebih lama.
- **`vfx` (1), `sky` (20), `ui` (72)** — **tak terikat skala dunia sama sekali.** Jangan disentuh.

**Ringkas:** 28 wajib · 60 menyusul · 60 tunda. Bukan 148 sekaligus.

---

## 2 — Verifikasi ulang gudang: ada 32px bersih atau tidak?

**Diperiksa ulang secara spesifik untuk grid 32px, bukan "asal 32".** Hasilnya tetap: **NOL.**

Pemindaian kelipatan-32 memang mengembalikan 9.496 berkas — tapi itu menyesatkan, karena
**setiap lembar LPC 64px juga kelipatan 32**. Setelah LPC dikeluarkan (dilarang #232),
yang tersisa diperiksa grid aslinya:

| Pack | Kandidat | Grid sebenarnya | Vonis |
|---|---|---|---|
| Ninja Adventure | 223 | **16px** — `TilesetHouse` 528×368 (528 ÷ 32 = 16,5 → bukan 32) | ❌ |
| Pixel Crawler | 142 | **16px** — `Dungeon_Props` 400×400 (400 ÷ 32 = 12,5) | ❌ |
| `assets_aetherion/tilesets` | 3 | **Duplikat Ninja Adventure** (nama & ukuran identik) → 16px | ❌ |
| `aetherion_original_assets_v1` | 41 | 32×32 **tapi ikon elemen & VFX**, bukan ubin | ❌ |
| kenney fantasy-ui-borders | 128 | 48×48, **UI** | ❌ (tak relevan) |
| `objek_terpilih` (superpowers CC0) | 1 | 12–30px | ❌ |

**Kurasi lama benar: nol ubin dunia 32px berlisensi bersih di gudang.**
Yang paling dekat pun (craftpix, 32px, gaya top-down bagus) gugur di lisensi — bukan CC0/CC-BY.

---

## 3 — Sumber 32px CC0/CC-BY yang layak dikejar (lisensi sudah dicek di halamannya)

### ✅ Layak — CC0 (nol kewajiban)

| Pack | Penulis | Ukuran | Isi | Menutup |
|---|---|---|---|---|
| **Mage City Arcanos** | Hyptosis | **32×32** | bangunan, jalan, terrain kota fantasi | **Tier 1: ubin tanah + bangunan Ashbrook** |
| **Dungeon Crawl 32×32 tiles** | Chris Hamons (kolektif DCSS) | **32×32**, ortografis **three-quarter** | **3.000+** ubin: terrain, dinding, perabot, benda, fitur dungeon | **Tier 1 prop + seluruh Tier 3 dungeon** |
| **Roguelike Indoor pack** | Kenney | 480 sprite | dapur, **meja, kursi, sofa**, perabot rumah | **Tier 1 interior** (`int_*`) |

⚠ **Roguelike Indoor pack: ukuran ubin TIDAK tercantum di halamannya.** Kenney kebanyakan
16×16/17×17. **Wajib diverifikasi sebelum diandalkan** — jangan ulangi kesalahan "nama ≠ isi".

### ✅ Layak — CC-BY (wajib atribusi, TANPA share-alike → #232 aman)

| Pack | Penulis | Ukuran | Catatan |
|---|---|---|---|
| **Lots of free 2d tiles and sprites by Hyptosis** | Hyptosis (via Zabin) | **32×32** (kecuali batch 5 = 16px) | Panen terbesar: terrain, rumah, kastil, dinding, interior+eksterior. Penulisnya: *"all I want is credit."* |
| **Orthogonal Fantasy 32x RPG Graphics (CC0 atau CC-BY)** | kurasi *byth* | **32×32** | grassland/hutan, **ubin interior**, ikon, prop, GUI. ⚠ **KOLEKSI** — campuran CC0 & CC-BY, cek per-berkas |

### 🔴 Jebakan — JANGAN dikejar

| Pack | Kenapa gugur |
|---|---|
| **Exterior 32x32 Town tileset** (Sonetto) | **CC-BY-SA** → melanggar #232 & putusan dunia-non-SA |
| **RPG Town Tileset** · **[LPC] House interior and decorations** | di-host `lpc.opengameart.org` → **turunan LPC** |
| **Top Down 2D JRPG 32x32 Art Collection** (Lvaslyfcms) | agregasi tanpa lisensi tunggal; **memuat karya turunan LPC** |
| **AK TopDown Asset Packs** | 60+ pack, tanpa lisensi tunggal, tanpa info ukuran |

### Aturan yang tetap berlaku saat mengunduh

`docs/ASSET_LOG.md` §3/§4 — **cek PER-BERKAS; nama folder BUKAN lisensi; "free to use" =
TIDAK DIKETAHUI = TOLAK.** Dua entri terakhir di daftar layak adalah **koleksi**, bukan pack —
justru bentuk yang paling sering menyelundupkan lisensi campur. Pelajaran 80-CC0-RPG-SFX.

---

## Urutan berburu yang saya sarankan

1. **Mage City Arcanos** (CC0) → uji langsung untuk 3 ubin Ashbrook yang hilang + 4 bangunan.
   Kalau gayanya cocok, satu pack itu sudah menutup separuh Tier 1.
2. **Dungeon Crawl 32×32** (CC0) → prop. Perspektifnya **ortografis three-quarter**, sama dengan
   Ashbrook — satu-satunya kandidat yang perspektifnya sudah terkonfirmasi cocok.
3. **Hyptosis CC-BY** → cadangan/pelengkap kalau (1) kurang.
4. **Roguelike Indoor** → hanya setelah ukuran ubinnya diverifikasi.

**Uji terlebih dahulu, jangan borong.** Uji berdampingan seperti `OBJEK_KURASI2.md`:
bentrok gaya baru terlihat saat bersebelahan, bukan sendirian.
