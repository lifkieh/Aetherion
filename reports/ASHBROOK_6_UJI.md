# ASHBROOK_6_UJI — Uji kelayakan: 6 sprite LPC penuh (rentang tersulit)

> **Tugas 2 (#233, klarifikasi Direktur):** rakit 6 **sprite karakter LPC penuh** (bukan portrait) sebagai
> **file lepas** di `reports/preview/` — **uji kelayakan aset, bukan pembangunan NPC.** **Nol perubahan
> `game/`, nol edit `town_npcs.json`.** Perakitan manual (Python composite lapisan ULPC), **bukan** mesin
> perakit produksi (itu masih menunggu spec Designer). Survei 2026-07-17.

## Pertanyaan yang diuji (kata Direktur)
> *"Kalau tiga [empat] orang tua ini jadi blob yang sama, kita punya Ninja kedua. Itu yang paling ingin saya tahu."*

**Rentang tersulit sengaja dipilih:** 4 orang tua (2♂ Merrit/Bram · 2♀ Otha/Nyai) + 1 muda (Halloran) +
1 remaja (Sora). Arlen dicoret (terlalu mirip Halloran).

## Cara rakit (lapisan, bukan sihir)
Tiap sprite = composite lapisan ULPC 832×2944 (`eulpc_body/head + hair + clothing`) + `whitebeard`/`hijab`,
crop frame walk-down. Umur & identitas dibedakan lewat **rambut · janggut · kerudung · gender-body ·
warna** (bukan wajah keriput — kepala-tua khusus ada di elders/bases untuk poles nanti).

| # | Tokoh | Lapisan pembeda | Hasil |
|---|---|---|---|
| 1 | **Merrit Fane** (58, pos) | body ♂ + rambut keriting-pendek **abu** + overall biru, **tanpa janggut** | ✅ |
| 2 | **Old Bram** (tua) | body ♂ + rambut **putih** + **JANGGUT PUTIH** + overall coklat | ✅ paling tua, terbaca instan |
| 3 | **Otha Renn** (61, ♀ penjahit) | body ♀ + rambut **sanggul abu** + atasan olive | ✅ |
| 4 | **Nyai Tuminah** (tua ♀) | body ♀ + **KERUDUNG abu** (bukan rambut) + atasan gelap | ✅ beda tegas dari Otha |
| 5 | **Halloran Muda** (muda, roti) | body ♂ + rambut keriting **coklat** + apron tan | ✅ muda (bukan abu) |
| 6 | **Sora Lanternwick** (16) | **body teen** (lebih kecil) + rambut swoop + cardigan | ✅ jelas remaja |

## VERDIKT — **LULUS. Bukan Ninja kedua.**

**Uji siluet (isi hitam, `ashbrook_lineup.png` baris bawah):**
- **Merrit vs Bram (2 ♂ tua):** **BEDA JELAS** — janggut Bram = massa dagu yang tak dimiliki Merrit.
- **Otha vs Nyai (2 ♀ tua):** **BEDA JELAS** — kerudung Nyai vs sanggul Otha = siluet kepala berbeda.
- **♂ tua vs ♀ tua:** body male vs female + tinggi = terbaca.
- **Sora (teen):** body lebih kecil = siluet paling pendek, jelas remaja.

**4 orang tua bisa dibedakan — di WARNA dan di SILUET.** Kontras dengan Ninja, di mana dewasa/tua/anak
adalah blob identik yang hanya beda warna. LPC lulus karena modularitasnya memberi **hook siluet nyata**
(janggut, kerudung, gender-body).

## ⚠ Satu kelemahan jujur (temuan penting)
**Merrit & Halloran memakai lapisan rambut yang SAMA** (keriting-pendek), beda hanya **warna** (abu vs
coklat). Di siluet murni, keduanya **mirip**. → **Ini bukan kegagalan LPC — ini penegasan hukum siluetku
sendiri:** *distinctness lahir dari MEMILIH lapisan berbeda, bukan otomatis.* Pakai ulang rambut yang sama
= siluet yang sama (jebakan Ninja dalam skala kecil). **Aturan produksi untuk mesin perakit nanti: tiap
tokoh bernama WAJIB rambut/tutup-kepala berbeda**, bukan sekadar recolor.

## Batas & sisa
- **Nol `game/`, nol `town_npcs.json`.** Otha & Nyai **tetap tokoh A1 yang belum dibangun** — tidak
  ditambahkan ke data. Sprite ini **file lepas** uji, bukan aset final.
- **Poles masa depan:** kepala-tua keriput (elders/bases v3) untuk umur lebih meyakinkan; wajah/portrait
  tetap GAP terpisah (di luar lingkup, sudah dilaporkan).
- **Lisensi:** sprite ini **CC-BY-SA** (turunan LPC) — atribusi di `reports/preview/README.md`.
