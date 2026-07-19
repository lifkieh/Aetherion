# PETA KENYATAAN — apa yang pemain SEBENARNYA lihat

**Dibuat:** 2026-07-19 · **Pemicu:** temuan Direktur — game yang dijalankan pemain **tidak memakai LPC**.
**Sifat:** peta jujur. **Nol perbaikan, nol migrasi.** Semua klaim `path:baris`.

> **Ringkas satu kalimat:** temuan Direktur **benar sepenuhnya**. LPC ada di **satu scene yatim**
> yang tak pernah dimuat gameplay. Semua yang pemain lihat adalah `_charsys` 32px.

---

## 1 — Rantai scene saat pemain tekan Play

`game/project.godot:10` → `run/main_scene="res://scenes/ui/MainMenu.tscn"`

| # | scene | dipicu oleh |
|---|---|---|
| 1 | `ui/MainMenu.tscn` | main scene |
| 2 | `ui/ClassSelect.tscn` | `MainMenu.gd:143` ("Main Baru") |
| 3 | `ui/CharacterCreator.tscn` | `ClassSelect.gd:276` |
| 4 | `ui/Intro.tscn` | `CharacterCreator.gd:236` |
| 5 | **`scenes/Main.tscn` (GREENVALE)** | `Intro.gd:103` |

Jalur "Lanjutkan" memotong lebih pendek: `MainMenu.gd:147` → langsung `scenes/Main.tscn`.

### ➡ Dunia utama yang pemain masuki = **GREENVALE** (`scenes/Main.tscn`)

**Ashbrook TIDAK pernah otomatis dimasuki.** Ia hanya dicapai lewat **Gerbang Penjelajah /
TravelUI** (`TravelUI.gd:150` → `Stage.go_to_scene(r.scene)`), memakai `data/regions.json:8`:

```json
"ashbrook": { "scene": "res://scenes/world/Ashbrook.tscn", "kingdom": "valenford" }
```

Artinya Ashbrook adalah **wilayah opsional yang harus dituju sendiri**, bukan rumah pertama —
walau kanon #206/#118 menyebutnya *"rumah pertama pemain"* dan opening Pegasus menempatkan
pemain **bangun di rumah Merrit** (`Ashbrook.gd:85-92`). **Kanon dan alur kode tidak sejalan.**

---

## 2 — `Ashbrook64.tscn` — **SCENE YATIM**

**Nol rujukan dari gameplay.** Grep seluruh `game/`:

| path:baris | jenis rujukan |
|---|---|
| `autoload/CharGen.gd:19` | komentar dokumentasi |
| `world/Ashbrook64.gd:4` | docstring dirinya sendiri |
| `tests/VerifyLoop64.gd:18` | harness verifikasi |

**Nol di `regions.json`. Nol di `TravelUI`. Nol `go_to_scene`. Nol `preload`.**

### Kenapa dibuat kalau tak ter-wire?

Karena memang **diperintahkan begitu**, dan itu tercatat:
- Perintah #253/#254: *"BATAS: scene BARU terpisah. Ashbrook 16px lama TIDAK disentuh."*
- *"Ini bukti untuk keputusan, bukan migrasi. Satu layar."*
- Ashbrook64 lahir sebagai **layar bukti** untuk menjawab *"apakah 64px cukup indah?"* —
  lalu dipromosikan jadi **kandidat** migrasi penuh (commit `8aaa014`), dengan syarat eksplisit
  *"16px lama disimpan sampai 64px lolos"*.

**Jadi ia bukan kecelakaan — ia rancangan.** Yang belum pernah terjadi: **langkah promosi.**
Tak ada satu pun perintah yang pernah berkata *"jadikan Ashbrook64 scene yang dimainkan"*,
dan saya juga tak pernah mengusulkannya. **Itu lubang di alur keputusan kita, bukan di kode.**

⚠ **Dan saya ikut andil:** laporan-laporan saya berulang kali menulis *"Ashbrook LPC berdiri"*,
*"core loop terbukti utuh"* — semuanya benar **untuk scene itu**, tapi saya tak pernah menegaskan
cukup keras bahwa **pemain tak bisa mencapainya**. Kalimat "Ashbrook.tscn tidak disentuh dan tetap
scene yang dimainkan" memang ada di docstring dan commit, tapi terkubur di antara kabar baik.

---

## 3 — Angka jujur: scene yang bisa dimasuki pemain

**Scene dunia/gameplay yang dapat dicapai: 16.**

| kelompok | scene | sumber karakter |
|---|---|---|
| Dunia (6) | `Main` (Greenvale) · `Ashbrook` · `Desert` · `Candyveil` · `Frostpeak` · `StormIsland` | **`_charsys`** |
| Interior (1) | `HouseInterior` | **`_charsys`** |
| Dungeon (5) | `GreenvaleDepths` · `GummyCavern` · `Barrow` · `FoothillBarrow` · `ZephyrSpire` | **`_charsys`** |
| Homestead (1) | `Homestead` | **`_charsys`** |
| Skenario (3) | `LunarWarren` · `StarWhaleBelly` · `TeaParty` | **`_charsys`** |

**UI yang menampilkan karakter: 3** — `CharacterCreator` · `ClassSelect` · `MenuUI`(status) —
semuanya **`_charsys`**.

### Skor

| | jumlah |
|---|---|
| Scene yang pemain bisa masuki memakai **LPC** | **0** |
| Scene yang pemain bisa masuki memakai **`_charsys`** | **16** |
| Scene LPC yang ada di repo | **1** (`Ashbrook64.tscn`) — **yatim** |

**Nol persen dari game yang bisa dimainkan memakai LPC.**

Sebabnya satu titik: setiap karakter di dunia lahir dari autoload `CharGen`
(`Player.gd:42` · `Villager.gd:51` · `Interactable.gd:153`). Selama `CharGen` menyuplai,
**semua scene otomatis `_charsys`** — termasuk yang belum pernah saya sentuh.

---

## 4 — Character creator ke LPC: seberapa besar?

**Direktur benar bahwa ini wajah pertama game.** Ini pekerjaan **terbesar** dari seluruh migrasi
karakter, bukan yang termudah.

`CharacterCreator.gd` (240 baris) memanggil `CharGen` di **11 tempat**:
`:30, 103, 104, 105, 106, 188, 194, 199, 210, 211, 212, 213`

### Yang dipakai UI, dan kenapa sulit

| panggilan | dipakai untuk | padanan LPC |
|---|---|---|
| `CharGen.races()` (`:103-105, 194, 210-212`) | **tiga** pemutar ras terpisah: kepala · badan+tangan · kaki | **tidak ada** — LPC tak memisah ras per-bagian tubuh |
| `CharGen.hair_styles()` (`:106, 199, 213`) | pemutar rambut (6 gaya) | ada, tapi katalognya ratusan varian × warna |
| `CharGen.sprite_frames(cfg)` (`:188`) | pratinjau hidup 4 arah | perlu perakit LPC di **runtime** |
| `CharGen.default_config()` (`:30`) | konfigurasi awal | bentuk `char_config` berbeda total |

**Penghalang terbesar bukan jumlah baris — melainkan bentuk data.**
`_charsys` = **ras per-bagian** (`head_race`/`torso_race`/`legs_race`, `CharGen.gd:288`).
LPC = **satu badan + lapisan wardrobe**. Pemutar "Kaki (ras)" **tak punya arti** di LPC.

**Dan ada lapisan yang lebih dalam:** `char_config` tersimpan di **save file**
(`PlayerData.gd:714 "char_config": char_config`). Mengganti bentuknya = **migrasi save**,
bukan sekadar ganti UI.

### Ongkos kasar

| bagian | ongkos |
|---|---|
| Port perakit LPC ke runtime GDScript (kini Python design-time) | **5–10 unit** |
| Rancang ulang UI creator (3 pemutar ras → model wardrobe LPC) | **8–12 unit** |
| Migrasi `char_config` + `SAVE_SCHEMA` | **3–5 unit** |
| `Player`/`Villager`/`Interactable` ikut berpindah | **5–8 unit** |
| Test: 8 assertion mematok lebar 96px & 6 rambut (`TestRunner.gd:1419-1450`) | **2–3 unit** |
| **Total** | **≈23–38 unit** |

Sebagai pembanding: seluruh migrasi visual Ashbrook (dunia + 6 NPC) yang sudah jalan
≈ **56–86 unit**, dan **nol** di antaranya menyentuh creator.

---

## 5 — Greenvale vs Ashbrook: apakah 14 sesi salah sasaran?

**Ya untuk alur kode. Tidak untuk kanon.** Keduanya benar sekaligus, dan itu masalahnya.

| | Greenvale (`Main.tscn`) | Ashbrook (`Ashbrook.tscn`) |
|---|---|---|
| Dimasuki otomatis saat Play | **YA** (`Intro.gd:103`) | tidak |
| Disebut kanon sebagai rumah pertama | tidak | **YA** (#206/#118) |
| Punya opening (bangun di rumah Merrit) | tidak | **YA** (`Ashbrook.gd:85-92`) |
| Punya core loop bukti (#226) | **tidak — nol titik-periksa** | **YA — 6 titik** |
| Punya halaman Chronicle | tidak | **YA** (`place_ashbrook_besar`) |
| Kanon: *"kota awal kita = Greenvale"* (#207b/#211) | **YA** | — |

**Jadi:** Greenvale adalah kota awal **menurut kanon #211** *dan* pintu masuk **menurut kode**.
Ashbrook adalah rumah pertama **menurut kanon #206/#118** — tapi **kodenya tak pernah dibuat
mengantar pemain ke sana.**

⚠ **Ini konflik kanon yang belum pernah masuk ledger.** #206 menjadikan Ashbrook *"rumah pertama
yang sudah kehilangan sebagian besar dirinya"*, dan `Ashbrook.gd:85-92` mengimplementasikan
opening Pegasus dengan pemain **bangun di kamar Merrit** — tapi tak ada yang pernah mengubah
`Intro.gd:103` dari `Main.tscn` ke `Ashbrook.tscn`.

**14 sesi tidak sia-sia** — Ashbrook adalah satu-satunya tempat di seluruh game yang punya
core loop tesis (bukti · halaman · loss). Tapi **pemain yang menekan Play hari ini tidak akan
pernah melihatnya**, kecuali ia kebetulan membuka Gerbang Penjelajah dan memilih Ashbrook.

---

## Empat lubang yang peta ini buka

1. **Ashbrook64 yatim** — dibangun sesuai perintah, tapi langkah promosinya tak pernah ada.
2. **Nol scene LPC yang bisa dimainkan** — 0 dari 16.
3. **Opening kanon tak tersambung** — `Intro.gd:103` mengantar ke Greenvale, bukan Ashbrook,
   padahal Ashbrook punya opening Pegasus lengkap yang tak pernah dijalankan pemain baru.
4. **Core loop terkurung** — satu-satunya wilayah bertesis adalah tujuan opsional.

**Nol perbaikan dilakukan.** Empat lubang di atas adalah keputusan Direktur, bukan keputusan saya.
