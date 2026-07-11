extends CanvasLayer
## HUD (R2 Part 3 — enriched) — framed character panel (portrait + themed HP/MP/XP
## bars), a clock/moon/weather widget, a radar minimap, a framed skill hotbar, toasts
## and the Sky Report. Built in code; styled with the unified UiTheme.

var _font: Font
var moon_tex := []

var hp_bar: ProgressBar
var mp_bar: ProgressBar
var exp_bar: ProgressBar
var hp_val: Label
var mp_val: Label
var exp_val: Label
var clock_label: Label
var moon_label: Label
var weather_label: Label
var date_label: Label
var infusion_label: Label
var elements_row: HBoxContainer
var hint_label: Label
var _last_elem_count := -1
var gold_label: Label
var level_label: Label
var toast_box: VBoxContainer
var moon_icon: TextureRect

const WEATHER_ID := {
	"sunny": "Cerah", "rain": "Hujan", "thunderstorm": "Badai Petir",
	"blizzard": "Salju", "blood_moon": "Bulan Darah",
}

func _ready() -> void:
	layer = 10
	add_to_group("hud")
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	for i in range(8):
		var p := "res://assets/game/sky/moon/moon_%d_%s.png" % [i, ["new","waxing_crescent","first_quarter","waxing_gibbous","full","waning_gibbous","last_quarter","waning_crescent"][i]]
		moon_tex.append(load(p) if ResourceLoader.exists(p) else null)
	_build()
	_connect()
	_refresh_all()
	call_deferred("_emit_sky_report")

func _mk_label(text: String, size: int = 16, col := Color(0.94, 0.96, 1.0)) -> Label:
	var l := Label.new()
	l.text = text
	if _font:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	return l

func _frame(bg := Color(0.06, 0.09, 0.22, 0.82), border := Color(1.0, 0.86, 0.42)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(7)
	return sb

func _build() -> void:
	_build_character_panel()
	_build_clock_widget()
	_build_minimap()
	_build_hotbar()
	_build_hint()
	_build_toasts()

# --- Character panel (top-left) --------------------------------------------

func _build_character_panel() -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _frame())
	panel.position = Vector2(10, 8)
	panel.custom_minimum_size = Vector2(244, 0)
	add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	panel.add_child(vb)

	# header: portrait + name/level + gold
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	vb.add_child(head)
	var pf := Panel.new()                 # portrait frame
	pf.custom_minimum_size = Vector2(40, 40)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.02, 0.03, 0.12); psb.border_color = Color(0.55, 0.68, 1.0)
	psb.set_border_width_all(2); psb.set_corner_radius_all(4)
	pf.add_theme_stylebox_override("panel", psb)
	head.add_child(pf)
	var portrait := TextureRect.new()
	var at := AtlasTexture.new()
	at.atlas = load("res://assets/game/sprites/player/idle.png")
	at.region = Rect2(0, 0, 16, 16)
	portrait.texture = at
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 3; portrait.offset_top = 3; portrait.offset_right = -3; portrait.offset_bottom = -3
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pf.add_child(portrait)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 0)
	head.add_child(info)
	level_label = _mk_label("Pahlawan  ·  Lv 1", 15, Color(1.0, 0.86, 0.42))
	info.add_child(level_label)
	var goldrow := HBoxContainer.new()
	goldrow.add_theme_constant_override("separation", 4)
	info.add_child(goldrow)
	var coin := TextureRect.new()
	coin.texture = _coin_tex()
	coin.custom_minimum_size = Vector2(12, 12)
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	goldrow.add_child(coin)
	gold_label = _mk_label("0", 14, Color(1.0, 0.9, 0.5))
	goldrow.add_child(gold_label)

	# themed stat bars
	var hpd := _stat_bar(Color(0.86, 0.24, 0.26))
	hp_bar = hpd.bar; hp_val = hpd.val; vb.add_child(hpd.row)
	var mpd := _stat_bar(Color(0.28, 0.5, 0.95))
	mp_bar = mpd.bar; mp_val = mpd.val; vb.add_child(mpd.row)
	var xpd := _stat_bar(Color(0.95, 0.82, 0.3), 9, "XP")
	exp_bar = xpd.bar; exp_val = xpd.val; vb.add_child(xpd.row)

func _stat_bar(color: Color, h := 15, tag := "") -> Dictionary:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	if tag != "":
		var t := _mk_label(tag, 10, Color(0.8, 0.84, 0.95))
		t.custom_minimum_size = Vector2(18, 0)
		row.add_child(t)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(210 if tag == "" else 190, h)
	bar.show_percentage = false
	bar.max_value = 100; bar.value = 100
	var fill := StyleBoxFlat.new()
	fill.bg_color = color; fill.set_corner_radius_all(3)
	fill.border_color = color.lightened(0.3); fill.border_width_top = 1
	bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.03, 0.04, 0.1, 0.9); bg.set_corner_radius_all(3)
	bg.border_color = Color(0, 0, 0, 0.5); bg.set_border_width_all(1)
	bar.add_theme_stylebox_override("background", bg)
	var val := _mk_label("", 11)
	val.set_anchors_preset(Control.PRESET_FULL_RECT)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(val)
	row.add_child(bar)
	return {"row": row, "bar": bar, "val": val}

# --- Clock / weather widget (top-left, below character) --------------------

func _build_clock_widget() -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _frame())
	panel.position = Vector2(10, 116)
	panel.custom_minimum_size = Vector2(196, 0)
	add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 1)
	panel.add_child(vb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	vb.add_child(row)
	moon_icon = TextureRect.new()
	moon_icon.custom_minimum_size = Vector2(26, 26)
	moon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	moon_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(moon_icon)
	clock_label = _mk_label("00:00", 20, Color(1.0, 0.95, 0.8))
	row.add_child(clock_label)
	moon_label = _mk_label("Bulan", 12, Color(0.78, 0.82, 0.95))
	vb.add_child(moon_label)
	weather_label = _mk_label("Cuaca: Cerah", 13)
	vb.add_child(weather_label)
	date_label = _mk_label("", 11, Color(0.7, 0.74, 0.88))
	vb.add_child(date_label)
	infusion_label = _mk_label("", 13)
	infusion_label.visible = false
	vb.add_child(infusion_label)
	elements_row = HBoxContainer.new()
	elements_row.add_theme_constant_override("separation", 2)
	vb.add_child(elements_row)
	_refresh_elements()

# --- Minimap (top-right) ----------------------------------------------------

func _build_minimap() -> void:
	var mm := Control.new()
	mm.set_script(load("res://scenes/ui/Minimap.gd"))
	mm.anchor_left = 1.0; mm.anchor_right = 1.0
	mm.position = Vector2(-128, 10)
	mm.size = Vector2(118, 118)
	add_child(mm)
	var lbl := _mk_label("Peta", 11, Color(1.0, 0.86, 0.42))
	lbl.anchor_left = 1.0; lbl.anchor_right = 1.0
	lbl.position = Vector2(-128, 130)
	add_child(lbl)
	# gold/level now live in the character panel; keep a level tracker there.

# --- Controls hint ----------------------------------------------------------

func _build_hint() -> void:
	hint_label = _mk_label("WASD gerak · 1-5 prime skill · klik-kiri: cast/serang ke kursor · 2 angka = FUSION · Space dodge · T tame · E interaksi · I tas", 11)
	hint_label.anchor_top = 1.0; hint_label.anchor_bottom = 1.0
	hint_label.anchor_left = 0.0; hint_label.anchor_right = 1.0
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint_label.position = Vector2(-8, -18)
	add_child(hint_label)

func _build_toasts() -> void:
	toast_box = VBoxContainer.new()
	toast_box.anchor_left = 0.5; toast_box.anchor_right = 0.5
	toast_box.anchor_top = 1.0; toast_box.anchor_bottom = 1.0
	toast_box.position = Vector2(-160, -150)
	toast_box.custom_minimum_size = Vector2(320, 0)
	toast_box.alignment = BoxContainer.ALIGNMENT_END
	add_child(toast_box)

func set_hint(text: String) -> void:
	if hint_label:
		hint_label.text = text

# --- Skill hotbar (5 slots, framed) -----------------------------------------

var hotbar_slots: Array = []
var fusion_indicator: Label

func _build_hotbar() -> void:
	var frame := PanelContainer.new()   # ornamental backing behind the slots
	frame.add_theme_stylebox_override("panel", _frame(Color(0.05, 0.07, 0.16, 0.78)))
	frame.anchor_left = 0.5; frame.anchor_right = 0.5
	frame.anchor_top = 1.0; frame.anchor_bottom = 1.0
	frame.position = Vector2(-138, -78)
	add_child(frame)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 5)
	frame.add_child(bar)
	for i in range(5):
		var slot := Panel.new()
		slot.custom_minimum_size = Vector2(44, 44)
		var glow := StyleBoxFlat.new()
		glow.bg_color = Color(0.10, 0.13, 0.28, 0.9)
		glow.set_border_width_all(2); glow.border_color = Color(0.4, 0.5, 0.8)
		glow.set_corner_radius_all(4)
		slot.add_theme_stylebox_override("panel", glow)
		var icon := TextureRect.new()
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 4; icon.offset_top = 4; icon.offset_right = -4; icon.offset_bottom = -4
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		slot.add_child(icon)
		var cd := ColorRect.new()
		cd.color = Color(0, 0, 0, 0.6)
		cd.set_anchors_preset(Control.PRESET_TOP_WIDE)
		cd.size.y = 0
		slot.add_child(cd)
		var num := _mk_label(str(i + 1), 12, Color(1.0, 0.9, 0.6))
		num.position = Vector2(3, -3)
		slot.add_child(num)
		bar.add_child(slot)
		hotbar_slots.append({"root": slot, "style": glow, "icon": icon, "cd": cd})
	fusion_indicator = _mk_label("", 14, Color(1.0, 0.85, 0.3))
	fusion_indicator.anchor_left = 0.5; fusion_indicator.anchor_right = 0.5
	fusion_indicator.anchor_top = 1.0; fusion_indicator.anchor_bottom = 1.0
	fusion_indicator.position = Vector2(-70, -104)
	add_child(fusion_indicator)

func _refresh_hotbar() -> void:
	if hotbar_slots.is_empty():
		return
	var p := get_tree().get_first_node_in_group("player")
	var hb = p.hotbar if (p and "hotbar" in p) else null
	for i in range(hotbar_slots.size()):
		var s: Dictionary = hotbar_slots[i]
		var sid: String = PlayerData.hotbar[i] if i < PlayerData.hotbar.size() else ""
		var elem: String = Db.skill(sid).get("element", "none")
		var path := "res://assets/game/ui/icons/element_%s_32.png" % elem
		if s.icon.texture == null and ResourceLoader.exists(path):
			s.icon.texture = load(path)
		var primed: bool = hb != null and (hb.primed == i or (hb.fusion_ready and (i in hb.fusion_slots)))
		s.style.border_color = Color(1.0, 0.85, 0.3) if primed else Color(0.4, 0.5, 0.8)
		s.style.set_border_width_all(3 if primed else 2)
		var frac: float = hb.cooldown_frac(i) if hb != null else 0.0
		s.cd.size = Vector2(s.root.size.x, s.root.size.y * frac)
	if fusion_indicator:
		fusion_indicator.text = "⚡ FUSION — klik kiri!" if (hb != null and hb.fusion_ready) else ""

# --- Signals / refresh ------------------------------------------------------

func _connect() -> void:
	EventBus.player_hp_changed.connect(func(c, m): _set_bar(hp_bar, hp_val, c, m))
	EventBus.player_mp_changed.connect(func(c, m): _set_bar(mp_bar, mp_val, c, m))
	EventBus.player_exp_changed.connect(func(c, n): _set_bar(exp_bar, exp_val, c, max(1, n)))
	EventBus.player_leveled_up.connect(func(lv): _set_level(lv); Audio.play_sfx("levelup"))
	EventBus.gold_changed.connect(func(g): gold_label.text = str(g))
	EventBus.weather_changed.connect(func(_w): _refresh_sky())
	EventBus.moon_phase_changed.connect(func(_i): _refresh_sky())
	EventBus.minute_passed.connect(func(_d): _refresh_clock())
	EventBus.item_gained.connect(_on_item_gained)
	EventBus.toast.connect(_on_toast)

func _set_bar(bar: ProgressBar, val: Label, cur: float, mx: float) -> void:
	if bar == null:
		return
	bar.max_value = mx; bar.value = cur
	if val:
		val.text = "%d/%d" % [int(cur), int(mx)]

func _set_level(lv: int) -> void:
	if level_label:
		level_label.text = "Pahlawan  ·  Lv %d" % lv

func _refresh_elements() -> void:
	if elements_row == null:
		return
	for c in elements_row.get_children():
		c.queue_free()
	if PlayerData.mastered_elements.is_empty():
		return
	elements_row.add_child(_mk_label("Elemen:", 11, Color(0.7, 0.74, 0.88)))
	for elem in PlayerData.mastered_elements:
		var p := "res://assets/game/ui/icons/element_%s_32.png" % elem
		if ResourceLoader.exists(p):
			var tr := TextureRect.new()
			tr.texture = load(p)
			tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tr.custom_minimum_size = Vector2(16, 16)
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.tooltip_text = elem.capitalize()
			elements_row.add_child(tr)
	_last_elem_count = PlayerData.mastered_elements.size()

func _process(_delta: float) -> void:
	_refresh_hotbar()
	if PlayerData.mastered_elements.size() != _last_elem_count:
		_refresh_elements()
	if infusion_label == null:
		return
	if PlayerData.has_active_infusion():
		var elem: String = PlayerData.infusion.get("element", "")
		var remain: int = PlayerData.infusion.get("expires_unix", 0) - GameClock.unix_now()
		infusion_label.visible = true
		infusion_label.text = "⚡ Infus: %s (%ds)" % [elem.capitalize(), max(0, remain)]
		infusion_label.add_theme_color_override("font_color", Vfx.elem_color(elem))
	else:
		infusion_label.visible = false

func _refresh_all() -> void:
	_refresh_clock()
	_refresh_sky()
	_set_bar(hp_bar, hp_val, PlayerData.hp, PlayerData.max_hp)
	_set_bar(mp_bar, mp_val, PlayerData.mp, PlayerData.max_mp)
	_set_bar(exp_bar, exp_val, PlayerData.exp, max(1, PlayerData.exp_to_next()))
	_set_level(PlayerData.level)
	gold_label.text = str(PlayerData.gold)

func _refresh_clock() -> void:
	clock_label.text = GameClock.time_string()

func _refresh_sky() -> void:
	var mi := GameClock.moon_index()
	if mi < moon_tex.size() and moon_tex[mi]:
		moon_icon.texture = moon_tex[mi]
	moon_label.text = GameClock.moon_name()
	weather_label.text = "Cuaca: " + WEATHER_ID.get(WorldState.weather, WorldState.weather)
	if date_label:
		date_label.text = GameClock.date_string()

# --- Toasts (icon-aware) ----------------------------------------------------

func _on_item_gained(item_id: String, qty: int) -> void:
	var icon := Db.item_icon(item_id)
	_toast_icon(icon, "+%d %s" % [qty, Db.item_name(item_id)])

func _on_toast(msg: String) -> void:
	_toast_icon("", msg)

func _toast_icon(icon_path: String, msg: String) -> void:
	if toast_box == null or not is_instance_valid(toast_box):
		return
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", _frame(Color(0.06, 0.09, 0.22, 0.9), Color(0.55, 0.68, 1.0)))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	pc.add_child(row)
	if icon_path != "":
		var tr := TextureRect.new()
		tr.texture = load(icon_path)
		tr.custom_minimum_size = Vector2(20, 20)
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		row.add_child(tr)
	row.add_child(_mk_label(msg, 14))
	toast_box.add_child(pc)
	var tw := create_tween()
	tw.tween_interval(2.4)
	tw.tween_property(pc, "modulate:a", 0.0, 0.6)
	tw.tween_callback(pc.queue_free)
	while toast_box.get_child_count() > 5:
		var oldest := toast_box.get_child(0)
		toast_box.remove_child(oldest)
		oldest.queue_free()

func _emit_sky_report() -> void:
	var report := {
		"date": GameClock.date_string(), "time": GameClock.time_string(),
		"moon": GameClock.moon_name(), "weather": WorldState.weather,
		"event": GameClock.sky_event_today(),
	}
	EventBus.sky_report_ready.emit(report)
	var ev: String = report.event
	var line := "Sky Report — %s %s · %s · %s" % [report.date, report.time, report.moon, weather_label.text]
	if ev != "":
		line += " · ✦ " + ev
	EventBus.toast.emit(line)

func _coin_tex() -> Texture2D:
	var img := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	for y in range(10):
		for x in range(10):
			var d: float = Vector2(x - 4.5, y - 4.5).length()
			if d <= 4.5:
				img.set_pixel(x, y, Color(1.0, 0.84, 0.3) if d < 3.2 else Color(0.8, 0.6, 0.15))
	img.set_pixel(3, 3, Color(1, 0.95, 0.7))
	return ImageTexture.create_from_image(img)
