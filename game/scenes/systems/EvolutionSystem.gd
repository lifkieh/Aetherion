class_name EvolutionSystem
extends RefCounted
## Evolution (GDD §8 / Monster_Roster) — condition-gated species change for
## tamed monsters. Fase 1 launch rule: Fluffbit → Moonbit under the full moon.

# species_id -> condition to evolve into its `evolution`
const CONDITIONS := {
	"fluffbit": "full_moon",
	"grey_wolf": "level",
	"dire_wolf": "full_moon",   # Dire Wolf -> Alpha Wolf under the full moon (v0.3)
	"wild_boar": "blood_moon",  # Wild Boar -> Ironhide Boar saat BULAN DARAH (v0.4.1, Decision Log #24)
}
# level threshold for "level"-conditioned evolutions
const LEVEL_REQ := {
	"grey_wolf": 8,
}

static func can_evolve(pet: Dictionary) -> bool:
	var sp: String = pet.get("species_id", "")
	var def := Db.monster(sp)
	if def.get("evolution", "") == "":
		return false
	var cond: String = CONDITIONS.get(sp, "")
	match cond:
		"full_moon": return GameClock.is_full_moon()
		"blood_moon": return WorldState.weather == "blood_moon"
		"level": return int(pet.get("level", 1)) >= int(LEVEL_REQ.get(sp, 999))
		"": return false
		_: return false

## Evolve a party pet in place if its condition is met. Returns new id or "".
static func evolve(pet: Dictionary) -> String:
	if not can_evolve(pet):
		return ""
	var evo_id: String = Db.monster(pet.get("species_id", "")).get("evolution", "")
	return apply(pet, evo_id)

## Transform a pet into `evo_id` in place (no condition check). Testable.
static func apply(pet: Dictionary, evo_id: String) -> String:
	var evo := Db.monster(evo_id)
	if evo.is_empty():
		return ""
	var lvl: int = pet.get("level", 1)
	var built := MonsterFactory.make(evo_id, lvl, pet.get("star", 3))
	# keep identity fields, take evolved stats/species
	pet["species_id"] = evo_id
	pet["name"] = evo.get("name", evo_id)
	pet["element"] = evo.get("element", pet.get("element", "none"))
	pet["rideable"] = evo.get("rideable", pet.get("rideable", false))
	pet["size"] = evo.get("size", pet.get("size", "small"))
	pet["max_hp"] = built.get("max_hp", pet.get("max_hp", 100))
	pet["atk"] = built.get("atk", pet.get("atk", 10))
	pet["spd"] = built.get("spd", pet.get("spd", 100))
	return evo_id

## Check the whole party; evolve all eligible. Returns count evolved.
static func check_party() -> int:
	var n := 0
	for pet in PlayerData.monsters:
		var evo := evolve(pet)
		if evo != "":
			n += 1
			EventBus.toast.emit("✨ %s berevolusi!" % Db.monster(evo).get("name", evo))
	return n
