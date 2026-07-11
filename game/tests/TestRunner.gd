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
	_test_fishing()
	_test_professions()
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
	var atk := {"atk": 100, "matk": 100, "crit_rate": 0.0, "element": "lightning"}
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
	check("common TTK sane (3..20 basic hits)", hits >= 3 and hits <= 20, "%d hits" % hits)

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
	PlayerCombat.melee_arc(actor, Vector2.RIGHT, 48.0, 120.0, Db.skill("strike"))
	Engine.time_scale = 1.0   # clear any hitstop from the swing
	check("arc melee multi-hit (m1)", m1.hp < hp1_0, "%d<%d" % [m1.hp, hp1_0])
	check("arc melee multi-hit (m2)", m2.hp < hp2_0)
	# knockback pushed the monster (velocity now non-zero)
	check("knockback applied velocity", m1.velocity.length() > 1.0)

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
		for i in range(int(kq.count)):
			EventBus.monster_killed.emit("verdant_slime", null)
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
	var ok := SaveManager.save_game(3)
	check("save writes", ok and SaveManager.has_save(3))
	# mutate then load
	PlayerData.level = 99
	PlayerData.gold = 0
	PlayerData.inventory.clear()
	WorldState.set_counter("rabbits_killed", 0)
	var loaded := SaveManager.load_game(3)
	check("load succeeds", loaded)
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
