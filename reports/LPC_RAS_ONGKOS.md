# LPC_RAS_ONGKOS — Ongkos 5 ras (UKUR, jangan bangun)

> **Tugas 3 (#233):** ukur ongkos merakit 5 ras dari lapisan yang ada. **Hukum proporsi (Designer):**
> ras yang menambah **OVERLAY** = MURAH (badan tak berubah → wardrobe tetap nyambung); ras yang mengubah
> **PROPORSI** = MAHAL (badan berubah → SELURUH wardrobe ikut). **Angka kasar, bukan kata sifat.**
> **Nol `game/`, nol wire, 947 test utuh.** Survei 2026-07-17. Bukti uji: `reports/preview/dwarf_test.png`.

## ⚠ UJI SUNGGUHAN DWARF (bukan tebak) — `dwarf_test.png`
Aku pendekkan badan (bukan skala seragam) lalu pakaikan **baju STANDAR**, screenshot 4 panel:
1. **NORMAL** — badan+overall+sepatu nyambung. ✅
2. **UNIFORM 80%** — seluruh sprite dikecilkan → **kepala ikut kecil = MANUSIA KERDIL, bukan dwarf.** ❌
3. **BADAN PENDEK + baju STANDAR** — **wardrobe MENANG:** overall/celana digambar untuk kaki tinggi,
   jadi ia **menimpa** kaki-pendek → sprite balik terlihat TINGGI. **Pemendekan badan sia-sia selama
   baju tak ikut diubah.** ← inilah kerusakannya.
4. **Semua layer di-squash bersama** — baru terlihat dwarf sejati (kaki pendek), TAPI ini menuntut
   **tiap layer pakaian diedit**, bukan satu gambar.

**JAWABAN PERTANYAAN TERPENTING:** *"Kalau badan Dwarf dipendekkan, apakah wardrobe rusak?"* →
**YA. Wardrobe mendikte proporsi.** Dwarf sejati (kaki pendek, kepala tetap besar) mustahil hanya
dengan mengedit badan — **setiap baju/celana/sepatu harus digambar ulang pada proporsi pendek**, atau
ia tak nyambung. Ini bukan satu gambar; ini **seluruh lemari pakaian.**

## Angka: berapa lapisan wardrobe terdampak?
Menghitung lapisan yang menyentuh zona torso/kaki/sepatu di `lpc/`+`lpc_extra/`:
- **Torso/baju:** overalls · cardigan · sleeveless2 · Aprons(×4) · Bandages · Maternity tank · Women's
  Shirt Pack(banyak) · long/short/sleeveless shirts · Clothes00 · Clothes01 · kimono · Dark Elves robe ·
  Legion armor · gentleman · Androgynous long-sleeve ≈ **20+ lapisan**
- **Kaki/celana:** pants · hose · shorts · skirt · maternity pants · androgynous pants · kimono/obi ≈ **8**
- **Sepatu:** shoes · high-socks · obi-boots · socks-shoes ≈ **4**
- **TOTAL ≈ 30+ lapisan SEKARANG — plus SETIAP pack pakaian masa depan (tak terbatas).**

## Tabel ongkos (per hukum proporsi)
| Ras | Jenis | Badan berubah? | Wardrobe terdampak | Ongkos | Seni baru yang perlu |
|---|---|---|---|---|---|
| **Astralborn** | OVERLAY | tidak | **0** | **MURAH** | sayap ✅ada · starhat ✅ada · glow (shader). ~0 gambar baru |
| **Shadeborn** | OVERLAY | tidak | **0** | **MURAH** | recolor palet gelap + overlay tanduk/mata-menyala (kecil) |
| **Dryad** | OVERLAY | tidak | **0** | **MURAH** | recolor kulit-kayu + overlay rambut-daun/akar (kecil–menengah); faun sbg pose opsional |
| **Dwarf** | **PROPORSI** | **ya** | **~30+ (seluruh wardrobe + semua pack masa depan)** | **MAHAL** | re-proporsi tiap baju/celana/sepatu ke badan pendek |
| **Tidekin** | **RE-GRID/REDRAW** | ya (frogman non-grid 480×864 & MENYATU) | 0–sebagian (bila proporsi humanoid dipertahankan) | **MAHAL** | frogman tak bisa dipretelin → **redraw badan+sirip/sisik/insang sbg lapisan ULPC 832×2944** |

## Kesimpulan (angka, bukan sifat)
- **3 ras MURAH — overlay, 0 lapisan wardrobe rusak:** **Astralborn · Shadeborn · Dryad.** Badan LPC
  standar tetap; seluruh 30+ wardrobe langsung dipakai. Seni baru = hanya overlay kecil (sayap sudah ada).
- **2 ras MAHAL:**
  - **Dwarf** — **~30+ lapisan wardrobe** harus di-re-proporsi + tiap pack pakaian masa depan. **Bukan
    satu sprite — satu lemari.** *Rekomendasi: pakai konvensi "tinggi-normal + janggut lebat + tubuh
    lebar" (0 ongkos) kecuali Direktur menuntut siluet kaki-pendek sejati.*
  - **Tidekin** — frogman **non-grid & menyatu** → harus **digambar ulang** sebagai lapisan ULPC.
    Ongkosnya di **redraw badan**, bukan wardrobe (bila proporsi tetap humanoid, 30+ wardrobe reusable).

> **Prinsip yang terbukti:** *tambah OVERLAY = murah; ubah PROPORSI = bayar seluruh wardrobe.* Karena itu
> **Dryad/Astralborn/Shadeborn lahir hampir gratis** dari badan LPC + overlay; **Dwarf & Tidekin** adalah
> tempat satu-satunya yang menuntut produksi seni nyata — dan Dwarf paling mahal karena menyeret **semua
> pakaian, selamanya.**
