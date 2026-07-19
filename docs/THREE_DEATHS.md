# THE THREE DEATHS — Aetherion

**Status sumber: LOCKED** (kanon Direktur). **Diekstrak 2026-07-20** dari
`docs/Aetherion_blueprint_reasoning_and_design.txt` (**THE CHRONICLE — THE MEMORY OF THE
WORLD**, baris **9847–9896**) — **arsip mentah TIDAK diedit**. Decision Log **#269**.

> Pola ekstraksi sama dengan **#194** (FACTION_BIBLE) dan **#203/#211** (KINGDOM_BIBLE):
> arsip terkunci diangkat jadi kanon terbaca, verbatim dulu, tafsir belakangan dan ditandai.

---

# 1 — TEKS SUMBER, VERBATIM

`…design.txt:9847-9866` — konteks yang melahirkannya:

> **THE CHRONICLE**
> **THE MEMORY OF THE WORLD**
>
> Chronicle bukan buku.
> **Chronicle adalah sistem.**
> Jaringan catatan terbesar di dunia.
>
> **Dikelola oleh:**
> Chronicle Order
> Memory Keepers
> Scholar
> Archivists
>
> Tujuan: **Mengingat.**
>
> **Filosofi**
> **Apa yang diingat akan hidup lebih lama.**

`…design.txt:9868-9894` — blok inti:

> **THE THREE DEATHS**
>
> Menurut Chronicle.
> **Seseorang mati tiga kali.**
>
> **Death 1**
> **Biological Death**
> Tubuh berhenti hidup.
>
> **Death 2**
> **Social Death**
> Tidak ada lagi yang menyebut namanya.
>
> **Death 3**
> **Historical Death**
> Tidak ada catatan bahwa ia pernah ada.
> **Inilah kematian terbesar.**
>
> **Design Reasoning**
> Sangat selaras dengan tema Aetherion.

---

# 2 — TIGA KEMATIAN, DIRAPIKAN

| | Nama | Bunyinya | Yang hilang |
|---|---|---|---|
| **D1** | **Biological Death** | *"Tubuh berhenti hidup."* | tubuh |
| **D2** | **Social Death** | *"Tidak ada lagi yang menyebut namanya."* | **penyebutnya** — orang berhenti mengucapkan |
| **D3** | **Historical Death** | *"Tidak ada catatan bahwa ia pernah ada."* | **catatannya** — tak ada bukti ia ada |

**D3 adalah "kematian terbesar" menurut sumber.** Bukan D1.

**Beda D2 dan D3 — dan ini yang paling sering keliru:**

> **D2 = ADA, lalu berhenti disebut.** Catatannya boleh masih ada; yang berhenti adalah mulut.
> **D3 = TIDAK PERNAH ADA catatannya sama sekali** — atau catatannya lenyap sampai tak ada
> bukti apa pun bahwa ia pernah ada.

Seseorang bisa terkena D2 tanpa D3 (namanya di arsip, tak ada yang membacanya).
Seseorang bisa terkena D3 tanpa pernah terkenal cukup untuk D2.
**Keduanya bukan tingkatan dari hal yang sama. Keduanya kehilangan yang berbeda.**

---

# 3 — JANGKAR KE KODE (R1)

Inilah alasan ekstraksi ini penting: **mesin R1 sudah membedakan D2 dan D3 sejak awal, tanpa
tahu nama keduanya.**

| Kanon | Kode | Kematian |
|---|---|---|
| `strike()` — halaman **ada**, lalu dicoret | `Chronicle.gd` `strike()` → `state = ST_STRUCK`. Data asli **disimpan tersembunyi**, bisa dipulihkan lewat perlawanan. | **D2** |
| `#229.3` — *"yang tak pernah dicatat tak meninggalkan apa-apa — **bukan entri kosong, tidak ada apa-apa**"* | **Tidak ada entri sama sekali.** `Chronicle.has()` → `false`, `state_of()` → `""`, `strike()` → `false`. | **D3** |
| `restore()` — halaman ditulis ulang dari **bekas** | melawan **D2**: yang dicoret bisa kembali karena catatannya masih ada di bawah coretan | **D2 bisa dilawan** |
| `loss` (#260) — *"restore tak pernah lengkap"* | tiap pemulihan meninggalkan satu baris yang tak kembali | **sisa D3 di dalam D2** |

**Yang mengunci beda itu di test:** `_test_uncared_leaves_nothing()` menguji **D3 sebagai
ketiadaan** — nol entri, `state == ""`, `strike()` mengembalikan `false`, dan tak ikut
dibacakan di adegan terakhir. *Buku tak bisa membacakan yang tak pernah ditulis.*

## Dua tokoh, dua kematian — dan itulah isi adegan A3

| | **Merrit Fane** | **Otha Renn** |
|---|---|---|
| Kematian | **D2** | **D3** |
| Kanon | `A3:32` — *"Merrit tetap hidup. Tetap ramah. **Tetap tak ingat.**"* | `A3:32` — *"**Otha hilang selamanya. Tak ada yang pernah tahu ia ada.**"* |
| Kalau dipulihkan | *"Merrit ingat lagi bahwa ia pernah menunggu seseorang"* | *"Otha tercatat. **Pertama kali. Terakhir kali.**"* |
| Tubuhnya | **masih hidup** (58) | **sudah mati** (61) |

▸ **A3 menaruh D2 dan D3 di meja yang sama dan menyuruh pemain memilih satu.** Itu bukan
kebetulan desain — itu seluruh adegannya. Menyelamatkan Merrit = melawan D2 pada orang yang
masih hidup. Menyelamatkan Otha = melawan D3 pada orang yang sudah mati, **satu-satunya
kesempatan yang akan pernah ada.**

---

# 4 — HUBUNGAN DENGAN "SECOND DEATH"

Arsip yang sama, `…design.txt:576-580`, memakai istilah **Second Death** dalam model **dua**
kematian:

> **KETAKUTAN TERBESAR**
> Bukan kematian. **Pelupaan. Second Death.**
> **Tubuh mati. Lalu nama ikut mati.**
> Itulah yang ditakuti Nirnama.

**Keduanya kanon, dan tidak bertabrakan** — "Second Death" adalah **D2** dalam bahasa sehari-hari
dunia. `NIRNAMA_BIBLE_PUBLIC:153` memakainya persis begitu: *"tubuh boleh hidup, tapi yang
dilupakan sudah mati kedua kalinya."*

⚠ **Yang bertabrakan adalah pemakaiannya.** Karena D3 tak pernah punya nama yang beredar,
dua dokumen memakai *"kematian kedua"* untuk peristiwa yang sebenarnya **D3**. Dikoreksi
2026-07-20 — lihat blok koreksi di `DUNGEON_ORIGINS.md` dan `REGION_ORIGINS.md`.

**Aturan sejak #269:** *"Second Death"* boleh dipakai sebagai **istilah dalam-dunia** untuk D2.
Untuk D3, pakai **"kematian ketiga"** / *Historical Death* — **jangan** pakai "kematian kedua".

---

# 5 — YANG BELUM DIPUTUSKAN (jangan ditebak)

1. **Apakah D3 bisa dilawan sama sekali?** `restore()` memulihkan halaman yang **ada lalu
   dicoret** (D2). Untuk D3 murni, tak ada yang bisa dipulihkan — `record_person()` **membuat
   halaman baru**, dan itu bukan pemulihan, itu **penulisan pertama**. A3 menyebutnya
   *"Pertama kali. Terakhir kali."* — **belum ada baris kanon yang menyatakan apakah menulis
   yang belum pernah tercatat itu mengalahkan D3, atau cuma menundanya.**
2. **`ROADBOOK:207` — *"Kematian kedua = final mutlak"*** (hukum revive). Tapi R1 `restore()`
   **memulihkan halaman D2**. Dua sistem, dua arti "final"? Atau satu di antaranya perlu
   dipersempit? **Belum diputus.**
3. **`_compute_loss()` tak membedakan D2 dan D3.** Lihat §6.

---

# 6 — TEMUAN TEKNIS: KODE BELUM MEMBEDAKAN D2 DAN D3 **(dilaporkan, kode TIDAK diubah)**

**Yang sudah benar:** D3-sebagai-ketiadaan dijaga `_test_uncared_leaves_nothing()`.

**Yang belum ada:** begitu sebuah halaman **dibuat lalu dicoret**, mesin tak lagi tahu apakah
ia menceritakan D2 atau D3.

- `person_otha_renn` dan `person_merrit_fane` sama-sama masuk `WorldState.chronicle` dan
  sama-sama berakhir `state == ST_STRUCK`. Secara mekanis **identik**.
- `_compute_loss()` memilih baris `loss` **hanya** dari **jenis bukti yang TIDAK dibawa**
  (`loss_by_missing_kind` → `loss_self` → `default`). **Nol cabang** untuk jenis kematian.
- `chronicle_losses.json` juga tak punya medan untuk itu — kunci yang ada cuma
  `benda · kebiasaan · akibat · orang`.

**Akibatnya:** beda D2/D3 hari ini **sepenuhnya naratif** — hidup di teks `loss` yang ditulis
tangan (`default` Otha: *"Ia tercatat. Tiga puluh empat tahun itu tidak."*), bukan di mesin.

**Itu belum tentu salah.** Menuliskannya per halaman dengan tangan justru pola yang #226
tuntut (*"bukan tabel acak"*). Tapi konsekuensinya harus disadari:

> **Tak ada penjaga yang mencegah halaman D3 diberi baris loss bergaya D2, atau sebaliknya.**
> Satu penulis yang tak tahu bedanya bisa merusaknya tanpa satu test pun gagal.

**Usul (BUKAN keputusan, kode tak disentuh):** medan `death` opsional per halaman di
`chronicle_losses.json` (`"d2"`/`"d3"`), dipakai **hanya** oleh test sebagai penjaga
konsistensi — bukan oleh UI, bukan oleh `_compute_loss()`. Ia menjawab satu pertanyaan
ya/tidak (*"halaman ini bercerita kematian yang mana?"*), jadi ia tak melanggar D-4.
**Menunggu putusan Designer.**
