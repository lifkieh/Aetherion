# Perakit sprite LPC — `_tools/lpc_assembler/`

Design-time (#162). JSON per-karakter → sheet 832×2944 flatten + slice per-animasi + manifest kredit.
Mesin **menumpuk lapisan yang sudah ada**; ia tak menggambar (overlay digambar `gen_overlays.py`).

## Pakai
```bash
# satu tokoh
python assemble.py characters/merrit_fane.json --out ../../game/assets/game/sprites/characters/
# semua tokoh + guard_231 lintas-tokoh (WAJIB dipakai utk tokoh bernama)
python assemble.py --all characters/ --out ../../game/assets/game/sprites/characters/
# slice saja (tanpa sheet penuh)
python assemble.py --all characters/ --out ../../game/assets/game/sprites/characters/ --no-sheet
```

## Hukum dikodekan
- **#231 HARD-FAIL** — dua tokoh **bernama** berbagi hook `hair`/`headwear` → `AssemblyError`, rakit batal.
  Botak (`hair=null,headwear=null`) = hook unik per-id. Cacat asli: Merrit↔Halloran kembar.
- **#232 struktural** — `--out` wajib `.../characters/`; kalau bukan → tolak. Uji CI menyisir `sprites/`
  dan gagal bila PNG turunan-LPC / berkas SA bocor ke `tiles/` atau `ui/`.
- **SA** — tiap sprite bawa `<id>.credits.txt` + `LICENSE-CC-BY-SA.txt`. Lapisan tanpa kredit tercatat
  ditandai `[TODO kredit]` (lengkapi `credits_db.json` sebelum rilis).

## Test
```bash
python test_perakit.py    # 13 test hijau (guard 231/232, z-order, roundtrip, leak-scan)
```

## File
- `assemble.py` — CLI + core (z-order §3, palette_shift, tint, padding 1344→2944, slice).
- `catalog.json` — slot → nama lapisan (relatif `assets_raw/lpc_extra`). `@overlay/x` = overlay digambar.
- `frame_map.json` — baris/frame animasi utk slice.
- `gen_overlays.py` — gambar horns/leaf_hair/bark_skin + props (basket/lantern+glow); alignment dari siluet badan.
- `overlays/` — hasil gambar (di-commit; design-time artefak).
- `characters/*.json` — 6 tokoh Ashbrook.
- `credits_db.json` (opsional) — kredit per-file → manifest.

## Katalog vs putusan
- Format lapisan: **`eulpc_*` 832×2944** (kanonik #233). Lapisan klasik 832×1344 (hijab, staff, apron, beard)
  **ditempel rata-atas** → baris 0-20 (spellcast/thrust/walk/slash/shoot/hurt) sejajar.
- Dryad = **human-body + bark/leaf overlay** (putusan Direktur, bukan faun). `race_overlay:["bark_skin","leaf_hair"]`.
- Merrit = botak + prop **LAMPU = scene** (bukan overlay sprite). Surat dicoret.

## Celah jujur (belum tuntas — untuk Direktur)
1. **Skin 1-tone.** Pustaka `eulpc_body_*` cuma satu warna kulit → field `skin` belum berefek.
   Butuh badan per-skintone (Death's Darling) diekstrak & dipetakan ke katalog.
2. **Slice sit-frame belum dikalibrasi.** Baris expanded (sit/run/jump, baris 21-45) di `frame_map.json`
   ditandai `calibrate:true` → belum di-slice. **walk + idle andal.** Merrit/Otha "duduk" ada di **sheet penuh**
   tapi slice sit menunggu verifikasi baris. Kalibrasi = render tiap baris expanded, cocokkan nama.
3. **horns first-pass.** Terbaca (hitam/kontras) tapi posisi di **sisi kepala**; sapuan-atas bisa diperkuat.
4. **Prop di semua frame.** basket/lantern ditaruh per-sel di walk/idle (motif pembukti). Pelacakan-tangan
   per-frame penuh (lentera ikut tangan tiap langkah) = langkah seni berikutnya.
5. **Kredit per-lapisan.** `credits_db.json` belum diisi → manifest flagged `[TODO]`. Wajib sebelum rilis (SA).
