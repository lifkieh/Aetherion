extends Area2D
## Simple skill projectile (e.g. Spark Bolt). Resolves combat on first monster hit.

var _dir := Vector2.RIGHT
var _skill := {}
var _attacker := {}
var _source: Node = null
var _speed := 320.0
var _life := 1.4

func setup(dir: Vector2, skill: Dictionary, attacker_stats: Dictionary, source: Node) -> void:
	_dir = dir.normalized()
	_skill = skill
	_attacker = attacker_stats
	_source = source
	_speed = skill.get("projectile_speed", 320)
	var elem: String = skill.get("element", "none")
	$Sprite.modulate = _elem_color(elem)
	rotation = _dir.angle()

func _physics_process(delta: float) -> void:
	position += _dir * _speed * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

## Sama dengan `Projectile2._live_source()` — penembak yang sudah dibebaskan tak boleh
## sampai ke `take_hit()`. Jalur ini lebih tua tapi cacatnya identik.
func _live_source() -> Node:
	return _source if (_source != null and is_instance_valid(_source)) else null


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("monsters") and body.has_method("take_hit"):
		var ctx := CombatResolver.build_ctx(body.is_wet)
		var res := CombatResolver.resolve(_attacker, body.combat_view(), _skill, ctx)
		body.take_hit(res, _live_source())
		if res.get("chain", false):
			_chain(body, res, ctx)
		queue_free()

func _chain(origin: Node2D, _res: Dictionary, ctx: Dictionary) -> void:
	for m in get_tree().get_nodes_in_group("monsters"):
		if m == origin or not is_instance_valid(m):
			continue
		if m.global_position.distance_to(origin.global_position) < 90.0:
			var r := CombatResolver.resolve(_attacker, m.combat_view(), _skill, ctx)
			r["damage"] = int(r["damage"] * 0.6)
			m.take_hit(r, _live_source())
			EventBus.toast.emit("⚡ Chain!")
			break

func _elem_color(elem: String) -> Color:
	match elem:
		"fire": return Color(1.0, 0.5, 0.2)
		"lightning": return Color(0.9, 0.9, 0.3)
		"ice": return Color(0.6, 0.9, 1.0)
		"water": return Color(0.4, 0.6, 1.0)
		_: return Color.WHITE
