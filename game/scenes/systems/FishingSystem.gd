class_name FishingSystem
extends RefCounted
## Fishing catch logic (MARKET_STUDY E). Which fish are available depends on the
## real WIB hour, the lunar tide, the full moon, and the equipped bait — so the
## sky/time pillar drives what you can catch. UI-free & testable.

## Tide band from GameClock.tide_level(): "high" (spring tide), "low", or "mid".
static func tide_band(tide: float) -> String:
	if tide > 0.3:
		return "high"
	if tide < -0.3:
		return "low"
	return "mid"

## Hour matches a fish window; windows may wrap past midnight (max_hour > 24).
static func _hour_ok(hour: int, lo: int, hi: int) -> bool:
	if hi <= 24:
		return hour >= lo and hour < hi
	# wrap: e.g. 19..28 means 19:00-23:59 or 00:00-03:59
	return hour >= lo or hour < (hi - 24)

static func eligible(hour: int, tide: float, full_moon: bool, bait: String) -> Array:
	var band := tide_band(tide)
	var out: Array = []
	for f in Db.fish:
		if not _hour_ok(hour, int(f.get("min_hour", 0)), int(f.get("max_hour", 24))):
			continue
		var ft: String = f.get("tide", "any")
		if ft != "any" and ft != band:
			continue
		if f.get("moon", "") == "full" and not full_moon:
			continue
		# bait-locked fish need that bait; other fish still bite with any bait
		var need_bait: String = f.get("bait", "")
		if need_bait != "" and need_bait != bait:
			continue
		out.append(f)
	return out

## Roll a catch for the current sky/time. Returns a fish def or {} (nothing).
static func roll(bait: String = "", rng: RandomNumberGenerator = null) -> Dictionary:
	var pool := eligible(GameClock.wib_hour(), GameClock.tide_level(), GameClock.is_full_moon(), bait)
	if pool.is_empty():
		return {}
	var total := 0.0
	for f in pool:
		total += float(f.get("weight", 1))
	var r := (rng.randf() if rng else randf()) * total
	var acc := 0.0
	for f in pool:
		acc += float(f.get("weight", 1))
		if r <= acc:
			return f
	return pool[pool.size() - 1]

## True if this bait + sky can hook the Star Whale hidden scenario path (v0.2 §8.2).
static func can_hook_starwhale(bait: String) -> bool:
	return bait == "star_bait" and GameClock.sky_event_today().findn("meteor") != -1
