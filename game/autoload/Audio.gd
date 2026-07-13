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
	# Minifantasy Dungeon SFX (Leohpaz) — v0.4.3 #92
	"chest": "chest_open.ogg",
	"crate": "crate_open.ogg",
	"secret_door": "secret_open.ogg",
	"trap_spike": "trap_spike.ogg",
	"trap_dart": "trap_dart.ogg",
	"stone_step": "dungeon_step.ogg",
}

## STINGER dari POTONGAN MUSIK ASLI (AlkaKrab Fantasy RPG Vol.2) — menggantikan
## stinger v1 yang dirakit dari sampel SFX (v0.4.3 #92).
const STINGER_DIR := "res://assets/game/audio/stingers/"
const STINGER_FILES := {
	"levelup": "levelup.ogg",
	"quest": "quest.ogg",
	"discovery": "discovery.ogg",
	"boss_kill": "boss_kill.ogg",
	"transcend": "transcend.ogg",
}

var _stinger: AudioStreamPlayer
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _cache := {}
var _music: AudioStreamPlayer
var _combat: AudioStreamPlayer          # combat-intensity layer (crossfaded)
var _current_music := ""
var _combat_on := false
const COMBAT_MUSIC := "boss.ogg"
const MUSIC_DB := -8.0
const QUIET_DB := -40.0
var muted := false
var sfx_scale := 1.0     # volume per channel (v0.4.1): 0..1
var music_scale := 1.0

## Volume per channel (owner review i): music & SFX terpisah.
func set_channel_volumes(music_v: float, sfx_v: float) -> void:
	music_scale = clampf(music_v, 0.0, 1.0)
	sfx_scale = clampf(sfx_v, 0.0, 1.0)
	if _music:
		_music.volume_db = MUSIC_DB + linear_to_db(maxf(0.001, music_scale))
	if _combat and _combat_on:
		_combat.volume_db = MUSIC_DB + linear_to_db(maxf(0.001, music_scale))

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
	_stinger = AudioStreamPlayer.new()
	_stinger.bus = "Master"
	add_child(_stinger)

func _get_stream(path: String) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	var s: AudioStream = null
	if ResourceLoader.exists(path):
		s = load(path)
	_cache[path] = s
	return s

const UI_SFX := ["menu", "blip", "click", "prime"]
const AMB_SFX := ["stone_step", "crate", "chest", "secret_door"]

## Skala volume per KANAL (v0.4.4): UI, ambience, dan SFX aksi terpisah.
func _channel_scale(name: String) -> float:
	if name in UI_SFX:
		return Settings.ui_volume
	if name in AMB_SFX:
		return Settings.ambience_volume
	return sfx_scale

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
	p.volume_db = linear_to_db(maxf(0.001, _channel_scale(name)))   # channel per jenis (v0.4.4)
	p.play()

## STINGER (v0.4.3 #84) — penanda momen: bukan lagu baru, melainkan urutan pendek
## dari sampel yang SUDAH ada (nada naik/turun via pitch). Momen besar wajib
## terdengar, bukan cuma tampak.
const STINGERS := {
	"levelup":   [["levelup", 1.0]],
	"quest":     [["success", 1.0], ["blip", 1.35]],
	"discovery": [["secret", 1.0], ["blip", 1.6]],
	"boss_kill": [["levelup", 0.85], ["fusion", 0.9], ["coin", 1.2]],
	"transcend": [["fusion", 0.8], ["levelup", 1.15]],
}

func play_stinger(kind: String) -> void:
	if muted:
		return
	# 1) stinger asli (potongan musik) bila ada
	var f: String = STINGER_FILES.get(kind, "")
	if f != "":
		var st := _get_stream(STINGER_DIR + f)
		if st != null:
			if st is AudioStreamOggVorbis:
				st.loop = false
			_stinger.stream = st
			_stinger.volume_db = linear_to_db(maxf(0.001, sfx_scale))
			_stinger.play()
			return
	# 2) fallback: stinger v1 dari sampel SFX (tetap ada bila aset hilang)
	var seq: Array = STINGERS.get(kind, [])
	if seq.is_empty():
		return
	var delay := 0.0
	for step in seq:
		if delay <= 0.0:
			play_sfx(step[0], float(step[1]))
		else:
			var t := get_tree().create_timer(delay, true)
			t.timeout.connect(play_sfx.bind(step[0], float(step[1])))
		delay += 0.22

## Ganti track dengan CROSSFADE (v0.4.3 #5/#92): musik lama meredup sementara
## musik baru menyala — perpindahan scene tak lagi memutus lagu di tengah nada.
const FADE_TIME := 1.2

func play_music(filename: String) -> void:
	if muted or filename == _current_music:
		return
	var s := _get_stream(MUSIC_DIR + filename)
	if s == null:
		return
	if s is AudioStreamOggVorbis:
		s.loop = true
	_current_music = filename
	if _music.playing:
		_crossfade_to(s)
	else:
		_music.stream = s
		_music.volume_db = MUSIC_DB
		_music.play()

func _crossfade_to(s: AudioStream) -> void:
	# fade-out track lama, tukar, fade-in track baru (satu player: cukup & ringan)
	var tw := create_tween()
	tw.tween_property(_music, "volume_db", QUIET_DB - 20.0, FADE_TIME * 0.5)
	tw.tween_callback(func():
		_music.stream = s
		_music.play())
	tw.tween_property(_music, "volume_db", MUSIC_DB, FADE_TIME * 0.5)

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
