extends DungeonBase
## Zephyr Spire — Storm Island's side-view dungeon. Boss: Storm Sovereign (2 phases;
## lightning chase — use Earth to ground yourself).

func cfg() -> Dictionary:
	return {
		"id": "zephyr_spire", "name": "Zephyr Spire", "w": 46, "h": 52,
		"bg": Color(0.10, 0.12, 0.20), "ambient": Color(0.34, 0.38, 0.52),
		"tile_tint": Color(0.80, 0.86, 1.05), "ore_freq": 0.08,
		"spawn_kinds": ["volt_weasel", "thunder_hawk", "storm_elemental"],
		"boss": "storm_sovereign", "music": "dungeon.ogg",
		"torch_color": Color(0.7, 0.85, 1.0),
		"return_scene": "res://scenes/world/StormIsland.tscn",
		"exit_label": "Keluar ke Storm Island [E]",
		"hint": "Klik-kiri: serang · WASD gerak · Space lompat · gali blok · E keluar · pakai Earth utk grounding",
		"intro": "Zephyr Spire — menara badai. Kalahkan Storm Sovereign (2 fase) di puncak.",
	}
