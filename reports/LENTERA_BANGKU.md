# LENTERA & BANGKU — mengisi konsumen yang sudah ter-wire

**Tanggal:** 2026-07-19 · **Pemicu:** temuan `OBJEK_KURASI2.md` — bukan "art tanpa
konsumen" (#244/#248), melainkan **KONSUMEN TANPA ART**.
**Batas dipatuhi:** nol wire adegan A1/A3 · script generator ter-commit (#240) · suite hijau.

---

## 1 — `lantern.png` (12×20) + `lantern_glow.png` (12×20)

**Konsumen sudah ada sejak sebelum sesi ini:** `Ashbrook.gd:164`.
Sebelumnya berkas itu tak ada → fallback `Image.create(6, 8)` = **kotak warna polos**.

Script: `_tools/gen_lantern.py` (peta piksel eksplisit, bisa dijalankan ulang, #240).
Palet **diambil verbatim** dari prop yang sudah ada — bukan tebakan:

| Sumber | Warna dipakai |
|---|---|
| `street_lamp.png` 12×44 | outline `#1E1612` · logam `#46424A`/`#3C3840`/`#302C34` · kaca `#FFE08C` · sorot `#FFF8D2` |
| `int_lamp.png` 12×24 | kaca redup `#DCB46E` |

Dua-duanya lampu, dua-duanya 12 px lebar → lentera ikut 12 px lebar.

### Tiga bug ditemukan saat menguji, bukan saat menggambar

Uji keterbacaan di scene aslinya membongkar tiga hal yang **tak terlihat dari kode**:

**(a) Aset baru tak pernah dipakai tanpa import.** Screenshot pertama tetap menampilkan
kotak 6×8 walau `lantern.png` sudah ada di disk. Sebabnya: PNG yang ditambah dari luar
editor belum di-import → `ResourceLoader.exists()` **false** → scene diam-diam jatuh ke
placeholder, tanpa error. Wajib `--headless --import` dulu. Sudah dicatat di `run_godot.bat`.

**(b) Lentera berada di luar jangkauan cahayanya sendiri.** `_lamp.z_index = 4000`,
sedangkan `Light2D.range_z_max` = **1024**. Dinding rumah tersorot, lenteranya tidak →
lampu terbaca **MATI** dari dekat. → `z_index = 1000` (tetap di atas semua yang ter-y-sort).

**(c) Beacon #218 menutupi kaca lentera.** `_build_vantage()` menaruh `_beacon` — kotak
6×6, `z_index = 4096` — **di posisi yang sama persis** dengan lentera. Karena z-nya juga
di luar `range_z_max`, ia tak tersentuh cahaya dan terbaca sebagai **kotak gelap menempel
di kaca**. Itulah "lampu mati"-nya, bukan seninya.
→ beacon di-fade ke 0 bila pemain < 320 px. **Node-nya TETAP ADA** (uji #218 memeriksa
grup `lamp_beacon`, bukan alpha-nya) — perannya sebagai titik cahaya lintas-jarak utuh.

Ketiganya diperbaiki di `Ashbrook.gd` (bug pada konsumen ter-wire, bukan wire adegan baru).

### Hasil

| Uji | Hasil |
|---|---|
| Dari **dekat**, ukuran main (zoom kamera 2×) | ✅ terbaca **MENYALA** — kaca kuning berinti terang, tudung & alas logam hangat, gantungan jelas · `_work/shot_lantern_E.png` |
| Dari **jauh**, satu layar penuh | ✅ satu-satunya cahaya hangat di desa gelap — hook siluet Merrit utuh |
| Glow hilang? | ❌ tidak. Glow justru **membaik**: `lantern_glow.png` (siluet hangat padat) menggantikan sprite sebagai tekstur lampu, jadi outline hitam sprite tak lagi melubangi cahaya |

---

## 2 — `bench.png` (20×11) + `workbench.png` (22×18)

### Pemisahan yang diperintahkan

Satu string `"bench"` selama ini melayani dua benda berbeda. Keduanya jatuh ke cabang
`else` `Interactable.gd` = **`rock.png` dipipihkan & dimodulasi cokelat**, berlabel
"Bengkel [E]", membuka menu meramu dengan Pandai Besi yang bicara.

| Sekarang | Isi | Konsumen |
|---|---|---|
| `workbench` | meja tempa + landasan di atasnya | 37 resep (`station: "workbench"`) · `Town.gd:235` · `HouseInterior.gd:149` (blacksmith) · ikon peta ⚒ · punya jam kerja |
| `bench` | bangku duduk berpapan lebar | 8 di alun-alun Ashbrook (`Ashbrook.gd:222`) |

Berkas tersentuh: `Interactable.gd` (default `kind`, `WORKERS`, 2 cabang `_build`,
1 cabang `interact`), `Town.gd`, `HouseInterior.gd`, `WorldMapUI.gd`, `recipes.json`
(37 baris, 0 sisa `"bench"`).

### Dua bug ikut mati bersama pemisahan itu

1. **8 bangku alun-alun tiap malam pindah ke penginapan.** `WORKERS` memuat `"bench"`,
   dan `_apply_schedule()` menyeret semua anggotanya ke penginapan saat malam — jadi
   alun-alun peringatan itu **mengosongkan dirinya sendiri** tiap malam. Kini hanya
   `workbench` yang punya jam kerja.
2. **Menekan E di bangku taman membuka menu tempa.** Kini `bench` diam total dan
   label-nya kosong — perabot cerita, bukan stasiun (#210 tunjukkan-jangan-papan-
   informasikan · D-3 nol penanda).

### Keputusan bentuk: bangku SENGAJA tanpa sandaran

Bukan selera — syarat teknis. Dari sudut three-quarter top-down, sandaran menutupi
permukaan duduk. **Varian cekungan Otha hanya terbaca kalau permukaan duduk terlihat penuh.**

---

## 3 — 🎯 Kelayakan varian cekungan Otha (diminta: lapor, jangan wire)

Diuji **di scratchpad, tidak di `game/assets/`** — belum ada konsumen (#244).
Tiga pendekatan, semua dinilai pada **ukuran main (zoom 2×)**, bukan zoom kerja:

| Pendekatan | 8× | Ukuran main 2× | Vonis |
|---|---|---|---|
| Cekungan satu tingkat lebih gelap | terlihat | nyaris hilang | ❌ |
| Cekungan dua tingkat + inti gelap | jelas | dua bintik gelap — bukan "cekungan" | ⚠ lemah |
| **Pudar KECUALI yang terlindung** (pola `gen_otha_sign.py`, konstanta `BLEACH` sama) | jelas | tetap halus | ⚠ lemah |
| Idem, tapi papan **24×14** (permukaan duduk 5 baris, bukan 3) | jelas | **terbaca** | ✅ |

**Vonis: overlay di atas `bench.png` 20×11 TIDAK layak.** Permukaan duduknya cuma 3 baris
piksel; cekungan butuh ≥2 baris kontras, jadi hampir tak menyisakan papan utuh sebagai
pembanding — dan tanpa pembanding, "aus" tak terbaca sebagai aus.

**Yang layak:** `bench_otha` sebagai **sprite tersendiri 24×14** (permukaan duduk 5 baris),
memakai hukum bekas yang sudah terbukti di repo ini — *"yang terbaca = KONTRAS & BENTUK"*
(`gen_otha_sign.py`). Bukan cekungan yang dipahat, melainkan **papan yang pudar 34 musim
KECUALI dua tempat yang terlindung badan orang** — persis trik `otha_sign_fadedmark`,
dan seperti papan itu, ia memang baru terbaca saat **diperiksa dari dekat**, yang justru
sesuai Hukum Bukti (#226).

⚠ Belum dibuat. Menunggu putusan — dan idealnya lahir **bersama adegan A1**, bukan sebelumnya.

---

## 4 — `run_godot.bat` diperbaiki

Tertulis `--script res://tests/run_tests.gd`. **Berkas itu tidak ada** — perintahnya
selalu gagal. Yang benar: `--headless res://tests/TestRunner.tscn`.
Ditambahkan juga baris `--headless --import` beserta sebabnya (lihat bug (a) di atas).

Harness baru: `game/tests/ShotScene.gd` — penangkap layar generik
(`AETHER_SCENE` / `_DELAY` / `_OUT` / `_COUNTERS` / `_WARP`). **Bukan test**, tak menambah
hitungan suite. Ada karena hanya `Main.gd` (Greenvale) yang punya jalur tangkap-layar;
Ashbrook tak punya, sehingga lentera Merrit **tak bisa dibuktikan** tanpanya (#240:
bukti yang tak bisa dijalankan ulang bukan bukti).

---

## 5 — ⚠ SUITE: 1026, dan itu BUKAN dari pekerjaan ini

Suite hijau — **1026 passed, 0 failed**. Tapi angkanya naik dari 1024, dan saya tidak
menulis satu test pun. Ditelusuri sampai tuntas, karena "suite tetap 1024" dipakai
sebagai gerbang penerimaan:

| Yang dibalik untuk menguji | Hasil |
|---|---|
| `recipes.json` ke versi `"bench"` | 1026 |
| `Town.gd` + `HouseInterior.gd` + `WorldMapUI.gd` | 1026 |
| `Interactable.gd` (seluruh pemisahan) | 1026 |
| `Ashbrook.gd` (seluruh perbaikan lentera) | 1026 |
| `bench.png` + `workbench.png` dikeluarkan dari folder | 1026 |

Dengan **semua** suntingan kode dibalik, daftar label test **identik** dengan versi
sekarang — nol label bertambah, nol berkurang, nol berubah.
**Kesimpulan: pekerjaan ini menambah 0 test dan 0 kegagalan.**

Angka 1024 terukur pada **2026-07-18 pukul 23.52 WIB**; semua pengukuran berikutnya jatuh
setelah tanggal berganti ke **2026-07-19**. Berarti ada test yang **jumlah `check()`-nya
bergantung kalender** (kandidat: musim/bulan/rasi/kalender langit — `GameClock` memang
diikat ke tanggal WIB nyata, bukan waktu palsu).

**Ini perlu putusan Direktur**, karena berdampak di luar sesi ini:
gerbang penerimaan berupa **angka mutlak** ("suite tetap 1024") akan **memberi alarm palsu
setiap kali tanggal berganti**. Usul: patok pada **`0 failed`**, bukan pada jumlah lulus —
atau lacak test yang jumlahnya bergoyang itu lalu buat jumlah `check()`-nya tetap.

---

## Ringkas

| | |
|---|---|
| Aset baru | 4 — `lantern.png`, `lantern_glow.png`, `bench.png`, `workbench.png` (semua prosedural, generator ter-commit) |
| Script #240 | `_tools/gen_lantern.py`, `_tools/gen_bench.py` |
| Bug diperbaiki | 5 — jangkauan cahaya lentera · beacon menutupi lentera · bangku pergi ke penginapan tiap malam · E-di-bangku membuka tempa · path test `run_godot.bat` |
| #232 | aman — semua prop di sini digambar sendiri, nol turunan LPC |
| Wire adegan A1/A3 | **nol** |
| Suite | **1026 passed, 0 failed** (pekerjaan ini: +0 test, +0 gagal — terbukti dengan pembalikan) |
| Bukti gambar | `_work/shot_lantern_E.png` (dekat & jauh), `_work/shot_bench.png` (alun-alun) |
