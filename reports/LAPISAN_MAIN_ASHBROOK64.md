# LAPISAN MAIN ASHBROOK64 — laporan empat bagian

**2026-07-20** · Empat commit: `7cc9a5c` · `1e9c870` · `22bc8ed` (+ perbaikan test).
**Gerbang #273: exit 0 — 1096 lulus, 0 gagal.** PlayLoop64 jalur self: **rantai UTUH.**

**Nol penilaian "rasa" di berkas ini.** Itu Direktur, saat playtest.

---

# BAGIAN 1 — batas tanah + tabrakan ✅

**Urutan dijalankan sesuai perintah, dan itu bukan formalitas.**
`ev_ashbrook_fondasi_rumput` ada di **y=1152 — di luar tanah 34 petak (1088 px)**.
Memasang batas lebih dulu akan **memutus jalur bukti**: titik itu jadi mustahil
dijangkau, dan halaman Ashbrook tak bisa lagi ditulis ulang lewat jalur SENDIRI.

Titik dipindah ke **(1504, 1056)**, reruntuhannya ikut naik ke (1504, 1024) supaya
keduanya tetap sepasang. **Baru** batas dipasang.
Diverifikasi: lima titik Ashbrook tercatat, tiga jenis terkumpul, rantai utuh.

| | Isi |
|---|---|
| **Batas** | empat dinding 16 px mengelilingi 1920×1088, **di luar** tepi supaya tak memakan ruang main (preseden `Ashbrook.gd:140-153`) |
| **Bangunan** | padat **hanya di kaki** (40 px) — fasad 7 petak yang padat penuh akan menghalangi pemain jauh sebelum ia menyentuh bangunannya, dan merusak y-sort yang justru membuat orang bisa berdiri di depan rumah |
| **Air mancur** | cekungannya (52×34), bukan seluruh sprite 64×64 |
| **Bangku · pohon** | dudukan (28×16) · batang (20×14), bukan tajuk |

Semua di **lapis 4** — sama dengan `Ashbrook.gd`, dan `Player.tscn` menyaring tepat
lapis itu. Salah lapis = pemain menembus tembok **tanpa satu pun galat muncul**.

**Bukti:** `reports/preview/9_batas_tepi.png` — pemain di tepi timur, dunia berhenti.

---

# BAGIAN 2 — satu interior bermakna, sisanya pintu jujur ✅

**Merrit dapat ruangan sungguhan** karena payoff menuntutnya: ia yang menulis
halaman Ashbrook (#261) dan menyalakan lentera itu. Kalau rumahnya tak bisa dimasuki,
satu-satunya alasan pemain percaya ia "repot" adalah karena **kita mengatakannya** —
bukan karena ia melihatnya.

Isinya menjawab satu pertanyaan: *kenapa orang ini repot mengingat kota yang sudah selesai.*

- **Surat di meja** — dibuka dan dilipat kembali sampai lipatannya menipis. Tanggalnya
  empat puluh tahun lalu, isinya satu kalimat: *"Tunggu aku, jangan pindah."*
  **Tanpa nama pengirim.**
- **Botol minyak lampu**, kosong semua, berjajar menurut tahun.
  *"Ada lebih banyak botol di sini daripada orang di Ashbrook."*

**Sisanya pintu tertutup yang bercerita — nol interior kosong.** Lima pintu yang
membuka ke lima ruangan kosong mengajari pemain bahwa **pintu tak berarti apa-apa**.

Teksnya menghormati **#269**:

| Pintu | Kematian | Teksnya |
|---|---|---|
| Toko Otha | **D3** | tak menyebut namanya — *"persegi yang catnya lebih gelap, tempat sesuatu dulu tergantung"* |
| Rumah kosong | **D2** | *"ditinggalkan"* — engsel masih diminyaki, perabot menunggu orang yang tak pulang. **Bukan "belum jadi"**; itu kematian yang berbeda |
| Gudang · rumah Lyra | — | empat ayam di ruang untuk empat ratus karung · seseorang memasak di dalam |

`Ashbrook64Prop.gd` **baru**: prop bisa-ditekan-E untuk hal yang **bukan bukti**.
`Interactable` mengikat teksnya ke `evidence_id`; tanpa bukti ia diam. Dan pintu tak
boleh jadi bukti — memasukkannya ke `Evidence` menambah jumlah **jenis** yang pemain
bawa, dan itu **langsung mengubah baris `loss` halaman** (#226 #3).

**Bukti:** `9_interior.png` · `9_pintu_otha.png`

---

# BAGIAN 3 — jalan keluar ✅

Di ujung **barat jalan dagang lama** — jalan yang sudah digambar `_ground()`
membentang barat→timur. Keluar lewat jalan yang memang menuju ke luar, bukan lewat
pintu ajaib di tengah rumput. Penanda: batu penjuru aus, bukan portal berkilau (D-3).

⚠ **Sementara ia kembali ke MENU, bukan Greenvale.** `TravelUI` + `regions.json`
adalah alur dunia **permanen**, dan putusan *"ganti vs dampingi 16px"* menunggu
playtest. Menyambungkannya sekarang **menjawab pertanyaan yang belum ditanyakan.**

**Bukti:** `9_gerbang.png`

---

# BAGIAN 4 — pacing: ANGKA, nol penilaian ✅

`_tools/gen_pacing_ashbrook64.py` menurunkan semuanya dari sumber — koordinat
di-parse dari `Ashbrook64.gd`, `BASE_SPEED` dari `Player.gd`, jenis dari
`evidence.json`. Geser tata letak, jalankan ulang, angkanya ikut.

| Ukuran | Hasil |
|---|---|
| **Jalur minimum SENDIRI** (3 jenis) | **1394 px = 15,2 detik** |
| Keenam titik berurutan | 3454 px = 37,5 detik |
| Titik terjauh dari mulai | 14,1 detik (jembatan) |
| Titik terdekat | 2,6 detik (batu fondasi) |
| Menyeberangi peta mendatar · tegak | 20,9 s · 11,8 s |

⚠ Jarak **garis lurus** = **batas bawah**. Dengan tabrakan yang kini terpasang, jalan
sungguhan bisa lebih panjang.

Rincian per titik: `reports/PACING_ASHBROOK64.md`.

---

# TIGA JEBAKAN Z-ORDER — semuanya diam, nol galat

Ketiganya ditemukan dengan **melihat layar**, bukan dari pesan kesalahan. Tak satu
pun akan tertangkap test.

1. **`_put(path, pos, z)` memakai z NEGATIF sebagai sentinel "hitung dari `pos.y`".**
   Meneruskan `-12` tidak memberi z −12 — ia **memicu mode-otomatis**. Perabot mendarat
   di z ≈ −300 dan tenggelam di bawah lantainya sendiri; kamar tampak **kosong**.
2. **`Player.gd:54` melakukan `z_index = int(global_position.y)`.** Kamar mula-mula
   diletakkan di koordinat **negatif** (preseden `Ashbrook.gd:20` memakai `(-360,-260)`),
   jadi z **pemain** ikut negatif dan ia tergambar **di bawah lantai**: ruangan lengkap,
   pemainnya hilang. Kamar dipindah ke ruang **positif (2100,160)**.
3. **`_kotak()` punya sentinel negatif yang sama.** Kini z **selalu eksplisit**.

> ⚠ **Nomor 2 kemungkinan cacat laten yang sama di `Ashbrook.gd` 16px** — `INTERIOR`
> di sana juga negatif. **Tidak disentuh**: di luar lingkup, dan menyentuh scene yang
> dimainkan tanpa diminta bukan keputusan saya.

---

# KESIAPAN — apa yang sudah, apa yang belum. **Bukan putusan.**

**Apakah Ashbrook64 kini "tempat"?** Tiga syarat yang Direktur sebut sudah terpasang:
tabrakan ✅ · interior ✅ · gerbang ✅.

## Yang membuatnya SIAP dinilai

| | |
|---|---|
| Loop payoff | ketiga jalur UTUH (self · elyn · ruang-penuh) |
| Dunia | punya tepi, benda padat, jalan keluar |
| Alasan tokohnya | terlihat, bukan dikatakan — surat & botol Merrit |
| Pintu | bercerita, dan konsisten dengan D2/D3 (#269) |
| Save | mendarat kembali di Ashbrook64 (#274) |
| Pacing | terukur, tercatat, bisa dijalankan ulang |

## Yang BELUM, dan relevan untuk pertanyaan "ganti vs dampingi"

1. **Ashbrook 16px punya isi yang Ashbrook64 belum punya**: `_spawn_life()` (ayam,
   anak berlari), `_spawn_paired_life()` (kambing, sepeda), `_build_windows()`
   (jendela padam satu per satu jam 19·20·21), `_build_vantage()` (titik-pandang
   #218), `_spawn_wolf_pup()` (monster pertama #118), `TownFolk.place()` (5 NPC
   berjadwal #97), White Stag (#D-ASH-4). **Ashbrook64 punya 6 NPC diam.**
2. **Gerbang masih sementara** — kembali ke menu, bukan ke dunia.
3. **Opening kanon belum ada** di Ashbrook64 — `_maybe_opening()` / Pegasus (#118)
   hanya ada di 16px.
4. **Satu interior**, bukan lima. Itu keputusan sadar, bukan kekurangan — tapi
   16px punya `_build_interior()` untuk momen bangun.
5. **`regions.json` belum menyebut Ashbrook64.** Ia dijangkau lewat `Intro.gd`
   sementara.

▸ Ringkasnya: **Ashbrook64 kini tempat yang bisa dimainkan dan menyelesaikan payoff.
Ashbrook 16px masih kota yang lebih hidup.** Mana yang lebih penting — dan apakah
jawabannya "ganti" atau "dampingi" — adalah putusan Direktur setelah playtest.
**Tidak diputuskan di sini. `regions.json` tidak disentuh.**
