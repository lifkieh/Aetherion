# CANON CHANGE LOG — perubahan kanon yang bisa ditelusuri

> Dibuat #171. **Bukan pengganti PLAN_LEDGER** (Decision Log tetap satu-satunya sumber
> keputusan). Ini **peta perubahan kanon per dokumen**, supaya siapa pun bisa menjawab
> *"apa yang berubah, kapan, karena keputusan mana"* tanpa membaca 172 baris ledger.

## 2026-07-14 — NIRNAMA BIBLE v2.0 → v2.1 (#171)

| Bab | Tindakan | Isi |
|---|---|---|
| Header | **DIUBAH** | v2.0 → **v2.1** |
| **XIII. Ordinary People** | **DIPERLUAS (R3)** | **Angka kanon: ~90%** penduduk hidup biasa — tidak dikenang, **tidak masuk Chronicle**, tak diceritakan setelah dua generasi. **Dunia berdiri karena mereka.** *"Sepuluh persen sisanya tidak menopang dunia; mereka hanya tercatat."* |
| **XIV. Potential = ???** | **DIPERLUAS (R4)** | Disambungkan ke **empat sistem**: NPC Philosophy · Living World · Legacy · **Future Unknown** (*"tak ada ramalan yang benar; Astrolog boleh salah"*). **+ peringatan tabrakan istilah** dengan `Personality.potential()` |
| **XV. Faktor manusiawi** | **DIPERLUAS (R5)** | **+ ENVIRONMENT** sebagai faktor keempat (*"lingkungan = kesempatan yang membeku menjadi tempat"*). **+ HUKUM R5**: *"Tidak semua yang gagal itu lemah. Tidak semua yang berhasil itu hebat."* |
| **XVII. Akhir** | **DIPERTEGAS (R7)** | **+ "NIRNAMA TIDAK SALAH. DUNIA TIDAK SALAH."** (ia melihat **siklus**; dunia melihat **kemungkinan** — dua-duanya nyata). **+ TIGA PENGGAMBARAN DILARANG:** kekalahan · eksekusi · kemenangan sederhana. **+ penghakiman akhir = hitungan Chronicle (D12).** Nasib persis **tetap** = spec Act 2 |
| **Bab dihapus** | **TIDAK ADA** | — |
| **Bab diganti-nama** | **TIDAK ADA** | — |
| **Lore dimundurkan** | **TIDAK ADA** | Bab 0, I–XII, XVI utuh |

**Sudah diterapkan lebih dulu di v2.0 (#168):** R1 (bab 0 — Nirnama = pertanyaan, bukan
protagonis) · R2 (bab XII — *"Jalan Nirnama"* dihapus) · R6 (bab XVI — Chronicle = tokoh utama
kedua) · kerangka R3/R4/R5/R7.

## 2026-07-14 — NPC DEPTH LAWS (#172)

- **+ RUMUS INDUK**: `Outcome = Potential + Opportunity + Effort + Luck` × Mental State —
  **sudah terkode** (`Personality.gd`, bobot `effort` 0,35 **>** `talent` 0,30).
- **+ Empat tier bakat** (Average/Gifted/Exceptional/Legendary) — **nama internal, tak pernah tampil**.
- **+ Lima keadaan mental** (depresi · burnout · kecanduan · kehilangan tujuan · kecemasan) —
  **spec v0.6**, melampaui `trauma[]` yang sudah ada.
- **+ Tabel status: SUDAH TERKODE vs SPEC** — 3 hukum terkode, 2 separuh, 3 spec.

## Verifikasi konsistensi (diminta Direktur)

| Butir | Hasil |
|---|---|
| **M9 (Caevael)** ada di `MISTERI_ABADI.md` | ✅ **ADA** (baris 103, #140) |
| **Test rahasia produksi** | ✅ **HIJAU** (dan kini menyisir `docs/` + dokumen hukum — #169) |
| **"The Final Silence = dunia LUPA" (D11)** | ⚠ **KONSISTEN, TAPI BELUM DIRATIFIKASI** — lihat bawah |

### ⚠ D11 — konsisten, tetapi belum punya baris keputusan
Tafsir *"The Final Silence = dunia LUPA (bukan dunia mati)"* **konsisten** dengan seluruh kanon
baru: LAW OF ERAS (#75b, *"tidak ada ending dunia"*) · tesis resmi (#168) · poros ingin-lupa vs
menolak-lupa (§XVI) · penghakiman-lewat-Chronicle (D12). **Ia bahkan lebih tajam** daripada
"dunia berakhir": dunia yang sunyi **karena tak ada lagi yang mengingat**.

**TETAPI:** ini masih **rekomendasi agent (REPORT-06 §D butir 11)** — **tidak ada baris Decision
Log yang meratifikasinya**, dan `ROADBOOK`/`INDEX` masih memuat daftar *5 ENDING* apa adanya.
**Saya TIDAK mengarang ratifikasinya.** Bila Direktur memang menerima tafsir ini: **satu baris
keputusan diperlukan** — dan sesudahnya barulah daftar 5 ending diperbarui.
