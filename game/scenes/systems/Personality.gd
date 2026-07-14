class_name Personality
extends RefCounted
## MODEL KEPRIBADIAN 5 LAPIS (Decision Log #136–#138).
##
## Lapis 1 **TEMPERAMEN** — 4 tipe klasik (primer + sekunder). **STABIL SEUMUR HIDUP.**
## Lapis 2 **BIG FIVE** 0–100 — semi-stabil; hanya bergeser oleh **pengalaman besar**.
## Lapis 3 **TRAUMA & LUKA** — daftar peristiwa berbekas (termasuk luka pasca-revive, D1).
## Lapis 4 **SUMBU MENCIUS** — moral default condong **BAIK**; dapat terkorupsi
##          (`moral_drift`) oleh lingkungan, kekuasaan, atau trauma yang tak terkelola.
##          Ini fondasi **kejatuhan DAN penebusan** (D021).
## Lapis 5 **GROWTH PROFILE** — `talent` (langka tinggi: **genius is rare**),
##          `effort` (terikat Conscientiousness), `opportunity` (**datang dari PERISTIWA**,
##          bukan dari waktu), `luck` (seed), `mental_state` (turunan lapis 3 —
##          memodulasi semuanya).
##
## ⚠ **MESINNYA BELUM DIBANGUN** (#139). Yang ada sekarang: **angka tersimpan** + efek
## terlihat lewat gosip. Growth engine, opportunity event, moral drift, dan mental state
## yang memengaruhi keputusan hidup = **v0.6 Life Events pass**.
##
## **Aturan pembagian (D018):** Great Companion & 25 NPC berkepribadian = **TULIS TANGAN**
## (tidak pernah digenerate ulang). NPC lain = **generate unik per individu**, deterministik
## dari id-nya, lalu **dipersist** — supaya seseorang tak pernah berubah watak semalaman.

const TEMPERAMENTS := ["sanguinis", "koleris", "melankolis", "plegmatis"]
const BIG5 := ["openness", "conscientiousness", "extraversion", "agreeableness", "neuroticism"]

## Profil seorang NPC. Tulis-tangan menang; kalau tak ada, digenerate & disimpan.
static func of(npc_id: String) -> Dictionary:
	if WorldState.npc_profiles.has(npc_id):
		return WorldState.npc_profiles[npc_id]
	var hand := handwritten(npc_id)
	var prof: Dictionary = hand if not hand.is_empty() else generate(npc_id)
	WorldState.npc_profiles[npc_id] = prof
	return prof

## Profil tulis-tangan dari data (25 NPC berkepribadian). {} bila tak ada.
static func handwritten(npc_id: String) -> Dictionary:
	for town in Db.town_npcs.keys():
		for p in Db.town_npcs[town]:
			if p.get("name", "") == npc_id and p.has("profile"):
				var prof: Dictionary = p["profile"].duplicate(true)
				prof["handwritten"] = true
				return _fill_defaults(prof)
	return {}

## Generate profil unik & deterministik dari id (NPC generik, D018).
static func generate(npc_id: String, seed_extra: int = 0) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("npc:" + npc_id) + seed_extra
	var prim: String = TEMPERAMENTS[rng.randi_range(0, 3)]
	var sec: String = TEMPERAMENTS[rng.randi_range(0, 3)]
	while sec == prim:
		sec = TEMPERAMENTS[rng.randi_range(0, 3)]
	var big5 := {}
	for k in BIG5:
		big5[k] = rng.randi_range(15, 90)
	# temperamen mewarnai Big Five (bukan menentukannya)
	match prim:
		"sanguinis": big5["extraversion"] = clampi(big5["extraversion"] + 20, 0, 100)
		"koleris":
			big5["conscientiousness"] = clampi(big5["conscientiousness"] + 12, 0, 100)
			big5["agreeableness"] = clampi(big5["agreeableness"] - 15, 0, 100)
		"melankolis": big5["neuroticism"] = clampi(big5["neuroticism"] + 18, 0, 100)
		"plegmatis":
			big5["agreeableness"] = clampi(big5["agreeableness"] + 15, 0, 100)
			big5["extraversion"] = clampi(big5["extraversion"] - 15, 0, 100)
	# LAPIS 5 — GENIUS IS RARE (L17): bakat tinggi harus langka.
	# Tiga kali roll, ambil yang terkecil → ekor atas menipis drastis.
	var talent: int = mini(mini(rng.randi_range(1, 100), rng.randi_range(1, 100)), rng.randi_range(1, 100))
	return _fill_defaults({
		"temperament": prim, "temperament_sub": sec,
		"big5": big5,
		"moral": rng.randi_range(55, 85),      # SUMBU MENCIUS: default condong BAIK
		"moral_drift": 0,
		"trauma": [],
		"talent": talent,
		"effort": clampi(int(big5["conscientiousness"] * 0.8) + rng.randi_range(0, 20), 1, 100),
		"opportunity": 0,                      # HANYA datang dari PERISTIWA (L14)
		"luck": rng.randi_range(1, 100),
		"mental_state": 100,                   # turunan lapis 3
		"handwritten": false,
	})

static func _fill_defaults(p: Dictionary) -> Dictionary:
	p["temperament"] = p.get("temperament", "plegmatis")
	p["temperament_sub"] = p.get("temperament_sub", "melankolis")
	var b: Dictionary = p.get("big5", {})
	for k in BIG5:
		b[k] = clampi(int(b.get(k, 50)), 0, 100)
	p["big5"] = b
	p["moral"] = clampi(int(p.get("moral", 70)), 0, 100)
	p["moral_drift"] = int(p.get("moral_drift", 0))
	p["trauma"] = p.get("trauma", [])
	p["talent"] = clampi(int(p.get("talent", 30)), 1, 100)
	p["effort"] = clampi(int(p.get("effort", 50)), 1, 100)
	p["opportunity"] = int(p.get("opportunity", 0))
	p["luck"] = clampi(int(p.get("luck", 50)), 1, 100)
	p["mental_state"] = clampi(int(p.get("mental_state", 100)), 0, 100)
	p["handwritten"] = bool(p.get("handwritten", false))
	return p

# --- pembacaan (dipakai gosip & kelak Life Events) ---------------------------

static func trait_of(prof: Dictionary, key: String) -> int:
	return int(prof.get("big5", {}).get(key, 50))

static func label(prof: Dictionary) -> String:
	return "%s-%s" % [str(prof.get("temperament", "-")).capitalize(),
		str(prof.get("temperament_sub", "-")).capitalize()]

## OUTCOME (proyeksi hasil hidup) — **BUKAN "potential"** (Decision Log #174).
## Talent+Effort > Talent (L17). Tanpa kesempatan, bakat sebesar apa pun tak tumbuh (L14).
##
## ⚠ **RUMUS DI BAWAH = INTERIM, BUKAN MODEL KANON** (#179/#186).
## **MODEL KANON (dibangun v0.6):**
##     Outcome = Potential × Effort × (1 + Opportunity) × Time × Luck
## `(1 + Opportunity)` — **bukan** `× Opportunity` (#184): kesempatan **lahir = 0** (Hukum 3 utuh),
## dan itu harus berarti **"hidup kecil"**, BUKAN **"tidak ada"**. Perkalian murni akan membuat
## **~90% dunia ber-Outcome NOL** — dan itu membunuh Hukum 8 (Ordinary People) **di dalam mesin
## yang seharusnya membuktikannya**. Faktor **Time** belum ada di kode.
##
## ⚠ **SKALA:** `talent` di sini masih **1–100** = **INTERIM** (#186). Skala kanon: mayoritas
## 50–150 · berbakat 150–400 · elite 400–700 · jenius 700–1000 · fenomena 1000+.
## **DILARANG mengklaim skala baru "sudah terkode" sampai migrasi v0.6.**
##
## ⚠ Dulu bernama `potential()` — dan itu **berbahaya**: HUKUM 1 (`POTENTIAL = ???`) justru
## menyatakan potensi **tersembunyi**, sehingga penulis berikutnya bisa menampilkan angka ini
## ke UI karena mengira "inilah potensi yang dimaksud kanon". **Nilai ini TIDAK PERNAH tampil
## ke pemain** — dijaga oleh test `_test_potential_not_exposed()`.
static func outcome_projection(prof: Dictionary) -> float:
	var t: float = float(prof.get("talent", 30))
	var e: float = float(prof.get("effort", 50))
	var o: float = float(prof.get("opportunity", 0))
	var l: float = float(prof.get("luck", 50))
	var m: float = float(prof.get("mental_state", 100)) / 100.0
	return (t * 0.3 + e * 0.35 + o * 0.25 + l * 0.1) * m

# --- POTENTIAL: data tersembunyi + GERBANG-ITEM (kanon #174/#175) --------------
## POTENSI ITU NYATA — ia membedakan orang yang mentok-biasa dari yang mentok-Legendary.
## Ia **tersembunyi secara default** dan **TIDAK PERNAH tampil sebagai angka**. Satu-satunya
## jalan mengintipnya = **ITEM PENGLIHAT POTENSI** (langka; **mesinnya = spec v0.6, belum
## dibangun**) — dan bahkan item itu hanya menampilkan **TIER**, tak pernah angka mentah.
##
## Kenapa ini memperkuat, bukan melanggar, Hukum 1: pemain biasa tetap melihat `???`.
## Pemain yang **berburu item langka** bisa mengintip — dan **pengetahuan itu sendiri menjadi
## kekuatan**: tahu anak petani ini berpotensi Legendary = **alasan memberinya kesempatan** (L14).
##
## ⚠ KALIBRASI SEMENTARA (#179): `talent` di kode masih berskala **1–100**. Model kanon baru
## memakai skala **50–1200** (mayoritas 50–150 · berbakat · jenius · fenomena langka) dengan
## rumus **PERKALIAN** + faktor **Time** yang belum ada di kode. **Migrasi = v0.6.**
## Sampai itu terjadi: ambang di bawah adalah **kalibrasi lama**, bukan skala kanon.
const TIERS := ["Average", "Gifted", "Exceptional", "Legendary"]

## Tier potensi seorang individu (data internal). **Jangan panggil dari UI** — satu-satunya
## pemanggil sah kelak adalah Item Penglihat Potensi (v0.6).
static func talent_tier(prof: Dictionary) -> String:
	var t := clampi(int(prof.get("talent", 30)), 1, 100)
	if t >= 90:
		return "Legendary"
	if t >= 75:
		return "Exceptional"
	if t >= 55:
		return "Gifted"
	return "Average"

## L15 — PEOPLE CAN BREAK: trauma menurunkan mental_state; performa ikut turun.
static func add_trauma(npc_id: String, event: String, weight: int = 15) -> void:
	var p := of(npc_id)
	p["trauma"].append({"event": event, "date": GameClock.date_string(), "weight": weight})
	p["mental_state"] = clampi(int(p["mental_state"]) - weight, 0, 100)
	WorldState.npc_profiles[npc_id] = p
