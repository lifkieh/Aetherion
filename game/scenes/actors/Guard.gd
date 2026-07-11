extends Node2D
## Immortal town gate-guard (owner UI/UX §4). Stands at a safe-zone gate and shoves
## any monster that strays too close back out of town. Cannot be harmed or die —
## it is pure defense so newcomers always feel safe inside the walls.

const GUARD_RADIUS := 66.0
const REPEL_CD := 0.5

var _cd := 0.0
var _sprite: Sprite2D
var _label: Label

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("guards")
	_build()

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
	if _cd > 0.0:
		return
	for m in get_tree().get_nodes_in_group("monsters"):
		if not is_instance_valid(m):
			continue
		if global_position.distance_to(m.global_position) < GUARD_RADIUS and m.has_method("knockback"):
			# Always shove OUTWARD (away from town), never toward the center — a guard
			# standing on the inner edge must not knock an escaping monster back in.
			var outward: Vector2 = SafeZone.escape_vector(m.global_position) if SafeZone.is_active() \
				else (m.global_position - global_position).normalized()
			m.knockback(m.global_position - outward * 10.0, 360.0)
			_cd = REPEL_CD
			Audio.play_sfx("dodge")
			Vfx.spark(get_parent(), m.global_position, "wind")
			break   # one decisive shove per cooldown

func interact() -> void:
	if Stage.is_busy():
		return
	await Stage.say([
		"Selama aku berjaga, tak ada monster yang berani masuk kota.",
		"Beristirahatlah dengan tenang, petualang."],
		"Penjaga Gerbang", _sprite.texture)
