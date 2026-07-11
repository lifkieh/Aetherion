extends Node
## PlayerData — active character: stats, inventory, professions, gold, pets.
## Combat-relevant derived stats feed CombatResolver (Fase0 §4).

signal stats_recalculated()

# --- Identity / progression ---
var char_name: String = "Wanderer"
var birth_sign: String = ""            # set from creation date (v0.3 §3.3)
var level: int = 1
var exp: int = 0

# --- Primary attributes (GDD Bagian 3) ---
var attributes: Dictionary = {
	"STR": 5, "END": 5, "AGI": 5, "INT": 5, "LUK": 5,
}
var stat_points: int = 0

# --- Derived combat stats (recomputed) ---
var max_hp: int = 100
var max_mp: int = 50
var atk: int = 10
var def: int = 5
var matk: int = 10
var mdef: int = 5
var spd: int = 100
var crit_rate: float = 0.05
var crit_dmg: float = 1.5

var hp: int = 100
var mp: int = 50

# --- Economy / inventory ---
var gold: int = 200
var inventory: Dictionary = {}         # item_id -> qty
var equipped_weapon: String = ""       # item_id (affects ATK + weapon element base)

# --- Skills / element ---
var known_skills: Array = ["strike", "flame_slash", "spark_bolt"]
var mastered_elements: Array = ["fire", "lightning"]
var infusion: Dictionary = {}          # {element, source, expires_unix} or empty

# --- Taming / pets ---
var monsters: Array = []               # tamed monster instances (dicts)
var active_pet_index: int = -1
var mounted: bool = false

# --- Homestead / scenario ---
var homestead_plots: Array = []        # [{crop_id, planted_at_unix, watered}]
var scenario_flags: Dictionary = {}    # id -> "cleared"/"failed"/"locked"
var titles: Array = []
var professions: Dictionary = {"main": "adventurer", "sub": []}

func _ready() -> void:
	recalculate_stats()
	hp = max_hp
	mp = max_mp

## Reset to a fresh character (New Game). birth_sign from creation date (v0.3 §3.3).
func new_game() -> void:
	level = 1; exp = 0; stat_points = 0
	attributes = {"STR": 5, "END": 5, "AGI": 5, "INT": 5, "LUK": 5}
	gold = 200
	inventory = {"minor_potion": 3, "basic_orb": 2, "wooden_sword": 1, "seed_mintleaf": 3}
	equipped_weapon = "wooden_sword"
	known_skills = ["strike", "flame_slash", "spark_bolt"]
	mastered_elements = ["fire", "lightning"]
	infusion = {}
	monsters = []
	active_pet_index = -1
	mounted = false
	homestead_plots = []
	scenario_flags = {}
	titles = []
	professions = {"main": "adventurer", "sub": []}
	birth_sign = _birth_sign_from_today()
	recalculate_stats()
	hp = max_hp
	mp = max_mp

func _birth_sign_from_today() -> String:
	# 12 Rasi Agung mapped by month (v0.3 §3.1) — flavor.
	var signs := ["Serigala","Paus","Pedang","Timbangan","Naga","Kelinci","Mahkota","Jangkar","Obor","Cermin","Benih","Gerbang"]
	return signs[(GameClock.now_wib().month - 1) % 12]

# --- EXP / leveling ---------------------------------------------------------

func exp_to_next() -> int:
	return int(round(50.0 * pow(level, 1.5)))

func gain_exp(amount: int) -> void:
	if amount <= 0:
		return
	exp += amount
	var leveled := false
	while exp >= exp_to_next():
		exp -= exp_to_next()
		level += 1
		stat_points += 3
		# auto-distribute for now (playable without a stat screen)
		attributes["STR"] += 1
		attributes["END"] += 1
		attributes["INT"] += 1
		leveled = true
	if leveled:
		recalculate_stats()
		hp = max_hp
		mp = max_mp
		EventBus.player_leveled_up.emit(level)
		EventBus.toast.emit("Level Up! Lv %d" % level)
	EventBus.player_exp_changed.emit(exp, exp_to_next())

# --- Derived stats ----------------------------------------------------------

func recalculate_stats() -> void:
	var s: int = attributes.STR
	var e: int = attributes.END
	var a: int = attributes.AGI
	var i: int = attributes.INT
	var l: int = attributes.LUK
	var lv := level
	# Hero is deliberately stronger per-point than fodder monsters (BST-based),
	# so early common monsters die in a handful of hits (Monster_Roster §1.3 TTK).
	max_hp = 140 + e * 16 + lv * 12
	max_mp = 40 + i * 6 + lv * 4
	atk = 24 + s * 5 + lv * 3 + _weapon_atk()
	def = 8 + e * 2 + lv
	matk = 20 + i * 5 + lv * 3
	mdef = 6 + i + e + lv
	spd = 90 + a * 3
	crit_rate = clampf(0.05 + l * 0.004, 0.05, 0.60)
	crit_dmg = 1.5
	hp = min(hp, max_hp)
	mp = min(mp, max_mp)
	stats_recalculated.emit()
	EventBus.player_hp_changed.emit(hp, max_hp)
	EventBus.player_mp_changed.emit(mp, max_mp)

func _weapon_atk() -> int:
	if equipped_weapon == "":
		return 0
	return Db.item(equipped_weapon).get("atk", 0)

## Stat block consumed by CombatResolver.
func combat_stats() -> Dictionary:
	return {
		"atk": atk, "def": def, "matk": matk, "mdef": mdef, "spd": spd,
		"crit_rate": crit_rate, "crit_dmg": crit_dmg,
		"level": level, "hp": hp, "max_hp": max_hp,
		"element": current_weapon_element(),
		"resist": {},
	}

# --- Element / infusion -----------------------------------------------------

func current_weapon_element() -> String:
	# Active infusion overrides the weapon's innate element (Element Flow, v0.3 §7).
	if has_active_infusion():
		return infusion.get("element", "none")
	if equipped_weapon != "":
		return Db.item(equipped_weapon).get("element", "none")
	return "none"

func has_active_infusion() -> bool:
	if infusion.is_empty():
		return false
	return GameClock.unix_now() < infusion.get("expires_unix", 0)

func apply_infusion(element: String, duration: int) -> void:
	infusion = {
		"element": element,
		"source": "flow",
		"expires_unix": GameClock.unix_now() + duration,
	}
	EventBus.toast.emit("Element Flow: " + element.capitalize())

func clear_infusion() -> void:
	infusion = {}

# --- HP / MP ----------------------------------------------------------------

func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)
	EventBus.player_hp_changed.emit(hp, max_hp)

func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)
	EventBus.player_hp_changed.emit(hp, max_hp)

func spend_mp(amount: int) -> bool:
	if mp < amount:
		return false
	mp -= amount
	EventBus.player_mp_changed.emit(mp, max_mp)
	return true

func restore_mp(amount: int) -> void:
	mp = min(max_mp, mp + amount)
	EventBus.player_mp_changed.emit(mp, max_mp)

func is_dead() -> bool:
	return hp <= 0

func respawn() -> void:
	hp = max_hp
	mp = max_mp
	EventBus.player_hp_changed.emit(hp, max_hp)

# --- Inventory / gold -------------------------------------------------------

func add_item(item_id: String, qty: int = 1) -> void:
	if qty <= 0:
		return
	inventory[item_id] = inventory.get(item_id, 0) + qty
	EventBus.item_gained.emit(item_id, qty)

func remove_item(item_id: String, qty: int = 1) -> bool:
	if inventory.get(item_id, 0) < qty:
		return false
	inventory[item_id] -= qty
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	return true

func item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

func add_gold(amount: int) -> void:
	gold = max(0, gold + amount)
	EventBus.gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	EventBus.gold_changed.emit(gold)
	return true

# --- Save / load ------------------------------------------------------------

func to_save() -> Dictionary:
	return {
		"char_name": char_name, "birth_sign": birth_sign,
		"level": level, "exp": exp, "attributes": attributes, "stat_points": stat_points,
		"hp": hp, "mp": mp, "gold": gold, "inventory": inventory,
		"equipped_weapon": equipped_weapon, "known_skills": known_skills,
		"mastered_elements": mastered_elements, "monsters": monsters,
		"active_pet_index": active_pet_index, "homestead_plots": homestead_plots,
		"scenario_flags": scenario_flags, "titles": titles, "professions": professions,
	}

func from_save(d: Dictionary) -> void:
	char_name = d.get("char_name", "Wanderer")
	birth_sign = d.get("birth_sign", "")
	level = d.get("level", 1)
	exp = d.get("exp", 0)
	attributes = d.get("attributes", attributes)
	stat_points = d.get("stat_points", 0)
	gold = d.get("gold", 200)
	inventory = d.get("inventory", {})
	equipped_weapon = d.get("equipped_weapon", "")
	known_skills = d.get("known_skills", known_skills)
	mastered_elements = d.get("mastered_elements", mastered_elements)
	monsters = d.get("monsters", [])
	active_pet_index = d.get("active_pet_index", -1)
	homestead_plots = d.get("homestead_plots", [])
	scenario_flags = d.get("scenario_flags", {})
	titles = d.get("titles", [])
	professions = d.get("professions", {"main": "adventurer", "sub": []})
	recalculate_stats()
	hp = d.get("hp", max_hp)
	mp = d.get("mp", max_mp)
	EventBus.player_hp_changed.emit(hp, max_hp)
	EventBus.player_mp_changed.emit(mp, max_mp)
	EventBus.gold_changed.emit(gold)
