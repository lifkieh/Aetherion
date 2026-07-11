extends Node
## ProjectilePool — object pooling for data-driven projectiles (used by player
## AND enemies). Projectiles live under this autoload (global coords) and are
## reused, never queue_free'd during play.

const POOL_SIZE := 40
const SCENE := preload("res://scenes/actors/Projectile2.tscn")

var _free: Array = []
var _all: Array = []

func _ready() -> void:
	for i in range(POOL_SIZE):
		var p = SCENE.instantiate()
		add_child(p)
		_all.append(p)
		_free.append(p)

## Fire a projectile by id. target_group = "monsters" (player shots) or "player".
func spawn(pos: Vector2, dir: Vector2, proj_id: String, atk: Dictionary, source, target_group: String) -> Node:
	var def := Db.projectiles.get(proj_id, {})
	if def.is_empty():
		return null
	var p = _get_free()
	p.launch(pos, dir, def, atk, source, target_group, self)
	return p

## Fire from an explicit def dict (used by fusion spells with a computed element).
func spawn_def(pos: Vector2, dir: Vector2, def: Dictionary, atk: Dictionary, source, target_group: String) -> Node:
	if def.is_empty():
		return null
	var p = _get_free()
	p.launch(pos, dir, def, atk, source, target_group, self)
	return p

func _get_free() -> Node:
	if _free.is_empty():
		var p = SCENE.instantiate()   # grow if exhausted
		add_child(p)
		_all.append(p)
		return p
	return _free.pop_back()

func release(p: Node) -> void:
	if not (p in _free):
		_free.append(p)

func active_count() -> int:
	return _all.size() - _free.size()

func pool_size() -> int:
	return _all.size()
