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

**5. POHON SKILL = SUB-POHON dari 6 DOMAIN (#116):** Combat · Magic · Survival ·
Craft · Leadership · Taming (field `domain` di `skill_trees.json`). **Capstone milik
CLASS** (Ultimate Class), bukan milik pohon — semua orang boleh membuka semua pohon.
**Gating lokasi tetap** (identitas Aetherion; deviasi sadar dari bible, dicatat).

**6. DUNGEON WAJIB PUNYA ALASAN (#120).** Kalau pemain bertanya "kenapa tempat ini
ada?", dunia harus punya jawabannya (`docs/DUNGEON_ORIGINS.md`). Anti-pola
"masuk → bunuh → loot → keluar" dilarang jadi *alasan* sebuah dungeon ada.

**7. ⏳ SKALA WAKTU (#123) — PENDING OWNER.** Penuaan/generasi/suksesi vs jam WIB asli
belum didamaikan. **Jangan bangun apa pun yang bergantung padanya.**

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

## PENDING OWNER Q1–Q7 (#107) — JANGAN SENTUH PENAMAAN

Tujuh pertanyaan konflik masih menunggu owner: ejaan **Nirnama**/Nirmana ·
**Greenhollow/Ashbrook vs Greenvale** · 7 benua vs enam lingkup budaya · nama asli
Nirnama · siapa The First Loss · sahabat naga vs Thunder Dragon · identitas Cael
Morrow. **Jangan mengubah penamaan dokumen, wilayah, atau aset apa pun yang
bergantung pada ini.** Default sementara: ejaan **"Nirnama"**. Companion Bible
mencatat lokasi tokoh **apa adanya** (pending-mapping), tidak dipetakan sepihak.

## Catatan teknis singkat
- Godot 4.3 (`_tools/godot/`), proyek di `game/`, GDScript, data-driven (`game/data/*.json`).
- Test: `_tools/godot/Godot_v4.3-stable_win64.exe --headless --path game res://tests/TestRunner.tscn` — **harus 0 failed** sebelum commit.
- Setelah menambah file `class_name` baru: jalankan `--headless --path game --import` sekali.
- Semua teks UI Bahasa Indonesia; teks baru idealnya lewat `Loc.t("key")` (retrofit penuh v0.4.4).
- Setiap export exe → perbarui baris `**Exe terakhir:**` di `STATUS.md` (aturan permanen).
