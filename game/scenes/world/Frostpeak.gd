extends Node2D
## Frostpeak Mountain (v0.3, Monster_Roster §2.4) — a snowbound region built from
## procedural snow/ice tiles. Level 22-38. Ice/Wind monsters; falling snow ambience;
## pine + snow-pine forest (WildDresser "frost"). Reached from Greenvale's north gate.

const TILE := 16
const MAP_W := 70
const MAP_H := 52
const SPAWN_TABLE := ["frost_fox", "ice_wolf", "snow_owl", "yeti_cub", "ice_wolf", "frost_fox"]
const MAX_MONSTERS := 12

var canvas_mod: CanvasModulate
var player
var _monster_count := 0
var _spawn_timer := 0.0
var _shot_at := -1.0

func _ready() -> void:
	randomize()
	_build_ground()
	_build_boundaries()
	_dress_wild()
	_build_sky()
	_spawn_player()
	_spawn_gathering()
	_add_ui()
	_prime_monsters()
	SafeZone.clear()
	Stage.enter_region("Frostpeak", "Puncak beku — salju abadi & angin menggigit", "26 - Lost Village.ogg")
	EventBus.toast.emit("Frostpeak Mountain — awas Yeti! Es abadi tak pernah mencair.")
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.6
	if OS.get_environment("AETHER_FPS") == "1":
		get_tree().create_timer(4.0).timeout.connect(func():
			print("[fps] Frostpeak fps=%.1f nodes=%d" % [Engine.get_frames_per_second(), get_tree().get_node_count()])
			get_tree().quit())

func _dress_wild() -> void:
	var spawn := Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 60)
	var avoid := [Rect2(spawn - Vector2(130, 140), Vector2(260, 220))]
	WildDresser.dress(self, "frost", MAP_W, MAP_H, avoid, [])
	var amb := Node2D.new()
	amb.set_script(load("res://scenes/systems/Ambience.gd"))
	add_child(amb)
	amb.setup("snow")

func _process(delta: float) -> void:
	if canvas_mod:
		canvas_mod.color = GameClock.ambient_color().lerp(Color(0.82, 0.9, 1.05), 0.28)  # cold blue-white
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = 3.0
		if _monster_count < MAX_MONSTERS:
			_spawn_one()
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit()

func _tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	for i in [["snow_0", 0], ["snow_1", 1], ["ice_patch", 2]]:
		var src := TileSetAtlasSource.new()
		src.texture = load("res://assets/game/tiles/%s.png" % i[0])
		src.texture_region_size = Vector2i(TILE, TILE)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src, i[1])
	return ts

func _build_ground() -> void:
	var ground := TileMapLayer.new()
	ground.tile_set = _tileset()
	add_child(ground)
	for y in range(MAP_H):
		for x in range(MAP_W):
			var sid := 0
			var r := randf()
			if r < 0.22:
				sid = 1
			elif r < 0.27:
				sid = 2       # icy patch
			ground.set_cell(Vector2i(x, y), sid, Vector2i(0, 0))

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
	add_child(canvas_mod)

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	if WorldState.pending_return_pos != null:
		player.global_position = WorldState.pending_return_pos
		WorldState.pending_return_pos = null
	else:
		player.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 60)
	add_child(player)

func _add_ui() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())
	var pm := Node.new()
	pm.set_script(load("res://scenes/systems/PetManager.gd"))
	add_child(pm)
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup("res://scenes/Main.tscn", "Kembali ke Greenvale [E]")
	portal.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 32)

func _spawn_gathering() -> void:
	var holder := Node2D.new()
	holder.y_sort_enabled = true
	add_child(holder)
	for i in range(12):
		var node := preload("res://scenes/world/GatherNode.tscn").instantiate()
		holder.add_child(node)
		node.global_position = Vector2(randf_range(48, MAP_W * TILE - 48), randf_range(48, MAP_H * TILE - 48))
		node.setup("tree", "fp_tree_%d" % i)

func _prime_monsters() -> void:
	for i in range(8):
		_spawn_one()

func _spawn_one() -> void:
	var species: String = SPAWN_TABLE[randi() % SPAWN_TABLE.size()]
	var inst := MonsterFactory.make(species)
	if inst.is_empty():
		return
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	var pos := Vector2(randf_range(64, MAP_W * TILE - 64), randf_range(64, MAP_H * TILE - 64))
	if player and pos.distance_to(player.global_position) < 120:
		pos += Vector2(140, 140)
	m.global_position = pos
	m.setup(inst, self)
	_monster_count += 1

func on_monster_died(_m) -> void:
	_monster_count = max(0, _monster_count - 1)
