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
	if kind == "pond":
		sprite.texture = load("res://assets/game/tiles/pond.png")
		sprite.scale = Vector2(1.6, 1.6)
		label.text = "Memancing [E]"
	elif kind == "board":
		sprite.texture = load("res://assets/game/sprites/props/branch.png")
		sprite.scale = Vector2(2.2, 2.6)
		sprite.modulate = Color(0.75, 0.6, 0.4)
		label.text = "Papan Quest [E]"
	elif kind == "inn":
		sprite.texture = load("res://assets/game/sprites/props/rock.png")
		sprite.scale = Vector2(2.4, 2.0)
		sprite.modulate = Color(0.55, 0.45, 0.75)
		label.text = "Penginapan — Tidur [E]"
	elif kind == "shop":
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
	if kind == "inn":
		_sleep()
		return
	if kind == "pond":
		_fish()
		return
	var menu := get_tree().get_first_node_in_group("inventory_ui")
	if menu == null:
		return
	if kind == "shop":
		menu.open("shop", self)
	elif kind == "board":
		menu.open("quest", self)
	else:
		menu.open("crafting", self)

func _fish() -> void:
	# Consume a Star Bait if held (unlocks star fish / Star Whale hook), else bare hook.
	var bait := ""
	if PlayerData.item_count("star_bait") > 0:
		bait = "star_bait"
		PlayerData.remove_item("star_bait", 1)
	FishingUI.open(bait)

func _sleep() -> void:
	# Sleeping is the trigger_action for the Moon Rabbit Warren (Fase0 §6).
	if ScenarioManager.try_trigger("sleep_at_inn"):
		return
	PlayerData.respawn()
	EventBus.toast.emit("Kamu tidur nyenyak. HP & MP pulih.")
	Audio.play_sfx("success")
