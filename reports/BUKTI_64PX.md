# LAYAR BUKTI 64px (#253) — dan ongkos sesungguhnya

**Bukti:** `reports/preview/bukti_16_vs_64.png` (1920×1080, zoom main 2×)
**Scene:** `game/scenes/world/Ashbrook64.tscn` — **BARU dan terpisah.**
`Ashbrook.tscn`/`Ashbrook.gd` **tidak disentuh.** Tak di-wire, tak masuk alur permainan.
**Gerbang:** 1026 passed, **0 failed** (#249).

---

## Kenapa satu scene dua paruh, bukan dua tangkapan ditempel

Kalau kiri dan kanan difoto terpisah, **beda jam saja sudah merusak penilaian** —
`GameClock` memakai jam WIB nyata, jadi satu bisa malam dan satu senja, dan mata akan
menilai pencahayaan, bukan skala. Di sini: satu kamera, satu zoom, satu `CanvasModulate`
dipatok, satu lampu. Yang berbeda **hanya skalanya.**

## Apa yang ada di layar

| | KIRI (16px) | KANAN (64px) |
|---|---|---|
| Karakter | `_charsys` 32px, badan tampak 12×27 | **Merrit LPC 64px asli** — dirakit `assemble.py` dari `merrit_fane.json` (botak, overall, #231 hook `__bare__`) |
| Tanah | `cobble_0` · `dirt_path` · `storm_grass` lama | **digambar NATIF 64px** (`_tools/gen_tiles64.py`): batu bernat & bersorot, rumput berhelai, jalan berkerikil |
| Bangunan | `inn.png` 74×98 | `inn.png` **dinaikkan 4×** — sengaja |
| Lentera | `lantern.png` 12×20 + glow | dinaikkan 4× + glow |

---

## ⚠ BACA INI SEBELUM MENILAI GAMBARNYA

Panel kanan **mencampur tiga hal berbeda**, dan hanya dua yang jujur:

1. **Merrit LPC — bukti SAH.** Ini seni 64px sungguhan. Bandingkan dengan sosok kecil di kiri.
2. **Tanah 64px — bukti SAH.** Digambar natif; nat batu, helai rumput, dan kerikil itu
   **memang tak muat di 16px.** Ini contoh nyata "detail yang dibuka 64px".
3. **Bangunan & lentera — BUKAN bukti.** Itu aset 16px yang digemukkan 4×. Tampak kotak-kotak
   dan buram. **Sengaja saya biarkan begitu**, karena itulah yang akan Direktur dapatkan
   kalau migrasi dilakukan tanpa menggambar ulang: bukan keindahan, hanya piksel yang lebih besar.

**Jadi jawaban jujur atas pertanyaan Direktur belum bisa diberikan sepenuhnya hari ini**,
dan sebabnya penting: **tak ada satu pun tileset/objek dunia 64px berlisensi bersih yang kita
punya untuk diuji.** Nol di gudang, nol yang sudah dikurasi, nol yang sudah diverifikasi
lisensinya. Panel kanan menunjukkan apa yang **bisa** dibuka 64px — bukan Aetherion 64px
yang sesungguhnya, karena Aetherion 64px belum punya bahan.

---

## Jawaban berangka

### 1. Dari 148 aset dunia: berapa diganti, berapa sudah ada, berapa harus dicari/dibuat

| | Jumlah |
|---|---|
| Aset dunia terikat skala | **148** |
| Sudah punya pengganti 64px di gudang | **0** |
| Harus dicari atau dibuat | **148** |

Diperiksa ulang khusus untuk 64px, bukan sekadar "kelipatan 64":

| Sumber | Kelipatan 64 | Kenyataannya |
|---|---|---|
| Ninja Adventure | 175 | lembar **karakter** 64×64 berisi seni 16px — bukan tileset |
| Pixel Crawler | 85 | lembar animasi karakter; propnya grid 16px |
| `assets_aetherion` | 4 | duplikat tileset Ninja Adventure (16px) |
| `aetherion_original_assets_v1` | 0 | — |
| **LPC / ULPC** | ribuan | **64px sungguhan, TAPI CC-BY-SA → dilarang #232 untuk dunia** |

**Koreksi laporan saya sebelumnya:** saya menulis "nol 32px bersih di gudang". Itu **kurang
teliti** — `assets_raw/_extract/PixelArtTopDown_Basic/` berisi **Cainos "Pixel Art Top Down
Basic v1.2.3"**, tileset top-down **grid 32px** (TX Tileset Grass/Stone 256×256, TX Struct/Props
512×512). Saya melewatkannya karena hanya memindai nama pack tingkat atas.
**Tapi ia tetap tak bisa dipakai:** **nol berkas lisensi di dalam pack**, hanya `Documentation.url`;
halaman dokumentasinya pun tak menyebut lisensi. Aturan #4 kita: *"lisensi ambigu = TIDAK
DIKETAHUI = TOLAK"*. → **TAHAN**, perlu Direktur meminta lisensi resmi ke `support@cainos.net`.
Kalau ternyata CC-BY, ini kandidat 32px terkuat yang kita punya — walau bukan 64px.

### 2. Ukuran petak 16→64: apa yang pecah

Bukan daftar teori — semuanya ada di kode yang sudah saya baca:

| Yang pecah | Di mana | Kenapa |
|---|---|---|
| **Konstanta petak** | `const TILE := 16` di **6 berkas** (`Ashbrook.gd:15`, `Main.gd`, `Desert.gd:6`, `Candyveil.gd:5`, `Frostpeak.gd:6`, `DungeonBase.gd:7`) | titik masuknya |
| **Setiap koordinat dunia yang di-hardcode** | Ashbrook saja: `VC`, `MERRIT_HOUSE`, `INTERIOR`, `FOREST_Y`, `VANTAGE_X`, `EXIT_X`, `MAP_W/H`, 7 entri `RUINS[].at`, 8 posisi bangunan, loop 8 bangku, ~6 titik periksa | semuanya satuan piksel-16 → **×4** |
| **Offset jangkar** | `Interactable.gd` `offset = Vector2(0,-8)` (−14 utk `stone_gate`), `Player.gd:44` −8 | "kaki di titik origin" hanya benar untuk sel 32px |
| **Jarak berbasis piksel** | label `< 72.0`, "terlihat" `< 400.0`, fade beacon `< 320.0`, safe-zone | jadi 4× terlalu kecil |
| **🔴 `z_index` = y** | `Interactable.gd:49`, `Player.gd`, `Ashbrook.gd` | **plafon `z_index` Godot = 4096.** Sekarang y maksimum Ashbrook 704 → aman. Di 64px jadi **2816**, dan `_beacon` sudah dipatok **4096** — konstanta z tetap (lamp 1000) akan **tenggelam di bawah** objek ber-y besar. Kelas bug baru, bukan sekadar penskalaan |
| **Zoom kamera** | `Player.gd:33` zoom 2 | 16px: layar memuat 40×22 petak. 64px: **10×5,6 petak** — alun-alun Ashbrook (17×11) **tak muat di layar**. Zoom harus turun ~0,5, dan itu mengubah rasa permainan |
| **Kolisi** | `_build_boundaries` dihitung dari `MAP_W*TILE` | ikut otomatis ✅ — satu-satunya yang gratis |
| **Test** | 8 assertion `_charsys` (lebar 96), test Ashbrook berbasis posisi | akan merah — dan itu benar |

### 3. Estimasi kasar "unit kerja" — Ashbrook penuh ke 64px

Satu unit ≈ satu aset digambar/disumber+diverifikasi, atau satu titik kode diperbaiki+diuji.

| Bagian | Unit |
|---|---|
| Seni: 28 aset Tier-1 Ashbrook di 64px (4 ubin · 4 bangunan · 5 prop cerita · 11 interior · 4 deko) | **28–40** (lebih tinggi bila digambar sendiri, bukan disumber) |
| Kode: konstanta + koordinat + offset + jarak (≈50 titik di ~8 berkas) | **12–18** |
| Kebijakan `z_index` (rancang ulang, bukan geser angka) | **3–5** |
| Kamera & rasa main (zoom, batas, y-sort) | **3–5** |
| Test: perbarui assertion + tambah test dunia baru | **5–8** |
| Perakit LPC menyeberang ke runtime (pra-panggang atau port GDScript) | **5–10** |
| **Ashbrook saja** | **≈56–86 unit** |
| Seluruh game (5 wilayah, 148 aset) | **≈200–300 unit** |

**Direktur benar bahwa sekarang waktu termurah.** Ashbrook ≈ ¼ dari ongkos total; menunda
sampai 5 wilayah jadi akan melipatgandakannya. Tapi angka Ashbrook itu **bukan pekerjaan satu ronde.**

---

## Pertanyaan tunggal untuk Direktur

> **Apakah 64px cukup lebih indah untuk membenarkan membangun ulang 148 aset?**

Yang bisa saya sajikan hari ini:
- **Karakter: YA, jelas.** Merrit LPC vs `_charsys` bukan perkara selera.
- **Tanah: YA, ada ruang nyata.** Nat batu dan helai rumput itu memang tak muat di 16px.
- **Bangunan & prop: BELUM BISA DIJAWAB.** Nol bahan 64px berlisensi bersih untuk diuji.

**Saran saya sebelum Direktur mengunci #253:** jangan putuskan dari panel ini saja.
**Temukan dulu satu pack dunia 64px CC0/CC-BY yang nyata** — lalu ulangi layar bukti ini
dengan bangunan dan prop yang sungguh-sungguh 64px. Kalau pack itu tak ada,
**ongkos 148 aset bukan "sumber lalu pasang", melainkan "gambar sendiri dari nol"**,
dan itu bilangan yang sangat berbeda.

---

## Catatan kepatuhan

- **#232 ✅** — tanah 64px digambar sendiri (nol turunan LPC). LPC hanya dipakai untuk **karakter**.
- **#240 ✅** — `_tools/gen_tiles64.py` ter-commit; ubin bisa dibuat ulang persis (seed tetap).
- **Aset hasil rakit TIDAK di-commit** (sheet Merrit 832×2944 + slice, ubin t64, upscale).
  Semuanya bisa dilahirkan ulang dari script yang sudah ter-commit — itu justru inti #240.
  Sheet Merrit adalah **turunan LPC = CC-BY-SA**; memasukkannya ke `game/assets/` adalah
  keputusan rilis tersendiri (butuh kredit ikut dikirim), **bukan keputusan saya.**
