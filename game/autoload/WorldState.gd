extends Node
## WorldState — weather + hidden world counters (Fase0 §6, §2).
## Counters (rabbits_killed, trees_cut...) are raised silently from EventBus.

var weather: String = "sunny"          # sunny/rain/thunderstorm/blizzard/blood_moon
var pending_return_pos = null           # Vector2 set by a dungeon door; consumed on overworld re-entry
var pending_interior := "house"         # interior variant to build on HouseInterior entry (R2 town)
var counters: Dictionary = {}          # key -> int
var node_states: Dictionary = {}       # gathering node id -> {harvested_at:unix}
var visited_regions: Array = []        # wilayah yang pernah dikunjungi (Gerbang Penjelajah, #43)
var current_region := "greenvale"
var last_free_travel := ""             # tanggal WIB travel gratis harian terakhir dipakai
var auction: Dictionary = {}           # Rumah Lelang: lot hari ini (v0.4.2, B8 #53)
var freed_captives: Array = []         # tawanan yang dibebaskan -> kandidat rekrut loyal (v0.6)
var miracle_log: Dictionary = {}       # {date, today, yesterday} — keajaiban (E7 #79)
var greenhouse := false                # Rumah Kaca dibeli: musim tak membatasi tanam (A4 #83)
var chests_opened: Dictionary = {}     # chest_id -> tanggal WIB terakhir dibuka (v0.4.3 #85)
var secrets_found: Array = []          # peti rahasia yang PERNAH ditemukan (permanen)
var spirit_state := "none"             # none | angry | blessed (Roh Hutan, #95)
var chronicle: Array = []              # Pencapaian Tercatat (benih Chronicle, #96)
var town_talk: Dictionary = {}         # apa yang sedang dibicarakan warga
var npc_profiles: Dictionary = {}      # npc_id -> profil kepribadian 5 lapis (#136-#138)
var dark_event: Dictionary = {}        # keajaiban GELAP yang sedang berlangsung (#145)

## Tandai wilayah dikunjungi (dipanggil _ready tiap region scene). #43
func mark_visited(region_id: String) -> void:
	current_region = region_id
	if not (region_id in visited_regions):
		visited_regions.append(region_id)
		if visited_regions.size() > 1:
			EventBus.toast.emit("🗺 Wilayah baru tercatat: gerbang penjelajah kini mengenalnya.")
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

# --- Prakiraan cuaca Astrolog (Audit B / v0.4.3 #91) -------------------------
# Langit punya RENCANA harian yang deterministik (seed = tanggal WIB + jam). Rol
# cuaca sungguhan mengikuti rencana itu 80% waktu — jadi prakiraan Astrolog benar
# ~80%, persis seperti yang dijanjikan GDD. 20% sisanya: langit berubah pikiran.
const FORECAST_ACCURACY := 0.8

func planned_weather(date: String, hour: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("weather:" + date + ":" + str(hour / 3))   # blok 3 jam
	var night: bool = hour >= 19 or hour < 6
	var r := rng.randf()
	if night:
		if r < 0.65: return "sunny"
		elif r < 0.85: return "rain"
		return "thunderstorm"
	if r < 0.60: return "sunny"
	elif r < 0.85: return "rain"
	return "thunderstorm"

## Prakiraan N jam ke depan: [{hour, weather, label}] — dipakai Astrolog.
func forecast(hours: int = 24) -> Array:
	var out: Array = []
	var now := GameClock.now_wib()
	var h: int = now.hour
	for i in range(hours):
		var hh: int = (h + i) % 24
		var date: String = GameClock.date_string()
		var w: String = planned_weather(date, hh)
		out.append({"hour": hh, "weather": w, "label": _weather_label(w)})
	return out

func _roll_weather(initial: bool) -> void:
	# Blood Moon during real full-moon night; else weighted normal weather.
	if GameClock.is_full_moon() and GameClock.is_night():
		set_weather("blood_moon")
		return
	# 80% ikuti RENCANA langit (yang dibaca Astrolog); 20% langit berubah pikiran
	if randf() < FORECAST_ACCURACY:
		var planned := planned_weather(GameClock.date_string(), GameClock.wib_hour())
		if initial:
			weather = planned
			EventBus.weather_changed.emit(planned)
		else:
			set_weather(planned)
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
		"visited_regions": visited_regions,
		"last_free_travel": last_free_travel,
		"auction": auction,
		"freed_captives": freed_captives,
		"miracle_log": miracle_log,
		"greenhouse": greenhouse,
		"chests_opened": chests_opened,
		"secrets_found": secrets_found,
		"spirit_state": spirit_state,
		"chronicle": chronicle,
		"town_talk": town_talk,
		"npc_profiles": npc_profiles,
		"dark_event": dark_event,
	}

func from_save(d: Dictionary) -> void:
	weather = d.get("weather", "sunny")
	counters = d.get("counters", {})
	node_states = d.get("node_states", {})
	visited_regions = d.get("visited_regions", [])
	last_free_travel = d.get("last_free_travel", "")
	auction = d.get("auction", {})
	freed_captives = d.get("freed_captives", [])
	miracle_log = d.get("miracle_log", {})
	greenhouse = bool(d.get("greenhouse", false))
	chests_opened = d.get("chests_opened", {})
	secrets_found = d.get("secrets_found", [])
	spirit_state = d.get("spirit_state", "none")
	chronicle = d.get("chronicle", [])
	town_talk = d.get("town_talk", {})
	npc_profiles = d.get("npc_profiles", {})
	dark_event = d.get("dark_event", {})

func new_game() -> void:
	counters = {}
	node_states = {}
	visited_regions = []
	last_free_travel = ""
	auction = {}
	freed_captives = []
	miracle_log = {}
	greenhouse = false
	chests_opened = {}
	secrets_found = []
	spirit_state = "none"
	chronicle = []
	town_talk = {}
	npc_profiles = {}
	dark_event = {}
	_roll_weather(true)
