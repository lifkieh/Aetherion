# AETHERION — DESAIN TEKNIS FASE 0 (FONDASI OFFLINE)
Engine: **Godot 4.x** | Bahasa: GDScript (cepat iterasi; port C# nanti jika perlu) | Target: PC dulu, arsitektur siap mobile.

---

# 1. TUJUAN FASE 0 (definisi "selesai")
Sebuah build offline yang bisa dimainkan 30 menit dengan loop lengkap:
1. Jalan-jalan di **Greenvale Forest** (1 wilayah, seamless).
2. Combat action: normal attack, 2 skill, dodge, **Element Flow** (infusi Fire & Lightning).
3. Bunuh & **tame** monster (Fluffbit, Wolf, Slime) → jadi pet/mount.
4. Gathering (tebang pohon, tambang copper) → **craft** 5 resep di bengkel.
5. **Homestead** mini: tanam 2 jenis herbal yang tumbuh real-time WIB.
6. **Siklus siang-malam WIB asli + fase bulan asli** terlihat di langit.
7. 1 **Hidden Scenario** berfungsi (counter kelinci berjalan diam-diam).
8. Save/load lokal.

Kalau 8 poin ini terasa menyenangkan → semua sistem lain tinggal konten, bukan teknologi baru.

---

# 2. STRUKTUR PROYEK GODOT
```
res://
  autoload/            # singleton global (urutan load penting)
    GameClock.gd       # waktu WIB, fase bulan, musim, event window
    WorldState.gd      # cuaca, counter dunia (trees_cut, rabbits_killed...)
    PlayerData.gd      # karakter aktif, inventory, profesi, gold
    Db.gd              # loader semua data JSON (read-only saat runtime)
    EventBus.gd        # signal global (decoupling antar sistem)
    SaveManager.gd     # serialize/deserialize -> user://save/
    Economy.gd         # harga NPC tersimulasi (supply-demand)
  data/                # SEMUA konten = data, bukan kode (data-driven!)
    monsters.json      # id, BST, rarity, archetype, element, drops, tame
    items.json         # id, tier(F..SSS), type, stats, stack
    recipes.json       # bahan, hasil, success_rate, profesi & level
    skills.json        # formula, elemen, cooldown, biaya
    elements.json      # matriks efektivitas + aturan sains (flags)
    scenarios.json     # trigger Hidden Scenario (counter, kondisi langit)
    crops.json         # tanaman homestead: durasi real-time, musim
    loot_tables.json
  scenes/
    world/Region.tscn        # TileMapLayer + spawner + weather layer
    actors/Player.tscn       # CharacterBody2D + StateMachine
    actors/Monster.tscn      # SATU scene generik, di-configure dari Db
    systems/CombatResolver.gd
    systems/TamingSystem.gd
    systems/CraftingBench.tscn
    homestead/Homestead.tscn
    ui/HUD.tscn, Inventory.tscn, SkyReport.tscn
  assets/
    game/{sprites,tiles,audio,ui}/   # hasil normalisasi (lihat v0.3 §8)
```

**Prinsip #1 — Data-driven:** menambah monster/resep/skill = menambah baris JSON, tanpa menyentuh kode. Ini yang membuat 64 monster realistis untuk tim kecil, dan JSON ini nanti tinggal dipindah ke PostgreSQL saat fase online (skema sudah cocok dengan GDD v0.1 §13).

**Prinsip #2 — Simulasi = calon server:** semua logika penting (damage, taming roll, craft roll, drop) lewat satu jalur `systems/` yang tidak menyentuh node/UI langsung. Saat fase online, folder `systems/` diangkat ke server hampir tanpa ubahan.

---

# 3. SISTEM WAKTU & LANGIT (jantung Aetherion — bangun paling awal)

## 3.1 GameClock.gd
```gdscript
# Waktu = jam perangkat, dipaksa ke WIB (UTC+7)
func now_wib() -> Dictionary:
    var t = Time.get_unix_time_from_system()
    return Time.get_datetime_dict_from_unix_time(int(t) + 7 * 3600)

# Fase bulan (algoritma siklus sinodik sederhana, akurasi ±1 hari — cukup untuk game)
const SYNODIC := 29.530588853
const KNOWN_NEW_MOON := 947182440  # 2000-01-06 18:14 UTC (referensi)
func moon_phase() -> float:   # 0.0 = bulan baru, 0.5 = purnama
    var days = (Time.get_unix_time_from_system() - KNOWN_NEW_MOON) / 86400.0
    return fposmod(days, SYNODIC) / SYNODIC

func is_full_moon() -> bool:  return abs(moon_phase() - 0.5) < 0.02   # ±0.6 hari
func is_new_moon() -> bool:   return moon_phase() < 0.02 or moon_phase() > 0.98
func tide_level() -> float:   # -1 surut ekstrem .. +1 pasang ekstrem
    return cos((moon_phase() - 0.5) * TAU) # purnama & bulan baru = pasang (spring tide)
```
- **Kalender event khusus** (solstice, meteor shower, gerhana) = file `data/sky_calendar.json` berisi tanggal astronomi asli 2 tahun ke depan (diisi manual dari data astronomi publik) → GameClock tinggal mencocokkan tanggal. Sederhana, tanpa perhitungan orbit.
- GameClock memancarkan signal via EventBus: `day_started`, `night_started`, `full_moon_began`, `golden_hour`, `sky_event(name)` → sistem lain tinggal subscribe. Inilah cara "dunia bereaksi" tanpa spaghetti.

## 3.2 Efek visual murah (game ringan)
- Siang-malam: satu `CanvasModulate` + kurva warna per jam (tanpa dynamic light per objek).
- Bulan & rasi: layer parallax sprite; fase bulan = 8 frame sprite dipilih dari `moon_phase()`.
- Hujan/salju: `GPUParticles2D` satu emitter layar penuh, dimatikan di Mode Hemat.

---

# 4. COMBAT & ELEMEN (arsitektur)

```
Input -> Player StateMachine (idle/move/attack/dodge/cast)
      -> CombatResolver.resolve(attacker_stats, defender_stats, skill, ctx)
```
`ctx` (konteks dunia) = kunci aturan sains: `{weather, underwater, target_wet, attacker_grounded, moon_phase, time}`.

```gdscript
# CombatResolver (potongan)
func elem_mod(atk_elem, def_elem, ctx) -> float:
    var m = Db.elements.matrix[atk_elem][def_elem]      # 1.3 / 1.0 / 0.7
    for rule in Db.elements.rules[atk_elem]:            # aturan sains dari JSON
        if rule.when_all_true(ctx): m *= rule.mult      # ex: fire+underwater -> x0.5
    return m
```
Aturan sains pun **data**: `{"element":"lightning","if":{"target_wet":true},"mult":1.3,"chain":true}` — designer bisa menambah interaksi tanpa programmer.

**Element Flow (infusi senjata):** komponen `Infusion` di Player: `{element, source, expires}`; CombatResolver membaca elemen dominan sesuai aturan anti double-dip (v0.3 §7).

**Monster generik:** satu scene `Monster.tscn` + resource dari `monsters.json` (sprite, BST→stat via arketipe, AI preset: melee/ranged/skittish/ambush). 64 spesies = 64 entri JSON + sprite.

---

# 5. TAMING, PET-MOUNT, HOMESTEAD (Fase 0 scope)

- **TamingSystem:** cek syarat (lvl, HP<5%, orb) → roll `chance(rarity, orb, pity)` → sukses: pindahkan entri ke `PlayerData.monsters[]`; gagal: enrage + pity++.
- **Pet-mount:** monster Medium+ dengan flag `rideable` + item saddle → tombol Mount kapan saja; saat mounted, kecepatan = SPD monster, pasif 50%.
- **Homestead:** scene instance terpisah; tiap plot menyimpan `{crop_id, planted_at_unix}`; saat load, pertumbuhan dihitung dari selisih waktu nyata (offline growth otomatis benar). Musim dicek dari GameClock.

---

# 6. HIDDEN SCENARIO ENGINE (kecil tapi sakral)

```json
// scenarios.json
{ "id": "moon_rabbit_warren",
  "counters": { "rabbits_killed": 10000 },
  "sky":      { "full_moon": true },
  "trigger_action": "sleep_at_inn",
  "no_fail": true,
  "scene": "res://scenes/scenarios/LunarWarren.tscn" }
```
- `WorldState` menaikkan counter dari EventBus (`monster_killed(species)`), TANPA UI apa pun — pemain tidak tahu dihitung.
- Saat `trigger_action` terjadi, ScenarioManager mengecek semua syarat → transisi paksa ke scene skenario.
- `no_fail: true` → hasil gagal ditulis permanen ke save (`scenario_locked`). Save di-hash sederhana untuk mencegah edit kasar (anti-cheat penuh menyusul di fase online).

---

# 7. EKONOMI NPC TERSIMULASI (Fase 0)
```
harga(item) = base_price × clamp(demand/supply, 0.5, 2.0)
```
- NPC toko punya stok yang menipis saat pemain memborong (harga naik) dan pulih per hari WIB → pemain sudah merasakan ekonomi hidup walau offline, dan formula ini jadi *price floor/ceiling* saat marketplace pemain hadir di Fase 2.
- Semua transaksi dicatat ke log lokal → kebiasaan audit sejak awal.

---

# 8. SAVE SYSTEM
- `user://save/slot_1.json` (+ backup rotasi 3 file, tulis atomik: tulis temp → rename).
- Isi: PlayerData + WorldState.counters + homestead + scenario flags + versi skema.
- Field `schema_version` + fungsi migrasi → save lama tetap hidup saat game update (wajib untuk game live).

---

# 9. TARGET PERFORMA (game ringan — diuji tiap milestone)
| Metrik | Target |
|---|---|
| RAM | < 500 MB |
| Draw calls | < 150 per frame |
| Entitas aktif | ≤ 60 monster per wilayah (spawner LOD: di luar layar = tick 1×/dtk) |
| Ukuran build Fase 0 | < 150 MB |
| FPS | 60 di iGPU; profil "Hemat" 30fps lock |

---

# 10. MILESTONE FASE 0 (solo dev / tim mini, ±10–14 minggu)
| Minggu | Deliverable |
|---|---|
| 1–2 | Proyek + autoload + GameClock (WIB, bulan, siang-malam visual) + gerak & kamera |
| 3–4 | CombatResolver + 3 monster + damage/elemen dari JSON |
| 5 | Element Flow + aturan sains ctx (hujan→wet→chain petir DEMO) |
| 6–7 | Taming + pet ikut + mount |
| 8 | Gathering + crafting bench + ekonomi NPC |
| 9 | Homestead + tanaman real-time |
| 10 | Hidden Scenario engine + Lunar Warren sederhana |
| 11–12 | Save/load, HUD, Sky Report, polish, playtest 30 menit |

Setiap milestone diakhiri **build yang bisa dimainkan**. Tidak ada milestone "50% jadi".

---

# 11. YANG SENGAJA TIDAK DIKERJAKAN DI FASE 0
Networking, akun, marketplace pemain, PvP, racing, breeding, fusion, guild, 12 wilayah lain, monetisasi. Semua sudah didesain (GDD v0.1–0.3) — fondasi ini dibangun agar semuanya tinggal "dicolok".
