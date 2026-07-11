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
