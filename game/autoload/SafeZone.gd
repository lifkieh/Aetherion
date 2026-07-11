extends Node
## SafeZone (owner UI/UX §4) — the ACTIVE town's no-monster polygon (global coords).
## Region scenes call set_region() on entry; monsters can't spawn inside it and lose
## aggro / cannot path across its edge. Non-town scenes call clear() so a stale town
## polygon never leaks into another map (all maps share the same coordinate origin).

var _poly: PackedVector2Array = PackedVector2Array()
var _gates: Array = []            # guard-post positions (global)
var _center := Vector2.ZERO       # town center (for outward escape)
var _active := false

## Activate the safe zone for a town id from towns.json (unknown id => cleared).
func set_region(town_id: String) -> void:
	var t: Dictionary = Db.towns.get(town_id, {})
	_poly = PackedVector2Array()
	_gates = []
	if t.is_empty():
		_active = false
		return
	var c: Array = t.get("center", [0, 0])
	_center = Vector2(c[0], c[1])
	for pt in t.get("safe_zone", []):
		_poly.append(_center + Vector2(pt[0], pt[1]))
	for g in t.get("gates", []):
		_gates.append(_center + Vector2(g[0], g[1]))
	_active = _poly.size() >= 3

func clear() -> void:
	_active = false
	_poly = PackedVector2Array()
	_gates = []

func is_active() -> bool:
	return _active

func contains(p: Vector2) -> bool:
	return _active and Geometry2D.is_point_in_polygon(p, _poly)

func polygon() -> PackedVector2Array:
	return _poly

func gates() -> Array:
	return _gates

## Outward direction from town center — a monster caught inside walks this way out.
func escape_vector(p: Vector2) -> Vector2:
	var d := p - _center
	return d.normalized() if d.length() > 0.5 else Vector2.RIGHT
