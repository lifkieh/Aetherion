extends Node2D
## AYAM ASHBROOK (#216) — **bukan objek quest.** Ia berkeliaran, ia menghalangi
## jalan, ia lari saat didekati. Hidup, lucu, mengganggu — **itu poin-nya**
## (cetak biru v2: "ayam yang BENAR-BENAR mengganggu jalan").
##
## Hukum Tertinggi Ashbrook: gudang gandum yang kosong itu **dihuni empat ekor
## ayam** — kematian dan kehidupan berdiri di tempat yang sama.

const SPEED := 34.0
const FLEE_RADIUS := 44.0

var _spr: Sprite2D
var _dir := Vector2.RIGHT
var _t := 0.0
var _home := Vector2.ZERO

func _ready() -> void:
	_home = global_position
	_spr = Sprite2D.new()
	var p := "res://assets/game/sprites/props/chicken.png"
	if ResourceLoader.exists(p):
		_spr.texture = load(p)
	else:
		var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.95, 0.93, 0.86))
		_spr.texture = ImageTexture.create_from_image(img)
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_spr)
	z_index = int(global_position.y)

func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0:
		_t = randf_range(0.8, 2.4)
		_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var pl = get_tree().get_first_node_in_group("player")
	var spd := SPEED
	if is_instance_valid(pl):
		var d: Vector2 = global_position - pl.global_position
		if d.length() < FLEE_RADIUS:      # lari saat didekati — bukan properti diam
			_dir = d.normalized()
			spd = SPEED * 2.6
	global_position += _dir * spd * delta
	if global_position.distance_to(_home) > 130.0:
		_dir = (_home - global_position).normalized()
	z_index = int(global_position.y)
