class_name CraftingSystem
extends RefCounted
## Crafting resolution (Fase0 §2 recipes, GDD v0.2 §2 anti-frustration).
## Consumes ingredients, rolls success_rate; on failure the lowest-tier base
## ingredient is preserved (support materials burn), plus an Insight stack that
## nudges the same recipe's rate up slightly (cap +9%).

const TIER_ORDER := ["F", "E", "D", "C", "B", "A", "S", "SS", "SSS"]
const TRANSCENDENT_TIERS := ["A", "S", "SS", "SSS"]

## Tier efektif resep: field "tier" eksplisit, atau tier item hasil.
static func recipe_tier(recipe: Dictionary) -> String:
	return recipe.get("tier", Db.item(recipe.get("result", "")).get("tier", "F"))

## Resep A+ = crafting Transenden (MOMEN: ritual + pengumuman di UI).
static func is_transcendent(recipe: Dictionary) -> bool:
	return recipe_tier(recipe) in TRANSCENDENT_TIERS

static func find_recipe(recipe_id: String) -> Dictionary:
	for r in Db.recipes:
		if r.get("id", "") == recipe_id:
			return r
	return {}

static func can_craft(recipe: Dictionary) -> bool:
	for ing in recipe.get("ingredients", []):
		if PlayerData.item_count(ing.get("item", "")) < int(ing.get("qty", 1)):
			return false
	return true

static func success_rate(recipe: Dictionary) -> float:
	var base: float = recipe.get("success_rate", 1.0)
	return clampf(base + PlayerData.craft_insight.get(recipe.get("id", ""), 0.0), 0.0, 1.0)

static func _lowest_tier_ingredient(recipe: Dictionary) -> String:
	# The "base" material kept on failure = highest-tier ingredient (the valuable one).
	var best := ""
	var best_rank := -1
	for ing in recipe.get("ingredients", []):
		var tier: String = Db.item(ing.get("item", "")).get("tier", "F")
		var rank := TIER_ORDER.find(tier)
		if rank > best_rank:
			best_rank = rank
			best = ing.get("item", "")
	return best

## Returns {success, result, reason}.
static func craft(recipe_id: String, rng: RandomNumberGenerator = null) -> Dictionary:
	var recipe := find_recipe(recipe_id)
	if recipe.is_empty():
		return {"success": false, "reason": "unknown_recipe"}
	# profession tier gate (GDD v0.2 §3): sub max tier B, A+ main-only
	var access := ProfessionSystem.can_use_recipe(recipe)
	if not access.ok:
		EventBus.toast.emit(access.reason)
		return {"success": false, "reason": "profession_gate"}
	if not can_craft(recipe):
		EventBus.toast.emit("Bahan tidak cukup.")
		return {"success": false, "reason": "missing_ingredients"}

	var rate := success_rate(recipe)
	var roll := (rng.randf() if rng else randf())
	var success := roll < rate
	var base_item := _lowest_tier_ingredient(recipe)

	# consume ingredients (on failure, refund the valuable base ingredient)
	for ing in recipe.get("ingredients", []):
		var item: String = ing.get("item", "")
		var qty: int = int(ing.get("qty", 1))
		PlayerData.remove_item(item, qty)
		if not success and item == base_item:
			PlayerData.add_item(item, qty)   # base preserved on failure

	if success:
		var result: String = recipe.get("result", "")
		var out_qty: int = int(recipe.get("qty", 1))
		out_qty += int(ProfessionSystem.perk_value(recipe.get("profession", ""), "bonus_yield"))
		PlayerData.add_item(result, out_qty)
		EventBus.item_crafted.emit(result, true)
		if is_transcendent(recipe):
			EventBus.transcendent_crafted.emit(result, true)
		else:
			EventBus.toast.emit("Berhasil membuat %s x%d!" % [Db.item_name(result), out_qty])
		return {"success": true, "result": recipe.get("result", ""), "reason": "ok"}
	else:
		var rid: String = recipe.get("id", "")
		PlayerData.craft_insight[rid] = minf(0.09, PlayerData.craft_insight.get(rid, 0.0) + 0.002)
		EventBus.item_crafted.emit(recipe.get("result", ""), false)
		if is_transcendent(recipe):
			EventBus.transcendent_crafted.emit(recipe.get("result", ""), false)
		else:
			EventBus.toast.emit("Gagal membuat (bahan dasar aman). +Insight")
		return {"success": false, "result": "", "reason": "failed_roll"}
