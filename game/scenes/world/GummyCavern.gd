extends DungeonBase
## Gummy Cavern — Candyveil's side-view dungeon (config over DungeonBase).

func cfg() -> Dictionary:
	return {
		"id": "gummy_cavern", "w": 48, "h": 44,
		"bg": Color(0.16, 0.08, 0.14), "ambient": Color(0.30, 0.18, 0.26),  # warm candy dark
		"tile_tint": Color(1.0, 0.75, 0.9), "ore_freq": 0.08,               # pink-tinted rock
		"spawn_kinds": ["gummy_slime", "lollipop_sprite", "gummy_mimic"],
		"boss": "gummy_titan", "music": "26 - Lost Village.ogg",
		"torch_color": Color(1.0, 0.6, 0.85),                               # pink torchlight
		"return_scene": "res://scenes/world/Candyveil.tscn",
		"exit_label": "Keluar ke Candyveil [E]",
		"hint": "Klik-kiri: serang (arah kursor) · Klik-kanan: skill · WASD gerak · Space lompat · gali blok · E keluar",
		"intro": "Gummy Cavern — manis tapi mematikan. Kalahkan Gummy Titan di dasar.",
	}
