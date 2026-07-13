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
var echo_vendors: Array = []
var projectiles: Dictionary = {}   # id -> def
var combat_feel: Dictionary = {}
var professions: Dictionary = {}   # id -> def
var towns: Dictionary = {}         # town_id -> {center, safe_zone, gates} (UI/UX §4)
var classes: Dictionary = {}       # class_id -> def (6 combat classes, FF-2a)
var class_order: Array = []        # display order
var skill_trees: Dictionary = {}   # tree_id -> def (pohon terikat lokasi, Decision Log #30)
var ui_feel: Dictionary = {}       # tuning motion/feel UI (Decision Log #44)
var rumors: Array = []             # rumor + variasi menyimpang (E5, #77)
var town_npcs: Dictionary = {}     # town_id -> 5 persona NPC (Hukum NPC Aneh, E6 #78)
var miracles: Array = []           # keajaiban langka tak-dipicu-pemain (E7, #79)
var seasons: Array = []            # 4 musim x 2 minggu nyata (A4, v0.4.3 #83)
var rasi: Array = []               # 12 Rasi Agung (A5, v0.4.3 #91)
var cutscenes: Array = []          # skrip cutscene data-driven (v0.4.3 #94)
var regions: Array = []            # wilayah + BAND level (lv_min/lv_max) — sumber kanon soft-cap EXP (#69)

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
	echo_vendors = _load_array("echo_vendors.json")
	projectiles = _load_indexed("projectiles.json", "id")
	combat_feel = _load_object("combat_feel.json")
	professions = _load_indexed("professions.json", "id")
	towns = _load_object("towns.json")
	classes = _load_indexed("classes.json", "id")
	class_order = _load_array("classes.json").map(func(c): return c.get("id", ""))
	skill_trees = _load_indexed("skill_trees.json", "id")
	ui_feel = _load_object("ui_feel.json")
	rumors = _load_array("rumors.json")
	town_npcs = _load_object("town_npcs.json")
	miracles = _load_array("miracles.json")
	seasons = _load_array("seasons.json")
	rasi = _load_array("rasi.json")
	cutscenes = _load_array("cutscenes.json")
	regions = _load_array("regions.json")
	if _errors.is_empty():
		print("[Db] Loaded: %d monsters, %d items, %d skills, %d recipes, %d crops, %d scenarios" % [
			monsters.size(), items.size(), skills.size(), recipes.size(), crops.size(), scenarios.size()])
	else:
		for e in _errors:
			push_error("[Db] " + e)

# --- Wilayah & BAND level (#69) ---------------------------------------------
## Band adalah KANON, bukan hiasan kartu travel: ia menentukan sampai level berapa
## dunia masih menyediakan lawan. Di luar band tertinggi yang TERBUKA, EXP dicekik
## (soft-cap #69) — pemain tak bisa lari dari konten dengan menaikkan angka.

func region(id: String) -> Dictionary:
	for r in regions:
		if r.get("id", "") == id:
			return r
	return {}

## Atap band dari daftar wilayah yang sudah dibuka pemain (0 bila tak satu pun dikenal).
func band_ceiling(open_ids: Array) -> int:
	var top := 0
	for id in open_ids:
		var r := region(String(id))
		if not r.is_empty():
			top = max(top, int(r.get("lv_max", 0)))
	return top

## Atap band SELURUH konten yang ada di game (skala era sekarang; kini 55).
func band_ceiling_global() -> int:
	var top := 0
	for r in regions:
		top = max(top, int(r.get("lv_max", 0)))
	return top

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

func cls(id: String) -> Dictionary:
	return classes.get(id, {})

func item_name(id: String) -> String:
	return items.get(id, {}).get("name", id)

## Resolve an item to a category icon (UI/UX §7). Returns a res:// path or "".
func item_icon(id: String) -> String:
	var it := item(id)
	var key := ""
	var wt: String = it.get("weapon_type", "")
	if wt in ["sword", "bow", "wand", "spear"]:
		key = wt
	else:
		match it.get("type", ""):
			"orb": key = "orb"
			"seed": key = "seed"
			"bait": key = "essence"
			"gear": key = "pelt"
			"consumable":
				key = "mana" if ("mana" in id or "draught" in id) else "potion"
			_:
				key = _material_icon_key(id)
	var path := "res://assets/game/ui/icons/item_%s.png" % key
	return path if ResourceLoader.exists(path) else ""

func _material_icon_key(id: String) -> String:
	# ordered keyword rules — candy/food checked before jelly/pelt to avoid clashes
	var rules := [
		[["gummy", "choco", "jellybean", "candyfloss", "candy_wool", "peppermint", "lollipop"], "candy"],
		[["meat", "honey", "boar"], "food"],
		[["plank"], "plank"],
		[["bar", "ingot"], "bar"],
		[["ore"], "ore"],
		[["log", "wood", "bark", "living_bark"], "wood"],
		[["herb", "leaf", "bud", "mint", "sunbud", "spore"], "herb"],
		[["jelly", "gel"], "jelly"],
		[["pelt", "wool", "fluff", "fox_tail", "rabbit_foot"], "pelt"],
		[["fang", "antler", "feather", "bone", "fossil"], "bone"],
		[["essence", "core", "star", "ambergris"], "essence"],
		[["gem", "crystal", "fragment", "ankh", "carrot_of"], "gem"],
	]
	for rule in rules:
		for kw in rule[0]:
			if kw in id:
				return rule[1]
	return "pouch"

func loot_table(id: String) -> Array:
	var t = loot_tables.get(id, {})
	if t is Dictionary:
		return t.get("drops", [])
	return []

## Order-independent element fusion recipe lookup (returns {} if none).
func elem_combo(a: String, b: String) -> Dictionary:
	return elem_combo_multi([a, b])

## Order-independent lookup for a 2-4 element fusion. A recipe matches when its set
## of elements (a/b + optional c/d, or an "elems" array) equals the primed set.
func elem_combo_multi(elems: Array) -> Dictionary:
	var want := []
	for e in elems:
		want.append(e)
	want.sort()
	for c in elements.get("combos", []):
		var have: Array = c.get("elems", [])
		if have.is_empty():
			have = [c.get("a", ""), c.get("b", "")]
			if c.has("c"): have.append(c["c"])
			if c.has("d"): have.append(c["d"])
		var hs := have.duplicate()
		hs.sort()
		if hs == want:
			return c
	return {}

func has_errors() -> bool:
	return not _errors.is_empty()

func get_errors() -> Array:
	return _errors
