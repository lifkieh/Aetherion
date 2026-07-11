extends CanvasLayer
## Photo Mode (MARKET_STUDY D) — [P] toggles: hides HUD, freezes the scene,
## shows a frame; [E] saves a clean screenshot to user://photos/.
## Great for the pastel Candyveil / full-moon sky (organic marketing).

const DIR := "user://photos/"

var active := false
var frame: Control
var hint: Label
var _shots := 0

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()

func _build() -> void:
	frame = Control.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	# corner brackets
	for corner in [[Vector2(20, 20), false, false], [Vector2(-20, 20), true, false], [Vector2(20, -20), false, true], [Vector2(-20, -20), true, true]]:
		var c := _corner(corner[1], corner[2])
		c.position = corner[0]
		frame.add_child(c)
	hint = Label.new()
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		hint.add_theme_font_override("font", load("res://assets/game/fonts/m5x7.ttf"))
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_constant_override("outline_size", 5)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hint.text = "📷 Photo Mode  ·  [E] simpan foto  ·  [P] keluar"
	hint.anchor_left = 0.5
	hint.anchor_right = 0.5
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	hint.position = Vector2(-200, -44)
	hint.custom_minimum_size = Vector2(400, 0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(hint)

func _corner(flip_h: bool, flip_v: bool) -> Control:
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if flip_h:
		holder.anchor_left = 1.0; holder.anchor_right = 1.0
	if flip_v:
		holder.anchor_top = 1.0; holder.anchor_bottom = 1.0
	var col := Color(1, 1, 1, 0.85)
	var sx := -1 if flip_h else 1
	var sy := -1 if flip_v else 1
	var h := ColorRect.new(); h.color = col; h.size = Vector2(40 * sx, 5 * sy); holder.add_child(h)
	var v := ColorRect.new(); v.color = col; v.size = Vector2(5 * sx, 40 * sy); holder.add_child(v)
	return holder

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("photo_mode"):
		toggle()
		get_viewport().set_input_as_handled()
	elif active and event.is_action_pressed("interact"):
		save_photo()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	active = not active
	visible = active
	get_tree().paused = active
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = not active
	if active:
		EventBus.toast.emit("Photo Mode aktif")

func save_photo() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if not DirAccess.dir_exists_absolute(DIR):
		DirAccess.make_dir_recursive_absolute(DIR)
	frame.visible = false
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	frame.visible = true
	if img == null:
		return
	_shots += 1
	var path := DIR + "photo_%d_%d.png" % [Time.get_ticks_msec(), _shots]
	img.save_png(path)
	EventBus.toast.emit("📸 Foto disimpan: " + path.get_file())
