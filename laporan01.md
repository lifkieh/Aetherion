# LAPORAN 01 — snapshot percakapan & kerja sesi Ashbrook

**Dibuat:** 2026-07-22 · **Guna:** cadangan percakapan. Kalau chat dihapus, berkas ini
cukup untuk memulihkan konteks dan melanjutkan kerja tanpa mengulang keputusan.

⚠ **Ini ringkasan padat, bukan transkrip kata-per-kata.** Yang disimpan: keputusan,
alasannya, angka yang diverifikasi, cacat yang ditemukan, dan apa yang menunggu.

---

## 0 · CARA KERJA SESI INI (penting untuk memulihkan nada)

| | |
|---|---|
| Proyek | **Aetherion** — Godot 4.3, RPG top-down 2D, repo `D:\2DGAME` |
| Panggilan pengguna | **Direktur** |
| Bahasa | Indonesia. Istilah teknis, kode, nama berkas tetap verbatim |
| Gaya jawaban | **CAVEMAN MODE (full)** — padat, fragmen boleh, nol basa-basi, nol narasi pemanggilan alat |
| Cabang git | `tata-letak-ashbrook-b-aksen` (dari `main` @ `70f29e8`) |
| Titik balik aman | `git checkout 70f29e8 -- game/scenes/world/Ashbrook64.gd` |

**Hukum proyek yang terus dipakai:**
- **#240** — tiap PNG wajib punya skrip yang melahirkannya, dan skrip itu ter-commit
- **#249 + #273** — suite lulus HANYA bila baris `===== RESULT: N passed, M failed =====` ada **dan** M=0
- **#277** — aset visual boleh CC-BY-SA, **kredit wajib untuk tiap aset**
- **#226** — Hukum Bukti: 4 jenis (`benda` · `kebiasaan` · `akibat` · `orang`)
- **#151b** — "UKUR DUNIA, BUKAN TEKSNYA": test wajib memuat scene sungguhan
- **#206** — Ashbrook desa-bekas-kota (1.500 → 40 jiwa)
- **D-3** — penemuan bukti harus DIAM: nol toast, nol banner
- **#218** — payoff lentera Merrit · **#275** — y negatif merusak y-sort
- **#231** — gerbang siluet · **#228** — tak ada jalur yang cuma bisa lewat satu cara

**Prinsip pendiri Ashbrook:**
> *"Ashbrook tidak boleh terasa BESAR. Ia harus terasa PERNAH besar."*

---

## 1 · URUTAN KERJA — apa yang diminta, apa yang dikerjakan

### 1.1 Warisan sebelum sesi ini (dari ringkasan kompaksi)
`POTRET_ASHBROOK.md` (potret jujur) · `GUDANG_UNTUK_ASHBROOK.md` · `KATALOG_GUDANG.md`
(~120 sumber) · `TRASH_LOG.md` · `TELUSUR_LISENSI.md` (tileset Sonetto **CC-BY-SA 4.0
byte-terbukti**; pohon LPC Tree Recolors).

**Metode forensik yang lahir di sana dan dipakai terus:** SHA256 untuk duplikat (nama
bohong, byte tidak) · nisbah warna-per-piksel sebagai uji gaya · papan catur + kisi 32 px
untuk memeriksa alfa · zip dibaca **di memori**, nol ekstraksi massal.

### 1.2 BLOCKOUT — tiga peta kotak (commit `da8ca57`)
Diminta: draft tata letak kotak polos, dua versi. Dihasilkan tiga:
- **A** — cermin `Ashbrook64.gd` apa adanya
- **B** — usul 4-cincin dari `ASHBROOK_MAP_SPEC.md`
- **B′** — B + **tujuh koreksi Direktur** → **tata letak final**

**Tujuh koreksi B′:** (1) simetri dipecah — sumbu geser 60 px ke barat & bengkok ·
(2) tepi alun-alun dimakan (aus barat-daya, rumput merambat timur-laut) · (3) bangunan
bernama maju-mundur tak sama · (4) satu distrik reruntuhan padat barat-laut ·
(5) air mancur off-center 38 px · (6) gradien lewat JARAK, bukan cuma lampu ·
(7) dua jangkar mata.

Prinsipnya: **"B rapi; B′ hidup"** — ketaksempurnaan **dirancang**, bukan diacak. Semua
simpangan dari RNG berbiji `20260721` supaya bisa diulang.

### 1.3 TAHAP 1 — koordinat (commit `5f05fad`)
Enam koreksi B′ dipasang tanpa alat baru. Kaki bangunan dikumpulkan jadi const supaya
pintu/jendela/bukti/ayam/zona warga menambat ke satu angka.

**Tiga cacat ditemukan alat & tangkap-layar, bukan mata:**
- celah gudang↔Merrit **30 px = persis selebar badan pemain** → terlihat seperti lorong, tak bisa dilewati
- jalan gerbang yang disambung **membelah ladang**
- 13 denah rapat × 7 batu = **91 batu**, terbaca seperti pemakaman

**Bonus:** anak bisa **lahir di dalam bangku** (1 dari 6 putaran).

### 1.4 TAHAP 1.5 + 1.6 — dekorasi & variasi tanah (commit `146b771`)
**Nol aset baru.** Repo ternyata punya 66 prop yang nyaris tak terpakai (`stall`,
`signboard`, `laundry`, `trough`, `workbench`, `crate`, `sack`, `flower_pot`, 4 siluet pohon).

Kepadatan ikut gradien. **Lapak kosong di distrik bekas** = aset yang SAMA dengan lapak
alun-alun, digelapkan: *benda tak perlu diganti untuk berganti arti, cuma perlu dipindah
ke tempat yang tak lagi punya orang.*

Dua koreksi dari tangkapan: ambang tanah mendarat **di atas jalan batu** · `branch.png`
oranye terbaca **sampah**.

### 1.5 TAHAP 1.7a — nyalakan wangset menganggur (commit `398dfaf`)
Atlas `lpc-tileset-buildings` punya **4 wangset**; generator cuma memakai **2**.
Dinyalakan **Flat Roofs** + **Adobe Walls** → 4 fasad baru, **9 bentuk untuk 15 bangunan**.

⚠ Jebakan: blok adobe lebarnya **empat** petak, bukan tiga seperti bata — menebak `c0+2`
mengambil petak tengah. Kolomnya **disebut**, tidak dihitung.

### 1.6 TAHAP 1.7b — bertingkat & lapuk (commit `fd69e39`)
- **Bertingkat** tak butuh petak baru: petak baris atas nine-slice punya lis; dipasang di
  tengah dinding, ia jadi **pemisah lantai**. Langka dengan sengaja — cuma balai + menara.
- **Lapuk berlubang**: lubang berlatar **GELAP**, bukan tembus. Yang tembus menampakkan
  rumput → terbaca cacat gambar, bukan rumah yang ditinggalkan.

### 1.7 TAHAP A — peta rujukan aset (commit `1deae31`)
Alat baru `_tools/peta_aset.py`. **Daftar yatim versi pertama 207; yang benar 22.**
Path disusun **empat tingkat** (utuh · awalan konstanta · awalan dipilih · nama dibentuk).
Alat sempat **mencemari hasilnya sendiri** (JSON keluarannya memuat semua jalur aset).

**Temuan yang mengubah rencana:** `props/` **tak bisa dibagi** — lima tempat memanggilnya
sebagai folder datar dengan nama dari data. Usul: biarkan datar.

### 1.8 EKOLOGI — Lapis 1 · 2 · 2.5 (commit `830298b` · `c2f3c97` · `553ba92` · `9961843`)

| lapis | isi | aturan yang membuatnya bercerita |
|---|---|---|
| **1 Ternak** | 2 domba + 3 ayam kandang, 2 ayam lepas | **kepemilikan, bukan zona** — koreksi Direktur atas rancangannya sendiri |
| **2 Liar** | 6 kucing · 2 anjing · 1 domba tersesat | gradien **berlawanan arah**; **liar = JARAK, bukan sprite** |
| **2 Pengikut** | 1 anjing | ikut 5 detik lalu **berdiri diam 4 detik** — jatah tak diisi ulang selama pemain dekat, kalau tidak ia jadi *companion* |
| **2 Penunggu** | 2 kucing duduk + 1 meringkuk | sengaja **dua, bukan lima**: satu = kebetulan, dua = pola, lima = sistem |
| **2.5 Burung** | 3 merpati inti · 3 gagak bekas · 2 melintas langit | **terbang, bukan lari** — lembar ditukar; mendarat **memindahkan rumahnya** |

**Perbaikan sistem:** hewan tak pernah berhenti → diberi jeda diam (lebih lama daripada
jalan), frame **beku** saat diam. Kecepatan per jenis dari katalog.

**Lisensi, byte-terbukti:** `[LPC] Cats and Dogs` bluecarrot16 (dog.png 9202 B) ·
`[LPC] Birds` bluecarrot16 (2870 B & 2719 B). Keduanya dipakai di bawah **OGA-BY 3.0** —
satu-satunya yang **tak menular**. Disimpan di `assets_raw/` **bersama `.credits.txt`**.
**Kambing ditahan** (`goat.png` ada & bergaya LPC tapi **nol kredit**).

### 1.9 RUSA PUTIH — "blink blink" (commit `906e50f`)
Direktur melapor rusa berkedip. **Lima cacat, satu gejala:** tak bergerak · frame beku
(8 frame tak dipakai) · muncul/hilang mendadak · **di tempat salah** (`y=190`, `z=500`,
komentarnya menyebut "hutan utara" padahal hutan di **selatan**) · **tidak putih**
(`modulate` cuma bisa mengalikan warna).

Pemutihan dipindah ke **generator** (operasi piksel). Kail `AETHER_RUSA=1` ditambahkan:
**cacat yang tak bisa dijepret adalah cacat yang tak akan pernah diperbaiki.**

### 1.10 TITIK PANDANG #218 (commit `529d472`)
Direktur bertanya *"kenapa kalau di kanan mapnya zoom out?"* — **pertanyaan itu vonisnya**.

Angka membuktikan: dari titik lama lentera **sudah di dalam bingkai** (sisa 22 px). Kamera
mundur untuk **memperjelas yang sudah terlihat**. Dipindah ke (1716, 856): lentera **di
luar 214 px** saat normal, masuk lega saat mundur. Menara jadi penanda. **Histeresis**
masuk 130 / keluar 240 (pita mati 110 px).

**Bug yang diungkap tangkapan:** kamar interior Merrit di `(2100,160)` **melayang di
kehampaan** saat zoom 0,55 → dipindah ke `(4200,160)`.

### 1.11 HUTAN TEPI (commit `ea9f27a`)
Void hitam → hutan. **Resep selatan tak bisa diputar 90°**: `pinus_atas` bergerigi dan
gerigi punya arah; memutarnya memutar arah cahayanya. Sisi tegak dibangun dari **pohon
tegak**. Digambar **1250 px ke luar peta** — dari titik pandang pandangan mencapai x=2880.
Percobaan pertama (modulate 0,26) masih terbaca **hitam** → dinaikkan ke 0,44/0,58.

**Cacat jadi tesis:** *alam menutup dari luar, satu jalan masuk.*

### 1.12 PLAYTEST #151b (commit `014f2af`)
Direktur menahan serigala: *"apakah menulis nama di Chronicle TERASA?"*

**Jawaban: rantai inti UTUH.** Alat baru `CekJalur.gd` (banjir BFS): **8276 petak bebas,
8276 terjangkau (100,0%)**.

**Tiga cacat ALAT, bukan dunia:** koordinat beku (di `PlayLoop64` **persis tiga titik yang
pindah gagal**, dua yang tak pindah lolos) · **panel yang menganga** mem-pause pohon scene
(gejalanya seragam — semuanya diam — dan keseragaman itu petunjuknya) · asersi terikat
nama beku.

**Satu cacat DUNIA:** jendela toko Otha **menyala tiap malam**. `terlupa()` menuntut
halaman **tercoret**; Otha kematian **d3** — halamannya tak pernah lahir. Pemain membaca
*"tak ada yang membukanya sejak dua musim"* lalu melihat lampu menyala. Ditambah
`AshbrookWindow.mati`.

Hasil: jalan-kaki **24/8 → 32/0**; rantai §0 utuh di **tiga jalur**.

### 1.13 AUDIT GAMEPLAY (commit `b04e1c2`)
`reports/AUDIT_GAMEPLAY_ASHBROOK.md`.

**Temuan terbesar — pemulihan sempurna MUSTAHIL:** dari empat jenis bukti, `orang` **nol
terpasang**. Ketiganya menuntut kesaksian, dan **keenam NPC bernama adalah `Sprite2D`
polos**. Maka baris penutup sudah ditentukan sebelum pemain menekan tombol pertama.

Lain: pintunya bicara orangnya tidak · **dua Merrit & dua Halloran** · tutorial HUD milik
Greenvale (nol dari 6 langkah bisa) · 16 dari 17 `kind` Interactable tak dipakai ·
companion 0 dari 4 (**Arlen tak ada sama sekali**) · A1 pemandangan, A2/A3 tak ada ·
R3 tidur · loop berputar **satu kali**.

### 1.14 BAHAN DIALOG + KOREKSI (commit `641c8a4`)
Direktur minta bahan Merrit. **Koreksi: Merrit bukan saksi.**

| bukti `orang` | halaman | saksi | penghalang |
|---|---|---|---|
| `ev_ashbrook_bram_ingat_ayahnya` | `place_ashbrook_besar` | **Old Bram** | Bram bisu |
| `ev_otha_nyai_tuminah_kamis` | `person_otha_renn` | Nyai | **`observe`**, bukan dialog |
| `ev_merrit_arlen_ingat` | `person_merrit_fane` | **Arlen** | Arlen tak ada |

→ **Bram yang menutup cacat utama, bukan Merrit.** Direktur memilih **Jalur A**.

### 1.15 KATALOG ASHBROOK (commit `673a93b`)
`reports/KATALOG_ASHBROOK.md` — seluruh mekanik, pemicu (waktu/jarak/sekali-jalan/acak),
event, dan **seluruh teks yang bisa dibaca pemain**.

### 1.16 OLD BRAM BERSUARA (commit `cff4d45`) ← **kerja terakhir**
Kesaksian jadi **baris ke-5** sesudah empat baris gosip. Tangganya terukur: **7–18
giliran**. Bram **tidak tahu ia sedang bersaksi**.

**D-3 dijaga:** `Evidence.find()` dipanggil, nilai baliknya **sengaja dibuang**;
`evidence_found` nol pendengar (ikut diuji).

**"Dua Bram" beres:** persona menyebut `lpc_sheet` (wajah asli) + `anchor` (bangkunya).
Mekanismenya **data-driven** — Merrit/Nyai/Halloran nanti lewat jalur sama.

**Bukti terkuat — loss BERUBAH:**
> *"Kau menuliskan apa yang kau lihat. Kau menulis 'dulu lebih besar' — dan itulah yang dunia akan ingat, karena itulah yang kau tahu."*

Bukan lagi *"tercatat sebagai kota, bukan seribu lima ratus orang"*. **Loss jadi pilihan.**

---

## 2 · COMMIT (cabang `tata-letak-ashbrook-b-aksen`)

```
cff4d45  Old Bram bersuara — jenis bukti keempat bisa dipungut
673a93b  KATALOG_ASHBROOK
641c8a4  bahan dialog Merrit + koreksi saksi `orang`
b04e1c2  audit gameplay — 6 dari 14 bukti ter-wire
014f2af  playtest: rantai inti UTUH (#151b)
ea9f27a  hutan tepi 3 sisi — void jadi tesis
529d472  #218 titik pandang — zoom yang MENGUNGKAP
906e50f  WHITE STAG berhenti berkedip — lima cacat
9961843  LAPIS 2.5 burung
553ba92  LAPIS 2 lengkap — anjing
c2f3c97  LAPIS 2 — hewan liar
830298b  LAPIS 1 — ternak
1deae31  TAHAP A — peta rujukan aset
fd69e39  1.7b bertingkat + dinding lapuk
398dfaf  1.7a nyalakan dua wangset menganggur
146b771  1.5+1.6 dekorasi & variasi tanah
5f05fad  TAHAP 1 tata letak B'
da8ca57  blockout A · B · B'
```

**Alat baru:** `_tools/gen_blockout_ashbrook.py` · `_tools/peta_aset.py` ·
`game/tests/CekKoridor.gd` · `CekJalur.gd` · `CekBram.gd` · `ShotBram.gd`

**Laporan:** `BLOCKOUT_ASHBROOK.md` · `RAPIKAN_ASET.md` · `AUDIT_GAMEPLAY_ASHBROOK.md` ·
`BAHAN_DIALOG_MERRIT.md` · `KATALOG_ASHBROOK.md` · **`laporan01.md`** (berkas ini)

---

## 3 · KEADAAN SEKARANG

| gerbang | hasil |
|---|---|
| Suite (#249 + #273) | **1121 lulus, 0 gagal** |
| Jalan-kaki `PlayWalk64` | **32 lulus, 0 gagal** |
| Rantai §0 `PlayLoop64` | **UTUH** di tiga jalur (self · elyn · penuh) |
| `CekJalur` | **100%** terjangkau (8276/8276) |
| `CekKoridor` · `CekJangkau` | lolos · bersih |
| `CekBram` | **15 lulus, 0 gagal** |

**Ashbrook sekarang:** 15 bangunan · 9 bentuk fasad · 2 bertingkat · hutan 4 sisi ·
27 makhluk · 6 titik-periksa · 10 prop bercerita · **Bram bisa diajak bicara** ·
`place_ashbrook_besar` **bisa dipulihkan sempurna**.

---

## 4 · YANG MENUNGGU

### Berikutnya — Jalur B (Merrit)
Direktur akan menulis dialognya. Yang dibutuhkan:
1. Empat baris lama dipakai ulang untuk wajah asli — **ya atau tulis baru?**
2. Himpunan **sesudah-A2**: *"Selamat pagi. Butuh kamar?"* + pengiring
3. Tiga bukti kamar (teks **sudah ditulis** di `evidence.json`) — di perabot mana?

Sesudah Merrit: Otha · Halloran · **Nyai** (perilaku Kamis, **bukan dialog**) · Sora.

### Ditahan atas keputusan Direktur
Serigala malam (Lapis 3) · A2/A3 penuh · companion & rekrutmen · tutorial Greenvale ·
zona hutan luar yang bisa dimasuki · `props/` & `tiles/` dirapikan (butuh keputusan
A/B/C) · 22 yatim → `_yatim/` (9 masih dilahirkan generator).

### Utang tercatat
`ev_merrit_arlen_ingat` butuh **Arlen yang tak ada** · jalur juru tulis **Sora** tak
ter-wire · **R3 pembusukan tidur** (pembaca ada, pemicu tak pernah dipanggil) · **kabut
kedua** belum ada (loop berputar sekali) · perpindahan region terkunci `visited_regions` ·
gerbang selatan → Main Menu · `WaterFountain.png` lisensi belum ditelusuri (air mancur
masih kering) · Merrit masih setinggi balai (butuh fasad, bukan koordinat) · wisp C3
kehilangan jangkarnya waktu ladang pindah · daftar ⚠CEK gudang belum ditelusuri.

---

## 5 · PELAJARAN YANG BERULANG

1. **Cacat yang tak bisa dijepret tak akan pernah diperbaiki** — rusa kotak-putih bertahan berbulan-bulan; kail harness menutupnya.
2. **Gerbang yang berbohong lebih buruk daripada nol gerbang** — kegagalan palsu membuat kegagalan sungguhan ikut diabaikan.
3. **Alat tak boleh memvonis apa yang tak bisa ia bedakan** — pejalan tanpa pencarian jalur.
4. **Kepadatan mengubah arti resep yang sama** — 7 denah × 7 batu benar; 13 × 7 jadi pemakaman.
5. **Perbaiki di berkas/generator, bukan di pemanggil** — aturan untuk satu kasus akan dilanggar diam-diam oleh kasus kesebelas.
6. **Ragu = tinggal.** Nama bohong, byte tidak.
7. **Angka dihitung, bukan diasumsikan** — "nyaris terlihat" itu vonis, bukan perasaan.
8. **Pertanyaan Direktur adalah data** — *"kenapa mapnya zoom out?"* membuktikan payoff-nya rusak.
