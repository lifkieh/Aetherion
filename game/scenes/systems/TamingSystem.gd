class_name TamingSystem
extends RefCounted
## Taming roll (Fase0 §5, GDD §7 / v0.2 §7.4).
## Chance = BaseRate(rarity/def) * OrbMod * AffinityMod * WeatherMod * TamerSkillMod
## + light pity per failure on the same individual. Requires HP<5% and an orb.

# Best orb the player holds (id -> multiplier), tried best-first.
const ORBS := [
	{"id": "master_orb", "mult": 2.5},
	{"id": "greater_orb", "mult": 1.5},
	{"id": "basic_orb", "mult": 1.0},
]

static func best_orb() -> Dictionary:
	for o in ORBS:
		if PlayerData.item_count(o.id) > 0:
			return o
	return {}

static func weather_mod() -> float:
	# Rain/thunderstorm makes beasts skittish -> slightly harder; full moon easier.
	if GameClock.is_full_moon():
		return 1.2
	if WorldState.is_wet_weather():
		return 0.9
	return 1.0

static func tamer_skill_mod() -> float:
	# Tamer bonus + pohon skill Menjinakkan (#30) + perk class Penjinak (#33).
	var penjinak := 0.05 if PlayerData.char_class == "penjinak" else 0.0
	return 1.0 + minf(0.25, PlayerData.level * 0.01) + SkillTreeSystem.bonus_total("tame_add") + penjinak

static func compute_chance(monster, orb: Dictionary) -> float:
	var base: float = monster.inst.get("tame_base", 0.4)
	var affinity_mod := 1.0
	var chance := base * float(orb.get("mult", 1.0)) * affinity_mod * weather_mod() * tamer_skill_mod()
	chance += monster.tame_pity
	return clampf(chance, 0.0, 0.99)

## Returns {success, chance, reason}.
static func attempt(monster, rng: RandomNumberGenerator = null) -> Dictionary:
	if not monster.can_be_tamed():
		return {"success": false, "chance": 0.0, "reason": "hp_too_high"}
	var orb := best_orb()
	if orb.is_empty():
		EventBus.toast.emit("Butuh Orb untuk menjinakkan!")
		return {"success": false, "chance": 0.0, "reason": "no_orb"}
	PlayerData.remove_item(orb.id, 1)
	var chance := compute_chance(monster, orb)
	var roll := (rng.randf() if rng else randf())
	var success := roll < chance
	EventBus.tame_attempted.emit(monster.inst.get("species_id", "?"), success, chance)
	if success:
		_add_to_party(monster)
	return {"success": success, "chance": chance, "reason": "ok"}

static func _add_to_party(monster) -> void:
	var pet := {
		"species_id": monster.inst.get("species_id", ""),
		"name": monster.inst.get("name", ""),
		"level": monster.inst.get("level", 1),
		"star": monster.inst.get("star", 3),
		"element": monster.inst.get("element", "none"),
		"size": monster.inst.get("size", "small"),
		"rideable": monster.inst.get("rideable", false),
		"max_hp": monster.inst.get("max_hp", 100),
		"atk": monster.inst.get("atk", 10),
		"spd": monster.inst.get("spd", 100),
		"affinity": 0,
		"tamed_at": GameClock.unix_now(),
	}
	PlayerData.monsters.append(pet)
	if PlayerData.active_pet_index < 0:
		PlayerData.active_pet_index = PlayerData.monsters.size() - 1
	EventBus.pet_added.emit(pet)
