extends Node
## MusicDirector — dynamic music layering (GDD v0.2 §10.5). Raises the combat
## layer when combat is active (any damage in the last few seconds), lowers it
## back to the region's explore track when the fighting stops.

const COMBAT_HOLD := 5.0
var _cd := 0.0

func _ready() -> void:
	EventBus.boss_engaged.connect(func(_n, _node): Audio.play_music("boss.ogg"))
	EventBus.damage_dealt.connect(_on_damage)
	EventBus.game_loaded.connect(func(_s): _reset())

func _on_damage(_a, _t, _amt, _crit, _elem) -> void:
	_cd = COMBAT_HOLD
	Audio.set_combat(true)

func _process(delta: float) -> void:
	if _cd > 0.0:
		_cd -= delta
		if _cd <= 0.0:
			Audio.set_combat(false)

func _reset() -> void:
	_cd = 0.0
	Audio.set_combat(false)
