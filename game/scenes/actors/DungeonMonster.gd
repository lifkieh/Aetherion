class_name DungeonMonster
extends CharacterBody2D
## Side-view dungeon monster (owner decision 2026-07-11). Simple platformer AI:
## edge/wall patrol + small hops; flyers bob and chase. Combat via CombatResolver,
## rewards via MonsterFactory.grant_rewards — no logic duplication.

const GRAVITY := 900.0
const PATROL_SPEED := 40.0
const CHASE_SPEED := 70.0
const HOP := -220.0

var inst: Dictionary = {}
var hp := 1
var max_hp := 1
var is_wet := false
var tame_pity := 0.0
var _spawner = null
var _flyer := false
var _dir := 1.0
var _attack_cd := 0.0
var _hop_cd := 0.0
var _shoot_cd := 0.0
var _shots := 0
var _contact_cd := 0.0
var _player: Node2D = null
var _dead := false
var _bob := 0.0
# boss state
var _boss := false
var _phase := 1
var _next_add := 0.75
var _jump_cd := 1.5
var _was_air := false

@onready var sprite: Sprite2D = $Sprite
@onready var hpbar: ProgressBar = $HPBar
@onready var wall_ray: RayCast2D = $WallRay
@onready var floor_ray: RayCast2D = $FloorRay

func setup(instance: Dictionary, spawner = null) -> void:
	inst = instance
	_spawner = spawner
	max_hp = inst.get("max_hp", 100)
	hp = max_hp
	_flyer = inst.get("ai", "melee") == "flyer"
	if is_inside_tree():
		_apply()

func _ready() -> void:
	add_to_group("monsters")
	if not inst.is_empty():
		_apply()
	_player = get_tree().get_first_node_in_group("player")

func _apply() -> void:
	var fs: int = inst.get("frame_size", 16)
	var tex := SheetUtil.load_tex(inst.get("sprite", ""))
	if tex:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(0, 0, fs, fs)
		sprite.texture = at
	var tint: String = inst.get("tint", "")
	if tint != "":
		sprite.modulate = Color(tint)
	if inst.get("mutation", false):
		sprite.modulate = sprite.modulate.lerp(Color(1.0, 0.75, 0.25), 0.45)   # MUTASI (v0.4.1)
	_build_rank_label()
	if inst.get("is_boss", false):
		sprite.scale = Vector2(2.4, 2.4)
		_boss = true
		# BOSS INTRO (v0.4.1): bar+nama di HUD + stinger + guncang
		EventBus.boss_engaged.emit(inst.get("name", "Bos"), self)
		Audio.play_sfx("secret", 0.6)
		CombatFeel.shake(5.0, 0.4)
	hpbar.max_value = max_hp
	hpbar.value = hp
	hpbar.visible = _boss

func combat_view() -> Dictionary:
	var v := MonsterFactory.combat_stats(inst)
	v["hp"] = hp
	return v

func _behavior() -> String:
	var b: String = inst.get("behavior", "")
	if b != "":
		return b
	if _flyer:
		return "flyer"
	if inst.get("ai", "") in ["ranged", "shooter"]:
		return "shooter"
	if "split" in inst.get("traits", []):
		return "jumper"
	return "walker"

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_hop_cd = maxf(0.0, _hop_cd - delta)
	_shoot_cd = maxf(0.0, _shoot_cd - delta)
	_contact_cd = maxf(0.0, _contact_cd - delta)
	_jump_cd = maxf(0.0, _jump_cd - delta)
	is_wet = WorldState.is_wet_weather()
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
	# status effects (v0.4.1)
	StatusFx.tick(self, delta)
	_refresh_status_icons()
	if StatusFx.is_stunned(self):
		velocity.x = 0.0
		velocity.y = minf(velocity.y + GRAVITY * delta, 560.0)
		move_and_slide()
		sprite.modulate = Color(0.6, 0.85, 1.0)
		return
	elif not statuses.has("freeze") and sprite.modulate == Color(0.6, 0.85, 1.0):
		sprite.modulate = Color.WHITE

	if _boss:
		_boss_ai(delta)
		_contact_damage()
		return

	var dx := 9999.0
	if _player:
		dx = _player.global_position.x - global_position.x
	var aggro: float = inst.get("aggro_radius", 160)
	var chasing := _player != null and absf(dx) < aggro and absf(_player.global_position.y - global_position.y) < 120

	match _behavior():
		"flyer": _fly(delta, chasing)
		"shooter": _shoot_ai(delta, chasing, dx)
		"jumper": _walk(delta, chasing, dx, true)
		_: _walk(delta, chasing, dx, false)

	_contact_damage()
	# melee when adjacent (walker/jumper); Paralyze mengunci serangan (v0.4.1)
	if _player and _behavior() != "shooter" and global_position.distance_to(_player.global_position) < 22.0 \
			and _attack_cd <= 0.0 and not StatusFx.is_attack_locked(self):
		_attack()

func _shoot_ai(delta: float, chasing: bool, dx: float) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, 560.0)
	if chasing and _player:
		# keep mid distance: back off if close, approach if far
		var adx := absf(dx)
		if adx < 90.0:
			velocity.x = -signf(dx) * PATROL_SPEED
		elif adx > 150.0:
			velocity.x = signf(dx) * PATROL_SPEED
		else:
			velocity.x = 0.0
		if _shoot_cd <= 0.0:
			_shoot_cd = 1.6
			_shots += 1
			var dir: Vector2 = (_player.global_position - global_position).normalized()
			var proj: String = inst.get("projectile", "enemy_bolt")
			if _shots % 3 == 0:
				# tembakan ke-3 = kipas 3 proyektil (pola burst, v0.4.1)
				for i in range(3):
					var a := dir.rotated(deg_to_rad(-14.0 + 14.0 * i))
					ProjectilePool.spawn(global_position + a * 10.0, a, proj, MonsterFactory.combat_stats(inst), self, "player")
			else:
				ProjectilePool.spawn(global_position + dir * 10.0, dir, proj, MonsterFactory.combat_stats(inst), self, "player")
	else:
		velocity.x = _dir * PATROL_SPEED
		wall_ray.target_position = Vector2(_dir * 10, 0)
		floor_ray.position = Vector2(_dir * 8, 0)
		if is_on_floor() and (is_on_wall() or not floor_ray.is_colliding()):
			_dir = -_dir
	move_and_slide()
	sprite.flip_h = _dir < 0

func _contact_damage() -> void:
	if inst.get("passive", false) or _contact_cd > 0.0 or _player == null:
		return
	if global_position.distance_to(_player.global_position) < (30.0 if _boss else 15.0):
		if _player.has_method("take_hit"):
			_contact_cd = 0.6
			var sk := {"skill_mod": 0.6, "kind": "physical", "element": inst.get("element", "none")}
			var res := CombatResolver.resolve(MonsterFactory.combat_stats(inst), _player.combat_view(), sk, CombatResolver.build_ctx())
			_player.take_hit(res, self)

func _walk(delta: float, chasing: bool, dx: float, hopper: bool = false) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, 560.0)
	if chasing:
		_dir = signf(dx) if dx != 0 else _dir
		velocity.x = _dir * CHASE_SPEED
		# jumpers hop toward the player frequently; walkers only hop over walls
		var hop_ready := _hop_cd <= 0.0 if hopper else is_on_wall()
		if is_on_floor() and (is_on_wall() or hop_ready):
			velocity.y = HOP
			_hop_cd = randf_range(0.5, 1.0) if hopper else randf_range(1.2, 2.4)
	else:
		velocity.x = _dir * PATROL_SPEED
		# turn at wall or ledge
		wall_ray.target_position = Vector2(_dir * 10, 0)
		floor_ray.position = Vector2(_dir * 8, 0)
		if is_on_floor() and (is_on_wall() or not floor_ray.is_colliding()):
			_dir = -_dir
	move_and_slide()
	sprite.flip_h = _dir < 0

func _fly(delta: float, chasing: bool) -> void:
	_bob += delta * 4.0
	if chasing and _player:
		var to := (_player.global_position - global_position)
		velocity = to.normalized() * CHASE_SPEED
	else:
		velocity.x = _dir * PATROL_SPEED
		velocity.y = sin(_bob) * 30.0
		if is_on_wall():
			_dir = -_dir
	move_and_slide()
	sprite.flip_h = velocity.x < 0

## King Slime — 2 telegraphed phases (owner req 6).
# --- Boss pattern machine (v0.4.1): 3 pola terkoreografi per fase + arena hazard.
# Berlaku untuk SEMUA 5 bos (satu mesin, rasa beda dari elemen + data override
# monsters.json "boss_patterns": {"p1": [...], "p2": [...]}).
const BOSS_P1 := ["leap", "leap", "slam", "burst"]
const BOSS_P2 := ["dash", "burst", "slam", "leap", "summon"]

var _bpatt := ""
var _bpatt_phase := 0
var _bpatt_t := 0.0
var _bpatt_idx := 0
var _arena_t := 5.0

func _boss_patterns() -> Array:
	var bp: Dictionary = inst.get("boss_patterns", {})
	if _phase == 1:
		return bp.get("p1", BOSS_P1)
	return bp.get("p2", BOSS_P2)

func _boss_ai(delta: float) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, 620.0)
	var frac := float(hp) / float(max_hp)
	# phase 2: <40% HP -> lebih kecil, cepat, pola baru
	if _phase == 1 and frac < 0.4:
		_phase = 2
		sprite.scale *= 0.6
		_bpatt_idx = 0
		Audio.play_sfx("secret", 0.7)
		CombatFeel.shake(6.0, 0.3)
		EventBus.toast.emit("%s mengamuk! (Fase 2)" % inst.get("name", "Bos"))
	# adds tiap melewati ambang 25% HP
	if frac <= _next_add and _next_add > 0.0:
		_next_add -= 0.25
		_spawn_adds(2)
	# arena hazard periodik (mekanik arena per bos, rasa dari elemen bos)
	_arena_t -= delta
	if _arena_t <= 0.0:
		_arena_t = 6.0 if _phase == 1 else 3.8
		_arena_hazard()
	# pola terkoreografi
	if _bpatt != "":
		_run_boss_pattern(delta)
		return
	if is_on_floor() and _jump_cd <= 0.0 and _player:
		_start_boss_pattern()
	else:
		velocity.x = move_toward(velocity.x, 0.0, 40.0 * delta)
	move_and_slide()
	_boss_landing_check()

func _start_boss_pattern() -> void:
	var seq := _boss_patterns()
	_bpatt = seq[_bpatt_idx % seq.size()]
	_bpatt_idx += 1
	_bpatt_phase = 0
	_bpatt_t = {"leap": 0.2, "slam": 0.6, "burst": 0.5, "dash": 0.4, "summon": 0.1}.get(_bpatt, 0.4)
	# telegraf universal
	var tw := create_tween().set_loops(3)
	tw.tween_property(sprite, "modulate", Color(1.6, 0.5, 0.5), 0.07)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.07)

func _run_boss_pattern(delta: float) -> void:
	_bpatt_t -= delta
	velocity.y = minf(velocity.y + GRAVITY * delta, 620.0)
	if _bpatt_phase == 0:
		velocity.x = 0.0
		move_and_slide()
		if _bpatt_t <= 0.0:
			_bpatt_phase = 1
			_boss_execute()
		return
	# fase eksekusi per pola
	match _bpatt:
		"leap":
			move_and_slide()
			_boss_landing_check()
			if is_on_floor() and not _was_air:
				_end_boss_pattern(1.2 if _phase == 1 else 0.8)
		"dash":
			move_and_slide()
			if _bpatt_t <= 0.0 or is_on_wall():
				_end_boss_pattern(1.0)
		_:
			velocity.x = 0.0
			move_and_slide()
			if _bpatt_t <= 0.0:
				_end_boss_pattern(1.4 if _phase == 1 else 1.0)

func _boss_execute() -> void:
	match _bpatt:
		"leap":
			_telegraph_landing()
			velocity.x = signf(_player.global_position.x - global_position.x) * (70.0 if _phase == 1 else 100.0) if _player else 60.0
			velocity.y = -300.0 if _phase == 1 else -400.0
			_was_air = true
			_bpatt_t = 3.0   # failsafe
		"slam":
			CombatFeel.shake(7.0, 0.25)
			Audio.play_sfx("hit", 0.6)
			_shockwave(-1)
			_shockwave(1)
			_bpatt_t = 0.4
		"burst":
			var proj: String = inst.get("projectile", "enemy_bolt")
			if proj == "": proj = "enemy_bolt"
			for i in range(8):
				var a := Vector2.from_angle(TAU * i / 8.0)
				ProjectilePool.spawn(global_position + a * 14.0, a, proj, MonsterFactory.combat_stats(inst), self, "player")
			Audio.play_sfx("attack", 0.7)
			_bpatt_t = 0.3
		"dash":
			velocity.x = (signf(_player.global_position.x - global_position.x) if _player else _dir) * 220.0
			Audio.play_sfx("dodge", 0.7)
			_bpatt_t = 0.55
		"summon":
			_spawn_adds(2)
			Audio.play_sfx("secret", 0.8)
			_bpatt_t = 0.2

func _end_boss_pattern(cd: float) -> void:
	_bpatt = ""
	_jump_cd = cd
	sprite.modulate = Color.WHITE

## Gelombang kejut slam: garis tanah melebar dua arah; kena jika pemain dekat lantai.
func _shockwave(dir: int) -> void:
	if get_parent() == null:
		return
	var line := Line2D.new()
	line.width = 6.0
	line.default_color = Vfx.elem_color(inst.get("element", "earth"))
	line.z_index = 32
	var y := global_position.y + 12.0
	line.points = PackedVector2Array([Vector2(global_position.x, y), Vector2(global_position.x, y)])
	get_parent().add_child(line)
	var grow := func(t: float) -> void:
		if not is_instance_valid(line):
			return
		line.points = PackedVector2Array([
			Vector2(global_position.x + dir * 12.0, y),
			Vector2(global_position.x + dir * (12.0 + 110.0 * t), y)])
		line.modulate.a = 1.0 - t * 0.6
	var tw := line.create_tween()
	tw.tween_method(grow, 0.0, 1.0, 0.35)
	tw.tween_callback(line.queue_free)
	# damage: pemain dekat lantai dalam jangkauan gelombang
	if _player and _player.has_method("take_hit"):
		var dx := (_player.global_position.x - global_position.x) * dir
		if dx > 0.0 and dx < 130.0 and absf(_player.global_position.y - y) < 26.0:
			var sk := {"skill_mod": 1.4, "kind": "physical", "element": inst.get("element", "earth")}
			_player.take_hit(CombatResolver.resolve(MonsterFactory.combat_stats(inst), _player.combat_view(), sk, CombatResolver.build_ctx()), self)

## Mekanik ARENA per bos: hazard telegraf jatuh di posisi pemain, rasa dari elemen
## (ice=pecahan es, lightning=sambaran, earth/darkness=semburan pasir, water=hujan gel...).
func _arena_hazard() -> void:
	if _player == null or get_parent() == null:
		return
	var elem: String = inst.get("element", "earth")
	var x := _player.global_position.x
	var y := _player.global_position.y
	var col := Vfx.elem_color(elem)
	# telegraf kolom 0.8s
	var warn := ColorRect.new()
	warn.color = Color(col.r, col.g, col.b, 0.28)
	warn.size = Vector2(30, 90)
	warn.position = Vector2(x - 15, y - 70)
	warn.z_index = 25
	get_parent().add_child(warn)
	var tw := warn.create_tween().set_loops(4)
	tw.tween_property(warn, "color:a", 0.10, 0.1)
	tw.tween_property(warn, "color:a", 0.34, 0.1)
	get_tree().create_timer(0.8).timeout.connect(func():
		if is_instance_valid(warn):
			warn.queue_free()
		if _dead or _player == null:
			return
		Vfx.impact(get_parent(), Vector2(x, y), elem, true)
		CombatFeel.shake(3.0, 0.1)
		Audio.play_sfx("hit", 0.8)
		if absf(_player.global_position.x - x) < 18.0 and absf(_player.global_position.y - y) < 46.0 and _player.has_method("take_hit"):
			var sk := {"skill_mod": 1.1, "kind": "magic", "element": elem}
			_player.take_hit(CombatResolver.resolve(MonsterFactory.combat_stats(inst), _player.combat_view(), sk, CombatResolver.build_ctx()), self))

func _boss_landing_check() -> void:
	if _was_air and is_on_floor():
		_was_air = false
		CombatFeel.shake(4.0, 0.15)
		if _player and global_position.distance_to(_player.global_position) < 40.0 and _player.has_method("take_hit"):
			var sk := {"skill_mod": 1.2, "kind": "physical", "element": inst.get("element", "water")}
			_player.take_hit(CombatResolver.resolve(MonsterFactory.combat_stats(inst), _player.combat_view(), sk, CombatResolver.build_ctx()), self)
		if _phase == 2:
			_gel_burst()

## Perayaan kill bos (v0.4.1): slow-mo + jingle + HUJAN LOOT + banner HUD.
func _boss_celebration() -> void:
	EventBus.boss_defeated.emit(inst.get("name", "Bos"))
	Engine.time_scale = 0.25
	var t := get_tree().create_timer(0.22, true, false, true)   # ignore time_scale
	t.timeout.connect(func(): Engine.time_scale = 1.0)
	Audio.play_sfx("fusion", 1.0)
	Audio.play_sfx("levelup", 0.8)
	CombatFeel.shake(8.0, 0.5)
	# loot shower: rol tabel loot 2x lagi sebagai hujan drop + hujan koin
	var table := Db.loot_table(inst.get("loot_table", ""))
	for pass_i in range(2):
		for d in table:
			if randf() <= float(d.get("chance", 0)):
				LootDrop.spawn(get_parent(), global_position + Vector2(randf_range(-14, 14), -10), d.get("item", ""), randi_range(int(d.get("min", 1)), int(d.get("max", 1))))
	for i in range(6):
		LootDrop.spawn_gold(get_parent(), global_position + Vector2(randf_range(-20, 20), -8), randi_range(4, 10) * maxi(1, int(inst.get("level", 1))))

func _telegraph_landing() -> void:
	if _player == null or get_parent() == null:
		return
	var shadow := ColorRect.new()
	shadow.color = Color(0.1, 0.1, 0.15, 0.5)
	shadow.size = Vector2(40, 8)
	shadow.position = Vector2(-20, -4)
	var mk := Node2D.new()
	mk.global_position = Vector2(_player.global_position.x, global_position.y + 20)
	mk.add_child(shadow)
	get_parent().add_child(mk)
	var tw := mk.create_tween()
	tw.tween_property(shadow, "modulate:a", 0.2, 0.5)
	tw.tween_callback(mk.queue_free)

func _spawn_adds(n: int) -> void:
	if get_parent() == null:
		return
	for i in range(n):
		var child := MonsterFactory.make(inst.get("add_species", "verdant_slime"), 10, 3)
		if child.is_empty():
			continue
		child["_no_split"] = true
		var m := preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
		get_parent().add_child(m)
		m.setup(child, _spawner)
		m.global_position = global_position + Vector2(randf_range(-24, 24), -6)
	EventBus.toast.emit("King Slime memuntahkan slime!")

func _gel_burst() -> void:
	for a: float in [-0.6, 0.0, 0.6]:
		var dir: Vector2 = Vector2(a, -1.0).normalized()
		ProjectilePool.spawn(global_position, dir, "gel_glob", MonsterFactory.combat_stats(inst), self, "player")

func _attack() -> void:
	# telegraf universal (v0.4.1): kedip merah + wind-up 0.25s sebelum pukulan
	_attack_cd = 1.5
	var tw := create_tween().set_loops(2)
	tw.tween_property(sprite, "modulate", Color(1.6, 0.5, 0.5), 0.06)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.06)
	get_tree().create_timer(0.25).timeout.connect(_strike_now)

func _strike_now() -> void:
	if _dead or StatusFx.is_attack_locked(self):
		return
	if _player == null or global_position.distance_to(_player.global_position) > 30.0:
		return   # pemain sempat menghindar — telegraf ada gunanya
	var skills: Array = inst.get("skills", ["tackle"])
	var sk := Db.skill(skills[0]) if skills.size() > 0 else Db.skill("tackle")
	if sk.get("kind", "physical") == "buff":
		sk = Db.skill("tackle")
	if inst.get("attack_status", "") != "":
		sk = sk.duplicate(); sk["apply_status"] = inst.attack_status   # trait Berbisa (v0.4.1)
	if _player.has_method("take_hit"):
		var pstats: Dictionary = _player.combat_view() if _player.has_method("combat_view") else PlayerData.combat_stats()
		var mstats := MonsterFactory.combat_stats(inst)
		mstats["accuracy"] = float(mstats.get("accuracy", 1.0)) * StatusFx.acc_mult(self)
		var res := CombatResolver.resolve(mstats, pstats, sk, CombatResolver.build_ctx())
		_player.take_hit(res, self)

var _hit_imm := {}
var statuses := {}     # status effects (v0.4.1)
var _status_lbl: Label = null
var _rank_lbl: Label = null

## Rank bintang + trait individu TAMPIL di target (v0.4.1).
func _build_rank_label() -> void:
	if _rank_lbl:
		_rank_lbl.queue_free()
	_rank_lbl = Label.new()
	_rank_lbl.add_theme_font_size_override("font_size", 9)
	_rank_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	_rank_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_rank_lbl.add_theme_constant_override("outline_size", 3)
	var txt := "★".repeat(int(inst.get("star", 3)))
	var traits: Array = inst.get("ind_traits", [])
	if not traits.is_empty():
		txt += " · " + " · ".join(traits)
	if inst.get("mutation", false):
		txt = "✦MUTASI✦ " + txt
	_rank_lbl.text = txt
	_rank_lbl.position = Vector2(-22, -36)
	_rank_lbl.visible = false
	add_child(_rank_lbl)

func take_hit(result: Dictionary, from) -> void:
	if _dead:
		return
	if result.get("miss", false):
		var dnm := preload("res://scenes/ui/DamageNumber.tscn").instantiate()
		get_parent().add_child(dnm); dnm.global_position = global_position + Vector2(0, -10); dnm.show_miss()
		return
	var now := float(Time.get_ticks_msec()) / 1000.0
	var key: int = from.get_instance_id() if is_instance_valid(from) else 0
	if _hit_imm.get(key, 0.0) > now:
		return
	_hit_imm[key] = now + CombatFeel.hit_immunity(inst.get("is_boss", false))
	result = StatusFx.pre_hit(self, result)   # Thermal Shock dll. (v0.4.1)
	hp = max(0, hp - int(result.get("damage", 0)))
	hpbar.visible = true
	if _rank_lbl: _rank_lbl.visible = true
	hpbar.value = hp
	EventBus.damage_dealt.emit(from, self, result.get("damage", 0), result.get("is_crit", false), result.get("element", "none"))
	_spawn_damage_number(result.get("damage", 0), result.get("is_crit", false), result.get("effective", false))
	Vfx.impact(get_parent(), global_position + Vector2(0, -6), result.get("element", "none"), result.get("is_crit", false))
	_flash()
	Audio.play_sfx("hit", 1.25 if result.get("is_crit", false) else 1.0)
	StatusFx.on_hit(self, result, is_wet)   # roll status (v0.4.1)
	if _boss:
		EventBus.boss_hp_changed.emit(hp, max_hp)
	if hp <= 0:
		_die(from)

## Small DoT tick (burn/poison) — bypasses per-source immunity (v0.4.1).
func take_status_damage(dmg: int, elem: String) -> void:
	if _dead:
		return
	hp = max(0, hp - dmg)
	hpbar.visible = true
	hpbar.value = hp
	var dn := preload("res://scenes/ui/DamageNumber.tscn").instantiate()
	get_parent().add_child(dn)
	dn.global_position = global_position + Vector2(randf_range(-6, 6), -14)
	dn.show_number(dmg, false, false)
	dn.modulate = Vfx.elem_color(elem)
	if hp <= 0:
		_die(null)

func _refresh_status_icons() -> void:
	var txt := StatusFx.icons_text(self)
	if txt == "" and _status_lbl == null:
		return
	if _status_lbl == null:
		_status_lbl = Label.new()
		_status_lbl.add_theme_font_size_override("font_size", 10)
		_status_lbl.position = Vector2(-14, -30)
		add_child(_status_lbl)
	if _status_lbl.text != txt:
		_status_lbl.text = txt

func can_be_tamed() -> bool:
	return not _dead and hp <= int(max_hp * 0.05)

func attempt_tame() -> void:
	var res := TamingSystem.attempt(self)
	if res.get("success", false):
		_dead = true
		EventBus.toast.emit("Berhasil menjinakkan " + inst.get("name", "") + "!")
		if _spawner and is_instance_valid(_spawner) and _spawner.has_method("on_monster_died"):
			_spawner.on_monster_died(self)
		queue_free()

func _die(from) -> void:
	_dead = true
	velocity = Vector2.ZERO
	Audio.play_sfx("death")
	if "split" in inst.get("traits", []) and not inst.get("_no_split", false) and not _boss:
		_split()   # boss uses phase adds instead of a death split
	MonsterFactory.grant_rewards(inst, self)   # physical loot burst (FF-2f)
	EventBus.monster_killed.emit(inst.get("species_id", "?"), self)
	if _spawner and is_instance_valid(_spawner) and _spawner.has_method("on_monster_died"):
		_spawner.on_monster_died(self)
	if _boss:
		_boss_celebration()
	# death dissolve (FF-2f)
	Vfx.death_burst(get_parent(), global_position, inst.get("element", "none"))
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(sprite, "modulate", Color(3, 3, 3, 1), 0.06)
	tw.chain().tween_property(sprite, "scale", sprite.scale * 1.25, 0.10)
	tw.parallel().tween_property(sprite, "modulate:a", 0.0, 0.16)
	tw.chain().tween_callback(queue_free)

func _split() -> void:
	if get_parent() == null:
		return
	for i in range(2):
		var child := MonsterFactory.make(inst.get("species_id", ""), max(1, inst.get("level", 1) - 2), 2)
		if child.is_empty():
			continue
		child["max_hp"] = int(child["max_hp"] * 0.4)
		child["hp"] = child["max_hp"]
		child["_no_split"] = true
		child["is_boss"] = false
		var m := preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
		get_parent().add_child(m)
		m.setup(child, _spawner)
		m.global_position = global_position + Vector2(randf_range(-20, 20), -8)

func _flash() -> void:
	var base: Color = Color(inst.get("tint", "ffffff")) if inst.get("tint", "") != "" else Color.WHITE
	sprite.modulate = Color(1, 0.4, 0.4)
	create_tween().tween_property(sprite, "modulate", base, 0.15)

func _spawn_damage_number(amount: int, crit: bool, eff: bool) -> void:
	if get_parent() == null:
		return
	var dn := preload("res://scenes/ui/DamageNumber.tscn").instantiate()
	get_parent().add_child(dn)
	dn.global_position = global_position + Vector2(0, -12)
	dn.show_number(amount, crit, eff)
