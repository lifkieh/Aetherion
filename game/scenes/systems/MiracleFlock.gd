extends Node2D
## Kawanan yang lewat (Miracle "migration", E7): siluet burung/kunang menyeberangi
## layar sekali lalu hilang. Tanpa teks, tanpa popup — kalau kau tak mendongak,
## kau melewatkannya. Itu memang intinya.

const SPEED := 90.0
const LIFE := 26.0

var _t := 0.0
var _birds: Array = []   # {offset: Vector2, phase: float}

func _ready() -> void:
	z_index = 380
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(name + GameClock.date_string())
	var night := GameClock.is_night()
	for i in range(18 if not night else 26):
		_birds.append({
			"o": Vector2(rng.randf_range(-90, 90), rng.randf_range(-40, 40)),
			"p": rng.randf_range(0.0, TAU),
			"s": rng.randf_range(0.8, 1.3),
		})

func _process(delta: float) -> void:
	_t += delta
	position.x += SPEED * delta
	position.y += sin(_t * 0.5) * 6.0 * delta
	queue_redraw()
	if _t > LIFE:
		queue_free()

func _draw() -> void:
	var night := GameClock.is_night()
	var col := Color(1.0, 0.95, 0.5, 0.85) if night else Color(0.12, 0.12, 0.18, 0.75)
	for b in _birds:
		var o: Vector2 = b.o + Vector2(0, sin(_t * 3.0 + float(b.p)) * 3.0)
		if night:
			draw_circle(o, 1.6 * float(b.s), col)   # kunang-kunang
		else:
			# siluet burung: dua garis pendek membentuk "v" yang mengepak
			var flap: float = 2.5 + sin(_t * 6.0 + float(b.p)) * 2.0
			draw_line(o + Vector2(-4, 0) * float(b.s), o + Vector2(0, -flap), col, 1.0)
			draw_line(o + Vector2(4, 0) * float(b.s), o + Vector2(0, -flap), col, 1.0)
