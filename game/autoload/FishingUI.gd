extends CanvasLayer
## Fishing minigame (MARKET_STUDY E). Cast -> wait for a bite -> hit [E] inside
## the bite window to land a fish rolled by FishingSystem (WIB hour + tide + moon).

enum { IDLE, CASTING, BITE, RESULT }

var state := IDLE
var _timer := 0.0
var _bite_window := 0.0
var _bait := ""
var panel: Control
var label: Label
var bar_bg: ColorRect
var bar_fill: ColorRect

func _ready() -> void:
	layer = 22
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()

func _build() -> void:
	panel = Control.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.35)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(dim)
	var box := PanelContainer.new()
	box.anchor_left = 0.5; box.anchor_top = 0.5; box.anchor_right = 0.5; box.anchor_bottom = 0.5
	box.position = Vector2(-190, -70)
	box.custom_minimum_size = Vector2(380, 140)
	panel.add_child(box)
	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(vb)
	label = Label.new()
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		label.add_theme_font_override("font", load("res://assets/game/fonts/m5x7.ttf"))
	label.add_theme_font_size_override("font_size", 22)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(360, 0)
	vb.add_child(label)
	bar_bg = ColorRect.new()
	bar_bg.color = Color(0.1, 0.1, 0.12)
	bar_bg.custom_minimum_size = Vector2(340, 16)
	vb.add_child(bar_bg)
	bar_fill = ColorRect.new()
	bar_fill.color = Color(0.3, 0.8, 0.4)
	bar_fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	bar_bg.add_child(bar_fill)

func open(bait: String = "") -> void:
	_bait = bait
	visible = true
	get_tree().paused = true
	_start_cast()

func _start_cast() -> void:
	state = CASTING
	_timer = randf_range(1.2, 3.0)
	label.text = "Melempar kail... tunggu gigitan"
	bar_fill.color = Color(0.4, 0.6, 0.9)
	_set_bar(1.0)

func _process(delta: float) -> void:
	match state:
		CASTING:
			_timer -= delta
			_set_bar(clampf(_timer / 3.0, 0.0, 1.0))
			if _timer <= 0.0:
				_start_bite()
		BITE:
			_timer -= delta
			_set_bar(clampf(_timer / _bite_window, 0.0, 1.0))
			if _timer <= 0.0:
				_miss()

func _start_bite() -> void:
	state = BITE
	_bite_window = 0.85
	_timer = _bite_window
	label.text = "❗ IKAN! Tekan [E]!"
	bar_fill.color = Color(0.9, 0.7, 0.2)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause_menu"):
		_close()
		get_viewport().set_input_as_handled()
	elif state == BITE and event.is_action_pressed("interact"):
		_hook()
		get_viewport().set_input_as_handled()
	elif state == RESULT and (event.is_action_pressed("interact") or event.is_action_pressed("photo_mode")):
		_close()
		get_viewport().set_input_as_handled()

func _hook() -> void:
	state = RESULT
	_set_bar(1.0)
	# Star Whale hook path (v0.2 §8.2) takes priority when eligible.
	if FishingSystem.can_hook_starwhale(_bait):
		label.text = "🌟 Sesuatu yang RAKSASA menarik kailmu..."
		Audio.play_sfx("secret")
		WorldState.add_counter("starwhale_hooked")
		return
	var f := FishingSystem.roll(_bait)
	if f.is_empty():
		label.text = "Tidak ada yang tertangkap di jam ini."
	else:
		PlayerData.add_item(f.get("item", ""), 1)
		var rar: String = f.get("rarity", "common")
		var mark := "🏆 " if rar in ["rare", "epic"] else ""
		label.text = "%sDapat: %s!  [E] lanjut" % [mark, f.get("name", "?")]
		Audio.play_sfx("coin" if rar == "junk" else "success")

func _miss() -> void:
	state = RESULT
	label.text = "Lolos! Ikannya kabur.  [E] lanjut"
	_set_bar(0.0)

func _close() -> void:
	visible = false
	get_tree().paused = false
	state = IDLE

func _set_bar(f: float) -> void:
	bar_fill.size = Vector2(340.0 * clampf(f, 0.0, 1.0), 16)
