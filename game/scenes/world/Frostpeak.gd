extends Node2D
## Frostpeak Mountain (v0.3, Monster_Roster §2.4) — a snowbound region built from
## procedural snow/ice tiles. Level 22-38. Ice/Wind monsters; falling snow ambience;
## pine + snow-pine forest (WildDresser "frost"). Reached from Greenvale's north gate.

const TILE := 16
const MAP_W := 70
const MAP_H := 52
const SPAWN_TABLE := ["frost_fox", "ice_wolf", "snow_owl", "yeti_cub", "ice_wolf",
	"frost_fox", "frost_elemental", "woolly_calf", "frost_wyvern"]
const MAX_MONSTERS := 12

var canvas_mod: CanvasModulate
var player
var _monster_count := 0
var _spawn_timer := 0.0
var _shot_at := -1.0

func _ready() -> void:
	randomize()
	_build_ground()
	_build_boundaries()
	_dress_wild()
	_build_sky()
	SafeZone.set_region("frostpeak")   # the climber outpost is a safe zone
	_spawn_player()
	_spawn_gathering()
	_add_ui()
	_build_village()
	_prime_monsters()
	Stage.enter_region("Frostpeak", "Puncak beku — salju abadi & angin menggigit", "26 - Lost Village.ogg")
	EventBus.toast.emit("Frostpeak Mountain — awas Yeti! Es abadi tak pernah mencair.")
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.6
	if OS.get_environment("AETHER_FPS") == "1":
		get_tree().create_timer(4.0).timeout.connect(func():
			print("[fps] Frostpeak fps=%.1f nodes=%d" % [Engine.get_frames_per_second(), get_tree().get_node_count()])
			get_tree().quit())

const VC := Vector2(560, 640)   # village centre

func _dress_wild() -> void:
	var avoid := [Rect2(VC - Vector2(240, 200), Vector2(480, 400))]   # keep the village clear
	WildDresser.dress(self, "frost", MAP_W, MAP_H, avoid, [])
	var amb := Node2D.new()
	amb.set_script(load("res://scenes/systems/Ambience.gd"))
	add_child(amb)
	amb.setup("snow")

func _process(delta: float) -> void:
	if canvas_mod:
		canvas_mod.color = GameClock.ambient_color().lerp(Color(0.82, 0.9, 1.05), 0.28)  # cold blue-white
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = 3.0
		if _monster_count < MAX_MONSTERS:
			_spawn_one()
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit()

func _tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	for i in [["snow_0", 0], ["snow_1", 1], ["ice_patch", 2]]:
		var src := TileSetAtlasSource.new()
		src.texture = load("res://assets/game/tiles/%s.png" % i[0])
		src.texture_region_size = Vector2i(TILE, TILE)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src, i[1])
	return ts

func _build_ground() -> void:
	var ground := TileMapLayer.new()
	ground.tile_set = _tileset()
	add_child(ground)
	for y in range(MAP_H):
		for x in range(MAP_W):
			var sid := 0
			var r := randf()
			if r < 0.22:
				sid = 1
			elif r < 0.27:
				sid = 2       # icy patch
			ground.set_cell(Vector2i(x, y), sid, Vector2i(0, 0))

func _build_boundaries() -> void:
	var walls := StaticBody2D.new()
	walls.collision_layer = 4
	walls.collision_mask = 0
	add_child(walls)
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	for rc in [Rect2(-16, -16, w + 32, 16), Rect2(-16, h, w + 32, 16), Rect2(-16, 0, 16, h), Rect2(w, 0, 16, h)]:
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rc.size
		cs.shape = shape
		cs.position = rc.position + rc.size / 2
		walls.add_child(cs)

func _build_sky() -> void:
	canvas_mod = CanvasModulate.new()
	add_child(canvas_mod)

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	if WorldState.pending_return_pos != null:
		player.global_position = WorldState.pending_return_pos
		WorldState.pending_return_pos = null
	else:
		player.global_position = VC + Vector2(0, 90)   # arrive at the outpost
	add_child(player)

func _add_ui() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())
	var pm := Node.new()
	pm.set_script(load("res://scenes/systems/PetManager.gd"))
	add_child(pm)
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup("res://scenes/Main.tscn", "Kembali ke Greenvale [E]")
	portal.global_position = Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 32)

func _spawn_gathering() -> void:
	var holder := Node2D.new()
	holder.y_sort_enabled = true
	add_child(holder)
	for i in range(12):
		var node := preload("res://scenes/world/GatherNode.tscn").instantiate()
		holder.add_child(node)
		node.global_position = Vector2(randf_range(48, MAP_W * TILE - 48), randf_range(48, MAP_H * TILE - 48))
		node.setup("tree", "fp_tree_%d" % i, "frost")

func _prime_monsters() -> void:
	for i in range(8):
		_spawn_one()

func _spawn_one() -> void:
	var species: String = SPAWN_TABLE[randi() % SPAWN_TABLE.size()]
	if not MonsterFactory.spawnable_now(species):
		return   # nokturnal hanya malam (v0.4.1)
	var inst := MonsterFactory.make(species)
	if inst.is_empty():
		return
	var pos := Vector2(randf_range(64, MAP_W * TILE - 64), randf_range(64, MAP_H * TILE - 64))
	for _t in range(6):
		if not SafeZone.contains(pos) and not (player and pos.distance_to(player.global_position) < 120):
			break
		pos = Vector2(randf_range(64, MAP_W * TILE - 64), randf_range(64, MAP_H * TILE - 64))
	if SafeZone.contains(pos):
		return
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	m.global_position = pos
	m.setup(inst, self)
	_monster_count += 1

func on_monster_died(_m) -> void:
	_monster_count = max(0, _monster_count - 1)

# --- climber outpost village (CharGen NPCs; v0.2.1 density) ------------------

func _frost_cfg(race: String, hair: String, hc: String, shirt: String, pants: String) -> Dictionary:
	return {"head_race": race, "torso_race": race, "legs_race": race,
		"hair": hair, "hair_color": hc, "shirt": shirt, "pants": pants}

func _build_village() -> void:
	var snow := Color(0.85, 0.92, 1.05)
	# cobble ground patch under the outpost
	var ts := TileSet.new(); ts.tile_size = Vector2i(TILE, TILE)
	for t in ["cobble_0", "cobble_1"]:
		var src := TileSetAtlasSource.new(); src.texture = load("res://assets/game/tiles/%s.png" % t)
		src.texture_region_size = Vector2i(TILE, TILE); src.create_tile(Vector2i(0, 0)); ts.add_source(src)
	var gl := TileMapLayer.new(); gl.tile_set = ts; gl.z_index = 1; add_child(gl)
	var ct := Vector2i(int(VC.x / TILE), int(VC.y / TILE))
	for y in range(ct.y - 9, ct.y + 10):
		for x in range(ct.x - 12, ct.x + 13):
			gl.set_cell(Vector2i(x, y), randi() % 2, Vector2i(0, 0))
	# buildings (frost-tinted) with doors
	var blds := [
		["inn", 74, 98, Vector2(-120, -70), "Penginapan Pendaki", "inn"],
		["store", 74, 66, Vector2(120, -60), "Toko Perbekalan", "store"],
		["house_blue", 58, 62, Vector2(-110, 70), "Pondok", "house"],
		["house_green", 58, 62, Vector2(110, 70), "Pondok", "house"],
	]
	for b in blds:
		var spr := Sprite2D.new()
		spr.texture = load("res://assets/game/sprites/buildings/%s.png" % b[0])
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.modulate = snow
		spr.global_position = VC + b[3]
		spr.z_index = int(spr.global_position.y + b[2] * 0.5)
		add_child(spr)
		var body := StaticBody2D.new(); body.global_position = VC + b[3]
		var cs := CollisionShape2D.new(); var sh := RectangleShape2D.new()
		sh.size = Vector2(b[1] - 10, b[2] * 0.42); cs.shape = sh; cs.position = Vector2(0, -b[2] * 0.08)
		body.add_child(cs); add_child(body)
		var door := preload("res://scenes/world/Interactable.tscn").instantiate()
		door.kind = "house_door"; door.custom_label = "%s [E]" % b[4]; door.interior_variant = b[5]
		add_child(door); door.global_position = VC + b[3] + Vector2(0, b[2] * 0.5 - 4)
	# service NPC (human trader) + deco
	_vnpc("shop", VC + Vector2(150, -10))
	_keeper(VC + Vector2(-90, 40), "frostpeak_village")   # Penjaga Pohon Es (#30)
	for d in [["crate", Vector2(-150, -20)], ["barrel", Vector2(-138, -12)], ["hay", Vector2(150, 60)], ["barrel", Vector2(90, -10)]]:
		var s := Sprite2D.new(); s.texture = load("res://assets/game/sprites/props/%s.png" % d[0])
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST; s.global_position = VC + d[1]
		s.z_index = int(s.global_position.y); add_child(s)
	# walking villagers — frostkin / wolfkin / bundled humans (a climber mix)
	var routes := [
		["Kael (Frostkin)", _frost_cfg("frostkin", "spiky", "#eefaff", "#1e3a5c", "#3a6fa0"), [Vector2(-80, 0), Vector2(80, 10), Vector2(60, 90)]],
		["Vora (Frostkin)", _frost_cfg("frostkin", "long", "#b8e4f2", "#3a6fa0", "#1e3a5c"), [Vector2(60, -40), Vector2(-60, -20), Vector2(-100, 40)]],
		["Grum (Wolfkin)", _frost_cfg("wolfkin", "none", "#241f36", "#8f2611", "#453d5c"), [Vector2(0, 60), Vector2(120, 90), Vector2(-40, 100)]],
		["Ibu Sena", {"head_race": "human", "torso_race": "wolfkin", "legs_race": "human", "hair": "long", "hair_color": "#3a2a1a", "shirt": "#5c4a3a", "pants": "#3a2a1a"}, [Vector2(-120, 60), Vector2(-40, 30), Vector2(-140, 20)]],
		["Pak Tuor", _frost_cfg("human", "short", "#e8e2f4", "#453d5c", "#2b2b3a"), [Vector2(90, 40), Vector2(150, 100), Vector2(60, 70)]],
	]
	for r in routes:
		var v := preload("res://scenes/actors/Villager.tscn").instantiate()
		var wps: Array = []
		for w in r[2]: wps.append(VC + w)
		add_child(v); v.setup(r[0], r[1], wps); v.global_position = wps[0]
	# gate guards + the Foothill Barrow dungeon entrance
	for g in SafeZone.gates():
		var guard := Node2D.new(); guard.set_script(load("res://scenes/actors/Guard.gd"))
		add_child(guard); guard.global_position = g
	var barrow := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(barrow)
	barrow.dungeon_scene = "res://scenes/world/FoothillBarrow.tscn"
	barrow.dungeon_label = "Foothill Barrow ▼ [E]"
	barrow.setup("dungeon")
	barrow.global_position = VC + Vector2(240, -120)

func _vnpc(kind: String, pos: Vector2) -> void:
	var n := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(n); n.setup(kind); n.global_position = pos

func _keeper(pos: Vector2, loc: String) -> void:
	var n := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(n); n.setup("tree_keeper"); n.keeper_location = loc; n.global_position = pos
