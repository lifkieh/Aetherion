extends Node
## PetManager (M4) — keeps the active pet spawned beside the player.
## Re-spawns when the active pet changes; frees when there is none.

var _pet_node: Pet = null
var _current: Dictionary = {}

func _ready() -> void:
	EventBus.pet_added.connect(func(_p): _sync())
	await get_tree().process_frame
	await get_tree().process_frame
	_sync()

func _process(_delta: float) -> void:
	# cheap poll so party swaps / loads reflect without extra signals
	if Engine.get_process_frames() % 30 == 0:
		_sync()

func _sync() -> void:
	var active := _active_pet()
	if active.is_empty():
		if _pet_node and is_instance_valid(_pet_node):
			_pet_node.queue_free()
			_pet_node = null
			_current = {}
		return
	if _pet_node == null or not is_instance_valid(_pet_node) or active != _current:
		_spawn(active)

func _spawn(pet_data: Dictionary) -> void:
	if _pet_node and is_instance_valid(_pet_node):
		_pet_node.queue_free()
	var player := get_tree().get_first_node_in_group("player")
	_pet_node = preload("res://scenes/actors/Pet.tscn").instantiate()
	get_parent().add_child(_pet_node)
	_pet_node.setup(pet_data)
	if player:
		_pet_node.global_position = player.global_position + Vector2(-20, 8)
	_current = pet_data

func _active_pet() -> Dictionary:
	var idx := PlayerData.active_pet_index
	if idx >= 0 and idx < PlayerData.monsters.size():
		return PlayerData.monsters[idx]
	return {}
