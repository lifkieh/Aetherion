extends Node
## UiTheme (owner UI-Kit) — ONE visual language for ALL UI: classic JRPG
## blue-framed windows (Kenney Fantasy UI 9-slice + Aetherion palette + m5x7).
## Built once and set as the project-wide default theme so every Control inherits
## it — no two panel styles on screen.

const PANEL_TEX := "res://assets/game/ui/kenney/panel-000.png"
const FONT := "res://assets/game/fonts/m5x7.ttf"

# Aetherion JRPG palette
const WINDOW := Color(0.16, 0.22, 0.46)      # deep JRPG blue
const WINDOW_HI := Color(0.28, 0.36, 0.64)
const TEXT := Color(0.94, 0.96, 1.0)
const TEXT_DIM := Color(0.72, 0.78, 0.92)
const ACCENT := Color(1.0, 0.86, 0.42)       # gold
const DANGER := Color(1.0, 0.5, 0.45)

var theme: Theme
var font: Font

func _ready() -> void:
	if ResourceLoader.exists(FONT):
		font = load(FONT)
	theme = _build()
	# apply globally
	var root := get_tree().root
	root.theme = theme

## Clean solid JRPG window: blue fill + light-blue/gold border + rounded corners.
## StyleBoxFlat = reliable render + no texture cost (game ringan). Kenney 9-slice
## PNGs are kept in assets for future decorative framing.
func _panel_sb(content: int, bg: Color, border: Color = Color(0.55, 0.68, 1.0), radius: int = 5, bw: int = 2) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(content)
	return sb

func _build() -> Theme:
	var t := Theme.new()
	if font:
		t.default_font = font
	t.default_font_size = 16

	# Windows (gold border for the classic JRPG frame)
	t.set_stylebox("panel", "PanelContainer", _panel_sb(14, WINDOW, ACCENT, 6, 3))
	t.set_stylebox("panel", "Panel", _panel_sb(14, WINDOW, ACCENT, 6, 3))

	# Buttons
	t.set_stylebox("normal", "Button", _panel_sb(6, WINDOW_HI))
	t.set_stylebox("hover", "Button", _panel_sb(6, WINDOW_HI.lightened(0.12), ACCENT))
	t.set_stylebox("pressed", "Button", _panel_sb(6, WINDOW.darkened(0.1)))
	t.set_stylebox("disabled", "Button", _panel_sb(6, WINDOW.darkened(0.25), Color(0.4, 0.44, 0.6)))
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", ACCENT)
	t.set_color("font_pressed_color", "Button", ACCENT)
	t.set_color("font_disabled_color", "Button", TEXT_DIM.darkened(0.3))
	t.set_font_size("font_size", "Button", 16)

	# Labels
	t.set_color("font_color", "Label", TEXT)
	t.set_font_size("font_size", "Label", 16)

	# CheckButton / CheckBox text
	for cls in ["CheckButton", "CheckBox"]:
		t.set_color("font_color", cls, TEXT)
		t.set_color("font_hover_color", cls, ACCENT)

	# ScrollContainer / VBox spacing feel handled per-widget.
	return t

## Helper: an outlined heading label in accent gold (for titles).
func heading(text: String, size: int = 22) -> Label:
	var l := Label.new()
	l.text = text
	if font:
		l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", ACCENT)
	l.add_theme_constant_override("outline_size", 4)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	return l
