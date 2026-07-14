extends Node2D
## ANAK-ANAK ASHBROOK (#216) — **kehidupan paling murni**: desa mengecil, tapi desa
## MASIH MELAHIRKAN. Mereka berlari, mereka mengejar ayam, mereka bermain **di depan
## gudang yang kosong** — kontras hidup × mati yang diminta Hukum Tertinggi.
##
## Mereka tidak memberi quest. Mereka tidak menjelaskan apa pun. Mereka cuma ada —
## dan justru itu yang membuat Ashbrook terasa rumah, bukan makam.

const SPEED := 62.0

var _spr: Sprite2D
var _chickens: Array = []
var _target: Node2D
var _t := 0.0
var _home := Vector2.ZERO

func setup(chickens: Array) -> void:
	_chickens = chickens

func _ready() -> void:
	_home = global_position
	_spr = Sprite2D.new()
	var img := Image.create(7, 11, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.85, 0.6, 0.45))
	_spr.texture = ImageTexture.create_from_image(img)
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_spr)

func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0 or not is_instance_valid(_target):
		_t = randf_range(2.0, 5.0)
		_target = _chickens.pick_random() if not _chickens.is_empty() and randf() < 0.7 else null
	var goal: Vector2 = _target.global_position if is_instance_valid(_target) else _home + Vector2(randf_range(-70, 70), randf_range(-50, 50))
	var d := goal - global_position
	if d.length() > 6.0:
		global_position += d.normalized() * SPEED * delta
	z_index = int(global_position.y)
