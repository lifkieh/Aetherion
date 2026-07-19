# FAKTA DESIGNER — BATCH 5 (prep spec eksekusi payoff + mekanik ingatan)

Read-only. Nol perubahan kode. Semua klaim `path:baris`.

**Peta ke enam pertanyaan:**
| pertanyaan | bagian |
|---|---|
| 1. `_compute_loss` + `chronicle_losses.json` | §1 |
| 2. `record_person` / yang melahirkan halaman | §2 |
| 3. **SLOT INGATAN PEMAIN** | **§3-BARU** |
| 4. **ELYN — umur & keturunan** | **§4-BARU** |
| 5. `enough_for`/`for_page`/`kinds_for` | §4 *(ambang)* |
| 6. `struck_entries`/`readable_entries` | §5 |

---

# 1 — `_compute_loss()` + `chronicle_losses.json`

## 1.1 Kode — `game/autoload/Chronicle.gd:197-223`

```gdscript
func _compute_loss(e: Dictionary, kinds: Array, scribe: String) -> String:
	var tbl: Dictionary = Db.chronicle_losses
	var row: Dictionary = tbl.get(e.get("id", ""), {})

	# jenis yang TIDAK dibawa — itulah yang hilang
	var missing: Array = []
	for k in EVIDENCE_KINDS:
		if not (k in kinds):
			missing.append(k)

	# Nilai loss ditulis dwibahasa {id,en} (#166) — resolusi lewat Loc.c ke String.
	var by_missing: Dictionary = row.get("loss_by_missing_kind", {})
	for k in missing:
		if by_missing.has(k):
			return Loc.c(by_missing[k])

	# #228 — yang menulis sendiri kehilangan lebih banyak: ia tak tahu caranya.
	if scribe == SCRIBE_SELF and row.has("loss_self"):
		return Loc.c(row["loss_self"])
	if row.has("default"):
		return Loc.c(row["default"])
	# Jaring pengaman: TIDAK PERNAH kosong (#226 #3 — dijaga test).
	return Loc.c({
		"id": "Sesuatu tidak kembali. Tak seorang pun tahu apa.",
		"en": "Something did not come back. No one knows what.",
	})
```

## 1.2 Bagaimana satu baris `loss` dipilih

**Hardcoded per-halaman, DIPILIH oleh algoritma. Bukan dihitung, bukan acak.**

Algoritmanya (`:201-218`), berurutan:
1. Hitung `missing` = `EVIDENCE_KINDS` **minus** jenis yang dibawa pemain.
   Urutan tetap: **`benda → kebiasaan → akibat → orang`** (`Chronicle.gd:36`).
2. Ambil **jenis hilang PERTAMA** yang punya entri di `loss_by_missing_kind` → **kembalikan itu**.
3. Bila semua 4 jenis dibawa → kalau `scribe == SCRIBE_SELF` dan ada `loss_self` → itu.
4. Kalau tidak → `default`.
5. Kalau baris halamannya tak ada sama sekali → jaring pengaman hardcoded di kode.

Doktrinnya `:187-196`:
> `## #226 #3 — YANG HILANG DITENTUKAN OLEH JENIS BUKTI YANG **TIDAK** DIBAWA.`
> `## Ini bukan hukuman acak. Ini logika: kalau tak seorang pun bersaksi (orang),`
> `## namanya tercatat tapi wajahnya tidak.`
> `## Data-driven: data/chronicle_losses.json. Ditulis TANGAN per halaman —`
> `## bukan tabel acak (pola sama dengan harga revive Kain #192).`
> `## **Ingatan dunia berbentuk seperti apa yang berhasil kau temukan.**`

## 1.3 Di mana baris "bukan sebagai seribu lima ratus orang" tersimpan

`game/data/chronicle_losses.json` → `place_ashbrook_besar` → `loss_by_missing_kind` → **`orang`**:

```json
"orang": {
  "id": "Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus orang.",
  "en": "Ashbrook is recorded as a town. Not as one thousand five hundred people."
}
```

**Kenapa baris ini yang muncul di uji `VerifyLoop64`:** 6 titik-periksa Ashbrook hanya
menghasilkan jenis **akibat · benda · kebiasaan**. Jenis **`orang` tidak pernah ter-wire**
(`ev_ashbrook_bram_ingat_ayahnya` — satu-satunya `orang` untuk halaman ini — tak ada di scene).
Jadi `missing = ["orang"]`, dan langkah 2 mengembalikan baris itu.

➡ **Konsekuensi desain yang perlu Designer sadari:** selama `ev_ashbrook_bram_ingat_ayahnya`
tak ter-wire, **setiap pemain akan selalu mendapat loss yang sama persis.** Variasi yang
dijanjikan #226 #3 ("pemain berbeda → halaman berbeda") **belum ada di dunia** — bukan karena
mesinnya kurang, tapi karena hanya 3 dari 4 jenis bisa dikumpulkan.

## 1.4 Isi `chronicle_losses.json` — **3 halaman nyata**

| halaman | `loss_by_missing_kind` | `loss_self` | `default` |
|---|---|---|---|
| `person_otha_renn` | 4 jenis lengkap | ✅ | ✅ |
| `person_merrit_fane` | 4 jenis lengkap | ✅ | ✅ |
| `place_ashbrook_besar` | 4 jenis lengkap | ✅ | ✅ |

Contoh keragaman (`person_merrit_fane`):
- **benda** hilang → *"Suratnya tidak ikut tertulis. Buku ini tahu ia menunggu. Buku ini tidak tahu untuk apa."*
- **kebiasaan** hilang → *"Tak seorang pun ingat lagi jam berapa lampunya dinyalakan."*
- **akibat** hilang → *"Ia tercatat sebagai tukang pos. Bukan sebagai orang yang menahan sebuah desa tetap tersambung ke dunia selama empat puluh tahun."*
- **orang** hilang → *"Ia tercatat. Bahwa ada yang menyayanginya, tidak."*
- **`loss_self`** → *"Kau menuliskannya sendiri. Tanggalnya meleset setahun, dan itu akan tetap begitu selamanya."*

Kunci meta: `_comment`, `_kinds`, `_urutan` (mendokumentasikan urutan pemeriksaan).

---

# 2 — YANG MELAHIRKAN HALAMAN

## 2.1 Tiga fungsi — `Chronicle.gd:70-97`

```gdscript
## Catat first-clear. Returns false bila sudah pernah (tak ada perayaan dobel).
func record(id: String, title: String, celebrate: bool = true) -> bool:
	return _write(id, title, KIND_DEED, celebrate)

## #230 — Catat SEORANG ORANG. Tak pernah otomatis: seseorang harus repot.
## Dipanggil saat pemain/Elyn/Sora menuliskan seseorang yang tak pernah cukup
## penting untuk dicatat. **Tak ada perayaan** — ini bukan prestasi.
func record_person(id: String, title: String) -> bool:
	return _write(id, title, KIND_PERSON, false)

func _write(id: String, title: String, kind: String, celebrate: bool) -> bool:
	if has(id):
		return false
	var entry := {
		"id": id, "title": title, "kind": kind,
		"date": GameClock.date_string(), "time": GameClock.time_string(),
		"season": GameClock.season_name(), "by": PlayerData.char_name,
		"level": PlayerData.level,
		"state": ST_WRITTEN,
		"struck_at": "", "struck_cause": "",
		"restored_at": "", "scribe": "",
		"witnesses": [], "loss": "",
	}
	WorldState.chronicle.append(entry)
	EventBus.chronicle_recorded.emit(id, title)
	if celebrate:
		_celebrate(entry)
	return true
```

`_celebrate()` (`:99-100`) = `Stage.banner(...)`. **`record_person` selalu `celebrate=false`** →
halaman ORANG lahir **diam total**, konsisten #230/D-3.

## 2.2 Argumen minimal untuk melahirkan `place_ashbrook_besar` di produksi

**Satu baris:**
```gdscript
Chronicle.record_person("place_ashbrook_besar", "Ashbrook — kota yang dulu besar")
```
(judul persis yang dipakai `TestRunner.gd:4480, 4550` dan `VerifyLoop64.gd:83`)

**Prasyarat: NOL.** `_write` hanya menolak bila `has(id)` sudah true (`:80-81`).
Tak butuh bukti, tak butuh state lain, tak butuh Elyn.

⚠ **Tapi `record_person` semantiknya "seseorang harus repot menulisnya"** (`:73-75`).
Memanggilnya otomatis saat pemain masuk Ashbrook akan **melanggar maksud #230**.
Ini keputusan desain, bukan teknis: **siapa yang menulis halaman ini, dan kapan?**

⚠ Catatan kedua: `place_ashbrook_besar` adalah **TEMPAT**, tapi satu-satunya jalur yang ada
adalah `record_person` (`KIND_PERSON`) atau `record` (`KIND_DEED`, **berbanner**).
**Tak ada `KIND_PLACE`.** `Chronicle.gd:32-33` hanya mendefinisikan `KIND_DEED` dan `KIND_PERSON`.

---

# 3 — `observe` vs `dialog_arlen`

## 3.1 🔴 TEMUAN: `found_by` TIDAK PERNAH DIBACA KODE

Grep `found_by` di seluruh `game/**/*.gd`: **nol hasil.**

Field evidence yang **benar-benar dibaca kode**:
| field | dibaca di |
|---|---|
| `kind` | `Evidence.gd:66, 134` |
| `page` | `Evidence.gd:132` |
| `notice` | `Evidence.gd:67` |
| `decay` | `Evidence.gd:95-119` |
| `requires_npc` | `Evidence.gd:136` (hanya untuk isi field `"by"`) + penjaga test `:4247, 4427, 4570` |
| `where` | `Evidence.gd:136` (fallback `"by"`) |
| **`found_by`** | **TIDAK ADA DI KODE** |
| **`schedule`** (di evidence.json) | **TIDAK ADA DI KODE** (`NpcSchedule.gd:31` membaca `schedule` **persona**, objek berbeda) |

**Artinya: `found_by` murni dokumentasi niat desain.** Kode tak melakukan dispatch apa pun
berdasarkan nilainya.

## 3.2 ⚠ KOREKSI BATCH 4

Di `FAKTA_DESIGNER_B4.md` §4.1 saya menulis `cangkir_kedua` terhalang karena
*"mode `observe` TIDAK ADA DI KODE"*. **Itu menyesatkan.** Benar bahwa mode `observe` tak ada —
tapi **itu bukan penghalang**, karena tak ada kode yang memeriksa `found_by` sama sekali.

**Ongkos mewire ketiganya IDENTIK: satu baris.**

```gdscript
_examine_point(Vector2(<x>, <y>), "ev_merrit_cangkir_kedua")
```

## 3.3 Perbandingan sesungguhnya

| bukti | `found_by` | dependensi MEKANIK | baris kode | dependensi DESAIN |
|---|---|---|---|---|
| `kartu_pos_kosong` | `examine` | **nol** | **1** | posisi di rumah singgah |
| `rute_pos_berubah` | `examine` | **nol** | **1** | idem |
| `cangkir_kedua` | `observe` | **nol** | **1** | `schedule:"pagi"` diabaikan kode → bisa ditemukan jam berapa saja. **Melanggar niat desain**, tidak melanggar kode |
| `arlen_ingat` | `dialog_arlen` | **nol untuk `find()`** | **1** | `requires_npc:"arlen"` — Arlen **tak ada di scene mana pun**. Mewire-nya lewat `_examine_point` akan memberi bukti "kesaksian Arlen" **tanpa Arlen**. Melanggar #228 secara naratif |

**Paling sedikit dependensi, mekanik DAN desain: `ev_merrit_rute_pos_berubah`** —
`found_by:"examine"`, nol `requires_npc`, nol `schedule`, dan objeknya (buku rute) statis.

**Untuk melengkapi jenis `orang` di `place_ashbrook_besar`** (satu-satunya yang mengubah
variasi `loss`): `ev_ashbrook_bram_ingat_ayahnya` — juga satu baris, dan Old Bram **sudah ada
di scene 64px** (`Ashbrook64.gd:176`), **belum di 16px**.

---

# 4 — AMBANG PEMULIHAN

## 4.1 Kode — `game/autoload/Evidence.gd:128-151`

```gdscript
func for_page(page_id: String) -> Array:
	var out: Array = []
	for eid in found.keys():
		var def: Dictionary = Db.evidence.get(eid, {})
		if def.get("page", "") == page_id:
			out.append({
				"kind": def.get("kind", ""),
				"id": eid,
				"by": def.get("requires_npc", def.get("where", "")),
			})
	return out

## Jenis bukti unik yang sudah dimiliki untuk halaman ini.
## #226 #1: yang dihitung JENIS, bukan jumlah.
func kinds_for(page_id: String) -> Array:
	var seen := {}
	for w in for_page(page_id):
		seen[w.get("kind", "")] = true
	return seen.keys()

## Cukupkah bukti untuk juru tulis ini? (#226 #1 + #228)
func enough_for(page_id: String, scribe: String) -> bool:
	var needed: int = Chronicle.SCRIBE_KINDS_NEEDED.get(scribe, 3)
	return kinds_for(page_id).size() >= needed
```

## 4.2 Ambang — `Chronicle.gd:49-53`

```gdscript
const SCRIBE_KINDS_NEEDED := {
	SCRIBE_SELF: 3,   # ia tak tahu caranya. Ia cuma repot. Dan itu cukup.
	SCRIBE_ELYN: 2,
	SCRIBE_SORA: 2,
}
```

**Jawaban langsung:**
- **Yang dihitung JENIS unik, bukan jumlah bukti.** 5 bukti sejenis = 1 jenis = tidak cukup.
- **Ambang: `self`=3 · `elyn`=2 · `sora`=2.** Default bila scribe tak dikenal = **3**
  (`Evidence.gd:150` + `Chronicle.gd:165`).
- **Ambang BUKAN per-halaman.** Ia per-**juru tulis**, global. Tak ada field ambang di
  `evidence.json` maupun `chronicle_losses.json`.
- Penegakan terjadi **dua kali**: `Evidence.enough_for()` (kueri) dan
  `Chronicle.restore()` (`:166-167`, penolakan sesungguhnya → `reason: "need_%d_kinds"`).

⚠ Karena maksimum jenis = 4 dan `self` butuh 3, **tiap halaman wajib punya ≥3 jenis berbeda
ter-wire di dunia** agar jalur SENDIRI (#228) hidup. Saat ini hanya `place_ashbrook_besar`
memenuhi (3 jenis). `person_merrit_fane` punya **0**.

---

# 5 — `struck_entries()` + `readable_entries()`

## 5.1 Kode — `Chronicle.gd:265-284`

```gdscript
## Halaman tercoret — untuk UI buku. **Bukan untuk skor.**
## UI menampilkannya sebagai coretan tinta di tempatnya, urut tanggal —
## TIDAK PERNAH sebagai daftar tugas yang bisa disortir (D-4).
func struck_entries() -> Array:
	var out: Array = []
	for e in WorldState.chronicle:
		if e.get("state", "") == ST_STRUCK:
			out.append(e)
	return out

## Halaman yang dibacakan di adegan terakhir (§XVII / D12).
## Chronicle "dihitung" SEKALI — oleh dunia, di adegan terakhir, tak pernah
## oleh UI. Bukunya tipis → adegan pendek. Tebal → panjang. Kosong → The Final
## Silence: tak ada yang dibacakan, karena tak ada yang ditulis.
func readable_entries() -> Array:
	var out: Array = []
	for e in WorldState.chronicle:
		if e.get("state", "") != ST_STRUCK:
			out.append(e)
	return out
```

## 5.2 Apa yang dikembalikan

Keduanya mengembalikan **Array of Dictionary — entri mentah**, bukan struktur khusus UI.
`readable_entries()` mencakup **`written` DAN `restored`** (filternya `!= ST_STRUCK`).

**Field siap-tampil per entri** (dari `_write`, `:82-92`):

| field | isi | catatan UI |
|---|---|---|
| `id` | kunci halaman | internal |
| `title` | *"Ashbrook — kota yang dulu besar"* | judul |
| `kind` | `deed` \| `person` | pembeda gaya |
| `date` · `time` | tanggal & jam **WIB nyata** | *"2026-07-19 15.27 WIB"* |
| `season` · `level` · `by` | musim · level · nama pemain | konteks |
| `state` | `written`/`struck`/`restored` | **penentu tampilan coretan** |
| `struck_at` · `struck_cause` | tanggal + sebab | ⚠ `struck_cause` **"tak pernah ditampilkan"** (`:125-127`, #229.4) |
| `restored_at` · `scribe` | tanggal + `self`/`elyn`/`sora` | menentukan gaya tulisan tangan (spec R1) |
| `witnesses` | salinan array bukti | bisa jadi "ditulis dari: …" |
| **`loss`** | **satu kalimat** | ⭐ inti tampilan pulih |

## 5.3 Status pemakaian

**Nol pemanggil di seluruh `game/scenes/`.** Satu-satunya konsumen Chronicle di UI adalah
`MenuUI.gd:544` → `Chronicle.entries()` (**tanpa filter**), di `_build_pedia()` — Aetherpedia,
benih #96. Ia menampilkan `title/date/time/season/level/by` dan **mengabaikan
`state`/`loss`/`witnesses`/`scribe`**.

➡ **Dua fungsi ini sudah siap dipakai UI kitab dan belum pernah dipakai.**

---

# RINGKAS — YANG SUDAH SIAP vs YANG KURANG

**Siap dipakai spec eksekusi, nol kode baru:**
`record_person()` · `strike()` · `restore()` · `_compute_loss()` + 3 halaman berisi 4 varian
loss masing-masing · `for_page`/`kinds_for`/`enough_for` · `struck_entries`/`readable_entries` ·
sinyal `chronicle_recorded`/`chronicle_struck`/`chronicle_restored` · 6 titik-periksa Ashbrook.

**Yang kurang, terurut ongkos:**
1. **1 baris** — `record_person("place_ashbrook_besar", "Ashbrook — kota yang dulu besar")`
   *(tapi butuh putusan desain: siapa yang menulis, kapan)*
2. **1 baris** — pemicu `strike()` *(butuh putusan: apa yang mencoret, dan kapan)*
3. **1 baris** — `_examine_point(... "ev_ashbrook_bram_ingat_ayahnya")` → jenis `orang` masuk →
   variasi `loss` akhirnya hidup
4. **UI kitab** — tab baru di `MenuUI.gd:80` + `_build_*` yang membaca `state`/`loss`.
   Ini satu-satunya pekerjaan berukuran layar, bukan baris.
5. **Jalur `restore()`** — butuh Elyn (R5) **atau** jalur SENDIRI (#228) yang tak butuh siapa pun.

⚠ Yang **tidak** ada dan mungkin dikira ada: `KIND_PLACE` (hanya `deed`/`person`) ·
dispatch `found_by` · ambang per-halaman · UI apa pun yang menampilkan `loss`.

---

# §3-BARU — SISTEM SLOT INGATAN PEMAIN

## 🔴 **TIDAK ADA DI KODE.**

Grep seluruh `game/**` untuk `memory_slot` · `memory_cap` · `slot_ingatan` · `kapasitas` ·
`capacity` · `max_memor` · `mem_slot` · `remember_cap` → **nol hasil di kode.**
Semua kecocokan kata "ingatan" adalah **komentar doktrin** atau **teks naratif data**:

| path:baris | isi |
|---|---|
| `Chronicle.gd:23, 178, 196` | komentar #226 |
| `Evidence.gd:4, 6, 8, 11, 14` | komentar doktrin |
| `data/evidence.json:3, 8, 11` | `_comment` / `_kinds` |
| `data/chronicle_losses.json:2` | `_comment` |
| `data/rumors.json:26` | teks rumor NPC |
| `data/town_npcs.json:276` | dialog warga |

## 3.1 Seluruh field `PlayerData` (`game/autoload/PlayerData.gd:12-97`)

Identitas & progres: `char_name` · `birth_sign` · `level` · `exp` · `playtime_sec` ·
`attributes` · `stat_points`
Stat: `max_hp` · `max_mp` · `atk` · `def` · `matk` · `mdef` · `spd` · `crit_rate` · `crit_dmg` · `hp` · `mp`
Ekonomi/gear: `gold` · `inventory` · `equipped_weapon/armor/accessory` · `gear_meta` · `coating`
Kelas: `char_class` · `advanced_class` · `combat_sub` · `pending_*` · `known_skills` ·
`mastered_elements` · `infusion` · `buffs` · `statuses` · `skill_trees`
Sosial (#130): `reputation` · `faction_standing` · `influence`
Lain: `monsters` · `active_pet_index` · `homestead_plots` · `scenario_flags` · `titles` ·
`professions` · `achievements` · `discovered` · `craft_insight` · `daily_quests` · `prof_xp` ·
`hotbar` · `discovered_fusions` · `char_config`

**Nol field kapasitas ingatan.** `to_save()` (`:695-715`) juga nol.

## 3.2 "Slot" yang ADA di kode — semuanya BUKAN ingatan

| jenis | path:baris |
|---|---|
| slot skill hotbar (`slot_1`…`slot_5`) | `Keybinds.gd:18-19, 37-41` |
| slot perlengkapan (`armor`/`accessory`) | `PlayerData.gd:52-53, 446` |
| slot berkas simpan | `EventBus.gd:80-81 save_completed(slot)` |
| **slot data ter-RESERVE (#130)** | `PlayerData.gd:65-69` |

⚠ `PlayerData.gd:65-69` menarik untuk dicontoh — ada preseden **memesan slot lebih dulu**:
> `# --- RESERVE (Decision Log #130): slot data reputasi & faksi ---`
> `# TETAPI slotnya di-reserve SEKARANG: menambah field setelah ratusan save beredar`

Dan `SAVE_SCHEMA := 2` (`:6`) + catatan `:3`:
> `## SAVE_SCHEMA 2 (v0.4.4+): menambah slot reputasi/faksi/influence (#130). Save schema 1 …`

➡ **Kalau slot ingatan akan dibangun, ini polanya:** tambah field + naikkan `SAVE_SCHEMA` ke 3
+ tangani migrasi di `from_save()` (`:717+`). Preseden #130 sudah membuktikan jalurnya.

## 3.3 Yang paling MENDEKATI kapasitas hari ini

Bukan slot, tapi **ambang jenis**: `SCRIBE_KINDS_NEEDED` (self=3 · elyn=2 · sora=2,
`Chronicle.gd:49-53`). Itu **syarat menulis**, bukan **kapasitas menyimpan** —
`Evidence.found` (`Evidence.gd:27`) adalah Dictionary **tanpa batas**.
Dan `Evidence.gd:157-158` melarang secara eksplisit:
> `# DILARANG ADA di file ini, selamanya:`
> `#   found_count() · total_for_page() · progress() · percent() · missing_kinds()`

⚠ **Peringatan desain:** sistem slot ingatan yang menampilkan "3/5 terisi" akan **bertabrakan
langsung dengan D-4** (#230) yang dikodekan di `Chronicle.gd:229-248` dan `Evidence.gd:154-168`,
dan dijaga test `_test_no_chronicle_score()` + `_test_no_evidence_score()`.
Kapasitas boleh ada; **menampilkan angkanya** yang dilarang.

---

# §4-BARU — ELYN: UMUR, CEILING, KETURUNAN

## 4.1 Di DOKUMEN — terkanonkan detail

`docs/Companion_bible/companion_02_elyn_thornewood.md`:

| baris | isi |
|---|---|
| `:37` | *"Elyn Thornewood, **134 tahun**, elf, Penjaga Arsip di perpustakaan tua **Sylvara**"* |
| `:39` | **KETURUNAN WREN:** *"Ada seorang gadis manusia bernama **Wren** yang datang membaca pada usia sebelas. Elyn menuliskan namanya di kartu pinjam. Wren tumbuh, membawa putrinya. Putrinya tum[buh]…"* |
| `:60` | **Ceiling: 690** (elite 400–700, *"tepat di tepi atas… sepuluh angka dari jenius, dan sepuluh angka itu tidak penting sama sekali"*) |
| `:76` | *"Ia takut bahwa dirinya sendiri adalah api yang kedua — hanya lebih pelan… ia **tidak lagi** [ingat]"* |
| `:78` | *"**Umur panjang, bagi Elyn, bukan berkah. Ia adalah ruang yang lebih besar untuk lupa.**"* |
| `:99` | *"**Wren (dan tiga keturunannya)** — relasi yang seluruhnya sudah selesai sebelum pemain tiba"* |
| `:114` | *"Elf, 134, **awal prima** — … Ia tidak akan menua di depan pemain. **Ia akan mengubur semua orang.**"* |
| `:116` | usul desain: *"**jadikan Elyn suara yang menyampaikan kehilangan**"* |
| `:118` | *"**Mentor** dalam arti paling murni (MEJA-3): ia tidak akan pernah pensiun karena tubuhnya melemah"* |

`docs/COMPANION_BIBLE.md:71`:
```
| 002 | **Elyn Thornewood** | *The Keeper of Forgotten Books* | Elf | **Sylvara** | Scholars | **690** · elite | companion_02_elyn_thornewood.md |
```

## 4.2 Tabel penuaan — `docs/TIME_LEGACY_SPEC.md:64-67`

| Ras | Dewasa | Prima | Menua | Sepuh | Harapan hidup | Laju vs manusia |
|---|---|---|---|---|---|---|
| **Elf** | 100 | **110–300** | 301–500 | 501+ | **~600** | **0,13** |

`:75` — *"**Elyn (134) jatuh di awal PRIMA elf.** Ia sudah melihat empat generasi manusia lahir dan…"*
`:5` — *"pemain menua **hanya lewat lompatan** ✅ (P-AGE=a) · tabel penuaan 8 ras & posisi Elyn **dipertahankan**"*

## 4.3 Di KODE — **TIDAK ADA DI KODE**

Grep `game/**` untuk `age` · `lifespan` · `aging` · `menua` · `generation` · `pewaris` · `dinasti`:

**Nol sistem umur.** Yang muncul hanya:
| path:baris | isi | bukan sistem umur |
|---|---|---|
| `PlayerData.gd:73, 76` | `influence` sumbu **`legacy`** | metrik pengaruh, bukan generasi |
| `AdvancedClass.gd:5` · `RasiSystem.gd:6` · `Chronicle.gd:3` | kata "LEGACY" sebagai pilar | komentar |
| `MenuUI.gd:403, 409` | tag NPC `"Memory"` / `"Legacy"` | label warna kartu NPC |
| `TestRunner.gd:2491` | `["Need","Dream","Fear","Ambition","Memory","Legacy","Hidden","Chronicle","Myth"]` | daftar tag sah |
| `MenuUI.gd:557` | *"…bekerja, berkeluarga, **menua**, dan meninggal…"* | teks Aetherpedia |

**Nol field `age` pada NPC/companion mana pun.** Nol `Aging` autoload. Nol data keturunan.
**Elyn sendiri nol node/scene** (dikonfirmasi `FAKTA_DESIGNER.md` §C).

## 4.4 Yang sudah dirancang tapi belum dibangun

`docs/TIME_LEGACY_SPEC.md:165`:
> `| Aging.thresholds(race, age) | autoload/util **baru** | tabel §2 sebagai **data JSON**, bukan konstanta kode |`

**Pertanyaan terbuka spec** (`:199-208`) — masih menunggu putusan:
- `:199` *"**Elf & pewarisan:** pemain elf praktis tak pernah menua melewati satu lompatan. Apakah ia…"*
- `:204-205` *"Tabel §2 = kanon atau tuning? **Rekomendasi: data JSON (bisa disetel)**, dengan **ambang** (dewasa/prima/menua/sepuh) yang **kanon**"*
- `:208` *"…melampaui usia prima? **Rekomendasi: ia TIDAK dibuang — ia berpindah peran**"*

## 4.5 Apa yang bisa disambung untuk mekanik ingatan

**Kait naratif yang paling kuat, sudah kanon, nol kode:**
1. **`:78` — "Umur panjang = ruang yang lebih besar untuk lupa."** Ini secara harfiah menyatakan
   ingatan sebagai **kapasitas terbatas yang tergerus waktu**. Kalau slot ingatan dibangun,
   kalimat ini adalah justifikasi kanonnya.
2. **`:39`/`:99` — Wren + tiga keturunan.** Sudah selesai sebelum pemain tiba → bahan
   **`kind:"orang"`** yang tak butuh NPC hidup, hanya kartu pinjam (**`kind:"benda"`**).
3. **`SCRIBE_ELYN` sudah ada di kode** (`Chronicle.gd:45`, ambang 2) — jalur mekaniknya siap;
   yang kurang cuma Elyn di dunia.
4. **"HARGA ELYN"** (`CHRONICLE_RESTORATION_SPEC.md:262-266`) masih `[BARU — usul, butuh putusan]`:
   tiap kali Elyn menulis untuk pemain, ia **mempercepat lupa miliknya sendiri**.
   ⚠ Itu **persis** mekanik slot-ingatan-yang-tergerus, tapi **untuk NPC**, bukan pemain.
   Belum diratifikasi, belum dikode.
