extends Node
## WorldController — routes world input (gather / tame / save / interact).
## Kept out of Player so it can query the whole scene for nearby targets.

const TAME_RANGE := 40.0
const GATHER_RANGE := 30.0
const INTERACT_RANGE := 44.0

var player: Node2D

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if Input.is_action_just_pressed("pause_menu"):
		# ESC cancels an active prime first (FF-2c); a second ESC opens the pause menu
		if player and "hotbar" in player and player.hotbar.is_primed():
			player.hotbar.cancel_all()
			return
		# pause menu layak (v0.4.1) — overlay khusus, bukan tab tas
		var pm := load("res://scenes/ui/PauseMenu.gd")
		pm.open_over(get_tree())
	elif Input.is_action_just_pressed("save_game"):
		SaveManager.save_game(SaveManager.current_slot)
	elif Input.is_action_just_pressed("tame"):
		_try_tame()
	elif Input.is_action_just_pressed("world_map"):
		load("res://scenes/ui/WorldMapUI.gd").open_over(get_tree())
	elif Input.is_action_just_pressed("interact"):
		_try_interact()
	elif Input.is_action_just_pressed("toggle_inventory"):
		_toggle_inventory()
	elif Input.is_action_just_pressed("mount"):
		_toggle_mount()

func _nearest_in_group(group: String, max_dist: float, predicate := Callable()) -> Node2D:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return null
	var best: Node2D = null
	var best_d := max_dist
	for n in get_tree().get_nodes_in_group(group):
		if not is_instance_valid(n):
			continue
		if predicate.is_valid() and not predicate.call(n):
			continue
		var d: float = n.global_position.distance_to(player.global_position)
		if d <= best_d:
			best_d = d
			best = n
	return best

func _try_tame() -> void:
	var m := _nearest_in_group("monsters", TAME_RANGE, func(n): return n.has_method("can_be_tamed") and n.can_be_tamed())
	if m:
		m.attempt_tame()
	else:
		EventBus.toast.emit("Tidak ada monster lemah (HP<5%) di dekatmu untuk dijinakkan.")

func _try_interact() -> void:
	# priority: gather node, then NPC/shop/bench (M5)
	var g := _nearest_in_group("gather", GATHER_RANGE, func(n): return n.has_method("can_harvest") and n.can_harvest())
	if g:
		g.harvest()
		return
	var i := _nearest_in_group("interactable", INTERACT_RANGE)
	if i and i.has_method("interact"):
		i.interact()
		return
	EventBus.toast.emit("Tidak ada yang bisa diinteraksi di sini.")

func _toggle_inventory() -> void:
	var ui := get_tree().get_first_node_in_group("inventory_ui")
	if ui and ui.has_method("toggle"):
		ui.toggle()
	else:
		EventBus.toast.emit("Tas: " + _inventory_summary())

func _inventory_summary() -> String:
	if PlayerData.inventory.is_empty():
		return "kosong"
	var parts := []
	for id in PlayerData.inventory.keys():
		parts.append("%s x%d" % [Db.item_name(id), PlayerData.inventory[id]])
	return ", ".join(parts)

func _toggle_mount() -> void:
	if PlayerData.active_pet_index < 0 or PlayerData.active_pet_index >= PlayerData.monsters.size():
		EventBus.toast.emit("Belum ada pet untuk ditunggangi.")
		return
	var pet: Dictionary = PlayerData.monsters[PlayerData.active_pet_index]
	if not pet.get("rideable", false):
		EventBus.toast.emit("%s terlalu kecil untuk ditunggangi." % pet.get("name", "Pet"))
		return
	PlayerData.mounted = not PlayerData.mounted
	EventBus.toast.emit(("Menunggangi " if PlayerData.mounted else "Turun dari ") + pet.get("name", "pet"))
