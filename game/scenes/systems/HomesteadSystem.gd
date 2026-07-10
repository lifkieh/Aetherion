class_name HomesteadSystem
extends RefCounted
## Homestead crop growth from real WIB time (Fase0 §5). Offline growth is
## automatic: a plot stores planted_at_unix; stage is derived from elapsed time.

## Growth stage 0..stages from elapsed seconds.
static func growth_stage(elapsed: float, grow_seconds: float, stages: int) -> int:
	if grow_seconds <= 0.0:
		return stages
	return clampi(int(floor(elapsed / grow_seconds * stages)), 0, stages)

static func is_ready(elapsed: float, grow_seconds: float, _stages: int = 4) -> bool:
	return elapsed >= grow_seconds

## Given a plot {crop_id, planted_at_unix}, compute current stage/ready now.
static func plot_status(plot: Dictionary) -> Dictionary:
	var crop := Db.crop(plot.get("crop_id", ""))
	if crop.is_empty():
		return {"stage": 0, "ready": false, "stages": 4}
	var grow: int = crop.get("grow_seconds", 600)
	var stages: int = crop.get("stages", 4)
	var elapsed: float = float(GameClock.unix_now() - int(plot.get("planted_at_unix", GameClock.unix_now())))
	# Sun-dependent crops don't advance while raining (science: photosynthesis).
	return {
		"stage": growth_stage(elapsed, grow, stages),
		"ready": is_ready(elapsed, grow, stages),
		"stages": stages,
		"crop": crop,
	}
