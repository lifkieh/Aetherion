extends Node
## PlayerData — active character: stats, inventory, professions, gold, pets.
## SAVE_SCHEMA 2 (v0.4.4+): menambah slot reputasi/faksi/influence (#130). Save schema 1
## tetap bisa dimuat — field baru default kosong (migrasi kosong).

const SAVE_SCHEMA := 2
## Combat-relevant derived stats feed CombatResolver (Fase0 §4).

signal stats_recalculated()

# --- Identity / progression ---
var char_name: String = "Wanderer"
var birth_sign: String = ""            # set from creation date (v0.3 §3.3)
var level: int = 1
var exp: int = 0
var playtime_sec: float = 0.0          # akumulasi waktu main (metadata slot, FF-2e)

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
# Gear & Economy v0.4.2: kualitas/maker/enchant per item_id (model stack ringan —
# semua salinan item_id yang sama berbagi meta; keputusan desain, ledger #72)
var gear_meta: Dictionary = {}         # item_id -> {"quality","maker","enchant"}
var coating: Dictionary = {}           # coating senjata aktif {"element","until"} (unix)
const QUALITY_MULT := {"normal": 1.0, "fine": 1.05, "masterwork": 1.10}
const QUALITY_NAME := {"normal": "Normal", "fine": "Halus", "masterwork": "Adikarya"}

# --- Class / skills / element ---
var char_class: String = "warrior"
var advanced_class: String = ""     # jalur lanjutan Lv60 (v0.4.4 #101)

# --- RESERVE (Decision Log #130): slot data reputasi & faksi ---------------
# Faction Bible mengunci: reputasi BUKAN angka global — ia LOKAL lalu menyebar,
# dengan tangga 6 tingkat (Unknown → Recognized → Trusted → Respected →
# Influential → Legendary) dan Influence 6 sumbu. Sistemnya dibangun v0.6,
# TETAPI slotnya di-reserve SEKARANG: menambah field setelah ratusan save beredar
# jauh lebih mahal daripada menyiapkan tempat kosong hari ini.
var reputation: Dictionary = {}     # region_id -> int (0..5 = tangga 6 tingkat)
var faction_standing: Dictionary = {}   # faction_id -> int (-100..100)
var influence: Dictionary = {}      # 6 sumbu: wealth/knowledge/military/reputation/territory/legacy

const REP_LADDER := ["Unknown", "Recognized", "Trusted", "Respected", "Influential", "Legendary"]
const INFLUENCE_AXES := ["wealth", "knowledge", "military", "reputation", "territory", "legacy"]

## Tingkat reputasi di sebuah wilayah (0..5). Reputasi TIDAK universal (#130).
func reputation_at(region_id: String) -> int:
	return clampi(int(reputation.get(region_id, 0)), 0, 5)

func reputation_label(region_id: String) -> String:
	return REP_LADDER[reputation_at(region_id)]     # class terpilih (combat ATAU kehidupan, Decision Log #33)
var combat_sub: String = ""            # jalur kehidupan: 1 combat SUB (1 senjata + 2 skill)
var pending_class: String = "warrior"  # New Game flow: ClassSelect -> CharacterCreator handoff
var pending_weapon: String = ""
var pending_sub: String = ""
var known_skills: Array = ["strike", "flame_slash", "spark_bolt"]
var mastered_elements: Array = ["fire", "lightning"]
var infusion: Dictionary = {}          # {element, source, expires_unix} or empty
var buffs: Dictionary = {}             # key -> {mult/add, until_msec} (war_cry, smoke_bomb)
var statuses: Dictionary = {}          # status effects pada PEMAIN (burn/poison/blind, v0.4.1)
var _softcap_told: int = -1             # level terakhir yang sudah diberi tahu soal soft-cap (#152) — jangan spam
var skill_trees: Dictionary = {}       # tree_id -> level (pohon terikat lokasi, Decision Log #30)

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
var fusion_fizzled_elements: Array = []  # elements that appeared in a fizzle (Grimoire mystery rows, FF-2d)
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
	# AFFINITY hidup (v0.4.1): pet aktif ikut bertempur -> +1 affinity per kill (cap 100)
	if active_pet_index >= 0 and active_pet_index < monsters.size():
		var pet: Dictionary = monsters[active_pet_index]
		var aff := int(pet.get("affinity", 0))
		if aff < 100:
			pet["affinity"] = aff + 1
			monsters[active_pet_index] = pet

## Beri makan pet (v0.4.1): konsumsi 1 item makanan -> +5 affinity (cap 100).
func feed_pet(idx: int, food_id: String) -> bool:
	if idx < 0 or idx >= monsters.size() or item_count(food_id) <= 0:
		return false
	var pet: Dictionary = monsters[idx]
	remove_item(food_id, 1)
	pet["affinity"] = mini(100, int(pet.get("affinity", 0)) + 5)
	monsters[idx] = pet
	EventBus.toast.emit("%s senang! Affinity %d/100" % [pet.get("name", "Pet"), pet["affinity"]])
	Audio.play_sfx("success")
	return true

## Reset to a fresh character (New Game). birth_sign from creation date (v0.3 §3.3).
## class_id = class combat ATAU kehidupan (Decision Log #33); weapon_id = varian senjata;
## sub_id = combat SUB untuk jalur kehidupan (1 senjata + 2 skill, aturan sub).
func new_game(class_id: String = "warrior", weapon_id: String = "", sub_id: String = "") -> void:
	var cd := Db.cls(class_id)
	if cd.is_empty():
		class_id = "warrior"
		cd = Db.cls(class_id)
	char_class = class_id
	var is_life: bool = cd.get("path", "combat") == "life"
	var sub := Db.cls(sub_id) if is_life else {}
	if is_life and sub.is_empty():
		sub = Db.cls("warrior")   # fallback combat sub
	combat_sub = sub.get("id", "") if is_life else ""
	level = 1; exp = 0; stat_points = 0; playtime_sec = 0.0
	attributes = {"STR": 5, "AGI": 5, "VIT": 5, "INT": 5, "DEX": 5, "LUK": 5}
	for k in cd.get("attr", {}):
		attributes[k] = attributes.get(k, 5) + int(cd.attr[k])
	gold = 200
	# senjata: jalur kehidupan memakai senjata pertama dari combat sub-nya
	var wsrc: Dictionary = sub if is_life else cd
	var variants: Array = wsrc.get("weapons", [])
	var wid := weapon_id
	if wid == "" or Db.item(wid).is_empty():
		wid = variants[0].get("id", "wooden_sword") if not variants.is_empty() else "wooden_sword"
	advanced_class = ""
	reputation = {}
	faction_standing = {}
	influence = {}
	gear_meta = {}
	coating = {}
	inventory = {"minor_potion": 3, "basic_orb": 2, "cloth_tunic": 1, "seed_mintleaf": 3}
	inventory[wid] = 1
	for kit_item in cd.get("kit", {}):
		inventory[kit_item] = int(inventory.get(kit_item, 0)) + int(cd.kit[kit_item])
	equipped_weapon = wid
	equipped_armor = "cloth_tunic"     # starting gear is tier F (PC5)
	equipped_accessory = ""
	if is_life:
		# aturan SUB: hanya 2 skill pertama + 1 elemen master pertama dari combat sub
		var sub_skills: Array = sub.get("skills", ["strike", "flame_slash"])
		known_skills = sub_skills.slice(0, 2)
		var sub_masters: Array = sub.get("masters", ["fire"])
		mastered_elements = [sub_masters[0]] if not sub_masters.is_empty() else ["fire"]
	else:
		known_skills = cd.get("skills", ["strike", "flame_slash", "spark_bolt"]).duplicate()
		mastered_elements = cd.get("masters", ["fire"]).duplicate()
	infusion = {}
	buffs = {}
	_softcap_told = -1
	statuses = {}
	skill_trees = {}
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
	if is_life:
		var ls: Array = known_skills.duplicate()
		while ls.size() < 2:
			ls.append("strike")
		hotbar = [ls[0], ls[1], "flow_" + mastered_elements[0], "strike", "strike"]
	else:
		hotbar = cd.get("hotbar", ["strike", "flame_slash", "flow_fire", "strike", "strike"]).duplicate()
	discovered_fusions = []
	fusion_fizzled_elements = []
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

# --- SOFT-CAP EXP (Decision Log #69 / K2, akhirnya dikodekan — #152) ---------
## Level TIDAK dibatasi (B10 tetap sah). Yang dibatasi adalah KECEPATAN lari dari
## konten: di luar band wilayah tertinggi yang sudah kau buka, EXP menanjak brutal.
## Pemain tetap maju (poin & pohon tetap mengalir pelan) — ia hanya tidak bisa
## meninggalkan dunia di belakangnya. Rebase kurva penuh = v0.9.
##
## Jujur, bukan diam-diam: pemain diberi tahu KENAPA EXP-nya menciut, dan apa
## yang harus dilakukan — "jelajahi lebih DALAM, bukan lebih TINGGI".

## Atap band = lv_max wilayah tertinggi yang PERNAH dikunjungi (Greenvale bila kosong).
func band_ceiling() -> int:
	var top := Db.band_ceiling(WorldState.visited_regions)
	if top <= 0:
		top = int(Db.region("greenvale").get("lv_max", 15))
	return top

## Pengali EXP di level sekarang (1.0 = penuh). Menanjak tajam di luar band.
## +1 lv di atas atap → 50% · +2 → 20% · +3 → 10% · +5 → ~4% · lantai 2%.
func exp_softcap_mult() -> float:
	var over := level - band_ceiling()
	if over <= 0:
		return 1.0
	return maxf(0.02, 1.0 / (1.0 + float(over * over)))

func gain_exp(amount: int) -> void:
	if amount <= 0:
		return
	# GOLDEN HOUR 17.00–18.30 WIB: EXP +10% NYATA (v0.2 §6.2, akhirnya berisi — v0.4.1)
	if GameClock.is_golden_hour():
		amount = int(ceil(amount * 1.1))
	var tree_exp: float = SkillTreeSystem.bonus_total("exp_pct")   # pohon skill (#30)
	tree_exp += buff_add("exp_pct")   # buff sementara (mis. pelangi ganda, E7)
	if tree_exp > 0.0:
		amount = int(ceil(amount * (1.0 + tree_exp)))
	var cap := exp_softcap_mult()
	if cap < 1.0:
		amount = max(1, int(floor(amount * cap)))   # tak pernah nol: kemajuan melambat, tidak mati
		EventBus.exp_softcapped.emit(level, band_ceiling(), cap)
		if level != _softcap_told:
			_softcap_told = level
			EventBus.toast.emit(Loc.t("exp.softcap"))
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
		Audio.play_stinger("levelup")
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
	Chronicle.record("boss:" + species_id, "Bos ditaklukkan pertama kali: %s" % Db.monster(species_id).get("name", species_id))
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
	# rev F: the mana pool IS the sustain cap (full channel dries it in ~8-12s at
	# equal level), so it scales gently — INT widens it but can't outrun cast costs.
	max_mp = 30 + i * 5 + lv * 3 + _gear_stat("mp_bonus")      # INT -> mana pool (+ accessory)
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
	mana_regen = 2.0 + i * 0.12                       # INT -> in-combat regen (x3 surge idle, rev B)
	crit_rate = clampf(0.05 + l * 0.004, 0.05, 0.60) # LUK -> crit
	drop_bonus = l * 0.008                            # LUK -> drop chance
	crit_dmg = 1.5
	# class weapon affinity (FF-2b): using your class's weapon type = +8% ATK/MATK, +5% speed
	var wtype: String = Db.item(equipped_weapon).get("weapon_type", "")
	if equipped_weapon != "" and wtype in Db.cls(char_class).get("affinity", []):
		atk = int(atk * 1.08)
		matk = int(matk * 1.08)
		attack_speed *= 1.05
	# perk class kehidupan (Decision Log #33)
	if char_class == "peramu":
		gather_bonus += 0.05
	# bonus pohon skill (Decision Log #30): pasif dari pohon yang dimiliki
	if not skill_trees.is_empty():
		atk = int(atk * (1.0 + SkillTreeSystem.bonus_total("atk_pct")))
		def = int(def * (1.0 + SkillTreeSystem.bonus_total("def_pct")))
		matk = int(matk * (1.0 + SkillTreeSystem.bonus_total("matk_pct")))
		attack_speed *= 1.0 + SkillTreeSystem.bonus_total("aspd_pct")
		gather_bonus += SkillTreeSystem.bonus_total("gather_add")
	# RASI KELAHIRAN (A5 #91): bonus tematik KECIL (2-3%) — identitas, bukan power spike
	if not Db.rasi.is_empty() and birth_sign != "":
		max_hp = int(max_hp * (1.0 + RasiSystem.birth_bonus("hp_pct")))
		max_mp = int(max_mp * (1.0 + RasiSystem.birth_bonus("mp_pct")))
		atk = int(atk * (1.0 + RasiSystem.birth_bonus("atk_pct")))
		matk = int(matk * (1.0 + RasiSystem.birth_bonus("matk_pct")))
		def = int(def * (1.0 + RasiSystem.birth_bonus("def_pct")))
		crit_rate = clampf(crit_rate + RasiSystem.birth_bonus("crit_pct"), 0.0, 0.60)
		evasion = clampf(evasion + RasiSystem.birth_bonus("evasion_add"), 0.0, 0.45)
		drop_bonus += RasiSystem.birth_bonus("drop_add")
		gather_bonus += RasiSystem.birth_bonus("harvest_pct")
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
			# kualitas + enchant menskalakan stat gear (v0.4.2)
			total += int(round(float(Db.item(id).get(key, 0)) * gear_mult(id)))
	return total

## Pengganda stat gear dari kualitas + enchant (v0.4.2): Adikarya +10%, +3%/enchant.
func gear_mult(item_id: String) -> float:
	var m: Dictionary = gear_meta.get(item_id, {})
	var q: float = QUALITY_MULT.get(m.get("quality", "normal"), 1.0)
	return q * (1.0 + 0.03 * int(m.get("enchant", 0)))

func gear_enchant(item_id: String) -> int:
	return int(gear_meta.get(item_id, {}).get("enchant", 0))

# --- Coating senjata (v0.4.2): elemen dominan tetap, +25% elemen sekunder ---
func apply_coating(elem: String, dur_sec: float) -> void:
	coating = {"element": elem, "until": Time.get_unix_time_from_system() + dur_sec}
	EventBus.toast.emit(Loc.t("coating.applied", [elem, int(dur_sec)]))

func coating_active() -> bool:
	if coating.is_empty():
		return false
	if Time.get_unix_time_from_system() >= float(coating.get("until", 0.0)):
		coating = {}
		return false
	return true

func coating_element() -> String:
	return coating.get("element", "none") if coating_active() else "none"

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
		"atk": int(atk * buff_mult("atk_mult")), "def": def,
		"matk": int(matk * buff_mult("matk_mult")), "mdef": mdef, "spd": spd,
		"crit_rate": crit_rate, "crit_dmg": crit_dmg,
		"level": level, "hp": hp, "max_hp": max_hp,
		"element": current_weapon_element(),
		"accuracy": accuracy * StatusFx.acc_mult(self),   # Blind memotong akurasi (v0.4.1)
		"evasion": clampf(evasion + buff_add("evasion_add"), 0.0, 0.75),
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

# --- Temp buffs (class skills: war_cry, smoke_bomb — FF-2a) -------------------

func apply_buff(key: String, buff: Dictionary) -> void:
	buffs[key] = {"data": buff, "until": Time.get_ticks_msec() + int(float(buff.get("duration", 5.0)) * 1000.0)}

func _prune_buffs() -> void:
	var now := Time.get_ticks_msec()
	for k in buffs.keys().duplicate():
		if buffs[k].get("until", 0) < now:
			buffs.erase(k)

## Product of an active-buff multiplier field (e.g. "atk_mult"), 1.0 if none.
func buff_mult(field: String) -> float:
	_prune_buffs()
	var m := 1.0
	for k in buffs:
		m *= float(buffs[k].get("data", {}).get(field, 1.0))
	return m

## Sum of an active-buff additive field (e.g. "evasion_add"), 0.0 if none.
func buff_add(field: String) -> float:
	_prune_buffs()
	var s := 0.0
	for k in buffs:
		s += float(buffs[k].get("data", {}).get(field, 0.0))
	return s

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
	# Poison memotong heal 50% (sains dosis, v0.4.1)
	amount = int(amount * StatusFx.heal_mult(self))
	hp = min(max_hp, hp + amount)
	EventBus.player_hp_changed.emit(hp, max_hp)

## DoT tick pada pemain (burn/poison) — dipanggil StatusFx.tick.
func take_status_damage(dmg: int, _elem: String) -> void:
	take_damage(dmg)
	if is_dead():
		EventBus.player_died.emit()

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
		"char_name": char_name, "birth_sign": birth_sign, "playtime_sec": playtime_sec,
		"level": level, "exp": exp, "attributes": attributes, "stat_points": stat_points,
		"hp": hp, "mp": mp, "gold": gold, "inventory": inventory,
		"equipped_weapon": equipped_weapon, "equipped_armor": equipped_armor, "equipped_accessory": equipped_accessory,
		"char_class": char_class, "combat_sub": combat_sub, "advanced_class": advanced_class,
		"reputation": reputation, "faction_standing": faction_standing, "influence": influence,
		"save_schema": SAVE_SCHEMA,
		"known_skills": known_skills,
		"mastered_elements": mastered_elements, "monsters": monsters,
		"active_pet_index": active_pet_index, "homestead_plots": homestead_plots,
		"scenario_flags": scenario_flags, "titles": titles, "professions": professions,
		"achievements": achievements, "active_title": active_title, "discovered": discovered,
		"craft_insight": craft_insight, "daily_quests": daily_quests, "prof_xp": prof_xp,
		"hotbar": hotbar, "discovered_fusions": discovered_fusions,
		"fusion_fizzled_elements": fusion_fizzled_elements,
		"skill_trees": skill_trees, "gear_meta": gear_meta,
		"onboarding_seen": onboarding_seen, "guide_step": guide_step, "guide_progress": guide_progress,
		"char_config": char_config,
	}

func from_save(d: Dictionary) -> void:
	char_name = d.get("char_name", "Wanderer")
	playtime_sec = float(d.get("playtime_sec", 0.0))
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
	char_class = d.get("char_class", "warrior")
	advanced_class = d.get("advanced_class", "")
	# migrasi kosong: save lama (schema < 2) tidak punya field ini — default {}
	reputation = d.get("reputation", {})
	faction_standing = d.get("faction_standing", {})
	influence = d.get("influence", {})
	combat_sub = d.get("combat_sub", "")
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
	fusion_fizzled_elements = d.get("fusion_fizzled_elements", [])
	skill_trees = d.get("skill_trees", {})
	gear_meta = d.get("gear_meta", {})
	coating = {}           # transient — coating tak dibawa lintas-save
	char_config = d.get("char_config", CharGen.default_config())
	onboarding_seen = d.get("onboarding_seen", [])
	guide_step = int(d.get("guide_step", 0))
	guide_progress = int(d.get("guide_progress", 0))
	# BUG-9 (REPORT-06): buff & status TIDAK pernah disimpan, tapi dulu juga tak
	# direset saat load → war_cry/burn/poison dari sesi sebelumnya menempel jadi hantu.
	buffs = {}
	_softcap_told = -1
	statuses = {}
	infusion = {}          # transient — never carry over a save
	mounted = false        # never load mounted (pet may not exist)
	recalculate_stats()
	hp = d.get("hp", max_hp)
	mp = d.get("mp", max_mp)
	EventBus.player_hp_changed.emit(hp, max_hp)
	EventBus.player_mp_changed.emit(mp, max_mp)
	EventBus.gold_changed.emit(gold)
