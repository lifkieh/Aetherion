# FAKTA DESIGNER — BATCH 4 (prep spec payoff)

Read-only. Nol perubahan kode. Semua klaim disertai `path:baris`.

---

# 1 — CHRONICLE_RESTORATION_SPEC.md

**Path:** `docs/CHRONICLE_RESTORATION_SPEC.md` · **335 baris** · status di baris 2:
> `## Core Loop Aetherion · Draft Designer v0.1 · menunggu ratifikasi Direktur`

**⚠ Spec ini masih DRAFT. Belum diratifikasi.** Penutupnya (`:333-335`):
> *"Dokumen ini adalah draft Designer. Setiap angka & mekanik adalah usul untuk diuji, bukan nilai final."*

## 1.1 Peta isi

| baris | bab |
|---|---|
| 15 | 0. TESIS SPEC INI |
| 32 | 1. LOOP INTI |
| 81 | 2. EMPAT WUJUD PENGHAPUSAN |
| 101 | **3. HUKUM BUKTI [BARU] — jantung sistem** |
| 131 | 4. HUKUM JALUR A / B / C (#5b) |
| 189 | 5. WILAYAH MEMUTIH |
| 218 | 6. EMPAT COMPANION = EMPAT PERAN MEKANIK |
| 237 | **7. UI — apa yang pemain lihat** |
| 252 | 8. HARGA |
| 272 | 9. THE FINAL SILENCE |
| 302 | **10. URUTAN BANGUN (R1–R10)** |
| 321 | 11. YANG BUTUH PUTUSAN DIREKTUR (D-1…D-6) |

## 1.2 Struktur data satu halaman Chronicle — **dari KODE**, bukan spec

`game/autoload/Chronicle.gd:79-97` (`_write()`):

```gdscript
var entry := {
    "id": id, "title": title, "kind": kind,
    "date": GameClock.date_string(), "time": GameClock.time_string(),
    "season": GameClock.season_name(), "by": PlayerData.char_name,
    "level": PlayerData.level,
    # --- R1 ---
    "state": ST_WRITTEN,
    "struck_at": "", "struck_cause": "",
    "restored_at": "", "scribe": "",
    "witnesses": [], "loss": "",
}
WorldState.chronicle.append(entry)
EventBus.chronicle_recorded.emit(id, title)
if celebrate: _celebrate(entry)
```

⚠ `_celebrate()` (`:99-100`) memanggil `Stage.banner(...)` — **hanya untuk `record()` biasa (deed).**
`record_person()` (`:76`) memanggil `_write(..., celebrate=false)`. Jadi halaman ORANG lahir diam.

## 1.3 R1 / R2 / R3 — definisi resmi (`:302-317`)

| Tahap | Isi | Sandaran |
|---|---|---|
| **R1** | `Chronicle.gd` + `strike(id)` & `restore(id, saksi[])`. UI coretan. **Belum ada kabut.** | ✅ |
| **R2** | Hukum Bukti: 4 jenis bukti sebagai data. Satu halaman uji coba di Ashbrook. | ✅ |
| **R3** | Wujud #4 (nama tak terucap) + #2 (halaman tercoret) di Ashbrook. **Nol teks on-screen.** | ✅ |
| R4 | **Jalur A1** — penghapusan pertama yang pemain lewatkan | R3 |
| R5 | **Elyn** + mekanik menulis ulang. **Jalur A3 (TRIASE)** | R2 |
| R6 | Sora + Lapis 2 kepekaan. Alarm pertama | R3 |
| R7 | **Jalur A2** — Merrit melupakan pemain | memori NPC v0.6 |
| R8 | Wilayah memutih (Ashbrook) | ✅ mesin sudah jadi |
| R9 | Jalur B ("Lampu yang Salah") + C ("Kesaksian Hujan") | R6, R7 |
| R10 | Lompatan Chronicle pertama. **Akhir Act 1** | #2 |

> *"Setelah R10: Ashbrook 100% jadi. Game bisa dimainkan, punya awal-tengah-akhir. Baru Valkaris."*

**Catatan penting:** kolom "Sandaran" mengklaim R1/R2/R3 ✅ — tapi itu **kesiapan mesin**,
bukan kesiapan jalur pemain. Lihat Bagian 3.

## 1.4 "Baris yang tak bisa ditulis ulang"

**TIDAK ADA istilah itu di spec.** Yang ada = **aturan keras #3** (`:125-127`):

> **3. Halaman yang ditulis ulang tidak identik dengan aslinya.** Selalu ada yang hilang.
> **[BARU]** Entri pulih ditandai halus: *"dipulihkan dari kesaksian"* — bukan *"dipulihkan"*.
> Dunia yang diingat kembali **bukan** dunia yang sama. Itu harga. (LAW OF ERAS: Loss & Continuation.)

Implementasinya di kode = field `loss` (`Chronicle.gd:173`, `_compute_loss()` `:197`).
Isi `loss` per halaman: `game/data/chronicle_losses.json`.

## 1.5 Hukum Bukti utuh (`:105-127`)

> ## **Ingatan tidak bisa dipulihkan dari ingatan. Hanya dari BEKAS.**

| Jenis | Contoh | Kenapa lolos dari kabut |
|---|---|---|
| **BENDA** | surat · mantel pos tua · kartu pinjam Wren · lentera | Benda tidak punya ingatan untuk dihapus |
| **KEBIASAAN** | Merrit menyalakan lampu tiap malam dan **tidak tahu kenapa lagi** | Tubuh ingat setelah kepala lupa |
| **AKIBAT** | jembatan terlalu lebar untuk 40 orang · gudang berisi 4 ayam | Bekas tidak bisa dicoret — hanya salah dibaca |
| **ORANG** | Sora · Nyai Tuminah · siapa pun yang cukup mencintai (#5a) | Cinta = ingatan yang tidak disimpan di kepala |

Tiga aturan keras: (1) minimal **dua jenis berbeda** · (2) **bukti boleh berbohong** —
Chronicle mencatat **pilihan pemain**, bukan kebenaran · (3) halaman pulih **tak pernah identik**.

## 1.6 D-1…D-6 — masih menunggu putusan (`:321-331`)

| # | Usul | Risiko kalau ditolak |
|---|---|---|
| D-1 | Hukum Bukti (§3) | tanpa ini, loop jadi fetch quest |
| **D-2** | **Harga Elyn** — menulis untuk pemain mempercepat Elyn melupakan miliknya | kehilangan harga terberatnya |
| D-3 | Nol teks on-screen untuk penghapusan pertama | tanpa ini, horornya mati |
| D-4 | Tanpa progress bar Chronicle selamanya | melanggar §XVII |
| D-5 | "Lampu yang Salah" (B menyamar C) | — |
| D-6 | "Kesaksian Hujan" (C dari cuaca × waktu × kehidupan) | — |

---

# 2 — ASHBROOK 16px: SEMUA NODE `Interactable`

Scene yang **DIMAINKAN**: `game/scenes/world/Ashbrook.gd` (+ `.tscn`).

| baris | pembuat | `kind` | `evidence_id` | terhubung `Evidence.find`? |
|---|---|---|---|---|
| 199 | `_examine_point` | `examine` | `ev_ashbrook_gudang_gandum` | ✅ |
| 200 | `_examine_point` | `examine` | `ev_ashbrook_halloran_200_roti` | ✅ |
| 209 | `_examine_point` | `examine` | `ev_ashbrook_jembatan_terlalu_lebar` | ✅ |
| 251 | `_otha_sign` → `_examine_point` | `examine` | `ev_otha_papan_bekas_cat` | ✅ |
| 263 ×2 | `_ruin_examine` → `_examine_point` | `examine` | `ev_ashbrook_fondasi_rumput`, `ev_ashbrook_batu_fondasi` | ✅ |
| **227-229** | loop `for i in 8` | **`bench`** | — | ❌ |
| **297-299** | `_keeper` | `tree_keeper` | — | ❌ |
| **304-306** | `_world_gate` | `world_gate` | — | ❌ |
| 236-238 | `Portal.tscn` (**bukan** Interactable) | — | — | ❌ |

**Hitungan:**
- **Titik-periksa nyata (`kind=="examine"` + `evidence_id`): 6.**
- **Interactable non-bukti: 10** (8 bangku + tree_keeper + world_gate).
- **Total node Interactable: 16.**

Jalur `Evidence.find` satu-satunya: `Interactable.gd:152-162 examine_notice()` → `:172 Evidence.find(evidence_id)`.

---

# 3 — `place_ashbrook_besar` (#228) & beacon Merrit (#229)

## 3.1 `place_ashbrook_besar` — **halamannya TIDAK PERNAH DIBUAT di produksi**

Grep seluruh `game/`:

| Lokasi | Jenis |
|---|---|
| `game/data/chronicle_losses.json:66` | **data** (definisi loss) |
| `game/data/evidence.json` — 6× (`:152,167,182,199,214,229`) | **data** (`page:`) |
| `game/scenes/world/Ashbrook.gd:213` | **KOMENTAR SAJA** — *"Dengan batu (benda), place_ashbrook_besar punya 3 jenis → JALUR SENDIRI terbuka (#228)"* |
| `TestRunner.gd:4478-4503, 4548-4576` · `VerifyLoop64.gd:76-87` | test / harness |

**`Chronicle.record_person("place_ashbrook_besar", ...)` hanya ada di `TestRunner.gd:4480, 4550`
dan `VerifyLoop64.gd:83`.**

➡ **Konsekuensi paling dalam:** bukan sekadar `strike`/`restore` tak ter-wire —
**halamannya sendiri tak pernah ditulis ke `WorldState.chronicle` milik pemain.**
Jadi bahkan bila `strike()` dipanggil hari ini, ia mengembalikan `false`
(`Chronicle.gd:129-138` hanya mencocokkan entri yang sudah ada).

**Prasyarat state agar #228 bisa hidup, berurutan:**
1. `Chronicle.record_person("place_ashbrook_besar", …)` → state `written` — **TIDAK ADA DI KODE PRODUKSI**
2. `Chronicle.strike("place_ashbrook_besar")` → `struck` + `Evidence.start_decay_clock` — **TIDAK ADA**
3. pemain periksa ≥3 jenis → `Evidence.kinds_for()` ≥ 3 — ✅ **sudah bisa** (6 titik = akibat·benda·kebiasaan)
4. `Chronicle.restore(..., SCRIBE_SELF)` — **TIDAK ADA**

Langkah 3 satu-satunya yang sudah jalan.

## 3.2 Beacon Merrit — **yang ini HIDUP**

`Ashbrook.gd:422-433` (`_build_vantage()`):
```gdscript
var beacon := Sprite2D.new()
var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
img.fill(Color(1.0, 0.88, 0.6))
beacon.texture = ImageTexture.create_from_image(img)
beacon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
beacon.global_position = MERRIT_HOUSE + Vector2(18, -14)
beacon.z_index = 4096
beacon.scale = Vector2(1.6, 1.6)
beacon.add_to_group("lamp_beacon")
add_child(beacon)
_beacon = beacon
```

**Yang menyalakannya** — `Ashbrook.gd:505-517`, dipanggil tiap frame dari `_process`:
```gdscript
_lamp.modulate = Color(1, 1, 1, 1.0 if h >= 17 or h < 6 else 0.75)
if _seat:
    _seat.visible = h >= 19 or h < 5      # Merrit duduk membaca surat (tanpa prompt)
if _beacon:
    var ba := 1.0 if h >= 17 or h < 6 else 0.55
    if player and player.global_position.distance_to(_beacon.global_position) < 320.0:
        ba = 0.0
    _beacon.modulate.a = ba
```

**Prasyarat: NOL.** Tak butuh bukti, tak butuh Chronicle. Murni **jam WIB** (`h = GameClock.wib_hour()`)
+ jarak pemain. Menyala 17:00–06:00 penuh, 0.55 di siang hari, 0 bila pemain < 320 px.

⚠ **Asimetri yang perlu disadari Designer:** hook siluet #229 (lampu) **sudah hidup penuh**,
sementara payoff #228 (halaman) **belum lahir sama sekali**. Pemain hari ini melihat janji
tanpa penyelesaian.

---

# 4 — EMPAT BUKTI `person_merrit_fane`

Semua dari `game/data/evidence.json`. **Keempatnya `decay.mode = "never"`.**

| id | kind | where | found_by | requires_npc |
|---|---|---|---|---|
| `ev_merrit_kartu_pos_kosong` | benda | `ashbrook_rumah_singgah` | **`examine`** | — |
| `ev_merrit_cangkir_kedua` | kebiasaan | `ashbrook_rumah_singgah` | **`observe`** | — |
| `ev_merrit_rute_pos_berubah` | akibat | `ashbrook_rumah_singgah` | **`examine`** | — |
| `ev_merrit_arlen_ingat` | orang | `ashbrook` | **`dialog_arlen`** | **`arlen`** |

Contoh utuh:
```json
{
  "id": "ev_merrit_kartu_pos_kosong",
  "kind": "benda", "page": "person_merrit_fane",
  "where": "ashbrook_rumah_singgah", "found_by": "examine",
  "notice": { "id": "Kartu pos kosong. Tanpa alamat. Di sudutnya, tulisan tangan Merrit: harga, dan sebuah tanggal — hari pertama kau tiba di Ashbrook." },
  "decay": { "mode": "never" }
}
```
```json
{
  "id": "ev_merrit_arlen_ingat",
  "kind": "orang", "page": "person_merrit_fane",
  "where": "ashbrook", "found_by": "dialog_arlen", "requires_npc": "arlen",
  "notice": { "id": "\"Kalian ngobrol tiap malam, Pak Tua. Aku lihat dari jalan. Tiap malam.\"" },
  "decay": { "mode": "never" }
}
```

## 4.1 Apa yang kurang agar SATU bisa ter-wire di 16px

**Termurah: `ev_merrit_rute_pos_berubah` atau `ev_merrit_kartu_pos_kosong`.** Keduanya `found_by:"examine"` —
jalur yang **sudah ada dan terbukti**.

Yang kurang, tepatnya **satu baris**:
```gdscript
_examine_point(Vector2(<x>, <y>), "ev_merrit_rute_pos_berubah")
```
di `Ashbrook.gd`, dengan posisi di dalam/di depan rumah singgah (`MERRIT_HOUSE = Vector2(232, 376)`).

**Hambatan per bukti:**
| bukti | hambatan |
|---|---|
| `rute_pos_berubah`, `kartu_pos_kosong` | **nol hambatan mekanik.** `where:"ashbrook_rumah_singgah"` menyiratkan **interior**; `HouseInterior.tscn` ada tapi generik — belum ada interior khusus rumah Merrit. Bisa ditaruh di eksterior sebagai kompromi |
| `cangkir_kedua` | `found_by:"observe"` — **mode `observe` TIDAK ADA DI KODE.** `Interactable` hanya punya `examine`. Butuh mode baru, atau turunkan jadi `examine` |
| `arlen_ingat` | `requires_npc:"arlen"` + `found_by:"dialog_arlen"` — **Arlen tak ada di scene mana pun**, dan **sistem dialog-bukti tak ada di kode** |

➡ **Satu baris `_examine_point` membuka bukti Merrit pertama.** Tapi itu hanya mengisi
`Evidence.found` — **tetap tak ada payoff** sampai `record_person` + `strike` + `restore` ada
(Bagian 3.1).

---

# 5 — UI: ADA TAB CHRONICLE ATAU TIDAK?

## 5.1 Daftar tab — `game/scenes/ui/MenuUI.gd:80`

```gdscript
for m in [["status","Status"], ["inventory","Tas"], ["crafting","Craft"], ["shop","Toko"],
          ["jurnal","Jurnal"], ["quest","Quest"], ["skill","Skill"], ["trees","Pohon"],
          ["grimoire","Grimoire"], ["pet","Pet"], ["prof","Profesi"],
          ["pedia","Pedia"], ["panduan","Panduan"]]:
```

**13 tab. Tidak ada tab "Kitab" / "Chronicle" / "Kronik".**

## 5.2 Aetherpedia (#96) ≠ Chronicle (R1/R2/R3)

`MenuUI.gd:538-546`:
```gdscript
func _build_pedia() -> void:
    title.text = "Aetherpedia"
    # --- PENCAPAIAN TERCATAT (benih Chronicle, #96): tanggal WIB NYATA ---
    var ch := _mk_label("✦ Pencapaian Tercatat (Kitab Sejarah — benih)", 18)
    ...
    var entries: Array = Chronicle.entries()
    if entries.is_empty():
        content.add_child(_mk_label("Belum ada yang tercatat. Dunia masih menunggu kau melakukan sesuatu yang layak diingat.", ...
```

**Pemisahan tegas:**

| | Aetherpedia (`_build_pedia`, `:538`) | Kitab Kehilangan (R1/R2/R3) |
|---|---|---|
| Sumber | `Chronicle.entries()` (`:544`) | — |
| Menampilkan | **pencapaian** — judul, tanggal/jam WIB, musim, level, oleh siapa | halaman tercoret & pulih |
| Menampilkan `state`? | **TIDAK** — nol `struck`/`restored`/`loss` | seharusnya ya |
| Kanon | **#96 "benih"** — labelnya sendiri berkata begitu | #226/#228/#229 |
| Status | ✅ hidup | ❌ **TIDAK ADA DI KODE** |

`Chronicle.entries()` (`:55`) mengembalikan **seluruh** `WorldState.chronicle` tanpa filter state.
Fungsi yang memfilter — `struck_entries()` (`:268`) dan `readable_entries()` (`:279`) — **tak
dipanggil dari UI mana pun** (grep `game/scenes/`: nol).

## 5.3 Input pembuka menu

`MenuUI.gd:19` `add_to_group("inventory_ui")`. Dibuka lewat `menu.open(<tab>, ctx)` dari
`Interactable.gd` (shop/crafting/quest/skill/…). **Tak ada input langsung ke `pedia`** yang
saya temukan di `MenuUI.gd`/`Player.gd` — pembuka menu ada di skrip lain (belum ditelusuri;
tidak diminta batch ini).

---

# RINGKAS UNTUK SPEC PAYOFF

Empat lapis yang hilang, berurutan dari paling dalam:

1. **Halaman tak pernah lahir** — `record_person("place_ashbrook_besar")` nol di produksi.
2. **Tak pernah tercoret** — `strike()` nol di produksi.
3. **Tak pernah bisa ditulis ulang** — `restore()` nol di produksi; UI-nya = R5 (butuh Elyn).
4. **Tak pernah bisa dilihat** — nol tab Chronicle; `struck_entries()`/`readable_entries()` nol pemanggil.

Yang **sudah siap dipakai** spec payoff: 6 titik-periksa · 3 jenis bukti terkumpul ·
`Evidence.kinds_for`/`enough_for`/`for_page` · `_compute_loss` + `chronicle_losses.json` ·
sinyal `chronicle_struck`/`chronicle_restored` · beacon & lentera Merrit.
