extends SceneTree
## Harness verifikasi SLICE PAYOFF (SPEC_PAYOFF_SLICE §6) — scene 16px.
## BUKAN test suite: tak menambah hitungan gerbang (#249). Ia menjalankan
## JALUR PEMAIN di `Ashbrook.tscn` dan melaporkan apa adanya.
##
## Harness BOLEH membaca state internal; UI TIDAK (D-4/K-3).
##
## Jalankan:
##   run_godot.bat --script res://tests/VerifySlice.gd

const PAGE := "place_ashbrook_besar"

var _t := 0.0
var _started := false
var _done := false
var _noise := 0


func _process(delta: float) -> bool:
	if _done:
		return true
	if not _started:
		_started = true
		# Replikasi jalur pemain NYATA: CharacterCreator.gd:233-234 memanggil
		# PlayerData.new_game() lalu WorldState.new_game() sebelum masuk dunia.
		# Halaman Ashbrook lahir di lapisan itu (#261), bukan di _ready scene.
		var pd = root.get_node_or_null("PlayerData")
		var ws0 = root.get_node_or_null("WorldState")
		if pd:
			pd.new_game()
		if ws0:
			ws0.new_game()
		if change_scene_to_file("res://scenes/world/Ashbrook.tscn") != OK:
			print("[slice] GAGAL memuat Ashbrook.tscn")
			quit(1)
		return false
	_t += delta
	if _t < 2.5:
		return false
	_done = true
	_run()
	quit(0)
	return true


func _run() -> void:
	var ws = root.get_node_or_null("WorldState")
	var ch = root.get_node_or_null("Chronicle")
	var ev = root.get_node_or_null("Evidence")
	if ws == null or ch == null or ev == null:
		print("[slice] autoload tak ada")
		return

	print("\n===== VERIFIKASI SLICE PAYOFF — Ashbrook 16px =====")

	# ---- [1] halaman lahir, by = merrit_fane, state struck, NOL feedback ----
	var page := {}
	for e in ws.chronicle:
		if e.get("id", "") == PAGE:
			page = e
			break
	print("[1] halaman '%s' ada       : %s" % [PAGE, str(not page.is_empty())])
	if page.is_empty():
		print("    -> GAGAL: halaman tak pernah lahir")
		return
	print("    by                     : %s   %s" % [
		str(page.get("by", "")), "OK" if page.get("by", "") == "merrit_fane" else "SALAH"])
	print("    state                  : %s   %s" % [
		str(page.get("state", "")), "OK" if page.get("state", "") == "struck" else "SALAH"])
	print("    struck_cause (internal): '%s'  (TAK PERNAH ditampilkan — #229.4)" % str(page.get("struck_cause", "")))
	print("    kind                   : %s" % str(page.get("kind", "")))

	# ---- nol feedback: pasang pengintai SEBELUM strike ulang ----
	_noise = 0
	var eb = root.get_node_or_null("EventBus")
	var f := func(_a = null, _b = null, _c = null): _noise += 1
	if eb and eb.has_signal("toast"):
		eb.toast.connect(f)
	# strike ulang halaman baru untuk mengukur kebisingannya
	ch.record_person("__uji_senyap__", "Uji Senyap", "merrit_fane")
	var struck_again: bool = ch.strike("__uji_senyap__", "waktu")
	if eb and eb.has_signal("toast"):
		eb.toast.disconnect(f)
	print("    strike senyap          : strike=%s  toast=%d  %s" % [
		str(struck_again), _noise, "OK" if _noise == 0 else "BISING — MELANGGAR K-4"])

	# ---- [2] tiga jenis bukti terjangkau di titik-periksa 16px NYATA ----
	ev.found.clear()
	ev.decayed.clear()
	ev._clock_start.clear()
	var points := []
	for n in root.get_tree().get_nodes_in_group("interactable"):
		if str(n.get("kind")) == "examine" and str(n.get("evidence_id")) != "":
			points.append(n)
	var read := 0
	for n in points:
		if n.examine_notice() != "":
			read += 1
	var kinds: Array = ev.kinds_for(PAGE)
	kinds.sort()
	print("[2] titik-periksa 16px     : %d   terbaca: %d" % [points.size(), read])
	print("    jenis terkumpul        : %d  %s   %s" % [
		kinds.size(), str(kinds), "OK" if kinds.size() >= 3 else "KURANG"])
	print("    cukup jalur SENDIRI    : %s" % str(ev.enough_for(PAGE, ch.SCRIBE_SELF)))
	print("    cukup jalur ELYN       : %s" % str(ev.enough_for(PAGE, ch.SCRIBE_ELYN)))

	print("===== SELESAI =====\n")
