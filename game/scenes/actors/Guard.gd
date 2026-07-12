extends Node2D
## Immortal town gate-guard — Decision Log #39: penjaga tidak lagi mendorong.
## Monster yang mendekati pagar/batas kota DIDATANGI dan DIBUNUH SATU PUKULAN
## (animasi serang + juice normal). Pemain TIDAK mendapat apa pun dari kill ini
## (guard_kill: nol EXP/drop/counter). Multi-monster ditangani satu per satu.
## Penjaga tetap abadi.

const ALERT_RADIUS := 96.0    # monster sedekat ini dari pos = ancaman
const MOVE_SPEED := 150.0
const STRIKE_RANGE := 20.0
const STRIKE_WINDUP := 0.18   # jeda kecil biar ayunannya terlihat
const STRIKE_CD := 0.5

var _cd := 0.0
var _striking := false
var _home := Vector2.ZERO
var _sprite: Sprite2D
var _label: Label

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("guards")
	_build()
	_home = global_position

func _build() -> void:
	_sprite = Sprite2D.new()
	var at := AtlasTexture.new()
	at.atlas = load("res://assets/game/sprites/player/idle.png")
	at.region = Rect2(0, 0, 16, 16)
	_sprite.texture = at
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(1.7, 1.7)
	_sprite.modulate = Color(0.72, 0.82, 1.05)   # steel-blue sentinel
	add_child(_sprite)

	_label = Label.new()
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_label.add_theme_font_override("font", load("res://assets/game/fonts/m5x7.ttf"))
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_label.add_theme_constant_override("outline_size", 4)
	_label.text = "Penjaga Gerbang [E]"
	_label.position = Vector2(-44, -34)
	_label.visible = false
	add_child(_label)

func _process(delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p and _label:
		_label.visible = global_position.distance_to(p.global_position) < 72.0
	_cd -= delta
	if _striking or _cd > 0.0:
		return
	# ancaman terdekat dari POS penjaga (satu per satu; yang lain menunggu giliran)
	var target: Node2D = null
	var best := ALERT_RADIUS
	for m in get_tree().get_nodes_in_group("monsters"):
		if not is_instance_valid(m) or not m.has_method("guard_kill"):
			continue
		if ("inst" in m) and m.inst.get("is_boss", false):
			continue   # bos bukan urusan penjaga gerbang
		var d: float = _home.distance_to(m.global_position)
		if d < best:
			best = d
			target = m
	if target == null:
		# kembali ke pos jaga
		if global_position.distance_to(_home) > 3.0:
			global_position = global_position.move_toward(_home, MOVE_SPEED * 0.7 * delta)
		return
	# datangi ancaman, lalu bunuh SATU PUKULAN dengan telegraf ayunan singkat
	if global_position.distance_to(target.global_position) > STRIKE_RANGE:
		global_position = global_position.move_toward(target.global_position, MOVE_SPEED * delta)
		return
	_strike(target)

func _strike(target: Node2D) -> void:
	_striking = true
	_cd = STRIKE_CD
	# wind-up kecil supaya ayunan terbaca, lalu eksekusi
	var tw := create_tween()
	tw.tween_property(_sprite, "rotation", -0.35, STRIKE_WINDUP * 0.6)
	tw.tween_property(_sprite, "rotation", 0.25, STRIKE_WINDUP * 0.4)
	tw.tween_callback(func():
		_sprite.rotation = 0.0
		_striking = false
		if not is_instance_valid(target):
			return
		var aim := (target.global_position - global_position)
		aim = aim.normalized() if aim.length() > 1.0 else Vector2.RIGHT
		Vfx.swing(get_parent(), global_position, aim, "none", "sword", 26.0, 100.0)
		Vfx.impact(get_parent(), target.global_position, "none", true)
		Audio.play_sfx("hit", 0.9)
		target.guard_kill())   # SATU PUKULAN — pemain nol reward (Decision Log #39)

func interact() -> void:
	if Stage.is_busy():
		return
	await Stage.say([
		"Selama aku berjaga, tak ada monster yang berani masuk kota.",
		"Beristirahatlah dengan tenang, petualang."],
		"Penjaga Gerbang", _sprite.texture)
