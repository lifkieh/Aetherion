extends Node2D
## Desert of Ruins (GDD v0.2 §4, Monster_Roster §2.3) — arid ruins region built
## from procedurally generated sand tiles. Level 12-25. Rock Golem is near-immune
## to Lightning (grounding science). No rain here (dry).

const TILE := 32   # R2b #287: gurun ikut petak 32
const MAP_W := 68
const MAP_H := 50
const SPAWN_TABLE := ["sand_scarab", "dune_viper", "vulture", "jackal_shade",
	"rock_golem", "cactus_fiend", "dune_serpent"]
const MAX_MONSTERS := 12

var canvas_mod: CanvasModulate
var player
var _monster_count := 0
var _spawn_timer := 0.0
var _shot_at := -1.0

func _ready() -> void:
	WorldState.mark_visited("desert")   # Gerbang Penjelajah (#43)
	randomize()
	_build_ground()
	_build_boundaries()
	_scatter_props()
	_dress_wild()
	_build_sky()
	_spawn_player()
	_spawn_gathering()
	_add_ui()
	_prime_monsters()
	SafeZone.clear()   # no town safe zone in the wilds (UI/UX §4)
	Stage.enter_region("Gurun Reruntuhan", "Pasir tandus & sisa peradaban kuno", "desert.ogg")
	EventBus.toast.emit("Desert of Ruins — reruntuhan kuno. Rock Golem kebal petir (grounding).")
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.6
	if OS.get_environment("AETHER_FPS") == "1":
		get_tree().create_timer(4.0).timeout.connect(func():
			print("[fps] Desert fps=%.1f nodes=%d" % [Engine.get_frames_per_second(), get_tree().get_node_count()])
			get_tree().quit())

func _dress_wild() -> void:
	# R2 Part 2 — desert density: cacti, dead brush, sandstone, ruins/statue landmarks.
	var spawn := Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 120)
	var avoid := [Rect2(spawn - Vector2(260, 280), Vector2(520, 440))]   # 2x
	WildDresser.dress(self, "desert", MAP_W, MAP_H, avoid, [], TILE)
	var amb := Node2D.new()
	amb.set_script(load("res://scenes/systems/Ambience.gd"))
	add_child(amb)
	amb.setup("desert")

func _process(delta: float) -> void:
	if canvas_mod:
		canvas_mod.color = GameClock.ambient_color().lerp(Color(1.0, 0.9, 0.7), 0.2)
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
	for i in [["sand_a", 0], ["sand_b", 1], ["stone", 2]]:
		var src := TileSetAtlasSource.new()
		src.texture = load("res://assets/game/tiles/desert/%s.png" % i[0])
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
			if r < 0.18:
				sid = 1
			elif r < 0.22:
				sid = 2
			ground.set_cell(Vector2i(x, y), sid, Vector2i(0, 0))

func _build_boundaries() -> void:
	var walls := StaticBody2D.new()
	walls.collision_layer = 4
	walls.collision_mask = 0
	add_child(walls)
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	for rc in [Rect2(-32, -32, w + 64, 32), Rect2(-32, h, w + 64, 32), Rect2(-32, 0, 32, h), Rect2(w, 0, 32, h)]:
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rc.size
		cs.shape = shape
		cs.position = rc.position + rc.size / 2
		walls.add_child(cs)

func _scatter_props() -> void:
	var props := Node2D.new()
	props.y_sort_enabled = true
	add_child(props)
	var cactus := load("res://assets/game/tiles/desert/cactus.png")
	var rock := load("res://assets/game/tiles/desert/rock.png")
	var obelisk := load("res://assets/game/tiles/desert/obelisk.png")
	for i in range(70):
		var s := Sprite2D.new()
		var r := randf()
		s.texture = cactus if r < 0.4 else (obelisk if r < 0.5 else rock)
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(2, 2)   # prop 16px, dunia 32 (#287)
		s.position = Vector2(randf_range(48, MAP_W * TILE - 48), randf_range(48, MAP_H * TILE - 48))
		props.add_child(s)

func _build_sky() -> void:
	canvas_mod = CanvasModulate.new()
	add_child(canvas_mod)

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	if WorldState.pending_return_pos != null:
		player.global_position = WorldState.pending_return_pos
		WorldState.pending_return_pos = null
	else:
		player.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 120)
	add_child(player)
	for c in player.get_children():   # kamera dunia 32 (#287)
		if c is Camera2D:
			c.zoom = Vector2(1.0, 1.0)

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
	portal.scale = Vector2(2, 2)
	portal.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 64)
	var barrow := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(barrow)
	barrow.dungeon_scene = "res://scenes/world/Barrow.tscn"
	barrow.dungeon_label = "Desert Barrow ▼ [E]"
	barrow.setup("dungeon")
	barrow.scale = Vector2(2, 2)
	barrow.global_position = Vector2(MAP_W * TILE * 0.5 + 180, MAP_H * TILE - 180)
	_keeper(Vector2(MAP_W * TILE * 0.5 - 180, MAP_H * TILE - 180), "desert_ruins")   # altar reruntuhan (#30)
	TownFolk.place(self, "desert_ruins", Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 240), 90)      # Hukum NPC Aneh (E6 #78)
	MiracleSystem.manifest(self, Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 240), 480.0)   # keajaiban hari ini (E7 #79)
	_world_gate(Vector2(MAP_W * TILE * 0.5 - 320, MAP_H * TILE - 120))   # Gerbang Penjelajah (#43)

func _spawn_gathering() -> void:
	var holder := Node2D.new()
	holder.y_sort_enabled = true
	add_child(holder)
	for i in range(12):
		var node := preload("res://scenes/world/GatherNode.tscn").instantiate()
		holder.add_child(node)
		node.global_position = Vector2(randf_range(96, MAP_W * TILE - 96), randf_range(96, MAP_H * TILE - 96))
		node.scale = Vector2(2, 2)
		node.setup("sandstone", "ds_stone_%d" % i)

func _prime_monsters() -> void:
	for i in range(8):
		_spawn_one()

func _spawn_one() -> void:
	var species: String = Seasons.pick_species(SPAWN_TABLE)   # bias elemen favorit musim (A4 #83)
	if not MonsterFactory.spawnable_now(species):
		return   # nokturnal hanya malam (v0.4.1)
	var inst := MonsterFactory.make(species)
	if inst.is_empty():
		return
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	var pos := Vector2(randf_range(128, MAP_W * TILE - 128), randf_range(128, MAP_H * TILE - 128))
	if player and pos.distance_to(player.global_position) < 240:
		pos += Vector2(280, 280)
	m.global_position = pos
	m.setup(inst, self)
	_monster_count += 1

func on_monster_died(_m) -> void:
	_monster_count = max(0, _monster_count - 1)

func _keeper(pos: Vector2, loc: String) -> void:
	var n := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(n); n.setup("tree_keeper"); n.keeper_location = loc; n.scale = Vector2(2, 2); n.global_position = pos

func _world_gate(pos: Vector2) -> void:
	var n := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(n); n.setup("world_gate"); n.scale = Vector2(2, 2); n.global_position = pos
