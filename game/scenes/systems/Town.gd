class_name Town
extends RefCounted
## Town builder (R2 Part 1) — turns the Greenvale plaza into a dense, believable town:
## cobbled streets, 10 facaded buildings (collision + doors + signs), a central well,
## night street-lamps, fences, market deco, NPCs at logical posts, strolling villagers
## and small animals. Everything is added as children of `host` (Main).

const TILE := 32   # R2 #286: kota Greenvale ikut petak 32 — layout tetap, skala naik
const S := 2.0     # pengali offset piksel tulisan-tangan era 16px (posisi relatif center)
const P_L := "res://assets/game/sprites/lpc32/"
const BDIR := "res://assets/game/sprites/buildings/"
const PDIR := "res://assets/game/sprites/props/"

# Building table: sprite, size, offset-from-center, sign label, door target
# door: "" = solid landmark, "house"/"blacksmith"/"inn"/"store" = enterable interior
static func _buildings() -> Array:
	# R2 #286: fasad lpc32 (keluarga visual Ashbrook64) menggantikan sprite 16px.
	# w/h = dimensi fasad nyata (diukur); off = offset lama x2. `tint` membedakan
	# tiga rumah warga yang memakai fasad sama (pengganti house_red/green/blue).
	return [
		{"spr": "fasad_datar_lebar", "w": 160, "h": 160, "off": Vector2(-500, -240), "sign": "Bengkel Pandai Besi", "door": "blacksmith"},
		{"spr": "fasad_balai",       "w": 160, "h": 288, "off": Vector2(0, -300),    "sign": "Balai Kota",          "door": ""},
		{"spr": "fasad_inn",         "w": 160, "h": 224, "off": Vector2(500, -236),  "sign": "Penginapan Rusa Emas","door": "inn"},
		{"spr": "fasad_datar_tinggi","w": 96,  "h": 256, "off": Vector2(-660, 40),   "sign": "Menara Astrolog",     "door": ""},
		{"spr": "fasad_shop",        "w": 96,  "h": 192, "off": Vector2(660, 60),    "sign": "Toko Umum",           "door": "store"},
		{"spr": "fasad_rumah",       "w": 160, "h": 192, "off": Vector2(-500, 350),  "sign": "Rumah Warga",         "door": "house", "tint": Color(1.0, 0.82, 0.82)},
		{"spr": "fasad_rumah",       "w": 160, "h": 192, "off": Vector2(-184, 380),  "sign": "Rumah Warga",         "door": "house", "tint": Color(0.84, 1.0, 0.86)},
		{"spr": "fasad_rumah",       "w": 160, "h": 192, "off": Vector2(220, 380),   "sign": "Rumah Warga",         "door": "house", "tint": Color(0.84, 0.9, 1.0)},
		{"spr": "fasad_gudang",      "w": 160, "h": 192, "off": Vector2(576, 340),   "sign": "Kandang",             "door": ""},
	]

static func build(host: Node2D, center: Vector2) -> void:
	_paint_ground(host, center)
	_place_buildings(host, center)
	_place_well(host, center)
	_place_lamps(host, center)
	_place_fences(host, center)
	_place_deco(host, center)
	_place_npcs(host, center)
	_place_villagers(host, center)
	_place_animals(host, center)
	TownFolk.place(host, "greenvale", center, 60)      # Hukum NPC Aneh (E6 #78) — LPC warga_060.. (#286)
	MiracleSystem.manifest(host, center, 520.0)        # keajaiban hari ini (E7 #79) — radius 2x

# --- cobbled ground ---------------------------------------------------------

static func _paint_ground(host: Node2D, center: Vector2) -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	# lpc32 (R2 #286): perkerasan yang sama dengan Ashbrook64.
	# pelataran32 TERNYATA bertekstur rumput-injak (mata, v2/v3) — variasi halus
	# perkerasan memakai stone32; tanah tetap aksen langka.
	for i in ["cobble32", "stone32", "ladang_tanah32"]:
		var src := TileSetAtlasSource.new()
		src.texture = load("res://assets/game/tiles/lpc32/%s.png" % i)
		src.texture_region_size = Vector2i(TILE, TILE)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src)
	var layer := TileMapLayer.new()
	layer.name = "TownGround"
	layer.tile_set = ts
	layer.z_index = 1          # overlay the grass base (which is z 0); below actors
	host.add_child(layer)
	var ct := Vector2i(int(center.x / TILE), int(center.y / TILE))
	# generous central plaza
	for y in range(ct.y - 9, ct.y + 11):
		for x in range(ct.x - 15, ct.x + 16):
			_cobble(layer, x, y)
	# wide cross roads to the four edges
	for x in range(ct.x - 26, ct.x + 27):
		for dy in [-2, -1, 0, 1, 2]:
			_cobble(layer, x, ct.y + dy)
	for y in range(ct.y - 22, ct.y + 24):
		for dx in [-2, -1, 0, 1, 2]:
			_cobble(layer, ct.x + dx, y)
	# a cobble yard around each building (door + frontage meets the street)
	for b in _buildings():
		var d: Vector2 = center + b.off + Vector2(0, b.h * 0.5 - 2)
		var dt := Vector2i(int(d.x / TILE), int(d.y / TILE))
		for yy in range(dt.y - 3, dt.y + 3):
			for xx in range(dt.x - 3, dt.x + 4):
				_cobble(layer, xx, yy)

static func _cobble(layer: TileMapLayer, x: int, y: int) -> void:
	# dominan cobble; pelataran 1/6 sebagai variasi halus; tanah 1/16 (mata #286:
	# campuran lama terbaca genangan lumpur di mana-mana pada ubin 32)
	var src := 0
	if randi() % 16 == 0:
		src = 2
	elif randi() % 6 == 0:
		src = 1
	layer.set_cell(Vector2i(x, y), src, Vector2i(0, 0))

# --- buildings --------------------------------------------------------------

static func _place_buildings(host: Node2D, center: Vector2) -> void:
	for b in _buildings():
		var pos: Vector2 = center + b.off
		# sprite — fasad lpc32 (#286); tint opsional utk varian rumah
		var spr := Sprite2D.new()
		spr.texture = load(P_L + b.spr + ".png")
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if b.has("tint"):
			spr.modulate = b.tint
		spr.global_position = pos
		spr.z_index = int(pos.y + b.h * 0.5)   # y-sort by base
		host.add_child(spr)
		# collision over the wall body (leave the door row walkable from below)
		var body := StaticBody2D.new()
		body.global_position = pos
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(b.w - 10, b.h * 0.42)
		cs.shape = shape
		cs.position = Vector2(0, -b.h * 0.08)
		body.add_child(cs)
		host.add_child(body)
		# hanging signboard — papan_gantung32 (native 32-world, #286)
		var sign := Sprite2D.new()
		sign.texture = load(P_L + "papan_gantung32.png")
		sign.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sign.global_position = pos + Vector2(b.w * 0.5 - 12, -b.h * 0.5 + 40)
		sign.z_index = int(pos.y + b.h * 0.5) + 1
		host.add_child(sign)
		# door interactable at the bottom-centre
		var door := preload("res://scenes/world/Interactable.tscn").instantiate()
		door.kind = "house_door"
		door.custom_label = "%s [E]" % b.sign
		door.interior_variant = b.door if b.door != "" else "house"
		door.solid_landmark = (b.door == "")
		host.add_child(door)
		door.global_position = pos + Vector2(0, b.h * 0.5 - 4)

static func _place_well(host: Node2D, center: Vector2) -> void:
	# fountain lpc32 (#286) menggantikan well 16px — pusat plaza yang sama dengan
	# bahasa visual Ashbrook64
	var spr := Sprite2D.new()
	spr.texture = load(P_L + "fountain.png")
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.global_position = center + Vector2(0, 88)
	spr.z_index = int(spr.global_position.y + 36)
	host.add_child(spr)
	var body := StaticBody2D.new()
	body.global_position = spr.global_position
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(48, 28)
	cs.shape = shape
	cs.position = Vector2(0, 16)
	body.add_child(cs)
	host.add_child(body)

# --- street lamps -----------------------------------------------------------

static func _place_lamps(host: Node2D, center: Vector2) -> void:
	var spots := [
		Vector2(-150, -60), Vector2(150, -60), Vector2(-150, 100), Vector2(150, 100),
		Vector2(-300, 120), Vector2(300, 130), Vector2(0, -70),
	]
	for s in spots:
		var lamp := Node2D.new()
		lamp.set_script(load("res://scenes/actors/StreetLamp.gd"))
		host.add_child(lamp)
		lamp.global_position = center + s * S

# --- fences -----------------------------------------------------------------

static func _place_fences(host: Node2D, center: Vector2) -> void:
	var holder := Node2D.new()
	holder.name = "Fences"
	host.add_child(holder)
	var ct := Vector2i(int(center.x / TILE), int(center.y / TILE))
	var x0 := ct.x - 25; var x1 := ct.x + 25
	var y0 := ct.y - 22; var y1 := ct.y + 23
	for x in range(x0, x1 + 1):
		if abs(x - ct.x) > 2:                      # gap for N/S roads
			_fence(holder, x, y0); _fence(holder, x, y1)
	for y in range(y0, y1 + 1):
		if abs(y - ct.y) > 2:                      # gap for E/W roads
			_fence(holder, x0, y); _fence(holder, x1, y)

static func _fence(holder: Node2D, tx: int, ty: int) -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/game/tiles/lpc32/pagar_h32.png")
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = Vector2(tx * TILE + TILE / 2.0, ty * TILE + TILE / 2.0)
	s.z_index = int(s.global_position.y)
	holder.add_child(s)

# --- market deco ------------------------------------------------------------

static func _place_deco(host: Node2D, center: Vector2) -> void:
	var holder := Node2D.new()
	holder.name = "TownDeco"
	host.add_child(holder)
	# hand-placed clusters so the town never has bare grass
	var items := [
		["stall", Vector2(-70, 60)], ["stall", Vector2(70, 55)],
		["crate", Vector2(-96, 66)], ["barrel", Vector2(-84, 74)], ["sack", Vector2(96, 66)],
		["crate", Vector2(210, -50)], ["barrel", Vector2(222, -42)], ["crate", Vector2(-200, -46)],
		["hay", Vector2(258, 150)], ["hay", Vector2(300, 158)], ["trough", Vector2(255, 190)],
		["laundry", Vector2(-150, 150)], ["laundry", Vector2(40, 205)],
		["flower_pot", Vector2(-220, -78)], ["flower_pot", Vector2(-280, -78)],
		["flower_pot", Vector2(224, -74)], ["flower_pot", Vector2(280, -12)],
		["flower_pot", Vector2(-222, 130)], ["flower_pot", Vector2(-62, 148)],
		["flower_pot", Vector2(140, 148)], ["barrel", Vector2(-300, 60)],
		["crate", Vector2(300, -8)], ["sack", Vector2(312, -2)],
		["bush", Vector2(-120, -30)], ["bush", Vector2(120, -34)], ["bush", Vector2(-40, 120)],
		["bush", Vector2(180, 90)], ["bush", Vector2(-180, 80)],
		["flower_pink", Vector2(-90, 40)], ["flower_blue", Vector2(90, 42)],
		["flower_pink", Vector2(-30, -40)], ["flower_blue", Vector2(30, -44)],
		["mushroom", Vector2(-160, 40)], ["pebbles", Vector2(60, 100)],
	]
	for it in items:
		_deco_at(holder, load(PDIR + it[0] + ".png"), center + it[1] * S)

	# --- dense garden fill: scatter greenery in the town's grassy gaps so no bare
	#     patch of grass survives (owner rule: no plain grass > 4 tiles in town) ---
	var blds := _buildings()
	# "grass" prop dibuang (#286): tuft 16px di-skala 2 terbaca LEMPENGAN hijau di
	# atas perkerasan, bukan rumput — di dunia 32 isian kota cukup semak & bunga
	var fill := ["bush", "bush", "flower_pink", "flower_blue", "mushroom", "pebbles", "pebbles"]
	for gy in range(-21, 22):
		for gx in range(-25, 26):
			if (gx + gy) % 2 != 0:
				continue
			# leave the central plaza + the cross-road bands as open paving
			if absi(gx) <= 15 and absi(gy) <= 10:
				continue
			if absi(gx) <= 3 or absi(gy) <= 3:
				continue
			var p: Vector2 = center + Vector2(gx * TILE + randi() % 10 - 5, gy * TILE + randi() % 10 - 5)
			var skip := false
			for b in blds:
				var bp: Vector2 = center + b.off
				if absf(p.x - bp.x) < b.w * 0.5 + 12 and absf(p.y - bp.y) < b.h * 0.5 + 12:
					skip = true; break
			if skip or randf() > 0.7:
				continue
			_deco_at(holder, load(PDIR + fill[randi() % fill.size()] + ".png"), p)

static func _deco_at(holder: Node2D, tex: Texture2D, pos: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(S, S)   # deco 16px di dunia 32 (#286) — pola pengali Ashbrook64
	s.global_position = pos
	s.z_index = int(pos.y)
	holder.add_child(s)

# --- NPCs at logical posts (reuse existing Interactable kinds) ---------------

static func _place_npcs(host: Node2D, center: Vector2) -> void:
	# [kind, offset] — placed just outside their building's door
	var npcs := [
		["workbench", Vector2(-210, -66)],    # blacksmith (crafting) by the forge
		["shop", Vector2(292, 68)],           # merchant by the store
		["astrologer", Vector2(-300, 78)],    # astrologer by the tower
		["inn", Vector2(292, -62)],           # innkeeper by the inn
		["board", Vector2(48, -104)],         # quest board at the town hall
		["guide", Vector2(-40, 96)],          # Pemandu by the plaza/well
		["mirror", Vector2(198, -56)],        # Cermin Jiwa (re-customize) by the inn
		["trainer", Vector2(-232, 96)],       # Guru Skill near the forge/plaza
		["tree_keeper", Vector2(96, 96)],     # Penjaga Pohon (skill tree lokal, #30)
		["enchanter", Vector2(-170, -66)],    # Enchanter di samping bengkel (v0.4.2)
		["auctioneer", Vector2(180, 96)],     # Rumah Lelang di plaza (B8 v0.4.2)
		["world_gate", Vector2(-96, -20)],    # Gerbang Penjelajah (#43)
	]
	for n in npcs:
		var node := preload("res://scenes/world/Interactable.tscn").instantiate()
		host.add_child(node)
		node.setup(n[0])
		node.keeper_location = "greenvale"
		node.scale = Vector2(S, S)   # ikon/NPC 16px + radius interaksi ikut dunia 32 (#286)
		node.global_position = center + n[1] * S

# --- strolling villagers ----------------------------------------------------

static func _human(hair: String, hc: String, shirt: String, pants: String, dark := false) -> Dictionary:
	var race := "human2" if dark else "human"
	return {"head_race": race, "torso_race": race, "legs_race": race,
		"hair": hair, "hair_color": hc, "shirt": shirt, "pants": pants}

static func _place_villagers(host: Node2D, center: Vector2) -> void:
	# Greenvale = 100% human — varied looks from CharGen (Aetherion Character System).
	var routes := [
		["Bu Sari", _human("long", "#241f36", "#8a3a6b", "#5c2380", true), [Vector2(-140, 0), Vector2(140, 10), Vector2(120, 120), Vector2(-120, 110)]],
		["Pak Budi", _human("short", "#3a2a1a", "#1e3a5c", "#453d5c"), [Vector2(0, -80), Vector2(200, -40), Vector2(60, 90)]],
		["Rina", _human("long", "#c9a227", "#2e6b3f", "#6b4226"), [Vector2(-200, 100), Vector2(-40, 60), Vector2(-260, 40)]],
		["Joko", _human("short", "#241f36", "#8f2611", "#2b2b3a", true), [Vector2(100, 40), Vector2(260, 120), Vector2(120, 170)]],
		["Nenek Ijah", _human("long", "#e8e2f4", "#5c2380", "#453d5c"), [Vector2(-60, 150), Vector2(60, 160), Vector2(0, 60)]],
	]
	var lpc_i := 40   # warga_040.. — rentang di luar pemakaian Ashbrook64 awal
	for r in routes:
		var v := preload("res://scenes/actors/Villager.tscn").instantiate()
		var wps: Array = []
		for w in r[2]:
			wps.append(center + w * S)
		# LPC 64 (#286): persona & rute tetap, hanya sumber frame yang naik kelas.
		# WAJIB sebelum add_child (pelajaran anak Ashbrook).
		v.lpc_sheet = "warga_%03d" % lpc_i
		lpc_i += 1
		host.add_child(v)
		v.setup(r[0], r[1], wps)
		v.global_position = wps[0]

# --- animals ----------------------------------------------------------------

static func _place_animals(host: Node2D, center: Vector2) -> void:
	var critters := [
		["chicken", Vector2(250, 200)], ["chicken", Vector2(272, 208)], ["chicken", Vector2(240, 216)],
		["cat", Vector2(-230, 150)], ["cat", Vector2(120, 60)],
	]
	for c in critters:
		var node := Node2D.new()
		node.set_script(load("res://scenes/actors/Critter.gd"))
		node.set("_kind", c[0])
		host.add_child(node)
		node.global_position = center + c[1] * S
		node.setup(c[0])
		node.scale = Vector2(S, S)   # critter 16px di dunia 32 (#286)
