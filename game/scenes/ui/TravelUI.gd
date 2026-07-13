class_name TravelUI
extends CanvasLayer
## "PILIH DUNIA" — Gerbang Penjelajah (Decision Log #43, tarikan maju fast-travel).
## Kartu wilayah yang PERNAH dikunjungi (nama + level range + cuaca live); klik =
## fade travel ke wilayah itu. Belum dikunjungi = siluet terkunci "belum dijelajahi"
## (kunjungan pertama tetap jalan kaki/berlayar). Biaya kecil gold; travel pertama
## tiap hari GRATIS (sink ringan).

const TRAVEL_COST := 25

const REGIONS := [
	{"id": "greenvale", "name": "Greenvale", "lv": "Lv 1–15", "scene": "res://scenes/Main.tscn",
		"color": "#2e6b3f", "icon": "wood", "flavor": "Desa perbatasan, rumah pertama semua petualang."},
	{"id": "candyveil", "name": "Candyveil Meadows", "lv": "Lv 18–32", "scene": "res://scenes/world/Candyveil.tscn",
		"color": "#d95fa4", "icon": "light", "flavor": "Padang gula kapas & istana Sugar Queen."},
	{"id": "desert", "name": "Desert of Ruins", "lv": "Lv 12–25", "scene": "res://scenes/world/Desert.tscn",
		"color": "#b8860b", "icon": "earth", "flavor": "Reruntuhan kuno di lautan pasir."},
	{"id": "frostpeak", "name": "Frostpeak Mountain", "lv": "Lv 22–38", "scene": "res://scenes/world/Frostpeak.tscn",
		"color": "#6fb4d9", "icon": "ice", "flavor": "Puncak beku & pos para pendaki."},
	{"id": "storm_island", "name": "Storm Island", "lv": "Lv 40–55", "scene": "res://scenes/world/StormIsland.tscn",
		"color": "#8a7fd6", "icon": "lightning", "flavor": "Pulau badai abadi & menara Zephyr."},
]

var _font: Font
var root: Control

static func region_def(id: String) -> Dictionary:
	for r in REGIONS:
		if r.id == id:
			return r
	return {}

## Biaya travel hari ini (0 = jatah gratis harian masih ada). #43
static func travel_cost_today() -> int:
	return 0 if WorldState.last_free_travel != GameClock.date_string() else TRAVEL_COST

static func open_over(tree: SceneTree) -> void:
	if tree.get_first_node_in_group("travel_ui") != null:
		return
	var ui = load("res://scenes/ui/TravelUI.gd").new()
	tree.current_scene.add_child(ui)

func _ready() -> void:
	layer = 24
	add_to_group("travel_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	get_tree().paused = true
	_build()

func _build() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = UiTheme.theme
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.08, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5; panel.anchor_right = 0.5
	panel.anchor_top = 0.5; panel.anchor_bottom = 0.5
	panel.custom_minimum_size = Vector2(640, 0)
	panel.position = Vector2(-320, -230)
	root.add_child(panel)
	UiFx.panel_in(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	panel.add_child(vb)
	vb.add_child(_lbl("🌍 PILIH DUNIA — Gerbang Penjelajah", 24, Color(1.0, 0.86, 0.42)))
	var cost := travel_cost_today()
	vb.add_child(_lbl("Melangkah lewat gerbang: %s. Kunjungan PERTAMA ke wilayah baru tetap lewat kakimu sendiri." % ("GRATIS (jatah harian)" if cost == 0 else "%d G" % cost), 12, Color(0.75, 0.8, 0.95)))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	vb.add_child(grid)
	for r in REGIONS:
		grid.add_child(_region_card(r))
	var close := Button.new()
	close.text = "Tutup (Esc)"
	if _font: close.add_theme_font_override("font", _font)
	close.pressed.connect(_close)
	UiFx.button(close)
	vb.add_child(close)

func _region_card(r: Dictionary) -> Control:
	var visited: bool = r.id in WorldState.visited_regions
	var here: bool = r.id == WorldState.current_region
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(305, 86)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.11, 0.22, 0.95) if visited else Color(0.05, 0.06, 0.10, 0.95)
	sb.border_color = Color(r.get("color", "#888888")) if visited else Color(0.25, 0.27, 0.35)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(8)
	card.add_theme_stylebox_override("panel", sb)
	var vb := VBoxContainer.new()
	card.add_child(vb)
	if not visited:
		# siluet terkunci — insentif eksplorasi (#43)
		vb.add_child(_lbl("🔒 ? ? ?", 18, Color(0.45, 0.47, 0.55)))
		vb.add_child(_lbl("Belum dijelajahi — dunia menunggumu datang dengan kakimu sendiri.", 11, Color(0.5, 0.52, 0.6)))
		return card
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	vb.add_child(head)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(24, 24)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var ip := "res://assets/game/ui/icons/element_%s_32.png" % r.get("icon", "wood")
	if ResourceLoader.exists(ip):
		icon.texture = load(ip)
	head.add_child(icon)
	head.add_child(_lbl(r.name, 17, Color(r.get("color", "#ffffff")).lightened(0.4)))
	vb.add_child(_lbl("%s · Cuaca: %s" % [r.lv, WorldState._weather_label(WorldState.weather)], 11, Color(0.75, 0.8, 0.95)))
	if here:
		vb.add_child(_lbl("📍 Kamu sedang di sini.", 11, Color(1.0, 0.86, 0.42)))
	else:
		var go := Button.new()
		var cost := travel_cost_today()
		go.text = "Berangkat!" + (" (gratis)" if cost == 0 else " (%d G)" % cost)
		if _font: go.add_theme_font_override("font", _font)
		go.pressed.connect(func(): _travel(r))
		UiFx.button(go)
		vb.add_child(go)
	return card

## SATU-SATUNYA jalur fast travel (Decision Log #93). Gerbang di dunia DAN Peta
## sama-sama memanggil ini: syarat, biaya, dan jatah gratis harian identik.
## Returns true bila perjalanan benar-benar berangkat.
static func do_travel(r: Dictionary, ui: CanvasLayer = null) -> bool:
	if not r.get("id", "") in WorldState.visited_regions:
		EventBus.toast.emit(Loc.t("travel.locked"))
		return false
	if r.get("id", "") == WorldState.current_region:
		EventBus.toast.emit(Loc.t("travel.here"))
		return false
	var cost := travel_cost_today()
	if cost > 0 and PlayerData.gold < cost:
		EventBus.toast.emit(Loc.t("travel.no_gold", [cost - PlayerData.gold]))
		Audio.play_sfx("menu", 0.6)
		return false
	if cost > 0:
		PlayerData.add_gold(-cost)
	else:
		WorldState.last_free_travel = GameClock.date_string()
	Audio.play_sfx("success")
	EventBus.toast.emit(Loc.t("travel.depart", [r.get("name", "")]))
	if ui and ui.is_inside_tree():
		ui.get_tree().paused = false
	Stage.go_to_scene(r.get("scene", ""))
	return true

func _travel(r: Dictionary) -> void:
	if do_travel(r, self):
		UiFx.celebrate(root, "✨")
		queue_free()

func _lbl(t: String, s: int, col := Color(0.94, 0.96, 1.0)) -> Label:
	var l := Label.new()
	l.text = t
	if _font: l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", s)
	l.add_theme_color_override("font_color", col)
	return l

func _close() -> void:
	get_tree().paused = false
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		_close()
		get_viewport().set_input_as_handled()
