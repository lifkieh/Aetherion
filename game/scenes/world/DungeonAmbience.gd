class_name DungeonAmbience
extends Node
## AMBIENCE DUNGEON (v0.4.3 #6, Decision Log #98) — tetes air & gema langkah batu
## sesekali, dari SFX Minifantasy yang sudah ada (#92). Bukan loop menerus: justru
## keheningan yang membuat satu tetes air terdengar. Mode Hemat mematikannya.

const MIN_GAP := 7.0
const MAX_GAP := 16.0
const CUES := [
	["stone_step", 0.55],     # gema langkah jauh — pitch rendah
	["stone_step", 0.75],
	["crate", 0.5],           # kayu tua berderak
	["chest", 0.45],          # logam berdenting di kejauhan
]

var _t := 0.0

static func attach(host: Node) -> DungeonAmbience:
	var a: DungeonAmbience = DungeonAmbience.new()
	a.name = "DungeonAmbience"
	host.add_child(a)
	return a

func _ready() -> void:
	_t = randf_range(MIN_GAP, MAX_GAP)

func _process(delta: float) -> void:
	if Settings.eco_mode:
		return
	_t -= delta
	if _t > 0.0:
		return
	_t = randf_range(MIN_GAP, MAX_GAP)
	var cue: Array = CUES[randi() % CUES.size()]
	Audio.play_sfx(cue[0], float(cue[1]) * randf_range(0.9, 1.1))
