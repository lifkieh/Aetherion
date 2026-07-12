extends CanvasLayer
## Character Creator (Aetherion Character System v2). Used at New Game (as the scene)
## and by the "Cermin Jiwa" NPC (added as an overlay, edit mode). Pick per-part race,
## hair, per-part skin, and outfit colours with a live 4-direction preview.

const RACE_NAME := {"human": "Manusia", "human2": "Manusia II", "wolfkin": "Serigala",
	"lizardkin": "Kadal", "candyfolk": "Permen", "frostkin": "Es", "undead": "Mayat Hidup"}
const HAIR_NAME := {"short": "Pendek", "long": "Panjang", "spiky": "Jabrik", "mohawk": "Mohawk", "bun": "Sanggul", "none": "Tanpa"}
const SKIN_SWATCH := ["", "#f5c9a2", "#c98a5c", "#a5713f", "#8d5a3a", "#e8b98f", "#6fb4d9", "#f78fc8", "#a89fc4", "#4fa352"]
const HAIR_SWATCH := ["#241f36", "#6b4226", "#3a2a1a", "#c9a227", "#e8e2f4", "#8f2611", "#3a6fa0", "#b8e4f2", "#c4302b", "#eefaff"]
const CLOTH_SWATCH := ["#2e6b3f", "#8a3a6b", "#1e3a5c", "#8f2611", "#453d5c", "#3a6fa0", "#5c2380", "#6b4226", "#d95fa4", "#c9a227", "#2b2b3a", "#e8e2f4"]
const EDIT_COST := 150

var mode := "new"
var cfg: Dictionary = {}
var _preview: Array = []          # 4 AnimatedSprite2D (down/left/right/up)
var _font: Font
var _opts_box: VBoxContainer

func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	mode = "new" if get_tree().current_scene == self else "edit"
	if mode == "edit":
		get_tree().paused = true
		cfg = PlayerData.char_config.duplicate(true)
	else:
		cfg = CharGen.default_config()
	_build()
	_refresh_preview()
	if OS.get_environment("AETHER_SHOT") == "1":
		get_tree().create_timer(1.0).timeout.connect(func():
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit())

# --- setup for edit overlay -------------------------------------------------

func open_edit() -> void:
	mode = "edit"

# --- UI ---------------------------------------------------------------------

func _lbl(t: String, s: int, col := Color(0.94, 0.96, 1.0)) -> Label:
	var l := Label.new()
	l.text = t
	if _font: l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", s)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 4)
	return l

func _build() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = UiTheme.theme
	add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.04, 0.05, 0.11, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var title := _lbl("Cermin Jiwa — Ubah Rupa" if mode == "edit" else "Buat Karaktermu", 30, Color(1.0, 0.86, 0.42))
	title.position = Vector2(40, 24)
	root.add_child(title)

	# preview panel (left)
	var pv := PanelContainer.new()
	pv.position = Vector2(40, 84)
	pv.custom_minimum_size = Vector2(420, 300)
	root.add_child(pv)
	var pvlabel := _lbl("4 arah:", 14, Color(0.8, 0.84, 0.95))
	pvlabel.position = Vector2(56, 92)
	root.add_child(pvlabel)
	# 4 animated preview sprites (screen-space, CanvasLayer)
	var dirs := ["down", "left", "right", "up"]
	for i in range(4):
		var a := AnimatedSprite2D.new()
		a.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		a.scale = Vector2(3.4, 3.4)
		a.position = Vector2(110 + i * 96, 250)
		add_child(a)
		_preview.append({"spr": a, "dir": dirs[i]})
		var dl := _lbl(["Depan", "Kiri", "Kanan", "Blkg"][i], 12, Color(0.7, 0.74, 0.88))
		dl.position = Vector2(84 + i * 96, 330)
		root.add_child(dl)

	# options panel (right)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(490, 84)
	scroll.custom_minimum_size = Vector2(740, 520)
	scroll.set_anchor_and_offset(SIDE_RIGHT, 1.0, -20)
	root.add_child(scroll)
	_opts_box = VBoxContainer.new()
	_opts_box.add_theme_constant_override("separation", 6)
	_opts_box.custom_minimum_size = Vector2(720, 0)
	scroll.add_child(_opts_box)

	_cycler("Kepala (ras)", "head_race", CharGen.races(), RACE_NAME)
	_cycler("Badan & Tangan (ras)", "torso_race", CharGen.races(), RACE_NAME)
	_cycler("Kaki (ras)", "legs_race", CharGen.races(), RACE_NAME)
	_cycler("Rambut", "hair", CharGen.hair_styles(), HAIR_NAME)
	_swatches("Warna Rambut", "hair_color", HAIR_SWATCH)
	_swatches("Kulit Kepala", "head_skin", SKIN_SWATCH)
	_swatches("Kulit Badan", "torso_skin", SKIN_SWATCH)
	_swatches("Kulit Kaki", "legs_skin", SKIN_SWATCH)
	_swatches("Baju", "shirt", CLOTH_SWATCH)
	_swatches("Celana", "pants", CLOTH_SWATCH)

	# buttons (bottom)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 12)
	bar.position = Vector2(40, 620)
	root.add_child(bar)
	bar.add_child(_btn("🎲 Acak", _randomize))
	if mode == "edit":
		bar.add_child(_btn("Simpan (%dG)" % EDIT_COST, _confirm))
		bar.add_child(_btn("Batal", _cancel))
	else:
		bar.add_child(_btn("Mulai Petualangan ▶", _confirm))

func _btn(t: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = t
	if _font: b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", 18)
	b.custom_minimum_size = Vector2(220, 36)
	b.pressed.connect(func(): Audio.play_sfx("menu"); cb.call())
	return b

func _cycler(label: String, key: String, values: Array, names: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_opts_box.add_child(row)
	var l := _lbl(label, 15)
	l.custom_minimum_size = Vector2(240, 0)
	row.add_child(l)
	var val := _lbl("", 15, Color(1.0, 0.9, 0.6))
	val.custom_minimum_size = Vector2(150, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var refresh := func():
		val.text = names.get(cfg.get(key, values[0]), str(cfg.get(key, values[0])))
	var step := func(dir: int):
		var cur: int = maxi(0, values.find(cfg.get(key, values[0])))
		cfg[key] = values[(cur + dir + values.size()) % values.size()]
		refresh.call(); _refresh_preview()
	row.add_child(_btn2("◀", func(): step.call(-1)))
	row.add_child(val)
	row.add_child(_btn2("▶", func(): step.call(1)))
	refresh.call()

func _btn2(t: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = t
	if _font: b.add_theme_font_override("font", _font)
	b.custom_minimum_size = Vector2(38, 30)
	b.pressed.connect(func(): Audio.play_sfx("menu"); cb.call())
	return b

func _swatches(label: String, key: String, colors: Array) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	_opts_box.add_child(row)
	var l := _lbl(label, 15)
	l.custom_minimum_size = Vector2(240, 0)
	row.add_child(l)
	for hex in colors:
		var sw := Button.new()
		sw.custom_minimum_size = Vector2(26, 26)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color.html(hex) if hex != "" else Color(0.2, 0.2, 0.24)
		sb.set_corner_radius_all(4); sb.set_border_width_all(1); sb.border_color = Color(0, 0, 0, 0.6)
		sw.add_theme_stylebox_override("normal", sb)
		sw.add_theme_stylebox_override("hover", sb)
		sw.add_theme_stylebox_override("pressed", sb)
		if hex == "":
			sw.text = "R"      # R = pakai warna ras
			if _font: sw.add_theme_font_override("font", _font)
		sw.pressed.connect(func(): Audio.play_sfx("menu"); cfg[key] = hex; _refresh_preview())
		row.add_child(sw)

func _refresh_preview() -> void:
	var sf := CharGen.sprite_frames(cfg)
	for p in _preview:
		p.spr.sprite_frames = sf
		p.spr.play("walk_" + p.dir)

func _randomize() -> void:
	var races := CharGen.races()
	cfg = {
		"head_race": races[randi() % races.size()],
		"torso_race": races[randi() % races.size()],
		"legs_race": races[randi() % races.size()],
		"hair": CharGen.hair_styles()[randi() % CharGen.hair_styles().size()],
		"hair_color": HAIR_SWATCH[randi() % HAIR_SWATCH.size()],
		"shirt": CLOTH_SWATCH[randi() % CLOTH_SWATCH.size()],
		"pants": CLOTH_SWATCH[randi() % CLOTH_SWATCH.size()],
	}
	_rebuild_options()
	_refresh_preview()

func _rebuild_options() -> void:
	for c in _opts_box.get_children():
		c.queue_free()
	_cycler("Kepala (ras)", "head_race", CharGen.races(), RACE_NAME)
	_cycler("Badan & Tangan (ras)", "torso_race", CharGen.races(), RACE_NAME)
	_cycler("Kaki (ras)", "legs_race", CharGen.races(), RACE_NAME)
	_cycler("Rambut", "hair", CharGen.hair_styles(), HAIR_NAME)
	_swatches("Warna Rambut", "hair_color", HAIR_SWATCH)
	_swatches("Kulit Kepala", "head_skin", SKIN_SWATCH)
	_swatches("Kulit Badan", "torso_skin", SKIN_SWATCH)
	_swatches("Kulit Kaki", "legs_skin", SKIN_SWATCH)
	_swatches("Baju", "shirt", CLOTH_SWATCH)
	_swatches("Celana", "pants", CLOTH_SWATCH)

func _confirm() -> void:
	if mode == "edit":
		PlayerData.char_config = cfg.duplicate(true)
		PlayerData.spend_gold(EDIT_COST)
		var p := get_tree().get_first_node_in_group("player")
		if p and p.has_method("refresh_look"):
			p.refresh_look()
		EventBus.toast.emit("Rupamu diperbarui di Cermin Jiwa.")
		get_tree().paused = false
		queue_free()
	else:
		# class + weapon chosen at ClassSelect (FF-2a); intro lore first (FF-2g)
		PlayerData.new_game(PlayerData.pending_class, PlayerData.pending_weapon)
		WorldState.new_game()
		PlayerData.char_config = cfg.duplicate(true)
		Stage.go_to_scene("res://scenes/ui/Intro.tscn")

func _cancel() -> void:
	get_tree().paused = false
	queue_free()
