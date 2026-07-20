extends Node
## EVIDENCE — HUKUM BUKTI (#226). R2.
##
## > **Ingatan tidak bisa dipulihkan dari ingatan. Hanya dari BEKAS.**
##
## Sang Nirnama menghapus INGATAN. Ia tidak bisa menghapus AKIBAT dari sesuatu
## yang pernah ada. Itulah retakan di argumennya (§XIV: ia bisa menghapus
## ingatan; ia tidak bisa melihat kemungkinan).
##
## Empat jenis bukti — KANON, jangan tambah tanpa putusan Direktur:
##   benda     — benda tak punya ingatan untuk dihapus
##   kebiasaan — tubuh ingat setelah kepala lupa
##   akibat    — bekas tak bisa dicoret, hanya salah dibaca
##   orang     — mencintai = ingatan yang tak disimpan di kepala (#224 Lapis 1)
##
## Tiga aturan keras (#226):
##   1. minimal N JENIS berbeda (bukan N bukti). 10 surat = tetap 1 jenis.
##   2. bukti boleh berbohong → Chronicle mencatat PILIHAN pemain, bukan kebenaran
##   3. halaman pulih TIDAK PERNAH identik → selalu ada `loss`
##
## ⛔ D-3 — MENEMUKAN BUKTI TIDAK DIUMUMKAN. Nol toast/banner/marker.
##    Pemain yang tidak memeriksa tidak akan pernah tahu bukti itu ada.
## ⛔ D-4 — TIDAK ADA HITUNGAN. Tak ada "3/4 bukti ditemukan".
## ⛔ #228 — pemain SENDIRIAN tak pernah terkunci (dijaga _test_evidence_228).

## Bukti yang sudah pemain temukan. id -> {found_at}
var found: Dictionary = {}

## R3 — PEMBUSUKAN BUKTI. Bekas yang sudah membusuk. id -> {decayed_at}
var decayed: Dictionary = {}

## Kapan jam pembusukan mulai untuk tiap halaman. page_id -> unix.
## Dipasang Chronicle.strike() — dunia mulai melupakan saat halaman DICORET,
## bukan saat pemain menemukan bukti (spec R3 §3).
var _clock_start: Dictionary = {}

func _ready() -> void:
	EventBus.chronicle_restored.connect(_on_restored)

# ══════════════════════════════════════════════════════════════════════════
# MENEMUKAN
# ══════════════════════════════════════════════════════════════════════════

## Pemain menemukan sebuah bekas.
##
## ⛔ HUKUM D-3 — DIKODEKAN, BUKAN DIHARAPKAN:
## fungsi ini DILARANG memanggil Stage.banner / EventBus.toast /
## Audio.play_stinger / Cutscene.play. Menemukan bukti tidak dirayakan —
## pemain cuma memperhatikan sesuatu, dan dunia tidak memberitahunya bahwa
## itu penting. Dijaga `_test_evidence_find_is_silent()`.
##
## Returns: notice string ("" bila sudah ditemukan / id tak dikenal).
## Pemanggil (interaksi dunia) yang menampilkan notice-nya sebagai teks
## periksa biasa — BUKAN sebagai notifikasi.
func find(evidence_id: String) -> String:
	if found.has(evidence_id):
		return ""
	# R3 — bekas yang sudah membusuk TIDAK BISA ditemukan lagi. DIAM (D-3):
	# pemain memeriksa, dan tidak ada apa-apa. Tak ada penjelasan kenapa.
	if is_decayed(evidence_id):
		return ""
	var def: Dictionary = Db.evidence.get(evidence_id, {})
	if def.is_empty():
		return ""
	found[evidence_id] = {"found_at": GameClock.date_string()}
	EventBus.evidence_found.emit(evidence_id, def.get("kind", ""))
	return Loc.c(def.get("notice", {}))

func has(evidence_id: String) -> bool:
	return found.has(evidence_id)

# ══════════════════════════════════════════════════════════════════════════
# R3 — PEMBUSUKAN (#226/#229 kejam-cuaca). Evaluasi MALAS, bukan timer.
# ══════════════════════════════════════════════════════════════════════════
#
# ⛔ D-3 — is_decayed() DILARANG memanggil Stage.banner/EventBus.toast/
#    Audio.play_stinger/Cutscene.play. Bekas menghilang tanpa suara.
# ⛔ D-4 — DILARANG: days_remaining/decay_progress/time_left/urgency. Tak ada
#    timer, tak ada "bukti akan hilang!". Perhatian bukan manajemen antrean.
#
# ⚠ Jam mulai saat HALAMAN DICORET (start_decay_clock via Chronicle.strike),
#   bukan saat find(). Pemain yang tak peduli tetap kehilangan bekas yang tak
#   pernah ia lihat — dan tak akan tahu apa (persis A1).
# ⚠ Yang membusuk = KESEMPATAN menemukan, bukan HASIL. Bukti yang SUDAH
#   ditemukan tak pernah hilang dari tangan pemain (kejam-cuaca, bukan berpenulis).

## Dipanggil saat halaman dicoret. Jam pembusukan mulai di sini.
func start_decay_clock(page_id: String) -> void:
	if not _clock_start.has(page_id):
		_clock_start[page_id] = GameClock.unix_now()

## Umur efektif (hari) sesudah akselerasi cuaca. Cuaca basah mempercepat `washed`;
## `sunny` mempercepat `faded`. Cuaca dipakai sebagai keadaan SAAT DITANYA — konsisten
## dengan evaluasi malas pertumbuhan tanaman (Homestead). Sekali busuk, di-cache.
func _effective_days(d: Dictionary) -> float:
	var base := float(d.get("days", 0))
	var accel: Dictionary = d.get("accel", {})
	if accel.has("rain") and WorldState.is_wet_weather():
		return base / float(accel["rain"])
	if accel.has("sunny") and WorldState.weather == "sunny":
		return base / float(accel["sunny"])
	return base

## Sudahkah bekas ini membusuk? Evaluasi MALAS (pola tanaman offline — terbukti #241).
func is_decayed(evidence_id: String) -> bool:
	if decayed.has(evidence_id):
		return true
	var def: Dictionary = Db.evidence.get(evidence_id, {})
	var d: Dictionary = def.get("decay", {})
	var mode: String = d.get("mode", "never")
	if mode == "never":
		return false
	var start: int = int(_clock_start.get(def.get("page", ""), 0))
	if start == 0:
		return false                      # halaman belum dicoret — jam belum mulai
	var elapsed_days := float(GameClock.unix_now() - start) / 86400.0
	if elapsed_days >= _effective_days(d):
		decayed[evidence_id] = {"decayed_at": GameClock.date_string()}
		return true
	return false

# ══════════════════════════════════════════════════════════════════════════
# MEMBACA
# ══════════════════════════════════════════════════════════════════════════

## Bukti yang sudah ditemukan untuk satu halaman, siap dikirim ke
## Chronicle.restore(). Format: [{"kind","id","by"}, ...]
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

# ══════════════════════════════════════════════════════════════════════════
# ⛔ HUKUM D-4 — DIKODEKAN
# ══════════════════════════════════════════════════════════════════════════
#
# DILARANG ADA di file ini, selamanya:
#   found_count() · total_for_page() · progress() · percent() · missing_kinds()
#
# Alasan: "3 dari 4 bukti ditemukan" mengubah perhatian jadi checklist.
# Pemain berhenti melihat dunia dan mulai memburu ikon.
# Dan angkanya bohong — kita tak tahu berapa bekas yang ADA di dunia,
# cuma berapa yang kita tulis di data.
#
# `enough_for()` boleh ada karena ia menjawab ya/tidak untuk satu aksi
# konkret (bisakah Elyn menulis sekarang?) — bukan skor kemajuan.
# Dijaga `_test_no_evidence_score()`.
# ══════════════════════════════════════════════════════════════════════════

func _on_restored(_id: String, _loss: String) -> void:
	# Bukti TIDAK dikonsumsi. Bekas tetap ada di dunia setelah halaman ditulis.
	# Jembatan tetap terlalu lebar. Halloran tetap memanggang 200 roti.
	# Dunia tidak berubah karena seseorang mengingatnya — cuma bukunya.
	pass

# --- Save ---

func to_save() -> Dictionary:
	return {
		"found": found.duplicate(true),
		"decayed": decayed.duplicate(true),
		"clock_start": _clock_start.duplicate(true),
	}

func from_save(d: Dictionary) -> void:
	found = d.get("found", {})
	decayed = d.get("decayed", {})
	_clock_start = d.get("clock_start", {})
