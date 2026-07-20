extends CanvasLayer
## PETA (v0.4.3 #1, Decision Log #93) — dua tingkat:
##   [PETA WILAYAH] posisi pemain live + marker dari NODE YANG BENAR-BENAR ADA di
##     scene (kota/gerbang/pintu dungeon/Penjaga Pohon/peti/warga) + sasaran quest
##     yang sedang dilacak dari Jurnal. Digambar dari data posisi — tanpa aset peta.
##   [PETA DUNIA] kartu semua wilayah; belum dikunjungi = siluet.
##
## FAST TRAVEL: TIDAK membangun sistem kedua. Ia memanggil TravelUI.do_travel() —
## sistem Gerbang Penjelajah yang sama (syarat pernah dikunjungi, gratis sekali
## sehari lalu 25G). Satu sistem, dua pintu masuk (gerbang di dunia & peta ini).

const PAPER := Color(0.86, 0.79, 0.62)      # parchment
const INK := Color(0.24, 0.18, 0.12)

var _font: Font
var root: Control
var _canvas: Control
var _tab := "region"                        # region | world
var _player: Node2D

static func open_over(tree: SceneTree) -> void:
	if tree.get_first_node_in_group("world_map_ui") != null:
		return
	var ui = load("res://scenes/ui/WorldMapUI.gd").new()
	tree.current_scene.add_child(ui)

func _ready() -> void:
	layer = 25
	add_to_group("world_map_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	_player = get_tree().get_first_node_in_group("player") as Node2D
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
	panel.custom_minimum_size = Vector2(660, 0)
	panel.position = Vector2(-330, -250)
	root.add_child(panel)
	UiFx.panel_in(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	vb.add_child(head)
	head.add_child(_lbl("🗺 PETA", 22, Color(1.0, 0.86, 0.42)))
	head.add_child(_btn("Wilayah Ini", func(): _tab = "region"; _refresh()))
	head.add_child(_btn("Peta Dunia", func(): _tab = "world"; _refresh()))
	head.add_child(_btn("Tutup (M/Esc)", _close))

	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(640, 400)
	vb.add_child(_canvas)
	_refresh()

func _refresh() -> void:
	for c in _canvas.get_children():
		c.queue_free()
	if _tab == "region":
		_build_region_map()
	else:
		_build_world_map()

# --- Peta wilayah -----------------------------------------------------------

## Marker: dibaca dari node hidup di scene — peta tak pernah berbohong tentang
## dunia, karena ia membaca dunia itu sendiri.
func _collect_markers() -> Array:
	var out: Array = []
	for n in get_tree().get_nodes_in_group("interactable"):
		if not n is Node2D:
			continue
		var kind := str(n.get("kind")) if "kind" in n else ""
		var icon := ""
		var name := ""
		match kind:
			"dungeon": icon = "▼"; name = "Pintu Dungeon"
			"world_gate": icon = "🌍"; name = "Gerbang Penjelajah"
			"tree_keeper": icon = "🌳"; name = "Penjaga Pohon"
			"shop": icon = "$"; name = "Pedagang"
			"workbench": icon = "⚒"; name = "Bengkel"
			"inn": icon = "🛏"; name = "Penginapan"
			"board": icon = "📜"; name = "Papan Quest"
			"astrologer": icon = "✧"; name = "Astrolog"
			"auctioneer": icon = "🔨"; name = "Rumah Lelang"
			"enchanter": icon = "✦"; name = "Enchanter"
			"house_door": icon = "⌂"; name = "Rumah"
			_: continue
		out.append({"pos": n.global_position, "icon": icon, "name": name})
	for n in get_tree().get_nodes_in_group("dungeon_chest"):
		if n is Node2D:
			out.append({"pos": n.global_position, "icon": "▣", "name": "Peti"})
	return out

func _world_bounds(markers: Array) -> Rect2:
	var r := Rect2()
	var first := true
	var pts: Array = []
	for m in markers:
		pts.append(m.pos)
	if _player:
		pts.append(_player.global_position)
	for p in pts:
		if first:
			r = Rect2(p, Vector2.ZERO)
			first = false
		else:
			r = r.expand(p)
	if first:
		return Rect2(Vector2.ZERO, Vector2(1000, 800))
	return r.grow(180.0)

func _build_region_map() -> void:
	var markers := _collect_markers()
	var bounds := _world_bounds(markers)
	var paper := ColorRect.new()
	paper.color = PAPER
	paper.size = Vector2(640, 366)
	_canvas.add_child(paper)

	var region_name: String = TravelUI.region_def(WorldState.current_region).get("name", WorldState.current_region.capitalize())
	var title := _lbl("%s — %s, %s (h.%d/14)" % [region_name, GameClock.season_name(), GameClock.time_string(), GameClock.season_day()], 14, INK)
	title.position = Vector2(10, 6)
	_canvas.add_child(title)

	var to_map := func(p: Vector2) -> Vector2:
		var f := (p - bounds.position) / bounds.size
		return Vector2(14.0 + f.x * 612.0, 28.0 + f.y * 320.0)

	for m in markers:
		var l := _lbl("%s" % m.icon, 15, INK)
		l.position = to_map.call(m.pos) - Vector2(6, 8)
		l.tooltip_text = m.name
		_canvas.add_child(l)

	# sasaran quest yang dilacak (Jurnal #84) — peta menjawab "aku harus ke mana?"
	var t := QuestSystem.tracked_target()
	if not t.is_empty():
		var group: String = "monsters" if t.get("kind", "") == "monster" else "gather"
		for n in get_tree().get_nodes_in_group(group):
			if not n is Node2D:
				continue
			var q := _lbl("🎯", 13, Color(0.75, 0.1, 0.1))
			q.position = to_map.call(n.global_position) - Vector2(6, 8)
			q.tooltip_text = "Sasaran quest"
			_canvas.add_child(q)

	if _player:
		var me := _lbl("◉", 18, Color(0.72, 0.12, 0.12))
		me.position = to_map.call(_player.global_position) - Vector2(7, 11)
		me.tooltip_text = "Kamu"
		_canvas.add_child(me)
		var mel := _lbl("kamu", 11, Color(0.72, 0.12, 0.12))
		mel.position = to_map.call(_player.global_position) + Vector2(8, -4)
		_canvas.add_child(mel)
	else:
		var no := _lbl("(peta wilayah hanya hidup saat kau berada di dunia)", 12, INK)
		no.position = Vector2(14, 180)
		_canvas.add_child(no)

	var legend := _lbl("◉ kamu   ▼ dungeon   🌍 gerbang   🌳 penjaga pohon   ⚒ bengkel   $ pedagang   🔨 lelang   ▣ peti   🎯 sasaran quest", 11, INK)
	legend.position = Vector2(10, 348)
	_canvas.add_child(legend)

# --- Peta dunia -------------------------------------------------------------

func _build_world_map() -> void:
	var paper := ColorRect.new()
	paper.color = PAPER
	paper.size = Vector2(640, 366)
	_canvas.add_child(paper)
	var cost := TravelUI.travel_cost_today()
	var head := _lbl("PETA DUNIA — Gerbang Penjelajah. Perjalanan hari ini: %s" % (
		"GRATIS (jatah harian)" if cost == 0 else "%d G" % cost), 13, INK)
	head.position = Vector2(10, 6)
	_canvas.add_child(head)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.position = Vector2(12, 30)
	grid.custom_minimum_size = Vector2(616, 320)
	_canvas.add_child(grid)
	for r in TravelUI.regions():
		grid.add_child(_world_card(r))

func _world_card(r: Dictionary) -> Control:
	var visited: bool = r.id in WorldState.visited_regions
	var here: bool = r.id == WorldState.current_region
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(196, 100)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.78, 0.71, 0.55) if visited else Color(0.62, 0.58, 0.48)
	sb.border_color = Color(r.get("color", "#888888")) if visited else Color(0.42, 0.4, 0.35)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(6)
	card.add_theme_stylebox_override("panel", sb)
	var vb := VBoxContainer.new()
	card.add_child(vb)
	if not visited:
		vb.add_child(_lbl("🔒 ? ? ?", 16, Color(0.35, 0.33, 0.3)))
		vb.add_child(_lbl("Belum dijelajahi — datanglah dengan kakimu sendiri.", 10, Color(0.38, 0.36, 0.32)))
		return card
	vb.add_child(_lbl(r.name, 15, INK))
	vb.add_child(_lbl(TravelUI.band_label(r), 11, INK))
	if here:
		vb.add_child(_lbl("📍 Kamu di sini.", 11, Color(0.72, 0.12, 0.12)))
	else:
		var cost := TravelUI.travel_cost_today()
		vb.add_child(_btn("Berangkat" + (" (gratis)" if cost == 0 else " (%dG)" % cost), func(): _travel(r)))
	return card

## Fast travel = sistem Gerbang Penjelajah yang SAMA (satu sistem, dua pintu masuk).
func _travel(r: Dictionary) -> void:
	if TravelUI.do_travel(r, self):
		queue_free()

# --- helpers ----------------------------------------------------------------

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
	b.pressed.connect(func(): Audio.play_sfx("menu"))
	b.pressed.connect(cb)
	UiFx.button(b)
	return b

func _close() -> void:
	get_tree().paused = false
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu") or event.is_action_pressed("world_map"):
		_close()
		get_viewport().set_input_as_handled()
