extends Control
## Opening intro (FF-2g): 4 layar teks bergambar sebelum masuk dunia — memberi
## konteks & motivasi ("aku siapa, di mana, mau apa"). Klik / Space / Enter =
## lanjut; Esc = lewati. Layar 3 dipersonalisasi dengan class pilihan pemain.

## ⚠ SEMENTARA (LANGKAH 7) — SATU-SATUNYA jalan pemain menuju Ashbrook64.
##
## `regions.json` SENGAJA TIDAK disentuh: penggantian permanen 16px→32px menunggu
## playtest manusia lulus. Sampai saat itu, Ashbrook64 dijangkau lewat sini —
## ujung alur permainan baru (MainMenu → ClassSelect → CharacterCreator → Intro),
## jadi pemain masuk lewat jalur nyata, bukan lewat `--script`.
##
## CharacterCreator sudah memanggil `WorldState.new_game()` sebelum layar ini,
## jadi halaman `place_ashbrook_besar` sudah lahir DAN sudah tercoret diam-diam
## saat pemain tiba. Itu prasyarat rantai §0, dan ia terpenuhi sendirinya di sini.
##
## MENCABUTNYA: kembalikan `_finish()` ke `res://scenes/Main.tscn`. Satu baris.
const NEXT_SCENE := "res://scenes/world/Ashbrook64.tscn"

var _font: Font
var _page := 0
var _label: Label
var _hint: Label
var _icon: TextureRect
var _busy := false

func _pages() -> Array:
	var cd := Db.cls(PlayerData.char_class)
	return [
		{"icon": "res://assets/game/sky/moon/moon_4_full.png",
			"text": "Dunia Aetherion bernafas mengikuti langit yang SUNGGUHAN.\n\nSiang dan malamnya adalah siang dan malammu. Purnama di jendela kamarmu\nadalah purnama yang sama yang menarik pasang di pantai Aetherion."},
		{"icon": "",
			"text": "Namun belakangan, langit gelisah.\n\nBadai datang tak sesuai musim. Monster berkeliaran makin jauh dari sarang.\nPara Astrolog membaca satu pesan yang sama di semua rasi:\n\"Sesuatu telah bangun.\""},
		{"icon": "res://assets/game/ui/icons/element_%s_32.png" % cd.get("icon_elem", "fire"),
			"text": _page3_text(cd)},
		{"icon": "",
			"text": "Pelajari dunia. Kuasai elemen. Jinakkan yang buas.\nDan saat langit memanggil... jawablah.\n\n— AETHERION —"},
	]

## Layar 3 bervariasi per JALUR (Decision Log #33): tempur vs kehidupan.
func _page3_text(cd: Dictionary) -> String:
	if cd.get("path", "combat") == "life":
		return "Kamu — %s muda, %s — tiba di GREENVALE,\ndesa perbatasan tempat semua petualang memulai.\n\nBukan pedang yang kau bawa, tapi KEAHLIAN.\nDunia yang gelisah tetap butuh makan, alat, dan sahabat —\ndan yang menyediakannya juga menjadi legenda." % [cd.get("name", "perantau"), cd.get("title", "")]
	return "Kamu — %s muda, %s — tiba di GREENVALE,\ndesa perbatasan tempat semua petualang memulai.\n\nBukan karena Greenvale istimewa. Tapi karena setiap legenda\nharus dimulai dari suatu tempat." % [cd.get("name", "petualang"), cd.get("title", "")]

func _ready() -> void:
	theme = UiTheme.theme
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.04, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2(96, 96)
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.anchor_left = 0.5; _icon.anchor_right = 0.5
	_icon.position = Vector2(-48, 110)
	add_child(_icon)
	_label = Label.new()
	if _font: _label.add_theme_font_override("font", _font)
	_label.add_theme_font_size_override("font_size", 20)
	_label.add_theme_color_override("font_color", Color(0.93, 0.95, 1.0))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 4)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.anchor_left = 0.5; _label.anchor_right = 0.5
	_label.anchor_top = 0.5; _label.anchor_bottom = 0.5
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_label)
	_hint = Label.new()
	if _font: _hint.add_theme_font_override("font", _font)
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.add_theme_color_override("font_color", Color(0.6, 0.65, 0.8))
	_hint.text = "Klik / Space — lanjut   ·   Esc — lewati"
	_hint.anchor_left = 0.5; _hint.anchor_right = 0.5
	_hint.anchor_top = 1.0; _hint.anchor_bottom = 1.0
	_hint.position = Vector2(-130, -46)
	add_child(_hint)
	_show_page(0)
	if OS.get_environment("AETHER_SHOT") == "1":
		get_tree().create_timer(1.0).timeout.connect(func():
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit())

func _show_page(i: int) -> void:
	_page = i
	var pages := _pages()
	if i >= pages.size():
		_finish()
		return
	var p: Dictionary = pages[i]
	var ip: String = p.get("icon", "")
	_icon.texture = load(ip) if (ip != "" and ResourceLoader.exists(ip)) else null
	_icon.visible = _icon.texture != null
	_label.text = p.get("text", "")
	_label.modulate.a = 0.0
	_icon.modulate.a = 0.0
	_busy = true
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_label, "modulate:a", 1.0, 0.55)
	tw.tween_property(_icon, "modulate:a", 1.0, 0.55)
	tw.chain().tween_callback(func(): _busy = false)

func _advance() -> void:
	if _busy:
		return
	Audio.play_sfx("menu")
	_show_page(_page + 1)

func _finish() -> void:
	Stage.go_to_scene(NEXT_SCENE)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				_finish()
			KEY_SPACE, KEY_ENTER:
				_advance()
