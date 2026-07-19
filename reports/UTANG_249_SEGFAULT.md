# UTANG-249 — SEGFAULT FLAKY DI SUITE

**2026-07-20** · **BELUM DITUTUP.** Diselidiki, dilokalisasi, **akar belum terbukti.**
Prioritas: **sebelum playtest** — playtest bersandar pada suite hijau yang bermakna.

---

# RINGKAS

| | |
|---|---|
| **Gejala** | `CrashHandlerException: Program crashed with signal 11` di tengah run |
| **Frekuensi** | **± 20–25%** — 2 dari 8, lalu 1 dari 10 (run bersih) |
| **Lokasi** | **DETERMINISTIK** — selalu berhenti di titik yang sama |
| **Akar** | ❌ **belum terbukti** |
| **Hipotesis Direktur (MonsterFactory "nope")** | ❌ **TERBANTAH** — lihat §2 |
| **Mitigasi yang bisa dipasang HARI INI** | ✅ ada, murah — lihat §5 |

---

# 1 — LOKASI: deterministik, dan bukan di tempat yang diduga

Sepuluh run instrumentasi. Tiap crash berhenti di **titik yang sama persis**:

```
[PASS] boss flagged
[PASS] boss starts phase 1
DBG-A          <- var monsters_before := ...
DBG-B
DBG-C          <- boss.hp = int(boss.max_hp * 0.7)
               <- CRASH di sini
(DBG-D tak pernah tercapai = await get_tree().physics_frame pertama)
```

**Crash terjadi DI DALAM physics frame pertama** setelah HP bos diturunkan melewati ambang
0,75 — yaitu saat `_spawn_adds(2)` berjalan dan dunia penuh objek yang baru saja
`queue_free()`.

`TestRunner.gd` ± baris **1765–1782**:

```gdscript
ProjectilePool.spawn(Vector2(0,0), Vector2.RIGHT, "spark", ..., actor, "monsters")  # :1767
...
m1.queue_free(); m2.queue_free(); actor.queue_free()                                # :1770
var boss = preload(".../DungeonMonster.tscn").instantiate()
add_child(boss)                                                                     # :1774
boss.setup(MonsterFactory.make("king_slime", 15, 3))
await get_tree().process_frame
check("boss starts phase 1", boss._phase == 1)
boss.hp = int(boss.max_hp * 0.7)
await get_tree().physics_frame     # <- CRASH
```

---

# 2 — HIPOTESIS MonsterFactory `"nope"` TERBANTAH

`[MonsterFactory] unknown species: nope` adalah baris terakhir di **stderr**. Titik berhenti
suite ada di **stdout**. **Dua aliran berbeda** — yang satu tak menunjukkan waktu yang lain.

`MonsterFactory.make("nope")` sendiri bersih:

```gdscript
var def := Db.monster(species_id)
if def.is_empty():
    push_error("[MonsterFactory] unknown species: " + species_id)
    return {}
```

`push_error` tak pernah membunuh proses. Test negatif itu (`TestRunner.gd:489`) berjalan
**jauh lebih awal** daripada titik crash, dan lulus tiap kali.

▸ **Aturan yang dipetik:** saat suite mati, **baris terakhir stderr bukan tempat kejadian.**
Baca `stdout` untuk lokasi, `stderr` untuk sebab.

---

# 3 — YANG TERLIHAT SEBELUM CRASH

Instrumentasi di `Projectile2._on_body()` menangkap satu run crash:

```
DBG-C
DBG-PROJ hit body=@CharacterBody2D@201 src_valid=true
               <- CRASH
```

Jadi sebuah **peluru dari pool sedang menabrak sesuatu** tepat saat crash, dan sumbernya
**masih valid** saat `_on_body` masuk.

## Tersangka utama (belum terbukti): peluru bocor antar-test

`ProjectilePool` adalah **autoload** — ia hidup melewati batas test.

1. `:1767` menembakkan peluru **dan tak pernah melepaskannya**; peluru tetap `active`
   selama `_life`-nya.
2. `:1770` membebaskan `actor` — **pemilik peluru itu**.
3. Peluru terus terbang ke bagian bos, menabrak bos/adds yang muncul di sekitar titik asal.
4. `Projectile2._physics_process` **punya** penjaga `is_instance_valid(_source)` (`:56`) —
   tapi `_on_body` dipanggil oleh physics server dan **bisa mendahului** `_physics_process`
   pada frame yang sama. Di `_on_body` **tak ada penjaga itu**.
5. `body.take_hit(res, _source)` → `EventBus.damage_dealt.emit(from, ...)`
   (`DungeonMonster.gd:532`) → `DebugOverlay._on_damage()` (autoload) melakukan
   `if attacker == p` pada objek yang mungkin sudah dibebaskan.

**Ini pas dengan semua bukti** — termasuk kenapa ia acak: bergantung pada apakah `actor`
sudah benar-benar dihapus saat peluru mendarat, dan pada urutan physics server vs
`_physics_process` di frame itu.

**Tapi ia BELUM TERBUKTI.**

---

# 4 — KENAPA BELUM TERBUKTI: menambah `print` MENGHILANGKANNYA

Instrumentasi halus di dalam `_on_body` (5 titik) → **16 run berturut-turut tanpa crash.**

Ia **Heisenbug**: `print` memperlambat frame secukupnya untuk mengubah interleaving.
Konsisten dengan balapan waktu, dan **itulah sebabnya penyelidikan berhenti di sini** —
melangkah lebih jauh butuh alat yang tak mengubah waktu (build debug + debugger, atau
pengulangan besar dengan seed tetap), bukan tebakan.

⚠ **Konsekuensi praktis:** siapa pun yang mencoba menambal ini akan melihat crash "hilang"
setelah suntingan apa pun yang menyentuh waktu — **termasuk tambalan yang salah.**
**Jangan nyatakan tertutup hanya karena 10 run hijau.**

---

# 5 — MITIGASI YANG BISA DIPASANG SEKARANG (belum dipasang)

**Lubang paling berbahaya bukan crash-nya — melainkan LOLOS PALSU.**

Run yang crash **tidak pernah mencetak baris `===== RESULT: N passed, M failed =====`.**
Log berhenti di 164 baris; run sehat 1186 baris.

> **Karena itu: gerbang #249 harus memeriksa KEHADIRAN baris RESULT, bukan hanya
> ketiadaan `[FAIL]`.**
>
> Sekarang: *"nol `[FAIL]`"* → run yang mati di tengah **lolos**, karena ia memang tak
> sempat mencetak `[FAIL]` apa pun.
> Seharusnya: *"baris RESULT ADA **dan** `0 failed`"*.

Itu menutup lolos-palsu **tanpa** menunggu akar ditemukan. **Belum saya pasang** — ia
mengubah cara gerbang dibaca, dan itu keputusan Direktur, bukan agent.

---

# 6 — DUA KANDIDAT PERBAIKAN (keduanya BELUM diverifikasi)

## (a) Bug test — peluru bocor melewati batas test

`TestRunner.gd:1767` menembakkan peluru dan tak pernah melepaskannya, lalu `:1770`
membebaskan pemiliknya. **Peluru aktif dengan pemilik yang dibebaskan, mengambang ke
test-test berikutnya.**

Perbaikan: lepaskan/nonaktifkan peluru itu sebelum membebaskan `actor`.

⚠ **Ini memperbaiki gejalanya di suite, bukan penyebabnya di produksi.**

## (b) Celah ketahanan produksi — `_on_body` tak menjaga `_source`

`Projectile2._physics_process:56` menjaga `is_instance_valid(_source)`; `_on_body` tidak.

**Ini bukan hipotetis untuk pemain:** peluru bisa masih terbang ketika penembaknya mati —
monster yang menembak lalu terbunuh, pemain yang mati saat panahnya di udara. Jalur
kodenya sama.

Perbaikan: penjaga yang sama di `_on_body`, dan/atau `DungeonMonster.gd:532` tak
memancarkan `from` yang sudah tak valid.

▸ **(b) layak dikerjakan walau ia bukan penyebab crash ini** — tapi **jangan** dipakai
sebagai bukti penutupan.

---

# 7 — ATURAN SAMPAI DITUTUP (Direktur, 2026-07-20)

> **Kalau "0 gagal" hilang, PERIKSA crash vs `[FAIL]` DULU sebelum menyalahkan commit.**

Cara memeriksa, dua detik:

```
Select-String -Path <stderr.log> -Pattern "signal 11"      # crash?
Select-String -Path <stdout.log> -Pattern "===== RESULT"   # suite selesai?
```

- Ada `signal 11`, tak ada `RESULT` → **crash flaky, bukan salah commit.** Ulang run.
- Ada `RESULT` dengan `M failed > 0` → **kegagalan nyata.** Selidiki commit.

---

# 8 — SISA PEKERJAAN

1. Buktikan akarnya dengan alat yang tak mengubah waktu (bukan `print`).
2. Putuskan gerbang #249: apakah kehadiran baris `RESULT` jadi syarat (§5).
3. Kerjakan (b) terlepas dari hasil (1) — ia celah ketahanan produksi yang nyata.
4. Tutup utang ini **hanya** setelah ± 50 run berturut-turut bersih, bukan 10.
