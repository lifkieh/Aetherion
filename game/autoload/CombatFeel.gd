extends Node
## CombatFeel — Terraria-style game feel (combat_feel.json): knockback (both
## parties, weighted by archetype), hitstop, and screen shake. Flash + i-frames
## are applied by the target's take_hit (this exposes the tuned durations).

var cfg: Dictionary = {}
var _restoring := false

func _ready() -> void:
	cfg = Db.combat_feel if not Db.combat_feel.is_empty() else _defaults()

func _defaults() -> Dictionary:
	return {"iframes": 0.5, "flash_time": 0.12, "hitstop_frames": 3,
		"screen_shake": {"amount": 3.0, "time": 0.12}, "knockback": {"base": 130.0, "by_archetype": {}}}

func iframes() -> float:
	return cfg.get("iframes", 0.5)

func flash_time() -> float:
	return cfg.get("flash_time", 0.12)

## Per-source hit-immunity window (anti-melt, owner combat rev D).
func hit_immunity(is_boss: bool = false) -> float:
	var hi: Dictionary = cfg.get("hit_immunity", {})
	return hi.get("boss", 0.4) if is_boss else hi.get("normal", 0.2)

## Apply knockback to `target` away from `from_pos`, plus hitstop + shake.
func on_hit(target: Node, from_pos: Vector2, is_crit: bool = false) -> void:
	apply_knockback(target, from_pos)
	hitstop(cfg.get("hitstop_frames_crit", 5) if is_crit else cfg.get("hitstop_frames", 3))
	var sh: Dictionary = cfg.get("screen_shake", {})
	shake(sh.get("amount_crit", 5.0) if is_crit else sh.get("amount", 3.0), sh.get("time", 0.12))

func apply_knockback(target: Node, from_pos: Vector2, force_mult: float = 1.0) -> void:
	if target == null or not is_instance_valid(target) or not ("velocity" in target):
		return
	var kb: Dictionary = cfg.get("knockback", {})
	var base: float = kb.get("base", 130.0)
	var arche := _archetype_of(target)
	var mult: float = kb.get("by_archetype", {}).get(arche, 1.0)
	var dir: Vector2 = (target.global_position - from_pos)
	dir.x = signf(dir.x) if dir.x != 0.0 else (1.0 if randf() > 0.5 else -1.0)
	dir.y = -0.35   # slight upward pop
	target.velocity += Vector2(dir.x, dir.y).normalized() * base * mult * force_mult

func _archetype_of(target: Node) -> String:
	if "inst" in target and target.inst is Dictionary:
		return target.inst.get("archetype", "bruiser")
	return "player"

func hitstop(frames: int) -> void:
	if frames <= 0 or _restoring:
		return
	Engine.time_scale = 0.0001
	_restoring = true
	var t := get_tree().create_timer(frames / 60.0, true, false, true)  # ignore_time_scale
	t.timeout.connect(func():
		Engine.time_scale = 1.0
		_restoring = false)

func shake(amount: float, time: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var tw := cam.create_tween()
	for i in range(4):
		tw.tween_property(cam, "offset", Vector2(randf_range(-amount, amount), randf_range(-amount, amount)), time / 4.0)
	tw.tween_property(cam, "offset", Vector2.ZERO, time / 4.0)
