class_name Monster
extends CharacterBody2D
## Generic monster (Fase0 §4): one scene configured from a MonsterFactory instance.
## AI presets: melee / ranged / skittish / ambush. Handles HP, drops, EXP, taming.

enum State { IDLE, WANDER, CHASE, ATTACK, FLEE, DEAD }

var inst: Dictionary = {}
var hp: int = 1
var max_hp: int = 1
var is_wet := false
var enraged_until := 0.0
var tame_pity := 0.0

var _state: int = State.IDLE
var _state_timer := 0.0
var _wander_dir := Vector2.ZERO
var _attack_cd := 0.0
var _home := Vector2.ZERO
var _home_set := false
var _player: Node2D = null
var _spawner = null

var _base_color := Color.WHITE
var _wet_marker: Node2D = null
var _sz_blocked := 0.0        # seconds spent pressed against a town safe-zone edge
var _knock := Vector2.ZERO    # residual knockback velocity (gate guards, UI/UX §4)

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hpbar: ProgressBar = $HPBar
@onready var tame_hint: Label = $TameHint

func setup(instance: Dictionary, spawner = null) -> void:
	inst = instance
	_spawner = spawner
	max_hp = inst.get("max_hp", 100)
	hp = max_hp
	# setup() is called after add_child() (node already in tree), so build the
	# real sprite now that inst is populated.
	if is_inside_tree():
		_build_sprite()
		_setup_bars()

func _ready() -> void:
	add_to_group("monsters")
	if not inst.is_empty():
		_build_sprite()
		_setup_bars()
	_player = get_tree().get_first_node_in_group("player")
	_state = State.WANDER
	EventBus.monster_spawned.emit(self)

func _build_sprite() -> void:
	var tex := SheetUtil.load_tex(inst.get("sprite", ""))
	if tex == null:
		tex = SheetUtil.load_tex("res://assets/game/sprites/monsters/slime.png")
	if tex:
		var fs: int = inst.get("frame_size", 16)
		sprite.sprite_frames = SheetUtil.build_directional(tex, fs, inst.get("cols", 4), inst.get("rows", 4), 6.0)
		sprite.play("idle_down")
	var tint: String = inst.get("tint", "")
	if tint != "":
		_base_color = Color(tint)
	sprite.modulate = _base_color
	_build_wet_marker()

func _build_wet_marker() -> void:
	# Science demo: a Wet target shows dripping cyan dots (rain/thunderstorm).
	_wet_marker = Node2D.new()
	_wet_marker.name = "WetMarker"
	_wet_marker.position = Vector2(0, -10)
	_wet_marker.visible = false
	add_child(_wet_marker)
	for off in [Vector2(-4, 0), Vector2(0, -2), Vector2(4, 1)]:
		var d := ColorRect.new()
		d.color = Color(0.45, 0.75, 1.0, 0.9)
		d.size = Vector2(2, 3)
		d.position = off
		_wet_marker.add_child(d)

func _setup_bars() -> void:
	hpbar.max_value = max_hp
	hpbar.value = hp
	hpbar.visible = false
	tame_hint.visible = false

func combat_view() -> Dictionary:
	var v := MonsterFactory.combat_stats(inst)
	v["hp"] = hp
	v["max_hp"] = max_hp
	return v

# --- AI ---------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	z_index = int(global_position.y)   # y-sort with town buildings/props (R2)
	if _state == State.DEAD:
		return
	if not _home_set:
		# Capture leash home once the spawner has finalized our position
		# (spawn order is add_child -> set position -> setup, so _ready is too early).
		_home = global_position
		_home_set = true
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_state_timer -= delta
	is_wet = WorldState.is_wet_weather()
	if _wet_marker:
		_wet_marker.visible = is_wet
	_update_tame_hint()

	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")

	# Caught inside a town safe zone (pushed in, edge case) — walk straight back out.
	if SafeZone.is_active() and SafeZone.contains(global_position):
		var edir: Vector2 = SafeZone.escape_vector(global_position)
		velocity = edir * (inst.get("spd", 100) * 0.8) + _knock
		move_and_slide()
		_knock = _knock.move_toward(Vector2.ZERO, 900.0 * delta)
		_anim(velocity)
		enraged_until = _now() + 1.0   # don't attack while fleeing town
		return

	var ai: String = inst.get("ai", "melee")
	var dist := 99999.0
	if _player:
		dist = global_position.distance_to(_player.global_position)
	var aggro: float = inst.get("aggro_radius", 130)

	match _state:
		State.WANDER, State.IDLE:
			_wander(delta)
			if _player and dist < aggro and _now() > enraged_until:
				_state = State.FLEE if ai == "skittish" else State.CHASE
				Onboarding.tip("monster")
		State.CHASE:
			if _player == null or dist > aggro * 1.8 or _sz_blocked > 0.6:
				# gave up (leash) or stopped at the town edge — cool off before re-aggro
				if _sz_blocked > 0.6:
					enraged_until = _now() + 2.5
				_sz_blocked = 0.0
				_enter_wander()
			elif dist <= _attack_range():
				_state = State.ATTACK
			else:
				_move_toward(_player.global_position, delta)
		State.FLEE:
			if _player == null or dist > aggro * 2.0:
				_enter_wander()
			else:
				_move_toward(global_position * 2 - _player.global_position, delta, 1.2)
		State.ATTACK:
			velocity = Vector2.ZERO
			if _player == null or dist > _attack_range() * 1.4:
				_state = State.CHASE
			elif _attack_cd <= 0.0:
				_attack_player()

func _attack_range() -> float:
	return 90.0 if inst.get("ai", "melee") == "ranged" else 26.0

func _wander(delta: float) -> void:
	if _state_timer <= 0.0:
		_state_timer = randf_range(1.0, 2.5)
		if randf() < 0.6:
			_wander_dir = Vector2.from_angle(randf() * TAU)
		else:
			_wander_dir = Vector2.ZERO
	# leash to home
	if global_position.distance_to(_home) > 180.0:
		_wander_dir = (_home - global_position).normalized()
	var base: Vector2 = _wander_dir * (inst.get("spd", 100) * 0.25)
	# don't wander into the town safe zone either
	if SafeZone.is_active() and SafeZone.contains(global_position + base * delta):
		base = Vector2.ZERO
	velocity = base + _knock
	move_and_slide()
	_knock = _knock.move_toward(Vector2.ZERO, 900.0 * delta)
	_anim(velocity)

func _move_toward(target: Vector2, delta: float, speed_mult: float = 1.0) -> void:
	var dir := (target - global_position).normalized()
	var v: Vector2 = dir * (inst.get("spd", 100) * 0.55 * speed_mult)
	# Monsters cannot cross into a town safe zone; they stop at the boundary.
	if SafeZone.is_active():
		if SafeZone.contains(global_position + v * delta):
			v = Vector2.ZERO
			_sz_blocked += delta
		else:
			_sz_blocked = 0.0
	velocity = v + _knock
	move_and_slide()
	_knock = _knock.move_toward(Vector2.ZERO, 900.0 * delta)
	_anim(velocity)

## Gate guards fling approaching monsters back out of town (immortal-guard, §4).
func knockback(from_pos: Vector2, force: float = 340.0) -> void:
	if _state == State.DEAD:
		return
	_knock = (global_position - from_pos).normalized() * force
	_sz_blocked = 0.0
	enraged_until = _now() + 1.5     # briefly refuse to re-aggro while being shoved
	if _state == State.CHASE or _state == State.ATTACK:
		_state = State.WANDER
		_state_timer = 0.3

func _enter_wander() -> void:
	_state = State.WANDER
	_state_timer = 0.0

func _anim(v: Vector2) -> void:
	if sprite.sprite_frames == null:
		return
	if v.length() > 4.0:
		sprite.play("walk_" + SheetUtil.dir_from_vec(v))
	else:
		sprite.play("idle_" + SheetUtil.dir_from_vec(v))

func _attack_player() -> void:
	_attack_cd = 1.3
	var skills: Array = inst.get("skills", ["tackle"])
	var sk := Db.skill(skills[0]) if skills.size() > 0 else Db.skill("tackle")
	if sk.get("kind", "physical") == "buff":
		sk = Db.skill("tackle")
	var ctx := CombatResolver.build_ctx()
	if _player and _player.has_method("take_hit"):
		var pstats: Dictionary = _player.combat_view() if _player.has_method("combat_view") else PlayerData.combat_stats()
		var res := CombatResolver.resolve(MonsterFactory.combat_stats(inst), pstats, sk, ctx)
		_player.take_hit(res, self)

# --- Damage / death ---------------------------------------------------------

func take_hit(result: Dictionary, from) -> void:
	if _state == State.DEAD:
		return
	var dmg: int = result.get("damage", 0)
	hp = max(0, hp - dmg)
	hpbar.visible = true
	hpbar.value = hp
	EventBus.damage_dealt.emit(from, self, dmg, result.get("is_crit", false), result.get("element", "none"))
	_spawn_damage_number(dmg, result.get("is_crit", false), result.get("effective", false))
	_flash()
	Audio.play_sfx("hit")
	# aggro on hit
	if _state in [State.WANDER, State.IDLE]:
		_state = State.CHASE
	if hp <= 0:
		_die(from)

func _die(from) -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO
	Audio.play_sfx("death")
	# split trait
	if "split" in inst.get("traits", []) and inst.get("_no_split", false) == false:
		_split()
	_grant_rewards(from)
	EventBus.monster_killed.emit(inst.get("species_id", "?"), self)
	if _spawner and is_instance_valid(_spawner) and _spawner.has_method("on_monster_died"):
		_spawner.on_monster_died(self)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)

func _split() -> void:
	for i in range(2):
		var child_inst := MonsterFactory.make(inst.get("species_id", ""), max(1, inst.get("level", 1) - 1), 2)
		if child_inst.is_empty():
			continue
		child_inst["max_hp"] = int(child_inst["max_hp"] * 0.5)
		child_inst["hp"] = child_inst["max_hp"]
		child_inst["_no_split"] = true
		var m := preload("res://scenes/actors/Monster.tscn").instantiate()
		get_parent().add_child(m)
		m.setup(child_inst, _spawner)
		m.global_position = global_position + Vector2(randf_range(-16, 16), randf_range(-16, 16))

func _grant_rewards(_from) -> void:
	MonsterFactory.grant_rewards(inst)   # shared with side-view DungeonMonster

# --- Taming (M4 core; input handled by nearby Player) -----------------------

func can_be_tamed() -> bool:
	return _state != State.DEAD and hp <= int(max_hp * 0.05)

func attempt_tame() -> void:
	var res := TamingSystem.attempt(self)
	if res.get("success", false):
		_tamed()
	else:
		# enrage: cannot tame for 10 min, ATK up
		enraged_until = _now() + 600.0
		tame_pity += 0.0005
		EventBus.toast.emit("Taming gagal! " + inst.get("name", "") + " mengamuk.")

func _tamed() -> void:
	_state = State.DEAD
	EventBus.toast.emit("Berhasil menjinakkan " + inst.get("name", "") + "!")
	Audio.play_sfx("success")
	# tamed monsters give NO drop/exp (Monster_Roster §1.4)
	if _spawner and is_instance_valid(_spawner) and _spawner.has_method("on_monster_died"):
		_spawner.on_monster_died(self)
	queue_free()

func _update_tame_hint() -> void:
	tame_hint.visible = can_be_tamed()

# --- FX helpers -------------------------------------------------------------

func _flash() -> void:
	sprite.modulate = Color(1, 0.4, 0.4, 1)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", _base_color, 0.15)

func _spawn_damage_number(amount: int, crit: bool, effective: bool) -> void:
	var dn := preload("res://scenes/ui/DamageNumber.tscn").instantiate()
	get_parent().add_child(dn)
	dn.global_position = global_position + Vector2(0, -10)
	dn.show_number(amount, crit, effective)

func _now() -> float:
	return float(Time.get_ticks_msec()) / 1000.0
