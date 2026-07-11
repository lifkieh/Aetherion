extends Node2D
## StreetLamp (R2 Part 1) — a lamp post that lights up at night. The PointLight2D
## only draws when it is night, so it is cheap during the day (hemat).

var _light: PointLight2D
var _glow: Sprite2D
var _cd := 0.0
var _on := false

func _ready() -> void:
	var post := Sprite2D.new()
	post.texture = load("res://assets/game/sprites/props/street_lamp.png")
	post.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	post.offset = Vector2(0, -14)          # base at the node origin
	add_child(post)
	z_index = int(global_position.y)
	_light = PointLight2D.new()
	_light.texture = _make_glow()
	_light.color = Color(1.0, 0.85, 0.5)
	_light.energy = 0.0
	_light.position = Vector2(0, -34)
	_light.z_index = 20
	add_child(_light)
	_glow = Sprite2D.new()               # small bright core on the lamp head
	_glow.texture = _make_core()
	_glow.position = Vector2(0, -34)
	_glow.visible = false
	add_child(_glow)
	_apply(GameClock.is_night())

func _process(delta: float) -> void:
	_cd -= delta
	if _cd > 0.0:
		return
	_cd = 0.7
	_apply(GameClock.is_night())

func _apply(night: bool) -> void:
	if night == _on:
		return
	_on = night
	_glow.visible = night
	var tw := create_tween()
	tw.tween_property(_light, "energy", 0.9 if night else 0.0, 0.6)

func _make_glow() -> Texture2D:
	var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	for y in range(96):
		for x in range(96):
			var d: float = Vector2(x - 48, y - 48).length() / 48.0
			img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d, 0.0, 1.0) ** 1.6))
	return ImageTexture.create_from_image(img)

func _make_core() -> Texture2D:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	for y in range(8):
		for x in range(8):
			var d: float = Vector2(x - 3.5, y - 3.5).length() / 4.0
			img.set_pixel(x, y, Color(1, 0.95, 0.75, clampf(1.0 - d, 0.0, 1.0)))
	return ImageTexture.create_from_image(img)
