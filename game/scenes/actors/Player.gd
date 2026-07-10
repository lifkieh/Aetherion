class_name Player
extends CharacterBody2D
## Player actor. 8-direction movement, 4-facing animation, attack/dodge/skills,
## Element Flow infusion. Reads stats from PlayerData; combat via CombatResolver.

const BASE_SPEED := 92.0
const MOUNT_SPEED := 168.0
const DODGE_SPEED := 260.0
const DODGE_TIME := 0.22
const DODGE_CD := 0.7
const ATTACK_TIME := 0.28

var facing := "down"
var _attack_cd := 0.0
var _dodge_timer := 0.0
var _dodge_cd := 0.0
var _dodge_dir := Vector2.ZERO
var _attacking := 0.0
var _iframes := 0.0
var _skill_cd := {}                       # skill_id -> remaining
var _mp_regen_acc := 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var hit_shape: CollisionShape2D = $Hitbox/Shape

func _ready() -> void:
	add_to_group("player")
	_build_sprite()
	var cam := Camera2D.new()
	cam.zoom = Vector2(3, 3)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	add_child(cam)

func _build_sprite() -> void:
	var tex := SheetUtil.load_tex("res://assets/game/sprites/player/walk.png")
	if tex:
		sprite.sprite_frames = SheetUtil.build_directional(tex, 16, 4, 4, 8.0)
		sprite.play("idle_down")

func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	_regen_mp(delta)
	_update_infusion_aura(delta)

	if _dodge_timer > 0.0:
		velocity = _dodge_dir * DODGE_SPEED
		move_and_slide()
		return

	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input.length() > 1.0:
		input = input.normalized()

	# Actions
	if Input.is_action_just_pressed("dodge") and _dodge_cd <= 0.0:
		_start_dodge(input)
		return
	if Input.is_action_just_pressed("attack") and _attack_cd <= 0.0:
		_do_attack()
	if Input.is_action_just_pressed("skill_1"):
		_do_skill("flame_slash")
	if Input.is_action_just_pressed("skill_2"):
		_do_skill("spark_bolt")
	if Input.is_action_just_pressed("infuse_fire"):
		PlayerData.apply_infusion("fire", 45)
	if Input.is_action_just_pressed("infuse_lightning"):
		PlayerData.apply_infusion("lightning", 45)

	var speed := MOUNT_SPEED if PlayerData.mounted else BASE_SPEED
	velocity = input * speed
	move_and_slide()

	if input != Vector2.ZERO:
		facing = SheetUtil.dir_from_vec(input)
	_update_anim(input)

func _update_anim(input: Vector2) -> void:
	if _attacking > 0.0:
		return
	if input != Vector2.ZERO:
		sprite.play("walk_" + facing)
	else:
		sprite.play("idle_" + facing)

func _start_dodge(input: Vector2) -> void:
	_dodge_dir = input if input != Vector2.ZERO else _facing_vec()
	_dodge_timer = DODGE_TIME
	_dodge_cd = DODGE_CD
	_iframes = DODGE_TIME + 0.05
	Audio.play_sfx("dodge")

func _facing_vec() -> Vector2:
	match facing:
		"up": return Vector2.UP
		"left": return Vector2.LEFT
		"right": return Vector2.RIGHT
		_: return Vector2.DOWN

# --- Attacks / skills -------------------------------------------------------

func _do_attack() -> void:
	_attack_cd = 0.35
	_attacking = ATTACK_TIME
	sprite.play("walk_" + facing)
	_apply_melee(Db.skill("strike"), 42.0)
	Audio.play_sfx("attack")

func _do_skill(skill_id: String) -> void:
	if _skill_cd.get(skill_id, 0.0) > 0.0:
		return
	var sk := Db.skill(skill_id)
	if sk.is_empty():
		return
	var cost: int = sk.get("mp_cost", 0)
	if not PlayerData.spend_mp(cost):
		EventBus.toast.emit("Mana tidak cukup")
		return
	_skill_cd[skill_id] = sk.get("cooldown", 1.0)
	_attacking = ATTACK_TIME
	sprite.play("walk_" + facing)
	if sk.get("projectile", false):
		_fire_projectile(sk)
	else:
		_apply_melee(sk, sk.get("range", 44))
	Audio.play_sfx("attack")

## Geometric melee: hit monsters within `reach` and inside a ~120° cone ahead.
## Robust in headless (no Area2D overlap timing) and matches on-screen swing.
func _apply_melee(skill: Dictionary, reach: float) -> void:
	var fv := _facing_vec()
	var atk := PlayerData.combat_stats()
	var aoe: bool = skill.get("aoe", false)
	var targets := []
	for m in get_tree().get_nodes_in_group("monsters"):
		if not is_instance_valid(m) or not m.has_method("take_hit"):
			continue
		var to: Vector2 = m.global_position - global_position
		if to.length() > reach:
			continue
		if to != Vector2.ZERO and fv.dot(to.normalized()) < 0.35:
			continue  # not in front
		targets.append(m)
	# single-target attacks hit the nearest; aoe hits all in cone
	if not aoe and targets.size() > 1:
		targets.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
		targets = [targets[0]]
	# swing flourish, tinted by the effective attack element
	var swing_elem: String = skill.get("element", "none")
	if swing_elem == "none":
		swing_elem = atk.get("element", "none")
	Vfx.swing(get_parent(), global_position, fv, swing_elem)
	for m in targets:
		var ctx := CombatResolver.build_ctx(m.is_wet)
		var res := CombatResolver.resolve(atk, m.combat_view(), skill, ctx)
		m.take_hit(res, self)
		if res.get("chain", false):
			_chain_lightning(m, res, skill, ctx)

func _chain_lightning(origin: Node2D, _res: Dictionary, skill: Dictionary, ctx: Dictionary) -> void:
	# Science demo: lightning arcs to nearby wet monsters (v0.3 §7).
	var atk := PlayerData.combat_stats()
	var chained := 0
	for m in get_tree().get_nodes_in_group("monsters"):
		if m == origin or not is_instance_valid(m):
			continue
		if not m.is_wet:
			continue  # only conducts to wet targets (science)
		if m.global_position.distance_to(origin.global_position) < 96.0:
			var chain_res := CombatResolver.resolve(atk, m.combat_view(), skill, ctx)
			chain_res["damage"] = int(chain_res["damage"] * 0.6)
			m.take_hit(chain_res, self)
			Vfx.chain_arc(get_parent(), origin.global_position, m.global_position, "lightning")
			chained += 1
			if chained >= 3:
				break
	if chained > 0:
		EventBus.toast.emit("⚡ Chain x%d (musuh basah)!" % chained)

func _update_infusion_aura(_delta: float) -> void:
	if PlayerData.has_active_infusion():
		var c := Vfx.elem_color(PlayerData.infusion.get("element", "none"))
		var pulse := 0.6 + 0.4 * sin(Time.get_ticks_msec() / 120.0)
		sprite.modulate = Color(1, 1, 1).lerp(c, 0.5 * pulse)
	else:
		sprite.modulate = Color.WHITE

func _fire_projectile(skill: Dictionary) -> void:
	var proj := preload("res://scenes/actors/Projectile.tscn").instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + _facing_vec() * 12.0
	proj.setup(_facing_vec(), skill, PlayerData.combat_stats(), self)

# --- Damage taken -----------------------------------------------------------

func take_hit(result: Dictionary, _from) -> void:
	if _iframes > 0.0:
		return
	var dmg: int = result.get("damage", 0)
	PlayerData.take_damage(dmg)
	EventBus.damage_dealt.emit(_from, self, dmg, result.get("is_crit", false), result.get("element", "none"))
	_iframes = 0.4
	Audio.play_sfx("hurt")
	if PlayerData.is_dead():
		_on_death()

func _on_death() -> void:
	EventBus.toast.emit("Kamu tumbang! Bangkit kembali...")
	PlayerData.respawn()
	global_position = Vector2(200, 200)

# --- Timers / regen ---------------------------------------------------------

func _tick_timers(delta: float) -> void:
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_dodge_cd = maxf(0.0, _dodge_cd - delta)
	_dodge_timer = maxf(0.0, _dodge_timer - delta)
	_attacking = maxf(0.0, _attacking - delta)
	_iframes = maxf(0.0, _iframes - delta)
	for k in _skill_cd.keys():
		_skill_cd[k] = maxf(0.0, _skill_cd[k] - delta)

func _regen_mp(delta: float) -> void:
	_mp_regen_acc += delta
	if _mp_regen_acc >= 1.0:
		_mp_regen_acc = 0.0
		if PlayerData.mp < PlayerData.max_mp:
			PlayerData.restore_mp(2)
