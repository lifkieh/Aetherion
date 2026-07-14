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
| **"The Final Silence = dunia LUPA" (D11)** | ✅ **DIRATIFIKASI (#176)** — lihat bawah |

### ✅ D11 — DIRATIFIKASI (#176)
**"THE FINAL SILENCE" = DUNIA *LUPA*, bukan dunia berakhir.** Dunia **terus ada**; **tak seorang
pun mengingat apa yang pernah dibangun**. **LAW OF ERAS (#75b) UTUH** — yang berakhir adalah
**era & ingatan**, bukan dunia. *Ending tergelap yang kita punya — dan ia gelap **tanpa satu pun
ledakan**.* **Diperbarui di:** `IMPLEMENTATION_ROADBOOK.md` · `Aetherion_bible/INDEX.md` ·
**Nirnama Bible §XVII** (privat + publik).

---

## 2026-07-14 — POTENTIAL: data tersembunyi + GERBANG-ITEM (#174/#175)

| Perubahan | Isi |
|---|---|
| **Kode: rename** | `Personality.potential()` → **`outcome_projection()`** + semua pemanggil. *(Nama lama akan membuat penulis berikutnya menampilkannya ke UI karena mengira "inilah potensi yang dimaksud kanon".)* |
| **Kode: baru** | `Personality.talent_tier()` + `TIERS` — **Average / Gifted / Exceptional / Legendary**. **Data internal**, bukan UI. |
| **Kanon baru** | **Potensi ITU NYATA** (membedakan mentok-biasa dari mentok-Legendary), **tersembunyi secara default**, dan **hanya bisa diintip lewat ITEM PENGLIHAT POTENSI** (langka; **TIER saja**, tak pernah angka mentah; **spec v0.6 — belum dibangun**). |
| **Hukum 1 & 2** | Kini punya **satu pengecualian kanon** — dan itu **memperkuat**: pemain biasa tetap melihat `???`; pemain yang **berburu** bisa mengintip, dan **pengetahuan itu sendiri menjadi kekuatan** (tahu anak petani ini Legendary = **alasan memberinya kesempatan**, L14). |
| **Test penjaga** | `_test_potential_not_exposed()` — menyisir **seluruh skrip UI** dan **gagal** bila ada yang menyentuh `outcome_projection`/`talent_tier`/`talent`/`TIERS`. Terverifikasi juga: **Legendary <5%**, **Average >60%** dari 300 kelahiran. |

## 2026-07-14 — MODEL POTENSI + TIGA MEJA (#179–#183)

| Perubahan | Isi |
|---|---|
| **Model potensi (kanon, spec v0.6)** | `Outcome = Potential × Effort × Opportunity × Time × Luck`. **POTENTIAL = ceiling bawaan** (bukan kemampuan, bukan hasil). Skala tersembunyi 50–600+. **"Legendary bukan SIFAT — Legendary adalah HASIL."** |
| **Hukum Kemauan NPC → CLAUDE.md** | **"The player influences lives. The player does not own them."** Pemain **tidak** mengontrol Effort; yang ia ubah adalah **Opportunity** (*jumlah pintu yang terbuka*). |
| **MEJA-1 (#180)** | **First Scar = Guru** & **Arc Act 1** → **RESMI FINAL**. **+ PENYESALAN SANG GURU** (Bible §III): ia meninggalkan seseorang — *muridnya berjuang ribuan tahun demi ingatan, untuk seorang guru yang sendirinya melupakan seseorang.* |
| **MEJA-2 (#181)** | **Harga kematian berevolusi per Act** (Act 1 = **memory fade murni**, tanpa gold/item). **→ DURABILITY (#29) naik jadi PRASYARAT KERAS ACT 4.** |
| **MEJA-3 (#182)** | **Mentor System**: Companion → Veteran → **Mentor** → Retired → Death → Legacy. **Memensiunkan karena stat turun = DILARANG.** |
| **Tema pemersatu (#183)** | *"Waktu terus berjalan; yang tersisa adalah apa yang kita tinggalkan."* |
| **⚠ Tiga konflik diangkat (#179b)** | rumus perkalian × `opportunity` lahir-0 → **Outcome nol mutlak** · skala vs kalibrasi bertabrakan · `talent` kode masih 1–100. **Menunggu Direktur.** |

## 2026-07-14 — TEMA RESMI (#178)

> **"Tidak semua yang gagal itu lemah. Tidak semua yang berhasil itu hebat."** *(Bab XV, R5)*
> Dinaikkan dari kalimat menjadi **syarat kejujuran dunia** — dan **penguat langsung argumen
> Ordinary People**. Game yang menjanjikan *"kerja keras selalu terbayar"* **membuat Nirnama
> menang**: kalau usaha selalu berbuah, maka yang tak berbuah **pantas** dilupakan.

---

### (arsip) D11 sebelum ratifikasi — konsisten, tetapi belum punya baris keputusan
Tafsir *"The Final Silence = dunia LUPA (bukan dunia mati)"* **konsisten** dengan seluruh kanon
baru: LAW OF ERAS (#75b, *"tidak ada ending dunia"*) · tesis resmi (#168) · poros ingin-lupa vs
menolak-lupa (§XVI) · penghakiman-lewat-Chronicle (D12). **Ia bahkan lebih tajam** daripada
"dunia berakhir": dunia yang sunyi **karena tak ada lagi yang mengingat**.

**TETAPI:** ini masih **rekomendasi agent (REPORT-06 §D butir 11)** — **tidak ada baris Decision
Log yang meratifikasinya**, dan `ROADBOOK`/`INDEX` masih memuat daftar *5 ENDING* apa adanya.
**Saya TIDAK mengarang ratifikasinya.** Bila Direktur memang menerima tafsir ini: **satu baris
keputusan diperlukan** — dan sesudahnya barulah daftar 5 ending diperbarui.
