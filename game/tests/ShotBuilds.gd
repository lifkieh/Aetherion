extends SceneTree
## Bukti mata #284: SEMUA build chargen di-screenshot satu-satu dengan labelnya.
## Laporan Direktur: "karakter laki-laki masih pregnant" — verifikasi visual,
## bukan baca kode. Tiap build dipaksa (bukan acak), preview di-refresh, jepret.
##
## Pakai: godot --path game --script res://tests/ShotBuilds.gd   (JANGAN --headless)
##   set AETHER_SHOT_OUT=D:\...\builds   (prefix)

var _t := 0.0
var _cc: Node = null
var _builds: Array = []
var _i := -1
var _out := "user://builds"
var _started := false


func _initialize() -> void:
	var o := OS.get_environment("AETHER_SHOT_OUT")
	if o != "":
		_out = o


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		if change_scene_to_file("res://scenes/ui/CharacterCreator.tscn") != OK:
			quit(1)
		return false
	_t += delta
	if _cc == null:
		_cc = current_scene
		return false
	var lg = root.get_node_or_null("LpcGen")
	if lg == null or not lg.siap():
		if _t > 3.0:
			print("[builds] LpcGen tak siap")
			quit(1)
		return false
	if _builds.is_empty():
		_builds = lg.builds()
		print("[builds] daftar: ", _builds)
	# tiap 1.6 dtk: jepret keadaan sekarang, lalu paksa build berikutnya
	if _t > 1.6:
		_t = 0.0
		if _i >= 0:
			var img := root.get_texture().get_image()
			var b: String = _builds[_i]
			img.save_png("%s_%s.png" % [_out, b])
			print("[builds] %s tersimpan" % b)
		_i += 1
		if _i >= _builds.size():
			quit(0)
			return true
		_cc.cfg = lg.rapikan({"build": _builds[_i]})
		_cc._rebuild_opsi()
		_cc._refresh_preview()
	return false
