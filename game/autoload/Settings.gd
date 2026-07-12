extends Node
## Settings (M8) — Mode Hemat (eco), audio, persisted to user://settings.cfg.

signal changed()

const PATH := "user://settings.cfg"

var eco_mode := false        # disable weather VFX, cap 30fps
var muted := false
var music_volume := 0.8
var sfx_volume := 1.0        # channel terpisah (v0.4.1, owner review i)
var fullscreen := false

func _ready() -> void:
	load_cfg()
	apply()

func apply() -> void:
	Engine.max_fps = 30 if eco_mode else 60
	Audio.set_muted(muted)
	Audio.set_channel_volumes(music_volume, sfx_volume)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	changed.emit()

func set_eco(v: bool) -> void:
	eco_mode = v
	apply()
	save_cfg()

func set_muted_pref(v: bool) -> void:
	muted = v
	apply()
	save_cfg()

func set_music_volume(v: float) -> void:
	music_volume = clampf(v, 0.0, 1.0)
	apply()
	save_cfg()

func set_sfx_volume(v: float) -> void:
	sfx_volume = clampf(v, 0.0, 1.0)
	apply()
	save_cfg()

func set_fullscreen(v: bool) -> void:
	fullscreen = v
	apply()
	save_cfg()

func save_cfg() -> void:
	var cfg := ConfigFile.new()
	cfg.load(PATH)   # jangan timpa key lain (mis. save/last_slot)
	cfg.set_value("video", "eco_mode", eco_mode)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("audio", "muted", muted)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.save(PATH)

func load_cfg() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	eco_mode = cfg.get_value("video", "eco_mode", false)
	fullscreen = cfg.get_value("video", "fullscreen", false)
	muted = cfg.get_value("audio", "muted", false)
	music_volume = cfg.get_value("audio", "music_volume", 0.8)
	sfx_volume = cfg.get_value("audio", "sfx_volume", 1.0)
