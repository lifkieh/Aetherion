extends Node
## ADVANCED CLASS QUEST Lv60 + TRIAL OF THE RASI (v0.2 §3 & v0.3 §3.3 — v0.4.4 #101).
## Janji teaser di ClassSelect ("Jalur lanjutan Lv60") akhirnya dibayar.
##
## Pilar: LEGACY (jalur yang kau pilih tercatat & mengubah gelar) + WONDER (Trial of
## the Rasi hanya bisa dijalani saat rasi KELAHIRANMU sedang naik — beberapa minggu
## nyata sekali; dunia yang menentukan waktunya, bukan pemain).
##
## Advanced Class: syarat Lv60 + satu ujian nyata (kalahkan N monster ≥ level 40
## TANPA mati) → pilih satu dari dua jalur; memberi gelar + bonus kecil permanen.
## Trial of the Rasi: syarat rasi kelahiran sedang NAIK (RasiSystem.ascendant) +
## Lv20 → hadiah: bonus rasi kelahiran DIGANDAKAN + gelar.

## PATCH KONSISTENSI (#153): 60 adalah angka SKALA-FINAL. Selama kurva masih
## terkompresi (Fase 0, konten berhenti di band 55), gerbang mengikuti BAND —
## kalau tidak, fitur ini melompat antara "mustahil" dan "trivial" tergantung era
## kurva, bukan tergantung kesiapan pemain. Ujian (Trial) TIDAK berubah.
## Ketidaksetujuan agent atas gerbang-angka itu sendiri (#101) menunggu Direktur.
const ADV_LEVEL_FINAL := 60          # skala final (v0.9 rebase kurva)
const ADV_KILLS := 30                # ujian: monster kuat, tanpa mati
const ADV_MIN_MONSTER_LV := 40
const TRIAL_LEVEL := 20

## Gerbang efektif hari ini = atap band konten yang ADA (kini 55), maks skala final.
func gate_level() -> int:
	var band := Db.band_ceiling_global()
	return ADV_LEVEL_FINAL if band <= 0 else mini(ADV_LEVEL_FINAL, band)

## Progres ujian advanced disimpan di WorldState.counters agar ikut save.
func adv_progress() -> int:
	return WorldState.get_counter("adv_trial_kills")

func adv_available() -> bool:
	return PlayerData.level >= gate_level() and PlayerData.advanced_class == ""

func adv_ready() -> bool:
	return adv_available() and adv_progress() >= ADV_KILLS

## Dua jalur per class (teks dari classes.json "advanced").
func paths(class_id: String) -> Array:
	var raw: String = Db.cls(class_id).get("advanced", "")
	var out: Array = []
	# format: "Jalur lanjutan (Lv60): A — desc · B — desc"
	var body := raw.split(":", true, 1)
	if body.size() < 2:
		return out
	for part in body[1].split("·"):
		var seg: String = part.strip_edges()
		if seg == "":
			continue
		var bits := seg.split("—")
		out.append({
			"name": bits[0].strip_edges(),
			"desc": bits[1].strip_edges() if bits.size() > 1 else "",
		})
	return out

func _ready() -> void:
	EventBus.monster_killed.connect(_on_kill)
	EventBus.player_died.connect(_on_death)

func _on_kill(_species: String, node) -> void:
	if not adv_available():
		return
	var lv := 0
	if is_instance_valid(node) and ("inst" in node):
		lv = int(node.inst.get("level", 1))
	if lv >= ADV_MIN_MONSTER_LV:
		WorldState.add_counter("adv_trial_kills")
		if adv_progress() == ADV_KILLS:
			EventBus.toast.emit(Loc.t("adv.ready"))

## Mati = ujian diulang dari nol. Ujian yang bisa dicicil tanpa risiko bukan ujian.
func _on_death() -> void:
	if adv_available() and adv_progress() > 0:
		WorldState.counters["adv_trial_kills"] = 0
		EventBus.toast.emit(Loc.t("adv.reset"))

## Pilih jalur lanjutan. Returns true bila berhasil.
func choose(path_name: String) -> bool:
	if not adv_ready():
		return false
	PlayerData.advanced_class = path_name
	PlayerData.titles.append(path_name)
	PlayerData.active_title = path_name
	PlayerData.recalculate_stats()
	Chronicle.record("advanced:" + path_name, Loc.t("adv.chronicle", [path_name]))
	EventBus.toast.emit(Loc.t("adv.chosen", [path_name]))
	return true

# --- Trial of the Rasi ------------------------------------------------------

func trial_done() -> bool:
	return WorldState.get_counter("rasi_trial") > 0

## Hanya bisa dijalani saat rasi KELAHIRANMU sedang naik (beberapa minggu sekali).
func trial_available() -> bool:
	if trial_done() or PlayerData.level < TRIAL_LEVEL:
		return false
	var birth := RasiSystem.birth()
	var asc := RasiSystem.ascendant()
	return not birth.is_empty() and birth.get("id", "") == asc.get("id", "")

func trial_reason() -> String:
	if trial_done():
		return Loc.t("trial.done")
	if PlayerData.level < TRIAL_LEVEL:
		return Loc.t("trial.level", [TRIAL_LEVEL])
	var birth := RasiSystem.birth()
	return Loc.t("trial.wait", [birth.get("name", "-"), RasiSystem.ascendant().get("name", "-")])

func run_trial() -> bool:
	if not trial_available():
		EventBus.toast.emit(trial_reason())
		return false
	WorldState.add_counter("rasi_trial")
	var birth := RasiSystem.birth()
	var title: String = Loc.t("trial.title", [birth.get("name", "-")])
	PlayerData.titles.append(title)
	PlayerData.active_title = title
	PlayerData.recalculate_stats()
	Audio.play_stinger("discovery")
	Chronicle.record("rasi_trial", Loc.t("trial.chronicle", [birth.get("name", "-")]))
	EventBus.toast.emit(Loc.t("trial.passed", [birth.get("name", "-")]))
	return true

## Bonus rasi kelahiran DIGANDAKAN setelah Trial (dibaca RasiSystem.birth_bonus).
func rasi_multiplier() -> float:
	return 2.0 if trial_done() else 1.0
