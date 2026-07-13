extends Node2D
## ROH HUTAN (Hidden Scenario #4, GDD v0.2 §8.2 — v0.4.3 #95).
## Bukan boss: ia tidak menyerang, tidak bisa dibunuh, dan tidak menghalangi jalanmu.
## Ia hanya BERHENTI MEMBERI. Itu jauh lebih menghukum — dan itu Stewardship:
## konsekuensi yang terlihat, tanpa pernah mengunci pemain (aturan no_fail).
## Digunakan sebagai aktor cutscene (spawn/despawn oleh Cutscene engine).

const R := 26.0

var _t := 0.0
var angry := true

func _ready() -> void:
	z_index = 60
	angry = ForestSpiritSystem.is_angry()
	var glow := PointLight2D.new()
	glow.color = Color(0.55, 1.0, 0.6) if not angry else Color(0.9, 0.55, 0.35)
	glow.energy = 1.1
	glow.texture = _dot()
	glow.scale = Vector2(1.6, 1.6)
	add_child(glow)

func _process(delta: float) -> void:
	_t += delta
	position.y += sin(_t * 1.6) * 6.0 * delta
	queue_redraw()

func _draw() -> void:
	var col := Color(0.45, 0.95, 0.55, 0.9) if not angry else Color(0.95, 0.5, 0.3, 0.9)
	# siluet: lingkaran inti + sulur yang bergerak (murah, tanpa aset)
	draw_circle(Vector2.ZERO, R * (0.9 + sin(_t * 2.2) * 0.06), col)
	draw_circle(Vector2.ZERO, R * 0.55, col.lightened(0.35))
	for i in 7:
		var a := _t * 0.6 + TAU * i / 7.0
		var p1 := Vector2.from_angle(a) * (R + 4.0)
		var p2 := Vector2.from_angle(a + 0.5) * (R + 16.0 + sin(_t * 3.0 + i) * 4.0)
		draw_line(p1, p2, col * Color(1, 1, 1, 0.75), 2.0)
	# "mata"
	draw_circle(Vector2(-7, -4), 2.5, Color(0.05, 0.12, 0.06))
	draw_circle(Vector2(7, -4), 2.5, Color(0.05, 0.12, 0.06))

func _dot() -> Texture2D:
	var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	for y in 96:
		for x in 96:
			var d := Vector2(x - 48, y - 48).length() / 48.0
			img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d, 0.0, 1.0)))
	return ImageTexture.create_from_image(img)
