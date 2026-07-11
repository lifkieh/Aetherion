extends Node2D
## Homestead (M6) — private instance: 4 plots, real-time crop growth, portal back.

const TILE := 16
const MAP_W := 28
const MAP_H := 20
const GRASS := Vector2i(1, 7)

var canvas_mod: CanvasModulate
var player: Player

func _ready() -> void:
	_ensure_plots()
	_build_ground()
	_build_boundaries()
	_build_sky()
	_build_plots()
	_build_portal()
	_spawn_player()
	_add_ui()
	Audio.play_music("26 - Lost Village.ogg")
	EventBus.toast.emit("Homestead — tanaman tumbuh dengan waktu nyata (termasuk offline).")
	if OS.get_environment("AETHER_HOME") == "1":
		_demo()

var _shot_at := -1.0

func _demo() -> void:
	# Plant plots at different real-time offsets to show growth stages + a ready crop.
	PlayerData.homestead_plots = [
		{"crop_id": "mintleaf", "planted_at_unix": GameClock.unix_now() - 700},   # ready (grow 600)
		{"crop_id": "mintleaf", "planted_at_unix": GameClock.unix_now() - 300},   # ~half
		{"crop_id": "sunbud", "planted_at_unix": GameClock.unix_now() - 200},     # early
		{},                                                                        # empty
	]
	PlayerData.add_item("seed_sunbud", 3)
	_shot_at = 1.4

func _process(delta: float) -> void:
	if canvas_mod:
		canvas_mod.color = GameClock.ambient_color()
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img:
					img.save_png("user://shot.png")
			get_tree().quit()

func _ensure_plots() -> void:
	while PlayerData.homestead_plots.size() < 4:
		PlayerData.homestead_plots.append({})

func _build_ground() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/game/tiles/field.png")
	src.texture_region_size = Vector2i(TILE, TILE)
	src.create_tile(GRASS)
	ts.add_source(src, 0)
	var layer := TileMapLayer.new()
	layer.tile_set = ts
	add_child(layer)
	for y in range(MAP_H):
		for x in range(MAP_W):
			layer.set_cell(Vector2i(x, y), 0, GRASS)

func _build_boundaries() -> void:
	var walls := StaticBody2D.new()
	walls.collision_layer = 4
	walls.collision_mask = 0
	add_child(walls)
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	for rc in [Rect2(-16, -16, w + 32, 16), Rect2(-16, h, w + 32, 16), Rect2(-16, 0, 16, h), Rect2(w, 0, 16, h)]:
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rc.size
		cs.shape = shape
		cs.position = rc.position + rc.size / 2
		walls.add_child(cs)

func _build_sky() -> void:
	canvas_mod = CanvasModulate.new()
	canvas_mod.color = GameClock.ambient_color()
	add_child(canvas_mod)

func _build_plots() -> void:
	var holder := Node2D.new()
	holder.y_sort_enabled = true
	add_child(holder)
	var start := Vector2(MAP_W * TILE * 0.5 - 60, MAP_H * TILE * 0.5)
	for i in range(4):
		var plot := preload("res://scenes/homestead/PlotNode.tscn").instantiate()
		holder.add_child(plot)
		plot.global_position = start + Vector2(i * 40, 0)
		plot.setup(i)

func _build_portal() -> void:
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup("res://scenes/Main.tscn", "Kembali ke Greenvale [E]")
	portal.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 40)

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	player.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 64)
	add_child(player)

func _add_ui() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())
