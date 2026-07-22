# CEK SINKRON — apa yang belum menyusul perombakan Ashbrook

**2026-07-22 · Nol perubahan dilakukan. Temuan + bukti + rekomendasi.**

Perombakan yang sudah dijalankan: tata letak B′, 120 warga baru (`warga_%03d`),
babi menggantikan domba, rusa & serigala berganti sumber, dua bukti kamar Merrit,
wajah asli Merrit.

Yang diperiksa di sini: **apa yang masih memakai keadaan lama.**

---

## 🔴 1 — JADWAL NPC TAK PERNAH DIHITUNG ULANG UNTUK B′

**Ini temuan terpenting, dan ia tak terlihat oleh satu pun dari 1.122 uji hijau.**

`NpcSchedule.post_for()` menghitung posisi sebagai `home + offset`, dan `home` untuk
warga tanpa `anchor` adalah **titik di cincin radius 120 px** mengelilingi
`VC + (60,120)` (`TownFolk.gd:44`). Offset di `town_npcs.json` ditulis untuk tata
letak LAMA.

Akibatnya **lima belas pos jadwal semuanya mendarat di alun-alun**, apa pun bunyi
teksnya:

| tokoh | slot | posisi hasil | terdekat | teks kegiatan |
|---|---|---|---|---|
| **Merrit** | pagi | (908, 848) | alun-alun 153px | *"membuka rumah singgah, menyortir surat"* |
| **Merrit** | sore | (960, 864) | alun-alun 160px | *"menyapu kamar yang tak ditiduri siapa pun"* |
| **Merrit** | malam | (904, 834) | alun-alun 142px | *"menyalakan lampu, lalu duduk"* |
| Halloran | pagi | (1017, 620) | alun-alun 102px | *"memanggang dua ratus roti"* |
| Lyra | malam | (823, 965) | alun-alun 294px | *"pulang; jendelanya padam"* |
| Spoon Man | malam | (1073, 793) | alun-alun 144px | *"berdiri diam menghadap rumah yang lama gelap"* |

### Angka yang paling telak

```
rumah singgah Merrit   (790, 440)
lampu Merrit           (862, 384)
Merrit pos MALAM       (904, 834)

jarak ke rumahnya      410 px
jarak ke LAMPUNYA      452 px
```

**Jadwalnya berbunyi "menyalakan lampu, lalu duduk" — dan ia berdiri 452 px dari
lampu itu.** Rumah singgah yang katanya ia buka tiap pagi ada 410 px di utara.
Halloran "memanggang dua ratus roti" 278 px dari toko rotinya sendiri.

**Old Bram adalah satu-satunya yang benar** — ia punya `anchor: [736,800]` yang
dipasang sengaja waktu Jalur A, dan itu tepat **16 px dari bangku alun-alun**
(`Ashbrook64.gd:1202`), 174 px dari air mancur yang ia pandangi. Kalimatnya cocok
dengan tempatnya.

> Empat tokoh lain tak punya `anchor`. Mereka berdiri di tempat yang ditentukan
> **sudut lingkaran**, bukan oleh ceritanya.

**Kenapa nol uji melihatnya:** tak ada invarian yang membandingkan *teks kegiatan*
dengan *jarak ke tempat yang disebut teks itu*. Uji yang ada memeriksa warga hidup,
bergerak, dan bisa diajak bicara — ketiganya benar.

**Rekomendasi:** beri `anchor` eksplisit ke Merrit, Halloran, Lyra, Spoon Man —
pola yang sudah terbukti pada Bram. Lalu tambahkan invarian: *tiap slot jadwal
yang menyebut bangunan bernama harus berada dalam radius X dari bangunan itu.*

---

## 🔴 2 — ADEGAN LAMPU MERRIT HILANG SAAT PINDAH KE 64px

`Ashbrook.gd:414-431` (peta 16px) memuat `_build_lamp_seat()`:

> *"Merrit DUDUK MEMBACA SURAT di bawah lampunya — malam hari, tanpa dialog, tanpa
> cutscene, tanpa prompt. Pemain boleh menonton atau pergi. **Isinya TIDAK
> dijelaskan** (benih, bukan payoff — #216; kekuatannya ada pada penundaan)."*

Isinya: bangku 12×8 di `MERRIT_HOUSE + (6,4)`, dan surat 7×5 warna kertas pucat di
`MERRIT_HOUSE + (14,0)`, dikomentari *"surat tua — kertas pucat, tak pernah dibuka
pemain"*.

**`Ashbrook64.gd` tidak punya fungsi ini.** Nol rujukan `lamp_seat` / `_seat`.

Yang tersisa di peta hidup: surat sebagai **benda periksa di dalam kamar**
(`"Surat di meja [E]"`). Itu benda; yang hilang adalah **gambarnya** — orang tua yang
duduk di bawah lampu membaca surat berumur empat puluh tahun, tanpa satu kata pun.

Digabung dengan temuan #1, kehilangannya berlipat: bukan cuma bangkunya yang tak
dipindah — Merrit sendiri pun tak berdiri di sana malam hari.

> **#218 (payoff lentera) masih berdiri; sosok manusianya yang hilang.** Titik pandang,
> jendela yang padam satu per satu, dan lampu yang menolak ikut tidur semuanya ada di
> peta 64. Yang tak ada: siapa yang menyalakannya.

**Dua fitur lain yang saya curigai hilang ternyata AMAN** — diperiksa, bukan
diasumsikan:
- jendela padam bertahap → **ada**, namanya `_jendela()` (`Ashbrook64.gd:1620`)
- anak serigala terluka #118 → **ada** (`Ashbrook64.gd:1715`)

---

## 🟠 3 — TUJUH PEMANGGILAN UJI MASIH MEMAKAI PETA WARISAN

`game/data/regions.json:8` menetapkan scene Ashbrook = **`Ashbrook64.tscn`**.
Pemain tak pernah masuk `Ashbrook.tscn`.

Tapi `TestRunner.gd` memuat `Ashbrook.tscn` di **tujuh tempat** — baris 3838, 3931,
4586, 5114, 5154, 5192, 5224. Empat di antaranya uji bermakna:

| uji | apa yang diperiksa |
|---|---|
| `_test_ashbrook_alive` | desa hidup |
| `_test_kamar_tak_menelan_pemain` | interior tak menelan pemain |
| `_test_examine_door_gudang` | pintu gudang bisa diperiksa |
| **`_test_solo_loop_ashbrook_besar`** | **lingkar Chronicle jalur SENDIRI** |

Yang terakhir menyisir `get_nodes_in_group("interactable")` **di scene yang dimuat**,
lalu memeriksa tiap bukti berhalaman `place_ashbrook_besar`. Artinya ia menguji
**penempatan bukti di peta yang tak dimainkan siapa pun.**

Bukan bencana — `PlayLoop64` sudah membuktikan rantai utuh di peta 64 pada ketiga
jalur. Tapi ini permukaan **hijau-tapi-tak-berarti**: kalau suatu hari peta 64 rusak
sementara peta 16 utuh, empat uji ini tetap hijau.

**Rekomendasi:** pindahkan keempatnya ke `Ashbrook64.tscn`, atau tandai eksplisit
bahwa `Ashbrook.tscn` adalah fixture uji, bukan peta.

---

## 🟠 4 — HALAMAN `person_merrit_fane` TAK PERNAH LAHIR

`chronicle_losses.json:38` memuat teks kerugian **lengkap** untuk halaman ini —
keempat jenis bukti, `loss_self`, `default`, dan `_scene`.

Tapi di seluruh kode hanya **satu** halaman yang pernah dibuat:
`WorldState.gd:261` → `place_ashbrook_besar`.

Akibat: dua bukti kamar Merrit yang baru dipasang **bisa ditemukan**, tapi halaman
yang mereka pulihkan **belum ada**. Bukti tanpa halaman = bukti yang tak bisa
dipakai untuk apa pun.

**Rekomendasi:** halaman ini lahir bersama adegan A2, bukan lebih awal — mencoretnya
sebelum pemain mengenal Merrit akan membalik urutan emosinya. Tahan sampai A2 dibangun.

---

## 🟡 5 — MEKANISME `observe` MASIH TAK ADA

`ev_merrit_cangkir_kedua` (`found_by: observe`, `schedule: pagi`) dan
`ev_otha_nyai_tuminah_kamis` sama-sama menunggu mekanisme yang **nol rujukan** di
`scenes/` maupun `autoload/`.

Membangunnya membayar **dua halaman** sekaligus. Dan ia bergantung pada temuan #1:
mengamati kebiasaan pagi Merrit cuma bermakna kalau Merrit **ada di rumah
singgahnya** pagi hari.

---

## 🟡 6 — TEKS EKOLOGI MASIH MENYEBUT DOMBA

`game/data/monsters.json:971`:
> `"peran_ekologi": "predator menengah — pengendali kelinci & domba"`

Domba sudah tak ada di dunia; `katalog_hewan.json` kini berisi
`babi · ayam · rusa · serigala · kucing ×2 · anjing ×2 · gagak ×2 · merpati ×2`.
Kelinci pun tak ada di katalog mana pun.

Komentar di `Hewan.gd:43-44` juga masih memakai domba sebagai contoh — tak salah
sebagai catatan sejarah, tapi menyesatkan pembaca baru.

---

## 🟡 7 — LAPORAN LAMA MENGUTIP ANGKA YANG SUDAH BERUBAH

| berkas | klaim lama | keadaan sekarang |
|---|---|---|
| `RAPIKAN_ASET.md:31` | `"warga_%02d" % n` | **`warga_%03d`** |
| `RAPIKAN_ASET.md:41` | `sprites/characters` = **100** berkas | **400** |
| `POTRET_ASHBROOK.md:29` | *"Ya, 20 warga"* | **120** |

Laporan bertanggal boleh usang — tapi `RAPIKAN_ASET.md` dikutip `.gitignore` sebagai
alasan `peta_aset.py` wajib ter-versi, jadi angkanya masih dibaca orang.

---

## RINGKAS — urutan yang saya sarankan

| # | temuan | dampak | ongkos |
|---|---|---|---|
| 1 | jadwal NPC tak sinkron B′ | 🔴 tiap tokoh berdiri di tempat yang membantah kalimatnya | kecil — 4 `anchor` |
| 2 | adegan lampu Merrit hilang | 🔴 #218 kehilangan sosok manusianya | kecil — port 1 fungsi |
| 3 | 7 uji di peta warisan | 🟠 hijau-tapi-tak-berarti | sedang |
| 4 | halaman Merrit belum lahir | 🟠 bukti tanpa halaman | tahan sampai A2 |
| 5 | `observe` tak ada | 🟡 2 bukti mati | sedang — sistem baru |
| 6 | teks domba | 🟡 kosmetik | menit |
| 7 | angka laporan usang | 🟡 kosmetik | menit |

**#1 dan #2 saling menguatkan dan sebaiknya dikerjakan bersama:** beri Merrit
`anchor` di rumah singgahnya, lalu kembalikan bangku-dan-surat di bawah lampunya.
Sesudah itu kalimat *"menyalakan lampu, lalu duduk"* akhirnya menjadi benar secara
harfiah — dan #218 mendapat kembali orang yang membuatnya berarti.
