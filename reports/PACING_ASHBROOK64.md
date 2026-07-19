# PACING ASHBROOK64 — UKURAN, BUKAN PENILAIAN

**Dihasilkan `_tools/gen_pacing_ashbrook64.py`.** Jalankan ulang setelah tata letak digeser — jangan sunting berkas ini.

Kecepatan jalan **92 px/detik** (`Player.gd` `BASE_SPEED`). Titik mulai **(560, 816)** — depan pintu Merrit.

> ⚠ Jarak **garis lurus**. Dengan tabrakan bangunan yang kini terpasang, jalan sungguhan **bisa lebih panjang** — angka di bawah adalah **batas bawah**.


## Dari titik mulai ke tiap titik

| titik | jenis | koordinat | jarak (px) | jalan (detik) |
|---|---|---|---|---|
| 1. `ev_otha_papan_bekas_cat` | akibat | (1216, 664) | 673 | **7.3 s** |
| 2. `ev_ashbrook_fondasi_rumput` | akibat | (1504, 1056) | 974 | **10.6 s** |
| 3. `ev_ashbrook_batu_fondasi` | benda | (800, 856) | 243 | **2.6 s** |
| 4. `ev_ashbrook_gudang_gandum` | akibat | (704, 480) | 366 | **4.0 s** |
| 5. `ev_ashbrook_halloran_200_roti` | kebiasaan | (1216, 560) | 704 | **7.7 s** |
| 6. `ev_ashbrook_jembatan_terlalu_lebar` | akibat | (1856, 704) | 1301 | **14.1 s** |

## Jalur minimum SENDIRI — tiga JENIS berbeda

`akibat` + `kebiasaan` + `benda`. Ini rute terpendek yang membuka penulisan-ulang tanpa Elyn (#228).

| kaki | dari → ke | jarak (px) | jalan (detik) |
|---|---|---|---|
| MULAI → gudang_gandum |  | 366 | 4.0 s |
| gudang_gandum → halloran_200_roti |  | 518 | 5.6 s |
| halloran_200_roti → batu_fondasi |  | 511 | 5.5 s |
| **TOTAL** | | **1394** | **15.2 detik** |

## Enam titik berurutan (pengumpul menyeluruh)

Berjalan dari titik mulai melewati keenam titik menurut urutan deklarasinya: **3454 px = 37.5 detik** berjalan terus-menerus.


## Rentang peta, untuk perbandingan

- Peta **60×34 petak** = **1920×1088 px**.
- Menyeberangi peta secara mendatar: **20.9 detik**.
- Menyeberangi peta secara tegak: **11.8 detik**.
- Titik terjauh dari mulai: **14.1 detik**.

---

**Nol penilaian di berkas ini.** Apakah angka-angka ini terasa jauh, tepat, atau kosong — itu putusan Direktur saat playtest.
