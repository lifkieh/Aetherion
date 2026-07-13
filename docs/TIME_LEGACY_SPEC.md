# TIME & LEGACY SPEC — turunan K1=c ("dua jam + lompatan")

> # ⚠ SEBAGIAN KANON, SEBAGIAN DRAF.
> **SUDAH DIPUTUS (#165):** laju **56 hari WIB = 1 tahun kronik** ✅ · **pemain menua HANYA
> lewat lompatan** ✅ (P-AGE=a) · tabel penuaan 8 ras & posisi Elyn **dipertahankan**.
> **Sisanya masih DRAF** — 5 pertanyaan §7 belum diputus. Disusun atas perintah Designer (#154).

## 0. DUA KOREKSI FAKTA sebelum spec dibaca (kewajiban lapor, #149)

Perintah Designer memuat dua premis yang **tidak cocok dengan isi repo**. Saya tidak
menutupinya, karena spec yang berdiri di atas premis keliru akan runtuh nanti:

1. **"K1=c, #115"** — baris **#115 adalah ARTEFAK TERLINDUNG**, bukan skala waktu.
   Baris skala waktu yang **⏳ PENDING OWNER** adalah **#123**. Keputusan K1=c yang Anda
   nyatakan sekarang **saya catat sebagai keputusan BARU** (#154) yang **menutup #123** —
   sah, dan sekarang tercatat di tempat yang benar.
2. **"chronicle_year sudah hidup"** — **tidak ada.** `grep chronicle_year game/` = **nol
   hasil**. Yang hidup adalah `Chronicle` (jurnal peristiwa bertanggal **WIB nyata**) dan
   `GameClock` (WIB + fase bulan + musim). **Jam kronik belum pernah ada** — spec ini
   merancangnya dari nol, bukan mendokumentasikan yang sudah ada.

---

## 1. DUA JAM — pembagian kuasa

Aturannya satu kalimat: **jam nyata memerintah HARI; jam kronik memerintah HIDUP.**

| | **JAM DUNIA** (WIB nyata) | **JAM KRONIK** (`chronicle_year`) |
|---|---|---|
| **Status** | ✅ **sudah hidup** (`GameClock`) | ❌ **belum ada — dibangun** |
| **Satuan** | detik/jam/hari/musim WIB asli | **tahun in-world** |
| **Sumber** | jam sistem pemain (WIB) | **turunan** dari hari WIB + akumulasi lompatan |
| **Memerintah** | siang-malam · fase bulan · musim (4×2 minggu) · cuaca · harga & restock · panen · gosip · bencana (#145) · Golden Hour · rasi | **penuaan** · **generasi** · **suksesi** · sejarah · tahun di Chronicle · pewarisan (P3) |
| **Laju** | 1:1 dengan hidup pemain | ✅ **DIPUTUS (#165): 1 tahun kronik = 56 hari WIB** (satu siklus musim penuh) |
| **Bisa melompat?** | **TIDAK PERNAH** — memalsukan jam nyata membunuh jiwa game ini | **YA** — lewat lompatan naratif (§4) |

**Kenapa 56 hari (bukan 14, bukan 365):** satu siklus musim penuh = satu tahun yang
**pemain rasakan** — ia melihat empat musim lewat, lalu dunia bilang "setahun berlalu",
dan itu **masuk akal secara tubuh**. Angka 14 (per musim) membuat NPC menua ~26 tahun per
tahun nyata (bayi jadi dewasa dalam 10 bulan main — absurd). Angka 365 membuat penuaan
**tak pernah terlihat** (persis penyakit yang K1 hendak sembuhkan).

**Konsekuensi laju ini:** pemain yang bermain **2 tahun nyata** melihat **~13 tahun kronik**
berlalu — cukup untuk anak tumbuh remaja, penguasa menua, sahabat beruban di pelipis.
Loncatan generasi penuh **tetap butuh lompatan** (§4). Itu disengaja.

**Rumus (patuh #89 — hitung-saat-login, nol tick):**
```
chronicle_year = TAHUN_AWAL
               + floor( (hari_WIB_sekarang − hari_WIB_lahir_dunia) / 56 )
               + total_tahun_lompatan          # tersimpan di save
```
Tak ada proses berjalan. Dua timestamp + satu akumulator. Dunia yang tak dimainkan
setahun **tetap** menua setahun-per-56-hari saat pemain kembali (dan Chronicle
menceritakan apa yang terlewat, §4).

---

## 2. LAJU PENUAAN PER RAS

Uji kelayakan spec ini: **Elyn — Elf, umur 134, Penjaga Arsip** (COMPANION_BIBLE).
Ia harus terbaca sebagai **dewasa yang matang, belum tua** — bukan nenek, bukan bocah.

| Ras | Dewasa | Prima | Menua | Sepuh | Harapan hidup tipikal | Laju vs manusia |
|---|---|---|---|---|---|---|
| **Human** | 18 | 20–40 | 41–60 | 61+ | ~75 | **1,00** |
| **Elf** | 100 | **110–300** | 301–500 | 501+ | ~600 | **0,13** |
| **Dryad** | 40 | 50–250 | 251–400 | 401+ | ~450 *(terikat pohonnya)* | 0,20 |
| **Dwarf** | 30 | 40–150 | 151–220 | 221+ | ~250 | 0,30 |
| **Beastfolk** | 14 | 16–35 | 36–50 | 51+ | ~60 | **1,25** |
| **Astralborn** | 25 | 30–120 | 121–180 | 181+ | ~200 | 0,40 |
| **Tidekin** | 20 | 25–60 | 61–90 | 91+ | ~100 | 0,75 |
| **Shadeborn** | 18 | 20–45 | 46–65 | 66+ | ~70 | 1,00 |

→ **Elyn (134) jatuh di awal PRIMA elf.** Ia sudah melihat empat generasi manusia lahir dan
mati di Arsipnya — **dan itu, bukan angkanya, yang harus terasa** saat ia bicara.

**Catatan yang MEMBERI, bukan menjelaskan** (Hukum Wonder):
- **Dryad** tidak mati karena umur — ia mati karena **pohonnya**. Umur di tabel adalah umur
  pohon yang sehat. *(Ini trade-off Stewardship, bukan statistik.)*
- **Astralborn**: ada yang bersikeras mereka **tidak menua saat rasi kelahirannya naik**.
  **Jangan pernah dikonfirmasi maupun dibantah** — kandidat MISTERI_ABADI.
- **Beastfolk** dewasa paling cepat dan mati paling awal. Mereka tahu itu. Itu sebabnya
  mereka **tidak menunda apa pun** — dan budaya mereka harus terasa begitu.
- **Shadeborn** menua seperti manusia, tetapi **tidak terlihat menua**. Berapa umurnya
  tidak pernah bisa ditebak dari wajahnya. *(Isyarat, bukan mekanik.)*

**Aturan keras (L14–L18, #137/#138):** umur **hanya** membuka/menutup **ambang**. Ia **tidak
pernah** menggerakkan Big Five, trauma, moral, atau growth — itu **hanya bergerak lewat
PERISTIWA**. Timer kosong tidak boleh mengubah siapa pun.

---

## 3. AMBANG USIA — apa yang benar-benar berubah

| Ambang | Yang berubah pada NPC | Yang **TIDAK** berubah |
|---|---|---|
| **Anak** | tak bekerja; belajar; **rentan** (Life Events tertentu hanya kena di sini) | — |
| **Dewasa** | mulai bekerja/menikah; **growth aktif** (latihan berbuah, L16) | temperamen (tetap seumur hidup) |
| **Prima** | puncak performa; **kandidat sejarah** (L17) | — |
| **Menua** | performa fisik turun perlahan; **mentoring** membuka (mereka menurunkan yang dimiliki, L14) | pengetahuan & pengaruh — justru **naik** |
| **Sepuh** | performa fisik jatuh; **kematian wajar** jadi mungkin (§4) | martabat. **Sepuh bukan sampah** (L18) |

**Kematian wajar bukan lemparan dadu diam-diam.** Ia hanya boleh terjadi (a) saat lompatan
waktu, atau (b) di ambang login, dan **wajib punya baris Chronicle**. NPC yang mati tanpa
tercatat = **bug**, bukan realisme.

---

## 4. LOMPATAN WAKTU — aturan main

**Pemicu yang SAH** (hanya ini):
1. **Suksesi dinasti / pewarisan pemain** (P3) — pemain menyerahkan tongkat estafet.
2. **Pergantian ERA** (LAW OF ERAS, #75b).
3. **Pensiun / peristirahatan yang dipilih pemain** secara eksplisit.
4. **Konsekuensi naratif besar** yang ditandai kanon (mis. penutupan arc).

**Pemicu TERLARANG:** grinding, tidur biasa, fast-travel, membuka menu, atau apa pun yang
bisa **dipancing** pemain untuk memanen waktu. **Waktu bukan sumber daya farmable.**

**Durasi:** ditentukan peristiwa (suksesi ≈ 15–25 tahun; era = dekade). Bukan slider.

**Yang dunia lakukan selama lompatan** (semua diturunkan, nol tick — #89):
- NPC menua; sebagian **mati** — **setiap kematian mendapat baris Chronicle bernama**.
- Anak lahir & tumbuh; **peluang** (L14) yang pemain berikan **berbuah atau tidak**.
- Kerajaan bergerak: penguasa berganti, perang mereda/pecah, kota tumbuh/runtuh.
- Quest yang menggantung **selesai atau gagal sendiri** (#89), dan **dunia mengingat mana**.

**Yang HARAM terjadi saat lompatan:**
- ❌ **Kematian senyap.** Tak boleh ada tokoh hilang tanpa Chronicle mencatat kapan & bagaimana.
- ❌ **Nasib acak murni.** Nasib harus turunan dari (bakat × usaha × **kesempatan yang
  pemain beri** × keberuntungan) — L17. Kalau pemain memberi Elyn arsip, Elyn tidak boleh
  mati sebagai pemulung karena dadu.
- ❌ **Semua orang jadi legenda.** Mayoritas harus tetap **biasa** (L18).
- ❌ **Misteri terjawab** hanya karena waktu lewat (Hukum Wonder).

**Setelah lompatan:** pemain **tidak** disodori laporan angka. Ia disodori **Chronicle** —
dan orang-orang yang masih hidup **menyebut** apa yang terjadi. *Kehilangan diceritakan oleh
yang ditinggalkan, bukan oleh statistik.*

---

## 5. SUKSESI KERAJAAN

| | Aturan |
|---|---|
| **Pemicu** | kematian penguasa (usia/peristiwa) · kudeta (dipicu Stability, **#59 — masih NOL kode**) · abdikasi · **lompatan waktu** |
| **Kapan dihitung** | **saat login** (#89): bandingkan `chronicle_year` tersimpan vs sekarang → turunkan peristiwa yang lewat |
| **Pewaris** | ditentukan hukum tiap ras/kerajaan (**HUKUM RAS #86** — bukan aturan tunggal; sebagian ras tidak mewariskan lewat darah sama sekali) |
| **Jejak** | penguasa baru **mengingat** perlakuan pemain kepada pendahulunya (reputasi #130 diwariskan **sebagian**, tidak utuh) |
| **Larangan** | tidak ada suksesi yang terjadi **di luar layar tanpa Chronicle** |

⚠ **Ketergantungan yang belum ada:** suksesi berbasis kudeta menuntut **Stability 3-metrik
(#59)** yang **nol kode** dan kini terjadwal **v0.6–0.7**. Sampai itu ada, suksesi hanya
boleh dipicu **usia & peristiwa**, bukan kudeta.

---

## 6. YANG HARUS DIBANGUN (bila spec ini disetujui)

| Potongan | Tempat | Catatan |
|---|---|---|
| `world_birth_unix`, `skip_years`, `chronicle_year` | `WorldState` + save schema **3** | migrasi: save lama → `world_birth_unix` = tanggal save pertama |
| `Chronicle.year()` | `Chronicle` | tahun kronik di samping tanggal WIB — **keduanya tampil**, itu identitas kita |
| `Aging.thresholds(race, age)` | autoload/util baru | tabel §2 sebagai **data JSON**, bukan konstanta kode |
| `TimeSkip.run(years, reason)` | sistem baru | wajib menulis Chronicle **sebelum** state berubah |
| Turunan saat-login | `WorldState.from_save()` | pola sudah ada: `Economy.catch_up()` (#151) |

---

## 6b. PENUAAN PEMAIN — ✅ DIPUTUS (#165, P-AGE=a)

> **Jam kronik menuakan NPC, kerajaan, dan dunia. Karakter PEMAIN hanya menua saat pemain
> MEMILIH.**

| | Aturan |
|---|---|
| **Pemicu penuaan pemain** | **HANYA**: lompatan peristiwa · pensiun (B3) · time-skip naratif |
| **Drift 56-hari** | **TIDAK** berlaku pada pemain. Pemain 1.000 jam **tidak dihukum usia** |
| **Sifatnya** | **keputusan naratif, bukan hukuman waktu** |
| **Dunia?** | tetap menua di sekitarnya — **itulah harga yang terasa**: bukan tubuhmu yang menua, melainkan **orang-orang yang kau kenal** |

*Catatan desain: konsekuensi emosional aturan ini justru lebih tajam daripada penuaan paksa.
Pemain yang menolak melompat akan melihat dunia berjalan tanpanya — dan **itu** Loss & Continuation
(LAW OF ERAS), bukan angka usia di lembar karakter.*

---

## 7. PERTANYAAN TERBUKA — sisa (butuh Direktur)

*(Q1 laju 56 hari & Q3 penuaan pemain: **SUDAH DIPUTUS** #165 — dicoret dari daftar.)*

1. **Tahun awal dunia** (`TAHUN_AWAL`) berapa? Angka tahun Era 1 belum pernah dikunci.
   **Rekomendasi: Era 1 Tahun 1 = saat pemain membuat karakter** — dunia bertahun sejak **kau**
   hadir. Itu Belonging.
2. **Companion menua & mati?** D1 sudah mengunci kematian companion **sebagai peristiwa**.
   Bolehkah **usia** jadi salah satu sebab? **Rekomendasi: ya — tapi HANYA di lompatan, dan
   selalu dengan adegan, tak pernah lewat notifikasi.**
3. **Elf & pewarisan:** pemain elf praktis tak pernah menua melewati satu lompatan. Apakah ia
   kehilangan akses konten pewarisan? **Rekomendasi: tidak — ia mewariskan lewat MURID, bukan
   anak.** Itu justru memperkuat L14 (kesempatan, bukan darah).
4. **Ras yang tak mewariskan lewat darah** (#86 *"no race is monolithic"*) — mana saja? Harus
   diputus **sebelum** suksesi dikodekan.
5. **Tabel §2 = kanon atau tuning?** **Rekomendasi: data JSON (bisa disetel)**, dengan **ambang**
   (dewasa/prima/menua/sepuh) yang **kanon** dan tak boleh diubah diam-diam.
6. **BARU — lahir dari #165:** kalau pemain tak menua tapi **companion menua**, maka companion
   bisa **menjadi tua di samping pemain yang tetap muda**. Apa yang terjadi pada companion yang
   melampaui usia prima? **Rekomendasi: ia TIDAK dibuang — ia berpindah peran** (dari
   bertarung → **mentor**, memberi *kesempatan* pada yang lebih muda, L14). *Companion yang
   dipensiunkan diam-diam karena statnya turun = pengkhianatan terhadap L18.*
