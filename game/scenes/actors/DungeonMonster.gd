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
var _player: Node2D = null
var _dead := false
var _bob := 0.0

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
	if inst.get("is_boss", false):
		sprite.scale = Vector2(2.2, 2.2)
	hpbar.max_value = max_hp
	hpbar.value = hp
	hpbar.visible = false

func combat_view() -> Dictionary:
	var v := MonsterFactory.combat_stats(inst)
	v["hp"] = hp
	return v

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_hop_cd = maxf(0.0, _hop_cd - delta)
	is_wet = WorldState.is_wet_weather()
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")

	var dx := 9999.0
	if _player:
		dx = _player.global_position.x - global_position.x
	var aggro: float = inst.get("aggro_radius", 160)
	var chasing := _player != null and absf(dx) < aggro and absf(_player.global_position.y - global_position.y) < 120

	if _flyer:
		_fly(delta, chasing)
	else:
		_walk(delta, chasing, dx)

	# attack when close
	if _player and global_position.distance_to(_player.global_position) < (36.0 if inst.get("is_boss", false) else 22.0) and _attack_cd <= 0.0:
		_attack()

func _walk(delta: float, chasing: bool, dx: float) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, 560.0)
	if chasing:
		_dir = signf(dx) if dx != 0 else _dir
		velocity.x = _dir * CHASE_SPEED
		# hop over obstacles / toward player occasionally
		if is_on_floor() and (is_on_wall() or _hop_cd <= 0.0):
			velocity.y = HOP
			_hop_cd = randf_range(1.2, 2.4)
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

func _attack() -> void:
	_attack_cd = 1.3
	var skills: Array = inst.get("skills", ["tackle"])
	var sk := Db.skill(skills[0]) if skills.size() > 0 else Db.skill("tackle")
	if sk.get("kind", "physical") == "buff":
		sk = Db.skill("tackle")
	if _player and _player.has_method("take_hit"):
		var pstats: Dictionary = _player.combat_view() if _player.has_method("combat_view") else PlayerData.combat_stats()
		var res := CombatResolver.resolve(MonsterFactory.combat_stats(inst), pstats, sk, CombatResolver.build_ctx())
		_player.take_hit(res, self)

func take_hit(result: Dictionary, from) -> void:
	if _dead:
		return
	hp = max(0, hp - int(result.get("damage", 0)))
	hpbar.visible = true
	hpbar.value = hp
	EventBus.damage_dealt.emit(from, self, result.get("damage", 0), result.get("is_crit", false), result.get("element", "none"))
	_spawn_damage_number(result.get("damage", 0), result.get("is_crit", false), result.get("effective", false))
	_flash()
	Audio.play_sfx("hit")
	if hp <= 0:
		_die(from)

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
	if "split" in inst.get("traits", []) and not inst.get("_no_split", false):
		_split()
	MonsterFactory.grant_rewards(inst)
	EventBus.monster_killed.emit(inst.get("species_id", "?"), self)
	if _spawner and is_instance_valid(_spawner) and _spawner.has_method("on_monster_died"):
		_spawner.on_monster_died(self)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)

func _split() -> void:
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
	var dn := preload("res://scenes/ui/DamageNumber.tscn").instantiate()
	get_parent().add_child(dn)
	dn.global_position = global_position + Vector2(0, -12)
	dn.show_number(amount, crit, eff)
