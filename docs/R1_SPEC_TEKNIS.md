# SPEC TEKNIS — R1: `Chronicle.strike()` & `Chronicle.restore()`
## Tahap pertama Chronicle Restoration · siap dibangun · Draft Designer v0.1

**Sandaran kode yang SUDAH ADA:** `Chronicle.gd` (record/has/entries/town_talk ✅) ·
`WorldState.chronicle: Array` ✅ · `EventBus.chronicle_recorded` ✅ · `GameClock.date_string()` ✅ ·
`SaveManager` + `schema_version` ✅
**Hukum yang mengikat:** D-1 (Hukum Bukti) · D-4 (tanpa progress bar) · §XVI · §VI.2 · §XVII

> **Prinsip R1: JANGAN bangun kabut dulu.** R1 hanya membangun **kemampuan buku untuk dicoret dan
> ditulis ulang**. Siapa yang mencoret, kapan, dan kenapa — itu R3+. Kalau R1 benar, sisanya murah.

---

## 1. PERUBAHAN STRUKTUR DATA

### 1.1 Entri Chronicle — sekarang

```gdscript
{ "id", "title", "date", "time", "season", "by", "level" }
```

### 1.2 Entri Chronicle — sesudah R1

```gdscript
{
    "id": "first_clear_lunar_warren",
    "title": "Warren of the Moon Rabbit",
    "date": "12 Juli 2026", "time": "23:41",     # WIB nyata — #159, JANGAN diubah
    "season": "Kemarau", "by": "Aria", "level": 34,

    # --- BARU (R1) ---
    "state": "written",        # written | struck | restored
    "struck_at": "",           # tanggal WIB saat dicoret ("" bila belum)
    "restored_at": "",         # tanggal WIB saat ditulis ulang
    "witnesses": [],           # [{"kind":"benda","id":"surat_merrit","by":"merrit"}, ...]
    "loss": "",               # APA yang hilang saat ditulis ulang (D-1: tak pernah identik)
}
```

**Catatan kunci — kenapa `state`, bukan menghapus entri:**
§VI.2 kanon: *"data asli disimpan tersembunyi — bisa DIPULIHKAN lewat perlawanan"*.
Entri **tidak pernah dihapus dari array.** Ia hanya berubah `state`. Buku menyimpan luka.

### 1.3 Bukti — struktur baru **[D-1]**

```gdscript
# WorldState.evidence: Dictionary   # evidence_id -> {found_at, kind, source}
```

Empat `kind` — **kanon D-1**, tak boleh ditambah tanpa putusan Direktur:

| `kind` | Arti | Contoh Ashbrook |
|---|---|---|
| `"benda"` | benda fisik yang selamat | surat Merrit · kartu pinjam Wren · lentera Sora |
| `"kebiasaan"` | tubuh ingat setelah kepala lupa | Merrit menyalakan lampu · Halloran memanggang 200 roti untuk 40 orang |
| `"akibat"` | bekas yang tak bisa dicoret | jembatan terlalu lebar · gudang gandum berisi 4 ayam · fondasi di rumput |
| `"orang"` | seseorang yang cukup mencintai (#5a) | Sora · Nyai Tuminah · Merrit |

---

## 2. API — `Chronicle.gd`

### 2.1 `strike(id, cause) -> bool`

```gdscript
## Coret satu halaman. Data asli TIDAK dihapus — hanya state berubah.
## cause: "kabut" | "test" | ...  (dicatat, tak pernah ditampilkan)
func strike(id: String, cause: String = "kabut") -> bool:
    for e in WorldState.chronicle:
        if e.get("id","") == id and e.get("state","written") == "written":
            e["state"] = "struck"
            e["struck_at"] = GameClock.date_string()
            e["struck_cause"] = cause
            EventBus.chronicle_struck.emit(id)      # BARU
            return true
    return false
```

> ### ⛔ HUKUM D-3 — DIKODEKAN, BUKAN DIHARAPKAN
> `strike()` **DILARANG** memanggil: `Stage.banner` · `EventBus.toast` · `Audio.play_stinger` ·
> `Cutscene.play`. **Nol umpan balik.** Buku berubah diam-diam.
> **Test wajib:** `_test_strike_is_silent()` — panggil `strike()`, pastikan **nol** sinyal
> toast/banner/stinger ter-emit. *(Pola sama dengan test White Stag #216 yang sudah ada.)*

### 2.2 `restore(id, witnesses) -> Dictionary`

```gdscript
## Tulis ulang halaman. WAJIB ≥2 bukti dengan kind BERBEDA (D-1).
## Mengembalikan {"ok":bool, "reason":String, "loss":String}
func restore(id: String, witnesses: Array) -> Dictionary:
    var e := _find(id)
    if e.is_empty() or e.get("state","") != "struck":
        return {"ok": false, "reason": "not_struck"}

    # --- D-1: minimal DUA JENIS bukti berbeda ---
    var kinds := {}
    for w in witnesses:
        kinds[w.get("kind","")] = true
    if kinds.size() < 2:
        return {"ok": false, "reason": "need_two_kinds"}

    e["state"] = "restored"
    e["restored_at"] = GameClock.date_string()
    e["witnesses"] = witnesses.duplicate(true)
    e["loss"] = _compute_loss(e, witnesses)     # D-1: tak pernah identik
    EventBus.chronicle_restored.emit(id, e["loss"])
    return {"ok": true, "reason": "", "loss": e["loss"]}
```

### 2.3 `_compute_loss()` — jantung D-1 **[BARU]**

> **Hukum: halaman yang ditulis ulang TIDAK PERNAH identik dengan aslinya. Selalu ada yang hilang.**

`loss` **bukan** angka. Ia **satu kalimat** yang menyebutkan apa yang tidak kembali.
Ditulis tangan per halaman (bukan tabel acak — konsisten dengan gaya harga revive Kain #192).

```gdscript
func _compute_loss(e: Dictionary, witnesses: Array) -> String:
    # Data-driven: data/chronicle_losses.json → id -> {"loss_by_missing_kind": {...}, "default": "..."}
    # Yang hilang DITENTUKAN oleh jenis bukti yang TIDAK pemain bawa.
    ...
```

**Contoh (Ashbrook):**

| Halaman | Bukti yang dibawa | `loss` |
|---|---|---|
| *"Rumah Singgah Fane"* | benda + orang (tanpa `kebiasaan`) | *"Tak seorang pun ingat lagi jam berapa lampunya dinyalakan."* |
| *"Rumah Singgah Fane"* | benda + kebiasaan (tanpa `orang`) | *"Namanya tercatat. Wajahnya tidak."* |
| *"Gudang Gandum Ashbrook"* | akibat + kebiasaan | *"Ia tercatat sebagai gudang. Bukan sebagai tempat empat puluh keluarga menghitung musim dingin."* |

**Kenapa ini penting:** pemain yang membawa bukti berbeda **mendapat halaman yang berbeda**.
Ingatan dunia berbentuk seperti apa yang berhasil kamu temukan. *Itu Hukum Bukti yang terasa.*

### 2.4 Query

```gdscript
func state_of(id: String) -> String            # "" | written | struck | restored
func struck_entries() -> Array                 # untuk UI
func is_struck(id: String) -> bool
```

> ### ⛔ HUKUM D-4 — DIKODEKAN
> **DILARANG ADA:** `restored_count()` · `total_count()` · `progress()` · `completion_percent()`.
> **Test wajib:** `_test_no_chronicle_score()` — grep API Chronicle; **gagal** bila ada fungsi
> yang mengembalikan rasio/persentase/jumlah-pulih.
> *Alasan kanon (§XVII): "Apa yang dunia ingat, itulah putusannya" — bukan skor.*

---

## 3. SINYAL BARU — `EventBus.gd`

```gdscript
signal chronicle_struck(id: String)                    # DIAM. Tak ada UI yang mendengarkan (D-3).
signal chronicle_restored(id: String, loss: String)     # boleh didengar UI buku, TANPA fanfare
signal evidence_found(evidence_id: String, kind: String)
```

**Catatan D-3:** `chronicle_struck` **boleh** didengar sistem internal (test, save), tapi
**dilarang** disambungkan ke toast/banner/stinger mana pun. Guard-nya = test, bukan disiplin.

---

## 4. UI — Buku, bukan menu

**[D-4 + §XVI]** Chronicle bukan daftar. Ia buku tulisan tangan.

| Elemen | Aturan |
|---|---|
| **Font** | tulisan tangan (bukan font UI). `assets/game/fonts/` — perlu 1 font tulisan tangan. |
| **Entri `written`** | tulisan tangan biasa + tanggal WIB nyata |
| **Entri `struck`** | **dicoret garis tinta hitam.** Judul **masih terbaca samar** — pemain tahu ada sesuatu, tak bisa membacanya. **Tanpa ikon. Tanpa warna merah. Tanpa tombol "PULIHKAN".** |
| **Entri `restored`** | tulisan tangan **berbeda** (ini ditulis ulang oleh orang lain — Elyn) + baris kecil: *"dipulihkan dari kesaksian: Merrit, sebuah surat"* + **baris `loss`** |
| **Halaman kosong** | yang tak pernah dicatat = **kosong**. Bukan "0 entries". Kekosongan harus terasa. |
| ⛔ **DILARANG** | persentase · progress bar · jumlah · badge · notifikasi · sorting "belum pulih" |

**Uji UI:** kalau pemain bisa **menyortir** halaman berdasarkan apa yang belum ia pulihkan,
D-4 sudah mati — ia baru saja diberi checklist.

---

## 5. SAVE & MIGRASI

`SaveManager` sudah punya `schema_version` ✅.

```gdscript
# Migrasi: entri lama tanpa "state" → dianggap "written"
func _migrate_chronicle_r1(entries: Array) -> void:
    for e in entries:
        if not e.has("state"):
            e["state"] = "written"
            e["struck_at"] = ""; e["restored_at"] = ""
            e["witnesses"] = []; e["loss"] = ""
```

**Save lama tetap jalan. Tidak ada kanon yang dimundurkan.**

---

## 6. TEST WAJIB (hukum test #151b: **ukur DUNIA, bukan teksnya**)

| Test | Memastikan |
|---|---|
| `_test_strike_preserves_data` | entri dicoret **tidak hilang** dari array; `title` & `date` asli utuh |
| `_test_strike_is_silent` | **D-3** — nol toast/banner/stinger saat `strike()` |
| `_test_restore_needs_two_kinds` | **D-1** — 2 bukti `kind` **sama** → **GAGAL**; 2 `kind` berbeda → sukses |
| `_test_restore_always_loses_something` | **D-1** — tiap `restore()` sukses mengembalikan `loss` **tidak kosong** |
| `_test_no_chronicle_score` | **D-4** — tak ada fungsi persentase/rasio/jumlah-pulih di API |
| `_test_restored_entry_marked` | entri `restored` menyimpan `witnesses` & `loss` |
| `_test_save_roundtrip_r1` | strike → restore → save → load → state utuh |
| `_test_migration_old_save` | save tanpa `state` → jadi `written`, tidak crash |

---

## 7. URUTAN KERJA R1 (satu sesi)

1. `EventBus`: 3 sinyal baru
2. `Chronicle.gd`: `state` di `record()` · `strike()` · `restore()` · `state_of()` · `struck_entries()`
3. `data/chronicle_losses.json`: **2 halaman uji coba** (Ashbrook)
4. `SaveManager`: migrasi
5. 8 test di atas
6. UI buku: **coretan saja dulu** (restore UI = R5, bersama Elyn)

**Definisi selesai R1:** halaman bisa dicoret **tanpa suara**, bisa ditulis ulang **hanya dengan
2 jenis bukti**, **selalu kehilangan sesuatu**, dan **tak ada satu angka pun** di mana pun.

---

## 8. YANG BELUM DIBANGUN DI R1 (sengaja)

❌ Kabut · ❌ siapa yang mencoret · ❌ Yang Terhapus · ❌ NPC lupa · ❌ wilayah memutih ·
❌ UI restore (butuh Elyn — R5) · ❌ Sora sebagai alarm (R6)

**R1 hanya membuat buku bisa terluka dan bisa disembuhkan. Itu saja. Itu cukup.**
