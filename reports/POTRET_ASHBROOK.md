# POTRET ASHBROOK — kota apa adanya

**Dibuat:** 2026-07-21 · **Sifat:** potret jujur. **Nol perubahan `game/`.**
**Metode:** 10 tangkapan layar pada zoom main (1.0; dua peta-lebar 0.5), lalu **dilihat satu per satu**.
Kolom "TERBACA" diisi dari **gambarnya**, bukan dari nama node.

> **Catatan batas:** berkas `ASHBROOK_MAP_SPEC.md` **tidak ada di disk** (sudah dicari di
> `docs/` dan `reports/`). Kolom SPEC di bawah diambil dari **kontrak yang tertulis di
> `Ashbrook64.gd` sendiri** — komentar C1–C4, aturan anti-kosong, gradien #218. Kalau
> Direktur punya spec 4-cincin di tempat lain, kolom itu perlu dibaca ulang terhadapnya.

**Tangkapan:** `reports/preview/potret/`
`01_peta_siang` · `02_peta_malam` · `03_spawn_gerbang` · `04a/04b/04c_jalur` ·
`05a_inti` · `05b_c2_otha` · `05c_c3_barat` · `05d_pemakaman`

---

## 1 — INVENTARIS PER-CINCIN: SPEC vs ADA vs TERBACA

### C1 — inti (alun-alun)

| SPEC (kontrak di kode) | ADA di layar | TERBACA sebagai |
|---|---|---|
| Alun-alun batu 17×11, pusat sejati peta | Ya — pelataran cobble + cakram batu besar | **Ya.** Bentuk bundar di dalam persegi terbaca "tempat", bukan "lewat saja" |
| Air mancur kering di pusat | Sprite `fountain.png` ADA | **Setengah.** Ia **cekungan batu kecil bertiang**, tinggi ±3 petak, dan di kamera main ia **tertutup badan warga** — di `05a` sosoknya hilang sama sekali di balik 5 orang. Terbaca "batu kecil", bukan "air mancur (yang kering)" |
| Balai desa — bangunan TERBESAR, gema 500 orang | `_building(fasad_inn.png, 960,464)` | **Tidak.** Ia **sprite yang sama persis** dengan rumah singgah Merrit. Dua bangunan kembar identik di satu peta; yang utara terbaca "penginapan kedua", bukan balai |
| 8 bangku (sengaja terlalu banyak) | Ya, terlihat di `04b`/`05a` | **Ya** — bangku kosong berjajar terbaca sepi |
| 4 tong penjuru sebagai bingkai | Ya | **Ya**, bingkainya bekerja |
| Kerumunan: 4 di alun-alun, sisanya menyebar | Ya, 20 warga | **Ya untuk sebaran**, **tidak untuk hidup** — lihat 🔴-1 |

### C2 — cincin rumah + jalan dagang

| SPEC | ADA | TERBACA |
|---|---|---|
| Cincin rata jari-jari 12–16 petak, 8 bangunan | 8 fasad: Merrit, gudang, toko Otha, rumah kosong, Lyra, +3 rumah selatan | **Ya.** Di `01` cincinnya tertutup di semua sisi; sisi selatan tak lagi bolong |
| Jalan dagang timur–barat melintas penuh | Pita batu selebar peta | **Ya**, dan ia satu-satunya garis yang membelah peta — sumbu terbaca jelas |
| Papan Otha kosong + bekas cat | Ada, skala 4× | **Ya** — persegi pudar terbaca sebagai "pernah ada tulisan" |
| Gradien #218: 1 dari 4 hidup | 6 jendela; hanya Lyra + lentera Merrit yang menyala | **Ya, dan ini yang paling kuat di seluruh peta** — lihat `02` |
| Ladang + gudang gandum | Tanah bajak + tanaman + jerami | **Ya**, ladang terbaca ladang |

### C3 — pinggiran (jejak "pernah ada")

| SPEC | ADA | TERBACA |
|---|---|---|
| Tepi = jejak kerugian, bukan hiasan | Fondasi batu, pagar patah, tunggul, batang tumbang, reruntuhan | **Ya.** Di `05c` reruntuhan barat terbaca sebagai **denah rumah yang hilang**, bukan batu acak |
| Anti-kosong: tiap tujuan jauh berujung SESUATU | Sebagian | **Setengah** — lihat 🟡-2. Barat-daya & tenggara masih hamparan rumput lebar tanpa satu penanda pun |
| 1 wisp di C3 (gradien hantu→nyata) | Ya, di ladang terbengkalai (872,1006) | **Ya**, dan ia terbaca justru karena sendirian |

### C4 — tepi hantu (pemakaman + treeline)

| SPEC | ADA | TERBACA |
|---|---|---|
| Pemakaman bisa dicapai, ±80 nisan tak rapi, D2:D3 ≈ 1:2 | Ya | **Ya, paling berhasil di peta.** Di `05d` jumlah batu vs ukuran desa langsung terbaca sebagai salah-imbang. Nisan aus vs terbaca memang beda jelas |
| Pagar tiang; sisi selatan bolong | Ya | **Ya** — "pernah dijaga" terbaca tanpa teks |
| Treeline berlapis = tembok yang indah | 4 lapis, pinus + pohon gundul | **Ya.** Ada kedalaman sungguhan; jauh lebih baik daripada pita kabut. Tabrakan penuh — pemain berhenti **di depan**, tak pernah masuk |
| Wisp 3× di kubur, alfa menurun ke dalam | Ya | **Ya.** Di `02` (malam) mereka satu-satunya cahaya selain lentera Merrit. Tesis "another life" tersampaikan |
| Sudut Sora (#013) dikosongkan | Kosong, **belum di-wire** | Terbaca sebagai petak kosong biasa — niatnya tak terlihat pemain |
| Gerbang selatan + titik lahir | Ada | **Setengah** — lihat 🟡-1 |

---

## 2 — DAFTAR JUJUR YANG BELUM JADI

### 🔴 MENGGANGGU — terlihat salah saat main

**🔴-1 · Dua puluh enam orang berdiri diam menghadap kamera.**
`04b`/`05a`: seluruh warga latar **dan** keenam tokoh bernama tergambar sebagai **satu frame
diam menghadap bawah**. `_folk()` memasang tokoh sebagai `Sprite2D` polos —
`at.region = Rect2(0,128,64,64)`, nol animasi, nol putar hadap. Alun-alun ramai terbaca
sebagai **etalase manekin**, dan itu justru merusak yang sudah benar: sebaran timpang yang
dikerjakan susah payah tak terbaca "orang punya urusan" kalau tak satu pun bergerak.

**🔴-2 · Cuaca diumumkan tapi tak digambar.**
Panel kiri di `05a` menulis **"Cuaca Badai Petir"**, `05d` **"Cuaca Hujan"** — layarnya
**identik** dengan `01` yang "Cuaca Cerah". Nol tetes, nol kilat, nol gelap tambahan. Teks
yang menjanjikan sesuatu yang tak ada lebih buruk daripada tak ada label sama sekali.

**🔴-3 · Tepi timur & barat = potongan hitam.**
`05c` (dan sisi kanan-kiri `01`): dunia berhenti pada void hitam bersudut tajam. Selatan
sudah punya treeline yang indah; timur/barat/utara belum punya apa pun. Kontrasnya membuat
tepi yang **belum dikerjakan** justru menonjol karena tepi lain sudah dikerjakan.

**🔴-4 · Air mancur terkubur warga.**
Pusat alun-alun — benda paling penting secara komposisi — tak terlihat dari kamera main
karena 4–5 warga berdiri persis di atasnya (`05a`). Zona alun-alun `VC + (0,96)` r=96
tumpang-tindih dengan lingkar air mancur.

### 🟡 PLACEHOLDER YANG BEKERJA — jelek tapi tak merusak

**🟡-1 · Gerbang selatan terbaca sebagai dua meja kayu.**
`03`: dua rangka kayu bertiang berdiri berdampingan. Fungsinya jalan (koridor lapang, jalur
batu ke utara), tapi siluetnya tak berkata "gerbang" — pemain baru tak tahu itu pintu masuk
kota. Titik lahir menghadap utara dengan treeline di punggung: **arah** benar, **lambang**
belum.

**🟡-2 · Kuadran barat-daya & tenggara masih lapangan rumput.**
Antara reruntuhan C3 dan pemakaman C4 ada dua hamparan lebar tanpa satu penanda. Ini
kekosongan **belum-jadi**, bukan bermakna: nol jejak, nol fondasi, nol alasan mata berhenti.

**🟡-3 · Balai desa = kembaran rumah Merrit.**
Aset terbesar repo dipakai dua kali. Berfungsi (massa besar menghadap alun-alun) tapi
identitasnya nol.

**🟡-4 · Nol hewan di separuh selatan.**
Ayam di gudang (utara), domba di timur. Seluruh perjalanan gerbang→inti melewati nol
makhluk hidup kecuali wisp. Wisp menutupinya dengan indah — itu sebabnya ini 🟡, bukan 🔴.

**🟡-5 · Minimap terbaca sebagai bintik acak.** Kanan-atas, semua tangkapan: titik-titik
warna tanpa denah jalan atau garis tepi. Tak menyesatkan, tapi tak menolong.

### ⚪ TERCATAT, MEMANG BELUM DIBANGUN

- **Sora (#013)** — sudut timur-laut pemakaman disiapkan, tokoh belum lahir (dialog + jadwal + siluet #231 = sesi tersendiri)
- **Interior tiga rumah selatan** — fasad ada, pintu tak menuju ke mana-mana
- **Sungai / jembatan** — keputusan cerita Direktur, bukan utang teknis; nol aset di gudang
- **Utara & timur belum digarap sebagai cincin** — pertumbuhan kanvas hanya ke selatan, jadi C3/C4 utara belum pernah lahir
- **Panduan 1/6 "kalahkan 2 monster di luar gerbang"** — hanya ADA satu anak serigala (1700,980), di sudut timur-laut, berlawanan arah dari gerbang selatan tempat pemain lahir

---

## 3 — KEKOSONGAN BERMAKNA vs KEKOSONGAN BELUM-JADI

Pembedaan ini yang paling penting, jadi dipisah eksplisit — keduanya "petak tanpa isi",
tapi satu adalah desain dan satu adalah utang.

**BERMAKNA (desain — jangan diisi):**
alun-alun yang terlalu besar untuk 40 orang · 8 bangku yang tak pernah penuh · pemakaman
yang lebih besar daripada desanya · rumah gelap yang jendelanya tak pernah menyala · papan
Otha yang kosong berbekas cat · garis fondasi tanpa rumah di atasnya · sisi pagar pemakaman
yang bolong · wisp yang tak bisa diajak bicara (tekan E = nol, sengaja).

**BELUM-JADI (utang — isi nanti):**
dua kuadran rumput di barat-daya & tenggara · tepi timur/barat/utara yang hitam · separuh
selatan tanpa hewan · balai desa tanpa identitas · gerbang tanpa lambang · warga tanpa gerak.

Ujinya sederhana: **kekosongan bermakna punya TEPI.** Alun-alun kosong dibingkai tong dan
bangku; pemakaman kosong dibingkai pagar. Kekosongan belum-jadi tak punya tepi — rumput
sampai layar habis.

---

## 4 — BERJALAN DI ASHBROOK

Pemain lahir menghadap utara dengan hutan gelap menutup punggungnya dan sebuah pemakaman
yang terlalu besar tergeletak di kiri, tiga cahaya biru pucat melayang perlahan di antara
batu-batunya. Tak ada yang menyambut. Ia berjalan ke utara melewati ladang yang masih
digarap dan rumah-rumah yang jendelanya tak pernah menyala, dan wisp keempat menunggunya
setengah jalan, di atas petak ladang yang berhenti dibajak — makin ke dalam kota, makin
tipis hantunya, sampai di alun-alun yang hidup bukan lagi cahaya melainkan ayam yang
berbunyi dan orang yang bisa diajak bicara. Perjalanan itu **menempuh** penyusutan
Ashbrook alih-alih menceritakannya, dan di situlah desa ini paling benar. Yang membuatnya
belum utuh bukan kekosongan — kekosongan justru isinya — melainkan bahwa ketika akhirnya
sampai di tengah, empat puluh orang yang menunggunya berdiri **diam sempurna** menghadap
kamera, dan kota yang sudah berhasil terasa *pernah besar* seketika terasa juga *belum
dinyalakan*. Malam memperbaikinya: begitu langit gelap dan tinggal lentera Merrit menyala
sendirian di antara delapan bangunan, Ashbrook akhirnya jadi tempat, bukan tata letak.

---

**Batas dipatuhi:** nol perubahan `game/`, gerbang tak disentuh, laporan + tangkapan saja.
