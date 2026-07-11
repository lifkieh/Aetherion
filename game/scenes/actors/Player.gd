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
var hotbar := Hotbar.new()

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var hit_shape: CollisionShape2D = $Hitbox/Shape

func _ready() -> void:
	add_to_group("player")
	_build_sprite()
	var cam := Camera2D.new()
	# R2: zoom out from 3x → 2x so the player sees the town + landmarks (world felt
	# empty largely because only ~427x240 world units were visible at 3x).
	var z := 1.0 if OS.get_environment("AETHER_WIDE") == "1" else 2.0
	cam.zoom = Vector2(z, z)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	add_child(cam)

func _build_sprite() -> void:
	var tex := SheetUtil.load_tex("res://assets/game/sprites/player/walk.png")
	if tex:
		sprite.sprite_frames = SheetUtil.build_directional(tex, 16, 4, 4, 8.0)
		sprite.play("idle_down")

func _physics_process(delta: float) -> void:
	z_index = int(global_position.y)   # y-sort with town buildings/props (R2)
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

	# Actions (hotbar prime -> left-click cast to cursor; same as dungeon)
	if Input.is_action_just_pressed("dodge") and _dodge_cd <= 0.0:
		_start_dodge(input)
		return
	hotbar.tick(delta)
	for i in range(5):
		if Input.is_action_just_pressed("slot_%d" % (i + 1)):
			hotbar.press_slot(i)
	if Input.is_action_just_pressed("attack"):
		var aim := (get_global_mouse_position() - global_position)
		aim = aim.normalized() if aim.length() > 2.0 else _facing_vec()
		if (hotbar.primed >= 0 or hotbar.fusion_ready) and hotbar.cast(self, aim):
			pass
		elif _attack_cd <= 0.0:
			facing = SheetUtil.dir_from_vec(aim)
			_do_attack()

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

func _weapon_type() -> String:
	var w: String = PlayerData.equipped_weapon
	return "sword" if w == "" else Db.item(w).get("weapon_type", "sword")

func _do_attack() -> void:
	# Aim toward the cursor so the weapon behavior matches the click scheme, same
	# control language as the side-view (SKILL_AUDIT §6: weapons ↔ click scheme).
	var aim := (get_global_mouse_position() - global_position)
	aim = aim.normalized() if aim.length() > 2.0 else _facing_vec()
	facing = SheetUtil.dir_from_vec(aim)
	_attacking = ATTACK_TIME
	sprite.play("walk_" + facing)
	match _weapon_type():
		"bow":
			_attack_cd = 0.3
			PlayerCombat.fire_pooled(self, aim, Db.item(PlayerData.equipped_weapon).get("projectile", "arrow"))
		"wand":
			var w := Db.item(PlayerData.equipped_weapon)
			var cost: int = w.get("mana_cost", 5)
			if not PlayerData.spend_mp(cost):
				EventBus.toast.emit("Mana tidak cukup")
				_attacking = 0.0
				return
			_attack_cd = 0.34
			PlayerCombat.fire_pooled(self, aim, w.get("projectile", "fireball"))
		"spear":
			_attack_cd = 0.42
			PlayerCombat.melee_arc(self, aim, 60.0, 40.0, Db.skill("strike"), 1.15)
		_:  # sword / default — wide arc toward cursor
			_attack_cd = 0.35
			PlayerCombat.melee_arc(self, aim, 46.0, 120.0, Db.skill("strike"))
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

## Delegates to the shared PlayerCombat (reused by the side-view platformer too).
func _apply_melee(skill: Dictionary, reach: float) -> void:
	PlayerCombat.melee(self, _facing_vec(), reach, skill)

func _update_infusion_aura(_delta: float) -> void:
	sprite.modulate = PlayerCombat.infusion_tint()

func _fire_projectile(skill: Dictionary) -> void:
	PlayerCombat.fire_projectile(self, _facing_vec(), skill)

# --- Damage taken -----------------------------------------------------------

func take_hit(result: Dictionary, _from) -> void:
	if _iframes > 0.0:
		return
	var dmg: int = result.get("damage", 0)
	PlayerData.take_damage(dmg)
	EventBus.damage_dealt.emit(_from, self, dmg, result.get("is_crit", false), result.get("element", "none"))
	_iframes = 0.55   # brief invulnerability caps swarm burst to a fair rate
	Audio.play_sfx("hurt")
	if PlayerData.is_dead():
		EventBus.player_died.emit()
		_on_death()

func _on_death() -> void:
	# Don't auto-respawn during a Hidden Scenario — the scene decides the outcome.
	if ScenarioManager.active_scenario != "":
		return
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
