class_name DungeonChest
extends Node2D
## Peti dungeon (v0.4.3 #6, Decision Log #85).
## Dua jenis: `common` (di lantai, terlihat) dan `secret` (di ruang rahasia di balik
## batu — hanya ditemukan yang mau menggali). Isi peti direset tiap hari WIB, jadi
## dungeon tetap punya alasan untuk didatangi lagi — tapi rahasianya hanya "pertama
## kali ditemukan" sekali seumur save (dicatat WorldState.counters).

var chest_id := ""          # unik: "<dungeon>_<index>"
var table := "chest_common"
var secret := false
var _opened := false
var _lbl: Label
var _body: ColorRect
var _lid: ColorRect

static func spawn(host: Node2D, pos: Vector2, id: String, loot_table: String, is_secret: bool = false) -> DungeonChest:
	var c: DungeonChest = DungeonChest.new()
	c.chest_id = id
	c.table = loot_table
	c.secret = is_secret
	host.add_child(c)
	c.global_position = pos
	return c

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("dungeon_chest")
	z_index = 30
	_opened = _is_opened_today()
	_build()

func _build() -> void:
	var base := Color(0.75, 0.55, 0.25) if not secret else Color(0.85, 0.75, 0.35)
	_body = ColorRect.new()
	_body.color = base if not _opened else base.darkened(0.55)
	_body.size = Vector2(18, 12)
	_body.position = Vector2(-9, -12)
	add_child(_body)
	_lid = ColorRect.new()
	_lid.color = base.lightened(0.15) if not _opened else base.darkened(0.4)
	_lid.size = Vector2(18, 5)
	_lid.position = Vector2(-9, -17 if not _opened else -20)
	if _opened:
		_lid.rotation = -0.5
	add_child(_lid)
	_lbl = Label.new()
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_lbl.add_theme_font_override("font", load("res://assets/game/fonts/m5x7.ttf"))
	_lbl.add_theme_font_size_override("font_size", 12)
	_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_lbl.add_theme_constant_override("outline_size", 4)
	_lbl.position = Vector2(-30, -36)
	_lbl.visible = false
	add_child(_lbl)
	if secret and not _opened:
		var glow := PointLight2D.new()
		glow.color = Color(1.0, 0.9, 0.5)
		glow.energy = 0.6
		glow.texture = _dot()
		add_child(glow)

func _dot() -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in 64:
		for x in 64:
			var d := Vector2(x - 32, y - 32).length() / 32.0
			img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d, 0.0, 1.0)))
	return ImageTexture.create_from_image(img)

func _process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p and _lbl:
		var near: bool = global_position.distance_to(p.global_position) < 60.0
		_lbl.visible = near
		if near:
			_lbl.text = ("Peti Rahasia [E]" if secret else "Peti [E]") if not _opened else "(kosong)"

func _is_opened_today() -> bool:
	return WorldState.chests_opened.get(chest_id, "") == GameClock.date_string()

func interact() -> void:
	if _opened:
		EventBus.toast.emit("Peti ini sudah kau buka hari ini.")
		return
	_opened = true
	WorldState.chests_opened[chest_id] = GameClock.date_string()
	# penemuan pertama sebuah peti rahasia = momen (sekali seumur save)
	var first_secret := false
	if secret and not WorldState.secrets_found.has(chest_id):
		WorldState.secrets_found.append(chest_id)
		WorldState.add_counter("secrets_found")
		first_secret = true
	var got := 0
	for d in Db.loot_table(table):
		if randf() <= float(d.get("chance", 0.0)):
			var qty := randi_range(int(d.get("min", 1)), int(d.get("max", 1)))
			LootDrop.spawn(get_parent(), global_position + Vector2(randf_range(-8, 8), -10), d.get("item", ""), qty)
			got += 1
	var gold := randi_range(40, 120) * (3 if secret else 1)
	LootDrop.spawn_gold(get_parent(), global_position + Vector2(0, -10), gold)
	if first_secret:
		Audio.play_stinger("discovery")
		EventBus.toast.emit("✦ RUANG RAHASIA DITEMUKAN — dunia mencatatnya.")
	else:
		Audio.play_sfx("secret" if secret else "coin")
		EventBus.toast.emit("Peti terbuka: %d barang + %dG." % [got, gold])
	_body.color = _body.color.darkened(0.55)
	_lid.color = _lid.color.darkened(0.4)
	_lid.position.y = -20
	_lid.rotation = -0.5
