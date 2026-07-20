extends SceneTree
## Harness tangkap-layar generik (design-time, BUKAN test — tak menambah hitungan suite).
##
## Dipakai membuktikan keterbacaan aset pada UKURAN MAIN di scene aslinya (#240:
## bukti yang tak bisa dijalankan ulang bukan bukti). Sebelum ini hanya Main.gd
## (Greenvale) yang punya jalur tangkap-layar — Ashbrook tak punya, jadi lentera
## Merrit tak bisa dibuktikan tanpa harness ini.
##
## Pakai:
##   set AETHER_SCENE=res://scenes/world/Ashbrook.tscn
##   set AETHER_SHOT_DELAY=2.5          (detik, opsional)
##   set AETHER_SHOT_OUT=D:\...\x.png   (opsional; default user://shot.png)
##   set AETHER_SHOT_COUNTERS=ashbrook_intro   (koma; dinaikkan SEBELUM scene dimuat —
##                                              melewati cutscene pembuka)
##   set AETHER_SHOT_WARP=232,330       (pindahkan pemain -> kamera ikut, sebelum jepret)
##   run_godot.bat --script res://tests/ShotScene.gd

var _t := 0.0
var _delay := 2.5
var _out := ""
var _done := false
var _warp := ""
var _scene := ""
var _started := false
var _zoom := 0.0     # AETHER_SHOT_ZOOM; 0 = biarkan kamera scene apa adanya


func _initialize() -> void:
	_scene = OS.get_environment("AETHER_SCENE")
	if _scene == "":
		_scene = "res://scenes/world/Ashbrook.tscn"
	var d := OS.get_environment("AETHER_SHOT_DELAY")
	if d != "":
		_delay = float(d)
	_warp = OS.get_environment("AETHER_SHOT_WARP")
	var z := OS.get_environment("AETHER_SHOT_ZOOM")
	if z != "":
		_zoom = float(z)
	_out = OS.get_environment("AETHER_SHOT_OUT")
	if _out == "":
		_out = "user://shot.png"


## Autoload BELUM ada saat _initialize() -> counter dinaikkan di frame pertama,
## tepat sebelum scene dimuat.
func _start() -> void:
	_started = true
	var ws := root.get_node_or_null("WorldState")
	for c in OS.get_environment("AETHER_SHOT_COUNTERS").split(",", false):
		if ws:
			ws.add_counter(c.strip_edges())
	print("[shot] scene=", _scene, " delay=", _delay)
	if change_scene_to_file(_scene) != OK:
		push_error("[shot] gagal memuat %s" % _scene)
		quit(1)


func _process(delta: float) -> bool:
	if _done:
		return true
	if not _started:
		_start()
		return false
	_t += delta
	# ZOOM: wide-shot butuh kamera ditarik mundur, dan kamera itu milik pemain.
	# Disetel DI SINI, bukan di scene — scene yang dimainkan tak boleh berubah demi
	# sebuah tangkap-layar. Disetel sesudah warp supaya kamera sempat menyusul.
	if _zoom > 0.0 and _t >= _delay * 0.6:
		var pl = root.get_tree().get_first_node_in_group("player")
		if pl:
			for c in pl.get_children():
				if c is Camera2D:
					c.zoom = Vector2(_zoom, _zoom)
		_zoom = 0.0
	if _warp != "" and _t >= _delay * 0.5:
		var parts := _warp.split(",")
		var p = root.get_tree().get_first_node_in_group("player")
		if p and parts.size() == 2:
			p.global_position = Vector2(float(parts[0]), float(parts[1]))
		_warp = ""
	if _t < _delay:
		return false
	_done = true
	var img := root.get_texture().get_image()
	if img == null:
		push_error("[shot] viewport kosong — jangan jalankan --headless")
		quit(1)
		return true
	var e := img.save_png(_out)
	if e != OK:
		push_error("[shot] gagal simpan %s (err %d)" % [_out, e])
		quit(1)
		return true
	print("[shot] tersimpan ", ProjectSettings.globalize_path(_out))
	quit(0)
	return true
