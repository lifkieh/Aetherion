# IMPLEMENTATION ROADBOOK — Bible → Game

**Aturan yang dipatuhi:** **tidak menciptakan fase baru** — hanya mengisi fase yang
sudah ada (v0.5 → v1.0). **Gerbang dihormati: B17 Companion Bible 10/50 tetap menahan
v0.5.** Semua yang bergantung pada **K1 (skala waktu, #123)** ditandai ⏳ dan **tidak
boleh dibangun** sebelum owner menjawab.

**Kondisi awal:** Fase 0 (v0.4.x) **tuntas** — 753 test, 0 gagal. Yang sudah berdiri:
combat, 10 class, 28 pohon (kini ber-domain), profesi, taming, crafting/enchant,
Rumah Lelang, musim, rasi, dungeon (peti/rahasia/jebakan/parallax), jadwal NPC,
Chronicle (benih), cutscene engine, peta, lokalisasi, gamepad.

---

## v0.5 — **"STORY & SOUL: FONDASI"** (#202)
**Gerbang:** ✅ B18 Nirnama Bible (#114) · ⚠ **B17 Companion Bible 15/50 — masih menahan**

> ### ⚖ BENTUK v0.5 DIPUTUS (#202): **FONDASI, BUKAN ACT 1 UTUH**
> **Jujur pada dependensi, bukan berpura-pura.** Act 1 **tidak bisa** selesai di v0.5 — dua
> tulang punggungnya belum lahir:
>
> | Yang dituntut §IX | Butuh | Ada? |
> |---|---|---|
> | **Klimaks: bulan retak** | **Celestial Crisis (B5)** | ❌ **v0.8** |
> | **"Satu NPC yang kau kenal MELUPAKANMU"** | **memori NPC (World Remembers)** | ❌ **v0.6** |
>
> **Maka v0.5 mengirim FASE 1–2 saja** — gejala, bukan klimaks. **Dan itu bukan kompromi: itu
> BENTUK YANG BENAR.** Act 1 dirilis **bertahap v0.5 → v0.6 → v0.8**, *"seperti dunia yang
> perlahan memutih."* **Pemain tidak akan merasa dipotong; ia akan merasa sedang ditulari.**

### 🥇 PRIORITAS #1 v0.5 — **LAHIRKAN ASHBROOK** (status beku DIBUKA)

**Alasannya keras:** **Merrit Fane (#011)** — patokan companion yang Direktur tulis sendiri,
**companion PEMBUKA TESIS GAME** — tinggal di Ashbrook. Begitu pula **Arlen Vale (#001)**.
**Selama Ashbrook tidak ada, tokoh pertama yang memperkenalkan tesis game TIDAK BISA DITEMUI.**

| Yang dibangun | Catatan |
|---|---|
| **Ashbrook** = desa kecil (~40 jiwa) dekat Greenvale, mulut **Greenhollow Valley** (Eldoria) | wilayah **main**, bukan kulit; masuk `regions.json` |
| **Rumah pos + rumah singgah Merrit** (lampu yang menyala di jendela **siang hari**) | jangkar tema |
| **5 NPC berkepribadian** (Hukum NPC Aneh #78) | 1 Aneh · 1 Misterius · 1 Lucu · 1 Tragis · 1 Tak-masuk-akal |
| Band level | **Lv 1–12** (bersanding Greenvale; desa **awal**, bukan lanjutan) |
| **Konsisten HUKUM PETA (#204)** | **titik-spawn sendiri** + **terhubung JALAN nyata ke Greenvale** (bisa ditempuh berjalan kaki; kunjungan pertama **wajib** jalan sendiri) |
| **Kanon Kingdom Bible (#203)** | Ashbrook ⊂ **VALENFORD** (*The Kingdom of Open Roads*) · **aroma kota: roti panggang · kayu basah · sungai** · NPC ikonik **Old Bram · Lyra · Spoon Man** · **rumor White Stag** ⚠ **populasi = konflik K-2, menunggu Direktur** |

### Act 1 — **FASE 1 & 2 SAJA** (dependensi eksplisit)

| Fase | Isi | Prasyarat | Fase rilis |
|---|---|---|---|
| **FASE 1 — GEJALA** *(jam 1–30)* | **wilayah MEMUTIH** (mesin Roh Hutan **dibalik** — ✅ sudah ada) · **rumor** tempat yang memucat (✅ sudah ada, **boleh salah**) · **NPC tergagap** saat menyebut nama · **YANG TERHAPUS (The Erased)** = musuh baru (siluet pucat tanpa wajah) · **Nirnama Cult** memuja *"Keheningan yang Baik"* | Roh Hutan ✅ · rumor ✅ · StatusFx ✅ · **monster baru** (data) | **✅ v0.5** |
| **FASE 2 — PENYINTAS BERSUARA** *(jam 30–60)* | **Old Elder** memberi kesaksian · **Silent One** MENOLAK bicara · **Underground Elite** MENJUAL info · **satu pertemuan tanpa nama**: pengelana tua lembut yang bertanya tentang apa yang kau bangun — **tak diungkap siapa** | Cutscene ✅ · dialog ✅ · **3 tokoh baru** (gelombang 3) | **✅ v0.5** |
| **FASE 3a — HOROR PERSONAL** | **satu NPC yang kau kenal MELUPAKANMU** | 🔴 **memori NPC (World Remembers)** | **v0.6** |
| **FASE 3b — KLIMAKS** | **bulan retak** → Nirnama berdiri terungkap; **pengelana tua itu adalah dia** | 🔴 **Celestial Crisis (B5)** | **v0.8** |

⚠ **Reveal nama asli = BUKAN Act 1.** Itu harta Act 2. *(Rahasia produksi, #144.)*

### Benih yang ditanam v0.5 (dipanen kelak)

| Benih | Aturan |
|---|---|
| **OPENING KANON final** — **Pegasus = First Mystery** (*"Carilah aku."*) + **anak serigala terluka** = monster pertama (boleh dibantu / diabaikan / **dibunuh** — semuanya sah) | **Pegasus TIDAK menandai pemain sebagai terpilih** (NO DESTINY). **Arti "Carilah aku" HARAM DIJAWAB** (MISTERI_ABADI) |
| **THE NAMELESS DOOR** — **TERPASANG di dunia, TIDAK terpecahkan** | Pintunya ada. **Apa yang di baliknya tetap milik kegelapan.** *Ia berdiri di sana selama bertahun-tahun sampai seseorang memutuskan ia penting.* |
| **Benih Chronicle cerita** — entri fragmen/rusak; % penyelesaian **disembunyikan** | Chronicle = **tokoh utama kedua** (#168) |

---

**Sisa antrean v0.5 (tetap):**

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| **Companion Bible 50/50** (dokumen) | Companion Philosophy (05), Companion Bible (13, 41) | — | 2–3 sesi penulisan **bersama Direktur** | Kategori/kuota sudah ada; butuh 40 tokoh |
| **Opening kanon** (rework intro): pemain jatuh → **anak serigala terluka** (First Monster) → **Pegasus = First Mystery** | Early Game (42) + #118 | Cutscene engine ✅ | 0,5 sesi | — |
| 🔴 **WONDER TIER-LEGENDA (Piagam, DIKEMBALIKAN — #155)**: **The Nameless Door** · **The Forgotten Musician** · **The Sleeping Giant** | **PIAGAM Bag.0** (tier-legenda pertama = v0.5) | Rumor ✅, Cutscene ✅ | 1,5 sesi | **Isi Piagam — bukan pilihan agent** |
| **First Mystery lokal** ("lonceng tengah malam yang tak punya lonceng") + **First Legend** ("Bukit Kabut") | Early Game (42), Mystery (51) | Rumor system ✅ | 0,5 sesi | **TAMBAHAN, bukan pengganti** (#155): sempat menggantikan tiga Wonder Piagam secara diam-diam — pelanggaran aturan-B, dicatat di GAP_AUDIT |
| **SOFT-CAP EXP (#69/#152)** — ✅ **SUDAH DIBANGUN** (band wilayah = data kanon; EXP menciut brutal di luar band; UI jujur) | K2 (#69) | — | ✅ selesai | Dieksekusi #152 |
| **CURSE (status ke-6) + PEN (penetration)** | GDD §6.3/§6.4 | StatusFx ✅ | 0,7 sesi | Ditugaskan Designer (#156) |
| **20 RESEP FUSION SISA** (15/35 → 35/35) | GDD §5.3 | Fusion ✅ | 0,5 sesi | Ditugaskan Designer (#156) — Grimoire butuh amunisi |
| **STAR WHALE ENTITY** (tubuhnya, bukan cuma perutnya) — **wajib tameable** (B9/#54) | B9 (#54), Skenario "Belly of the Star Whale" | Taming ✅ | 0,7 sesi | Ditugaskan Designer (#156) |
| **GUARD ARTEFAK (#115)** — kode + test yang MENOLAK `enchant_level`/grade pada artefak | K2 (#115) | gear_meta ✅ | 0,3 sesi | Utang murah: kunci **sebelum** artefak pertama lahir |
| **PROGRESSION NON-LEVEL YANG TERLIHAT (#152b)** — reputasi tampil · milestone profesi dirayakan · hitungan Chronicle di HUD-lite | World Bible ("level bukan sumbu kekuatan") | reputasi slot ✅ | 1 sesi | Requirement Designer (#152): kalau level bukan sumbunya, sumbunya harus **punya angka yang terlihat naik** |
| **Companion v1**: 3–5 tokoh Tier-S hidup di dunia; **rekrutmen BUKAN menu** (diyakinkan lewat perbuatan); Life Quest; **Argument System** (boleh tak setuju, boleh pergi) | Companion (41), Recruitment (35) | **B17 50/50** | 1,5–2 sesi | Siapa **First Companion** (wajib **bukan** yang terkuat) |
| **Act 1 Nirnama — FASE 1–2 SAJA (#202)**: gejala penghapusan — wilayah memutih (mesin Forest Spirit dibalik), NPC tergagap, **The Erased** (musuh baru), satu pertemuan tanpa nama | NIRNAMA_BIBLE §VI, §IX | Cutscene ✅, StatusFx ✅ | 1,5 sesi | Sumbu konflik final (**Q18**) |
| **Chronicle: entri fragmen/rusak** + sembunyikan % penyelesaian | Mystery (51) b.1508/1664 | Chronicle ✅ | 0,3 sesi | **C7** |
| **Hidden Dungeon** pertama (dungeon utuh yang tersembunyi) + asal-usul 5 dungeon masuk ke dalam game (jurnal, artefak bercerita) | Dungeon (40) + `DUNGEON_ORIGINS.md` | — | 1 sesi | — |
| **Dual Class** (spec → implementasi) | Class & Skill Tree (45) + #117 | — | 1 sesi | Sudah diputus (#117) |
| **NPC DEPTH PIPELINE** (#162) — pool dialog kontekstual **8–12 varian/NPC/konteks, dwibahasa sejak lahir** (8 tag konteks, **bukan** perkalian silang); draft Life Event chain (**draft, bukan kanon**); reaksi bencana/keajaiban & gosip lebih kaya | `docs/NPC_DEPTH_PIPELINE.md` | ⚠ **#164 harus diputus dulu** (inline dwibahasa vs Loc) | 2–3 sesi | Resmi (#162); **3 gerbang wajib: kanon · test rahasia · review** |
| **LOKALISASI GELOMBANG 2** (#146): **nama item · nama monster · lore/Pedia → EN**; teks cerita v0.5 **ditulis dwibahasa sejak lahir** | B15 (#62/#100) | Loc ✅ | 1 sesi | Sudah diputus (#146) |
| **Rename**: fusi elemen tetap *Fusion*; penyatuan pemain–monster = **Sinkronisasi** | World Bible b.3798 | — | 0,1 sesi | **C4 / Q6** |

---

## v0.6 — HEARTH & LEGACY
**Tema:** dunia yang hidup tanpa pemain + markas yang tumbuh.

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| 🔴 **ACT 1 FASE 3a — HOROR PERSONAL** (#202): **satu NPC yang pemain kenal MELUPAKANNYA** | NIRNAMA_BIBLE §IX | 🔴 **memori NPC (World Remembers v1)** — dibangun di fase ini juga | 0,5 sesi | **Dependensi keras** — mustahil sebelum memori NPC ada |
| 🔴 **MENTOR SYSTEM** (#182) — siklus **Companion → Veteran → Mentor → Retired → Death → Legacy**; di fase Mentor: **berhenti garis depan**, melatih generasi baru, **pengaruh & pengetahuan NAIK** (L14). **Memensiunkan karena stat turun = DILARANG** (L18/T6) | MEJA-3 + `NPC_DEPTH_LAWS.md` | personality ✅ · TIME_LEGACY_SPEC (#165) | 1,5 sesi | **Kanon** — jawaban resmi atas T6 |
| 🔴 **DELAPAN HUKUM KEDALAMAN NPC** (#170) — Potential=??? · Hidden Talent · **Opportunity (pemain = sumber kesempatan terbesar)** · Luck · Mental Health · Growth Rate · Training Philosophy · **Ordinary People** | `docs/NPC_DEPTH_LAWS.md` + L14–L18 | personality engine ✅ (5 lapis) | 2 sesi | **KANON** — mengikat SEMUA sistem NPC v0.6 |
| **Living HQ / Domain 5→7 tahap** (tambah Kingdom Capital & Great Civilization) | World Bible b.544, B1 (#46) | — | 2 sesi | **C15** (setuju 7 tahap?) |
| **5 Atribut Kerajaan** (Prosperity/Stability/Loyalty/Security/**Ecology**) menggantikan Stability 3-metrik | World Bible b.814 | — | 1 sesi | 🔴 **C3 / Q5** |
| **ECOLOGY v1**: populasi terbatas per wilayah, over-hunting → predator lapar → menyerang desa (perluasan mesin Forest Spirit) | World Bible b.933 | 5 atribut | 1,5 sesi | 🔴 **C3 / Q5** |
| **Reputasi & Faksi v1**: reputasi **lokal** (6 tingkat), **Influence 6 sumbu**, relasi faksi, reputasi **tidak universal** | Faction 01–08 (54–61) | **Reserve slot data (lakukan lebih awal!)** | 2–3 sesi | **C17 / Q27** |
| **World Remembers v1**: memori NPC, kematian & **Replacement Rule**, suksesi pemimpin | World Bible b.288/5704, Faction 08 | Reputasi | 2 sesi | **C1/C2/Q3/Q4** |
| **Chronicle menerima entri NPC/dunia** (bukan hanya pemain) | World Bible b.1097 | Reputasi | 0,5 sesi | **C8** |
| **BLACK MARKET** (barang > tier A, artefak ilegal, informasi) — terhubung Netherdeep | Faction 03 (56) + #121 | Reputasi | 1 sesi | Sudah diputus (#121) |
| **Companion Dungeon** (tipe VI) + **Raid Dungeon** (tipe III, butuh entourage) | Dungeon (40) | Companion v1, rekrutan | 1,5 sesi | — |
| **LIFE EVENTS + GROWTH ENGINE** (mesin kepribadian penuh, #139): opportunity events (**pemain memberi kesempatan → takdir berubah**, L14), growth tick lewat PERISTIWA, moral drift (kejatuhan & penebusan), mental_state memengaruhi keputusan hidup NPC | Personality (#136–#138), Recruitment (35) | Profil ✅ (sudah ditanam) | 2 sesi | Sudah diputus (#139) |
| **Rune / Runesmith**, profesi bible (Hunter, Tailor, Farmer, Rancher, Merchant, Scholar, Explorer) | Profession (46) + #122 | — | 1,5 sesi | Cook tetap (#122) |
| ⏳ **World history ledger** (peristiwa ireversibel offline) | World Bible b.5704 | **K1** | — | ⏳ **K1 #123** |

---

## v0.7 — HORIZON (Emberfall · Kerajaan Thalassar · Wildhearth)

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| 🔴 **PETA DUNIA BERSKALA (#204)** — dunia BESAR · **jalan nyata** antar-kota/kerajaan (bisa ditempuh **berjalan kaki**) · **titik fast-travel dibuka seiring penjelajahan** (⛔ **perbesar Gerbang Penjelajah #43 — DILARANG bangun sistem travel kedua**) · world-map dua-tingkat (v0.4.3) **diperluas** | Kingdom Bible (#203) · visi Direktur | Gerbang Penjelajah ✅ · world map ✅ | 2–3 sesi | **HUKUM: "jalan di antara kota harus HIDUP"** — perjalanan = tempat kejadian (encounter · NPC pengembara · rahasia pinggir jalan · cuaca), **bukan ruang kosong** |
| **Benua & budaya baru**: Azhur (Thalassar/Tidekin), Nethrak (Wildhearth/Beastfolk), Sylvara (Elf/Ancient Jungle) | World Bible, Ras (#86), #110 | Aset (lihat MANIFEST) | 3–4 sesi | Fairy Realm → benua mana? |
| **CUACA PER-WILAYAH** (#147): cuaca global dipecah per wilayah/benua — badai di laut ≠ badai di gurun | v0.1 §4.3 | Wilayah baru | 0,5 sesi | Sudah diputus (#147) |
| **REQUIREMENT DESAIN DUNGEON** (#148): dungeon BARU **wajib mengisi tipe kanon yang masih kosong lebih dulu** — **Raid (III)** · **Companion (VI)** · **Kingdom (VII)** — sebelum menambah Ancient Ruins ke-4 | Dungeon Bible (40), `DUNGEON_ORIGINS.md` | Companion v1 (VI), Domain (VII), entourage (III) | — | Sudah diputus (#148) |
| **Ras playable bertambah** (Elf ← Sylvara, Tidekin ← Azhur) — **ras = budaya, bukan stat** | RAS_KANON (#86) | CharGen | 1 sesi | — |
| **Monster multi-elemen** (1–3 elemen; 4+ langka) | Monster (32), Taming (44) + #122 | — | 1 sesi | — |
| **Monster cerdas** (tier 4–5): tidak masuk tabel loot; taming lewat **persetujuan**; membunuhnya berkonsekuensi | Faction 06, Taming (44) | Reputasi | 1,5 sesi | **C18/C19 / Q23/Q24** |
| **Naga Kuno (10 spesies × 5)**: **jalur Pact — mereka memilih**, keluar dari pipeline orb | Dragon (52) | Reputasi, monster cerdas | 2 sesi | **C5 / Q7** |
| ⏳ **Naval / laut** (Leviathan, kapal) | dirujuk, **Naval Bible belum ada** | Bible belum lahir | — | **Q14** |

---

## v0.8 — CELESTIA & CRISIS

| Sistem | Bible sumber | Prasyarat | Estimasi | Keputusan owner |
|---|---|---|---|---|
| 🔴 **ACT 1 FASE 3b — KLIMAKS: BULAN RETAK** (#202): Sang Nirnama berdiri terungkap — **dan pengelana tua yang kau temui sejak Act 1 adalah dia** | NIRNAMA_BIBLE §IX | 🔴 **Celestial Crisis (B5)** | 1 sesi | **Klimaks Act 1 dipindah ke sini** — jujur pada dependensi, bukan berpura-pura |
| **Celestial Crisis** (bulan retak / supernova) — B5 | Nirnama Bible, GDD v0.3 | Act 1 | 2 sesi | — |
| **World Dungeon** (tipe IV: *The Hollow Sky* — sudah terlihat dari Zephyr Spire) | Dungeon (40), DUNGEON_ORIGINS | Raid | 2 sesi | — |
| **Great Monsters** (Leviathan/Titan/Phoenix/World Beast/Ancient Predator/Void Colossus) — **peristiwa dunia, bukan boss** | Great Monster (53) | Ekologi | 2–3 sesi | — |
| **Religion v1** (Gereja, Holy Order, Inquisitor, mukjizat ULTRA-langka) + rename `MiracleSystem` → **Wonder/Omen** | Religion (49) + **DIVINE_BIBLE (#140–#143)** | ✅ nama dewa **sudah dikunci** | 1,5 sesi | Butuh sesi penulisan: kepribadian/agenda/gereja tiap dewa |
| **Heirs of Nothingness** (5 kelompok pewaris kehampaan) | Nirnama Bible part 4 (69) | Act 1 | 1,5 sesi | — |

---

## v0.9 — GENERATION
⏳ **SELURUH fase ini terkunci di belakang K1 (#123).** Tanpa keputusan skala waktu,
penuaan/generasi/suksesi **tidak akan pernah terpicu** (Tahun 120 = ~18,5 tahun nyata).

| Sistem | Bible sumber | Prasyarat | Keputusan owner |
|---|---|---|---|
| Aging, generasi, **Succession** (pewaris = individu baru, bukan salinan) | World Bible (Time), Time & Legacy (36) | **K1** | ⏳ 🔴 **K1 #123** |
| Legacy Family (B3), pernikahan pemain (P3 #88) | — | **K1** | ⏳ |
| Kurva level rebase + loadout penuh (K1/K2 lama: #68/#69) | — | — | — |
| **Catatan:** roadmap owner menaruh Multi-Generation di **Tier E (pasca-rilis)** — kita di v0.9 | `game design roadmap.txt` | — | **C12 / Q10** |

---

## v1.0 — RILIS

### ENDGAME: **HYBRID FINAL JUDGE** — dikunci (#134, D2)

**Hukum bible dipertahankan penuh: Sang Nirnama TIDAK mati di tangan pemain.**
Tapi klimaksnya **tetap pertarungan gameplay besar** — hanya saja objektifnya dibalik:

| Fase | Isi | Objektif |
|---|---|---|
| **1. Badai Penghapusan** | *Expedition encounter*: gelombang **Yang Terhapus** + wilayah yang mulai memutih | **BERTAHAN** |
| **2. Melindungi** | Domain-mu, companion-mu, halaman Chronicle-mu **dijadikan objektif hidup** — merekalah yang bisa hilang, bukan HP musuh | **LINDUNGI apa yang kau bangun** |
| **3. PENGHAKIMAN** | Dunia menjawab pertanyaannya **lewat bukti**: Chronicle yang pulih, orang-orang yang masih mengingatmu, **save file-mu sebagai argumen** | **JAWAB** |

**Kemenangan bukan membunuh.** Level tanpa batas tak pernah jadi jawaban — karena
pertanyaannya bukan pertanyaan tempur. **Nasib akhir Nirnama (pergi / tinggal / berubah
/ menunggu era berikutnya) SENGAJA TIDAK DIKUNCI** — itu keputusan penulisan Act 2.

- **5 ENDING** (Dawn / **Final Silence** / Last Sky / Broken Answer / **The World Remembers**) + **hukum: tidak ada ending sempurna**.
  - ⚖ **RATIFIKASI D11 (#176): "THE FINAL SILENCE" = DUNIA *LUPA*, BUKAN DUNIA BERAKHIR.**
    Dunia **terus ada** — tetapi **tak seorang pun mengingat apa yang pernah dibangun**.
    **LAW OF ERAS (#75b) UTUH:** tidak ada ending-dunia; yang berakhir adalah **era & ingatan**.
    *Ini ending paling gelap yang kita punya — dan ia gelap **tanpa** satu pun ledakan.*
- Butuh **sistem penilaian warisan** (metrik: Chronicle, Domain, companion yang hidup, orang yang mengingat).
- 10 checklist experience hijau → demo publik.

### KEMATIAN & REVIVE — dikunci (#133, D1)
Berlaku sejak sistem companion lahir (v0.5+):
- **1× seumur hidup**, per NPC/companion bernama (termasuk 50 Great Companion).
- **Tubuh harus utuh/ditemukan** — hancur/hilang/dilupakan = **mustahil selamanya**.
- **Mati wajar karena usia = TIDAK BISA direvive** (*kematian karena waktu adalah hukum
  dunia, bukan luka*). Mati tragis/dibunuh/kecelakaan = jalur **per-kasus, ditulis
  tangan, selalu sulit**.
- **Harga = INGATAN**, tanpa kecuali. **Kematian kedua = final mutlak.**

---

## HARGA KEMATIAN PEMAIN — BEREVOLUSI PER ACT (MEJA-2, #181 · spec)

> **Hukumannya tumbuh mengikuti PEMAHAMAN PEMAIN ATAS KEHILANGAN — bukan mengikuti level.**

| Act | Harga | Kenapa |
|---|---|---|
| **Act 1** *(v0.5)* | **MEMORY FADE murni** — harga **ingatan** / serpihan Chronicle. **Tanpa gold. Tanpa item.** | **Edukatif**: pemain diajari *apa* yang dipertaruhkan dunia ini (#119, K6 — tema Memori). Uang tidak mengajarkan apa-apa di sini. |
| **Act 2** | + **10–30% currency** | Mulai terasa. |
| **Act 3** | + **30–50% currency** + **1 item acak jatuh** *(bisa diambil kembali di titik mati)* | Kehilangan menjadi **berwujud**. |
| **Act 4** | + **50% currency** + item jatuh + **DURABILITY SCAR** (**−10% max durability** pada item yang jatuh) | **Luka permanen kecil.** Dunia mulai menyimpan bekas. |

> ### 🔗 **DURABILITY (#29) = PRASYARAT KERAS ACT 4 — RESMI (#188)**
> **Bukan lagi ditunda-sadar.** Tanpa durability, **Durability Scar mustahil**.
> **Jadwal: durability & repair dibangun SEBELUM Act 4 dimulai** — ia adalah **gerbang**, bukan
> pelengkap. Janji yang menggantung sejak #29 (dan nyaris mati diam-diam, REPORT-06 §A) **akhirnya
> punya tanggal yang mengikat.**

*Semua = spec; dibangun **bertahap seiring Act lahir**. **Act 1 = v0.5.***

---

## Yang harus dilakukan LEBIH AWAL daripada fasenya (utang murah)

1. **Reserve slot data reputasi/faksi di `PlayerData`** (C17) — menambahkannya setelah save beredar jauh lebih mahal.
2. **Reserve format entri Chronicle** untuk entri NPC/dunia & fragmen (C7/C8).
3. **Rename istilah Sinkronisasi** (C4) sebelum kata "fusion" makin tertanam.
4. **Whitelist non-orb** untuk Naga Kuno/Great Monster (C5/C18) — belum ada satu pun di game, jadi **gratis** dikunci sekarang.
5. **Guard artefak (#115)** — kunci **sekarang**, selagi belum ada satu artefak pun. Setelah artefak pertama lahir sebagai `type: "weapon"` biasa, kanon sudah bocor diam-diam.

---

## YANG SEMPAT HILANG DARI ROADBOOK — dikembalikan (#156)

Tiga janji ini hidup di TRACKBACK/ledger tetapi **tidak punya satu baris pun di dokumen
eksekusi**. Itulah cara sebuah janji mati tanpa ada yang memutuskan membunuhnya.

| Janji | Sumber | Fase | Catatan |
|---|---|---|---|
| **10 CAPSTONE per class** (Worldbreaker, Astral Genesis, Throne of Souls, …) | #57 / #116 | **v0.9** (bersama rebase kurva) | Kode hari ini hanya punya test yang **MELARANG** capstone menempel di pohon — tak ada yang **membuatnya**. 6 capstone sisa belum bernama (butuh Direktur, D-butir 3). |
| **Sistem Rival** | #38b | **v0.6** (World Remembers v1) | Rival = memori dunia yang berjalan; tempatnya di sana. |
| **B7 Perayaan Legacy & festival** | #52 / #81 | **v0.6** | Chronicle hari ini **mencatat** tanpa pernah **merayakan**. Legacy yang tak dirayakan cuma basis data. |

---

## BACKLOG PENULISAN BIBLE — meja Direktur + Designer (#132)

**Jadwal: PASCA-B17** — agar tidak menggeser gerbang v0.5 (#128).

| Dokumen | Lapisan | Kenapa dibutuhkan |
|---|---|---|
| **Mythology Bible** | Tier S/A | Legenda, dongeng, ramalan — *"dunia hidup tidak hanya dibangun oleh fakta, tapi oleh cerita yang dipercaya"* |
| **Language Bible** | Tier A | Bahasa kuno, bahasa naga, simbol — dibutuhkan **Knowledge Gates** (pintu yang dibuka pemahaman, bukan kunci) |
| **Emotion Bible** | Tier A+ | Apa yang harus **dirasakan** pemain: Wonder → Belonging → Responsibility → Loss → Legacy |
| **Mystery Bible** | Tier A | Daftar rahasia terbesar dunia — melengkapi `MISTERI_ABADI.md` |
| **Divine Bible** — *lanjutan* | Tier S | ✅ **seed selesai** (#143: nama, domain, hukum gema). Sisa: **kepribadian · agenda · gereja** tiap dewa + apakah ada dewa bawahan + relasi Lima dengan 17 elemen |
| **Ancient History Bible** | Tier S | Bertaut **M8** (#126) — Kebohongan Sejarah Terbesar |
| **Player Motivation / Retention / Endgame / Content Longevity / Emotional Design** | **Tier A+** | Lapisan meta yang **belum pernah kita sentuh**: kenapa pemain masih main di jam ke-500? Apa yang dilakukan setelah semuanya selesai? |
| **Multiplayer Bible** | Tier A | Boleh **ditulis** sebagai spec pasca-v1.0; **implementasi tetap beku** (B14 gratis-penuh, daftar tahan MMO) |
