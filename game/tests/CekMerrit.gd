extends SceneTree
## CEK BUKTI KAMAR MERRIT (Jalur B, #226 · #151b).
##
## Yang diuji bukan "apakah kodenya jalan" melainkan apakah bukti Merrit BISA
## DITEMUKAN PEMAIN. Bedanya nyata: `evidence.json` sudah memuat teks lengkap untuk
## keempat bukti Merrit sejak lama, dan tiga di antaranya tak pernah bisa ditemukan
## siapa pun karena tak punya titik di dunia. Data yang lengkap tanpa titik terbaca
## sebagai "sudah dikerjakan" di tiap laporan, dan tetap tak ada di layar.
##
## Uji ini juga menjaga aturan JARAK yang sudah dibayar sekali: dua `Interactable`
## yang lebih dekat dari 72 px saling merebut tombol E, dan gejalanya BUKAN galat —
## melainkan bukti yang diam.

const R := 72.0                      # radius label `Interactable`

var _l := 0
var _g := 0


func _ok(label: String, cond: bool, detail := "") -> void:
	if cond:
		_l += 1
	else:
		_g += 1
	print("  [%s] %s%s" % ["LULUS" if cond else "GAGAL", label,
		"" if detail == "" else "  -> " + detail])


const SCENE := "res://scenes/world/Ashbrook64.tscn"

var _mulai := false
var _t := 0.0


## POLA `_process`, BUKAN `_initialize` + `await`. Percobaan pertama memakai
## `_initialize()` dengan `await process_frame` dan prosesnya MENGGANTUNG tanpa satu
## baris keluaran pun — bukan gagal, cuma diam. `extends SceneTree` di mode `--script`
## menjalankan loop-nya sendiri; scene harus dimuat lewat `change_scene_to_file` lalu
## ditunggu beberapa frame. Pola ini disalin dari `CekBram.gd` yang sudah bekerja.
func _process(delta: float) -> bool:
	if not _mulai:
		_mulai = true
		if change_scene_to_file(SCENE) != OK:
			push_error("[merrit] gagal memuat scene")
			quit(1)
		return false
	_t += delta
	if _t < 1.5:
		return false
	quit(_ukur())
	return true


func _ukur() -> int:
	print("===== BUKTI KAMAR MERRIT (Jalur B) =====")
	var w := current_scene
	if w == null:
		print("GAGAL: scene kosong")
		return 1
	var db = root.get_node("Db")
	var ev = root.get_node("Evidence")

	# 1 — data: keempat bukti Merrit terdaftar
	for e in ["ev_merrit_kartu_pos_kosong", "ev_merrit_cangkir_kedua",
			"ev_merrit_rute_pos_berubah", "ev_merrit_arlen_ingat"]:
		_ok("data: %s terdaftar" % e, db.evidence.has(e))

	# 2 — dunia: titik `examine` benar-benar ADA
	var titik := {}
	# ⚠ `n.get()` mengembalikan null untuk node yang TAK PUNYA properti itu, dan
	#   `String(null)` bukan konstruktor yang sah. Diperiksa eksplisit, bukan dibungkus
	#   konversi — konversi yang menelan null akan menyamakan "tak punya bukti" dengan
	#   "bukti bernama kosong", dan keduanya butuh jawaban berbeda.
	for n in w.get_tree().get_nodes_in_group("interactable"):
		var eid = n.get("evidence_id")
		if eid != null and str(eid) != "":
			titik[str(eid)] = n.global_position

	var wajib := ["ev_merrit_kartu_pos_kosong", "ev_merrit_rute_pos_berubah"]
	for e in wajib:
		_ok("dunia: %s punya titik-periksa" % e, titik.has(e),
			"bukti bertekst tanpa titik = tak pernah bisa ditemukan")

	# 3 — JARAK >= 72 px dari interaktif lain
	for e in wajib:
		if not titik.has(e):
			continue
		var pos: Vector2 = titik[e]
		var dekat := []
		for n in w.get_tree().get_nodes_in_group("interactable"):
			var other = n.get("evidence_id")
			if other != null and str(other) == e:
				continue
			var d := pos.distance_to(n.global_position)
			if d < R:
				dekat.append("%s %.0fpx" % [n.name, d])
		_ok("jarak: %s tak berebut E" % e, dekat.is_empty(), str(dekat))

	# 4 — WAJAH ASLI, bukan warga_NNN generik
	var lembar := ""
	for p in db.town_npcs.get("ashbrook", []):
		if String(p.get("name", "")) == "Merrit Fane":
			lembar = String(p.get("lpc_sheet", ""))
	_ok("Merrit memakai wajah asli `merrit_fane`", lembar == "merrit_fane", lembar)

	# 5 — menemukannya harus benar-benar MENCATATNYA
	var sebelum: bool = ev.has("ev_merrit_kartu_pos_kosong")
	ev.find("ev_merrit_kartu_pos_kosong")
	_ok("Evidence.find mencatat kartu pos", not sebelum
		and ev.has("ev_merrit_kartu_pos_kosong"))

	print("
===== MERRIT: %d lulus, %d gagal =====" % [_l, _g])
	return 0 if _g == 0 else 1
