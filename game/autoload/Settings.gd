extends Node
## Settings (M8) — Mode Hemat (eco), audio, persisted to user://settings.cfg.

signal changed()

const PATH := "user://settings.cfg"

var eco_mode := false        # disable weather VFX, cap 30fps
var muted := false
var music_volume := 0.8

func _ready() -> void:
	load_cfg()
	apply()

func apply() -> void:
	Engine.max_fps = 30 if eco_mode else 60
	Audio.set_muted(muted)
	changed.emit()

func set_eco(v: bool) -> void:
	eco_mode = v
	apply()
	save_cfg()

func set_muted_pref(v: bool) -> void:
	muted = v
	apply()
	save_cfg()

func save_cfg() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "eco_mode", eco_mode)
	cfg.set_value("audio", "muted", muted)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.save(PATH)

func load_cfg() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	eco_mode = cfg.get_value("video", "eco_mode", false)
	muted = cfg.get_value("audio", "muted", false)
	music_volume = cfg.get_value("audio", "music_volume", 0.8)
