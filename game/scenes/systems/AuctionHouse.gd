class_name AuctionHouse
extends RefCounted
## RUMAH LELANG NPC (B8 #53, blueprint §10, v0.4.2 Bagian 3).
## - Offline: lot acak harian (reset per tanggal WIB) + lot istimewa saat purnama.
## - Maks tier A — S+ TIDAK PERNAH muncul (prinsip "item terbaik = crafted").
## - Bidding melawan NPC BERKEPRIBADIAN: tiap lot punya rival dengan gaya sendiri;
##   saat rival menyerah, palu jatuh — pemain menang & membayar (gold sink).
## - Lot TAWANAN (nada gelap B16): memenangkan lelang = MEMBEBASKAN mereka;
##   mereka mengingat kebaikan itu → kandidat rekrut loyal markas (v0.6, #70a).

const BANNED_TIERS := ["S", "SS", "SSS"]
const DAILY_LOTS := 4
const FULLMOON_EXTRA := 2
const CAPTIVE_CHANCE := 0.25       # peluang lot tawanan pada hari biasa (purnama: pasti)

## NPC penawar berkepribadian (placeholder pool — kelak tokoh Tier-B Companion Bible)
const BIDDERS := [
	{"id": "havel", "name": "Saudagar Havel", "style": "agresif — mengejar hampir semua lot", "counter": 0.72, "budget": 1.45},
	{"id": "lirael", "name": "Nyonya Lirael", "style": "kolektor — gila aksesori", "counter": 0.5, "budget": 1.8, "fav_type": "accessory", "fav_counter": 0.9},
	{"id": "bram", "name": "Tuan Bram", "style": "pelit — cepat menyerah", "counter": 0.38, "budget": 1.1},
	{"id": "sera", "name": "Sera Bermata Elang", "style": "pemburu senjata", "counter": 0.5, "budget": 1.6, "fav_type": "weapon", "fav_counter": 0.85},
]

## Kandidat tawanan bernama (pool placeholder #70a — diganti tokoh Tier-B nanti)
const CAPTIVE_NAMED := [
	{"name": "Rian", "tag": "bekas penambang Reruntuhan Gurun"},
	{"name": "Sela", "tag": "peramu muda dari Greenvale"},
	{"name": "Togar", "tag": "bekas serdadu Frostpeak"},
	{"name": "Mira", "tag": "penenun Candyveil"},
	{"name": "Dio", "tag": "anak nelayan Storm Island"},
]
const CAPTIVE_GENERIC_NAMES := ["Aren", "Bela", "Cika", "Damar", "Eka", "Farel", "Gita", "Halim", "Intan", "Jaka"]
const CAPTIVE_TAGS := ["petani terjerat utang", "penggembala yang diculik", "pelaut karam", "penambang tanpa surat", "pengrajin buangan", "peramu jalanan"]

## State lelang hari ini — regenerasi otomatis saat tanggal WIB berganti.
static func state() -> Dictionary:
	var a: Dictionary = WorldState.auction
	if a.get("date", "") != GameClock.date_string():
		a = generate(GameClock.date_string())
		WorldState.auction = a
	return a

## Bangun lot untuk satu hari. rng/full_moon bisa dipaksa (test/harness).
static func generate(date: String, rng: RandomNumberGenerator = null, force_full_moon: int = -1) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.seed = hash(date) + 7
	var full_moon: bool = GameClock.is_full_moon() if force_full_moon < 0 else force_full_moon == 1
	var lots: Array = []
	var pool := _pool()
	var count := DAILY_LOTS + (FULLMOON_EXTRA if full_moon else 0)
	for i in count:
		# lot purnama (ekstra) condong ke tier tinggi (B/A) — tetap TAK PERNAH S+
		var special: bool = full_moon and i >= DAILY_LOTS
		lots.append(_make_lot(pool, rng, special))
	# lot tawanan: purnama pasti ada; hari biasa berpeluang
	if full_moon or rng.randf() < CAPTIVE_CHANCE:
		lots.append(_make_captive(rng))
	return {"date": date, "full_moon": full_moon, "lots": lots}

static func _pool() -> Array:
	var out: Array = []
	for id in Db.items.keys():
		var def: Dictionary = Db.items[id]
		if def.get("tier", "F") in BANNED_TIERS:
			continue
		if int(def.get("value", 0)) < 40:
			continue
		if not def.get("type", "") in ["weapon", "armor", "accessory", "material", "consumable", "orb", "coating"]:
			continue
		out.append(id)
	out.sort()   # deterministik lintas-platform
	return out

static func _make_lot(pool: Array, rng: RandomNumberGenerator, special: bool) -> Dictionary:
	var pick := ""
	for attempt in 40:
		pick = pool[rng.randi_range(0, pool.size() - 1)]
		var tier: String = Db.item(pick).get("tier", "F")
		if special and tier in ["B", "A"]:
			break
		if not special and (tier in ["D", "C", "E"] or rng.randf() < 0.25):
			break
	var value := int(Db.item(pick).get("value", 100))
	var minb := maxi(30, int(value * rng.randf_range(0.55, 0.7)))
	return {
		"kind": "item", "item": pick, "special": special,
		"min": minb, "bid": minb, "bidder": "",
		"buyout": int(value * rng.randf_range(1.4, 1.8)),
		"rival": BIDDERS[rng.randi_range(0, BIDDERS.size() - 1)].id,
		"sold": false, "winner": "",
	}

static func _make_captive(rng: RandomNumberGenerator) -> Dictionary:
	var freed_names: Array = []
	for c in WorldState.freed_captives:
		freed_names.append(c.get("name", ""))
	var who: Dictionary = {}
	if rng.randf() < 0.3:   # sesekali kandidat bernama dari pool placeholder
		var avail: Array = []
		for c in CAPTIVE_NAMED:
			if not c.name in freed_names:
				avail.append(c)
		if not avail.is_empty():
			who = avail[rng.randi_range(0, avail.size() - 1)].duplicate()
			who["named"] = true
	if who.is_empty():   # NPC minor hasil CharGen dengan tag latar sederhana (#70a)
		who = {
			"name": CAPTIVE_GENERIC_NAMES[rng.randi_range(0, CAPTIVE_GENERIC_NAMES.size() - 1)],
			"tag": CAPTIVE_TAGS[rng.randi_range(0, CAPTIVE_TAGS.size() - 1)],
			"named": false,
		}
	var base := rng.randi_range(500, 900)
	return {
		"kind": "captive", "name": who.name, "tag": who.tag, "named": who.get("named", false),
		"min": base, "bid": base, "bidder": "",
		"buyout": base * 3,
		"rival": BIDDERS[rng.randi_range(0, BIDDERS.size() - 1)].id,
		"sold": false, "winner": "",
	}

static func _bidder(id: String) -> Dictionary:
	for b in BIDDERS:
		if b.id == id:
			return b
	return BIDDERS[0]

static func raise_step(lot: Dictionary) -> int:
	return maxi(10, int(lot.get("bid", 100) * 0.1))

## Pemain menawar. Rival berkepribadian membalas atau menyerah — saat menyerah,
## palu jatuh: pemain langsung menang & membayar. Returns {status, ...}.
static func player_bid(lot_index: int, rng: RandomNumberGenerator = null) -> Dictionary:
	var a := state()
	if lot_index < 0 or lot_index >= a.lots.size():
		return {"status": "invalid"}
	var lot: Dictionary = a.lots[lot_index]
	if lot.get("sold", false):
		return {"status": "sold"}
	var my_bid: int = int(lot.bid) + (0 if lot.get("bidder", "") == "" else raise_step(lot))
	if PlayerData.gold < my_bid:
		EventBus.toast.emit(Loc.t("auction.poor", [my_bid]))
		return {"status": "poor", "need": my_bid}
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	lot["bid"] = my_bid
	lot["bidder"] = "you"
	# rival menimbang: kepribadian + budget
	var rival := _bidder(lot.get("rival", "havel"))
	var chance: float = rival.get("counter", 0.5)
	if lot.get("kind", "item") == "item" and Db.item(lot.get("item", "")).get("type", "") == rival.get("fav_type", "~"):
		chance = rival.get("fav_counter", chance)
	var cap: int = int(float(_lot_value(lot)) * float(rival.get("budget", 1.3)))
	var counter_bid: int = my_bid + raise_step(lot)
	if rng.randf() < chance and counter_bid <= cap:
		lot["bid"] = counter_bid
		lot["bidder"] = rival.name
		return {"status": "outbid", "by": rival.name, "bid": counter_bid, "style": rival.style}
	# rival menyerah — TERJUAL ke pemain
	PlayerData.spend_gold(my_bid)
	lot["sold"] = true
	lot["winner"] = "you"
	_deliver(lot)
	return {"status": "won", "paid": my_bid}

## Beli langsung tanpa perang tawar (buyout).
static func player_buyout(lot_index: int) -> Dictionary:
	var a := state()
	if lot_index < 0 or lot_index >= a.lots.size():
		return {"status": "invalid"}
	var lot: Dictionary = a.lots[lot_index]
	if lot.get("sold", false):
		return {"status": "sold"}
	var price: int = int(lot.buyout)
	if not PlayerData.spend_gold(price):
		EventBus.toast.emit(Loc.t("enchant.no_gold", [price]))
		return {"status": "poor", "need": price}
	lot["sold"] = true
	lot["winner"] = "you"
	_deliver(lot)
	return {"status": "won", "paid": price}

static func _lot_value(lot: Dictionary) -> int:
	if lot.get("kind", "item") == "captive":
		return int(lot.get("min", 600)) * 2
	return int(Db.item(lot.get("item", "")).get("value", 100))

static func _deliver(lot: Dictionary) -> void:
	if lot.get("kind", "item") == "captive":
		# MEMBEBASKAN tawanan — ia mengingat kebaikanmu (kandidat rekrut loyal, v0.6)
		WorldState.freed_captives.append({
			"name": lot.name, "tag": lot.tag, "named": lot.get("named", false),
			"date": GameClock.date_string(), "loyal": true,
		})
		Audio.play_sfx("secret")
		EventBus.toast.emit(Loc.t("auction.freed", [lot.name]))
		EventBus.captive_freed.emit(lot.name, lot.tag)
	else:
		PlayerData.add_item(lot.item, 1)
		Audio.play_sfx("coin")
		EventBus.toast.emit(Loc.t("auction.sold", [Db.item_name(lot.item)]))
