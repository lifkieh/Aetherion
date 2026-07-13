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

## Catatan teknis singkat
- Godot 4.3 (`_tools/godot/`), proyek di `game/`, GDScript, data-driven (`game/data/*.json`).
- Test: `_tools/godot/Godot_v4.3-stable_win64.exe --headless --path game res://tests/TestRunner.tscn` — **harus 0 failed** sebelum commit.
- Setelah menambah file `class_name` baru: jalankan `--headless --path game --import` sekali.
- Semua teks UI Bahasa Indonesia; teks baru idealnya lewat `Loc.t("key")` (retrofit penuh v0.4.4).
- Setiap export exe → perbarui baris `**Exe terakhir:**` di `STATUS.md` (aturan permanen).
