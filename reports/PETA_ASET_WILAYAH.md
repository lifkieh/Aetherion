# PETA ASET — apa yang khas Ashbrook, apa yang dipakai bersama

**2026-07-22 · TAHAP A: memetakan. NOL berkas dipindah.**

## Ringkas

Permintaan Direktur ada dua, dan yang pertama **sudah berlaku**:

| permintaan | keadaan |
|---|---|
| pisahkan aset yang dipakai dari yang mentah | **sudah** — `game/assets/` dipakai, `assets_raw/` mentah |
| kelompokkan aset Ashbrook ke `assets/ashbrook/` | **sebagian besar tak bisa** — lihat di bawah |

## Kenapa "semua aset Ashbrook" hampir tak ada

Repo ini punya **17 scene wilayah**, bukan satu. Aset yang tampak "milik Ashbrook"
sebenarnya dipakai bersama:

| aset | pemiliknya | wilayah pemakai |
|---|---|---|
| `sprites/characters/` (400) | `CharGen.gd` (autoload) · `Villager.gd` | pembuatan karakter PEMAIN + tiap kota |
| `sprites/props/` · `buildings/` | `Town.gd` · `WildDresser.gd` | Candyveil · Desert · Frostpeak · StormIsland |
| `sprites/monsters/` (25) | `Monster.gd` · `Pet.gd` | seluruh pertarungan |
| `sprites/animals/` | `Critter.gd` · `Hewan.gd` | Ashbrook + `monsters.json` |
| `tiles/` | sudah per-wilayah | `candyveil/` `desert/` `dungeon/` |

Disisir per-berkas — tiap nama sprite dicari di seluruh `.gd`/`.tscn`/`.json`, lalu
dipisah antara "cuma disebut berkas ber-nama Ashbrook" dan "disebut yang lain":

```
KHAS ASHBROOK        33
dipakai bersama     ~180
tak dirujuk NAMA    ~400   <- 120 warga, dimuat dinamis `warga_%03d`
```

**390 dari 400 lembar karakter tak pernah disebut namanya di kode.** Ia dimuat lewat
`Villager.gd` yang melayani tiap kota di enam wilayah. Memindahkannya ke `ashbrook/`
akan menamai berkas menurut tempat ia kebetulan pertama dipakai, bukan menurut siapa
yang memakainya.

### 33 yang benar-benar khas

```
lpc32/     17   fasad_* (rumah·gudang·inn·shop·balai·lapuk·adobe_pudar·…)
props/      9   otha_sign_* · ruins · lantern · nisan_*
animals/    4   rusa_putih_kiri · kucing_menunggu · kucing_meringkuk · anjing_menunggu
characters/ 3   anak_pim · anak_toka · anak_wen
```

## Kenapa saya berhenti dan tidak memindah

Memindahkan `game/assets/game/sprites/` ke `game/assets/ashbrook/` akan:

* memindahkan **33 berkas dengan benar**, dan **~577 dengan salah**;
* memutus Candyveil, Desert, Frostpeak, StormIsland — empat wilayah yang memakai
  `Town.gd`/`WildDresser.gd`;
* memindahkan aset pembuatan karakter PEMAIN ke folder sebuah desa.

> Struktur folder itu pernyataan tentang KEPEMILIKAN. Menaruh aset bersama di bawah
> nama satu wilayah bukan merapikan — ia menuliskan klaim yang salah, dan klaim itu
> baru terbantah waktu wilayah lain rusak.

## Dua jalan yang benar

### A — kelompokkan yang KHAS saja (kecil, aman)

```
game/assets/game/sprites/
  ashbrook/      33 berkas khas (fasad, otha_sign, ruins, anak_*, rusa_putih…)
  characters/    tetap — bersama
  props/         tetap — bersama
  ...
```

Sentuh ±33 berkas + rujukannya. Ashbrook jadi punya rumahnya sendiri tanpa
mengarang kepemilikan atas barang bersama.

### B — pisah BERSAMA vs WILAYAH (besar, lebih jujur)

```
game/assets/game/
  bersama/   characters · monsters · player · props bersama · tiles dasar
  wilayah/
    ashbrook/   33
    candyveil/  (tiles sudah di sini)
    desert/     dungeon/ …
```

Lebih benar jangka panjang, tapi menyentuh **17 scene** dan tiap konstanta path.
Menuntut playtest #151b penuh sesudahnya.

## Rekomendasi

**A sekarang, B kalau wilayah kedua benar-benar digarap.** Ashbrook satu-satunya
wilayah yang isinya padat hari ini; memecah `bersama/` sebelum ada wilayah kedua yang
sama padatnya berarti membayar ongkos struktur untuk masalah yang belum ada.
