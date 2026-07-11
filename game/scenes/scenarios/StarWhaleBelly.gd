extends Node2D
## Belly of the Star Whale (Hidden Scenario, v0.2 §8.2). Escape before you are
## digested: survive 60s while stomach acid wells up. Die = fail permanent.
## Clear -> material [S] Ambergris Star + permanent... (Fase 0: reward only).

const TILE := 16
const MAP_W := 42
const MAP_H := 30
const SURVIVE_TIME := 60.0

var time_left := SURVIVE_TIME
var resolved := false
var player: Player
var label: Label
var _acid_timer := 0.0
var _shot_at := -1.0

func _ready() -> void:
	SafeZone.clear()
	_build_ground()
	_build_boundaries()
	_build_sky()
	_spawn_player()
	_spawn_parasites()
	_build_hud()
	EventBus.player_died.connect(_on_player_died)
	Audio.play_music("26 - Lost Village.ogg")
	EventBus.toast.emit("PERUT STAR WHALE — bertahan 60 dtk, hindari asam lambung!")
	if OS.get_environment("AETHER_WHALE_SHOT") == "1":
		_shot_at = 1.4

func _process(delta: float) -> void:
	if not resolved:
		time_left -= delta
		if label:
			label.text = "Keluar dalam: %0.1f dtk  ·  hindari asam!" % max(0.0, time_left)
		# acid wells up faster as time runs out
		_acid_timer -= delta
		var interval: float = lerpf(1.1, 0.35, 1.0 - time_left / SURVIVE_TIME)
		if _acid_timer <= 0.0:
			_acid_timer = interval
			_spawn_acid()
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
	# fleshy belly floor: a solid dark-red color layer
	var bg := ColorRect.new()
	bg.color = Color(0.35, 0.12, 0.16)
	bg.size = Vector2(MAP_W * TILE, MAP_H * TILE)
	bg.z_index = -10
	add_child(bg)
	# pulsing veins (decorative)
	for i in range(40):
		var v := ColorRect.new()
		v.color = Color(0.5, 0.18, 0.22, 0.6)
		v.size = Vector2(randf_range(6, 30), 3)
		v.position = Vector2(randf_range(0, MAP_W * TILE), randf_range(0, MAP_H * TILE))
		v.z_index = -9
		add_child(v)

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
	cm.color = Color(0.7, 0.5, 0.55)   # dim, organic
	add_child(cm)

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	player.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE * 0.5)
	add_child(player)

func _spawn_parasites() -> void:
	# a couple of slow digestive parasites to pressure movement
	for i in range(2):
		var inst := MonsterFactory.make("verdant_slime", 12, 3)
		inst["name"] = "Parasit Lambung"
		inst["tint"] = "c07040"
		inst["spd"] = 90
		inst["aggro_radius"] = 1200.0
		var m := preload("res://scenes/actors/Monster.tscn").instantiate()
		add_child(m)
		m.global_position = Vector2(randf_range(40, MAP_W * TILE - 40), randf_range(40, MAP_H * TILE - 40))
		m.setup(inst, self)

func _spawn_acid() -> void:
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1   # player
	var cs := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 14
	cs.shape = shape
	area.add_child(cs)
	var rect := ColorRect.new()
	rect.color = Color(0.6, 0.9, 0.3, 0.7)
	rect.size = Vector2(28, 28)
	rect.position = Vector2(-14, -14)
	area.add_child(rect)
	area.z_index = 5
	# spawn near the player but not on top
	var off := Vector2.from_angle(randf() * TAU) * randf_range(40, 120)
	area.global_position = (player.global_position if is_instance_valid(player) else Vector2(200, 200)) + off
	area.global_position.x = clampf(area.global_position.x, 20, MAP_W * TILE - 20)
	area.global_position.y = clampf(area.global_position.y, 20, MAP_H * TILE - 20)
	add_child(area)
	area.body_entered.connect(func(b):
		if b == player and b.has_method("take_hit"):
			b.take_hit({"damage": 22, "element": "poison"}, null))
	# fade out after a few seconds
	var tw := area.create_tween()
	tw.tween_interval(2.5)
	tw.tween_property(rect, "modulate:a", 0.0, 0.6)
	tw.tween_callback(area.queue_free)

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

func _on_player_died() -> void:
	if not resolved:
		_finish(false)

func _finish(success: bool) -> void:
	if resolved:
		return
	resolved = true
	if _shot_at > 0.0:
		return
	ScenarioManager.resolve(success)
