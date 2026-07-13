extends Node2D
## HouseInterior (UI/UX §7) — a cosy enterable building interior. A small warmly-lit
## wooden room with furniture and an exit portal back to Greenvale. Demonstrates
## interiors; no monsters, no day/night dimming (interiors are always lit).

const TILE := 16
const MAP_W := 20
const MAP_H := 14

var player: Player
var variant := "house"

const VARIANTS := {
	"house":      {"title": "Rumah Warga", "sub": "Hangat & aman — istirahat sejenak", "floor": Color(0.55, 0.40, 0.24)},
	"blacksmith": {"title": "Bengkel Pandai Besi", "sub": "Bau arang & besi panas", "floor": Color(0.34, 0.30, 0.30)},
	"inn":        {"title": "Penginapan Rusa Emas", "sub": "Kamar hangat untuk bermalam", "floor": Color(0.50, 0.38, 0.28)},
	"store":      {"title": "Toko Umum", "sub": "Segala kebutuhan petualang", "floor": Color(0.58, 0.46, 0.30)},
}

func _ready() -> void:
	SafeZone.clear()
	variant = WorldState.pending_interior if WorldState.pending_interior in VARIANTS else "house"
	var envv := OS.get_environment("AETHER_INTERIOR")
	if envv in VARIANTS:
		variant = envv
	_build_floor()
	_build_walls()
	_build_light()
	_build_furniture()
	_build_resident()
	_build_portal()
	_spawn_player()
	_add_ui()
	var v: Dictionary = VARIANTS[variant]
	Stage.enter_region(v.title, v.sub, "town.ogg")
	if OS.get_environment("AETHER_SHOT") == "1":
		get_tree().create_timer(1.4).timeout.connect(func():
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit())

func _build_floor() -> void:
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	var floor := ColorRect.new()          # warm plank floor (tinted per variant)
	floor.color = VARIANTS[variant].floor
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

func _p(name: String) -> String:
	return "res://assets/game/sprites/props/%s.png" % name

func _hearth(pos: Vector2, col := Color(1.0, 0.8, 0.5), energy := 0.7) -> void:
	var light := PointLight2D.new()
	light.texture = _glow_tex()
	light.color = col
	light.energy = energy
	light.position = pos
	add_child(light)

func _build_furniture() -> void:
	var cx := MAP_W * TILE * 0.5
	var W := MAP_W * TILE
	var H := MAP_H * TILE
	_deco(_p("int_rug"), Vector2(cx, H * 0.5))
	_deco(_p("int_lamp"), Vector2(18, H - 40))
	_deco(_p("int_lamp"), Vector2(W - 18, H - 40))
	match variant:
		"blacksmith":
			_deco(_p("int_shelf"), Vector2(30, 34))          # tool rack
			_deco(_p("barrel"), Vector2(W - 30, 40))
			_deco(_p("crate"), Vector2(W - 50, 46))
			_deco(_p("int_table"), Vector2(cx + 6, 54))      # anvil bench
			# forge glow (orange, strong) at the far wall
			var forge := ColorRect.new()
			forge.color = Color(1.0, 0.5, 0.1); forge.size = Vector2(26, 18)
			forge.position = Vector2(W - 58, 20); add_child(forge)
			_hearth(Vector2(W - 45, 28), Color(1.0, 0.5, 0.2), 1.1)
		"inn":
			_deco(_p("int_bed"), Vector2(40, 40))
			_deco(_p("int_bed"), Vector2(W - 44, 40))
			_deco(_p("int_bed"), Vector2(40, H - 46))
			_deco(_p("int_table"), Vector2(cx, 54))
			_deco(_p("int_shelf"), Vector2(cx + 40, 34))
			_hearth(Vector2(cx, 40), Color(1.0, 0.85, 0.6), 0.6)
		"store":
			_deco(_p("int_shelf"), Vector2(24, 34))
			_deco(_p("int_shelf"), Vector2(56, 34))
			_deco(_p("int_shelf"), Vector2(W - 24, 34))
			_deco(_p("stall"), Vector2(cx, 58))              # shop counter
			_deco(_p("sack"), Vector2(30, H - 40))
			_deco(_p("barrel"), Vector2(W - 30, H - 44))
			_hearth(Vector2(cx, 50), Color(1.0, 0.9, 0.7), 0.5)
		_:  # cosy home
			_deco(_p("int_bed"), Vector2(40, 40))
			_deco(_p("int_shelf"), Vector2(W - 28, 34))
			_deco(_p("int_table"), Vector2(cx + 30, 60))
			_deco(_p("flower_pot"), Vector2(W - 24, H - 42))
			_hearth(Vector2(W - 28, 34), Color(1.0, 0.8, 0.5), 0.7)

func _build_resident() -> void:
	# A themed NPC inside the building providing its service (reuses Interactable kinds).
	var kind := ""
	match variant:
		"blacksmith": kind = "bench"
		"inn": kind = "inn"
		"store": kind = "shop"
		_: return                      # plain houses have no service NPC
	var npc := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(npc)
	npc.setup(kind)
	npc.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE * 0.5 - 4)

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
