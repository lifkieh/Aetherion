extends SceneTree
## Tangkap-layar Bram BICARA (design-time, BUKAN test).
##
## Bedanya dengan `CekBram.gd`: berkas itu memanggil `persona_line()` langsung untuk
## mengukur rantainya. Berkas ini menekan **E** lewat `Input.parse_input_event()`, jadi
## yang berjalan adalah `WorldController` → `Villager.interact()` → `Stage.say()` —
## jalur yang sama persis dengan jari pemain. Kalau sambungannya putus, ia putus di sini.
##
## Pakai:
##   set AETHER_SHOT_OUT=D:\...\bram.png
##   run_godot.bat --script res://tests/ShotBram.gd

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const KEY_E := 69
const BANGKU := Vector2(736, 800)

var _step := 0
var _t := 0.0
var _tekan := 0
var _out := ""


func _initialize() -> void:
	_out = OS.get_environment("AETHER_SHOT_OUT")
	if _out == "":
		_out = "user://bram.png"


func _key(down: bool) -> void:
	var e := InputEventKey.new()
	e.keycode = KEY_E
	e.physical_keycode = KEY_E
	e.pressed = down
	Input.parse_input_event(e)


func _bram() -> Node:
	var scn := current_scene
	if scn == null:
		return null
	for c in scn.get_children():
		var sc = c.get_script()
		if sc != null and String(sc.resource_path).ends_with("Villager.gd"):
			if String(c.get("_name")) == "Old Bram":
				return c
	return null


func _process(delta: float) -> bool:
	_t += delta
	match _step:
		0:
			if change_scene_to_file(SCENE) != OK:
				push_error("[shotbram] gagal memuat scene")
				quit(1)
			_step = 1
			_t = 0.0
		1:
			if _t < 2.0:
				return false
			# Berdiri TEPAT di sebelah Bram — dan Bram berkelana, jadi posisinya
			# dibaca saat itu juga, bukan dari konstanta.
			var b := _bram()
			if b == null:
				push_error("[shotbram] Old Bram tak ditemukan")
				quit(1)
				return true
			var pl = root.get_tree().get_first_node_in_group("player")
			if pl == null:
				push_error("[shotbram] pemain tak ada")
				quit(1)
				return true
			pl.global_position = b.global_position + Vector2(0, 34)
			_step = 2
			_t = 0.0
		2:
			if _t < 0.6:
				return false
			# Tekan E berulang: `persona_line()` menyelingi sapaan & gosip, jadi
			# beberapa tekan diperlukan sebelum baris kelima muncul. Tiap tekan
			# dijalankan lewat WorldController, sama seperti pemain.
			var ev = root.get_node("Evidence")
			var st = root.get_node("Stage")
			if ev.has("ev_ashbrook_bram_ingat_ayahnya") or _tekan > 160:
				_step = 3
				_t = 0.0
				return false
			# ⚠ IKUTI DIA. Bram berkelana; menaruh pemain sekali lalu menekan E
			#   berulang kali membuat separuh tekan jatuh di luar radius 44 px, dan
			#   hasilnya terbaca "dialog tak jalan" padahal cuma orangnya menjauh.
			var b2 := _bram()
			var pl2 = root.get_tree().get_first_node_in_group("player")
			if b2 != null and pl2 != null:
				pl2.global_position = b2.global_position + Vector2(0, 30)
			if not st.is_busy():
				_key(true)
				_key(false)
				_tekan += 1
			else:
				_key(true)   # tutup teks, lanjut giliran berikutnya
				_key(false)
			_t = 0.0
		3:
			# satu tekan terakhir supaya teks kesaksiannya TERBUKA saat dijepret
			if _t < 0.4:
				return false
			_key(true)
			_key(false)
			_step = 4
			_t = 0.0
		4:
			if _t < 1.2:
				return false
			var img := root.get_texture().get_image()
			if img == null:
				push_error("[shotbram] viewport kosong — jangan jalankan --headless")
				quit(1)
				return true
			img.save_png(_out)
			var ev2 = root.get_node("Evidence")
			print("[shotbram] tekan E %dx · bukti tercatat: %s"
				% [_tekan, str(ev2.has("ev_ashbrook_bram_ingat_ayahnya"))])
			print("[shotbram] tersimpan ", _out)
			quit(0)
			return true
	return false
