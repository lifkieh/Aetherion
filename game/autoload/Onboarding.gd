extends CanvasLayer
## Onboarding (owner UI/UX §5) — teaches a brand-new player to play in <10 min.
##   • contextual one-time tip popups (town / tree / monster / levelup / orb / dungeon door)
##   • a 5-step opening quest chain (chop 3 → craft 1 → kill 2 → tame 1 → visit board)
##     shown in an always-on tracker, advanced via EventBus, persisted in PlayerData.
## Short, friendly Bahasa Indonesia — never condescending. Non-blocking (never pauses).

# --- contextual tips --------------------------------------------------------
const TIPS := {
	"town": {
		"title": "Selamat datang di Greenvale",
		"text": "Ini kota — zona aman. Monster tak bisa masuk dan penjaga gerbang menjagamu. Jelajahi dengan tenang, lalu ikuti Panduan di kanan layar."},
	"tree": {
		"title": "Menebang & memungut",
		"text": "Dekati pohon atau batu, lalu tekan E untuk memungut bahan. Bahan dipakai untuk meramu di Bengkel."},
	"monster": {
		"title": "Bertarung",
		"text": "Klik kiri untuk menyerang ke arah kursor. Tekan angka 1–5 untuk 'prime' skill, lalu klik kiri untuk melepasnya. Space untuk menghindar."},
	"levelup": {
		"title": "Naik level!",
		"text": "Statusmu meningkat dan HP/MP pulih. Musuh lebih kuat menanti di gua dan wilayah lain."},
	"orb": {
		"title": "Menjinakkan monster",
		"text": "Lemahkan monster hingga HP-nya sangat rendah, dekati, lalu tekan T untuk menjinakkannya dengan Orb. Pet ikut bertarung — dan sebagian bisa ditunggangi (R)."},
	"dungeon_door": {
		"title": "Pintu gua",
		"text": "Tekan E untuk masuk. Di dalam gua, dunia jadi sisi-samping (ala Terraria): lompat dengan Space, gali blok, kalahkan bos di dasar."},
}

# --- opening quest chain ----------------------------------------------------
const STEPS := [
	{"desc": "Tebang 3 pohon (dekati, tekan E)", "kind": "gather_tree", "count": 3},
	{"desc": "Ramu 1 barang di Bengkel (tekan E)", "kind": "craft", "count": 1},
	{"desc": "Kalahkan 2 monster (klik kiri)", "kind": "kill", "count": 2},
	{"desc": "Jinakkan 1 monster (lemahkan, tekan T)", "kind": "tame", "count": 1},
	{"desc": "Kunjungi Papan Quest (tekan E)", "kind": "board", "count": 1},
]

var _panel: PanelContainer
var _title: Label
var _body: Label
var _queue: Array = []
var _showing := false

var _tracker: PanelContainer
var _tracker_label: Label

func _ready() -> void:
	layer = 35
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_popup()
	_build_tracker()
	EventBus.player_leveled_up.connect(func(_lv): tip("levelup"))
	EventBus.item_gained.connect(_on_item_gained)
	EventBus.node_harvested.connect(func(t, _i, _q): _advance("gather_tree" if t == "tree" else "", t))
	EventBus.item_crafted.connect(func(_i, ok): if ok: _advance("craft"))
	EventBus.monster_killed.connect(func(_s, _m): _advance("kill"))
	EventBus.pet_added.connect(func(_p): _advance("tame"))
	EventBus.board_visited.connect(func(): _advance("board"))
	EventBus.game_loaded.connect(func(_s): _refresh_tracker())
	call_deferred("_refresh_tracker")

# --- Contextual tips --------------------------------------------------------

var _vis_cd := 0.0

func _process(delta: float) -> void:
	# hide the whole onboarding overlay outside gameplay (e.g. main menu = no player)
	_vis_cd -= delta
	if _vis_cd > 0.0:
		return
	_vis_cd = 0.3
	visible = get_tree().get_first_node_in_group("player") != null

## Show a one-time tip (id from TIPS). No-op if already seen this save.
func tip(id: String) -> void:
	if not TIPS.has(id) or id in PlayerData.onboarding_seen:
		return
	PlayerData.onboarding_seen.append(id)
	_queue.append(id)
	if not _showing:
		_next()

func _on_item_gained(item_id: String, _qty: int) -> void:
	if item_id.ends_with("_orb") or item_id == "basic_orb":
		tip("orb")

func _next() -> void:
	if _queue.is_empty():
		_showing = false
		return
	_showing = true
	var id: String = _queue.pop_front()
	var t: Dictionary = TIPS[id]
	_title.text = "💡 " + t.get("title", "")
	_body.text = t.get("text", "")
	Audio.play_sfx("secret")
	_panel.modulate.a = 0.0
	_panel.visible = true
	var tw := create_tween()
	tw.tween_property(_panel, "modulate:a", 1.0, 0.35)
	tw.tween_interval(6.0)
	tw.tween_property(_panel, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func():
		_panel.visible = false
		_next())

# --- Opening quest chain ----------------------------------------------------

func _advance(kind: String, _target := "") -> void:
	if kind == "" or PlayerData.guide_step >= STEPS.size():
		return
	var step: Dictionary = STEPS[PlayerData.guide_step]
	if step.get("kind", "") != kind:
		return
	PlayerData.guide_progress += 1
	if PlayerData.guide_progress >= int(step.get("count", 1)):
		_complete_step()
	else:
		_refresh_tracker()

func _complete_step() -> void:
	PlayerData.guide_step += 1
	PlayerData.guide_progress = 0
	Audio.play_sfx("success")
	if PlayerData.guide_step >= STEPS.size():
		EventBus.toast.emit("🎓 Panduan selesai! Kamu siap menjelajah Aetherion.")
		PlayerData.add_gold(100)
		PlayerData.add_item("basic_orb", 3)
		EventBus.toast.emit("🎁 Hadiah lulus: 100G + 3 Orb Dasar")
	else:
		var nxt: Dictionary = STEPS[PlayerData.guide_step]
		EventBus.toast.emit("✅ Langkah selesai! Berikutnya: %s" % nxt.get("desc", ""))
	_refresh_tracker()

func _refresh_tracker() -> void:
	if _tracker == null:
		return
	if PlayerData.guide_step >= STEPS.size():
		_tracker.visible = false
		return
	var step: Dictionary = STEPS[PlayerData.guide_step]
	_tracker.visible = true
	_tracker_label.text = "📜 Panduan %d/%d\n%s  (%d/%d)" % [
		PlayerData.guide_step + 1, STEPS.size(), step.get("desc", ""),
		PlayerData.guide_progress, int(step.get("count", 1))]

# --- UI ---------------------------------------------------------------------

func _mk_label(size: int, color: Color) -> Label:
	var l := Label.new()
	if UiTheme.font:
		l.add_theme_font_override("font", UiTheme.font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _build_popup() -> void:
	_panel = PanelContainer.new()
	_panel.theme = UiTheme.theme
	_panel.anchor_left = 0.5; _panel.anchor_right = 0.5
	_panel.position = Vector2(-230, 96)
	_panel.custom_minimum_size = Vector2(460, 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.visible = false
	add_child(_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	_panel.add_child(vb)
	_title = _mk_label(20, UiTheme.ACCENT)
	vb.add_child(_title)
	_body = _mk_label(16, UiTheme.TEXT)
	_body.custom_minimum_size = Vector2(440, 0)
	vb.add_child(_body)

func _build_tracker() -> void:
	_tracker = PanelContainer.new()
	_tracker.theme = UiTheme.theme
	_tracker.anchor_left = 1.0; _tracker.anchor_right = 1.0
	_tracker.position = Vector2(-250, 156)   # below the minimap (R2 HUD)
	_tracker.custom_minimum_size = Vector2(238, 0)
	_tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tracker.visible = false
	add_child(_tracker)
	_tracker_label = _mk_label(15, UiTheme.TEXT)
	_tracker_label.custom_minimum_size = Vector2(214, 0)
	_tracker.add_child(_tracker_label)
