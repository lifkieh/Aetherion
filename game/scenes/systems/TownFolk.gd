class_name TownFolk
extends RefCounted
## HUKUM NPC ANEH (E6, Decision Log #78): tiap kota/desa WAJIB punya minimal lima
## NPC berkepribadian — 1 Aneh, 1 Misterius, 1 Lucu, 1 Tragis, 1 Tak-masuk-akal.
## Mereka tidak memberi quest, tidak menjual apa pun, tidak menjelaskan dunia.
## Mereka hanya membuat dunia terasa DIHUNI.
##
## Oddwalker (blueprint "The Strange Ones"): 90% dari mereka memang tidak penting.
## ~10% menyimpan sesuatu — di data ditandai `oddwalker: true`. TIDAK ADA payoff
## sekarang (itu disengaja): hanya benih, agar kelak ada yang bisa tumbuh.

const REQUIRED := ["aneh", "misterius", "lucu", "tragis", "tak_masuk_akal"]

static func personas(town_id: String) -> Array:
	return Db.town_npcs.get(town_id, [])

## Apakah satu kota memenuhi Hukum NPC Aneh?
static func satisfies_law(town_id: String) -> bool:
	var seen := {}
	for p in personas(town_id):
		seen[p.get("archetype", "")] = true
	for a in REQUIRED:
		if not seen.has(a):
			return false
	return true

## Tempatkan kelima persona di sekitar `center` (rute jalan kecil per orang).
static func place(host: Node2D, town_id: String, center: Vector2) -> int:
	var list := personas(town_id)
	var n := 0
	for i in list.size():
		var p: Dictionary = list[i]
		var a := TAU * float(i) / maxf(1.0, float(list.size()))
		var anchor := center + Vector2.from_angle(a) * 120.0
		var wps := [anchor, anchor + Vector2.from_angle(a + 1.2) * 46.0, anchor + Vector2(0, 40)]
		var v := preload("res://scenes/actors/Villager.tscn").instantiate()
		host.add_child(v)
		v.setup(p.get("name", "Warga"), p.get("config", {}), wps)
		v.set("_home", anchor)        # jangkar jadwal (#97)
		v.set_persona(p)
		v.global_position = wps[0]
		n += 1
	return n
