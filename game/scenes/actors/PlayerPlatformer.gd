class_name PlayerPlatformer
extends CharacterBody2D
## Side-view platformer player for DUNGEONS (owner decision 2026-07-11).
## Reuses PlayerData stats + PlayerCombat for all combat — no logic duplication.
## Physics: gravity, jump (coyote + buffer), Wind double-jump, one-way drop,
## ladders, and mining soft blocks in the facing direction.

const MOVE_SPEED := 118.0
const GRAVITY := 980.0
const MAX_FALL := 560.0
const JUMP_VELOCITY := -330.0
const DOUBLE_JUMP_VELOCITY := -270.0
const CLIMB_SPEED := 90.0
const COYOTE := 0.10
const JUMP_BUFFER := 0.10
const PLATFORM_MASK_BIT := 3   # collision layer 8 (one-way platforms)

var facing := "right"
var _coyote := 0.0
var _jump_buf := 0.0
var _attack_cd := 0.0
var _mine_cd := 0.0
var _skill_cd := {}
var _iframes := 0.0
var _double_jumped := false
var _drop_timer := 0.0
var _mp_acc := 0.0
var _charging := false
var _charge := 0.0
var hotbar := Hotbar.new()
var terrain: Node = null

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	add_to_group("player")
	_build_sprite()
	var cam := Camera2D.new()
	cam.zoom = Vector2(3, 3)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 9.0
	add_child(cam)
	terrain = get_tree().get_first_node_in_group("terrain")

func _build_sprite() -> void:
	var tex := SheetUtil.load_tex("res://assets/game/sprites/player/walk.png")
	if tex:
		sprite.sprite_frames = SheetUtil.build_directional(tex, 16, 4, 4, 8.0)
		sprite.play("idle_right")

func _facing_vec() -> Vector2:
	return Vector2.LEFT if facing == "left" else Vector2.RIGHT

func _physics_process(delta: float) -> void:
	_tick(delta)
	if terrain == null or not is_instance_valid(terrain):
		terrain = get_tree().get_first_node_in_group("terrain")

	var ix := Input.get_axis("move_left", "move_right")
	var iy := Input.get_axis("move_up", "move_down")
	if ix != 0.0:
		facing = "right" if ix > 0.0 else "left"

	var on_ladder: bool = terrain != null and terrain.has_method("is_ladder") and terrain.is_ladder(global_position)

	# --- vertical ---
	if on_ladder and (Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down")):
		velocity.y = iy * CLIMB_SPEED
		_double_jumped = false
	else:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)

	if is_on_floor():
		_coyote = COYOTE
		_double_jumped = false

	# jump (with coyote + buffer) and Wind double-jump
	if Input.is_action_just_pressed("dodge") or Input.is_action_just_pressed("move_up"):
		_jump_buf = JUMP_BUFFER
	if _jump_buf > 0.0:
		if _coyote > 0.0 or is_on_floor():
			velocity.y = JUMP_VELOCITY
			_jump_buf = 0.0
			_coyote = 0.0
			Audio.play_sfx("dodge")
		elif not _double_jumped and _has_wind_flow():
			velocity.y = DOUBLE_JUMP_VELOCITY
			_double_jumped = true
			_jump_buf = 0.0
			Vfx.spark(get_parent(), global_position, "wind")

	# drop through one-way platform: down + jump
	if Input.is_action_pressed("move_down") and (Input.is_action_just_pressed("dodge")):
		_drop_timer = 0.2
	if _drop_timer > 0.0:
		set_collision_mask_value(PLATFORM_MASK_BIT + 1, false)
	else:
		set_collision_mask_value(PLATFORM_MASK_BIT + 1, true)

	# --- horizontal ---
	velocity.x = ix * MOVE_SPEED

	# --- actions (mouse-aimed, hotbar + Terraria-style) ---
	var aim := _aim_dir()
	if aim.x != 0.0:
		facing = "right" if aim.x > 0.0 else "left"
	hotbar.tick(delta)
	for i in range(5):
		if Input.is_action_just_pressed("slot_%d" % (i + 1)):
			hotbar.press_slot(i)
	# left-click: cast primed skill/fusion toward cursor, else weapon attack
	if Input.is_action_just_pressed("attack") and (hotbar.primed >= 0 or hotbar.fusion_ready):
		hotbar.cast(self, aim)
	else:
		_handle_attack(aim)

	move_and_slide()
	_animate(ix, on_ladder)
	sprite.modulate = PlayerCombat.infusion_tint()
	if _flow_rule("freeze_puddle"):
		_freeze_nearby_puddles()

## Read an element-flow platformer rule from data (elements.json).
func _flow_rule(key: String) -> bool:
	if not PlayerData.has_active_infusion():
		return false
	var elem: String = PlayerData.infusion.get("element", "")
	return bool(Db.elements.get("platformer_rules", {}).get(elem, {}).get(key, false))

func _has_wind_flow() -> bool:
	return _flow_rule("double_jump")

func _freeze_nearby_puddles() -> void:
	for p in get_tree().get_nodes_in_group("puddle"):
		if is_instance_valid(p) and p.has_method("freeze") and p.global_position.distance_to(global_position) < 40.0:
			p.freeze()

func _animate(ix: float, on_ladder: bool) -> void:
	if sprite.sprite_frames == null:
		return
	if on_ladder and absf(velocity.y) > 4.0:
		sprite.play("walk_up")
	elif absf(ix) > 0.1:
		sprite.play("walk_" + facing)
	else:
		sprite.play("idle_" + facing)

# --- combat (shared) + mining ----------------------------------------------

func _aim_dir() -> Vector2:
	var d := get_global_mouse_position() - global_position
	if d.length() < 2.0:
		return _facing_vec()
	return d.normalized()

func _weapon_type() -> String:
	var w: String = PlayerData.equipped_weapon
	if w == "":
		return "sword"
	return Db.item(w).get("weapon_type", "sword")

## Per-weapon behavior (owner req 5). Element Flow still applies via melee_arc.
func _handle_attack(aim: Vector2) -> void:
	var wt := _weapon_type()
	if wt == "bow":
		if Input.is_action_pressed("attack"):
			_charge = minf(1.0, _charge + get_physics_process_delta_time() / 0.8)
			_charging = true
		elif _charging and Input.is_action_just_released("attack"):
			_charging = false
			PlayerCombat.fire_pooled(self, aim, "arrow", 0.5 + _charge)
			Audio.play_sfx("attack")
			_attack_cd = 0.25
			_charge = 0.0
		return
	if not Input.is_action_just_pressed("attack") or _attack_cd > 0.0:
		return
	match wt:
		"spear":
			_attack_cd = 0.42
			PlayerCombat.melee_arc(self, aim, 66.0, 34.0, Db.skill("strike"), 1.15)
		"wand":
			var w := Db.item(PlayerData.equipped_weapon)
			var cost: int = w.get("mana_cost", 5)
			if not PlayerData.spend_mp(cost):
				EventBus.toast.emit("Mana tidak cukup")
				return
			_attack_cd = 0.34
			PlayerCombat.fire_pooled(self, aim, w.get("projectile", "fireball"))
		_:  # sword (fast wide arc)
			_attack_cd = 0.28
			PlayerCombat.melee_arc(self, aim, 46.0, 110.0, Db.skill("strike"))
	Audio.play_sfx("attack")
	_try_mine()

func _cast_flame(aim: Vector2) -> void:
	if _skill_cd.get("flame_slash", 0.0) > 0.0:
		return
	var sk := Db.skill("flame_slash")
	if not PlayerData.spend_mp(sk.get("mp_cost", 8)):
		EventBus.toast.emit("Mana tidak cukup")
		return
	_skill_cd["flame_slash"] = sk.get("cooldown", 2.0)
	PlayerCombat.melee_arc(self, aim, 52.0, 120.0, sk)
	Audio.play_sfx("attack")

func _cast_bolt(aim: Vector2) -> void:
	if _skill_cd.get("spark_bolt", 0.0) > 0.0:
		return
	var sk := Db.skill("spark_bolt")
	if not PlayerData.spend_mp(sk.get("mp_cost", 10)):
		EventBus.toast.emit("Mana tidak cukup")
		return
	_skill_cd["spark_bolt"] = sk.get("cooldown", 2.0)
	PlayerCombat.fire_pooled(self, aim, "spark")
	Audio.play_sfx("attack")

func _try_mine() -> void:
	if _mine_cd > 0.0 or terrain == null or not terrain.has_method("try_mine"):
		return
	var target := global_position + _facing_vec() * 14.0
	if terrain.try_mine(target):
		_mine_cd = 0.25

# --- damage taken (mirrors top-down Player, minimal) ------------------------

func take_hit(result: Dictionary, from) -> void:
	if _iframes > 0.0:
		return
	var dmg: int = result.get("damage", 0)
	PlayerData.take_damage(dmg)
	EventBus.damage_dealt.emit(from, self, dmg, result.get("is_crit", false), result.get("element", "none"))
	_iframes = CombatFeel.iframes()
	# knockback on the player too (two-directional feel)
	if from != null and is_instance_valid(from):
		CombatFeel.apply_knockback(self, from.global_position, 0.8)
	_flash_hurt()
	Audio.play_sfx("hurt")
	if PlayerData.is_dead():
		EventBus.player_died.emit()
		_on_death()

func combat_view() -> Dictionary:
	return PlayerData.combat_stats()

func _flash_hurt() -> void:
	sprite.modulate = Color(1, 0.4, 0.4)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color.WHITE, CombatFeel.flash_time())

func _on_death() -> void:
	if ScenarioManager.active_scenario != "":
		return
	EventBus.toast.emit("Kamu tumbang di kegelapan...")
	PlayerData.respawn()
	# respawn at dungeon entrance
	var t := get_tree().get_first_node_in_group("dungeon_spawn")
	if t:
		global_position = t.global_position

func _tick(delta: float) -> void:
	_coyote = maxf(0.0, _coyote - delta)
	_jump_buf = maxf(0.0, _jump_buf - delta)
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_mine_cd = maxf(0.0, _mine_cd - delta)
	_iframes = maxf(0.0, _iframes - delta)
	_drop_timer = maxf(0.0, _drop_timer - delta)
	for k in _skill_cd.keys():
		_skill_cd[k] = maxf(0.0, _skill_cd[k] - delta)
	_mp_acc += delta
	if _mp_acc >= 1.0:
		_mp_acc = 0.0
		if PlayerData.mp < PlayerData.max_mp:
			PlayerData.restore_mp(2)
