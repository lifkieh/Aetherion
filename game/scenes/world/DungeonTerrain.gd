extends Node2D
## DungeonTerrain — side-view mineable tile terrain (owner decision 2026-07-11).
## Built from an ASCII layout so level design stays controlled. Soft blocks
## (dirt/stone/ore) are diggable; hard bedrock is not. Ore veins give material
## + Miner EXP. Also builds one-way platforms and ladder zones.

const TILE := 16
# char -> block config. source = TileSet source id; hard = undiggable.
const BLOCKS := {
	"D": {"source": 0, "soft": true, "hp": 2, "drop": "", "xp": 1},   # dirt
	"#": {"source": 1, "soft": true, "hp": 3, "drop": "", "xp": 1},   # stone
	"B": {"source": 2, "soft": false},                                 # bedrock (hard)
	"O": {"source": 3, "soft": true, "hp": 4, "drop": "copper_ore", "xp": 4},  # copper vein
}

var solid: TileMapLayer             # visual tiles only
var _body: StaticBody2D             # collision — merged horizontal STRIPS per row
var _hp: Dictionary = {}            # Vector2i -> remaining hits
var _row_shapes: Dictionary = {}    # row y -> Array[CollisionShape2D]
var _ladder_cells: Dictionary = {} # Vector2i -> true
var width := 0
var height := 0

func _ready() -> void:
	add_to_group("terrain")

func build_from(layout: Array, tile_tint: Color = Color.WHITE) -> void:
	height = layout.size()
	width = 0
	for row in layout:
		width = maxi(width, String(row).length())
	solid = TileMapLayer.new()
	solid.tile_set = _make_tileset()
	solid.modulate = tile_tint
	add_child(solid)
	_body = StaticBody2D.new()
	_body.collision_layer = 4        # value 4 = solid dungeon terrain
	_body.collision_mask = 0
	add_child(_body)
	var platforms := _new_platform_body()
	add_child(platforms)
	var ladder_holder := Node2D.new()
	add_child(ladder_holder)

	for y in range(height):
		var row := String(layout[y])
		for x in range(row.length()):
			var c := row[x]
			var cell := Vector2i(x, y)
			if BLOCKS.has(c):
				solid.set_cell(cell, BLOCKS[c].source, Vector2i(0, 0))
				# _hp is initialized lazily on first mine (so the Miner "faster" perk applies)
			elif c == "=":
				_add_platform(platforms, cell)
			elif c == "H":
				_add_ladder(ladder_holder, cell)
	# merged strip collision (perf: ~rows*few shapes instead of one per cell)
	for y in range(height):
		_rebuild_row(y)

## Rebuild one row's collision as merged horizontal strips of solid cells.
func _rebuild_row(y: int) -> void:
	if _row_shapes.has(y):
		for cs in _row_shapes[y]:
			if is_instance_valid(cs):
				cs.queue_free()
	_row_shapes[y] = []
	var x := 0
	while x < width:
		if solid.get_cell_source_id(Vector2i(x, y)) != -1:
			var start := x
			while x < width and solid.get_cell_source_id(Vector2i(x, y)) != -1:
				x += 1
			var run := x - start
			var cs := CollisionShape2D.new()
			var shape := RectangleShape2D.new()
			shape.size = Vector2(run * TILE, TILE)
			cs.shape = shape
			cs.position = Vector2(start * TILE + run * TILE / 2.0, y * TILE + TILE / 2.0)
			_body.add_child(cs)
			_row_shapes[y].append(cs)
		else:
			x += 1

func collision_node_count() -> int:
	var n := 0
	for y in _row_shapes.keys():
		n += _row_shapes[y].size()
	return n

func _make_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	var files := ["dirt", "stone", "bedrock", "ore_copper"]
	for i in range(files.size()):
		var src := TileSetAtlasSource.new()
		src.texture = load("res://assets/game/tiles/dungeon/%s.png" % files[i])
		src.texture_region_size = Vector2i(TILE, TILE)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src, i)
	return ts

func _new_platform_body() -> StaticBody2D:
	var b := StaticBody2D.new()
	b.name = "Platforms"
	b.collision_layer = 8   # value 8 = one-way platforms
	b.collision_mask = 0
	return b

func _add_platform(body: StaticBody2D, cell: Vector2i) -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(TILE, 4)
	cs.shape = shape
	cs.one_way_collision = true
	cs.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + 2.0)
	body.add_child(cs)
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/game/tiles/dungeon/platform.png")
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)
	body.add_child(spr)

func _add_ladder(holder: Node2D, cell: Vector2i) -> void:
	_ladder_cells[cell] = true
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/game/tiles/dungeon/ladder.png")
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)
	holder.add_child(spr)

# --- Queries used by the platformer player ---------------------------------

func _cell_at(global_pos: Vector2) -> Vector2i:
	return solid.local_to_map(solid.to_local(global_pos))

func is_ladder(global_pos: Vector2) -> bool:
	return _ladder_cells.has(_cell_at(global_pos))

## Mine the block at `global_pos`. Returns true if it was a mineable block.
func try_mine(global_pos: Vector2) -> bool:
	var cell := _cell_at(global_pos)
	var src := solid.get_cell_source_id(cell)
	if src == -1:
		return false
	# find the block config for this source id
	var cfg := {}
	for c in BLOCKS.keys():
		if BLOCKS[c].source == src:
			cfg = BLOCKS[c]
			break
	if cfg.is_empty():
		return false
	if not cfg.get("soft", false):
		EventBus.toast.emit("Batu ini terlalu keras untuk digali.")
		return false
	# Miner "faster" perk reduces the hits needed.
	if not _hp.has(cell):
		_hp[cell] = maxi(1, cfg.hp - int(ProfessionSystem.perk_value("miner", "faster")))
	_hp[cell] -= 1
	Audio.play_sfx("mine")
	if _hp[cell] <= 0:
		solid.erase_cell(cell)
		_hp.erase(cell)
		_rebuild_row(cell.y)   # split the strip around the removed cell
		var drop: String = cfg.get("drop", "")
		if drop != "":
			var qty := randi_range(1, 2) + int(ProfessionSystem.perk_value("miner", "bonus_yield"))
			PlayerData.add_item(drop, qty)
			EventBus.node_harvested.emit("ore", drop, qty)   # -> Miner XP via ProfessionSystem
		WorldState.add_counter("blocks_mined")
		EventBus.block_mined.emit(cell, "ore" if drop != "" else "block")
	return true
