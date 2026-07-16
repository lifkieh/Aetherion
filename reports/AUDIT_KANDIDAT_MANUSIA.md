# AUDIT KANDIDAT MANUSIA — Calon Pengganti Ninja Adventure

> **Keputusan Direktur:** Cluster A (Ninja Adventure 16px) **DITOLAK** — gayanya tidak disukai; ia
> gagal target JRPG top-down three-quarter. Audit ini mencari **keluarga visual pengganti**.
> ⚠ **INI AUDIT — NOL perubahan `game/`, nol file dihapus, nol wire. 947 test tetap hijau.**
> Metode: ekstrak stash kedua `.vscode/assets_raw_new/`, **baca berkas lisensi** (bukan tebak nama),
> **lihat sprite**, jalankan uji siluet dengan cara yang sudah terbukti benar. Tanggal: 2026-07-16.

> **TEMUAN INDUK:** stash kedua `.vscode/assets_raw_new/` **didominasi ekosistem LPC (Liberated Pixel
> Cup / "Universal Sprite Sheet")** — persis *jalur-ketiga* yang disebut brief, dan **sudah ada di
> gudang.** LPC memenuhi target gaya + cakupan yang Ninja gagal penuhi. Harganya: **lisensi CC-BY-SA
> (share-alike, flag kuning)** + **butuh pipeline perakitan lapisan.**

---

## FASE 1 — SENSUS SUMBER SPRITE MANUSIA

| Sumber | Lokasi | Jml karakter | Ukuran | Sudut | Arah | Walk? | LISENSI (dibaca) | Dewasa | Tua | Anak | Hewan(ayam) | Monster |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **LPC Character Bases v3.1** | stash2 | modular (♂♀ muscular pregnant **child**) × banyak skin | **64×64** | **¾ top-down** | 4 (+diag via anim) | ✅ full (walk/cast/thrust/slash/shoot) | **CC-BY-SA 3.0 / GPL 3.0** | ✅ | ✅(via layer) | ✅ | — | — |
| **LPC pakaian/rambut/aksesori** | stash2 (Sara, crusader, spartan, gentleman, dark-elves, ratusan hair/beard/clothes) | ratusan lapisan | 64×64 | ¾ | 4 | ✅ | CC-BY-SA 3.0 / CC-BY 3.0 (campur, per-file di `credits.txt`) | ✅ | ✅ | ✅ | — | — |
| **LPC animals** | stash2 (`chicken.png`, pig/horse/cat/wolf/cabbit/bunny/`bird_1..3_*`) | ~12 spesies | 64×64 grid | ¾ | 4 | ✅ | CC-BY-SA 3.0 (bluecarrot16 dkk) | — | — | — | ✅ **ayam ada** | (hewan) |
| **LPC monsters** | stash2 (`lpc-monsters.zip`, goblin/orc/minotaur/wraith/dragon) | ~belasan | 64×64 | ¾ | 4 | ✅ sebagian | CC-BY-SA 3.0 | — | — | — | — | ✅ |
| **24×32 Characters (Kushnariova)** | stash2 `24x32 black characters pack` | ~15 arketipe kelas | **24×32** + **portrait** | **¾ (RPG-Maker klasik)** | 4 | ✅ (3-frame) | **CC-BY 3.0 / OGA-BY 3.0** | ✅ | ✖ | ✖ | ✖ | ✖ |
| **Dungeon Crawl Stone Soup** | stash2 `...Full.zip` (6169 file, **1347 monster**) | ratusan | 32×32 | top-down | 1 (statis) | ✖ (ikon statis) | **CC0** ✅ | ✖ | ✖ | ✖ | ✖ | ✅✅✅ |
| **Pixel Crawler** | gudang-1 | 1 base modular | 32×32 | top-down | 4 | ✅ (farming) | Custom restricted (no redist) | ✅ | ✖ | ✖ | ✖ | (mob) |
| **Ninja Adventure** *(DITOLAK)* | gudang-1 | ~90 | 16×16 | ¾ ringan | 4 | ✅ | CC0 | ✅ | ✅ | ✅ | ✅ | ✅ |
| customizable_characters / PartsSpriteSheet | stash2 | modular kecil | ~kecil | top-down | 4 | ✅ | **tak ada berkas lisensi di zip → TIDAK DIKETAHUI** | ✅ | ? | ? | ✖ | ✖ |
| Overland Sprites | stash2 | ~puluhan mini | ~16px overworld | top-down | 4 | ✅ | tak ada lisensi di zip → cek OGA (Mandi Paugh, umumnya CC-BY-SA) | ✅ | ? | ? | ✖ | ✖ |
| Monster RPG 2 (Ben McGraw) | stash2 tar.gz | battler/monster | var | side/battler | — | ✖ | perlu cek (umumnya CC-BY-SA) | ✖ | ✖ | ✖ | ✖ | ✅ |
| 2DPIXX Isometric Fantasy | stash2 | tileset | — | **ISOMETRIC** | — | — | cek | — | — | — | — | — |

**Catatan lisensi (aturan Fase 1):** LPC = **share-alike → flag kuning** (bukan hijau, bukan tolak).
Kushnariova = **CC-BY** (atribusi saja, TANPA SA → lebih bersih). DCSS = **CC0** (paling bersih).
`customizable_characters` & beberapa zip = **nol berkas lisensi → TIDAK DIKETAHUI = TOLAK** sampai bukti.
CraftPix "ruined temple" (di stash) = lisensi CraftPix free **restriktif (no-redistribute) → tolak untuk repo**.
2DPIXX = **isometric** → salah sudut pandang untuk JRPG top-down, gugur di gaya.

---

## FASE 2 — UJI (3 syarat terbukti + UJI SILUET WAJIB)

Uji dijalankan benar: **ukuran relatif sejati · bersebelahan · di atas grass tileset kandidat** —
bukan zoom, bukan latar putih. **Uji siluet (isi hitam) = KRITERIA UTAMA** (temuan yang membunuh Ninja).

**LPC — uji siluet (base bodies, skala sejati diukur):** dewasa ♂ **30px** · ♀ **28px** · **anak 23px**.
- **LULUS.** Anak **jelas lebih pendek & lebih bulat** dari dewasa — **terbaca dari tinggi/proporsi saja**,
  tanpa warna. ♂ lebih bidang dari ♀. Ini **kebalikan Ninja** (di sana dewasa/tua/anak = blob identik).
- Dan itu **baru base telanjang.** LPC modular: tambah **topi/rambut/jubah/janggut** → variasi siluet
  meledak (mis. `whitebeard` = lapisan janggut+rambut putih untuk membuat orang tua). **Hook siluet
  (temuanku sendiri, kini hukum) terpenuhi by-design.**

**Kushnariova 24×32 — dilihat (`Aristocrat-M`):** walk-sheet ¾ + **portrait wajah** menyertai. Outline
gelap tipis, shading lembut, kostum kelas berbeda (aristocrat/fighter/mage) → **siluet beda per-kostum**.
- **LULUS untuk arketipe dewasa**, TAPI **tak ada anak/tua** di set → uji siluet lintas-usia **tak bisa
  dijalankan** (bahan tidak ada). Cakupan usia = bolong.

**DCSS:** ikon statis 1-arah, bukan keluarga karakter beranimasi → **gugur sebagai keluarga warga**
(tetap juara sebagai bank monster CC0).

*(Komposit uji tidak di-commit: berisi aset CC-BY-SA/restricted → menyeret SA ke repo. Bukti = angka
piksel terukur di atas + deskripsi.)*

---

## FASE 3 — COCOK TARGET GAYA?

Target kanon: **JRPG top-down ¾ · Suikoden/RPG-Maker/Harvest-Moon · outline gelap tipis · shading
lembut 2-3 tingkat · palet hangat-pudar · tema desa tua mengecil.**

| Kandidat | Sudut ¾? | Outline tipis? | Shading lembut? | Palet hangat? | Dekat referensi? | Verdikt gaya |
|---|---|---|---|---|---|---|
| **LPC** | ✅ | ✅ | ✅ (2-3 tingkat) | ✅ (bisa di-recolor) | mirip Sacred/RPG-klasik | **MEMENUHI** |
| **Kushnariova 24×32** | ✅ | ✅ | ✅ | ✅ | **paling dekat "RPG Maker klasik"** | **MEMENUHI (paling on-referensi)** |
| DCSS | top-down datar | tegas | terbatas | dingin/dungeon | tidak | gagal (untuk warga) |
| Ninja *(ditolak)* | ¾ ringan | ✅ | 2 tingkat | ✅ | terlalu imut/16px | **DITOLAK Direktur** |

Keduanya (LPC, Kushnariova) **lolos target** yang Ninja gagal. DCSS gagal sebagai keluarga warga.

---

## FASE 4 — LAPORAN PER KANDIDAT

### ★ LPC (Liberated Pixel Cup) — *kandidat utama*
- **Kelebihan:** cakupan **tak tertandingi** (dewasa ♂♀, **anak**, **tua** via lapisan, muscular,
  pregnant, **hewan termasuk ayam**, **monster**), **animasi 4-arah penuh** (walk/cast/thrust/slash/
  shoot/hurt), **modular** (rakit ras/usia/profesi apa pun dari lapisan) → **langsung melayani kanon
  #138 "NPC generik = generate unik per individu"** & 8-ras × generasi. Lolos uji siluet. Gaya ¾ hangat.
- **Kelemahan:** **bukan sprite jadi** — harus **dirakit dari lapisan** (body+kepala+rambut+baju+gear);
  **tanpa portrait bawaan**; kualitas antar-kontributor sedikit bervariasi.
- **Risiko:** **CC-BY-SA** menuntut disiplin atribusi + rilis turunan ber-SA; perlu **pipeline
  perakit** (engineering) sebelum produktif.
- **Skalabilitas 10 tahun:** **TERTINGGI.** Modular = tak pernah kehabisan variasi; komunitas LPC
  masih tumbuh (hair 2024, bases v3). Satu-satunya yang skala ke ambisi Aetherion.
- **LISENSI:** 🟡 **CC-BY-SA 3.0 / GPL 3.0** (sebagian CC-BY 3.0, sedikit CC0) — **komersial DIIZINKAN**
  (SA ≠ NC), wajib **atribusi** + turunan seni ber-**CC-BY-SA**. Tidak menulari kode game (seni = data).
- **Cakupan:** ✅ lengkap (warga/tua/anak/ayam/monster/4-arah).
- **Ongkos migrasi:** ganti SEMUA sprite Ninja di `game/assets/` (player, NPC, monster, hewan) — **tapi
  modular menurunkan ongkos per-karakter**; bangun **pipeline perakit LPC** sekali (selaras generator
  Python proyek yang sudah ada).
- **Bolong yang harus dibuat sendiri:** **portrait** (LPC tak punya) → pakai Kushnariova/produksi;
  tileset desa ¾ senada (LPC punya tileset terpisah — perlu kurasi lanjutan); pipeline perakit.

### ☆ Kushnariova 24×32 — *runner-up, lisensi paling bersih*
- **Kelebihan:** **sprite JADI** (tak perlu rakit) + **portrait wajah menyertai**, **paling dekat "RPG
  Maker klasik"**, **CC-BY (tanpa SA)** = lisensi paling bersih di antara yang lolos gaya, mudah dipakai.
- **Kelemahan:** **cakupan tipis** (~15 arketipe kelas dewasa); **tak ada anak, tua, hewan, monster**;
  bukan modular → **tak bisa generate NPC unik** (#138 mati).
- **Risiko:** kehabisan variasi cepat; game 8-ras × generasi butuh ratusan wajah — pack ini tak cukup.
- **Skalabilitas 10 tahun:** **RENDAH-SEDANG.** Bagus untuk **tokoh bernama pilihan**, buruk untuk cast masif.
- **LISENSI:** 🟢-ish **CC-BY 3.0 / OGA-BY 3.0** (atribusi wajib, tanpa SA).
- **Cakupan:** ✖ (dewasa saja; nol hewan/monster/anak/tua).
- **Ongkos migrasi:** ganti sprite manusia; **hewan & monster harus dari sumber lain** (DCSS CC0?).
- **Bolong:** anak, tua, hewan (**ayam!**), monster, cast besar → semua harus dicari/dibuat.

### ☆ DCSS (Dungeon Crawl Stone Soup) — *bukan keluarga warga; juara monster CC0*
- **Kelebihan:** **CC0** (paling bersih), **1347 monster** + ratusan item/tile. **Kelemahan:** ikon
  **statis 1-arah** (bukan walk-cycle), gaya dungeon dingin. **Skalabilitas:** tinggi sebagai **bank
  monster/props CC0**, nol sebagai keluarga warga. **Peran:** **penambal monster/ikon**, bukan pengganti Ninja.

### Sisanya (ringkas)
- **Pixel Crawler** (gudang-1): 32px modular farming, **restricted (no-redist)** → tak aman repo. Bukan pengganti.
- **customizable_characters / Overland / Monster RPG2 / 2DPIXX:** lisensi tak ada di unduhan / isometric /
  battler → **TOLAK atau tak relevan** sampai bukti lisensi & kecocokan gaya.

---

## FASE 5 — REKOMENDASI

**Kesimpulan jujur (jalur-ketiga):** **ada** kandidat yang memenuhi gaya + cakupan — **LPC** — tetapi
harganya **share-alike + pipeline perakit**. Tidak ada keluarga **CC0-penuh-cakupan-siap-pakai** di
gudang; itu tidak ada di dunia bebas mana pun (LPC = standar de-facto justru karena itu). Jadi pilihannya
bukan "sempurna vs cacat", melainkan **"cakupan penuh dengan flag-kuning SA" (LPC) vs "lisensi bersih tapi
cakupan bolong" (Kushnariova)**. Untuk game seukuran Aetherion — **8 ras × generasi × penuaan × profesi,
NPC generik yang WAJIB di-generate unik (#138)** — hanya sistem **modular** yang bertahan. Kushnariova
kehabisan napas di desa kedua; DCSS bukan warga; sisanya gugur lisensi/gaya.

Aetherion secara harfiah membutuhkan **perakitan-lapisan** untuk memenuhi kanonnya sendiri. LPC adalah
satu-satunya yang menyediakannya, gratis, dalam gaya yang benar. Harga SA (atribusi + turunan ber-SA)
**bisa dibayar** oleh proyek yang memang sudah berbasis aset CC & repo terbuka — jauh lebih murah daripada
membangun 500 karakter tangan. DCSS (CC0) menambal monster; portrait ditambal Kushnariova/produksi — di
bawah **satu** keputusan keluarga, bukan tambal-sulam gaya.

**Rekomendasi saya: LPC (Liberated Pixel Cup) sebagai keluarga karakter kanon, dengan konsekuensi
CC-BY-SA diterima secara sadar. Kalau Direktur memilih lain, risiko terbesarnya adalah memilih pack
"siap-pakai + lisensi bersih" (mis. Kushnariova 24×32) yang cast-nya ~15 karakter tetap — sehingga
generate-NPC-unik (#138), 8 ras, dan generasi menjadi mustahil, dan tim terpaksa mengomisikan ratusan
karakter tangan yang tak dimilikinya: cakupan runtuh di desa kedua, dan proyek berhenti karena kehabisan
orang untuk mengisi dunia yang seluruh tesisnya adalah "dunia yang dihuni".**
