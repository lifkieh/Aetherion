extends Node2D
## World interactable (M5): crafting bench or shop NPC. Press E nearby.

var kind := "bench"   # bench | shop | inn | board | astrologer | pond | dungeon | house_door | guide
var dungeon_scene := "res://scenes/world/GreenvaleDepths.tscn"
var dungeon_label := "Gua Greenvale ▼ [E]"
var custom_label := ""              # override the door/sign label (R2 town buildings)
var keeper_location := "greenvale"  # lokasi Penjaga Pohon (skill tree, Decision Log #30)
var interior_variant := "house"     # which interior HouseInterior builds on entry
var solid_landmark := false         # true = building can't be entered (just flavour)

@onready var sprite: Sprite2D = $Sprite
@onready var label: Label = $Label

func setup(k: String) -> void:
	kind = k
	if is_inside_tree():
		_build()

var _lbl_cd := 0.0

func _ready() -> void:
	add_to_group("interactable")
	_build()

func _process(delta: float) -> void:
	_lbl_cd -= delta
	if _lbl_cd > 0.0:
		return
	_lbl_cd = 0.15
	z_index = int(global_position.y)   # y-sort with town buildings (R2)
	var p := get_tree().get_first_node_in_group("player")
	if p and label:
		var near := global_position.distance_to(p.global_position) < 72.0
		label.visible = near
		if near and kind == "dungeon":
			Onboarding.tip("dungeon_door")

func _build() -> void:
	if kind == "dungeon":
		# a dark stone archway reads as a cave/dungeon mouth (no more blob-tree sprite)
		sprite.texture = load("res://assets/game/sprites/props/stone_gate.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale = Vector2(1.3, 1.3)
		sprite.modulate = Color(0.5, 0.45, 0.6)
		sprite.offset = Vector2(0, -14)
		label.text = dungeon_label
	elif kind == "astrologer":
		_char_sprite({"head_race": "human", "torso_race": "human", "legs_race": "human",
			"hair": "long", "hair_color": "#3a6fa0", "shirt": "#5c2380", "pants": "#453d5c"})
		label.text = "Astrolog [E]"
	elif kind == "pond":
		sprite.texture = load("res://assets/game/tiles/pond.png")
		sprite.scale = Vector2(1.6, 1.6)
		label.text = "Memancing [E]"
	elif kind == "board":
		sprite.texture = load("res://assets/game/sprites/props/branch.png")
		sprite.scale = Vector2(2.2, 2.6)
		sprite.modulate = Color(0.75, 0.6, 0.4)
		label.text = "Papan Quest [E]"
	elif kind == "house_door":
		# R2: the building sprite is drawn by Town; the door is an invisible hotspot.
		sprite.visible = false
		label.text = custom_label if custom_label != "" else "Rumah Warga [E]"
	elif kind == "inn":
		sprite.texture = load("res://assets/game/sprites/props/rock.png")
		sprite.scale = Vector2(2.4, 2.0)
		sprite.modulate = Color(0.55, 0.45, 0.75)
		label.text = "Penginapan — Tidur [E]"
	elif kind == "mirror":
		sprite.texture = load("res://assets/game/sprites/props/mirror.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale = Vector2(1.5, 1.5)
		sprite.offset = Vector2(0, -8)
		label.text = "Cermin Jiwa [E]"
	elif kind == "guide":
		_char_sprite({"head_race": "human", "torso_race": "human", "legs_race": "human",
			"hair": "short", "hair_color": "#6b4226", "shirt": "#2e6b3f", "pants": "#453d5c"})
		label.text = "Pemandu [E]"
	elif kind == "trainer":
		_char_sprite({"head_race": "human", "torso_race": "human", "legs_race": "human",
			"hair": "long", "hair_color": "#b0b0c0", "shirt": "#334a6b", "pants": "#2b2b3a"})
		label.text = "Guru Skill [E]"
	elif kind == "enchanter":
		_char_sprite({"head_race": "human", "torso_race": "human", "legs_race": "human",
			"hair": "bun", "hair_color": "#c9a0e8", "shirt": "#5c2380", "pants": "#2b2b3a"})
		label.text = "Enchanter [E]"
	elif kind == "auctioneer":
		_char_sprite({"head_race": "human2", "torso_race": "human2", "legs_race": "human2",
			"hair": "short", "hair_color": "#d4c391", "shirt": "#8a2f2f", "pants": "#2b2b3a"})
		label.text = "🔨 Rumah Lelang [E]"
	elif kind == "tree_keeper":
		_char_sprite({"head_race": "human", "torso_race": "human", "legs_race": "human",
			"hair": "bun", "hair_color": "#e8e2f4", "shirt": "#2e6b3f", "pants": "#6b4226"})
		label.text = "Penjaga Pohon [E]"
	elif kind == "world_gate":
		sprite.texture = load("res://assets/game/sprites/props/stone_gate.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale = Vector2(1.4, 1.4)
		sprite.modulate = Color(0.55, 0.75, 1.0)   # biru penjelajah
		sprite.offset = Vector2(0, -14)
		label.text = "🌍 Gerbang Penjelajah [E]"
	elif kind == "shop":
		_char_sprite({"head_race": "human2", "torso_race": "human2", "legs_race": "human2",
			"hair": "short", "hair_color": "#241f36", "shirt": "#c9a227", "pants": "#453d5c"})
		label.text = "Pedagang [E]"
	else:
		sprite.texture = load("res://assets/game/sprites/props/rock.png")
		sprite.scale = Vector2(1.8, 1.4)
		sprite.modulate = Color(0.7, 0.5, 0.35)
		label.text = "Bengkel [E]"

## Render a townsfolk NPC from a CharGen config (idle, facing down).
func _char_sprite(config: Dictionary) -> void:
	var tex := CharGen.sheet_texture(config)
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(CharGen.CW, 0, CharGen.CW, CharGen.CH)   # frame 1 (idle), row 0 (down)
	sprite.texture = at
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE
	sprite.offset = Vector2(0, -8)

func interact() -> void:
	if Stage.is_busy():
		return
	if kind == "inn":
		await Stage.say(["Istirahatlah, petualang. Malam masih panjang.",
			"Tidur di sini memulihkan HP & MP-mu."], "Penjaga Wisma")
		_sleep()
		return
	if kind == "pond":
		_fish()
		return
	if kind == "dungeon":
		WorldState.pending_return_pos = global_position
		Stage.go_to_scene(dungeon_scene)
		return
	if kind == "mirror":
		if Stage.is_busy():
			return
		if PlayerData.gold < 150:
			await Stage.say("Cermin Jiwa berbisik: ubah rupamu perlu 150 gold. Kembalilah bila cukup.", "Cermin Jiwa")
			return
		await Stage.say(["Tatap Cermin Jiwa... rupamu bisa kau bentuk ulang (150 gold)."], "Cermin Jiwa")
		var cc := preload("res://scenes/ui/CharacterCreator.tscn").instantiate()
		get_tree().current_scene.add_child(cc)
		return
	if kind == "house_door":
		if solid_landmark:
			await Stage.say("Pintunya terkunci. Mungkin penghuninya sedang keluar.", custom_label.trim_suffix(" [E]"))
			return
		WorldState.pending_interior = interior_variant
		Stage.go_to_scene("res://scenes/world/HouseInterior.tscn")
		return
	var menu := get_tree().get_first_node_in_group("inventory_ui")
	if menu == null:
		return
	if kind == "shop":
		await Stage.say(["Selamat datang di kedaiku, kawan!",
			"Silakan lihat-lihat dagangannya."], "Pedagang", sprite.texture)
		menu.open("shop", self)
	elif kind == "board":
		EventBus.board_visited.emit()
		await Stage.say("Papan misi desa. Ambil tugas harian untuk emas & EXP.", "Papan Quest")
		menu.open("quest", self)
	elif kind == "guide":
		await Stage.say([
			"Halo, petualang baru! Aku Pemandu Greenvale.",
			"Ikuti daftar 'Panduan' di kanan layar untuk belajar dasar-dasarnya.",
			"Kubuka buku Panduan lengkap untukmu sekarang."], "Pemandu", sprite.texture)
		menu.open("panduan", self)
	elif kind == "astrologer":
		await Stage.say(["Bintang-bintang berbisik malam ini...",
			"Mau kubacakan ramalan langit untukmu?"], "Astrolog", sprite.texture)
		menu.open("sky", self)
	elif kind == "trainer":
		await Stage.say(["Ah, seorang petualang yang haus ilmu.",
			"Kuajarkan jurus-jurus lanjutan — bila level & emasmu cukup.",
			"Lihat daftar 'Belum dikuasai' di Skill Book."], "Guru Skill", sprite.texture)
		menu.open("skill", self)
	elif kind == "enchanter":
		await Stage.say(["Logam juga bisa bermimpi, petualang.",
			"Bawa gear-mu — kubisikkan mantra agar ia lebih tajam dari takdirnya.",
			"Di atas +6, mimpinya bisa buyar... siapkan Gulungan Perlindungan."], "Enchanter", sprite.texture)
		menu.open("enchant", self)
	elif kind == "auctioneer":
		await Stage.say(["Selamat datang di Rumah Lelang, tuan-tuan dan nyonya-nyonya!",
			"Lot berganti tiap hari — dan saat purnama, barang ISTIMEWA turun ke lantai.",
			"Menangkan tawaranmu sebelum para saudagar itu merebutnya."], "Juru Lelang", sprite.texture)
		menu.open("auction", self)
	elif kind == "tree_keeper":
		await Stage.say(["Setiap tanah menumbuhkan ilmunya sendiri, petualang.",
			"Pohon di sini bisa kubukakan untukmu. Yang lain? Hanya rumor yang bisa kubisikkan."], "Penjaga Pohon", sprite.texture)
		menu.open("trees", {"location": keeper_location})
	elif kind == "world_gate":
		load("res://scenes/ui/TravelUI.gd").open_over(get_tree())
	else:
		await Stage.say("Perlu meramu sesuatu? Bengkel ini siap membantu.", "Pandai Besi")
		menu.open("crafting", self)

func _fish() -> void:
	# Consume a Star Bait if held (unlocks star fish / Star Whale hook), else bare hook.
	var bait := ""
	if PlayerData.item_count("star_bait") > 0:
		bait = "star_bait"
		PlayerData.remove_item("star_bait", 1)
	FishingUI.open(bait)

func _sleep() -> void:
	# Sleeping is the trigger_action for the Moon Rabbit Warren (Fase0 §6).
	if ScenarioManager.try_trigger("sleep_at_inn"):
		return
	PlayerData.respawn()
	EventBus.toast.emit("Kamu tidur nyenyak. HP & MP pulih.")
	Audio.play_sfx("success")
