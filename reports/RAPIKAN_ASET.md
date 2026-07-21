# RAPIKAN ASET — TAHAP A: PETA, BUKAN PEMINDAHAN

**Dibuat:** 2026-07-21 · **Sifat:** rencana. **NOL berkas dipindah. NOL kode diubah.**
**Alat:** `_tools/peta_aset.py` (#240) · data mentah `_tools/_peta_aset.json`

| | |
|---|---|
| Aset di `game/assets/` | **431** berkas · 27 folder |
| Berkas sumber dipindai | 796 (`.gd` `.tscn` `.tres` `.json` `.import` `.md` `.py`) |
| **Yatim sungguhan** | **22** |
| Pola nama dinamis ditemukan | **29** |

---

## ⚠ TEMUAN UTAMA — dan ia mengubah bentuk pekerjaannya

**Daftar yatim versi pertama berisi 207 berkas. Yang benar 22.**
Kalau daftar pertama itu dipercaya lalu dipindahkan, yang mati sekaligus:
dua puluh warga kota, seluruh fase bulan, tiap ikon elemen, tiap ikon barang,
dan enam bangunan Ashbrook 16px — **tanpa satu galat pun muncul**, karena
`ResourceLoader.exists()` mengembalikan `false` dengan tenang.

Sebabnya: **Ashbrook menyusun path saat jalan, bukan menuliskannya utuh.** Ada
**empat tingkat** penyusunan, dan tiap tingkat butuh cara pelacakan sendiri:

| tingkat | contoh | kenapa grep gagal |
|---|---|---|
| 1 · utuh | `preload("res://.../Wisp.gd")` | — (grep berhasil) |
| 2 · awalan konstanta | `_put(P_S + "fasad_inn.png")` | jalur penuh tak pernah ditulis |
| 3 · awalan **dipilih** | `_jejak("rock.png")` → `P_T` **atau** `P_OLD`, ditentukan dari akhiran nama | folder tujuan baru diketahui saat jalan |
| 4 · nama **dibentuk** | `"warga_%02d" % n` lalu `+ "_walk.png"` | nama utuh tak ada **di mana pun**, bahkan potongannya dari variabel |

Tingkat 4 yang paling berbahaya: `warga_07_walk.png` tak muncul di satu berkas pun.

---

## Peta folder sekarang

| folder | isi | catatan |
|---|---|---|
| `sprites/characters` | **100** | 20 warga × 3 pose + 6 NPC × 4 + anak + pemain |
| `sprites/props` | **66** | ⚠ pusat masalah — lihat di bawah |
| `sprites/monsters` | 25 | |
| `sprites/lpc32` | 22 | fasad + potongan dinding lama |
| `sprites/buildings` | 10 | bangunan 16px (Ashbrook lama, Frostpeak) |
| `sprites/animals` · `player` · `dungeon` · `t64` | 6 · 4 · 3 · 3 | |
| `tiles` (akar) | 15 | tercampur: rumput, salju, badai, gua |
| `tiles/{candyveil,dungeon,desert,lpc32,t64}` | 11 · 7 · 6 · 12 · 3 | sudah per-wilayah ✔ |
| `ui/icons` · `ui/prompts` · `ui/kenney` · `ui` | 40 · 27 · 3 · 2 | |
| `audio/{sfx,music,stingers}` | 24 · 9 · 5 | sudah rapi ✔ |
| `sky/{constellations,moon}` | 12 · 8 | sudah rapi ✔ |
| `vfx` · `fonts` | 1 · 1 | |

---

## 🔴 HAMBATAN KERAS — `props/` TIDAK BISA dibagi begitu saja

Direktur mengusulkan `props/bangunan/ · props/dekorasi/ · props/alam/ · props/tanah/`.
Struktur itu benar secara isi, tapi **lima tempat memanggil `props/` sebagai folder
DATAR, dengan nama berkas datang dari data**:

```
game/scenes/Main.gd:96          load("res://assets/game/sprites/props/%s.png" % pair[0])
game/scenes/Main.gd:344         load("res://assets/game/sprites/props/%s.png" % pick)
game/scenes/world/Frostpeak.gd:214   ... % d[0]
game/scenes/world/GatherNode.gd:67   ... % name
game/scenes/world/HouseInterior.gd:95 ... % name
```

Begitu `rock.png` pindah ke `props/alam/`, kelimanya **berhenti menemukannya**, dan
tak satu pun melempar galat — prop cuma **hilang dari layar**. Persis cacat
lentera-jadi-kotak, dan test suite tak bisa melihatnya karena tak ada yang gagal.

Ditambah `Ashbrook64._jejak()` (tingkat 3) yang memilih folder dari **akhiran nama**:

```gdscript
var akar := P_T if nama.ends_with("32.png") else P_OLD
```

Aturan itu langsung batal kalau `props/` bercabang.

### Tiga jalan, dan rekomendasinya bukan yang paling rapi

| | jalan | ongkos | risiko |
|---|---|---|---|
| **A** | Biarkan `props/` datar. Rapikan yang lain saja. | ~nol | ~nol |
| **B** | Bagi `props/`, ubah 5 pemanggil jadi **mencari di sub-folder** | sedang | sedang — perlu uji mata tiap wilayah, bukan cuma Ashbrook |
| **C** | Bagi `props/` + **manifes nama→jalur** (`props_index.json`, dilahirkan skrip) | lebih besar | **paling kecil** — nama tetap kunci, folder jadi urusan manifes; satu tempat gagal keras kalau nama tak ketemu |

**Rekomendasi: A sekarang, C nanti kalau `props/` tumbuh melewati ~100 berkas.**

Alasannya bukan malas. Yang dikeluhkan Direktur adalah **sulit menemukan aset**, dan
itu masalah **pencarian**, bukan masalah folder. `_tools/peta_aset.py` +
`_peta_aset.json` sudah menjawabnya: satu perintah memberi tahu tiap aset dipakai
di mana. Memindah 66 berkas untuk memperbaiki pencarian berarti membayar risiko
gagal-senyap di lima wilayah demi kenyamanan yang sudah bisa didapat gratis.

---

## ✅ YANG AMAN DIRAPIKAN SEKARANG (nol pemanggil dinamis)

Ketiganya folder **tanpa** pola `%s`, jadi tiap rujukan bisa dilacak dan diperbaiki:

1. **`tiles/` akar (15 berkas) → per-wilayah.** Saudara-saudaranya sudah begitu
   (`tiles/dungeon`, `tiles/desert`, …), akarnya saja yang masih campur: rumput
   Greenvale, salju Frostpeak, batu badai, `nature.png`.
   ⚠ **Tapi** `Town.gd` · `Ashbrook.gd` · `Frostpeak.gd` · `StormIsland.gd` memakai
   `"res://assets/game/tiles/%s.png"` — **hambatan yang sama dengan props/**.
   → **Tunda.** Masuk daftar yang sama dengan `props/`.

2. **`sprites/t64/` (3) + `tiles/t64/` (3) → `_arsip/t64/`.** Percobaan petak 64 px
   yang sudah ditinggalkan; nol rujukan kode. **Aman.**

3. **`sprites/lpc32/` (22)** — campur fasad & potongan dinding lama. Bisa dipecah
   `lpc32/fasad/` + `lpc32/potongan/`; semua rujukan memakai awalan konstanta `P_S`
   yang bisa dipecah jadi dua konstanta. **Aman, tapi manfaatnya kecil.**

---

## 📦 YATIM SUNGGUHAN — 22 berkas

Usul: **`game/assets/_yatim/`**, dipindah, **tidak dibuang** (perintah Direktur).

| berkas | kenapa yatim | ⚠ catatan |
|---|---|---|
| `lpc32/fasad_inn.png` | **baru saja jadi yatim** — 1.7a mengganti pemakaian terakhirnya (Merrit→`fasad_singgah`, balai→`fasad_balai`) | **masih dilahirkan `gen_fasad.py`** |
| `lpc32/pintu.png` | digambar **ke dalam** fasad, tak pernah dimuat sendiri | masih dilahirkan `gen_fasad.py` |
| `lpc32/wall_brick · wall_inn · wall_wood · window_lpc` | potongan dinding sebelum fasad dirakit | dilahirkan `gen_lpc32_slices.py` |
| `tiles/lpc32/kabut32.png` | **digantikan treeline** (`_pemakaman_dan_kabut`: "Kabut lama terbaca RATA dan TERANG") | dilahirkan `gen_c4.py`, `gen_treeline.py` |
| `sprites/t64/inn64_upscaled · lantern64_upscaled · lantern_glow64_upscaled` | percobaan 64 px | tak ada generator |
| `tiles/t64/cobble64 · dirt64 · grass64` | idem | dilahirkan `gen_tiles64.py` |
| `sprites/props/fence_post · tree_dead_c · tree_pine_big` | saudaranya dipakai, yang ini tak pernah | |
| `sprites/monsters/star_whale.png` | | |
| `sprites/player/dead.png` | | |
| `ui/palette.png` · `ui/icons/fluffbit_32 · moonbit_32` | | |
| `ui/kenney/panel-010 · panel-border-000` · `ui/prompts/pad_lt.png` | | |
| `vfx/fire_flow_strip.png` | | |

### ⚠ Jebakan yang harus ikut dibereskan kalau yatim dipindah

**Sembilan dari 22 masih DILAHIRKAN generator.** Memindahkannya tanpa menyentuh
generatornya berarti berkas itu **muncul lagi di tempat lama** pada regenerasi
berikutnya — dan sesudah itu ada dua salinan, satu di `_yatim/`, satu di tempat asal,
dan tak ada yang tahu mana yang benar. **Generator harus ikut diarahkan, atau
barisnya dimatikan dengan catatan alasan.**

---

## Dua batas kejujuran alat ini

1. **Komentar ikut terhitung sebagai pemakaian.** `wall_ruin.png` dinyatakan
   "dipakai" padahal satu-satunya penyebutnya adalah komentar di `Ashbrook64.gd`
   yang menjelaskan bahwa berkas itu **salah** dan sudah ditinggalkan. Alat ini
   membaca teks, bukan makna. Sebelum memindah apa pun, penyebut tunggal wajib
   dilihat manusia.
2. **Vonis "dipakai" lewat pola bukan jaminan berkasnya benar-benar dimuat**, cuma
   jaminan **ada jalur yang bisa** memuatnya. Kebalikannya yang penting: vonis
   **"yatim"** kini bisa dipercaya, dan itu yang dibutuhkan untuk memindah dengan aman.

---

## Usul urutan TAHAP B (menunggu persetujuan Direktur)

| # | kerja | risiko | uji |
|---|---|---|---|
| 1 | 22 yatim → `game/assets/_yatim/` **+ arahkan 9 generatornya** | rendah | suite + Ashbrook siang |
| 2 | `t64` (6 berkas) ikut ke `_yatim/t64/` | rendah | idem |
| 3 | `lpc32/` → `fasad/` + `potongan/`, pecah `P_S` jadi dua konstanta | rendah-sedang | **uji mata Ashbrook wajib** |
| 4 | `props/` & `tiles/` akar | **tinggi** | butuh manifes (jalan C) — **jangan disentuh sesi ini** |

**Nomor 1–3 bisa dikerjakan aman. Nomor 4 jangan, sampai Direktur memilih jalan A/B/C.**
