# AUDIT ARSITEKTUR + INVENTARIS ERA-16px — #281/#279 (2026-07-24)

> Perintah Direktur: *"audit arsitektur kode ini, perbaiki menjadi maintainable...
> hapus aja world yang 16px atau ubah asset2nya... dasar-dasarnya maintain dan
> updateable, rencana develop jangka panjang."*
> Laporan = keadaan NYATA (diukur dari disk/kode, bukan ingatan) + apa yang SUDAH
> diperbaiki ronde ini + peta kerja sisa berurutan. Nol tebakan.

## A. Yang SUDAH dibayar ronde ini (commit a55994d · 64afc40 · 39eb788 · ronde ini)

| Utang | Status |
|---|---|
| Player 32px `_charsys` di kota 64px (bug "mengecil") | **TUTUP** — Player memilih LpcGen utk config ber-`build`; offset diukur dari frame |
| Panel chargen menumpuk saat klik cepat | **TUTUP** — rebuild sinkron, test `_test_chargen_no_stack_280` |
| Monster: 60 spesies pose-statis DCSS 32px→64px blok | **TUTUP** — 60 lembar LPC beranimasi 4-arah, `gen_monster_lpc.py`, arah dipetakan MATA |
| Perakit: `skin` tak berefek | **TUTUP** — 22 nada kulit, HARD FAIL utk skin tak dikenal |
| Perakit: baris expanded tak terkalibrasi | **TUTUP** — sit b30-33 · run b34-37 · jump b26-29 (bukti mata) |
| Kredit SA `[TODO]` di 130 manifest | **TUTUP** — `isi_kredit.py` + CREDITS.csv ULPC resmi (beku di repo) |
| Potret HUD = gumpalan 16px hijau utk semua pemain | **TUTUP** — potret dipotong dari wajah LPC pemain sendiri |
| CLAUDE.md memuat hukum skala yang sudah dicabut (#253) | **TUTUP** — blok #256 terpasang, sejarah keputusan tercatat (#282) |

## B. INVENTARIS ERA-16px yang MASIH HIDUP (#279 — diukur 2026-07-24)

Tiga zaman aset hidup berdampingan; kanon #256: **dunia 32px · karakter/monster 64px**.

| Kantong 16px | Isi | Dipakai oleh | Nasib usulan |
|---|---|---|---|
| `sprites/props/` | 66 PNG (barrel 13×16 dst.) | Greenvale/Town lama, sebagian dipakai Ashbrook64 dgn pengali skala | ganti bertahap ke `lpc32/` (pola `barrel_lpc` 32×64 sudah ada — dua generasi sudah berdampingan) |
| `tiles/` akar | ~8 ubin (grass/dirt/cobble/field) | Greenvale (`Main.gd`) — **wilayah BEKU** | ikut migrasi wilayah (D di bawah) |
| ~~`tiles/dungeon/`~~ | ~~7 ubin 16px~~ | **MIGRASI SELESAI (R1 #286, 2026-07-25)** — ubin 32px prosedural (`gen_tiles_dungeon32.py`), pemain platformer = LPC 64, fisika ×2, kamera 1.5. Gudang/OGA nihil tileset gua side-view → prosedural sah per #279. Sisa kecil: obor masih 16px di-skala 2 (gambar obor 32 menyusul); blok bijih "melayang" = keanehan layout LAMA (ada juga di 16px). | — |
| `tiles/desert/` · `tiles/candyveil/` | ubin wilayah | Desert, Candyveil | ikut migrasi wilayah |
| `sprites/player/` (walk/idle/attack/dead 16px) | 4 PNG | ~~PlayerPlatformer~~ **(migrasi R1 — kini LPC)** · Guard.gd:29 · EchoVendor.gd:22 · Main.gd:115 (cadangan HUD) | sisa pemakai = wilayah beku; mati saat R2 Greenvale |
| HUD potret | ~~idle.png 16px~~ | ~~HUD.gd:99~~ | **SUDAH DIGANTI** (wajah LPC) |

**Kenapa tidak dihapus sekaligus sekarang:** Greenvale/Desert/Candyveil/Frostpeak/Storm
adalah wilayah yang MASIH dimuat dari save lama dan dijaga test
`_test_frozen_regions_stay_charsys`. Menghapus asetnya = mematahkan wilayah hidup tanpa
pengganti. Jalur benar = migrasi PER-WILAYAH (pola Ashbrook→Ashbrook64 yang terbukti),
lalu hapus aset lama + test bekunya SESUDAH wilayah barunya lahir. Itu keputusan
per-wilayah Direktur (urutan usulan di D).

## C. AUDIT ARSITEKTUR — temuan terukur

### C1. Angka dasar
- **48 autoload** di project.godot — sangat gemuk. Tiap autoload = state global hidup
  di semua scene. Kandidat penggabungan/demosi: `FishingUI`, `PhotoMode`, `DebugOverlay`,
  `CombatFeel`, `Onboarding` (fitur-UI, bukan service); `SafeZone`+`ForestSpiritSystem`+
  `MiracleSystem` (domain dunia yang bisa di bawah `WorldState`).
- **`Ashbrook64.gd` = 2.385 baris** — kota + tata letak + gerbang + wisp + hewan +
  bukti + treeline dalam satu berkas. Pecahan alami: `Ashbrook64Layout` (blockout/petak),
  `Ashbrook64Life` (hewan/warga/wisp), `Ashbrook64Evidence` (titik periksa) — TANPA
  mengubah perilaku, pindahan fungsi murni.
- `TestRunner.gd` 5.000+ baris / 115 test — masih satu berkas; bisa dipecah per-domain
  kalau mulai menyakitkan, TAPI gerbang #249/#273 bergantung format keluarannya —
  pecah = sentuh gerbang, jadi jangan disentuh tanpa ronde khusus.
- 31 berkas `data/*.json` — data-driven sehat ✓. `monsters.json` kini sinkron dgn disk.

### C2. Dualitas sistem karakter (BY DESIGN, tapi kini bisa disempitkan)
`CharGen` (32px prosedural) + `LpcGen` (64px LPC) hidup berdampingan — dulu sengaja
(migrasi bertahap, wilayah beku). Kini pemain & Ashbrook64 sepenuhnya LPC. Sisa pemakai
`_charsys`: Villager tanpa `lpc_sheet` (Greenvale), Cermin Jiwa edit save lama, chargen
fallback. **Usul:** biarkan sampai migrasi wilayah selesai, lalu pensiunkan CharGen
sekali jalan (satu ronde, satu commit, test ikut).

### C3. Duplikasi & jahitan yang kelihatan
- **Urutan lapis LPC ditulis 2×**: `LpcGen._lapis()` (GDScript) dan `assemble.py`
  `_layer_plan()` (Python). Komentar keduanya saling menunjuk ✓ tapi tak ada test yang
  MEMBANDINGKAN hasilnya. Usul test: rakit config sama di kedua jalur → diff piksel ≤ ambang.
- **Peta baris sheet ada 3×**: `frame_map.json` (perakit) · `LpcGen` (hardcode 8..15) ·
  `SheetUtil.DIRS`. Satu sumber: LpcGen baca `frame_map.json` (res:// copy) — perubahan kecil.
- **Ukuran petak dunia**: `TILE := 32` hidup di beberapa scene world sebagai konstanta
  lokal. Tarik ke satu tempat (`WorldConst` atau `Db`).

### C4. Yang SEHAT dan patut dipertahankan (jangan "dirapikan")
- Hukum-hukum ber-test (#151b/#231/#232/#240/#249/#273) — pagar yang benar-benar menggigit.
- Data-driven `data/*.json` + generator `_tools/*` ter-commit (#240) — reproducible.
- Pola opt-in (`lpc_sheet` di Villager) — migrasi tanpa memecahkan wilayah beku.
- EventBus + jalur-pemain di test — jangan ditukar dengan panggilan langsung.

## D. URUTAN KERJA SISA (usulan, menunggu putusan Direktur)

1. **Migrasi dungeon → 32px side-view** (buru tileset dulu; platformer player ikut LPC di sini)
2. **Migrasi Greenvale** (wilayah start lama; pola Ashbrook64; sesudahnya Guard/EchoVendor/
   idle.png 16px mati alami)
3. **Desert · Candyveil · Frostpeak · Storm** satu per satu (aset dunia 32px dari gudang/OGA)
4. **Pensiun CharGen + hapus `sprites/props` 16px + `tiles/` lama + test beku** (sesudah 1-3)
5. **Diet autoload 48 → ±30** (gabung/demosi; per-langkah, suite hijau tiap commit)
6. **Pecah Ashbrook64.gd** (3 berkas, pindahan murni)
7. Test paritas LpcGen↔assemble + satu sumber frame_map (C3)
8. Wardrobe expanded 5 tokoh (celah perakit #3 — keputusan Designer)
9. Sumber seni yang masih gap: hawk/roc besar, elemental sejati, pari, belut (README monster)

## E. Kejujuran batas
- "Maintainable" ≠ selesai satu ronde. Ronde ini menutup **fondasi visual + lisensi +
  bug dasar**; butir D adalah pekerjaan bertahap yang tiap langkahnya bisa diverifikasi
  suite. Yang berbahaya justru merombak 48 autoload atau memecah 2.400 baris dalam satu
  malam tanpa gerbang — itu cara menghasilkan regresi, bukan kerapian.
