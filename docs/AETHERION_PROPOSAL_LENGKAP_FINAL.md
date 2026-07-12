# AETHERION — PROPOSAL & BLUEPRINT LENGKAP (DOKUMEN WARISAN)
**Versi: FINAL-SESI-1 · 2026-07-12 · Owner/Direktur: Liffyy (koze) · Designer: Claude · Builder: Claude Code Agent**
**Fungsi dokumen:** proposal game lengkap DARI NOL SAMPAI v1.0 SIAP DIMAINKAN — merangkum seluruh keputusan, sistem, ide, sejarah pengembangan, dan rencana. Dirancang agar sesi Claude BARU yang membaca dokumen ini memulihkan 100% konteks proyek.
**Cara pakai saat sesi baru:** upload file ini (+ PLAN_LEDGER.md & STATUS.md terbaru dari D:\2DGAME bila ada) → "lanjutkan proyek Aetherion sesuai dokumen warisan ini".

---

# BAGIAN I — RINGKASAN EKSEKUTIF

## 1.1 Apa itu Aetherion
**Fantasy Legacy Adventure RPG 2D** (pixel art, Godot 4, offline-first, GRATIS PENUH) di mana dunia berjalan mengikuti **waktu & langit WIB sungguhan** (jam nyata, fase bulan kalender lunar asli, tanggal astronomi asli), **menyimpan rahasia**, dan **mengingat semua yang pemain lakukan**. Pemain bukan pahlawan takdir — pemain adalah **pendiri**: membangun diri (build tanpa batas), membangun Domain (dari api unggun sampai kerajaan berpenduduk), dan membangun sejarah (Chronicle + pewarisan generasi).

- **North Star:** *"Kamu bukan pahlawan dari sebuah kisah — kamu pendiri dari sebuah sejarah."*
- **Tagline EN:** *"Be and build yourself in another world."*
- **Identitas sistemik:** THE WORLD REMEMBERS.
- **Slogan proyek:** "Aetherion bukan dunia yang menunggu pemain datang. Aetherion adalah dunia yang terus berjalan, menyimpan rahasia, dan mengingat apa yang dilakukan pemain."
- **Kiblat kompetitif:** Terraria (dungeon & progression dunia), Toram (skill tree bebas & crafting), Final Fantasy (dramaturgi & momen), Suikoden (rekrutmen & markas), Palworld (monster bekerja), Utopia Origin (hidup di dunia).
- **Model rilis:** v1.0 gratis penuh; monetisasi HANYA di fase online kelak (kosmetik anti-P2W) dan tak pernah menyentuh offline. Bahasa: pemain memilih ID/EN. Nada cerita: BERANI GELAP (kematian tragis NPC diizinkan; gelap emosional, bukan gore). Platform: PC dulu → mobile pasca-v1.0.

## 1.2 Tujuh Pilar (3 sistem + 4 pengalaman)
**Pilar Sistem (GDD asal):** (1) LIVING WORLD — cuaca/musim/langit/aksi pemain mengubah dunia; (2) IDENTITY THROUGH COMBINATION — kekuatan dari kombinasi class×elemen×monster×gear, bukan sekat; (3) PLAYER-DRIVEN — ekonomi & item terbaik lahir dari tangan pemain (crafted, bukan drop).
**Pilar Pengalaman (Piagam + Direktur):** (4) WONDER — dunia *menyimpan* (rahasia bertingkat); (5) BELONGING — dunia *menemani* (Domain & orang-orang); (6) STEWARDSHIP — dunia *menanggapi* (pilihan ber-trade-off; kerajaan = cermin moral); (7) LEGACY — dunia *mengingat* (Chronicle, generasi).

## 1.3 Loop inti
Per sesi: **PERGI** (bahaya/misteri/langit) → **PULANG** (bawa material/monster/ORANG/pengetahuan) → **TUMBUH** (Domain berubah terlihat). Per hidup: bertahan → identitas → Domain → desa → ekspedisi → era baru → **pewarisan generasi**.

## 1.4 Definisi berhasil
Pemain 150 jam berkata: "Aku punya kerajaan sendiri. Rakyat yang kuingat. Naga yang kutangkap saat Blood Moon. Pedang buatan pandai besi pertamaku — yang kini sudah tiada. Aku mempertahankan kotaku dari Behemoth bersama mereka. Kini aku bermain sebagai anak karakter pertamaku. Aku benar-benar merasa hidup di Aetherion."

---

# BAGIAN II — KONDISI PROYEK SAAT INI (jujur, per 2026-07-12 malam)

## 2.1 Angka
- Repo: **github.com/lifkieh/Aetherion** (public), riwayat bersih pasca-purge (history 5.7MB), tag: v0.1-alpha, v0.2-alpha, v0.2.1-alpha, v0.3-alpha (+ rounds sesudahnya di main).
- **467 test headless hijau** · exe standalone **89.5 MB** (< target 150MB) · 60fps iGPU dengan Mode Hemat.
- Konten hidup: **5 wilayah** (Greenvale hub, Candyveil, Desert of Ruins, Frostpeak + desa Pos Pendaki, Storm Island) · **5 dungeon side-view** · **5 boss terkoreografi** · **60 spesies monster** · **3 Hidden Scenario** · **28 pohon skill** · **10 class** (6 tempur + 4 kehidupan) · CharGen 7 ras · Rumah? belum — homestead tanam ada.
- Tata kelola: **PLAN_LEDGER.md = hukum tertinggi** (Bagian 1 status ~55+ sistem; Bagian 2 Decision Log 44+ baris), aturan permanen tertanam di memori agent (baca ledger tiap sesi awal; keputusan dicatat SEBELUM kode; penyimpangan tanpa keputusan = BUG DESAIN; baris "Exe terakhir" di STATUS tiap export; push tiap akhir bagian).

## 2.2 Sistem yang SUDAH TERBANGUN & TERUJI (implemented)
1. **Waktu & langit:** jam WIB asli; fase bulan sinodik (8 frame sprite orisinal); sky_calendar 11 event astronomi nyata 2026–27; siang-malam CanvasModulate; event harian NYATA: Golden Hour 17.00–18.30 EXP+10%, Morning Dew, 4 spesies nokturnal, **Blood Moon** penuh (purnama asli + malam acak; aggro×1.5, drop×2, langit merah, gerbang evolusi Ironhide Boar).
2. **Karakter:** creator modular **CharGen** (kepala/badan+tangan/kaki per ras, 7 ras, chimera bebas, warna kulit/rambut/baju; disimpan config JSON; 343 kombinasi teruji), Cermin Jiwa re-custom 150G; **ClassSelect dua tab**: JALUR TEMPUR (Warrior/Mage/Archer/Assassin/Paladin/Necromancer — bonus stat, 3 skill awal, 2 varian senjata, teaser advanced Lv60) & JALUR KEHIDUPAN (Perajin/Petani/Peramu/Penjinak — +50% EXP domain nyata, kit awal, perk, diskon 50% + node gratis pohon domain; wajib pilih 1 combat sub = 1 senjata + 2 skill); intro lore per class/jalur.
3. **Stat & progression:** 6 atribut (STR/AGI/VIT/INT/DEX/LUK) +5/level dialokasikan manual, respec NPC; profesi utama+2sub (sub cap 60%, efisiensi 75%, gate tier); kurva level = kompresi Fase 0 (akan direntangkan — level final TANPA CAP).
4. **SKILL TREE:** 28 pohon **terikat lokasi** (beli hanya di lokasinya; upgrade di mana pun): Common (Ketahanan/Olah Gerak/Meditasi/Kecakapan), Senjata×8, Elemen×8 dasar, Kehidupan (9), Khusus ber-BUKU (advanced class, Meteor★ULTIMATE dari first-kill Frost Titan); syarat node = tier level + prasyarat + **kaskade stat** + gold; rumor berarah untuk pohon jauh ("Kekuatan air sejati hanya diajarkan di kedalaman lautan..."); pohon Celestial tampil-terkunci di Menara Astrologer (buka via Hidden Scenario); Penjaga Pohon terpasang di 5 lokasi hidup + Homestead; 7 lokasi masa depan ber-flag content_locked.
5. **Combat (dua mode, satu resolver):** TANPA cooldown — hold-to-attack (rate senjata×AGI); prime angka → klik-kiri cast/CHANNEL (mana_cost×cast_rate; mana habis = klik kosong; regen surge idle 3dtk); angka sama = batal, klik kanan/ESC batal semua; fusion 2-elemen holdable, **3–4 elemen recast 0.7dtk** (satu-satunya CD; 4 resep triple + 2 quad hidup); **Grimoire** discovery (fizzle = "Fire + ? = ???", first-discovery banner+jingle); hit-immunity per-sumber anti-melt (0.2s/0.4s boss); 8 tipe senjata ber-moveset & arc-slash VFX berbeda + afinitas class; **Element Flow infusi mengubah bentuk serangan** per elemen (Lightning reach 1.5×, Fire arc besar, Earth sempit-berat) dengan drain mana; status ber-SAINS: Wet/Burn/Freeze/Paralyze/Poison/Blind + interaksi nyata (basah tak terbakar; petir hanya melumpuhkan yang basah; air memadamkan burn; poison memotong heal 50%; **Thermal Shock ×1.5** dari Freeze+Fire, es pecah); Combo window 2dtk +30% (data-driven); formula & cap dipublikasikan di tab Status.
6. **Mode dungeon Terraria:** side-view: gravitasi/coyote/jump-buffer; **tangga modern** (W/S menempel, lepas = menggantung, SPACE lompat-lepas, anti-nyangkut bibir atas); dinding TAMBANG + urat ore di dinding; gelap + obor; mouse-aim penuh (melee arc ke kursor, proyektil pooling data-driven projectiles.json); contact damage; knockback dua arah + i-frames + hitstop + screenshake (combat_feel.json); AI platformer (patrol/jumper/shooter kipas); 5 dungeon (Gua Greenvale/King Slime, Gummy Cavern, Barrow gurun, Foothill Barrow/Frost Titan, Zephyr Spire/Storm Sovereign).
7. **Boss:** intro bar+nama+stinger; fase 1 pola telegraf (leap/slam gelombang/burst cincin) + fase 2 (+dash & summon); arena hazard ber-elemen; **perayaan kill** slow-mo + jingle + banner + hujan loot fisik→magnet. First-kill unlock (Meteor).
8. **Monster:** 60 spesies BST×arketipe (Tank/Bruiser/Assassin/Caster/Support/Swift) — **0% jalan-nabrak** (pola per arketipe: lunge telegraf / flank+tusuk ganda / kipas proyektil); rank ★1–5 TAMPIL di UI+Pedia; trait per individu BEREFEK (mis. Berbisa); **mutasi 1/500** (emas, +10%, diverifikasi 6000 rol); taming (syarat HP<5% + orb; rate: C80/R40/E15/**L1.5/M0.5/A0.01%** + pity; gagal=enrage); pet ikut bertarung; **pet=mount** (size Medium+ + saddle, kapan saja, pasif 50%); **affinity hidup** (+1 assist kill, +5 makan; UI ranch); evolusi bersyarat langit (Dire Wolf→Alpha Wolf saat PURNAMA ASLI; Ironhide Boar saat Blood Moon; 11+ jalur evolusi); secret spawn: **Thunder Dragon** (malam+thunderstorm), Star Whale (kini BISA di-tame — keputusan B9).
9. **Dunia & kota:** kepadatan standar v0.2.1 (9+ bangunan berfasad Greenvale, 6 interior enterable, lampu malam, NPC berjadwal jalan + gosip SADAR-LANGIT, hewan); **konvensi pohon**: HANYA pinus berjenjang & batang-mati yang bisa ditebang (outline tebal, 1.12×) — sisanya dekorasi membulat; safe zone kota + **PENJAGA 1-HIT** (mendatangi monster dekat pagar, membunuh sekali pukul, PEMAIN NOL reward/EXP/drop/counter via guard_kill() — anti-exploit); landmark navigasi 4 arah; **Gerbang Penjelajah** "Pilih Dunia" (wilayah pernah dikunjungi, kartu + cuaca; 25G, gratis 1×/hari; belum dikunjungi = terkunci "datang dengan kakimu sendiri"); Homestead: tanam real-time WIB (offline growth), altar pohon Bertani.
10. **Hidden Scenario (no-fail):** Lunar Warren (10.000 kelinci + purnama + tidur; gagal=terkunci permanen; reward Carrot of Calamity [S]), Sugar Queen Tea Party (100 permen; kuis etiket 3-salah=diusir selamanya; Kue [S] + pet Peppermint Fairy + gelar), Star Whale Belly; counter generik ScenarioManager; trees_cut berjalan utk Forest Spirit (trigger belum dibuat).
11. **UI/UX modern-playful:** UiTheme JRPG biru-emas + font m5x7; UiFx (ui_feel.json): panel scale-fade, tombol hover naik+glow / press squash, kartu bounce, breathing, toast spring, micro-celebration; microcopy berkepribadian ID; HUD: panel karakter berpotret, widget jam+bulan+cuaca, minimap radar data-driven, hotbar berbingkai + rantai prime "1+2+5" + recast bar, quest tracker; inventory grid + tooltip banding hijau/merah; Grimoire tab; Pedia 60 monster + lore; damage number pop; Sky Report; onboarding 6 tip kontekstual + quest pembuka bercabang per jalur + NPC Pemandu + tab Panduan; pause menu + volume musik/SFX + fullscreen (persist); save 3 slot + autosave transisi + Continue + metadata; main menu berlatar blur + versi.
12. **Ekonomi (dasar):** gear 3 slot NYATA (tier F→E→D chain, +27–36%/tier), ekonomi NPC supply-demand, gold sink (travel/respec/pohon/craft), balance harness v2 dua-arah sadar-mana (BALANCE_TARGETS/REPORT; menemukan & memperbaiki: TTK kolaps antar level, formula MDEF, pack lethality; band: musuh 3-6dtk openworld, dungeon +15-25%, boss 2-4mnt, mage kering ~12dtk channel; death dungeon = respawn pintu −10% gold; chase openworld selalu escapable).
13. **Original assets (milik proyek, generator Python tersimpan):** palet 53 warna; Fluffbit 3 varian; 17 ikon elemen; 8 fase bulan; 12 Rasi Agung (BELUM dipakai kode!); tileset Candyveil; Star Whale 128×80; Fire VFX; 15 sheet NPC manusia; CharGen system; 11+ sprite monster ice; 5 sprite orisinal polish; SFX prosedural. Pack pihak-ketiga terunduh 19 (Kenney/Ninja Adventure/PIPOYA/Sprout Lands/Mana Seed demo/Shikashi/Frostwindz lightning/HydroGene music/dll — di assets_raw lokal, di-ignore git, tercatat ASSET_LOG).

## 2.3 Sejarah pengembangan (kronologi ronde)
Fase 0 M1–M8 (fondasi offline: clock/combat/taming/craft/homestead/scenario/save) → konten mandiri 3 wilayah → koreksi pohon & ras → v0.2 UI/UX besar (0: purge repo; 1: UI kit; 2: hotbar+fusion; 3: dialog FF+kota; 4: safe zone; 5: onboarding; 6: SKILL_AUDIT; 7: asset polish) → v0.2.1 World Density (akar "kosong" = kamera 3×→2×) → v0.3 (Frostpeak+desa+Barrow+Frost Titan; Storm Island+Zephyr+Storm Sovereign; Thunder Dragon; ras NPC; CharGen) → Power & Combat Calibration (stat, akuisisi skill, equipment, no-cooldown+loadout mana, harness v2) → **vonis owner "HAMPA"** → Foundation First (GAP_AUDIT skor 20/60; MASTER_IMPROVEMENT_PLAN; PLAN_LEDGER lahir) → v0.4.0 Identity&Juice (class selection, 8 senjata, Grimoire, autosave, juice, intro) → v0.4.1 Combat Depth (status effect sains, 0% jalan-nabrak, 5 boss upgrade, kedalaman monster tampak, event harian, Blood Moon, pause) → v0.4.1b Skill Tree lokasi + dua jalur (BD-1: koreksi hilang pra-ledger, diperbaiki) → v0.4.1c (**Gerbang 0 LULUS: "sudah tidak hampa"**; bug jalur kehidupan buntu; tangga; Gerbang Penjelajah; UI playful) → penjaga 1-hit → **Piagam Pengalaman** → **Master Blueprint v1.0 → v1.0.1 Director Approved (B1–B19)** → dokumen ini.

---

# BAGIAN III — DESAIN LENGKAP SEMUA SISTEM (kanon + rencana)

## 3.1 LIVING SKY (sistem gameplay terbesar)
- **Jam WIB asli** = jam dunia. Pagi 05–07 Morning Dew (herb+1); Golden Hour 17.00–18.30 (EXP+10%); malam = nokturnal & bintang fungsional.
- **Bulan:** fase kalender lunar NYATA. Purnama: pasang tinggi, werebeast, evolusi (Alpha Wolf), lelang istimewa. Bulan baru/sabit: surut ekstrem → dasar laut terbuka (jalur/gua/harta — kelak via elemen Moon). **Blood Moon** (purnama/acak-jarang): agresi+drop×2+langit merah+gerbang evolusi+serangan Domain (kelak).
- **sky_calendar tanggal asli:** solstice/equinox (skenario "Day of the Unsetting Sun", "Twin Gate"), meteor shower Perseid/Geminid (Star Ore, Star Whale), gerhana (gerbang Abyss, ritual Corona Sun+Moon), **live-event tahunan: bintang membengkak → SUPERNOVA (3 malam terang, drop Neutron Shard [SSS-path]) → lubang hitam = dungeon Void permanen** — disatukan dengan CELESTIAL CRISIS sebagai "Kalender Sejarah Dunia".
- **Musim (v0.4.3):** 4×2 minggu nyata — tanaman per musim, varian spawn, drop modifier, tint dunia; greenhouse untuk lintas musim.
- **Ramalan Rasi:** 12 Rasi Agung (Serigala, Paus, Pedang, Timbangan, Naga, Kelinci, Mahkota, Jangkar, Obor, Cermin, Benih, Gerbang; ASET SUDAH ADA) mengikuti musim langit asli; ramalan mingguan Astrologer = TEKA-TEKI konten aktif (kadang Ramalan Palsu penjebak); rasi kelahiran per karakter (bonus kecil + questline tahunan "Trial of the Rasi"); prakiraan cuaca 24 jam akurasi 80%.
- **Elemen & sains (aturan 80/20):** 17 elemen — dasar: Fire Water Wind Earth Lightning Ice Light Darkness; lanjut: Poison Metal Wood Spirit; langka: Void Sky; **Celestial: Sun Moon Star** (maks 1/karakter; via Hidden Scenario). Matriks ×1.3/1.0/0.7 + RULES sains data-driven: api butuh oksigen (air −50%, angin +25%), konduksi petir via air/logam + grounding Earth, korosi asam→Metal, fotosintesis Sun→Wood, pasang-surut Moon (trigger area/quest), cahaya-bintang-masa-lalu Star ("Letter from a Dead Star"), Steam dari Fire+Water, dst. 20% dijelaskan Aether.

## 3.2 ENAM LINGKUP BUDAYA (B19) & DUNIA
| Lingkup | Wilayah | Filosofi | Catatan |
|---|---|---|---|
| Aetheria | Greenvale, Candyveil, Desert, Frostpeak, Storm | Peradaban·Kerajaan·Rumah | 5 wilayah HIDUP sekarang |
| Wildhearth | kota beastfolk + Ancient Jungle | Kebebasan·Naluri·Monster | pohon Beast & Transformation |
| Celestia | ibukota semua ras + Menara Astrologer | Pengetahuan·Langit·Takdir | Cermin Jiwa pindah ke sini; grandmaster trees |
| Undersea | Ocean Kingdom | Adaptasi·Eksplorasi·Peradaban Hilang | breathing gear; pasang-surut nyata |
| Underground | Desert Ruins + tambang dalam + Abyss | Keserakahan·Ambisi·Rahasia | Dragon Ore di zona bahaya |
| Sky Realm | Skyveil (lautan awan ala Skypiea) | Harapan·Transendensi·Keabadian | naik via updraft/balon/mount terbang |
Wilayah penuh (13): +Emberfall Volcano, Ancient Jungle, Ocean, Skyveil, Abyss, Celestia, Wildhearth. Dungeon tematik terencana: Magma Heart (lava naik+heat gauge), Sunken Cathedral (kantong udara; surut membuka lantai), **Belly of the Star Whale** (ditelan saat memancing+meteor; asam naik tiap 5 mnt), Temple of the White Sea (awan rapuh), Abyss Rift (Void: api mati, gravitasi aneh). Berpindah lingkup = arsitektur, musik, dialek NPC, hukum, quest, pohon lokal berbeda.

## 3.3 KARAKTER, CLASS, SKILL (final)
- **Ras (CharGen):** human×2, wolfkin (digitigrade+moncong+ekor), lizardkin (crest+sisik+ekor), candyfolk, frostkin (tanduk es), undead — chimera per bagian tubuh sah. Kota utama Greenvale = 100% human (kanon); pemukiman lain ras tematik; Celestia = semua ras.
- **10 class (utama):** TEMPUR 6 + KEHIDUPAN 4 (wajib combat sub). Ganti utama: biaya+cooldown.
- **Level TANPA CAP (B10); all-in-one target 500+ jam.** Poin level → pohon. **Kaskade stat** = harga sejati.
- **ACTIVE LOADOUT (B10-A):** dipelajari ≠ dibawa — equip: 20–30 skill aktif (hotbar 5 memilih dari sini), slot pasif/ultimate/fusion terbatas; ganti di zona aman/Domain; preset bernama.
- **CAPSTONE eksklusif class (B10-B; bukan grinding — wajib class):** Warrior WORLDBREAKER (avatar perang momentum), Mage ASTRAL GENESIS (ledakan gabungan semua elemen dikuasai), Archer Panah Cakrawala (slow-aim tembus layar), Assassin Seribu Bayang (eksekusi teleport berantai), Paladin Sumpah Fajar (zona: ally & WARGA tak bisa <1 HP — sinergi pertahanan Domain), Necromancer **THRONE OF SOULS** (memanggil semua yang pernah dibunuh — DITENAGAI Chronicle), Perajin Karya Agung Sejati, Petani Panen Raya Abadi, Peramu Ramuan Sang Filsuf, Penjinak ANCIENT BEAST PACT (fusion penuh pet affinity tertinggi).
- **Gelar Hybrid** dari utama+sub (Beast Knight, Runesmith, dst — tabel data-driven). Advanced Class Lv60 questline per class. Gelar rahasia **"Yang Paripurna"** untuk penamat semua pohon (entri Chronicle).

## 3.4 COMBAT & ITEM (final — sebagian besar sudah hidup, lihat II.2.2 §5–7)
Tambahan rencana: (a) **Enchant +1..+10** crystal via profesi Enchanter BARU — gagal turun 1 TIDAK hancur; Protection Scroll craft; (b) **Coating/minyak Alchemist** (10 mnt, market); (c) **Quality roll** Normal/Fine/Masterwork + **maker's mark** (nama crafter di item — benih Legacy); (d) **TRANSENDEN A/S/SS/SSS**: craft-only **1%** + Insight +0.2%/gagal (cap +9%), piramida (A butuh item B + material kunci boss; S butuh A; SS butuh S; SSS butuh SS → segelintir di dunia), material kunci SUDAH drop (Everfrost Core[A], Tempest Heart[S], Ankh Fragment) — dibangun sebagai **MOMEN** (ritual, jeda dramatis, pengumuman, entri Chronicle); (e) **Rune** 4 slot pemain/2 monster (Epic+ 3), grade I–V, merge 3→naik (fase konten, pasangan loot dungeon); (f) durability/repair (prioritas rendah, sink); (g) **RUMAH LELANG NPC (B8):** lot ACAK harian + istimewa purnama/event; isi apa pun MAKS TIER A (S+ TIDAK PERNAH): item receh, buku skill, halaman grimoire, mount, pet/monster, herb, material, dan **"tawanan & kontrak"** — ditebus lalu DIBEBASKAN → mengingat kebaikanmu (World Remembers) → kandidat rekrutan loyal; bidding lawan NPC berkepribadian; gold sink + kejutan mingguan.

## 3.5 MONSTER (final)
Roster launch 64 (60 hidup) per wilayah — kerangka BST (C300→A800, growth 3–4%), rank ★, trait, affinity, mutasi, growth type; SEMUA spesies bisa di-tame (B9). Peran: pet/companion, mount, **WORKER Domain (B2)** — penugasan bangunan + sinergi elemen (Salamander→forge +20% peleburan; Golem→mining; Griffin→transport/kurir; penjaga malam; panen), guardian, racing (beku), **fusion player×monster** (fase depan: Tamer 50+, affinity 80+, bonus+skill: Lion Roar, Dragon terbang+breath, Phoenix rebirth, Golem DEF, Leviathan air). **Breeding** (fase depan): egg group, trait menurun, cross-species 5% (Storm Lion!), cooldown 3 hari, telur timer nyata. **Evolusi bercabang** + syarat langit. **RIVAL (spec v0.6):** musuh Rare+ lolos (HP<50%→kabur) → kembali berpangkat ★+1 (maks +2) + julukan + aura + "Kamu menyesal membiarkanku kabur." — maks 2–3 hidup; kill = reward+ + Chronicle; membunuh pemain = naik pangkat (cap).

## 3.6 DOMAIN (jantung — B1, v0.6)
**5 tier:** Camp (api unggun+tenda; menit 15 pemain) → Homestead (rumah+kebun+gudang) → Village (10–20 NPC) → Town (pasar+penjaga+workshop) → Kingdom (benteng+menara sihir+pelabuhan+arena). **Bukan base building — tempat lahirnya cerita.**
- **Rekrutmen ala Suikoden:** puluhan tokoh ber-syarat cerita unik (bukan beli); tinggal → layanan/bangunan/wajah baru; ikut EKSPEDISI.
- **LIFE EVENTS:** 4–6 peristiwa hidup ditulis-tangan per tokoh (menikah — bila si penjual bunga direkrut juga; murid datang; karya agung — bila dibawakan material; WAFAT — kanon nada gelap; penerus melanjutkan) ber-syarat waktu+kondisi dunia+hubungan → rasa simulasi, biaya quest.
- **Autonomous Kingdom (B11):** pemain pilih ARAH (Militer/Perdagangan/Pertanian/Pengetahuan) → NPC mengurus detail; tanpa micromanagement.
- **Stability v1 (B12):** Prosperity/Security/Ecology per wilayah (Loyalty+Stability menyusul) — cermin Stewardship.
- **Perayaan Legacy (B7):** quest besar/boss/milestone → festival (dekor+kembang api+musik), dialog menyebut pencapaian berhari-hari, entri Chronicle; skala ikut pencapaian. **Dunia maju saat ditinggal (B4):** panen menunggu (ada), penduduk berkembang, surat/kejadian, cerita kecil.
- **Pertahanan:** penjaga 1-hit (ada); serangan Blood Moon/boss ke Domain (rencana) — dipertahankan bersama rakyat.
- **EXPEDITION ENCOUNTER (boss raid-class):** Ancient Behemoth dkk — MEKANIKA besar (menghancurkan bangunan, pilar serentak, aggro ganda), butuh companion+pet+tentara+specialist 2–4+; solo hampir mustahil; boss reguler tetap solo-able.
- **Expansion (B13, v0.8+):** Frontier / Ancient Restoration / Political Integration (v1.1).

## 3.7 WORLD REMEMBERS & STEWARDSHIP (spec v0.6)
Memori NPC personal (dipukul→dingin, harga+20%, lapor penjaga, pulih lama/maaf berbiaya; ditolong→hangat, diskon, prioritas rekrutan) → reputasi kota agregat. Reaksi dunia: Forest Spirit (1.000 pohon → murka; menanam 1.000 → ujian damai "The Thousandth Tree"), migrasi overhunt, kota berkembang bila sering diselamatkan, biome berubah bila boss dibiarkan. Trade-off sadar di semua sistem alam; tidak ada pilihan sepenuhnya benar.

## 3.8 LEGACY (v0.5 benih → v0.9 penuh)
**Chronicle (Kitab Sejarah):** otomatis mencatat segalanya (kerajaan, perang, penemuan pertama-personal, companion, boss, Rival, generasi) — bisa dibaca, MENENAGAI sistem (Throne of Souls; syarat gelar), dicoret oleh Nirnama (horor). Aula patung, maker's mark. **LEGACY FAMILY (B3):** pensiun → pewarisan nama keluarga + Domain utuh + 1 artefak ber-riwayat + bonus kecil; leluhur = NPC/patung/entri; TIDAK memakan slot (3 slot = 3 dinasti); progres tak pernah reset — berganti era. **Dua-lapis:** offline sekarang → online kelak menyalakan first-discovery/kill/craft global dengan sistem yang sama.

## 3.9 CERITA (v0.5; gerbang: B17+B18)
**Tema: MEMORI vs PELUPAAN.** Pertanyaan sentral: *"Apakah sesuatu tetap layak dibangun walaupun suatu hari akan hilang?"* **SANG NIRNAMA** (nama kerja): pendiri pertama era lampau — kerajaannya megah, lalu Crisis terdahulu (supernova lama yang cahayanya kini "bintang mati") menghapus semuanya dan dunia LUPA; kesimpulannya: ingatan = kebohongan menyakitkan; penghapusan = kasih sayang → murid Void. Kekuatan: MENGHAPUS — NPC melupakan pemain (memori World Remembers dikosongkan), halaman Chronicle tercoret, wilayah memutih. **The Nameless Door = pintunya.** Ia MENGASIHANI pemain (melihat dirinya yang dulu). Tanpa Chosen One. **Celestial Crisis (B5)** = klimaks Act 1 (±jam-100): BULAN RETAK, NPC berhenti bekerja, monster berubah perilaku, rasi berubah, musik berubah, quest era baru — permanen. **B17 COMPANION BIBLE** (wajib pra-v0.5): 50 tokoh — 15 Tier-S companion, 15 Tier-A tokoh dunia, 20 Tier-B rekrutan; wajib identitas/relasi/tujuan/konflik/Life-Event-chain. **B18 NIRNAMA BIBLE** (wajib pra-Act 1): nama asli, sejarah, kerajaan asal, penyebab kejatuhan, relasi Crisis lama & Chronicle, alasan memilih pelupaan.

## 3.10 WONDER (kanon rahasia — RAHASIAKAN dari marketing)
Bertingkat: **remah** (solo-findable): The Forgotten Musician (NPC lagu beda tiap musim; ikuti 3 musim → quest), petunjuk lore/rumor/ramalan/gosip untuk semua scenario. **Legenda:** **The Nameless Door** (muncul 03:33 WIB + bulan baru + musim dingin — pintu Nirnama), **The Sleeping Giant** (gunung = boss hidup; kandidat raid), Night of Three Lights (supermoon+meteor → jalur SSS). Hidden Scenario hidup: Lunar Warren, Tea Party, Star Whale Belly (+rencana GDD: Gravekeeper's Debt, The Thousandth Tree, High Noon Pact, Day of the Unsetting Sun, Twin Gate, Letter from a Dead Star, Hunter's Trial rasi). Aturan: no-fail permanen; first-clear dirayakan; petunjuk samar wajib eksis utk tier-remah; 2–3 skenario baru per season TANPA patch note.

---

# BAGIAN IV — DETAIL DATA PENTING (angka yang sudah dikanonkan)

## 4.1 Formula inti (hidup di kode; cap dipublikasikan ke pemain)
```
Dmg Fisik = (ATK×SkillMod − DEF×0.6) × ElemMod × CritMod × (1−Resist)
Dmg Magic = (MATK×SkillMod) × ElemMod × CritMod × (1−MRes) − MDEF-mitigasi (fix ronde kalibrasi)
Hit = clamp(75% + (ACC−EVA)×0.3%, 60..100) · Crit base 5..60%, CritDmg 150..250% · PEN cap 40%
Skill: mana_cost × cast_rate (tanpa CD) · Fusion 3-4: recast 0.7s · hit-immunity 0.2s/0.4s(boss)
Elemen: kuat ×1.3 / netral ×1.0 / lemah ×0.7 + rules sains data-driven
```
## 4.2 Tabel kunci
- **BST monster:** C300 R360 E440 L540 M660 A800 (+3.0–4.0%/lvl); rank ★ ±3%/bintang; arketipe distribusi (Tank 30/12/25/5/20/8 dst).
- **TTK target:** common 3–6s · rare 8–15 · elite 25–45 · boss 2–4 mnt · dungeon +15–25% lethality · pack membunuh pemula 6–12s (sempat kabur) · mage kering ~12s full channel.
- **Taming:** C80 R40 E15 L1.5 M0.5 A0.01 (%) + pity kecil; orb bertingkat craft Alchemist; tamed ≠ drop/EXP.
- **Tier item:** F E D C B (umum) | A S SS SSS (Transenden craft-only 1% + Insight; piramida). Lelang maks A.
- **Profesi:** utama cap 99 / sub cap 60%, efisiensi 75%, gate tier B; +50% EXP domain jalur kehidupan; Penjinak juga +EXP saat aksi taming (8 sukses/3 gagal).
- **Loadout (B10-A):** aktif ter-equip 20–30 → hotbar 5; pasif/ultimate/fusion slot terbatas (angka final saat implementasi).
- **Ekonomi sink:** travel 25G (1 gratis/hari), respec, pohon skill (diskon 50% domain), lelang, enchant, Insight material; target sink ≥85–90% faucet (fase online).
- **Wilayah level:** Greenvale 1–15 · Candyveil 18–32 · Desert 12–25 · Frostpeak 22–38 · Storm 40–55 · (rencana) Emberfall 50–65 · Ocean 55–70 · Jungle 30–45 · Skyveil 70–90 · Abyss 85+ · Celestia hub 60–80.

## 4.3 Konvensi dunia yang DIKUNCI (jangan dilanggar builder)
Dua pohon tebang eksklusif (pinus & batang-mati) · kota utama 100% human · penjaga 1-hit tanpa reward pemain · guard_kill() tanpa sinyal · kill oleh penjaga tetap memberi tahu spawner · Transenden tak pernah dijual/lelang/drop jadi · Hidden Scenario no-fail & tanpa counter UI · exe selalu dicatat "Exe terakhir" di STATUS · gelap emosional bukan gore · teks baru ber-key lokalisasi.

---

# BAGIAN V — TEKNIS & PIPELINE

- **Engine:** Godot 4 GDScript · arsitektur data-driven (SEMUA konten JSON: monsters/items/skills/recipes/elements+rules/scenarios/skill_trees/projectiles/combat_feel/ui_feel/towns/classes) · logika sistem UI-free (server-authoritative-style, siap online).
- **Autoload (±19):** GameClock, WorldState, PlayerData, Db, EventBus, SaveManager, Economy, UiTheme, UiFx, Stage, SafeZone, Onboarding, CharGen, SkillTreeSystem, ScenarioManager, dst.
- **Save:** 3 slot + autosave + backup + schema_version + metadata; config karakter JSON (bukan PNG).
- **Lokalisasi (B15):** string-key + Godot TranslationServer; infra v0.4.4; pemain pilih ID/EN.
- **Performa (game ringan):** 60fps iGPU, Mode Hemat (matikan motion/VFX), exe <150MB (kini 89.5MB), pooling proyektil, culling seperlunya.
- **Repo & tata kelola:** GitHub lifkieh/Aetherion · commit per bagian + push tiap akhir bagian + tag per rilis · test headless (467) + balance harness v2 · PLAN_LEDGER hukum tertinggi (status ~55 sistem + Decision Log 44+; aturan: keputusan SEBELUM kode; penyimpangan tanpa keputusan = BUG DESAIN; baca ledger tiap awal sesi) · empat laporan Direktur (REPORT-01 Sinkronisasi+peta cakupan fitur, 02 Scope Risk, 03 Story Readiness, 04 v0.4.2 Readiness) sebelum implementasi besar.
- **Cara kerja tim:** Owner/Direktur (visi, playtest, keputusan) ↔ Designer Claude di chat (desain, review, direktif, asset orisinal, dokumen) ↔ Claude Code agent di terminal D:\2DGAME (build otonom; "lanjutkan sesuai STATUS.md" tiap sesi baru). Gerbang playtest owner tiap fase — pelajaran mahal: 3 ronde tanpa playtest = hampir salah arah.
- **Asset:** orisinal (generator Python di repo/tools) + 19 pack pihak-ketiga lokal (ASSET_LOG); artis manusia kelak memoles template TANPA mengubah sistem (config karakter JSON, palet resmi 53 warna).

---

# BAGIAN VI — ROADMAP LENGKAP KE v1.0 (+ sesudahnya)

| Fase | Nama | Isi (ringkas tapi lengkap) | Gerbang |
|---|---|---|---|
| **v0.4.2** | Gear & Economy | Transenden A–SSS sebagai MOMEN + Insight + piramida + material kunci boss terpakai; quality roll + maker's mark; Enchant +1..+10 + profesi Enchanter; Coating; **RUMAH LELANG NPC v1** (B8) | 4 REPORT Direktur → playtest owner |
| v0.4.3 | World Presentation | MUSIM penuh; RASI penuh (pakai 12 aset!) + ramalan mingguan + prakiraan cuaca; quest journal + penunjuk; world map; cutscene engine; dungeon chest/rahasia/trap/parallax/ambience; Forest Spirit trigger + perayaan first-clear; stinger musik; NPC jadwal | playtest |
| v0.4.4 | Modern Meta | Settings lengkap + keybind + gamepad; **infra lokalisasi ID/EN**; transisi UI; Advanced Class quest + Trial of Rasi | playtest |
| **v0.5** | STORY & SOUL ⭐ | GERBANG MASUK: **Companion Bible (B17: 50 tokoh)** + **Nirnama Bible (B18)** selesai → Act 1 Memori-vs-Pelupaan (villain menghapus: NPC melupakanmu, Chronicle tercoret, wilayah memutih), 3–4 companion utama hidup, boss-gating dunia ala Terraria, identitas musik + tema, momen sinematik, **benih Chronicle**, rahasia tier-legenda #1 (Nameless Door terpasang), nada BERANI GELAP | playtest cerita |
| **v0.6** | HEARTH & LEGACY ⭐⭐ | **DOMAIN 5-tier** + rekrutmen Suikoden + **LIFE EVENTS** + monster BEKERJA + arah Kingdom (B11) + Stability 3 (B12) + **World Remembers v1** (memori NPC + RIVAL + reaksi dunia) + **Ancient Behemoth** expedition + dunia-maju-saat-ditinggal + Perayaan penuh + Rune | playtest "Belonging" |
| v0.7 | HORIZON | Emberfall + Ocean Kingdom + dungeon ikonik (Magma Heart, Sunken Cathedral) + Wildhearth + pohon Beast/Transformation + rekrutan & rahasia per lingkup budaya | playtest |
| v0.8 | CELESTIA & CRISIS | Celestia Kingdom (kota terbesar, semua ras, grandmaster) + **CELESTIAL CRISIS: bulan retak** (gerbang Act 2, permanen) + supernova live-event + endgame chase S/SS + world boss + pohon Celestial via scenario + Expansion (B13) | playtest era |
| v0.9 | GENERATION | **LEGACY FAMILY penuh** (pensiun, pewarisan, artefak, dinasti, Chronicle dua zaman) + kurva level tanpa-batas final + Loadout matang + capstone lengkap + EN lengkap + polish | playtest legacy |
| **v1.0** | RILIS GRATIS | 10 checklist experience hijau (lihat 6.1) → itch.io publik | dunia |
| Pasca | ONLINE (fase 2–4) | marketplace async & Echo Vendor → co-op 2–5 & world boss bersama → guild/war/racing/gambling/marketplace pemain; **Legacy menyala global** (first-discovery dunia); monetisasi kosmetik anti-P2W; mobile port | — |

## 6.1 Checklist "SIAP DIMAINKAN" (10 perasaan — semua wajib hijau di v1.0)
30-menit-pertama paham & penasaran tanpa dijelaskan · tiap sesi 45mnt ≥1 momen PERGI-PULANG-TUMBUH · ≥1 rahasia ditemukan SENDIRI yang ingin diceritakan · rekrutan pertama = memenangkan seseorang · Domain berubah tampak tiap 2–3 jam · boss = cerita yang bisa diceritakan ulang · pulang setelah lama = ada yang menunggu · Chronicle membuat tersenyum membaca masa lalu sendiri · Act 1 tuntas + 1 momen sinematik terkenang + gerbang Crisis terpasang · pensiun & pewarisan berfungsi.

---

# BAGIAN VII — DAFTAR KEPUTUSAN KUNCI (Decision Log ringkas — detail penuh di PLAN_LEDGER repo)
#1–21 retroaktif (MMORPG→offline-first; no-cooldown→ekonomi mana; LPC ditolak→CharGen; kompresi level; Celestia=semua ras; 2 pohon tebang; kota utama human; MDEF fix; dst) · #22–25 review fase 0.4.x · #26 pola musuh per arketipe · #30–32 skill tree lokasi + Wildhearth + Penjinak XP · #33 BD-1 dua-jalur (bug proses pra-ledger) · #34–39 Piagam + penjaga + World Remembers spec · #40 GERBANG 0 LULUS ("sudah tidak hampa") · #41–44 v0.4.1c · **B1–B19 (blueprint v1.0.1):** B1 Domain 5-tier · B2 monster bekerja · B3 Legacy Family (tanpa makan slot) · B4 dunia maju saat ditinggal · B5 Celestial Crisis=FF Moment (disatukan supernova) · B6 tanpa Chosen One + boss=mekanika + expedition · B7 Perayaan · B8 Rumah Lelang (maks A; tawanan-dibebaskan) · B9 taming semua spesies · B10 level tanpa batas 500+ jam · B10-A Active Loadout · B10-B capstone eksklusif bernama · B11 Autonomous arah · B12 Stability 3 · B13 Expansion 3 jalur · B14 GRATIS PENUH · B15 lokalisasi pilihan ID/EN · B16 nada berani gelap · B17 Companion Bible 50 · B18 Nirnama Bible · B19 Enam Lingkup Budaya (KOREKSI: GPT menulis "B14", nomor benar B19).

# BAGIAN VIII — PARKIR IDE (disebut, belum kanon — jangan hilang)
Fusion player×monster detail (Lion/Dragon/Phoenix/Golem/Leviathan) · breeding & mutation lanjut + cross-species · racing 3 kategori + championship + betting parimutuel · gambling hall gold-only · marketplace/auction pemain + Merchant kios · guild/territory war · world boss rotasi + Void Emperor saat gerhana · profesi Treasure Hunter & Merchant & Carpenter penuh · housing decor · Photo Mode & title micro-buff & Echo Vendor & event kontribusi server (sebagian tercatat "Ada" ringan) · elemen Moon pasang-surut gameplay & Sun sundial puzzle & Star navigasi (spec GDD v0.3 §2 — kaya, siap pakai saat wilayahnya lahir) · mobile port · Anthropic API artifacts tidak relevan · nama sejati Nirnama & 50 tokoh (pekerjaan Bible) · angka final slot Loadout · harga/paket EN voice—tidak ada (teks saja).

# BAGIAN IX — INSTRUKSI SERAH-TERIMA (WAJIB DIBACA SESI BARU)
1. **File di D:\2DGAME:** repo game (game/, docs/ berisi GDD v0.1–0.3 + Monster_Roster + Fase0 + Daftar_Asset + MASTER_BLUEPRINT v1.0.1 + dokumen ini), PLAN_LEDGER/STATUS/DEVLOG/GAP_AUDIT/TRACKBACK/MASTER_IMPROVEMENT_PLAN di repo, assets_raw lokal, export/Aetherion.exe.
2. **Melanjutkan BUILD:** terminal → `cd /d D:\2DGAME` → `claude` → "lanjutkan sesuai STATUS.md". Agent membaca PLAN_LEDGER otomatis (aturan permanen + memori).
3. **Melanjutkan DESAIN (chat Claude baru):** upload dokumen ini (+ PLAN_LEDGER & STATUS terbaru) → "lanjutkan proyek Aetherion sesuai dokumen warisan ini". Peran Claude: Lead Designer/co-Director — review laporan agent, tulis direktif, buat asset orisinal, kerjakan Bible bersama owner, jaga ledger dari kecolongan.
4. **Antrean persis saat dokumen ini ditulis:** (a) owner paste direktif "PENGUNCIAN MASTER BLUEPRINT v1.0.1 + EMPAT LAPORAN" ke agent (blueprint→docs dulu); (b) agent hasilkan REPORT-01..04 → direview; (c) "gas v0.4.2"; (d) paralel di chat: mulai **NIRNAMA BIBLE + COMPANION BIBLE (B17/B18)** — pekerjaan designer×owner berikutnya.
5. **Pelajaran termahal proyek (jangan diulang):** keputusan yang tidak masuk ledger akan hilang (BD-1) · fase "rasa" tanpa playtest owner = membangun di atas asumsi · laporan hijau ≠ game enak · exe yang diuji harus dicocokkan baris "Exe terakhir" · GPT/AI lain boleh usul, tapi penomoran & konsistensi kanon dijaga designer.

— AKHIR DOKUMEN WARISAN. Aetherion menunggu untuk terus diingat. —
