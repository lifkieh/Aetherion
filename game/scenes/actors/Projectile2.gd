extends Area2D
## Data-driven pooled projectile (projectiles.json). Used by player AND enemies.
## Handles speed, gravity_scale, pierce, bounce, lifetime, element, on_hit_effect.
## Returns itself to ProjectilePool on expiry (no queue_free — pooled).

var active := false
var _def: Dictionary = {}
var _atk: Dictionary = {}
var _source = null
var _target_group := "monsters"
var _life := 0.0
var _pierce := 0
var _bounce := 0
var _pool = null

@onready var sprite: Sprite2D = $Sprite
@onready var shape: CollisionShape2D = $Shape

func _ready() -> void:
	if ResourceLoader.exists("res://assets/game/sprites/dungeon/proj.png"):
		sprite.texture = load("res://assets/game/sprites/dungeon/proj.png")
	body_entered.connect(_on_body)
	_deactivate()

func launch(pos: Vector2, dir: Vector2, def: Dictionary, atk: Dictionary, source, target_group: String, pool) -> void:
	_def = def
	_atk = atk
	_source = source
	_target_group = target_group
	_pool = pool
	_life = def.get("lifetime", 2.0)
	_pierce = int(def.get("pierce", 0))
	_bounce = int(def.get("bounce", 0))
	global_position = pos
	rotation = dir.angle()
	velocity_v = dir.normalized() * float(def.get("speed", 300))
	var col := Color(def.get("color", "ffffff"))
	sprite.modulate = col
	(shape.shape as CircleShape2D).radius = def.get("radius", 4)
	# mask: hit the target group + solid terrain (layer 4)
	collision_mask = (2 if target_group == "monsters" else 1) | 4
	active = true
	visible = true
	monitoring = true
	set_physics_process(true)

var velocity_v := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not active:
		return
	velocity_v.y += 900.0 * float(_def.get("gravity_scale", 0.0)) * delta
	global_position += velocity_v * delta
	rotation = velocity_v.angle()
	_life -= delta
	if _life <= 0.0 or (_source != null and not is_instance_valid(_source)):
		_deactivate()

## Penembak yang sudah dibebaskan TIDAK BOLEH ikut terbang bersama pelurunya.
##
## `_physics_process` sudah menjaga ini (lihat di atas) — tapi `_on_body` dipanggil
## oleh physics server dan **bisa mendahului** `_physics_process` pada frame yang sama.
## Kalau penembaknya dibebaskan di frame itu, `_source` sampai ke `take_hit()` lalu ke
## `EventBus.damage_dealt.emit(from, ...)` sebagai objek mati, dan pendengar mana pun
## yang menyentuhnya ikut jatuh.
##
## Ini bukan kasus tepi buatan test: peluru masih terbang ketika penembaknya mati adalah
## kejadian biasa — monster yang menembak lalu terbunuh, pemain yang mati saat panahnya
## di udara. **Peluru tetap mengenai sasaran** (kerusakan sudah dihitung saat ditembakkan);
## yang hilang cuma atribusi penembaknya, dan itu memang sudah tak ada.
func _live_source():
	return _source if (_source != null and is_instance_valid(_source)) else null


func _on_body(body: Node) -> void:
	if not active:
		return
	if body.is_in_group(_target_group) and body.has_method("take_hit"):
		var elem: String = _def.get("element", "none")
		var skill := {"skill_mod": _def.get("damage_mult", 1.0), "kind": "physical", "element": elem}
		var wet: bool = body.is_wet if ("is_wet" in body) else false
		var ctx := CombatResolver.build_ctx(wet)
		var res := CombatResolver.resolve(_atk, body.combat_view(), skill, ctx)
		body.take_hit(res, _live_source())
		CombatFeel.on_hit(body, global_position, res.get("is_crit", false))
		# `_live_source()`, bukan `_source`: ini satu-satunya sisa rujukan mentah di
		# fungsi ini, dan ia MENYENTUH objeknya (`has_method`), bukan sekadar
		# meneruskannya. Pemicunya `res.chain` — butuh `target_wet`, jadi keadaan,
		# bukan tetap. Itulah kenapa ia tak pernah muncul di test yang rapi.
		var live_src = _live_source()
		if _def.get("on_hit_effect", "") == "chain" and res.get("chain", false) \
				and live_src and live_src.has_method("get"):
			pass  # chain handled by PlayerCombat when relevant
		if _pierce > 0:
			_pierce -= 1
		else:
			_deactivate()
	elif body is StaticBody2D:
		if _bounce > 0:
			_bounce -= 1
			velocity_v.y = -velocity_v.y * 0.6
			velocity_v.x *= 0.8
		else:
			_deactivate()

func _deactivate() -> void:
	active = false
	visible = false
	monitoring = false
	set_physics_process(false)
	velocity_v = Vector2.ZERO
	if _pool != null:
		_pool.release(self)
