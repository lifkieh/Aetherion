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

@onready var sprite: Sprite2D = $Sprite

func setup(k: String, id: String) -> void:
	kind = k
	node_id = id
	# setup() runs after add_child (node already in tree), so (re)build now that
	# kind/id are known — otherwise _ready built with the default kind="tree".
	if is_inside_tree():
		_apply()

func _ready() -> void:
	add_to_group("gather")
	if node_id != "":
		_apply()

func _apply() -> void:
	_build_sprite()
	_set_depleted(not WorldState.node_ready(node_id, RESPAWN.get(kind, 60)))

func _build_sprite() -> void:
	if kind == "lollipop":
		sprite.texture = load("res://assets/game/tiles/candyveil/candy_lollipop_tree_32x48.png")
		sprite.offset = Vector2(0, -16)
	elif kind == "sandstone":
		sprite.texture = load("res://assets/game/tiles/desert/rock.png")
		sprite.scale = Vector2(1.8, 1.6)
	elif kind == "tree":
		var at := AtlasTexture.new()
		at.atlas = load("res://assets/game/tiles/nature.png")
		at.region = Rect2(16, 48, 32, 32)
		sprite.texture = at
		sprite.offset = Vector2(0, -8)
	else:
		sprite.texture = load("res://assets/game/sprites/props/rock.png")
		sprite.scale = Vector2(1.6, 1.6)
		sprite.modulate = Color(0.85, 0.55, 0.35)
	_hits_left = HITS.get(kind, 3)

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
	var tw := create_tween()
	tw.tween_property(sprite, "position:x", 2.0, 0.05)
	tw.tween_property(sprite, "position:x", 0.0, 0.05)
	if _hits_left <= 0:
		_do_drop()
		_set_depleted(true)
		WorldState.mark_node_harvested(node_id)
	return true

func _do_drop() -> void:
	var prof := "miner" if kind in ["ore", "sandstone"] else "lumberjack"
	var bonus := int(ProfessionSystem.perk_value(prof, "bonus_yield"))
	var report_kind := "ore" if kind in ["ore", "sandstone"] else "tree"
	var table := Db.loot_table(LOOT.get(kind, ""))
	for d in table:
		if randf() <= float(d.get("chance", 1.0)):
			var qty := randi_range(int(d.get("min", 1)), int(d.get("max", 1))) + bonus
			PlayerData.add_item(d.get("item", ""), qty)
			EventBus.node_harvested.emit(report_kind, d.get("item", ""), qty)
	EventBus.toast.emit("Memanen %s" % ("kayu" if kind == "tree" else "tembaga"))

func _set_depleted(v: bool) -> void:
	_depleted = v
	modulate.a = 0.35 if v else 1.0
