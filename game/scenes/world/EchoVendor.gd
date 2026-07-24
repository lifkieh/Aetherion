extends Node2D
## Echo Vendor (GDD v0.2 §10.6) — a static "ghost" of another player that makes
## the offline hub feel lived-in. Interact to browse their kiosk (fixed prices).

var data: Dictionary = {}

@onready var sprite: Sprite2D = $Sprite
@onready var label: Label = $Label

func setup(d: Dictionary) -> void:
	data = d
	if is_inside_tree():
		_build()

func _ready() -> void:
	add_to_group("interactable")
	if not data.is_empty():
		_build()

## OPT-IN LPC (#286): kosong = ikon 16px lama (wilayah 16px lain tak berubah).
## Diisi id sheet warga = gema tampil sebagai sosok LPC 64 transparan.
var lpc_sheet := ""

func _build() -> void:
	if lpc_sheet != "" and ResourceLoader.exists(
			"res://assets/game/sprites/characters/%s_idle.png" % lpc_sheet):
		var ai := AtlasTexture.new()
		ai.atlas = load("res://assets/game/sprites/characters/%s_idle.png" % lpc_sheet)
		ai.region = Rect2(0, 2 * 64, 64, 64)   # baris 2 = hadap bawah
		sprite.texture = ai
		sprite.scale = Vector2(1, 1)
		sprite.offset = Vector2(0, -20)
	else:
		var at := AtlasTexture.new()
		at.atlas = load("res://assets/game/sprites/player/idle.png")
		at.region = Rect2(0, 0, 16, 16)
		sprite.texture = at
		sprite.scale = Vector2(1.4, 1.4)
	var tint: String = data.get("tint", "ffffff")
	sprite.modulate = Color(tint)
	sprite.modulate.a = 0.75   # ghostly
	label.text = "%s [E]" % data.get("name", "Gema")
	# gentle bobbing so it reads as a spectral echo
	var tw := create_tween().set_loops()
	tw.tween_property(sprite, "position:y", -3.0, 1.2).as_relative().set_trans(Tween.TRANS_SINE)
	tw.tween_property(sprite, "position:y", 3.0, 1.2).as_relative().set_trans(Tween.TRANS_SINE)

var _lbl_cd := 0.0

func _process(delta: float) -> void:
	_lbl_cd -= delta
	if _lbl_cd > 0.0:
		return
	_lbl_cd = 0.15
	var p := get_tree().get_first_node_in_group("player")
	if p and label:
		label.visible = global_position.distance_to(p.global_position) < 80.0

func interact() -> void:
	var menu := get_tree().get_first_node_in_group("inventory_ui")
	if menu and menu.has_method("open"):
		menu.open("echo", data)
