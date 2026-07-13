# NPC DEPTH PIPELINE — kedalaman sebagai DATA yang dipanggang

> **Status: RESMI** (Decision Log #162). Target eksekusi pertama: **v0.5**.
> **Hukum induk (#163):** *Kedalaman NPC Aetherion lahir dari **PENULISAN yang diperbanyak
> mesin**, bukan dari **mesin yang menulis sendiri di rumah pemain**.*

## 0. Apa ini, dan apa yang BUKAN

| | |
|---|---|
| **INI** | Agent menulis kedalaman **saat pengembangan** → hasilnya **data JSON yang di-commit**, dibaca game secara deterministik, sama untuk semua pemain, gratis, offline, bisa dites. |
| **BUKAN** | Model bahasa berjalan **di dalam game** di komputer pemain. **DITOLAK untuk v1.0** (#161). |

**Konsekuensi yang harus selalu benar:** apa pun yang keluar dari pipeline ini **bisa dibaca
manusia, bisa direview, bisa di-diff, bisa di-test, dan bisa DIHAPUS bila salah.** Kalau
sebuah output tidak memenuhi keempatnya, ia belum siap di-commit.

---

## 1. GERBANG WAJIB — tak ada output yang lolos tanpa ketiganya

Setiap berkas hasil generate **harus** melewati, berurutan:

1. **KONSISTENSI KANON** — dicek terhadap `PLAN_LEDGER.md` + Bible terkait.
   Larangan keras: ❌ tidak boleh **mengonfirmasi** butir `docs/MISTERI_ABADI.md` (Hukum
   Wonder — boleh menambah isyarat & kesaksian yang **bertentangan**, tidak boleh menambah
   jawaban) · ❌ tidak boleh menjelaskan dunia lewat mulut NPC berkepribadian (Hukum NPC
   Aneh, #78: *mereka membuat dunia terasa dihuni, bukan menjelaskannya*) · ❌ tidak boleh
   menandai pemain sebagai terpilih (NO DESTINY).
2. **TEST RAHASIA PRODUKSI** — `_test_nirnama_secret` menyisir `res://data`,
   `res://translations`, `res://scenes`, `res://autoload`. **Ini gerbang paling keras**:
   teks generate adalah persis tempat sebuah nama rahasia bisa bocor tanpa ada yang sengaja
   menuliskannya. **Jalankan SEBELUM commit, bukan sesudah.**
3. **REVIEW MANUSIA** — Direktur/Designer. **Draft ≠ kanon.** Life Event chain khususnya
   masuk sebagai **usulan**, bukan sebagai fakta dunia.

---

## 2. TIGA KELUARAN

### (a) Pool dialog kontekstual — target v0.5

**Target Designer: 8–12 varian per NPC bernama per konteks utama, dwibahasa sejak lahir.**

⚠ **PERINGATAN SKALA — konteks TIDAK BOLEH berupa perkalian silang.**
Musim (4) × cuaca (4) × waktu (3) × reputasi (6) = **288 konteks**. Dikali 25 NPC bernama
× 10 varian × 2 bahasa = **144.000 baris**. Itu bukan pipeline; itu rawa.

**Bentuk yang benar — KONTEKS = daftar TAG kecil, baris diberi syarat opsional:**

| Konteks utama (8) | Contoh pemicu |
|---|---|
| `netral` | tak ada yang istimewa (selalu ada — jaring pengaman) |
| `musim` | musim aktif (4 varian tag: semi/panas/gugur/dingin) |
| `cuaca_keras` | hujan deras / badai / blizzard |
| `malam` | jam WIB malam / purnama |
| `bencana` | dark miracle aktif (#145) — warga **murung** |
| `keajaiban` | bright miracle baru terjadi |
| `reputasi_tinggi` | pemain dikenal di wilayah ini |
| `peristiwa_pemain` | first-clear, Roh Hutan murka, Chronicle baru |

→ **25 NPC × 8 konteks × 10 varian × 2 bahasa ≈ 4.000 baris.** Besar, tapi **manusiawi**:
bisa direview, bisa di-diff, bisa dihapus.

**Pemilihan baris saat runtime:** filter berdasarkan tag aktif → bobot → pilih **deterministik
per (npc_id, hari WIB)**, supaya seorang warga tidak berganti kepribadian tiap kali pemain
menutup-buka dialog. *(Pola ini sudah dipakai rumor & gosip.)*

### (b) Draft Life Event chain per tokoh — **DRAFT, BUKAN KANON**

Keluar sebagai `docs/drafts/LIFE_EVENTS_<tokoh>.md` untuk **kurasi Direktur+Designer**.
Wajib tunduk **L14–L18 (#137/#138)**:
- temperamen **tetap seumur hidup**; Big Five/trauma/moral/growth **hanya bergerak lewat
  PERISTIWA** — **tidak pernah lewat timer kosong**;
- **mayoritas NPC tetap biasa** (L18). Chain yang membuat semua orang jadi legenda = ditolak;
- **kesempatan dari PEMAIN** harus menjadi salah satu simpul chain (L14) — itulah Belonging.

### (c) Reaksi bencana/keajaiban & gosip yang makin kaya

Memperluas yang sudah hidup: `miracles.json` (`gossip_true` / `gossip_false`) dan
`rumors.json` (`truth` / `distortions`).
**Hukum yang tidak boleh dilanggar: gosip BOLEH SALAH** (E5/#77 — dan itu ada di **DAFTAR
DILINDUNGI**, #159). Pipeline yang "merapikan" gosip jadi akurat = **merusak**, bukan menambah.

---

## 3. ⚠ BUTIR KEPUTUSAN — di mana teks ini tinggal? (butuh Direktur)

**Fakta repo hari ini:** dialog NPC (`town_npcs.json` → `lines`) dan rumor (`rumors.json`)
adalah **string Bahasa Indonesia inline di data**, **bukan** `Loc.t("key")`. `translations/`
hanya berisi **107 key UI**. Jadi aturan CLAUDE.md *"teks baru lewat `Loc.t()`"* **selama ini
memang tidak berlaku untuk teks konten** — itu deviasi yang belum pernah dicatat.

Perintah "dwibahasa sejak lahir" memaksa persoalan ini keluar. Dua jalan:

| | **A — inline dwibahasa di data** *(rekomendasi saya)* | **B — semua ke `translations/`** |
|---|---|---|
| Bentuk | `{"id": "...", "en": "..."}` di dalam baris dialog | `Loc.t("npc.warno.musim.03")` |
| Untung | penulis melihat kalimat & terjemahannya **bersebelahan**; diff terbaca; satu berkas per NPC | satu tempat untuk semua teks |
| Rugi | dua bahasa dalam satu berkas data | **~4.000 key buatan** di `translations/`; konteks hilang; review nyaris mustahil |
| Konsisten dengan | `miracles.json`, `rumors.json`, `town_npcs.json` (semua sudah inline) | `Loc` (UI) |

**Usulan saya: A untuk KONTEN, `Loc` tetap untuk UI** — dan **dicatat sebagai deviasi sadar**
di CLAUDE.md, bukan dibiarkan jadi kebiasaan tak tertulis. **Belum dieksekusi — menunggu
keputusan Direktur.**

---

## 4. Yang dijaga oleh test (saat pipeline dijalankan)

- setiap NPC bernama punya **≥1 baris konteks `netral`** (jaring pengaman: tak ada NPC bisu);
- setiap baris dwibahasa **punya kedua bahasa** (tak ada `en` kosong yang diam-diam menampilkan ID);
- **test rahasia produksi hijau** (gerbang #2 di atas);
- tak ada baris dialog yang **menyebut** butir MISTERI_ABADI sebagai **fakta**;
- Oddwalker (~10%) **tetap tidak dibayar tuntas** (#78) — pipeline tidak boleh "menyelesaikan" mereka.
