class_name DungeonBase
extends Node2D
## Shared side-view dungeon logic (owner directive). Subclasses override cfg()
## to theme a dungeon; everything else (terrain, lighting, spawns, boss, exit,
## perf hook) is reused — no per-dungeon duplication.

const TILE := 32   # R1 #286: ikut DungeonTerrain.TILE — dua konstanta, satu nilai (audit C3)
var W := 46
var H := 46
var _light_tex: Texture2D
var _boss_alive := true
var _shot_at := -1.0
var _secret_rect := Rect2i()   # rongga rahasia (v0.4.3 #6)
var player: Node

## Override this in each dungeon.
func cfg() -> Dictionary:
	return {
		"id": "dungeon", "name": "Gua Bawah Tanah", "w": 46, "h": 46,
		"bg": Color(0.10, 0.09, 0.13), "ambient": Color(0.16, 0.15, 0.22),
		"tile_tint": Color(1, 1, 1),
		"spawn_kinds": ["cave_bat", "verdant_slime", "cave_spitter"],
		"boss": "king_slime", "music": "dungeon.ogg",
		"torch_color": Color(1.0, 0.7, 0.4),
		"return_scene": "res://scenes/Main.tscn", "exit_label": "Keluar [E]",
		"hint": "Klik-kiri: serang (arah kursor) · Klik-kanan: skill · WASD gerak · Space lompat · gali blok · E keluar",
		"intro": "Dungeon — kalahkan bos di dasar.",
	}

func _ready() -> void:
	randomize()
	var c := cfg()
	W = c.get("w", 46)
	H = c.get("h", 46)
	_light_tex = _make_light_texture()
	var terrain := preload("res://scenes/world/DungeonTerrain.tscn").instantiate()
	add_child(terrain)
	terrain.build_from(_layout(c), c.get("tile_tint", Color.WHITE))
	_build_background(c.get("bg", Color(0.1, 0.09, 0.13)))
	# PARALLAX + AMBIENCE (v0.4.3 #98) — Mode Hemat mematikan keduanya
	DungeonParallax.attach(self, c.get("parallax_tint", c.get("torch_color", Color(0.5, 0.55, 0.7))), c.get("id", "dungeon"))
	DungeonAmbience.attach(self)
	_build_lighting(c.get("ambient", Color(0.16, 0.15, 0.22)))
	_spawn_player()
	_place_torches(c.get("torch_color", Color(1.0, 0.7, 0.4)))
	_spawn_monsters(c.get("spawn_kinds", []))
	_place_chests()      # peti + peti rahasia (v0.4.3 #6)
	_place_traps()       # paku & panah (telegraf, tak pernah membunuh dari full HP)
	_spawn_boss(c.get("boss", ""))
	_place_exit(c.get("return_scene", "res://scenes/Main.tscn"), c.get("exit_label", "Keluar [E]"))
	_add_ui(c.get("hint", ""))
	SafeZone.clear()   # dungeons are never safe zones (UI/UX §4)
	Stage.enter_region(c.get("name", "Dungeon"), c.get("intro", ""), c.get("music", "dungeon.ogg"))
	EventBus.dungeon_entered.emit(c.get("id", "dungeon"))
	if OS.get_environment("AETHER_ARENA") == "1" and player:
		player.global_position = Vector2(W * TILE * 0.5, (H - 5) * TILE)
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.8
	if OS.get_environment("AETHER_PERF") == "1":
		_perf_probe()

func _process(delta: float) -> void:
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit()

func _physics_process(_delta: float) -> void:
	for c in get_children():
		if c is PointLight2D and c.has_meta("follow") and is_instance_valid(player):
			c.global_position = player.global_position

# --- Layout (3 floors + arena; parameterized) -------------------------------

func _layout(c: Dictionary) -> Array:
	var g: Array = []
	for y in range(H):
		var row: Array = []
		for x in range(W):
			row.append(" ")
		g.append(row)
	for x in range(W):
		g[0][x] = "B"; g[H - 1][x] = "B"; g[H - 2][x] = "B"
	for y in range(H):
		g[y][0] = "B"; g[y][W - 1] = "B"
	var ore_freq: float = c.get("ore_freq", 0.10)
	var draw_floor := func(fy: int, gap: int):
		for x in range(1, W - 1):
			if absi(x - gap) > 1:
				g[fy][x] = "#" if randf() > 0.18 else "D"
				if randf() < ore_freq:
					g[fy][x] = "O"
	draw_floor.call(11, 9)
	for y in range(12, 20): g[y][9] = "H"
	draw_floor.call(21, W - 10)
	for y in range(22, 30): g[y][W - 10] = "H"
	draw_floor.call(31, 9)
	for y in range(32, 43): g[y][9] = "H"
	for p in [[16, 6], [16, 30], [26, 14], [26, W - 6], [36, 20], [36, 30]]:
		for dx in range(4):
			if p[1] + dx < W - 1:
				g[p[0]][p[1] + dx] = "="
	for i in range(24):
		var ox := (2 if randf() < 0.5 else W - 3)
		var oy := randi_range(3, H - 4)
		if g[oy][ox] == " ":
			g[oy][ox] = "O"
	for x in range(1, W - 1):
		g[H - 3][x] = "B"
	# RUANG RAHASIA (v0.4.3 #6): rongga tertutup penuh oleh blok yang bisa digali —
	# tak ada pintu, tak ada petunjuk. Hanya yang menggali yang menemukannya.
	_secret_rect = _carve_secret(g)
	var out: Array = []
	for row in g:
		out.append("".join(row))
	return out

## Rongga 5x3 di dinding samping, ditutup rapat blok "#" (bisa digali).
## Mengembalikan Rect2i sel rongga (kosong bila gagal).
func _carve_secret(g: Array) -> Rect2i:
	var candidates := [Vector2i(W - 9, 15), Vector2i(3, 25), Vector2i(W - 9, 35)]
	var pick: Vector2i = candidates[randi() % candidates.size()]
	if pick.x < 2 or pick.x + 5 >= W - 1 or pick.y + 3 >= H - 3:
		return Rect2i()
	for y in range(pick.y - 1, pick.y + 4):
		for x in range(pick.x - 1, pick.x + 6):
			if y < 1 or y >= H - 3 or x < 1 or x >= W - 1:
				continue
			g[y][x] = "#"          # cangkang: blok biasa yang bisa digali
	for y in range(pick.y, pick.y + 3):
		for x in range(pick.x, pick.x + 5):
			g[y][x] = " "          # rongga di dalamnya
	return Rect2i(pick.x, pick.y, 5, 3)

# --- Peti & jebakan (v0.4.3 #6) ---------------------------------------------

## Peti biasa di tiap lantai + peti rahasia di dalam rongga tersembunyi.
func _place_chests() -> void:
	var c := cfg()
	var did: String = c.get("id", "dungeon")
	# umum, LANGKA (lantai tengah — lebih jauh, lebih berisi), umum
	var spots := [[Vector2(W - 8, 10), "chest_common"], [Vector2(6, 20), "chest_rare"],
		[Vector2(W - 12, 30), "chest_common"]]
	var i := 0
	for sp in spots:
		DungeonChest.spawn(self, Vector2(sp[0].x * TILE, sp[0].y * TILE - 4),
			"%s_c%d" % [did, i], sp[1], false)
		i += 1
	if _secret_rect.size.x > 0:
		var center := Vector2(
			(_secret_rect.position.x + 2) * TILE + TILE * 0.5,
			(_secret_rect.position.y + 2) * TILE - 4)
		DungeonChest.spawn(self, center, "%s_secret" % did, c.get("secret_table", "chest_secret"), true)

## Jebakan: paku di lantai (terlihat) + panah dinding (telegraf sebelum menembak).
func _place_traps() -> void:
	for fy in [11, 21, 31]:
		for k in 3:
			var x := randi_range(4, W - 6)
			DungeonTrap.spawn(self, Vector2(x * TILE + TILE * 0.5, fy * TILE - 5), "spike")
	for fy in [16, 26, 36]:
		DungeonTrap.spawn(self, Vector2(randi_range(8, W - 10) * TILE, fy * TILE), "dart")

# --- Build helpers (shared) -------------------------------------------------

func _build_background(col: Color) -> void:
	var bg := ColorRect.new()
	bg.color = col
	bg.size = Vector2(W * TILE, H * TILE)
	bg.z_index = -20
	add_child(bg)

func _build_lighting(ambient: Color) -> void:
	var cm := CanvasModulate.new()
	cm.color = ambient
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

func _place_torches(tcol: Color) -> void:
	for fy in [11, 21, 31, H - 3]:
		for x in range(4, W - 4, 8):
			var tp := Vector2(x * TILE + TILE / 2.0, fy * TILE - 16)
			var spr := Sprite2D.new()
			spr.texture = load("res://assets/game/sprites/dungeon/torch.png")
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.scale = Vector2(2, 2)   # obor 16px di dunia 32 (#286) — sementara sampai obor 32 digambar
			spr.position = tp
			spr.z_index = 2
			add_child(spr)
			_add_light(tp + Vector2(0, -8), tcol, 1.1, 0.9)

func _spawn_player() -> void:
	player = preload("res://scenes/actors/PlayerPlatformer.tscn").instantiate()
	player.global_position = Vector2(4 * TILE, 9 * TILE)
	add_child(player)
	var pl := _add_light(Vector2.ZERO, Color(0.9, 0.9, 1.0), 0.9, 1.1)
	pl.set_meta("follow", true)
	var marker := Marker2D.new()
	marker.add_to_group("dungeon_spawn")
	marker.global_position = player.global_position
	add_child(marker)

func _spawn_monsters(kinds: Array) -> void:
	if kinds.is_empty():
		return
	var floors := [11, 21, 31]
	for fi in range(floors.size()):
		var fy: int = floors[fi]
		for i in range(2):
			var species: String = kinds[(fi + i) % kinds.size()]
			var inst := MonsterFactory.make(species, 12, 3)
			if inst.is_empty():
				continue
			var m := preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
			add_child(m)
			m.global_position = Vector2(randf_range(14, W - 14) * TILE, (fy - 2) * TILE)
			m.setup(inst, self)

func _spawn_boss(species: String) -> void:
	if species == "":
		return
	var inst := MonsterFactory.make(species, 15, 4)
	if inst.is_empty():
		return
	var m := preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(m)
	m.global_position = Vector2(W * TILE * 0.5, (H - 5) * TILE)
	m.setup(inst, self)

func on_monster_died(m) -> void:
	if m and is_instance_valid(m) and m.inst.get("is_boss", false):
		_boss_alive = false
		EventBus.toast.emit("★ Bos dikalahkan! Jalan pulang terbuka.")
		Audio.play_sfx("secret")

func _place_exit(return_scene: String, label: String) -> void:
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup(return_scene, label)
	portal.global_position = Vector2(4 * TILE, 9 * TILE)

func _add_ui(hint: String) -> void:
	var hud := preload("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	if hint != "":
		hud.call_deferred("set_hint", hint)
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())

func _perf_probe() -> void:
	get_tree().create_timer(2.0).timeout.connect(func():
		var terr = get_tree().get_first_node_in_group("terrain")
		print("[perf] scene_nodes=%d collision_strips=%d fps=%.1f monsters=%d" % [
			get_tree().get_node_count(),
			(terr.collision_node_count() if terr else -1),
			Engine.get_frames_per_second(),
			get_tree().get_nodes_in_group("monsters").size()])
		get_tree().quit())
