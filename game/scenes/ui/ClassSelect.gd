extends Control
## Class Selection — first step of New Game. DUA JALUR (Decision Log #33):
## • JALUR TEMPUR: 6 class combat (GDD v0.1 §3.3) — 3 skill, 2 varian senjata.
## • JALUR KEHIDUPAN: 4 class konsolidasi (Perajin/Petani/Peramu/Penjinak) —
##   +50% EXP domain, starting kit, perk khas, dan memilih 1 COMBAT SUB
##   (1 senjata + 2 skill; aturan sub berlaku).

var _font: Font
var _path := "combat"              # tab aktif: combat | life
var _selected := ""
var _weapon := ""
var _sub := "warrior"              # combat sub untuk jalur kehidupan
var _cards: Dictionary = {}        # class_id -> PanelContainer
var _detail: VBoxContainer
var _start_btn: Button
var _grid: GridContainer
var _tab_btns: Dictionary = {}

func _ready() -> void:
	theme = UiTheme.theme
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	_build()
	_select_path("combat")
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
	title.position = Vector2(40, 14)
	add_child(title)
	var subt := _lbl("Dua jalur hidup di Aetherion: bertarung, atau berkarya. Keduanya sah, keduanya legenda.", 13, Color(0.75, 0.8, 0.95))
	subt.position = Vector2(42, 52)
	add_child(subt)

	# dua TAB JALUR (Decision Log #33)
	var tabs := HBoxContainer.new()
	tabs.position = Vector2(40, 74)
	tabs.add_theme_constant_override("separation", 8)
	add_child(tabs)
	for pd in [["combat", "⚔ JALUR TEMPUR"], ["life", "🌾 JALUR KEHIDUPAN"]]:
		var tb := Button.new()
		tb.text = pd[1]
		if _font: tb.add_theme_font_override("font", _font)
		tb.toggle_mode = true
		tb.custom_minimum_size = Vector2(220, 34)
		var pid: String = pd[0]
		tb.pressed.connect(func(): Audio.play_sfx("menu"); _select_path(pid))
		tabs.add_child(tb)
		_tab_btns[pid] = tb

	# kartu class (2 kolom kiri) + detail panel (kanan)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.position = Vector2(40, 118)
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	add_child(_grid)

	var dp := PanelContainer.new()
	dp.position = Vector2(560, 118)
	dp.custom_minimum_size = Vector2(560, 480)
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

func _select_path(p: String) -> void:
	_path = p
	for k in _tab_btns:
		_tab_btns[k].button_pressed = (k == p)
	for ch in _grid.get_children():
		ch.queue_free()
	_cards.clear()
	var ids := Db.class_order.filter(func(cid): return Db.cls(cid).get("path", "combat") == p)
	for cid in ids:
		_grid.add_child(_class_card(cid))
	if not ids.is_empty():
		_select(ids[0])

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
	if c.get("path", "combat") == "life":
		_weapon = Db.cls(_sub).get("weapons", [{}])[0].get("id", "")
	else:
		_weapon = c.get("weapons", [{}])[0].get("id", "")
	for k in _cards:
		var sb: StyleBoxFlat = _cards[k].get_theme_stylebox("panel")
		sb.set_border_width_all(4 if k == cid else 2)
		sb.bg_color = Color(0.14, 0.17, 0.30, 0.98) if k == cid else Color(0.09, 0.11, 0.22, 0.95)
	if _cards.has(cid):
		UiFx.select_bounce(_cards[cid])   # kartu bouncing saat dipilih (#44)
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
	if c.get("path", "combat") == "life":
		_refresh_life_detail(c)
		return
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
	_add_start_button()

## Tombol Lanjut untuk KEDUA jalur (BUG P0 #41: dulu hanya di builder tempur —
## jalur kehidupan buntu). Sekarang satu helper dipanggil kedua panel.
func _add_start_button() -> void:
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 8)
	_detail.add_child(sp)
	_start_btn = Button.new()
	_start_btn.text = "Lanjut: Bentuk Rupamu ▶"
	if _font: _start_btn.add_theme_font_override("font", _font)
	_start_btn.custom_minimum_size = Vector2(300, 40)
	_start_btn.pressed.connect(_confirm)
	UiFx.button(_start_btn)
	_detail.add_child(_start_btn)
	UiFx.breathe(_start_btn)   # tombol terpenting bernafas (#44)

## Detail JALUR KEHIDUPAN (Decision Log #33): perk + kit + pohon domain + combat sub.
func _refresh_life_detail(c: Dictionary) -> void:
	_detail.add_child(_lbl("— Perk Jalur —", 15, Color(1.0, 0.86, 0.42)))
	var pk := _lbl("★ " + c.get("perk", ""), 12, Color(0.6, 0.9, 0.6))
	pk.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pk.custom_minimum_size = Vector2(520, 0)
	_detail.add_child(pk)
	# starting kit
	var kit_parts := []
	for kid in c.get("kit", {}):
		kit_parts.append("%s x%d" % [Db.item_name(kid), int(c.kit[kid])])
	_detail.add_child(_lbl("Kit awal: " + ", ".join(kit_parts), 12, Color(0.75, 0.8, 0.95)))
	# domain trees teaser
	var dt: Array = c.get("tree_domain", []).map(func(tid): return Db.skill_trees.get(tid, {}).get("name", tid))
	_detail.add_child(_lbl("Pohon domain (diskon+gratis): %s" % ", ".join(dt), 11, Color(0.75, 0.8, 0.95)))
	# combat SUB: 1 senjata + 2 skill (aturan sub)
	_detail.add_child(_lbl("— Combat Sub (pilih 1: 1 senjata + 2 skill) —", 15, Color(1.0, 0.86, 0.42)))
	var srow := GridContainer.new()
	srow.columns = 3
	srow.add_theme_constant_override("h_separation", 6)
	srow.add_theme_constant_override("v_separation", 6)
	_detail.add_child(srow)
	for cid in Db.class_order:
		var cc := Db.cls(cid)
		if cc.get("path", "combat") != "combat":
			continue
		var b := Button.new()
		b.text = cc.get("name", cid)
		if _font: b.add_theme_font_override("font", _font)
		b.toggle_mode = true
		b.button_pressed = (cid == _sub)
		b.custom_minimum_size = Vector2(160, 30)
		var pick: String = cid
		b.pressed.connect(func():
			Audio.play_sfx("menu")
			_sub = pick
			_weapon = Db.cls(pick).get("weapons", [{}])[0].get("id", "")
			_refresh_detail())
		srow.add_child(b)
	var sd := Db.cls(_sub)
	var two: Array = sd.get("skills", []).slice(0, 2).map(func(sid): return Db.skill(sid).get("name", sid))
	_detail.add_child(_lbl("Sub %s: senjata %s · skill: %s" % [sd.get("name", "-"),
		Db.item_name(_weapon), ", ".join(two)], 12, Color(0.72, 0.76, 0.9)))
	_add_start_button()   # BUG P0 #41: jalur kehidupan juga harus bisa LANJUT

func _confirm() -> void:
	if _selected == "":
		return
	PlayerData.pending_class = _selected
	PlayerData.pending_weapon = _weapon
	PlayerData.pending_sub = _sub if Db.cls(_selected).get("path", "combat") == "life" else ""
	Audio.play_sfx("success")
	Stage.go_to_scene("res://scenes/ui/CharacterCreator.tscn")
