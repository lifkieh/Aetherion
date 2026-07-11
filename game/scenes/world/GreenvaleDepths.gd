extends DungeonBase
## Greenvale Depths — King Slime pilot dungeon (config over DungeonBase).

func cfg() -> Dictionary:
	return {
		"id": "greenvale_depths", "w": 46, "h": 46,
		"bg": Color(0.10, 0.09, 0.13), "ambient": Color(0.16, 0.15, 0.22),
		"tile_tint": Color(1, 1, 1), "ore_freq": 0.10,
		"spawn_kinds": ["cave_bat", "verdant_slime", "cave_spitter"],
		"boss": "king_slime", "music": "23 - Road.ogg",
		"torch_color": Color(1.0, 0.7, 0.4),
		"return_scene": "res://scenes/Main.tscn",
		"exit_label": "Keluar ke Greenvale [E]",
		"hint": "Klik-kiri: serang (arah kursor) · Klik-kanan: skill · WASD gerak · Space lompat · panjat tangga · gali blok · E keluar",
		"intro": "Greenvale Depths — J/klik untuk tebas & gali; kalahkan King Slime di dasar.",
	}

func _ready() -> void:
	super()
	_place_puddles()

func _place_puddles() -> void:
	for spot in [Vector2(20 * TILE, 21 * TILE - 6), Vector2(30 * TILE, 31 * TILE - 6)]:
		var pud := preload("res://scenes/world/Puddle.tscn").instantiate()
		add_child(pud)
		pud.setup(3)
		pud.global_position = spot
