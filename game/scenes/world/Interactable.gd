extends Node2D
## World interactable (M5): crafting bench or shop NPC. Press E nearby.

var kind := "bench"   # bench | shop

@onready var sprite: Sprite2D = $Sprite
@onready var label: Label = $Label

func setup(k: String) -> void:
	kind = k
	if is_inside_tree():
		_build()

func _ready() -> void:
	add_to_group("interactable")
	_build()

func _build() -> void:
	if kind == "shop":
		# NPC placeholder: player base sprite, first frame, tinted.
		var at := AtlasTexture.new()
		at.atlas = load("res://assets/game/sprites/player/idle.png")
		at.region = Rect2(0, 0, 16, 16)
		sprite.texture = at
		sprite.scale = Vector2(1.4, 1.4)
		sprite.modulate = Color(1.0, 0.9, 0.6)
		label.text = "Pedagang [E]"
	else:
		sprite.texture = load("res://assets/game/sprites/props/rock.png")
		sprite.scale = Vector2(1.8, 1.4)
		sprite.modulate = Color(0.7, 0.5, 0.35)
		label.text = "Bengkel [E]"

func interact() -> void:
	var menu := get_tree().get_first_node_in_group("inventory_ui")
	if menu == null:
		return
	if kind == "shop":
		menu.open("shop", self)
	else:
		menu.open("crafting", self)
