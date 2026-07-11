extends Node2D
## Puddle — Ice-flow freezes it into a solid standing platform (element rule,
## elements.json platformer_rules.ice.freeze_puddle). Fire melts it back.

const TILE := 16

var frozen := false
var width_tiles := 3
var _rect: ColorRect
var _body: StaticBody2D

func setup(tiles: int) -> void:
	width_tiles = tiles

func _ready() -> void:
	add_to_group("puddle")
	_rect = ColorRect.new()
	_rect.color = Color(0.35, 0.55, 0.85, 0.7)
	_rect.size = Vector2(width_tiles * TILE, 6)
	_rect.position = Vector2(-width_tiles * TILE / 2.0, 0)
	add_child(_rect)

func freeze() -> void:
	if frozen:
		return
	frozen = true
	_rect.color = Color(0.7, 0.9, 1.0, 0.95)
	_rect.size.y = 8
	_body = StaticBody2D.new()
	_body.collision_layer = 4   # solid — you can stand on the ice
	_body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width_tiles * TILE, 8)
	cs.shape = shape
	cs.position = Vector2(0, 4)
	_body.add_child(cs)
	add_child(_body)
	EventBus.toast.emit("❄ Genangan membeku jadi pijakan!")
	Audio.play_sfx("click")

func melt() -> void:
	if not frozen:
		return
	frozen = false
	if _body and is_instance_valid(_body):
		_body.queue_free()
	_rect.color = Color(0.35, 0.55, 0.85, 0.7)
	_rect.size.y = 6
