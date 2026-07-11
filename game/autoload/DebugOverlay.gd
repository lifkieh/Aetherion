extends CanvasLayer
## F9 debug overlay (PC6, dev-only): rolling DPS, last-kill TTK, damage taken,
## and the player's effective stats. Hidden entirely in non-debug builds.

const WINDOW := 5.0   # rolling window (s) for DPS / damage-taken

var _panel: PanelContainer
var _label: Label
var _dealt: Array = []      # [ [time, dmg], ... ] player -> enemy
var _taken: Array = []      # [ [time, dmg], ... ] enemy -> player
var _first_hit: Dictionary = {}   # target instance_id -> time of first player hit
var _last_ttk := -1.0
var _last_kill := ""

func _ready() -> void:
	layer = 30
	visible = false
	if not OS.is_debug_build():
		set_process(false)
		set_process_input(false)
		return
	_build()
	EventBus.damage_dealt.connect(_on_damage)
	EventBus.monster_killed.connect(_on_kill)

func _build() -> void:
	_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.05, 0.12, 0.85)
	sb.border_color = Color(0.4, 0.9, 0.5)
	sb.set_border_width_all(1)
	sb.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.position = Vector2(8, 60)
	add_child(_panel)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.7))
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_label.add_theme_font_override("font", load("res://assets/game/fonts/m5x7.ttf"))
	_panel.add_child(_label)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		visible = not visible

func _now() -> float:
	return Time.get_ticks_msec() / 1000.0

func _on_damage(attacker, target, amount: int, _crit: bool, _elem: String) -> void:
	var t := _now()
	var p := get_tree().get_first_node_in_group("player")
	if attacker == p:
		_dealt.append([t, amount])
		if is_instance_valid(target) and not _first_hit.has(target.get_instance_id()):
			_first_hit[target.get_instance_id()] = t
	elif target == p:
		_taken.append([t, amount])

func _on_kill(species_id: String, monster) -> void:
	if is_instance_valid(monster) and _first_hit.has(monster.get_instance_id()):
		_last_ttk = _now() - _first_hit[monster.get_instance_id()]
		_last_kill = species_id
		_first_hit.erase(monster.get_instance_id())

func _sum_window(arr: Array) -> float:
	var t := _now()
	while not arr.is_empty() and t - arr[0][0] > WINDOW:
		arr.pop_front()
	var s := 0.0
	for e in arr:
		s += e[1]
	return s

func _process(_delta: float) -> void:
	if not visible or _label == null:
		return
	var dps := _sum_window(_dealt) / WINDOW
	var taken := _sum_window(_taken)
	var pd := PlayerData
	_label.text = "== DEBUG (F9) ==\nDPS (5s): %.1f\nTTK terakhir: %s\nDamage diterima (5s): %d\n\nATK %d  MATK %d  DEF %d  MDEF %d\nHP %d/%d  MP %d/%d\nAtkSpd x%.2f  Eva %d%%  Acc %d%%\nCrit %d%%  Regen %.1f MP/s" % [
		dps,
		("%.1fs (%s)" % [_last_ttk, _last_kill]) if _last_ttk >= 0.0 else "-",
		int(taken),
		pd.atk, pd.matk, pd.def, pd.mdef,
		pd.hp, pd.max_hp, pd.mp, pd.max_mp,
		pd.attack_speed, int(pd.evasion * 100), int(pd.accuracy * 100),
		int(pd.crit_rate * 100), pd.mana_regen,
	]
