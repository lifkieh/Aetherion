extends Panel
## Inventory slot with a rich (colored) comparison tooltip (PC5). The plain
## tooltip_text can't be colored, so we render a BBCode RichTextLabel instead.

var tip_bbcode := ""
var _font: Font = null

func set_tip(bb: String, font: Font) -> void:
	tip_bbcode = bb
	_font = font
	tooltip_text = " "   # non-empty so Godot asks us for a custom tooltip

func _make_custom_tooltip(_for_text: String) -> Object:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.08, 0.18, 0.98)
	sb.border_color = Color(0.4, 0.5, 0.8)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(5)
	sb.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", sb)
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.custom_minimum_size = Vector2(250, 0)
	if _font:
		rt.add_theme_font_override("normal_font", _font)
		rt.add_theme_font_size_override("normal_font_size", 15)
	rt.text = tip_bbcode
	panel.add_child(rt)
	return panel
