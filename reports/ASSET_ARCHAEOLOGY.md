# ASSET_ARCHAEOLOGY — Peta Gudang Aset Aetherion

> **Tujuan:** memetakan SELURUH gudang `assets_raw/` **sebelum** memilih apa pun, agar
> Direktur tahu apa yang dimiliki, apa yang kurang, kandidat gaya standar, dan risiko lisensi.
> Disusun dengan **melihat gambar & membaca berkas lisensi**, bukan menebak dari nama file.
> Tanggal survei: 2026-07-16. Metode: ekstrak/list arsip, baca LICENSE/README/PDF, lihat sprite kunci.

> ⚠ **TEMUAN PALING PENTING DI ATAS SEMUANYA (baca dulu):** gudang ini **bukan greenfield**.
> Aetherion **sudah punya pipeline aset yang jalan** — `game/assets/game/` sudah berisi 233 PNG +
> 30 OGG + 8 WAV yang dipakai build sekarang, dan **Ninja Adventure (CC0) sudah de-facto jadi gaya
> rumah** (lihat `ASSET_CATALOG.md`). Jadi "keputusan gaya" yang Direktur tunggu **sebagian sudah
> terjadi dalam praktik.** Pertanyaan sebenarnya bukan *"gaya apa yang dipilih dari nol"* melainkan
> *"pertahankan Ninja 16px sebagai kanon, atau naik kelas ke look tiga-perempat beresolusi lebih
> tinggi (butuh re-art total + verifikasi lisensi)?"* — dijawab di §F.

---

## A. RINGKASAN BESAR

- **Total gudang `assets_raw/`:** **5,6 GB** — **23 arsip** + **7 folder ter-ekstrak**.
- **Komposisi kasar:** ~**5,4 GB audio** (96%), ~**115 MB sprite/pixel-art**, sisanya UI/font/tooling.
- **`assets_raw/` sudah di-`.gitignore`** → gudang mentah **tidak pernah** masuk repo/build. Benar.

| Kategori | Sumber utama di gudang | Volume |
|---|---|---|
| **Character** | Ninja Adventure (≈90 karakter), Pixel Crawler (modular paper-doll) | Kaya |
| **Tileset** | Ninja Adventure (20+ tileset), Cainos Top-Down, Aetherion candyveil | Cukup |
| **Object/Props** | Ninja Adventure (Items/Object/Weapons/Food…), Pixel Chest | Kaya |
| **Animal** | Ninja Adventure (Chicken/Cow/Pig/Dog/Horse/Cat/… 27 hewan) | Kaya |
| **Monster/Boss** | Ninja Adventure (Boss ×20, Monster), — | Sedang |
| **Portrait** | Ninja Adventure Faceset (38×38 per karakter) | Cukup (kecil) |
| **UI** | Kenney Fantasy-UI-Borders, Kenney input-prompts, Ninja Ui/Theme | Kaya |
| **Audio (musik)** | Abstraction loop-bundle (CC0), AlkaKrab ×8 pack, Ninja Musics | **Sangat kaya** |
| **Audio (SFX)** | 80-CC0-RPG-SFX, Kenney UI-audio, Minifantasy, Ninja Sounds | Kaya |
| **FX/VFX** | Ninja Adventure FX (magic/slash/smoke/elemental), Aetherion fire_vfx | Sedang |
| **Misc/Tooling** | Aetherion asset-generators (Python), palette, mockup | — |

---

## B. STYLE CLUSTERING

### Cluster A — "Keluarga Ninja Adventure" (16px JRPG hangat) — **GAYA RUMAH SAAT INI**
- **Ciri:** sprite 16×16, outline gelap tipis, shading lembut 2 tingkat, palet cerah-hangat, chibi
  imut, tiga-perempat ringan. Karakter walk 4-arah (down/up/left/right), portrait 38×38.
- **Jumlah:** 1915 PNG + 188 audio dalam satu pack. **Paling lengkap & paling koheren.**
- **Kelebihan:** CC0 penuh (aman repo publik); satu keluarga visual dari karakter→tileset→UI→SFX→musik;
  sudah dipakai build; ada tileset **desa terbengkalai** yang persis tema Ashbrook.
- **Kelemahan:** 16px = detail rendah; "imut", bukan "megah". Kurang cocok bila Direktur ingin nuansa
  Suikoden yang lebih sinematik. Portrait kecil (38px) — ekspresi terbatas.
- **Potensi:** tulang punggung seluruh game 2D sekarang & jangka menengah.

### Cluster B — "Tiga-perempat detail tinggi" (32px, sinematik) — **ASPIRASI, TAPI TAK LENGKAP**
- **Anggota:** Cainos *Pixel Art Top-Down Basic* (tile 32px, rumput/batu/pohon/nisan/sumur,
  perspektif tiga-perempat kuat, bayangan halus) · Pixel Chest Pack (peti beranimasi, resolusi besar).
- **Ciri:** lebih dekat ke referensi Suikoden/JRPG klasik dalam perspektif & kedalaman.
- **Kelebihan:** paling "indah", paling dekat target gaya tertulis Direktur.
- **Kelemahan fatal:** **tidak punya karakter** (Cainos = tileset+props+1 player saja);
  **lisensi tak jelas** (tak ada berkas lisensi di unduhan → per hukum kurasi = **TOLAK sampai
  diverifikasi**). Mengadopsi cluster ini = **re-art total** semua karakter/hewan/UI agar seragam.
- **Potensi:** referensi gaya + kandidat dressing area overworld **bila** lisensi diverifikasi
  dan tim siap memproduksi karakter senada.

### Cluster C — "Modular farming/adventure" (Pixel Crawler, 32px paper-doll)
- **Ciri:** base-body botak + layer (rambut/baju), animasi kaya: Idle/Walk/Run/Carry/Collect/Fishing/
  Death/Hit/Pierce ×4 arah. Ideal untuk sistem berpakaian.
- **Kelebihan:** modular (paper-doll) — cocok kanon "warga dewasa ideal modular"; animasi bertani.
- **Kelemahan:** lisensi Anokolisa custom (**boleh dipakai di game, TIDAK boleh redistribusi mentah**)
  → **tidak aman untuk repo publik**; gaya 32px **bertabrakan** dengan Cluster A 16px.
- **Potensi:** cadangan bila proyek pindah ke basis 32px modular (keputusan besar, bukan sekarang).

### Cluster D — "Placeholder generik proyek" (Aetherion original v1, 16px)
- **Ciri:** tileset candyveil/ikon elemen/rasi/moon-phase hasil script Python. Datar, mutu placeholder.
- **Lisensi:** milik proyek (CC0-kita). **Aman**, tapi mutu di bawah Cluster A.
- **Potensi:** ikon elemen & rasi bintang **tetap berguna** (tak ada padanannya di pack lain);
  tileset candyveil = placeholder sampai diganti seni tangan.

### Cluster UI — "Kenney" (CC0)
- Fantasy-UI-Borders (9-slice panel), input-prompts (glyph tombol), UI-audio (klik/hover). Netral,
  bersih, CC0. Cocok sebagai lapisan UI di atas gaya apa pun.

### Cluster Audio (dipisah dari visual — musik tak punya "gaya visual"):
- **A-Audio "Abstraction loop-bundle"** — **CC0**, mutu tinggi, ~264 loop (pre2023 + 6 kuartal +
  chiptune). Aman repo publik. **Bank musik teraman & terbesar.**
- **B-Audio "AlkaKrab" ×8 pack** — mutu produksi tinggi, **TAPI lisensi melarang redistribusi
  mentah & "open-source" tanpa izin** (lihat §Legal). ⚠ **Sudah dipakai build & ter-commit.**
- **C-Audio "Ninja Musics/Sounds"** — CC0, on-family, sudah ada. Ambient hujan/angin/sungai + musik
  berlabel (Lost Village/Melancholia/Lament).
- **D-Audio SFX** — 80-CC0-RPG-SFX (CC0) · Kenney UI-audio (CC0) · Minifantasy (**lisensi tak ada di
  unduhan → TOLAK**).

---

## C. HIDDEN GEMS (mudah terlewat, tapi terbaik di kelasnya)

1. **`TilesetVillageAbandoned.png` (Ninja, 320×192, CC0)** — **PERMATA #1.** Rumah-rumah lapuk
   ditumbuhi lumut, sumur tua, kayu retak. **Persis tema Ashbrook** ("desa yang mengecil tetapi
   masih hidup"). Satu file ini sendirian membenarkan seluruh pilihan gaya.
2. **Ninja Musics "26 - Lost Village", "16 - Melancholia", "29 - Lament", "7 - Sad Theme" (CC0)** —
   melankolis-hangat, **berlabel eksplisit**, langsung pakai untuk Ashbrook. Tak perlu menebak mood.
3. **Ninja Ambient `Rain/Rain2/Storm/Wind/River.wav` (CC0)** — menutup kebutuhan **suara hujan**
   (kanon opening: "hujan memimpin sebelum gambar") + ambience malam + sungai jembatan.
4. **Ninja `OldMan/OldWoman` sheet + Faceset (CC0)** — sosok tua untuk **Merrit Fane** (tragis) &
   **Old Bram** (lucu). Emosi jantung Ashbrook punya sprite senada.
5. **Abstraction `music-loop-bundle-chiptune` + `pre2023` (CC0)** — cadangan musik tak terbatas,
   bebas repo publik; banyak loop tenang/reflektif untuk Chronicle & wilayah masa depan.
6. **Kenney input-prompts (4752 file)** — glyph tombol keyboard+gamepad lengkap; menutup kebutuhan
   remap & UI gamepad (#158 BUG-3 dulu soal input) tanpa bikin sendiri.

---

## D. FUTURE POTENTIAL (per pack, lintas roadmap — bukan hanya kegunaan sekarang)

| Pack | Ashbrook | Greenvale | Ironvein | Observatory | Netherdeep | Kingdom | Companion | Monster | UI | Trailer/Marketing |
|---|---|---|---|---|---|---|---|---|---|---|
| **Ninja Adventure** (CC0) | ●●● | ●●● | ●●○ | ●○○ | ●●○ | ●●○ | ●●● | ●●● | ●●○ | ●●○ |
| **Cainos Top-Down** (lisensi?) | ●●○ | ●●● | ●●○ | ●●○ | ●○○ | ●●● | — | — | ●○○ | ●●● |
| **Pixel Crawler** (restricted) | ●●○ | ●●○ | ●○○ | — | — | ●○○ | ●●○ | ●○○ | — | ●○○ |
| **Pixel Chest** (lisensi?) | ●○○ | ●●○ | ●●● | ●○○ | ●●● | ●●○ | — | — | — | ●○○ |
| **Abstraction music** (CC0) | ●●● | ●●● | ●●○ | ●●● | ●●● | ●●● | ●●● | ●●○ | — | ●●● |
| **AlkaKrab music** (restricted) | ●●○ | ●●● | ●●○ | ●●○ | ●●● | ●●● | ●●○ | ●●○ | — | ●●● |
| **Kenney UI/audio/input** (CC0) | ●●○ | ●●○ | ●●○ | ●●○ | ●●○ | ●●○ | ●○○ | — | ●●● | ●●○ |
| **80-CC0-RPG-SFX** (CC0) | ●●○ | ●●● | ●●● | ●●○ | ●●● | ●●○ | ●○○ | ●●● | ●●○ | ●○○ |
| **Pirate Music Vol.2** (restricted) | — | — | — | — | — | ●●● (Veskar/laut) | ●●○ | ●○○ | — | ●●○ |
| **30 Sci-fi Space** (restricted) | — | — | — | ●●● | ●●○ | — | ●●○ | ●●○ | — | ●●○ |
| **Aetherion original v1** (CC0-kita) | ●○○ | ●○○ | — | ●●● (rasi/moon) | — | — | — | — | ●●○ (ikon elemen) | ●○○ |

●●●=inti · ●●○=berguna · ●○○=marginal · —=tak relevan. **Catatan:** Pirate & Sci-fi jelas dibeli
untuk **Veskar (laut, v0.7)** dan **Celestia/Void (v0.8)** — simpan, jangan buang.

---

## E. ASSET GAP REPORT (yang gudang BELUM punya)

**Sudah tertutup baik:** warga desa · anak · sosok tua · ternak (ayam/sapi/babi/anjing) · tileset
desa+desa-terbengkalai+alam+air · hujan/angin/sungai · musik melankolis · UI panel · glyph input ·
SFX tempur/UI · ikon elemen · rasi bintang & fase bulan.

**BELUM ada di gudang (perlu dicari/diproduksi):**
1. **Objek berdiri sendiri gaya Ashbrook:** **lentera/oil-lamp**, **papan nama pudar**, **bangku**,
   **air mancur**, **jembatan batu** sebagai sprite lepas. *Semuanya kini ada hanya menempel di dalam
   tileset* — cukup untuk tilemap, tapi tak ada sprite objek interaktif terpisah (lampu Merrit =
   sekarang dibuat prosedural dari ColorRect, bukan sprite).
   - 🔴 **4 objek-BUKTI A1/A2 (papan nama · bangku+cekungan · cangkir ×2 · kartu pos kosong) =
     GAP MEKANIK, bukan estetik** — bekasnya (`akibat`/`kebiasaan`/`benda`) yang dikonsumsi `restore()`
     tak terbaca dari aset gudang apa adanya. Audit + usul produksi: **`reports/ASSET_BEKAS_A1_A2.md`.**
2. **Portrait ekspresif besar** (untuk dialog Companion & tokoh utama). Faceset 38px terlalu kecil
   untuk emosi. Butuh portrait ≥96px atau ilustrasi.
3. **Arsitektur khas per-Kerajaan** (7 kerajaan wajib "feel different" — #207). Gudang hanya punya
   satu vernakular desa. Rosenhal/Durnhold/Lumeria/dst. belum ada bahan pembeda.
4. **Observatorium / Astral Observatory · kapal udara · monster laut · UI Chronicle** — nol bahan.
5. **Fairy Realm, Shadeborn, Astralborn** dan makhluk unik kanon — tak ada padanan.
6. **Aset tiga-perempat detail-tinggi berkarakter** — bila Direktur mau naik kelas dari 16px,
   TIDAK ADA satu pun pack berkarakter di gudang yang menyediakannya (Cainos tanpa karakter).

---

## F. STANDARD VISUAL CANDIDATE — kandidat gaya standar Aetherion

### Kandidat 1 — **Ninja Adventure 16px (CC0)** — *pertahankan gaya rumah* ✅ **REKOMENDASI**
- **Kelebihan:** CC0 (aman repo publik) · paling lengkap · satu keluarga koheren · sudah dipakai &
  divalidasi build · ada tileset desa-terbengkalai on-tema · skalabel (Godot upscale nearest).
- **Kelemahan:** 16px "imut", bukan sinematik · portrait kecil · butuh suplemen untuk arsitektur
  kerajaan & tema kosmik.
- **Risiko:** rendah. Gaya sudah terbukti; risiko utama hanya "kurang wah" untuk marketing.
- **Skalabilitas jangka panjang:** tinggi untuk konten desa/alam/monster; **rendah** untuk
  observatorium/kosmik/laut — itu perlu produksi baru apa pun kandidatnya.

### Kandidat 2 — **Cainos-style tiga-perempat 32px** — *naik kelas sinematik*
- **Kelebihan:** paling dekat target tertulis (Suikoden/JRPG klasik) · trailer lebih menjual.
- **Kelemahan:** **tanpa karakter** · **lisensi tak jelas** (TOLAK sampai diverifikasi) · mengharuskan
  **re-art total** karakter/hewan/monster/UI agar seragam — biaya produksi raksasa.
- **Risiko:** **tinggi.** Mengganti gaya di tengah jalan membuang aset yang sudah jalan; tanpa artis
  in-house untuk karakter 32px, proyek macet.
- **Skalabilitas:** tinggi secara estetik, **rendah secara realistis** untuk tim kecil/solo.

### Kandidat 3 — **Hibrida: Ninja 16px basis + Cainos-family sebagai overlay overworld**
- **Kelebihan:** pertahankan yang jalan, tambah kedalaman hanya di area "pemandangan" (overworld,
  jalan antar-kota #204) di mana karakter kecil relatif terhadap lanskap.
- **Kelemahan:** dua skala dalam satu game = risiko tabrakan visual (16px vs 32px berdampingan
  terlihat salah) · masih butuh verifikasi lisensi Cainos.
- **Risiko:** sedang. Bisa berhasil bila dibatasi ketat (overworld saja, tak pernah satu layar dengan
  sprite 16px besar) — tapi mudah bocor jadi berantakan.

### 🎯 REKOMENDASI PRIBADI (Art-Director Assistant)
**Kunci Ninja Adventure 16px CC0 sebagai gaya kanon Aetherion (Kandidat 1).** Alasannya bukan karena
ia paling indah — **karena ia satu-satunya yang sekaligus (a) lengkap, (b) koheren, (c) CC0-aman untuk
repo publik, dan (d) sudah terbukti jalan.** Hukum kurasi Direktur sendiri berkata **"GAYA MENANG ATAS
KUALITAS"** dan **"prioritas CC0"** — keduanya menunjuk ke sini. Ashbrook bahkan sudah punya permata
tileset desa-terbengkalai yang tak akan pernah kita dapat sebersih itu dari pack lain.

Cainos/Pixel Crawler **cantik tapi jebakan**: mereka menggoda naik-kelas yang, untuk tim tanpa artis
karakter 32px, berujung game setengah jadi dengan gaya belang. Simpan Cainos sebagai **referensi
aspirasi** di `_reference/` — patok mutu untuk hari nanti kalau ada artis, **bukan** ganti haluan hari
ini. **Gaya yang selesai mengalahkan gaya yang megah tapi tak pernah utuh.**

Satu koreksi jujur untuk Direktur: teks gaya kanon menyebut "Suikoden/RPG-Maker tiga-perempat".
Ninja Adventure **bukan** persis itu — ia lebih imut & lebih kecil. Ada **selisih antara gaya yang
dicita-citakan di atas kertas dan gaya yang sebenarnya sudah dikirim.** Itu bukan kegagalan — banyak
game bagus lahir dari aset CC0 imut. Tapi Direktur berhak tahu selisih itu ada dan **memutuskannya
sadar**, bukan menemukannya nanti saat trailer terasa "kurang megah".

---

## G. TES SILUET — dijalankan benar (ukuran layar · bersebelahan · di atas tileset)

> Tes siluet awal saya cacat: tiap sprite dilihat **sendirian, di-zoom, latar transparan** — persis
> anti-pola. Diulang benar (2026-07-16): **ukuran relatif sejati · bersebelahan lintas-pack · di atas
> grass tileset kandidat**. Referensi CC0 ter-commit: `assets_aetherion/_reference/siluet_test_ninja_cc0.png`.
> *(Komposit lintas-pack memuat Pixel Crawler (restricted) + Cainos (unknown) → **tidak di-commit**;
> hanya dijelaskan di sini.)*

**Tiga temuan:**
1. **Keluarga Ninja koheren di ground-nya sendiri.** Villager/OldMan/Child/Chicken duduk wajar di grass
   Ninja — satu palet, satu outline, satu kepadatan. Mereka **milik** tempat itu.
2. **Pack asing bentrok keras — mengunci "JANGAN hibrida".** Karakter Pixel Crawler (**30px, ~2×**
   tinggi Ninja 14px), lebih detail, kulit lebih merah-muda, di grass yang sama **terbaca dari game
   lain.** Ground Cainos (**32px, olive teredam**) vs Ninja (**16px, hijau terang**) = beda skala +
   palet + perspektif. *Ini bukti visual untuk §F: pilih SATU keluarga; mencampur = dua game.*
3. **⚠ TEMUAN BARU (disembunyikan oleh view-sendirian): siluet manusia Ninja nyaris kembar.**
   Diisi hitam, Villager/OldMan/Child = **blob bulat yang hampir tak bisa dibedakan** — mereka beda
   lewat **WARNA & detail wajah**, bukan **bentuk**. **Di ukuran layar sejati (zoom 2 ≈ 28px), wajah &
   warna tipis nyaris tak terbaca** → warga akan terbaca sebagai "orang yang sama, beda baju".
   **TAPI penutup kepala memecah siluet:** topi tinggi Noble & rambut tebal Villager2 **terbaca jelas
   di hitam**; ayam pun khas.

**Konsekuensi desain (actionable) — kunci BELONGING di skala 16px:**
> **NPC penting wajib punya HOOK SILUET** (topi · rambut · prop dibawa · postur), **bukan** hanya
> palet/wajah. Yang khas-bentuk terbaca dari jauh; yang khas-warna hilang.
Ini **memvalidasi & mempertajam** desain adegan yang sudah ada: **Merrit "duduk membaca surat di bawah
lampu"** = hook postur+prop (bukan wajah) — benar secara siluet. **Spoon Man** semestinya membawa
sendok (hook prop), dst. 5 NPC-kepribadian Ashbrook (#78) harus dibedakan **per-bentuk**, bukan per-warna.

## LAPORAN AKHIR — DIREKTUR + DESIGNER (ringkas; detail per-item di `docs/ASSET_LOG.md`)

### A. Kandidat terbaik per kebutuhan Ashbrook (alasan GAYA)
| Kebutuhan | Kandidat terpilih | Alasan gaya |
|---|---|---|
| Warga dewasa | Ninja `Villager1–6`, `Woman`, `Noble` | satu keluarga, 4-arah, palet hangat seragam |
| Anak-anak | Ninja `Child` | proporsi & outline senada warga |
| Sosok tua (Merrit/Bram) | Ninja `OldMan/OldMan2/3`, `OldWoman` | membawa berat emosi tanpa keluar gaya |
| Ayam / ternak | Ninja `Chicken`(4 warna)/`Cow`/`Pig`/`Dog` | imut-hangat, cocok desa hidup |
| Tileset desa | Ninja `TilesetHouse` + **`TilesetVillageAbandoned`** | permata on-tema "desa mengecil" |
| Batas hutan | Ninja `TilesetNature`/`TilesetField` | pohon/semak sekeluarga |
| Air/jembatan | Ninja `TilesetWater`/`TilesetRelief` | sungai Ashbrook |
| Objek (buku surat Merrit) | Ninja `Book.png` | ada; lampu/bangku masih GAP (§E) |
| Hujan (opening) | Ninja `Rain.wav`/`Storm.wav` | kanon "hujan memimpin" |
| Ambience malam | Ninja `Wind.wav` + `River.wav` | tenang, tak menutup keheningan |
| Musik melankolis-hangat | Ninja **`26 - Lost Village`** / `16 - Melancholia` | berlabel, on-mood, CC0 |

### B. Kebutuhan yang belum terpenuhi
Lentera/papan-nama/bangku/air-mancur sebagai **sprite objek lepas**; **portrait besar**; **arsitektur
per-kerajaan**; **observatorium/kapal-udara/monster-laut/UI Chronicle**. (§E untuk daftar penuh.)
→ Diproduksi sendiri atau dicari pack CC0 tambahan; **jangan** memaksakan pack beda-gaya.

### C. Konflik gaya
- **Ninja 16px ⟂ Cainos/Pixel Crawler 32px** — beda skala & kepadatan; **jangan campur di satu layar.**
- **AlkaKrab (restricted) ⟂ prinsip repo publik** — lihat peringatan legal di bawah.
- **Bila satu keluarga harus dipilih: pilih Ninja Adventure (CC0).** Alasan di §F.

### ⚠ D. PERINGATAN LEGAL — WAJIB DIPUTUS DIREKTUR
Build sekarang **meng-commit 9 OGG turunan AlkaKrab** ke `game/assets/game/audio/music/` di repo
`github.com/lifkieh/Aetherion`. Lisensi AlkaKrab (PDF): *"No reselling/redistribution of the track
as-is… for open-source games contact me for permission."* **Repo publik yang memuat file OGG mentah =
redistribusi as-is dalam proyek open-source** → berpotensi melanggar, **kecuali** izin tertulis
AlkaKrab didapat **atau** repo dibuat privat **atau** audio dipindah ke jalur rilis non-publik.
**Jalur aman yang sudah tersedia:** ganti ke **Abstraction (CC0)** + **Ninja Musics (CC0)** untuk
apa pun yang ter-commit. Ini **bukan** menuduh — ini menaikkan risiko jadi butir keputusan (#149:
diam = kelalaian). Sama untuk **Minifantasy SFX & Cainos & Pixel Chest**: lisensi tak ada di unduhan /
restricted → **jangan commit mentah** sampai jelas.

---

### E. PUTUSAN AKHIR — satu taruhan, tanpa pagar

**Rekomendasi saya: Cluster A (Ninja Adventure 16px CC0). Kalau Direktur memilih Cluster lain, risiko
terbesarnya adalah proyek harus me-*re-art* SELURUH karakter/hewan/monster/UI dari nol — dengan artis
karakter yang belum dimiliki — sambil membuang pipeline CC0 yang sudah jalan dan lisensi Cainos yang
belum jelas; hasil paling mungkin: Aetherion mandek bertahun di gaya belang setengah-migrasi, bukan
game yang lebih indah.**
