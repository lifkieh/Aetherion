extends Node2D
## Critter (R2 Part 1) — a small ambient town animal (chicken / cat). Idles and
## wanders a few tiles around its home spot. Pure decoration, cheap.

const SPEED := 14.0

var _kind := "chicken"
var _home := Vector2.ZERO
var _target := Vector2.ZERO
var _pause := 0.0
var _sprite: AnimatedSprite2D

func setup(kind: String) -> void:
	_kind = kind

func _ready() -> void:
	_home = global_position
	_target = global_position
	_sprite = AnimatedSprite2D.new()
	var tex := load("res://assets/game/sprites/animals/%s.png" % _kind)
	_sprite.sprite_frames = SheetUtil.build_strip(tex, 16, 2, "idle", 3.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.play("idle")
	add_child(_sprite)

func _process(delta: float) -> void:
	z_index = int(global_position.y)
	if _pause > 0.0:
		_pause -= delta
		return
	var to := _target - global_position
	if to.length() < 3.0:
		_target = _home + Vector2(randf_range(-28, 28), randf_range(-20, 20))
		_pause = randf_range(0.6, 2.4)
		return
	global_position += to.normalized() * SPEED * delta
	_sprite.flip_h = to.x < 0
