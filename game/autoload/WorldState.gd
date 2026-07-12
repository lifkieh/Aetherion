extends Node
## WorldState — weather + hidden world counters (Fase0 §6, §2).
## Counters (rabbits_killed, trees_cut...) are raised silently from EventBus.

var weather: String = "sunny"          # sunny/rain/thunderstorm/blizzard/blood_moon
var pending_return_pos = null           # Vector2 set by a dungeon door; consumed on overworld re-entry
var pending_interior := "house"         # interior variant to build on HouseInterior entry (R2 town)
var counters: Dictionary = {}          # key -> int
var node_states: Dictionary = {}       # gathering node id -> {harvested_at:unix}
var _weather_timer := 0.0
var _weather_interval := 90.0          # seconds between weather rolls (demo-friendly)

# Weather that makes targets Wet (science demo)
const WET_WEATHER := ["rain", "thunderstorm"]

func _ready() -> void:
	EventBus.monster_killed.connect(_on_monster_killed)
	EventBus.node_harvested.connect(_on_node_harvested)
	_roll_weather(true)

func _process(delta: float) -> void:
	_weather_timer += delta
	if _weather_timer >= _weather_interval:
		_weather_timer = 0.0
		_roll_weather(false)

# --- Counters ---------------------------------------------------------------

func get_counter(key: String) -> int:
	return counters.get(key, 0)

func add_counter(key: String, amount: int = 1) -> void:
	counters[key] = counters.get(key, 0) + amount
	EventBus.counter_changed.emit(key, counters[key])

func set_counter(key: String, value: int) -> void:
	counters[key] = value
	EventBus.counter_changed.emit(key, value)

# --- Weather ----------------------------------------------------------------

func is_wet_weather() -> bool:
	return weather in WET_WEATHER

func set_weather(w: String) -> void:
	if w == weather:
		return
	weather = w
	EventBus.weather_changed.emit(w)
	EventBus.toast.emit("Cuaca berubah: " + _weather_label(w))

func force_weather(w: String) -> void:
	# Manual override (debug / scenario) — also resets the roll timer.
	_weather_timer = 0.0
	set_weather(w)

func _roll_weather(initial: bool) -> void:
	# Blood Moon during real full-moon night; else weighted normal weather.
	if GameClock.is_full_moon() and GameClock.is_night():
		set_weather("blood_moon")
		return
	var r := randf()
	var w := "sunny"
	if GameClock.is_night():
		# BLOOD MOON acak jarang di malam biasa (v0.4.1): spawn agresif + drop x2 +
		# langit merah + gerbang evolusi/scenario. ~6% per rol malam.
		if not initial and r < 0.06:
			set_weather("blood_moon")
			EventBus.toast.emit("🌕 BULAN DARAH terbit... malam ini dunia haus.")
			return
		# nights lean clearer for star navigation
		if r < 0.65: w = "sunny"
		elif r < 0.85: w = "rain"
		else: w = "thunderstorm"
	else:
		if r < 0.60: w = "sunny"
		elif r < 0.85: w = "rain"
		else: w = "thunderstorm"
	if initial:
		weather = w  # set silently on boot
		EventBus.weather_changed.emit(w)
	else:
		set_weather(w)

func _weather_label(w: String) -> String:
	return {
		"sunny": "Cerah",
		"rain": "Hujan",
		"thunderstorm": "Badai Petir",
		"blizzard": "Badai Salju",
		"blood_moon": "Bulan Darah",
	}.get(w, w)

# --- Gathering node respawn -------------------------------------------------

func mark_node_harvested(node_id: String) -> void:
	node_states[node_id] = {"harvested_at": GameClock.unix_now()}

func node_ready(node_id: String, respawn_seconds: int) -> bool:
	if not node_states.has(node_id):
		return true
	var t: int = node_states[node_id].get("harvested_at", 0)
	return GameClock.unix_now() - t >= respawn_seconds

# --- Signal handlers --------------------------------------------------------

func _on_monster_killed(species_id: String, _monster) -> void:
	add_counter("monsters_killed")
	var def := Db.monster(species_id)
	# Hidden rabbit counter — the sacred Warren trigger. No UI. (Fase0 §6)
	if def.get("is_rabbit", false) or species_id == "fluffbit":
		add_counter("rabbits_killed")

func _on_node_harvested(node_type: String, _item_id: String, _qty: int) -> void:
	if node_type == "tree":
		add_counter("trees_cut")
	elif node_type == "ore":
		add_counter("ore_mined")

# --- Save / load ------------------------------------------------------------

func to_save() -> Dictionary:
	return {
		"weather": weather,
		"counters": counters,
		"node_states": node_states,
	}

func from_save(d: Dictionary) -> void:
	weather = d.get("weather", "sunny")
	counters = d.get("counters", {})
	node_states = d.get("node_states", {})

func new_game() -> void:
	counters = {}
	node_states = {}
	_roll_weather(true)
