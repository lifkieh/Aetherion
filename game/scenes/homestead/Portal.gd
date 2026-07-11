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
	get_tree().paused = false
	Stage.go_to_scene(target_scene)
