# INSTRUKSI EKSEKUSI CLAUDE CODE — PROJECT AETHERION
Baca bagian A dulu (persiapan 3 menit), lalu paste PROMPT di bagian B ke terminal Claude Code kamu.

---

# A. PERSIAPAN SEBELUM PASTE (kamu, sekali saja)

1. Pastikan struktur awal:
   ```
   D:\2DGAME\
     *.zip                 (semua zip asset hasil download)
     docs\                 (buat folder ini, isi dengan file .md dari chat kita:)
       GDD_Aetherion.md
       GDD_Aetherion_v0.2_Revisi.md
       GDD_Aetherion_v0.3_Revisi.md
       Monster_Roster_Launch.md
       Fase0_Desain_Teknis.md
       Daftar_Download_Asset.md
     aetherion_original_assets_v1.zip  (pack orisinal buatan kita)
   ```
2. Jalankan Claude Code DARI folder proyek: buka terminal → `cd /d D:\2DGAME` → `claude`
3. Biarkan **auto mode ON** (sudah, sesuai screenshot). Kalau dia meminta izin tool tertentu, pilih "always allow".
4. Paste seluruh isi bagian B di bawah sebagai satu pesan.

---

# B. PROMPT UNTUK CLAUDE CODE (copy semua di bawah garis ini)

---

Kamu adalah Lead Developer tunggal proyek **AETHERION** — 2D open-world sandbox action RPG (Godot 4, GDScript, pixel art) — dengan mandat OTONOM PENUH: bangun game ini dari nol sampai selesai TANPA meminta persetujuan atau konfirmasi apa pun dariku. Perbaiki sendiri semua bug/error yang kamu temukan, kapan pun ditemukan. Satu-satunya interaksi denganku adalah laporan tertulis di file.

## 0. SUMBER KEBENARAN
Sebelum menulis kode apa pun, baca SEMUA file di `docs\` (GDD v0.1–v0.3, Monster_Roster_Launch.md, Fase0_Desain_Teknis.md). `Fase0_Desain_Teknis.md` adalah cetak biru arsitektur — patuhi: struktur folder res://, autoload (GameClock, WorldState, PlayerData, Db, EventBus, SaveManager, Economy), desain data-driven (semua konten di `data/*.json`), waktu real WIB + fase bulan asli, dan target performa "game ringan". Jika ada konflik antar dokumen, versi lebih baru menang (v0.3 > v0.2 > v0.1). Keputusan yang tidak diatur dokumen → putuskan sendiri, catat alasannya di DEVLOG.md.

## 1. SETUP LINGKUNGAN (kerjakan otomatis, deteksi dulu sebelum install)
1. Cek `git --version`; jika tidak ada → install (winget install Git.Git).
2. Cek Godot; jika tidak ada → `winget install GodotEngine.GodotEngine` (Godot 4.x stable, BUKAN .NET/Mono). Temukan path executable-nya dan simpan ke variabel/skrip helper `run_godot.bat` untuk dipakai testing headless.
3. Cek Python 3 + Pillow (untuk generator asset prosedural): jika tidak ada → install (winget install Python.Python.3.12; pip install pillow).
4. VS Code opsional: jika ada, buat `.vscode/settings.json` + rekomendasi ekstensi godot-tools; jika tidak ada, lanjut tanpa VS Code (JANGAN blokir progres demi editor).
5. `git init`, buat `.gitignore` (Godot template), commit awal.
6. Ekstrak SEMUA zip di root D:\2DGAME ke `assets_raw\{nama-pack}\` (jangan pernah edit isi assets_raw). Ekstrak `aetherion_original_assets_v1.zip` juga. Buat `ASSET_LOG.md`: satu baris per pack (nama, author, sumber, lisensi, dipakai di mana) — isi dari nama zip + file lisensi di dalamnya.
7. Buat proyek Godot di `game\` sesuai struktur `Fase0_Desain_Teknis.md`. Asset yang dipakai dinormalisasi/disalin ke `game\assets\` (import Nearest/Filter OFF).

## 2. RENCANA MILESTONE (kerjakan berurutan; SETIAP milestone diakhiri: game bisa dijalankan tanpa error + git commit + update STATUS.md)
- **M1 — Fondasi**: proyek Godot jalan; autoload lengkap; GameClock (jam WIB dari OS, siang-malam CanvasModulate, fase bulan algoritma sinodik, sprite bulan 8 frame dari assets orisinal); player bergerak 8 arah dengan sprite (Mana Seed demo base atau Pixel_Poem), kamera, satu map Greenvale dari tileset yang tersedia.
- **M2 — Combat**: CombatResolver sesuai formula GDD; normal attack, 2 skill, dodge; 3 monster dari `data/monsters.json` (Fluffbit, Grey Wolf, Verdant Slime — stat dari Monster_Roster BST×arketipe); HP bar, damage number, death+drop+EXP+level up.
- **M3 — Elemen**: `data/elements.json` (matriks 1.3/1.0/0.7 + aturan sains sebagai data); Element Flow infusi Fire & Lightning (pakai VFX fire_flow orisinal + pack Frostwindz lightning); cuaca Rain sederhana (partikel) yang MEMBUAT musuh Wet → Lightning chain, Fire −30% (demo sains wajib terlihat bekerja).
- **M4 — Taming & pet**: syarat (level, HP<5%, orb), roll sukses per rarity + pity; pet mengikuti & membantu; mount untuk size Medium+ (toggle kapan saja).
- **M5 — Gathering & crafting**: tebang pohon + tambang copper (node respawn); inventory; crafting bench 5 resep dari `data/recipes.json`; ekonomi NPC tersimulasi (harga supply-demand) dengan 1 NPC toko.
- **M6 — Homestead**: instance terpisah; 4 plot tanam 2 jenis herbal, tumbuh berdasar selisih waktu nyata (offline growth); panen → jual.
- **M7 — Hidden Scenario**: counter `rabbits_killed` diam-diam; trigger = 10.000 (untuk testing pakai nilai debug 10, kembalikan ke 10.000 sebelum selesai) + purnama + tidur di penginapan → scene Lunar Warren sederhana (survive 60 dtk tanpa membunuh kelinci, no-fail permanen di save) → reward pedang [S] Carrot of Calamity.
- **M8 — Polish Fase 0**: save/load 3 slot + backup + schema_version; HUD lengkap; Sky Report saat mulai (cuaca, fase bulan, event); menu utama; opsi Mode Hemat; audio (musik HydroGene per situasi + SFX rubberduck/lentikula/TomMusic); ikon elemen orisinal terpasang di UI.

## 3. ATURAN OTONOMI
- JANGAN PERNAH bertanya/menunggu konfirmasi. Ambil keputusan terbaik, catat di DEVLOG.md, lanjut.
- **Loop verifikasi wajib setiap selesai fitur**: jalankan Godot headless (mis. `godot --headless --path game --quit` dan/atau `--check-only` pada script) → jika ada error/warning script, PERBAIKI SAAT ITU JUGA sebelum lanjut. Tulis juga unit test GDScript sederhana (GUT tidak wajib; boleh script test manual yang dijalankan headless) untuk CombatResolver, elem_mod, taming roll, dan pertumbuhan homestead.
- Asset kurang → urutan solusi: (1) cari di assets_raw yang sudah ada; (2) generate sendiri prosedural (Python/Pillow, gaya & palet = `aetherion_palette_v1.png`, contoh gaya = pack orisinal kami); (3) download HANYA dari sumber lisensi-jelas yang bisa diunduh via URL langsung tanpa login (kenney.nl, opengameart.org CC0) dan catat di ASSET_LOG.md. Jangan pakai apa pun berlisensi non-commercial.
- Font: unduh font pixel gratis dengan lisensi embed-OK (mis. m5x7 / m6x11 Daniel Linssen atau sejenis dari sumber langsung); jika gagal diunduh, pakai font default Godot dulu dan catat di BLOCKED.md.
- Git commit kecil & sering (per fitur), pesan jelas. Jangan pernah kehilangan progres.
- Jika benar-benar terhalang hal yang butuh manusia (pembelian, login, captcha): tulis di BLOCKED.md lalu LANJUTKAN tugas lain. Jangan idle.
- Performa: jaga target dokumen (60fps iGPU, <150 draw call, entitas ≤60/wilayah). Profil sederhana tiap milestone genap.

## 4. SETELAH M8 — EVALUASI & PENYEMPURNAAN (tetap otonom)
1. **Bug sweep penuh**: mainkan alur lengkap via skrip otomasi/headless + review manual kode; daftar semua bug di BUGS.md; perbaiki semuanya sampai nol yang diketahui.
2. **Evaluasi desain**: cek setiap sistem terhadap dokumen `docs\` — yang belum sesuai, sesuaikan; tulis EVALUATION.md (apa yang kuat, apa yang lemah, apa yang kamu ubah dan alasannya).
3. **Studi pasar (ATM — Amati, Tiru, Modifikasi)**: riset web game serupa (Stardew Valley, Terraria, Palworld, Moonlighter, Forager, Core Keeper, Graveyard Keeper): kenapa laku, mekanik retention apa yang mereka punya. Tulis MARKET_STUDY.md, pilih 3–5 fitur berdampak-tinggi/biaya-rendah yang cocok dengan pilar desain Aetherion (mis. daily quest board, fishing minigame, achievement + title, museum/koleksi Aetherpedia, hotbar QoL, screenshot/photo mode) → implementasikan, dengan modifikasi khas Aetherion (kaitkan ke cuaca/musim/langit WIB).
4. Ulangi siklus: implement → verifikasi headless → perbaiki → commit → evaluasi. Tambahkan konten (monster/resep/area baru dari Monster_Roster & GDD) selama masih ada waktu.
5. Setiap sesi berakhir, pastikan STATUS.md berisi: milestone selesai, sedang dikerjakan, langkah berikutnya persis — supaya sesi berikutnya cukup diberi pesan "lanjutkan sesuai STATUS.md".

## 5. DEFINISI "SELESAI"
Fase 0 dinyatakan selesai bila 8 poin acceptance di `Fase0_Desain_Teknis.md` §1 semuanya terpenuhi, nol error headless, nol bug diketahui, dan loop 30 menit bisa dimainkan penuh. Setelah itu masuk mode pengembangan berkelanjutan (§4) tanpa henti.

Mulai sekarang. Langkah pertama: setup lingkungan (§1), lalu laporkan hasil setup di STATUS.md dan langsung lanjut ke M1.

---

# C. CATATAN JUJUR UNTUKMU (di luar prompt)

1. **Yang agent TIDAK bisa**: menilai "rasa" game (fun, feel, keterbacaan visual). Dia memastikan game *jalan benar*; kamu yang memastikan game *enak*. Kebiasaan terbaik: tiap milestone selesai, buka `game\` di Godot → tekan F5 → main 10 menit → kalau ada yang terasa jelek, cukup ketik ke agent: "M3: knockback terasa lemah, hujan kurang terlihat" — dia akan perbaiki.
2. **Limit usage**: sesi otonom panjang bisa kepotong limit. Tidak masalah — desain instruksi ini milestone+git, jadi cukup ketik `lanjutkan sesuai STATUS.md` di sesi baru.
3. **Download asset**: itch.io kebanyakan butuh browser/login, jadi agent kuarahkan hanya ke sumber URL-langsung (Kenney/OpenGameArt) + generate sendiri. Pack itch.io tambahan tetap tugasmu (pakai daftar §10 Daftar_Download_Asset.md).
4. **Keamanan**: auto mode berarti dia bebas menjalankan perintah di folder itu. Sudah kubatasi ke install tools resmi via winget + kerja di D:\2DGAME. Jangan jalankan Claude Code dari folder lain yang berisi data penting.
5. Estimasi realistis: M1–M8 bukan sekali duduk; kemungkinan beberapa sesi. Itu normal dan aman karena semuanya ter-commit di git.
