# FAKTA UNTUK DESIGNER — read-only, path + baris

**Dibuat:** 2026-07-19 · **Nol perubahan kode.** Semua klaim disertai path:baris.
Yang tak ada di kode ditulis **TIDAK ADA DI KODE** — tidak disimpulkan dari ledger.

---

# BAGIAN A — CHRONICLE

## A.1 `strike()` — `game/autoload/Chronicle.gd:128-138`

```gdscript
func strike(id: String, cause: String = "kabut") -> bool:
	for e in WorldState.chronicle:
		if e.get("id", "") == id and e.get("state", ST_WRITTEN) == ST_WRITTEN:
			e["state"] = ST_STRUCK
			e["struck_at"] = GameClock.date_string()
			e["struck_cause"] = cause
			# R3 — dunia mulai melupakan SAAT halaman dicoret (bukan saat find).
			Evidence.start_decay_clock(id)
			EventBus.chronicle_struck.emit(id)
			return true
	return false
```

**Argumen:** `id` (halaman), `cause` (default `"kabut"`).
**Yang diubah:** state `written→struck` di `WorldState.chronicle`; stempel `struck_at` (tanggal WIB);
`struck_cause`; **memulai jam pembusukan** (`Evidence.start_decay_clock`); emit `EventBus.chronicle_struck`.
**UI: NOL.** Komentar `Chronicle.gd:120-127` menyatakan eksplisit:

> `## fungsi ini DILARANG memanggil Stage.banner / EventBus.toast / Audio.play_stinger / Cutscene.play.`
> `## **Nol umpan balik.** Buku berubah diam-diam, dan pemain yang tidak memperhatikan tidak akan pernah tahu.`
> `## Dijaga _test_strike_is_silent(). Preseden: #210, White Stag #216.`
> `## cause dicatat untuk keperluan internal — **tak pernah ditampilkan.** (#229.4)`

## A.2 `restore()` — `game/autoload/Chronicle.gd:157-175`

```gdscript
func restore(id: String, witnesses: Array, scribe: String = SCRIBE_SELF) -> Dictionary:
	var e := _find(id)
	if e.is_empty():                        return {"ok": false, "reason": "not_found", "loss": ""}
	if e.get("state", "") != ST_STRUCK:     return {"ok": false, "reason": "not_struck", "loss": ""}
	var kinds := _kinds_of(witnesses)
	var needed: int = SCRIBE_KINDS_NEEDED.get(scribe, 3)
	if kinds.size() < needed:               return {"ok": false, "reason": "need_%d_kinds" % needed, "loss": ""}
	e["state"] = ST_RESTORED
	e["restored_at"] = GameClock.date_string()
	e["scribe"] = scribe
	e["witnesses"] = witnesses.duplicate(true)
	e["loss"] = _compute_loss(e, kinds, scribe)
	EventBus.chronicle_restored.emit(id, e["loss"])
	return {"ok": true, "reason": "", "loss": e["loss"]}
```

**Konstanta terkait** (`Chronicle.gd:36-52`):
`EVIDENCE_KINDS = ["benda","kebiasaan","akibat","orang"]` ·
`ST_WRITTEN/ST_STRUCK/ST_RESTORED` ·
`SCRIBE_SELF="self"` (3 jenis) · `SCRIBE_ELYN="elyn"` (2) · `SCRIBE_SORA="sora"` (2).

**Yang diubah:** state → `restored`; `restored_at`; `scribe`; salinan `witnesses`; **`loss`** dari
`_compute_loss()` (`Chronicle.gd:197`); emit `EventBus.chronicle_restored(id, loss)`.

## A.3 Apa yang terjadi secara VISUAL saat tercoret → pulih

**Kode yang menjawab, bukan deskripsi:**
- **Saat tercoret: TIDAK ADA APA-APA di layar.** Dijamin oleh komentar `Chronicle.gd:120-127` +
  test `_test_strike_is_silent()`.
- **Satu-satunya konsumen sinyal:** `Evidence.gd:170` `func _on_restored(_id, _loss)`.
- **UI Chronicle-kehilangan: TIDAK ADA DI KODE.** Grep `chronicle` di `game/scenes/ui/*.gd`
  hanya menemukan `MenuUI.gd:544 Chronicle.entries()` — dan itu di `_build_pedia()`
  ("Pencapaian Tercatat", benih #96), **bukan** kitab kehilangan R1/R2/R3.
- Tampilan `struck`/`restored` (coretan, tulisan tangan berbeda) = **spec** di
  `docs/R1_SPEC_TEKNIS.md:173`, **belum dikode**.

## A.4 SEMUA call-site `strike` / `restore`

| Lokasi | Produksi / Test |
|---|---|
| `game/tests/TestRunner.gd` — baris 3950 · 3958 · 3971 · 4033 · 4041 · 4049 · 4054 · 4065 · 4068 · 4076 · 4099 · 4100 · 4146 · 4158 · 4159 · 4292 · 4297 · 4303 · 4481 · 4500 · 4551 · 4573 | **TEST** |
| `game/tests/VerifyLoop64.gd:84, 86` | **HARNESS** (dibuat 2026-07-19) |
| `game/autoload/Evidence.gd:33, 81, 127` | **komentar saja**, bukan pemanggilan |

**Scene produksi: NOL pemanggilan.** Tidak ada satu pun `.gd` di `game/scenes/` yang memanggil
`strike()` atau `restore()`.

---

# BAGIAN B — HUKUM BUKTI #226 + 14 BUKTI

## B.1 Definisi

- **`game/autoload/Evidence.gd`** — `found:27` · `decayed:30` · `_clock_start:35` ·
  `find():55` · `has():69` · `start_decay_clock():88` · `_effective_days():95` ·
  `is_decayed():105` · `for_page():128` · `kinds_for():142` · `enough_for():149` ·
  `_on_restored():170` · `to_save():178` · `from_save():185`
- **`game/scenes/world/Interactable.gd`** — `kind:8` · `evidence_id:12` ·
  `examine_notice():152-162` · cabang `examine` di `_build():83-88` · `interact():167-172`

## B.2 Keempat belas bukti — dan status wiring

| id | jenis | halaman | Ashbrook 16px | Ashbrook64 |
|---|---|---|---|---|
| ev_otha_papan_bekas_cat | akibat | person_otha_renn | ✅ | ✅ |
| **ev_otha_bangku_cekungan** | kebiasaan | person_otha_renn | ❌ | ❌ |
| **ev_otha_jahitan_mantel_merrit** | benda | person_otha_renn | ❌ | ❌ |
| **ev_otha_nyai_tuminah_kamis** | orang | person_otha_renn | ❌ | ❌ |
| **ev_merrit_kartu_pos_kosong** | benda | person_merrit_fane | ❌ | ❌ |
| **ev_merrit_cangkir_kedua** | kebiasaan | person_merrit_fane | ❌ | ❌ |
| **ev_merrit_rute_pos_berubah** | akibat | person_merrit_fane | ❌ | ❌ |
| **ev_merrit_arlen_ingat** | orang | person_merrit_fane | ❌ | ❌ |
| ev_ashbrook_jembatan_terlalu_lebar | akibat | place_ashbrook_besar | ✅ | ✅ |
| ev_ashbrook_gudang_gandum | akibat | place_ashbrook_besar | ✅ | ✅ |
| ev_ashbrook_halloran_200_roti | kebiasaan | place_ashbrook_besar | ✅ | ✅ |
| ev_ashbrook_fondasi_rumput | akibat | place_ashbrook_besar | ✅ | ✅ |
| ev_ashbrook_batu_fondasi | benda | place_ashbrook_besar | ✅ | ✅ |
| **ev_ashbrook_bram_ingat_ayahnya** | orang | place_ashbrook_besar | ❌ | ❌ |

**8 tak ter-wire** (tebal). Pola: **halaman `person_otha_renn` 1/4 · `person_merrit_fane` 0/4 ·
`place_ashbrook_besar` 5/6.** Jenis `orang` **tak pernah ter-wire sama sekali** (3 dari 3 hilang).

**Terhubung ke strike/restore?** Semua 6 yang ter-wire hanya terhubung ke `Evidence.find()`
lewat `Interactable.examine_notice()`. **Nol** di antaranya memicu `strike`/`restore` —
lihat A.4.

## B.3 Teks #226 — `CLAUDE.md:617` dan `docs/CANON_219-230_FINAL.md:175`

Kutipan dari komentar kode `Chronicle.gd:146-153`:

> `## #226 HUKUM BUKTI — tiga aturan keras:`
> `##   1. minimal N jenis bukti BERBEDA (N per juru tulis — #228)`
> `##   2. bukti boleh berbohong: Chronicle mencatat PILIHAN pemain, bukan kebenaran`
> `##   3. halaman pulih TIDAK PERNAH identik — selalu ada loss`
> `## #228 HUKUM TAGLINE — Elyn bukan satu-satunya jalan. SCRIBE_SELF selalu`
> `## tersedia: lebih mahal (3 jenis), loss terbesar, tulisan tangan berantakan.`
> `## **Dan itu tetap sah. Dunia mengingat versi pemain.**`

Dan `Evidence.gd:177-178`:
> `## #226 #1: "Satu bukti tak pernah cukup. Ingatan itu jaringan, bukan item."`

---

# BAGIAN C — ELYN

**Koreksi laporan saya sebelumnya.** Saya pernah menulis "Elyn hanya muncul di Chronicle.gd,
Evidence.gd, TestRunner.gd". Itu benar **untuk kode**, tapi menyesatkan: Elyn **sangat terkanonkan
di dokumen.**

**DI KODE — hanya disebut, nol node/scene/dialog:**
| Path:baris | Konteks |
|---|---|
| `Chronicle.gd:45` | `const SCRIBE_ELYN := "elyn"` — 2 bukti, loss terkecil |
| `Chronicle.gd:49-52` | `SCRIBE_KINDS_NEEDED` (self=3, elyn=2, sora=2) |
| `Chronicle.gd:74, 151, 244-245` | komentar |
| `Evidence.gd:166` | komentar |
| `TestRunner.gd:4044, 4050, 4058, 4081, 4228, 4232, 4471, 4473, 4498, 4499, 4502` | test |

**Node Elyn: TIDAK ADA DI KODE.** Scene: TIDAK ADA. Dialog: TIDAK ADA.
Perpustakaan/Sylvara: TIDAK ADA sebagai scene. Laci: TIDAK ADA.

**DI DOKUMEN — kanon tebal:**
- `docs/Companion_bible/companion_02_elyn_thornewood.md` — sheet penuh (elf, 134 th, Penjaga Arsip
  Sylvara, ceiling **690**, arc 6 tahap, relasi Sora/Torgrim/Merrit/Wren)
- `docs/FACTION_BIBLE.md:132, 144-167` — **#205: Elyn = PEMBANGKANG Chronicle Order** (ratifikasi)
- `docs/A3_TRIASE.md` — adegan TRIASE penuh; `:257-266` menandai **"laci Elyn = paling penting"**
- `docs/CHRONICLE_RESTORATION_SPEC.md:262-266` — **"HARGA ELYN" masih berlabel `[BARU — usul,
  butuh putusan]`** → **kanon menggantung**
- Ledger `#205` (meja-Elyn), `#209` (kalimat kunci jadi kanon), `#248` (laci TERBLOKIR — nol perpustakaan)

---

# BAGIAN D — SILUET #231

## D.1 `guard_231` — `_tools/lpc_assembler/assemble.py:216-234`

```python
def guard_231(named_chars):
    """#231: dua tokoh bernama berbagi hook rambut/tutup-kepala -> HARD FAIL.
    Botak (hair=null, headwear=null) diperlakukan UNIK per-id (tak bentrok).
    """
    seen = {}
    for c in named_chars:
        if not c.get("named"): continue
        key = c.get("headwear") or c.get("hair")
        if key is None: key = f"__bare__:{c['id']}"
        else:           key = f"hook:{key}"
        if key in seen:
            raise AssemblyError(f"#231 DILANGGAR: '{c['id']}' dan '{seen[key]}' berbagi hook kepala '{key}'. ...")
        seen[key] = c["id"]
```

**⚠ Batas guard yang menjelaskan lolosnya Halloran↔Bram:** guard hanya membandingkan **string id
lapisan**, bukan **bentuk siluet**. `curly_short` ≠ `curly_short2` sebagai string → **lolos**.
Dalam siluet hitam, keduanya menghasilkan massa rambut bulat yang nyaris identik, dan **janggut
Bram tak terlihat sama sekali** karena berada di dalam kontur kepala.

## D.2 Data dua tokoh

`_tools/lpc_assembler/characters/halloran.json`:
```json
{"id":"halloran","named":true,"race":"human","body":"male","head":"male","skin":"light",
 "hair":"curly_short","headwear":null,"facial":{"beard":null},
 "torso":"overalls","apron":"male","legs":"pants_thin","feet":"shoes_thin",
 "race_overlay":[],"story_prop":[],"palette_shift":null,
 "_hook":"celemek (apron). Hook kepala = curly_short (BEDA dari Merrit botak — cacat kembar #231 dihindari by design)."}
```
`_tools/lpc_assembler/characters/old_bram.json`:
```json
{"id":"old_bram","named":true,"race":"human","body":"male","head":"male","skin":"light",
 "hair":"curly_short2","headwear":null,"facial":{"beard":"white"},
 "torso":"overalls","legs":"pants_thin","feet":"shoes_thin",
 "race_overlay":[],"story_prop":[],"palette_shift":null,
 "_hook":"janggut putih (beard=white). Sang Penempa (echo_bramm)."}
```
Keduanya `torso: "overalls"`. Halloran punya `apron:"male"`, Bram tidak.
**Keduanya `palette_shift: null`** — lihat F.3.

## D.3 Berkas bukti

| Path | Ada? |
|---|---|
| `reports/preview/siluet231.png` | **TIDAK ADA DI REPO** — dibuat di scratchpad, tak pernah disalin ke `reports/` |
| `reports/preview/merrit_fix.png` | ✅ ada (uji botak/datar/keriting, #237) |
| `reports/preview/final_merrit.png` | ✅ ada — **referensi overall DENIM** |
| `reports/preview/final_6_lineup.png` | ✅ ada (#237 Merrit≠Halloran) |

---

# BAGIAN E — ASHBROOK64 + FASAD LPC

## E.1 Struktur `game/scenes/world/Ashbrook64.tscn` — **seluruh isinya**

```
[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://scenes/world/Ashbrook64.gd" id="1"]
[node name="Ashbrook64" type="Node2D"]
script = ExtResource("1")
```
**Satu node.** Semua dibangun runtime oleh `Ashbrook64.gd`.

## E.2 Aset "bangunan" yang dipakai sekarang — `Ashbrook64.gd:100-111`

| Baris | Aset | Peran yang diklaim |
|---|---|---|
| 101 | `sprites/lpc32/wall_inn.png` | rumah singgah Merrit |
| 103 | `sprites/lpc32/wall_brick.png` | gudang gandum |
| 104 | `sprites/lpc32/wall_wood.png` | toko Otha |
| 105 | `sprites/lpc32/wall_inn.png` | rumah kosong |
| 106 | `sprites/lpc32/wall_inn.png` | rumah Lyra |

**Semuanya PANEL DINDING, bukan fasad.** Nol atap, nol pintu → terbaca sebagai tembok, bukan rumah.

## E.3 Inventaris atlas Mage City — koordinat 32px terverifikasi

Sumber: `assets_raw/lpc/magecity.png` (256×1450 = **8 kolom × 45 baris**).
Yang **sudah** dipotong (`_tools/gen_lpc32_slices.py:48-62`):

| nama | kolom,baris | ukuran |
|---|---|---|
| grass32 | (0,0) | 32×32 |
| cobble32 | (1,9) | 32×32 |
| stone32 | (1,1) | 32×32 |
| wall_inn | (0,4) 4×2 | 128×64 |
| fountain | (6,2) 2×2 | 64×64 |
| bench_lpc | (7,0) | 32×32 |
| barrel_lpc | (4,2) 1×2 | 32×64 |
| wall_wood | (0,23) 3×3 | 96×96 |
| wall_brick | (4,26) 4×3 | 128×96 |
| wall_ruin | (4,23) 4×3 | 128×96 |
| window_lpc | (1,21) 2×1 | 64×32 |
| tree_lpc | (3,17) 2×2 | 64×64 |
| table_lpc | (1,16) | 32×32 |

**BELUM dipotong — kandidat untuk merakit fasad** (dibaca dari peta kisi
`magecity_grid_0/1.png`, belum diekstrak):
- **Dinding batu pasir** — kolom 0–7, **baris 4–5** (sebagian sudah jadi `wall_inn`)
- **Panel kayu bertekstur/atap miring** — kolom 0–2 & 4–7, **baris 23–25**
- **Bata besar berlumut** — kolom 4–7, **baris 26–28**
- **Jendela** — kolom 0–3, **baris 19–22** (banyak varian)
- **Pintu/gerbang: BELUM DITEMUKAN** di peta kisi yang sudah dirender (baris 30–45 belum
  diperiksa — `magecity_grid_2.png` belum dilihat).

⚠ **Atap miring jadi: BELUM TERKONFIRMASI ADA** di Mage City. Perlu diperiksa baris 30–45,
atau diambil dari pack LPC lain (`[LPC] Terrains` / LPC Tile Atlas — lihat `reports/BURU_ASET_64.md`).

## E.4 Bug overall Merrit — krem vs denim

`_tools/lpc_assembler/assemble.py`:
- `:94` `def _palette_shift(im, mode)` — fungsi **ADA**
- `:100` `raise AssemblyError(f"palette_shift tak dikenal: {mode}")`
- `:113` `pshift = char.get("palette_shift")`
- `:133` komentar `# 2 badan (+ palette shift / bark skin overlay)`
- `:146` komentar `# 7 kepala (+ palette shift)`
- `:183` `im = _palette_shift(im, tint.split(":", 1)[1])`

**Temuan:** `palette_shift` **jalan**, tapi **`merrit_fane.json` menyetelnya `null`** —
sama seperti `halloran.json` dan `old_bram.json`. Jadi lapisan warna **tidak di-skip oleh bug**;
ia **tidak pernah diminta**. Warna overall datang langsung dari aset `torso: "overalls"` di ULPC.

**Artinya:** `final_merrit.png` (denim, #237) **dirakit dengan cara lain** — kemungkinan
lapisan/varian warna berbeda, atau script sekali-pakai yang kini lenyap (#240; 43 dari 45 PNG
di `reports/preview/` tak punya generator). **Selisih ini belum bisa direproduksi.**

---

# BAGIAN F — LEDGER: ENTRI YANG DIMINTA

⚠ **Hasil grep `^| N |` pada `PLAN_LEDGER.md`:**

| # | Status |
|---|---|
| **#226** | **TIDAK ADA baris ledger.** Ada sebagai HEADING kanon: `CLAUDE.md:617` · `docs/CANON_219-230_FINAL.md:175` |
| **#228** | **TIDAK ADA baris ledger.** Heading: `docs/CANON_219-230_FINAL.md:19, 210` |
| **#229** | **TIDAK ADA baris ledger.** Heading: `docs/CANON_219-230_FINAL.md:24, 252` |
| **#231** | **TIDAK DITEMUKAN** sebagai baris ledger **maupun** heading kanon. Hanya dirujuk (kode `assemble.py:216`, komentar, laporan). **Kanon menggantung.** |
| **#254** | **TIDAK ADA baris ledger.** Keputusan dijalankan (commit `1d4aef6`, `8aaa014`) tapi **barisnya tak pernah ditulis** — **melanggar aturan ledger (a)**. Ini kelalaian saya. |
| #237 · #240 · #249 · #250 · #253 · #255 | **ADA** — disalin utuh di bawah |

Teks utuh #237, #240, #249, #250, #253, #255 tersedia di `PLAN_LEDGER.md` (grep `^| 237 |` dst).
Ringkas judulnya:
- **#237** — Merrit diperbaiki (BOTAK); spec 4 prop identitas; Astralborn overlay TERBUKTI
- **#240** — HUKUM REPRODUKSI: tiap gambar wajib bawa script pembuatnya
- **#249** — GERBANG TEST = 0 GAGAL, bukan jumlah lulus
- **#250** — LPC 64px = sumber karakter tunggal; `_charsys` dipensiunkan
- **#253** — AETHERION TETAP 16px (**dicabut oleh #254**)
- **#255** — PORTRAIT = gap identitas, buatan sendiri, ditangguhkan

---

# BAGIAN G — v0.5, GERBANG, PLATFORM

## G.1 Kriteria masuk/keluar v0.5

`docs/AETHERION_PROPOSAL_LENGKAP_FINAL.md:165`:
> `| **v0.5** | STORY & SOUL ⭐ | GERBANG MASUK: **Companion Bible (B17: 50 tokoh)** + **Nirnama Bible (B18)** selesai → Act 1 Memori-vs-Pelupaan …`

`docs/AETHERION_PROPOSAL_LENGKAP_FINAL.md:112` — `## 3.9 CERITA (v0.5; gerbang: B17+B18)`

**Kriteria KELUAR v0.5 yang eksplisit: TIDAK DITEMUKAN.** Yang ada hanya gerbang **MASUK**.
Kriteria keluar terdekat = checklist v1.0 (`§6.1`, 10 "perasaan").
**Status B17: 15/50** (`docs/COMPANION_BIBLE.md:3`). **B18:** `docs/NIRNAMA_BIBLE_PUBLIC.md`
**v2.1, 369 baris, 18 bab** — tampak lengkap; **status "selesai" tak dinyatakan eksplisit.**

## G.2 Gerbang "playtest" — dan **koreksi laporan saya**

Kolom `Gerbang` di tabel roadmap (`:160-175`) berisi literal `playtest` untuk v0.4.2/0.4.3/0.4.4.
**Definisi operasional "playtest": TIDAK ADA DI DOKUMEN** — tak ada checklist, tak ada format laporan.

**⚠ KOREKSI:** di `reports/PROJECT_SNAPSHOT.md` saya menulis "nol catatan playtest manusia".
**Itu salah.** Catatan playtest owner ADA di `STATUS.md`:
- `:476` — *"Menanggapi playtest owner ('world building kurang, kurang bangunan, UI kurang banget')"*
- `:535` — *"Playtest owner: 'game terasa HAMPA'. Semua konten baru DIBEKUKAN."*
- `:286` — *"playtest gamepad oleh owner — tiga bug fatal lolos 822 test"*
- `:133` — *"⏳ Menunggu playtest owner"* · `:275` — *"SISA GERBANG v0.5: … + playtest gamepad owner"*

Jadi: **playtest owner pernah dilakukan dan mengubah arah proyek.** Yang benar-benar nihil adalah
**laporan playtest terstruktur** dan **playtest untuk v0.4.2–v0.4.4 secara spesifik**.

## G.3 Platform & build

- **`game/export_presets.cfg` ADA.** (isi belum saya baca detail — belum diminta)
- `game/project.godot:212` — `renderer/rendering_method.mobile="gl_compatibility"` → jalur mobile disiapkan
- `project.godot:10` — main scene `res://scenes/ui/MainMenu.tscn`

## G.4 Ikatan waktu WIB nyata — kode & test

**Kode:** `game/autoload/GameClock.gd` — `WIB_OFFSET := 7*3600` (`:5`) ·
`now_wib()` (`:38-40`) memakai `Time.get_unix_time_from_system()` **bukan** waktu palsu ·
`SEASON_EPOCH := 1767225600` (`:19`) · `KNOWN_NEW_MOON` (`:7`).

**Test yang mengukurnya:**
| Path:baris | Yang diuji |
|---|---|
| `TestRunner.gd:2522` | `check("musim = fungsi tanggal WIB (bukan acak)", GameClock.season() == s_now)` |
| `TestRunner.gd:2517` | komentar: 4 musim × 14 hari = 56 hari; tiap 14 hari WIB berganti |
| `TestRunner.gd:2672` | `rasi naik deterministik (minggu WIB)` |
| `TestRunner.gd:2870` | `entri memakai TANGGAL WIB NYATA` |
| `TestRunner.gd:2610` | peti: buka sekali per **hari WIB** |
| `TestRunner.gd:550, 554, 2539` | pertumbuhan tanaman dari `planted_at_unix` (waktu nyata) |

**⚠ Yang TIDAK diuji:** tak ada test yang mensimulasikan **game ditutup lalu dibuka lagi**
(mis. memundurkan `planted_at_unix` berhari-hari lalu memeriksa dunia sudah berubah).
Yang ada menguji **fungsi-dari-tanggal**, bukan **kesinambungan lintas-sesi**.
Ini juga sebab langsung ketidakstabilan jumlah test (#249).
