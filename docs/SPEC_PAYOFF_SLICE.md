# SPEC EKSEKUSI — VERTICAL SLICE "PAYOFF PERTAMA"

**Ditulis:** 2026-07-19 · **Oleh:** Designer · **Untuk:** agen eksekusi @ `D:\2DGAME`
**Status:** spec build — bukan usul. Baris ledger #256–261 diratifikasi (lihat §2).
**Aturan dokumen:** tiap item build menyebut `path:baris`. Yang belum ada ditandai **BARU**.
**Kepatuhan:** slice ini WAJIB lolos D-1…D-6 dan silence law #226. Pelanggaran = gagal.

---

## 0 — TUJUAN SLICE

Di Ashbrook 16px (scene yang **dimainkan**, bukan 64px), pemain harus bisa menjalani rantai penuh:

> masuk kota → halaman Ashbrook sudah tercoret (senyap) → periksa 6 objek, kumpulkan 3 jenis bukti → buka Kitab → lihat halaman tercoret → tulis ulang **lewat pilihan sadar**: simpan sendiri atau limpahkan ke Elyn → tempat & lentera Merrit menyala → **satu baris tetap tercoret**: *"Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus orang."*

Kehilangan yang tersisa itulah seluruh permainannya.

---

## 1 — KOREKSI DESAIN YANG MENGIKAT (baca dulu)

**K-1 — Tidak ada KIND_PLACE, dan itu benar.** Ashbrook lahir lewat `record_person` (`Chronicle.gd`, hanya KIND_DEED & KIND_PERSON ada). Ashbrook dicatat bukan sebagai *tempat* tapi sebagai *orang yang mengingatnya* (Merrit). Ini menegakkan #226, bukan menyiasati kekurangan mesin.

**K-2 — Loss "orang" adalah fitur, bukan cacat.** 3 jenis (akibat·benda·kebiasaan) tersedia di 6 titik-periksa; `self` butuh 3 jenis (`Chronicle.gd:49-53`). Restore SENDIRI sudah bisa tanpa jenis orang. Karena orang tak ter-wire di Ashbrook, `_compute_loss()` (`Chronicle.gd:197-223`) selalu mengembalikan baris "orang" dari `chronicle_losses.json → place_ashbrook_besar → loss_by_missing_kind → orang`. **JANGAN wire person-evidence di Ashbrook pada slice ini.** Variasi #226#3 adalah urusan halaman lain di ronde berikutnya.

**K-3 — Kapasitas ingatan tak pernah berangka (D-4).** `Chronicle.gd:229-248` + `Evidence.gd:154-168` melarang `found_count`/progress/persen selamanya, dijaga `_test_no_chronicle_score()` + `_test_no_evidence_score()`. Sistem ruang-ingatan (§4.D) BOLEH menyimpan kapasitas internal, tapi UI DILARANG menampilkan hitungan/meter/persen. Batas ditemui sebagai **penolakan**, bukan dibaca sebagai **angka**.

**K-4 — Strike wajib senyap (#226).** `Chronicle.gd:120-127` melarang `Stage.banner`/`EventBus.toast`/`Audio.play_stinger`/`Cutscene.play` saat strike. Halaman tercoret sebelum pemain tiba, tanpa umpan balik. Pemain *menemukan* coretan di Kitab, tidak diberitahu.

**K-5 — Halaman lahir dari yang "repot" (#230).** `record_person` bersemantik "tak pernah otomatis: seseorang harus repot" (`Chronicle.gd:73-75`). Halaman lahir atas nama **Merrit** — penjaga lentera yang menolak Ashbrook terlupa. Bukan dipanggil saat pemain masuk sebagai efek samping; dipanggil sebagai tindakan Merrit dalam inisialisasi dunia, dengan `by:"merrit_fane"`.

---

## 2 — BARIS LEDGER (ratifikasi — tulis ke PLAN_LEDGER)

Salin verbatim. Ini meratifikasi kanon-de-facto yang sudah di kode + keputusan Direktur P1.

```
#256 — HUKUM INGATAN TERBATAS. Ingatan adalah ruang terbatas. Pemain dan Elyn
       masing-masing punya ruang. Menyimpan halaman mengisi ruang salah satunya.

#257 — KAPASITAS TAK BERANGKA (tunduk D-4). Kapasitas ingatan ada di state,
       tapi tak pernah ditampilkan sebagai hitungan/meter/persen. Batas ditemui
       sebagai penolakan ("kamu tak sanggup memikul lebih"), bukan dibaca angka.

#258 — HARGA ELYN (a+b; menyerap CHRONICLE_RESTORATION_SPEC:262). Melimpahkan
       halaman ke Elyn membebaskan ruang pemain, mengisi ruang Elyn, mempercepat
       lupa Elyn (umur berkurang), dan mewariskan beban ke keturunannya. Satu
       sistem ruang-ingatan, dua pemilik.

#259 — HUKUM KETERBUKAAN. Ongkos limpahan ke Elyn WAJIB diberitahu ke pemain
       sebelum dipilih. Nol jebakan. Keputusan sadar, bukan kejutan.

#260 — BARIS TAK-TERPULIHKAN. Tiap halaman punya satu `loss` permanen, identik
       di kedua jalur restore. Restore tak pernah lengkap (aturan keras #3).

#261 — ASAL-USUL HALAMAN. Halaman lahir dari NPC yang "repot" (#230), tak pernah
       otomatis sebagai efek samping. Ashbrook lahir dari Merrit (penjaga lentera).
```

Plus ketuk empat yang menggantung: **#226 · #228 · #229 · #231** (draf ada di sesi sebelumnya).

### ⚖ AMANDEMEN KANON — #267 (Direktur, 2026-07-20)

Diratifikasi setelah rekonsiliasi B18 (`reports/REKONSILIASI_B18.md` K2) menemukan #258
menabrak sheet #002. **Direktur memilih mengubah sheet, bukan mencabut #258.**

```
#267 — OVERRIDE #002 (Direktur, sadar). Elyn MENUA dan BERKETURUNAN.
       Ongkos limpahan #258 = tahun elf yang dibelanjakan + beban yang
       diwariskan ke keturunannya.
       MEMBATALKAN: companion_02 AGING PATH "tak menua di depan pemain"
       (teksnya DIPERTAHANKAN, DIREINTERPRETASI — ia tetap melampaui umur
       biasa, tapi penuaannya kini TERLIHAT dan tahunnya bisa dibelanjakan)
       dan LEGACY PATH yang nol-keturunan.
       KODE DIVALIDASI, TIDAK DIUBAH: PlayerData.elyn_age_spent ·
       Chronicle.ELYN_YEARS_PER_PAGE · teks keterbukaan Kitab §4.G
       (LANGKAH 6-7). Yang dulu menyalahi sheet kini berjangkar kanon.
```

**Tiga hal yang #267 TIDAK putuskan — dan tak boleh ditebak siapa pun:**

1. **Identitas garis keturunan.** Verifikasi Wren sudah dijalankan:
   **garis BARU, jangan realokasi** (`reports/VERIFIKASI_WREN.md`). Wren manusia, pembaca
   perpustakaan; tiga keturunan di `RELASI PENTING` adalah keturunan **Wren**; dan
   **kartu pinjam Wren sudah jadi bukti `benda` kanon** di `R1_SPEC_TEKNIS:54`,
   `CHRONICLE_RESTORATION_SPEC:114`, `CANON_219-230_FINAL:184` — memindahkannya mengubah
   apa yang bukti itu buktikan. Nama/ras/asal garis = sesi penulisan Designer.
2. **Laju tahun per halaman.** Ambang elf **menua = 301** (`TIME_LEGACY_SPEC:66`); Elyn **134**.
   Jarak **167 tahun**. `ELYN_YEARS_PER_PAGE = 1` **tak akan pernah** menyeberanginya dalam
   satu permainan — jadi "penuaan terlihat" butuh laju baru, atau definisi ulang
   ("terlihat" = menyeberang ambang, bukan hitungan tahun).
3. **Darah vs murid.** `TIME_LEGACY_SPEC:199-200` menyarankan elf mewariskan **lewat MURID,
   bukan anak** *("memperkuat L14 — kesempatan, bukan darah")*. Belum diratifikasi, tapi
   #267 bergerak berlawanan arah. Menyentuh Sora sebagai warisan-yang-berjalan.

✅ **Status K1 — SUDAH DIBERESKAN (2026-07-20).** `TIME_LEGACY_SPEC:13-15` mencatat K1=c
sebagai **#154 yang menutup #123**; `IMPLEMENTATION_ROADBOOK` masih memakai rujukan basi di
tiga tempat (kepala berkas, baris World history ledger, dan kepala v0.9). **Ketiganya
dikoreksi** — skala waktu **bukan lagi penghalang**; yang menahan v0.9 adalah pekerjaan
sistemnya, bukan keputusan owner yang belum ada.

✅ **Laju tahun — DIPUTUS (2026-07-20).** `ELYN_YEARS_PER_PAGE` **1 → 10**, dan penuaan
diubah jadi **model AMBANG**: tahun menumpuk diam-diam di `elyn_age_spent`; yang **terlihat**
(potret/dialog) hanya berubah saat Elyn **menyeberangi ambang tahap hidup**.
`EventBus.elyn_stage_changed(stage)` dipancarkan **hanya saat menyeberang** — itulah kailnya.
Ambang: `prima` → `prima_akhir` (250, **tuning**) → `menua` (**301, KANON**) → `sepuh` (**501, KANON**).
Pelimpah-berat (~17 halaman) menyeberang ke `menua`; pelimpah-ringan (~5) tidak.
**Umur tak pernah tampil sebagai angka** (D-4) — `PlayerData` sengaja tak menyediakan
pengaksesnya; hanya `elyn_stage()` yang mengembalikan nama tahap.

### ⚖ #268 — AMBANG KETERBACAAN ELYN (Direktur, 2026-07-20)

Diratifikasi menjawab pertanyaan yang #267 tinggalkan terbuka: apa status `prima_akhir`.

```
#268 — AMBANG KETERBACAAN ELYN (mekanik, bukan biologi). prima_akhir=250
       adalah ambang penuaan-terlihat khusus mekanik limpahan Elyn, supaya
       pelimpah menengah melihat satu perubahan sebelum lompatan kanon 301.
       BUKAN tahap tabel §2 TIME_LEGACY (dewasa/prima/menua/sepuh berlaku semua
       elf). Angka playtest-tunable.
```

**Garis yang #268 tarik, dan kenapa ia penting:** tabel §2 `TIME_LEGACY_SPEC` menjelaskan
**bagaimana elf menua** — ia berlaku untuk setiap elf di dunia. `prima_akhir` menjelaskan
**kapan pemain melihat akibat perbuatannya** — ia hanya ada di jalur limpahan Elyn.
Dua benda berbeda yang kebetulan memakai satuan yang sama. Menyatukannya akan membuat
seluruh ras elf punya tahap hidup yang lahir dari satu mekanik UI.

**Konsekuensi mengikat:**
- `prima_akhir` **tak boleh** muncul di tabel §2, di CharGen, atau pada elf mana pun selain Elyn.
- 301 dan 501 tetap **kanon biologis**; 250 tetap **angka mekanik**, bebas disetel playtest.
- Kalau kelak elf lain memakai mekanik limpahan yang sama, ambang ini ikut — **karena
  mekaniknya**, bukan karena biologinya.

### ⚖ #269 — EKSTRAKSI THREE DEATHS (Direktur, 2026-07-20)

Lahir dari `reports/TARIKAN_FINAL_SPINE_V03.md` §1: model tiga-kematian terkubur di arsip
LOCKED, sementara penyederhanaan dua-kematian sudah menyebar dan dua dokumen memakainya salah.

```
#269 — EKSTRAKSI THREE DEATHS (dari arsip LOCKED ke kanon, pola #194/#211).
       D1 biologis · D2 sosial/dilupakan · D3 tak-pernah-tercatat ("kematian
       terbesar"). Menjangkarkan R1: strike()=D2, #229.3=D3. Otha Renn=D3,
       Merrit=D2. Sapu lima dokumen yang salah pakai model dua-kematian.
```

**Kanon terbaca:** `docs/THREE_DEATHS.md` — verbatim `…design.txt:9847-9894`, plus jangkar
kode dan daftar yang belum diputuskan.

**Aturan istilah sejak #269:** *"Second Death"* tetap sah sebagai **istilah dalam-dunia untuk
D2**. Untuk D3 pakai **"kematian ketiga"** / *Historical Death*. **Jangan** pakai "kematian
kedua" untuk peristiwa tak-pernah-tercatat.

⚠ **Tiga hal #269 TIDAK putuskan:** apakah D3 bisa dilawan sama sekali (menulis yang belum
pernah tercatat = mengalahkan D3, atau menundanya?) · apakah *"kematian kedua = final mutlak"*
(`ROADBOOK:207`, hukum revive) bertabrakan dengan `restore()` yang memulihkan halaman D2 ·
dan apakah mesin perlu membedakan D2/D3 (`THREE_DEATHS.md` §6 — **kode tidak diubah**).

---

## 3 — PETA MESIN YANG SUDAH ADA (jangan bangun ganda)

| Kebutuhan | Sudah ada di | Status |
|---|---|---|
| Struktur halaman (id·title·kind·R1) | `Chronicle.gd:79-97` | pakai apa adanya |
| `record_person(id, title)` | `Chronicle.gd` | pakai untuk lahirkan Ashbrook |
| `strike(id, cause)` | `Chronicle.gd:128-138` | pakai; hanya cocokkan entri ada |
| `restore(id, scribe)` | `Chronicle.gd:157-175` | pakai; tolak `need_%d_kinds` |
| Ambang jenis per juru tulis | `Chronicle.gd:49-53` (self=3·elyn=2·sora=2) | pakai apa adanya |
| `_compute_loss()` | `Chronicle.gd:197-223` | pakai; hasilkan loss "orang" |
| Data loss Ashbrook | `chronicle_losses.json` | sudah berisi baris final |
| Dispatch bukti | `Interactable.gd:172` (`_examine_point`) | pakai untuk wire |
| `struck_entries()` / `readable_entries()` | `Chronicle.gd:268,279` | pakai untuk UI Kitab |
| Sinyal `chronicle_struck`/`chronicle_restored` | `Chronicle.gd` | pakai untuk refresh UI |
| Beacon & lentera Merrit | `:422-433, :505-517` (17:00–06:00 WIB) | sudah hidup; jadi payoff |

Yang **BARU** (harus dibangun): field ruang-ingatan di `PlayerData`, ruang Elyn, tab UI Kitab, teks dialog/prompt.

---

## 4 — ITEM BUILD

### A. Lahirkan halaman (satu tindakan Merrit)

Di inisialisasi dunia (bukan `_ready` scene Ashbrook — di lapisan world-state yang jalan sekali per save), atas nama Merrit:

```gdscript
Chronicle.record_person("place_ashbrook_besar", "Ashbrook — kota yang dulu besar")
# by:"merrit_fane" — Merrit yang menulis. #230/#261.
```

Prasyarat nol; `_write` hanya menolak bila `has(id)` (idempoten aman). Verifikasi `by` terekam sebagai `merrit_fane`, bukan sistem.

### B. Strike senyap (#226 / K-4)

Setelah halaman lahir, coret oleh waktu — sebelum pemain tiba, tanpa umpan balik:

```gdscript
Chronicle.strike("place_ashbrook_besar", "waktu")   # struck_cause disimpan, TAK ditampilkan (#229.4)
```

DILARANG memanggil banner/toast/stinger/cutscene di jalur ini. Uji dengan grep: nol pemanggil feedback di sekitar strike ini.

### C. Wiring 3 bukti (jenis sudah cukup — nol person)

6 titik-periksa Ashbrook sudah menghasilkan akibat·benda·kebiasaan lewat `Interactable.gd:172`. Konfirmasi ketiga jenis benar-benar terjangkau pemain di scene 16px. Bila salah satu jenis belum terpasang di titik-periksa nyata, pasang dengan satu baris:

```gdscript
_examine_point(Vector2(x, y), "ev_<id>")   # found_by TAK dibaca kode — cukup id + kind benar
```

**Tak ada** person-evidence di Ashbrook (K-2). Jangan pasang `arlen_ingat` (butuh Arlen yang tak ada di scene, `requires_npc` dibaca kode).

### D. Sistem ruang-ingatan (BARU — #256/#257)

**D.1 Field pemain** — `PlayerData.gd`. Ikuti preseden reputasi (`:65-69`) yang me-reserve slot sebelum dipakai, dan naikkan `SAVE_SCHEMA` → 2 (`:3, :6`), migrasi terbukti sekali.

```gdscript
# BARU — ruang ingatan pemain. Kapasitas internal; UI DILARANG menampilkan angka (D-4/#257).
var memory_held: Array = []        # id halaman yang pemain simpan sendiri
const MEMORY_CAP: int = 3          # awal — nilai untuk diuji playtest, bukan final
func memory_full() -> bool: return memory_held.size() >= MEMORY_CAP
```

Tambah keduanya ke `to_save()` (`:695-715`) + jalur muat, dengan default kosong untuk save lama.

**D.2 Ruang Elyn** — karena Elyn nol di kode, slice ini memakai representasi minimal di `PlayerData` (companion belum jadi autoload). Cukup untuk mekanik #258; sistem Aging penuh (TIME_LEGACY_SPEC) ronde berikutnya.

```gdscript
# BARU — beban Elyn. Justifikasi kanon: companion_02:78
# "Umur panjang bagi Elyn... ruang yang lebih besar untuk lupa."
var elyn_burden: Array = []        # id halaman yang dilimpahkan
var elyn_age_spent: int = 0        # tahun umur tergerus; tiap limpahan menambah
# keturunan mewarisi beban: dicatat sebagai hook Legacy, tak disimulasikan penuh di slice ini
```

**D.3 Aturan**: menyimpan halaman mengisi salah satu ruang. Bila `memory_full()` dan pemain memilih SENDIRI → tolak (§4.G teks penolakan). Limpah ke Elyn tak pernah "penuh" di slice ini, tapi tiap limpahan menambah `elyn_age_spent` dan memunculkan keterbukaan (#259).

### E. Jalur restore (dua pilihan, memakai ambang yang sudah ada)

- **SENDIRI (#228)** — `restore("place_ashbrook_besar", "self")`. Butuh 3 jenis (`self=3`). Sudah terjangkau. Mengisi `memory_held`. Bila `memory_full()` → blokir sebelum memanggil restore, tampilkan penolakan.
- **ELYN (R5)** — `restore("place_ashbrook_besar", "elyn")`. Butuh 2 jenis (`elyn=2`) — Elyn arsiparis, lebih ringan syaratnya. Mengisi `elyn_burden`, menambah `elyn_age_spent`. WAJIB lewat prompt keterbukaan dulu (#259).

Kedua jalur → `restored` → `_compute_loss()` → loss "orang" → beacon/lentera Merrit yang sudah menyala kini bermakna. Baris tak-terpulihkan tampil di halaman.

### F. UI Kitab (satu-satunya pekerjaan berukuran layar)

Tab **"Kitab"** BARU di `MenuUI.gd:80` (terpisah dari `pedia`/#96). JANGAN memodifikasi `_build_pedia()` (`:538-546`).

- **Sumber data**: `struck_entries()` (`:268`) untuk daftar tercoret; `readable_entries()` (`:279`) untuk yang sudah ditulis/pulih. Keduanya mengembalikan field siap-tampil: `title·date·time·season·by·level·state·restored_at·scribe·witnesses·loss`.
- **Halaman tercoret**: judul dengan coretan visual (R1), tanpa `struck_cause` (#229.4). Tombol "Tulis ulang" muncul hanya bila bukti cukup untuk ≥1 jalur.
- **Prompt pilih jalur**: saat "Tulis ulang" ditekan → tawarkan SENDIRI vs LIMPAH KE ELYN. Untuk ELYN, tampilkan keterbukaan (#259) SEBELUM konfirmasi.
- **Halaman pulih**: tampilkan `loss` menonjol — baris tak-terpulihkan adalah fokus visual, bukan catatan kaki. Tandai "dipulihkan dari kesaksian", bukan "dipulihkan" (aturan keras #3).
- **DILARANG (D-4)**: nol hitungan bukti, nol "3/5", nol progress bar, nol persen. Kapasitas terasa hanya lewat penolakan saat penuh.

### G. Teks persis (ID; siapkan slot EN)

**Prompt keterbukaan Elyn** (muncul sebelum konfirmasi limpah — #259):
> Elyn akan menulis ini untukmu. Ingatan itu akan menempati ruangnya, bukan ruangmu.
> Umurnya berkurang tiap kali ia menolak lupa. Dan ruang yang penuh diwariskan —
> keturunannya memikul apa yang tak sanggup kaubawa sendiri.
> **[ Biarkan Elyn menanggung ]   [ Simpan sendiri ]**

**Dialog Elyn saat pertama dilimpahi**:
> "Aku sudah melihat empat generasi manusia pergi. Satu ingatan lagi bukan beban baru —
> hanya ruang yang lebih sempit untuk lupa. Berikan. Aku akan mengingatnya selama aku bisa."

**Penolakan saat ruang pemain penuh** (SENDIRI, `memory_full()` — #257, tanpa angka):
> Kamu tak sanggup memikul lebih banyak masa lalu. Lepaskan sesuatu yang kausimpan,
> atau biarkan Elyn yang menanggung ini.

**Baris tak-terpulihkan** (dari `chronicle_losses.json`, tampil di halaman pulih):
> Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus orang.

---

## 5 — URUTAN EKSEKUTOR

1. Tulis baris ledger #256–261 + ketuk #226/#228/#229/#231.
2. §4.A lahirkan halaman (Merrit) + §4.B strike senyap. Verifikasi via harness: halaman ada, state `struck`, `by:merrit_fane`, nol feedback.
3. §4.C konfirmasi/pasang 3 jenis bukti terjangkau di 16px.
4. §4.D ruang-ingatan pemain + Elyn, `SAVE_SCHEMA`→2, migrasi save lama.
5. §4.E jalur restore SENDIRI + ELYN memakai ambang yang ada.
6. §4.F UI Kitab (tab baru) + §4.G teks.
7. Verifikasi rantai penuh (§6). Commit per langkah, bukan satu commit besar.

---

## 6 — VERIFIKASI (harness, bukan menambah hitungan gerbang)

Perluas pola `VerifyLoop64.gd` untuk scene **16px**. Harness membuktikan, tanpa melanggar D-4 (harness boleh membaca state internal; UI tidak):

- [1] halaman `place_ashbrook_besar` lahir, `by == "merrit_fane"`, state `struck`, nol feedback saat strike.
- [2] 3 jenis bukti terkumpul dari titik-periksa 16px nyata (akibat·benda·kebiasaan).
- [3a] restore SENDIRI sukses (3 jenis), `memory_held` bertambah, loss == baris "orang".
- [3b] restore ELYN sukses (2 jenis), `elyn_burden` + `elyn_age_spent` bertambah, keterbukaan terpicu.
- [4] `memory_full()` → SENDIRI ditolak, penolakan tampil, ELYN tetap tersedia.
- [5] halaman pulih menandai "dipulihkan dari kesaksian", baris tak-terpulihkan hadir.
- [6] beacon/lentera Merrit menyala pada jendela WIB yang benar.
- [D-4] `_test_no_chronicle_score()` + `_test_no_evidence_score()` tetap lulus; grep UI Kitab nol angka progress.

**Definisi selesai slice:** rantai §0 dijalankan penuh, keenam cek harness hijau, D-1…D-6 utuh — lalu **satu playtest manusia** (tutup lubang v0.4.2–v0.4.4). Baru setelah itu migrasi visual boleh lanjut.
