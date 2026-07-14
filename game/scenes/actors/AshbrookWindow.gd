extends Node2D
## JENDELA ASHBROOK (#218) — **kontras dari PERBEDAAN, bukan ketiadaan.**
##
## Sebelum ini, "hanya lampu Merrit yang menyala" benar hanya karena **tak ada
## jendela lain sama sekali**. Mata pemain tak pernah melihat apa pun **padam**.
##
## Kini: rumah-rumah lain **menyala sore hari**, lalu **PADAM SATU PER SATU**
## (19.00 · 20.00 · 21.00). Pemain menyaksikan desa **tertidur** — dan satu lampu
## menolak ikut tidur.

var off_hour := 20
var _rect: ColorRect
var _light: PointLight2D

func place(p: Vector2, hour_off: int) -> void:
	global_position = p
	off_hour = hour_off

func _ready() -> void:
	add_to_group("ashbrook_window")
	z_index = 3000
	_rect = ColorRect.new()
	_rect.color = Color(1.0, 0.84, 0.52)
	_rect.size = Vector2(7, 6)
	_rect.position = Vector2(-3, -3)
	add_child(_rect)
	_light = PointLight2D.new()
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	_light.texture = ImageTexture.create_from_image(img)
	_light.energy = 0.8
	_light.texture_scale = 4.0
	_light.color = Color(1.0, 0.82, 0.5)
	add_child(_light)
	apply_hour(GameClock.wib_hour())

## Menyala hanya SORE (17.00) sampai jam padamnya sendiri. Dipanggil test (#151b).
func apply_hour(h: int) -> void:
	var lit := h >= 17 and h < off_hour
	visible = lit

func is_lit() -> bool:
	return visible
