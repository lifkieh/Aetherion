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
var _body: StaticBody2D             # collision (per-cell shapes so mining is exact)
var _hp: Dictionary = {}            # Vector2i -> remaining hits
var _shapes: Dictionary = {}        # Vector2i -> CollisionShape2D
var _ladder_cells: Dictionary = {} # Vector2i -> true
var width := 0
var height := 0

func _ready() -> void:
	add_to_group("terrain")

func build_from(layout: Array) -> void:
	height = layout.size()
	width = 0
	for row in layout:
		width = maxi(width, String(row).length())
	solid = TileMapLayer.new()
	solid.tile_set = _make_tileset()
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
				_add_collision(cell)
				if BLOCKS[c].soft:
					_hp[cell] = BLOCKS[c].hp
			elif c == "=":
				_add_platform(platforms, cell)
			elif c == "H":
				_add_ladder(ladder_holder, cell)

func _add_collision(cell: Vector2i) -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(TILE, TILE)
	cs.shape = shape
	cs.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)
	_body.add_child(cs)
	_shapes[cell] = cs

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
	_hp[cell] = _hp.get(cell, cfg.hp) - 1
	Audio.play_sfx("mine")
	if _hp[cell] <= 0:
		solid.erase_cell(cell)
		_hp.erase(cell)
		if _shapes.has(cell):
			_shapes[cell].queue_free()
			_shapes.erase(cell)
		var drop: String = cfg.get("drop", "")
		if drop != "":
			var qty := randi_range(1, 2)
			PlayerData.add_item(drop, qty)
			EventBus.node_harvested.emit("ore", drop, qty)
		PlayerData.gain_prof_xp("miner", cfg.get("xp", 1))
		WorldState.add_counter("blocks_mined")
		EventBus.block_mined.emit(cell, "ore" if drop != "" else "block")
	return true
