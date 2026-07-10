class_name Player
extends CharacterBody2D
## Player actor. 8-direction movement, 4-facing animation, attack/dodge/skills,
## Element Flow infusion. Reads stats from PlayerData; combat via CombatResolver.

const BASE_SPEED := 92.0
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

	var speed := BASE_SPEED
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
	_position_hitbox(40.0)
	_apply_melee(Db.skill("strike"))
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
		var r: float = sk.get("range", 44)
		_position_hitbox(r)
		_apply_melee(sk)
	Audio.play_sfx("attack")

func _position_hitbox(reach: float) -> void:
	var v := _facing_vec()
	hitbox.position = v * (reach * 0.5)
	(hit_shape.shape as RectangleShape2D).size = Vector2(reach, reach)
	hit_shape.disabled = false
	hitbox.monitoring = true

func _apply_melee(skill: Dictionary) -> void:
	var ctx := CombatResolver.build_ctx()
	var atk := PlayerData.combat_stats()
	var hit_any := false
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("monsters") and body.has_method("take_hit"):
			var target_wet := body.get("is_wet") if body.get("is_wet") != null else false
			ctx["target_wet"] = target_wet or WorldState.is_wet_weather()
			var res := CombatResolver.resolve(atk, body.combat_view(), skill, ctx)
			body.take_hit(res, self)
			hit_any = true
			if res.get("chain", false):
				_chain_lightning(body, res, skill, ctx)
	# hitbox is a quick sweep; disable shortly after
	get_tree().create_timer(0.12).timeout.connect(func():
		if is_instance_valid(hit_shape):
			hit_shape.disabled = true
			hitbox.monitoring = false)

func _chain_lightning(origin: Node2D, res: Dictionary, skill: Dictionary, ctx: Dictionary) -> void:
	# Science demo: lightning arcs to nearby wet monsters (v0.3 §7).
	var atk := PlayerData.combat_stats()
	for m in get_tree().get_nodes_in_group("monsters"):
		if m == origin or not is_instance_valid(m):
			continue
		if m.global_position.distance_to(origin.global_position) < 90.0:
			var chain_res := CombatResolver.resolve(atk, m.combat_view(), skill, ctx)
			chain_res["damage"] = int(chain_res["damage"] * 0.6)
			m.take_hit(chain_res, self)
			EventBus.toast.emit("⚡ Chain!")
			break

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
