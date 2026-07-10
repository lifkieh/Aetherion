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
var gold_label: Label
var level_label: Label
var toast_box: VBoxContainer
var moon_icon: TextureRect

func _ready() -> void:
	layer = 10
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
	var hint := _mk_label("WASD gerak · J serang · K/L skill · 1/2 infus · Space dodge · T tame · E interaksi · I tas · F5 simpan", 11)
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	hint.anchor_left = 0.0
	hint.anchor_right = 1.0
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.position = Vector2(-8, -18)
	add_child(hint)

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
	var l := _mk_label(msg, 14)
	l.modulate = Color(1, 1, 1)
	toast_box.add_child(l)
	var tw := create_tween()
	tw.tween_interval(2.2)
	tw.tween_property(l, "modulate:a", 0.0, 0.6)
	tw.tween_callback(l.queue_free)
	# cap toasts
	while toast_box.get_child_count() > 5:
		toast_box.get_child(0).free()

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
