extends Node
## PlayerData — active character: stats, inventory, professions, gold, pets.
## Combat-relevant derived stats feed CombatResolver (Fase0 §4).

signal stats_recalculated()

# --- Identity / progression ---
var char_name: String = "Wanderer"
var birth_sign: String = ""            # set from creation date (v0.3 §3.3)
var level: int = 1
var exp: int = 0

# --- Primary attributes (GDD §3.5): STR/AGI/VIT/INT/DEX/LUK ---
var attributes: Dictionary = {
	"STR": 5, "AGI": 5, "VIT": 5, "INT": 5, "DEX": 5, "LUK": 5,
}
var stat_points: int = 0
const ATTR_ORDER := ["STR", "AGI", "VIT", "INT", "DEX", "LUK"]
const ATTR_DESC := {
	"STR": "Kekuatan — menambah ATK fisik.",
	"AGI": "Ketangkasan — mempercepat serangan & menaikkan evasion.",
	"VIT": "Vitalitas — menambah HP & pertahanan.",
	"INT": "Intelek — menambah MATK, mana, & regen mana.",
	"DEX": "Kecekatan — menaikkan akurasi & kualitas panen.",
	"LUK": "Keberuntungan — menaikkan crit & peluang drop.",
}
const POINTS_PER_LEVEL := 5

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
var equipped_armor: String = ""        # item_id (armor slot — DEF/HP)
var equipped_accessory: String = ""    # item_id (accessory slot — varied)

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
var professions: Dictionary = {"main": "", "sub": [], "last_main_change": 0}
var achievements: Array = []           # unlocked achievement ids
var active_title: String = ""          # equipped title (micro-buff)
var discovered: Dictionary = {"monsters": {}, "items": {}, "weathers": {}}  # Aetherpedia
var craft_insight: Dictionary = {}     # recipe_id -> accumulated success bonus
var daily_quests: Dictionary = {}      # {date, quests:[...]} — Daily Quest Board
var prof_xp: Dictionary = {}           # profession -> xp (miner, lumberjack, ...)
var hotbar: Array = ["flame_slash", "spark_bolt", "flow_fire", "flow_lightning", "strike"]  # 5 slots
var discovered_fusions: Array = []     # combo results the player has cast (first-discovery)
var char_config: Dictionary = {}       # Aetherion Character System v2 look (CharGen)
var onboarding_seen: Array = []        # contextual tip ids already shown (UI/UX §5)
var guide_step: int = 0                # opening quest chain: current step 0..5 (5 = done)
var guide_progress: int = 0            # progress within the current opening-chain step

func _ready() -> void:
	recalculate_stats()
	hp = max_hp
	mp = max_mp
	EventBus.monster_killed.connect(_on_monster_killed)

## Boss first-kill skill unlocks (PC4) — one hook for both perspectives.
func _on_monster_killed(species_id: String, node) -> void:
	if is_instance_valid(node) and ("inst" in node) and node.inst.get("is_boss", false):
		on_boss_killed(species_id)

## Reset to a fresh character (New Game). birth_sign from creation date (v0.3 §3.3).
func new_game() -> void:
	level = 1; exp = 0; stat_points = 0
	attributes = {"STR": 5, "AGI": 5, "VIT": 5, "INT": 5, "DEX": 5, "LUK": 5}
	gold = 200
	inventory = {"minor_potion": 3, "basic_orb": 2, "wooden_sword": 1, "cloth_tunic": 1, "seed_mintleaf": 3}
	equipped_weapon = "wooden_sword"
	equipped_armor = "cloth_tunic"     # starting gear is tier F (PC5)
	equipped_accessory = ""
	known_skills = ["strike", "flame_slash", "spark_bolt"]
	mastered_elements = ["fire", "lightning"]
	infusion = {}
	monsters = []
	active_pet_index = -1
	mounted = false
	homestead_plots = []
	scenario_flags = {}
	titles = []
	professions = {"main": "", "sub": [], "last_main_change": 0}
	achievements = []
	active_title = ""
	discovered = {"monsters": {}, "items": {}, "weathers": {}}
	craft_insight = {}
	daily_quests = {}
	prof_xp = {}
	hotbar = ["flame_slash", "spark_bolt", "flow_fire", "flow_lightning", "strike"]
	discovered_fusions = []
	char_config = CharGen.default_config()
	onboarding_seen = []
	guide_step = 0
	guide_progress = 0
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
		stat_points += POINTS_PER_LEVEL   # +5 free points to allocate in the Status tab
		leveled = true
	if leveled:
		recalculate_stats()
		hp = max_hp
		mp = max_mp
		EventBus.player_leveled_up.emit(level)
		EventBus.toast.emit("Level Up! Lv %d" % level)
		_learn_level_milestones()
	EventBus.player_exp_changed.emit(exp, exp_to_next())

# --- Skill acquisition (PC4) -------------------------------------------------

## True if the player may prime this skill: flow skills need the element mastered;
## every other active skill must be in known_skills.
func can_use_skill(sid: String) -> bool:
	var sk := Db.skill(sid)
	if sk.is_empty():
		return false
	if sk.get("kind", "") == "flow":
		return sk.get("element", "") in mastered_elements
	return sid in known_skills

## Learn an active skill. Idempotent. Applies element mastery ("masters") too.
## Returns true only if it was newly learned.
func learn_skill(sid: String) -> bool:
	var sk := Db.skill(sid)
	if sk.is_empty() or sid in known_skills:
		return false
	known_skills.append(sid)
	var mastered: String = sk.get("masters", "")
	if mastered != "" and not (mastered in mastered_elements):
		mastered_elements.append(mastered)
	EventBus.skill_learned.emit(sid)
	var star := "★ " if sk.get("ultimate", false) else ""
	EventBus.toast.emit("%sSkill dipelajari: %s!" % [star, sk.get("name", sid)])
	Audio.play_sfx("levelup", 1.1)
	return true

## Auto-learn every level-milestone skill the player now qualifies for.
func _learn_level_milestones() -> void:
	for sk in Db.skills.values():
		var u: Dictionary = sk.get("unlock", {})
		if u.get("source", "") == "level" and level >= int(u.get("level", 999)):
			learn_skill(sk.get("id", ""))

## Boss first-kill unlocks: learn any skill gated behind this boss species.
func on_boss_killed(species_id: String) -> void:
	for sk in Db.skills.values():
		var u: Dictionary = sk.get("unlock", {})
		if u.get("source", "") == "boss" and u.get("boss", "") == species_id:
			learn_skill(sk.get("id", ""))

## Learn from a Skill Book item in the bag (consumes it). Returns true on success.
func use_skillbook(item_id: String) -> bool:
	var it := Db.item(item_id)
	var sid: String = it.get("skill_book", "")
	if sid == "":
		return false
	if sid in known_skills:
		EventBus.toast.emit("Skill ini sudah dikuasai.")
		return false
	if learn_skill(sid):
		remove_item(item_id, 1)
		return true
	return false

## Pay a trainer to learn a skill (gold + level prereq). Returns true on success.
func train_skill(sid: String) -> bool:
	var sk := Db.skill(sid)
	var u: Dictionary = sk.get("unlock", {})
	if u.get("source", "") != "trainer" or sid in known_skills:
		return false
	if level < int(u.get("level", 1)):
		EventBus.toast.emit("Butuh Level %d untuk melatih %s." % [int(u.get("level", 1)), sk.get("name", sid)])
		return false
	var cost: int = int(u.get("cost", 0))
	if gold < cost:
		EventBus.toast.emit("Gold tidak cukup (%d G)." % cost)
		return false
	add_gold(-cost)
	return learn_skill(sid)

# --- Derived stats ----------------------------------------------------------

# derived combat extras (GDD §3.5 wiring)
var attack_speed: float = 1.0          # multiplies weapon/skill cast rate (AGI)
var evasion: float = 0.0               # chance to dodge (AGI)
var accuracy: float = 0.90             # hit chance (DEX)
var mana_regen: float = 3.0            # mana/sec base (INT)
var drop_bonus: float = 0.0            # extra drop chance (LUK)
var gather_bonus: float = 0.0          # gather/harvest quality (DEX)

func recalculate_stats() -> void:
	var s: int = attributes.get("STR", 5)
	var a: int = attributes.get("AGI", 5)
	var v: int = attributes.get("VIT", 5)
	var i: int = attributes.get("INT", 5)
	var dx: int = attributes.get("DEX", 5)
	var l: int = attributes.get("LUK", 5)
	var lv := level
	# Hero is deliberately stronger per-point than fodder monsters (BST-based).
	max_hp = 165 + v * 18 + lv * 14 + _gear_stat("hp_bonus")   # VIT -> HP (+ armor)
	max_mp = 40 + i * 8 + lv * 4 + _gear_stat("mp_bonus")      # INT -> mana pool (+ accessory)
	atk = 24 + s * 5 + lv * 3 + _gear_stat("atk")   # STR -> physical ATK (gear atk incl. weapon)
	if has_node("/root/Achievements"):
		atk = int(atk * (1.0 + get_node("/root/Achievements").active_buff("atk_pct")))
	def = 8 + v * 2 + lv + _gear_stat("def")         # VIT -> DEF/resist
	matk = 20 + i * 5 + lv * 3 + _gear_stat("matk")  # INT -> MATK
	mdef = 6 + i + v + lv + _gear_stat("mdef")
	spd = 90 + a * 3
	attack_speed = 1.0 + a * 0.03                    # AGI -> attack/cast speed
	evasion = clampf(a * 0.006, 0.0, 0.40)           # AGI -> evasion
	accuracy = clampf(0.90 + dx * 0.006, 0.6, 0.99)  # DEX -> accuracy
	gather_bonus = dx * 0.02                          # DEX -> gathering quality
	mana_regen = 3.0 + i * 0.35                       # INT -> mana regen
	crit_rate = clampf(0.05 + l * 0.004, 0.05, 0.60) # LUK -> crit
	drop_bonus = l * 0.008                            # LUK -> drop chance
	crit_dmg = 1.5
	hp = min(hp, max_hp)
	mp = min(mp, max_mp)
	stats_recalculated.emit()
	EventBus.player_hp_changed.emit(hp, max_hp)
	EventBus.player_mp_changed.emit(mp, max_mp)

## Which equipped_* slot an item belongs to ("" if not equippable).
func slot_for_item(item_id: String) -> String:
	match Db.item(item_id).get("type", ""):
		"weapon": return "equipped_weapon"
		"armor": return "equipped_armor"
		"accessory": return "equipped_accessory"
	return ""

## Equip an item (or unequip if it's already in its slot — toggle). Returns the
## slot name affected, or "" if the item isn't equippable. (PC5)
func equip_item(item_id: String) -> String:
	var slot := slot_for_item(item_id)
	if slot == "":
		return ""
	if get(slot) == item_id:
		set(slot, "")   # toggle off
		EventBus.toast.emit("Melepas " + Db.item_name(item_id))
	else:
		set(slot, item_id)
		EventBus.toast.emit("Memakai " + Db.item_name(item_id))
	recalculate_stats()
	return slot

## Sum a stat across equipped gear (weapon + armor + accessory). Gear stats really count.
func _gear_stat(key: String) -> int:
	var total := 0
	for slot in ["equipped_weapon", "equipped_armor", "equipped_accessory"]:
		var id: String = get(slot)
		if id != "":
			total += int(Db.item(id).get(key, 0))
	return total

## Allocate one free point into an attribute. Returns true on success.
func allocate_point(attr: String) -> bool:
	if stat_points <= 0 or not attributes.has(attr):
		return false
	attributes[attr] += 1
	stat_points -= 1
	recalculate_stats()
	return true

## Respec: reset all attributes to 5, refund points (paid in gold by the caller).
func respec() -> void:
	var spent := 0
	for k in attributes.keys():
		spent += attributes[k] - 5
		attributes[k] = 5
	stat_points += max(0, spent)
	recalculate_stats()

## Stat block consumed by CombatResolver.
func combat_stats() -> Dictionary:
	return {
		"atk": atk, "def": def, "matk": matk, "mdef": mdef, "spd": spd,
		"crit_rate": crit_rate, "crit_dmg": crit_dmg,
		"level": level, "hp": hp, "max_hp": max_hp,
		"element": current_weapon_element(),
		"accuracy": accuracy, "evasion": evasion,
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
	return not infusion.is_empty()   # persistent now — sustained by mana drain (rev E)

func apply_infusion(element: String, _duration: int = 0) -> void:
	var drain: float = Db.skill("flow_" + element).get("drain", 2.0)
	infusion = {"element": element, "source": "flow", "drain": drain}
	EventBus.toast.emit("Element Flow: " + element.capitalize())

## Toggle a flow infusion: same element = turn off, different = switch. (rev E)
func toggle_infusion(element: String) -> void:
	if infusion.get("element", "") == element:
		clear_infusion()
		EventBus.toast.emit("Element Flow dimatikan.")
	else:
		apply_infusion(element)

func clear_infusion() -> void:
	infusion = {}

# fractional mana accumulator (for per-second drain/regen)
var _mp_frac: float = 0.0

## Drain fractional mana (infusion upkeep). Clears infusion if it runs out.
func drain_mana(amount: float) -> void:
	_mp_frac += amount
	while _mp_frac >= 1.0 and mp > 0:
		_mp_frac -= 1.0
		mp -= 1
	if mp <= 0:
		mp = 0
		if has_active_infusion():
			clear_infusion()
			EventBus.toast.emit("Mana habis — Element Flow padam.")
	EventBus.player_mp_changed.emit(mp, max_mp)

## Regenerate fractional mana (base + INT; caller passes the rate*delta).
func regen_mana(amount: float) -> void:
	if mp >= max_mp:
		return
	_mp_frac += amount
	while _mp_frac >= 1.0 and mp < max_mp:
		_mp_frac -= 1.0
		mp += 1
	EventBus.player_mp_changed.emit(mp, max_mp)

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

## Profession XP (GDD v0.2 §3). Simple accumulation for now; perks TBD.
func gain_prof_xp(profession: String, amount: int) -> void:
	if amount <= 0:
		return
	prof_xp[profession] = prof_xp.get(profession, 0) + amount
	EventBus.prof_xp_gained.emit(profession, prof_xp[profession])

func prof_level(profession: String) -> int:
	return int(floor(sqrt(prof_xp.get(profession, 0) / 20.0))) + 1

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
		"equipped_weapon": equipped_weapon, "equipped_armor": equipped_armor, "equipped_accessory": equipped_accessory,
		"known_skills": known_skills,
		"mastered_elements": mastered_elements, "monsters": monsters,
		"active_pet_index": active_pet_index, "homestead_plots": homestead_plots,
		"scenario_flags": scenario_flags, "titles": titles, "professions": professions,
		"achievements": achievements, "active_title": active_title, "discovered": discovered,
		"craft_insight": craft_insight, "daily_quests": daily_quests, "prof_xp": prof_xp,
		"hotbar": hotbar, "discovered_fusions": discovered_fusions,
		"onboarding_seen": onboarding_seen, "guide_step": guide_step, "guide_progress": guide_progress,
		"char_config": char_config,
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
	equipped_armor = d.get("equipped_armor", "")
	equipped_accessory = d.get("equipped_accessory", "")
	known_skills = d.get("known_skills", known_skills)
	mastered_elements = d.get("mastered_elements", mastered_elements)
	monsters = d.get("monsters", [])
	active_pet_index = d.get("active_pet_index", -1)
	homestead_plots = d.get("homestead_plots", [])
	scenario_flags = d.get("scenario_flags", {})
	titles = d.get("titles", [])
	professions = d.get("professions", {"main": "", "sub": [], "last_main_change": 0})
	achievements = d.get("achievements", [])
	active_title = d.get("active_title", "")
	discovered = d.get("discovered", {"monsters": {}, "items": {}, "weathers": {}})
	craft_insight = d.get("craft_insight", {})
	daily_quests = d.get("daily_quests", {})
	prof_xp = d.get("prof_xp", {})
	hotbar = d.get("hotbar", ["flame_slash", "spark_bolt", "flow_fire", "flow_lightning", "strike"])
	discovered_fusions = d.get("discovered_fusions", [])
	char_config = d.get("char_config", CharGen.default_config())
	onboarding_seen = d.get("onboarding_seen", [])
	guide_step = int(d.get("guide_step", 0))
	guide_progress = int(d.get("guide_progress", 0))
	infusion = {}          # transient — never carry over a save
	mounted = false        # never load mounted (pet may not exist)
	recalculate_stats()
	hp = d.get("hp", max_hp)
	mp = d.get("mp", max_mp)
	EventBus.player_hp_changed.emit(hp, max_hp)
	EventBus.player_mp_changed.emit(mp, max_mp)
	EventBus.gold_changed.emit(gold)
