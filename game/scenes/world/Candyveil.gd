extends Node2D
## Candyveil Meadows (Fase 1 content, GDD v0.2 §4) — pastel cotton-candy region
## built from original Aetherion candy tiles. Level 18-32 candy monsters.

const TILE := 16
const MAP_W := 70
const MAP_H := 52
const SPAWN_TABLE := ["gummy_slime", "candyfloss_sheep", "jellybean_bunny", "choco_bear",
	"lollipop_sprite", "soda_serpent", "caramel_golem", "gummy_mimic"]
const MAX_MONSTERS := 12

var ground: TileMapLayer
var canvas_mod: CanvasModulate
var rain: GPUParticles2D
var player
var _monster_count := 0
var _spawn_timer := 0.0
var _shot_at := -1.0

func _ready() -> void:
	randomize()
	_build_ground()
	_build_boundaries()
	_scatter_props()
	_build_sky()
	_build_weather()
	_spawn_player()
	_spawn_gathering()
	_add_ui()
	_prime_monsters()
	EventBus.weather_changed.connect(_on_weather)
	Settings.changed.connect(func(): _on_weather(WorldState.weather))
	_on_weather(WorldState.weather)
	SafeZone.clear()   # no town safe zone in the wilds (UI/UX §4)
	Stage.enter_region("Padang Candyveil", "Ladang permen pastel — manis tapi menipu", "26 - Lost Village.ogg")
	EventBus.toast.emit("Candyveil Meadows — padang gula kapas. Awas Gummy Mimic!")
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.6

func _process(delta: float) -> void:
	if canvas_mod:
		canvas_mod.color = GameClock.ambient_color().lerp(Color(1.0, 0.85, 0.95), 0.15)
	if rain and player:
		rain.position = player.global_position + Vector2(0, -180)
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

func _candy_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	for i in [["candy_grass_a_16", 0], ["candy_grass_b_16", 1], ["candy_path_16", 2]]:
		var src := TileSetAtlasSource.new()
		src.texture = load("res://assets/game/tiles/candyveil/%s.png" % i[0])
		src.texture_region_size = Vector2i(TILE, TILE)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src, i[1])
	return ts

func _build_ground() -> void:
	ground = TileMapLayer.new()
	ground.tile_set = _candy_tileset()
	add_child(ground)
	for y in range(MAP_H):
		for x in range(MAP_W):
			var sid := 0
			var r := randf()
			if r < 0.14:
				sid = 1
			ground.set_cell(Vector2i(x, y), sid, Vector2i(0, 0))
	# a winding candy path down the middle
	for y in range(MAP_H):
		var cx := int(MAP_W / 2 + sin(y * 0.25) * 6)
		ground.set_cell(Vector2i(cx, y), 2, Vector2i(0, 0))
		ground.set_cell(Vector2i(cx + 1, y), 2, Vector2i(0, 0))

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

func _scatter_props() -> void:
	var props := Node2D.new()
	props.y_sort_enabled = true
	add_child(props)
	# Candy deco variety (UI/UX §7): region tiles + our new candy props.
	var deco := [
		"res://assets/game/tiles/candyveil/candy_gummy_bush_16.png",
		"res://assets/game/tiles/candyveil/candy_gummy_bush_16.png",
		"res://assets/game/tiles/candyveil/candy_mint_rock_16.png",
		"res://assets/game/sprites/props/gumdrop.png",
		"res://assets/game/sprites/props/lollipop.png",
		"res://assets/game/sprites/props/candy_cane.png",
	]
	for i in range(110):
		var s := Sprite2D.new()
		s.texture = load(deco[randi() % deco.size()])
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.position = Vector2(randf_range(24, MAP_W * TILE - 24), randf_range(24, MAP_H * TILE - 24))
		props.add_child(s)
	# animated soda pools
	for i in range(8):
		var a := AnimatedSprite2D.new()
		a.sprite_frames = SheetUtil.build_strip(load("res://assets/game/tiles/candyveil/candy_soda_f1_16.png"), 16, 1, "s", 2.0)
		a.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		a.position = Vector2(randf_range(40, MAP_W * TILE - 40), randf_range(40, MAP_H * TILE - 40))
		a.play("s")
		props.add_child(a)

func _build_sky() -> void:
	canvas_mod = CanvasModulate.new()
	add_child(canvas_mod)

func _build_weather() -> void:
	rain = GPUParticles2D.new()
	rain.amount = 90
	rain.lifetime = 0.8
	rain.z_index = 20
	rain.emitting = false
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(280, 10, 1)
	mat.gravity = Vector3(0, 700, 0)
	mat.initial_velocity_min = 220.0
	mat.initial_velocity_max = 320.0
	mat.color = Color(1.0, 0.6, 0.85)   # Sugar Rain (pink)
	rain.process_material = mat
	var img := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.7, 0.9))
	rain.texture = ImageTexture.create_from_image(img)
	add_child(rain)

func _on_weather(w: String) -> void:
	if rain:
		rain.emitting = (w in ["rain", "thunderstorm"]) and not Settings.eco_mode

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
	# portal back to Greenvale
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup("res://scenes/Main.tscn", "Kembali ke Greenvale [E]")
	portal.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 32)
	# side-view dungeon entrance
	var dungeon := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(dungeon)
	dungeon.dungeon_scene = "res://scenes/world/GummyCavern.tscn"
	dungeon.dungeon_label = "Gummy Cavern ▼ [E]"
	dungeon.setup("dungeon")
	dungeon.global_position = Vector2(MAP_W * TILE * 0.5 + 80, MAP_H * TILE - 90)

func _spawn_gathering() -> void:
	var holder := Node2D.new()
	holder.y_sort_enabled = true
	add_child(holder)
	for i in range(12):
		var node := preload("res://scenes/world/GatherNode.tscn").instantiate()
		holder.add_child(node)
		node.global_position = Vector2(randf_range(48, MAP_W * TILE - 48), randf_range(48, MAP_H * TILE - 48))
		node.setup("lollipop", "cv_lolli_%d" % i)

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
