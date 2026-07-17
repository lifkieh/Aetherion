# PROP_IDENTITAS_SPEC — Spec 4 prop identitas Ashbrook (RANCANG, jangan gambar)

> **Tugas 2 (#233):** LPC memberi MANUSIA, bukan TOKOH KAMI. Lentera Sora / benang Otha / surat Merrit
> milik cerita kami — tak akan ada di pack siapa pun. Spec-kan sebagai **lapisan overlay ULPC
> (832×2944, `eulpc_*`)**. **JANGAN GAMBAR — Direktur putuskan siapa penggambar.** Survei 2026-07-17.
> **Hukum penyajian bekas:** prop wajib terbaca lewat **KONTRAS/BENTUK**, bukan detail sub-piksel.
> Lentera 6px yang tak terbaca = gagal.

## Ringkas ongkos (frame = pengali termahal)
| Prop | Jenis | Frame varian | Ongkos | Padanan LPC |
|---|---|---|---|---|
| **Surat (Merrit)** | prop tangan | **duduk/idle saja** (~1–4) | **MURAH** | dari nol (trivial: kertas pucat) / adaptasi "held book" |
| **Gulungan benang (Otha)** | prop pangkuan | **duduk saja** (~2–4) | **MURAH–MENENGAH** | keranjang LPC (ada) direcolor + benang |
| **Lentera-dipegang (Sora)** | prop tangan + **glow** | walk 4-arah + idle (~banyak) ATAU carry-pose (~4) | **MENENGAH** | adaptasi "held torch" (ada) → tukar api jadi kotak+glow |
| **Postur bungkuk (Nyai)** | ⚠ **POSTUR, bukan overlay** | badan baru → **seluruh wardrobe** | **MAHAL → TOLAK, pakai alternatif** | — |

---

## 1. SURAT (Merrit) — prop tangan · MURAH
- **Lapisan & z-order:** di **DEPAN tangan** (Merrit memegang & membaca). Untuk arah-atas (membelakangi),
  tangan digambar menutup surat → butuh varian "di belakang tangan" untuk 1 arah. Praktis: layer tunggal
  di depan badan untuk arah bawah/samping (arah yang dipakai adegan A2).
- **Frame varian:** Merrit **DUDUK membaca di bawah lampu** (A2) → cukup **frame duduk (sit) + idle
  menghadap bawah**, ~1–4 frame. **TIDAK perlu walk.** Ini yang membuatnya murah.
- **Ukuran kasar:** kertas terlipat **~8×6 px**, krem pucat.
- **Padanan:** tak ada di ULPC (Ninja non-grid). **Dari nol — tapi trivial.** Alternatif: adaptasi lapisan
  "held book/reading" LPC (ada di beberapa pack) → ganti buku jadi lembar surat.
- **Bekas (kontras):** persegi **pucat** vs tangan/baju gelap = kontras nilai tinggi → **terbaca**. Tak
  perlu teks di surat (sub-piksel); "ada kertas di tangan" sudah cukup.

## 2. GULUNGAN BENANG (Otha) — prop pangkuan + duduk · MURAH–MENENGAH
- **Lapisan & z-order:** **DEPAN paha** saat duduk (di pangkuan). Layer duduk saja.
- **Frame varian:** Otha **penjahit yang duduk** → **frame duduk saja** (LPC sit: bawah/samping), ~2–4.
  **TIDAK perlu walk.** Murah dari sisi frame.
- **Ukuran kasar:** gulungan tunggal ~5–6px = **TERLALU KECIL (sub-piksel, gagal bekas).** → Sajikan
  sebagai **keranjang jahit di pangkuan (~12–14px)** + gulungan di atasnya + **garis benang 1–2px**
  berwarna menuju tangan. **Bentuk keranjang + kontras warna benang** yang terbaca, bukan gulungan mungil.
- **Padanan:** **keranjang LPC ADA** (`lpc-more-backpacks/basket`) → **recolor + taruh di pangkuan** =
  hemat. Benang & garis = tambahan kecil.
- **Bekas (bentuk+kontras):** siluet keranjang di pangkuan + benang berwarna. Uji: kalau diisi hitam,
  keranjang-di-pangkuan masih terbaca sebagai "sesuatu di pangkuan" → lulus.

## 3. LENTERA-DIPEGANG (Sora) — prop tangan + GLOW · MENENGAH
- **Lapisan & z-order:** dipegang di tangan → **DEPAN badan** untuk arah bawah/samping, **BELAKANG** untuk
  arah atas. Pola sama seperti sayap (butuh varian back/front) ATAU cukup front untuk arah yang dipakai.
- **Frame varian — sumber ongkos:** benda **dipegang** mengikuti tangan **tiap frame**. Dua jalur:
  - (a) **Full walk 4-arah + idle** (Sora keliling menyalakan lampu) = ~36+ frame → **mahal**.
  - (b) **Carry-pose tetap** (pakai `push_and_carry` LPC: lengan menekuk memegang di sisi) → lentera cukup
    **~1 posisi per arah (4 frame)** → **jauh lebih murah.** **Rekomendasi: jalur (b).**
- **Ukuran kasar:** kotak lentera **~8–10px** + gagang ~4px + **halo cahaya ~14px**.
- **⚠ GLOW WAJIB (bekas law):** lentera **tanpa glow** di ~8px = kotak abu tak terbaca = **gagal.** Yang
  membuatnya terbaca = **halo hangat (kontras terang vs sekitar gelap)** — terutama malam. Glow = inti
  identitas "penjaga lentera", bukan hiasan.
- **Padanan:** LPC punya **held-torch** (api + tongkat) di pack tempur/tool → **adaptasi:** ganti api jadi
  kotak-lentera + halo. Hemat vs dari nol.

## 4. POSTUR BUNGKUK (Nyai) — ⚠ BUKAN overlay · MAHAL → TOLAK
- **Kenapa mahal:** bungkuk = **tulang punggung/torso menekuk** → **siluet BADAN berubah** → itu **badan
  baru**, bukan overlay. Per hukum proporsi: **setiap wardrobe (~30+ lapisan) harus dicocokkan** ke torso
  menekuk, sama kelas dengan Dwarf. **Uji Dwarf sudah membuktikan wardrobe mendikte proporsi.**
- **REKOMENDASI — alternatif MURAH (Nyai sudah cukup beda):**
  1. **Kerudung saja** — Nyai **sudah** punya hook siluet kuat (uji 6-wajah: kepala mulus tanpa volume,
     unik di antara perempuan). **Bungkuk TIDAK diperlukan untuk dikenali.** Ongkos = **0**.
  2. **+ Tongkat (cane)** — prop tangan overlay (batang ~2×14px) → **mengisyaratkan tua & bungkuk TANPA
     menekuk badan.** Wardrobe utuh. Padanan: `lpc_simple_staff` (ada) dipendekkan/direcolor jadi tongkat.
  3. (opsional) varian **kepala sedikit menunduk** (layer kepala) — kecil, tak menyentuh wardrobe.
- **Putusan usul:** **kerudung + tongkat**. Bungkuk-badan **ditolak** (mahal, tak sepadan — Nyai sudah
  terbedakan).

---

## Rekomendasi produksi (urutan termurah → termahal)
1. **Surat (Merrit)** — duduk-frame, kertas pucat. Termurah, blocker A2.
2. **Tongkat (Nyai)** — recolor staff jadi cane. Murah, ganti bungkuk.
3. **Gulungan benang (Otha)** — recolor keranjang + benang, duduk-frame.
4. **Lentera (Sora)** — carry-pose + glow. Termenengah; **glow wajib**.
> **Semua 4 = lapisan ULPC 832×2944** (kecuali yang cukup di frame duduk/carry saja). **Tak ada yang
> menyentuh wardrobe** (semua overlay) → **murah relatif** — **kecuali bungkuk-badan, yang kita TOLAK.**
> **Direktur menentukan penggambar. Ini spec, bukan gambar.**

---

## EKSEKUSI (#238) — 4 prop digambar (first-pass) & diuji keterbacaan
Digambar prosedural & diuji (hitam · bersebelahan · ukuran main; lentera di latar GELAP).
Hasil: `reports/preview/props_test.png` + `prop_*.png`. **Ini first-pass motif pembukti-keterbacaan
+ penempatan — belum sheet 832×2944 penuh per-frame** (produksi frame = langkah artis berikutnya).

| Prop | Terbaca? | Catatan |
|---|---|---|
| **Lentera+GLOW (Sora)** | ✅ **KUAT** | glow hangat terbaca jelas di latar gelap — **membuktikan kanon "glow = Sora".** Inti identitas, bukan hiasan. |
| **Tongkat (Nyai)** | ✅ **KUAT** | garis vertikal **terbaca bahkan di siluet murni** — hook lebih kuat dari bungkuk 3px (persis kata Direktur). |
| **Keranjang+benang (Otha)** | ✅ **cukup** | bentuk keranjang + benang merah (kontras) terbaca; posisi = pangkuan saat duduk. |
| **Surat (Merrit)** | ⚠ **LEMAH — dilaporkan, tak dipaksakan** | terbaca lewat kontras, TAPI penempatanku menyatu dgn bib overall pucat. **Perbaikan: taruh di TANGAN (lebih bawah) di atas area gelap, bukan di dada.** Konsep (kertas pucat=kontras) sah; penempatan produksi harus dihindarkan dari kain pucat. |

**Verdikt:** 3 kuat, 1 (surat) perlu penempatan ulang di tangan. Semua overlay, nol sentuh wardrobe.
