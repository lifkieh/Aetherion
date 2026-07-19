# SWEEP CAKUPAN PENUH — pasca-perubahan autoload sesi ini

**2026-07-20** · Cakupan di luar loop Ashbrook. Yang diperiksa: apa pun yang bisa
putus karena sesi ini menyentuh **Chronicle · PlayerData (SAVE_SCHEMA 2→3) ·
EventBus (`elyn_stage_changed`) · Projectile (penjaga `_source`)**.

**Ringkas: nol regresi ditemukan. Dua cacat NYATA ditemukan — keduanya PRA-ADA,
bukan akibat sesi ini. Tak satu pun ditambal (menunggu putusan Direktur).**

---

# 11 — SISTEM LAIN

Semua sistem di bawah punya cakupan suite; suite dijalankan lewat gerbang #273
(`_tools/run_suite.ps1`) — **exit 0, 1079 lulus, 0 gagal.**

| Sistem | Status | Catatan |
|---|---|---|
| Tempur · elemen · fusion | ✅ | termasuk jalur peluru yang baru dijaga (#UTANG-249) |
| Profesi | ✅ | |
| Homestead | ✅ | scene boot bersih (§14) |
| Memancing | ✅ | |
| Pet / taming | ✅ | |
| Enchant | ✅ | |
| Rumah Lelang | ✅ | |
| Jadwal NPC | ✅ | |
| Musim · cuaca · bulan · rasi | ✅ | terikat WIB nyata (sebab #249, tak berubah) |
| Foto-mode | ✅ | |
| Lokalisasi | ✅ | slot EN teks Kitab ikut ditulis saat LANGKAH 6 |

## Permukaan sentuh yang diperiksa manual

**`PlayerData` schema 3** — tiga medan baru (`memory_held`, `elyn_burden`,
`elyn_age_spent`) plus `elyn_stage()`. Pembacanya **hanya** `Chronicle` dan tab
Kitab `MenuUI`. Nol sistem lain menyentuhnya, jadi nol permukaan regresi di luar
loop payoff. Diverifikasi lewat pencarian menyeluruh, bukan asumsi.

**`EventBus.elyn_stage_changed`** — dipancarkan `Chronicle.restore_elyn()`, **nol
pendengar** hari ini. Sinyal tanpa pendengar tak bisa memutus apa pun; ia kail untuk
potret/dialog nanti (#267/#268). Aman.

**`Projectile2` / `Projectile`** — `_live_source()` mengubah **apa yang diteruskan**
(`null` menggantikan rujukan mati), bukan apakah peluru mengenai. Perilaku pukulan
tak berubah; suite tempur lulus penuh.

---

# 12 — SAVE/LOAD LINTAS-SESI

Suite sudah menguji `to_save()`/`from_save()` **di dalam satu proses**. Yang belum
tersentuh: **tulis ke disk → tutup proses → muat di proses baru** — jalur yang
dipakai pemain, lewat `SaveManager` (tulis atomik, rotasi cadangan, `schema_version`).

Harness baru: `game/tests/SaveLintas.tscn`, **tiga fase, tiga proses terpisah.**

| Fase | Hasil |
|---|---|
| **tulis** (schema 3, slot 2) | ✅ `save_game` berhasil · tahap Elyn `prima_akhir` (umur 254) |
| **muat** (proses baru) | ✅ nama · `memory_held` · `elyn_burden` · `elyn_age_spent=120` · **tahap Elyn pulih `prima_akhir`** · halaman tercoret pulih · halaman Ashbrook tetap ada (idempoten) |
| **lama** (save diturunkan ke schema 2 **di disk**) | ✅ tetap termuat, **nol crash** · ketiga medan default **KOSONG** · tahap Elyn `prima` · `memory_full()` tak meledak · nama tetap pulih |

▸ **Regresi save lama: TIDAK ADA.** Pemain pra-#256 memuat save-nya dan mendapat
ruang-ingatan kosong — bukan nilai sampah, bukan crash. Dan **tahap Elyn-nya
`prima`**, bukan tahap acak: ia mulai dari awal, sebagaimana seharusnya.

---

# 13 — ⚠ CACAT NYATA: "Muat Slot" mengabaikan lokasi tersimpan

**Dikonfirmasi. Dan lebih luas daripada jebakan playtest.**

```gdscript
# MainMenu.gd:112 — LABEL memakai lokasi dari save
"Muat Slot %d — %s · %s Lv%d · %s · %s" % [..., meta.get("location", "?"), ...]

# MainMenu.gd:146-148 — TUJUAN mengabaikannya sama sekali
func _load(slot: int) -> void:
    if SaveManager.load_game(slot):
        Stage.go_to_scene("res://scenes/Main.tscn")     # <- selalu Greenvale
```

**Yang salah: TUJUAN, bukan label.** Label membaca `meta.location` dengan benar —
ia melaporkan apa yang tersimpan. `_load()` yang membuang informasi itu dan
mengeraskan `Main.tscn`.

## Ini PRA-ADA, bukan akibat sesi ini

`_load()` sudah mengeraskan `Main.tscn` sejak sebelum Ashbrook64 lahir. Artinya
**pemain yang menyimpan di Ashbrook 16px pun mendarat di Greenvale saat memuat.**
Ashbrook64 hanya membuatnya **terlihat**, karena labelnya kini menyebut wilayah yang
jelas bukan Greenvale.

⚠ **Cakupannya lebih besar dari Ashbrook:** cacat ini berlaku untuk **setiap** wilayah.
Simpan di Candyveil, Frostpeak, Storm Island — muat, dan Anda di Greenvale.

## TIDAK DITAMBAL — dua jawaban sah, dan itu putusan Direktur

| Pilihan | Artinya |
|---|---|
| **(a) Perbaiki tujuan** — `_load()` merutekan menurut `meta.location` lewat `regions.json` | Save kembali ke tempatnya. Tapi Ashbrook64 masih **sementara** (#LANGKAH 7); merutekan ke sana mengukuhkannya lebih cepat daripada rencana. |
| **(b) Perbaiki label** — tampilkan "Greenvale" apa adanya | Jujur seketika, nol risiko. Tapi ia **menormalkan** kehilangan posisi, dan itu cacat yang sebenarnya. |

▸ Rekomendasi saya **(a)**, tapi **setelah** playtest — karena ia menyentuh
`regions.json`, dan Direktur sudah menetapkan penggantian permanen Ashbrook64
menunggu playtest lulus. Menambalnya sekarang mendahului putusan itu.

**Sampai diputus: pakai "Main Baru" untuk self-playtest.** Isi slot 1 sendiri bersih
(`place_ashbrook_besar` masih `struck`, `memory_held` kosong) — payoff belum terpakai.

---

# 14 — BOOT 21 SCENE + Main

**22 dari 22 boot bersih. Nol crash, nol `SCRIPT ERROR`, nol screenshot gagal.**

| | Scene |
|---|---|
| **Wilayah (6)** | Ashbrook · **Ashbrook64** · Candyveil · Desert · Frostpeak · StormIsland |
| **Dungeon (5)** | Barrow · FoothillBarrow · GreenvaleDepths · GummyCavern · ZephyrSpire |
| **Skenario (3)** | LunarWarren · StarWhaleBelly · TeaParty |
| **Lain (7)** | HouseInterior · DungeonTerrain · EchoVendor · GatherNode · Puddle · Interactable · Homestead |
| **Target muat (1)** | **Main.tscn** (Greenvale) — ditambahkan karena §13 |

▸ `Main.tscn` sengaja dimasukkan: ia tujuan `_load()`, jadi kalau ia rusak, **setiap**
pemuatan save rusak. Ia bersih.

---

# RINGKASAN REGRESI

**Regresi akibat sesi ini: NOL.**

| Temuan | Sifat | Tindakan |
|---|---|---|
| `_load()` mengabaikan lokasi tersimpan | **cacat nyata, PRA-ADA**, berlaku semua wilayah | ⏸ menunggu putusan Direktur (§13) |
| Titik-periksa 5 di luar batas tanah (y=1152 > 1088) | cacat kecil, lahir bersama Ashbrook64 | ⏸ bukan pemblokir; jalur minimum di dalam peta |

Keduanya **tak menghalangi loop payoff diselesaikan pemain.**

**Gerbang #273: exit 0 — 1079 lulus, 0 gagal.**
