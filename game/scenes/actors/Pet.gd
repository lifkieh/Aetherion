class_name Pet
extends CharacterBody2D
## Allied pet (M4): follows the player and assists in combat.
## Configured from a PlayerData.monsters[] entry. When the player is mounted
## on this pet, it hides and lends its speed to the player.

const FOLLOW_DIST := 40.0
const AGGRO := 150.0
const ATTACK_RANGE := 26.0

var pet: Dictionary = {}
var _attack_cd := 0.0
var _player: Node2D = null

@onready var sprite: AnimatedSprite2D = $Sprite

func setup(pet_data: Dictionary) -> void:
	pet = pet_data
	if is_inside_tree():
		_build_sprite()

func _ready() -> void:
	add_to_group("pets")
	if not pet.is_empty():
		_build_sprite()
	_player = get_tree().get_first_node_in_group("player")
	_add_ally_marker()

func _build_sprite() -> void:
	var def := Db.monster(pet.get("species_id", ""))
	var tex := SheetUtil.load_tex(def.get("sprite", ""))
	if tex == null:
		tex = SheetUtil.load_tex("res://assets/game/sprites/monsters/slime.png")
	if tex:
		sprite.sprite_frames = SheetUtil.build_directional(tex, def.get("frame_size", 16), def.get("cols", 4), def.get("rows", 4), 6.0)
		sprite.play("idle_down")
	var tint: String = def.get("tint", "")
	if tint != "":
		sprite.modulate = Color(tint)

func _play(anim: String) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

func _add_ally_marker() -> void:
	var m := ColorRect.new()
	m.color = Color(0.4, 1.0, 0.5, 0.9)
	m.size = Vector2(3, 3)
	m.position = Vector2(-1.5, -14)
	add_child(m)

func _physics_process(delta: float) -> void:
	_attack_cd = maxf(0.0, _attack_cd - delta)
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		return

	# Mounted: hide and stick to the player (player borrows our SPD).
	if PlayerData.mounted and _is_active_pet():
		visible = false
		global_position = _player.global_position
		velocity = Vector2.ZERO
		return
	visible = true

	var enemy := _nearest_enemy()
	if enemy and enemy.global_position.distance_to(global_position) <= AGGRO:
		var d: float = enemy.global_position.distance_to(global_position)
		if d <= ATTACK_RANGE:
			velocity = Vector2.ZERO
			if _attack_cd <= 0.0:
				_attack(enemy)
		else:
			_move_to(enemy.global_position, delta)
	else:
		# follow player
		var to_player := _player.global_position - global_position
		if to_player.length() > FOLLOW_DIST:
			_move_to(_player.global_position, delta)
		else:
			velocity = Vector2.ZERO
			_play("idle_" + SheetUtil.dir_from_vec(to_player))

func _move_to(target: Vector2, _delta: float) -> void:
	var dir := (target - global_position).normalized()
	velocity = dir * (pet.get("spd", 120) * 0.6 + 40.0)
	move_and_slide()
	_play("walk_" + SheetUtil.dir_from_vec(dir))

func _attack(enemy) -> void:
	_attack_cd = 1.1
	var atk := {
		"atk": pet.get("atk", 12), "matk": pet.get("atk", 12),
		"crit_rate": 0.05, "crit_dmg": 1.5,
		"element": pet.get("element", "none"), "level": pet.get("level", 1),
	}
	# Passive-only at 50% while player is mounted on a different pet is n/a here.
	var mult := 1.0
	var ctx := CombatResolver.build_ctx(enemy.is_wet)
	var res := CombatResolver.resolve(atk, enemy.combat_view(), Db.skill("bite"), ctx)
	res["damage"] = int(res["damage"] * mult)
	if enemy.has_method("take_hit"):
		enemy.take_hit(res, self)
	Vfx.swing(get_parent(), global_position, (enemy.global_position - global_position).normalized(), pet.get("element", "none"))

func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var bd := AGGRO
	var origin: Vector2 = _player.global_position if _player else global_position
	for m in get_tree().get_nodes_in_group("monsters"):
		if not is_instance_valid(m):
			continue
		var d: float = m.global_position.distance_to(origin)
		if d < bd:
			bd = d
			best = m
	return best

func _is_active_pet() -> bool:
	var idx := PlayerData.active_pet_index
	return idx >= 0 and idx < PlayerData.monsters.size() and PlayerData.monsters[idx] == pet
