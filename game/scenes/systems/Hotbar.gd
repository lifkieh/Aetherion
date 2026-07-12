class_name Hotbar
extends RefCounted
## Skill hotbar + tiered element fusion (owner combat revisions B/C). No single-skill
## cooldowns: a primed skill is CHANNELLED by holding left-click — each cast costs mana
## at the skill's cast_rate; mana out = channel stops (empty click). Flow skills TOGGLE a
## persistent weapon infusion (drained by mana). Fusion: prime 2 (holdable, mana ~2.5x);
## prime 3-4 for a recast fusion (the only cooldown in the game — see PC3).

const COMBO_WINDOW := 1.5
const FUSION_BASE_MANA := 6   # min mana base for fusion (flow skills prime at 0 mana)
# Combo Skill (GDD §6.2, v0.4.1): 2 skill BEDA dalam window = bonus. DATA-DRIVEN
# dari combat_feel.json "skill_combo" (designer bisa tuning tanpa kode).
static func _combo_cfg() -> Dictionary:
	return Db.combat_feel.get("skill_combo", {"window": 2.0, "mult": 1.3})

var _last_cast_sid := ""
var _last_cast_ms := -99999
var _combo_announced := false

var primed := -1                  # slot armed for a channelled cast
var fusion_slots: Array = []      # ordered primed slots for a fusion (2-4)
var fusion_ready := false
var _combo_t := 0.0
var _cast_t := 0.0                # channel accumulator (seconds until next cast)
var _empty_t := 0.0               # throttle for the "no mana" click
var _fusion_announced := false

func tick(delta: float) -> void:
	_combo_t = maxf(0.0, _combo_t - delta)
	_empty_t = maxf(0.0, _empty_t - delta)

# HUD compatibility: no per-skill cooldowns any more.
func cooldown_frac(_slot: int) -> float:
	return 0.0

func _slot_skill(slot: int) -> String:
	if slot >= 0 and slot < PlayerData.hotbar.size():
		return PlayerData.hotbar[slot]
	return ""

## Number key (slot 0..4). Chains into a fusion if pressed within the combo window.
## Pressing the SAME slot again cancels the prime (FF-2c toggle).
func press_slot(slot: int) -> void:
	var sid := _slot_skill(slot)
	if sid == "":
		return
	if not PlayerData.can_use_skill(sid):
		EventBus.toast.emit("%s belum dipelajari." % Db.skill(sid).get("name", sid))
		Audio.play_sfx("menu", 0.6)
		return
	# toggle off: same key on the primed slot (or a slot already in the fusion chain)
	if (primed == slot and fusion_slots.is_empty()) or (slot in fusion_slots):
		cancel_all()
		return
	if primed >= 0 and not (slot in fusion_slots) and _combo_t > 0.0:
		if fusion_slots.is_empty():
			fusion_slots = [primed]
		if not (slot in fusion_slots) and fusion_slots.size() < 4:
			fusion_slots.append(slot)
			fusion_ready = fusion_slots.size() >= 2
			_combo_t = COMBO_WINDOW
			Audio.play_sfx("prime", 1.15 + 0.1 * fusion_slots.size())
			EventBus.toast.emit("⚡ Prime %s — klik kiri untuk melepas!" % _chain_str())
			if fusion_ready:
				Onboarding.tip("fusion_prime")   # tutorial fusion pertama (FF-2d)
	else:
		primed = slot
		fusion_ready = false
		fusion_slots = []
		_combo_t = COMBO_WINDOW
		Audio.play_sfx("prime")

func _chain_str() -> String:
	var parts := []
	for s in fusion_slots:
		parts.append(str(s + 1))
	return "+".join(parts)

func is_primed() -> bool:
	return primed >= 0 or fusion_ready

## Cancel every prime/fusion chain (FF-2c: same-key toggle, right-click, or ESC).
func cancel_all() -> void:
	if not is_primed():
		return
	_reset()
	end_cast()
	Audio.play_sfx("menu", 0.7)
	EventBus.toast.emit("Prime dibatalkan.")

# --- HUD helpers ---
## "1+2+3" while a fusion is chained, "2" for a single primed slot, "" otherwise.
func prime_chain_str() -> String:
	if fusion_ready:
		return _chain_str()
	if primed >= 0:
		return str(primed + 1)
	return ""

## True while a 3-4 element (recast) fusion is primed — the only "cooldown" in the game.
func is_recast_fusion() -> bool:
	return fusion_ready and fusion_slots.size() >= 3

## 0..1 recast progress for a 3-4 fusion (0 = just fired/cooling, 1 = ready to recast).
func recast_frac() -> float:
	if not is_recast_fusion():
		return 0.0
	var interval := 1.0 / maxf(0.5, _cast_rate())
	return clampf(1.0 - _cast_t / interval, 0.0, 1.0)

func primed_is_flow() -> bool:
	return primed >= 0 and not fusion_ready and Db.skill(_slot_skill(primed)).get("kind", "") == "flow"

## Left-click DOWN. Flow = toggle infusion (one-shot). Otherwise start a channel.
## Returns true if the click was consumed (caller skips the basic attack).
func begin_cast(actor: Node2D, aim: Vector2) -> bool:
	if not is_primed():
		return false
	if primed_is_flow():
		PlayerData.toggle_infusion(Db.skill(_slot_skill(primed)).get("element", "fire"))
		Audio.play_sfx("prime", 0.9)
		_reset()
		return true
	_fusion_announced = false
	_cast_t = 0.0
	_do_cast(actor, aim)
	_cast_t = 1.0 / maxf(0.5, _cast_rate())
	return true

## Held each frame while left-click is down and a skill/fusion is primed.
func channel_tick(actor: Node2D, aim: Vector2, delta: float) -> void:
	if not is_primed() or primed_is_flow():
		return
	_cast_t -= delta
	if _cast_t <= 0.0:
		_cast_t = 1.0 / maxf(0.5, _cast_rate())
		_do_cast(actor, aim)

func end_cast() -> void:
	_cast_t = 0.0   # next press casts immediately

func _cast_rate() -> float:
	if fusion_ready:
		return 2.0 if fusion_slots.size() == 2 else 0.7   # 3-4 fusion = slow recast (PC3)
	return float(Db.skill(_slot_skill(primed)).get("cast_rate", 2.0))

func _do_cast(actor: Node2D, aim: Vector2) -> bool:
	if fusion_ready:
		return _cast_fusion(actor, aim)
	if primed >= 0:
		return _cast_single(actor, aim, _slot_skill(primed))
	return false

func _reset() -> void:
	primed = -1
	fusion_ready = false
	fusion_slots = []

func _no_mana() -> void:
	if _empty_t <= 0.0:
		_empty_t = 0.35
		Audio.play_sfx("menu", 0.6)   # empty click

func _cast_single(actor: Node2D, aim: Vector2, sid: String) -> bool:
	var sk := Db.skill(sid)
	if sk.is_empty():
		return false
	if not PlayerData.spend_mp(sk.get("mana_cost", 0)):
		_no_mana()
		return false
	# COMBO SKILL (v0.4.1): merangkai 2 skill BERBEDA dalam window = bonus damage.
	var ccfg := _combo_cfg()
	var now_ms := Time.get_ticks_msec()
	var is_combo := _last_cast_sid != "" and _last_cast_sid != sid \
		and (now_ms - _last_cast_ms) < int(float(ccfg.get("window", 2.0)) * 1000.0)
	if is_combo:
		sk = sk.duplicate()
		sk["skill_mod"] = float(sk.get("skill_mod", 1.0)) * float(ccfg.get("mult", 1.3))
		if not _combo_announced:
			_combo_announced = true
			EventBus.toast.emit("⚡ COMBO! %s → %s (+%d%%)" % [Db.skill(_last_cast_sid).get("name", ""), sk.get("name", sid), int((float(ccfg.get("mult", 1.3)) - 1.0) * 100)])
			Audio.play_sfx("prime", 1.4)
	else:
		_combo_announced = false
	_last_cast_sid = sid
	_last_cast_ms = now_ms
	match sk.get("kind", "physical"):
		"heal":
			PlayerData.heal(int(sk.get("heal_amount", 30)))
			Vfx.spark(actor.get_parent(), actor.global_position, "light")
			Audio.play_sfx("levelup", 1.3)
		"buff":
			PlayerData.apply_buff(sid, sk.get("buff", {}))
			Vfx.spark(actor.get_parent(), actor.global_position, sk.get("element", "none"))
			EventBus.toast.emit("%s!" % sk.get("name", sid))
			Audio.play_sfx("prime", 0.8)
		"magic":
			if sk.get("projectile", false):
				var shots: int = int(sk.get("shots", 1))
				var spread: float = deg_to_rad(float(sk.get("spread_deg", 14)))
				for i in range(shots):
					var a := aim
					if shots > 1:
						a = aim.rotated(spread * (float(i) - (shots - 1) * 0.5))
					PlayerCombat.fire_pooled(actor, a, sk.get("projectile_id", "spark"), sk.get("skill_mod", 1.0))
			else:
				PlayerCombat.melee_arc(actor, aim, sk.get("range", 60), sk.get("aoe_arc", 120), sk)
			Audio.play_sfx("attack", 1.05)
		_:
			PlayerCombat.melee_arc(actor, aim, sk.get("range", 48), sk.get("aoe_arc", 120), sk)
			Audio.play_sfx("attack", 1.05)
	EventBus.skill_cast.emit(sid)   # opening-quest hook (FF-2g)
	return true

func _cast_fusion(actor: Node2D, aim: Vector2) -> bool:
	var elems: Array = []
	for s in fusion_slots:
		elems.append(Db.skill(_slot_skill(s)).get("element", "none"))
	var combo := Db.elem_combo_multi(elems)
	# Flow skills cost 0 mana to prime, so a fusion needs a floor to stay expensive.
	var base := FUSION_BASE_MANA
	for s in fusion_slots:
		base = maxi(base, int(Db.skill(_slot_skill(s)).get("mana_cost", 3)))
	var tier := elems.size()
	var mana := int(base * (2.5 if tier == 2 else (4.0 if tier == 3 else 6.0)))
	if combo.is_empty():
		PlayerData.spend_mp(int(mana * 0.3))
		Vfx.spark(actor.get_parent(), actor.global_position + aim * 14.0, "wind")
		Audio.play_sfx("fizzle")
		# Grimoire (FF-2d): a fizzled element opens its mystery rows in the Grimoire
		for e in elems:
			if not (e in PlayerData.fusion_fizzled_elements):
				PlayerData.fusion_fizzled_elements.append(e)
		if not _fusion_announced:
			_fusion_announced = true
			EventBus.toast.emit("...paduan %s tak stabil (fizzle). Petunjuk tercatat di Grimoire." % "+".join(elems))
		return true
	if not PlayerData.spend_mp(mana):
		_no_mana()
		return false
	var elem: String = combo.get("element", elems[0])
	var def: Dictionary = Db.projectiles.get("fusion_bolt", {}).duplicate(true)
	def["element"] = elem
	def["damage_mult"] = combo.get("mult", 1.6)
	def["color"] = Vfx.elem_color(elem).to_html(false)
	def["radius"] = 8 + tier * 2
	ProjectilePool.spawn_def(actor.global_position + aim * 12.0, aim, def, PlayerData.combat_stats(), actor, "monsters")
	PlayerCombat.melee_arc(actor, aim, 52.0 + tier * 6, 130.0 + tier * 10, {"skill_mod": combo.get("mult", 1.6) * 0.6, "kind": "magic", "element": elem})
	Audio.play_sfx("fusion")
	var nm: String = combo.get("result", "Fusion")
	if not _fusion_announced:
		_fusion_announced = true
		if not (nm in PlayerData.discovered_fusions):
			PlayerData.discovered_fusions.append(nm)
			# first-discovery celebration: banner + Grimoire entry (FF-2d)
			EventBus.fusion_discovered.emit(nm, combo.get("desc", ""))
			Audio.play_sfx("levelup", 1.2)
		else:
			EventBus.toast.emit("✦ %s!" % nm)
	return true
