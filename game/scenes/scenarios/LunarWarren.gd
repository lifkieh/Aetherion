extends Node2D
## Lunar Warren (M7) — the Moon Rabbit's hidden scenario.
## Survive 60s chased by the Moon Rabbit Berserker WITHOUT killing a single
## rabbit (sin must be atoned). Kill a rabbit or die = fail permanent.

const TILE := 16
const MAP_W := 40
const MAP_H := 30
const SURVIVE_TIME := 60.0

var time_left := SURVIVE_TIME
var resolved := false
var player: Player
var label: Label
var _shot_at := -1.0

func _ready() -> void:
	SafeZone.clear()
	_build_ground()
	_build_boundaries()
	_build_sky()
	_spawn_player()
	_spawn_rabbits()
	_spawn_berserker()
	_build_hud()
	EventBus.monster_killed.connect(_on_monster_killed)
	EventBus.player_died.connect(_on_player_died)
	Audio.play_music("dungeon.ogg")
	EventBus.toast.emit("LUNAR WARREN — Bertahan 60 dtk. JANGAN bunuh kelinci!")
	if OS.get_environment("AETHER_WARREN_SHOT") == "1":
		_shot_at = 1.4

func _process(delta: float) -> void:
	if not resolved:
		time_left -= delta
		if label:
			label.text = "Bertahan: %0.1f dtk  ·  JANGAN bunuh kelinci!" % max(0.0, time_left)
		if time_left <= 0.0:
			_finish(true)
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit()

func _build_ground() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/game/tiles/field.png")
	src.texture_region_size = Vector2i(TILE, TILE)
	src.create_tile(Vector2i(1, 7))
	ts.add_source(src, 0)
	var layer := TileMapLayer.new()
	layer.tile_set = ts
	layer.modulate = Color(0.6, 0.65, 0.9)   # moonlit tint
	add_child(layer)
	for y in range(MAP_H):
		for x in range(MAP_W):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(1, 7))

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
	var cm := CanvasModulate.new()
	cm.color = Color(0.45, 0.5, 0.8)   # eerie moonlight
	add_child(cm)

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	player.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE * 0.5)
	add_child(player)

func _spawn_rabbits() -> void:
	for i in range(8):
		var inst := MonsterFactory.make("fluffbit", 1, 3)
		var m := preload("res://scenes/actors/Monster.tscn").instantiate()
		add_child(m)
		m.global_position = Vector2(randf_range(48, MAP_W * TILE - 48), randf_range(48, MAP_H * TILE - 48))
		m.setup(inst, self)

func _spawn_berserker() -> void:
	var inst := MonsterFactory.make("fluffbit", 8, 5)
	inst["name"] = "Moon Rabbit Berserker"
	inst["ai"] = "melee"
	inst["aggro_radius"] = 2000.0
	inst["spd"] = 150
	inst["atk"] = 42
	inst["max_hp"] = 999999
	inst["hp"] = 999999
	inst["tint"] = "b060ff"
	inst["is_rabbit"] = true
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	m.global_position = Vector2(60, 60)
	m.setup(inst, self)
	m.scale = Vector2(1.6, 1.6)

func _build_hud() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 15
	add_child(cl)
	label = Label.new()
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_constant_override("outline_size", 5)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		label.add_theme_font_override("font", load("res://assets/game/fonts/m5x7.ttf"))
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.position = Vector2(-200, 20)
	label.custom_minimum_size = Vector2(400, 0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cl.add_child(label)

func on_monster_died(_m) -> void:
	pass

func _on_monster_killed(species_id: String, _m) -> void:
	# Killing ANY rabbit (incl. the berserker) is the sin -> instant fail.
	if resolved:
		return
	var def := Db.monster(species_id)
	if def.get("is_rabbit", false) or species_id == "fluffbit":
		EventBus.toast.emit("Kamu menumpahkan darah kelinci lagi...")
		_finish(false)

func _on_player_died() -> void:
	if not resolved:
		_finish(false)

func _finish(success: bool) -> void:
	if resolved:
		return
	resolved = true
	if _shot_at > 0.0:
		return   # keep the scene up for the screenshot in demo mode
	ScenarioManager.resolve(success)
