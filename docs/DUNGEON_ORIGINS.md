# ASAL-USUL DUNGEON — pass wajib Dungeon Bible (K7, Decision Log #120)

**Hukum yang dipatuhi (Dungeon Bible, FILE 40):**
> **FIRST LAW — Every Dungeon Has A Reason To Exist.** Dilarang membuat dungeon
> "hanya untuk konten". Uji: *jika pemain bertanya "kenapa tempat ini ada?", dunia
> harus punya jawabannya.*
> **Anti-pola yang DILARANG:** `masuk → bunuh monster → ambil loot → keluar`.
> **DUNGEONS REMEMBER:** tindakan pemain mengubah dungeon — dan dunia.

**Status:** teks kanon (spec). Peti, jebakan, dan ruang rahasia yang sudah dibangun
**tetap** — ia bukan *alasan* dungeon itu ada, ia hanya isi. Yang ditambahkan di sini
adalah **alasan**, **tipe kanon**, dan **konsekuensi** (apa yang berubah di dunia
setelah dungeon disentuh) — untuk diimplementasi bertahap mulai v0.5.

**7 tipe kanon:** I Ancient Ruins · II Living Dungeons · III Raid Dungeons ·
IV World Dungeons · V Hidden Dungeons · VI Companion Dungeons · VII Kingdom Dungeons.

---

## 1. GREENVALE DEPTHS — *Tipe I: Ancient Ruins* (dengan benih Tipe VII)

**Kenapa tempat ini ada:** ini bukan gua alami. Ini **tambang pertama Greenhollow
Valley** — digali para pemukim generasi pertama untuk mencari tembaga, lalu
**ditinggalkan tergesa-gesa** ketika penggalian menembus sesuatu yang bukan batu:
sebuah rongga yang **sudah berbentuk ruangan** sebelum ada yang menggalinya (bertaut
**M7 MISTERI_ABADI** — pembangun reruntuhan yang lebih tua). Balok-balok penyangga
yang membusuk masih ada; palu-palu masih tergeletak di tempat orang menjatuhkannya.

**Kenapa ada monster:** King Slime bukan penjaga — ia **pemulung**. Ia tumbuh besar
justru karena tambang ditinggalkan berisi perbekalan, dan tak ada yang mengusirnya
selama puluhan tahun. Ia menempati rumah yang ditinggalkan manusia.

**Konsekuensi (Dungeons Remember):** membunuh King Slime membuka tambang untuk
dipakai lagi → Greenvale mendapat pasokan tembaga → **harga bijih turun, pandai besi
menguat** (hook Economy Bible). Tapi tanpa pemulung, sisa organik menumpuk: dalam
beberapa musim, **spesies lain pindah masuk**. Dungeon tidak pernah kosong.

**Benih Kingdom Dungeon:** bila diabaikan terlalu lama, koloni slime meluber ke ladang
Greenvale (spec v0.6).

---

## 2. FOOTHILL BARROW (Frostpeak) — *Tipe I: Ancient Ruins* (kuburan)

**Kenapa tempat ini ada:** **kuburan para pendaki** — bukan dibangun sebagai makam,
melainkan **gua tempat orang berteduh dan tidak pernah keluar**. Selama berabad-abad,
pendaki yang gagal turun dibawa ke sini oleh yang selamat, karena tanah beku tak bisa
digali. Nama-nama diukir di dinding. Sebagian ukiran **sudah aus** — dan itu, di dunia
ini, adalah **kematian ketiga** (THREE_DEATHS #269: *Historical Death*).

> ⚖ **KOREKSI #269.** Baris ini dulu berbunyi: *"…adalah kematian kedua (bertaut
> NIRNAMA_BIBLE: Second Death)."* **Salah kematian.** Kematian kedua = *"tidak ada lagi
> yang menyebut namanya"* — mulutnya yang berhenti. Yang terjadi di sini **catatannya yang
> lenyap**: ukiran itu adalah satu-satunya bukti mereka pernah ada, dan ausnya berarti
> *"tidak ada catatan bahwa ia pernah ada"* — **D3, kematian terbesar.**
> Lihat `docs/THREE_DEATHS.md`.

**Kenapa ada monster:** Frost Titan bukan monster yang "muncul di dungeon". Ia adalah
**dingin yang mengeras** — apa yang terjadi bila cukup banyak kematian menumpuk di
satu tempat yang tak pernah mencair. Para tetua Frostpeak menolak menyebutnya monster.

**Konsekuensi:** mengalahkannya **memulihkan nama-nama yang aus** (satu entri Chronicle
per kunjungan berikutnya). Ini dungeon pertama yang mengajarkan tema utama game:
**dilupakan itu lebih buruk daripada mati.**

---

## 3. DESERT BARROW (Reruntuhan Gurun) — *Tipe I: Ancient Ruins* (bertaut Nirnama)

**Kenapa tempat ini ada:** **makam pejabat sebuah kota yang namanya tidak tercatat di
mana pun.** Bukan hilang karena perang — hilang karena **tak ada yang menuliskannya**.
Anubis Warden masih menjaga pintu yang di baliknya tidak ada siapa-siapa: majikannya
sudah lama tak punya nama untuk dijaga.

**Kenapa ada monster:** Warden **tidak tahu bahwa tugasnya sudah tak ada artinya.** Ia
akan tetap berdiri di sana seribu tahun lagi. (Kandidat kuat **NIRNAMA DUNGEON** —
tempat yang pernah disentuh Sang Nirnama; keputusan final menunggu Story pass v0.5.)

**Konsekuensi:** menembus makam memberi pemain **Pecahan Ankh** (material [A] yang
sudah ada) — tapi juga **menghapus penjagaan terakhir atas sebuah nama**. Chronicle
mencatat: *"Sebuah pintu dibuka. Tak ada yang di dalam. Tak ada yang ingat siapa yang
pernah ada."*

---

## 4. GUMMY CAVERN (Candyveil) — *Tipe II: Living Dungeon*

**Kenapa tempat ini ada:** ini **bukan gua — ini organ.** Candyveil tumbuh, dan yang
tumbuh punya rongga. Gua gula ini **membesar dan menyempit sendiri** mengikuti musim
(hook MUSIM v1 #83): peta lama menjadi tidak akurat — persis definisi **Living Dungeon**.

**Kenapa ada monster:** Gummy Titan bukan penghuni; ia **bagian dari gua itu sendiri**
yang memisahkan diri. Membunuhnya melukai gua.

**Konsekuensi:** setiap kali Titan dikalahkan, gua **menyembuhkan diri dengan bentuk
berbeda** — lorong berpindah. Sugar Queen mengetahui ini dan **tidak keberatan**;
ia hanya ingin tahu berapa lama pemain butuh untuk menyadarinya. *(Nada gelap-di-balik-
manis, B16.)*

---

## 5. ZEPHYR SPIRE (Storm Island) — *Tipe I → kandidat Tipe IV (World Dungeon)*

**Kenapa tempat ini ada:** menara ini **tidak dibangun untuk badai — badailah yang
datang kepadanya.** Ia lebih tua dari Storm Island itu sendiri; pulaunya tumbuh di
sekelilingnya. Para Astrolog menduga menara ini **alat**, bukan bangunan: sesuatu yang
dipasang untuk **mengukur** langit, oleh seseorang yang perlu mengukur langit.

**Kenapa ada monster:** Storm Sovereign adalah **hasil**, bukan penghuni: petir yang
terlalu lama terkurung dalam satu bentuk. Ia tidak menjaga apa pun. Ia hanya **tidak
bisa pergi**.

**Konsekuensi:** memuncaki menara membuka pandangan ke **retakan di langit** yang tidak
bisa dijelaskan siapa pun — benih **The Hollow Sky** (World Dungeon kanon, tipe IV;
konten v0.8 CELESTIA & CRISIS). Pemain boleh melihatnya sekarang. Ia **tidak boleh
memasukinya** selama bertahun-tahun.

---

## Yang BELUM terwakili dari 7 tipe kanon (jujur, untuk roadbook)

| Tipe | Status | Rencana |
|---|---|---|
| I Ancient Ruins | ✅ 3 dungeon | — |
| II Living Dungeon | ✅ 1 (Gummy Cavern) | perilaku "peta berubah" = v0.6 |
| III **Raid Dungeon** | ❌ belum ada | butuh sistem entourage/rekrutan (v0.6 HEARTH) |
| IV **World Dungeon** | ⚠ benih (The Hollow Sky terlihat dari Zephyr Spire) | v0.8 |
| V **Hidden Dungeon** | ⚠ sebagian (ruang rahasia dalam dungeon, #85) — belum dungeon utuh yang tersembunyi | v0.5–0.6 |
| VI **Companion Dungeon** | ❌ belum ada | **gerbang B17** (butuh Companion Bible 50/50) |
| VII **Kingdom Dungeon** | ❌ belum ada (benih di Greenvale Depths) | v0.6 (butuh Domain/Kingdom) |
