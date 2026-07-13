extends Node
## FOREST SPIRIT + PENEBUSAN (v0.4.3 #4, Decision Log #95).
##
## Pilar: **STEWARDSHIP** — menebang itu berguna, dan itulah masalahnya. Menebang
## melewati ambang membangunkan Roh Hutan; ia tidak menyerang, ia BERHENTI MEMBERI:
## Greenvale memucat (tint) dan spawn berkurang. Tak ada soft-lock, tak ada game
## over: dunia hanya jadi lebih miskin sampai kau memperbaikinya (aturan no_fail).
##
## Penebusan: TANAM POHON (bibit dari drop/toko herbalis). Rasio pulih bila
## trees_planted >= trees_cut - WRATH_THRESHOLD/2 → Roh kembali sebagai entitas
## damai: berkah mingguan (+hasil kayu & herbal) + membuka node rahasia pohon
## Kehidupan.

const WRATH_THRESHOLD := 200        # Fase 0 (env AETHER_SPIRIT=N untuk uji)
const BLESSING_GATHER := 0.15       # +15% hasil kayu/herbal saat berkah aktif
const PALE_SPAWN_MULT := 0.6        # spawn Greenvale saat hutan memucat

func threshold() -> int:
	var env := OS.get_environment("AETHER_SPIRIT")
	if env != "":
		return maxi(1, int(env))
	return WRATH_THRESHOLD

func trees_cut() -> int:
	return WorldState.get_counter("trees_cut")

func trees_planted() -> int:
	return WorldState.get_counter("trees_planted")

## Berapa pohon lagi yang harus ditanam agar tanah memaafkan.
func debt() -> int:
	return maxi(0, trees_cut() - int(threshold() / 2.0) - trees_planted())

func is_angry() -> bool:
	return WorldState.spirit_state == "angry"

func is_blessed() -> bool:
	return WorldState.spirit_state == "blessed"

func _ready() -> void:
	EventBus.node_harvested.connect(_on_harvest)

func _on_harvest(kind: String, _item: String, _qty: int) -> void:
	if kind != "tree":
		return
	WorldState.add_counter("trees_cut")
	if WorldState.spirit_state == "none" and trees_cut() >= threshold():
		_wake()

func _wake() -> void:
	WorldState.spirit_state = "angry"
	EventBus.spirit_state_changed.emit("angry")
	Cutscene.play("forest_spirit_wrath")

## Dipanggil saat pemain menanam bibit pohon di alam liar.
func plant_tree() -> void:
	WorldState.add_counter("trees_planted")
	var tail := Loc.t("spirit.debt", [debt()]) if is_angry() and debt() > 0 else Loc.t("spirit.accepted")
	EventBus.toast.emit(Loc.t("spirit.planted", [tail]))
	if is_angry() and debt() <= 0:
		_forgive()

func _forgive() -> void:
	WorldState.spirit_state = "blessed"
	EventBus.spirit_state_changed.emit("blessed")
	Achievements.unlock_scenario_clear("forest_spirit") if Achievements.has_method("unlock_scenario_clear") else null
	Chronicle.record("forest_spirit", "Roh Hutan memaafkan — hutan Greenvale kembali bernapas")
	Cutscene.play("forest_spirit_forgiven")

## Berkah mingguan: bonus hasil kayu & herbal (dibaca ProfessionSystem/GatherNode).
func gather_bonus() -> float:
	return BLESSING_GATHER if is_blessed() else 0.0

## Tint dunia Greenvale saat hutan memucat (dipakai Main/Ambience).
func world_tint() -> Color:
	if is_angry():
		return Color(0.72, 0.78, 0.72)      # pucat, kehilangan warna
	return Color.WHITE

## Pengali spawn Greenvale (hutan yang memucat lebih sepi — bukan lebih berbahaya).
func spawn_mult() -> float:
	return PALE_SPAWN_MULT if is_angry() else 1.0

## Node rahasia pohon Kehidupan hanya terbuka bagi yang menebus.
func life_tree_node_unlocked() -> bool:
	return is_blessed()
