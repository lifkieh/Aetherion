class_name WildDresser
extends RefCounted
## WildDresser (R2 Part 2) — densifies a wild region: themed decorative flora/rocks
## scattered so every screen has 12-20 dressing objects, a dense edge band that reads
## as a natural boundary, unique directional landmarks for map-less navigation, and
## dirt paths linking points of interest. Reusable by Greenvale / Candyveil / Desert.

const TILE := 16
const PDIR := "res://assets/game/sprites/props/"

# DECORATIVE pools only (no interaction). Pines & bare dead trunks are reserved for
# choppable GatherNodes so the player can read which trees drop loot — decoration uses
# natural ROUNDED broadleaf trees (and themed flora) instead.
const THEMES := {
	"forest": ["tree_oak", "tree_oak", "tree_birch", "tree_round", "bush", "bush",
		"stump", "log_fallen", "mushroom", "flower_pink", "flower_blue", "rock", "pebbles", "grass"],
	"frost": ["tree_snow_round", "tree_snow_round", "tree_round", "rock", "rock", "pebbles", "stump"],
	"candy": ["tree_candy", "tree_candy", "gumdrop", "lollipop", "candy_cane", "bush",
		"flower_pink", "flower_pink", "pebbles", "mushroom"],
	"desert": ["cactus", "cactus_ball", "dead_bush", "dead_bush", "desert_rock", "desert_rock",
		"rock", "pebbles"],
	"storm": ["rock", "rock", "desert_rock", "bush", "pebbles", "stump", "dead_bush"],
}
# Edge-band sprite (natural wall) per theme.
const EDGE := {
	"forest": ["tree_oak", "tree_giant", "tree_round"],
	"frost": ["tree_snow_round", "rock"],
	"candy": ["tree_candy", "gumdrop"],
	"desert": ["desert_rock", "cactus"],
	"storm": ["rock", "desert_rock"],
}
# Directional landmarks [sprite, scale] — N, E, S, W.
const LANDMARKS := {
	"forest": [["tree_giant", 1.4], ["statue", 1.4], ["stone_gate", 1.3], ["ruins", 1.3]],
	"frost": [["tree_snow_round", 1.9], ["statue", 1.4], ["stone_gate", 1.4], ["ruins", 1.3]],
	"candy": [["tree_candy", 2.4], ["lollipop", 2.6], ["gumdrop", 2.6], ["ruins", 1.2]],
	"desert": [["ruins", 1.4], ["statue", 1.4], ["stone_gate", 1.4], ["cactus", 2.2]],
	"storm": [["ruins", 1.6], ["stone_gate", 1.5], ["statue", 1.4], ["ruins", 1.3]],
}

## Dress a whole region. `avoid` = Array of Rect2 (world) to keep clear (town/spawn).
static func dress(host: Node2D, theme: String, map_w: int, map_h: int, avoid: Array = [], paths: Array = []) -> void:
	var holder := Node2D.new()
	holder.name = "WildDressing"
	holder.y_sort_enabled = false
	host.add_child(holder)
	var W := map_w * TILE
	var H := map_h * TILE
	var pool: Array = THEMES.get(theme, THEMES["forest"])

	_paint_paths(host, paths)                       # dirt paths under everything
	_scatter(holder, pool, W, H, avoid)             # dense interior scatter
	_edge_band(holder, theme, W, H)                 # natural boundary
	_landmarks(holder, theme, W, H)                 # navigation anchors

static func _place(holder: Node2D, name: String, pos: Vector2, scale := 1.0) -> void:
	var s := Sprite2D.new()
	s.texture = load(PDIR + name + ".png")
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = pos
	if scale != 1.0:
		s.scale = Vector2(scale, scale)
	s.z_index = int(pos.y)
	holder.add_child(s)

static func _blocked(pos: Vector2, avoid: Array) -> bool:
	for r in avoid:
		if (r as Rect2).has_point(pos):
			return true
	return false

static func _scatter(holder: Node2D, pool: Array, W: int, H: int, avoid: Array) -> void:
	# jittered grid so the whole map is populated but not gridlike
	var step := 46
	for gy in range(1, int(H / step)):
		for gx in range(1, int(W / step)):
			if randf() > 0.62:                      # ~62% fill density
				continue
			var pos := Vector2(gx * step + randf_range(-16, 16), gy * step + randf_range(-16, 16))
			pos.x = clampf(pos.x, 24, W - 24); pos.y = clampf(pos.y, 24, H - 24)
			if _blocked(pos, avoid):
				continue
			_place(holder, pool[randi() % pool.size()], pos)

static func _edge_band(holder: Node2D, theme: String, W: int, H: int) -> void:
	var edge: Array = EDGE.get(theme, EDGE["forest"])
	var margin := 30
	# top & bottom rows
	for x in range(margin, W - margin, 30):
		if randf() < 0.85:
			_place(holder, edge[randi() % edge.size()], Vector2(x + randf_range(-6, 6), randf_range(6, 26)))
		if randf() < 0.85:
			_place(holder, edge[randi() % edge.size()], Vector2(x + randf_range(-6, 6), H - randf_range(6, 26)))
	# left & right columns
	for y in range(margin, H - margin, 30):
		if randf() < 0.85:
			_place(holder, edge[randi() % edge.size()], Vector2(randf_range(6, 26), y + randf_range(-6, 6)))
		if randf() < 0.85:
			_place(holder, edge[randi() % edge.size()], Vector2(W - randf_range(6, 26), y + randf_range(-6, 6)))

static func _landmarks(holder: Node2D, theme: String, W: int, H: int) -> void:
	var lm: Array = LANDMARKS.get(theme, LANDMARKS["forest"])
	var cx := W * 0.5; var cy := H * 0.5
	var spots := [Vector2(cx, cy - H * 0.34), Vector2(cx + W * 0.36, cy), Vector2(cx, cy + H * 0.34), Vector2(cx - W * 0.36, cy)]
	for i in range(min(4, lm.size())):
		_place(holder, lm[i][0], spots[i], lm[i][1])

static func _paint_paths(host: Node2D, paths: Array) -> void:
	if paths.is_empty():
		return
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/game/tiles/dirt_path.png")
	src.texture_region_size = Vector2i(TILE, TILE)
	src.create_tile(Vector2i(0, 0))
	ts.add_source(src)
	var layer := TileMapLayer.new()
	layer.name = "PathLayer"
	layer.tile_set = ts
	layer.z_index = 1
	host.add_child(layer)
	for pr in paths:
		_line(layer, pr[0], pr[1])

static func _line(layer: TileMapLayer, a: Vector2, b: Vector2) -> void:
	# an L-shaped 2-wide dirt path from a to b
	var at := Vector2i(int(a.x / TILE), int(a.y / TILE))
	var bt := Vector2i(int(b.x / TILE), int(b.y / TILE))
	var x := at.x
	while x != bt.x:
		for dy in [0, 1]:
			layer.set_cell(Vector2i(x, at.y + dy), 0, Vector2i(0, 0))
		x += 1 if bt.x > x else -1
	var y := at.y
	while y != bt.y:
		for dx in [0, 1]:
			layer.set_cell(Vector2i(bt.x + dx, y), 0, Vector2i(0, 0))
		y += 1 if bt.y > y else -1
