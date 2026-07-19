extends Node
## CHRONICLE — "PENCAPAIAN TERCATAT" (v0.4.3 #4, Decision Log #96).
## Benih dari Kitab Sejarah Dunia (Piagam LEGACY, v0.5–v0.6). Setiap first-clear
## (scenario, boss, ruang rahasia, penebusan Roh Hutan) dicatat PERMANEN dengan
## **tanggal WIB nyata** — bukan "hari ke-12 dalam game", melainkan hari sungguhan
## saat kau melakukannya. Dunia mengingat kapan.
##
## Perayaan: cutscene template "first_clear" + jingle kemenangan dari bank musik +
## NPC terdekat membicarakannya beberapa hari (lewat RumorSystem — dan seperti
## gosip lain, mereka boleh saja salah menceritakannya).
##
## ══════════════════════════════════════════════════════════════════════════════
## R1 — CHRONICLE RESTORATION (#221, #226, #230). Chronicle berhenti menjadi
## daftar prestasi; ia menjadi **tokoh utama kedua** (§XVI) — kitab yang menolak
## berhenti mencatat, dan **lawan sejati** Sang Nirnama.
##
## #230 — SATU BUKU, DUA JENIS HALAMAN:
##   PENCAPAIAN (KIND_DEED) — boss/first-clear. Ditulis sistem, otomatis.
##   ORANG      (KIND_PERSON) — "Otha Renn, penjahit". **Harus ada yang repot.**
## Keduanya di buku yang sama, urut tanggal WIB. Buku TIDAK menghakimi (§XVI):
## ia tak tahu mana yang penting. Boss kill datang sendiri. Otha butuh seseorang.
##
## #226 — HUKUM BUKTI: ingatan tak bisa dipulihkan dari ingatan, hanya dari BEKAS.
## #229.3 — Pemain menghapus dengan TIDAK PEDULI: yang tak pernah dicatat tak
##          meninggalkan apa-apa. Bukan entri kosong — **tidak ada apa-apa.**
## D-3 — strike() DIAM TOTAL. D-4 — TAK PERNAH ADA ANGKA.
## ══════════════════════════════════════════════════════════════════════════════

const TALK_DAYS := 3        # berapa hari NPC masih membicarakannya

# --- #230: dua jenis halaman, satu buku ---------------------------------------
const KIND_DEED := "deed"       # pencapaian — ditulis sistem
const KIND_PERSON := "person"   # orang — harus ada yang repot menulis

# --- #226: empat jenis bukti. KANON — jangan tambah tanpa putusan Direktur -----
const EVIDENCE_KINDS := ["benda", "kebiasaan", "akibat", "orang"]

# --- state halaman ------------------------------------------------------------
const ST_WRITTEN := "written"
const ST_STRUCK := "struck"
const ST_RESTORED := "restored"

# --- #228: siapa yang memegang pena ------------------------------------------
const SCRIBE_SELF := "self"     # pemain sendiri — 3 bukti, loss terbesar, selalu tersedia
const SCRIBE_ELYN := "elyn"     # 2 bukti, loss terkecil — harganya: Elyn melupakan miliknya
const SCRIBE_SORA := "sora"     # 2 bukti, loss sedang — harganya: Sora menanggungnya

## Berapa jenis bukti yang dibutuhkan tiap juru tulis (#226 #1, #228).
const SCRIBE_KINDS_NEEDED := {
	SCRIBE_SELF: 3,   # ia tak tahu caranya. Ia cuma repot. Dan itu cukup.
	SCRIBE_ELYN: 2,
	SCRIBE_SORA: 2,
}

func entries() -> Array:
	return WorldState.chronicle

## Sudah pernah tercatat? (state apa pun — tercoret tetap "pernah ada")
func has(id: String) -> bool:
	for e in WorldState.chronicle:
		if e.get("id", "") == id:
			return true
	return false

# ══════════════════════════════════════════════════════════════════════════════
# MENULIS
# ══════════════════════════════════════════════════════════════════════════════

## Catat first-clear. Returns false bila sudah pernah (tak ada perayaan dobel).
func record(id: String, title: String, celebrate: bool = true) -> bool:
	return _write(id, title, KIND_DEED, celebrate)

## #230 — Catat SEORANG ORANG. Tak pernah otomatis: seseorang harus repot.
## Dipanggil saat pemain/Elyn/Sora menuliskan seseorang yang tak pernah cukup
## penting untuk dicatat. **Tak ada perayaan** — ini bukan prestasi.
##
## `by` — SIAPA yang repot menuliskannya (#261). Kosong = pemain sendiri.
## Ashbrook lahir dengan by:"merrit_fane" — penjaga lentera yang menolak desanya terlupa.
func record_person(id: String, title: String, by: String = "") -> bool:
	return _write(id, title, KIND_PERSON, false, by)

func _write(id: String, title: String, kind: String, celebrate: bool, by: String = "") -> bool:
	if has(id):
		return false
	var entry := {
		"id": id, "title": title, "kind": kind,
		"date": GameClock.date_string(), "time": GameClock.time_string(),
		"season": GameClock.season_name(),
		# #261 — halaman lahir dari yang REPOT. Kosong = pemain sendiri (perilaku lama).
		"by": by if by != "" else PlayerData.char_name,
		"level": PlayerData.level,
		# --- R1 ---
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

func _celebrate(entry: Dictionary) -> void:
	Stage.banner(Loc.t("chronicle.recorded"), "%s — %s WIB" % [entry.title, entry.date])
	Audio.play_stinger("boss_kill")
	if Cutscene.def("first_clear").size() > 0 and not Cutscene.playing:
		Cutscene.play("first_clear")
	# warga akan membicarakannya beberapa hari (boleh keliru — E5 #77)
	WorldState.town_talk = {
		"text": entry.title,
		"start_day": int(floor(float(Time.get_unix_time_from_system() + GameClock.WIB_OFFSET) / 86400.0)),
		"days": TALK_DAYS,
	}

# ══════════════════════════════════════════════════════════════════════════════
# MENCORET — §VI.2. **D-3: DIAM TOTAL.**
# ══════════════════════════════════════════════════════════════════════════════

## Coret satu halaman. Data asli TIDAK dihapus — hanya `state` berubah (§VI.2:
## "data asli disimpan tersembunyi — bisa DIPULIHKAN lewat perlawanan").
## Buku menyimpan luka.
##
## ⛔ HUKUM D-3 — DIKODEKAN, BUKAN DIHARAPKAN:
## fungsi ini DILARANG memanggil Stage.banner / EventBus.toast /
## Audio.play_stinger / Cutscene.play. **Nol umpan balik.** Buku berubah
## diam-diam, dan pemain yang tidak memperhatikan tidak akan pernah tahu.
## Dijaga `_test_strike_is_silent()`. Preseden: #210, White Stag #216.
##
## `cause` dicatat untuk keperluan internal — **tak pernah ditampilkan.**
## (#229.4: tidak semua kabut datang dari Nirnama. Pemain tak akan pernah bisa
##  membedakan penghapusan dari kelupaan biasa — dan kita tak akan menjawabnya.)
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

# ══════════════════════════════════════════════════════════════════════════════
# MENULIS ULANG — #226 (Hukum Bukti) + #228 (tiga jalur)
# ══════════════════════════════════════════════════════════════════════════════

## Tulis ulang halaman yang tercoret.
##
## #226 HUKUM BUKTI — tiga aturan keras:
##   1. minimal N jenis bukti BERBEDA (N per juru tulis — #228)
##   2. bukti boleh berbohong: Chronicle mencatat PILIHAN pemain, bukan kebenaran
##   3. halaman pulih TIDAK PERNAH identik — selalu ada `loss`
##
## #228 HUKUM TAGLINE — Elyn bukan satu-satunya jalan. SCRIBE_SELF selalu
## tersedia: lebih mahal (3 jenis), loss terbesar, tulisan tangan berantakan.
## **Dan itu tetap sah. Dunia mengingat versi pemain.**
##
## witnesses: Array[Dictionary] → [{"kind":"benda","id":"surat_merrit","by":"merrit"}, ...]
## returns: {"ok": bool, "reason": String, "loss": String}
func restore(id: String, witnesses: Array, scribe: String = SCRIBE_SELF) -> Dictionary:
	var e := _find(id)
	if e.is_empty():
		return {"ok": false, "reason": "not_found", "loss": ""}
	if e.get("state", "") != ST_STRUCK:
		return {"ok": false, "reason": "not_struck", "loss": ""}

	var kinds := _kinds_of(witnesses)
	var needed: int = SCRIBE_KINDS_NEEDED.get(scribe, 3)
	if kinds.size() < needed:
		return {"ok": false, "reason": "need_%d_kinds" % needed, "loss": ""}

	e["state"] = ST_RESTORED
	e["restored_at"] = GameClock.date_string()
	e["scribe"] = scribe
	e["witnesses"] = witnesses.duplicate(true)
	e["loss"] = _compute_loss(e, kinds, scribe)
	EventBus.chronicle_restored.emit(id, e["loss"])
	return {"ok": true, "reason": "", "loss": e["loss"]}

## Jenis bukti unik yang dibawa (bukan jumlah bukti — JUMLAH JENIS).
## #226 #1: "Satu bukti tak pernah cukup. Ingatan itu jaringan, bukan item."
func _kinds_of(witnesses: Array) -> Array:
	var seen := {}
	for w in witnesses:
		var k: String = w.get("kind", "")
		if k in EVIDENCE_KINDS:
			seen[k] = true
	return seen.keys()

## #226 #3 — YANG HILANG DITENTUKAN OLEH JENIS BUKTI YANG **TIDAK** DIBAWA.
##
## Ini bukan hukuman acak. Ini logika: kalau tak seorang pun bersaksi (`orang`),
## namanya tercatat tapi wajahnya tidak. Kalau tak ada `kebiasaan`, yang hilang
## adalah irama hidupnya — jam berapa ia menyalakan lampu.
##
## Data-driven: `data/chronicle_losses.json`. Ditulis TANGAN per halaman —
## bukan tabel acak (pola sama dengan harga revive Kain #192).
## Pemain yang membawa bukti berbeda mendapat halaman yang BERBEDA.
## **Ingatan dunia berbentuk seperti apa yang berhasil kau temukan.**
func _compute_loss(e: Dictionary, kinds: Array, scribe: String) -> String:
	var tbl: Dictionary = Db.chronicle_losses
	var row: Dictionary = tbl.get(e.get("id", ""), {})

	# jenis yang TIDAK dibawa — itulah yang hilang
	var missing: Array = []
	for k in EVIDENCE_KINDS:
		if not (k in kinds):
			missing.append(k)

	# Nilai loss ditulis dwibahasa {id,en} (#166) — resolusi lewat Loc.c ke String.
	# TANPA ini, mengembalikan Dictionary dari fungsi -> String = nilai rusak/kosong.
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

# ══════════════════════════════════════════════════════════════════════════════
# QUERY
# ══════════════════════════════════════════════════════════════════════════════
#
# ⛔ HUKUM D-4 — DIKODEKAN, BUKAN DIHARAPKAN.
#
# **DILARANG ADA di file ini, selamanya:**
#   restored_count() · struck_count() · total_count() · progress() ·
#   completion_percent() · atau apa pun yang bisa dipakai pemain untuk tahu
#   "tinggal berapa lagi".
#
# Tiga alasan (#230/D-4):
#   1. Angka bikin pemain berhenti melihat orang. Merrit jadi 3%.
#   2. Angka itu bohong. Berapa penyebutnya? Otha tak pernah punya halaman.
#      Persen hanya bisa menghitung yang SUDAH tercatat — yang tidak pernah
#      tercatat justru inti masalahnya.
#   3. **Menghitung ADALAH kesalahan Nirnama** (§XIII: "Kekeliruannya pada
#      SKALANYA"). Progress bar mengajari pemain berpikir seperti Nirnama.
#
# 100% mustahil, dan itu tokohnya: Elyn bangun tiap pagi mengerjakan sesuatu
# yang matematis mustahil. Kalau ada 100%, Elyn cuma pemalas yang belum kelar.
# **Tidak ada yang pernah selesai mengingat.**
#
# Dijaga `_test_no_chronicle_score()`.
# ══════════════════════════════════════════════════════════════════════════════

func _find(id: String) -> Dictionary:
	for e in WorldState.chronicle:
		if e.get("id", "") == id:
			return e
	return {}

## "" | written | struck | restored
func state_of(id: String) -> String:
	var e := _find(id)
	return e.get("state", "") if not e.is_empty() else ""

func is_struck(id: String) -> bool:
	return state_of(id) == ST_STRUCK

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

# --- Bahan gosip warga --------------------------------------------------------

## Apa yang sedang dibicarakan kota hari-hari ini ("" bila tak ada).
func town_talk() -> String:
	var t: Dictionary = WorldState.town_talk
	if t.is_empty():
		return ""
	var now := int(floor(float(Time.get_unix_time_from_system() + GameClock.WIB_OFFSET) / 86400.0))
	if now - int(t.get("start_day", now)) >= int(t.get("days", TALK_DAYS)):
		WorldState.town_talk = {}      # kota berhenti membicarakannya — dunia bergerak
		return ""
	return t.get("text", "")

# --- Migrasi save lama (schema R1) -------------------------------------------

## Save lama tetap jalan. Tidak ada kanon yang dimundurkan.
func migrate_r1(list: Array) -> void:
	for e in list:
		if not e.has("state"):
			e["state"] = ST_WRITTEN
			e["kind"] = e.get("kind", KIND_DEED)
			e["struck_at"] = ""; e["struck_cause"] = ""
			e["restored_at"] = ""; e["scribe"] = ""
			e["witnesses"] = []; e["loss"] = ""
