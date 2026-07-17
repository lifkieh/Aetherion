# LPC_6_WAJAH — Uji kelayakan 6 sprite Ashbrook (dengan prop + hook siluet)

> **Tugas 2 (#233):** buktikan bahan cukup untuk 6 NPC bernama SEBELUM mesin perakit dibangun.
> Rakit MANUAL dari lapisan `eulpc_*` (script sekali-pakai). **Hukum siluet #231:** tiap NPC WAJIB
> hook siluet (topi/rambut/prop/postur) — warna & wajah tak terbaca di ukuran main. **Nol `game/`,
> nol wire, nol edit data. 947 test utuh.** Preview: `reports/preview/w6_*.png`. Survei 2026-07-17.

## Roster (dengan hook yang DIMINTA Direktur)
| # | Tokoh | Hook diminta | Hook TERSEDIA? | Dipakai di preview |
|---|---|---|---|---|
| 1 | Merrit (58, pos) | tua · mantel · **duduk + lampu + surat** | ❌ **lampu/surat/duduk-terintegrasi HILANG** | rambut abu + mantel (hook lemah) |
| 2 | Sora (16, penjaga lentera) | remaja kurus · **membawa lentera** | ❌ **lentera-dibawa HILANG** | badan teen (lebih kecil) |
| 3 | Otha (61, penjahit) | tua · duduk · **gulungan benang** | ❌ **benang HILANG** | abu + celemek (hook lemah) |
| 4 | Nyai Tuminah (tua) | **kerudung** · bungkuk | ✅ kerudung (hijab) · ❌ **bungkuk HILANG** | **kerudung** (hook kuat) |
| 5 | Halloran (muda, roti) | **celemek** | ✅ celemek (Aprons.zip) | **celemek putih** (hook kuat) |
| 6 | Arlen (19, kurir) | **tas kurir** · siap jalan | ✅ keranjang/backpack (lpc-more-backpacks) | **keranjang punggung** (hook kuat) |

## UJI SILUET (isi hitam · berenam bersebelahan · ukuran main) — `w6_lineup.png`

**Verdikt: LULUS SEBAGIAN.** Yang punya hook-layer nyata **terbaca**; yang hook-nya HILANG **jatuh**.

**✅ Terbedakan kuat (4):**
- **Nyai** — kerudung = kepala mulus tanpa volume rambut, unik di antara perempuan.
- **Halloran** — celemek putih = bentuk torso khas.
- **Arlen** — keranjang punggung = siluet bahu melebar, **paling khas**.
- **Sora** — badan teen = siluet paling pendek, jelas remaja.

**🔴 KEMBAR — laporan SIAPA & KENAPA (yang membunuh Ninja):**
- **Merrit ↔ Halloran.** Keduanya **laki-laki + rambut keriting**. Celemek memisah torso Halloran, tapi
  **kepala/rambut mereka nyaris identik di siluet.** Parahnya, **hook Merrit (duduk+lampu+surat) SELURUHNYA
  hilang lapisan** → Merrit hanya bersandar pada **warna rambut abu**, yang **tak terbaca di siluet/ukuran
  main.** **Merrit = tokoh terlemah; tanpa propnya ia kembar Halloran.**
- **Otha lemah** — hook aslinya (gulungan benang) hilang; ia jatuh ke abu+celemek, mirip siluet perempuan lain.

**Akar (penegasan hukum siluet #231):** distinctness datang dari **MEMILIH lapisan hook berbeda**, bukan
otomatis. Aku mengulang jebakan sendiri: memberi Merrit & Halloran rambut keriting yang sama. **Aturan
mengikat mesin perakit: (a) tak ada dua NPC bernama berbagi lapisan rambut/kepala; (b) NPC yang
identitasnya ADALAH propnya WAJIB punya prop itu — kalau propnya tak ada, tokohnya belum bisa lahir.**

## 🔴 LAPISAN YANG TIDAK ADA (harus diproduksi)
Hook identitas 3 dari 6 tokoh **tidak punya lapisan LPC**:
| Lapisan hilang | Untuk siapa | Catatan |
|---|---|---|
| **Lentera dibawa (di tangan)** | Sora (penjaga lentera!), Merrit (lampu) | ada objek lentera statis di pack lain, TAPI bukan lapisan "dipegang" ULPC-grid |
| **Gulungan benang / jarum jahit** | Otha (penjahit!) | tak ada; prop pengrajin |
| **Surat/kartu di tangan** | Merrit | tak ada lapisan; objek Ninja tak ULPC |
| **Postur bungkuk (badan tua membungkuk)** | Nyai | LPC tak punya badan bungkuk; butuh varian badan |
| **Duduk-membaca terintegrasi** | Merrit | `lpc_sitting_kit` ADA (pose duduk terpisah), tapi "duduk + baca surat + lampu" = adegan, bukan satu lapisan |

**Yang ADA & terbukti:** kerudung (hijab) · celemek (Aprons) · keranjang/backpack · badan teen · janggut ·
rambut beragam · pose duduk terpisah (sitting kit).

## Rekomendasi
1. **Produksi 4 lapisan prop kecil** (lentera-dipegang · gulungan benang · surat · — semuanya ULPC-grid
   832×2944, tangan-anchor). Kecil tapi **wajib**: tanpa lentera, "penjaga lentera" bukan siapa-siapa.
2. **Aturan rambut unik per-NPC** dikunci di mesin perakit (Merrit≠Halloran).
3. **Bungkuk & duduk-baca** = poles nanti (varian badan / adegan sit-kit), bukan blocker.

> **Ringkas untuk Direktur:** bahan cukup untuk **3–4 tokoh berhook-kuat sekarang**; **2 tokoh (Merrit,
> Otha) dan sebagian Sora** butuh **prop kecil digambar** karena identitas mereka ADALAH propnya. Itu
> bukan kegagalan LPC — LPC memberi badan/pakaian; **prop-cerita spesifik memang selalu tugas produksi.**

---

## ✅ PERBAIKAN MERRIT (#237) — blocker A2 selesai
Merrit ↔ Halloran kembar **karena lapisan rambut sama**. Diganti ke lapisan **berbeda BENTUK** (bukan
recolor): diuji **botak** vs **datar** vs keriting Halloran (`reports/preview/merrit_fix.png`).
**Terpilih: MERRIT BOTAK** (kepala mulus kecil) — siluet **paling jauh** dari puff keriting Halloran,
dan cocok: **tukang pos tua 58 th yang menipis rambutnya.** Uji ulang (`final_6_lineup.png`): **keenam
kini terbedakan di siluet**, Merrit ≠ Halloran **tegas**. *(Prop surat Merrit tetap perlu digambar —
lihat `PROP_IDENTITAS_SPEC.md` — tapi siluet dasarnya sudah aman.)*

## ✅ PROP SPEC & ASTRALBORN
- Prop identitas (lentera/benang/surat/bungkuk) → **`reports/PROP_IDENTITAS_SPEC.md`** (rancang, bukan gambar).
- **Astralborn overlay-ras TERBUKTI MURAH** (`reports/preview/astralborn_test.png`): 1 Astralborn
  (sayap+starhat) dengan **3 baju berbeda** — **wardrobe nyambung sempurna, 0 rusak.** Jalur overlay-ras
  (Astralborn→Shadeborn→Dryad) resmi terbukti.
