extends Node
## KEYBIND REMAP + GAMEPAD (v0.4.4, Decision Log #99).
## Semua aksi bisa dipetakan ulang (keyboard/mouse) dan semuanya punya binding
## GAMEPAD bawaan. Perubahan disimpan di `user://settings.cfg` [keys] sebagai
## daftar event; InputMap dibangun ulang saat start.
##
## Prinsip: default gamepad HARUS ada sejak awal (bukan "boleh diatur sendiri") —
## pemain gamepad tak seharusnya membuka menu keyboard hanya untuk bisa main.

## Aksi yang boleh dipetakan ulang + label tampil (key lokalisasi).
const REMAPPABLE := [
	["move_up", "ui.key.move_up"], ["move_down", "ui.key.move_down"],
	["move_left", "ui.key.move_left"], ["move_right", "ui.key.move_right"],
	["interact", "ui.key.interact"], ["attack", "ui.key.attack"],
	["dodge", "ui.key.dodge"], ["toggle_inventory", "ui.key.inventory"],
	["world_map", "ui.key.map"], ["plant_sapling", "ui.key.plant"],
	["pause_menu", "ui.key.pause"],
	["skill_1", "ui.key.skill1"], ["skill_2", "ui.key.skill2"],
	["skill_3", "ui.key.skill3"], ["skill_4", "ui.key.skill4"], ["skill_5", "ui.key.skill5"],
]

## Binding gamepad bawaan (Xbox layout; SDL mapping menangani sisanya).
const PAD_DEFAULTS := {
	"move_up": {"axis": JOY_AXIS_LEFT_Y, "dir": -1.0},
	"move_down": {"axis": JOY_AXIS_LEFT_Y, "dir": 1.0},
	"move_left": {"axis": JOY_AXIS_LEFT_X, "dir": -1.0},
	"move_right": {"axis": JOY_AXIS_LEFT_X, "dir": 1.0},
	"interact": {"button": JOY_BUTTON_A},
	"attack": {"button": JOY_BUTTON_X},
	"dodge": {"button": JOY_BUTTON_B},
	"toggle_inventory": {"button": JOY_BUTTON_Y},
	"world_map": {"button": JOY_BUTTON_BACK},
	"pause_menu": {"button": JOY_BUTTON_START},
	"plant_sapling": {"button": JOY_BUTTON_LEFT_SHOULDER},
	"skill_1": {"button": JOY_BUTTON_DPAD_UP},
	"skill_2": {"button": JOY_BUTTON_DPAD_RIGHT},
	"skill_3": {"button": JOY_BUTTON_DPAD_DOWN},
	"skill_4": {"button": JOY_BUTTON_DPAD_LEFT},
	"skill_5": {"button": JOY_BUTTON_RIGHT_SHOULDER},
	"ui_accept": {"button": JOY_BUTTON_A},
	"ui_cancel": {"button": JOY_BUTTON_B},
}

const CFG := "user://settings.cfg"

var _defaults: Dictionary = {}      # action -> Array[InputEvent] (dari project.godot)
var last_device := "keyboard"       # "keyboard" | "gamepad" — untuk glyph

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for pair in REMAPPABLE:
		_defaults[pair[0]] = InputMap.action_get_events(pair[0]).duplicate()
	_ensure_pad_defaults()
	load_binds()

func _input(event: InputEvent) -> void:
	# lacak perangkat terakhir → glyph mengikuti apa yang benar-benar dipakai pemain
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if last_device != "gamepad":
			last_device = "gamepad"
			EventBus.input_device_changed.emit("gamepad")
	elif event is InputEventKey or event is InputEventMouseButton:
		if last_device != "keyboard":
			last_device = "keyboard"
			EventBus.input_device_changed.emit("keyboard")

## Pasang binding gamepad bawaan pada semua aksi (bila belum ada).
func _ensure_pad_defaults() -> void:
	for action in PAD_DEFAULTS.keys():
		if not InputMap.has_action(action):
			continue
		var has_pad := false
		for e in InputMap.action_get_events(action):
			if e is InputEventJoypadButton or e is InputEventJoypadMotion:
				has_pad = true
		if has_pad:
			continue
		var d: Dictionary = PAD_DEFAULTS[action]
		if d.has("button"):
			var b := InputEventJoypadButton.new()
			b.button_index = d.button
			InputMap.action_add_event(action, b)
		else:
			var m := InputEventJoypadMotion.new()
			m.axis = d.axis
			m.axis_value = d.dir
			InputMap.action_add_event(action, m)

## Ganti binding keyboard/mouse sebuah aksi (binding gamepad dipertahankan).
func rebind(action: String, event: InputEvent) -> bool:
	if not InputMap.has_action(action):
		return false
	if _conflict(action, event) != "":
		EventBus.toast.emit(Loc.t("ui.keybind.conflict") % _conflict(action, event))
		return false
	for e in InputMap.action_get_events(action):
		if e is InputEventKey or e is InputEventMouseButton:
			InputMap.action_erase_event(action, e)
	InputMap.action_add_event(action, event)
	save_binds()
	return true

## Aksi lain yang sudah memakai event ini ("" bila bebas).
func _conflict(action: String, event: InputEvent) -> String:
	for pair in REMAPPABLE:
		if pair[0] == action:
			continue
		for e in InputMap.action_get_events(pair[0]):
			if e.is_match(event):
				return pair[0]
	return ""

func reset_defaults() -> void:
	for pair in REMAPPABLE:
		var a: String = pair[0]
		InputMap.action_erase_events(a)
		for e in _defaults.get(a, []):
			InputMap.action_add_event(a, e)
	_ensure_pad_defaults()
	save_binds()

## Label tombol saat ini untuk sebuah aksi ("W", "Klik Kiri", "A" dst).
func label_for(action: String) -> String:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			return OS.get_keycode_string(e.physical_keycode if e.physical_keycode != 0 else e.keycode)
		if e is InputEventMouseButton:
			return "Mouse %d" % e.button_index
	return "-"

func save_binds() -> void:
	var cfg := ConfigFile.new()
	cfg.load(CFG)
	for pair in REMAPPABLE:
		var a: String = pair[0]
		var codes: Array = []
		for e in InputMap.action_get_events(a):
			if e is InputEventKey:
				codes.append({"type": "key", "code": e.physical_keycode if e.physical_keycode != 0 else e.keycode})
			elif e is InputEventMouseButton:
				codes.append({"type": "mouse", "code": e.button_index})
		cfg.set_value("keys", a, codes)
	cfg.save(CFG)

func load_binds() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CFG) != OK:
		return
	for pair in REMAPPABLE:
		var a: String = pair[0]
		var codes = cfg.get_value("keys", a, [])
		if not codes is Array or codes.is_empty():
			continue
		for e in InputMap.action_get_events(a):
			if e is InputEventKey or e is InputEventMouseButton:
				InputMap.action_erase_event(a, e)
		for c in codes:
			if c.get("type", "") == "key":
				var k := InputEventKey.new()
				k.physical_keycode = int(c.get("code", 0))
				InputMap.action_add_event(a, k)
			elif c.get("type", "") == "mouse":
				var m := InputEventMouseButton.new()
				m.button_index = int(c.get("code", 1))
				InputMap.action_add_event(a, m)
