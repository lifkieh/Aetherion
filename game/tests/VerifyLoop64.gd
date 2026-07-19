extends SceneTree
## Harness verifikasi core loop di scene 64px (#254 tugas 2) — BUKAN test suite.
## Tak menambah hitungan gerbang; ia menjalankan JALUR PEMAIN di scene baru dan melapor.
##
## HUKUM #151b: wajah boleh berubah, LOGIKA tidak. Harness ini membuktikan bahwa
## setelah Ashbrook dipindah ke LPC, pemain masih bisa:
##   1. memeriksa lima objek (Evidence.find lewat Interactable yang SAMA)
##   2. mengumpulkan ≥3 jenis bukti
##   3. SENDIRIAN memulihkan `place_ashbrook_besar` (#228)
##   4. melihat lampu Merrit menyala (hook siluet #229)
##
## Jalankan: AETHER_SCENE opsional; default scene 64px.
##   run_godot.bat --script res://tests/VerifyLoop64.gd

var _t := 0.0
var _started := false
var _done := false
var _scene := "res://scenes/world/Ashbrook64.tscn"


func _initialize() -> void:
	var s := OS.get_environment("AETHER_SCENE")
	if s != "":
		_scene = s


func _process(delta: float) -> bool:
	if _done:
		return true
	if not _started:
		_started = true
		if change_scene_to_file(_scene) != OK:
			print("[verify] GAGAL memuat ", _scene)
			quit(1)
		return false
	_t += delta
	if _t < 2.0:
		return false
	_done = true
	_run()
	quit(0)
	return true


func _run() -> void:
	var ws = root.get_node_or_null("WorldState")
	var ev = root.get_node_or_null("Evidence")
	var ch = root.get_node_or_null("Chronicle")
	if ev == null or ch == null:
		print("[verify] autoload tak ada")
		return
	ev.found.clear()
	ev.decayed.clear()
	ev._clock_start.clear()

	print("\n===== VERIFIKASI CORE LOOP — %s =====" % _scene)

	# 1) titik periksa yang benar-benar ADA di dunia
	var points := []
	for n in root.get_tree().get_nodes_in_group("interactable"):
		if str(n.get("kind")) == "examine" and str(n.get("evidence_id")) != "":
			points.append(n)
	print("[1] titik-periksa di scene : %d" % points.size())

	# 2) pemain memeriksa semuanya (jalur yang sama dengan tekan-E)
	var read := 0
	for n in points:
		var notice: String = n.examine_notice()
		var tag := "OK " if notice != "" else "KOSONG"
		print("    %-34s %s" % [str(n.get("evidence_id")), tag])
		if notice != "":
			read += 1
	print("[2] bukti terbaca          : %d dari %d" % [read, points.size()])

	# 3) jenis bukti untuk halaman Ashbrook-besar
	var kinds: Array = ev.kinds_for("place_ashbrook_besar")
	print("[3] jenis bukti terkumpul  : %d  %s" % [kinds.size(), str(kinds)])

	# 4) pemain SENDIRIAN memulihkan halaman (#228)
	for i in range(ws.chronicle.size() - 1, -1, -1):
		if ws.chronicle[i].get("id", "") == "place_ashbrook_besar":
			ws.chronicle.remove_at(i)
	ch.record_person("place_ashbrook_besar", "Ashbrook — kota yang dulu besar")
	var struck: bool = ch.strike("place_ashbrook_besar")
	var enough: bool = ev.enough_for("place_ashbrook_besar", ch.SCRIBE_SELF)
	var r: Dictionary = ch.restore("place_ashbrook_besar",
		ev.for_page("place_ashbrook_besar"), ch.SCRIBE_SELF)
	print("[4] halaman tercoret       : %s" % str(struck))
	print("    cukup utk jalur SENDIRI: %s" % str(enough))
	print("    pulih                  : %s  (%s)" % [str(r.get("ok")), str(r.get("reason"))])
	print("    yang TETAP hilang      : %s" % str(r.get("loss")).substr(0, 70))

	# 5) lampu Merrit
	var lamps := 0
	for n in root.get_tree().get_nodes_in_group("lamp_beacon"):
		lamps += 1
	var lit := false
	for n in _all(root):
		if n is PointLight2D and n.energy > 0.0:
			lit = true
			break
	print("[5] beacon lampu           : %d   PointLight2D menyala: %s" % [lamps, str(lit)])
	print("===== SELESAI =====\n")


func _all(n: Node) -> Array:
	var out := [n]
	for c in n.get_children():
		out += _all(c)
	return out
