extends Node2D
## Main — Greenvale Forest region bootstrap. Builds ground, sky, weather,
## player, monster spawner and HUD in code (Fase0 §2 world/Region).

const TILE := 16
const MAP_W := 80
const MAP_H := 60
const GRASS_PRIMARY := Vector2i(1, 7)
const GRASS_VARIANTS := [Vector2i(3, 6), Vector2i(4, 6)]

const SPAWN_TABLE := ["fluffbit", "fluffbit", "grey_wolf", "verdant_slime", "wild_boar", "forest_fox"]
const MAX_MONSTERS := 12

var ground: TileMapLayer
var canvas_mod: CanvasModulate
var rain: GPUParticles2D
var star_layer: Node2D
var player: Player
var _monster_count := 0
var _spawn_timer := 0.0
var _screenshot_at := -1.0

func _ready() -> void:
	randomize()
	_build_ground()
	_build_boundaries()
	_scatter_props()
	_build_sky()
	_build_weather()
	_spawn_player()
	_spawn_gathering_nodes()
	_add_hud()
	_prime_monsters()
	EventBus.weather_changed.connect(_on_weather_changed)
	_on_weather_changed(WorldState.weather)
	Audio.play_music("11 - Clearing.ogg")
	# Optional automated screenshot for verification (--screenshot arg or env)
	if "--shot" in OS.get_cmdline_user_args() or OS.get_environment("AETHER_SHOT") == "1":
		_screenshot_at = 1.6
	if OS.get_environment("AETHER_COMBAT") == "1":
		_combat_demo()
		_screenshot_at = 2.6
	if OS.get_environment("AETHER_ELEM") == "1":
		_elem_demo()
		_screenshot_at = 2.4

func _elem_demo() -> void:
	# Science demo: rain -> monsters Wet -> Lightning infusion chains between them.
	await get_tree().process_frame
	WorldState.force_weather("rain")
	PlayerData.apply_infusion("lightning", 60)
	player.facing = "right"
	EventBus.damage_dealt.connect(func(_a, t, amt, crit, elem):
		if t != player:
			print("[elem] MONSTER took %d elem=%s%s" % [amt, elem, (" CRIT" if crit else "")]))
	for i in range(4):
		var inst := MonsterFactory.make("grey_wolf", 2, 3)
		var m := preload("res://scenes/actors/Monster.tscn").instantiate()
		add_child(m)
		m.global_position = player.global_position + Vector2(30 + i * 14, -10 + i * 10)
		m.setup(inst, self)
		_monster_count += 1
	var t := Timer.new()
	t.wait_time = 0.4
	t.autostart = true
	add_child(t)
	t.timeout.connect(func():
		if is_instance_valid(player):
			player.facing = "right"
			player._do_attack())

func _combat_demo() -> void:
	# Spawn a cluster of monsters beside the player and auto-attack for a shot.
	await get_tree().process_frame
	EventBus.damage_dealt.connect(func(_a, t, amt, crit, elem):
		var who := "player" if t == player else "MONSTER"
		print("[dmg] -> %s  %d%s elem=%s" % [who, amt, (" CRIT" if crit else ""), elem]))
	EventBus.monster_killed.connect(func(sp, _m): print("[kill] ", sp))
	EventBus.item_gained.connect(func(id, q): print("[loot] +%d %s" % [q, id]))
	EventBus.player_leveled_up.connect(func(lv): print("[levelup] Lv ", lv))
	player.facing = "right"
	PlayerData.equipped_weapon = "copper_sword"
	PlayerData.recalculate_stats()
	PlayerData.hp = PlayerData.max_hp
	for i in range(4):
		var inst := MonsterFactory.make("verdant_slime", 1, 3)
		var m := preload("res://scenes/actors/Monster.tscn").instantiate()
		add_child(m)
		m.global_position = player.global_position + Vector2(30 + i * 4, -6 + i * 8)
		m.setup(inst, self)
		_monster_count += 1
	var t := Timer.new()
	t.wait_time = 0.35
	t.autostart = true
	add_child(t)
	t.timeout.connect(func():
		if is_instance_valid(player):
			player.facing = "right"
			player._do_attack())

func _process(delta: float) -> void:
	if canvas_mod:
		canvas_mod.color = GameClock.ambient_color()
	if star_layer:
		star_layer.modulate.a = lerpf(star_layer.modulate.a, 1.0 if GameClock.is_night() else 0.0, delta * 2.0)
	_tick_spawner(delta)
	if _screenshot_at > 0.0:
		_screenshot_at -= delta
		if _screenshot_at <= 0.0:
			_take_screenshot()

# --- World build ------------------------------------------------------------

func _make_field_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/game/tiles/field.png")
	src.texture_region_size = Vector2i(TILE, TILE)
	for coord in [GRASS_PRIMARY] + GRASS_VARIANTS:
		src.create_tile(coord)
	ts.add_source(src, 0)
	return ts

func _build_ground() -> void:
	ground = TileMapLayer.new()
	ground.tile_set = _make_field_tileset()
	add_child(ground)
	for y in range(MAP_H):
		for x in range(MAP_W):
			var coord := GRASS_PRIMARY
			var r := randf()
			if r < 0.10:
				coord = GRASS_VARIANTS[randi() % GRASS_VARIANTS.size()]
			ground.set_cell(Vector2i(x, y), 0, coord)

func _build_boundaries() -> void:
	var walls := StaticBody2D.new()
	walls.name = "Boundaries"
	add_child(walls)
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	var thickness := 16
	var rects := [
		Rect2(-thickness, -thickness, w + thickness * 2, thickness),      # top
		Rect2(-thickness, h, w + thickness * 2, thickness),               # bottom
		Rect2(-thickness, 0, thickness, h),                               # left
		Rect2(w, 0, thickness, h),                                        # right
	]
	for rc in rects:
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rc.size
		cs.shape = shape
		cs.position = rc.position + rc.size / 2
		walls.add_child(cs)

func _scatter_props() -> void:
	var props := Node2D.new()
	props.name = "Props"
	props.y_sort_enabled = true
	add_child(props)
	var grass := load("res://assets/game/sprites/props/grass.png")
	var rock := load("res://assets/game/sprites/props/rock.png")
	for i in range(120):
		var s := Sprite2D.new()
		s.texture = grass if randf() < 0.7 else rock
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.position = Vector2(randf_range(24, MAP_W * TILE - 24), randf_range(24, MAP_H * TILE - 24))
		props.add_child(s)

func _build_sky() -> void:
	canvas_mod = CanvasModulate.new()
	canvas_mod.color = GameClock.ambient_color()
	add_child(canvas_mod)
	# Parallax star field (visible at night)
	star_layer = Node2D.new()
	star_layer.name = "Stars"
	star_layer.z_index = -5
	star_layer.modulate.a = 0.0
	add_child(star_layer)
	for i in range(80):
		var dot := ColorRect.new()
		dot.color = Color(0.9, 0.95, 1.0, randf_range(0.4, 1.0))
		dot.size = Vector2(2, 2)
		dot.position = Vector2(randf_range(0, MAP_W * TILE), randf_range(0, MAP_H * TILE))
		star_layer.add_child(dot)

func _build_weather() -> void:
	rain = GPUParticles2D.new()
	rain.name = "Rain"
	rain.amount = 120
	rain.lifetime = 0.7
	rain.z_index = 20
	rain.emitting = false
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(280, 10, 1)
	mat.direction = Vector3(0.1, 1, 0)
	mat.gravity = Vector3(0, 900, 0)
	mat.initial_velocity_min = 300.0
	mat.initial_velocity_max = 420.0
	mat.scale_min = 0.5
	mat.scale_max = 1.0
	rain.process_material = mat
	var img := Image.create(2, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.6, 0.75, 1.0, 0.7))
	rain.texture = ImageTexture.create_from_image(img)
	add_child(rain)

func _on_weather_changed(w: String) -> void:
	if rain:
		rain.emitting = w in ["rain", "thunderstorm"]

func _process_rain_follow() -> void:
	if rain and player:
		rain.position = player.global_position + Vector2(0, -180)

# --- Actors -----------------------------------------------------------------

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	player.global_position = Vector2(MAP_W * TILE / 2, MAP_H * TILE / 2)
	add_child(player)

func _add_hud() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	# gathering/interaction + save handled by a small controller
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())

func _spawn_gathering_nodes() -> void:
	var holder := Node2D.new()
	holder.name = "GatherNodes"
	holder.y_sort_enabled = true
	add_child(holder)
	for i in range(10):
		_add_gather_node(holder, "tree", Vector2(randf_range(48, MAP_W * TILE - 48), randf_range(48, MAP_H * TILE - 48)))
	for i in range(8):
		_add_gather_node(holder, "ore", Vector2(randf_range(48, MAP_W * TILE - 48), randf_range(48, MAP_H * TILE - 48)))

func _add_gather_node(holder: Node2D, kind: String, pos: Vector2) -> void:
	var node := preload("res://scenes/world/GatherNode.tscn").instantiate()
	holder.add_child(node)
	node.global_position = pos
	node.setup(kind, "gn_%s_%d" % [kind, holder.get_child_count()])

# --- Spawner ----------------------------------------------------------------

func _prime_monsters() -> void:
	for i in range(8):
		_spawn_one()

func _tick_spawner(delta: float) -> void:
	_process_rain_follow()
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = 3.0
		if _monster_count < MAX_MONSTERS:
			_spawn_one()

func _spawn_one() -> void:
	var species: String = SPAWN_TABLE[randi() % SPAWN_TABLE.size()]
	var inst := MonsterFactory.make(species)
	if inst.is_empty():
		return
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	# spawn away from player
	var pos := Vector2(randf_range(64, MAP_W * TILE - 64), randf_range(64, MAP_H * TILE - 64))
	if player and pos.distance_to(player.global_position) < 120:
		pos += Vector2(140, 140)
	m.global_position = pos
	m.setup(inst, self)
	_monster_count += 1

func on_monster_died(_m) -> void:
	_monster_count = max(0, _monster_count - 1)

func _take_screenshot() -> void:
	if DisplayServer.get_name() == "headless":
		get_tree().quit()
		return
	var img := get_viewport().get_texture().get_image()
	if img == null:
		get_tree().quit()
		return
	var path := "user://shot.png"
	img.save_png(path)
	print("[shot] saved ", ProjectSettings.globalize_path(path))
	get_tree().quit()
