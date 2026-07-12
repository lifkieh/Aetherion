extends Node2D
## Storm Island (v0.3, Monster_Roster §2.5) — a wind-lashed isle of perpetual storm.
## Level 40-55. Lightning monsters; driving rain + lightning flashes; the Thunder
## Dragon spawns SECRETLY at night during a thunderstorm. Zephyr Spire is its dungeon.

const TILE := 16
const MAP_W := 72
const MAP_H := 54
const SPAWN_TABLE := ["volt_weasel", "storm_crab", "thunder_hawk", "cloud_ray", "volt_eel", "storm_elemental"]
const MAX_MONSTERS := 12

var canvas_mod: CanvasModulate
var flash: ColorRect
var player
var _monster_count := 0
var _spawn_timer := 0.0
var _shot_at := -1.0
var _flash_cd := 4.0
var _dragon_spawned := false
var _dragon_check := 6.0

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
	Stage.enter_region("Storm Island", "Pulau badai abadi — petir & angin tak henti", "23 - Road.ogg")
	EventBus.toast.emit("Storm Island — awas petir! Konon Thunder Dragon muncul saat badai malam.")
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.6
	if OS.get_environment("AETHER_FPS") == "1":
		get_tree().create_timer(4.0).timeout.connect(func():
			print("[fps] StormIsland fps=%.1f nodes=%d" % [Engine.get_frames_per_second(), get_tree().get_node_count()])
			get_tree().quit())

func _dress_wild() -> void:
	var spawn := Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 60)
	var avoid := [Rect2(spawn - Vector2(140, 140), Vector2(280, 220))]
	WildDresser.dress(self, "storm", MAP_W, MAP_H, avoid, [])
	var amb := Node2D.new()
	amb.set_script(load("res://scenes/systems/Ambience.gd"))
	add_child(amb)
	amb.setup("storm")

func _process(delta: float) -> void:
	if canvas_mod:
		canvas_mod.color = GameClock.ambient_color().lerp(Color(0.55, 0.6, 0.78), 0.4)   # stormy gloom
	# lightning flashes
	_flash_cd -= delta
	if _flash_cd <= 0.0 and flash and not Settings.eco_mode:
		_flash_cd = randf_range(3.0, 7.0)
		flash.color = Color(1, 1, 1, 0.55)
		Audio.play_sfx("secret", 0.7)
		var tw := create_tween()
		tw.tween_property(flash, "color:a", 0.0, 0.5)
	# secret Thunder Dragon: night + thunderstorm
	_dragon_check -= delta
	if _dragon_check <= 0.0 and not _dragon_spawned:
		_dragon_check = 6.0
		if GameClock.is_night() and WorldState.weather == "thunderstorm":
			_spawn_dragon()
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

func _spawn_dragon() -> void:
	var inst := MonsterFactory.make("thunder_dragon", 55, 5)
	if inst.is_empty():
		return
	_dragon_spawned = true
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	m.global_position = Vector2(MAP_W * TILE * 0.5, 120)
	m.setup(inst, self)
	_monster_count += 1
	CombatFeel.shake(6.0, 0.4)
	EventBus.toast.emit("⚡★ Petir menyambar... THUNDER DRAGON muncul dari badai!")

func _tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	for i in [["storm_grass", 0], ["storm_rock", 1], ["storm_sand", 2]]:
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
			var edge: bool = x < 4 or y < 4 or x > MAP_W - 5 or y > MAP_H - 5
			var r := randf()
			if edge and r < 0.5:
				sid = 2       # sandy shore at the edges
			elif r < 0.2:
				sid = 1       # wet rock
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
	flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0)
	flash.z_index = 40
	flash.size = Vector2(MAP_W * TILE, MAP_H * TILE)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

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
	var spire := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(spire)
	spire.dungeon_scene = "res://scenes/world/ZephyrSpire.tscn"
	spire.dungeon_label = "Zephyr Spire ▲ [E]"
	spire.setup("dungeon")
	spire.global_position = Vector2(MAP_W * TILE * 0.5 + 120, MAP_H * TILE - 140)
	_keeper(Vector2(MAP_W * TILE * 0.5 - 100, MAP_H * TILE - 140), "storm_island")   # penjaga menara (#30)

func _spawn_gathering() -> void:
	var holder := Node2D.new()
	holder.y_sort_enabled = true
	add_child(holder)
	for i in range(10):
		var node := preload("res://scenes/world/GatherNode.tscn").instantiate()
		holder.add_child(node)
		node.global_position = Vector2(randf_range(48, MAP_W * TILE - 48), randf_range(48, MAP_H * TILE - 48))
		node.setup("sandstone", "si_rock_%d" % i)

func _prime_monsters() -> void:
	for i in range(8):
		_spawn_one()

func _spawn_one() -> void:
	var species: String = SPAWN_TABLE[randi() % SPAWN_TABLE.size()]
	if not MonsterFactory.spawnable_now(species):
		return   # nokturnal hanya malam (v0.4.1)
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

func _keeper(pos: Vector2, loc: String) -> void:
	var n := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(n); n.setup("tree_keeper"); n.keeper_location = loc; n.global_position = pos
