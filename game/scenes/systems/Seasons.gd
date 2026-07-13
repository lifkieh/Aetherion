class_name Seasons
extends RefCounted
## MUSIM v1 (Addendum A4, Decision Log #83) — 4 musim x 2 MINGGU NYATA, terikat
## tanggal WIB asli seperti jam & bulan: musim berjalan walau game ditutup.
## Pilar yang dikuatkan (Hukum Direktur #1): **STEWARDSHIP** — musim memaksa
## trade-off nyata (menanam di luar musim = lambat; rumah kaca = biaya emas) —
## dan **WONDER** ringan (dunia berubah rupa tanpa diminta).

static func def() -> Dictionary:
	return GameClock.season_def()

static func id() -> String:
	return GameClock.season()

## Bolehkah tanaman ini ditanam di musim sekarang? Rumah Kaca = jalan keluar.
static func crop_in_season(crop_id: String) -> bool:
	var c := Db.crop(crop_id)
	var list: Array = c.get("seasons", [])
	return list.is_empty() or id() in list

static func has_greenhouse() -> bool:
	return bool(WorldState.greenhouse)

static func can_plant(crop_id: String) -> bool:
	return crop_in_season(crop_id) or has_greenhouse()

## Pengali waktu tumbuh: musim dingin lambat, gugur/semi cepat; di LUAR musimnya
## tanaman merambat 2.5x lebih lambat (rumah kaca menetralkannya).
static func growth_mult(crop_id: String) -> float:
	var m: float = float(def().get("crop_growth_mult", 1.0))
	if not crop_in_season(crop_id):
		if has_greenhouse():
			return 1.0        # rumah kaca: musim tak berlaku di dalamnya
		m *= 2.5
	elif has_greenhouse():
		m = minf(m, 1.0)      # rumah kaca minimal senetral musim normal
	return m

static func drop_mult() -> float:
	return float(def().get("drop_mult", 1.0))

## Bias spawn: monster berelemen "favorit musim" lebih sering muncul.
static func spawn_bias(species_id: String) -> float:
	var d := def()
	var fav: Array = d.get("favored_elements", [])
	var elem: String = Db.monster(species_id).get("element", "none")
	return float(d.get("spawn_bias", 1.0)) if elem in fav else 1.0

## Pilih spesies dari tabel spawn dengan bobot musim (dipakai scene dunia).
static func pick_species(table: Array, rng: RandomNumberGenerator = null) -> String:
	if table.is_empty():
		return ""
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var weights: Array = []
	var total := 0.0
	for sp in table:
		var w: float = spawn_bias(sp)
		weights.append(w)
		total += w
	var pick := rng.randf() * total
	for i in table.size():
		pick -= float(weights[i])
		if pick <= 0.0:
			return table[i]
	return table[table.size() - 1]
