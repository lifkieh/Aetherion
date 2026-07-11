extends Node2D
## Ambience (R2 Part 2) — cheap GPU-particle atmosphere that follows the player:
## forest → butterflies by day, fireflies by night; candy → drifting sugar;
## desert → blowing dust. One or two GPUParticles2D nodes, emission box ~screen size.

var theme := "forest"
var _day: GPUParticles2D
var _night: GPUParticles2D
var _cd := 0.0

func setup(t: String) -> void:
	theme = t

func _ready() -> void:
	z_index = 30
	match theme:
		"snow":
			_day = _make(_dot(Color(1, 1, 1, 0.95), 3), 26, Vector2(5, 26), Color(1, 1, 1), 4.2)  # falling flakes
		"candy":
			_day = _make(_dot(Color(1, 1, 1, 0.9), 3), 16, Vector2(6, -14), Color(1, 0.9, 0.95), 3.2)
		"desert":
			_day = _make(_dot(Color(0.85, 0.75, 0.55, 0.5), 3), 14, Vector2(34, 4), Color(0.9, 0.82, 0.6), 3.5)
		_:
			_day = _make(_butterfly(), 12, Vector2(10, -4), Color(1, 1, 1), 4.0)      # butterflies
			_night = _make(_dot(Color(1.0, 0.95, 0.5, 1.0), 3), 14, Vector2(4, -4), Color(1.0, 0.9, 0.4), 4.5)
	_refresh()

func _make(tex: Texture2D, amount: int, drift: Vector2, col: Color, life: float) -> GPUParticles2D:
	var p := GPUParticles2D.new()
	p.amount = amount
	p.lifetime = life
	p.preprocess = life
	p.texture = tex
	p.modulate = col
	var m := ParticleProcessMaterial.new()
	m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	m.emission_box_extents = Vector3(360, 220, 0)          # ~screen area at 2x
	m.direction = Vector3(drift.x, drift.y, 0)
	m.spread = 40.0
	m.initial_velocity_min = 6.0
	m.initial_velocity_max = 18.0
	m.gravity = Vector3(0, -2 if theme == "candy" else 0, 0)
	m.scale_min = 0.7
	m.scale_max = 1.3
	m.angle_min = -180; m.angle_max = 180
	m.angular_velocity_min = -40; m.angular_velocity_max = 40
	var curve := Curve.new()
	curve.add_point(Vector2(0, 0)); curve.add_point(Vector2(0.2, 1)); curve.add_point(Vector2(0.8, 1)); curve.add_point(Vector2(1, 0))
	var ct := CurveTexture.new(); ct.curve = curve
	m.alpha_curve = ct
	p.process_material = m
	add_child(p)
	return p

func _process(delta: float) -> void:
	var pl := get_tree().get_first_node_in_group("player")
	if pl:
		global_position = pl.global_position
	_cd -= delta
	if _cd > 0.0:
		return
	_cd = 1.0
	_refresh()

func _refresh() -> void:
	if Settings.eco_mode:
		if _day: _day.emitting = false
		if _night: _night.emitting = false
		return
	var night := GameClock.is_night()
	if theme == "forest":
		if _day: _day.emitting = not night
		if _night: _night.emitting = night
	else:
		if _day: _day.emitting = true

func _dot(col: Color, r: int) -> Texture2D:
	var s := r * 2 + 2
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	for y in range(s):
		for x in range(s):
			var d: float = Vector2(x - s * 0.5, y - s * 0.5).length() / r
			img.set_pixel(x, y, Color(col.r, col.g, col.b, col.a * clampf(1.0 - d, 0.0, 1.0)))
	return ImageTexture.create_from_image(img)

func _butterfly() -> Texture2D:
	var img := Image.create(8, 6, false, Image.FORMAT_RGBA8)
	var cols := [Color(1, 0.6, 0.2), Color(0.9, 0.4, 0.7), Color(0.5, 0.7, 1.0)]
	var c: Color = cols[randi() % cols.size()]
	for p in [Vector2i(1,1),Vector2i(2,1),Vector2i(1,2),Vector2i(2,3),Vector2i(1,4),Vector2i(5,1),Vector2i(6,1),Vector2i(5,2),Vector2i(5,3),Vector2i(6,4)]:
		img.set_pixel(p.x, p.y, c)
	img.set_pixel(3, 2, Color(0.2, 0.2, 0.2)); img.set_pixel(4, 2, Color(0.2, 0.2, 0.2))  # body
	img.set_pixel(3, 3, Color(0.2, 0.2, 0.2)); img.set_pixel(4, 3, Color(0.2, 0.2, 0.2))
	return ImageTexture.create_from_image(img)
