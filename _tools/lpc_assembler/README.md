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

## Celah jujur (status 2026-07-24, #278)
1. ~~Skin 1-tone~~ **TUTUP (#278-2).** Field `skin` berefek: badan+kepala diambil dari
   pustaka chargen per-warna (22 nada). Baris expanded pada bases per-skin dilengkapi
   `_tools/lengkapi_expanded_skin.py` (LUT dari baris klasik yang sejajar, deterministik).
   Skin tak dikenal = HARD FAIL. Test: `test_skin_*` (3).
2. ~~Slice sit belum dikalibrasi~~ **TUTUP (#278-2).** Baris expanded dikalibrasi MATA
   dari sheet rakitan nyata (bukti `reports/preview/expanded_rows_0/1.png`):
   b21 climb·6f | b22-25 idle·4f | b26-29 jump·5f | **b30-33 SIT** (f0-2; f3+ bangkit) |
   b34-37 run·8f | b38-41/42-45 tak dipetakan. Tebakan lama "sit di 22-25" = IDLE, salah.
   `sit`/`run`/`jump` kini di-slice.
3. **BARU — garmen tanpa baris expanded.** Keluarga `longsleeve_*` (undershirt male!) &
   `pants2_male_*` di pustaka eulpc kosong di baris 21+; keluarga `longsleeve2_*` penuh.
   Perakit kini MELEWATI slice expanded bila garmen terpakai bolong (dan menghapus slice
   telanjang lama) — anak-anak dapat sit/run/jump penuh, 5 tokoh dewasa tertahan.
   Jalan keluar: tarik lapisan longsleeve male dari rilis ULPC-expanded lebih baru, ATAU
   Designer menukar undershirt tokoh ke keluarga yang punya baris expanded.
4. **horns first-pass.** Terbaca (hitam/kontras) tapi posisi di **sisi kepala**; sapuan-atas bisa diperkuat.
5. **Prop di semua frame.** basket/lantern ditaruh per-sel di walk/idle (motif pembukti). Pelacakan-tangan
   per-frame penuh (lentera ikut tangan tiap langkah) = langkah seni berikutnya.
6. **Kredit per-lapisan.** `credits_db.json` belum diisi → manifest flagged `[TODO]`. Wajib sebelum rilis (SA).
