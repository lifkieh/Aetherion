# LANGKAH 7 — rantai §0 dijalankan SEBAGAI PEMAIN

**2026-07-19** · `_tools/godot ... --script res://tests/PlayLoop64.gd`
`AETHER_PLAY_PATH=self|elyn|penuh` · **22 gambar** di `reports/preview/7_main_*.png`

**Hasil: tiga jalur, ketiganya `rantai UTUH`. Suite 1052 lulus, 0 gagal.**

---

## Yang membedakan ini dari harness sebelumnya

`ShotKitab.gd` memanggil fungsi Kitab langsung. `PlayLoop64.gd` **tidak**. Ia memuat
`Ashbrook64.tscn` yang sebenarnya — pemain, HUD, MenuUI, WorldController — lalu:

- menekan **tombol** lewat `Input.parse_input_event()`, jadi `WorldController._unhandled_input()`
  yang memutuskan apa yang terjadi, bukan harness;
- menekan tombol Kitab lewat `emit_signal("pressed")` pada `Button` aslinya, jadi callback
  yang jalan adalah callback yang dipasang UI.

**Satu hal yang tidak ditiru: berjalan kaki.** Pemain di-*warp* ke depan tiap titik-periksa,
lalu tombolnya ditekan sungguhan. Yang diuji rantainya (jarak → `interact()` → `Evidence` →
`Chronicle` → Kitab), bukan pathfinding.

---

## TIGA SAMBUNGAN PUTUS YANG DITEMUKAN — dan apa isinya

### 1. `Ashbrook64` adalah DIORAMA, bukan tempat yang bisa dimainkan

```
PUTUS: Ashbrook64 tanpa pemain — grup "player" kosong
```

Scene itu punya lima titik-periksa di koordinat yang benar, tapi **nol pemain, nol UI,
nol pengendali**. `Interactable` mencari grup `"player"` untuk menghitung jarak; tak ada
yang bisa berdiri di depannya, dan tombol E tak tersambung ke apa pun. Rantai putus di
sambungan **pertama**.

Diperbaiki: `_spawn_player()` + `_add_ui()` (HUD · MenuUI · WorldController) +
`SafeZone.set_region()` + `mark_visited()`. Kamera Player dipatok `2.0` untuk dunia 16px —
di petak 32 itu memperbesar dua kali lipat dan alun-alun tak lagi muat; ia disetel ke
`ZOOM` yang sudah dinilai pada 5b.

### 2. Empat dari lima titik melapor "tak terjangkau" — padahal baik-baik saja

```
periksa ev_ashbrook_gudang_gandum → tercatat
PUTUS: titik ev_ashbrook_halloran_200_roti tak terjangkau
PUTUS: titik ev_ashbrook_jembatan_terlalu_lebar tak terjangkau
... jenis terkumpul: ["akibat"]  → SENDIRI mustahil
```

Bukan bug scene. Bug **harness**, dan ia hampir membuat saya melaporkan kerusakan palsu:

- `Interactable.interact()` diawali `if Stage.is_busy(): return`. Setelah titik pertama,
  teks periksa terbuka dan **menutup semua interaksi berikutnya** — persis seperti di
  permainan sungguhan.
- `Stage._input()` menutup teks itu dengan memeriksa **`event.keycode`** mentah (E/Space/Enter).
  Saya mengirim `InputEventAction`, yang **tak punya keycode**. Teksnya tak pernah tertutup.

Diperbaiki: kirim `InputEventKey` dengan `keycode` **dan** `physical_keycode` terisi (peta
input memakai physical), lalu tekan E berulang selama `Stage.is_busy()` — persis yang
dilakukan pemain. Kelima titik langsung tercatat.

### 3. Penekanan tombol tidak langsung sampai

`Input.parse_input_event()` menaruh event ke antrean; ia baru tiba di `_unhandled_input()`
pada putaran berikutnya. Memeriksa akibatnya di baris berikutnya selalu membaca keadaan
**sebelum** tombol bekerja. Tiap penekanan kini dipecah dua putaran.

---

## SATU LAGI: siang abadi diam-diam membatalkan payoff #218

Bukan bagian rantai §0, tapi ditemukan begitu scene-nya bisa dimainkan. `Ashbrook64._ready()`
memaku `CanvasModulate` ke putih — dipasang dulu supaya tangkap-layar reprodusibel. Efeknya
di permainan: **Ashbrook tak pernah malam**, jadi lentera Merrit tak pernah jadi
satu-satunya yang menyala, dan seluruh payoff #218 tak pernah terjadi.

Diperbaiki: langit ikut `GameClock`, lentera & beacon mengikuti jam WIB dengan aturan yang
sama seperti `Ashbrook.gd` — termasuk menekan beacon jadi transparan saat pemain dekat
(pelajaran yang sudah dibayar di scene 16px: beacon 6×6 px di atas segalanya terbaca
sebagai kotak gelap menempel di kaca lentera). `AETHER_PIN_DAY=1` mematok siang untuk harness.

Buktinya: `7_main_self_09_kembali_ke_dunia.png` — pukul 23:39, **lentera Merrit satu-satunya
cahaya di seluruh Ashbrook.**

---

## Rantai yang dijalankan, per jalur

| tahap | self | elyn | penuh |
|---|---|---|---|
| halaman lahir `by:merrit_fane` + tercoret **senyap** | ✅ | ✅ | ✅ |
| tiba di Ashbrook64, 6 interactable hidup | ✅ | ✅ | ✅ |
| 5 titik diperiksa → `["akibat","kebiasaan","benda"]` | ✅ | ✅ | ✅ |
| buka Kitab (tombol I), halaman tercoret tampil | ✅ | ✅ | ✅ |
| "Tulis ulang" → pilih jalur | ✅ | ✅ | ✅ |
| keterbukaan Elyn **sebelum** menulis (#259) | — | ✅ | ✅ |
| penolakan ruang penuh (#257), Elyn tetap ada (#228) | — | — | ✅ |
| halaman pulih + loss "orang" | ✅ | ✅ | ✅ |
| ruang pemain / beban Elyn bertambah | `memory_held` | `burden`, umur −1 | `burden`, umur −1 |

Loss ketiganya: **"Ashbrook tercatat sebagai kota. Bukan sebagai seribu lima ratus orang."**

Pemeriksaan yang ikut dijalankan tiap putaran, dan gagal keras kalau bocor:
`state == struck` sebelum keterbukaan Elyn ditampilkan (#259) · `state == struck` saat ruang
penuh (#257) · loss tak pernah kosong (#226 #3) · label "dipulihkan dari kesaksian" hadir.

---

## Jalan pemain menuju Ashbrook64 — **SEMENTARA**

`regions.json` **tidak disentuh**. Ashbrook64 dijangkau lewat `Intro.gd`:

```
MainMenu → ClassSelect → CharacterCreator → Intro → Ashbrook64
```

`CharacterCreator` sudah memanggil `WorldState.new_game()` sebelum Intro, jadi halaman
`place_ashbrook_besar` sudah lahir **dan** sudah tercoret saat pemain tiba. Prasyarat
rantai §0 terpenuhi sendirinya di jalur nyata.

**Mencabutnya: kembalikan `Intro.NEXT_SCENE` ke `res://scenes/Main.tscn`. Satu baris.**

---

## Yang JUJUR masih terbuka — untuk playtest manusia

1. **Nol tabrakan.** Pemain berjalan menembus fasad, air mancur, dan bangku. `Ashbrook.tscn`
   16px punya `_build_boundaries()`; Ashbrook64 belum.
2. **Nol jalan keluar.** Tak ada gerbang dunia, tak ada `_world_gate()`. Sekali masuk,
   Ashbrook64 satu-satunya tempat.
3. **Titik-periksa dicapai dengan warp di harness**, bukan dengan berjalan. Jarak antar
   titik belum pernah dilalui kaki manusia — apakah 1856,704 terasa jauh? Belum diketahui.
4. **Papan Otha** (`ev_otha_papan_bekas_cat`) ada di scene tapi bukan bagian halaman
   Ashbrook; halaman Otha sendiri belum pernah lahir di jalur pemain.
5. **Rumah tak bisa dimasuki.** Pintu digambar, tapi tak ada interior — `_build_interior()`
   milik scene 16px tak punya padanan di sini.
