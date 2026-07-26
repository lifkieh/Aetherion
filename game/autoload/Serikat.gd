extends Node
## SERIKAT PENJELAJAH (#291-4) — kontrak berperingkat, cabang HANYA Greenvale.
## Satu keluarga dengan Gerbang Penjelajah (#43) dan kanon Valenford "Kingdom of
## Open Roads". Ashbrook TIDAK punya cabang — kota memudar (tesis); papan tuanya
## tetap papan komunitas.
##
## HUKUM YANG DIPEGANG:
##   E8 (#80)  — tiap poster BERTANDA TANGAN (giver + alasan manusiawi), dan
##               menyelesaikan kontrak MENGUBAH sesuatu: sapaan penjaga cabang
##               bergeser mengikuti peringkat, poster peringkat berikut terbuka.
##   #122      — mengambil kontrak = merobek poster DI CABANG (aksi di dunia,
##               tombol Ambil hanya hidup saat berdiri di depan penjaga), bukan
##               menu Terima/Tolak yang melayang di mana pun.
##   #179      — reputasi = OPPORTUNITY: membuka akses (peringkat, kontrak),
##               tidak pernah mengendalikan sikap NPC di luar Serikat.
##
## STATE: PlayerData.kontrak {aktif: [{id, progress, done}], selesai: [id]}
##        (persisted) + WorldState.counters["serikat_rep"] = kontrak selesai.

const MAX_AKTIF := 2
const RANKS := ["F", "E", "D", "C"]
const RANK_BUTUH := {"F": 0, "E": 2, "D": 5, "C": 9}


func _ready() -> void:
	EventBus.monster_killed.connect(_on_kill)
	EventBus.node_harvested.connect(_on_gather)
	EventBus.item_crafted.connect(_on_craft)
	EventBus.pet_added.connect(_on_tame)


func data(id: String) -> Dictionary:
	for k in Db.kontrak_serikat:
		if k.get("id", "") == id:
			return k
	return {}


func rep() -> int:
	return WorldState.get_counter("serikat_rep")


func rank_terbuka(r: String) -> bool:
	return rep() >= int(RANK_BUTUH.get(r, 9999))


func rank() -> String:
	var best := "F"
	for r in RANKS:
		if rank_terbuka(r):
			best = r
	return best


func aktif() -> Array:
	return PlayerData.kontrak.get("aktif", [])


func selesai_ids() -> Array:
	return PlayerData.kontrak.get("selesai", [])


func sedang_aktif(id: String) -> bool:
	for a in aktif():
		if a.id == id:
			return true
	return false


## Merobek poster dari papan cabang (#122 — dipanggil UI hanya saat _ctx = penjaga).
func ambil(id: String) -> bool:
	var k := data(id)
	if k.is_empty() or id in selesai_ids() or sedang_aktif(id):
		return false
	if aktif().size() >= MAX_AKTIF or not rank_terbuka(str(k.get("rank", "F"))):
		return false
	if not PlayerData.kontrak.has("aktif"):
		PlayerData.kontrak["aktif"] = []
	PlayerData.kontrak["aktif"].append({"id": id, "progress": 0, "done": false})
	EventBus.toast.emit("🧭 Poster dirobek dari papan: %s (ttd. %s)" % [k.get("name", id), k.get("giver", "?")])
	return true


func _maju(type: String, target: String) -> void:
	var ubah := false
	for a in aktif():
		if a.done:
			continue
		var k := data(str(a.id))
		if k.get("type", "") != type:
			continue
		var tgt := str(k.get("target", "any"))
		if tgt != "any" and tgt != target:
			continue
		a.progress += 1
		if int(a.progress) >= int(k.get("count", 1)):
			a.progress = int(k.get("count", 1))
			a.done = true
			EventBus.toast.emit(("🧭 Kontrak rampung: %s — lapor ke cabang.") % k.get("name", a.id))
			Audio.play_stinger("quest")
		ubah = true
	if ubah:
		EventBus.counter_changed.emit("kontrak_progress", 0)


func _on_kill(species: String, _m) -> void:
	_maju("kill", species)


func _on_gather(kind: String, _item: String, _qty: int) -> void:
	_maju("gather", kind)


func _on_craft(_item: String, success: bool) -> void:
	if success:
		_maju("craft", "any")


func _on_tame(_pet: Dictionary) -> void:
	_maju("tame", "any")


func klaim(id: String) -> bool:
	for a in aktif():
		if a.id == id and a.done:
			var k := data(id)
			PlayerData.kontrak["aktif"].erase(a)
			if not PlayerData.kontrak.has("selesai"):
				PlayerData.kontrak["selesai"] = []
			PlayerData.kontrak["selesai"].append(id)
			var rank_lama := rank()
			WorldState.add_counter("serikat_rep")
			var g := int(k.get("reward_gold", 0))
			if g > 0:
				PlayerData.add_gold(g)
			if str(k.get("reward_item", "")) != "":
				PlayerData.add_item(str(k.get("reward_item", "")), int(k.get("reward_qty", 1)))
			EventBus.toast.emit("🎁 Upah kontrak %s: %dG" % [k.get("name", id), g])
			# E8: naik peringkat = dunia Serikat berubah (poster baru, sapaan baru)
			if rank() != rank_lama:
				EventBus.toast.emit("🧭 Serikat menaikkan peringkatmu: %s. Poster baru terpasang di papan cabang." % rank())
			return true
	return false


## E8 — sapaan Sela (penjaga cabang) bergeser mengikuti peringkat: dari
## menerima orang asing sampai bicara sesama pemegang jalan.
func sapaan() -> Array:
	match rank():
		"C":
			return ["Peringkat C. Jalur yang kau buka sudah dipakai kurir tiap pagi.",
				"Serikat mencatat jalan — dan namamu sudah tertulis di beberapa.",
				"Papan di belakangku. Kontrak yang tersisa bukan untuk sembarang orang."]
		"D":
			return ["Kurir rute utara menyebut namamu kemarin. Itu jarang.",
				"Peringkat D — kontrakmu sekarang menyangkut nyawa orang, bukan pagar ladang.",
				"Baca alasannya sebelum merobek posternya. Selalu."]
		"E":
			return ["Kembali lagi. Papannya sudah hafal tanganmu.",
				"Peringkat E — para pemberi kerja mulai menulis namamu di posternya."]
		_:
			return ["Serikat Penjelajah, cabang Greenvale. Aku Sela, penjaganya.",
				"Aturannya satu: tiap poster ada tanda tangannya. Kau bekerja untuk ORANG, bukan untuk papan.",
				"Ambil dari peringkat F. Jalan pulang juga bagian dari kontrak."]
