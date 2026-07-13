extends Node2D
## Pelangi ganda pasca-hujan (Miracle "double_rainbow", E7). Melengkung di langit
## selama beberapa menit lalu memudar. Buff-nya diberikan MiracleSystem, bukan di sini.

const LIFE := 240.0
const BANDS := [
	Color(0.95, 0.3, 0.3), Color(0.98, 0.65, 0.25), Color(0.98, 0.92, 0.35),
	Color(0.4, 0.85, 0.45), Color(0.35, 0.6, 0.95), Color(0.6, 0.4, 0.9),
]

var _t := 0.0

func _ready() -> void:
	z_index = 370
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 0.55, 3.0)

func _process(delta: float) -> void:
	_t += delta
	if _t > LIFE and modulate.a > 0.0:
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 4.0)
		tw.tween_callback(queue_free)
		set_process(false)

func _draw() -> void:
	_arc(300.0, 5.0)    # pelangi utama
	_arc(390.0, 3.0)    # pelangi kedua (lebih pucat) — inilah "ganda"-nya

func _arc(radius: float, width: float) -> void:
	var faded := radius > 340.0
	for i in BANDS.size():
		var c: Color = BANDS[i]
		if faded:
			c.a = 0.45
		draw_arc(Vector2.ZERO, radius + i * width, PI, TAU, 48, c, width)
