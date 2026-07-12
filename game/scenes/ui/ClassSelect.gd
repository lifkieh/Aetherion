extends Control
## Class Selection (FF-2a) — first step of New Game. Pick 1 of 6 combat classes
## (GDD v0.1 §3.3), then a starting weapon variant, then continue to the
## Character Creator. The class = profesi combat utama (max 1 combat, GDD §3.2).

var _font: Font
var _selected := ""
var _weapon := ""
var _cards: Dictionary = {}        # class_id -> PanelContainer
var _detail: VBoxContainer
var _start_btn: Button

func _ready() -> void:
	theme = UiTheme.theme
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	_build()
	# default selection so the flow is never stuck
	if not Db.class_order.is_empty():
		_select(Db.class_order[0])
	if OS.get_environment("AETHER_SHOT") == "1":
		get_tree().create_timer(1.0).timeout.connect(func():
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit())

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
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.06, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := _lbl("Pilih Jalanmu", 34, Color(1.0, 0.86, 0.42))
	title.position = Vector2(40, 18)
	add_child(title)
	var sub := _lbl("Class adalah profesi combat utamamu — identitasmu sejak langkah pertama. (Profesi hidup lain bisa diambil di dalam game.)", 13, Color(0.75, 0.8, 0.95))
	sub.position = Vector2(42, 58)
	add_child(sub)

	# 6 class cards (2 kolom kiri) + detail panel (kanan)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.position = Vector2(40, 88)
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	add_child(grid)
	for cid in Db.class_order:
		grid.add_child(_class_card(cid))

	var dp := PanelContainer.new()
	dp.position = Vector2(560, 88)
	dp.custom_minimum_size = Vector2(560, 500)
	add_child(dp)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 6)
	dp.add_child(_detail)

	var back := Button.new()
	back.text = "← Kembali"
	if _font: back.add_theme_font_override("font", _font)
	back.position = Vector2(40, 620)
	back.pressed.connect(func(): Stage.go_to_scene("res://scenes/ui/MainMenu.tscn"))
	add_child(back)

func _class_card(cid: String) -> PanelContainer:
	var c := Db.cls(cid)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(245, 78)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.11, 0.22, 0.95)
	sb.border_color = Color(c.get("color", "#888888"))
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(8)
	card.add_theme_stylebox_override("panel", sb)
	var vb := VBoxContainer.new()
	card.add_child(vb)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	vb.add_child(head)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(26, 26)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var ip := "res://assets/game/ui/icons/element_%s_32.png" % c.get("icon_elem", "fire")
	if ResourceLoader.exists(ip):
		icon.texture = load(ip)
	head.add_child(icon)
	var nm := _lbl(c.get("name", cid), 19, Color(c.get("color", "#ffffff")).lightened(0.35))
	head.add_child(nm)
	vb.add_child(_lbl(c.get("title", ""), 12, Color(0.75, 0.8, 0.95)))
	card.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			Audio.play_sfx("menu")
			_select(cid))
	_cards[cid] = card
	return card

func _select(cid: String) -> void:
	_selected = cid
	var c := Db.cls(cid)
	_weapon = c.get("weapons", [{}])[0].get("id", "")
	for k in _cards:
		var sb: StyleBoxFlat = _cards[k].get_theme_stylebox("panel")
		sb.set_border_width_all(4 if k == cid else 2)
		sb.bg_color = Color(0.14, 0.17, 0.30, 0.98) if k == cid else Color(0.09, 0.11, 0.22, 0.95)
	_refresh_detail()

func _refresh_detail() -> void:
	for ch in _detail.get_children():
		ch.queue_free()
	var c := Db.cls(_selected)
	if c.is_empty():
		return
	_detail.add_child(_lbl("%s — %s" % [c.get("name", ""), c.get("title", "")], 24, Color(c.get("color", "#ffffff")).lightened(0.35)))
	var desc := _lbl(c.get("desc", ""), 14)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(520, 0)
	_detail.add_child(desc)
	# attribute bonuses
	var attrs := []
	for k in c.get("attr", {}):
		attrs.append("%s +%d" % [k, int(c.attr[k])])
	_detail.add_child(_lbl("Bonus stat awal: " + ", ".join(attrs), 14, Color(0.6, 0.9, 0.6)))
	# starting skills
	_detail.add_child(_lbl("— 3 Skill Awal —", 15, Color(1.0, 0.86, 0.42)))
	for sid in c.get("skills", []):
		var sk := Db.skill(sid)
		var row := _lbl("• %s — %s" % [sk.get("name", sid), sk.get("desc", "")], 12)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.custom_minimum_size = Vector2(520, 0)
		_detail.add_child(row)
	# weapon variant choice
	_detail.add_child(_lbl("— Senjata Awal (pilih satu) —", 15, Color(1.0, 0.86, 0.42)))
	var wrow := HBoxContainer.new()
	wrow.add_theme_constant_override("separation", 8)
	_detail.add_child(wrow)
	for wv in c.get("weapons", []):
		var b := Button.new()
		var wid: String = wv.get("id", "")
		b.text = "%s\n%s" % [wv.get("label", wid), wv.get("hint", "")]
		if _font: b.add_theme_font_override("font", _font)
		b.toggle_mode = true
		b.button_pressed = (wid == _weapon)
		b.custom_minimum_size = Vector2(250, 52)
		b.pressed.connect(func():
			Audio.play_sfx("menu")
			_weapon = wid
			_refresh_detail())
		wrow.add_child(b)
	# weapon affinity + advanced class teaser
	_detail.add_child(_lbl("Afinitas senjata: %s (+8%% damage, +5%% kecepatan)" % ", ".join(c.get("affinity", [])), 12, Color(0.75, 0.8, 0.95)))
	var adv := _lbl("★ %s" % c.get("advanced", ""), 12, Color(0.8, 0.7, 1.0))
	adv.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	adv.custom_minimum_size = Vector2(520, 0)
	_detail.add_child(adv)
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 8)
	_detail.add_child(sp)
	_start_btn = Button.new()
	_start_btn.text = "Lanjut: Bentuk Rupamu ▶"
	if _font: _start_btn.add_theme_font_override("font", _font)
	_start_btn.custom_minimum_size = Vector2(300, 40)
	_start_btn.pressed.connect(_confirm)
	_detail.add_child(_start_btn)

func _confirm() -> void:
	if _selected == "":
		return
	PlayerData.pending_class = _selected
	PlayerData.pending_weapon = _weapon
	Audio.play_sfx("success")
	Stage.go_to_scene("res://scenes/ui/CharacterCreator.tscn")
