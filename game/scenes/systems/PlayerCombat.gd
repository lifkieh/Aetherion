class_name PlayerCombat
extends RefCounted
## Shared player combat orchestration (top-down AND side-view platformer reuse
## this — no duplication). All math stays in CombatResolver; this handles target
## finding, VFX, chain, and projectiles for any player-actor node.

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
static func melee_arc(actor: Node2D, aim: Vector2, reach: float, arc_deg: float, skill: Dictionary, dmg_mult: float = 1.0) -> int:
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
	Vfx.swing(actor.get_parent(), origin, aim, swing_elem)
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
