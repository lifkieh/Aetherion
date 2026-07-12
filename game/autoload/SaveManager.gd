extends Node
## SaveManager — 3 slots + backup rotation + schema_version + atomic write.
## Atomic write: write temp -> rename (Fase0 §8).

const SCHEMA_VERSION := 1
const SAVE_DIR := "user://save/"
const MAX_BACKUPS := 3
const AUTOSAVE_INTERVAL := 180.0   # autosave berkala (FF-2e)

## The slot the player is currently playing (set on save/load); used by
## quick-save (F5) and scenario auto-save so results land in the right slot.
var current_slot := 1
var _auto_t := AUTOSAVE_INTERVAL
var _world_check := 0.0
var _in_world := false

func _ready() -> void:
	_ensure_dir()

## Playtime accumulation + periodic autosave — only while actually in the world.
func _process(delta: float) -> void:
	if get_tree().paused:
		return
	_world_check -= delta
	if _world_check <= 0.0:
		_world_check = 1.0
		_in_world = get_tree().get_first_node_in_group("player") != null
	if not _in_world:
		return
	PlayerData.playtime_sec += delta
	_auto_t -= delta
	if _auto_t <= 0.0:
		_auto_t = AUTOSAVE_INTERVAL
		autosave()

## Quiet save to the active slot (periodic + area transitions). FF-2e.
func autosave() -> void:
	if get_tree().get_first_node_in_group("player") == null:
		return
	if ScenarioManager.active_scenario != "":
		return   # never autosave mid Hidden-Scenario (no-fail integrity)
	save_game(current_slot, true)

## Slot terakhir yang dipakai (untuk tombol Continue di title). Disimpan di Settings cfg.
func last_slot() -> int:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		return int(cfg.get_value("save", "last_slot", 0))
	return 0

func _remember_slot(slot: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("save", "last_slot", slot)
	cfg.save("user://settings.cfg")

func _ensure_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot

func backup_path(slot: int, n: int) -> String:
	return SAVE_DIR + "slot_%d.bak%d.json" % [slot, n]

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))

func build_payload() -> Dictionary:
	var scn := get_tree().current_scene
	return {
		"schema_version": SCHEMA_VERSION,
		"saved_at": GameClock.unix_now(),
		"saved_at_str": GameClock.date_string() + " " + GameClock.time_string(),
		"location": scn.name if scn else "?",
		"player": PlayerData.to_save(),
		"world": WorldState.to_save(),
		"economy": Economy.to_save(),
	}

func save_game(slot: int, quiet: bool = false) -> bool:
	current_slot = slot
	_remember_slot(slot)
	_ensure_dir()
	_rotate_backups(slot)
	var payload := build_payload()
	var json := JSON.stringify(payload, "\t")
	var tmp := slot_path(slot) + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_error("[SaveManager] cannot open temp for slot %d" % slot)
		return false
	f.store_string(json)
	f.close()
	# atomic replace
	var da := DirAccess.open(SAVE_DIR)
	if da:
		if da.file_exists(slot_path(slot).get_file()):
			da.remove(slot_path(slot).get_file())
		var err := da.rename(tmp.get_file(), slot_path(slot).get_file())
		if err != OK:
			push_error("[SaveManager] rename failed (%d)" % err)
			return false
	EventBus.save_completed.emit(slot)
	if not quiet:
		EventBus.toast.emit("Game tersimpan (slot %d)" % slot)
	return true

func _rotate_backups(slot: int) -> void:
	if not has_save(slot):
		return
	var da := DirAccess.open(SAVE_DIR)
	if da == null:
		return
	# shift bak(n-1)->bak(n)
	for n in range(MAX_BACKUPS, 1, -1):
		var older := backup_path(slot, n - 1).get_file()
		var newer := backup_path(slot, n).get_file()
		if da.file_exists(older):
			if da.file_exists(newer):
				da.remove(newer)
			da.rename(older, newer)
	# current -> bak1 (copy)
	var cur := FileAccess.get_file_as_string(slot_path(slot))
	var bf := FileAccess.open(backup_path(slot, 1), FileAccess.WRITE)
	if bf:
		bf.store_string(cur)
		bf.close()

func load_game(slot: int) -> bool:
	if not has_save(slot):
		return _try_load_backup(slot)
	var txt := FileAccess.get_file_as_string(slot_path(slot))
	var data = JSON.parse_string(txt)
	if data == null or not (data is Dictionary):
		push_warning("[SaveManager] slot %d corrupt, trying backup" % slot)
		return _try_load_backup(slot)
	return _apply(data, slot)

func _try_load_backup(slot: int) -> bool:
	for n in range(1, MAX_BACKUPS + 1):
		if FileAccess.file_exists(backup_path(slot, n)):
			var txt := FileAccess.get_file_as_string(backup_path(slot, n))
			var data = JSON.parse_string(txt)
			if data is Dictionary:
				return _apply(data, slot)
	return false

func _apply(data: Dictionary, slot: int) -> bool:
	current_slot = slot
	data = _migrate(data)
	PlayerData.from_save(data.get("player", {}))
	WorldState.from_save(data.get("world", {}))
	Economy.from_save(data.get("economy", {}))
	EventBus.game_loaded.emit(slot)
	EventBus.toast.emit("Game dimuat (slot %d)" % slot)
	return true

func _migrate(data: Dictionary) -> Dictionary:
	var v: int = data.get("schema_version", 0)
	# Future migrations chain here: while v < SCHEMA_VERSION: ...
	if v < SCHEMA_VERSION:
		data["schema_version"] = SCHEMA_VERSION
	return data

func delete_save(slot: int) -> void:
	var da := DirAccess.open(SAVE_DIR)
	if da == null:
		return
	for p in [slot_path(slot)] + range(1, MAX_BACKUPS + 1).map(func(n): return backup_path(slot, n)):
		var fn: String = p.get_file()
		if da.file_exists(fn):
			da.remove(fn)

func save_meta(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var txt := FileAccess.get_file_as_string(slot_path(slot))
	var data = JSON.parse_string(txt)
	if data is Dictionary:
		var p: Dictionary = data.get("player", {})
		var pt := int(p.get("playtime_sec", 0))
		return {
			"saved_at_str": data.get("saved_at_str", "?"),
			"level": p.get("level", 1),
			"name": p.get("char_name", "?"),
			"class": Db.cls(p.get("char_class", "")).get("name", "?"),
			"playtime": "%d:%02d" % [pt / 3600, (pt % 3600) / 60],
			"location": data.get("location", "?"),
		}
	return {}
