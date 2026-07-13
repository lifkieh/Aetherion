extends Node
## QuestSystem (MARKET_STUDY A) — Daily Quest Board.
## 3 quests rolled deterministically from the real WIB date, some gated by
## today's weather/moon. Progress tracked via EventBus; rewards on claim.
## Resets each WIB day. Persisted in PlayerData.daily_quests.

const DAILY_COUNT := 3

func _ready() -> void:
	EventBus.monster_killed.connect(_on_kill)
	EventBus.node_harvested.connect(_on_gather)
	EventBus.item_crafted.connect(_on_craft)
	EventBus.pet_added.connect(_on_tame)
	EventBus.hour_passed.connect(func(_h): ensure_today())
	call_deferred("ensure_today")

# --- Daily roll -------------------------------------------------------------

func ensure_today() -> void:
	var today := GameClock.date_string()
	if PlayerData.daily_quests.get("date", "") == today and PlayerData.daily_quests.has("quests"):
		return
	_roll(today)

func _date_seed(date: String) -> int:
	var s := 0
	for i in range(date.length()):
		s = (s * 31 + date.unicode_at(i)) % 2147483647
	return s

func _roll(date: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = _date_seed(date)
	# eligible pool: skip sky-gated quests whose condition isn't active today
	var pool: Array = []
	for q in Db.quests:
		var cond: String = q.get("condition", "")
		if cond == "full_moon" and not GameClock.is_full_moon():
			continue
		pool.append(q)
	# deterministic shuffle by sorting on a per-id hash
	pool.sort_custom(func(a, b): return _q_hash(a, rng.seed) < _q_hash(b, rng.seed))
	var picked: Array = []
	for i in range(min(DAILY_COUNT, pool.size())):
		var q: Dictionary = pool[i]
		picked.append({
			"id": q.id, "name": q.get("name", q.id), "desc": q.get("desc", ""),
			"type": q.type, "target": q.get("target", "any"), "count": int(q.count),
			"condition": q.get("condition", ""), "progress": 0, "done": false, "claimed": false,
			"reward_gold": int(q.get("reward_gold", 0)),
			"reward_item": q.get("reward_item", ""), "reward_qty": int(q.get("reward_qty", 1)),
		})
	PlayerData.daily_quests = {"date": date, "quests": picked}
	EventBus.toast.emit("📋 Papan Quest harian diperbarui (%d misi)." % picked.size())

func _q_hash(q: Dictionary, seed: int) -> int:
	var s := seed
	var id: String = q.get("id", "")
	for i in range(id.length()):
		s = (s * 131 + id.unicode_at(i)) % 2147483647
	return s

func quests() -> Array:
	return PlayerData.daily_quests.get("quests", [])

# --- Pelacakan (Jurnal, v0.4.3 #84) -----------------------------------------

## Quest yang sedang dilacak ({} bila tak ada / sudah diklaim).
func tracked() -> Dictionary:
	var id: String = PlayerData.daily_quests.get("tracked", "")
	if id == "":
		return {}
	for q in quests():
		if q.id == id and not q.claimed:
			return q
	return {}

func track(quest_id: String) -> void:
	if PlayerData.daily_quests.get("tracked", "") == quest_id:
		PlayerData.daily_quests["tracked"] = ""      # klik lagi = berhenti melacak
		return
	PlayerData.daily_quests["tracked"] = quest_id
	for q in quests():
		if q.id == quest_id:
			EventBus.toast.emit(Loc.t("quest.tracking", [q.name]))
			return

## Petunjuk sasaran quest yang dilacak untuk penanda arah HUD:
## {kind: "monster"/"gather"/"", target: id}
func tracked_target() -> Dictionary:
	var q := tracked()
	if q.is_empty() or q.get("done", false):
		return {}
	match q.get("type", ""):
		"kill": return {"kind": "monster", "target": q.get("target", "any")}
		"gather": return {"kind": "gather", "target": q.get("target", "any")}
		_: return {}

# --- Progress ---------------------------------------------------------------

func _cond_ok(q: Dictionary) -> bool:
	match q.get("condition", ""):
		"rain": return WorldState.is_wet_weather()
		"full_moon": return GameClock.is_full_moon()
		_: return true

func _advance(type: String, target: String) -> void:
	var changed := false
	for q in quests():
		if q.done or q.type != type:
			continue
		if q.target != "any" and q.target != target:
			continue
		if not _cond_ok(q):
			continue
		q.progress += 1
		if q.progress >= q.count:
			q.progress = q.count
			q.done = true
			EventBus.toast.emit(Loc.t("quest.done", [q.name]))
			Audio.play_stinger("quest")
		changed = true
	if changed:
		EventBus.counter_changed.emit("quest_progress", 0)  # nudge UI refresh

func _on_kill(species: String, _m) -> void:
	_advance("kill", species)

func _on_gather(kind: String, _item: String, _qty: int) -> void:
	_advance("gather", kind)

func _on_craft(_item: String, success: bool) -> void:
	if success:
		_advance("craft", "any")

func _on_tame(_pet: Dictionary) -> void:
	_advance("tame", "any")

# --- Claim ------------------------------------------------------------------

func claim(quest_id: String) -> bool:
	for q in quests():
		if q.id == quest_id and q.done and not q.claimed:
			q.claimed = true
			if q.reward_gold > 0:
				PlayerData.add_gold(q.reward_gold)
			if q.reward_item != "":
				PlayerData.add_item(q.reward_item, q.reward_qty)
			EventBus.toast.emit("🎁 Hadiah quest: %dG + %s" % [q.reward_gold, Db.item_name(q.reward_item)])
			return true
	return false
