extends Node2D
## HouseInterior (UI/UX §7) — a cosy enterable building interior. A small warmly-lit
## wooden room with furniture and an exit portal back to Greenvale. Demonstrates
## interiors; no monsters, no day/night dimming (interiors are always lit).

const TILE := 16
const MAP_W := 20
const MAP_H := 14

var player: Player

func _ready() -> void:
	SafeZone.clear()
	_build_floor()
	_build_walls()
	_build_light()
	_build_furniture()
	_build_portal()
	_spawn_player()
	_add_ui()
	Stage.enter_region("Rumah Warga", "Hangat & aman — istirahat sejenak", "26 - Lost Village.ogg")
	if OS.get_environment("AETHER_SHOT") == "1":
		get_tree().create_timer(1.4).timeout.connect(func():
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit())

func _build_floor() -> void:
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	var floor := ColorRect.new()          # warm plank floor
	floor.color = Color(0.55, 0.40, 0.24)
	floor.size = Vector2(w, h)
	floor.z_index = -10
	add_child(floor)
	# plank seams for texture
	for gy in range(0, MAP_H):
		var seam := ColorRect.new()
		seam.color = Color(0.46, 0.32, 0.18, 0.7)
		seam.size = Vector2(w, 1)
		seam.position = Vector2(0, gy * TILE)
		seam.z_index = -9
		add_child(seam)
	# skirting/wall band at the top
	var wall := ColorRect.new()
	wall.color = Color(0.34, 0.24, 0.16)
	wall.size = Vector2(w, 24)
	wall.position = Vector2(0, -24)
	add_child(wall)

func _build_walls() -> void:
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

func _build_light() -> void:
	var mod := CanvasModulate.new()
	mod.color = Color(1.0, 0.94, 0.82)     # cosy warm interior light (never dims)
	add_child(mod)

func _deco(path: String, pos: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.position = pos
	s.z_index = int(pos.y)
	add_child(s)

func _build_furniture() -> void:
	var cx := MAP_W * TILE * 0.5
	_deco("res://assets/game/sprites/props/int_rug.png", Vector2(cx, MAP_H * TILE * 0.5))
	_deco("res://assets/game/sprites/props/int_bed.png", Vector2(40, 40))
	_deco("res://assets/game/sprites/props/int_shelf.png", Vector2(MAP_W * TILE - 28, 34))
	_deco("res://assets/game/sprites/props/int_table.png", Vector2(cx + 30, 60))
	_deco("res://assets/game/sprites/props/int_lamp.png", Vector2(20, MAP_H * TILE - 40))
	_deco("res://assets/game/sprites/props/int_lamp.png", Vector2(MAP_W * TILE - 20, MAP_H * TILE - 40))
	# a warm hearth glow near the shelf
	var light := PointLight2D.new()
	light.texture = _glow_tex()
	light.color = Color(1.0, 0.8, 0.5)
	light.energy = 0.7
	light.position = Vector2(MAP_W * TILE - 28, 34)
	add_child(light)

func _glow_tex() -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(64):
			var d := Vector2(x - 32, y - 32).length() / 32.0
			var a := clampf(1.0 - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a))
	return ImageTexture.create_from_image(img)

func _build_portal() -> void:
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup("res://scenes/Main.tscn", "Keluar rumah [E]")
	portal.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 20)

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	player.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 44)
	add_child(player)

func _add_ui() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())
