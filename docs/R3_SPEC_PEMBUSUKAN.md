# SPEC — R3: PEMBUSUKAN BUKTI
## "Dunia tidak menunggu pemain memutuskan." · Draft Designer v0.1

**Kanon:** #226 (Hukum Bukti) · #228 (Tagline) · #229 (Kekejaman: kejam-cuaca) ·
#227 ("Kesaksian Hujan") · D-3 (nol teks) · D-4 (tanpa angka) · #221 (core loop)
**Sandaran kode yang SUDAH ADA & TERBUKTI:**
`GameClock.unix_now()` ✅ · `GameClock.season()` ✅ · `WorldState.weather` ✅ ·
pola `node_states: {id -> {harvested_at: unix}}` ✅ · `Evidence.gd` (R2) ✅
**Prasyarat A3.** Juga prasyarat jalur C "Kesaksian Hujan" (#227).

---

# 0. TESIS

> **Tanpa R3, Chronicle Restoration adalah fetch quest yang sabar.**
> Kumpulkan bukti kapan saja. Tulis kapan saja. Tidak ada yang hilang.
>
> **Dengan R3, memulihkan ingatan jadi lomba melawan dunia yang terus melupakan.**
>
> Dan pemain **tidak pernah diberi tahu bahwa ia sedang berlomba.**

R3 bukan fitur A3. **R3 adalah yang membuat seluruh loop punya taruhan.**

---

# 1. TEMUAN YANG MENGUBAH DESAIN

**Tidak ada sistem umur NPC di proyek ini.** Saya cek: `Personality.gd` dan
`NpcSchedule.gd` tidak punya `age`/`birth`/`death`. Tidak ada.

Spec A3 §9 mengasumsikan *"Nyai Tuminah bisa mati"* — **itu asumsi yang salah.**

**Konsekuensi: R3 TIDAK BOLEH bergantung pada umur NPC.** Membangun sistem umur NPC
untuk satu bekas = biaya besar untuk hasil kecil, dan menyentuh sistem waktu yang baru
saja terbukti rapuh (#241: test tanaman gagal karena mengabaikan pengali musim).

**Ganti: bukti `orang` membusuk lewat LUPA, bukan MATI.**

> Nyai Tuminah tidak mati. **Ia berhenti berjalan ke sana tiap Kamis.**
>
> Kakinya makin sakit. Cucunya melarangnya keluar. Ia lupa itu hari Kamis.
> Suatu Kamis sore, jalan utama kosong. **Dan tidak ada yang memberitahu pemain
> bahwa bukti terakhir Otha baru saja berhenti berjalan.**

**Ini lebih baik dari kematian.** Kematian punya adegan; kematian punya bobot.
Berhenti berjalan tidak punya apa-apa. **Ia cuma... tidak datang lagi.**

Dan itu #229 kejam-cuaca dalam bentuk paling murni: **tidak ada yang mati.
Tidak ada yang salah. Cuma seorang perempuan tua yang kakinya sakit.**

---

# 2. EMPAT CARA BEKAS MEMBUSUK

Tiap `kind` membusuk dengan caranya sendiri — dan **caranya harus masuk akal
secara fisik**, bukan timer sewenang-wenang.

| `kind` | Cara membusuk | Pemicunya | Contoh |
|---|---|---|---|
| **`akibat`** | **memudar** — cuaca & waktu | hari berlalu + `sunny` mempercepat | bekas cat pudar di bawah matahari |
| **`kebiasaan`** | **terhapus** — peristiwa dunia | `weather == "rain"` | cekungan bangku rata oleh hujan |
| **`orang`** | **berhenti** — orang lupa | hari berlalu | Nyai berhenti berjalan tiap Kamis |
| **`benda`** | **TIDAK MEMBUSUK** | — | benda tidak punya ingatan untuk dihapus |

## Kenapa `benda` abadi — dan ini penting

**#226 sudah menetapkannya:** *"benda tak punya ingatan untuk dihapus."*

Kalau benda ikut membusuk, hukumnya bohong. Surat Merrit, kartu pos kosong, lonceng
gereja — **semuanya akan tetap ada seribu tahun lagi.**

> **Dan di situlah tragedinya:** bukti `benda` selalu ada, tapi **tidak pernah cukup
> sendirian** (#226 #1 butuh 2 jenis). Lonceng itu masih di sana, dengan tulisan
> *DARI SERIBU LIMA RATUS TANGAN* — dan tak seorang pun bisa membacanya lagi.
>
> **Bukti yang abadi tapi tak terbaca sama saja dengan tidak ada.**

## Konsekuensi desain: `benda` = lantai kesempatan (#184)

Karena `benda` abadi, **selalu ada minimal satu jenis bukti tersisa** untuk tiap
halaman. Pemain tidak pernah kehilangan **semuanya**.

Tapi satu jenis tidak pernah cukup. **Jadi yang hilang bukan kemungkinan —
yang hilang adalah kecukupan.** Pemain berdiri memegang lonceng, dan tidak bisa
menulis apa-apa dengannya.

*Itu jauh lebih kejam daripada kehilangan total.*

---

# 3. UMUR BEKAS — data, bukan kode

Tambah field di `evidence.json`:

```json
{
  "id": "ev_otha_bangku_cekungan",
  "kind": "kebiasaan",
  "decay": {
    "mode": "washed",           // faded | washed | stopped | never
    "days": 21,                 // umur dasar dalam HARI NYATA
    "accel": {"rain": 3.0}      // cuaca yang mempercepat (opsional)
  }
}
```

**Empat mode:**

| mode | Rumus | Untuk |
|---|---|---|
| `faded` | hari berlalu; `sunny` × 1.5 | `akibat` |
| `washed` | hari berlalu; `rain` × 3.0 — **hujan mempercepat drastis** | `kebiasaan` |
| `stopped` | hari berlalu, tanpa akselerasi | `orang` |
| `never` | tak pernah | `benda` — **wajib untuk semua `benda`** |

**Umur dihitung dari `first_seen`**, bukan dari `found`.

> ⚠ **Ini keputusan penting.** Kalau umur dihitung dari saat pemain **menemukan**
> bukti, maka pemain yang tidak peduli **tidak pernah kehilangan apa-apa** — jamnya
> tak pernah mulai.
>
> Yang benar: **jam mulai saat halaman dicoret.** Dunia mulai melupakan saat itu,
> bukan saat pemain memperhatikan.
>
> **Pemain yang lambat kehilangan bekas yang tak pernah ia lihat. Dan ia tidak akan
> pernah tahu apa yang ia lewatkan.** *(Persis A1.)*

---

# 4. API — `Evidence.gd` (R2 diperluas)

```gdscript
## Bekas yang sudah membusuk. id -> {decayed_at}
var decayed: Dictionary = {}

## Kapan jam mulai untuk tiap halaman. page_id -> unix
## Dipasang oleh Chronicle.strike() — dunia mulai melupakan saat halaman dicoret.
var _clock_start: Dictionary = {}

## Dipanggil saat halaman dicoret. Jam pembusukan mulai di sini.
func start_decay_clock(page_id: String) -> void:
    if not _clock_start.has(page_id):
        _clock_start[page_id] = GameClock.unix_now()

## Sudahkah bekas ini membusuk?
## PENTING: dievaluasi MALAS (saat ditanya), bukan lewat timer.
## Pola sama dengan pertumbuhan tanaman offline (Homestead) — terbukti.
func is_decayed(evidence_id: String) -> bool:
    if decayed.has(evidence_id):
        return true
    var def: Dictionary = Db.evidence.get(evidence_id, {})
    var d: Dictionary = def.get("decay", {})
    var mode: String = d.get("mode", "never")
    if mode == "never":
        return false
    var start: int = _clock_start.get(def.get("page", ""), 0)
    if start == 0:
        return false                      # halaman belum dicoret — belum ada jam
    var elapsed_days := float(GameClock.unix_now() - start) / 86400.0
    if elapsed_days >= _effective_days(d):
        decayed[evidence_id] = {"decayed_at": GameClock.date_string()}
        return true
    return false
```

> ### ⛔ HUKUM D-3 — DIKODEKAN
> `is_decayed()` **DILARANG** memanggil `Stage.banner` · `EventBus.toast` ·
> `Audio.play_stinger` · `Cutscene.play`.
>
> **Bekas menghilang tanpa suara.** Pemain kembali ke bangku itu, dan tanahnya rata.
> **Itu saja.** Tidak ada yang memberitahunya bahwa ia baru saja kehilangan Otha
> selamanya.
>
> **Test wajib:** `_test_decay_is_silent()` — pola sama dengan
> `_test_strike_is_silent()`.

## Perubahan pada fungsi R2 yang sudah ada

```gdscript
## Bekas yang membusuk TIDAK BISA ditemukan lagi.
func find(evidence_id: String) -> String:
    if is_decayed(evidence_id):
        return ""            # DIAM. Pemain memeriksa, dan tidak ada apa-apa.
    ...

## Bekas yang sudah ditemukan TETAP SAH meski dunia melupakannya.
func for_page(page_id: String) -> Array:
    # Bukti yang SUDAH pemain temukan tidak hilang dari tangannya.
    # Yang membusuk adalah kesempatan MENEMUKANNYA.
    ...
```

> ### ⚠ KEPUTUSAN DESAIN — bukti yang sudah ditemukan TIDAK hilang
>
> **Kenapa:** kalau bukti di tangan pemain bisa menguap, itu **kejam-berpenulis**
> — dunia mencuri dari pemain. Dan pemain akan belajar menimbun-lalu-panik.
>
> **Yang membusuk adalah KESEMPATAN, bukan HASIL.**
>
> Pemain yang memperhatikan menyimpan apa yang ia lihat. Pemain yang tidak
> memperhatikan kehilangan sesuatu yang **tak pernah ia lihat** — dan tidak akan
> pernah tahu apa.
>
> **Itu #229 kejam-cuaca. Yang pertama adalah hukuman; yang kedua adalah hidup.**

---

# 5. ⛔ D-4 — DIKODEKAN

**DILARANG ADA, selamanya:**
- `days_remaining()` · `decay_progress()` · `time_left()` · `urgency()`
- Ikon jam · warna memudar di UI · *"bukti ini akan hilang!"*
- Sortir bukti berdasarkan sisa waktu

**Alasan:** timer mengubah perhatian jadi **manajemen**. Pemain berhenti melihat dunia
dan mulai mengelola antrean.

Dan angkanya bohong: **kita tak tahu berapa bekas yang ADA di dunia**, cuma berapa
yang kita tulis di data.

**Test wajib:** `_test_no_decay_timer()` — sisir `Evidence.gd` + UI.

---

# 6. YANG BERUBAH DI DUNIA — tanpa satu kata pun

**Ini bagian level design, dan ini yang membuat R3 terasa.**

| Bekas | Sebelum busuk | Sesudah busuk |
|---|---|---|
| **Bangku Otha** | 4 cekungan dalam di tanah | **tanah rata.** Bangkunya masih ada. Kosong. |
| **Papan bekas cat** | persegi panjang lebih gelap | **kayu polos.** Pudar rata. Tak ada bekas apa pun. |
| **Nyai Tuminah** | tiap Kamis sore berjalan ke jalan utama, berdiri, pulang | **ia tidak datang.** Jalan utama kosong tiap Kamis. |
| **Cangkir kedua Merrit** | dua cangkir di meja pagi | *(tidak membusuk — Merrit masih hidup)* |
| **Lonceng gereja** | tulisan hampir aus | *(`benda` — abadi)* |

**Nyai yang berhenti berjalan tidak perlu sistem umur.** Ia cuma dihapus dari
`NpcSchedule` untuk hari Kamis. Mesinnya sudah ada (#216).

Kalau pemain bertanya padanya — **ia masih di rumahnya.** Ia ramah. Ia menawarkan teh.

**Ia cuma tidak berjalan ke sana lagi.** Dan kalau ditanya kenapa:

> *"Kaki tua. Sudah tidak kuat."*

**Ia tidak tahu ia baru saja menghapus seseorang.**

---

# 7. "KESAKSIAN HUJAN" — jalur C pertama, sekarang mungkin **[#227]**

R3 membuka jalur C yang sudah diratifikasi:

```
hujan × malam × Merrit hidup × pemain pernah menginap × sebuah nama sedang dihapus
```

**Dengan R3, "sedang dihapus" punya arti mekanis:** ada bekas yang **membusuk malam
itu juga.**

> Hujan. Malam. Pemain di rumah singgah.
> Dan di luar, cekungan bangku Otha sedang rata oleh air.
>
> Merrit mulai bicara tentang seseorang — dan berhenti di tengah kalimat.
> *"Ah. Sudah tua."*
>
> **Jendela pendek untuk bertanya. Diam = hilang selamanya.**

**Dan `washed` × `rain` = 3.0 berarti hujan benar-benar mempercepatnya.**
Pemain yang berteduh di dalam sambil hujan turun sedang **kehilangan sesuatu di luar.**

*Ia tidak akan pernah tahu.*

---

# 8. UMUR — **DIUJI, bukan ditebak**

> ⚠ **Angka pertama saya SALAH, dan simulasi menangkapnya.** Draft awal (papan 40,
> bangku 21, nyai 28) menghasilkan dua cacat:
> 1. **Tebing, bukan peluruhan** — semua jalur mati bersamaan antara hari 27–30.
> 2. **Hujan tidak berpengaruh pada keputusan** — jendela kering & hujan sama-sama
>    ~26 hari. **"Kesaksian Hujan" (#227) jadi hiasan, bukan mekanik.**
>
> Angka di bawah sudah disimulasikan.

| Bekas | mode | hari | akselerasi | Mati di hari |
|---|---|---|---|---|
| `ev_otha_nyai_tuminah_kamis` | `stopped` | **21** | — | **21** — pertama |
| `ev_otha_bangku_cekungan` | `washed` | **30** | rain ×**5.0** | **30** kering / **6** hujan |
| `ev_otha_papan_bekas_cat` | `faded` | **60** | sunny ×1.5 | **60** / 40 terik |
| `ev_otha_jahitan_mantel_merrit` | `never` | — | — | tak pernah |
| `ev_merrit_*` | `never`/lambat | — | — | **Merrit masih hidup** |
| `ev_ashbrook_lonceng_gereja` | `never` | — | — | `benda` |
| `ev_ashbrook_halloran_200_roti` | `never` | — | — | ⚠ lihat catatan |

## Hasil simulasi — dan ini yang membuat A3 bekerja

**Bekas mati satu-satu, bukan bersamaan:**

```
KERING:  hari 21 → Nyai berhenti berjalan   (tersisa 3 jenis)
         hari 30 → cekungan bangku rata      (tersisa 2)
         hari 60 → bekas cat pudar habis     (tersisa: benda saja)

HUJAN:   hari  6 → cekungan bangku rata      ← 5× lebih cepat
         hari 21 → Nyai berhenti berjalan
         hari 60 → bekas cat pudar habis
```

**Jendela keputusan:**

| Juru tulis | Kering | Hujan | Selisih |
|---|---|---|---|
| **Sendiri** (butuh 3 jenis) | **29 hari** | **20 hari** | **−9 hari** |
| Elyn (2 jenis) | 59 hari | 59 hari | 0 |
| Sora (2 jenis) | 59 hari | 59 hari | 0 |

> ### Dan ini temuan terbaik dari simulasi:
>
> **Hujan hanya menghukum pemain yang menulis SENDIRIAN.**
>
> Pemain dengan Elyn tidak terpengaruh — ia butuh 2 jenis, dan selalu ada 2.
> Pemain sendirian butuh 3, dan hujan mencuri jenis ketiganya sembilan hari lebih awal.
>
> **Itu bukan bug. Itu #228 yang jujur:** jalan sendirian **boleh lebih mahal**.
> Ia tidak boleh mustahil — dan hari ke-0 ia selalu mungkin (diuji: LOLOS).
>
> **Pemain sendirian yang berteduh dari hujan sedang kehilangan sembilan hari,
> dan tidak ada yang memberitahunya.**

## Uji yang lolos

| Uji | Hasil |
|---|---|
| **#228** — hari-0 setiap halaman bisa dipulihkan sendirian | ✅ 4 jenis tersedia |
| **#226** — `benda` abadi (999 hari + hujan terus) | ✅ bertahan |
| **#226** — tapi `benda` sendirian tak pernah cukup | ✅ self:TIDAK elyn:TIDAK |
| **Peluruhan bertahap**, bukan tebing | ✅ 21 → 30 → 60 |
| **Hujan mengubah keputusan** | ✅ −9 hari untuk jalur sendiri |

> ⚠ **Halloran tidak membusuk** — ia memanggang 200 roti tiap pagi dan akan terus
> begitu. **Kebiasaan yang masih hidup bukan bekas yang membusuk.**
>
> **Aturan:** `kebiasaan` membusuk hanya bila **orangnya sudah tidak melakukannya
> lagi**. Bekas Otha membusuk karena Otha sudah mati. Bekas Halloran tidak, karena
> Halloran masih memanggang.

**Konsekuensi untuk A3:** halaman Ashbrook-besar **tidak pernah mendesak**.
Halaman Otha mendesak. Halaman Merrit tidak.

**Itulah TRIASE-nya, dan ia lahir dari fisika, bukan dari aturan.**

---

# 9. URUTAN BANGUN

| Tahap | Isi |
|---|---|
| **R3a** | field `decay` di `evidence.json` · `is_decayed()` · `start_decay_clock()` · `find()` menolak yang busuk |
| **R3b** | `Chronicle.strike()` memanggil `start_decay_clock()` |
| **R3c** | Test: diam (D-3) · tanpa timer (D-4) · `benda` tak pernah busuk · #228 tetap lolos **setelah** pembusukan |
| **R3d** | Dunia berubah: sprite bangku (2 varian) · papan (3 varian: bertulisan/bekas/polos) · `NpcSchedule` Nyai Kamis dihapus |
| **R3e** | Save/load `decayed` + `_clock_start` |

## ⚠ Test paling penting: #228 SETELAH pembusukan

```gdscript
func _test_decay_never_locks_solo() -> void:
    # Setelah SEMUA bekas yang bisa busuk membusuk, apakah masih ada
    # halaman yang bisa dipulihkan pemain sendirian?
    #
    # JAWABAN YANG DIHARAPKAN: TIDAK untuk halaman Otha — dan itu BENAR.
    # Otha memang bisa hilang selamanya. Itu adegannya.
    #
    # TAPI: pemain harus punya CUKUP WAKTU sebelum busuk.
    # Yang diuji: pada hari ke-0 (halaman baru dicoret), setiap halaman
    # HARUS bisa dipulihkan sendirian. Kalau tidak — #228 mati sejak lahir.
```

> **#228 tidak menjanjikan pemain selalu berhasil. Ia menjanjikan pemain
> selalu PUNYA KESEMPATAN.**
>
> Kehilangan Otha karena terlambat = sah.
> Kehilangan Otha karena tak pernah mungkin = **hukum mati.**

---

# 10. YANG TIDAK DIBANGUN (sengaja)

❌ Sistem umur NPC — **tidak ada, dan R3 tidak membutuhkannya**
❌ Notifikasi apa pun (D-3)
❌ Timer/progress (D-4)
❌ Bukti di tangan pemain menguap — **tidak akan pernah**
❌ Pembusukan `benda` — melanggar #226

---

> ## SATU KALIMAT UNTUK PENULIS BERIKUTNYA
>
> Godaan terbesar di sistem ini adalah **memberi peringatan.** Satu ikon jam.
> Satu warna memudar. Satu baris *"cepat, sebelum hilang!"*
>
> **Tolak.**
>
> Seluruh maksud R3 adalah bahwa **dunia tidak memberitahumu apa yang sedang
> kaukehilangan.** Bangku itu rata pagi ini, dan tak seorang pun berkata apa-apa,
> dan Otha Renn hilang selamanya.
>
> **Persis seperti dunia sungguhan.**
