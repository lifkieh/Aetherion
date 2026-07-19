# SWEEP SELURUH GAME — apa yang bolong

**Sifat:** AUDIT. Nol perbaikan, nol commit selain laporan ini.
**Metode:** 21 scene di-instantiate & di-screenshot pada **siang hari (15:38 WIB)**, error muat
ditangkap dari runtime, lalu **dilihat satu per satu**. Ditambah sapuan statik seluruh rujukan aset.
**Gerbang:** 1026 lulus, 0 gagal — tak ada yang disentuh.

---

## Ringkas — apa yang paling merusak kalau pemain main HARI INI

| # | Temuan | Kelas |
|---|---|---|
| 1 | **Seluruh payoff core loop (R1/R2/R3) tak bisa dicapai pemain** | ⚪→🔴 |
| 2 | **Elyn tidak ada di dunia** — nol NPC, nol perpustakaan, nol laci | ⚪ |
| 3 | **8 dari 14 bukti tak ter-wire** — A2 Merrit nol, A1 Otha 1 dari 4 | ⚪ |
| 4 | **Homestead: 4 label "Tanam [E]" bertumpuk** jadi tak terbaca | 🔴 |
| 5 | `chicken.png` hilang — ayam Ashbrook jadi kotak 8×8 | 🔴 |
| 6 | 4 scene berlatar warna datar (StarWhaleBelly, LunarWarren, TeaParty, Homestead) | 🟡 |

---

## 🔴 1 — CORE LOOP TAK PUNYA JALAN PEMAIN (temuan terbesar)

Ini bukan aset hilang. Ini **seluruh tesis game yang tak tersambung ke tangan pemain.**

Terverifikasi lewat grep menyeluruh di `game/scenes/`:

| Fungsi | Dipanggil dari scene? |
|---|---|
| `Evidence.find()` — menemukan bukti | ✅ `Interactable.gd:172` |
| `Chronicle.strike()` — halaman tercoret | ❌ **NOL** (hanya test & autoload) |
| `Chronicle.restore()` — menulis ulang halaman | ❌ **NOL** |
| `Evidence.enough_for()` / `kinds_for()` | ❌ **NOL** |
| UI Kronik-kehilangan | ❌ **tak ada tab** |

**Artinya bagi pemain hari ini:** ia bisa berjalan ke 6 objek Ashbrook, menekan E, dan membaca
teks periksa. Bukti tercatat di memori. **Lalu tidak terjadi apa-apa — selamanya.**
Tak ada halaman yang tercoret, tak ada yang bisa ditulis ulang, tak ada Kronik yang bisa dibuka,
tak ada Elyn untuk menuliskannya.

`chronicle_losses.json` memuat **3 halaman nyata** — `person_otha_renn`, `person_merrit_fane`,
`place_ashbrook_besar`. Pemain bisa mencapai **0 dari 3.**

⚠ **Test-nya HIJAU** — `_test_core_loop_ashbrook_besar` memanggil `Chronicle.restore()`
**langsung**, bukan lewat pintu pemain. Persis bentuk hijau-palsu yang #151b larang, tapi
di lapisan *wiring*, bukan lapisan data. Testnya membuktikan mesinnya jalan; tak ada yang
membuktikan pemain bisa menyalakannya.

**Catatan:** tab "Aetherpedia" (`MenuUI.gd:544`) memang menampilkan `Chronicle.entries()`,
tapi itu **benih pencapaian #96** ("Pencapaian Tercatat"), bukan Kronik-kehilangan R1/R2/R3.
Dua sistem berbeda dengan nama sama.

## ⚪ 2 — Elyn tidak ada

`Elyn` hanya muncul di `autoload/Chronicle.gd`, `autoload/Evidence.gd`, dan `TestRunner.gd`.
**Nol** kemunculan di scene mana pun. Tak ada NPC Elyn, tak ada perpustakaan, tak ada laci.
A3 = 0% ter-wire. (Konsisten dengan #248 yang menahan laci sampai ruangannya ada —
tapi ruangannya masih belum ada.)

## ⚪ 3 — 8 dari 14 bukti tak ter-wire

| Ter-wire (6) | Tak ter-wire (8) |
|---|---|
| `ev_ashbrook_gudang_gandum` · `ev_ashbrook_halloran_200_roti` · `ev_ashbrook_jembatan_terlalu_lebar` · `ev_ashbrook_fondasi_rumput` · `ev_ashbrook_batu_fondasi` · `ev_otha_papan_bekas_cat` | `ev_otha_bangku_cekungan` · `ev_otha_jahitan_mantel_merrit` · `ev_otha_nyai_tuminah_kamis` · `ev_merrit_kartu_pos_kosong` · `ev_merrit_cangkir_kedua` · `ev_merrit_rute_pos_berubah` · `ev_merrit_arlen_ingat` · `ev_ashbrook_bram_ingat_ayahnya` |

**A1 (Otha): 1 dari 4. A2 (Merrit): 0 dari 4.** Teksnya sudah ditulis, objeknya belum ada di dunia.
`ev_otha_bangku_cekungan` menunggu sprite bangku-cekungan yang memang sengaja ditunda.

## 🔴 4 — Homestead: empat label bertumpuk

Empat petak tanam berjajar rapat, masing-masing memunculkan label `Tanam [E]` pada Y yang sama →
terbaca `Tanam [Tanam [Tanam [Tanam [E]`. **Tak terbaca sama sekali.**
Terlihat jelas di `_work/sweep/Homestead.png`. Ini rusak yang dilihat pemain, di scene yang
memang dipakai berulang (bertani).

## 🔴 5 — `chicken.png` hilang (satu-satunya aset benar-benar hilang)

`AshbrookChicken.gd:45` memuat `sprites/props/chicken.png` — **tak ada**.
Seni aslinya ada, tapi di `sprites/animals/chicken.png` (32×16). Jadi ini **jalur salah**,
bukan seni hilang. Pemain melihat kotak 8×8 di tempat empat ayam gudang gandum —
padahal ayam itu justru "kehidupan" pasangan dari reruntuhan gudang (Hukum Tertinggi #206).

## 🟡 6 — Placeholder yang jalan tapi datar

| Scene | Yang terlihat |
|---|---|
| **StarWhaleBelly** | latar merah gelap rata + 3 `ColorRect` olive sebagai rintangan |
| **LunarWarren** | latar hijau gelap rata bergaris, nol ubin tanah, kelinci mungil |
| **TeaParty** | latar merah muda **rata penuh layar** + tombol pilihan |
| **Homestead** | rumput rata, petak = kotak cokelat polos, tepi ladang langsung ke hitam, portal = gumpalan ungu |
| **Ashbrook** | air mancur & jembatan masih `ColorRect` (`Ashbrook.gd:196-218`) |

---

## ✅ UTUH & bisa dimainkan

**21 scene di-instantiate: 21 berhasil, 0 crash, 0 error muat aset.**

- **Dunia:** Ashbrook (kini berdiri di atas tanah), Greenvale/`Main`, Frostpeak, Desert,
  Candyveil, StormIsland, HouseInterior — semua bertileset penuh dan berpenghuni.
- **Dungeon:** GreenvaleDepths, GummyCavern, Barrow, FoothillBarrow, ZephyrSpire — lima-limanya
  tampil konsisten (side-view, tangga, obor).
- **UI:** MainMenu, ClassSelect, CharacterCreator, Intro, HUD, 11 tab MenuUI
  (auction · crafting · echo · enchant · inventory · panduan · quest · shop · skill · sky · trees).
- **Aset terverifikasi lengkap:** font `m5x7.ttf` ✅ · **126 dari 126** ikon item resolve ✅ ·
  17 ikon elemen ✅ · 8 fase bulan ✅ · 27 glyph input ✅ · audio 18 musik + 48 sfx + 10 stinger ✅.

### Yang sempat saya kira rusak, ternyata tidak

Dicatat supaya tak diaudit ulang:
- **`DungeonTerrain` blank** — bukan bug. Ia sub-komponen yang di-`instantiate` oleh
  `DungeonBase.gd:36`, bukan scene yang dimasuki pemain.
- **Ikon item** — sempat terbaca "125 dari 126 hilang". **Salah saya:** `Db.item_icon()`
  memetakan ke **kategori** (`item_sword`, `item_potion`, …), bukan ke id item. Semua resolve.

---

## Urutan yang saya sarankan

1. **Sambungkan core loop** (#1) — semua yang lain sia-sia kalau pemain tak pernah sampai payoff.
   Minimal: satu jalur `strike → periksa → restore` yang bisa disentuh, plus tempat melihat Kronik.
2. **Homestead label** (#4) — perbaikan termurah dengan dampak langsung; pemain bertani berulang.
3. **`chicken.png`** (#5) — satu baris path, ayamnya sudah ada.
4. **Sisa bukti A1/A2** (#3) — teksnya sudah ditulis; yang kurang objek di dunia.
5. **Placeholder** (#6) — terakhir. Jelek tapi jalan; #1 rusak tapi tak terlihat.

**Pola yang berulang lagi:** empat dari lima temuan teratas **tak terdeteksi test mana pun**,
dan tiga di antaranya cuma ketahuan dari **melihat layar** atau dari **grep siapa-memanggil-siapa**.
Test membuktikan mesin bekerja; ia tak pernah membuktikan mesin itu **tersambung**.
