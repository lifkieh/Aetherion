extends CanvasLayer
## HUD — clock/moon/weather, HP/MP/EXP bars, gold, toasts, Sky Report.
## Built in code for robustness; styled with the pixel font when available.

var _font: Font
var moon_tex := []

var hp_bar: ProgressBar
var mp_bar: ProgressBar
var exp_bar: ProgressBar
var clock_label: Label
var moon_label: Label
var weather_label: Label
var infusion_label: Label
var elements_row: HBoxContainer
var hint_label: Label
var _last_elem_count := -1
var gold_label: Label
var level_label: Label
var toast_box: VBoxContainer
var moon_icon: TextureRect

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

func _mk_label(text: String, size: int = 16) -> Label:
	var l := Label.new()
	l.text = text
	if _font:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 4)
	return l

func _build() -> void:
	# --- Top-left: time / moon / weather ---
	var topleft := VBoxContainer.new()
	topleft.position = Vector2(12, 8)
	add_child(topleft)
	var row := HBoxContainer.new()
	topleft.add_child(row)
	moon_icon = TextureRect.new()
	moon_icon.custom_minimum_size = Vector2(28, 28)
	moon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	moon_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(moon_icon)
	clock_label = _mk_label("00:00", 18)
	row.add_child(clock_label)
	moon_label = _mk_label("Bulan", 14)
	topleft.add_child(moon_label)
	weather_label = _mk_label("Cerah", 14)
	topleft.add_child(weather_label)
	infusion_label = _mk_label("", 14)
	infusion_label.visible = false
	topleft.add_child(infusion_label)
	elements_row = HBoxContainer.new()
	elements_row.add_theme_constant_override("separation", 2)
	topleft.add_child(elements_row)
	_refresh_elements()

	# --- Top-right: gold / level ---
	var topright := VBoxContainer.new()
	topright.anchor_left = 1.0
	topright.anchor_right = 1.0
	topright.position = Vector2(-160, 8)
	topright.custom_minimum_size = Vector2(150, 0)
	add_child(topright)
	level_label = _mk_label("Lv 1", 16)
	topright.add_child(level_label)
	gold_label = _mk_label("Gold: 0", 14)
	topright.add_child(gold_label)

	# --- Bottom-left: bars ---
	var bars := VBoxContainer.new()
	bars.anchor_top = 1.0
	bars.anchor_bottom = 1.0
	bars.position = Vector2(12, -78)
	bars.custom_minimum_size = Vector2(220, 0)
	add_child(bars)
	hp_bar = _mk_bar(Color(0.85, 0.25, 0.25))
	bars.add_child(hp_bar)
	mp_bar = _mk_bar(Color(0.25, 0.45, 0.9))
	bars.add_child(mp_bar)
	exp_bar = _mk_bar(Color(0.9, 0.8, 0.3))
	exp_bar.custom_minimum_size = Vector2(220, 8)
	bars.add_child(exp_bar)

	# --- Controls hint (bottom-right) ---
	hint_label = _mk_label("WASD gerak · 1-5 prime skill · klik-kiri: cast/serang ke kursor · 2 angka = FUSION · Space dodge · T tame · E interaksi · I tas", 11)
	hint_label.anchor_top = 1.0
	hint_label.anchor_bottom = 1.0
	hint_label.anchor_left = 0.0
	hint_label.anchor_right = 1.0
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint_label.position = Vector2(-8, -18)
	add_child(hint_label)

	_build_hotbar()

	# --- Toasts (center-bottom) ---
	toast_box = VBoxContainer.new()
	toast_box.anchor_left = 0.5
	toast_box.anchor_right = 0.5
	toast_box.anchor_top = 1.0
	toast_box.anchor_bottom = 1.0
	toast_box.position = Vector2(-140, -140)
	toast_box.custom_minimum_size = Vector2(280, 0)
	toast_box.alignment = BoxContainer.ALIGNMENT_END
	add_child(toast_box)

func set_hint(text: String) -> void:
	if hint_label:
		hint_label.text = text

# --- Skill hotbar (5 slots) -------------------------------------------------

var hotbar_slots: Array = []          # [{root, icon, num, cd, glow}]
var fusion_indicator: Label

func _build_hotbar() -> void:
	var bar := Control.new()
	bar.anchor_left = 0.5; bar.anchor_right = 0.5
	bar.anchor_top = 1.0; bar.anchor_bottom = 1.0
	add_child(bar)
	for i in range(5):
		var slot := Panel.new()
		slot.size = Vector2(44, 44)
		slot.position = Vector2(-120 + i * 48, -92)
		var glow := StyleBoxFlat.new()
		glow.bg_color = Color(0.10, 0.13, 0.28, 0.85)
		glow.set_border_width_all(2)
		glow.border_color = Color(0.4, 0.5, 0.8)
		glow.set_corner_radius_all(4)
		slot.add_theme_stylebox_override("panel", glow)
		var icon := TextureRect.new()
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		slot.add_child(icon)
		var cd := ColorRect.new()      # cooldown shade (top-down fill)
		cd.color = Color(0, 0, 0, 0.6)
		cd.set_anchors_preset(Control.PRESET_TOP_WIDE)
		cd.size.y = 0
		slot.add_child(cd)
		var num := _mk_label(str(i + 1), 11)
		num.position = Vector2(2, -2)
		slot.add_child(num)
		bar.add_child(slot)
		hotbar_slots.append({"root": slot, "style": glow, "icon": icon, "cd": cd})
	fusion_indicator = _mk_label("", 14)
	fusion_indicator.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	fusion_indicator.anchor_left = 0.5; fusion_indicator.anchor_right = 0.5
	fusion_indicator.anchor_top = 1.0; fusion_indicator.anchor_bottom = 1.0
	fusion_indicator.position = Vector2(-60, -70)
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
		# prime highlight + cooldown
		var primed: bool = hb != null and (hb.primed == i or (hb.fusion_ready and (hb.fusion_a == i or hb.fusion_b == i)))
		s.style.border_color = Color(1.0, 0.85, 0.3) if primed else Color(0.4, 0.5, 0.8)
		s.style.set_border_width_all(3 if primed else 2)
		var frac: float = hb.cooldown_frac(i) if hb != null else 0.0
		s.cd.size = Vector2(s.root.size.x, s.root.size.y * frac)
	if fusion_indicator:
		fusion_indicator.text = "⚡ FUSION — klik kiri!" if (hb != null and hb.fusion_ready) else ""

func _mk_bar(color: Color) -> ProgressBar:
	var b := ProgressBar.new()
	b.custom_minimum_size = Vector2(220, 16)
	b.show_percentage = false
	b.max_value = 100
	b.value = 100
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 2
	b.add_theme_stylebox_override("fill", sb)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.55)
	b.add_theme_stylebox_override("background", bg)
	return b

func _connect() -> void:
	EventBus.player_hp_changed.connect(func(c, m): hp_bar.max_value = m; hp_bar.value = c)
	EventBus.player_mp_changed.connect(func(c, m): mp_bar.max_value = m; mp_bar.value = c)
	EventBus.player_exp_changed.connect(func(c, n): exp_bar.max_value = max(1, n); exp_bar.value = c)
	EventBus.player_leveled_up.connect(func(lv): level_label.text = "Lv %d" % lv; Audio.play_sfx("levelup"))
	EventBus.gold_changed.connect(func(g): gold_label.text = "Gold: %d" % g)
	EventBus.weather_changed.connect(func(_w): _refresh_sky())
	EventBus.moon_phase_changed.connect(func(_i): _refresh_sky())
	EventBus.minute_passed.connect(func(_d): _refresh_clock())
	EventBus.toast.connect(_on_toast)

func _refresh_elements() -> void:
	if elements_row == null:
		return
	for c in elements_row.get_children():
		c.queue_free()
	var lbl := _mk_label("Elemen:", 12)
	elements_row.add_child(lbl)
	for elem in PlayerData.mastered_elements:
		var p := "res://assets/game/ui/icons/element_%s_32.png" % elem
		if ResourceLoader.exists(p):
			var tr := TextureRect.new()
			tr.texture = load(p)
			tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tr.custom_minimum_size = Vector2(18, 18)
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
	hp_bar.max_value = PlayerData.max_hp
	hp_bar.value = PlayerData.hp
	mp_bar.max_value = PlayerData.max_mp
	mp_bar.value = PlayerData.mp
	exp_bar.max_value = max(1, PlayerData.exp_to_next())
	exp_bar.value = PlayerData.exp
	level_label.text = "Lv %d" % PlayerData.level
	gold_label.text = "Gold: %d" % PlayerData.gold

func _refresh_clock() -> void:
	clock_label.text = GameClock.time_string()

func _refresh_sky() -> void:
	var mi := GameClock.moon_index()
	if mi < moon_tex.size() and moon_tex[mi]:
		moon_icon.texture = moon_tex[mi]
	moon_label.text = GameClock.moon_name()
	weather_label.text = "Cuaca: " + {
		"sunny": "Cerah", "rain": "Hujan", "thunderstorm": "Badai Petir",
		"blizzard": "Salju", "blood_moon": "Bulan Darah"
	}.get(WorldState.weather, WorldState.weather)

func _on_toast(msg: String) -> void:
	if toast_box == null or not is_instance_valid(toast_box):
		return
	var l := _mk_label(msg, 14)
	l.modulate = Color(1, 1, 1)
	toast_box.add_child(l)
	var tw := create_tween()
	tw.tween_interval(2.2)
	tw.tween_property(l, "modulate:a", 0.0, 0.6)
	tw.tween_callback(l.queue_free)
	# cap toasts (queue_free so the running tween on the node is cleaned up safely)
	while toast_box.get_child_count() > 5:
		var oldest := toast_box.get_child(0)
		toast_box.remove_child(oldest)
		oldest.queue_free()

func _emit_sky_report() -> void:
	var report := {
		"date": GameClock.date_string(),
		"time": GameClock.time_string(),
		"moon": GameClock.moon_name(),
		"weather": WorldState.weather,
		"event": GameClock.sky_event_today(),
	}
	EventBus.sky_report_ready.emit(report)
	var ev: String = report.event
	var line := "Sky Report — %s %s · %s · %s" % [report.date, report.time, report.moon, weather_label.text]
	if ev != "":
		line += " · ✦ " + ev
	EventBus.toast.emit(line)
