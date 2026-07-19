# VERIFIKASI WREN — sebelum garis keturunan Elyn dikunci (#267)

**2026-07-20** · gerbang yang Direktur pasang: *"Jangan tebak — lapor."*
**Putusan yang saya minta: GARIS BARU. JANGAN realokasi Wren.**

---

## Apa yang dicari

Apakah "tiga keturunan Wren" (`companion_02:99`) bisa direalokasi menjadi keturunan Elyn,
atau garis keturunan Elyn harus baru?

Diperiksa: seluruh `docs/` (md + txt), `NIRNAMA_BIBLE_PUBLIC.md` (B18), `COMPANION_BIBLE.md`,
15 sheet companion, `TIME_LEGACY_SPEC.md`, `RAS_KANON.md`, dan seluruh spec R1/R2/R3.

---

## Temuan 1 — **Wren tidak punya sheet. Ia hanya ada di dua baris.**

| Lokasi | Isi |
|---|---|
| `companion_02:39` | asal-usulnya |
| `companion_02:99` | entri `RELASI PENTING` |

**Nol penyebutan di B18.** Nol sheet companion. Nol entri di `COMPANION_BIBLE.md`.
Ia bukan tokoh — ia **alat ukur waktu** untuk menjelaskan Elyn.

## Temuan 2 — **Wren MANUSIA, dan hubungannya PEMBACA–ARSIPARIS, bukan keluarga**

> `companion_02:39` — *"Ada seorang gadis **manusia** bernama **Wren** yang datang membaca pada
> usia sebelas. Elyn menuliskan namanya di **kartu pinjam**. Wren tumbuh, membawa putrinya.
> Putrinya tumbuh, membawa putrinya."*

Empat generasi: **Wren → putri → cucu**. Realokasi berarti menyatakan Elyn (elf) adalah leluhur
sebuah garis **manusia** yang ia kenal sebagai **peminjam buku**. Itu bukan penyesuaian; itu
mengganti tokohnya.

## Temuan 3 — 🔴 **"Kartu pinjam Wren" SUDAH JADI BUKTI `benda` KANON di TIGA spec**

| Spec | Baris | Isi |
|---|---|---|
| `R1_SPEC_TEKNIS.md` | 54 | *"`benda` — benda fisik yang selamat: surat Merrit · **kartu pinjam Wren** · lentera Sora"* |
| `CHRONICLE_RESTORATION_SPEC.md` | 114 | *"**BENDA** … kartu pinjam Wren … Benda tidak punya ingatan untuk dihapus"* |
| `CANON_219-230_FINAL.md` | 184 | *"**`benda`** \| benda tak punya ingatan untuk dihapus \| surat Merrit · **kartu pinjam Wren**"* |

**Ini yang membuat realokasi mahal.** Kartu itu berfungsi sebagai bukti karena ia adalah
**jejak seorang perempuan biasa yang tak punya siapa-siapa selain Elyn** — persis Hukum
Ordinary People (`B18:210-219`). Jadikan Wren keluarga Elyn, dan bukti itu berubah dari
*"orang asing yang tetap dicatat"* menjadi *"catatan keluarga sendiri"* — yang justru
**membalik maknanya**, dan melemahkan kind `benda` di tempat ia paling kuat.

## Temuan 4 — Garis Wren **masih hidup di masa kini**

> `companion_02:39` — *"**Hari ini cucunya duduk di kursi yang sama**, tidak tahu bahwa nama
> neneknya ada di laci Elyn."*

`:99` menyebut relasi itu *"seluruhnya sudah selesai sebelum pemain tiba"* — yang **selesai**
adalah hubungan Elyn–Wren, bukan garisnya. **Cucu Wren adalah NPC yang tersedia hari ini**
dan belum dipakai siapa pun. Itu aset, dan realokasi membakarnya.

## Temuan 5 — Gambar terkuat tokoh ini bergantung pada Wren **bukan** keluarga

> `companion_02:99` — *"Satu kartu pinjam. Satu nama. Empat generasi. Ia menyimpan kartu itu
> bukan sebagai arsip — **sebagai kubur.**"*

Kekuatannya justru karena Wren **bukan siapa-siapa baginya**. Seorang elf yang menyimpan kartu
pinjam **orang asing** seperti kuburan = seluruh tesis Ordinary People dalam satu benda.
Jadikan Wren cucunya sendiri, dan itu jadi kesedihan keluarga biasa.

## Temuan 6 — 🟠 Tabrakan terpisah: **TIME_LEGACY_SPEC menyarankan elf mewariskan lewat MURID**

> `TIME_LEGACY_SPEC.md:199-200` — *"**Elf & pewarisan:** … **Rekomendasi: tidak — ia mewariskan
> lewat MURID, bukan anak.** Itu justru memperkuat L14 (kesempatan, bukan darah)."*

**Status: rekomendasi, BELUM diratifikasi.** Tapi #267 bergerak berlawanan arah dengannya, dan
konsekuensinya menyentuh Sora: `companion_02` LEGACY PATH butir 3 menyebut Sora
*"legacy yang berjalan dengan dua kaki dan membawa lentera"*. Kalau darah masuk, **murid
kehilangan monopolinya**. Perlu putusan sadar, bukan efek samping.

## Temuan 7 — 🟠 Prasyarat teknis penuaan belum terpenuhi

| Fakta | Sumber |
|---|---|
| Elf: prima **110–300**, **menua 301–500**, sepuh 501+, harapan hidup ~600 | `TIME_LEGACY_SPEC.md:66` |
| Elyn **134** = awal prima → **167 tahun** ke ambang "menua" | `TIME_LEGACY_SPEC.md:75` |
| Penuaan hanya lewat **lompatan**, selalu **beradegan**, tak pernah notifikasi | `TIME_LEGACY_SPEC.md:178,198` |
| Aging/generasi/suksesi terkunci di **v0.9** | `IMPLEMENTATION_ROADBOOK.md:143-149` |

**`ELYN_YEARS_PER_PAGE = 1` tak akan pernah menyeberangi ambang 301.** Untuk penuaan yang
*terlihat*, laju harus jauh lebih besar — atau "terlihat" harus didefinisikan ulang sebagai
**penyeberangan ambang**, bukan hitungan tahun. Angka itu belum ada di dokumen mana pun.

⚠ **Dan satu ketidakcocokan status:** `TIME_LEGACY_SPEC.md:13-15` mencatat K1=c sebagai **#154
yang MENUTUP #123**; `IMPLEMENTATION_ROADBOOK.md:144` masih menulis *"SELURUH fase ini terkunci
di belakang K1 (#123)"*. Salah satunya kedaluwarsa. Perlu dikonfirmasi sebelum penuaan Elyn
dijadwalkan.

---

# REKOMENDASI

## ✅ GARIS BARU. Jangan sentuh Wren.

**Empat alasan, berurut dari yang paling mahal:**

1. **Bukti `benda` kanon di tiga spec berubah makna** (Temuan 3). Ini satu-satunya alasan yang
   menyentuh **kode yang sudah jalan**.
2. **Gambar terkuat tokoh runtuh** (Temuan 5). Wren berharga justru karena ia orang asing.
3. **Ras dan hubungan tak cocok** (Temuan 2). Manusia, peminjam buku, bukan keluarga.
4. **Membakar NPC yang masih tersedia** (Temuan 4). Cucu Wren hidup hari ini, belum dipakai.

**Ongkos garis baru: hampir nol.** Wren tak punya sheet untuk direvisi; garis baru tak menabrak
apa pun karena `LEGACY PATH` memang tak pernah menyebut anak. Yang dibutuhkan cuma sesi
penulisan — dan itu milik Designer.

## Tiga hal yang harus diputus bersamaan dengan nama garisnya

1. **Darah vs murid** (Temuan 6) — berdampingan, atau darah menggantikan?
2. **Laju tahun per halaman** (Temuan 7) — berapa yang membuat penuaan terbaca?
3. **Status K1** (Temuan 7) — #123 atau #154 yang berlaku?

## Yang SUDAH saya kerjakan tanpa menunggu

Amandemen `companion_02` untuk **penuaan** (tak ambigu — Direktur menyatakannya langsung) dan
**keberadaan** keturunan. **Identitas garis dikosongkan** dengan tanda ⚠ eksplisit di sheet.

## Yang TIDAK saya kerjakan

Nol nama, nol ras, nol jumlah generasi, nol kaitan ke tokoh mana pun. Nol sentuhan pada
dua baris Wren. Nol perubahan kode.
