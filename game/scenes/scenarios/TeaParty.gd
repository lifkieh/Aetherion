extends Node2D
## The Sugar Queen's Tea Party (Hidden Scenario, v0.2 §8.2). A 3-round etiquette
## quiz; 3 wrong answers total = expelled forever (no_fail). Clear = Cook [S]
## Royal Tea Cake + Peppermint Fairy pet + "sugar_blessed" trait.

const QUESTIONS := [
	{"q": "Saat Sang Ratu menuangkan teh untukmu, kamu sebaiknya...",
	 "a": ["Menyeruput sekeras mungkin agar dipuji", "Menunggu, lalu mengucap terima kasih", "Menuang balik ke cangkir Ratu"], "correct": 1},
	{"q": "Menurut etiket jamuan, kue dinikmati dengan urutan...",
	 "a": ["Dari yang gurih ke yang paling manis", "Langsung yang paling manis", "Semua disuap sekaligus"], "correct": 0},
	{"q": "Bila Sang Ratu melempar lelucon yang garing, kamu...",
	 "a": ["Mengoreksi leluconnya keras-keras", "Tertawa kecil dengan sopan", "Pura-pura tertidur"], "correct": 1},
]

var idx := 0
var wrong := 0
var resolved := false
var _shot_at := -1.0

var cl: CanvasLayer
var q_label: Label
var status_label: Label
var answers_box: VBoxContainer
var _font: Font

func _ready() -> void:
	SafeZone.clear()
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	_build_bg()
	_build_ui()
	Audio.play_music("26 - Lost Village.ogg")
	EventBus.toast.emit("Jamuan Teh Sang Ratu Gula — jawab dengan sopan. Salah 3× = diusir selamanya!")
	_show_question()
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.4

func _process(delta: float) -> void:
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit()

func _build_bg() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.95, 0.75, 0.88)   # pastel candy parlour
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var c := CanvasLayer.new()
	c.layer = 1
	add_child(c)
	c.add_child(bg)

func _mk_label(t: String, s: int) -> Label:
	var l := Label.new()
	l.text = t
	if _font: l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", s)
	l.add_theme_color_override("font_color", Color(0.35, 0.12, 0.25))
	return l

func _build_ui() -> void:
	cl = CanvasLayer.new()
	cl.layer = 5
	add_child(cl)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(root)
	var vb := VBoxContainer.new()
	vb.anchor_left = 0.5; vb.anchor_top = 0.2; vb.anchor_right = 0.5
	vb.position = Vector2(-280, 60)
	vb.custom_minimum_size = Vector2(560, 0)
	vb.add_theme_constant_override("separation", 10)
	root.add_child(vb)
	vb.add_child(_mk_label("☕ Jamuan Teh Sang Ratu Gula", 26))
	status_label = _mk_label("", 15)
	vb.add_child(status_label)
	q_label = _mk_label("", 18)
	q_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	q_label.custom_minimum_size = Vector2(540, 0)
	vb.add_child(q_label)
	answers_box = VBoxContainer.new()
	answers_box.add_theme_constant_override("separation", 6)
	vb.add_child(answers_box)

func _show_question() -> void:
	if resolved:
		return
	status_label.text = "Babak %d/%d   ·   Kesalahan: %d/3" % [idx + 1, QUESTIONS.size(), wrong]
	var q: Dictionary = QUESTIONS[idx]
	q_label.text = q.q
	for c in answers_box.get_children():
		c.queue_free()
	for i in range(q.a.size()):
		var b := Button.new()
		b.text = q.a[i]
		if _font: b.add_theme_font_override("font", _font)
		b.add_theme_font_size_override("font_size", 16)
		b.custom_minimum_size = Vector2(540, 30)
		var choice := i
		b.pressed.connect(func(): answer(choice))
		answers_box.add_child(b)

## Answer the current question. Testable (no UI needed).
func answer(choice: int) -> void:
	if resolved:
		return
	var q: Dictionary = QUESTIONS[idx]
	if choice == int(q.correct):
		Audio.play_sfx("success")
		idx += 1
		if idx >= QUESTIONS.size():
			_finish(true)
		else:
			_show_question()
	else:
		wrong += 1
		Audio.play_sfx("hurt")
		EventBus.toast.emit("Sang Ratu mengernyit... (%d/3)" % wrong)
		if wrong >= 3:
			_finish(false)
		else:
			_show_question()

func _finish(success: bool) -> void:
	if resolved:
		return
	resolved = true
	if success:
		_grant_peppermint_fairy()
	if _shot_at > 0.0:
		return   # keep scene up for demo screenshot
	ScenarioManager.resolve(success)

func _grant_peppermint_fairy() -> void:
	var fairy := {
		"species_id": "peppermint_fairy", "name": "Peppermint Fairy", "level": 22, "star": 4,
		"element": "light", "size": "small", "rideable": false,
		"max_hp": 800, "atk": 30, "spd": 130, "affinity": 50, "tamed_at": GameClock.unix_now(),
	}
	PlayerData.monsters.append(fairy)
	if PlayerData.active_pet_index < 0:
		PlayerData.active_pet_index = PlayerData.monsters.size() - 1
	EventBus.pet_added.emit(fairy)
	EventBus.toast.emit("✨ Peppermint Fairy bergabung!")
