# RAS_ONGKOS_SURVEI — Ongkos produksi 8 Ras Besar dari material LPC/ULPC

> **Tugas 3 (#233):** survei ONGKOS memproduksi tiap ras kanon dari `assets_raw/lpc/` + `lpc_extra/`.
> **Audit saja — nol sprite dirakit, nol wire, nol `game/`, 947 test utuh.** Survei 2026-07-17.
> Hukum ras (#86): *"Races Are Cultures, Not Stats"* — ras = penampilan/budaya, bukan bonus angka.
> Material dinilai dari katalog terbukti (`LPC_STRUKTUR.md`, `LPC_EXTRA_KURASI.md`).

## Skala ongkos
**READY** = lapisan siap, tinggal composite · **LOW** = 1 lapisan/recolor ada · **MEDIUM** = butuh
konvensi/recolor menengah atau re-anchor · **HIGH** = butuh lapisan BARU digambar (bark/sisik/bayang).

## Tabel ringkas
| Ras | Material di gudang | Yang kurang | Ongkos | Jalur termurah |
|---|---|---|---|---|
| **Human** | bases lengkap (♂♀/anak/teen/muscular/pregnant) + **skintone rework** (black/brown/olive/peach/white + babies) + elder heads | — | **READY** | composite langsung |
| **Elf** | `Long ears` + `elvenears_light` + `LPC Dark Elves` (lapisan telinga) | varian budaya | **LOW** | human base + lapisan telinga |
| **Beastfolk** | kepala wolf/boarman/minotaur (bases v3) + `wolfman`/`boarman` + `furry-ears-tails` + faun + cat ears/tail | konsistensi antar-suku | **LOW** | ganti kepala/ tambah telinga-ekor |
| **Astralborn** | **feathered wings ✅** + `starhat` + facial 2024 | badan/palet "langit" khas; glow | **LOW–MEDIUM** | human + sayap feathered + recolor terang |
| **Dwarf** | janggut ✅ (whitebeard dkk); baju/kapak ✅ | **badan pendek** (LPC tak punya) | **MEDIUM** | konvensi "pendek+janggut+lebar" atau skala badan (butuh re-proporsi frame) |
| **Shadeborn** | `imp`/`daemon`/`icy_demon` (gaya MONSTER, bukan warga); tanduk di beberapa pack | **badan warga bergaya bayang** (kulit gelap/asap, mata bercahaya) | **MEDIUM–HIGH** | recolor human ke siluet gelap + lapisan mata-menyala BARU |
| **Dryad** | `faun` (roh alam, tanduk/kuku) terdekat | **kulit kulit-kayu + rambut daun/ranting** (tak ada) | **HIGH** | faun recolor + lapisan bark/daun BARU digambar |
| **Tidekin** | `frogman` (amfibi) — **non-64-grid (480×864)** | **sisik/sirip/insang** LPC-grid; badan akuatik benar | **HIGH** | frogman re-anchor ATAU lapisan sisik/sirip/insang BARU |

## Rincian per-ras

**Human — READY.** Basis penuh + skintone rework (Death's Darling, CC-BY-SA, terverifikasi #233):
5 tona × dewasa/anak + babies. Elder heads ada. **Nol ongkos baru.**

**Elf — LOW.** Elf = human + **lapisan telinga panjang** (sudah ada, ULPC-grid). Dark Elves memberi
varian kulit gelap. *Cukup satu keputusan budaya (#86: elf tak monolitik) — bukan ongkos seni.*

**Beastfolk — LOW.** Kepala non-human (wolf/boar/minotaur/lizard) + furry-ears-tails + faun =
**suku beragam dari lapisan yang ada.** Ongkos = kurasi kepala, bukan gambar baru. *Ras paling kaya-bahan.*

**Astralborn — LOW–MEDIUM.** Sayap **feathered** (terbukti stack) + starhat + facial. Yang kurang cuma
**palet & glow** "makhluk langit" — pekerjaan recolor/shader ringan, bukan lapisan struktural baru.

**Dwarf — MEDIUM.** Semua pakaian/janggut/kapak ada, TAPI **LPC tak punya badan pendek**. Dua jalur:
(a) **konvensi** dwarf = tinggi-normal + janggut lebat + tubuh lebar (ongkos ~0, deviasi proporsi),
(b) **badan pendek** = re-proporsi tiap frame 64×64 (ongkos MEDIUM, tapi sekali untuk semua dwarf).
*Rekomendasi: (a) dulu, (b) bila Direktur menuntut siluet dwarf sejati.*

**Shadeborn — MEDIUM–HIGH.** Bahan yang ada (`imp`/`daemon`) bergaya **monster**, bukan **warga** —
melanggar rasa "ras yang dihuni". Butuh: **recolor human ke siluet gelap/berasap + lapisan mata-menyala
BARU**. Bukan mustahil (human base + palet gelap), tapi identitas visual harus digambar.

**Dryad — HIGH.** `faun` memberi "roh alam" tapi bukan **dryad-pohon**. Identitas dryad (kulit kulit-kayu,
rambut daun/ranting, urat kayu) **tidak ada lapisannya** — harus digambar sebagai lapisan ULPC baru
(kulit bark + rambut-daun). Faun bisa jadi basis pose, sisanya seni baru.

**Tidekin — HIGH (gap terbesar).** Satu-satunya bahan (`frogman`) **non-grid** → re-anchor mahal, dan
tetap "katak", bukan spektrum Tidekin (sisik/sirip/insang/ekor). Butuh lapisan akuatik BARU. **Ras paling
mahal** untuk dilahirkan dari gudang ini.

## Ringkas ongkos
- **Gratis/murah (4):** Human (ready) · Elf · Beastfolk · Astralborn.
- **Menengah (1):** Dwarf (konvensi gratis, badan-pendek menengah).
- **Mahal — butuh lapisan seni BARU (3):** Shadeborn · Dryad · Tidekin.

> **Implikasi:** LPC melahirkan **5 dari 8 ras** dengan ongkos rendah. **3 ras "non-humanoid-standar"
> (Dryad/Shadeborn/Tidekin)** menuntut lapisan digambar tangan — **itu bukan kegagalan LPC, itu batas
> wajar**: LPC dirancang untuk humanoid + fantasy-head, bukan makhluk-elemen. Ketiganya adalah tempat
> paling masuk akal untuk **satu artis kontrak / produksi terarah**, bukan mencari pack lain (tak ada
> pack CC yang menyediakan dryad-pohon/tidekin ULPC-grid siap pakai).
