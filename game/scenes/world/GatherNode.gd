extends Node2D
## Resource node: tree (wood) or ore (copper). Harvest by pressing E nearby.
## Depletes, then respawns after a real-time delay tracked in WorldState.

const RESPAWN := {"tree": 60, "ore": 90, "lollipop": 75, "sandstone": 80}
const LOOT := {"tree": "tree_node", "ore": "copper_node", "lollipop": "lollipop_node", "sandstone": "sandstone_node"}
const HITS := {"tree": 3, "ore": 4, "lollipop": 3, "sandstone": 4}

var kind := "tree"
var node_id := ""
var _hits_left := 3
var _depleted := false
var _tree_variant := "tree_pine_b"
var biome := "forest"          # "frost" => snow pines

@onready var sprite: Sprite2D = $Sprite

func setup(k: String, id: String, b: String = "forest") -> void:
	kind = k
	node_id = id
	biome = b
	# setup() runs after add_child (node already in tree), so (re)build now that
	# kind/id are known — otherwise _ready built with the default kind="tree".
	if is_inside_tree():
		_apply()

func _ready() -> void:
	add_to_group("gather")
	if node_id != "":
		_apply()

func _apply() -> void:
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = int(global_position.y)          # y-sort so the player can walk behind
	_build_sprite()
	if kind == "tree":
		_add_trunk_collision()                # trunk-only: canopy stays walkable
	_set_depleted(not WorldState.node_ready(node_id, RESPAWN.get(kind, 60)))

func _build_sprite() -> void:
	if kind == "lollipop":
		sprite.texture = load("res://assets/game/tiles/candyveil/candy_lollipop_tree_32x48.png")
		sprite.offset = Vector2(0, -16)
	elif kind == "sandstone":
		sprite.texture = load("res://assets/game/tiles/desert/rock.png")
		sprite.scale = Vector2(1.8, 1.6)
	elif kind == "tree":
		# choppable trees use ONLY the approved pine style (snow pines in Frostpeak)
		if biome == "frost":
			_tree_variant = ["tree_pine_snow_a", "tree_pine_snow_b"][_variant_index() % 2]
		else:
			_tree_variant = ["tree_pine_a", "tree_pine_b", "tree_pine_c"][_variant_index()]
		# actual sprite (tree vs stump) is set by _set_depleted below
	else:
		sprite.texture = load("res://assets/game/sprites/props/rock.png")
		sprite.scale = Vector2(1.6, 1.6)
		sprite.modulate = Color(0.85, 0.55, 0.35)
	_hits_left = HITS.get(kind, 3)

func _variant_index() -> int:
	var s := 0
	for i in range(node_id.length()):
		s += node_id.unicode_at(i)
	return s % 3

func _prop(name: String) -> Texture2D:
	return load("res://assets/game/sprites/props/%s.png" % name)

func _show_prop(name: String) -> void:
	var tex := _prop(name)
	sprite.texture = tex
	sprite.offset = Vector2(0, -tex.get_height() * 0.5 + 1)   # base sits at the node origin
	sprite.rotation = 0.0
	sprite.modulate.a = 1.0
	# choppable pines are drawn a touch larger so they read as interactable vs decor
	sprite.scale = Vector2(1.12, 1.12) if name.begins_with("tree_pine") else Vector2.ONE

func _add_trunk_collision() -> void:
	if has_node("Trunk"):
		return
	var body := StaticBody2D.new()
	body.name = "Trunk"
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(7, 6)
	cs.shape = shape
	cs.position = Vector2(0, -1)
	body.add_child(cs)
	add_child(body)

func _process(_delta: float) -> void:
	if _depleted and WorldState.node_ready(node_id, RESPAWN.get(kind, 60)):
		_set_depleted(false)
		_hits_left = HITS.get(kind, 3)
	# first-time gathering tip when the player wanders up to a tree (UI/UX §5)
	if kind == "tree" and not _depleted and "tree" not in PlayerData.onboarding_seen:
		var p := get_tree().get_first_node_in_group("player")
		if p and global_position.distance_to(p.global_position) < 56.0:
			Onboarding.tip("tree")

func can_harvest() -> bool:
	return not _depleted

## Called by WorldController when player interacts nearby.
func harvest() -> bool:
	if _depleted:
		return false
	_hits_left -= 1
	Audio.play_sfx("mine" if kind == "ore" else "dodge")
	if kind == "tree":
		_sway()
	else:
		var tw := create_tween()
		tw.tween_property(sprite, "position:x", 2.0, 0.05)
		tw.tween_property(sprite, "position:x", 0.0, 0.05)
	if _hits_left <= 0:
		_depleted = true                       # lock immediately so it can't be re-hit
		_do_drop()
		WorldState.mark_node_harvested(node_id)
		if kind == "tree":
			await _fall()                      # timber! lean over, then leave a stump
		_set_depleted(true)
	return true

func _sway() -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "rotation", 0.13, 0.06)
	tw.tween_property(sprite, "rotation", -0.06, 0.06)
	tw.tween_property(sprite, "rotation", 0.0, 0.08)

func _fall() -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(sprite, "rotation", 1.35, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(sprite, "modulate:a", 0.0, 0.4)
	await tw.finished

func _do_drop() -> void:
	var prof := "miner" if kind in ["ore", "sandstone"] else "lumberjack"
	var bonus := int(ProfessionSystem.perk_value(prof, "bonus_yield"))
	var report_kind := "ore" if kind in ["ore", "sandstone"] else "tree"
	var table := Db.loot_table(LOOT.get(kind, ""))
	for d in table:
		if randf() <= float(d.get("chance", 1.0)):
			var qty := randi_range(int(d.get("min", 1)), int(d.get("max", 1))) + bonus
			if GameClock.is_morning_dew():
				qty += 1   # MORNING DEW 05.00–07.00: panen +1 (v0.2 §6.2, v0.4.1)
			PlayerData.add_item(d.get("item", ""), qty)
			EventBus.node_harvested.emit(report_kind, d.get("item", ""), qty)
	EventBus.toast.emit("Memanen %s" % ("kayu" if kind == "tree" else "tembaga"))

func _set_depleted(v: bool) -> void:
	_depleted = v
	if kind == "tree":
		if v:
			_show_prop("stump")               # chopped -> stump (regrows on respawn)
		else:
			_show_prop(_tree_variant)          # regrown pine
		modulate.a = 1.0
	else:
		modulate.a = 0.35 if v else 1.0
