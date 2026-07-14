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

## Ukuran/warna bisa diubah — dipakai juga oleh KAMBING di jembatan (#217).
var body_radius := 5.0
## BUG-217f: kambing berkeliaran sampai ~235px dari jembatan — ia meninggalkan pos
## yang justru menjadi ALASAN keberadaannya. Radius kini DIKUNCI KERAS.
var wander_radius := 110.0

## BUG-217g: `_ready()` menangkap _home SEBELUM posisi di-set (add_child dulu,
## posisi belakangan) → SEMUA ayam/kambing berumah di (0,0), bukan di gudang/jembatan.
## Kehidupan yang seharusnya berpasangan dengan keruntuhan justru menggerombol di
## sudut peta. `place()` menetapkan posisi DAN rumah sekaligus.
func place(p: Vector2) -> void:
	global_position = p
	_home = p

func _ready() -> void:
	if _home == Vector2.ZERO:
		_home = global_position
	add_to_group("ashbrook_life")
	# BUG-217a: ayam TIDAK menghalangi jalan (tak punya collision) — padahal cetak
	# biru menuntut "ayam yang BENAR-BENAR mengganggu jalan". Kini ia benda padat.
	var body := StaticBody2D.new()
	var cs := CollisionShape2D.new()
	var sh := CircleShape2D.new()
	sh.radius = body_radius
	cs.shape = sh
	body.add_child(cs)
	add_child(body)
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
	var away := global_position - _home
	if away.length() > wander_radius:                  # klem KERAS, bukan sekadar belok
		global_position = _home + away.normalized() * wander_radius
		_dir = (-away).normalized()
	z_index = int(global_position.y)
