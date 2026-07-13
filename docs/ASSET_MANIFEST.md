# ASSET MANIFEST — kebutuhan aset hasil membaca seluruh Bible

**Kebijakan (perintah Direktur):** **FREE ONLY**. **Tidak ada unduhan** dari dokumen
ini — ia **manifest**, bukan daftar belanja yang dieksekusi agent. Direktur & designer
yang berburu link. Aset yang bisa **diproduksi sendiri** ditandai jelas: prioritas #1
adalah CharGen & prosedural, karena keduanya **gratis, konsisten gaya, dan sudah teruji**.

**Kolom sumber:** `CharGen` (sistem karakter modular kita) · `Prosedural` (generator
Python/GDScript gaya kita) · `Pack-free` (pack gratis yang sudah dimiliki) · `Dicari`
(belum ada — designer berburu) · `Owner` (keputusan desain dulu).

---

## (a) KARAKTER — ras & NPC

**Hukum yang menguntungkan kita:** *"Races Are Cultures, Not Stats"* (#86). Karena ras
= **budaya**, bukan angka, maka **mayoritas ras cukup dibedakan lewat template CharGen
+ fitur kecil** (telinga, tinggi, proporsi, palet, pakaian) — **bukan** sprite sheet
baru dari nol. Ini menghemat pekerjaan terbesar di manifest ini.

| Item | Kebutuhan fase | Sumber | Status |
|---|---|---|---|
| **Elf** (telinga panjang, proporsi ramping, palet dingin) | v0.7 (Sylvara) | **CharGen** (+ part telinga baru) | Murah — prioritas #1 |
| **Dwarf** (tinggi pendek, torso lebar, janggut) | pasca-v1.0 (Valkaris) | **CharGen** (+ skala tubuh + janggut) | Murah |
| **Dryad** (kulit kulit-kayu, daun sebagai rambut) | v0.7+ | **CharGen** (+ palet & "rambut" daun) | Murah |
| **Astralborn** (tanda langit, mata bercahaya) | v0.8 (Celestia) | **CharGen** (+ overlay glow) | Murah |
| **Tidekin** (sirip, insang, palet laut) | v0.7 (Azhur/Thalassar) | **CharGen** (+ part sirip) | Murah |
| **Shadeborn** (siluet pudar, tanpa wajah jelas) | v0.5 (The Erased) & v0.8 | **CharGen + shader** (desaturasi/alpha) | Murah — **dipakai Act 1** |
| **Beastfolk varian** (wolfkin/lizardkin sudah ada; tambah felinekin, avian?) | v0.7 (Nethrak/Wildhearth) | **CharGen** (part kepala/ekor) | Sedang |
| **NPC 3 tahap usia** (anak / dewasa / tua) — dituntut Aging | ⏳ v0.9 (**K1**) | **CharGen** (skala + palet rambut) | ⏳ tunggu K1 |
| **The Erased** — siluet pucat tanpa wajah | **v0.5** | **Prosedural/shader** | Prioritas Act 1 |
| **Heirs of Nothingness** — 5 varian ideologi (Angry/Broken/Scholars/Cults/True) | v0.8 | **CharGen** (+ jubah kultus, topeng) | Sedang |
| **Sang Nirnama** — sprite + **portrait close-up** (bible menekankan **matanya**) | v0.5 (siluet) → v0.8 (penuh) | **Dicari / Owner** (butuh art khusus) | 🔴 kritikal, unik |
| **The Last Witness** (naga dalam wujud humanoid) | ⏳ (>100 jam; identitas **PENDING Q7**) | **CharGen** (sengaja biasa saja!) | ⏳ jangan dibuat mencolok |
| **Pengungsi & korban perang** | v0.6 | **CharGen** (palet lusuh) | Murah |
| **Strange People** (peramal, penipu, penantang maut, orang kuat misterius) | v0.6 | **CharGen** — sudah ada pola 25 NPC persona | Murah |

---

## (b) MONSTER

| Item | Kebutuhan fase | Sumber | Status |
|---|---|---|---|
| **Anak serigala terluka** (First Monster kanon) | **v0.5** | **Prosedural/Pack-free** (varian `grey_wolf` kecil + darah) | 🔴 prioritas opening |
| **Monster multi-elemen** (1–3 elemen) — mis. Storm Wolf, Solar Lion, Void Frost Wolf | v0.7 | **Prosedural** (recolor + VFX overlay dari 60 monster existing) | Murah — gaya kita mendukung |
| **10 spesies Naga Kuno**: Flame · Storm · Ocean · Earth · Celestial · Spirit · Void (+**3 belum bernama — Q13**) | v0.7–v0.8 | **Dicari** (butuh sprite besar berkualitas) | 🔴 besar; 3 nama menunggu owner |
| **50 individu naga** — nama + entri Chronicle + portrait | v0.8 | **Owner** (desain) + portrait CharGen/dicari | Menunggu Bible |
| **Wujud humanoid Naga Kuno** | v0.8 | **CharGen** | Murah (setelah keputusan) |
| **Great Monsters** (6 kategori): Leviathan · Titan · Phoenix · World Beast (Spirit Whale) · Ancient Predator · **Void Colossus** | v0.8 | **Dicari** (skala raksasa) | Besar |
| **Beast Tribes**: Wolf Clans · Sky Roc Flocks · Ancient Serpent Nests · Titan Herds | v0.7 | **Prosedural** (varian dari roster) + camp tileset | Sedang |
| **Monster cerdas (tier 4–5)** — butuh penanda visual "ini bisa diajak bicara" | v0.7 | **Prosedural** (aura/ikon) | Murah |
| **Hewan "prey" non-monster** (rusa, dsb — basis rantai makanan Ecology) | v0.6 | **Prosedural/Pack-free** (Critter sudah ada) | Murah |
| **Monster bermigrasi / sarang** | v0.6 | **Prosedural** | Murah |

---

## (c) DUNIA — tileset & bangunan per budaya

| Item | Kebutuhan fase | Sumber | Status |
|---|---|---|---|
| **Ashbrook** (desa kecil dekat Greenvale — rumah Arlen Vale) | v0.5–0.6 | **Pack-free** (reuse Greenvale) | Murah |
| **7 tahap permukiman** (Camp → Homestead → Village → Town → City → Kingdom Capital → Great Civilization) — progresi **terlihat** | v0.6 | **Prosedural + Pack-free** (Town.gd sudah generatif) | 🔴 inti v0.6 |
| **3 Kingdom Personality** (Benevolent / Iron Dominion / Celestial) — palet + heraldik + dekorasi | v0.6 | **Prosedural** (palet + banner) | Sedang |
| **Sylvara** (hutan elf, perpustakaan tua) | v0.7 | **Dicari** (tileset hutan mewah) | Besar |
| **Valkaris** (kota dwarf, batu & tempa) | pasca-v1.0 | **Dicari** | Besar |
| **Azhur / Thalassar** (laut, kota bawah air) | v0.7 | **Dicari** (underwater — sudah tercatat di ASSET_LOG: ansimuz underwater) | Besar |
| **Nethrak / Wildhearth** (beastfolk) | v0.7 | **Dicari** | Besar |
| **Monster Kingdom NON-arsitektural** (wilayah, bukan kota — kerajaan naga = jaringan wilayah terbang) | v0.7 | **Prosedural** (marker + boundary + ambience) | **Murah** — justru lebih murah dari kota |
| **Institusi**: Merchant/Explorer/Adventurer Guild, Scholar Consortium, **Hidden Library** | v0.6 | **Pack-free** (interior reuse) | Sedang |
| **Bawah tanah**: pasar gelap, sarang Syndicate, kedai info broker | v0.6–0.7 | **Pack-free** (reuse dungeon/interior) | Sedang |
| **Agama**: kuil, arsip suci, ruang relik, jalur ziarah | v0.8 | **Dicari** | Sedang |
| **Militer**: benteng, kamp, kereta suplai, tenda medis, kamp pengungsi | v0.6+ | **Pack-free/Prosedural** | Sedang |
| **Wonders** (air terjun terbalik, pulau berpindah, gunung bernyanyi, laut bermimpi) — **sebagian TANPA fungsi gameplay** | v0.5+ | **Prosedural** (efek + ambience) | Murah, dampak besar |
| **Wilayah memutih** (kekuatan MENGHAPUS) | **v0.5** | **Shader** (mesin Forest Spirit dibalik) | Murah — sudah ada |
| **Reruntuhan "aktif kembali"** (tanda era akhir) | v0.8 | **Prosedural** (varian menyala dari ruin existing) | Murah |
| **Hutan tertebang / ekologi rusak** | v0.6 | **Prosedural** (varian tint + tunggul) | Murah — pola Forest Spirit |
| **The Nameless Door** (03:33 WIB + bulan baru + musim dingin) | v0.5 | **Prosedural** (prop tunggal + ambience) | Murah, ikonik |
| **Patung pahlawan / memorial** (Memory System) | v0.6 | **Prosedural** | Murah |

---

## (d) UI & AUDIO

| Item | Kebutuhan fase | Sumber | Status |
|---|---|---|---|
| **Panel 5 Atribut Kerajaan** (termasuk Ecology) | v0.6 | Prosedural (UiTheme) | — |
| **Reputasi lokal 6 tingkat** (Unknown→Legendary) — **per wilayah, bukan bar global** | v0.6 | Prosedural | 🔴 hukum kanon |
| **Influence 6 sumbu** (radar chart) | v0.6 | Prosedural | — |
| **Faction relation matrix** + 6 ikon tipe konflik | v0.6 | Prosedural | — |
| **Chronicle: entri fragmen/tercoret** (halaman rusak, catatan kontradiktif) | **v0.5** | Prosedural | Murah, tematik |
| **Peta yang bisa SALAH / belum dipetakan / berubah** | v0.6 | Prosedural (WorldMapUI ✅) | Sedang |
| **4 tingkat Discovery** (Common/Rare/Legendary/Mythic) — frame + VFX + SFX | v0.5 | Prosedural + Pack-free | Murah |
| **Kenney ui-audio & input-prompts** | ✅ **sudah dipakai** (v0.4.4) | Pack-free | Selesai |
| **Tema Nirnama** — *dingin & kosong*, **bukan** jahat/menakutkan | v0.5 | **Dicari** (AlkaKrab Piano/Ambient sudah di gudang) | Kandidat ada |
| **Tema naga sahabat** — hangat & tragis (kontras dengan Nirnama) | v0.8 | **Dicari** (Piano pack) | Kandidat ada |
| **Tema Great Monster** — leitmotif **bencana alam**, bukan boss heroik | v0.8 | Dicari (Sci-fi/Ambient pack di gudang) | Kandidat ada |
| **6 tema era** + tema gereja/choir | v0.8 | Dicari | — |
| **SFX Erasure** (wilayah lenyap — **bukan** ledakan; senyap) | v0.5 | **Prosedural** (silence + sub-bass) | Murah, signature |
| **4 lagu musiman Forgotten Musician** | v0.5+ | Dicari (Piano pack) | Kandidat ada |
| **Sting "Dunia Mengingat"** (reputasi naik tingkat) | v0.6 | Pack-free (stinger v2) | Murah |

---

## Ringkasan strategi produksi

1. **CharGen menanggung hampir seluruh kebutuhan ras** — karena ras = budaya, bukan
   stat. Yang benar-benar perlu dibeli/dicari adalah **naga, Great Monster, dan tileset
   budaya asing** (Sylvara/Valkaris/Azhur/Nethrak).
2. **Mesin yang sudah ada bisa dipakai ulang untuk kanon baru** — dan ini penghematan
   terbesar: *wilayah memutih* (Forest Spirit dibalik) = kekuatan MENGHAPUS;
   *ruang rahasia* = Hidden Dungeon; *Chronicle* = halaman tercoret; *rumor tak akurat*
   = legenda yang tidak pasti; *musim* = Living Dungeon yang berubah.
3. **Yang paling mahal & paling menentukan:** **portrait/sprite Sang Nirnama** (bible
   menekankan matanya — ini wajah game) dan **10 spesies naga**.
4. **Jangan dibuat mencolok:** The Last Witness harus tampak seperti orang biasa.
   Aset yang terlalu istimewa akan **membocorkan misterinya**.
