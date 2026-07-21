# CARA PASANG R1 — 5 langkah

**Verifikasi:** logika aturan sudah diuji lepas dari Godot; semua lulus.
Yang belum: jalankan di Godot sungguhan (butuh mesinmu).

## 1. `game/autoload/EventBus.gd`
Tambah di bawah `signal chronicle_recorded` (baris ~61):
```gdscript
# --- R1: Chronicle Restoration (#221) ---
signal chronicle_struck(id: String)                     # D-3: DIAM. Tak ada UI yang boleh mendengar.
signal chronicle_restored(id: String, loss: String)      # boleh didengar UI buku — TANPA fanfare
signal evidence_found(evidence_id: String, kind: String)
```

## 2. `game/autoload/Chronicle.gd`
Ganti seluruh isi dengan `Chronicle.gd` di folder ini.
Yang dipertahankan utuh: `record()` · `has()` · `entries()` · `town_talk()` · `_celebrate()` · TALK_DAYS.
Yang ditambah: `strike()` · `restore()` · `record_person()` · `state_of()` · `struck_entries()` ·
`readable_entries()` · `migrate_r1()`.

## 3. `game/data/chronicle_losses.json`
Salin apa adanya. 3 halaman siap: Otha · Merrit · Ashbrook-besar.

## 4. `game/autoload/SaveManager.gd`
Di `_migrate()` (baris ~161), dalam blok `if v < SCHEMA_VERSION:`:
```gdscript
Chronicle.migrate_r1(data.get("world", {}).get("chronicle", []))
```
Naikkan `SCHEMA_VERSION := 2`.

## 5. `game/tests/TestRunner.gd`
Tempel isi `TestRunner_R1_tests.gd`, daftarkan 8 fungsi:
```
_test_strike_preserves_data · _test_strike_is_silent · _test_no_chronicle_score
_test_restore_needs_two_kinds · _test_restore_alone_is_possible
_test_restore_always_loses_something · _test_chronicle_two_kinds_one_book
_test_uncared_leaves_nothing · _test_chronicle_save_r1
```

## Definisi selesai R1
Halaman bisa dicoret **tanpa suara** · ditulis ulang **hanya dengan bukti berbeda-jenis** ·
**selalu kehilangan sesuatu** · **tak ada satu angka pun** · **pemain sendirian tak pernah terkunci**.

## Belum dibangun (sengaja)
❌ kabut ❌ siapa yang mencoret ❌ Yang Terhapus ❌ NPC lupa ❌ wilayah memutih
❌ UI restore (R5, butuh Elyn) ❌ Sora sebagai alarm (R6)
