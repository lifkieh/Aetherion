extends CanvasLayer
## Pause menu layak (v0.4.1, owner review i): Resume / Pengaturan (volume per
## channel + fullscreen + eco) / Simpan / Menu Utama — overlay khusus, terpisah
## dari tas. Dibuka WorldController saat ESC.

var _font: Font
var root: Control
var _mode := "main"   # main | settings

static func open_over(tree: SceneTree) -> void:
	if tree.get_first_node_in_group("pause_menu") != null:
		return
	var pm := load("res://scenes/ui/PauseMenu.gd").new()
	tree.current_scene.add_child(pm)

func _ready() -> void:
	layer = 25
	add_to_group("pause_menu")
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	get_tree().paused = true
	_build()

func _build() -> void:
	if root:
		root.queue_free()
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = UiTheme.theme
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.08, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5; panel.anchor_right = 0.5
	panel.anchor_top = 0.5; panel.anchor_bottom = 0.5
	panel.custom_minimum_size = Vector2(340, 0)
	panel.position = Vector2(-170, -160)
	root.add_child(panel)
	UiFx.panel_in(panel)   # (#44)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	panel.add_child(vb)
	var title := _lbl("⏸ JEDA" if _mode == "main" else "⚙ Pengaturan", 24, Color(1.0, 0.86, 0.42))
	vb.add_child(title)
	if _mode == "main":
		vb.add_child(_btn(Loc.t("ui.pause.resume"), _close))
		vb.add_child(_btn(Loc.t("ui.pause.settings"), func(): _mode = "settings"; _build()))
		vb.add_child(_btn(Loc.t("ui.pause.save") % SaveManager.current_slot, func():
			SaveManager.save_game(SaveManager.current_slot)))
		vb.add_child(_btn(Loc.t("ui.pause.to_title"), func():
			get_tree().paused = false
			queue_free()
			Stage.go_to_scene("res://scenes/ui/MainMenu.tscn")))
	else:
		vb.add_child(_slider("Musik", Settings.music_volume, func(v): Settings.set_music_volume(v)))
		vb.add_child(_slider("Efek Suara", Settings.sfx_volume, func(v): Settings.set_sfx_volume(v)))
		vb.add_child(_check("Layar Penuh", Settings.fullscreen, func(v): Settings.set_fullscreen(v)))
		vb.add_child(_check("Mode Hemat (30fps)", Settings.eco_mode, func(v): Settings.set_eco(v)))
		vb.add_child(_check("Bisukan Audio", Settings.muted, func(v): Settings.set_muted_pref(v)))
		vb.add_child(_btn("← Kembali", func(): _mode = "main"; _build()))

func _lbl(t: String, s: int, col := Color(0.94, 0.96, 1.0)) -> Label:
	var l := Label.new()
	l.text = t
	if _font: l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", s)
	l.add_theme_color_override("font_color", col)
	return l

func _btn(t: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = t
	if _font: b.add_theme_font_override("font", _font)
	b.custom_minimum_size = Vector2(300, 34)
	b.pressed.connect(func(): Audio.play_sfx("menu"))
	b.pressed.connect(cb)
	UiFx.button(b)   # (#44)
	return b

func _slider(label: String, value: float, cb: Callable) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	var l := _lbl(label, 15)
	l.custom_minimum_size = Vector2(110, 0)
	h.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(170, 20)
	s.value_changed.connect(cb)
	s.drag_ended.connect(func(_c): Audio.play_sfx("menu"))
	h.add_child(s)
	return h

func _check(label: String, value: bool, cb: Callable) -> CheckButton:
	var c := CheckButton.new()
	c.text = label
	if _font: c.add_theme_font_override("font", _font)
	c.button_pressed = value
	c.toggled.connect(cb)
	return c

func _close() -> void:
	get_tree().paused = false
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		if _mode == "settings":
			_mode = "main"
			_build()
		else:
			_close()
		get_viewport().set_input_as_handled()
