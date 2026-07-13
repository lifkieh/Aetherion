# MASTER_IMPROVEMENT_PLAN — Aetherion (2026-07-12)

Semua gap dari `GAP_AUDIT.md`, diprioritaskan **dampak-ke-rasa ÷ biaya**, dikelompokkan
jadi fase v0.4.x. Estimasi dalam "sesi kerja" (1 sesi ≈ satu ronde kerja agen penuh).
Konten dunia baru tetap BEKU sampai owner membuka.

**Legenda dampak:** 🔥 = membunuh rasa hampa secara langsung; ⚙ = kedalaman sistem;
✨ = polish/meta.

---

## FASE v0.4.0 — "IDENTITY & JUICE" (= Tahap 2 direktif owner, DIKERJAKAN SEKARANG)

| # | Item | Dampak | Biaya |
|---|---|---|---|
| 2a | Class selection 6 class (senjata khas ×2 varian, 3 skill awal beda, bonus stat, teaser advanced) | 🔥🔥🔥 | Besar |
| 2b | Weapon moveset + arc slash VFX per tipe (8 tipe: sword/spear/bow/wand/dagger/hammer/staff/scythe) + afinitas class | 🔥🔥🔥 | Besar |
| 2c | Prime toggle & cancel (angka sama = batal; klik kanan/ESC = batal semua) | 🔥 | Kecil |
| 2d | Grimoire fusion (resep ditemukan + slot misteri + tutorial + perayaan discovery) | 🔥⚙ | Sedang |
| 2e | Save modern: autosave berkala + transisi + Continue + metadata slot | ✨✨ | Sedang |
| 2f | Juice pass combat: impact layering penuh, death dissolve + **loot burst fisik**, dodge VFX, damage pop | 🔥🔥🔥 | Sedang |
| 2g | 30 menit pertama: intro 3–5 layar, quest pembuka per-sistem ber-reward, class terasa menit 1 | 🔥🔥 | Sedang |

**Estimasi total: 1 sesi penuh (sesi ini).** Kriteria selesai: new game → pilih class
→ intro → 10 menit pertama terasa beda per class, setiap pukulan terlihat & terdengar.

---

## FASE v0.4.1 — "COMBAT DEPTH" (kedalaman yang dijanjikan GDD §6)

| # | Item | Sumber gap | Dampak | Biaya |
|---|---|---|---|---|
| 1 | **Status effect system**: Burn/Freeze/Poison/Paralyze/Blind + ikon di atas musuh + interaksi sains (Freeze+Fire=Thermal Shock benar-benar dari status) | Audit §1 #5 | 🔥⚙⚙ | Sedang |
| 2 | **Variasi attack pattern musuh**: minimal 4 pola baru data-driven (lunge telegraf, proyektil arc, spin AoE, summon kecil); target: <40% musuh "jalan-nabrak"; telegraf visual universal (flash + wind-up) | Benchmark 2.2 | 🔥🔥 | Besar |
| 3 | **Boss upgrade**: intro bar+nama+stinger, 3 pola per fase terkoreografi, arena mechanic per bos, perayaan kill (slow-mo + jingle + loot shower) | Benchmark 2.2 | 🔥🔥 | Besar |
| 4 | **Combo Skill window** (2 skill berurutan <2 dtk = bonus efek, data-driven) | Audit §1 #2 | ⚙ | Sedang |
| 5 | Publikasi cap & formula di UI (tab Status: "Crit 60% cap" dll.) | Audit §1 #4 | ⚙ | Kecil |
| 6 | **[ADDENDUM A7] Kedalaman monster TAMPAK**: rank bintang di UI target + Pedia, trait 1–2 per individu dengan efek nyata, **affinity pet hidup** (naik saat dipakai/diberi makan, tampil di ranch UI), **mutation 1/500** (recolor + bonus + nilai jual) | Addendum A7 | 🔥⚙⚙ | Sedang |
| 7 | **[ADDENDUM A6] Event harian BERISI**: Golden Hour EXP+10% nyata, Morning Dew herb+1 pagi, monster nokturnal (spawn gating malam), **Blood Moon penuh** (malam acak jarang → spawn agresif + drop ×2 + tint merah + gerbang evolusi/scenario) | Addendum A6 | 🔥⚙ | Sedang |

**Estimasi: 1.5–2 sesi.**

## FASE v0.4.2 — "GEAR & ECONOMY DEPTH" (alasan kembali ke kota)

| # | Item | Sumber gap | Dampak | Biaya |
|---|---|---|---|---|
| 1 | **[ADDENDUM A1] Crafting Transenden ujung-ke-ujung**: piramida A→S→SS→SSS (craft A butuh item B + material kunci; S butuh A; dst), success 1% + Insight +0.2%/gagal cap +9% (sudah ada), **resep pengolah untuk SEMUA material kunci [A]/[S] yang sudah drop** (Everfrost Core, Tempest Heart, Ankh Fragment), animasi ritual + pengumuman sukses | Addendum A1 | 🔥⚙⚙ | Besar |
| 2 | **[ADDENDUM A1] Quality roll** (Normal/Fine/Masterwork ±10%) + **maker's mark** (nama crafter tertera di item) | Addendum A1 | ⚙✨ | Kecil |
| 3 | **[ADDENDUM A3] Enchant crystal +1..+10** via **profesi Enchanter BARU** (gagal mulai +7 = turun 1, TIDAK hancur; Protection Scroll craft) | Addendum A3 | ⚙⚙ | Sedang |
| 4 | **[ADDENDUM A3] Coating/minyak Alchemist** (Venom Oil, Frost Coat; 10 menit; aturan elemen dominan + 25% sekunder) — melengkapi 4 jalur Element Flow | Addendum A3 | ⚙ | Kecil |
| 5 | Profesi yang hilang: **Enchanter** (untuk #3), lalu **Merchant** & **Treasure Hunter** (fase berikut bila ekonomi/dungeon sudah dalam) | Audit B | ⚙ | Sedang |
| 6 | **[B8 #53] RUMAH LELANG NPC** — offline, maks tier A, sumber tematik (termasuk tawanan-dibebaskan); sink & discovery ekonomi | Blueprint | 🔥⚙ | Sedang |

> **Rune System DIHAPUS dari fase ini** (Decision Log #28): ditunda ke fase pembukaan
> konten, dipasangkan dengan loot dungeon & slot monster Epic+. v0.4.2 fokus:
> Transenden (sebagai MOMEN, #25) + Enchant + Coating + Quality/maker's mark + Enchanter.

**Estimasi: 1.5 sesi.**

## FASE v0.4.3 — "WORLD PRESENTATION" (dunia yang bercerita) — ✅ **SELESAI 2026-07-13** (9/9 butir; Decision Log #83–#98)

| # | Item | Sumber gap | Dampak | Biaya |
|---|---|---|---|---|
| 1 | **Quest journal terpusat** + tujuan aktif + penanda arah di dunia/minimap | Benchmark 2.1 | 🔥✨ | Sedang |
| 2 | **World map** (per region + antar region) + fast travel gerbang/dermaga yang sudah dikunjungi | Benchmark 2.1 | ✨✨ | Sedang |
| 3 | **Cutscene mini engine**: Stage diperluas — gerakkan aktor, kamera pan, urutan skrip data-driven; dipakai untuk intro & event kunci | Benchmark 2.1 | 🔥 | Sedang |
| 4 | NPC hidup: jadwal pagi/sore/malam sederhana + dialog kontekstual (cuaca/waktu/progress) | Benchmark 2.1 | ✨ | Besar |
| 5 | Musik: stinger (level-up/quest/discovery/boss-kill), crossfade antar scene, track bos | Benchmark 2.1 | 🔥✨ | Kecil |
| 6 | Dungeon layak Terraria: **chest + ruang rahasia + trap** per dungeon, parallax bg, ambience khas, loot unik non-bos | Benchmark 2.3 | 🔥⚙ | Besar |
| 7 | **[ADDENDUM A4] MUSIM v1**: 4 musim × 2 minggu nyata di GameClock; efek minimal: tanaman homestead per musim (+greenhouse jalan keluar), varian spawn, drop modifier, tint dunia per musim | Addendum A4 | 🔥⚙ | Sedang |
| 8 | **[ADDENDUM A5] Ramalan Rasi penuh**: **pakai 12 aset rasi_*.png yang sudah ada** (langit malam + UI Sky), ramalan mingguan = teka-teki yang terhubung konten aktif minggu itu, bonus tematik birth sign (+2% kecil), prakiraan cuaca Astrologer 24 jam akurasi 80% | Addendum A5 + Audit B | 🔥✨ | Sedang |
| 9 | **[ADDENDUM A8] Forest Spirit** (trigger trees_cut, skenario penebusan v0.2 §8.2) + **perayaan first-clear scenario** (banner + patung/piagam + entri permanen) | Addendum A8 | ⚙✨ | Sedang |

**Estimasi: 2–2.5 sesi.** → **Aktual: selesai. Semua 9 butir terbangun + diuji (699 test, 0 gagal).**

## FASE v0.4.4 — "MODERN META" ← **ANTREAN BERIKUTNYA**

| # | Item | Dampak | Biaya |
|---|---|---|---|
| 1 | ~~Volume per channel + fullscreen~~ **SELESAI di v0.4.1** (tarikan review iii / Decision Log #23); sisa: slider Ambience terpisah, vsync, **keybind remap** | ✨✨ | Sedang |
| 2 | Gamepad support penuh (binding + navigasi UI + glyph) | ✨✨ | Sedang |
| 3 | ~~Pause menu khusus~~ **SELESAI di v0.4.1** (PauseMenu overlay) | — | — |
| 4 | UI transition pass: fade/slide panel, scene transition, hover state + SFX konsisten | ✨ | Sedang |
| 4b | **[B15 #62] Infra LOKALISASI penuh**: retrofit string lama ke key, pilihan bahasa ID/EN di Settings, en.json lengkap | ✨⚙ | Besar |
| 5 | Advanced Class Quest lvl 60 (janji teaser 2a dibayar) + Trial of the [Rasi] birth sign | ⚙✨ | Besar |
| ~~6~~ | ~~Rune System~~ — **DIPINDAH ke fase pembukaan konten** (Decision Log #28, dedup review designer) | — | — |

**Estimasi: 1–1.5 sesi.**

---

## Urutan yang disarankan & alasan

`v0.4.0 (sekarang) → v0.4.1 → v0.4.2 → v0.4.3 → v0.4.4`

- v0.4.0+v0.4.1 menyerang langsung 3 akar hampa teratas (identitas, bahasa visual
  combat, musuh membosankan). Sesudah dua fase ini game seharusnya *terasa* seperti
  action RPG.
- v0.4.2 memberi alasan ekonomi & loot untuk terus bermain (kedalaman janji GDD).
- v0.4.3 membuat dunia bercerita (presentasi Suikoden/Stardew).
- v0.4.4 merapikan standar modern; bisa dicicil paralel bila ada sisa kapasitas sesi.

Total estimasi ke "fondasi layak": **±6–8 sesi kerja** dari titik ini (naik dari 5–6
setelah addendum telaah designer memasukkan A1–A8).
Review owner+designer menentukan pemotongan/penambahan per fase.

> **Dokumen induk:** status seluruh sistem + riwayat keputusan kini dilacak di
> `PLAN_LEDGER.md` (aturan permanen di DEVLOG). Plan ini adalah turunan prioritas
> dari ledger; jika keduanya bertentangan, ledger yang benar.

---

## REVISI ROADMAP (Piagam owner, Decision Log #37 — detail di TRACKBACK.md)

Setelah v0.4.x di atas: **v0.5 STORY & SOUL** tetap target terbesar (+ Wonder
tier-legenda pertama + benih chronicle) → **v0.6 "HEARTH & LEGACY"** (Living HQ/
kerajaan = evolusi Pact, sistem rekrutan, companion AI, **World Remembers v1**
[spec di PLAN_LEDGER §8], Rune per #28) → **v0.7 Emberfall/Ocean** (bergeser) →
**v0.8 Celestia** → **v0.9 demo publik**. Racing/gambling/marketplace/MMO tetap beku.
Boss raid-class (mis. Sleeping Giant) butuh entourage 2–4 rekrutan; boss reguler
tetap solo-able (#36).
