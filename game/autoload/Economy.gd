extends Node
## Economy — simulated NPC shop pricing (Fase0 §7).
## price(item) = base_price * clamp(demand/supply, 0.5, 2.0)
## Stock depletes on buy (price up), recovers per WIB day. This becomes the
## price floor/ceiling baseline when a player marketplace arrives (Fase 2).

const CLAMP_LO := 0.5
const CLAMP_HI := 2.0
const DEFAULT_STOCK := 20
const DEFAULT_BASE_DEMAND := 10.0

var stock: Dictionary = {}             # item_id -> current supply units
var demand: Dictionary = {}            # item_id -> demand units
var _last_restock_day: String = ""
var trade_log: Array = []              # {t, action, item, qty, unit_price}

func _ready() -> void:
	EventBus.hour_passed.connect(_on_hour)
	_last_restock_day = GameClock.date_string()

func _on_hour(_h: int) -> void:
	var today := GameClock.date_string()
	if today != _last_restock_day:
		_last_restock_day = today
		_daily_restock()

func _ensure(item_id: String) -> void:
	if not stock.has(item_id):
		var base_supply: int = Db.item(item_id).get("shop_stock", DEFAULT_STOCK)
		stock[item_id] = base_supply
	if not demand.has(item_id):
		demand[item_id] = Db.item(item_id).get("shop_demand", DEFAULT_BASE_DEMAND)

func base_price(item_id: String) -> int:
	return Db.item(item_id).get("value", 10)

func price_multiplier(item_id: String) -> float:
	_ensure(item_id)
	var s: float = maxf(1.0, float(stock[item_id]))
	var d: float = maxf(1.0, float(demand[item_id]))
	return clampf(d / s, CLAMP_LO, CLAMP_HI)

func buy_price(item_id: String) -> int:
	# BENCANA (#145): wabah/kekeringan/perang menaikkan harga — dunia yang terluka
	# terasa di kantong, bukan cuma di dialog.
	return int(round(base_price(item_id) * price_multiplier(item_id) * MiracleSystem.price_mult()))

func sell_price(item_id: String) -> int:
	# shops buy from player at 60% of current buy price
	return int(round(buy_price(item_id) * 0.6))

func can_buy(item_id: String, qty: int) -> bool:
	_ensure(item_id)
	return stock[item_id] >= qty and PlayerData.gold >= buy_price(item_id) * qty

func buy(item_id: String, qty: int = 1) -> bool:
	_ensure(item_id)
	if not can_buy(item_id, qty):
		return false
	var unit := buy_price(item_id)
	if not PlayerData.spend_gold(unit * qty):
		return false
	stock[item_id] -= qty
	demand[item_id] = demand.get(item_id, DEFAULT_BASE_DEMAND) + qty  # buying raises demand
	PlayerData.add_item(item_id, qty)
	_log("buy", item_id, qty, unit)
	return true

func sell(item_id: String, qty: int = 1) -> bool:
	if PlayerData.item_count(item_id) < qty:
		return false
	_ensure(item_id)
	var unit := sell_price(item_id)
	PlayerData.remove_item(item_id, qty)
	PlayerData.add_gold(unit * qty)
	stock[item_id] += qty                                   # selling raises supply
	demand[item_id] = maxf(1.0, demand.get(item_id, DEFAULT_BASE_DEMAND) - qty * 0.5)
	_log("sell", item_id, qty, unit)
	return true

## HUKUM SIMULASI DUNIA (#89): dunia berjalan tanpa pemain. Saat load, kejadian
## diturunkan dari SELISIH WAKTU WIB nyata — bukan dari tick saat game berjalan.
## BUG-10 (REPORT-06): dulu restock hanya dipicu event jam saat game hidup, jadi
## save berumur 30 hari punya stok seolah baru semalam.
func catch_up(last_day: String) -> void:
	if last_day == "":
		return
	var a := last_day.split("-")
	var b := GameClock.date_string().split("-")
	if a.size() != 3 or b.size() != 3:
		return
	var d0 := Time.get_unix_time_from_datetime_dict({"year": int(a[0]), "month": int(a[1]), "day": int(a[2])})
	var d1 := Time.get_unix_time_from_datetime_dict({"year": int(b[0]), "month": int(b[1]), "day": int(b[2])})
	var days := int(floor(float(d1 - d0) / 86400.0))
	for i in mini(maxi(0, days), 30):     # cap 30 hari: cukup untuk konvergen
		_daily_restock()
	_last_restock_day = GameClock.date_string()

func _daily_restock() -> void:
	for id in stock.keys():
		var base_supply: int = Db.item(id).get("shop_stock", DEFAULT_STOCK)
		stock[id] = int(round(lerp(float(stock[id]), float(base_supply), 0.5)))
		demand[id] = lerp(float(demand.get(id, DEFAULT_BASE_DEMAND)), DEFAULT_BASE_DEMAND, 0.5)

func _log(action: String, item_id: String, qty: int, unit: int) -> void:
	trade_log.append({
		"t": GameClock.unix_now(), "action": action,
		"item": item_id, "qty": qty, "unit_price": unit,
	})
	if trade_log.size() > 500:
		trade_log = trade_log.slice(trade_log.size() - 500)

func to_save() -> Dictionary:
	return {"stock": stock, "demand": demand, "last_restock_day": _last_restock_day}

func from_save(d: Dictionary) -> void:
	stock = d.get("stock", {})
	demand = d.get("demand", {})
	var saved_day: String = d.get("last_restock_day", GameClock.date_string())
	_last_restock_day = saved_day
	# BUG-10 (REPORT-06): HUKUM SIMULASI DUNIA (#89) — dunia berjalan tanpa pemain.
	# Dulu restock hanya dipicu tick saat game hidup: save berumur 30 hari punya stok
	# seolah baru semalam. Sekarang: kejar ketertinggalan dari selisih hari WIB nyata.
	catch_up(saved_day)
