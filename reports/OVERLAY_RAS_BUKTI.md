# OVERLAY_RAS_BUKTI — 3 ras overlay diuji (Astralborn · Shadeborn · Dryad)

> **Tugas 2 (#233):** ulangi pola Astralborn untuk Shadeborn & Dryad. **1 sprite, 3 baju, uji wardrobe
> nyambung.** Overlay yang belum ada → **spec, jangan gambar.** **Nol `game/`; 947 test hijau.** 2026-07-17.

## Hasil (semua: 1 sprite × 3 baju berbeda)
| Ras | Metode | Wardrobe nyambung? | Overlay hilang (SPEC) | Bukti |
|---|---|---|---|---|
| **Astralborn** | badan std + sayap feathered + starhat | ✅ **0 rusak** (3/3 baju) | — (sayap✅ starhat✅) | `astralborn_test.png` (#237) |
| **Shadeborn** | **palette shadow** (recolor badan+kepala) + 3 baju | ✅ **0 rusak** (3/3 baju) | **`horns`** (tanduk) — belum ada | `shadeborn_test.png` |
| **Dryad** | **faun** (kaki-native) + 3 baju atas + bark tint | ⚠ **torso 0 rusak**, **kaki ≠** | **`leaf_hair` + `bark_skin`** — belum ada | `dryad_test.png` |

## Rincian
**Astralborn — MURAH, terbukti (#237).** Badan LPC standar tak berubah → 30+ wardrobe langsung dipakai.
Sayap (back+front) + starhat = overlay murni. **Ras berikutnya setelah Human** (putusan Designer).

**Shadeborn — MURAH, terbukti.** `palette_shift="shadow"`: badan+kepala di-recolor gelap-keunguan;
**geometri badan TAK berubah → 3 baju (overalls/sleeveless/cardigan) nyambung sempurna, 0 rusak.**
Tanduk = **overlay `horns` yang BELUM ADA** (pack imp/daemon = sprite penuh, bukan lapisan tanduk).
→ **SPEC:** `horns` = overlay kepala (layer z-9), ~6–10px, di atas kepala di bawah rambut/tutup-kepala;
frame = ikut kepala (semua arah); dari nol atau crop dari imp. **Jangan gambar sekarang.**

**Dryad — MURAH-SEBAGIAN, ada catatan.** Faun memberi **tanduk + kaki-kambing GRATIS**. **Torso wardrobe
(overalls/tank/cardigan) NYAMBUNG** (tubuh atas faun human-proporsi). **TAPI kaki faun = fur/kuku →
celana/sepatu manusia TIDAK berlaku** (skip layer legs/feet). Jadi **Dryad = torso-bebas, kaki-native.**
Dua jalur (putusan Direktur):
- **(a) Faun** — horns+kaki gratis, torso-wardrobe, TANPA pakai celana (dryad nature-spirit tak bercelana). Murah.
- **(b) Human-body + `bark_skin` + `leaf_hair` overlay** — **wardrobe PENUH** (celana berlaku), tapi
  overlay bark/daun **harus digambar**. Lebih mahal seni, lebih fleksibel busana.
- **`leaf_hair`** (rambut-daun) & **`bark_skin`** (kulit kulit-kayu) = **SPEC, belum ada.** leaf_hair =
  layer rambut (z-10/11); bark_skin = palette_shift + tekstur urat (bisa dimulai dari recolor).

## Untuk perakit
`race_overlay` menyisip di z-order (lihat `PERAKIT_SPEC.md` §5). Astralborn & Shadeborn = **jalur murni
overlay/recolor**. Dryad = overlay + **skip layer kaki** (kaki-native) ATAU human+overlay. **3 overlay
perlu digambar sebelum ras ini lahir penuh: `horns`, `leaf_hair`, `bark_skin`** — Direktur tentukan penggambar.
