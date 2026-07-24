extends SceneTree
## Harness reproduksi bug chargen (design-time, BUKAN test — tak menambah suite).
##
## Laporan Direktur (#280b): "memilih karakter player, terus ganti-ganti, spritenya
## ketimpa-timpa." Harness ini membuktikan/membantah dengan MATA + angka:
##   1. muat CharacterCreator sebagai scene baru,
##   2. jepret keadaan awal,
##   3. tekan ▶ "Bentuk Badan" beberapa kali TERPISAH frame (klik normal),
##   4. tekan ▶ dua kali DALAM SATU FRAME (klik cepat — memancing race
##      `_rebuild_opsi()` yang await process_frame),
##   5. jepret + hitung baris `_opts_box` dan jumlah AnimatedSprite2D preview
##      di tiap tahap. Baris > 6 atau sprite > 4 = tumpukan terbukti.
##
## Pakai:
##   set AETHER_SHOT_OUT=D:\...\chargen_repro   (prefix; _0.png, _1.png, ...)
##   run godot --path game --script res://tests/ShotChargen.gd   (JANGAN --headless)

var _t := 0.0
var _step := 0
var _out := "user://chargen_repro"
var _started := false
var _cc: Node = null


func _initialize() -> void:
	var o := OS.get_environment("AETHER_SHOT_OUT")
	if o != "":
		_out = o


func _start() -> void:
	_started = true
	if change_scene_to_file("res://scenes/ui/CharacterCreator.tscn") != OK:
		push_error("[chargen-repro] gagal memuat CharacterCreator")
		quit(1)


## Tombol ▶ pertama pada baris berlabel `label` di _opts_box.
func _btn_maju(label: String) -> Button:
	if _cc == null or not is_instance_valid(_cc):
		return null
	var box: VBoxContainer = _cc._opts_box
	if box == null:
		return null
	for row in box.get_children():
		var lbl := row.get_child(0) if row.get_child_count() > 0 else null
		if lbl is Label and (lbl as Label).text == label:
			for c in row.get_children():
				if c is Button and (c as Button).text == "▶":
					return c
	return null


func _hitung() -> Dictionary:
	var rows := 0
	var sprites := 0
	if _cc and is_instance_valid(_cc):
		if _cc._opts_box:
			for c in _cc._opts_box.get_children():
				if not c.is_queued_for_deletion():
					rows += 1
		for c in _cc.get_children():
			if c is AnimatedSprite2D:
				sprites += 1
	return {"rows": rows, "sprites": sprites}


func _jepret(tag: String) -> void:
	var img := root.get_texture().get_image()
	if img:
		var p := "%s_%s.png" % [_out, tag]
		img.save_png(p)
		var n := _hitung()
		print("[chargen-repro] %s -> rows=%d sprites=%d (%s)" % [tag, n.rows, n.sprites, p])


func _process(delta: float) -> bool:
	if not _started:
		_start()
		return false
	_t += delta
	if _cc == null:
		_cc = current_scene
		return false
	# Tahapan berjeda supaya rakit sheet + rebuild panel selesai antar-langkah.
	if _step == 0 and _t > 2.0:
		_step = 1
		_jepret("0_awal")
	elif _step == 1 and _t > 3.0:
		_step = 2
		var b := _btn_maju("Bentuk Badan")
		if b: b.pressed.emit()
	elif _step == 2 and _t > 4.0:
		_step = 3
		_jepret("1_ganti_badan_1x")
		var b := _btn_maju("Bentuk Badan")
		if b: b.pressed.emit()
	elif _step == 3 and _t > 5.0:
		_step = 4
		_jepret("2_ganti_badan_2x")
		# RACE: dua tekan dalam SATU frame
		var b := _btn_maju("Bentuk Badan")
		if b:
			b.pressed.emit()
			b.pressed.emit()
	elif _step == 4 and _t > 6.5:
		_step = 5
		_jepret("3_race_2klik_1frame")
		# ganti baju cepat 3x satu frame
		var b := _btn_maju("Baju")
		if b:
			b.pressed.emit()
			b.pressed.emit()
			b.pressed.emit()
	elif _step == 5 and _t > 8.0:
		_step = 6
		_jepret("4_race_baju_3klik")
		var n := _hitung()
		print("[chargen-repro] AKHIR rows=%d sprites=%d — sehat: rows=6, sprites=4" % [n.rows, n.sprites])
		quit(0)
		return true
	return false
