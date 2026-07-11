class_name CombatResolver
extends RefCounted
## Pure combat math (Fase0 §4). No nodes/UI — this is the future server path.
##
## Damage Fisik = (ATK*SkillMod - DEF*0.5) * ElemMod * CritMod * (1-Resist%)
## Damage Magic = (MATK*SkillMod - MDEF*0.5) * ElemMod * CritMod * (1-MRes%)   (v2, PC6)
## ElemMod = matrix[atk][def] (1.3/1.0/0.7) * product(science rule mults for ctx)

const DEF_FACTOR := 0.5   # tuned down from GDD draft 0.6 for snappier early TTK
const CRIT_MIN := 0.05
const CRIT_MAX := 0.60
const CRIT_DMG_CAP := 2.5

## Returns matrix multiplier * all matching science-rule multipliers.
static func elem_mod(atk_elem: String, def_elem: String, ctx: Dictionary) -> float:
	if atk_elem == "" or atk_elem == "none":
		return 1.0
	var matrix: Dictionary = Db.elements.get("matrix", {})
	var m: float = float(matrix.get(atk_elem, {}).get(def_elem, 1.0))
	var rules: Array = Db.elements.get("rules", {}).get(atk_elem, [])
	for rule in rules:
		if rule.has("mult") and _rule_matches(rule.get("if", {}), ctx):
			m *= float(rule["mult"])
	return m

## Does this element's attack chain in the given ctx (e.g. lightning + wet)?
static func elem_chains(atk_elem: String, ctx: Dictionary) -> bool:
	var rules: Array = Db.elements.get("rules", {}).get(atk_elem, [])
	for rule in rules:
		if rule.get("chain", false) and _rule_matches(rule.get("if", {}), ctx):
			return true
	return false

static func _rule_matches(cond: Dictionary, ctx: Dictionary) -> bool:
	for k in cond.keys():
		if ctx.get(k, null) != cond[k]:
			return false
	return true

## Roll a full attack. rng optional (deterministic tests pass a seeded RNG).
## attacker/defender are stat dicts; skill is a Db skill def.
static func resolve(attacker: Dictionary, defender: Dictionary, skill: Dictionary, ctx: Dictionary, rng: RandomNumberGenerator = null) -> Dictionary:
	var skill_mod: float = float(skill.get("skill_mod", 1.0))
	var kind: String = skill.get("kind", "physical")
	# Element: skill element overrides "none"; else attacker's weapon element
	var atk_elem: String = skill.get("element", "none")
	if atk_elem == "none" or atk_elem == "":
		atk_elem = attacker.get("element", "none")
	var def_elem: String = defender.get("element", "none")
	var em := elem_mod(atk_elem, def_elem, ctx)

	# Accuracy vs evasion (DEX vs AGI) — a miss deals no damage.
	var acc: float = float(attacker.get("accuracy", 1.0))
	var eva: float = float(defender.get("evasion", 0.0))
	var hit_chance := clampf(acc - eva, 0.2, 1.0)
	if (rng.randf() if rng else randf()) > hit_chance:
		return {"damage": 0, "miss": true, "is_crit": false, "element": atk_elem, "elem_mod": em, "chain": false, "effective": false, "resisted": false}

	# Crit
	var crit_rate := clampf(float(attacker.get("crit_rate", 0.05)), CRIT_MIN, CRIT_MAX)
	var roll := rng.randf() if rng else randf()
	var is_crit := roll < crit_rate
	var crit_mod := minf(float(attacker.get("crit_dmg", 1.5)), CRIT_DMG_CAP) if is_crit else 1.0

	var raw := 0.0
	if kind == "magic":
		# v2 calibration (PC6): MDEF mitigates like DEF (inside the multipliers).
		# The old flat post-multiplier subtraction floored low-MATK casts to 1 dmg
		# vs any tanky target (see BALANCE_REPORT_v2) — wands became useless.
		var matk := float(attacker.get("matk", 0))
		var mres := float(defender.get("resist", {}).get(atk_elem, 0.0))
		raw = (matk * skill_mod - float(defender.get("mdef", 0)) * DEF_FACTOR) * em * crit_mod * (1.0 - mres)
	else:
		var atk := float(attacker.get("atk", 0))
		var dfn := float(defender.get("def", 0))
		var res := float(defender.get("resist", {}).get(atk_elem, 0.0))
		raw = (atk * skill_mod - dfn * DEF_FACTOR) * em * crit_mod * (1.0 - res)

	var dmg := int(round(maxf(1.0, raw)))  # always at least 1
	return {
		"damage": dmg,
		"is_crit": is_crit,
		"element": atk_elem,
		"elem_mod": em,
		"chain": elem_chains(atk_elem, ctx),
		"effective": em > 1.0,
		"resisted": em < 1.0,
	}

## Build the world/science ctx for an attack against `target_wet` etc.
static func build_ctx(target_wet: bool = false, target_grounded: bool = false, underwater: bool = false) -> Dictionary:
	return {
		"weather": WorldState.weather,
		"target_wet": target_wet or WorldState.is_wet_weather(),
		"target_grounded": target_grounded,
		"underwater": underwater,
		"wind_active": WorldState.weather == "thunderstorm",
		"is_night": GameClock.is_night(),
		"is_day": not GameClock.is_night(),
		"full_moon": GameClock.is_full_moon(),
		"new_moon": GameClock.is_new_moon(),
		"clear_sky": WorldState.weather == "sunny",
		"overcast": WorldState.weather in ["rain", "thunderstorm", "blizzard"],
		"solar_noon": GameClock.wib_hour() >= 11 and GameClock.wib_hour() <= 13,
		"hot_zone": false,
	}
