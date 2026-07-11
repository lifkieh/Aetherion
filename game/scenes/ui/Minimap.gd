extends Control
## Minimap (R2 Part 3) — a cheap radar drawn from node POSITIONS (not a re-render of
## the world). Centred on the player; plots buildings/NPCs, the dungeon door, portals
## and monsters as coloured dots. Throttled redraw.

const SCALE := 0.085          # world px -> minimap px (120px shows ~±700 world)
var _cd := 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(118, 118)

func _process(delta: float) -> void:
	_cd -= delta
	if _cd > 0.0:
		return
	_cd = 0.15
	queue_redraw()

func _draw() -> void:
	var r := size
	# backdrop + border
	draw_rect(Rect2(Vector2.ZERO, r), Color(0.04, 0.06, 0.14, 0.85))
	draw_rect(Rect2(Vector2.ZERO, r), Color(1.0, 0.86, 0.42), false, 2.0)
	var pl := get_tree().get_first_node_in_group("player")
	if pl == null:
		return
	var origin: Vector2 = pl.global_position
	var c := r * 0.5
	var rad := r.x * 0.5 - 3.0
	# POIs
	_plot_group("interactable", origin, c, rad, Color(1.0, 0.85, 0.4))
	_plot_group("villagers", origin, c, rad, Color(0.6, 0.9, 1.0))
	_plot_group("monsters", origin, c, rad, Color(1.0, 0.4, 0.4))
	# player (always centre)
	draw_circle(c, 3.0, Color(1, 1, 1))
	draw_circle(c, 1.5, Color(0.3, 0.8, 1.0))

func _plot_group(group: String, origin: Vector2, c: Vector2, rad: float, col: Color) -> void:
	for n in get_tree().get_nodes_in_group(group):
		if not is_instance_valid(n) or not (n is Node2D):
			continue
		var d: Vector2 = (n.global_position - origin) * SCALE
		if d.length() > rad:
			continue
		var kind := ""
		if "kind" in n:
			kind = n.kind
		var col2 := col
		var sz := 2.0
		if kind == "dungeon":
			col2 = Color(0.9, 0.3, 0.9); sz = 2.5
		elif kind == "house_door":
			col2 = Color(0.8, 0.7, 0.5)
		draw_rect(Rect2(c + d - Vector2(sz, sz) * 0.5, Vector2(sz * 2, sz * 2)), col2)
