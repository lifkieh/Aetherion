# BRIEF UNTUK AI AGENT — IMPLEMENTASI R1 + A1/A2
## ⚠ BACA SELURUHNYA SEBELUM MENYENTUH SATU BARIS KODE

---

# 0. PERINGATAN — BACA INI DUA KALI

> ## **Aetherion SENGAJA melanggar praktik UX yang baik.**
>
> Kamu dilatih untuk membuat antarmuka yang informatif, responsif, dan memuaskan.
> **Di proyek ini, sebagian besar naluri itu SALAH.**
>
> Kalau kamu merasa *"ini kurang feedback"* · *"user butuh progress indicator"* ·
> *"restore harusnya pulih penuh"* · *"kasih toast dong biar tahu"* —
> **kamu sedang merasakan naluri yang benar di proyek yang salah.**
>
> **Semua itu SUDAH dipertimbangkan, dan SUDAH ditolak, oleh Direktur.**
> Bukan kelalaian. **Itu desainnya.**

**Kalau kamu "memperbaiki" satu saja dari daftar larangan di §2, kamu merusak fitur inti game ini.**

---

# 1. KONTEKS 60 DETIK

Aetherion = RPG tentang **ingatan vs pelupaan**. Antagonisnya (Sang Nirnama) **menghapus** —
bukan membunuh. Ia mencoret halaman buku sejarah dunia (Chronicle).

**Core loop:** Nirnama mencoret → pemain menulis ulang.
**Tidak ada yang menang. Yang kalah adalah yang berhenti menulis.**

**Tagline:** *"Be yourself in another world."*

Tiga hukum yang mengikat seluruh pekerjaan ini:

| # | Hukum | Artinya untukmu |
|---|---|---|
| **#226** | Ingatan tak bisa dipulihkan dari ingatan — **hanya dari BEKAS** | butuh ≥2 **jenis** bukti berbeda |
| **#228** | **Tak ada jalan tunggal** | pemain sendirian **tak pernah** terkunci |
| **#229** | Boleh sekejam dunia nyata | jangan lunakkan apa pun |

---

# 2. ⛔ DAFTAR LARANGAN — LANGGAR SATU = FITUR RUSAK

Setiap larangan punya nomor putusan Direktur. **Semua sudah final.**

| # | ⛔ DILARANG | Kenapa (jangan tanya ulang) |
|---|---|---|
| **D-3** | `strike()` memanggil **toast · banner · stinger · musik · cutscene** | Penghapusan **harus** bisa dilewatkan pemain seumur hidup. Kalau ada notifikasi → jadi quest. Quest tidak menakutkan. |
| **D-4** | **Angka apa pun** di Chronicle: persen · "23/49" · progress bar · badge · sortir "belum pulih" | **Menghitung ADALAH kesalahan Nirnama** (§XIII). Progress bar mengajari pemain berpikir seperti dia. |
| **#226** | `restore()` yang **tidak** kehilangan apa pun | Halaman yang ditulis ulang **TIDAK PERNAH** identik. Selalu. Termasuk dengan bukti lengkap. |
| **#226** | Menghitung **jumlah bukti** alih-alih **jumlah JENIS** | 10 surat = tetap 1 jenis = tetap gagal |
| **#219** | Menampilkan **potensi/tier/bintang** monster atau NPC di UI mana pun | Nilai ada di data. Pemain lihat `???`. Selamanya. |
| **#228** | Membuat jalur yang **hanya bisa** lewat 1 companion | Pemain tanpa Elyn **harus** tetap bisa menulis (3 jenis bukti) |
| **#229.3** | Membuat entri placeholder/kosong untuk NPC yang tak pernah disentuh | Yang tak pernah dicatat meninggalkan **TIDAK ADA APA-APA** |
| **#210** | Teks on-screen di Ashbrook | Sudah kanon sejak #216. Jangan tambah. |

## Kalau kamu ragu

**Jangan "perbaiki". Tanya Direktur.** Tulis pertanyaannya di `BLOCKED.md` dan lanjut ke tugas lain.

---

# 3. BERKAS YANG DIKIRIM & URUTAN BACA

**Baca urut ini. Jangan lompat.**

| # | Berkas | Isi | Wajib? |
|---|---|---|---|
| 1 | `CANON_219-230_FINAL.md` | **12 putusan Direktur.** Semua hukum. | ✅ **baca dulu** |
| 2 | `CHRONICLE_RESTORATION_SPEC.md` | core loop · Hukum Bukti · jalur A/B/C · peran 4 companion | ✅ |
| 3 | `R1_SPEC_TEKNIS.md` | API · struktur data · 8 test wajib | ✅ untuk R1 |
| 4 | `PASANG_R1.md` | 5 langkah pasang | ✅ untuk R1 |
| 5 | `Chronicle.gd` | **kode jadi** — drop-in | ✅ |
| 6 | `chronicle_losses.json` | **data jadi** — 3 halaman | ✅ |
| 7 | `TestRunner_R1_tests.gd` | **8 test jadi** | ✅ |
| 8 | `A1_PENGHAPUSAN_PERTAMA.md` | adegan 1 — Toko Kain Otha | 🟡 setelah R1 |
| 9 | `A2_SESEORANG_MELUPAKANMU.md` | adegan 2 — Merrit lupa pemain | 🟡 setelah R1 |
| 10 | `HUKUM_KEPATUHAN_FITUR.md` | uji 7 pertanyaan untuk fitur GDD | 🟡 rujukan |

---

# 4. TUGAS 1 — PASANG R1 (kode sudah jadi, jangan tulis ulang)

**`Chronicle.gd` dan test-nya SUDAH SELESAI dan SUDAH DIVERIFIKASI logikanya.**
Tugasmu: **memasang**, bukan merancang ulang.

Ikuti `PASANG_R1.md` — 5 langkah:
1. `EventBus.gd` → 3 sinyal baru
2. `Chronicle.gd` → ganti isi
3. `chronicle_losses.json` → salin ke `game/data/`
4. `SaveManager.gd` → migrasi + `SCHEMA_VERSION := 2`
5. `TestRunner.gd` → tempel 8 test, daftarkan

## Yang boleh kamu ubah
- Path/nama sesuai struktur repo nyata (mis. `res://autoload/` vs `res://game/autoload/`)
- Sintaks yang tidak kompile di versi Godot-mu
- Cara `Db.get_json()` dipanggil — **cek konvensi asli di repo**

## Yang TIDAK boleh kamu ubah
- Aturan `SCRIBE_KINDS_NEEDED` (self=3, elyn=2, sora=2)
- Kediaman `strike()` (D-3)
- Ketiadaan fungsi hitung (D-4)
- Isi `chronicle_losses.json` — **itu tulisan tangan, bukan placeholder**

## Definisi selesai
**947 test lama tetap lulus + 8 test baru lulus.** Kalau ada yang gagal, laporkan — jangan
matikan test-nya.

---

# 5. TUGAS 2 — A1 & A2 (butuh penyesuaian aset)

**Ini bagian yang butuh matamu**, karena dokumennya ditulis tanpa tahu aset apa yang kamu punya.

## Cara kerja yang benar

1. **Baca adegannya dulu sampai paham maksudnya** — bukan cuma daftar aset
2. **Inventaris aset yang ADA** di `game/assets/game/sprites/` dan `tiles/`
3. **Cocokkan** — kalau tak ada, cari yang paling dekat
4. **Laporkan yang tidak bisa dipenuhi** — jangan diam-diam ganti

## A1 — kebutuhan aset

| Kebutuhan | Kalau tak ada aset |
|---|---|
| Papan nama toko: **2 varian** (bertulisan / kosong + bekas cat persegi panjang lebih gelap) | **Ini WAJIB.** Kalau tak ada, buat dari tile kayu polos + 1 rect gelap. Bekas cat adalah **bukti `akibat`** — tanpa ini adegan mati. |
| Bangku + 4 cekungan di tanah | boleh diganti: bangku biasa + 4 tile tanah lebih gelap |
| Otha: sprite **duduk saja**, tanpa jalan, tanpa dialog | boleh pakai sprite NPC tua mana pun. **Jangan beri dia dialog.** |
| Rute Halloran berubah setelah A1 | `NpcSchedule` sudah ada — cukup ubah waypoint |
| Rute Nyai Tuminah: Kamis sore → jalan utama → berhenti 4 detik → pulang | `NpcSchedule` sudah ada |

**⚠ Yang paling sering salah dipahami:** bekas cat di papan nama **bukan dekorasi.** Itu bukti
`akibat` yang dipakai `restore()`. Kalau kamu ganti papan kosong jadi papan bersih tanpa bekas,
**kamu menghapus mekanik.**

## A2 — kebutuhan aset

| Kebutuhan | Catatan |
|---|---|
| Kartu pos kosong (item) | **bukti `benda`** — wajib ada |
| Cangkir kedua di meja pagi Merrit | **bukti `kebiasaan`** — prop kecil |
| Buku rute Merrit | **bukti `akibat`** — bisa jadi teks di objek yang ada |
| Dialog Merrit: reset ke set perkenalan | **dialognya sudah ada** — cukup panggil set lama |
| ~6 baris dialog baru (Arlen, Sora, Bram, Lyra, Halloran) | ada di dokumen A2 |

**⚠ Prasyarat A2: memori NPC v0.6 (`affinity = 0`).** Kalau belum ada, **A2 belum bisa dibangun.**
Laporkan, jangan paksakan.

---

# 6. ATURAN PENYESUAIAN ASET

> **Aset boleh diganti. MEKANIK tidak.**

Setiap bekas (`benda` · `kebiasaan` · `akibat` · `orang`) adalah **bagian dari sistem**, bukan hiasan.
Kalau kamu mengganti sebuah aset, tanya:

1. **Apakah bukti ini masih bisa dilihat pemain tanpa dijelaskan?**
   *(Bekas cat harus terlihat. Cangkir kedua harus terlihat.)*
2. **Apakah ia masih tidak punya penanda?**
   *(Jangan tambah ikon "!" di atas kartu pos. Jangan beri outline.)*
3. **Apakah dunia masih tidak membantu pemain?**
   *(Jangan tambah NPC yang bilang "kok papan itu kosong ya?")*

**Kalau salah satu jawabannya "tidak" — aset penggantinya salah.**

---

# 7. YANG **TIDAK** DIBANGUN SEKARANG

Jangan tergoda melengkapi. Ini sengaja belum ada:

❌ Kabut (siapa yang mencoret) ❌ Yang Terhapus (musuh) ❌ NPC lupa (butuh memori v0.6)
❌ Wilayah memutih ❌ UI restore (R5 — butuh Elyn) ❌ Sora sebagai alarm (R6)

**R1 hanya membuat buku bisa terluka dan bisa disembuhkan. Itu saja. Itu cukup.**

---

# 8. LAPORAN YANG DIHARAPKAN

Setelah selesai, tulis di `DEVLOG.md`:

```
## R1 — Chronicle Restoration (#221)
- [x/8] test lulus · [n] test lama tetap lulus
- Aset A1: [apa yang dipakai / apa yang diganti / apa yang belum ada]
- Aset A2: [sama]
- PENYIMPANGAN dari spec: [ada/tidak ada] — kalau ada, alasannya + baris di GAP_AUDIT.md
- DIBLOKIR: [apa yang butuh putusan Direktur]
```

**Aturan ledger (c) & (d) berlaku:** setiap penyimpanganmu dari spec = baris + alasan di
`GAP_AUDIT.md`. Implementasi yang bertentangan tanpa baris keputusan = **BUG DESAIN.**

---

# 9. TIGA KALIMAT YANG HARUS KAMU INGAT

> **1. Kalau naluri UX-mu bilang "tambahkan feedback" — jangan. Itu larangan D-3.**
>
> **2. Kalau naluri UX-mu bilang "tambahkan progress" — jangan. Itu larangan D-4.**
>
> **3. Kalau naluri engineering-mu bilang "restore harusnya pulih penuh" — jangan. Itu #226 #3.**

Ketiganya terasa seperti bug. **Ketiganya adalah fiturnya.**

---

> ## UJI TERAKHIR SEBELUM COMMIT
>
> Jalankan seluruh test. Lalu tanya dirimu satu hal:
>
> **"Kalau seorang pemain tidak memperhatikan sama sekali, apakah ia bisa melewatkan
> seluruh penghapusan ini tanpa pernah tahu?"**
>
> **Kalau jawabannya TIDAK — kamu sudah menambahkan sesuatu yang tidak boleh ada.**
