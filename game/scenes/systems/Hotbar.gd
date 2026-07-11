class_name Hotbar
extends RefCounted
## Shared skill-hotbar + element-fusion logic (owner UI/UX §2). Used by BOTH the
## top-down Player and side-view PlayerPlatformer — one control language.
##
## PRIME a slot (number key) -> LEFT-CLICK releases it toward the cursor.
## Press two numbers within COMBO_WINDOW -> FUSION prime; left-click casts the
## fusion spell if elements.json has a recipe (mana 2x), else FIZZLE (discovery).

const COMBO_WINDOW := 1.5

var primed := -1            # slot armed for a normal cast
var fusion_a := -1          # first slot of a fusion
var fusion_b := -1          # second slot of a fusion
var fusion_ready := false
var _combo_t := 0.0
var _cooldowns := {}        # skill_id -> remaining seconds

func tick(delta: float) -> void:
	_combo_t = maxf(0.0, _combo_t - delta)
	for k in _cooldowns.keys():
		_cooldowns[k] = maxf(0.0, _cooldowns[k] - delta)

func cooldown_frac(slot: int) -> float:
	var sid := _slot_skill(slot)
	var sk := Db.skill(sid)
	var cd: float = sk.get("cooldown", 0.0)
	if cd <= 0.0:
		return 0.0
	return clampf(_cooldowns.get(sid, 0.0) / cd, 0.0, 1.0)

func _slot_skill(slot: int) -> String:
	if slot >= 0 and slot < PlayerData.hotbar.size():
		return PlayerData.hotbar[slot]
	return ""

## Press a number key (slot 0..4). Chains into a fusion if within the window.
func press_slot(slot: int) -> void:
	if _slot_skill(slot) == "":
		return
	if primed >= 0 and primed != slot and _combo_t > 0.0 and not fusion_ready:
		fusion_a = primed
		fusion_b = slot
		fusion_ready = true
		EventBus.toast.emit("⚡ FUSION siap — klik kiri untuk melepas!")
	else:
		primed = slot
		fusion_ready = false
		fusion_a = -1
		fusion_b = -1
		_combo_t = COMBO_WINDOW

## Left-click. Returns true if a skill/fusion was cast (caller skips normal attack).
func cast(actor: Node2D, aim: Vector2) -> bool:
	if fusion_ready:
		var ok := _cast_fusion(actor, aim)
		_reset()
		return ok
	if primed >= 0:
		var ok := _cast_single(actor, aim, _slot_skill(primed))
		_reset()
		return ok
	return false

func _reset() -> void:
	primed = -1
	fusion_ready = false
	fusion_a = -1
	fusion_b = -1

func _cast_single(actor: Node2D, aim: Vector2, sid: String) -> bool:
	var sk := Db.skill(sid)
	if sk.is_empty():
		return false
	if _cooldowns.get(sid, 0.0) > 0.0:
		EventBus.toast.emit("%s masih pulih..." % sk.get("name", sid))
		return false
	if not PlayerData.spend_mp(sk.get("mp_cost", 0)):
		EventBus.toast.emit("Mana tidak cukup")
		return false
	_cooldowns[sid] = sk.get("cooldown", 1.0)
	match sk.get("kind", "physical"):
		"flow":
			PlayerData.apply_infusion(sk.get("element", "fire"), sk.get("duration", 45))
		"magic":
			PlayerCombat.fire_pooled(actor, aim, sk.get("projectile_id", "spark"))
		_:
			PlayerCombat.melee_arc(actor, aim, sk.get("range", 48), sk.get("aoe_arc", 120), sk)
	Audio.play_sfx("attack")
	return true

func _cast_fusion(actor: Node2D, aim: Vector2) -> bool:
	var e1 := Db.skill(_slot_skill(fusion_a)).get("element", "none")
	var e2 := Db.skill(_slot_skill(fusion_b)).get("element", "none")
	var combo := Db.elem_combo(e1, e2)
	var mana := 2 * maxi(Db.skill(_slot_skill(fusion_a)).get("mp_cost", 6), Db.skill(_slot_skill(fusion_b)).get("mp_cost", 6))
	if combo.is_empty():
		# fizzle — small smoke, a HINT that other combinations may work (discovery)
		PlayerData.spend_mp(int(mana * 0.3))
		Vfx.spark(actor.get_parent(), actor.global_position + aim * 14.0, "wind")
		Audio.play_sfx("dodge")
		EventBus.toast.emit("...kombinasi %s+%s tak stabil (fizzle). Coba paduan lain?" % [e1, e2])
		return true
	if not PlayerData.spend_mp(mana):
		EventBus.toast.emit("Fusion butuh %d mana!" % mana)
		return false
	var elem: String = combo.get("element", e1)
	var def: Dictionary = Db.projectiles.get("fusion_bolt", {}).duplicate(true)
	def["element"] = elem
	def["damage_mult"] = combo.get("mult", 1.6)
	def["color"] = Vfx.elem_color(elem).to_html(false)
	var atk := PlayerData.combat_stats()
	ProjectilePool.spawn_def(actor.global_position + aim * 12.0, aim, def, atk, actor, "monsters")
	# plus an impact swing for feel
	PlayerCombat.melee_arc(actor, aim, 56.0, 140.0, {"skill_mod": combo.get("mult", 1.6) * 0.6, "kind": "magic", "element": elem})
	Audio.play_sfx("secret")
	var name: String = combo.get("result", "Fusion")
	if not (name in PlayerData.discovered_fusions):
		PlayerData.discovered_fusions.append(name)
		EventBus.toast.emit("★ FUSION PERTAMA: %s! (%s)" % [name, combo.get("desc", "")])
	else:
		EventBus.toast.emit("✦ %s!" % name)
	return true
