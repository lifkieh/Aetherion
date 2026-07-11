extends Node2D
## Floating combat damage number.

@onready var label: Label = $Label

func show_number(amount: int, crit: bool, effective: bool) -> void:
	label.text = str(amount)
	# crisp dark outline for readability against any background (R2 Part 3)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 5)
	var col := Color(1, 1, 1)
	var big := 1.0
	if crit:
		col = Color(1.0, 0.85, 0.2)
		label.text = str(amount) + "!"
		big = 1.5
	elif effective:
		col = Color(1.0, 0.55, 0.3)
	label.modulate = col
	# a little pop + bounce so hits feel juicy
	label.pivot_offset = label.size * 0.5
	label.scale = Vector2(0.3, 0.3)
	var start_y := position.y
	var dx := randf_range(-6, 6)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "scale", Vector2(big, big), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:x", position.x + dx, 0.6)
	# up then a slight settle (bounce)
	tw.tween_property(self, "position:y", start_y - 26, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(self, "position:y", start_y - 20, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var fade := create_tween()
	fade.tween_interval(0.4)
	fade.tween_property(self, "modulate:a", 0.0, 0.4)
	fade.tween_callback(queue_free)
