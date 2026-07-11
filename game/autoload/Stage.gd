extends CanvasLayer
## Stage — FF-style overworld presentation layer (owner UI/UX §3). One persistent
## overlay (autoload) that survives scene changes, providing:
##   • say()          dark-blue JRPG dialog box: speaker name + portrait + per-letter typing
##   • banner()       elegant area-name banner on region entry
##   • enter_region() banner + per-region music in one call
##   • go_to_scene()  fade-out → change scene → fade-in transition
## Uses the unified UiTheme palette so it reads as the same visual language.

signal dialog_finished
signal _advanced      # internal: player pressed advance while a line is fully shown

const TYPE_SPEED := 42.0     # letters per second

var _fade: ColorRect
var _banner: Control
var _banner_title: Label
var _banner_sub: Label

var _dlg_root: Control
var _dlg_name_tab: Panel
var _dlg_name: Label
var _dlg_text: Label
var _dlg_portrait: TextureRect
var _dlg_portrait_frame: Panel
var _dlg_arrow: Label

var _typing := false
var _full_text := ""
var _shown := 0.0
var _blip_at := 0
var _dlg_active := false
var _arrow_t := 0.0

func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_fade()
	_build_banner()
	_build_dialog()

func _font(size: int) -> Font:
	return UiTheme.font

# --- Fade -------------------------------------------------------------------

func _build_fade() -> void:
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)

func fade_out(secs := 0.35) -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, secs)
	await tw.finished

func fade_in(secs := 0.45) -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 0.0, secs)
	await tw.finished

## Fade to black, swap scene, fade back in. Safe to call from anywhere.
func go_to_scene(path: String) -> void:
	await fade_out(0.35)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	await fade_in(0.45)

# --- Area-name banner -------------------------------------------------------

func _build_banner() -> void:
	_banner = Control.new()
	_banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.modulate.a = 0.0
	add_child(_banner)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.anchor_left = 0.5; box.anchor_right = 0.5
	box.position = Vector2(0, 46)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_banner.add_child(box)
	var rule_top := _rule()
	box.add_child(rule_top)
	_banner_title = UiTheme.heading("", 30)
	_banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_banner_title)
	_banner_sub = Label.new()
	_banner_sub.add_theme_font_override("font", _font(14))
	_banner_sub.add_theme_font_size_override("font_size", 14)
	_banner_sub.add_theme_color_override("font_color", UiTheme.TEXT_DIM)
	_banner_sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	_banner_sub.add_theme_constant_override("outline_size", 4)
	_banner_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_banner_sub)
	box.add_child(_rule())

func _rule() -> ColorRect:
	var r := ColorRect.new()
	r.color = UiTheme.ACCENT
	r.custom_minimum_size = Vector2(220, 2)
	return r

## Elegant area-name banner. Slides/fades in, holds, fades out.
func banner(title: String, subtitle := "") -> void:
	_banner_title.text = title
	_banner_sub.text = subtitle
	_banner_sub.visible = subtitle != ""
	_banner.modulate.a = 0.0
	_banner.position.y = -8
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_banner, "modulate:a", 1.0, 0.5)
	tw.tween_property(_banner, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.chain().tween_interval(1.9)
	tw.chain().tween_property(_banner, "modulate:a", 0.0, 0.7)

## One call on region entry: banner + explore music.
func enter_region(title: String, subtitle := "", music := "") -> void:
	banner(title, subtitle)
	if music != "":
		Audio.play_music(music)

# --- Dialog box -------------------------------------------------------------

func _build_dialog() -> void:
	_dlg_root = Control.new()
	_dlg_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dlg_root.visible = false
	add_child(_dlg_root)

	# Dark-blue FF window anchored to the bottom.
	var panel := Panel.new()
	panel.anchor_left = 0.0; panel.anchor_right = 1.0
	panel.anchor_top = 1.0; panel.anchor_bottom = 1.0
	panel.offset_left = 20; panel.offset_right = -20
	panel.offset_top = -168; panel.offset_bottom = -30
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.08, 0.26, 0.96)     # classic FF dark blue
	sb.border_color = UiTheme.ACCENT
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(7)
	sb.set_content_margin_all(14)
	# subtle inner highlight ring
	sb.shadow_color = Color(0.3, 0.42, 0.9, 0.4)
	sb.shadow_size = 2
	panel.add_theme_stylebox_override("panel", sb)
	_dlg_root.add_child(panel)

	# Portrait frame (left)
	_dlg_portrait_frame = Panel.new()
	_dlg_portrait_frame.position = Vector2(6, 6)
	_dlg_portrait_frame.size = Vector2(104, 104)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.02, 0.03, 0.12, 0.9)
	psb.border_color = Color(0.55, 0.68, 1.0)
	psb.set_border_width_all(2)
	psb.set_corner_radius_all(5)
	_dlg_portrait_frame.add_theme_stylebox_override("panel", psb)
	panel.add_child(_dlg_portrait_frame)
	_dlg_portrait = TextureRect.new()
	_dlg_portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dlg_portrait.offset_left = 4; _dlg_portrait.offset_top = 4
	_dlg_portrait.offset_right = -4; _dlg_portrait.offset_bottom = -4
	_dlg_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_dlg_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_dlg_portrait_frame.add_child(_dlg_portrait)

	# Speaker name tab
	_dlg_name_tab = Panel.new()
	_dlg_name_tab.position = Vector2(120, -14)
	_dlg_name_tab.size = Vector2(160, 30)
	var nsb := StyleBoxFlat.new()
	nsb.bg_color = Color(0.10, 0.15, 0.42, 0.98)
	nsb.border_color = UiTheme.ACCENT
	nsb.set_border_width_all(2)
	nsb.set_corner_radius_all(5)
	nsb.set_content_margin_all(4)
	_dlg_name_tab.add_theme_stylebox_override("panel", nsb)
	panel.add_child(_dlg_name_tab)
	_dlg_name = Label.new()
	_dlg_name.add_theme_font_override("font", _font(18))
	_dlg_name.add_theme_font_size_override("font_size", 18)
	_dlg_name.add_theme_color_override("font_color", UiTheme.ACCENT)
	_dlg_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dlg_name.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dlg_name_tab.add_child(_dlg_name)

	# Body text (per-letter typing via visible_characters)
	_dlg_text = Label.new()
	_dlg_text.position = Vector2(120, 20)
	_dlg_text.size = Vector2(1000, 86)
	_dlg_text.anchor_right = 1.0
	_dlg_text.offset_right = -14
	_dlg_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dlg_text.add_theme_font_override("font", _font(20))
	_dlg_text.add_theme_font_size_override("font_size", 20)
	_dlg_text.add_theme_color_override("font_color", UiTheme.TEXT)
	panel.add_child(_dlg_text)

	# Blinking advance arrow
	_dlg_arrow = Label.new()
	_dlg_arrow.text = "▼"
	_dlg_arrow.add_theme_font_override("font", _font(18))
	_dlg_arrow.add_theme_font_size_override("font_size", 18)
	_dlg_arrow.add_theme_color_override("font_color", UiTheme.ACCENT)
	_dlg_arrow.anchor_left = 1.0; _dlg_arrow.anchor_right = 1.0
	_dlg_arrow.anchor_top = 1.0; _dlg_arrow.anchor_bottom = 1.0
	_dlg_arrow.position = Vector2(-30, -30)
	_dlg_arrow.visible = false
	panel.add_child(_dlg_arrow)

## Show a dialog. `lines` may be a String or Array of Strings. `portrait` may be a
## Texture2D or a res:// path (String); null/"" hides the portrait frame.
## Await it to block until the player dismisses every line.
func say(lines, speaker := "", portrait = null) -> void:
	var arr: Array = lines if typeof(lines) == TYPE_ARRAY else [str(lines)]
	if arr.is_empty():
		return
	_set_portrait(portrait)
	_dlg_name.text = speaker
	_dlg_name_tab.visible = speaker != ""
	_dlg_root.visible = true
	_dlg_active = true
	var was_paused := get_tree().paused
	get_tree().paused = true
	for line in arr:
		await _run_line(str(line))
	_dlg_root.visible = false
	_dlg_active = false
	get_tree().paused = was_paused
	dialog_finished.emit()

func is_busy() -> bool:
	return _dlg_active

func _set_portrait(portrait) -> void:
	var tex: Texture2D = null
	if portrait is Texture2D:
		tex = portrait
	elif typeof(portrait) == TYPE_STRING and portrait != "" and ResourceLoader.exists(portrait):
		tex = load(portrait)
	_dlg_portrait.texture = tex
	_dlg_portrait_frame.visible = tex != null
	# text starts after the portrait if present, else uses the full width
	_dlg_text.position.x = 120.0 if tex != null else 16.0
	_dlg_name_tab.position.x = 120.0 if tex != null else 16.0

func _run_line(line: String) -> void:
	_full_text = line
	_dlg_text.text = line
	_dlg_text.visible_characters = 0
	_shown = 0.0
	_blip_at = 0
	_typing = true
	_dlg_arrow.visible = false
	while _typing:
		await get_tree().process_frame
	_dlg_arrow.visible = true
	await _advanced
	Audio.play_sfx("click")

func _process(delta: float) -> void:
	# blinking advance arrow
	if _dlg_arrow and _dlg_arrow.visible:
		_arrow_t += delta
		_dlg_arrow.modulate.a = 0.4 + 0.6 * absf(sin(_arrow_t * 4.0))
	if not _typing:
		return
	_shown += delta * TYPE_SPEED
	var n := int(_shown)
	if n >= _full_text.length():
		_dlg_text.visible_characters = -1
		_typing = false
	else:
		_dlg_text.visible_characters = n
		if n - _blip_at >= 3:
			_blip_at = n
			var c := _full_text.substr(maxi(0, n - 1), 1)
			if c.strip_edges() != "":
				Audio.play_sfx("click", 1.6)

func _input(event: InputEvent) -> void:
	if not _dlg_active:
		return
	var advance := false
	if event is InputEventKey and event.pressed and not event.echo:
		advance = event.keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance = true
	if not advance:
		return
	get_viewport().set_input_as_handled()
	if _typing:
		# reveal the whole line immediately
		_dlg_text.visible_characters = -1
		_typing = false
	else:
		_advanced.emit()
