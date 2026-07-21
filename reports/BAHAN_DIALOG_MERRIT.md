# BAHAN DIALOG — MERRIT FANE (#011), dan siapa saksi bukti `orang`

**Dibuat:** 2026-07-22 · **Sifat:** bahan untuk Direktur menulis dialog. **NOL perubahan `game/`.**
**Sumber:** `docs/Companion_bible/companion_11_merrit_fane.md` · `game/data/evidence.json` ·
`game/data/town_npcs.json` · `docs/Aetherion_bible/A2_SESEORANG_MELUPAKANMU.md`

---

## ⚠ KOREKSI YANG HARUS DIBACA DULU — Merrit BUKAN saksi

Direktur meminta "apa kesaksian Merrit — bukti `orang` apa yang ia berikan".
Saya cek ke `evidence.json`, dan jawabannya: **Merrit tidak memberi kesaksian apa pun.**

Tiga bukti `orang` di seluruh data, beserta saksinya:

| bukti `orang` | halaman | cara ditemukan | saksi | penghalang |
|---|---|---|---|---|
| `ev_ashbrook_bram_ingat_ayahnya` | **`place_ashbrook_besar`** | `dialog_bram` | **OLD BRAM** | Bram bisu — **satu sambungan** |
| `ev_otha_nyai_tuminah_kamis` | `person_otha_renn` | **`observe`** (jadwal `kamis_sore`) | Nyai Tuminah | **bukan dialog** — butuh perilaku terjadwal + pengamatan |
| `ev_merrit_arlen_ingat` | `person_merrit_fane` | `dialog_arlen` · `requires_npc: arlen` | **ARLEN** | **Arlen tak ada di game sama sekali** |

**Merrit adalah SUBJEK halaman, bukan saksinya.** Yang bersaksi tentang Merrit adalah Arlen —
anak yang dulu ia tampung, yang kerinduannya pada horizon lahir di rumah pos itu.

### Akibatnya untuk urutan kerja

Cacat utama audit — *loss "tercatat sebagai kota, bukan seribu lima ratus orang" tak
terhindari* — ada di halaman **`place_ashbrook_besar`**. Saksinya **Old Bram**.

> **Memberi Merrit suara TIDAK memperbaiki cacat itu. Memberi Bram suara memperbaikinya —
> sendirian.**

Sesudah Bram bicara, `place_ashbrook_besar` punya keempat jenis:

```
benda      ✓ batu fondasi berpahat      (sudah terpasang)
kebiasaan  ✓ 200 roti Halloran          (sudah terpasang)
akibat     ✓ jembatan / gudang / fondasi (sudah terpasang)
orang      → Bram bicara                 ← SATU sambungan
```

→ **pemulihan sempurna jadi mungkin, dan loss kembali jadi PILIHAN.**

---

## ⚡ TEMUAN KEDUA — dialognya SUDAH DITULIS

`evidence.json` menyimpan `notice.id` untuk tiap bukti: **kalimat yang muncul saat pemain
menemukannya, sudah dalam bahasa Indonesia, sudah bernada final.** Direktur mungkin tak
perlu menulis dari nol — cukup memutuskan pembungkusnya.

**Kesaksian Bram, verbatim dari data:**

> *"Ayahku dulu ngeluh soal antrean di penggilingan. Antrean! Di sini! Orang tua memang
> suka melebih-lebihkan."*

Catatan desainer yang menyertainya: *"Old Bram tidak ingat Ashbrook besar; ia lahir
setelahnya. Tapi ia ingat AYAHNYA mengeluh soal antrean di penggilingan. Antrean. Di desa
40 orang tidak ada antrean. Ia menceritakannya sebagai lelucon tentang orang tua yang
membesar-besarkan.* **⚠ Bram TIDAK sedang membantu pemain. Ia sedang bergosip.**"

Itu #226 dalam bentuk paling murni: bukti datang dari orang yang **tidak tahu ia sedang
memberi bukti**.

---

# MERRIT FANE — bahan yang Direktur minta

## 1. Siapa Merrit (sheet #011 — "Yang Menunggu Surat Balasan")

**Merrit Fane, 58 tahun, tukang pos desa Ashbrook.** Bukan tukang pos biasa: di desa 40
jiwa ia adalah **simpul** — tangan yang menyentuh tiap kabar masuk dan keluar lembah. Ia
**hafal tulisan tangan setiap keluarga**. Ia tahu siapa yang sedang menunggu kabar dan
siapa yang berpura-pura tidak.

**Fisik:** jangkung mulai membungkuk, rambut kelabu diikat ke belakang, **jari bernoda
tinta permanen**. Berjalan pelan, tak pernah terlambat mengantar — **kecuali ke satu
alamat**. Mantel pos tua yang seharusnya diganti dua dekade lalu; ia menolak, karena
*"mantel ini yang dipakainya waktu ia melihatku terakhir kali."*

**Rumahnya merangkap rumah singgah.** Dulu ramai. Kini nyaris kosong — jalur dagang
bergeser. **Ia mempertahankannya bukan untuk uang.**

**Surat itu.** Empat puluh tahun lalu seorang pengelana muda menitipkan sepucuk surat:
*"Simpan ini. Jangan dibaca. Aku akan kembali mengambilnya."* Ambisi Merrit bukan tahu
isinya — melainkan **agar orang itu kembali mengambilnya sendiri.** Selama surat itu
tertutup, janji itu masih hidup.

**Lampu itu.** Satu lampu menyala di jendela, **siang hari**, empat puluh tahun. Sudah
ter-wire di game (`lantern.png` + `PointLight2D` + beacon lintas-jarak #218).

**Ketakutannya** bukan kematiannya sendiri: ia takut **kesetiaannya sia-sia** — bahwa ia
menunggu sesuatu yang sudah lama tak ada, dan dunia diam-diam menertawakan orang tua yang
tak bisa melepaskan.

**Konflik intinya:** *ia menyampaikan kabar orang lain, tapi menolak mencari kabar yang ia
sendiri butuhkan.* Ia bisa mengirim surat ke utara, bertanya, menyelidiki. Ia tak pernah.
**Karena selama ia tidak tahu, kedua kemungkinan masih hidup.** Mencari tahu berarti
memilih satu kenyataan — mungkin yang salah. *Keberaniannya mengantar setiap surat, dan
kepengecutannya menolak menyelidiki satu.*

**Ratifikasi #206:** kesepiannya **bukan sifat, melainkan akibat** — kotanya yang mengecil.
*"Seorang tukang pos yang menolak melupakan satu orang, tinggal di kota yang sedang
dilupakan dunia."* Ia tak pernah menyebutkannya; baginya kedua hal itu bahkan bukan soal
yang sama.

## 2. Apa yang ia katakan pada orang asing

### (a) Empat baris yang SUDAH ADA — dan sedang dipakai wajah yang salah

`town_npcs.json` sudah memuat persona **"Merrit Fane"**, arketipe **tragis**, 4 baris:

> 1. *"Kamar-kamar itu masih kusapu. Bukan karena ada yang datang. Karena kalau berdebu, aku akan terbiasa."*
> 2. *"Tulisan tanganmu jelek. Bagus. Yang jelek biasanya jujur."*
> 3. *"Dulu aku hafal tulisan tangan setiap keluarga di sini. Sekarang aku hafal semuanya karena tinggal sedikit."*
> 4. *"Kalau kau pergi ke Greenvale, jangan menoleh. Atau menolehlah. Terserah. Lampunya tetap menyala."*

⚠ Baris-baris ini **hidup di tubuh yang salah**: mereka dipasang pada `Villager` berwajah
**generik** (`warga_00…19`), sementara potret Merrit yang sesungguhnya berdiri bisu di
depan rumahnya. Inilah "dua Merrit berdampingan" dari audit.

**Perbaikan yang Direktur minta = memindahkan empat baris ini ke wajah aslinya.** Nol
tulisan baru diperlukan untuk langkah pertama.

⚠ Catatan: baris 2 (*"tulisan tanganmu jelek"*) mengandaikan Merrit **sudah kenal** pemain.
Itu benar untuk **sebelum A2**, dan justru harus **hilang sesudah A2**.

### (b) Sesudah A2 — kalimat yang menghancurkan

`A2_SESEORANG_MELUPAKANMU.md` menetapkan satu baris, dan seluruh adegan bergantung padanya:

> **"Selamat pagi. Butuh kamar?"**

Itu cara ia menyapa **pengelana**. Bukan salah, bukan kasar — **hanya bukan untukmu**. Ia
menanyakan pertanyaan yang sama seperti hari pertama mereka bertemu. Nol musik, nol
kamera, nol toast. Yang hilang bukan pemain, melainkan **bahwa ia pernah menunggu pemain
juga**.

→ **Merrit butuh DUA himpunan dialog: sebelum-lupa dan sesudah-lupa.** Itulah A2, dan
itulah kenapa memberinya mulut membuka adegan yang sekarang tak ada.

## 3. Kesaksian Merrit — **tak ada; yang ada bukti TENTANG dia**

Halaman `person_merrit_fane` (kematian **d2** — ada lalu dicoret, **bisa** dipulihkan)
punya empat bukti. Ketiganya bukan dialog, dan **semua ada di dalam rumah singgahnya** —
ruangan yang **sudah ada di game** (kamar Merrit, kini berisi surat & botol):

| bukti | jenis | cara | teks yang sudah ditulis |
|---|---|---|---|
| `ev_merrit_kartu_pos_kosong` | **benda** | `examine` | *"Kartu pos kosong. Tanpa alamat. Di sudutnya, tulisan tangan Merrit: harga, dan sebuah tanggal — hari pertama kau tiba di Ashbrook."* |
| `ev_merrit_cangkir_kedua` | **kebiasaan** | `observe` (pagi) | *"Dua cangkir di meja. Ia menuang teh ke keduanya, seperti tiap pagi. Yang kedua dingin tanpa disentuh, seperti tiap pagi."* |
| `ev_merrit_rute_pos_berubah` | **akibat** | `examine` | *"Rute posnya punya satu perhentian yang tak masuk akal — tak ada rumah di sana. Ditambahkan beberapa bulan lalu, dengan tulisan tangannya sendiri. Ia masih melewatinya tiap hari."* |
| `ev_merrit_arlen_ingat` | **orang** | `dialog_arlen` | ⛔ **butuh Arlen — tak ada di game** |

Ketiganya berbunyi: **tubuh ingat setelah kepala lupa.** Itu isi A2.

→ **Halaman Merrit bisa dipulihkan lewat jalur SELF** (butuh 3 jenis: benda + kebiasaan +
akibat ✓) — **tapi tak akan pernah sempurna** sampai Arlen ada.

---

# USUL URUTAN — dua pilihan, Direktur putuskan

## Jalur A — "cacat dulu" (leverage tertinggi)

1. **OLD BRAM bicara** → pasang `ev_ashbrook_bram_ingat_ayahnya`.
   **Hasil langsung: pemulihan sempurna Ashbrook jadi mungkin; loss kembali jadi pilihan.**
   Dialognya sudah ditulis. Ongkos: satu NPC + satu titik bukti.
2. Merrit bicara (empat baris dipindah ke wajah asli) + tiga bukti di kamarnya.
3. Sisanya: Halloran, Nyai (perilaku Kamis, bukan dialog), Otha, Sora.

## Jalur B — "Merrit dulu" (permintaan awal Direktur)

1. Merrit bicara + tiga bukti di kamar → membuka **halaman Merrit** & fondasi **A2**.
2. Bram menyusul → menutup cacat utama.

**Rekomendasi saya: Jalur A.** Sebabnya bukan bahwa Merrit kurang penting — melainkan
bahwa cacat yang Direktur sendiri sebut sebagai pembatal tesis (*"hukuman yang tak
terhindari berhenti jadi hukuman"*) **hanya tersentuh oleh Bram**. Merrit membuka pintu
baru; Bram menutup lubang yang sudah menganga. Menutup lubang dulu.

⚠ Kalau Jalur B tetap dipilih, itu sah — asal Direktur tahu bahwa sesudah Merrit selesai,
**loss "kota bukan 1500 orang" masih tetap tak terhindari.**

---

## Yang saya butuh dari Direktur untuk mulai

**Kalau Jalur A (Bram):** nol tulisan baru — kalimatnya sudah ada di `evidence.json`.
Cukup satu putusan: **Bram memberi kesaksian itu di baris keberapa?** Ia punya 4 baris
gosip; kesaksian ini baris ke-5, atau menggantikan salah satunya?

**Kalau Jalur B (Merrit):**
1. Empat baris lama dipakai ulang untuk wajah asli — **ya atau tulis baru?**
2. Himpunan **sesudah-A2** ("Selamat pagi. Butuh kamar?" + 2–3 baris pengiring) — perlu
   tulisan tangan Direktur, karena A2 belum ada mekanismenya.
3. Tiga bukti di kamar sudah punya teks; cukup putusan **di perabot mana** masing-masing
   dipasang (kartu pos di laci? cangkir di meja? buku rute di rak?).
