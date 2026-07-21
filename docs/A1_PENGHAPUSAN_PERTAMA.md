# A1 — "PENGHAPUSAN PERTAMA"
## Adegan · Ashbrook · Jalur A (kanon, pasti) · Draft Penulis v0.1

**Hukum yang mengikat:** D-3 (nol teks on-screen) · #210 (tunjukkan, jangan papan-informasikan) ·
§0 (adegan harus kuat andaikan Nirnama tak pernah muncul) · §XIII (Ordinary People) ·
#206 (Ashbrook = desa-bekas-kota)
**Kapan:** Act 1 Fase 1 (jam 1–30). **Sesudah** pemain nyaman di Ashbrook, **sebelum** ia curiga apa pun.

---

> ## MAKSUD ADEGAN INI
>
> **Pemain harus melewatkannya.**
>
> Ini satu-satunya adegan di Aetherion yang dirancang untuk **gagal**. Kalau pemain
> menyadarinya di kali pertama, adegan ini tidak bekerja.
>
> Yang kita tanam bukan informasi. Yang kita tanam adalah **rasa bersalah yang tertunda** —
> yang baru meledak berjam-jam kemudian, saat pemain sadar bahwa **ia pernah lewat di depannya
> dan tidak berhenti.**

---

# 1. SIAPA YANG DIHAPUS

**Bukan companion. Bukan quest giver. Bukan siapa-siapa.**

> ### TOKO KAIN OTHA
> Sebuah bangunan kecil di jalan utama Ashbrook, di antara rumah pos Merrit dan gudang gandum.
> Pintunya tertutup. Jendelanya berdebu. **Papan namanya kosong** — kayu polos, tanpa tulisan,
> dengan dua lubang paku dan bekas cat yang lebih gelap di tengahnya, berbentuk persegi panjang.
>
> Otha Renn, 61 tahun, penjahit. Ia menjahit untuk Ashbrook selama tiga puluh empat tahun,
> sejak kota ini masih punya seribu lima ratus jiwa dan orang masih perlu baju baru.
> Ia berhenti membuka toko dua musim lalu karena tidak ada lagi yang memesan.
> **Ia masih tinggal di dalamnya.**
>
> **Ia tidak akan pernah muncul di layar.**

**Kenapa dia:** karena §XIII. Yang dihapus **harus** orang yang tidak penting. Kalau kabut pertama
mengambil seorang tokoh, pemain akan belajar bahwa penghapusan itu **dramatis**. Ia harus belajar
sebaliknya: penghapusan itu **tidak dramatis sama sekali.** Ia terlihat persis seperti sebuah toko
yang tutup.

---

# 2. YANG PEMAIN LIHAT (dan tidak lihat)

## ⛔ DILARANG — D-3, dikodekan bukan diharapkan

❌ toast · ❌ banner · ❌ stinger · ❌ musik berubah · ❌ cutscene · ❌ entri quest ·
❌ penanda peta · ❌ kamera pan · ❌ NPC yang menyebutkannya · ❌ satu pun kata di layar

**Test wajib:** `_test_a1_is_silent()` — jalankan A1 di scene nyata, pastikan **nol** sinyal
`toast`/`banner`/`stinger`/`cutscene` ter-emit. *(Pola sama dengan White Stag #216.)*

## ✅ YANG BERUBAH — dan semuanya diam

**Sebelum** (jam 1–N, pemain lewat berkali-kali):
- Papan nama bertuliskan **"OTHA — JAHIT & TAMBAL"**, cat biru pudar
- Kadang ada seorang tua duduk di bangku depan pintu saat sore. Tidak bicara. Mengangguk kalau ditegur.
- Halloran Muda, saat lewat, kadang berkata: *"Pagi, Bu Otha."*

**Sesudah** (satu pagi, tanpa peringatan):
- **Papan namanya kosong.** Kayu polos. Dua lubang paku. Bekas cat yang lebih gelap di tengah.
- **Bangku depan pintu masih ada.** Kosong.
- Halloran lewat. **Tidak berkata apa-apa.** Ia tidak berhenti. Ia tidak melihat ke arah pintu itu.
  **Rutenya bahkan sedikit berubah** — ia berjalan lebih lurus sekarang, tidak lagi melipir ke kanan.
- Kalau pemain **berdiri di depan pintu itu dan menekan tombol interaksi:** tidak terjadi apa-apa.
  Bukan *"Pintu terkunci."* **Tidak ada respons sama sekali** — seperti berinteraksi dengan tembok.

**Dan itu saja. Tidak ada lagi.**

---

# 3. BEKAS YANG TERTINGGAL — Hukum Bukti (D-1) ditanam di sini

**Ini yang membuat adegan ini bisa dipulihkan berjam-jam kemudian.** Empat bekas ditanam sekarang,
tanpa penjelasan, tanpa penanda. Semuanya **sudah ada di dunia sebelum penghapusan** — pemain
mungkin sudah melihatnya dan tidak peduli.

| `kind` | Bekas | Di mana | Kabut tidak bisa menyentuhnya karena |
|---|---|---|---|
| **`akibat`** | **Bekas cat di papan nama.** Persegi panjang lebih gelap. Kayu di bawah tulisan tidak seluruh pudar oleh matahari. | papan itu sendiri | bekas bukan ingatan — ia **fisika** |
| **`kebiasaan`** | **Bangku depan pintu.** Kakinya sudah membentuk empat cekungan di tanah, sedalam tiga puluh empat tahun. | depan toko | tanah ingat setelah orang lupa |
| **`benda`** | **Mantel pos Merrit** — *"mantel ini yang dipakainya waktu ia melihatku terakhir kali"* **(kanon sheet #011)**. Jahitan di siku kanannya diperbaiki. **Bukan oleh Merrit.** | Merrit | benda tidak punya ingatan untuk dihapus |
| **`orang`** | **Nyai Tuminah.** Ia tidak ingat Otha. Tapi setiap Kamis sore ia berjalan ke jalan utama, berhenti di depan toko itu, berdiri sebentar, lalu pulang. **Ia tidak tahu kenapa.** *"Kaki tua. Sudah hafal jalannya sendiri."* | jadwal NPC | mencintai = ingatan yang tidak disimpan di kepala **(#5a Lapis 1)** |

**Aturan penulisan:** keempat bekas ini **dilarang** disebut oleh siapa pun sebagai petunjuk.
Tidak ada NPC yang berkata *"aneh ya, papan itu kosong."* Dunia **tidak sedang membantu pemain.**

---

# 4. TIGA CARA ADEGAN INI BERAKHIR

## (a) PEMAIN TIDAK SADAR — **~90% pemain, dan ini yang benar**

Tidak terjadi apa-apa. Pemain lanjut main. Toko itu tetap tutup selamanya.
Nyai Tuminah tetap berjalan ke sana setiap Kamis sore sampai ia mati.

**Chronicle tidak mencatat apa pun.** Tidak ada halaman yang tercoret — karena **Otha tidak pernah
punya halaman.** Ia tidak pernah cukup penting untuk dicatat.

> **Dan itulah dakwaannya.** Nirnama tidak perlu mencoret apa-apa. **Dunia sudah tidak mencatatnya
> sejak awal.** Kabut cuma menyelesaikan pekerjaan yang sudah dimulai oleh ketidakpedulian.

## (b) PEMAIN SADAR — TERLAMBAT

Berjam-jam kemudian — setelah A2 (seseorang yang pemain kenal melupakannya), setelah pemain
tahu kabut itu nyata — pemain berjalan melewati jalan utama, dan **berhenti.**

Ia melihat papan kosong itu. Bekas cat persegi panjang. Bangku dengan empat cekungan.

**Dan ia ingat bahwa dulu ada tulisannya. Ia tidak ingat tulisannya apa.**

**Ini adalah momen emosional paling penting di Act 1.** Bukan reveal Nirnama. **Ini.**
Karena pemain baru saja mengalami sendiri apa yang Elyn alami selama seratus tahun:

> *"Ia ingat bahwa buku itu **ada**. Ia ingat warna punggungnya, tempatnya di rak, berat di tangan.
> Isinya sudah tidak ada di dalam dirinya."* — sheet #002

**Pemain baru saja menjadi Elyn.** Dan tidak ada yang memberitahunya.

## (c) PEMAIN SADAR — SEKETIKA (langka, dan harus dihargai)

Pemain yang benar-benar memperhatikan — yang menghafal jalan utama, yang menyapa Otha di bangku,
yang menyadari Halloran mengubah rutenya — akan berhenti **di hari itu juga.**

**Yang ia dapat: tidak ada.** Tidak ada reward. Tidak ada achievement. Tidak ada Chronicle entry.

**Yang ia dapat sebenarnya:** empat bekas masih segar, Nyai Tuminah masih hidup, dan
**pemulihan masih mungkin.** Ia bisa membawa bekas-bekas itu ke Elyn (R5) dan menulis halaman
untuk seseorang yang tidak pernah punya halaman.

> **Dan halaman itu — *"Otha Renn, penjahit, tiga puluh empat tahun"* — adalah entri Chronicle
> pertama di seluruh game yang dibuat oleh PEMAIN, bukan oleh pencapaian.**
>
> Bukan first-clear. Bukan boss. **Seorang penjahit yang berhenti membuka toko karena tidak ada
> lagi yang memesan.**
>
> Itu §XIII, dan pemain melakukannya sendiri, tanpa disuruh.

---

# 5. KENAPA ADEGAN INI LOLOS UJI §0

> *"Uji tulis: kalau sebuah adegan tetap kuat andaikan Nirnama tidak pernah muncul di dalamnya,
> adegan itu benar."*

**Nirnama tidak ada di adegan ini.** Tidak disebut, tidak diisyaratkan, tidak terlihat.

Dan lebih dari itu: **adegan ini akan tetap menyakitkan andaikan Nirnama tidak ada sama sekali.**
Karena yang terjadi pada Otha Renn **terjadi setiap hari, di dunia nyata, tanpa kabut apa pun.**
Orang tua berhenti membuka toko. Papan namanya pudar. Tetangganya lupa. Dan tak seorang pun jahat.

**Itulah kenapa pertanyaan Nirnama masuk akal.** Dan itulah kenapa adegan ini harus jadi
yang pertama.

---

# 6. CATATAN PRODUKSI

| Kebutuhan | Status |
|---|---|
| Sprite papan nama: **2 varian** (bertulisan / kosong dengan bekas cat) | 🔴 aset |
| Sprite bangku + 4 cekungan di tanah | 🔴 aset |
| NPC Otha: **sprite duduk saja**, tanpa dialog, tanpa jadwal jalan | 🟡 kecil |
| `NpcSchedule`: rute Halloran **berubah** setelah A1 (kanon #216 — ia sudah punya jadwal ✅) | 🟢 mesin ada |
| `NpcSchedule`: Nyai Tuminah — rute Kamis sore ke jalan utama, berhenti 4 detik, pulang | 🟢 mesin ada |
| Mantel Merrit: jahitan siku sebagai `evidence` (`kind: benda`) | 🟡 data |
| `data/evidence.json`: 4 bekas Otha | 🟡 data |
| Test `_test_a1_is_silent` | 🟡 test |
| **Dialog** | ✅ **NOL.** Tidak ada satu baris pun ditulis untuk adegan ini. |

**Biaya total: sangat murah.** Dua sprite, dua perubahan jadwal, satu file data.
**Dan ini mungkin adegan terpenting di Act 1.**

---

> ## SATU KALIMAT UNTUK PENULIS BERIKUTNYA
>
> Kalau kelak ada yang tergoda menambahkan **satu saja** petunjuk — satu NPC yang berkata
> *"kok papan itu kosong ya?"*, satu toast, satu ikon tanda seru — **tolak.**
>
> Kekuatan seluruh adegan ini adalah bahwa **dunia tidak memberitahumu apa yang baru saja hilang.**
> Persis seperti dunia sungguhan. Persis seperti Otha Renn.
