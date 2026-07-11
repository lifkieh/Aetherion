extends Node2D
## Portal (M6) — travel between Greenvale and the Homestead instance.

@export var target_scene := "res://scenes/homestead/Homestead.tscn"
var label_text := "Rumah [E]"

@onready var sprite: Sprite2D = $Sprite
@onready var label: Label = $Label

func setup(target: String, text: String) -> void:
	target_scene = target
	label_text = text
	if is_inside_tree():
		label.text = label_text

func _ready() -> void:
	add_to_group("interactable")
	label.text = label_text
	sprite.texture = load("res://assets/game/sprites/props/rock.png")
	sprite.scale = Vector2(2.0, 2.4)
	sprite.modulate = Color(0.5, 0.4, 0.7)

func interact() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(target_scene)
