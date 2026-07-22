# INVENTARIS KANON — MERRIT FANE · ARLEN VALE · RUMAH SINGGAH · CHRONICLE · BUKTI #226

**Dibuat 2026-07-22 · Nol lore baru · Tiap fakta bersumber berkas.**

Aturan berkas ini: **hanya yang tertulis di repo.** Yang tak ada datanya ditulis
`TIDAK ADA DATA KANON`. Yang saling bertentangan ditandai `⚠ TEGANGAN`, tidak
didamaikan sendiri — mendamaikannya berarti memilih, dan memilih itu hak Designer.

Sumber ditulis `berkas:baris` bila baris relevan, `berkas` bila keseluruhan.

---

# 1. MERRIT FANE

## 1.1 Identitas

| fakta | nilai | sumber |
|---|---|---|
| Nama lengkap | Merrit Fane | `docs/Companion_bible/companion_11_merrit_fane.md:21` · `game/data/town_npcs.json` |
| Nomor companion | **#011** | `companion_11_merrit_fane.md:1` |
| Julukan sheet | **"Yang Menunggu Surat Balasan"** | `companion_11_merrit_fane.md:2` |
| Umur | **58 tahun** | `companion_11_merrit_fane.md:22` |
| Ras | manusia | `companion_11_merrit_fane.md:22` · `town_npcs.json` (`head_race: human`) |
| Pekerjaan | **tukang pos desa Ashbrook** | `companion_11_merrit_fane.md:22` |
| Rumah | rumah pos **merangkap rumah singgah** | `companion_11_merrit_fane.md:26` |
| Anak | **tidak punya anak** | `companion_11_merrit_fane.md:79` |

**Fisik (kanon sheet #011)** — `companion_11_merrit_fane.md:24`:
pria jangkung yang mulai membungkuk · rambut kelabu diikat ke belakang · jari-jari
bernoda tinta permanen · berjalan pelan tapi **tak pernah terlambat mengantar —
kecuali ke satu alamat** · mengenakan **mantel pos tua** yang seharusnya diganti dua
dekade lalu.

**Alasan menolak ganti mantel, verbatim:**
> *"mantel ini yang dipakainya waktu ia melihatku terakhir kali."*
> — `companion_11_merrit_fane.md:24`

**Warna dalam data game** (`town_npcs.json`, blok `config`):
`hair: long` · `hair_color: #cfc9d6` (kelabu-pucat) · `shirt: #4a4436` · `pants: #2f2a24`.
Sprite: `lpc_sheet: "merrit_fane"` — lembar wajah asli, `game/assets/game/sprites/characters/merrit_fane.png`.

## 1.2 Kepribadian — lima lapis kanon

Sumber ganda yang **saling cocok**: `companion_11_merrit_fane.md:36-40` dan blok
`profile` di `game/data/town_npcs.json`.

| lapis | sheet #011 | data game |
|---|---|---|
| Temperamen | Plegmatis-Melankolis | `temperament: plegmatis` · `temperament_sub: melankolis` |
| Openness | 45 | `openness: 45` |
| Conscientiousness | 80 | `conscientiousness: 80` |
| Extraversion | 40 | `extraversion: 40` |
| Agreeableness | 85 | `agreeableness: 85` |
| Neuroticism | 55 | `neuroticism: 55` |
| Sumbu Mencius | condong baik, stabil | `moral: 88` · `moral_drift: 0` |
| Growth | Discipline tinggi, Ambition rendah | `effort: 88` · `opportunity: 0` |

**Trauma** — `town_npcs.json`:
> `"event": "Kepergian yang tak pernah dijelaskan. Empat puluh tahun ketidakpastian."`
> `"weight": 18`

Sheet #011 menulis hal yang sama (`:38`): *"kepergian yang tak pernah dijelaskan;
empat puluh tahun ketidakpastian yang perlahan mengeras jadi cara hidup."*

**Angka lain di data game:** `talent: 30` · `luck: 35` · `mental_state: 78`.

> ⚠ **TEGANGAN — dua angka potensi.** Sheet #011 mengunci **Hidden Potential = 110**
> (`companion_11_merrit_fane.md:43`), sedangkan `town_npcs.json` menulis `talent: 30`.
> Keduanya mungkin skala berbeda (ceiling vs bakat mentah), tapi repo **tidak
> menjelaskan hubungannya di mana pun**. Ditandai, tidak didamaikan.

## 1.3 Rutinitas harian & jadwal NPC

Dari `game/data/town_npcs.json`, blok `schedule` (koordinat relatif terhadap pusat kota):

| waktu | posisi | kegiatan (verbatim) |
|---|---|---|
| pagi | `[-232, 24]` | *"membuka rumah singgah, menyortir surat yang tak banyak"* |
| sore | `[-180, 40]` | *"menyapu kamar yang tak ditiduri siapa pun"* |
| malam | `[-236, 10]` | *"menyalakan lampu, lalu duduk"* |

Ketiganya di sisi **barat** pusat — konsisten dengan rumah singgah di ujung barat
jalan (`Ashbrook.gd:19`).

## 1.4 Dialog yang SUDAH ADA

### a. Empat baris gosip harian — `game/data/town_npcs.json`, blok `lines`

1. *"Kamar-kamar itu masih kusapu. Bukan karena ada yang datang. Karena kalau berdebu, aku akan terbiasa."*
2. *"Tulisan tanganmu jelek. Bagus. Yang jelek biasanya jujur."*
3. *"Dulu aku hafal tulisan tangan setiap keluarga di sini. Sekarang aku hafal semuanya karena tinggal sedikit."*
4. *"Kalau kau pergi ke Greenvale, jangan menoleh. Atau menolehlah. Terserah. Lampunya tetap menyala."*

Status wiring: **terpasang** — `TownFolk`/`Villager` memuat `lines` dari
`town_npcs.json`. Merrit **tidak bisu**; yang tak ada adalah baris kesaksian.

### b. Dialog cutscene pembuka — `game/data/cutscenes.json`, cutscene `opening_pegasus`, langkah 10

> **Merrit Fane:**
> *"Kutemukan kau di dekat jembatan. Basah kuyup, tapi napasmu jalan."*
> *"Aku tidak bertanya dari mana kau datang. Orang lewat sini sudah lama — dan yang lewat biasanya tak suka ditanya."*
> *"Kamar itu kosong. Sudah lama kosong. Pakai saja."*

**Ini kalimat pertama yang didengar pemain di seluruh game.** Langkah 9 adalah
`speaker: "?"` — *"Oh. Kau akhirnya bangun."* — suara Merrit sebelum namanya muncul.

### c. Dialog A2 (draft, BELUM ter-wire) — `docs/Aetherion_bible/A2_SESEORANG_MELUPAKANMU.md`

Sebelum penghapusan, tentang kartu pos (`:56-58`):
> *"Oh, itu. Aku beli waktu kau pertama datang. Kalau-kalau kau pergi jauh dan mau kirim kabar."*
> *"Aku belum tulis alamatnya. Aku tidak tahu kau mau ke mana."*

Sesudah penghapusan (`:64`):
> **"Selamat pagi. Butuh kamar?"**

## 1.5 Hubungan dengan PEMAIN

Terkuat di seluruh data, dan berlapis:

1. **Merrit yang menemukan pemain.** Di dekat jembatan, basah kuyup.
   `cutscenes.json` / `opening_pegasus`.
2. **Merrit yang memberi pemain tempat tinggal.** *"Kamar itu kosong. Pakai saja."*
3. **Pemain BANGUN di rumah Merrit** — `Ashbrook.gd:85` (*"Opening kanon (#118):
   Pegasus = FIRST MYSTERY. Pemain BANGUN di rumah Merrit"*), posisi spawn
   `MERRIT_HOUSE + Vector2(0, 46)` (`Ashbrook.gd:89, 97`).
4. **Merrit tidak bertanya asal-usul pemain.** Disengaja, dinyatakan di dialognya.
5. **Merrit membeli kartu pos untuk pemain** — `ev_merrit_kartu_pos_kosong`.
6. **Merrit mengubah rute posnya demi pemain** — `ev_merrit_rute_pos_berubah`.
7. **Merrit menyisihkan cangkir kedua untuk pemain** — `ev_merrit_cangkir_kedua`.
8. **A2: Merrit melupakan pemain.** *"Yang hilang cuma satu hal: bahwa pemain pernah
   penting baginya."* — `A2_SESEORANG_MELUPAKANMU.md:88`

> Tiga dari empat bukti #226 adalah **bekas kasih sayang Merrit kepada pemain yang
> dilakukan tanpa diberitahukan.** Ketiganya ditemukan sesudah ia lupa.

## 1.6 Hubungan dengan CHRONICLE

**Merrit adalah juru tulis halaman Ashbrook.**

`game/autoload/WorldState.gd:261`:
```gdscript
Chronicle.record_person("place_ashbrook_besar", "Ashbrook — kota yang dulu besar", "merrit_fane")
```

Argumen ketiga `by` = **siapa yang repot menuliskannya**. `Chronicle.gd:77-78`:
> *"`by` — SIAPA yang repot menuliskannya (#261). Kosong = pemain sendiri.
> Ashbrook lahir dengan by:"merrit_fane" — **penjaga lentera yang menolak desanya
> terlupa**."*

`WorldState.gd:247-249`: halaman itu *"lahir atas nama **Merrit**, bukan sistem"*.

Halaman itu lalu **dicoret oleh WAKTU** (`WorldState.gd:265`,
`Chronicle.strike("place_ashbrook_besar", "waktu")`) — bukan oleh Nirnama, dan
`struck_cause` **tersimpan tapi tak pernah ditampilkan** (#229.4).

**Peran tematis** — `companion_11_merrit_fane.md:31`:
> *"Merrit adalah Chronicle dalam bentuk manusia paling kecil dan paling rapuh — satu
> orang tua yang menolak membiarkan satu nama hilang."*

### Halaman Chronicle miliknya sendiri: `person_merrit_fane`

Terdaftar di `game/data/chronicle_losses.json:38`. Isinya lengkap:

| medan | teks (id) |
|---|---|
| `_scene` | *"Rumah Singgah Fane. Merrit menyalakan lampu tiap malam selama 40 tahun untuk seseorang yang menitipkan surat. #229.2: bila ia mati sebelum suratnya terpecahkan, lampunya cuma tidak menyala lagi."* |
| `death` | `d2` |
| loss `benda` | *"Suratnya tidak ikut tertulis. Buku ini tahu ia menunggu. Buku ini tidak tahu untuk apa."* |
| loss `kebiasaan` | *"Tak seorang pun ingat lagi jam berapa lampunya dinyalakan."* |
| loss `akibat` | *"Ia tercatat sebagai tukang pos. Bukan sebagai orang yang menahan sebuah desa tetap tersambung ke dunia selama empat puluh tahun."* |
| loss `orang` | *"Ia tercatat. Bahwa ada yang menyayanginya, tidak."* |
| `loss_self` | *"Kau menuliskannya sendiri. Tanggalnya meleset setahun, dan itu akan tetap begitu selamanya."* |
| `default` | *"Ia tercatat sebagai orang yang menunggu. Apa yang ia tunggu tidak."* |

> ⚠ **STATUS WIRING:** halaman `person_merrit_fane` **tidak pernah dibuat maupun
> dicoret di kode mana pun.** Hanya `place_ashbrook_besar` yang dipanggil
> (`WorldState.gd:261`). Teks kerugiannya lengkap; halamannya belum lahir.

`A2_SESEORANG_MELUPAKANMU.md:177` menulis satu `loss` tambahan yang **belum ada di
JSON**:
> *"Ia ingat namamu. Ia tidak ingat bahwa ia pernah menunggumu pulang."*

## 1.7 Hubungan dengan ASHBROOK

**Ratifikasi #206** — `companion_11_merrit_fane.md:6-17`:
Ashbrook **dulu starting town makmur ~1.500 jiwa**; kini desa **~40 jiwa**. Sebabnya
**jalur dagang Valenford bergeser**, penduduk pindah ke kota.

> *"Kesepiannya berhenti menjadi **sifat**; ia menjadi **akibat**. **Ia menyalakan
> lampu terakhir dari zaman ketika Ashbrook masih ramai.**"*

> *"seorang tukang pos yang menolak melupakan satu orang, tinggal di kota yang sedang
> dilupakan dunia. **Ia tak pernah menyebutkannya — baginya kedua hal itu bahkan bukan
> soal yang sama.**"*

Fungsi sosial (`:22, :29`): ia **simpul** — tiap kabar masuk-keluar lembah lewat
tangannya · hafal tulisan tangan tiap keluarga · tahu siapa menunggu kabar dan siapa
berpura-pura tidak · **sumber rumor paling akurat** karena menghormati kabar seperti
orang lain menghormati sumpah.

## 1.8 Hubungan dengan LAMPU

Lampu Merrit adalah **objek desain terpenting Ashbrook**.

| fakta | sumber |
|---|---|
| Disebut **"jiwa Ashbrook"** | `Ashbrook.gd:48` (`var _lamp` — komentar) |
| **Menyala siang DAN malam** | `Ashbrook64.gd:1211` · `Ashbrook.gd:43` (*"lampu di jendelanya menyala — siang maupun malam"*) |
| Rumah lain padam satu per satu (19.00 · 20.00 · 21.00), lampu Merrit tersisa satu | `Ashbrook.gd:403-407` · `AshbrookWindow.gd:1-9` |
| Prinsipnya: **kontras dari PERBEDAAN, bukan ketiadaan** | `AshbrookWindow.gd:2` |
| Terlihat dari titik pandang jauh saat pemain berjalan ke Greenvale (#218) | `Ashbrook.gd:24` (`VANTAGE_ZOOM := 0.7`), `:434-440` |
| Posisi (16px) | `MERRIT_HOUSE + Vector2(18, -14)` — `Ashbrook.gd:172` |
| Posisi (64px) | `MERRIT_HOUSE + Vector2(72, -56)`, `z = Z_LAMP` — `Ashbrook64.gd:1212` |

**Merrit duduk membaca surat di bawah lampunya** — `Ashbrook.gd:414-431`
(`_build_lamp_seat`). Komentar kodenya:
> *"Merrit DUDUK MEMBACA SURAT di bawah lampunya — malam hari, tanpa dialog, tanpa
> cutscene, tanpa prompt. Pemain boleh menonton atau pergi. **Isinya TIDAK
> dijelaskan** (benih, bukan payoff — #216; kekuatannya ada pada penundaan)."*

Elemen adegan itu: bangku `ColorRect` 12×8 di `MERRIT_HOUSE + (6,4)`; surat
`ColorRect` 7×5 warna `(0.92, 0.88, 0.76)` di `MERRIT_HOUSE + (14,0)` — dikomentari
*"surat tua — kertas pucat, **tak pernah dibuka pemain**"*.

**Bila Merrit mati sebelum suratnya terpecahkan:** *"lampunya cuma tidak menyala
lagi."* — `chronicle_losses.json`, `_scene`.

## 1.9 Hubungan dengan SURAT

**Dua benda kertas berbeda, dan membedakannya penting:**

| | SURAT PENGELANA | KARTU POS KOSONG |
|---|---|---|
| umur | **40 tahun** | dibeli **saat pemain pertama datang** |
| pemilik janji | pengelana muda tak dikenal | pemain |
| status | **tak pernah dibuka** | **tak pernah ditulis alamatnya** |
| sumber | `companion_11_merrit_fane.md:46` | `evidence.json` · `A2:56` |

**Titipan itu, verbatim** — `companion_11_merrit_fane.md:46`:
> *"Simpan ini. Jangan dibaca. Aku akan kembali mengambilnya."*

> *"Ambisi Merrit yang sesungguhnya bukan tahu isinya — melainkan agar orang itu
> kembali untuk mengambilnya sendiri. **Selama surat itu tertutup, janji itu masih
> hidup.**"*

Bila tak terpecahkan, surat itu masuk Chronicle sebagai **"Surat yang Tak Pernah
Dibuka"** — entri permanen (`companion_11_merrit_fane.md:71`), dan
`A2:191`: *"tidak bisa dibuka. Bukan karena terkunci. **Karena orang yang berhak
membukanya sudah tidak ada, dan pemain bukan orang itu.**"*

**Identitas pengelana: SENGAJA KOSONG.** `companion_11_merrit_fane.md:61`:
> *"benang yang menghubungkan Merrit ke seluruh Life Event Chain. **Sengaja kosong** —
> kandidat: pengembara biasa yang mati dalam kecelakaan sepele (paling menyakitkan
> karena tak bermakna), atau seseorang yang terhubung sejarah lebih besar (kutahan
> agar tak dikunci; **Direktur putuskan saat Act ditulis**)."*

## 1.10 Relasi lain

| tokoh | hubungan | sumber |
|---|---|---|
| **Arlen Vale (#1)** | ayah tak resmi — lihat §2 | `companion_11:58` · `companion_01:56` |
| **Kain Blacktide (#5)** | pernah mencoba **membeli tanah Merrit** (penyelundupan/gudang); Merrit menolak; Kain menghormati penolakan itu | `companion_11:59` |
| **Nyai Tuminah (NPC #25)** | *"dua orang tua yang sama-sama menyalakan lampu untuk seseorang yang mungkin tak kembali. **Mereka jarang bicara. Mereka tidak perlu.**"* | `companion_11:60` |
| **Otha Renn** | Merrit adalah **saksi** bukti Otha `ev_otha_jahitan_mantel_merrit` | `evidence.json` |
| **Old Bram · Lyra · Halloran** | menjelaskan kelupaan Merrit sebagai umur — **dan tak satu pun salah** | `A2:99-103` |

## 1.11 Konflik yang sudah dikanonkan

**Internal** (`companion_11:52`):
> *"ia menyampaikan kabar orang lain, tapi menolak mencari kabar yang ia sendiri
> butuhkan… selama ia tidak tahu, kedua kemungkinan masih hidup… **keberaniannya
> mengantar setiap surat, dan kepengecutannya menolak menyelidiki satu.**"*

**Eksternal** (`companion_11:55`): tanahnya diincar (jalur dagang / gudang Rumah
Lelang B8). Penolakannya, verbatim:
> *"Kalau ia kembali dan rumahnya sudah tiada, ke mana ia mencariku?"*

**Ketakutan** (`companion_11:49`): bukan kematiannya sendiri — bahwa **kesetiaannya
sia-sia**.

## 1.12 Apakah pernah muncul di Bible lain

| dokumen | isi |
|---|---|
| `docs/Companion_bible/companion_11_merrit_fane.md` | **sheet penuh #011** (95 baris) |
| `docs/Aetherion_bible/A2_SESEORANG_MELUPAKANMU.md` | **adegan A2 — Merrit korbannya** (272 baris) |
| `docs/Companion_bible/companion_01_arlen_vale.md` | relasi ayah-tak-resmi, sumber horizon Arlen |
| `reports/INFO_PRA_V05.md:152` | Merrit (#011) terdaftar di **Rumah Lelang (B8)**, *"sudah HIDUP di kode (v0.4.2)"* |
| `reports/INFO_PRA_V05.md:224-227` | *"**patokan yang Direktur tulis sendiri**… dirancang sebagai **companion pembuka tema**, ditemui **paling awal**"* |
| `reports/BAHAN_DIALOG_MERRIT.md` | analisis bukti & saksi |
| `reports/AUDIT_GAMEPLAY_ASHBROOK.md` | status wiring |

---

# 2. ARLEN VALE

**Ada data kanon, dan jumlahnya besar** — satu sheet companion penuh 103 baris.
Yang tak ada adalah **implementasinya**.

## 2.1 Identitas

| fakta | nilai | sumber |
|---|---|---|
| Nama lengkap | **Arlen Vale** | `companion_01_arlen_vale.md:1` |
| Nomor companion | **#001** | `:1` |
| Julukan sheet | **"The Boy Who Wanted The Horizon"** | `:2` |
| Umur | **19 tahun** | `:8` |
| Jenis kelamin | **laki-laki** (*"anak yang ingin ikut"*, *"seorang kurir"*, ayahnya menyebutnya anak lelaki) | `:8, :15, :57` |
| Ras | manusia | `:8` |
| Pekerjaan | **kurir desa Ashbrook** | `:8` |
| Tempat tinggal | **Ashbrook** | `:8` · `INFO_PRA_V05.md:104` |
| Status | **hidup** — tak ada data kematian di kanon dasar | `:8` |
| Hidden Potential | **340 (berbakat)** | `:29` |

**Fisik** (`:10`): jangkung-kurus · kaki kuat · kulit terbakar matahari · **senyum
yang datang terlalu cepat dan terlalu sering**.

**Benda penandanya** (`:10`): peta lembah yang ia gambar sendiri **sejak umur 11**,
dilipat sampai lipatannya sobek; di tepinya, di luar garis lembah, satu kata ditulis
berkali-kali sampai kertasnya berlubang: **"lalu?"**

**Batu penanda** (`:12`): di ujung jalan utara Ashbrook. *"Arlen mengantar sampai batu
itu. Ia berhenti di sana. **Ia sudah berhenti di sana ribuan kali.**"*

## 2.2 Hubungan dengan Merrit — kanon eksplisit dua arah

**Dari sheet Arlen** (`:36`):
> *"Arlen tumbuh di rumah pos Merrit Fane. Sebagai anak, ia duduk di lantai sambil
> menonton orang tua itu menyerahkan surat ke tangan orang lain… **Kerinduannya pada
> horizon lahir di sana** — bukan dari keinginan berjalan, melainkan dari kesadaran
> kecil dan pahit bahwa **surat-surat itu selalu untuk orang lain**."*

**Ambisi sesungguhnya** (`:36`):
> *"**menjadi orang yang mengirim kartu pos, bukan yang menonton kartu pos orang lain
> diantar.**"*

**Dari sheet Merrit** (`companion_11:58`):
> *"Merrit menampung Arlen kecil saat orang tuanya sibuk… Dalam arti nyata,
> **kerinduan Arlen pada horizon lahir di rumah pos Merrit.**"*

**Sifat hubungannya** (`companion_01:56`):
> *"ayah tak resmi… hangat dan sedikit sesak: Merrit **bangga** padanya dan **tidak
> pernah menyuruhnya pergi** — karena Merrit tahu betul harga menunggu seseorang yang
> pergi, dan tak sanggup menjadi orang yang mengirim satu lagi."*

**Ketakutan lapis ketiga Arlen** (`:41`):
> *"ia takut menjadi Merrit. Ia takut suatu hari menjadi orang tua di jendela yang
> menyalakan lampu untuk sesuatu yang tak datang, dan menyebutnya kesetiaan agar tidak
> perlu menyebutnya kekalahan."*

**Ironi yang WAJIB dijaga** (`:43`):
> *"Merrit-lah yang mengajarinya menginginkan horizon — dan Merrit juga yang, tanpa
> pernah bermaksud, mengajarinya bahwa tidak-tahu lebih aman daripada jawaban yang
> salah."*

## 2.3 Keluarga

| tokoh | fakta | sumber |
|---|---|---|
| **Corvin Vale** (ayah) | petani; punggung **dua musim tak bisa membungkuk penuh**; ladang menyusut; upah kurir Arlen yang menahan keluarga di ambang | `companion_01:51, :57` |
| kalimat Corvin | *"Jangan tinggal karena aku. Aku tidak sanggup jadi alasan."* | `:57` |
| ibu | **TIDAK ADA DATA KANON** | — |
| saudara | **TIDAK ADA DATA KANON** | — |

## 2.4 Evidence yang melibatkannya

Satu, dan hanya satu: **`ev_merrit_arlen_ingat`** — `game/data/evidence.json`.

```
kind:         orang
page:         person_merrit_fane
where:        ashbrook
found_by:     dialog_arlen
requires_npc: arlen
decay:        never
```

**Teks yang dilihat pemain (`notice.id`):**
> *"Kalian ngobrol tiap malam, Pak Tua. Aku lihat dari jalan. Tiap malam."*

**Catatan desainernya (`_note`):**
> *"A2 × #228 — Arlen ingat. 'Kalian ngobrol tiap malam, Pak Tua. Aku lihat.'
> **MERRIT TIDAK PERCAYA PADANYA** — Merrit percaya pada dirinya sendiri, dan dirinya
> bilang ia tak pernah kenal orang ini. ⚠ Pemain yang tak merekrut Arlen tidak dapat
> bukti ini — dan itu SAH (#228: masih ada 3 bukti lain, cukup untuk jalur SENDIRI)."*

**Fakta turunan dari baris ini:**
- Arlen memanggil Merrit **"Pak Tua"**
- Arlen **melihat dari jalan** — ia berjalan malam; konsisten dengan kurir
- Merrit dan pemain **mengobrol tiap malam** sebelum A2 — dikonfirmasi saksi
- **Merrit tidak percaya kesaksian Arlen**

## 2.5 Dialog yang sudah ada

**Satu kalimat**, yaitu `notice` di atas. Tak ada blok `lines`, tak ada entri di
`town_npcs.json`, tak ada cutscene.

Kalimat lain yang tertulis di sheet tapi **belum jadi data game**:
- *"Di sana seperti apa?"* — pertanyaannya yang selalu sama (`:10`)
- *"Kau datang dari arah mana? Di sana seperti apa?"* — pertemuan pertama (`:63`)
- *"aku cuma ingin melihat apa yang sudah kau lihat."* (`:60`)
- *"aku hampir pergi sekali."* — Arlen 39, dua puluh tahun kemudian (`:72`)

## 2.6 Status implementasi — TIDAK ADA

| aspek | status | sumber |
|---|---|---|
| entri `town_npcs.json` | **tidak ada** | diperiksa langsung |
| sprite | **tidak ada** | `AUDIT_GAMEPLAY_ASHBROOK.md:240` |
| penempatan di scene mana pun | **tidak ada** | `:240` |
| sistem dialog-bukti (`dialog_arlen`) | **tidak ada di kode** | `FAKTA_DESIGNER_B4.md:253` |
| bisa direkrut | **tidak** | `AUDIT:244` |

`AUDIT_GAMEPLAY_ASHBROOK.md:240`:
> *"**TIDAK ADA sama sekali** — nol sprite, nol penempatan. Cuma disebut di satu id bukti"*

`FAKTA_DESIGNER_B5.md:209` — peringatan wiring:
> *"Mewire-nya lewat `_examine_point` akan memberi bukti 'kesaksian Arlen' **tanpa
> Arlen**. Melanggar #228 secara naratif"*

> ⚠ **TEGANGAN — pencoretan casting.** `reports/ASHBROOK_6_UJI.md:12` mencatat
> *"Arlen dicoret (terlalu mirip Halloran)."* Itu keputusan **casting untuk uji 6 NPC**,
> bukan penghapusan kanon — sheet #001 tetap utuh dan `INFO_PRA_V05.md` tetap
> memperlakukannya sebagai companion gelombang awal. **Ditandai, tidak didamaikan.**

## 2.7 Peran yang direncanakan

- **"Kaki" Domain** — pembuka rute, pemetaan wilayah, jalur dagang, kurir antar-wilayah
  (`companion_01:19`)
- Berpasangan dengan sistem pos Merrit: *"**Merrit memegang surat, Arlen memegang
  jalan.**"* (`:19`)
- `AUDIT:244` mencatat rantai rencana yang belum satu pun hidup:
  *"Sora merasakan → **Arlen mengambil** → Merrit tahu ke mana → Elyn menulis"*

---

# 3. RUMAH SINGGAH MERRIT

## 3.1 Posisi di dunia

| versi | konstanta | nilai |
|---|---|---|
| Ashbrook 16px | `MERRIT_HOUSE` | `Vector2(232, 376)` — *"rumah singgah — ujung barat jalan"* (`Ashbrook.gd:19`) |
| Ashbrook64 | `MERRIT_HOUSE` | `Vector2(790, 440)` (`Ashbrook64.gd:65`) |
| Fasad | `fasad_singgah.png` | `Ashbrook64.gd:1078` |
| Interior | `INTERIOR` | `Vector2(4200, 160)` (`Ashbrook64.gd:97`) |
| Pintu masuk | `Ashbrook64.gd:1871` | label **"Masuk rumah Merrit [E]"** |

Interior hidup di **ruang positif DI LUAR peta** — disengaja. Perabotnya diberi
`z_index` eksplisit karena `_put()` menurunkan z dari koordinat-y dan kamar ini pernah
tenggelam di bawah lantainya sendiri (`Ashbrook64.gd:1979-1983`).

Zona warga latar: `MERRIT_HOUSE + Vector2(0, 72)`, radius 44, **1 orang** — teras rumah
singgah (`Ashbrook64.gd:2080`).

## 3.2 Layout interior — `_bangun_kamar_merrit()`, `Ashbrook64.gd:1977`

Semua relatif terhadap `o = INTERIOR = (4200, 160)`.

| elemen | posisi | ukuran / catatan |
|---|---|---|
| lantai | `o + (0,0)` | 320×240, warna `(0.17, 0.14, 0.11)`, z 0 |
| dinding | `o + (0,-14)` | 320×14, warna `(0.10, 0.08, 0.07)`, z 1 |
| **perapian** | `o + (28,52)` | 40×34, warna `(0.34, 0.19, 0.11)`, z 2 |
| cahaya api | `o + (48,70)` | `PointLight2D` energy 2.6, warna `(1.0, 0.74, 0.45)` |
| cahaya isian | `o + (160,120)` | `PointLight2D` energy 1.5, warna `(0.95, 0.80, 0.62)` |

**Kamar berukuran 320×240 dan punya SATU sumber cahaya: perapian.** Komentar kodenya:
*"Perapian = satu-satunya cahaya, dan ia menyala. `CanvasModulate` menggelapkan seisi
scene pada malam WIB; tanpa lampu ini kamarnya jadi kotak hitam."*

## 3.3 Perabot

| benda | sprite | posisi |
|---|---|---|
| meja | `table_lpc.png` | `o + (160,120)` |
| bangku | `bench_lpc.png` | `o + (120,156)` |
| tong | `barrel_lpc.png` | `o + (272,96)` |
| rak botol | `_kotak` 64×18, `(0.26,0.30,0.28)` | `o + (232,150)` |
| para-para perapian | `_kotak` 48×6, `(0.30,0.24,0.18)` | `o + (34,88)` |
| rak buku rute | `_kotak` 44×6, `(0.30,0.24,0.18)` | `o + (250,34)` |

## 3.4 Benda interaktif

| benda | posisi | jenis | label |
|---|---|---|---|
| **SURAT di meja** | `o + (160,112)` | `setup_bicara` | *"Surat di meja [E]"* |
| **BOTOL berjajar** | `o + (264,146)` | `setup_bicara` | *"Botol berjajar [E]"* |
| **kartu pos** | `o + (56,96)` | `_examine` → `ev_merrit_kartu_pos_kosong` | (notice bukti) |
| **buku rute** | `o + (272,40)` | `_examine` → `ev_merrit_rute_pos_berubah` | (notice bukti) |
| pintu keluar | `o + (150,205)` | `setup_pindah` → `MERRIT_HOUSE + (0,36)` | *"Keluar [E]"* |

### Teks SURAT — verbatim, `Ashbrook64.gd:2016-2020`

> *"Sepucuk surat, dibuka dan dilipat kembali sampai lipatannya menipis."*
> *"Tanggalnya empat puluh tahun lalu. Isinya cuma satu kalimat: **"Tunggu aku, jangan pindah."**"*
> *"Tak ada nama pengirim. Merrit tak pernah menyebutkannya kepada siapa pun."*

> ⚠ **TEGANGAN — dua versi isi surat.** Kode menulis isinya **"Tunggu aku, jangan
> pindah."** Sheet #011 (`:46`) menulis titipannya sebagai *"Simpan ini. Jangan
> dibaca. Aku akan kembali mengambilnya"* dan isinya **belum ditentukan** (kandidat di
> `:69`: *"Terima kasih sudah menungguku. Aku tahu kau akan."*).
> Kode sudah **memutuskan** apa yang sheet sengaja tahan. **Ditandai, tidak
> didamaikan** — Designer perlu memilih mana yang kanon.

### Teks BOTOL — verbatim, `Ashbrook64.gd:2025-2028`

> *"Botol minyak lampu, kosong semua, berjajar rapi menurut tahun."*
> *"Kau berhenti menghitung di baris ketiga. **Ada lebih banyak botol di sini daripada
> orang di Ashbrook.**"*

Komentar kodenya: *"BOTOL MINYAK — bukti kerja, bukan penjelasan."*

## 3.5 Aturan ruang yang sudah dibayar

Jarak antar-titik interaktif **wajib ≥72 px** — `Interactable` memunculkan label pada
radius 72, jadi dua titik lebih dekat saling merebut tombol E. Pernah memutus rantai
payoff di alun-alun tanpa satu galat pun muncul (`Ashbrook64.gd:2034-2046` ·
`Ashbrook64.gd:2062-2070`).

Diuji otomatis: `game/tests/CekMerrit.gd` (10 invarian) dan `TestRunner.gd`
(*"nol titik-periksa berbukti di luar tanah MAUPUN di luar interior"* +
*"kamar interior punya pintu masuk"*).

---

# 4. EVIDENCE #226

## 4.1 Empat bukti halaman `person_merrit_fane`

Semua `where: ashbrook_rumah_singgah` kecuali yang `orang`; semua `decay: never`;
semua bertanda **A2** di catatannya.

### ① `ev_merrit_kartu_pos_kosong` — **benda**

- **found_by:** `examine` · **lokasi:** laci / rumah singgah · **terpasang:** ✅ `o+(56,96)`
- **notice (id):** *"Kartu pos kosong. Tanpa alamat. Di sudutnya, tulisan tangan
  Merrit: harga, dan sebuah tanggal — hari pertama kau tiba di Ashbrook."*
- **notice (en):** *"A blank postcard. No address. In the corner, Merrit's handwriting:
  a price, and a date — the first day you arrived in Ashbrook."*
- **_note:** *"A2 — 'Aku beli waktu kau pertama datang…' Setelah A2 ia tak ingat
  membelinya — **TAPI ITU TULISAN TANGANNYA DI SUDUT**: harga, tanggal. Ia tak akan
  pernah membuangnya. **Tangannya tidak mau.**"*

### ② `ev_merrit_cangkir_kedua` — **kebiasaan**

- **found_by:** `observe` · **schedule:** `pagi` · **terpasang:** ❌ mekanisme `observe`
  **tidak ada di kode** (nol rujukan di `scenes/` maupun `autoload/`)
- **notice (id):** *"Dua cangkir di meja. Ia menuang teh ke keduanya, seperti tiap
  pagi. Yang kedua dingin tanpa disentuh, seperti tiap pagi."*
- **_note:** *"Merrit masih menyisihkan cangkir kedua tiap pagi. Ia tidak tahu untuk
  siapa. Ia sudah melakukannya berbulan-bulan. **Tubuh ingat setelah kepala lupa.**"*

### ③ `ev_merrit_rute_pos_berubah` — **akibat**

- **found_by:** `examine` · **lokasi:** buku rute · **terpasang:** ✅ `o+(272,40)`
- **notice (id):** *"Rute posnya punya satu perhentian yang tak masuk akal — tak ada
  rumah di sana. Ditambahkan beberapa bulan lalu, dengan tulisan tangannya sendiri. Ia
  masih melewatinya tiap hari."*
- **_note:** *"Ia menambahkan satu perhentian berbulan-bulan lalu: **tempat pemain
  sering ada**. Ia MASIH melewatinya tiap hari. Ia tidak tahu kenapa."*

### ④ `ev_merrit_arlen_ingat` — **orang**

- **found_by:** `dialog_arlen` · **requires_npc:** `arlen` · **terpasang:** ❌ Arlen tak ada
- **notice (id):** *"Kalian ngobrol tiap malam, Pak Tua. Aku lihat dari jalan. Tiap malam."*
- **_note:** *"MERRIT TIDAK PERCAYA PADANYA — Merrit percaya pada dirinya sendiri, dan
  dirinya bilang ia tak pernah kenal orang ini."*

## 4.2 Bukti KELIMA — Merrit sebagai saksi orang lain

**`ev_otha_jahitan_mantel_merrit`** — `kind: benda`, `page: person_otha_renn`,
`where: ashbrook_rumah_singgah`, `found_by: dialog_merrit`.

- **notice (id):** *"Siku kanan mantel itu pernah robek, dan dijahit ulang oleh tangan
  yang jauh lebih sabar daripada tangan Merrit."*
- **_note:** *"A1 × kanon #011… Merrit menolak mengganti mantel pos tuanya. Jahitan di
  siku kanan sudah diperbaiki — **BUKAN oleh Merrit. Ia tak ingat siapa.** Ia cuma
  tahu ia tak pernah bisa menjahit serapi itu. ⚠ Merrit **TIDAK menawarkan** info ini.
  Pemain harus memeriksa mantelnya."*

> Ini satu-satunya tempat Merrit **memberi** bukti, dan yang ia buktikan adalah
> **Otha** — bukan dirinya.

## 4.3 Hubungan antar-bukti

**Tiga dari empat bukti Merrit adalah tulisan tangannya sendiri atau tubuhnya
sendiri, dan ketiganya tentang PEMAIN:**

```
kartu pos   -> tulisan tangannya   -> tanggal pemain tiba
buku rute   -> tulisan tangannya   -> tempat pemain sering ada
cangkir     -> tubuhnya            -> untuk seseorang yang tak ia kenali
arlen       -> orang lain          -> dan Merrit TIDAK percaya
```

**Polanya tunggal dan tegas:** bukti datang dari **bekas perbuatan**, bukan dari
ingatan. Tiga dari empat adalah **bekas yang ditinggalkan Merrit sendiri**, dan Merrit
tak bisa menyangkal tulisan tangannya sendiri. Yang keempat adalah kesaksian manusia —
dan itu justru yang **ia tolak percayai**.

`A2:154` menulis hukumnya:
> *"**#226 — ingatan tidak bisa dipulihkan dari ingatan. Hanya dari bekas.**"*

Ambang pemulihan (`A2:164`): **butuh 2 jenis** (jalur Elyn/Sora) atau **3 jenis**
(jalur sendiri). Karena itu hilangnya bukti `orang` **tidak mematikan** halaman ini —
tiga bukti sisanya cukup untuk jalur sendiri (#228, dicatat di `_note` bukti ④).

## 4.4 Apa yang sebenarnya sedang diceritakan bukti-bukti ini

**Analisis dari data saja, nol tambahan.**

Keempat bukti punya satu bentuk yang sama: **Merrit melakukan sesuatu untuk pemain
tanpa pernah memberitahu pemain.** Kartu pos dibeli diam-diam. Rute diubah diam-diam.
Cangkir dituang diam-diam. Percakapan malam disaksikan orang ketiga, bukan diceritakan.

Dan keempatnya baru **terlihat** sesudah ia lupa.

Artinya struktur adegannya begini: pemain tak pernah tahu ia disayangi **sampai
bukti kasih sayang itu jadi satu-satunya yang tersisa**. Kartu pos yang tak pernah
ditulis alamatnya adalah gambar paling padatnya — kasih sayang yang **disiapkan tapi
tak pernah disampaikan**, lalu pemiliknya lupa kenapa ia menyiapkannya.

Bacaan kedua, dari `loss` yang ditulis tangan (`A2:177`):
> *"Ia ingat namamu. **Ia tidak ingat bahwa ia pernah menunggumu pulang.**"*

Bukti memulihkan **fakta**, bukan **perasaan**. Halaman kembali, nama kembali —
menunggu tidak. Itu konsisten dengan `loss` di `chronicle_losses.json`:
*"Ia tercatat sebagai orang yang menunggu. **Apa yang ia tunggu tidak.**"*

---

# 5. TIMELINE MERRIT

## FAKTA KANON

| # | waktu | peristiwa | sumber |
|---|---|---|---|
| 1 | ~40+ th lalu | Ashbrook **kota makmur ~1.500 jiwa**, starting town | `companion_11:7` |
| 2 | ~40 th lalu | **Jalur dagang Valenford bergeser**; penduduk pindah; Ashbrook menyusut ke ~40 jiwa | `companion_11:7` |
| 3 | **40 th lalu** | **Pengelana muda menitipkan surat:** *"Simpan ini. Jangan dibaca. Aku akan kembali mengambilnya."* | `companion_11:46` |
| 4 | 40 th lalu | Pertemuan terakhir — Merrit memakai mantel pos yang sejak itu **ia tolak ganti** | `companion_11:24` |
| 5 | sejak itu | **Lampu dinyalakan tiap malam.** Botol minyak kosong berjajar menurut tahun | `chronicle_losses` · `Ashbrook64.gd:2025` |
| 6 | ~2 dekade lalu | Mantel *"seharusnya sudah diganti"* | `companion_11:24` |
| 7 | tak bertanggal | **Siku mantel robek, dijahit oleh orang lain.** Merrit **tak ingat siapa** | `evidence.json` |
| 8 | Arlen kecil | **Merrit menampung Arlen**; kerinduan Arlen pada horizon lahir di rumah pos itu | `companion_01:36` · `companion_11:58` |
| 9 | tak bertanggal | **Kain Blacktide mencoba membeli tanahnya. Merrit menolak.** | `companion_11:59` |
| 10 | — | Merrit **menulis halaman Ashbrook ke Chronicle** (`by: merrit_fane`) | `WorldState.gd:261` |
| 11 | — | Halaman itu **dicoret oleh WAKTU** | `WorldState.gd:265` |
| 12 | **hari-0** | Langit retak · pemain jatuh · **Merrit menemukannya di dekat jembatan, basah kuyup** | `cutscenes.json` |
| 13 | hari-0 | *"Kamar itu kosong. Sudah lama kosong. Pakai saja."* Pemain **bangun di rumah Merrit** | `cutscenes.json` · `Ashbrook.gd:85` |
| 14 | hari-0 | Merrit **membeli kartu pos** untuk pemain; menulis harga & tanggal di sudut; **tak pernah menulis alamat** | `evidence.json` |
| 15 | beberapa bulan | Merrit **menambah satu perhentian** di rute posnya: tempat pemain sering ada | `evidence.json` |
| 16 | berbulan-bulan | Merrit **menyisihkan cangkir kedua** tiap pagi | `evidence.json` |
| 17 | tiap malam | Merrit & pemain **mengobrol tiap malam** — disaksikan Arlen dari jalan | `evidence.json` |
| 18 | **A2** | **Merrit melupakan pemain.** *"Selamat pagi. Butuh kamar?"* | `A2:64` |
| 19 | sesudah A2 | Kartu pos **tetap di laci**; lampu **tetap menyala**; tanah **tetap tak dijual** | `A2:82-87` |
| **SEKARANG** | v0.4.x | Merrit di Ashbrook64, 4 baris gosip, wajah asli, 2 bukti kamar terpasang | repo |

## CELAH — ditandai, tidak diisi

| # | celah | apa yang hilang |
|---|---|---|
| C1 | **Identitas pengelana** | Sengaja kosong. *"Direktur putuskan saat Act ditulis"* — `companion_11:61` |
| C2 | **Isi surat** | ⚠ dua versi berbeda (§3.4). Belum ada putusan |
| C3 | **Umur Merrit saat dititipi surat** | 58 − 40 = **18**, tapi **tak pernah ditulis** di kanon mana pun |
| C4 | **Siapa yang menjahit mantelnya** | Kanon menyatakan Merrit tak ingat. Tak ada data siapa |
| C5 | **Kapan Arlen tinggal di rumah pos** | *"saat orang tuanya sibuk"*; umur & lama **tak tertulis** |
| C6 | **Apakah Arlen masih tinggal di sana** | Tak ada data. Sheet menyebut ia punya ayah & ladang keluarga |
| C7 | **Ibu Arlen** | TIDAK ADA DATA KANON |
| C8 | **Kapan tepatnya A2 terjadi** | *"Act 1 Fase 3 (jam 60–100)"* — `A2:6`; tanggal in-world tak ada |
| C9 | **Berapa lama pemain di Ashbrook sebelum A2** | Bukti menyebut *"beberapa bulan"* / *"berbulan-bulan"*; angka pasti tak ada |
| C10 | **Apakah Merrit tahu Arlen ingin pergi** | Sheet menyatakan ia **tak pernah menyuruhnya pergi**; apakah ia **tahu** tak tertulis |
| C11 | **Nyai Tuminah menunggu siapa** | *"seseorang yang mungkin tak kembali"* — tak dirinci |
| C12 | **Umur & sebab halaman `person_merrit_fane` lahir** | Halaman tak pernah dibuat di kode; pemicunya belum ada |
| C13 | **Bagaimana Merrit bertemu pemain "tiap malam"** | Hanya diketahui dari kesaksian Arlen. Isi percakapannya tak ada |
| C14 | **Apakah Merrit pernah menulis kartu pos lain** | Tak ada data |

---

# 6. ANALISIS DESIGNER — tema utama Merrit

**Bukan "penantian". Tema utamanya: MENGINGAT SEBAGAI PEKERJAAN YANG DIPILIH, DAN
ONGKOSNYA.**

Penantian adalah **gejala**, bukan tema. Alasannya ada di data:

**Satu — pekerjaannya dan lukanya adalah kata kerja yang sama.** Merrit tukang pos:
ia **menyampaikan** yang dititipkan. Lukanya juga titipan yang tak tersampaikan.
Sheet #011:22 menyebutnya *simpul* — tangan yang menyentuh setiap kabar. Kalau temanya
penantian, pekerjaannya tak perlu tukang pos; ia bisa penjaga mercusuar. Bahwa ia
tukang pos berarti temanya **penyampaian dan ingatan**, bukan menunggu.

**Dua — konflik internalnya bukan tentang menunggu, tapi tentang MENOLAK TAHU.**
`companion_11:52`: *"ia menyampaikan kabar orang lain, tapi menolak mencari kabar yang
ia sendiri butuhkan."* Ia bisa mengirim surat ke utara. Ia tidak. Yang dijaga bukan
harapan — melainkan **keadaan tak-tahu**, karena tahu berarti memilih satu kenyataan.
Itu bukan penantian; itu **kesetiaan yang memilih ketidakpastian di atas jawaban**.

**Tiga — Chronicle menempatkannya sebagai penulis, bukan penunggu.**
`WorldState.gd:261` — Ashbrook masuk Chronicle **atas nama Merrit**, `by: merrit_fane`.
`Chronicle.gd:78` menyebutnya *"penjaga lentera yang menolak desanya terlupa."*
Yang ia lakukan pada desanya sama persis dengan yang ia lakukan pada pengelana:
**menolak membiarkan sesuatu hilang tercatat.** Dua obyek, satu kata kerja.

**Empat — ongkosnya dinyatakan eksplisit sebagai kerugian, bukan kesedihan.**
Keempat `loss` di `chronicle_losses.json` semuanya tentang **yang tak ikut tercatat**:
*"Buku ini tahu ia menunggu. Buku ini tidak tahu untuk apa."* · *"Ia tercatat sebagai
tukang pos. Bukan sebagai orang yang menahan sebuah desa tetap tersambung."* Kerugian
Merrit selalu berbentuk **catatan yang tidak lengkap** — bukan cinta yang tak
terbalas.

**Lima — A2 menyerang tepat di situ, bukan di penantiannya.** `A2:88`:
> *"Empat puluh tahun kesetiaannya kepada orang lain — **utuh**. Beberapa bulan
> bersama pemain — hilang. **Kabut tidak mengambil yang besar. Ia mengambil yang
> baru.**"*

Kalau tema Merrit penantian, adegan paling kejam adalah **membuktikan pengelana sudah
mati**. Tapi kanon justru **membiarkan penantian itu utuh** dan mengambil hal lain.
Yang dirusak adalah **kemampuannya mengingat**, dan yang dipakai memperbaikinya adalah
**bekas** — #226. Temanya ada di senjatanya.

### Tema sekunder yang didukung data

- **Ingatan sebagai kerja tubuh, bukan kepala** — *"Tubuh ingat setelah kepala lupa"*
  (cangkir), *"Tangannya tidak mau"* (kartu pos). Dua bukti mengatakan hal yang sama.
- **Kasih sayang yang tak pernah disampaikan** — tiga bukti = tiga perbuatan diam-diam
  untuk pemain. Kartu pos tanpa alamat adalah lambangnya.
- **Ordinary People / Hukum 8** — potensi 110, dinyatakan sebagai *pernyataan desain*
  (`companion_11:43`): *"Empat puluh tahun kesetiaan Merrit lebih berat daripada
  potensi 900 yang disia-siakan."*

### Kalimat yang paling padat memuat temanya

> *"Kamar-kamar itu masih kusapu. Bukan karena ada yang datang. **Karena kalau
> berdebu, aku akan terbiasa.**"* — `town_npcs.json`

Ia tidak menyapu untuk tamu. Ia menyapu supaya **dirinya sendiri tidak terbiasa pada
ketiadaan**. Itu bukan menunggu — itu **menolak lupa, dikerjakan tiap hari, dengan
tangan.**

### Implikasi untuk membangun Arlen

Kalau tema Merrit adalah *mengingat sebagai kerja yang dipilih*, maka Arlen adalah
**bantahannya yang penuh kasih**: anak yang tumbuh di rumah ingatan lalu menginginkan
**horizon** — pergi, bukan menyimpan. Kanon sudah mengunci ironinya
(`companion_01:41,43`): Arlen **takut menjadi Merrit**, dan Merrit-lah yang
mengajarinya menginginkan pergi.

Simetri yang sudah tertulis dan tinggal dipakai:
**Merrit memegang surat · Arlen memegang jalan** (`companion_01:19`) — dan bila Arlen
berhasil, `companion_01:69`: *"Ia mengirim kartu pos ke Ashbrook. **Merrit yang
mengantarnya.**"*

Kartu pos ada di kedua sheet, dari dua arah berlawanan. Itu bukan kebetulan; itu
poros yang sudah disiapkan Designer sejak awal.
