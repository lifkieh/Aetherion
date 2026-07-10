extends Node2D
## Floating combat damage number.

@onready var label: Label = $Label

func show_number(amount: int, crit: bool, effective: bool) -> void:
	label.text = str(amount)
	var col := Color(1, 1, 1)
	if crit:
		col = Color(1.0, 0.85, 0.2)
		label.text = str(amount) + "!"
		label.scale = Vector2(1.4, 1.4)
	elif effective:
		col = Color(1.0, 0.5, 0.3)
	label.modulate = col
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position:y", position.y - 22, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.chain().tween_callback(queue_free)
