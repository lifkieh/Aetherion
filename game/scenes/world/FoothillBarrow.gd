extends DungeonBase
## Foothill Barrow — Frostpeak's side-view dungeon. Boss: Frost Titan (2 phases).

func cfg() -> Dictionary:
	return {
		"id": "foothill_barrow", "name": "Foothill Barrow", "w": 48, "h": 46,
		"bg": Color(0.10, 0.13, 0.20), "ambient": Color(0.30, 0.36, 0.48),   # icy tomb
		"tile_tint": Color(0.82, 0.90, 1.05), "ore_freq": 0.08,
		"spawn_kinds": ["ice_wolf", "frost_elemental", "yeti_cub"],
		"boss": "frost_titan", "music": "town.ogg",
		"torch_color": Color(0.6, 0.8, 1.0),
		"return_scene": "res://scenes/world/Frostpeak.tscn",
		"exit_label": "Keluar ke Frostpeak [E]",
		"hint": "Klik-kiri: serang · WASD gerak · Space lompat · gali blok · E keluar",
		"intro": "Foothill Barrow — makam beku. Kalahkan Frost Titan (2 fase) di dasar.",
	}
