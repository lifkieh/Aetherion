extends Node
## Db — read-only loader for all data/*.json content (Fase0 §2, Prinsip #1).
## Adding a monster/recipe/skill == adding JSON rows, never touching code.

const DATA_DIR := "res://data/"

var monsters: Dictionary = {}      # id -> def
var items: Dictionary = {}         # id -> def
var recipes: Array = []            # list of recipe defs
var skills: Dictionary = {}        # id -> def
var elements: Dictionary = {}      # {matrix:{}, rules:{}, list:[]}
var scenarios: Array = []
var crops: Dictionary = {}         # id -> def
var loot_tables: Dictionary = {}   # id -> table
var sky_calendar: Array = []
var achievements: Array = []
var quests: Array = []
var fish: Array = []

var _errors: Array[String] = []

func _ready() -> void:
	load_all()

func load_all() -> void:
	_errors.clear()
	monsters = _load_indexed("monsters.json", "id")
	items = _load_indexed("items.json", "id")
	skills = _load_indexed("skills.json", "id")
	crops = _load_indexed("crops.json", "id")
	loot_tables = _load_indexed("loot_tables.json", "id")
	recipes = _load_array("recipes.json")
	scenarios = _load_array("scenarios.json")
	elements = _load_object("elements.json")
	sky_calendar = _load_array("sky_calendar.json")
	achievements = _load_array("achievements.json")
	quests = _load_array("quests.json")
	fish = _load_array("fish.json")
	if _errors.is_empty():
		print("[Db] Loaded: %d monsters, %d items, %d skills, %d recipes, %d crops, %d scenarios" % [
			monsters.size(), items.size(), skills.size(), recipes.size(), crops.size(), scenarios.size()])
	else:
		for e in _errors:
			push_error("[Db] " + e)

# --- JSON helpers -----------------------------------------------------------

func _read_json(filename: String):
	var path := DATA_DIR + filename
	if not FileAccess.file_exists(path):
		_errors.append("Missing data file: " + filename)
		return null
	var txt := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(txt)
	if parsed == null:
		_errors.append("Parse error (or empty) in " + filename)
	return parsed

func _load_indexed(filename: String, key: String) -> Dictionary:
	var out: Dictionary = {}
	var data = _read_json(filename)
	if data is Array:
		for row in data:
			if row is Dictionary and row.has(key):
				out[row[key]] = row
	elif data is Dictionary:
		out = data
	return out

func _load_array(filename: String) -> Array:
	var data = _read_json(filename)
	if data is Array:
		return data
	return []

func _load_object(filename: String) -> Dictionary:
	var data = _read_json(filename)
	if data is Dictionary:
		return data
	return {}

# --- Convenience accessors --------------------------------------------------

func monster(id: String) -> Dictionary:
	return monsters.get(id, {})

func item(id: String) -> Dictionary:
	return items.get(id, {})

func skill(id: String) -> Dictionary:
	return skills.get(id, {})

func crop(id: String) -> Dictionary:
	return crops.get(id, {})

func item_name(id: String) -> String:
	return items.get(id, {}).get("name", id)

func loot_table(id: String) -> Array:
	var t = loot_tables.get(id, {})
	if t is Dictionary:
		return t.get("drops", [])
	return []

func has_errors() -> bool:
	return not _errors.is_empty()

func get_errors() -> Array:
	return _errors
