extends Node
## Achievements + Aetherpedia (post-M8 retention, MARKET_STUDY B & C).
## Pure EventBus hooks over counters/discovery already emitted by the game.

func _ready() -> void:
	EventBus.counter_changed.connect(_on_counter)
	EventBus.monster_spawned.connect(_on_monster_seen)
	EventBus.monster_killed.connect(func(sp, _m): _discover("monsters", sp))
	EventBus.item_gained.connect(func(id, _q): _discover("items", id))
	EventBus.weather_changed.connect(func(w): _discover("weathers", w))
	EventBus.full_moon_began.connect(func(): EvolutionSystem.check_party())
	EventBus.pet_added.connect(func(_p): EvolutionSystem.check_party())   # level-based evo (e.g. Dire Wolf)
	EventBus.weather_changed.connect(func(w): if w == "blood_moon": EvolutionSystem.check_party())   # gerbang Bulan Darah (v0.4.1)

# --- Achievements -----------------------------------------------------------

func _on_counter(key: String, value: int) -> void:
	for a in Db.achievements:
		if a.get("counter", "") != key:
			continue
		var id: String = a.get("id", "")
		if id in PlayerData.achievements:
			continue
		if value >= int(a.get("threshold", 999999)):
			_unlock(a)

func _unlock(a: Dictionary) -> void:
	var id: String = a.get("id", "")
	PlayerData.achievements.append(id)
	var title: String = a.get("title", "")
	if title != "" and not (title in PlayerData.titles):
		PlayerData.titles.append(title)
	if PlayerData.active_title == "" and title != "":
		PlayerData.active_title = title
	EventBus.achievement_unlocked.emit(id, a.get("name", ""), title)
	EventBus.toast.emit("🏆 Pencapaian: %s — gelar \"%s\"" % [a.get("name", ""), title])
	Audio.play_sfx("success")

## Sum of a buff value across unlocked achievements whose title is equipped.
func active_buff(key: String) -> float:
	var total := 0.0
	for a in Db.achievements:
		if a.get("id", "") in PlayerData.achievements and a.get("title", "") == PlayerData.active_title:
			total += float(a.get("buff", {}).get(key, 0.0))
	return total

# --- Aetherpedia (codex) ----------------------------------------------------

func _on_monster_seen(m) -> void:
	if m and is_instance_valid(m) and m.inst:
		_discover("monsters", m.inst.get("species_id", ""))

func _discover(kind: String, id: String) -> void:
	if id == "":
		return
	if not PlayerData.discovered.has(kind):
		PlayerData.discovered[kind] = {}
	var bucket: Dictionary = PlayerData.discovered[kind]
	var first := not bucket.has(id)
	bucket[id] = int(bucket.get(id, 0)) + 1
	if first:
		EventBus.codex_discovered.emit(kind, id)
		if kind == "monsters":
			EventBus.toast.emit("📖 Aetherpedia: %s tercatat" % Db.monster(id).get("name", id))

func total_monsters() -> int:
	return Db.monsters.size()

func discovered_count(kind: String) -> int:
	return PlayerData.discovered.get(kind, {}).size()
