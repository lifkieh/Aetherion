extends Node2D
## Homestead plot (M6). Plant a seed -> grows in real WIB time (offline too) ->
## harvest. State persists in PlayerData.homestead_plots[index].

var index := 0
@onready var soil: ColorRect = $Soil
@onready var plant: Sprite2D = $Plant
@onready var label: Label = $Label

func setup(i: int) -> void:
	index = i

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("plots")
	plant.texture = load("res://assets/game/sprites/props/grass.png")
	plant.offset = Vector2(0, -6)
	_refresh()

func _process(_delta: float) -> void:
	if Engine.get_process_frames() % 20 == 0:
		_refresh()

func _plot() -> Dictionary:
	if index < PlayerData.homestead_plots.size():
		return PlayerData.homestead_plots[index]
	return {}

func _refresh() -> void:
	var p := _plot()
	if p.is_empty() or not p.has("crop_id"):
		plant.visible = false
		label.text = "Tanam [E]"
		return
	var st := HomesteadSystem.plot_status(p)
	plant.visible = true
	var crop: Dictionary = st.get("crop", {})
	var frac := float(st.stage) / float(max(1, st.stages))
	plant.scale = Vector2(0.5 + frac * 1.1, 0.5 + frac * 1.1)
	plant.modulate = Color(0.55, 0.8, 0.45).lerp(Color(0.5, 1.0, 0.4), frac)
	if st.ready:
		plant.modulate = Color(1.0, 0.95, 0.4)
		label.text = "Panen %s [E]" % crop.get("name", "")
	else:
		label.text = "%s %d/%d" % [crop.get("name", ""), st.stage, st.stages]

func interact() -> void:
	var p := _plot()
	if p.is_empty() or not p.has("crop_id"):
		_plant()
	else:
		var st := HomesteadSystem.plot_status(p)
		if st.ready:
			_harvest(st)
		else:
			EventBus.toast.emit("Masih tumbuh: %d/%d" % [st.stage, st.stages])

func _plant() -> void:
	# prefer mintleaf seed, else sunbud
	var seed_id := ""
	var crop_id := ""
	for pair in [["seed_mintleaf", "mintleaf"], ["seed_sunbud", "sunbud"]]:
		if PlayerData.item_count(pair[0]) > 0:
			seed_id = pair[0]; crop_id = pair[1]; break
	if seed_id == "":
		EventBus.toast.emit("Tidak punya benih. Beli di toko!")
		return
	PlayerData.remove_item(seed_id, 1)
	while PlayerData.homestead_plots.size() <= index:
		PlayerData.homestead_plots.append({})
	PlayerData.homestead_plots[index] = {"crop_id": crop_id, "planted_at_unix": GameClock.unix_now()}
	EventBus.crop_planted.emit(index, crop_id)
	EventBus.toast.emit("Menanam %s" % Db.crop(crop_id).get("name", crop_id))
	Audio.play_sfx("dodge")
	_refresh()

func _harvest(st: Dictionary) -> void:
	var p := _plot()
	var crop: Dictionary = Db.crop(p.get("crop_id", ""))
	var qty := randi_range(int(crop.get("yield_min", 1)), int(crop.get("yield_max", 2)))
	var product: String = crop.get("product", "")
	PlayerData.add_item(product, qty)
	EventBus.crop_harvested.emit(index, p.get("crop_id", ""), qty)
	EventBus.toast.emit("Panen %s x%d!" % [Db.item_name(product), qty])
	Audio.play_sfx("success")
	PlayerData.homestead_plots[index] = {}
	_refresh()
