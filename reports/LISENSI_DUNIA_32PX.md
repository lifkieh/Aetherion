# Dunia 32px untuk karakter LPC 64px — peta pilihan lisensi

**Sifat:** PETA PILIHAN, bukan rekomendasi. Direktur meminta pilihannya disajikan, bukan dipilih.
**Pemicu:** #250 (LPC 64px = sumber karakter tunggal). Karakter LPC butuh dunia yang skalanya cocok.

---

## Duduk perkaranya, dalam angka

| | |
|---|---|
| Aset dunia yang terikat skala | **113** — 36 ubin · 67 prop · 10 bangunan (di luar 25 monster, 4 pemain, 5 dungeon/hewan) |
| Skala LPC | ubin **32 px**, FRAME karakter **64 px** (badan tampak 34×47) |
| Skala sekarang | ubin **16 px**, badan `_charsys` tampak **12×27** |
| Ubin 32px CC0 yang sudah kita punya | **NOL** |

Angka terakhir itu diverifikasi, bukan dikira-kira. Seluruh gudang 5,6 GB disurvei:
Ninja Adventure **16px** · Pixel Crawler **16px** · superpowers **16px** ·
Overland Tiles 16px (**lisensi tak terverifikasi — DITAHAN**) ·
craftpix 32px (**bukan CC0/CC-BY**) · `aetherion_original_assets_v1` punya 28 berkas 32×32
tapi semuanya **ikon elemen & VFX, bukan ubin** · `assets_aetherion` didominasi 48×48 (UI) dan 16×16.

**Tidak ada satu pun ubin dunia 32px berlisensi bersih, di mana pun.**

---

## (a) Cabut #232 — terima seluruh tileset jadi SA

**Yang didapat:** akses langsung ke seni dunia LPC — ubin 32px yang memang dirancang menyatu
dengan karakter LPC. Nol ongkos gambar. Ini satu-satunya pilihan yang bisa jalan minggu ini.

**Konsekuensinya:**

1. **Seni dunia jadi CC-BY-SA — dan itu menular ke setiap turunannya.** Tileset, scene yang
   memanggangnya, dan materi promosi yang menampilkannya wajib ditawarkan di bawah CC-BY-SA.
2. **Komersial tetap BOLEH.** CC-BY-SA bukan NC. Aetherion tetap boleh dijual.
3. **Tapi siapa pun boleh mengambil ulang seni dunia itu** — secara sah, termasuk pesaing,
   termasuk untuk produk berbayar. Yang dilepas bukan hak menjual, melainkan **eksklusivitas visual.**
4. **Kode TIDAK tertular.** CC-BY-SA melekat pada karya seni, bukan pada GDScript di sebelahnya.
5. **⚠ Yang paling jarang disadari:** #233 mencatat lapisan ULPC berlisensi campur —
   **CC-BY-SA 3.0/4.0 + GPL + OGA-BY**. Ubin ber-GPL bukan sekadar "SA": GPL menuntut
   **penyediaan bentuk sumber**. Kalau jalur ini diambil, per-berkas wajib disaring —
   **SA saja boleh, GPL harus dipisahkan atau dihindari.**
6. Ini mencabut hukum pembatas yang Direktur tetapkan **secara sadar** di #232. Yang dicabut
   bukan detail teknis; itu keputusan yang isinya "kemenulaan SA berhenti di karakter".

**Yang perlu diputuskan kalau (a) dipilih:** apakah eksklusivitas visual Aetherion memang
sesuatu yang boleh dilepas — dan siapa yang menyaring per-berkas untuk menyingkirkan GPL.

---

## (b) Bangun / cari ubin 32px CC0 dari nol

**Berapa banyak:** 113 karya (36 ubin · 67 prop · 10 bangunan). Titik awal: **nol**.

**Dari mana:**
- **Kenney** (CC0, terbukti, sudah kita pakai untuk UI) — kuat di UI/prompt, **tipis di
  top-down fantasi 32px**. Tidak menutupi 113 itu.
- **OpenGameArt CC0 32px** — ada, tapi berserak, gaya tak konsisten antar-submission, dan
  tunduk aturan lisensi kita sendiri (`ASSET_LOG` §3/§4): **cek PER-BERKAS, nama folder bukan
  lisensi, "free to use" = TIDAK DIKETAHUI = TOLAK.** Pelajaran 80-CC0-RPG-SFX berlaku penuh.
- **Gambar sendiri** — paling terkendali, dan satu-satunya yang menjamin gaya konsisten.
  Dari 113, hanya **7** yang punya generator hari ini (papan Otha 3, lentera 2, bangku 2).
  Sisanya ±106 = kerja tangan.

**Konsekuensinya:** eksklusivitas visual utuh, nol risiko lisensi, dan **program seni besar yang
seluruhnya mendahului manfaat scene mana pun.** Itu persis bentuk yang #244 peringatkan
("art tanpa konsumen"), hanya dalam skala 113 berkas — kecuali dibangun per-adegan, sesuai kebutuhan.

---

## (c) Karakter 64px SEKARANG di dunia 16px, dunia menyusul

**Bisa secara teknis? Ya. Terbaca? Tidak.** Ini bisa dihitung, bukan diperdebatkan:

| | lebar × tinggi badan | dalam satuan ubin 16px |
|---|---|---|
| `_charsys` sekarang | 12 × 27 | 0,8 × 1,7 ubin |
| LPC 64px apa adanya | 34 × 47 | **2,1 × 2,9 ubin** |

Bangunan kita setinggi 58–106 px. Karakter 47 px berdiri di samping rumah 62 px =
**karakter setinggi rumahnya sendiri.** Itu tidak terbaca sebagai "sementara"; itu terbaca
sebagai rusak. Dan sekali pemain melihatnya, "sementara" jadi mahal untuk dibatalkan.

### (c2) — varian yang tidak ada di daftar, dan mungkin layak dipertimbangkan

**Pakai LPC sebagai SUMBER TUNGGAL, tapi render turun 50% (frame 64 → 32).**
Ini persis **mode kompresi yang Direktur tunda** — hanya dipakai sekarang untuk mencocokkan dunia,
bukan nanti untuk perangkat low-end.

| | badan | dalam ubin 16px |
|---|---|---|
| `_charsys` sekarang | 12 × 27 | 0,8 × 1,7 |
| **LPC diturunkan 50%** | **17 × 24** | **1,1 × 1,5** |

Jejaknya **hampir identik dengan yang ada sekarang.** Artinya: sumber karakter bisa berpindah ke
LPC **minggu ini**, di dunia 16px yang sudah jalan, **tanpa satu pun dari 113 aset dunia disentuh** —
dan keputusan lisensi (a)/(b) bisa ditunda sampai benar-benar matang, bukan diburu.

**Ongkosnya jujur:** menurunkan piksel-art 50% mengaburkan garis 1-px; sebagian keunggulan detail
LPC hilang justru di jalan. Apakah LPC-turun-50% masih **terlihat lebih baik** dari `_charsys`
12×27 adalah pertanyaan yang **hanya bisa dijawab dengan melihat**, bukan dengan menghitung —
dan itu satu render pembanding, bukan sebuah program.

---

## Ringkasan untuk keputusan

| | ongkos seni | risiko lisensi | bisa jalan kapan | eksklusivitas visual |
|---|---|---|---|---|
| **(a)** cabut #232 | ~nol | **tinggi** — SA menular; ULPC campur GPL wajib disaring | minggu ini | **dilepas** |
| **(b)** 32px CC0 dari nol | **113 karya**, titik awal nol | nol | bulan, bukan minggu | utuh |
| **(c)** 64px di dunia 16px | nol | nol | segera — tapi terbaca rusak (2,1 × 2,9 ubin) | utuh |
| **(c2)** LPC turun 50% | nol | nol | minggu ini | utuh |

**Belum diputuskan. Menunggu Direktur.**
Satu-satunya hal yang saya sarankan untuk didahulukan bukan pilihan itu sendiri, melainkan
**satu render pembanding untuk (c2)** — karena kalau LPC-turun-50% ternyata sudah mengalahkan
`_charsys`, keputusan lisensi (a)/(b) berhenti jadi penghalang dan berubah jadi pekerjaan
yang bisa diambil kapan saja.
