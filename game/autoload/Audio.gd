extends Node
## Audio — lightweight SFX pool + situational music (Fase0 polish, M8).
## Fails silently if a stream is missing so gameplay never breaks on audio.

const SFX_DIR := "res://assets/game/audio/sfx/"
const MUSIC_DIR := "res://assets/game/audio/music/"
const POOL_SIZE := 8

# logical name -> filename in SFX_DIR
const SFX_MAP := {
	"attack": "blade_01.ogg",
	"hit": "blade_02.ogg",
	"hurt": "creature_hurt_01.ogg",
	"slime": "creature_slime_01.ogg",
	"death": "creature_die_01.ogg",
	"coin": "item_coins_01.ogg",
	"metal": "metal_01.ogg",
	"dodge": "wood_01.ogg",
	"click": "misc_01.ogg",
	"mine": "stones_01.ogg",
	"levelup": "LevelUp1.wav",
	"success": "Success1.wav",
	"secret": "Secret1.wav",
	"prime": "ui_prime.wav",      # original UI SFX (UI/UX §7)
	"fusion": "ui_fusion.wav",
	"fizzle": "ui_fizzle.wav",
	"menu": "ui_menu.wav",
	"blip": "ui_blip.wav",
}

var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _cache := {}
var _music: AudioStreamPlayer
var _combat: AudioStreamPlayer          # combat-intensity layer (crossfaded)
var _current_music := ""
var _combat_on := false
const COMBAT_MUSIC := "23 - Road.ogg"
const MUSIC_DB := -8.0
const QUIET_DB := -40.0
var muted := false

func _ready() -> void:
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = "Master"
	_music.volume_db = MUSIC_DB
	add_child(_music)
	_combat = AudioStreamPlayer.new()
	_combat.bus = "Master"
	_combat.volume_db = QUIET_DB
	add_child(_combat)

func _get_stream(path: String) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	var s: AudioStream = null
	if ResourceLoader.exists(path):
		s = load(path)
	_cache[path] = s
	return s

func play_sfx(name: String, pitch: float = 1.0) -> void:
	if muted:
		return
	var fn: String = SFX_MAP.get(name, "")
	if fn == "":
		return
	var s := _get_stream(SFX_DIR + fn)
	if s == null:
		return
	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stream = s
	p.pitch_scale = pitch
	p.play()

func play_music(filename: String) -> void:
	if muted or filename == _current_music:
		return
	var s := _get_stream(MUSIC_DIR + filename)
	if s == null:
		return
	if s is AudioStreamOggVorbis:
		s.loop = true
	_current_music = filename
	_music.stream = s
	_music.play()

func stop_music() -> void:
	_music.stop()
	_current_music = ""

## Crossfade a combat layer over the base track (base keeps playing underneath
## for a seamless resume). Dynamic music layering (GDD v0.2 §10.5).
func set_combat(active: bool) -> void:
	if active == _combat_on or muted:
		return
	_combat_on = active
	if active:
		var s := _get_stream(MUSIC_DIR + COMBAT_MUSIC)
		if s:
			if s is AudioStreamOggVorbis:
				s.loop = true
			_combat.stream = s
			_combat.play()
		_fade(_combat, MUSIC_DB, 0.8)
		_fade(_music, QUIET_DB, 0.8)
	else:
		_fade(_combat, QUIET_DB, 1.2)
		_fade(_music, MUSIC_DB, 1.2)

func _fade(p: AudioStreamPlayer, to_db: float, secs: float) -> void:
	var tw := create_tween()
	tw.tween_property(p, "volume_db", to_db, secs)

func set_muted(m: bool) -> void:
	muted = m
	if m:
		_music.stop()
		_combat.stop()
		_combat_on = false
