# LANGKAH 5b + 5c — proporsi & riset fasad

**2026-07-19** · **nol impor, nol rakit.** 5c menunggu putusan lisensi Direktur.

---

# 5b — PROPORSI: **"sebesar rumah" HILANG dari tanah & prop. Belum bisa dinilai vs bangunan.**

Bukti: `reports/preview/5b_proporsi.png` — dua panel, **skala layar SAMA**
(16px zoom 2× dan 32px zoom 1,0× → keduanya 1 petak = 32 px layar), jadi selisih
yang terlihat murni selisih **karakter**.

## Angka

| | tinggi badan | dalam petak |
|---|---|---|
| LPC di dunia **16px** (keadaan sekarang) | 34×47 px | **2,1 × 2,9 petak** |
| LPC di dunia **32px** (Ashbrook64) | 34×47 px | **1,1 × 1,5 petak** ✅ |
| `_charsys` di dunia 16px (dulu) | 12×27 px | 0,8 × 1,7 petak |

**Target Anda "±1,5 petak" tercapai persis di 32px.** Karakter berdiri wajar di atas
perkerasan, seukuran dengan bangku, tong, dan air mancur.

## ⚠ Yang JUJUR belum terjawab

Panel bawah **tidak punya bangunan** — yang ada cuma panel dinding tergeletak, nol atap.
Jadi pertanyaan *"masih sebesar rumah?"* **belum bisa dijawab**, karena rumahnya belum ada.

Yang **sudah** terbukti: proporsi terhadap **tanah, prop, dan perabot** benar.
Yang **menunggu 5c**: proporsi terhadap **bangunan menjulang**.

Bandingkan panel atas — di sana rumahnya ADA, dan karakternya jelas kebesaran:
warga hampir setinggi ambang pintu. **Itu masalah yang 32px sudah selesaikan** untuk
segala yang bukan bangunan.

---

# 5c — RISET FASAD

## Temuan 1: **Mage City TIDAK CUKUP. Nol atap, nol pintu.**

Seluruh 8×45 petak diperiksa (tiga pita kisi):

| baris | isi |
|---|---|
| 0–3 | tanaman, guci, tong, air mancur, bangku, peti |
| 4–5 | **dinding batu pasir** ✅ |
| 6–8 | air, pagar kayu |
| 9–11 | perkerasan cobble |
| 12–18 | patung, pohon dalam pot |
| 19–22 | **jendela** ✅ (banyak varian) |
| 23–25 | **panel kayu** ✅ |
| 26–28 | **bata besar berlumut** ✅ |
| 29–34 | pohon, jalan setapak rumput, labu |
| 35–40 | **dinding batu/bata** ✅ + pagar besi |
| 41–43 | rak buku, tempayan |

**Ada:** dinding (4 jenis) · jendela · pagar.
**TIDAK ADA:** **atap** (nol jenis) · **pintu** (nol jenis).

Tanpa atap dan pintu, yang bisa dirakit hanyalah **tembok**, bukan rumah. Fasad Suikoden
mustahil dari Mage City sendirian.

## Temuan 2: pack yang punya atap+pintu — dan lisensinya

| pack | lisensi | atap | dinding | pintu | ukuran | URL |
|---|---|---|---|---|---|---|
| **[LPC] Roofs** — bluecarrot16 | 🔴 **CC-BY-SA 3.0 + GPL 3.0** | ✅ hipped·gabled·gambrel·saltbox; sirap·slate·genteng·papan·semen | — | — | 32px | https://opengameart.org/content/lpc-roofs |
| **[LPC] Walls** — bluecarrot16 | 🔴 **CC-BY-SA 3.0** | — | ✅ **300+** + 32 lis plafon | — | 32px | https://opengameart.org/content/lpc-walls |
| **[LPC] Windows & Doors** — bluecarrot16 | 🔴 **CC-BY-SA 3.0 + GPL 3.0+** | — | — | ✅ | 32px | https://opengameart.org/content/lpc-windows-doors |
| **✅ [LPC Revised] 4-Seasons Tilesets** — JaidynReiman / Eliza Wyatt | 🟢 **CC-BY 3.0 + OGA-BY 3.0** | ✅ | ✅ | ❌ *(pembuatnya sengaja tak menyertakan — ia anggap pintu itu sprite, bukan ubin)* | **32px**, atlas 2048² | https://opengameart.org/content/lpc-revised-fully-configured-4-seasons-tilesets-for-tiled-map-editor |
| Mage City Arcanos (di gudang) | 🟢 **CC0** | ❌ | ✅ | ❌ | 32px | https://opengameart.org/content/mage-city-arcanos |

⚠ **Tiga pack bluecarrot16 — yang paling lengkap — semuanya CC-BY-SA.**
Memakainya berarti tileset Aetherion **dan seluruh seni asli yang di-composite bersamanya**
ikut SA. Itu persis yang Anda minta dihindari.

## Temuan 3: satu-satunya jalan non-menular

**LPC Revised 4-Seasons (OGA-BY)** memberi **atap + dinding** tanpa menular.
Yang kurang cuma **pintu** — dan pintu adalah aset **terkecil** dari ketiganya:
1–2 petak, geometri sederhana, sudah ada preseden generator kita
(`gen_otha_sign.py`, `gen_bench.py`, `gen_tiles_ashbrook16.py`).

> **Rakitan usulan:** atap + dinding **LPC Revised (OGA-BY)** · perkerasan/prop
> **Mage City (CC0)** · **pintu digambar sendiri** (#240, script ter-commit).
> Hasilnya: **nol CC-BY-SA**, nol pembelian, dan pintu jadi milik penuh Aetherion.

---

# PUTUSAN YANG SAYA MINTA

Tiga pilihan. **Saya tidak mengunduh apa pun sampai Anda memilih.**

| | jalan | lisensi hasil | ongkos |
|---|---|---|---|
| **(1)** ⭐ | LPC Revised (OGA-BY) + Mage City (CC0) + **pintu gambar sendiri** | **atribusi saja — tak menular** | +1 generator pintu |
| **(2)** | Tambah pack bluecarrot16 (Roofs/Walls/Windows&Doors) | **seluruh tileset & turunannya jadi CC-BY-SA** | nol gambar, lengkap seketika |
| **(3)** | Gambar seluruh fasad sendiri | milik penuh | jauh terbesar |

**Rekomendasi saya: (1).**
Ia memberi hampir seluruh keuntungan (2) tanpa mengunci seluruh seni dunia Aetherion ke SA,
dan lubangnya — pintu — kebetulan bagian termurah untuk digambar sendiri.

**Risiko kalau pilih (2):** SA menular ke **setiap** turunan. Begitu satu ubin bluecarrot16
masuk ke tileset Ashbrook, seni asli kita yang di-composite di atasnya ikut SA — termasuk
lentera, bangku, papan Otha, dan ubin tanah yang sudah kita gambar sendiri. Itu tak bisa
ditarik kembali setelah rilis.

⚠ Catatan: #254 memang mencabut #232 dan menerima SA. Jadi (2) **sah**. Saya tetap
menyarankan (1) karena SA yang **bisa dihindari tanpa ongkos berarti** sebaiknya dihindari —
menjaga pilihan tetap terbuka lebih murah daripada membukanya kembali nanti.
