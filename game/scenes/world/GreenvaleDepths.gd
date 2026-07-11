extends Node2D
## Greenvale Depths — the King Slime dungeon, PILOT for the side-view platformer
## format (owner decision 2026-07-11). 3 vertical floors + boss arena at the
## bottom. Dark + torch lighting, mineable copper veins, ladders & platforms.

const TILE := 16
const W := 46
const H := 46
const DUNGEON_ID := "greenvale_depths"

var player: Node
var _light_tex: Texture2D
var _boss_alive := true
var _shot_at := -1.0

func _ready() -> void:
	randomize()
	_light_tex = _make_light_texture()
	var terrain := preload("res://scenes/world/DungeonTerrain.tscn").instantiate()
	add_child(terrain)
	terrain.build_from(_layout())
	_build_background()
	_build_lighting()
	_spawn_player()
	_place_torches()
	_spawn_monsters()
	_spawn_boss()
	_place_exit()
	_place_puddles()
	_add_ui()

func _place_puddles() -> void:
	# a puddle spanning a floor gap — Ice-flow (key 2 = lightning; use skill/infuse)
	# freezes it into a bridge (element platformer rule).
	for spot in [Vector2(20 * TILE, 21 * TILE - 6), Vector2(30 * TILE, 31 * TILE - 6)]:
		var pud := preload("res://scenes/world/Puddle.tscn").instantiate()
		add_child(pud)
		pud.setup(3)
		pud.global_position = spot
	Audio.play_music("23 - Road.ogg")
	EventBus.dungeon_entered.emit(DUNGEON_ID)
	EventBus.toast.emit("Greenvale Depths — J untuk tebas & gali; naik/panjat tangga; kalahkan King Slime di dasar.")
	if OS.get_environment("AETHER_ARENA") == "1" and player:
		player.global_position = Vector2(W * TILE * 0.5, (H - 5) * TILE)
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.8
	if OS.get_environment("AETHER_PERF") == "1":
		var t := get_tree().create_timer(2.0)
		t.timeout.connect(func():
			var terr = get_tree().get_first_node_in_group("terrain")
			print("[perf] scene_nodes=%d collision_strips=%d fps=%.1f monsters=%d lights=%d" % [
				get_tree().get_node_count(),
				(terr.collision_node_count() if terr else -1),
				Engine.get_frames_per_second(),
				get_tree().get_nodes_in_group("monsters").size(),
				_count_lights()])
			get_tree().quit())

func _count_lights() -> int:
	var n := 0
	for c in get_children():
		if c is PointLight2D:
			n += 1
	return n

func _process(delta: float) -> void:
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit()

# --- Layout (ASCII, controlled level design) --------------------------------

func _layout() -> Array:
	var g: Array = []
	for y in range(H):
		var row: Array = []
		for x in range(W):
			row.append(" ")
		g.append(row)
	# bedrock border (undiggable frame)
	for x in range(W):
		g[0][x] = "B"; g[H - 1][x] = "B"; g[H - 2][x] = "B"
	for y in range(H):
		g[y][0] = "B"; g[y][W - 1] = "B"
	# helper to draw a floor slab with a ladder gap
	var draw_floor := func(fy: int, gap: int):
		for x in range(1, W - 1):
			if absi(x - gap) > 1:
				g[fy][x] = "#" if randf() > 0.18 else "D"
				if randf() < 0.10:
					g[fy][x] = "O"   # copper vein in the floor
	# three floors + ladders through their gaps
	draw_floor.call(11, 9)
	for y in range(12, 20): g[y][9] = "H"
	draw_floor.call(21, 36)
	for y in range(22, 30): g[y][36] = "H"
	draw_floor.call(31, 9)
	for y in range(32, 43): g[y][9] = "H"
	# mid-air one-way platforms for verticality
	for p in [[16, 6], [16, 30], [26, 14], [26, 40], [36, 20], [36, 30]]:
		for dx in range(4):
			g[p[0]][p[1] + dx] = "="
	# ore pockets embedded in the side walls (mine into the wall)
	for i in range(24):
		var ox := (2 if randf() < 0.5 else W - 3)
		var oy := randi_range(3, H - 4)
		if g[oy][ox] == " ":
			g[oy][ox] = "O"
	# boss arena floor (solid bedrock so you can't dig out) at row H-3
	for x in range(1, W - 1):
		g[H - 3][x] = "B"
	var out: Array = []
	for row in g:
		out.append("".join(row))
	return out

# --- Visuals / lighting -----------------------------------------------------

func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.09, 0.13)
	bg.size = Vector2(W * TILE, H * TILE)
	bg.z_index = -20
	add_child(bg)

func _build_lighting() -> void:
	var cm := CanvasModulate.new()
	cm.color = Color(0.16, 0.15, 0.22)   # dark cave
	add_child(cm)

func _make_light_texture() -> Texture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 160
	gt.height = 160
	return gt

func _add_light(pos: Vector2, color: Color, energy: float, scale: float) -> PointLight2D:
	var l := PointLight2D.new()
	l.texture = _light_tex
	l.color = color
	l.energy = energy
	l.texture_scale = scale
	l.position = pos
	add_child(l)
	return l

func _place_torches() -> void:
	# a torch every few tiles along the floors
	for fy in [11, 21, 31, H - 3]:
		for x in range(4, W - 4, 8):
			var tp := Vector2(x * TILE + TILE / 2.0, fy * TILE - 8)
			var spr := Sprite2D.new()
			spr.texture = load("res://assets/game/sprites/dungeon/torch.png")
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = tp
			spr.z_index = 2
			add_child(spr)
			_add_light(tp + Vector2(0, -4), Color(1.0, 0.7, 0.4), 1.1, 0.9)

# --- Actors -----------------------------------------------------------------

func _spawn_player() -> void:
	player = preload("res://scenes/actors/PlayerPlatformer.tscn").instantiate()
	player.global_position = Vector2(4 * TILE, 9 * TILE)
	add_child(player)
	# carried light
	var pl := _add_light(Vector2.ZERO, Color(0.9, 0.9, 1.0), 0.9, 1.1)
	pl.set_meta("follow", true)
	# spawn marker for death respawn
	var marker := Marker2D.new()
	marker.add_to_group("dungeon_spawn")
	marker.global_position = player.global_position
	add_child(marker)

func _physics_process(_delta: float) -> void:
	# keep the carried light on the player
	for c in get_children():
		if c is PointLight2D and c.has_meta("follow") and is_instance_valid(player):
			c.global_position = player.global_position

func _spawn_monsters() -> void:
	var floors := [11, 21, 31]
	var kinds := ["cave_bat", "verdant_slime", "cave_spitter"]   # flyer / jumper / shooter
	for fi in range(floors.size()):
		var fy: int = floors[fi]
		for i in range(2):
			var species: String = kinds[(fi + i) % kinds.size()]
			var inst := MonsterFactory.make(species, 12, 3)
			var m := preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
			add_child(m)
			m.global_position = Vector2(randf_range(14, W - 14) * TILE, (fy - 2) * TILE)
			m.setup(inst, self)

func _spawn_boss() -> void:
	var inst := MonsterFactory.make("king_slime", 15, 4)
	var m := preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(m)
	m.global_position = Vector2(W * TILE * 0.5, (H - 5) * TILE)
	m.setup(inst, self)

func on_monster_died(m) -> void:
	if m and is_instance_valid(m) and m.inst.get("is_boss", false):
		_boss_alive = false
		EventBus.toast.emit("★ King Slime dikalahkan! Jalan pulang terbuka.")
		Audio.play_sfx("secret")

func _place_exit() -> void:
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup("res://scenes/Main.tscn", "Keluar ke Greenvale [E]")
	portal.global_position = Vector2(4 * TILE, 9 * TILE)

func _add_ui() -> void:
	var hud := preload("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	hud.call_deferred("set_hint", "Klik-kiri: serang (arah kursor) · Klik-kanan: skill · WASD gerak · Space lompat · panjat tangga · gali blok · E keluar")
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())
