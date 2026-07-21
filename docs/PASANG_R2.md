# CARA PASANG R2 — HUKUM BUKTI (#226)

> ⚠⚠ **PELAJARAN #241 — WAJIB BACA:**
> 9 test R1 ditulis tapi **tidak pernah didaftarkan di `_ready()`**. Berminggu-minggu kita
> percaya D-3/D-4/#226/#229.3 dijaga mesin. **Tidak ada yang menjaganya.**
>
> **Test yang tidak dijalankan bukan penjaga. Itu komentar.**
>
> Setelah pasang: **jalankan, dan pastikan angka test BERTAMBAH.** 979 → ~995.
> Kalau tidak naik, mereka tidak jalan.

## 1. `game/data/evidence.json`
Salin apa adanya. **14 bukti**, 3 halaman (Otha · Merrit · Ashbrook-besar).

## 2. `game/autoload/Db.gd`
`evidence` var + `load_all()` **sudah ditambal di #241** — tapi pemuatannya **bersyarat**
(karena file belum ada). Sekarang file-nya ada:

```gdscript
# UBAH dari pemuatan bersyarat → tanpa syarat:
evidence = _load_indexed("evidence.json", "id")
```

**Alasan:** file yang hilang harus jadi error, bukan didiamkan. Pemuatan bersyarat benar
saat file belum ada; sekarang salah.

## 3. `game/autoload/Evidence.gd` — BARU
Salin. Daftarkan sebagai autoload **SETELAH** `Db` dan `Chronicle`
(ia menyentuh `Db.evidence` + `Chronicle.SCRIBE_KINDS_NEEDED`).

## 4. `game/autoload/SaveManager.gd`
Tambah `Evidence.to_save()` / `Evidence.from_save()` ke payload.

## 5. `game/tests/TestRunner.gd`
Tempel isi `TestRunner_R2_tests.gd`, **DAFTARKAN 6 fungsi di `_ready()`**:
```
_test_evidence_find_is_silent
_test_no_evidence_score
_test_evidence_counts_kinds_not_items
_test_evidence_228_solo_never_locked
_test_evidence_kinds_are_canon
_test_evidence_to_restore_flow
```

## Definisi selesai R2
- Bukti bisa ditemukan **tanpa suara** (D-3)
- Tak ada hitungan bukti di mana pun (D-4)
- Yang dihitung **jenis**, bukan jumlah (#226 #1)
- **Setiap halaman bisa dipulihkan pemain sendirian** (#228 — dijaga penjaga DATA)
- Alur penuh bekas → halaman → `loss` bekerja
- Angka test **naik dari 979**

## Temuan saat menulis R2 (untuk ledger)
Penjaga `_test_evidence_228_solo_never_locked` **menangkap pelanggaran nyata pada data
saya sendiri**: `place_ashbrook_besar` cuma punya 2 jenis bukti → pemain sendirian
**terkunci selamanya**. Diperbaiki dengan menambah lonceng (`benda`) + kesaksian Old Bram
(`orang`).

Juga: `requires_npc` semula dipasang pada Merrit/Nyai/Halloran/Bram — **salah.** Mereka
NPC kota, bukan companion. Gate hanya untuk companion yang harus **direkrut** (Arlen).
