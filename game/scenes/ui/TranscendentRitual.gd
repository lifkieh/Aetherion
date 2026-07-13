class_name TranscendentRitual
extends CanvasLayer
## Ritual MOMEN crafting Transenden (tier A+, v0.4.2 #25): layar redup,
## lingkaran rune berputar, jeda dramatis, LALU roll dieksekusi — sukses =
## pengumuman besar bergaya first-craft, gagal = rune pecah tapi bahan kunci
## selamat. Berjalan saat tree paused (menu). Hormati Settings.eco_mode.

signal finished(result: Dictionary)

const TIER_COLOR := {
	"A": Color(0.45, 0.85, 1.0),
	"S": Color(1.0, 0.84, 0.35),
	"SS": Color(0.95, 0.5, 1.0),
	"SSS": Color(1.0, 1.0, 1.0),
}

var _recipe_id := ""
var _tier := "A"
var _dim: ColorRect
var _circle: Node2D
var _label: Label
var _spin := 0.0
var _pulse := 0.0
var _resolved := false

static func play(parent: Node, recipe_id: String, tier: String) -> TranscendentRitual:
	var r: TranscendentRitual = TranscendentRitual.new()
	r._recipe_id = recipe_id
	r._tier = tier
	r.layer = 90
	r.process_mode = Node.PROCESS_MODE_ALWAYS
	parent.get_tree().root.add_child(r)
	return r

func _ready() -> void:
	var vp := get_viewport().get_visible_rect().size
	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.02, 0.06, 0.0)
	_dim.size = vp
	add_child(_dim)
	create_tween().tween_property(_dim, "color:a", 0.82, 0.4)

	_circle = Node2D.new()
	_circle.position = vp * 0.5
	_circle.draw.connect(_draw_circle)
	add_child(_circle)

	_label = Label.new()
	_label.text = Loc.t("ritual.title", [_tier])
	_label.add_theme_font_size_override("font_size", 22)
	_label.add_theme_color_override("font_color", TIER_COLOR.get(_tier, Color.WHITE))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.size = Vector2(vp.x, 40)
	_label.position = Vector2(0, vp.y * 0.5 + 130)
	add_child(_label)

	Audio.play_sfx("fusion")
	var wait := 1.0 if Settings.eco_mode else 2.6
	get_tree().create_timer(wait, true).timeout.connect(_resolve)

func _process(delta: float) -> void:
	_spin += delta * (1.5 if not _resolved else 6.0)
	_pulse += delta * 3.0
	if is_instance_valid(_circle):
		_circle.queue_redraw()

func _draw_circle() -> void:
	var col: Color = TIER_COLOR.get(_tier, Color.WHITE)
	var r := 90.0 + sin(_pulse) * 6.0
	_circle.draw_arc(Vector2.ZERO, r, 0, TAU, 48, col, 2.0)
	_circle.draw_arc(Vector2.ZERO, r * 0.72, _spin, _spin + TAU * 0.8, 40, col * Color(1, 1, 1, 0.7), 1.5)
	# glyph rune: 8 tanda pendek di lingkar luar, berputar berlawanan
	for k in 8:
		var a := -_spin * 0.7 + TAU * k / 8.0
		var p1 := Vector2.from_angle(a) * (r + 8.0)
		var p2 := Vector2.from_angle(a) * (r + 20.0)
		_circle.draw_line(p1, p2, col, 2.0)

func _resolve() -> void:
	_resolved = true
	var res := CraftingSystem.craft(_recipe_id)
	var vp := get_viewport().get_visible_rect().size
	if res.get("success", false):
		Audio.play_stinger("transcend")
		var flash := ColorRect.new()
		flash.color = Color(1, 1, 0.9, 0.9)
		flash.size = vp
		add_child(flash)
		create_tween().tween_property(flash, "color:a", 0.0, 0.6)
		var item_id: String = res.get("result", "")
		_label.text = Loc.t("ritual.success", [_tier, PlayerData.char_name, Db.item_name(item_id)])
		_label.position.y = vp.y * 0.5 - 24.0
		_label.add_theme_font_size_override("font_size", 26)
		if not Settings.eco_mode:
			UiFx.celebrate(_label)
	else:
		Audio.play_sfx("fizzle")
		_label.text = Loc.t("ritual.fail")
		_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		if is_instance_valid(_circle):
			_circle.queue_free()
			_circle = null
	var hold := 1.0 if Settings.eco_mode else 2.2
	get_tree().create_timer(hold, true).timeout.connect(func():
		finished.emit(res)
		queue_free())
