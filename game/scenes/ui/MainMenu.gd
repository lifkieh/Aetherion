extends Control
## Main Menu (M8) — entry scene. New Game / Load (3 slots) / Options / Quit,
## with a Sky Report of the real sky right now (Fase0 §8, v0.2 §10.8).

var _font: Font

func _ready() -> void:
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	theme = UiTheme.theme    # unified UI kit
	_build()
	if OS.get_environment("AETHER_SHOT") == "1":
		get_tree().create_timer(0.8).timeout.connect(func():
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit())

func _lbl(t: String, s: int) -> Label:
	var l := Label.new()
	l.text = t
	if _font: l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", s)
	l.add_theme_constant_override("outline_size", 4)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	return l

func _button(t: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = t
	if _font: b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", 18)
	b.custom_minimum_size = Vector2(320, 34)
	b.pressed.connect(cb)
	return b

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.07, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# moon icon
	var mi := TextureRect.new()
	var idx := GameClock.moon_index()
	var mp := "res://assets/game/sky/moon/moon_%d_%s.png" % [idx, ["new","waxing_crescent","first_quarter","waxing_gibbous","full","waning_gibbous","last_quarter","waning_crescent"][idx]]
	if ResourceLoader.exists(mp):
		mi.texture = load(mp)
	mi.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mi.custom_minimum_size = Vector2(96, 96)
	mi.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mi.position = Vector2(90, 60)
	add_child(mi)

	var vb := VBoxContainer.new()
	vb.position = Vector2(90, 170)
	vb.add_theme_constant_override("separation", 8)
	add_child(vb)

	var title := _lbl("AETHERION", 56)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.7))
	vb.add_child(title)
	vb.add_child(_lbl("Dunia yang mengikuti langit sungguhan.", 16))

	# Sky Report
	var ev := GameClock.sky_event_today()
	var report := "☾ %s  ·  %s  ·  %s WIB  ·  Cuaca: %s" % [
		GameClock.moon_name(), GameClock.date_string(), GameClock.time_string(),
		{"sunny":"Cerah","rain":"Hujan","thunderstorm":"Badai Petir","blizzard":"Salju","blood_moon":"Bulan Darah"}.get(WorldState.weather, WorldState.weather)]
	if ev != "": report += "  ·  ✦ " + ev
	var rl := _lbl(report, 15)
	rl.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	vb.add_child(rl)

	vb.add_child(_spacer(10))
	vb.add_child(_button("Main Baru", _new_game))
	if SaveManager.has_save(1) or SaveManager.has_save(2) or SaveManager.has_save(3):
		for slot in [1, 2, 3]:
			if SaveManager.has_save(slot):
				var meta := SaveManager.save_meta(slot)
				vb.add_child(_button("Muat Slot %d — %s Lv%d (%s)" % [slot, meta.get("name", "?"), meta.get("level", 1), meta.get("saved_at_str", "?")], _load.bind(slot)))
	# Options
	var eco := CheckButton.new()
	eco.text = "Mode Hemat (30fps, tanpa VFX cuaca)"
	if _font: eco.add_theme_font_override("font", _font)
	eco.button_pressed = Settings.eco_mode
	eco.toggled.connect(func(v): Settings.set_eco(v))
	vb.add_child(eco)
	var mute := CheckButton.new()
	mute.text = "Bisukan Audio"
	if _font: mute.add_theme_font_override("font", _font)
	mute.button_pressed = Settings.muted
	mute.toggled.connect(func(v): Settings.set_muted_pref(v))
	vb.add_child(mute)

	vb.add_child(_spacer(6))
	vb.add_child(_button("Keluar", func(): get_tree().quit()))

	var hint := _lbl("Rasi Kelahiranmu ditentukan hari kamu mulai. Langit di game = langit asli WIB.", 12)
	hint.position = Vector2(90, 640)
	add_child(hint)

func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

func _new_game() -> void:
	PlayerData.new_game()
	WorldState.new_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _load(slot: int) -> void:
	if SaveManager.load_game(slot):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
