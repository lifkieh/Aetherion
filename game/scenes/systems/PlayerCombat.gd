class_name PlayerCombat
extends RefCounted
## Shared player combat orchestration (top-down AND side-view platformer reuse
## this — no duplication). All math stays in CombatResolver; this handles target
## finding, VFX, chain, and projectiles for any player-actor node.

# --- Weapon movesets (FF-2b): every type swings DIFFERENTLY -------------------
# rate = attacks/sec (pre-AGI) · reach/arc = melee shape · mult = damage per hit.
# Items may override via "attack_rate" / "arc_mult". Balance: rate × mult ≈ konstan.
const WEAPON_MOVESET := {
	"sword":  {"rate": 2.85, "reach": 46.0, "arc": 110.0, "mult": 1.0},
	"spear":  {"rate": 2.4,  "reach": 68.0, "arc": 30.0,  "mult": 1.2},
	"dagger": {"rate": 4.2,  "reach": 32.0, "arc": 70.0,  "mult": 0.72},
	"hammer": {"rate": 1.7,  "reach": 44.0, "arc": 100.0, "mult": 1.7},
	"scythe": {"rate": 2.0,  "reach": 58.0, "arc": 175.0, "mult": 1.25},
	"bow":    {"rate": 3.3,  "ranged": true},
	"wand":   {"rate": 3.0,  "ranged": true},
	"staff":  {"rate": 2.2,  "ranged": true, "mult": 1.3},
}

static func weapon_type() -> String:
	var w: String = PlayerData.equipped_weapon
	return "sword" if w == "" else Db.item(w).get("weapon_type", "sword")

static func moveset() -> Dictionary:
	return WEAPON_MOVESET.get(weapon_type(), WEAPON_MOVESET["sword"])

## Seconds between basic attacks: weapon rate × AGI attack_speed (rev A).
static func basic_interval() -> float:
	var w := Db.item(PlayerData.equipped_weapon)
	var rate: float = w.get("attack_rate", moveset().get("rate", 2.85))
	return 1.0 / maxf(0.4, rate * PlayerData.attack_speed)

## One basic attack toward `aim` — the ONLY basic-attack path for both modes.
## Melee types swing their own shape; ranged types fire their projectile
## (wand/staff spend the weapon's small mana cost). Returns true if it happened.
static func basic_attack(actor: Node2D, aim: Vector2) -> bool:
	var w := Db.item(PlayerData.equipped_weapon)
	var wt := weapon_type()
	var ms := moveset()
	if ms.get("ranged", false):
		var cost: int = w.get("mana_cost", 0)
		if cost > 0 and not PlayerData.spend_mp(cost):
			Audio.play_sfx("menu", 0.6)   # empty click
			return false
		fire_pooled(actor, aim, w.get("projectile", "arrow"), ms.get("mult", 1.0))
		Vfx.swing(actor.get_parent(), actor.global_position, aim, PlayerData.current_weapon_element(), wt)
		Audio.play_sfx("attack")
		return true
	var reach: float = ms.get("reach", 46.0)
	var arc: float = ms.get("arc", 110.0) * float(w.get("arc_mult", 1.0))
	melee_arc(actor, aim, reach, arc, Db.skill("strike"), ms.get("mult", 1.0), wt)
	Audio.play_sfx("attack", {"dagger": 1.3, "hammer": 0.75, "scythe": 0.9}.get(wt, 1.0))
	return true

## Geometric melee: hit monsters within `reach` inside a ~120° cone toward `facing`.
static func melee(actor: Node2D, facing: Vector2, reach: float, skill: Dictionary) -> void:
	var origin: Vector2 = actor.global_position
	var atk := PlayerData.combat_stats()
	var aoe: bool = skill.get("aoe", false)
	var targets: Array = []
	for m in actor.get_tree().get_nodes_in_group("monsters"):
		if not is_instance_valid(m) or not m.has_method("take_hit"):
			continue
		var to: Vector2 = m.global_position - origin
		if to.length() > reach:
			continue
		if to != Vector2.ZERO and facing.dot(to.normalized()) < 0.35:
			continue
		targets.append(m)
	if not aoe and targets.size() > 1:
		targets.sort_custom(func(a, b): return a.global_position.distance_to(origin) < b.global_position.distance_to(origin))
		targets = [targets[0]]
	var swing_elem: String = skill.get("element", "none")
	if swing_elem == "none":
		swing_elem = atk.get("element", "none")
	Vfx.swing(actor.get_parent(), origin, facing, swing_elem)
	for m in targets:
		var wet: bool = m.is_wet if ("is_wet" in m) else false
		var ctx := CombatResolver.build_ctx(wet)
		var res := CombatResolver.resolve(atk, m.combat_view(), skill, ctx)
		m.take_hit(res, actor)
		if res.get("chain", false):
			chain_lightning(actor, m, skill, ctx)

static func chain_lightning(actor: Node2D, origin: Node2D, skill: Dictionary, ctx: Dictionary) -> void:
	var atk := PlayerData.combat_stats()
	var chained := 0
	for m in actor.get_tree().get_nodes_in_group("monsters"):
		if m == origin or not is_instance_valid(m):
			continue
		if not (("is_wet" in m) and m.is_wet):
			continue
		if m.global_position.distance_to(origin.global_position) < 96.0:
			var chain_res := CombatResolver.resolve(atk, m.combat_view(), skill, ctx)
			chain_res["damage"] = int(chain_res["damage"] * 0.6)
			m.take_hit(chain_res, actor)
			Vfx.chain_arc(actor.get_parent(), origin.global_position, m.global_position, "lightning")
			chained += 1
			if chained >= 3:
				break
	if chained > 0:
		EventBus.toast.emit("⚡ Chain x%d (musuh basah)!" % chained)

## Terraria-style arc melee toward an aim direction: MULTI-HIT all monsters
## within `reach` and inside `arc_deg`. Applies knockback + hitstop/shake feel.
static func melee_arc(actor: Node2D, aim: Vector2, reach: float, arc_deg: float, skill: Dictionary, dmg_mult: float = 1.0, wtype: String = "") -> int:
	var origin: Vector2 = actor.global_position
	var atk := PlayerData.combat_stats()
	# rev E: an active weapon infusion reshapes the melee (reach/arc/damage per element)
	if PlayerData.has_active_infusion():
		var infuse: String = PlayerData.infusion.get("element", "")
		var im: Dictionary = Db.elements.get("infusion_melee", {}).get(infuse, {})
		if not im.is_empty():
			reach *= im.get("reach_mult", 1.0)
			arc_deg *= im.get("arc_mult", 1.0)
			dmg_mult *= im.get("dmg_mult", 1.0)
	var half := deg_to_rad(arc_deg * 0.5)
	var swing_elem: String = skill.get("element", "none")
	if swing_elem == "none":
		swing_elem = atk.get("element", "none")
	Vfx.swing(actor.get_parent(), origin, aim, swing_elem, wtype, reach, arc_deg)
	var hits := 0
	for m in actor.get_tree().get_nodes_in_group("monsters"):
		if not is_instance_valid(m) or not m.has_method("take_hit"):
			continue
		var to: Vector2 = m.global_position - origin
		if to.length() > reach:
			continue
		if to != Vector2.ZERO and absf(aim.angle_to(to)) > half:
			continue
		var wet: bool = m.is_wet if ("is_wet" in m) else false
		var ctx := CombatResolver.build_ctx(wet)
		var res := CombatResolver.resolve(atk, m.combat_view(), skill, ctx)
		res["damage"] = int(res["damage"] * dmg_mult)
		m.take_hit(res, actor)
		CombatFeel.on_hit(m, origin, res.get("is_crit", false))
		# drain skills (Necromancer): a slice of dealt damage returns as HP (FF-2a)
		var drain: float = float(skill.get("drain_heal", 0.0))
		if drain > 0.0 and res.get("damage", 0) > 0:
			PlayerData.heal(int(res["damage"] * drain))
		if res.get("chain", false):
			chain_lightning(actor, m, skill, ctx)
		hits += 1
	return hits

## Fire a pooled data-driven projectile toward `aim` (player shot). dmg_mult
## scales the shot (e.g. bow charge).
static func fire_pooled(actor: Node2D, aim: Vector2, proj_id: String, dmg_mult: float = 1.0) -> void:
	var atk := PlayerData.combat_stats()
	if dmg_mult != 1.0:
		atk = atk.duplicate()
		atk["atk"] = int(atk.get("atk", 10) * dmg_mult)
		atk["matk"] = int(atk.get("matk", 10) * dmg_mult)
	ProjectilePool.spawn(actor.global_position + aim * 12.0, aim, proj_id, atk, actor, "monsters")

static func fire_projectile(actor: Node2D, facing: Vector2, skill: Dictionary) -> void:
	var proj := preload("res://scenes/actors/Projectile.tscn").instantiate()
	actor.get_parent().add_child(proj)
	proj.global_position = actor.global_position + facing * 12.0
	proj.setup(facing, skill, PlayerData.combat_stats(), actor)

## Element-flow aura tint for a player sprite (shared visual).
static func infusion_tint() -> Color:
	if PlayerData.has_active_infusion():
		var c := Vfx.elem_color(PlayerData.infusion.get("element", "none"))
		var pulse := 0.6 + 0.4 * sin(Time.get_ticks_msec() / 120.0)
		return Color(1, 1, 1).lerp(c, 0.5 * pulse)
	return Color.WHITE
