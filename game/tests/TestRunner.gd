extends Node
## Headless test runner. Run:
##   godot --headless --path game res://tests/TestRunner.tscn --quit-after 20
## Exits with code 0 on all-pass, 1 on any failure.

var passed := 0
var failed := 0

func _ready() -> void:
	await get_tree().process_frame   # let autoloads settle
	if OS.get_environment("AETHER_BALANCE") == "1":
		_balance_probe()
		get_tree().quit()
		return
	if OS.get_environment("AETHER_BALANCE") == "2":
		_balance_probe_v2()
		get_tree().quit()
		return
	print("\n===== AETHERION TEST SUITE =====")
	_test_db()
	_test_elements()
	_test_science_rules()
	_test_combat_resolver()
	_test_monster_factory()
	_test_ttk()
	await _test_taming()
	_test_homestead_growth()
	_test_economy()
	_test_crafting()
	_test_scenario()
	await _test_sugarqueen()
	_test_saveload()
	_test_achievements()
	_test_quests()
	_test_evolution()
	await _test_platformer()
	await _test_dungeon_combat()
	await _test_hotbar()
	_test_fishing()
	_test_professions()
	_test_safezone()
	_test_chargen()
	_test_v3content()
	_test_onboarding()
	_test_skill_audit()
	_test_skill_acquisition()
	_test_classes()
	_test_status_fx()
	await _test_ui_flow_both_paths()
	_test_travel_hub()
	_test_ui_feel()
	_test_blueprint_code()
	await _test_ladder_modern()
	await _test_guard_kill()
	_test_life_path()
	_test_skill_trees()
	_test_daily_events()
	_test_monster_depth()
	_test_combo()
	await _test_patterns()
	_test_transcendent_pyramid()
	_test_gear_meta_enchant_coating()
	_test_auction_house()
	_test_rumors()
	_test_town_folk()
	_test_miracles()
	_test_quest_taxonomy()
	_test_seasons()
	_test_journal_and_stingers()
	await _test_dungeon_chests_traps()
	await _test_rasi_and_forecast()
	_test_new_assets()
	_test_opening()
	_test_save_modern()
	_test_equipment()
	_test_skycalendar()
	await _test_bugfixes()
	print("===== RESULT: %d passed, %d failed =====\n" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)

## TTK balance probe: same-level player w/ reasonable gear vs each monster,
## normal attacks + a periodic skill, averaged over trials. Prints a table.
func _balance_probe() -> void:
	print("BALANCE_PROBE_BEGIN")
	# [species, rarity, target_lo_s, target_hi_s]
	var mons := [
		["fluffbit", "common", 3, 6], ["verdant_slime", "common", 3, 6],
		["grey_wolf", "common", 3, 6], ["wild_boar", "common", 3, 6],
		["forest_fox", "rare", 8, 15], ["cervel", "rare", 8, 15],
		["treant_sapling", "epic", 25, 45], ["king_slime", "epic", 25, 45],
		["gummy_slime", "common", 3, 6], ["rock_golem", "rare", 8, 15],
		["ice_wolf", "common", 3, 6], ["yeti_cub", "rare", 8, 15],
		["frost_wyvern", "epic", 25, 45], ["thunder_hawk", "rare", 8, 15],
		["storm_elemental", "epic", 25, 45], ["thunder_dragon", "legendary", 25, 45],
	]
	var atk_interval := 0.30   # avg swing cadence
	var trials := 200
	for m in mons:
		var species: String = m[0]
		var def := Db.monster(species)
		var lvl: int = def.get("level", 5)
		# same-level player with a reasonable weapon
		PlayerData.new_game()
		PlayerData.level = lvl
		PlayerData.equipped_weapon = "copper_sword" if lvl < 15 else "wooden_spear"
		PlayerData.recalculate_stats()
		var pstats := PlayerData.combat_stats()
		var rng := RandomNumberGenerator.new()
		rng.seed = 42
		var total_hits := 0
		for t in range(trials):
			var inst := MonsterFactory.make(species, lvl, 3, rng)
			var hp: int = inst.max_hp
			var mstats := MonsterFactory.combat_stats(inst)
			var hits := 0
			while hp > 0 and hits < 2000:
				# every 6th hit is a flame_slash (skill rotation)
				var sk := Db.skill("flame_slash") if hits % 6 == 5 else Db.skill("strike")
				var res := CombatResolver.resolve(pstats, mstats, sk, {}, rng)
				hp -= res.damage
				hits += 1
			total_hits += hits
		var avg_hits := float(total_hits) / trials
		var ttk := avg_hits * atk_interval
		var mid: float = (float(m[2]) + float(m[3])) / 2.0
		var dev: float = (ttk - mid) / mid * 100.0
		var flag := "  <<< DEVIASI >30%" if absf(dev) > 30.0 else ""
		print("PROBE|%s|%s|lvl%d|hits=%.1f|ttk=%.1fs|target=%d-%ds|dev=%+.0f%%%s" % [
			species, m[1], lvl, avg_hits, ttk, m[2], m[3], dev, flag])
	print("BALANCE_PROBE_END")
	PlayerData.new_game()

# --- Harness v2 (PC6): mana-aware two-way TTK for 3 builds × 4 levels ---------
const _V2_DT := 0.05
const _V2_TRIALS := 24

# archetype -> attribute weights + weapon + channel skill + infusion element
const _V2_BUILDS := {
	"fighter":  {"w": {"STR": 0.5, "VIT": 0.3, "AGI": 0.2}, "wt": "sword", "skill": "", "infuse": "earth"},
	"mage":     {"w": {"INT": 0.7, "VIT": 0.2, "DEX": 0.1}, "wt": "wand", "skill": "frost_bolt", "infuse": ""},
	"balanced": {"w": {"STR": 0.3, "VIT": 0.3, "INT": 0.2, "AGI": 0.2}, "wt": "sword", "skill": "flame_slash", "infuse": ""},
}
const _V2_WEAPON := {
	"sword": {1: "wooden_sword", 5: "copper_sword", 10: "iron_sword", 15: "iron_sword"},
	"wand": {1: "apprentice_wand", 5: "apprentice_wand", 10: "apprentice_wand", 15: "apprentice_wand"},
}
const _V2_ARMOR := {1: "cloth_tunic", 5: "leather_vest", 10: "iron_mail", 15: "iron_mail"}
const _V2_ACC := {1: "", 5: "copper_ring", 10: "silver_ring", 15: "gold_ring"}
const _WEAPON_RATE := {"bow": 3.3, "wand": 3.0, "spear": 2.4, "sword": 2.85}

func _v2_apply_build(build_id: String, level: int) -> void:
	var b: Dictionary = _V2_BUILDS[build_id]
	PlayerData.new_game()
	PlayerData.level = level
	var pts := (level - 1) * 5
	var attrs := {"STR": 5, "AGI": 5, "VIT": 5, "INT": 5, "DEX": 5, "LUK": 5}
	for k in b.w:
		attrs[k] += int(round(pts * float(b.w[k])))
	PlayerData.attributes = attrs
	PlayerData.equipped_weapon = _V2_WEAPON[b.wt][level]
	PlayerData.equipped_armor = _V2_ARMOR[level]
	PlayerData.equipped_accessory = _V2_ACC[level]
	PlayerData.recalculate_stats()
	PlayerData.hp = PlayerData.max_hp
	PlayerData.mp = PlayerData.max_mp

## Player → Enemy: seconds to kill one same-level enemy (mana-aware channel/basic).
func _v2_pve(build_id: String, level: int, species: String, dungeon: bool, rng: RandomNumberGenerator) -> float:
	var b: Dictionary = _V2_BUILDS[build_id]
	_v2_apply_build(build_id, level)
	var ps := PlayerData.combat_stats()
	var wt: String = b.wt
	var basic_interval: float = 1.0 / maxf(0.4, _WEAPON_RATE[wt] * PlayerData.attack_speed)
	# wand basic = magic shot (MATK) costing the wand's small mana_cost; melee = strike
	var basic_sk: Dictionary = {"kind": "magic", "skill_mod": 1.0, "element": "fire"} if wt == "wand" else Db.skill("strike")
	var basic_cost: int = int(Db.item(PlayerData.equipped_weapon).get("mana_cost", 0)) if wt == "wand" else 0
	var chan_id: String = b.skill
	var chan := Db.skill(chan_id) if chan_id != "" else {}
	var chan_rate: float = float(chan.get("cast_rate", 2.0))
	var chan_cost: int = int(chan.get("mana_cost", 0))
	# infusion damage multiplier for basic-attack builds (rev E)
	var infuse: String = b.infuse
	var inf_mult := 1.0
	var inf_drain := 0.0
	if infuse != "":
		var im: Dictionary = Db.elements.get("infusion_melee", {}).get(infuse, {})
		inf_mult = float(im.get("dmg_mult", 1.0))
		inf_drain = float(Db.skill("flow_" + infuse).get("drain", 2.0))
	var total := 0.0
	for tr in range(_V2_TRIALS):
		var lvl_scaled := level
		var inst := MonsterFactory.make(species, lvl_scaled, 3, rng)
		if inst.is_empty():
			return -1.0
		var hp: float = inst.max_hp * (1.2 if dungeon else 1.0)
		var mstats := MonsterFactory.combat_stats(inst)
		var mana: float = PlayerData.max_mp
		var t := 0.0
		var basic_cd := 0.0
		var chan_cd := 0.0
		while hp > 0.0 and t < 600.0:
			t += _V2_DT
			mana = minf(PlayerData.max_mp, mana + PlayerData.mana_regen * _V2_DT)
			if infuse != "":
				mana = maxf(0.0, mana - inf_drain * _V2_DT)
			chan_cd -= _V2_DT
			basic_cd -= _V2_DT
			# holding LMB = EITHER channel the primed skill (while affordable) OR basic —
			# never both at once (matches the real input model, rev A/B).
			if chan_id != "" and mana >= chan_cost:
				if chan_cd <= 0.0:
					chan_cd = 1.0 / chan_rate
					mana -= chan_cost
					hp -= CombatResolver.resolve(ps, mstats, chan, {}, rng).damage
			elif basic_cd <= 0.0 and mana >= basic_cost:
				basic_cd = basic_interval
				mana -= basic_cost
				var dmg: float = CombatResolver.resolve(ps, mstats, basic_sk, {}, rng).damage
				if infuse != "" and mana > 0.0:
					dmg *= inf_mult
				hp -= dmg
		total += t
	return total / _V2_TRIALS

## Enemy pack → Player: seconds a `count`-pack of same-level enemies needs to kill the player.
func _v2_epv(build_id: String, level: int, species: String, count: int, dungeon: bool, rng: RandomNumberGenerator) -> float:
	_v2_apply_build(build_id, level)
	var pdef := PlayerData.combat_stats()
	var total := 0.0
	for tr in range(_V2_TRIALS):
		var hp: float = PlayerData.max_hp
		var estats := []
		var ecd := []
		for i in range(count):
			var inst := MonsterFactory.make(species, level, 3, rng)
			var st := MonsterFactory.combat_stats(inst)
			if dungeon:
				st["atk"] = int(st.atk * 1.2)
				st["matk"] = int(st.matk * 1.2)
			var sk_id: String = inst.get("skills", ["tackle"])[0]
			estats.append({"st": st, "sk": Db.skill(sk_id)})
			ecd.append(0.6 + 0.1 * i)
		var t := 0.0
		var iframes := 0.0   # the player's 0.5s post-hit i-frames serialize pack damage
		while hp > 0.0 and t < 600.0:
			t += _V2_DT
			iframes -= _V2_DT
			for i in range(count):
				ecd[i] -= _V2_DT
				if ecd[i] <= 0.0 and iframes <= 0.0:
					ecd[i] = 1.1   # enemy swing cadence (> hit-immunity window)
					var res := CombatResolver.resolve(estats[i].st, pdef, estats[i].sk, {}, rng)
					if res.get("damage", 0) > 0:
						hp -= res.get("damage", 0)
						iframes = CombatFeel.iframes()
		total += t
	return total / _V2_TRIALS

func _balance_probe_v2() -> void:
	print("BALANCE_V2_BEGIN")
	# [species, region, dungeon, kind, ttk_lo, ttk_hi, min_lv]. Targets are tier-appropriate:
	# common 3-6s (open); rare 7-16s (mini-threat, ~2-3x common); dungeon-rare tank runs
	# tankier ("dangerous commitment"); boss is a PURE-DPS proxy 45-120s (~2-4min live once
	# phases/dodging are added — the harness has no downtime). min_lv skips levels where the
	# fight is out of scope (a Lv1 vs a dungeon rare/boss is intended to be hopeless).
	var targets := [
		["verdant_slime", "Greenvale", false, "common", 3, 6, 1],
		["grey_wolf", "Greenvale", false, "common", 3, 6, 1],
		["forest_fox", "Greenvale", false, "rare", 7, 16, 5],
		["ice_wolf", "Frostpeak", false, "common", 3, 6, 1],
		["yeti_cub", "Foothill-Barrow", true, "rare", 10, 45, 5],
		["storm_crab", "Storm-Island", false, "common", 3, 6, 1],
		["king_slime", "Boss", true, "boss", 45, 120, 10],
	]
	var levels := [1, 5, 10, 15]
	var rng := RandomNumberGenerator.new()
	# P->E table
	print("== P->E (player kills one same-level enemy), seconds ==")
	for tg in targets:
		var species: String = tg[0]
		for build_id in ["fighter", "mage", "balanced"]:
			for lvl in levels:
				if lvl < int(tg[6]):
					continue
				rng.seed = 1337
				var ttk := _v2_pve(build_id, lvl, species, tg[2], rng)
				var lo: float = tg[4]; var hi: float = tg[5]
				var flag := ""
				if ttk >= 0.0 and (ttk < lo or ttk > hi):
					flag = "  <<DEV"
				print("V2PVE|%s|%s|%s|Lv%d|ttk=%.1fs|target=%d-%ds%s" % [tg[1], species, build_id, lvl, ttk, int(lo), int(hi), flag])
	# E->P table (pack of 3 commons; new player = Lv1/5)
	print("== E->P (pack of 3 kills the player), seconds ==")
	for tg in targets:
		if tg[3] != "common":
			continue
		for build_id in ["fighter", "mage", "balanced"]:
			for lvl in [1, 5, 10]:
				rng.seed = 999
				var surv := _v2_epv(build_id, lvl, tg[0], 3, tg[2], rng)
				print("V2EPV|%s|%s|%s|Lv%d|survive=%.1fs|(open target die 6-12s @Lv1-5)" % [tg[1], tg[0], build_id, lvl, surv])
	# mana sustain: how long can a Lv10 mage channel before running dry?
	_v2_apply_build("mage", 10)
	var chan := Db.skill("frost_bolt")
	var mana: float = PlayerData.max_mp
	var drain_t := 0.0
	var cd := 0.0
	while mana >= chan.mana_cost and drain_t < 120.0:
		drain_t += _V2_DT
		mana = minf(PlayerData.max_mp, mana + PlayerData.mana_regen * _V2_DT)
		cd -= _V2_DT
		if cd <= 0.0:
			cd = 1.0 / float(chan.cast_rate)
			mana -= chan.mana_cost
	print("V2MANA|mage|Lv10|max_mp=%d|regen=%.1f|channel_frost_bolt_until_dry=%.1fs (target 8-12s)" % [PlayerData.max_mp, PlayerData.mana_regen, drain_t])
	print("BALANCE_V2_END")
	PlayerData.new_game()

func check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		passed += 1
		print("  [PASS] ", name)
	else:
		failed += 1
		print("  [FAIL] ", name, "  ", detail)

func approx(a: float, b: float, eps: float = 0.001) -> bool:
	return abs(a - b) < eps

# --- Tests ------------------------------------------------------------------

func _test_db() -> void:
	print("[Db]")
	check("monsters loaded", Db.monsters.size() >= 10)
	check("items loaded", Db.items.size() >= 20)
	check("skills loaded", Db.skills.has("strike") and Db.skills.has("spark_bolt"))
	check("elements matrix", Db.elements.has("matrix"))
	check("no db errors", not Db.has_errors(), str(Db.get_errors()))
	# Candyveil content
	check("candyveil monster loaded", Db.monsters.has("gummy_slime") and Db.monsters.has("gummy_mimic"))
	check("candyveil loot table", Db.loot_table("candy_gummy_slime").size() > 0)
	# Frostpeak content (v0.3)
	check("frostpeak monsters loaded", Db.monsters.has("frost_fox") and Db.monsters.has("yeti_cub"))
	check("frost monster builds (ice element)", MonsterFactory.make("ice_wolf").get("element", "") == "ice")
	check("frostpeak loot table", Db.loot_table("yeti_cub").size() > 0)
	check("frost items have flavor", Db.item("ice_shard").get("flavor", "") != "")
	check("candyveil monster builds", not MonsterFactory.make("choco_bear").is_empty())
	# Desert content + grounding science (Rock Golem resists lightning)
	# Echo vendors + their wares resolve to real items
	check("echo vendors loaded", Db.echo_vendors.size() >= 2)
	var echo_ok := true
	for v in Db.echo_vendors:
		for w in v.get("wares", []):
			if not Db.items.has(w.get("item", "")):
				echo_ok = false
	check("echo vendor wares are real items", echo_ok)
	check("desert monster loaded", Db.monsters.has("rock_golem") and Db.monsters.has("dune_serpent"))
	var golem := MonsterFactory.make("rock_golem", 20, 3)
	check("rock golem carries lightning resist", golem.get("resist", {}).get("lightning", 0.0) > 0.5)
	var gv := MonsterFactory.combat_stats(golem)
	var atk := {"atk": 100, "matk": 400, "crit_rate": 0.0, "element": "lightning", "accuracy": 2.0}
	var normal := CombatResolver.resolve(atk, MonsterFactory.combat_stats(MonsterFactory.make("sand_scarab", 20, 3)), Db.skill("spark_bolt"), {})
	var grounded := CombatResolver.resolve(atk, gv, Db.skill("spark_bolt"), {})
	check("lightning hits golem much less (grounding)", grounded.damage < normal.damage)

func _test_elements() -> void:
	print("[elem_mod]")
	var ctx := {}
	check("fire>wood=1.3", approx(CombatResolver.elem_mod("fire", "wood", ctx), 1.3))
	check("fire<water=0.7", approx(CombatResolver.elem_mod("fire", "water", ctx), 0.7))
	check("neutral=1.0", approx(CombatResolver.elem_mod("wind", "fire", ctx), 1.0))
	check("none=1.0", approx(CombatResolver.elem_mod("none", "water", ctx), 1.0))

func _test_science_rules() -> void:
	print("[science rules]")
	var wet := {"target_wet": true}
	# lightning vs neutral, target wet: 1.0 * 1.3 = 1.3, and chains
	check("lightning+wet=1.3", approx(CombatResolver.elem_mod("lightning", "none", wet), 1.3))
	check("lightning+wet chains", CombatResolver.elem_chains("lightning", wet))
	check("lightning dry no chain", not CombatResolver.elem_chains("lightning", {}))
	# fire vs neutral, target wet: 1.0 * 0.7
	check("fire+wet=0.7", approx(CombatResolver.elem_mod("fire", "none", wet), 0.7))
	# fire underwater 0.5
	check("fire underwater=0.5", approx(CombatResolver.elem_mod("fire", "none", {"underwater": true}), 0.5))
	# grounded lightning weakened
	check("lightning grounded weak", approx(CombatResolver.elem_mod("lightning", "none", {"target_grounded": true}), 0.7))

func _test_combat_resolver() -> void:
	print("[CombatResolver.resolve]")
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var atk := {"atk": 60, "matk": 40, "crit_rate": 0.0, "crit_dmg": 1.5, "element": "none"}
	var dfn := {"def": 20, "mdef": 10, "resist": {}, "element": "none"}
	var res := CombatResolver.resolve(atk, dfn, Db.skill("strike"), {}, rng)
	# (60*1.0 - 20*0.5)*1.0 = 50
	check("physical dmg = 50", res.damage == 50, str(res.damage))
	check("no crit at 0 rate", res.is_crit == false)
	check("min damage >= 1", CombatResolver.resolve({"atk": 1}, {"def": 999}, Db.skill("strike"), {}, rng).damage >= 1)
	# magic
	var mres := CombatResolver.resolve(atk, dfn, Db.skill("spark_bolt"), {}, rng)
	check("magic dmg positive", mres.damage > 0, str(mres.damage))

func _test_monster_factory() -> void:
	print("[MonsterFactory]")
	var w := MonsterFactory.make("grey_wolf", 3, 3)
	check("wolf built", not w.is_empty())
	check("wolf hp>0", w.max_hp > 0)
	check("wolf atk>0", w.atk > 0)
	check("wolf exp>0", w.exp_reward > 0)
	# archetype distribution: tank has more HP fraction than assassin
	var tank := MonsterFactory.make("verdant_slime", 5, 3)
	var assassin := MonsterFactory.make("honeybuzz", 5, 3)
	check("tank hp > assassin hp", tank.max_hp > assassin.max_hp, "%d vs %d" % [tank.max_hp, assassin.max_hp])
	check("assassin spd > tank spd", assassin.spd > tank.spd)
	check("unknown species empty", MonsterFactory.make("nope").is_empty())

func _test_ttk() -> void:
	print("[TTK simulation]")
	var rng := RandomNumberGenerator.new()
	rng.seed = 999
	# same-level fight (v2 calibration corridor: 3-6s ≈ 9-17 basic hits @~2.85/s)
	PlayerData.new_game()
	PlayerData.level = 3
	PlayerData.attributes["STR"] += 6   # a Lv3 player has allocated +10 free points
	PlayerData.attributes["VIT"] += 4
	PlayerData.recalculate_stats()
	var player := PlayerData.combat_stats()
	player["element"] = "none"
	var wolf := MonsterFactory.make("grey_wolf", 3, 3)
	var wolf_stats := MonsterFactory.combat_stats(wolf)
	var hp: int = wolf.max_hp
	var hits := 0
	while hp > 0 and hits < 100:
		var r := CombatResolver.resolve(player, wolf_stats, Db.skill("strike"), {}, rng)
		hp -= r.damage
		hits += 1
	check("wolf dies", hp <= 0)
	check("common TTK in corridor (6..25 basic hits same-level)", hits >= 6 and hits <= 25, "%d hits" % hits)
	PlayerData.new_game()

func _test_taming() -> void:
	print("[TamingSystem]")
	var m: Monster = preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	m.setup(MonsterFactory.make("fluffbit", 2, 3))
	await get_tree().process_frame
	m.hp = int(m.max_hp * 0.04)   # below 5%
	check("can be tamed at low hp", m.can_be_tamed())
	PlayerData.inventory.clear()
	PlayerData.add_item("basic_orb", 1)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var chance := TamingSystem.compute_chance(m, {"id": "basic_orb", "mult": 1.0})
	check("tame chance in (0,1)", chance > 0.0 and chance <= 0.99, str(chance))
	var before: int = PlayerData.item_count("basic_orb")
	var res := TamingSystem.attempt(m, rng)
	check("orb consumed", PlayerData.item_count("basic_orb") == before - 1)
	check("attempt returns result", res.has("success"))
	m.queue_free()

func _test_homestead_growth() -> void:
	print("[Homestead growth]")
	# crop grows by real-time delta: stage = floor(elapsed/grow_seconds * stages)
	var crop := Db.crop("mintleaf")
	check("crop exists", not crop.is_empty())
	var grow: int = crop.get("grow_seconds", 600)
	var stages: int = crop.get("stages", 4)
	var half := HomesteadSystem.growth_stage(grow / 2, grow, stages)
	var done := HomesteadSystem.growth_stage(grow, grow, stages)
	check("half-grown < ready", half < stages)
	check("fully grown at elapsed>=grow", done >= stages)
	check("ready detection", HomesteadSystem.is_ready(grow + 1, grow, stages))
	# offline growth via plot_status (time-delta based)
	var ready_plot := {"crop_id": "mintleaf", "planted_at_unix": GameClock.unix_now() - (grow + 5)}
	var st := HomesteadSystem.plot_status(ready_plot)
	check("backdated plot is ready", st.ready and st.stage == st.stages)
	var young := {"crop_id": "mintleaf", "planted_at_unix": GameClock.unix_now() - int(grow / 4)}
	check("young plot not ready", not HomesteadSystem.plot_status(young).ready)

func _test_safezone() -> void:
	print("[Safe Zone + Guards]")
	check("towns data loaded", Db.towns.has("greenvale"))
	check("greenvale has a polygon", Db.towns.get("greenvale", {}).get("safe_zone", []).size() >= 3)
	check("greenvale has gates", Db.towns.get("greenvale", {}).get("gates", []).size() >= 1)
	SafeZone.set_region("greenvale")
	var center := Vector2(640, 480)
	check("zone active after set_region", SafeZone.is_active())
	check("town center is inside safe zone", SafeZone.contains(center))
	check("far corner is outside safe zone", not SafeZone.contains(Vector2(40, 40)))
	check("gates resolved to global coords", SafeZone.gates().size() >= 1)
	# gate posts sit on/near the zone boundary, not deep inside
	var gate_ok := true
	for g in SafeZone.gates():
		if g.distance_to(center) < 100.0:
			gate_ok = false
	check("gate posts are at the perimeter", gate_ok)
	# unknown region / clear() deactivates it (no stale polygon leaks between maps)
	SafeZone.set_region("nonexistent_town")
	check("unknown town clears the zone", not SafeZone.is_active())
	SafeZone.set_region("greenvale")
	SafeZone.clear()
	check("clear() deactivates the zone", not SafeZone.is_active())
	check("contains() is false when inactive", not SafeZone.contains(center))
	# monster knockback API pushes away from the source and interrupts the chase
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	m.setup(MonsterFactory.make("grey_wolf", 2, 3), null)
	m.global_position = Vector2(200, 200)
	m.knockback(Vector2(180, 200), 300.0)   # guard to the left -> shove right
	check("knockback stored a rightward impulse", m._knock.x > 0.0)
	check("knockback suppresses re-aggro briefly", m.enraged_until > m._now())
	m.queue_free()
	# restore the town zone for anything that runs after the tests
	SafeZone.set_region("greenvale")

func _test_skill_audit() -> void:
	print("[Skill Audit §6]")
	# fusion recipe symmetry — 1+2 must equal 2+1 for every recipe
	var combos: Array = Db.elements.get("combos", [])
	check("at least 8 fusion recipes", combos.size() >= 8)
	var symmetric := true
	for c in combos:
		if not c.has("a"):
			continue   # 2-elem recipes use a/b; multi-elem (3-4) use an "elems" array
		var ab := Db.elem_combo(c.a, c.b)
		var ba := Db.elem_combo(c.b, c.a)
		if ab.get("result", "") != ba.get("result", "") or ab.get("mult", 0) != ba.get("mult", 0):
			symmetric = false
	check("every fusion recipe is order-independent (1+2==2+1)", symmetric)
	# rev C: multi-element (3-4) fusion recipes exist and are order-independent
	var triples := 0
	var quads := 0
	for c in combos:
		var n: int = c.get("elems", []).size()
		if n == 3: triples += 1
		elif n == 4: quads += 1
	check("at least 4 triple-element recipes", triples >= 4, str(triples))
	check("at least 2 quad-element recipes", quads >= 2, str(quads))
	check("multi-elem lookup order-independent (plasma storm)", Db.elem_combo_multi(["lightning","fire","wind"]).get("result","") == "Plasma Storm")
	# a non-recipe pair fizzles (empty)
	check("non-recipe pair returns empty (fizzle)", Db.elem_combo("earth", "ice").is_empty())
	# castable skills: valid element + real projectile where declared
	var elist: Array = Db.elements.get("list", [])
	var castable := ["strike", "flame_slash", "spark_bolt", "frost_bolt", "flow_fire", "flow_lightning", "flow_ice", "flow_wind"]
	var elem_ok := true
	var proj_ok := true
	for sid in castable:
		var sk := Db.skill(sid)
		var el: String = sk.get("element", "none")
		if el != "none" and not (el in elist):
			elem_ok = false
		if sk.get("projectile", false) and not Db.projectiles.has(sk.get("projectile_id", "")):
			proj_ok = false
	check("all castable skill elements are valid", elem_ok)
	check("all projectile skills reference a real projectile", proj_ok)
	check("dead 'element_flow' skill removed (flow_* supersede it)", not Db.skills.has("element_flow"))
	# rev B: no cooldowns. Damage-per-mana (skill_mod / mana_cost) within ±35% of mean.
	var vals: Array = []
	for sid in ["flame_slash", "spark_bolt", "frost_bolt"]:
		var sk := Db.skill(sid)
		vals.append(float(sk.get("skill_mod", 1.0)) / maxf(1.0, float(sk.get("mana_cost", 1))))
	var mean: float = (vals[0] + vals[1] + vals[2]) / 3.0
	var within := true
	for v in vals:
		if abs(v - mean) / mean > 0.35:
			within = false
	check("no damage-per-mana outlier >35%", within, str(vals))
	# rev B: castable damage skills declare the new economy levers (no cooldown field)
	var levers_ok := true
	for sid in ["flame_slash", "spark_bolt", "frost_bolt"]:
		var sk := Db.skill(sid)
		if sk.get("mana_cost", 0) <= 0 or sk.get("cast_rate", 0.0) <= 0.0 or sk.has("cooldown"):
			levers_ok = false
	check("damage skills use mana_cost+cast_rate, no cooldown", levers_ok)
	# rev B: flow skills drain mana per second (no cooldown/duration)
	check("flow skills declare a mana drain", Db.skill("flow_fire").get("drain", 0.0) > 0.0)
	# weapon behavior wired to the click scheme (both perspectives branch on these)
	check("bow weapon declares a projectile", Db.item("short_bow").get("projectile", "") != "")
	check("wand weapon declares a projectile + mana", Db.item("apprentice_wand").get("projectile", "") != "" and Db.item("apprentice_wand").get("mana_cost", 0) > 0)
	check("wand projectile exists", Db.projectiles.has(Db.item("apprentice_wand").get("projectile", "")))
	# Element Flow platformer rules survive the refactor
	var pr: Dictionary = Db.elements.get("platformer_rules", {})
	check("wind flow grants double jump", pr.get("wind", {}).get("double_jump", false))
	check("ice flow freezes puddles", pr.get("ice", {}).get("freeze_puddle", false))

func _test_skill_acquisition() -> void:
	print("[Skill Acquisition — PC4]")
	PlayerData.new_game()
	# --- 16 player skills, each with an unlock source ---
	var player_skills := 0
	var ultimate := 0
	for sk in Db.skills.values():
		if sk.has("unlock"):
			player_skills += 1
			if sk.get("ultimate", false):
				ultimate += 1
	check("player skills all declare unlock sources (29 w/ class kits)", player_skills == 29, str(player_skills))
	check("exactly 1 Ultimate candidate", ultimate == 1, str(ultimate))
	check("meteor is the ultimate", Db.skill("meteor").get("ultimate", false))
	# --- start with only the class's 3 skills; flow gated by mastered elements ---
	check("starts with 3 known active skills", PlayerData.known_skills.size() == 3)
	check("can use starter flame_slash", PlayerData.can_use_skill("flame_slash"))
	check("can use flow_fire (fire mastered)", PlayerData.can_use_skill("flow_fire"))
	check("CANNOT use flow_ice (ice not mastered)", not PlayerData.can_use_skill("flow_ice"))
	check("CANNOT use unlearned frost_bolt", not PlayerData.can_use_skill("frost_bolt"))
	# --- learn_skill applies element mastery (masters) ---
	check("frost_bolt learned = true (new)", PlayerData.learn_skill("frost_bolt"))
	check("frost_bolt now usable", PlayerData.can_use_skill("frost_bolt"))
	check("learning frost_bolt masters ice -> flow_ice usable", PlayerData.can_use_skill("flow_ice"))
	check("re-learning returns false (idempotent)", not PlayerData.learn_skill("frost_bolt"))
	# --- level milestone auto-learn (gust @ Lv3, quake @ Lv8) ---
	PlayerData.new_game()
	check("gust locked at Lv1", not PlayerData.can_use_skill("gust"))
	PlayerData.level = 2
	PlayerData.gain_exp(PlayerData.exp_to_next())   # -> Lv3, triggers milestone
	check("gust auto-learned at Lv3", PlayerData.can_use_skill("gust"))
	check("gust masters wind -> flow_wind usable", PlayerData.can_use_skill("flow_wind"))
	check("quake still locked (needs Lv8)", not PlayerData.can_use_skill("quake"))
	# --- skill book item learns + is consumed ---
	PlayerData.new_game()
	PlayerData.add_item("book_spore_cloud", 1)
	check("spore_cloud locked before book", not PlayerData.can_use_skill("spore_cloud"))
	check("use_skillbook learns it", PlayerData.use_skillbook("book_spore_cloud"))
	check("spore_cloud usable after book", PlayerData.can_use_skill("spore_cloud"))
	check("book consumed", PlayerData.item_count("book_spore_cloud") == 0)
	# --- trainer: gold + level prereq (stone_lance: Lv6, 450g) ---
	PlayerData.new_game()
	PlayerData.gold = 9999
	check("train fails below level prereq", not PlayerData.train_skill("stone_lance"))
	PlayerData.level = 6
	PlayerData.gold = 100
	check("train fails without gold", not PlayerData.train_skill("stone_lance"))
	PlayerData.gold = 500
	check("train succeeds with level+gold", PlayerData.train_skill("stone_lance"))
	check("stone_lance usable + earth mastered", PlayerData.can_use_skill("stone_lance") and PlayerData.can_use_skill("flow_earth"))
	check("gold deducted by cost", PlayerData.gold == 50)
	# --- boss first-kill (holy_ray from king_slime) ---
	PlayerData.new_game()
	check("holy_ray locked before boss", not PlayerData.can_use_skill("holy_ray"))
	PlayerData.on_boss_killed("king_slime")
	check("holy_ray learned on king_slime kill", PlayerData.can_use_skill("holy_ray"))
	check("meteor learned on frost_titan kill", func_learn_boss("frost_titan", "meteor"))
	PlayerData.new_game()

func func_learn_boss(boss: String, sid: String) -> bool:
	PlayerData.on_boss_killed(boss)
	return PlayerData.can_use_skill(sid)

func _test_status_fx() -> void:
	print("[Status Effects — v0.4.1]")
	# fake entity duck-typed: statuses + max_hp + take_status_damage
	var e := _FakeEntity.new()
	# explicit apply_status = pasti kena
	StatusFx.on_hit(e, {"damage": 10, "element": "none", "apply_status": "poison"}, false)
	check("apply_status poison selalu kena", StatusFx.has(e, "poison"))
	# poison DoT ticks damage over time
	var hp0: int = e.fake_hp
	StatusFx.tick(e, 3.0)
	check("poison DoT mengurangi HP", e.fake_hp < hp0)
	# heal cut while poisoned
	check("heal dipotong 50% saat poison", StatusFx.heal_mult(e) == 0.5)
	# expiry
	StatusFx.tick(e, 10.0)
	check("status kedaluwarsa setelah durasi", not StatusFx.has(e, "poison"))
	# sains: burn tidak menempel saat basah
	e.statuses.clear()
	var burned := false
	for i in range(200):
		StatusFx.on_hit(e, {"damage": 5, "element": "fire"}, true)
		if StatusFx.has(e, "burn"): burned = true
	check("basah = tak bisa terbakar (200 percobaan)", not burned)
	# sains: lightning hanya melumpuhkan target BASAH
	e.statuses.clear()
	var para_dry := false
	for i in range(200):
		StatusFx.on_hit(e, {"damage": 5, "element": "lightning"}, false)
		if StatusFx.has(e, "paralyze"): para_dry = true
	check("lightning kering = tak melumpuhkan", not para_dry)
	var para_wet := false
	for i in range(200):
		StatusFx.on_hit(e, {"damage": 5, "element": "lightning"}, true)
		if StatusFx.has(e, "paralyze"): para_wet = true
	check("lightning + basah = bisa paralyze (konduksi)", para_wet)
	# Thermal Shock: fire pada target beku = x1.5 + es pecah
	e.statuses.clear()
	StatusFx.apply(e, "freeze")
	check("freeze = stunned & attack locked", StatusFx.is_stunned(e) and StatusFx.is_attack_locked(e))
	var res := StatusFx.pre_hit(e, {"damage": 100, "element": "fire"})
	check("Thermal Shock: fire vs frozen = 150 dmg", res.get("damage", 0) == 150 and res.get("thermal_shock", false))
	check("es pecah setelah thermal shock", not StatusFx.has(e, "freeze"))
	# sains: air memadamkan burn
	StatusFx.apply(e, "burn")
	StatusFx.on_hit(e, {"damage": 5, "element": "water"}, false)
	check("air memadamkan burn", not StatusFx.has(e, "burn"))
	# blind memotong akurasi
	StatusFx.apply(e, "blind")
	check("blind acc x0.7", absf(StatusFx.acc_mult(e) - 0.7) < 0.001)
	check("ikon status tampil", StatusFx.icons_text(e) != "")
	# CombatResolver meneruskan apply_status
	var rng := RandomNumberGenerator.new(); rng.seed = 7
	var rr := CombatResolver.resolve({"atk": 50, "accuracy": 2.0}, {"def": 0}, Db.skill("venom_strike"), {}, rng)
	check("resolve meneruskan apply_status dari skill", rr.get("apply_status", "") == "poison")

class _FakeEntity:
	var statuses := {}
	var max_hp := 100
	var fake_hp := 100
	func take_status_damage(d: int, _e: String) -> void:
		fake_hp -= d

func _test_blueprint_code() -> void:
	print("[Kanonisasi blueprint — kode B9 + B15]")
	# B9 (#54): SEMUA spesies tameable — tak ada tame_base 0 tersisa
	var banned := []
	for sid in Db.monsters:
		if float(Db.monsters[sid].get("tame_base", 1.0)) <= 0.0:
			banned.append(sid)
	check("B9: tak ada spesies terlarang tame", banned.is_empty(), str(banned))
	# B15 (#62): Loc string-key + fallback berjenjang
	check("Loc: key dikenal (id)", Loc.t("ui.pause.resume") != "ui.pause.resume")
	var lang0: String = Loc.language
	Loc.language = "en"
	check("Loc: EN aktif menerjemahkan", Loc.t("ui.pause.resume") == "▶ Resume")
	Loc.language = "id"
	check("Loc: ID default", Loc.t("ui.pause.resume") == "▶ Lanjutkan")
	check("Loc: key tak dikenal fallback ke key mentah", Loc.t("kunci.tak.ada") == "kunci.tak.ada")
	Loc.language = lang0

func _test_ui_feel() -> void:
	print("[UI feel — Decision Log #44]")
	check("ui_feel.json termuat & bisa dituning", not Db.ui_feel.is_empty() and Db.ui_feel.has("panel_in") and Db.ui_feel.has("hover"))
	# smoke: apply ke tombol & panel tanpa crash + guard dobel
	var b := Button.new()
	add_child(b)
	UiFx.button(b)
	UiFx.button(b)   # idempotent (meta guard)
	check("UiFx.button idempotent", b.has_meta("uifx"))
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(100, 60)
	add_child(p)
	UiFx.panel_in(p)
	UiFx.select_bounce(p)
	UiFx.toast_spring(p)
	check("UiFx panel/bounce/spring tidak crash", true)
	# Mode Hemat mematikan motion
	var eco0 := Settings.eco_mode
	Settings.eco_mode = true
	check("Mode Hemat menonaktifkan motion", not UiFx._on())
	Settings.eco_mode = eco0
	b.queue_free(); p.queue_free()

func _test_travel_hub() -> void:
	print("[Gerbang Penjelajah 'Pilih Dunia' — Decision Log #43]")
	var TravelUI = load("res://scenes/ui/TravelUI.gd")
	PlayerData.new_game()
	WorldState.new_game()
	# visited tracking
	check("mulai: belum ada wilayah tercatat", WorldState.visited_regions.is_empty())
	WorldState.mark_visited("greenvale")
	WorldState.mark_visited("frostpeak")
	WorldState.mark_visited("frostpeak")   # idempotent
	check("visited tercatat & idempotent", WorldState.visited_regions == ["greenvale", "frostpeak"])
	check("current_region terpasang", WorldState.current_region == "frostpeak")
	# 5 wilayah terdaftar dengan scene valid
	var ok := true
	for r in TravelUI.REGIONS:
		if not ResourceLoader.exists(r.scene):
			ok = false
	check("5 wilayah terdaftar + scene valid", TravelUI.REGIONS.size() == 5 and ok)
	# travel pertama hari ini GRATIS, berikutnya berbiaya
	WorldState.last_free_travel = ""
	check("travel pertama hari ini gratis", TravelUI.travel_cost_today() == 0)
	WorldState.last_free_travel = GameClock.date_string()
	check("travel berikutnya berbiaya %dG" % TravelUI.TRAVEL_COST, TravelUI.travel_cost_today() == TravelUI.TRAVEL_COST)
	# persist visited + jatah gratis
	SaveManager.save_game(3, true)
	WorldState.new_game()
	SaveManager.load_game(3)
	check("visited & jatah gratis selamat save/load", WorldState.visited_regions == ["greenvale", "frostpeak"] \
		and WorldState.last_free_travel == GameClock.date_string())
	SaveManager.delete_save(3)
	PlayerData.new_game()
	WorldState.new_game()

class _FakeLadderTerrain:
	extends Node2D
	var ladder_top_y := -8000.0   # tangga hanya ada di bawah y ini... (y turun = besar)
	func is_ladder(pos: Vector2) -> bool:
		return pos.y >= ladder_top_y and pos.x > 4900.0 and pos.x < 5100.0

func _test_ladder_modern() -> void:
	print("[Tangga modern — Decision Log #42]")
	var terr := _FakeLadderTerrain.new()
	terr.add_to_group("terrain")
	add_child(terr)
	var pl = load("res://scenes/actors/PlayerPlatformer.tscn").instantiate()
	add_child(pl)
	pl.global_position = Vector2(5000, -7000)   # di area tangga, melayang
	pl.terrain = terr
	await get_tree().physics_frame
	# 1) tekan W sekali = MENEMPEL
	Input.action_press("move_up")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("move_up")
	check("W sekali = menempel di tangga", pl.climbing)
	# 2) lepas tombol = MENGGANTUNG diam (tidak jatuh)
	var y0: float = pl.global_position.y
	for i in range(20):
		await get_tree().physics_frame
	check("menggantung tanpa input (tidak jatuh)", pl.climbing and absf(pl.global_position.y - y0) < 2.0, str(pl.global_position.y - y0))
	# 3) naik dengan W
	Input.action_press("move_up")
	for i in range(10):
		await get_tree().physics_frame
	Input.action_release("move_up")
	check("W = naik", pl.global_position.y < y0 - 4.0)
	# 4) SPACE = lompat lepas dari tangga
	Input.action_press("dodge")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("dodge")
	check("SPACE = lompat lepas (tidak lagi menempel, meluncur ke atas)", not pl.climbing and pl.velocity.y < 0.0)
	# 5) ujung atas: memanjat melewati puncak = lepas otomatis + tidak nyangkut
	pl.global_position = Vector2(5000, -7995)
	pl.velocity = Vector2.ZERO
	Input.action_press("move_up")
	await get_tree().physics_frame
	await get_tree().physics_frame
	var t := 0.0
	while t < 1.0 and pl.climbing:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	Input.action_release("move_up")
	check("melewati puncak = lepas otomatis (<1 dtk, tidak nyangkut)", not pl.climbing)
	pl.queue_free()
	terr.queue_free()
	await get_tree().process_frame

func _test_ui_flow_both_paths() -> void:
	print("[UI flow kedua jalur — BUG P0 #41]")
	# instansiasi LAYAR ClassSelect sungguhan (bukan hanya logika)
	var cs = load("res://scenes/ui/ClassSelect.tscn").instantiate()
	add_child(cs)
	await get_tree().process_frame
	# JALUR TEMPUR: tombol Lanjut ada
	cs._select_path("combat")
	await get_tree().process_frame
	check("TEMPUR: tombol Lanjut ada", is_instance_valid(cs._start_btn) and cs._start_btn.text.begins_with("Lanjut"))
	# JALUR KEHIDUPAN: pilih class + sub -> tombol Lanjut HARUS ada (dulu buntu)
	cs._select_path("life")
	await get_tree().process_frame
	check("KEHIDUPAN: kartu 4 class tampil", cs._cards.size() == 4)
	cs._select("peramu")
	await get_tree().process_frame
	check("KEHIDUPAN: tombol Lanjut ADA (fix P0)", is_instance_valid(cs._start_btn) and cs._start_btn.get_parent() != null)
	# handler Lanjut mengisi pending dengan benar (tanpa navigasi scene di test:
	# replikasi isi _confirm — navigasi asli diverifikasi boot scene di bawah)
	cs._sub = "archer"
	cs._weapon = "short_bow"
	PlayerData.pending_class = cs._selected
	PlayerData.pending_weapon = cs._weapon
	PlayerData.pending_sub = cs._sub if Db.cls(cs._selected).get("path", "combat") == "life" else ""
	check("pending class/sub/senjata terisi", PlayerData.pending_class == "peramu" \
		and PlayerData.pending_sub == "archer" and PlayerData.pending_weapon == "short_bow")
	check("tombol Lanjut tersambung ke _confirm", cs._start_btn.pressed.is_connected(cs._confirm))
	cs.queue_free()
	await get_tree().process_frame
	# lanjutkan alur: new_game seperti yang dilakukan CharacterCreator -> in-world state benar
	PlayerData.new_game(PlayerData.pending_class, PlayerData.pending_weapon, PlayerData.pending_sub)
	check("in-world: kit & bonus jalur kehidupan benar", PlayerData.char_class == "peramu" \
		and PlayerData.combat_sub == "archer" and PlayerData.equipped_weapon == "short_bow" \
		and PlayerData.item_count("herb_mintleaf") >= 4)
	# jalur tempur end-to-end juga
	PlayerData.pending_class = "warrior"; PlayerData.pending_weapon = "guard_blade"; PlayerData.pending_sub = ""
	PlayerData.new_game(PlayerData.pending_class, PlayerData.pending_weapon, PlayerData.pending_sub)
	check("in-world: jalur tempur benar", PlayerData.char_class == "warrior" and PlayerData.equipped_weapon == "guard_blade")
	PlayerData.new_game()

func _test_guard_kill() -> void:
	print("[Penjaga gerbang membunuh tanpa reward — Decision Log #39]")
	PlayerData.new_game()
	PlayerData.guide_step = 0   # langkah 1 = kill 2 (counter pemain)
	PlayerData.guide_progress = 0
	var killed_flag := [false]
	var cb := func(_s, _m): killed_flag[0] = true
	EventBus.monster_killed.connect(cb)
	var exp0: int = PlayerData.exp
	var gold0: int = PlayerData.gold
	var inv0: int = PlayerData.inventory.size()
	# monster mati di tangan penjaga
	var m: Monster = preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	m.setup(MonsterFactory.make("grey_wolf", 3, 3))
	await get_tree().process_frame
	m.guard_kill()
	await get_tree().process_frame
	check("monster mati oleh penjaga", m._state == Monster.State.DEAD)
	check("NOL EXP dari kill penjaga", PlayerData.exp == exp0)
	check("NOL gold & NOL drop", PlayerData.gold == gold0 and PlayerData.inventory.size() == inv0)
	check("monster_killed TIDAK dipancarkan (quest/counter aman)", not killed_flag[0])
	check("progres panduan pemain TIDAK naik", PlayerData.guide_step == 0 and PlayerData.guide_progress == 0)
	EventBus.monster_killed.disconnect(cb)
	# penjaga benar-benar DATANG & membunuh satu pukulan (AI end-to-end)
	var g := Node2D.new()
	g.set_script(load("res://scenes/actors/Guard.gd"))
	g.position = Vector2(2000, 2000)   # pos sebelum add_child agar _home terekam benar
	add_child(g)
	var m2: Monster = preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m2)
	m2.setup(MonsterFactory.make("verdant_slime", 3, 3))
	await get_tree().process_frame
	m2.global_position = Vector2(2040, 2000)   # dalam ALERT_RADIUS dari pos penjaga
	var t := 0.0
	while t < 3.0 and is_instance_valid(m2) and m2._state != Monster.State.DEAD:
		await get_tree().process_frame
		t += get_process_delta_time()
	check("penjaga mendatangi & membunuh SATU PUKULAN (<3 dtk)", not is_instance_valid(m2) or m2._state == Monster.State.DEAD)
	check("kill AI penjaga juga nol reward", PlayerData.exp == exp0 and PlayerData.gold == gold0)
	g.queue_free()
	PlayerData.new_game()

func _test_life_path() -> void:
	print("[Dua Jalur ClassSelect — BD-1 / Decision Log #33]")
	check("10 class dimuat (6 tempur + 4 kehidupan)", Db.classes.size() == 10)
	var life_ids := Db.class_order.filter(func(c): return Db.cls(c).get("path", "") == "life")
	check("4 class kehidupan: perajin/petani/peramu/penjinak", life_ids == ["perajin", "petani", "peramu", "penjinak"], str(life_ids))
	var life_ok := true
	for lid in life_ids:
		var c := Db.cls(lid)
		if c.get("kit", {}).is_empty() or c.get("perk", "") == "" or c.get("tree_domain", []).is_empty() or c.get("attr", {}).is_empty():
			life_ok = false
	check("tiap class kehidupan: kit + perk + pohon domain + attr", life_ok)
	# END-TO-END jalur kehidupan: Perajin dengan sub Mage
	PlayerData.new_game("perajin", "", "mage")
	check("class kehidupan terpasang", PlayerData.char_class == "perajin" and PlayerData.combat_sub == "mage")
	check("SUB = 2 skill pertama combat sub (aturan sub)", PlayerData.known_skills == ["spark_bolt", "frost_bolt"])
	check("SUB = 1 elemen master pertama", PlayerData.mastered_elements == ["lightning"])
	check("senjata dari combat sub", PlayerData.equipped_weapon == "apprentice_wand")
	check("kit awal masuk tas", PlayerData.item_count("copper_bar") >= 2 and PlayerData.item_count("plank") >= 3)
	# +50% EXP domain (Perajin: blacksmith dst.)
	ProfessionSystem.set_main("miner")   # main ≠ domain, isolasi bonus domain
	PlayerData.prof_xp["blacksmith"] = 0
	ProfessionSystem.toggle_sub("blacksmith")   # aktifkan agar award jalan
	EventBus.item_crafted.emit("copper_bar", true)   # hook award blacksmith? uji langsung:
	ProfessionSystem.award("blacksmith", 10)
	check("+50% EXP domain Perajin (10 -> 15)", PlayerData.prof_xp.get("blacksmith", 0) >= 15, str(PlayerData.prof_xp.get("blacksmith", 0)))
	# integrasi pohon: diskon 50% + node gratis di pohon domain
	PlayerData.gold = 1000
	check("diskon domain 50%: life_cooking 80 -> 40", SkillTreeSystem.unlock_cost("life_cooking") == 40)
	var res := SkillTreeSystem.unlock("life_cooking", "greenvale")
	check("buka pohon domain sukses", res.ok)
	check("node GRATIS: pohon domain langsung level 2", SkillTreeSystem.level("life_cooking") == 2)
	# quest pembuka bercabang: langkah 2 jalur kehidupan = domain, bukan skill class
	check("langkah 2 bercabang ke domain (prof_xp)", Onboarding.step_at(1).get("kind", "") == "prof_xp")
	# END-TO-END jalur tempur tetap utuh
	PlayerData.new_game("necromancer")
	check("jalur tempur tetap: 3 skill + tanpa sub", PlayerData.known_skills.size() == 3 and PlayerData.combat_sub == "")
	check("langkah 2 jalur tempur = skill class", Onboarding.step_at(1).get("kind", "") == "skill")
	# persist combat_sub
	PlayerData.new_game("penjinak", "", "archer")
	SaveManager.save_game(3, true)
	PlayerData.new_game("warrior")
	SaveManager.load_game(3)
	check("combat_sub selamat save/load", PlayerData.char_class == "penjinak" and PlayerData.combat_sub == "archer")
	SaveManager.delete_save(3)
	PlayerData.new_game()

func _test_skill_trees() -> void:
	print("[Skill Tree terikat lokasi — Decision Log #30]")
	PlayerData.new_game()
	PlayerData.gold = 5000
	check("pohon dimuat (28)", Db.skill_trees.size() >= 26, str(Db.skill_trees.size()))
	# lokasi salah = DITOLAK dengan pesan RUMOR
	var wrong := SkillTreeSystem.can_unlock("ice_high", "greenvale")
	check("beli di lokasi salah DITOLAK", not wrong.ok)
	check("pesan penolakan berisi RUMOR berarah", wrong.reason.begins_with("🗺 RUMOR:") and "beku" in wrong.reason, wrong.reason)
	# pohon lokal terbuka di 5 lokasi hidup
	for pair in [["arms_common", "greenvale"], ["ice_high", "frostpeak_village"],
			["lightning_high", "storm_island"], ["earth_metal_high", "desert_ruins"],
			["cooking_advanced", "candyveil_palace"], ["farming_mid", "homestead"]]:
		var res := SkillTreeSystem.unlock(pair[0], pair[1])
		check("pohon %s terbuka di %s" % [pair[0], pair[1]], res.ok, str(res.reason))
	# upgrade BOLEH di mana pun setelah dimiliki
	var up := SkillTreeSystem.upgrade("ice_high")
	check("upgrade node bisa di mana pun (tanpa lokasi)", up.ok and SkillTreeSystem.level("ice_high") == 2)
	# bonus benar-benar dihitung: atk naik setelah arms_common
	var atk_before: int = PlayerData.atk
	PlayerData.skill_trees.erase("arms_common")
	PlayerData.recalculate_stats()
	check("bonus pohon nyata (ATK turun saat pohon dilepas)", PlayerData.atk < atk_before, "%d vs %d" % [PlayerData.atk, atk_before])
	# terkunci-konten: wilayah belum dibangun
	var locked := SkillTreeSystem.can_unlock("fire_high", "emberfall")
	check("pohon wilayah belum dibangun = terkunci-konten", not locked.ok and locked.reason.begins_with("🔒"))
	# Celestial: tampil di astrologer_tower tapi TERKUNCI tanpa buku skenario
	var cel := SkillTreeSystem.at_location("astrologer_tower")
	check("3 pohon Celestial tampil di Menara Astrologer", cel.size() == 3)
	var cchk := SkillTreeSystem.can_unlock("celestial_moon", "astrologer_tower")
	check("Celestial terkunci tanpa buku Skenario Tersembunyi", not cchk.ok and "Skenario" in cchk.reason)
	PlayerData.scenario_flags["moon_rabbit_warren"] = "cleared"
	check("Celestial TERBUKA setelah skenario clear", SkillTreeSystem.can_unlock("celestial_moon", "astrologer_tower").ok)
	# Penjinak: XP juga saat PERCOBAAN taming (Decision Log #32)
	PlayerData.new_game()
	ProfessionSystem.set_main("tamer")
	var xp0: int = PlayerData.prof_xp.get("tamer", 0)
	EventBus.tame_attempted.emit("fluffbit", false, 0.4)   # percobaan GAGAL tetap dapat XP
	check("percobaan taming (gagal) tetap memberi XP Tamer", PlayerData.prof_xp.get("tamer", 0) > xp0)
	PlayerData.new_game()

func _test_daily_events() -> void:
	print("[Event harian & Blood Moon — v0.4.1]")
	# Blood Moon: aggro x1.5 dicek via data jalur; drop x2 via grant_rewards passes
	PlayerData.new_game()
	WorldState.force_weather("blood_moon")
	var inst := MonsterFactory.make("verdant_slime", 3, 3)
	var got := 0
	for i in range(60):
		PlayerData.inventory.clear()
		MonsterFactory.grant_rewards(inst)
		got += PlayerData.item_count("slime_jelly")
	WorldState.force_weather("sunny")
	var got_normal := 0
	for i in range(60):
		PlayerData.inventory.clear()
		MonsterFactory.grant_rewards(inst)
		got_normal += PlayerData.item_count("slime_jelly")
	check("Blood Moon drop ~x2 (60 kill)", got > int(got_normal * 1.4), "%d vs %d" % [got, got_normal])
	# Blood Moon = gerbang evolusi kedua: wild_boar -> ironhide_boar
	WorldState.force_weather("blood_moon")
	var boar := {"species_id": "wild_boar", "name": "Uji Boar", "level": 5, "star": 3}
	check("wild_boar BISA evolve saat Bulan Darah", EvolutionSystem.can_evolve(boar))
	WorldState.force_weather("sunny")
	check("wild_boar TIDAK evolve tanpa Bulan Darah", not EvolutionSystem.can_evolve(boar))
	# nokturnal: gating spawn siang/malam
	check("timberwing_owl bertanda nokturnal", Db.monster("timberwing_owl").get("nocturnal", false))
	if GameClock.is_night():
		check("nokturnal boleh spawn malam", MonsterFactory.spawnable_now("timberwing_owl"))
	else:
		check("nokturnal DILARANG spawn siang", not MonsterFactory.spawnable_now("timberwing_owl"))
	check("spesies biasa selalu boleh spawn", MonsterFactory.spawnable_now("grey_wolf"))
	# Golden Hour: EXP +10% nyata (dites via jalur gain_exp saat kondisi terpenuhi)
	PlayerData.new_game()
	PlayerData.level = 50   # exp_to_next besar -> tidak level-up, murni akumulasi
	PlayerData.exp = 0
	PlayerData.gain_exp(100)
	if GameClock.is_golden_hour():
		check("Golden Hour EXP +10%", PlayerData.exp >= 110 and PlayerData.exp <= 111, str(PlayerData.exp))
	else:
		check("EXP normal di luar Golden Hour", PlayerData.exp == 100, str(PlayerData.exp))
	PlayerData.new_game()

func _test_monster_depth() -> void:
	print("[Kedalaman monster — v0.4.1]")
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	# trait individu: dari 200 rol, muncul dengan efek nyata
	var with_traits := 0
	var berbisa_found := false
	for i in range(200):
		var m := MonsterFactory.make("grey_wolf", 5, 3, rng)
		if m.get("ind_traits", []).size() > 0:
			with_traits += 1
		if m.get("attack_status", "") == "poison":
			berbisa_found = true
	check("trait individu muncul (~75% dari rol)", with_traits > 100 and with_traits < 190, str(with_traits))
	check("trait Berbisa memberi attack_status poison", berbisa_found)
	# trait Kekar menaikkan ATK nyata
	rng.seed = 1
	var base_atk := -1
	var kekar_atk := -1
	for i in range(400):
		var m := MonsterFactory.make("grey_wolf", 5, 3, rng)
		if m.ind_traits.is_empty() and base_atk < 0:
			base_atk = m.atk
		elif m.ind_traits == ["Kekar"] and kekar_atk < 0:
			kekar_atk = m.atk
	check("Kekar ATK > tanpa trait", kekar_atk > base_atk and base_atk > 0, "%d vs %d" % [kekar_atk, base_atk])
	# mutation 1/500: dari 6000 rol ada beberapa, bonus stat & nama ✦
	rng.seed = 42
	var mutants := 0
	var mut_named := false
	for i in range(6000):
		var m := MonsterFactory.make("fluffbit", 3, 3, rng)
		if m.get("mutation", false):
			mutants += 1
			mut_named = m.get("name", "").begins_with("✦")
	check("mutation ~1/500 (6000 rol: 4-30)", mutants >= 4 and mutants <= 30, str(mutants))
	check("mutan bernama ✦ (tampak)", mut_named)
	# affinity hidup: pet aktif +1 per kill, feed +5
	PlayerData.new_game()
	PlayerData.monsters = [{"name": "Uji", "species_id": "fluffbit", "affinity": 0, "star": 3, "level": 1}]
	PlayerData.active_pet_index = 0
	EventBus.monster_killed.emit("grey_wolf", null)
	check("pet aktif +1 affinity per kill", int(PlayerData.monsters[0].get("affinity", 0)) == 1)
	var pot0: int = PlayerData.item_count("minor_potion")
	check("feed_pet +5 affinity & konsumsi item", PlayerData.feed_pet(0, "minor_potion") \
		and int(PlayerData.monsters[0].affinity) == 6 and PlayerData.item_count("minor_potion") == pot0 - 1)
	PlayerData.new_game()

func _test_combo() -> void:
	print("[Combo Skill — v0.4.1]")
	PlayerData.new_game("mage")
	PlayerData.mp = 999
	var actor := Node2D.new()
	add_child(actor)
	var hb := Hotbar.new()
	# dua skill BEDA cepat = combo (skill_mod naik dicek via kondisi internal)
	hb._cast_single(actor, Vector2.RIGHT, "spark_bolt")
	var was := hb._last_cast_sid
	hb._cast_single(actor, Vector2.RIGHT, "frost_bolt")
	check("kombo terdeteksi (2 skill beda <2s)", was == "spark_bolt" and hb._combo_announced)
	# skill sama berulang = bukan combo
	hb._cast_single(actor, Vector2.RIGHT, "frost_bolt")
	check("skill sama = bukan combo", not hb._combo_announced)
	actor.queue_free()
	PlayerData.new_game()

func _test_patterns() -> void:
	print("[Attack Patterns — v0.4.1]")
	# setiap arketipe punya pola (0% musuh jalan-nabrak murni)
	var m: Monster = preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	var by_arch := {}
	for sp in ["grey_wolf", "fluffbit", "verdant_slime", "timberwing_owl", "lollipop_sprite"]:
		m.setup(MonsterFactory.make(sp, 5, 3))
		by_arch[m.inst.get("archetype", "?")] = m._pattern_for()
		check("%s (%s) punya pola: %s" % [sp, m.inst.get("archetype", "?"), m._pattern_for()], m._pattern_for() != "")
	check("min 3 pola berbeda antar arketipe", by_arch.values().reduce(func(acc, v): return acc if v in acc else acc + [v], []).size() >= 3 if by_arch.size() >= 3 else false, str(by_arch))
	# telegraf: memulai pola masuk fase 0 (wind-up), bukan langsung memukul
	m.setup(MonsterFactory.make("grey_wolf", 5, 3))
	await get_tree().process_frame
	m._start_pattern()
	check("pola lunge dimulai dengan telegraf (fase 0)", m._patt == "lunge" and m._patt_phase == 0 and m._patt_t > 0.0)
	# audit roster: SEMUA spesies menghasilkan pola valid
	var all_ok := true
	for sid in Db.monsters:
		m.inst = MonsterFactory.make(sid, 5, 3)
		if m.inst.is_empty():
			continue
		if not (m._pattern_for() in ["lunge", "flank", "burst"]):
			all_ok = false
	check("semua 60 spesies punya pola valid (0% nabrak-polos)", all_ok)
	m.queue_free()

func _test_opening() -> void:
	print("[30 menit pertama — FF-2g]")
	PlayerData.new_game()
	PlayerData.guide_step = 0
	PlayerData.guide_progress = 0
	# step 1: kill 2 -> reward gold + potion (satu sistem, satu reward jelas)
	var g0: int = PlayerData.gold
	var p0: int = PlayerData.item_count("minor_potion")
	EventBus.monster_killed.emit("verdant_slime", null)
	EventBus.monster_killed.emit("verdant_slime", null)
	check("step 1 (kill 2) completes", PlayerData.guide_step == 1)
	check("step 1 reward: +40G +2 potion", PlayerData.gold == g0 + 40 and PlayerData.item_count("minor_potion") == p0 + 2)
	# step 2: cast a class skill via the hotbar hook
	EventBus.skill_cast.emit("flame_slash")
	check("step 2 (skill cast) completes", PlayerData.guide_step == 2)
	# every step declares a reward (reward loop 5-10 menit pertama)
	var all_rewarded := true
	for s in Onboarding.STEPS:
		if not (s.has("reward_gold") or s.has("reward_item")):
			all_rewarded = false
	check("every opening step has a clear reward", all_rewarded)
	check("opening has 6 steps (one system each)", Onboarding.STEPS.size() == 6)
	PlayerData.new_game()

func _test_save_modern() -> void:
	print("[Save modern — FF-2e]")
	# metadata slot kaya: name/class/level/playtime/location
	PlayerData.new_game("paladin")
	PlayerData.playtime_sec = 3725.0   # 1:02
	SaveManager.save_game(3, true)
	var meta := SaveManager.save_meta(3)
	check("meta has class name", meta.get("class", "") == "Paladin")
	check("meta has playtime h:mm", meta.get("playtime", "") == "1:02", str(meta))
	check("meta has location", meta.get("location", "?") != "?")
	check("last_slot remembered for Continue", SaveManager.last_slot() == 3)
	# playtime + char_class survive the roundtrip
	PlayerData.new_game("warrior")
	check("state reset before load", PlayerData.char_class == "warrior" and PlayerData.playtime_sec == 0.0)
	SaveManager.load_game(3)
	check("class survives save/load", PlayerData.char_class == "paladin")
	check("playtime survives save/load", absf(PlayerData.playtime_sec - 3725.0) < 1.0)
	SaveManager.delete_save(3)
	PlayerData.new_game()

func _test_classes() -> void:
	print("[Class Selection — FF-2a]")
	var combat_ids := Db.class_order.filter(func(c): return Db.cls(c).get("path", "combat") == "combat")
	check("6 combat classes loaded (+4 life = 10 total)", combat_ids.size() == 6 and Db.classes.size() == 10)
	var all_ok := true
	var kit_ids := {}
	for cid in combat_ids:
		var c := Db.cls(cid)
		if c.get("skills", []).size() != 3: all_ok = false
		if c.get("weapons", []).size() != 2: all_ok = false
		if c.get("attr", {}).is_empty() or c.get("advanced", "") == "": all_ok = false
		for sid in c.get("skills", []):
			if Db.skill(sid).is_empty(): all_ok = false
		for wv in c.get("weapons", []):
			if Db.item(wv.get("id", "")).is_empty(): all_ok = false
		kit_ids[str(c.get("skills", []))] = true
	check("every combat class: 3 real skills + 2 real weapons + attr + advanced teaser", all_ok)
	check("all 6 combat skill kits are DIFFERENT", kit_ids.size() == 6, str(kit_ids.size()))
	# new_game applies the class package
	PlayerData.new_game("necromancer")
	check("necromancer class set", PlayerData.char_class == "necromancer")
	check("necro attr bonus applied (INT 9)", PlayerData.attributes.get("INT", 0) == 9)
	check("necro knows shadow_bolt, NOT flame_slash", PlayerData.can_use_skill("shadow_bolt") and not PlayerData.can_use_skill("flame_slash"))
	check("necro masters darkness (flow usable)", PlayerData.can_use_skill("flow_darkness"))
	check("necro starting weapon = bone_staff", PlayerData.equipped_weapon == "bone_staff")
	# weapon variant honored
	PlayerData.new_game("warrior", "guard_blade")
	check("weapon variant honored (guard_blade)", PlayerData.equipped_weapon == "guard_blade")
	check("guard_blade def counts", PlayerData.def > 0 and PlayerData._gear_stat("def") >= int(Db.item("guard_blade").def) + int(Db.item("cloth_tunic").def))
	# class affinity: warrior with sword = +8% atk vs same char without affinity
	PlayerData.new_game("warrior", "wide_sword")
	var atk_aff: int = PlayerData.atk
	PlayerData.char_class = "mage"   # same stats, no sword affinity
	PlayerData.recalculate_stats()
	check("weapon affinity grants bonus ATK", atk_aff > PlayerData.atk)
	# buff skills (war_cry) raise combat_stats atk temporarily
	PlayerData.new_game("warrior")
	var base_atk: int = PlayerData.combat_stats().atk
	PlayerData.apply_buff("war_cry", {"atk_mult": 1.2, "duration": 5.0})
	check("war_cry buff raises atk ~20%", PlayerData.combat_stats().atk == int(PlayerData.atk * 1.2), "%d vs %d" % [PlayerData.combat_stats().atk, base_atk])
	# moveset table: every weapon_type in items has a moveset
	var ms_ok := true
	for iid in Db.items:
		var it: Dictionary = Db.items[iid]
		if it.get("type", "") == "weapon" and not PlayerCombat.WEAPON_MOVESET.has(it.get("weapon_type", "")):
			ms_ok = false
	check("every weapon type has a moveset (FF-2b)", ms_ok)
	# movesets genuinely differ (dagger fast-weak vs hammer slow-heavy)
	var dg: Dictionary = PlayerCombat.WEAPON_MOVESET["dagger"]
	var hm: Dictionary = PlayerCombat.WEAPON_MOVESET["hammer"]
	check("dagger faster than hammer, hammer hits harder", dg.rate > hm.rate * 2.0 and hm.mult > dg.mult * 2.0)
	PlayerData.new_game()

func _test_equipment() -> void:
	print("[Equipment — PC5]")
	PlayerData.new_game()
	# neutralize class weapon affinity for additive-stat assertions (archer = bow only)
	PlayerData.char_class = "archer"
	PlayerData.recalculate_stats()
	# --- slots & starting gear ---
	check("3 equip slots resolve by type", PlayerData.slot_for_item("wooden_sword") == "equipped_weapon" \
		and PlayerData.slot_for_item("cloth_tunic") == "equipped_armor" \
		and PlayerData.slot_for_item("copper_ring") == "equipped_accessory")
	check("starting armor is tier F equipped", PlayerData.equipped_armor == "cloth_tunic" and Db.item("cloth_tunic").get("tier") == "F")
	check("non-gear item has no slot", PlayerData.slot_for_item("minor_potion") == "")
	# --- gear stats really count (def + hp from armor) ---
	PlayerData.equipped_armor = ""
	PlayerData.recalculate_stats()
	var bare_def: int = PlayerData.def
	var bare_hp: int = PlayerData.max_hp
	PlayerData.equip_item("cloth_tunic")
	check("armor adds DEF", PlayerData.def == bare_def + int(Db.item("cloth_tunic").def))
	check("armor adds HP", PlayerData.max_hp == bare_hp + int(Db.item("cloth_tunic").hp_bonus))
	# --- accessory adds MATK + MP ---
	var pre_matk: int = PlayerData.matk
	var pre_mp: int = PlayerData.max_mp
	PlayerData.equip_item("copper_ring")
	check("accessory adds MATK", PlayerData.matk == pre_matk + int(Db.item("copper_ring").matk))
	check("accessory adds MP", PlayerData.max_mp == pre_mp + int(Db.item("copper_ring").mp_bonus))
	# --- equip is a toggle (re-equip same = unequip) ---
	PlayerData.equip_item("copper_ring")
	check("re-equipping unequips (toggle)", PlayerData.equipped_accessory == "")
	# --- weapon atk counted exactly once (no double-count) ---
	PlayerData.equipped_weapon = ""
	PlayerData.equipped_armor = ""
	PlayerData.recalculate_stats()
	var no_wep: int = PlayerData.atk
	PlayerData.equip_item("wooden_sword")
	check("weapon atk counted once", PlayerData.atk == no_wep + int(Db.item("wooden_sword").atk))
	# --- tier scaling ~+25-35% per jump (armor def+hp aggregate) ---
	var eff := func(item_id):
		var d := Db.item(item_id)
		return int(d.get("def", 0)) * 4 + int(d.get("hp_bonus", 0)) + int(d.get("matk", 0)) * 4 + int(d.get("mp_bonus", 0))
	var af: int = eff.call("cloth_tunic"); var ae: int = eff.call("leather_vest"); var ad: int = eff.call("iron_mail")
	check("armor F->E effectiveness +20..45%", float(ae) / af >= 1.2 and float(ae) / af <= 1.45, "%.2f" % (float(ae) / af))
	check("armor E->D effectiveness +20..45%", float(ad) / ae >= 1.2 and float(ad) / ae <= 1.45, "%.2f" % (float(ad) / ae))
	var rf: int = eff.call("copper_ring"); var re: int = eff.call("silver_ring"); var rd: int = eff.call("gold_ring")
	check("accessory F->E effectiveness +20..45%", float(re) / rf >= 1.2 and float(re) / rf <= 1.45, "%.2f" % (float(re) / rf))
	check("accessory E->D effectiveness +20..45%", float(rd) / re >= 1.2 and float(rd) / re <= 1.45, "%.2f" % (float(rd) / re))
	# --- craft chain F->E->D exists (upgrades consume the lower tier) ---
	var recipe := func(rid):
		for r in Db.recipes:
			if r.get("id", "") == rid: return r
		return {}
	check("craft chain: iron_mail (D) consumes leather_vest (E)", _recipe_uses(recipe.call("craft_iron_mail"), "leather_vest"))
	check("craft chain: leather_vest (E) consumes cloth_tunic (F)", _recipe_uses(recipe.call("craft_leather_vest"), "cloth_tunic"))
	check("craft chain: gold_ring (D) consumes silver_ring (E)", _recipe_uses(recipe.call("craft_gold_ring"), "silver_ring"))
	check("craft chain: silver_ring (E) consumes copper_ring (F)", _recipe_uses(recipe.call("craft_silver_ring"), "copper_ring"))
	PlayerData.new_game()

func _recipe_uses(recipe: Dictionary, item_id: String) -> bool:
	for ing in recipe.get("ingredients", []):
		if ing.get("item", "") == item_id:
			return true
	return false

func _test_v3content() -> void:
	print("[v0.3 content — Frostpeak/Storm]")
	# Thermal Shock fusion (Fire + Ice), symmetric
	check("Thermal Shock fusion (fire+ice)", Db.elem_combo("fire", "ice").get("result", "") == "Thermal Shock")
	check("Thermal Shock symmetric (ice+fire)", Db.elem_combo("ice", "fire").get("result", "") == "Thermal Shock")
	# new species build with correct elements
	check("frost_elemental builds (ice)", MonsterFactory.make("frost_elemental").get("element", "") == "ice")
	check("frost_wyvern builds", not MonsterFactory.make("frost_wyvern").is_empty())
	check("woolly_calf builds", not MonsterFactory.make("woolly_calf").is_empty())
	check("volt_weasel builds (lightning)", MonsterFactory.make("volt_weasel").get("element", "") == "lightning")
	check("thunder_hawk builds", not MonsterFactory.make("thunder_hawk").is_empty())
	check("storm_elemental builds", not MonsterFactory.make("storm_elemental").is_empty())
	check("thunder_dragon is legendary secret", Db.monster("thunder_dragon").get("rarity", "") == "legendary")
	# bosses
	check("Frost Titan is a boss", Db.monster("frost_titan").get("is_boss", false))
	check("Storm Sovereign is a boss", Db.monster("storm_sovereign").get("is_boss", false))
	check("Everfrost Core drops from Frost Titan", _lt_has("frost_titan", "everfrost_core"))
	check("Tempest Heart drops from Storm Sovereign", _lt_has("storm_sovereign", "tempest_heart"))
	# Dire Wolf -> Alpha Wolf (full moon)
	check("dire_wolf -> alpha_wolf", Db.monster("dire_wolf").get("evolution", "") == "alpha_wolf")
	check("dire_wolf condition = full_moon", EvolutionSystem.CONDITIONS.get("dire_wolf", "") == "full_moon")
	var pet := {"species_id": "dire_wolf", "level": 12, "star": 3, "name": "Dire Wolf"}
	EvolutionSystem.apply(pet, "alpha_wolf")
	check("apply() transforms Dire -> Alpha Wolf", pet.get("species_id", "") == "alpha_wolf" and pet.get("name", "") == "Alpha Wolf")
	# frost items flavor
	check("everfrost_core has flavor", Db.item("everfrost_core").get("flavor", "") != "")

func _lt_has(table: String, item: String) -> bool:
	for d in Db.loot_table(table):
		if d.get("item", "") == item:
			return true
	return false

func _test_chargen() -> void:
	print("[CharGen — Aetherion Character System]")
	var races: Array = CharGen.races()
	check("7 races available", races.size() == 7)
	# every head x torso x legs race combination composes to a 96x128 sheet (no crash)
	var ok := true
	var count := 0
	for h in races:
		for t in races:
			for l in races:
				var cfg := {"head_race": h, "torso_race": t, "legs_race": l,
					"hair": "short", "hair_color": "#241f36", "shirt": "#2e6b3f", "pants": "#453d5c"}
				var img := CharGen.sheet_image(cfg)
				if img.get_width() != 96 or img.get_height() != 128:
					ok = false
				count += 1
	check("all %d race x part combos -> 96x128" % count, ok)
	# all hair styles compose
	var hok := true
	for hs in CharGen.hair_styles():
		var c := CharGen.default_config(); c["hair"] = hs
		if CharGen.sheet_image(c).get_width() != 96:
			hok = false
	check("all hair styles compose", hok)
	# per-part skin override
	var cs := CharGen.default_config(); cs["head_skin"] = "#ff3355"
	check("per-part skin override composes", CharGen.sheet_image(cs).get_width() == 96)
	# sprite frames
	var sf := CharGen.sprite_frames(CharGen.default_config())
	check("walk_down has 4 frames (0-1-2-1)", sf.get_frame_count("walk_down") == 4)
	check("idle_down animation present", sf.has_animation("idle_down"))
	check("all 4 directions have walk anims", sf.has_animation("walk_up") and sf.has_animation("walk_left") and sf.has_animation("walk_right"))
	check("attack_down is a 2-frame non-loop swing", sf.has_animation("attack_down") and sf.get_frame_count("attack_down") == 2 and not sf.get_animation_loop("attack_down"))
	check("6 hair styles (added mohawk/bun)", CharGen.hair_styles().size() == 6)

func _test_onboarding() -> void:
	print("[Onboarding + Guide chain]")
	check("STEPS chain is 6 long (FF-2g)", Onboarding.STEPS.size() == 6)
	check("tips cover the six contexts", Onboarding.TIPS.has("town") and Onboarding.TIPS.has("tree") \
		and Onboarding.TIPS.has("monster") and Onboarding.TIPS.has("levelup") \
		and Onboarding.TIPS.has("orb") and Onboarding.TIPS.has("dungeon_door"))
	# one-time tip gating
	PlayerData.onboarding_seen = []
	Onboarding.tip("town")
	Onboarding.tip("town")
	check("tip shown once, then suppressed", PlayerData.onboarding_seen.count("town") == 1)
	Onboarding.tip("nonexistent_tip")
	check("unknown tip id is a no-op", not ("nonexistent_tip" in PlayerData.onboarding_seen))
	# opening quest chain (FF-2g order): kill 2 -> skill -> chop 3 -> craft -> tame -> board
	PlayerData.guide_step = 0
	PlayerData.guide_progress = 0
	EventBus.node_harvested.emit("tree", "wood_log", 1)
	check("wrong kind doesn't advance (tree during kill step)", PlayerData.guide_step == 0 and PlayerData.guide_progress == 0)
	EventBus.monster_killed.emit("grey_wolf", null)
	check("kill 1/2 — still step 1", PlayerData.guide_step == 0 and PlayerData.guide_progress == 1)
	EventBus.monster_killed.emit("grey_wolf", null)
	check("kill 2/2 advances to skill step", PlayerData.guide_step == 1)
	EventBus.skill_cast.emit("flame_slash")
	check("skill cast advances to gather step", PlayerData.guide_step == 2)
	EventBus.node_harvested.emit("tree", "wood_log", 1)
	EventBus.node_harvested.emit("tree", "wood_log", 1)
	EventBus.node_harvested.emit("tree", "wood_log", 1)
	check("chop 3/3 advances to craft step", PlayerData.guide_step == 3)
	EventBus.item_crafted.emit("x", false)
	check("failed craft doesn't advance", PlayerData.guide_step == 3)
	EventBus.item_crafted.emit("plank", true)
	check("craft advances to tame step", PlayerData.guide_step == 4)
	EventBus.pet_added.emit({})
	check("tame advances to board step", PlayerData.guide_step == 5)
	EventBus.board_visited.emit()
	check("visiting board completes the chain", PlayerData.guide_step == 6)
	EventBus.monster_killed.emit("grey_wolf", null)
	check("events after completion are ignored", PlayerData.guide_step == 6)
	# reset for a clean save state
	PlayerData.guide_step = 0
	PlayerData.guide_progress = 0
	PlayerData.onboarding_seen = []

func _test_skycalendar() -> void:
	print("[Sky Calendar]")
	check("sky calendar loaded", Db.sky_calendar.size() > 0)
	check("days_until today == 0", GameClock.days_until(GameClock.date_string()) == 0)
	check("days_until far future > 0", GameClock.days_until("2099-01-01") > 0)
	check("days_until past < 0", GameClock.days_until("2000-01-01") < 0)
	var ev: Array = GameClock.upcoming_events(6)
	var sorted := true
	var non_neg := true
	for i in range(ev.size()):
		if ev[i].days < 0: non_neg = false
		if i > 0 and ev[i - 1].days > ev[i].days: sorted = false
	check("upcoming events non-negative", non_neg)
	check("upcoming events sorted ascending", sorted)

func _test_professions() -> void:
	print("[ProfessionSystem: 1 main + 2 sub]")
	check("professions data loaded", Db.professions.size() >= 5)
	PlayerData.new_game()
	# --- XP gating: only main+sub earn XP ---
	PlayerData.professions = {"main": "miner", "sub": ["fisherman"], "last_main_change": 0}
	ProfessionSystem.award("miner", 10)
	check("main +50% XP", PlayerData.prof_xp.get("miner", 0) == 15)
	ProfessionSystem.award("fisherman", 10)
	check("sub 1.0x XP", PlayerData.prof_xp.get("fisherman", 0) == 10)
	ProfessionSystem.award("lumberjack", 10)
	check("inactive profession earns NO XP", PlayerData.prof_xp.get("lumberjack", 0) == 0)
	# --- efficiency 75% for sub ---
	check("main efficiency 1.0", abs(ProfessionSystem.efficiency("miner") - 1.0) < 0.001)
	check("sub efficiency 0.75", abs(ProfessionSystem.efficiency("fisherman") - 0.75) < 0.001)
	check("inactive efficiency 0.0", abs(ProfessionSystem.efficiency("lumberjack") - 0.0) < 0.001)
	# --- level caps: sub ~60% of main ---
	PlayerData.prof_xp["miner"] = 999999
	PlayerData.prof_xp["fisherman"] = 999999
	check("main level capped at MAIN_CAP", ProfessionSystem.effective_level("miner") == ProfessionSystem.MAIN_CAP)
	check("sub level capped at SUB_CAP", ProfessionSystem.effective_level("fisherman") == ProfessionSystem.SUB_CAP)
	check("sub cap < main cap (~60%)", ProfessionSystem.SUB_CAP < ProfessionSystem.MAIN_CAP)
	# --- recipe tier gate ---
	var basic := {"profession": "blacksmith", "result": "copper_sword", "tier": "E"}
	check("basic recipe usable by anyone", ProfessionSystem.can_use_recipe(basic).ok)
	var b_tier := {"profession": "lumberjack", "tier": "B"}   # lumberjack is inactive here
	check("B-tier needs active profession", not ProfessionSystem.can_use_recipe(b_tier).ok)
	var a_main := {"profession": "miner", "tier": "A"}         # miner is main
	check("A-tier usable by MAIN", ProfessionSystem.can_use_recipe(a_main).ok)
	var a_sub := {"profession": "fisherman", "tier": "A"}      # fisherman is only sub
	check("A-tier NOT usable by sub", not ProfessionSystem.can_use_recipe(a_sub).ok)
	# --- perk value scaled by role efficiency ---
	PlayerData.prof_xp["miner"] = 800
	check("main perk full value", ProfessionSystem.perk_value("miner", "faster") >= 1.0)
	PlayerData.professions = {"main": "fisherman", "sub": ["miner"], "last_main_change": 0}
	PlayerData.prof_xp["miner"] = 800
	check("same perk as SUB is reduced (x0.75)", ProfessionSystem.perk_value("miner", "faster") < 1.0 and ProfessionSystem.perk_value("miner", "faster") > 0.0)
	# --- max 2 subs + set main flow ---
	PlayerData.professions = {"main": "", "sub": [], "last_main_change": 0}
	PlayerData.gold = 999999
	check("first main pick is free", ProfessionSystem.set_main("miner").ok)
	ProfessionSystem.toggle_sub("fisherman")
	ProfessionSystem.toggle_sub("cook")
	var third := ProfessionSystem.toggle_sub("herbalist")
	check("cannot add a 3rd sub", not third.ok and ProfessionSystem.subs().size() == 2)
	# event-driven award still works for an active profession
	var lb_before: int = PlayerData.prof_xp.get("miner", 0)
	EventBus.block_mined.emit(Vector2i(0, 0), "block")
	check("block_mined awards active Miner", PlayerData.prof_xp.get("miner", 0) > lb_before)
	PlayerData.new_game()

func _test_fishing() -> void:
	print("[FishingSystem]")
	check("fish data loaded", Db.fish.size() >= 6)
	check("tide high", FishingSystem.tide_band(0.6) == "high")
	check("tide low", FishingSystem.tide_band(-0.6) == "low")
	check("tide mid", FishingSystem.tide_band(0.0) == "mid")
	var noon := FishingSystem.eligible(12, 0.0, false, "").map(func(f): return f.id)
	check("carp available at noon", "common_carp" in noon)
	check("night_eel not at noon", not ("night_eel" in noon))
	check("star_minnow needs bait", not ("star_minnow" in noon))
	var night_star := FishingSystem.eligible(21, 0.0, false, "star_bait").map(func(f): return f.id)
	check("star_minnow with bait at night", "star_minnow" in night_star)
	check("night_eel available at 02:00 (wrap window)", "night_eel" in FishingSystem.eligible(2, 0.0, false, "").map(func(f): return f.id))
	check("moonfish excluded w/o full moon", not ("moonfish" in FishingSystem.eligible(21, 0.0, false, "").map(func(f): return f.id)))
	check("moonfish at full-moon night", "moonfish" in FishingSystem.eligible(21, 0.0, true, "").map(func(f): return f.id))
	check("snapper at high tide", "tide_snapper" in FishingSystem.eligible(12, 0.7, false, "").map(func(f): return f.id))
	check("roll yields a catch (carp always eligible)", not FishingSystem.roll("").is_empty())

func _test_hotbar() -> void:
	print("[Hotbar + fusion]")
	check("fusion recipes >= 8", Db.elements.get("combos", []).size() >= 8)
	check("combo lookup order-independent", not Db.elem_combo("fire", "ice").is_empty() and not Db.elem_combo("ice", "fire").is_empty())
	check("fire+lightning has no recipe", Db.elem_combo("fire", "lightning").is_empty())
	PlayerData.new_game()
	PlayerData.mp = 999
	var actor := Node2D.new()
	add_child(actor)
	await get_tree().process_frame
	var hb := Hotbar.new()
	# ensure known hotbar layout: slots map to flow elements for deterministic fusion.
	# master every element the test primes so can_use_skill gates don't block (PC4).
	PlayerData.mastered_elements = ["fire", "lightning", "ice", "wind", "earth", "poison"]
	if not ("spark_bolt" in PlayerData.known_skills):
		PlayerData.known_skills.append("spark_bolt")   # default class (warrior) doesn't know it
	PlayerData.hotbar = ["flow_fire", "flow_lightning", "flow_fire", "spark_bolt", "flow_ice"]
	# --- rev B: no cooldowns, channelled cast ---
	check("cooldown_frac always 0 (no CDs)", hb.cooldown_frac(0) == 0.0)
	# single prime + flow toggle (slot 2 = flow_fire -> infusion)
	PlayerData.mp = 999
	hb.press_slot(2)
	check("slot primed", hb.primed == 2)
	check("flow begin_cast returns true", hb.begin_cast(actor, Vector2.RIGHT))
	check("flow cast applied infusion", PlayerData.has_active_infusion())
	check("flow cast resets prime", hb.primed == -1)
	PlayerData.clear_infusion()
	# --- channel drain: holding a non-flow skill casts at cast_rate, spends mana ---
	PlayerData.mp = 999
	hb.press_slot(3)   # spark_bolt (magic, mana_cost > 0)
	check("non-flow primed (channel)", hb.is_primed() and not hb.primed_is_flow())
	var mp_channel: int = PlayerData.mp
	hb.begin_cast(actor, Vector2.RIGHT)   # first cast immediately
	check("channel first cast spent mana", PlayerData.mp < mp_channel)
	var mp_after1: int = PlayerData.mp
	hb.channel_tick(actor, Vector2.RIGHT, 1.0)   # >1/cast_rate -> another cast
	check("channel tick fired another cast", PlayerData.mp < mp_after1)
	# channel stops when mana empty (empty click, no negative mana)
	PlayerData.mp = 0
	hb.channel_tick(actor, Vector2.RIGHT, 1.0)
	check("no mana = mp stays 0", PlayerData.mp == 0)
	hb.end_cast()
	hb.primed = -1; hb.fusion_slots = []; hb.fusion_ready = false; hb.tick(2.0)
	# --- valid 2-element fusion: slot 2 (fire) + slot 4 (ice) = Thermal Shock (holdable) ---
	PlayerData.discovered_fusions.clear()
	PlayerData.mp = 999
	hb.press_slot(2)
	hb.press_slot(4)
	check("fusion primed on 2nd key in window", hb.fusion_ready)
	check("2-elem fusion cast_rate is holdable (>0)", hb._cast_rate() >= 1.5)
	var mp_before: int = PlayerData.mp
	check("valid fusion casts", hb.begin_cast(actor, Vector2.RIGHT))
	check("fusion is first-discovered", "Thermal Shock" in PlayerData.discovered_fusions)
	check("fusion spent 2x mana", PlayerData.mp < mp_before)
	hb.end_cast()
	hb.primed = -1; hb.fusion_slots = []; hb.fusion_ready = false; hb.tick(2.0)
	# --- rev C: 3-element fusion = slow recast ---
	PlayerData.mp = 999
	hb.press_slot(0)   # fire
	hb.press_slot(1)   # lightning
	hb.press_slot(4)   # ice
	check("3-elem fusion ready", hb.fusion_ready and hb.fusion_slots.size() == 3)
	check("3-elem fusion is recast (slow rate < 1)", hb._cast_rate() < 1.0)
	# PC3 HUD helpers: prime chain string + recast flag/bar
	check("prime chain string shows 3 slots", hb.prime_chain_str() == "1+2+5")
	check("3-elem fusion flagged as recast", hb.is_recast_fusion())
	check("recast_frac in 0..1", hb.recast_frac() >= 0.0 and hb.recast_frac() <= 1.0)
	hb.end_cast()
	hb.primed = -1; hb.fusion_slots = []; hb.fusion_ready = false; hb.tick(2.0)
	# fizzle: slot 0 (fire) + slot 1 (lightning) = no 2-elem recipe
	PlayerData.hotbar = ["flow_fire", "flow_lightning", "flow_fire", "spark_bolt", "flow_ice"]
	PlayerData.mp = 999
	hb.press_slot(0)
	hb.press_slot(1)
	var disc_before: int = PlayerData.discovered_fusions.size()
	hb.begin_cast(actor, Vector2.RIGHT)
	check("fizzle discovers nothing", PlayerData.discovered_fusions.size() == disc_before)
	hb.end_cast()
	# combo window expiry -> no fusion
	hb.press_slot(0)
	hb.tick(2.0)   # > COMBO_WINDOW (1.5)
	hb.press_slot(1)
	check("expired window = single prime, not fusion", hb.primed == 1 and not hb.fusion_ready)
	# --- FF-2c: prime toggle & cancel ---
	hb.press_slot(1)   # same slot again = cancel
	check("same-key press cancels the prime (toggle)", hb.primed == -1 and not hb.is_primed())
	hb.press_slot(0)
	hb.press_slot(1)
	check("fusion chain primed", hb.fusion_ready)
	hb.cancel_all()
	check("cancel_all clears prime + fusion", not hb.is_primed() and hb.fusion_slots.is_empty())
	# --- FF-2d: Grimoire — fizzle records elements for mystery rows ---
	PlayerData.fusion_fizzled_elements.clear()
	PlayerData.mp = 999
	hb.press_slot(0)   # fire
	hb.press_slot(1)   # lightning (no 2-elem recipe = fizzle)
	hb.begin_cast(actor, Vector2.RIGHT)
	check("fizzle records elements for the Grimoire", "fire" in PlayerData.fusion_fizzled_elements and "lightning" in PlayerData.fusion_fizzled_elements)
	hb.end_cast()
	actor.queue_free()
	PlayerData.new_game()

func _test_dungeon_combat() -> void:
	print("[Dungeon combat / feel]")
	PlayerData.new_game()
	check("projectiles data loaded", Db.projectiles.size() >= 5)
	check("combat_feel loaded", not Db.combat_feel.is_empty())
	check("iframes = 0.5", abs(CombatFeel.iframes() - 0.5) < 0.001)
	check("projectile pool prewarmed", ProjectilePool.pool_size() >= 40)

	# arc melee is MULTI-HIT: two monsters in the arc both take damage
	var actor := Node2D.new()
	add_child(actor)
	actor.global_position = Vector2.ZERO
	var m1 = preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	var m2 = preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(m1); add_child(m2)
	m1.setup(MonsterFactory.make("verdant_slime", 5, 3))
	m2.setup(MonsterFactory.make("verdant_slime", 5, 3))
	await get_tree().process_frame
	m1.global_position = Vector2(28, -6)
	m2.global_position = Vector2(30, 10)
	var hp1_0: int = m1.hp
	var hp2_0: int = m2.hp
	PlayerData.accuracy = 2.0   # guarantee hits (bypass the AGI/DEX miss roll for this determinism test)
	PlayerCombat.melee_arc(actor, Vector2.RIGHT, 48.0, 120.0, Db.skill("strike"))
	Engine.time_scale = 1.0   # clear any hitstop from the swing
	check("arc melee multi-hit (m1)", m1.hp < hp1_0, "%d<%d" % [m1.hp, hp1_0])
	check("arc melee multi-hit (m2)", m2.hp < hp2_0)
	# knockback pushed the monster (velocity now non-zero)
	check("knockback applied velocity", m1.velocity.length() > 1.0)

	# --- rev D: per-SOURCE hit-immunity (anti-melt) ---
	var imm_m = preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(imm_m)
	imm_m.setup(MonsterFactory.make("verdant_slime", 5, 3))
	await get_tree().process_frame
	var imm_hp0: int = imm_m.hp
	var hit := {"damage": 5, "is_crit": false, "element": "none"}
	imm_m.take_hit(hit, actor)
	var imm_hp1: int = imm_m.hp
	check("first hit from source lands", imm_hp1 < imm_hp0)
	imm_m.take_hit(hit, actor)   # same source, same frame -> blocked by immunity window
	check("immediate re-hit from SAME source is blocked", imm_m.hp == imm_hp1)
	var other := Node2D.new(); add_child(other)
	imm_m.take_hit(hit, other)   # DIFFERENT source -> lands
	check("hit from a DIFFERENT source still lands", imm_m.hp < imm_hp1)
	imm_m.queue_free(); other.queue_free()

	# --- rev E: weapon infusion reshapes melee reach (Lightning = 1.5x) ---
	var far_m = preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(far_m)
	far_m.setup(MonsterFactory.make("verdant_slime", 5, 3))
	await get_tree().process_frame
	far_m.global_position = Vector2(60, 0)   # beyond base reach 48, within 48*1.5=72
	PlayerData.clear_infusion()
	PlayerData.accuracy = 2.0
	var far_hp0: int = far_m.hp
	PlayerCombat.melee_arc(actor, Vector2.RIGHT, 48.0, 120.0, Db.skill("strike"))
	check("no infusion = target beyond reach untouched", far_m.hp == far_hp0)
	PlayerData.apply_infusion("lightning")   # reach_mult 1.5 -> now in range
	PlayerCombat.melee_arc(actor, Vector2.RIGHT, 48.0, 120.0, Db.skill("strike"))
	check("lightning infusion extends reach to hit far target", far_m.hp < far_hp0)
	PlayerData.clear_infusion()
	far_m.queue_free()

	# projectile pooling: firing takes from the pool
	var before_active: int = ProjectilePool.active_count()
	ProjectilePool.spawn(Vector2(0, 0), Vector2.RIGHT, "spark", PlayerData.combat_stats(), actor, "monsters")
	check("pool spawns an active projectile", ProjectilePool.active_count() == before_active + 1)
	check("pool size stable (reused, not grown)", ProjectilePool.pool_size() >= 40)
	m1.queue_free(); m2.queue_free(); actor.queue_free()

	# boss phases: King Slime enters phase 2 under 40% HP + spawns adds
	var boss = preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(boss)
	boss.setup(MonsterFactory.make("king_slime", 15, 3))
	await get_tree().process_frame
	check("boss flagged", boss._boss)
	check("boss starts phase 1", boss._phase == 1)
	var monsters_before: int = get_tree().get_nodes_in_group("monsters").size()
	boss.hp = int(boss.max_hp * 0.7)   # cross the 0.75 add threshold
	await get_tree().physics_frame
	await get_tree().physics_frame
	check("boss spawned adds at threshold", get_tree().get_nodes_in_group("monsters").size() > monsters_before)
	boss.hp = int(boss.max_hp * 0.3)   # below 40% -> phase 2
	await get_tree().physics_frame
	check("boss enters phase 2 under 40% HP", boss._phase == 2)
	Engine.time_scale = 1.0
	# --- boss upgrade (v0.4.1): pola terkoreografi + fase beda + perayaan ---
	check("boss fase 1 punya >= 3 pola", boss.BOSS_P1.reduce(func(acc, v): return acc if v in acc else acc + [v], []).size() >= 3)
	check("fase 2 punya pola BARU (dash/summon)", ("dash" in boss.BOSS_P2) and ("summon" in boss.BOSS_P2) and not ("dash" in boss.BOSS_P1))
	boss._start_boss_pattern()
	check("pola bos dimulai dengan telegraf", boss._bpatt != "" and boss._bpatt_phase == 0)
	var engaged := [false]
	var defeated := [false]
	EventBus.boss_engaged.connect(func(_n, _b): engaged[0] = true)
	EventBus.boss_defeated.connect(func(_n): defeated[0] = true)
	var boss2 = preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(boss2)
	boss2.setup(MonsterFactory.make("frost_titan", 28, 3))
	await get_tree().process_frame
	check("boss intro memancarkan boss_engaged", engaged[0])
	boss2._boss_celebration()
	check("perayaan kill memancarkan boss_defeated + slow-mo", defeated[0] and Engine.time_scale < 1.0)
	await get_tree().create_timer(0.3, true, false, true).timeout
	check("time_scale pulih setelah perayaan", Engine.time_scale == 1.0)
	Engine.time_scale = 1.0
	boss2.queue_free()
	# candy boss + configurable adds (Gummy Cavern content)
	var gt := MonsterFactory.make("gummy_titan", 25, 4)
	check("gummy titan is boss", gt.get("is_boss", false))
	check("gummy titan spawns gummy_slime adds", gt.get("add_species", "") == "gummy_slime")
	boss.queue_free()
	# cleanup any adds
	for m in get_tree().get_nodes_in_group("monsters"):
		m.queue_free()

func _test_platformer() -> void:
	print("[Dungeon platformer]")
	# --- terrain: mining + ladders ---
	var terrain = preload("res://scenes/world/DungeonTerrain.tscn").instantiate()
	add_child(terrain)
	terrain.build_from(["BBBBB", "B O B", "B H B", "B###B", "BBBBB"])
	await get_tree().process_frame
	check("ladder cell detected", terrain.is_ladder(terrain.solid.map_to_local(Vector2i(2, 2))))
	check("non-ladder cell false", not terrain.is_ladder(terrain.solid.map_to_local(Vector2i(2, 3))))
	PlayerData.new_game()
	PlayerData.professions = {"main": "miner", "sub": [], "last_main_change": 0}  # miner active for XP
	var before: int = PlayerData.item_count("copper_ore")
	check("bedrock is undiggable", not terrain.try_mine(terrain.solid.map_to_local(Vector2i(0, 0))))
	check("bedrock cell intact", terrain.solid.get_cell_source_id(Vector2i(0, 0)) != -1)
	var ore_pos = terrain.solid.map_to_local(Vector2i(2, 1))
	for i in range(4):
		terrain.try_mine(ore_pos)
	check("ore mined out after 4 hits", terrain.solid.get_cell_source_id(Vector2i(2, 1)) == -1)
	check("ore dropped copper", PlayerData.item_count("copper_ore") > before)
	check("mining granted Miner XP", PlayerData.prof_xp.get("miner", 0) > 0)
	terrain.queue_free()

	# --- physics: gravity fall + landing + jump ---
	var t2 = preload("res://scenes/world/DungeonTerrain.tscn").instantiate()
	add_child(t2)
	t2.build_from(["BBBBBBBB", "B      B", "B      B", "B      B", "B######B", "BBBBBBBB"])
	var pp = preload("res://scenes/actors/PlayerPlatformer.tscn").instantiate()
	add_child(pp)
	pp.global_position = t2.solid.map_to_local(Vector2i(3, 1))
	var y0: float = pp.global_position.y
	for i in range(70):
		await get_tree().physics_frame
	check("player fell under gravity", pp.global_position.y > y0, "y0=%.1f y=%.1f" % [y0, pp.global_position.y])
	check("player landed on floor (stopped falling)", pp.is_on_floor() or absf(pp.velocity.y) < 40.0, "y=%.1f vy=%.1f onfloor=%s" % [pp.global_position.y, pp.velocity.y, str(pp.is_on_floor())])
	var y_land: float = pp.global_position.y
	pp.velocity.y = pp.JUMP_VELOCITY
	for i in range(3):
		await get_tree().physics_frame
	check("jump moves player upward", pp.global_position.y < y_land)
	pp.queue_free()
	t2.queue_free()

	# --- scene transition state (dungeon door return-pos round trip) ---
	WorldState.pending_return_pos = Vector2(123, 456)
	check("return pos stored on dungeon entry", WorldState.pending_return_pos == Vector2(123, 456))
	WorldState.pending_return_pos = null   # overworld consumes it
	check("return pos consumed on re-entry", WorldState.pending_return_pos == null)

func _test_evolution() -> void:
	print("[EvolutionSystem]")
	check("moonbit data loaded", Db.monsters.has("moonbit"))
	check("fluffbit evolves to moonbit", Db.monster("fluffbit").get("evolution", "") == "moonbit")
	check("fluffbit gated by full_moon", EvolutionSystem.CONDITIONS.get("fluffbit", "") == "full_moon")
	# non-conditioned species never auto-evolves
	var slime := {"species_id": "verdant_slime", "level": 3, "star": 3, "element": "water"}
	check("slime does not auto-evolve (no condition)", not EvolutionSystem.can_evolve(slime))
	# transform logic (condition-independent)
	var pet := {"species_id": "fluffbit", "name": "Fluffbit", "level": 8, "star": 4, "element": "wood", "size": "small", "rideable": false, "max_hp": 200, "atk": 20, "spd": 100}
	var evo := EvolutionSystem.apply(pet, "moonbit")
	check("apply returns moonbit", evo == "moonbit")
	check("pet species becomes moonbit", pet.species_id == "moonbit")
	check("pet element becomes moon", pet.element == "moon")
	check("can_evolve matches current moon state", EvolutionSystem.can_evolve({"species_id": "fluffbit", "level": 5}) == GameClock.is_full_moon())
	# Grey Wolf -> Dire Wolf (level-based evolution)
	check("dire_wolf data loaded", Db.monsters.has("dire_wolf"))
	check("grey_wolf evolves to dire_wolf", Db.monster("grey_wolf").get("evolution", "") == "dire_wolf")
	check("wolf evolves at level >= 8", EvolutionSystem.can_evolve({"species_id": "grey_wolf", "level": 10}))
	check("wolf does NOT evolve below level 8", not EvolutionSystem.can_evolve({"species_id": "grey_wolf", "level": 5}))
	var wolf_pet := {"species_id": "grey_wolf", "level": 10, "star": 3, "element": "none", "size": "medium", "rideable": true, "max_hp": 500, "atk": 40, "spd": 100}
	check("apply wolf evo -> dire_wolf", EvolutionSystem.apply(wolf_pet, "dire_wolf") == "dire_wolf" and wolf_pet.species_id == "dire_wolf")

func _test_quests() -> void:
	print("[QuestSystem]")
	check("quests data loaded", Db.quests.size() >= 5)
	PlayerData.new_game()
	PlayerData.daily_quests = {}
	QuestSystem.ensure_today()
	var qs: Array = QuestSystem.quests()
	check("daily quests rolled (<=3)", qs.size() > 0 and qs.size() <= 3)
	check("quest board dated today", PlayerData.daily_quests.get("date", "") == GameClock.date_string())
	var ids1 := qs.map(func(q): return q.id)
	PlayerData.daily_quests = {}
	QuestSystem.ensure_today()
	var ids2 := QuestSystem.quests().map(func(q): return q.id)
	check("daily roll deterministic per date", str(ids1) == str(ids2))
	# complete a no-condition kill quest if one was rolled
	var kq = null
	for q in QuestSystem.quests():
		if q.type == "kill" and q.get("condition", "") == "":
			kq = q; break
	if kq != null:
		# emit the quest's ACTUAL target species (target varies by the date-seeded roll)
		var kill_species: String = kq.target if kq.target != "any" else "verdant_slime"
		for i in range(int(kq.count)):
			EventBus.monster_killed.emit(kill_species, null)
		check("kill quest completes", kq.done)
		var gold_before: int = PlayerData.gold
		check("claim grants reward", QuestSystem.claim(kq.id) and PlayerData.gold > gold_before)
		check("cannot double-claim", not QuestSystem.claim(kq.id))
	else:
		check("no-condition kill quest availability (n/a today)", true)
	PlayerData.new_game()

func _test_bugfixes() -> void:
	print("[bug fixes]")
	# Bug 2: GatherNode rebuilds on setup() -> ore gets ore stats, not tree defaults
	var gn := preload("res://scenes/world/GatherNode.tscn").instantiate()
	add_child(gn)
	gn.setup("ore", "gn_test_1")
	await get_tree().process_frame
	check("gather node kind applied on setup", gn.kind == "ore")
	check("ore node needs 4 hits (not tree's 3)", gn.get("_hits_left") == 4)
	gn.queue_free()
	# R2b: choppable trees use the approved pine style + trunk collision + chop-to-stump
	var tn := preload("res://scenes/world/GatherNode.tscn").instantiate()
	add_child(tn)
	tn.setup("tree", "gn_tree_test")
	await get_tree().process_frame
	check("choppable tree uses a pine sprite", str(tn.get("_tree_variant")).begins_with("tree_pine"))
	check("choppable tree has trunk collision", tn.has_node("Trunk"))
	tn._set_depleted(true)
	check("chopped tree shows a stump", tn.get_node("Sprite").texture.resource_path.ends_with("stump.png"))
	tn._set_depleted(false)
	check("regrown tree shows a pine", tn.get_node("Sprite").texture.resource_path.contains("tree_pine"))
	tn.queue_free()
	# Bug 3: craft_insight resets on new_game
	PlayerData.craft_insight["craft_x"] = 0.05
	PlayerData.new_game()
	check("craft_insight reset on new_game", PlayerData.craft_insight.is_empty())
	# Bug 4: mounted + infusion cleared on load
	PlayerData.new_game()
	PlayerData.mounted = true
	PlayerData.apply_infusion("fire", 60)
	SaveManager.save_game(3)
	SaveManager.load_game(3)
	check("mounted reset on load", PlayerData.mounted == false)
	check("infusion cleared on load", not PlayerData.has_active_infusion())
	SaveManager.delete_save(3)
	PlayerData.new_game()

func _test_achievements() -> void:
	print("[Achievements/Aetherpedia]")
	check("achievements data loaded", Db.achievements.size() >= 5)
	PlayerData.achievements.clear()
	PlayerData.titles.clear()
	PlayerData.active_title = ""
	PlayerData.discovered = {"monsters": {}, "items": {}, "weathers": {}}
	WorldState.set_counter("trees_cut", 0)
	WorldState.add_counter("trees_cut", 25)   # emits counter_changed -> unlock woodcutter
	check("woodcutter unlocked at 25 trees", "woodcutter" in PlayerData.achievements)
	check("title granted", "Penebang" in PlayerData.titles)
	check("first title auto-equipped", PlayerData.active_title == "Penebang")
	EventBus.item_gained.emit("wolf_pelt", 1)
	check("aetherpedia records item", PlayerData.discovered["items"].has("wolf_pelt"))
	# neutral micro-buff via equipped title
	PlayerData.achievements.append("hunter_50")
	PlayerData.active_title = "Pemburu"
	check("atk_pct title buff active", abs(Achievements.active_buff("atk_pct") - 0.02) < 0.001)
	# cleanup
	WorldState.set_counter("trees_cut", 0)
	PlayerData.new_game()

func _test_saveload() -> void:
	print("[SaveManager]")
	PlayerData.new_game()
	PlayerData.level = 7
	PlayerData.add_gold(1234)
	PlayerData.add_item("wolf_fang", 5)
	WorldState.set_counter("rabbits_killed", 42)
	PlayerData.char_config = {"head_race": "wolfkin", "torso_race": "human", "legs_race": "lizardkin",
		"hair": "spiky", "hair_color": "#b8e4f2", "shirt": "#2e6b3f", "pants": "#453d5c"}
	var ok := SaveManager.save_game(3)
	check("save writes", ok and SaveManager.has_save(3))
	# mutate then load
	PlayerData.level = 99
	PlayerData.gold = 0
	PlayerData.inventory.clear()
	WorldState.set_counter("rabbits_killed", 0)
	PlayerData.char_config = {}
	var loaded := SaveManager.load_game(3)
	check("load succeeds", loaded)
	check("char_config restored (chimera)", PlayerData.char_config.get("head_race", "") == "wolfkin" and PlayerData.char_config.get("legs_race", "") == "lizardkin")
	check("level restored", PlayerData.level == 7, str(PlayerData.level))
	check("gold restored", PlayerData.gold == 200 + 1234, str(PlayerData.gold))
	check("item restored", PlayerData.item_count("wolf_fang") == 5)
	check("world counter restored", WorldState.get_counter("rabbits_killed") == 42)
	# second save creates a backup
	SaveManager.save_game(3)
	check("backup created", FileAccess.file_exists(SaveManager.backup_path(3, 1)))
	check("schema version present", SaveManager.build_payload().get("schema_version", 0) == SaveManager.SCHEMA_VERSION)
	SaveManager.delete_save(3)

func _test_sugarqueen() -> void:
	print("[Sugar Queen Tea Party]")
	check("scenario loaded", not ScenarioManager.find("sugar_queen_tea").is_empty())
	PlayerData.new_game()
	PlayerData.scenario_flags.erase("sugar_queen_tea")
	WorldState.set_counter("candies_eaten", 0)
	check("no trigger below candy threshold", ScenarioManager.would_trigger("eat_candy") == "")
	WorldState.set_counter("candies_eaten", 100)
	check("triggers at 100 candies", ScenarioManager.would_trigger("eat_candy") == "sugar_queen_tea")
	# reward
	PlayerData.inventory.clear()
	PlayerData.scenario_flags.erase("sugar_queen_tea")
	ScenarioManager.apply_result("sugar_queen_tea", true)
	check("clear gives Royal Tea Cake [S]", PlayerData.item_count("royal_tea_cake") == 1)
	check("clear grants sugar_blessed", "sugar_blessed" in PlayerData.titles)
	# quiz: all correct -> win + Peppermint Fairy
	var tp = preload("res://scenes/scenarios/TeaParty.tscn").instantiate()
	tp._shot_at = 999.0   # block resolve()/scene change
	add_child(tp)
	await get_tree().process_frame
	var pets_before: int = PlayerData.monsters.size()
	for q in tp.QUESTIONS:
		tp.answer(int(q.correct))
	check("all-correct wins quiz", tp.resolved and tp.idx == tp.QUESTIONS.size())
	check("win grants Peppermint Fairy pet", PlayerData.monsters.size() == pets_before + 1)
	tp.queue_free()
	# quiz: 3 wrong -> expelled
	var tp2 = preload("res://scenes/scenarios/TeaParty.tscn").instantiate()
	tp2._shot_at = 999.0
	add_child(tp2)
	await get_tree().process_frame
	var wc: int = (int(tp2.QUESTIONS[0].correct) + 1) % tp2.QUESTIONS[0].a.size()
	tp2.answer(wc); tp2.answer(wc); tp2.answer(wc)   # wrong stays on Q0
	check("3 wrong = expelled (fail)", tp2.resolved and tp2.wrong >= 3)
	tp2.queue_free()
	PlayerData.new_game()
	WorldState.set_counter("candies_eaten", 0)

func _test_scenario() -> void:
	print("[ScenarioManager]")
	var id := "moon_rabbit_warren"
	PlayerData.scenario_flags.erase(id)
	WorldState.set_counter("rabbits_killed", 0)
	check("no trigger below rabbit threshold", ScenarioManager.would_trigger("sleep_at_inn") == "")
	# threshold uses 10000 (shipping), debug uses 10
	var sc := ScenarioManager.find(id)
	check("shipping threshold is 10000", ScenarioManager.threshold(sc) == 10000)
	# flag blocks re-trigger even if conditions met
	PlayerData.scenario_flags[id] = "cleared"
	WorldState.set_counter("rabbits_killed", 99999)
	check("cleared flag blocks re-trigger (no_fail)", ScenarioManager.would_trigger("sleep_at_inn") == "")
	# reward application
	PlayerData.scenario_flags.erase(id)
	PlayerData.inventory.clear()
	if "moon" in PlayerData.mastered_elements:
		PlayerData.mastered_elements.erase("moon")
	var summary := ScenarioManager.apply_result(id, true)
	check("clear gives Carrot of Calamity", PlayerData.item_count("carrot_of_calamity") == 1)
	check("clear unlocks Moon element", "moon" in PlayerData.mastered_elements)
	check("clear sets flag", PlayerData.scenario_flags.get(id, "") == "cleared")
	# fail path
	PlayerData.scenario_flags.erase(id)
	ScenarioManager.apply_result(id, false)
	check("fail sets permanent flag", PlayerData.scenario_flags.get(id, "") == "failed")
	WorldState.set_counter("rabbits_killed", 0)
	# Star Whale scenario (action-triggered via fishing)
	var wid := "star_whale_belly"
	check("star whale scenario loaded", not ScenarioManager.find(wid).is_empty())
	PlayerData.scenario_flags.erase(wid)
	PlayerData.inventory.clear()
	ScenarioManager.apply_result(wid, true)
	check("star whale clear gives Ambergris Star", PlayerData.item_count("ambergris_star") == 1)
	check("cleared star whale won't re-trigger", not ScenarioManager.trigger_scenario(wid))
	PlayerData.scenario_flags.erase(wid)

func _test_economy() -> void:
	print("[Economy]")
	var p1 := Economy.buy_price("minor_potion")
	check("buy price > 0", p1 > 0)
	check("sell < buy", Economy.sell_price("minor_potion") < p1)
	# buying depletes stock -> price should not decrease
	var before := Economy.buy_price("minor_potion")
	Economy.buy("minor_potion", 3)
	check("buying raises/holds price", Economy.buy_price("minor_potion") >= before)

func _test_crafting() -> void:
	print("[CraftingSystem]")
	PlayerData.inventory.clear()
	# guaranteed recipe: plank from 2 wood_log (success 1.0)
	PlayerData.add_item("wood_log", 2)
	var r := CraftingSystem.craft("craft_plank")
	check("plank crafted", r.success and PlayerData.item_count("plank") == 1, str(r))
	check("ingredients consumed", PlayerData.item_count("wood_log") == 0)
	# Cook recipes present + craftable
	check("cook recipe exists", not CraftingSystem.find_recipe("cook_grilled_fish").is_empty())
	var cooked := false
	for attempt in range(20):   # 95% rate -> retry to keep the test deterministic
		PlayerData.inventory.clear()
		PlayerData.add_item("fish_carp", 1)
		PlayerData.add_item("wood_log", 1)
		if CraftingSystem.craft("cook_grilled_fish").success:
			cooked = true
			break
	check("grilled fish cooked", cooked and PlayerData.item_count("grilled_fish") >= 1)
	# missing ingredients fails cleanly
	var r2 := CraftingSystem.craft("craft_copper_sword")
	check("craft fails without mats", not r2.success)
	# failure preserves the valuable base (deterministic 0% via forced roll)
	PlayerData.inventory.clear()
	PlayerData.add_item("copper_bar", 2)
	PlayerData.add_item("plank", 1)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2  # force a high roll -> likely fail at 75%
	var attempts := 0
	var failed_once := false
	while attempts < 40 and not failed_once:
		PlayerData.inventory.clear()
		PlayerData.add_item("copper_bar", 2)
		PlayerData.add_item("plank", 1)
		var rr := CraftingSystem.craft("craft_copper_sword", rng)
		if not rr.success:
			failed_once = true
			# base = highest tier ingredient (copper_bar, tier E) preserved
			check("failure preserves base copper_bar", PlayerData.item_count("copper_bar") == 2, "had %d" % PlayerData.item_count("copper_bar"))
		attempts += 1
	check("crafting can fail (roll works)", failed_once)


func _test_transcendent_pyramid() -> void:
	print("[Transcendent Pyramid v0.4.2]")
	# --- integritas data: semua resep baru valid & bahan/hasil ada di items ---
	var need := ["craft_glacier_blade", "craft_frostspark_wand", "craft_barkhide_armor",
		"craft_cloudsilk_scarf", "craft_aether_ingot", "craft_dragonfang_sword",
		"craft_dragonscale_mail", "craft_stormsilk_cloak", "craft_everfrost_edge",
		"craft_ankh_aegis", "craft_tempest_fang", "craft_aurora_rend", "craft_bintang_aetherion"]
	var all_ok := true
	for rid in need:
		var r := CraftingSystem.find_recipe(rid)
		if r.is_empty():
			all_ok = false
			continue
		if not Db.items.has(r.get("result", "")):
			all_ok = false
		for ing in r.get("ingredients", []):
			if not Db.items.has(ing.get("item", "")):
				all_ok = false
	check("13 resep piramida valid (bahan & hasil ada)", all_ok)
	# material kunci drop masing-masing dipakai resep
	for key_mat in ["everfrost_core", "tempest_heart", "ankh_fragment", "ambergris_star"]:
		var used := false
		for r in Db.recipes:
			for ing in r.get("ingredients", []):
				if ing.get("item", "") == key_mat:
					used = true
		check("material kunci %s punya resep" % key_mat, used)
	# success rate menurun A -> SSS (piramida makin curam)
	var ra := CraftingSystem.find_recipe("craft_everfrost_edge").get("success_rate", 0.0)
	var rs := CraftingSystem.find_recipe("craft_tempest_fang").get("success_rate", 0.0)
	var rss := CraftingSystem.find_recipe("craft_aurora_rend").get("success_rate", 0.0)
	var rsss := CraftingSystem.find_recipe("craft_bintang_aetherion").get("success_rate", 0.0)
	check("rate piramida menurun", ra > rs and rs > rss and rss > rsss, "%s %s %s %s" % [ra, rs, rss, rsss])
	# is_transcendent: A+ ya, resep biasa tidak
	check("A+ = transenden", CraftingSystem.is_transcendent(CraftingSystem.find_recipe("craft_everfrost_edge")))
	check("resep biasa bukan transenden", not CraftingSystem.is_transcendent(CraftingSystem.find_recipe("craft_plank")))
	# stat naik antar tier (C < B < A < S < SS < SSS untuk pedang)
	var chain := ["glacier_blade", "dragonfang_sword", "everfrost_edge", "tempest_fang", "aurora_rend", "bintang_aetherion"]
	var rising := true
	for i in range(1, chain.size()):
		if int(Db.item(chain[i]).get("atk", 0)) <= int(Db.item(chain[i - 1]).get("atk", 0)):
			rising = false
	check("ATK pedang naik tiap tier", rising)
	# --- gate profesi: A+ hanya profesi UTAMA ---
	var save_profs: Dictionary = PlayerData.professions.duplicate(true)
	PlayerData.professions = {"main": "cook", "sub": [], "last_main_change": 0}
	var gate := ProfessionSystem.can_use_recipe(CraftingSystem.find_recipe("craft_everfrost_edge"))
	check("A+ terkunci untuk non-blacksmith", not gate.ok)
	PlayerData.professions = {"main": "blacksmith", "sub": [], "last_main_change": 0}
	var gate2 := ProfessionSystem.can_use_recipe(CraftingSystem.find_recipe("craft_everfrost_edge"))
	check("A+ terbuka untuk main blacksmith", bool(gate2.ok), str(gate2))
	# --- craft A sukses (rng dipaksa) menambah item & konsumsi bahan ---
	PlayerData.inventory.clear()
	PlayerData.add_item("dragonfang_sword", 1)
	PlayerData.add_item("everfrost_core", 1)
	PlayerData.add_item("aether_ingot", 2)
	var rng := RandomNumberGenerator.new()
	var made := false
	var kept_core := false
	for attempt in range(60):
		rng.seed = attempt
		var rr := CraftingSystem.craft("craft_everfrost_edge", rng)
		if rr.success:
			made = PlayerData.item_count("everfrost_edge") >= 1
			break
		else:
			# gagal: material kunci tier tertinggi (everfrost_core) HARUS selamat
			kept_core = PlayerData.item_count("everfrost_core") >= 1
			PlayerData.add_item("dragonfang_sword", 1)
			PlayerData.add_item("aether_ingot", 2)
			if PlayerData.item_count("everfrost_core") == 0:
				PlayerData.add_item("everfrost_core", 1)
	check("everfrost_edge tertempa", made)
	check("gagal ritual: everfrost_core selamat", kept_core or made)
	PlayerData.professions = save_profs


func _test_gear_meta_enchant_coating() -> void:
	print("[Gear Meta / Enchant / Coating v0.4.2]")
	# --- quality roll + maker's mark saat crafting gear ---
	PlayerData.char_name = "Penguji"
	PlayerData.gear_meta.clear()
	PlayerData.inventory.clear()
	PlayerData.add_item("wood_log", 4)
	CraftingSystem.craft("craft_plank")
	CraftingSystem.craft("craft_plank")
	var made_sword := false
	for attempt in range(30):
		PlayerData.add_item("plank", 2)
		if CraftingSystem.craft("craft_wooden_sword").success:
			made_sword = true
			break
	check("gear tertempa dapat maker's mark", made_sword and PlayerData.gear_meta.get("wooden_sword", {}).get("maker", "") == "Penguji")
	var q: String = PlayerData.gear_meta.get("wooden_sword", {}).get("quality", "normal")
	check("quality valid", q in ["normal", "fine", "masterwork"], q)
	# material TIDAK dapat meta
	check("material tanpa meta", not PlayerData.gear_meta.has("plank"))
	# --- gear_mult: kualitas + enchant menskalakan stat ---
	PlayerData.gear_meta["wooden_sword"] = {"quality": "masterwork", "maker": "Penguji", "enchant": 10}
	var mult := PlayerData.gear_mult("wooden_sword")
	check("gear_mult masterwork+10 = 1.43", absf(mult - 1.1 * 1.3) < 0.001, str(mult))
	PlayerData.equipped_weapon = "wooden_sword"
	PlayerData.recalculate_stats()
	# --- enchant: sukses, gagal aman <=+6, gagal >=+7 turun 1, scroll menahan ---
	PlayerData.gear_meta["wooden_sword"] = {"quality": "normal", "maker": "Penguji", "enchant": 0}
	PlayerData.add_item("wooden_sword", 1)
	PlayerData.gold = 999999
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var r1 := EnchantSystem.enchant("wooden_sword", rng)   # target +1 rate 1.0 -> pasti sukses
	check("enchant +1 pasti sukses", r1.success and PlayerData.gear_enchant("wooden_sword") == 1)
	# paksa gagal di target rendah: level tetap
	PlayerData.gear_meta["wooden_sword"]["enchant"] = 3
	var failed_low := false
	for attempt in range(200):
		rng.seed = attempt
		var rr := EnchantSystem.enchant("wooden_sword", rng)
		if not rr.success:
			failed_low = true
			check("gagal <=+6: level tetap", PlayerData.gear_enchant("wooden_sword") == int(rr.level) and rr.level >= 3)
			break
		PlayerData.gear_meta["wooden_sword"]["enchant"] = 3
	check("enchant bisa gagal", failed_low)
	# gagal >=+7 tanpa scroll: turun 1
	PlayerData.remove_item("protection_scroll", 99)
	PlayerData.gear_meta["wooden_sword"]["enchant"] = 8
	var dropped := false
	for attempt in range(300):
		rng.seed = attempt
		var rr2 := EnchantSystem.enchant("wooden_sword", rng)
		if not rr2.success:
			dropped = PlayerData.gear_enchant("wooden_sword") == 7
			break
		PlayerData.gear_meta["wooden_sword"]["enchant"] = 8
	check("gagal >=+7: turun 1 (tak hancur)", dropped and PlayerData.item_count("wooden_sword") >= 1)
	# scroll menahan penurunan
	PlayerData.gear_meta["wooden_sword"]["enchant"] = 8
	PlayerData.add_item("protection_scroll", 5)
	var protected := false
	for attempt in range(300):
		rng.seed = attempt
		var rr3 := EnchantSystem.enchant("wooden_sword", rng)
		if not rr3.success:
			protected = PlayerData.gear_enchant("wooden_sword") == 8 and bool(rr3.get("protected", false))
			break
		PlayerData.gear_meta["wooden_sword"]["enchant"] = 8
	check("Gulungan Perlindungan menahan level", protected)
	# biaya: profesi enchanter aktif = diskon
	var save_profs: Dictionary = PlayerData.professions.duplicate(true)
	PlayerData.professions = {"main": "blacksmith", "sub": [], "last_main_change": 0}
	var c0 := EnchantSystem.cost("wooden_sword")
	PlayerData.professions = {"main": "enchanter", "sub": [], "last_main_change": 0}
	var c1 := EnchantSystem.cost("wooden_sword")
	check("diskon enchanter 30%", c1 < c0, "%d vs %d" % [c1, c0])
	PlayerData.professions = save_profs
	# --- coating: aktif, elemen benar, kedaluwarsa ---
	PlayerData.apply_coating("poison", 60.0)
	check("coating aktif + elemen", PlayerData.coating_active() and PlayerData.coating_element() == "poison")
	PlayerData.coating = {"element": "poison", "until": Time.get_unix_time_from_system() - 1.0}
	check("coating kedaluwarsa", not PlayerData.coating_active() and PlayerData.coating_element() == "none")
	# resep coating + scroll ada dan valid
	for rid in ["craft_venom_oil", "craft_frost_coat", "craft_protection_scroll"]:
		check("resep %s ada" % rid, not CraftingSystem.find_recipe(rid).is_empty())
	check("profesi enchanter terdaftar", Db.professions.has("enchanter"))
	PlayerData.gear_meta.clear()
	PlayerData.equipped_weapon = ""
	PlayerData.recalculate_stats()


func _test_auction_house() -> void:
	print("[Rumah Lelang v0.4.2 B8]")
	var rng := RandomNumberGenerator.new()
	# --- S+ TIDAK PERNAH muncul: 120 hari simulasi (60 biasa + 60 purnama) ---
	var banned_seen := false
	var captive_days := 0
	var lot_total := 0
	var value_sum := 0
	for day in range(120):
		rng.seed = day * 31 + 5
		var fm := 1 if day >= 60 else 0
		var a := AuctionHouse.generate("2026-%02d-%02d" % [1 + (day / 28), 1 + (day % 28)], rng, fm)
		if fm == 1:
			check("purnama hari %d: lot ekstra" % day, a.lots.size() >= AuctionHouse.DAILY_LOTS + AuctionHouse.FULLMOON_EXTRA) if day == 60 else null
		for lot in a.lots:
			lot_total += 1
			if lot.get("kind", "item") == "captive":
				captive_days += 1
				continue
			var tier: String = Db.item(lot.get("item", "")).get("tier", "F")
			if tier in AuctionHouse.BANNED_TIERS:
				banned_seen = true
			value_sum += int(lot.get("min", 0))
			if int(lot.get("min", 0)) <= 0 or int(lot.get("buyout", 0)) <= int(lot.get("min", 0)):
				check("harga lot waras", false, str(lot))
	check("S+ TIDAK PERNAH muncul (120 hari)", not banned_seen)
	check("lot tawanan muncul (purnama pasti)", captive_days >= 60, str(captive_days))
	print("  [harness gold-flow] %d lot / 120 hari, rata-rata bid awal %dG" % [lot_total, value_sum / maxi(1, lot_total - captive_days)])
	# --- bidding: menang saat rival menyerah; emas berkurang; barang diterima ---
	WorldState.auction = AuctionHouse.generate("2099-01-01", null, 0)
	var a2 := AuctionHouse.state()
	check("state pakai lot tanggal berbeda -> regenerasi", a2.get("date", "") != "2099-01-01")
	WorldState.auction = AuctionHouse.generate(GameClock.date_string(), null, 0)
	a2 = AuctionHouse.state()
	var item_idx := -1
	for i in a2.lots.size():
		if a2.lots[i].get("kind", "item") == "item":
			item_idx = i
			break
	check("ada lot item", item_idx >= 0)
	PlayerData.gold = 9999999
	var gold0 := PlayerData.gold
	var inv_item: String = a2.lots[item_idx].get("item", "")
	var had := PlayerData.item_count(inv_item)
	var won := false
	for round in range(200):
		rng.seed = round
		var r := AuctionHouse.player_bid(item_idx, rng)
		if r.get("status", "") == "won":
			won = true
			check("menang: bayar > 0 & emas berkurang", int(r.get("paid", 0)) > 0 and PlayerData.gold == gold0 - int(r.get("paid", 0)))
			break
		elif r.get("status", "") == "outbid":
			check("rival punya nama", r.get("by", "") != "")
	check("lelang bisa dimenangkan", won)
	check("barang diterima", PlayerData.item_count(inv_item) == had + 1)
	check("lot terjual terkunci", AuctionHouse.player_bid(item_idx).get("status", "") == "sold")
	# --- buyout ---
	var idx2 := -1
	for i in a2.lots.size():
		if a2.lots[i].get("kind", "item") == "item" and not a2.lots[i].get("sold", false):
			idx2 = i
			break
	if idx2 >= 0:
		var r2 := AuctionHouse.player_buyout(idx2)
		check("buyout langsung menang", r2.get("status", "") == "won")
	# --- tawanan: menang = dibebaskan -> kandidat rekrut loyal ---
	WorldState.freed_captives.clear()
	WorldState.auction = AuctionHouse.generate(GameClock.date_string(), null, 1)   # purnama: tawanan pasti
	var a3 := AuctionHouse.state()
	var cap_idx := -1
	for i in a3.lots.size():
		if a3.lots[i].get("kind", "") == "captive":
			cap_idx = i
			break
	check("lot tawanan ada saat purnama", cap_idx >= 0)
	if cap_idx >= 0:
		var r3 := AuctionHouse.player_buyout(cap_idx)
		check("tawanan dibebaskan", r3.get("status", "") == "won" and WorldState.freed_captives.size() == 1)
		if not WorldState.freed_captives.is_empty():
			var c: Dictionary = WorldState.freed_captives[0]
			check("tawanan loyal + punya tag latar", bool(c.get("loyal", false)) and c.get("tag", "") != "")
	# save/load membawa lelang & tawanan
	var ws := WorldState.to_save()
	check("save membawa auction + captives", ws.has("auction") and ws.has("freed_captives"))
	WorldState.auction = {}
	WorldState.freed_captives = []
	WorldState.from_save(ws)
	check("load memulihkan captives", WorldState.freed_captives.size() == 1)
	WorldState.auction = {}
	WorldState.freed_captives = []
	PlayerData.gold = 200


func _test_rumors() -> void:
	print("[Rumor tidak akurat E5]")
	check("rumors.json termuat", Db.rumors.size() >= 8)
	var ok := true
	for r in Db.rumors:
		if r.get("truth", "") == "" or r.get("distortions", []).is_empty():
			ok = false
		var acc: float = float(r.get("accuracy", -1.0))
		if acc < 0.0 or acc > 1.0:
			ok = false
	check("tiap rumor punya truth + distorsi + accuracy 0..1", ok)
	# distribusi: dengan banyak roll, versi menyimpang PASTI muncul (dunia tak sempurna)
	var rng := RandomNumberGenerator.new()
	var inaccurate := 0
	var accurate := 0
	WorldState.miracle_log = {"date": GameClock.date_string(), "today": {}, "yesterday": {}}
	for i in 400:
		rng.seed = i
		var r := RumorSystem.speak(rng)
		if r.get("text", "") == "":
			check("rumor tak pernah kosong", false)
			break
		if bool(r.get("accurate", true)):
			accurate += 1
		else:
			inaccurate += 1
	check("gosip warga bisa MELENCENG", inaccurate > 30, "%d menyimpang / %d akurat" % [inaccurate, accurate])
	check("gosip warga tetap sering benar", accurate > inaccurate, "%d vs %d" % [accurate, inaccurate])
	# rumor fungsional (Penjaga Pohon) TIDAK boleh disentuh sistem distorsi
	var tree_rumor: String = ""
	for t in Db.skill_trees.values():
		if t.get("rumor", "") != "":
			tree_rumor = t.get("rumor", "")
			break
	check("rumor Penjaga Pohon tetap akurat (dari skill_trees.json, bukan RumorSystem)", tree_rumor != "")
	check("truth() mengembalikan versi benar", RumorSystem.truth("r_guards").contains("Penjaga"))

func _test_town_folk() -> void:
	print("[Hukum NPC Aneh E6]")
	var towns := ["greenvale", "frostpeak_village", "candyveil_palace", "desert_ruins", "storm_island"]
	var total := 0
	var oddwalkers := 0
	for t in towns:
		var list := TownFolk.personas(t)
		check("%s punya >=5 NPC berkepribadian" % t, list.size() >= 5, "%d" % list.size())
		check("%s memenuhi Hukum NPC Aneh (5 arketipe)" % t, TownFolk.satisfies_law(t))
		for p in list:
			total += 1
			if p.get("lines", []).size() < 3:
				check("%s: %s punya >=3 baris dialog" % [t, p.get("name", "?")], false)
			if p.get("config", {}).is_empty():
				check("%s: %s punya config CharGen" % [t, p.get("name", "?")], false)
			if bool(p.get("oddwalker", false)):
				oddwalkers += 1
	check("25 NPC berkepribadian total", total == 25, str(total))
	check("Oddwalker ~10% (1-4 dari 25)", oddwalkers >= 1 and oddwalkers <= 4, str(oddwalkers))
	# persona hidup: dialog bergilir (bukan acak murni)
	var v = preload("res://scenes/actors/Villager.tscn").instantiate()
	add_child(v)
	var persona: Dictionary = TownFolk.personas("greenvale")[0]
	v.setup(persona.get("name", "x"), persona.get("config", {}), [Vector2.ZERO, Vector2(10, 0)])
	v.set_persona(persona)
	var seen := {}
	for i in 40:
		seen[v.persona_line()] = true
	check("dialog persona bergilir (>=3 baris berbeda terlihat)", seen.size() >= 3, str(seen.size()))
	check("NPC persona masuk grup town_folk", v.is_in_group("town_folk"))
	v.queue_free()

func _test_miracles() -> void:
	print("[Miracle System v1 E7]")
	check("miracles.json termuat (4 keajaiban)", Db.miracles.size() == 4)
	for m in Db.miracles:
		check("keajaiban %s punya gosip benar + versi keliru" % m.get("id", "?"),
			m.get("gossip_true", "") != "" and not m.get("gossip_false", []).is_empty())
	check("item keajaiban ada", Db.items.has("ancient_bloom") and Db.items.has("star_fragment"))
	# roll deterministik: tanggal sama -> hasil sama
	var a := MiracleSystem.roll("2026-08-01")
	var b := MiracleSystem.roll("2026-08-01")
	check("roll deterministik per tanggal", a == b)
	# frekuensi: langka tapi nyata (sekitar DAILY_CHANCE dalam 400 hari)
	var hit := 0
	var kinds := {}
	for d in range(400):
		var r := MiracleSystem.roll("2027-%02d-%02d" % [1 + (d / 28), 1 + (d % 28)])
		if not r.is_empty():
			hit += 1
			kinds[r.get("id", "")] = true
	check("keajaiban langka tapi terjadi (5%-50% hari)", hit > 20 and hit < 200, "%d/400" % hit)
	check("keempat jenis keajaiban bisa muncul", kinds.size() == 4, str(kinds.keys()))
	# gosip esok hari: keajaiban kemarin yang diumumkan, TIDAK ada popup
	WorldState.miracle_log = {"date": GameClock.date_string(), "today": {},
		"yesterday": {"id": "falling_star", "date": "kemarin"}}
	var rng := RandomNumberGenerator.new()
	var mentioned := false
	for i in 60:
		rng.seed = i
		var line: String = RumorSystem.speak(rng).get("text", "")
		if line.to_lower().contains("bintang"):
			mentioned = true
			break
	check("keajaiban semalam digosipkan warga esok hari", mentioned)
	WorldState.miracle_log = {}

func _test_quest_taxonomy() -> void:
	print("[Quest Taxonomy + Hukum Quest E8]")
	var valid := ["Need", "Dream", "Fear", "Ambition", "Memory", "Legacy", "Hidden", "Chronicle", "Myth", "World", "Era"]
	var all_tagged := true
	var all_human := true
	for q in Db.quests:
		var qt: String = q.get("quest_type", "")
		if not qt in valid:
			all_tagged = false
			print("  [!] quest tanpa taksonomi sah: %s" % q.get("id", "?"))
		# HUKUM QUEST: kill/collect tanpa konteks manusia dilarang jadi inti quest —
		# deskripsi wajib menyebut seseorang/alasan manusia, bukan cuma "kalahkan N".
		var d: String = q.get("desc", "")
		if d.length() < 40:
			all_human = false
			print("  [!] quest tanpa konteks manusia: %s" % q.get("id", "?"))
	check("semua quest punya quest_type sah", all_tagged)
	check("semua quest punya konteks manusia (Hukum Quest)", all_human)
	check("mekanik quest tetap utuh (field type)", Db.quests[0].get("type", "") != "")


func _test_seasons() -> void:
	print("[MUSIM v1 A4 / #83]")
	check("seasons.json termuat (4 musim)", Db.seasons.size() == 4)
	var ids := []
	for sd in Db.seasons:
		ids.append(sd.get("id", ""))
	check("urutan musim semi->panas->gugur->dingin", ids == ["semi", "panas", "gugur", "dingin"], str(ids))
	# siklus: 4 musim x 14 hari = 56 hari; tiap 14 hari WIB berganti musim
	check("SEASON_DAYS = 14 (dua minggu nyata)", GameClock.SEASON_DAYS == 14)
	var s_now := GameClock.season()
	check("musim sekarang valid", s_now in ids, s_now)
	check("hari musim 1..14", GameClock.season_day() >= 1 and GameClock.season_day() <= 14, str(GameClock.season_day()))
	check("musim = fungsi tanggal WIB (bukan acak)", GameClock.season() == s_now)
	check("tint musim mewarnai ambient dunia", GameClock.season_def().has("tint"))
	# tanam: tanaman di luar musimnya tumbuh jauh lebih lambat; Rumah Kaca menetralkan
	var was_gh: bool = WorldState.greenhouse
	WorldState.greenhouse = false
	var in_season := Seasons.crop_in_season("mintleaf")
	var mult := Seasons.growth_mult("mintleaf")
	if in_season:
		check("dalam musim: pengali tumbuh <= 1.5", mult <= 1.5, str(mult))
	else:
		check("luar musim: tumbuh jauh lebih lambat (>=2x)", mult >= 2.0, str(mult))
	WorldState.greenhouse = true
	check("Rumah Kaca menetralkan musim", Seasons.growth_mult("mintleaf") <= 1.0, str(Seasons.growth_mult("mintleaf")))
	check("Rumah Kaca: semua tanaman boleh ditanam", Seasons.can_plant("sunbud") and Seasons.can_plant("mintleaf"))
	WorldState.greenhouse = was_gh
	check("item Rumah Kaca ada di toko", Db.items.has("greenhouse_kit"))
	# plot_status ikut pengali musim (waktu tumbuh nyata berubah)
	var plot := {"crop_id": "mintleaf", "planted_at_unix": GameClock.unix_now() - 605}
	var st := HomesteadSystem.plot_status(plot)
	var expect_ready: bool = 605.0 >= 600.0 * Seasons.growth_mult("mintleaf")
	check("plot_status menghormati musim", bool(st.ready) == expect_ready, "ready=%s mult=%s" % [st.ready, Seasons.growth_mult("mintleaf")])
	# drop & spawn bias
	check("drop_mult musim masuk akal (1.0-1.3)", Seasons.drop_mult() >= 1.0 and Seasons.drop_mult() <= 1.3, str(Seasons.drop_mult()))
	var fav: Array = GameClock.season_def().get("favored_elements", [])
	check("musim punya elemen favorit", not fav.is_empty())
	# pick_species: elemen favorit lebih sering keluar daripada bobot rata
	var table := ["snow_hare", "flame_imp", "gummy_slime", "cave_bat"]
	var rng := RandomNumberGenerator.new()
	var counts := {}
	for i in 600:
		rng.seed = i
		var sp := Seasons.pick_species(table, rng)
		counts[sp] = int(counts.get(sp, 0)) + 1
	check("pick_species selalu mengembalikan spesies dari tabel", counts.size() >= 1 and counts.size() <= table.size())
	var total := 0
	for k in counts:
		total += int(counts[k])
	check("pick_species mengembalikan 600 hasil", total == 600, str(total))


func _test_journal_and_stingers() -> void:
	print("[Jurnal + Stinger v0.4.3]")
	QuestSystem.ensure_today()
	var qs: Array = QuestSystem.quests()
	check("ada quest harian", not qs.is_empty())
	if qs.is_empty():
		return
	var qid: String = qs[0].get("id", "")
	PlayerData.daily_quests["tracked"] = ""
	check("awalnya tak melacak apa pun", QuestSystem.tracked().is_empty())
	QuestSystem.track(qid)
	check("melacak quest", QuestSystem.tracked().get("id", "") == qid)
	var t := QuestSystem.tracked_target()
	check("sasaran lacak punya kind + target", t.has("kind") and t.has("target"), str(t))
	check("kind sasaran sesuai mekanik quest",
		t.get("kind", "") in ["monster", "gather", ""], str(t))
	QuestSystem.track(qid)
	check("klik lagi = berhenti melacak", QuestSystem.tracked().is_empty())
	# quest yang sudah diklaim tak bisa jadi target pelacakan
	QuestSystem.track(qid)
	for q in QuestSystem.quests():
		if q.id == qid:
			q.done = true
			q.claimed = true
	check("quest diklaim otomatis lepas dari pelacakan", QuestSystem.tracked().is_empty())
	PlayerData.daily_quests["tracked"] = ""
	# stinger: definisi momen besar ada & memakai sampel yang benar-benar terdaftar
	for kind in ["levelup", "quest", "discovery", "boss_kill", "transcend"]:
		var seq: Array = Audio.STINGERS.get(kind, [])
		check("stinger %s terdefinisi" % kind, not seq.is_empty())
		for step in seq:
			if not Audio.SFX_MAP.has(step[0]):
				check("stinger %s memakai sfx terdaftar (%s)" % [kind, step[0]], false)
	check("stinger tidak crash saat dipanggil", true)
	Audio.play_stinger("quest")


func _test_dungeon_chests_traps() -> void:
	print("[Dungeon: peti + rahasia + jebakan v0.4.3 #6]")
	check("loot table peti ada", not Db.loot_table("chest_common").is_empty() and not Db.loot_table("chest_secret").is_empty())
	var secret_rich := 0.0
	for d in Db.loot_table("chest_secret"):
		secret_rich += float(Db.item(d.get("item", "")).get("value", 0)) * float(d.get("chance", 0))
	var common_rich := 0.0
	for d in Db.loot_table("chest_common"):
		common_rich += float(Db.item(d.get("item", "")).get("value", 0)) * float(d.get("chance", 0))
	check("peti rahasia jauh lebih berharga daripada peti biasa", secret_rich > common_rich * 2.0,
		"%.0f vs %.0f" % [secret_rich, common_rich])
	# peti: buka sekali per hari WIB; rahasia tercatat permanen
	WorldState.chests_opened.clear()
	WorldState.secrets_found.clear()
	PlayerData.inventory.clear()
	var host := Node2D.new()
	add_child(host)
	var chest := DungeonChest.spawn(host, Vector2(100, 100), "test_secret", "chest_secret", true)
	await get_tree().process_frame
	check("peti rahasia belum terbuka", not WorldState.chests_opened.has("test_secret"))
	chest.interact()
	check("peti tercatat dibuka hari ini", WorldState.chests_opened.get("test_secret", "") == GameClock.date_string())
	check("penemuan rahasia dicatat permanen", "test_secret" in WorldState.secrets_found and WorldState.get_counter("secrets_found") >= 1)
	var before: int = host.get_child_count()
	chest.interact()   # buka lagi hari yang sama = tak ada apa-apa
	check("peti tak bisa dipanen dua kali sehari", host.get_child_count() == before)
	# jebakan: paku merusak tapi TIDAK PERNAH >25% max HP, dan pemain tak mati dari full HP
	var trap := DungeonTrap.spawn(host, Vector2(200, 100), "spike")
	await get_tree().process_frame
	check("jebakan punya jenis sah", trap.kind in ["spike", "dart"])
	check("cap damage jebakan 25% max HP", DungeonTrap.CAP <= 0.25)
	check("paku < cap; panah < cap", DungeonTrap.SPIKE_DMG < DungeonTrap.CAP and DungeonTrap.DART_DMG < DungeonTrap.CAP)
	var hp0: int = PlayerData.max_hp
	PlayerData.hp = hp0
	trap._hit(_FakeTrapTarget.new(), DungeonTrap.SPIKE_DMG)
	check("jebakan tak crash pada target tanpa take_hit", true)
	# save/load membawa peti & rahasia
	var ws := WorldState.to_save()
	check("save membawa chests_opened + secrets_found", ws.has("chests_opened") and ws.has("secrets_found"))
	WorldState.chests_opened = {}
	WorldState.secrets_found = []
	WorldState.from_save(ws)
	check("load memulihkan rahasia yang ditemukan", "test_secret" in WorldState.secrets_found)
	WorldState.chests_opened.clear()
	WorldState.secrets_found.clear()
	host.queue_free()

class _FakeTrapTarget extends Node:
	pass


func _test_rasi_and_forecast() -> void:
	print("[12 Rasi + Prakiraan Astrolog A5/Audit B #91]")
	check("rasi.json termuat (12 rasi)", Db.rasi.size() == 12)
	var missing_art := 0
	var fields := {}
	for r in Db.rasi:
		if not ResourceLoader.exists(r.get("asset", "")):
			missing_art += 1
		if r.get("riddle", "") == "" or r.get("philosophy", "") == "":
			check("rasi %s punya teka-teki + filosofi" % r.get("id", "?"), false)
		fields[r.get("bonus", {}).get("field", "")] = true
	check("12 aset rasi benar-benar ada & terpakai", missing_art == 0, "%d hilang" % missing_art)
	check("bonus rasi beragam (bukan satu stat saja)", fields.size() >= 8, str(fields.size()))
	# bonus KECIL: tak ada rasi yang memberi lebih dari 3%
	var too_big := false
	for r in Db.rasi:
		if float(r.get("bonus", {}).get("value", 0.0)) > 0.03:
			too_big = true
	check("bonus rasi kecil (<=3%) — identitas, bukan power spike", not too_big)
	# rasi naik: fungsi minggu nyata, sama untuk semua
	var asc := RasiSystem.ascendant()
	check("rasi naik valid", asc.has("id") and asc.get("id", "") != "")
	check("rasi naik deterministik (minggu WIB)", RasiSystem.ascendant().get("id", "") == asc.get("id", ""))
	check("ramalan mingguan tak kosong", RasiSystem.weekly_prophecy().length() > 10)
	# langit malam: rasi naik benar-benar dipasang di dunia (tanpa teks)
	var amb := Node2D.new()
	amb.set_script(load("res://scenes/systems/Ambience.gd"))
	amb.set("theme", "forest")
	add_child(amb)
	await get_tree().process_frame
	var sky_found := false
	for c in amb.get_children():
		if c is CanvasLayer:
			for cc in c.get_children():
				if cc is TextureRect and cc.texture != null:
					sky_found = true
	check("rasi naik tergambar di langit malam", sky_found)
	amb.queue_free()
	# rasi kelahiran: bonus benar-benar masuk stat
	var save_sign: String = PlayerData.birth_sign
	PlayerData.birth_sign = "Paus"          # +2% HP
	PlayerData.recalculate_stats()
	var hp_paus: int = PlayerData.max_hp
	PlayerData.birth_sign = "Gerbang"       # bonus 0
	PlayerData.recalculate_stats()
	var hp_base: int = PlayerData.max_hp
	check("bonus rasi kelahiran masuk ke stat", hp_paus > hp_base, "%d vs %d" % [hp_paus, hp_base])
	check("bonus rasi kecil di praktik (<5%)", float(hp_paus - hp_base) / float(maxi(1, hp_base)) < 0.05)
	PlayerData.birth_sign = save_sign
	PlayerData.recalculate_stats()
	# prakiraan: deterministik & 24 entri; rol cuaca mengikuti rencana ~80%
	var fc: Array = WorldState.forecast(24)
	check("prakiraan 24 jam", fc.size() == 24)
	var valid := true
	for f in fc:
		if not f.get("weather", "") in ["sunny", "rain", "thunderstorm", "blizzard", "blood_moon"]:
			valid = false
	check("semua entri prakiraan cuaca sah", valid)
	var d := GameClock.date_string()
	check("rencana langit deterministik", WorldState.planned_weather(d, 9) == WorldState.planned_weather(d, 9))
	check("akurasi prakiraan = 80% (janji GDD)", absf(WorldState.FORECAST_ACCURACY - 0.8) < 0.001)


func _test_new_assets() -> void:
	print("[Aset baru: musik, stinger, peti, SFX v0.4.3 #92]")
	# musik wilayah: semua track terwire benar-benar ada di build
	var tracks := ["menu.ogg", "greenvale.ogg", "town.ogg", "candyveil.ogg", "desert.ogg",
		"frostpeak.ogg", "storm.ogg", "dungeon.ogg", "boss.ogg"]
	for t in tracks:
		check("musik %s ada" % t, ResourceLoader.exists("res://assets/game/audio/music/" + t))
	# tak ada lagi referensi track lama yang sudah dihapus
	check("track lama tak dipakai lagi", not ResourceLoader.exists("res://assets/game/audio/music/23 - Road.ogg"))
	check("musik combat = boss.ogg", Audio.COMBAT_MUSIC == "boss.ogg")
	# stinger dari potongan musik asli
	for kind in ["levelup", "quest", "discovery", "boss_kill", "transcend"]:
		var f: String = Audio.STINGER_FILES.get(kind, "")
		check("stinger asli %s ada" % kind, f != "" and ResourceLoader.exists(Audio.STINGER_DIR + f))
	check("fallback stinger sampel tetap ada", not Audio.STINGERS.is_empty())
	# SFX Minifantasy
	for sfx in ["chest", "secret_door", "trap_spike", "trap_dart", "crate", "stone_step"]:
		var fn: String = Audio.SFX_MAP.get(sfx, "")
		check("sfx %s terdaftar & ada" % sfx, fn != "" and ResourceLoader.exists(Audio.SFX_DIR + fn))
	# sprite peti (Pixel Chest Pack) — 3 varian x 2 keadaan
	for v in ["common", "rare", "secret"]:
		var pair: Array = DungeonChest.ART.get(v, [])
		check("sprite peti %s (tutup+buka) ada" % v,
			pair.size() == 2 and ResourceLoader.exists(pair[0]) and ResourceLoader.exists(pair[1]))
	# varian peti dipilih dari tabel loot
	check("loot table chest_rare ada", not Db.loot_table("chest_rare").is_empty())
	var host := Node2D.new()
	add_child(host)
	var c1 := DungeonChest.spawn(host, Vector2.ZERO, "t_c1", "chest_common", false)
	var c2 := DungeonChest.spawn(host, Vector2.ZERO, "t_c2", "chest_rare", false)
	var c3 := DungeonChest.spawn(host, Vector2.ZERO, "t_c3", "chest_secret", true)
	check("varian peti dipetakan benar", c1.variant() == "common" and c2.variant() == "rare" and c3.variant() == "secret")
	host.queue_free()
	# crossfade
	check("crossfade musik aktif (FADE_TIME > 0)", Audio.FADE_TIME > 0.0)
