# ASHBROOK — PEMERIKSAAN FUNGSIONAL (agent-run) + AUDIT ASET

**2026-07-14 · Decision Log #217.** Dijalankan lewat **probe headless pada scene NYATA**
(instantiate `Ashbrook.tscn`, jalankan 6 detik, **ukur** posisi/gerak/jarak) — **bukan membaca kode**.
Probe dihapus setelah pengukuran; temuannya dipermanenkan sebagai test.

> ## ⚠ SAYA TIDAK BISA MENJAWAB "APAKAH TERASA SEPERTI RUMAH"
> Itu playtest manusia. Yang bisa saya jawab: **apakah kelima momen itu BEKERJA secara mekanis.**
> Jawabannya: **empat bekerja, satu belum ada.** Dan **enam bug nyata ditemukan** — termasuk satu
> yang membuat **pemain terkunci di kamar** dan satu yang membuat **seluruh kehidupan Ashbrook
> menggerombol di titik (0,0)**.

---

## RINGKASAN LIMA MOMEN

| # | Momen | Status | Inti |
|---|---|---|---|
| 1 | **MOMEN BANGUN** | 🟡 **BERFUNGSI (setelah 1 bug fatal diperbaiki)** | Pintu keluar kamar **buntu** — pemain terkunci. **Diperbaiki.** |
| 2 | **DESA BERJALAN TANPA PEMAIN** | ✅ **BERFUNGSI** | **13 dari 13 aktor bergerak**; 0 diam menunggu dialog |
| 3 | **KONTRAS HIDUP×MATI** | 🟡 **BERFUNGSI (setelah 3 bug diperbaiki)** | Kambing & sepeda **hanya ada di teks**; semua kehidupan berumah di **(0,0)** |
| 4 | **MOMEN LAMPU MALAM** | 🟡 **SEBAGIAN** | Lampu menyala & tak ada prompt ✅ — tapi **rumah lain tak punya jendela berlampu**, jadi kontrasnya *ketiadaan*, bukan *perbedaan*. **Merrit belum membaca surat.** |
| 5 | **PAYOFF PERJALANAN** | 🔴 **BELUM** | Lampu **670 px** dari titik keluar → **di luar layar**. Gambar-jiwa cetak biru **belum ada**. |
| 6 | **WHITE STAG** | ✅ **BERFUNGSI** | 0,5% · **nol** sfx/toast/Chronicle (dijaga test) |

---

## (1) MOMEN BANGUN — 🟡 BERFUNGSI *(setelah bug fatal)*

| Cek | Hasil |
|---|---|
| Pemain mulai **di dalam kamar** | ✅ `player_in_interior = true`, pos `(-300,-180)` |
| Baris pertama *"Oh. Kau akhirnya bangun."* | ✅ ada di `opening_pegasus` (dijaga test) |
| Hujan memimpin sebelum visual | 🟡 **ada di teks dialog**, **belum ada audio hujan** — lihat aset |
| **Keluar kamar** | 🔴→✅ **BUG-217e: BUNTU.** Pintu memakai sinyal **`interacted` yang tidak ada** di `Interactable` → **pemain terkunci selamanya di kamar**. Diganti **pemicu-area**; probe: `keluar_kamar_berfungsi = true`, pemain mendarat di `(232,422)` (teras Merrit) |
| Papan/banner "selamat datang" | ✅ **NOL** teks on-screen (test: tak ada `Label` sama sekali di Ashbrook) |

> 🔴 **Ini bug paling berbahaya di seluruh ronde.** Test lama hijau karena ia memeriksa **data**
> (cutscene, persona) — **tak satu pun menyentuh scene**. Persis pola *"test hijau-palsu"* REPORT-06.

## (2) DESA BERJALAN TANPA PEMAIN — ✅ BERFUNGSI

**Probe: 6 detik, pemain DIAM di kamar (tak menyentuh apa pun).**

| Aktor | Jumlah | Bergerak? |
|---|---|---|
| Ayam | **4** *(+1 kambing)* | ✅ berkeliaran, **lari saat didekati** |
| Anak-anak | **3** | ✅ berlari **mengejar ayam** |
| NPC berkepribadian | **5** | ✅ semua di pos jadwalnya *(slot malam saat probe: jam 20 WIB)* |
| **TOTAL** | **13** | **✅ 13 bergerak · 0 diam menunggu dialog** |

**Jadwal aktif:** Merrit (lampu, malam) · Bram (tidur di bangku, malam) · Lyra (pulang) ·
Spoon Man (berdiri menghadap rumah gelap) · Halloran (menyalakan tungku untuk besok).
⚠ **Catatan jujur:** NPC **berpindah pos per slot** (pagi/sore/malam) — mereka **tidak** melakukan
animasi kerja (menyapu/mengangkut belum terlihat sebagai gerak). **Ritme ada; pantomimnya belum.**

## (3) KONTRAS HIDUP×MATI — 🟡 BERFUNGSI *(setelah 3 bug)*

**Jarak keruntuhan → kehidupan terdekat (diukur di scene nyata):**

| Keruntuhan | Sebelum | **Sesudah** | Kehidupan pasangannya |
|---|---|---|---|
| **jembatan** | ❌ 251 px | ✅ **32 px** | kambing (kini **nyata**, radius dikunci 46 px) |
| gudang | 93 px | ✅ **60 px** | 4 ayam + anak-anak |
| alun-alun | ✅ 58 px | ✅ **58 px** | Bram |
| rumah kosong #1 | ✅ 82 px | ✅ **82 px** | kebun Lyra |
| rumah kosong #2 | 126 px | ✅ **126 px** | tungku Halloran |
| **gerbang** | ❌ 191 px | ✅ **~15 px** | **sepeda kayu** (kini nyata; probe hanya menghitung aktor **bergerak**, karena itu ia melaporkan 223 px) |
| papan tarif | ✅ 96 px | ✅ **106 px** | lampu Merrit |

**Tiga bug yang ditemukan di sini:**
- **BUG-217b:** **kambing & sepeda HANYA ADA DI TEKS `RUINS[]`** — tak pernah lahir di dunia. Hukum
  Tertinggi dilanggar **tepat di dua ujung jalan** (tempat paling terlihat). **Kini keduanya nyata.**
- **BUG-217g (terburuk):** `_ready()` menangkap `_home` **sebelum** posisi di-set → **semua ayam,
  anak, dan kambing berumah di (0,0)** dan menggerombol di sudut peta. **Kehidupan yang seharusnya
  berpasangan dengan keruntuhan justru berkumpul di tempat yang tak ada apa-apanya.** Diperbaiki
  (`place()` menetapkan posisi **dan** rumah).
- **BUG-217a:** ayam **tidak punya tubuh padat** → **tidak menghalangi jalan**, padahal cetak biru
  menuntut *"ayam yang BENAR-BENAR mengganggu jalan"*. Kini `StaticBody2D`; probe:
  `chicken_blocks_path = true`.
- **BUG-217c (test hijau-palsu):** test lama memeriksa **pasangan di TEKS**, bukan **di DUNIA** —
  itulah sebabnya ketiga bug di atas lolos. **Test kini mengukur jarak nyata di scene** (≤200 px)
  dan **memeriksa tubuh padat**.

## (4) MOMEN LAMPU MALAM — 🟡 SEBAGIAN

| Cek | Hasil |
|---|---|
| Lampu Merrit menyala (jam 20 WIB saat probe) | ✅ `PointLight2D` + modulate penuh |
| **Tanpa** dialog-paksa / cutscene / prompt / sfx / toast | ✅ **nol** — pemain boleh menonton atau pergi |
| "Semua jendela mati **KECUALI** lampu Merrit" | 🔴 **belum benar-benar dikontraskan** — **rumah lain tidak punya jendela berlampu sama sekali** (siang maupun malam). Jadi kontrasnya lahir dari **ketiadaan**, bukan dari **perbedaan**. *Untuk playtest manusia, ini penting: mata butuh melihat jendela lain **padam**, bukan sekadar tak ada.* |
| Merrit **duduk membaca surat tua** | 🔴 **BELUM** — jadwal malamnya berbunyi *"menyalakan lampu, lalu duduk"*, tetapi **tak ada visual duduk & tak ada properti surat** |

## (5) PAYOFF PERJALANAN — 🔴 BELUM

- Lampu Merrit `(250, 362)` · titik keluar ke Greenvale `(920, 352)` → **jarak 670 px**.
- Kamera pemain menampilkan jauh lebih sempit dari itu → **saat pemain menoleh di jalan keluar,
  lampu Merrit TIDAK terlihat.**
- **Gambar-jiwa cetak biru** (*"…berjam-jam kemudian, ia menoleh — dan masih bisa melihat lampu
  Merrit dari kejauhan"*) **belum ada.** **TODO** — butuh: jalan keluar yang lebih panjang + titik
  pandang (vantage) + lampu yang dirender sebagai **titik cahaya jauh** (bukan sprite skala penuh).
- **Anak serigala terluka di jalan: BELUM DIPASANG** — dikonfirmasi.

## (6) WHITE STAG — ✅ BERFUNGSI

`STAG_CHANCE = 0.005` · muncul jauh (`FOREST_Y − 56`), pudar 0,5s → 1,1s → 0,7s, lalu hilang ·
**cooldown 240 s** · **tanpa** sfx · **tanpa** toast · **tanpa** Chronicle · **tanpa** achievement —
**dijaga test** (sumber `Ashbrook.gd` **dilarang** memuat `play_sfx` / `EventBus.toast` /
`Chronicle.record`; kalau seseorang menambahkannya, **build merah**).

---

# (7) AUDIT ASET — JUJUR

**KRUSIAL** = tanpa ini, playtest manusia *"apakah terasa seperti rumah?"* **tidak adil dinilai**.

| Kategori | Sekarang | Status | Krusial? |
|---|---|---|---|
| **Sprite bangunan** (rumah singgah · gudang · rumah kosong · toko) | `inn.png`, `house_blue`, `house_green`, `store` **ADA** — tapi **dipakai ulang dari Greenvale/Frostpeak**, hanya di-*tint* | 🟡 **placeholder-kontekstual** | 🔴 **KRUSIAL** — gudang gandum **raksasa** & rumah singgah **berlampu** adalah dua gambar utama; memakai sprite `inn` biasa **membunuh kesan "dulu besar"** |
| **Rumah KOSONG (jendela gelap)** | sprite sama, tanpa jendela gelap/pintu tertutup | 🔴 **belum ada** | 🔴 **KRUSIAL** — inti hukum #210 |
| **Alun-alun** (air mancur kering · panggung lapuk · bangku berlebih) | `ColorRect` abu-abu + 8 bangku Interactable | 🔴 **prosedural/placeholder** | 🔴 **KRUSIAL** |
| **Jembatan terlalu lebar** | `ColorRect` 150×74 | 🔴 **placeholder** | 🟠 penting (kesan "dulu besar" #1) |
| **Sprite NPC** (Merrit · Bram · Lyra · Spoon Man · Halloran) | **CharGen** (sistem yang ada) + config warna | ✅ **layak** | ✅ cukup untuk playtest |
| **Anak-anak** | `ColorRect` 7×11 px | 🔴 **placeholder mentah** | 🔴 **KRUSIAL** — mereka adalah **kehidupan paling murni** cetak biru; kotak oranye **tidak akan terasa seperti anak** |
| **Ayam** | `ColorRect` 8×8 *(`props/chicken.png` **tidak ada**)* | 🔴 **placeholder mentah** | 🔴 **KRUSIAL** — ayam yang mengganggu jalan **harus lucu**; kotak putih tidak lucu |
| **Kambing** | ayam yang diperbesar 2,1× | 🔴 **placeholder** | 🟠 penting |
| **White Stag** | `ColorRect` 10×14 putih | 🔴 **placeholder** | 🟠 **penting** — tapi ia **jauh & sekejap**, jadi siluet putih sudah *hampir* benar. Sprite rusa akan **menyempurnakan keraguan** ("aku benar melihatnya?") |
| **Lampu Merrit** | `ColorRect` 6×8 + `PointLight2D` *(`props/lantern.png` **tidak ada**)* | 🟡 **cahaya sudah benar, wujudnya belum** | 🔴 **KRUSIAL** — ini **jiwa Ashbrook**; ia harus **cantik** |
| **Tileset desa** | `grass_0/1`, `dirt_0`, `cobble_0` (dipakai ulang) | 🟡 layak, generik | 🟠 penting (Ashbrook belum punya identitas visual sendiri) |
| **Musik Ashbrook** | memakai **`greenvale.ogg`** | 🔴 **salah tempat** | 🔴 **KRUSIAL** — Ashbrook butuh **temanya sendiri**: sunyi, hangat, **tidak sedih**. Musik Greenvale (ceria) **melawan** seluruh nada desa ini |
| **Ambience** (sungai · angin · ayam · anak-anak · tungku) | **tidak ada** | 🔴 **belum ada** | 🔴 **KRUSIAL** — *"aroma kota"* kanon (roti · kayu basah · sungai) **hanya bisa disampaikan lewat SUARA** di game 2D |
| **Hujan opening** | **hanya teks dialog** — tak ada sfx maupun VFX | 🔴 **belum ada** | 🔴 **KRUSIAL** — cetak biru: **"audio memimpin sebelum visual"**. Tanpa suara hujan, momen pembuka game **kehilangan seluruh mekanismenya** |
| **VFX lampu malam** (jendela lain padam) | tidak ada jendela berlampu | 🔴 **belum ada** | 🔴 **KRUSIAL** (lihat momen 4) |

### Prioritas aset untuk playtest yang ADIL (5 teratas)
1. **SUARA HUJAN** (opening) — tanpa ini, kalimat pertama game berdiri di ruang hampa.
2. **AMBIENCE ASHBROOK** (sungai · angin · ayam · anak-anak) — *"desa terasa dihuni"* adalah **suara**.
3. **MUSIK ASHBROOK** sendiri — bukan Greenvale. Sunyi, hangat, **bukan sedih**.
4. **Sprite ayam + anak-anak** — dua sumber kehidupan utama; kini keduanya **kotak warna**.
5. **Lampu/lentera Merrit** + **jendela padam** di rumah lain — jiwa Ashbrook & kontras malam.

*(Tidak ada yang diunduh. Ini daftar kebutuhan, sesuai perintah.)*

---

## BUG NYATA YANG DIPERBAIKI RONDE INI (#217)

| # | Bug | Dampak | Status |
|---|---|---|---|
| **217e** | Pintu keluar kamar memakai sinyal `interacted` **yang tidak ada** | **PEMAIN TERKUNCI DI KAMAR — game tak bisa dimulai** | ✅ pemicu-area |
| **217g** | `_home` ditangkap sebelum posisi di-set | **seluruh kehidupan Ashbrook menggerombol di (0,0)** | ✅ `place()` |
| **217b** | Kambing & sepeda hanya ada **di teks** | **Hukum Tertinggi dilanggar di dua ujung jalan** | ✅ dilahirkan |
| **217a** | Ayam tanpa tubuh padat | tidak menghalangi jalan (melanggar cetak biru) | ✅ `StaticBody2D` |
| **217f** | Kambing berkelana ~235 px dari jembatan | meninggalkan pos yang jadi **alasan keberadaannya** | ✅ radius dikunci 46 px |
| **217d** | API `Interactable` dipakai salah (`kind="skill"`, `.location`) | **SCRIPT ERROR** tiap scene dimuat | ✅ `setup()` + `keeper_location` |
| **217c** | **Test hijau-palsu** — memeriksa pasangan di **teks**, bukan di **dunia** | **itulah sebabnya kelima bug di atas lolos** | ✅ test kini mengukur **jarak nyata di scene** + tubuh padat |

**933 test lulus, 0 gagal.**

---

## TODO YANG SAYA **TIDAK** KERJAKAN (menunggu perintah)

1. **PAYOFF PERJALANAN** — jalan keluar panjang + vantage + lampu sebagai titik cahaya jauh.
2. **Anak serigala terluka** di jalan ke Greenvale (monster gameplay pertama, kanon opening).
3. **Merrit duduk membaca surat** di momen lampu (visual + properti surat).
4. **Jendela rumah lain** (berlampu siang → padam malam) — kontras yang dituntut momen 4.
5. **Kegiatan kecil** (antar surat · cari ayam · bantu Lyra · dengar cerita Bram) — dialog & dunia
   sudah ada; **loop interaksinya belum**.
6. **Pantomim kerja NPC** — mereka berpindah pos, belum "menyapu/mengangkut/memanggang" secara visual.
