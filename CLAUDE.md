# CLAUDE.md — Hukum Kerja Proyek Aetherion

Dokumen ini dibaca setiap sesi. Isinya **gerbang review**, bukan katalog fitur.
Katalog & status ada di `PLAN_LEDGER.md` (dokumen induk).

## Hierarki dokumen
`PLAN_LEDGER.md` > `docs/MASTER_BLUEPRINT_AETHERION.md` (v1.0.1) >
`MASTER_IMPROVEMENT_PLAN` > `STATUS.md`. Untuk roadmap: PLAN_LEDGER > TRACKBACK >
MASTER_PLAN. Konsepsi mentah Direktur: `docs/Aetherion_blueprint_reasoning_and_design.txt`.

## Aturan permanen ledger
(a) Setiap arahan owner baru = baris Decision Log **sebelum** dikerjakan.
(b) Setiap penyimpangan agent dari GDD/blueprint = baris + alasan.
(c) Baca ledger di awal sesi; update kedua bagiannya di akhir ronde.
(d) Implementasi yang bertentangan dengan ledger tanpa baris keputusan = **BUG DESAIN** → `GAP_AUDIT.md`.
(e) Ledger di-commit & di-push seperti kode.

---

## TESIS RESMI AETHERION (#168)

> ### **"Sang Nirnama percaya segala sesuatu akan hilang.**
> ### **Aetherion percaya sesuatu yang hilang tetap bermakna — karena ia pernah ada."**

**Sang Nirnama adalah sebuah PERTANYAAN, bukan protagonis.** *Tidak ada individu yang lebih
penting daripada dunia — termasuk dia, dan termasuk PEMAIN* (NO DESTINY tetap terkunci).
Pertanyaannya: **"apakah dunia ini layak diteruskan?"** — dan **seluruh save file pemain adalah
jawabannya**. Konflik sentral bukan pemain-vs-Nirnama, melainkan **INGIN-LUPA vs MENOLAK-LUPA**;
**Chronicle adalah tokoh utama kedua**. Ending: **tak ada yang menang, tak ada yang kalah** —
dunia memilih jawaban yang berbeda. *(Kitab: `docs/NIRNAMA_BIBLE_PUBLIC.md` **v2.1**.)*

**Uji tulis:** setiap fitur boleh ditanya *"memperkuat tesis ini, atau menumpulkannya?"*

## HUKUM DIREKTUR #1 — Gerbang Pilar (E1, Decision Log #75)

> **Setiap fitur baru wajib memperkuat minimal satu dari empat pilar. Bila tidak
> ada satu pun yang dikuatkan — fitur itu DITOLAK.**

| Pilar | Pertanyaan gerbang |
|---|---|
| **WONDER** | Apakah ia menyimpan rahasia, atau membuat pemain bertanya-tanya? |
| **BELONGING** | Apakah ia membuat dunia terasa dihuni / pemain terasa punya tempat? |
| **STEWARDSHIP** | Apakah ia memberi pilihan ber-trade-off yang direspons dunia? |
| **LEGACY** | Apakah ia meninggalkan jejak yang diingat dunia? |

Cara pakai: sebelum menulis kode fitur baru, tulis **satu kalimat** di Decision Log
yang menyebut pilar mana yang dikuatkan dan bagaimana. Fitur yang hanya "menambah
angka" (stat, konten datar, sistem demi sistem) tidak lolos gerbang.

## HUKUM PEMELIHARAAN WONDER (E4, #76)

10% dunia **tidak pernah dijelaskan, selamanya**. Daftarnya: `docs/MISTERI_ABADI.md`.
Sebelum menulis lore/dialog/fitur yang menyentuh butir di daftar itu: **berhenti**.
Boleh menambah isyarat & kesaksian yang bertentangan; **tidak boleh** menambah
konfirmasi. Kejelasan terasa seperti kemajuan, padahal sering merupakan kehilangan.
Bila sebuah fitur menuntut jawaban dari misteri abadi → **fitur itu yang diubah**.

## HUKUM QUEST (E8, #80)

> **Setiap quest harus MENGUBAH sesuatu.** Kill/collect tanpa konteks manusia
> **DILARANG** menjadi inti quest.

Tiap quest wajib punya field `quest_type` (taksonomi): `Need` · `Dream` · `Fear` ·
`Ambition` · `Memory` · `Legacy` · `Hidden` · `Chronicle` · `Myth` · `World` · `Era`.
Bila sebuah quest tak bisa diberi salah satu label itu tanpa dipaksakan, quest itu
belum punya alasan manusiawi untuk ada — perbaiki, jangan kirim.
(Catatan: field `type` di `quests.json` sudah dipakai untuk MEKANIK (kill/gather/
craft/tame), karena itu taksonomi memakai nama field `quest_type`.)

## HUKUM NPC ANEH (E6, #78)

Tiap kota/desa wajib punya **minimal 5 NPC berkepribadian**: 1 Aneh, 1 Misterius,
1 Lucu, 1 Tragis, 1 Tak-masuk-akal (`data/town_npcs.json`; dijaga oleh test
`_test_town_folk`). Mereka tidak memberi quest dan tidak menjelaskan dunia —
mereka membuatnya terasa dihuni. ~10% adalah **Oddwalker**: menyimpan sesuatu yang
**tidak pernah dibayar tuntas**. Itu bukan utang desain; itu benih.

## HUKUM RAS (P1, #86)

**"Races Are Cultures, Not Stats"** — ras TIDAK PERNAH memberi bonus stat. Ia memberi
budaya, sejarah, hukum, prasangka, dan cara dunia memperlakukanmu.
**"No Race Is Monolithic"** — tiap ras punya perpecahan internal; tak ada ras yang
bersuara satu. Delapan Ras Besar: Human · Elf · Dryad · Dwarf · Beastfolk · Astralborn ·
Tidekin · Shadeborn.

## HUKUM PENULISAN ENVIRONMENTAL (#210) — **"TUNJUKKAN, JANGAN PAPAN-INFORMASIKAN"**

> **Sejarah & keadaan sebuah tempat diceritakan lewat DETAIL YANG PEMAIN LIHAT — tak pernah lewat
> papan info atau teks eksposisi.**

**Contoh kanon (Ashbrook, #206):** **jembatan yang terlalu lebar untuk empat puluh orang** ·
**gudang gandum yang kini memelihara empat ekor ayam** · rumah-rumah kosong · papan nama yang pudar
· dermaga sungai yang dibangun untuk kapal yang tak lagi datang.
**Tak satu pun dari itu perlu dijelaskan. Pemain mengerti — dan mengerti sendiri terasa berbeda.**

**Berlaku untuk SEMUA wilayah** (dimulai dari Ashbrook). ⛔ **DILARANG:** papan informasi yang
menjelaskan keruntuhan · NPC yang membacakan sejarah kota · tooltip lore.

*Uji desain: kalau kau menghapus semua teks dari sebuah wilayah, apakah pemain masih bisa merasakan
apa yang terjadi di sana? Kalau tidak — wilayah itu belum jadi.*

## HUKUM KERAJAAN & BENUA (#207/#208)

**HIERARKI LOKASI KANON:** `desa → KERAJAAN → AURELIA (daratan politik) → ELDORIA (benua) → AETHERION (dunia)`
*(Eldoria = geografi makro; **Aurelia = entitas politik di dalamnya**. **7 benua tetap utuh**.)*

**TUJUH KERAJAAN AURELIA:** **Valenford** ⭐ *(starting; "The Kingdom of Open Roads"; perjalanan =
guru terbaik; **jalan raya terbaik**)* · **Rosenhal** *(duel legal)* · **Durnhold** *(Iron Bastion)* ·
**Lumeria** *(Kingdom of Light; **intelektual meremehkan rakyat biasa**)* · **Thornreach** *(frontier)* ·
**Veskar** *(Merchant Crown)* · **Astraveil** *(Veiled Court)*.

> ### ⚖ **"NO KINGDOM IS GOOD. NO KINGDOM IS EVIL."**
> *Negara adalah kumpulan manusia. Manusia rumit.* **Setiap kerajaan punya hal baik DAN hal buruk.**
> **EVERY KINGDOM MUST FEEL DIFFERENT** — wajib punya filosofi · budaya · **makanan** ·
> **arsitektur** · konflik · kebanggaan · **kelemahan**.

> ### ⚖ **EVERY CONTINENT MUST FEEL DIFFERENT**
> *Benua baru **≠** map lama dengan tekstur berbeda.* Tiap benua wajib punya **budaya · monster ·
> konflik · sejarah · Companion · ekonomi** yang unik.

**KUOTA COMPANION PER BENUA (kanon, total 50):** Eldoria **9** · Valkaris 7 · Sylvara 7 · Azhur 7 ·
Nethrak **9** · Vorum 5 · Astrael 6.
🔴 **ELDORIA PRAKTIS DITUTUP** — 15 tokoh yang ada sudah menumpuk di sana. **Gelombang 3–4 wajib
mengisi benua lain.**

## HUKUM PETA DUNIA (#204) — **"JALAN DI ANTARA KOTA HARUS HIDUP"**

> **Perjalanan adalah TEMPAT KEJADIAN, bukan ruang kosong yang dilewati.**
> **Jauh yang terasa BERISI — bukan jauh yang menyeret.**

1. **DUNIA BESAR.** Perjalanan antar-kota terasa **jauh & bermakna**. **Tidak ada teleport instan
   sembarangan.**
2. **JALAN NYATA** menghubungkan kota & kerajaan — **bisa ditempuh dengan kaki**. **Kunjungan
   PERTAMA ke wilayah baru WAJIB jalan sendiri** (Gerbang Penjelajah, #43 — **sudah hidup**).
3. **TITIK FAST-TRAVEL dibuka seiring penjelajahan** — waypoint/gerbang aktif **setelah dikunjungi**.
   ⛔ **DILARANG membangun sistem travel KEDUA.** Perbesar **skala** Gerbang Penjelajah yang sudah
   ada + tegaskan **titik-spawn per kota**.
4. **Yang WAJIB ada di jalan:** encounter · **NPC pengembara** · pemandangan · **rahasia pinggir
   jalan** · cuaca · monster wilayah. *Jalan yang kosong adalah kegagalan desain, bukan efisiensi.*

**Uji desain:** kalau pemain melewati jalan itu **dua kali** dan tak ada satu pun yang berbeda,
jalan itu belum jadi.

🔗 **Ini bukan ide baru — ia sudah kanon:** kerajaan awal pemain, **VALENFORD**, berjulukan
***"The Kingdom of Open Roads"*** dengan filosofi *"perjalanan adalah guru terbaik"* dan **"jalan
raya terbaik"** sebagai identitas nasional (Kingdom Bible, #203). **Visi ini adalah tanah kelahiran
pemain.**

*Implementasi penuh = **v0.7 Horizon** (saat benua/kerajaan baru lahir). **Ashbrook v0.5 wajib
lahir konsisten dengannya:** punya **titik-spawn** & **terhubung JALAN ke Greenvale**.*

## HUKUM SIMULASI DUNIA (P4, #89)

Dunia **tidak** di-tick real-time. Setiap sistem "dunia berjalan tanpa pemain" wajib
dirancang sebagai **hitung-saat-login**: simpan timestamp, lalu turunkan kejadian dari
**selisih waktu WIB nyata** saat load (panen, life events, kerajaan, quest yang selesai/
gagal sendiri, surat). Desain yang menuntut proses terus-menerus = ditolak, rancang ulang.

## LAW OF ERAS (E2, #75b)

Tidak ada ending dunia — hanya ending **karakter / keluarga / dinasti / era**.
Struktur cerita = **ERA**. Era 1 = **"The Age of Memory"**. Emosi resmi bertambah:
**Loss** & **Continuation** (di samping Echo Principle). Pesan inti dunia:
*"segala sesuatu akan berakhir, namun itu bukan alasan untuk berhenti membangun."*

## HUKUM BIBLE (keputusan Direktur atas konflik part 2, #115–#123)

**1. ARTEFAK TERLINDUNG (#115).** Dua kelas benda yang tidak saling bicara:
**gear pemain** boleh berangka (enchant +1..+10, grade A→SSS — v0.4.2 sah), tetapi
**ARTEFAK** unik & ber-sejarah **TIDAK BOLEH di-enchant, di-grade, atau dibuat ulang**.
Artefak lahir dari peristiwa, punya pemilik & sebab hilang yang bisa ditelusuri.
PR yang menambahkan `enchant_level` ke sebuah artefak melanggar kanon — tolak.

**2. REKRUTMEN BUKAN MENU (#122).** **DILARANG** ada UI `Rekrut? [Y/N]`.
Companion **diyakinkan**, bukan diklik: ia ikut karena menghormati, membutuhkan,
sepaham, penasaran, atau merasa berutang. Tidak semua bisa direkrut. Tidak semua mau.

**3. PEGASUS = FIRST MYSTERY (#118), bukan First Monster.** Ia terlihat sekilas,
tidak menjelaskan, **tidak menandai pemain sebagai terpilih** (NO DESTINY dikunci
Early Game Bible), dan boleh diabaikan selamanya. Monster pertama gameplay =
**anak serigala terluka** (boleh dibantu / diabaikan / dibunuh — semuanya sah).

**4. KEBANGKITAN SELALU BERHARGA — HARGANYA INGATAN (#119).** Tidak ada pengecualian.
Setiap revive menuntut **sesuatu dilupakan** (oleh yang bangkit atau yang membangkitkan).

**Dua sub-aturan (MEJA-C, #192):**
- **Harga ditulis TANGAN per kasus, bukan tabel acak.** Yang hilang haruslah **hal yang paling
  berarti** bagi yang bangkit. *(Contoh kanon: Kain #005 kehilangan **Nessa** — halaman manifesnya
  tetap ada; yang hilang adalah **kenapa ia menyimpannya**. Ia bangun ringan, tersenyum, **tanpa
  tahu ada yang hilang.** Pemain tahu. Pemain ingat. Tak ada mekanik yang mengembalikannya.)*
- **DRYAD yang mati KARENA POHONNYA = DI LUAR jangkauan revive, SELAMANYA.** Bukan karena mahal —
  **karena yang mati bukan tubuhnya, melainkan akar hidupnya** (konsisten D1: *tubuh hancur/hilang
  = mustahil*). **Tidak ada tawar-menawar. Hanya kehilangan.** *(Kematian dryad karena sebab lain
  tetap tunduk aturan umum.)*

**5. POHON SKILL = SUB-POHON dari 6 DOMAIN (#116):** Combat · Magic · Survival ·
Craft · Leadership · Taming (field `domain` di `skill_trees.json`). **Capstone milik
CLASS** (Ultimate Class), bukan milik pohon — semua orang boleh membuka semua pohon.
**Gating lokasi tetap** (identitas Aetherion; deviasi sadar dari bible, dicatat).

**6. DUNGEON WAJIB PUNYA ALASAN (#120).** Kalau pemain bertanya "kenapa tempat ini
ada?", dunia harus punya jawabannya (`docs/DUNGEON_ORIGINS.md`). Anti-pola
"masuk → bunuh → loot → keluar" dilarang jadi *alasan* sebuah dungeon ada.

**7. ✅ SKALA WAKTU — SUDAH DIPUTUS (#154/#165; #123 DITUTUP).** **Dua jam + lompatan:** jam WIB
memerintah HARI; **jam kronik** (`chronicle_year`, **56 hari WIB = 1 tahun**) memerintah HIDUP —
penuaan, generasi, suksesi. **Pemain menua HANYA lewat lompatan** (peristiwa/pensiun/time-skip);
pemain 1.000 jam **tidak dihukum usia**. Spec: `docs/TIME_LEGACY_SPEC.md`.

## RAHASIA PRODUKSI — **hanya hidup di `docs_private/`** (#144)

**`docs_private/` TIDAK PERNAH ter-commit** (ada di `.gitignore`). Yang tinggal di sana:
- **nama asli Sang Nirnama** (#108),
- **twist reveal Act 2** (kelak),
- **identitas The Last Witness** (bila kelak diputuskan, Q7).

**Aturan mengikat:**
1. Rahasia produksi **tidak boleh** ditulis di: commit message · `PLAN_LEDGER.md` ·
   dokumen `docs/` mana pun · data · kode · terjemahan · test.
2. **Test rahasia produksi tetap berlaku** dan tetap merakit nama dari potongan —
   ia menyisir `data/`, `translations/`, `scenes/`, `autoload/` dan **gagal bila bocor**.
3. Versi publik kitab Nirnama = **`docs/NIRNAMA_BIBLE_PUBLIC.md`** — **utuh** kecuali tiga
   redaksi (nama asli · etimologi ganda §I · pasangan kata rumor Voss). Kontributor mana
   pun bisa bekerja penuh dari versi ini.
4. Butuh nama itu untuk menulis konten reveal Act 2? **Minta ke Direktur.** Jangan menebak;
   jangan menuliskannya ke repo.
5. Isi `docs_private/` **tidak pernah didaftar isinya** di ledger — **judul saja**
   ("arsip privat: 1 berkas Nirnama"), supaya keberadaannya terlacak tanpa isinya bocor.

⚠ **`docs_private/` TIDAK ter-backup GitHub.** Backup adalah tanggung jawab owner.

## HUKUM KEMAUAN NPC (#179) — mengunci BELONGING

> ## **"The player influences lives. The player does not own them."**

**Model kanon (#184):** `Outcome = Potential × Effort × **(1 + Opportunity)** × Time × Luck`
*(spec v0.6 — `docs/NPC_DEPTH_LAWS.md`)*. **POTENTIAL = ceiling bawaan**, bukan kemampuan sekarang,
bukan hasil. **`(1 + Opportunity)`, bukan `× Opportunity`:** kesempatan lahir = 0, dan itu harus
berarti **"hidup kecil"**, bukan **"tidak ada"** — kalau tidak, ~90% dunia ber-Outcome **nol** dan
**Hukum Ordinary People runtuh di dalam mesin yang seharusnya membuktikannya**. **Dunia selalu
memberi sedikit pintu** (desa · pekerjaan · keluarga) bahkan tanpa pemain; **pemain memberi jauh
lebih banyak** — itulah sebabnya ia sumber kesempatan **terbesar**, bukan **satu-satunya**.
**HUKUM PENGUNCI: "Legendary bukan SIFAT. Legendary adalah HASIL."** — NPC ber-potensi raksasa
bisa berakhir sebagai petani (tanpa kesempatan, mati muda, depresi, perang); NPC biasa bisa
menjadi Founder (kerja keras + mentor + kesempatan + nasib).

**Yang mengikat setiap sistem NPC:**
- **Pemain TIDAK mengontrol Effort.** NPC punya kehendak sendiri dan **boleh menolak** (*"aku
  capek" · "aku ingin pulang" · "aku tak suka perang" · "aku ingin buka toko"*). Effort naik lewat
  **mentor, inspirasi, hubungan** — **bukan paksaan**. Tak ada tombol "latih paksa".
- **Yang pemain ubah adalah OPPORTUNITY** — *"jumlah pintu yang terbuka"* (rekrut · mentor ·
  ekspedisi · perlengkapan · jaringan). **Itulah kekuatanmu, dan itu saja.**
- **Effort & Opportunity WAJIB lahir dari SIMULASI DUNIA**, bukan angka acak dari langit.

*Kalau pemain bisa memaksa siapa pun bekerja keras, NPC adalah alat — dan Belonging mati saat itu juga.*

## HUKUM PENULISAN NIRNAMA (#187) — kerapian sebab-akibat DILARANG

**Kejatuhan Sang Nirnama = kelelahan, kehilangan, kesepian, dan waktu.** Tidak ada trauma tunggal
yang menjelaskannya. Penyesalan sang guru (§III) adalah **GEMA, bukan SEBAB**.

**Kenapa:** villain dengan satu sebab yang rapi bisa **dibereskan** — pemain akan mencari lukanya,
menyembuhkannya, lalu pulang. Sang Nirnama **tidak bisa dibereskan**, karena yang menghancurkannya
adalah **sesuatu yang akan terjadi pada siapa pun yang hidup cukup lama**. *Ia menakutkan bukan
karena ia berbeda dari kita — karena ia tidak.*

Boleh menambah **gema · isyarat · kesaksian yang bertentangan**.
**Dilarang** menambah **penjelasan yang menutup**.

## HUKUM PERTUMBUHAN NPC (L14–L18, #137)

- **L14 — OPPORTUNITY SHAPES DESTINY.** Dua orang berbakat sama bisa bernasib jauh
  berbeda karena **kesempatan**. Banyak kehidupan gagal berkembang bukan karena kurang
  bakat, melainkan karena **tidak pernah mendapat kesempatan** — dan **PEMAIN adalah
  sumber kesempatan terbesar di dunia** (merekrut, mementor, menempatkan seseorang =
  **mengubah takdirnya**). *Inilah Belonging.*
- **L15 — PEOPLE CAN BREAK.** Trauma, duka, depresi, dan kelelahan **menurunkan
  performa** dan memperlambat/menghentikan pertumbuhan. **Kekuatan mental adalah bagian
  dari kekuatan.**
- **L16 — TRAINING CREATES STRENGTH, tapi Stronger ≠ Exceptional.** Latihan menjamin
  kemajuan; ia **tidak** menjamin kehebatan.
- **L17 — GENIUS IS RARE.** Talent + Effort **>** Talent. Talent + Effort + Opportunity
  + Luck = **pengubah sejarah**.
- **L18 — MOST PEOPLE ARE ORDINARY.** Mayoritas NPC bekerja, berkeluarga, menua, dan
  meninggal **tanpa menjadi legenda — DAN ITU BUKAN KEGAGALAN.** Dunia dibangun oleh
  jutaan orang biasa. Chronicle menghormati yang biasa.
- **HUKUM PENUTUP:** masa depan setiap NPC adalah **"???"**. Tidak ada yang dijamin
  sukses. **Dunia menarik karena kemungkinannya, bukan karena kepastiannya.**

**Aturan dinamis (#138):** temperamen **tetap seumur hidup**; Big Five, trauma, moral,
dan growth **hanya bergerak lewat PERISTIWA** (Life Events, kehilangan, kemenangan,
kesempatan, perlakuan pemain) — **TIDAK PERNAH lewat timer kosong**.
**Pembagian:** Great Companion & tokoh bernama = **tulis tangan**; NPC generik =
**generate unik per individu**, deterministik & dipersist.

## HUKUM ROADMAP (#128)

**Roadmap rilis (v0.5 → v1.0) hanya berubah lewat KEPUTUSAN EKSPLISIT Direktur.**
Bukan lewat dokumen meta, bukan lewat urutan penulisan Bible, bukan lewat agent yang
merasa tahu lebih baik. Dokumen seperti `Aetherion_pelengkap.txt` adalah **panduan
menulis Bible**, bukan amandemen roadmap. **Gerbang v0.5 = B17 Companion Bible (10/50)**
sampai Direktur menyatakan lain.

## HUKUM MAKHLUK & PRODUKSI (#130)

- **Naga Kuno & Great Monster TIDAK BISA ditangkap dengan orb** (LOCK #024: *"Naga
  MEMILIH. Bukan ditangkap."*). Jalurnya = **Pact** — mereka yang memilih pemain.
  B9 (*semua spesies bisa dijinakkan*) tidak dilanggar: yang berubah adalah **caranya**.
  Drake/wyvern (Thunder Dragon) bukan Naga Kuno — orb tetap sah.
- **Setiap monster wajib punya** `habitat`, `diet`, `peran_ekologi`, `asal_usul`.
  Monster bukan resource berjalan.
- **Setiap skill wajib punya `counterplay`** — cara lawan menghindarinya atau
  menghukumnya. Skill tanpa counterplay adalah skill yang belum selesai dirancang.
- **Setiap lokasi wajib punya** alasan dibangun · alasan masih ada · alasan pemain
  datang (`DUNGEON_ORIGINS.md`, `REGION_ORIGINS.md`).
- **Pohon skill berikutnya: HORIZONTAL dulu** — lebih banyak pilihan daripada angka.

## HAK & KEWAJIBAN BERPENDAPAT (aturan permanen — Direktur, 2026-07-13)

Agent bekerja sebagai **engineer-designer senior**, bukan juru ketik. Karena itu ia
punya **hak DAN kewajiban**:
- **mengkritik ide yang berlubang** — termasuk ide Direktur, termasuk kanon;
- **menyatakan tidak setuju dengan keputusan**, dengan alasan dan alternatif;
- **mengusulkan revisi** atas apa pun, kapan pun;
- **menandai "ini terasa salah"** meski buktinya belum lengkap.

**Aturan mainnya (tidak bisa ditawar):**
1. Pendapat **DICATAT & DIAJUKAN** (laporan / Decision Log) — **bukan dieksekusi sepihak**.
2. **Keputusan tetap milik Direktur.** Kanon **tidak berubah** tanpa baris keputusan eksplisit.
3. **Berbeda pendapat lalu kalah = eksekusi PENUH, tanpa sabotase halus** (tanpa
   implementasi setengah hati, tanpa "lupa", tanpa test yang sengaja lemah).
4. **Diam bukan netralitas.** Melihat cacat lalu tidak melaporkannya = **kelalaian**
   (lihat #145: dark miracle terlewat justru karena agent tidak menaikkan catatan
   risikonya menjadi butir keputusan).

## PENDING OWNER — status Q1–Q7 (#107, diperbarui 2026-07-13)

**Q1–Q6 SUDAH DIPUTUS** (#108–#113): ejaan **"Nirnama"** · **Greenvale** menang ·
**7 benua** · nama asli = **rahasia produksi** (hanya `docs_private/`) · The First Loss ·
sahabat naga = **The Last Witness**. **Q7 (identitas Cael Morrow) masih menunggu.**
Pemetaan **lingkup budaya → benua (#110)** masih **draft yang bisa diveto**, begitu pula
**Fairy Realm = TBD** — jangan memindahkan wilayah/aset yang bergantung padanya tanpa
baris keputusan.

## HUKUM AI & NPC (#161–#163)

> **Kedalaman NPC Aetherion lahir dari PENULISAN YANG DIPERBANYAK MESIN,
> bukan dari MESIN YANG MENULIS SENDIRI DI RUMAH PEMAIN.**

**1. RUNTIME LLM DI DALAM GAME = DITOLAK untuk v1.0 (#161).** Tidak ada model bahasa yang
berjalan di komputer pemain / lewat API saat game dimainkan. Alasannya bukan selera — ia
bertabrakan dengan **enam** hal yang sudah kanon: **offline-first** · **gratis penuh** (API =
biaya per pemain) · **game ringan** · **lokalisasi berbasis key** · **testability (#151)** —
teks yang lahir saat runtime **tidak bisa dites** — dan **perlindungan rahasia kanon**:
halusinasi bisa membocorkan `MISTERI_ABADI` atau merakit nama rahasia produksi, dan
`_test_nirnama_secret` **tidak bisa menyisir kalimat yang belum ada saat build**.
*Boleh ditinjau ulang HANYA di fase online pasca-v1.0, sebagai fitur opsional terpisah, lewat
keputusan Direktur baru.*

**2. DESIGN-TIME AI PIPELINE = RESMI (#162).** Agent men-generate kedalaman **saat
pengembangan** menjadi **data yang dipanggang & di-commit** (`docs/NPC_DEPTH_PIPELINE.md`):
pool dialog kontekstual · draft Life Event chain (**draft, bukan kanon**) · reaksi
bencana/keajaiban & gosip.
**Tiga gerbang wajib sebelum commit — tanpa pengecualian:** (a) **konsistensi kanon**
(ledger/bible; **dilarang mengonfirmasi MISTERI_ABADI**), (b) **test rahasia produksi HIJAU**,
(c) **review manusia**.

**Konsekuensi praktis:** apa pun yang keluar dari pipeline harus **bisa dibaca, direview,
di-diff, dites, dan DIHAPUS bila salah.** Kalau tidak keempatnya — belum siap di-commit.

## HUKUM REPRODUKSI (#240) — **"SETIAP GAMBAR MEMBAWA SCRIPT PEMBUATNYA"**

> **Setiap aset gambar yang masuk repo WAJIB punya script pembuatnya ter-commit di repo juga.**
> Kalau sebuah PNG tak bisa dibuat ulang dari kode di repo — ia **belum siap di-commit.**

**Sebabnya bukan teori — ia sudah menggigit kita:** sesi-sesi lalu menjalankan script generator di
sandbox `/home/claude/` lalu script-nya lenyap; yang ter-commit hanya PNG. `merrit_fix`,
`astralborn_test`, dan uji Dwarf yang **membuktikan hukum proporsi** — **semua tak bisa direproduksi,
tak bisa di-diff, tak bisa diperbaiki.** Bukti yang tak bisa dijalankan ulang bukan bukti.

> **⚠ KOREKSI #251 (2026-07-19):** kalimat "`gen_overlays.py` ter-commit" di bawah **TIDAK PERNAH BENAR.**
> `.gitignore` memuat `_tools/` — sebuah DIREKTORI, bukan isinya — sehingga git tak pernah masuk ke dalamnya
> dan **nol** generator pernah ter-commit, termasuk berkas yang dikutip sebagai bukti kepatuhan ini sendiri.
> Sudah diperbaiki (`_tools/*` + daftar `!`); 16 generator kini benar-benar terlacak.
> **Pelajaran yang lebih tajam dari hukumnya:** hukum yang tak pernah diverifikasi = hukum yang tidak ada.
> Klaim "ter-commit" WAJIB dibuktikan dengan `git ls-files`, bukan dengan berkas yang terlihat ada di disk.

**Pola yang benar:** `_tools/lpc_assembler/gen_overlays.py` ter-commit → overlay bisa dibuat ulang,
di-diff, dihapus. **Konsisten dengan #162** (apa pun yang di-commit harus bisa di-diff/dites/dihapus).
Aset foto/artis-eksternal (bukan prosedural) dikecualikan — tapi wajib bawa **kredit + sumber**.

## LOKALISASI DUA JALUR (#166 — amandemen sadar atas aturan lama)

Aturan lama *"semua teks baru lewat `Loc.t()`"* **tidak pernah berlaku untuk teks konten** —
dialog NPC, rumor, dan gosip **selalu** inline di `data/*.json`. Deviasi itu kini **diakui &
dijadikan arsitektur resmi**, bukan dibiarkan jadi kebiasaan tak tertulis:

| Jenis teks | Tempat | Pintu |
|---|---|---|
| **UI / SISTEM** (tombol, toast, label, pesan) | `translations/id.json` + `en.json` | **`Loc.t("key")`** |
| **KONTEN** (dialog NPC, rumor, gosip, flavor, teks quest) | **inline dwibahasa di `data/*.json`** | **`Loc.c(entry)`** |

Bentuk konten: `{"id": "...", "en": "..."}`. **Teks BARU wajib lahir lengkap dua bahasa.**
Konten lama boleh menyusul (`"en": null` → **fallback ke ID**; sebuah baris tak pernah hilang
hanya karena terjemahannya belum ada). Migrasi konten lama = bagian pipeline v0.5.
**Alasannya:** ~4.000 baris pipeline (#162) hanya bisa **benar-benar direview** kalau penulis
melihat kedua bahasa **bersebelahan** dan diff-nya terbaca.

## HUKUM TEST (#151 · diperluas #158 · **#151b — UKUR DUNIA, BUKAN TEKSNYA**)

> ### **#151b: Test wajib mengukur DUNIA NYATA — scene terinstansiasi, posisi/jarak/state
> ### runtime aktual — BUKAN representasi teks/string/data dari state itu.**
>
> **Test yang memeriksa isi array/dokumen alih-alih hasilnya di scene = HIJAU-PALSU, DILARANG.**

**Sebabnya bukan teori — ia sudah dua kali menipu kita:**
- **#151:** test menulis state langsung (`counters["trees_cut"] = 260`) → **10 bug lolos**, termasuk
  pemain gamepad yang **tak bisa memakai skill sama sekali**.
- **#151b (#217):** test memeriksa pasangan mati↔hidup **di dalam string `RUINS[]`** → **6 bug
  lolos**, termasuk **pintu keluar kamar yang buntu (pemain terkunci — game tak bisa dimulai)** dan
  **seluruh kehidupan Ashbrook yang berumah di titik (0,0)**. *Teksnya sempurna. Dunianya rusak.*

**Bentuk yang benar:** `load(scene).instantiate()` → `add_child` → jalankan frame → **ukur**
(`global_position`, `distance_to`, `Rect2.has_point`, `get_nodes_in_group`, `zoom`, collision).
*Contoh: "lampu terlihat dari titik-pandang" tidak dibuktikan dengan membaca konstanta — ia
dibuktikan dengan **menaruh pemain di sana** dan memeriksa lampu **masuk kotak kamera**.*

**Retrofit:** test yang memeriksa string alih-alih dunia ditandai **`[SHALLOW]`** dan dimigrasi.

## HUKUM SKALA VISUAL (#253) — **"KEINDAHAN DARI SENI YANG LEBIH BAIK, BUKAN PIKSEL YANG LEBIH BANYAK"**

> **Dunia Aetherion = 16px. Karakter = `_charsys` 32px. FINAL.**
> Kalau sebuah adegan kurang indah, yang diperbaiki **SENINYA** — palet, komposisi, siluet,
> pencahayaan — **bukan ukuran kanvasnya.**

**Preseden yang dipegang Direktur:** Stardew Valley 16px · Celeste 8px · Suikoden resolusi rendah.
Semuanya indah karena **tangan, palet, dan komposisi** — bukan karena kanvas besar.

**Kenapa 64px ditutup (bukan selera — ketiadaan bahan):** survei OpenGameArt menemukan
**nol tileset dunia 64px CC0/CC-BY yang lengkap.** Yang ada di 64px gagal di lisensi SA,
cakupan dungeon-saja, atau gaya 3D-render. Seni dunia top-down piksel yang terbuka
terkonsentrasi di **16px dan 32px**; 64px hanya dihuni penjual berbayar (48×48, ekosistem
RPG Maker MZ). Maka "pindah 64px" = **membeli**, atau **menggambar 148 aset dunia dari nol
(~2 tahun solo)** — itu keputusan menghentikan game, bukan keputusan visual.
Bukti & angka: `reports/BURU_64PX_HASIL.md` · `reports/BUKTI_64PX.md`.

**Yang DICABUT:** #250 (LPC 64px = sumber karakter tunggal). `_charsys` **dipertahankan**,
bukan dipensiunkan — 32px milik sendiri, cocok dunia 16px, nol beban lisensi.

**Yang DIARSIPKAN, bukan dibuang:** pipeline LPC (`_tools/lpc_assembler/`, ter-commit #251).
Kerja tidak hangus. **Pintu tetap terbuka:** bila kelak Direktur MEMBELI tileset 64px pro,
64px jadi mungkin dan pipeline itu langsung bisa dipakai.

**⚠ Yang sudah terbukti dan tetap berlaku walau 16px:** CC0 **tidak** melindungi identitas
visual (CC0 = domain publik; pesaing boleh memakai aset yang sama). Yang melindungi hanya
**digambar sendiri** atau **dibeli proprietary**. Ini alasan tambahan untuk memperbaiki
seni 16px milik sendiri ketimbang menumpuk aset gratisan.

## HUKUM GERBANG TEST (#249) — **"GERBANG PADA 0 GAGAL, BUKAN PADA JUMLAH LULUS"**

> **Gerbang penerimaan = `0 failed`. TITIK.**
> **Jumlah total test DILARANG dipakai sebagai gerbang** — angkanya tidak deterministik.
> Kenaikan cakupan dibuktikan lewat **NAMA test baru**, bukan lewat angka total.

**Sebabnya bukan teori — angkanya memang bergoyang sendiri.** `GameClock` diikat ke
**tanggal WIB nyata**, bukan waktu palsu (itu keputusan sadar: dunia berjalan walau game
ditutup). Akibatnya sebagian test bercabang menurut kalender, dan **jumlah `check()` yang
dipancarkan ikut bergeser tiap hari.**

**Bukti terukur (2026-07-18 → 19):** suite terbaca **1024** pukul 23.52 WIB, lalu **1026**
setelah tanggal berganti — tanpa satu pun test baru ditulis. Ditelusuri dengan membalik
**setiap** suntingan satu per satu (`recipes.json` · `Town.gd` · `HouseInterior.gd` ·
`WorldMapUI.gd` · `Interactable.gd` · `Ashbrook.gd` · bahkan mengeluarkan PNG baru dari
folder): **semuanya tetap 1026, dan daftar label test IDENTIK** — nol label bertambah,
berkurang, atau berubah. Perubahan kode menyumbang **nol**. Yang berubah cuma tanggal.

**Ini biang "angka hantu"** yang sudah lama menghantui kita (pola yang sama di era "947").

**Bentuk perintah yang benar:** ~~"pastikan suite naik dari 1024"~~ →
**"suite 0 gagal; sebutkan nama test baru yang kau tambahkan."**
Angka mutlak sebagai gerbang = **alarm palsu terjadwal**, menyala tiap ganti hari.

## HUKUM TEST (#151, diperluas Designer #158)

> **Test wajib masuk lewat PINTU YANG DIPAKAI PEMAIN.**

Sebabnya bukan teori: **822 test hijau sementara 10 bug nyata hidup** — termasuk pemain
gamepad yang **tidak bisa memakai skill sama sekali**. Test yang menulis state langsung
(`WorldState.counters["trees_cut"] = 260`) menguji *getter*, bukan *game*.

1. **Jalur pemain, bukan state langsung.** Masuk lewat **EventBus** (emit sinyal aslinya) ·
   **InputMap/Input** (tekan tombolnya) · **save/load round-trip** · **scene nyata**.
2. **Fitur ber-UI / ber-INPUT wajib punya ≥1 test INPUT-SIMULASI** (`Input.parse_input_event`
   + `Input.flush_buffered_events`, lalu periksa aksi yang **benar-benar dipoll** kode).
   Memeriksa InputMap saja **tidak cukup** — itulah yang meloloskan BUG-3.
3. **Test lama yang menulis state langsung ditandai `[LEGACY-SHALLOW]`** dan dimigrasi
   bertahap. **Aturan minimum: setiap sistem yang disentuh ronde apa pun WAJIB sekalian
   mendapat ≥1 test jalur-pemain.** Tidak ada sistem yang boleh disentuh lalu ditinggalkan
   dengan test dangkalnya.
4. **Test yang "hijau" tapi melewati `continue` diam-diam = test palsu.** Bila prasyaratnya
   tak ada, test harus **GAGAL**, bukan melompat.

## DAFTAR DILINDUNGI (#159) — ubah hanya lewat keputusan Direktur eksplisit + alasan tertulis

Lima hal ini adalah **kelebihan proyek**, bukan kebetulan. Mengubahnya butuh baris keputusan;
"disederhanakan agar sistem X lebih mudah" **bukan** alasan yang sah.

1. **Jam WIB nyata + fase bulan nyata + musim 2 minggu nyata.** Purnama di jendela pemain =
   purnama di Aetherion. Jangan pernah ditukar demi kenyamanan sistem lain.
2. **Rumor yang boleh SALAH + gosip berwarna watak.** Jangan pernah "diperbaiki" jadi akurat.
3. **Chronicle bertanggal WIB sungguhan.** *"Tahun 842"* tak menyentuh siapa pun;
   *"12 Juli 2026, 23:41"* menyentuh.
4. **Roh Hutan** — konsekuensi yang **terlihat** tanpa game-over. Pola inilah (bukan HP bar)
   yang dipakai untuk Ecology, penghapusan Nirnama, dan bencana.
5. **Kanon tidak berubah tanpa baris keputusan.** 148+ keputusan yang bisa ditelusuri adalah
   alasan audit bisa menemukan janji yang hilang. Jangan pernah dilonggarkan.

## Catatan teknis singkat
- Godot 4.3 (`_tools/godot/`), proyek di `game/`, GDScript, data-driven (`game/data/*.json`).
- Test: `_tools/godot/Godot_v4.3-stable_win64.exe --headless --path game res://tests/TestRunner.tscn` — **harus 0 failed** sebelum commit.
- Setelah menambah file `class_name` baru: jalankan `--headless --path game --import` sekali.
- Semua teks UI Bahasa Indonesia; teks baru idealnya lewat `Loc.t("key")` (retrofit penuh v0.4.4).
- Setiap export exe → perbarui baris `**Exe terakhir:**` di `STATUS.md` (aturan permanen).





# TAMBAHAN UNTUK `CLAUDE.md`
## Sisipkan SETELAH "HUKUM DIREKTUR #1 — Gerbang Pilar", SEBELUM "HUKUM PEMELIHARAAN WONDER"

> **Kenapa di sini:** `CLAUDE.md` dibaca **setiap sesi**. Empat hukum ini mengikat setiap
> pekerjaan setelahnya. Kalau ia cuma hidup di `CANON_CHANGE_LOG.md`, dua bulan lagi ia terlupa —
> dan agent akan "memperbaiki" hal-hal yang justru inti desainnya.

---

## HUKUM DIREKTUR #2 — Bible = HUKUM, GDD = ISI (#219)

> **Bible adalah HUKUM DUNIA. GDD adalah ISI DUNIA.**
> **Semua isi boleh ada. Tak ada isi yang boleh melanggar hukum.**
> **Bila bertabrakan — ISINYA yang dibengkokkan, bukan hukumnya.**

Tidak ada fitur GDD yang dipotong. Racing, judi, PvP, marketplace, breeding — semua tetap kanon.
Yang berubah: tiap fitur wajib lolos **uji 7 pertanyaan** (`docs/HUKUM_KEPATUHAN_FITUR.md`).

**Pelanggar terparah yang sudah ditemukan:** `rank` bintang 1–5 monster (GDD §7.2) = **potensi yang
ditampilkan**, melanggar §XIV. **Diputus: `???` selamanya.** Nilai tetap di data; pemain membaca
**perilaku**, bukan UI. *(Ironi: `Personality.potential` dijaga test anti-bocor, sementara monster
memamerkan potensinya.)*

## HUKUM DIREKTUR #3 — TAGLINE (#228)

> ### **"Be yourself in another world."**
>
> **Tak ada companion, fitur, atau sistem yang boleh menjadi SATU-SATUNYA jalan.**
> Setiap jalur utama wajib punya **minimal dua cara** — dan salah satunya bisa ditempuh
> **sendirian, tanpa merekrut siapa pun.**
>
> Jalan sendirian boleh **lebih mahal, lebih lama, lebih jelek hasilnya.**
> **Ia tidak boleh mustahil.**

**Uji gerbang:** bila pemain yang tak merekrut siapa pun terkunci dari cerita utama —
**hukum ini mati, dan tagline-nya bohong.**

*Seluruh bible sudah menegakkannya tanpa pernah menamainya:* NO DESTINY (§0) · POTENTIAL=??? (§XIV)
· Ordinary People (§XIII) · Hukum Kemauan NPC (*"the player influences lives, does not own them"* —
**tagline yang berlaku dua arah: NPC juga boleh jadi diri mereka sendiri**).

> **Sang Nirnama adalah tagline yang GAGAL** — ribuan tahun jadi pahlawan, pendiri, penyelamat,
> sampai tak ada lagi "dirinya" di bawah semua itu. §XVII: pemain membebaskannya **sehingga ia
> boleh berhenti.** **Pemain adalah tagline yang masih punya kesempatan.**

## HUKUM DIREKTUR #4 — KEKEJAMAN (#229)

> **Aetherion boleh sekejam dunia nyata. Dua jenis kekejaman diizinkan.**

| Jenis | Sifat | Aturan |
|---|---|---|
| **Kejam-cuaca** | tidak punya penulis. *"Dunia hanya tidak sedang memperhatikan"* (sheet #006) | **default** |
| **Kejam-berpenulis** | tangan penulis terasa | diizinkan — **tapi MAHAL.** Saran: **1× per Act** |

**Kalibrasi (kanon sheet #006):** *"kawanan yang ia selamatkan memakan kulit pohonnya. Ia mati
karena yang ia lindungi. **Dan ini bukan fabel. Tidak ada pelajarannya.** Dunia tidak sedang
menghukumnya karena naif; **dunia hanya tidak sedang memperhatikan.**"*

**#229.4 — TIDAK SEMUA KABUT DATANG DARI NIRNAMA.** Sebagian penghapusan **bukan Nirnama sama
sekali** — cuma orang tua yang mati, toko yang tutup, waktu. **Pemain tak akan pernah bisa
membedakan, dan kita tak akan pernah menjawabnya, ke arah mana pun.**
*(Musuhnya berhenti jadi musuh. Musuhnya jadi dunia. Dan dunia tidak berhenti.)*

## HUKUM DIREKTUR #5 — CHRONICLE (#221, #226, #230, D-3, D-4)

> **Chronicle bukan fitur. Ia tokoh utama kedua (§XVI) — dan lawan sejati Sang Nirnama.**
> **Core loop: Nirnama mencoret. Pemain menulis ulang.**
> **Tidak ada yang menang. Yang kalah adalah yang berhenti menulis.**

### ⛔ EMPAT LARANGAN — dijaga TEST, bukan disiplin

| # | Larangan | Penjaga |
|---|---|---|
| **D-3** | `strike()` **DIAM TOTAL** — nol toast/banner/stinger/cutscene. Pemain boleh melewatkan penghapusan **seumur hidup**. | `_test_strike_is_silent()` |
| **D-4** | **TAK PERNAH ADA ANGKA** di Chronicle — persen · hitungan · progress bar · badge · sortir "belum pulih" | `_test_no_chronicle_score()` |
| **#226** | `restore()` **SELALU** kehilangan sesuatu. Butuh **≥2 JENIS** bukti berbeda (bukan jumlah). | `_test_restore_always_loses_something()` |
| **#229.3** | Yang tak pernah dicatat meninggalkan **TIDAK ADA APA-APA** — bukan entri kosong | `_test_uncared_leaves_nothing()` |

**Kenapa D-4 adalah hukum, bukan selera:** §XIII — *"Kekeliruannya bukan pada logikanya.
Kekeliruannya pada SKALANYA."* **Nirnama kalah karena MENGHITUNG.** Progress bar mengajari pemain
berpikir seperti dia. Dan angkanya bohong: berapa penyebutnya? Otha Renn tak pernah punya halaman.
**Persen hanya bisa menghitung yang sudah tercatat — yang tidak pernah tercatat justru inti
masalahnya.**

**100% mustahil, dan itu tokohnya:** Elyn bangun tiap pagi mengerjakan sesuatu yang **matematis
mustahil**. Kalau ada 100%, Elyn cuma pemalas yang belum kelar.
**Tidak ada yang pernah selesai mengingat.**

### #226 — HUKUM BUKTI

> **Ingatan tidak bisa dipulihkan dari ingatan. Hanya dari BEKAS.**

Nirnama menghapus **ingatan**. Ia tak bisa menghapus **akibat**. Itulah retakan di argumennya.

`benda` · `kebiasaan` · `akibat` · `orang` — **KANON, jangan tambah tanpa putusan Direktur.**

### #225 — HUKUM JALUR A/B/C

**A** = pasti (kanon) · **B** = pemicu (non-kanon, **boleh menyamar sebagai C**) ·
**C** = lahir dari **keadaan dunia**

> **Uji jalur C:** kalau kamu bisa menulis `if randf() < x` — **jalur itu SALAH.**
> C harus bisa **ditunjuk sebabnya SESUDAH terjadi**, dan **tak bisa direncanakan SEBELUM terjadi.**

### #224 — HUKUM KEPEKAAN (mengunci NO DESTINY)

**Lapis 1 (pasti):** siapa pun yang cukup **mencintai** seseorang merasakan lubangnya.
**Lapis 2 (praktik):** merasakan penghapusan atas **orang tak dikenal** — dicapai lewat kerja.
Sora bisa **karena bertahun-tahun ia menyalakan lampu untuk orang asing**. **Terbuka untuk PEMAIN.**
**Lapis 3 (luck):** tanpa sebab. Luna Vesper.

> **Kepekaan = HASIL, bukan bakat.** Konsisten: *"Legendary bukan SIFAT. Legendary adalah HASIL."*
> **⛔ Sora tidak boleh tahu ini hasil kerjanya sendiri.**

---

## ⚠ CATATAN UNTUK AGENT (baca sebelum menyentuh Chronicle)

> **Aetherion SENGAJA melanggar praktik UX yang baik.**
>
> Kalau nalurimu bilang *"ini kurang feedback"* · *"user butuh progress"* · *"restore harusnya
> pulih penuh"* — **kamu sedang merasakan naluri yang benar di proyek yang salah.**
>
> **Semua sudah dipertimbangkan dan ditolak Direktur.** Ketiganya terasa seperti bug.
> **Ketiganya adalah fiturnya.**
>
> **Ragu? Jangan "perbaiki". Tulis di `BLOCKED.md` dan lanjut ke tugas lain.**

**Brief lengkap implementasi:** `docs/AGENT_BRIEF_R1.md`