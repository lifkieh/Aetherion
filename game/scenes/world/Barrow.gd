extends DungeonBase
## Desert Barrow — Desert of Ruins' side-view dungeon (config over DungeonBase).

func cfg() -> Dictionary:
	return {
		"id": "desert_barrow", "w": 48, "h": 44,
		"bg": Color(0.14, 0.11, 0.08), "ambient": Color(0.28, 0.24, 0.18),  # sandy tomb dark
		"tile_tint": Color(1.0, 0.92, 0.72), "ore_freq": 0.09,              # sandstone tint
		"spawn_kinds": ["sand_scarab", "cactus_fiend", "dune_viper"],       # walker / shooter / jumper
		"boss": "anubis_warden", "music": "dungeon.ogg",
		"torch_color": Color(1.0, 0.8, 0.45),
		"return_scene": "res://scenes/world/Desert.tscn",
		"exit_label": "Keluar ke Desert [E]",
		"hint": "Klik-kiri: serang (arah kursor) · Klik-kanan: skill · WASD gerak · Space lompat · gali blok · E keluar",
		"intro": "Desert Barrow — makam kuno. Kalahkan Anubis Warden di dasar.",
	}
