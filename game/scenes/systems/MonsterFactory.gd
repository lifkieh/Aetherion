class_name MonsterFactory
extends RefCounted
## Builds a live monster stat instance from a Db monster def.
## Balancing tables (Monster_Roster §1) live here as code: this is the
## server-authoritative simulation layer, not content data.

# Archetype -> [HP, ATK, DEF, MATK, MDEF, SPD] as fractions of BST
const ARCHETYPES := {
	"tank":     [0.30, 0.12, 0.25, 0.05, 0.20, 0.08],
	"bruiser":  [0.25, 0.25, 0.18, 0.04, 0.13, 0.15],
	"assassin": [0.15, 0.30, 0.08, 0.05, 0.10, 0.32],
	"caster":   [0.17, 0.05, 0.10, 0.32, 0.20, 0.16],
	"support":  [0.24, 0.08, 0.15, 0.20, 0.23, 0.10],
	"swift":    [0.18, 0.15, 0.10, 0.08, 0.11, 0.38],
}
# Rarity -> [default BST, growth per level, exp modifier, base tame rate]
const RARITY := {
	"common":    {"bst": 300, "growth": 0.030, "exp": 1.0,  "tame": 0.40},
	"rare":      {"bst": 360, "growth": 0.032, "exp": 1.8,  "tame": 0.20},
	"epic":      {"bst": 440, "growth": 0.034, "exp": 3.0,  "tame": 0.10},
	"legendary": {"bst": 540, "growth": 0.036, "exp": 6.0,  "tame": 0.015},
	"mythic":    {"bst": 660, "growth": 0.038, "exp": 9.0,  "tame": 0.005},
	"ancient":   {"bst": 800, "growth": 0.040, "exp": 12.0, "tame": 0.0001},
}
const STAR_MULT := [0.94, 0.97, 1.00, 1.03, 1.06]   # 1..5 star
const STAR_WEIGHTS := [15, 25, 35, 20, 5]
const HP_DISPLAY_MULT := 2.0

static func roll_star(rng: RandomNumberGenerator = null) -> int:
	var total := 0
	for w in STAR_WEIGHTS:
		total += w
	var r := (rng.randi_range(1, total) if rng else randi_range(1, total))
	var acc := 0
	for i in range(STAR_WEIGHTS.size()):
		acc += STAR_WEIGHTS[i]
		if r <= acc:
			return i + 1
	return 3

static func make(species_id: String, level_override: int = -1, star_override: int = -1, rng: RandomNumberGenerator = null) -> Dictionary:
	var def := Db.monster(species_id)
	if def.is_empty():
		push_error("[MonsterFactory] unknown species: " + species_id)
		return {}
	var rarity: String = def.get("rarity", "common")
	var rinfo: Dictionary = RARITY.get(rarity, RARITY["common"])
	var arche: String = def.get("archetype", "bruiser")
	var dist: Array = ARCHETYPES.get(arche, ARCHETYPES["bruiser"])
	var bst: float = float(def.get("bst", rinfo["bst"]))
	var level: int = level_override if level_override > 0 else int(def.get("level", 1))
	var star: int = star_override if star_override > 0 else roll_star(rng)
	var star_mult: float = STAR_MULT[clampi(star - 1, 0, 4)]
	var growth: float = rinfo["growth"]
	var lvl_scale: float = (1.0 + growth * (level - 1)) * star_mult

	var hp := int(round(bst * dist[0] * lvl_scale * HP_DISPLAY_MULT))
	var atk := int(round(bst * dist[1] * lvl_scale))
	var dfn := int(round(bst * dist[2] * lvl_scale))
	var matk := int(round(bst * dist[3] * lvl_scale))
	var mdef := int(round(bst * dist[4] * lvl_scale))
	var spd := int(round(bst * dist[5] * lvl_scale)) + 60

	var eff_bst := bst * lvl_scale
	var exp_reward := int(round(eff_bst * 0.2 * float(rinfo["exp"])))

	return {
		"species_id": species_id,
		"name": def.get("name", species_id),
		"rarity": rarity,
		"element": def.get("element", "none"),
		"archetype": arche,
		"size": def.get("size", "small"),
		"rideable": def.get("rideable", false),
		"level": level,
		"star": star,
		"max_hp": hp, "hp": hp,
		"atk": atk, "def": dfn, "matk": matk, "mdef": mdef, "spd": spd,
		"crit_rate": 0.05, "crit_dmg": 1.5,
		"resist": def.get("resist", {}),   # e.g. Rock Golem {lightning:0.9} = grounding (science)
		"skills": def.get("skills", ["tackle"]),
		"traits": def.get("traits", []),
		"loot_table": def.get("loot_table", ""),
		"tame_base": float(def.get("tame_base", rinfo["tame"])),
		"exp_reward": exp_reward,
		"ai": def.get("ai", "melee"),
		"aggro_radius": def.get("aggro_radius", 130),
		"sprite": def.get("sprite", ""),
		"frame_size": def.get("frame_size", 16),
		"cols": def.get("cols", 4), "rows": def.get("rows", 4),
		"tint": def.get("tint", ""),
		"is_rabbit": def.get("is_rabbit", false),
		"is_boss": def.get("is_boss", false),
		"behavior": def.get("behavior", ""),
		"projectile": def.get("projectile", ""),
		"passive": def.get("passive", false),
		"add_species": def.get("add_species", "verdant_slime"),
	}

## Grant kill rewards (EXP + loot + gold) for an instance. Shared by the top-down
## Monster and the side-view DungeonMonster — no duplication.
static func grant_rewards(inst: Dictionary) -> void:
	PlayerData.gain_exp(inst.get("exp_reward", 5))
	var table := Db.loot_table(inst.get("loot_table", ""))
	for d in table:
		if randf() <= float(d.get("chance", 0)):
			var qty := randi_range(int(d.get("min", 1)), int(d.get("max", 1)))
			PlayerData.add_item(d.get("item", ""), qty)
	var lvl: int = int(inst.get("level", 1))
	PlayerData.add_gold(randi_range(1, 4) * maxi(1, lvl))

## Combat stat view for CombatResolver.
static func combat_stats(inst: Dictionary) -> Dictionary:
	return {
		"atk": inst.get("atk", 1), "def": inst.get("def", 0),
		"matk": inst.get("matk", 0), "mdef": inst.get("mdef", 0),
		"spd": inst.get("spd", 100),
		"crit_rate": inst.get("crit_rate", 0.05), "crit_dmg": inst.get("crit_dmg", 1.5),
		"level": inst.get("level", 1), "element": inst.get("element", "none"),
		"resist": inst.get("resist", {}),
	}
