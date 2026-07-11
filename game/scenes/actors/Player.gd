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
var _combat_t := 999.0     # seconds since last combat action (idle mana-regen bonus)
var _dodge_timer := 0.0
var _dodge_cd := 0.0
var _dodge_dir := Vector2.ZERO
var _attacking := 0.0
var _iframes := 0.0
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
	# Aetherion Character System: build the look from the saved config (CharGen).
	var cfg: Dictionary = PlayerData.char_config if not PlayerData.char_config.is_empty() else CharGen.default_config()
	sprite.sprite_frames = CharGen.sprite_frames(cfg)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.offset = Vector2(0, -8)     # 32px cell: lift so the character's feet sit at the node origin
	sprite.play("idle_down")

## Rebuild the sprite after the player re-customizes (Cermin Jiwa).
func refresh_look() -> void:
	_build_sprite()

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
	# hold-to-attack (rev A) + hold-to-channel a primed skill (rev B)
	var aim := (get_global_mouse_position() - global_position)
	aim = aim.normalized() if aim.length() > 2.0 else _facing_vec()
	if Input.is_action_pressed("attack"):
		facing = SheetUtil.dir_from_vec(aim)
		_combat_t = 0.0
		if hotbar.is_primed():
			if Input.is_action_just_pressed("attack"):
				hotbar.begin_cast(self, aim)
			else:
				hotbar.channel_tick(self, aim, delta)
		elif _attack_cd <= 0.0:
			_attack_cd = _basic_attack_interval()
			_do_attack()
	elif Input.is_action_just_released("attack"):
		hotbar.end_cast()

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

# Base attacks/sec per weapon type (before AGI attack_speed). Weapons may override
# via item "attack_rate". (rev A: hold-to-attack at the weapon's attack rate.)
const WEAPON_RATE := {"bow": 3.3, "wand": 3.0, "spear": 2.4, "sword": 2.85}

func _basic_attack_interval() -> float:
	var w := Db.item(PlayerData.equipped_weapon)
	var rate: float = w.get("attack_rate", WEAPON_RATE.get(_weapon_type(), 2.85))
	return 1.0 / maxf(0.4, rate * PlayerData.attack_speed)

func _do_attack() -> void:
	var aim := (get_global_mouse_position() - global_position)
	aim = aim.normalized() if aim.length() > 2.0 else _facing_vec()
	facing = SheetUtil.dir_from_vec(aim)
	_attacking = ATTACK_TIME
	sprite.play("attack_" + facing)
	match _weapon_type():
		"bow":
			PlayerCombat.fire_pooled(self, aim, Db.item(PlayerData.equipped_weapon).get("projectile", "arrow"))
		"wand":
			var w := Db.item(PlayerData.equipped_weapon)
			if not PlayerData.spend_mp(w.get("mana_cost", 3)):
				_attacking = 0.0
				return
			PlayerCombat.fire_pooled(self, aim, w.get("projectile", "fireball"))
		"spear":
			PlayerCombat.melee_arc(self, aim, 60.0, 40.0, Db.skill("strike"), 1.15)
		_:
			PlayerCombat.melee_arc(self, aim, 46.0, 120.0, Db.skill("strike"))
	Audio.play_sfx("attack")

func _update_infusion_aura(delta: float) -> void:
	sprite.modulate = PlayerCombat.infusion_tint()
	# Element Flow upkeep: drain mana per second while active (rev E)
	if PlayerData.has_active_infusion():
		PlayerData.drain_mana(PlayerData.infusion.get("drain", 2.0) * delta)

# --- Damage taken -----------------------------------------------------------

func take_hit(result: Dictionary, _from) -> void:
	if _iframes > 0.0:
		return
	if result.get("miss", false):
		return
	var dmg: int = result.get("damage", 0)
	PlayerData.take_damage(dmg)
	EventBus.damage_dealt.emit(_from, self, dmg, result.get("is_crit", false), result.get("element", "none"))
	_iframes = CombatFeel.iframes()   # tuned i-frames (combat feel parity, PC6)
	_combat_t = 0.0
	_flash_hurt()
	CombatFeel.shake(4.0, 0.12)
	Audio.play_sfx("hurt")
	if PlayerData.is_dead():
		EventBus.player_died.emit()
		_on_death()

func _flash_hurt() -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.4, 0.4), 0.05)
	tw.tween_property(sprite, "modulate", Color(1, 1, 1), 0.12)

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
	_combat_t += delta

func _regen_mp(delta: float) -> void:
	# base + INT scaling (PlayerData.mana_regen); surges when out of combat for 3s (rev B)
	var rate := PlayerData.mana_regen * (3.0 if _combat_t > 3.0 else 1.0)
	PlayerData.regen_mana(rate * delta)
