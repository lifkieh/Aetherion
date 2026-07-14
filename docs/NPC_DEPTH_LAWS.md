# DELAPAN HUKUM KEDALAMAN NPC — spec v0.6

> **Status: KANON** (Decision Log #170). **Implementasi: v0.6** (bersama personality engine,
> trait spesies, Growth Type, Life Events). Ini **bukan** fitur baru — ini **hukum yang mengikat**
> setiap sistem NPC yang kita bangun setelahnya.

**Kenapa ini ada di kanon, bukan di dokumen tuning:** kedelapan hukum ini adalah **jawaban
mekanis atas Pertanyaan Nirnama** (`NIRNAMA_BIBLE_PUBLIC.md` §XII–XV). Kalau NPC hanyalah
angka yang naik, maka Nirnama benar — tidak ada yang layak diteruskan. Kedelapan hukum inilah
yang membuatnya salah.

---

## 1. POTENTIAL = ??? *(hukum induk — mengikat tujuh sisanya)*

**Masa depan setiap NPC adalah `???`, dan itu TIDAK PERNAH boleh diketahui — oleh pemain,
oleh penulis, bahkan oleh Sang Nirnama.**

- `potential` **boleh ada di data**; ia **TIDAK PERNAH tampil di UI**. Tak ada bintang, tak ada
  "bakat: A", tak ada bar tersembunyi yang bocor lewat tooltip.
- **Tak ada NPC yang dijamin sukses. Tak ada yang dijamin gagal.**
- **Uji desain:** kalau seorang pemain bisa menyortir NPC berdasarkan siapa yang "layak
  diinvestasikan", hukum ini sudah mati.

## 2. HIDDEN TALENT TIER

Bakat **ada** dan **tidak merata** — tapi ia **tersembunyi**, dan **sering tidak diketahui oleh
pemiliknya sendiri**.

- Tier bakat **tidak pernah ditampilkan** — ia hanya **tersirat** lewat perilaku, kecepatan
  belajar, dan komentar orang lain (*"anak itu... cepat sekali menangkap."*).
- **Bakat besar di tempat yang salah = tetap tak menjadi apa-apa** (lihat Hukum 3).
- **GENIUS IS RARE** (L17): Talent + Effort **>** Talent. Talent + Effort + Opportunity + Luck
  = **pengubah sejarah**. Sisanya: orang berbakat yang tak pernah terdengar.

## 3. OPPORTUNITY *(hukum terpenting bagi gameplay)*

**Bakat tanpa kesempatan tidak menjadi apa-apa.** Dan:

> **PEMAIN ADALAH SUMBER KESEMPATAN TERBESAR DI DUNIA.**

Merekrut · mementor · menempatkan seseorang · memberi alat · memberi kepercayaan =
**mengubah takdirnya**. Ini **bukan** metafora — ini harus jadi **mekanik yang bisa dilacak**:
Chronicle mencatat *siapa yang kau beri kesempatan*, dan **apa jadinya mereka**.

*Inilah senjata sesungguhnya melawan Nirnama: memberi orang lain kesempatan yang tak pernah ia
berikan kepada dirinya sendiri.*

## 4. LUCK

Sebagian orang berdiri di tempat yang tepat pada hari yang tepat. Sebagian tidak.

- Luck **hanya bergerak lewat PERISTIWA** (#138) — **tak pernah** lewat timer kosong.
  *Keberuntungan yang di-tick tiap detik bukan keberuntungan; itu cuaca.*
- Luck **tidak boleh** ditampilkan sebagai stat NPC. Ia hanya terlihat **setelah** kejadian.
- **Dua tafsir atas fakta yang sama:** Nirnama membaca keberuntungan sebagai bukti dunia **tak
  berarti**; Aetherion membacanya sebagai bukti dunia **tidak ditentukan sebelumnya**.

## 5. MENTAL HEALTH *(PEOPLE CAN BREAK — L15)*

**Kekuatan mental adalah bagian dari kekuatan.**

- Trauma, duka, depresi, kelelahan **menurunkan performa** dan **memperlambat/menghentikan**
  pertumbuhan — bukan sebagai debuff bertimer, melainkan sebagai **keadaan**.
- **Pemulihan itu mungkin, tapi tidak dijamin.** Sebagian orang **tidak pulih** — dan kitab ini
  dilarang berpura-pura sebaliknya (§XV Tragedy).
- Yang memulihkan: **peristiwa**, **orang lain**, **waktu yang diisi**, **tujuan** — bukan potion.

## 6. GROWTH RATE

Orang tumbuh dengan **kecepatan berbeda**, dan **kurva yang berbeda** (Early / Balanced / Late).

- **Late bloomer harus ada** — dan pemain **tidak boleh bisa mengenalinya di awal** (Hukum 1).
  Seseorang yang tampak biasa selama 50 jam **boleh** menjadi luar biasa di jam ke-200.
- Growth **hanya bergerak lewat peristiwa & latihan**, tak pernah lewat idle.

## 7. TRAINING PHILOSOPHY *(L16)*

> **TRAINING CREATES STRENGTH — tapi Stronger ≠ Exceptional.**

- **Latihan MENJAMIN kemajuan.** Siapa pun yang dilatih **akan** membaik. Ini janji yang kita tepati.
- **Latihan TIDAK MENJAMIN kehebatan.** Tak ada jumlah latihan yang mengubah orang biasa menjadi
  legenda — dan **itu bukan kegagalan sistem, itu kejujurannya.**
- Karena itu: **mentoring selalu bernilai** (Hukum 3), **tanpa** menjadi mesin cetak pahlawan.

## 8. ORDINARY PEOPLE *(L18 — dan jawaban atas nihilisme)*

**Mayoritas NPC bekerja, berkeluarga, menua, dan meninggal tanpa menjadi legenda — DAN ITU BUKAN
KEGAGALAN.**

- Dunia dibangun oleh **jutaan orang biasa**. **Chronicle menghormati yang biasa.**
- **Dilarang:** sistem apa pun yang memperlakukan NPC biasa sebagai **bahan mentah** (angka yang
  dioptimalkan, unit yang dibuang saat statnya turun).
- **Uji desain:** kalau seorang pemain optimal **tidak punya alasan** untuk peduli pada tukang
  roti, kita sudah gagal — dan Nirnama menang.

---

## Konsekuensi silang yang WAJIB dijaga

| Hukum | Sistem yang menyentuhnya | Bahaya bila dilanggar |
|---|---|---|
| 1, 2 | UI NPC / Domain / rekrutmen | Pemain menyortir manusia seperti loot |
| 3 | Rekrutmen · mentoring · Domain · Chronicle | Belonging mati; pemain jadi turis |
| 4, 6 | Life Events · growth engine | Timer kosong menggantikan peristiwa (#138) |
| 5 | Life Events · companion | Trauma jadi debuff yang di-*dispel* |
| 7 | Training / Domain | Mesin cetak pahlawan |
| 8 | Semua | **Nirnama menang** |

**Companion yang menua melampaui prima (T6, menunggu Direktur):** rekomendasi tetap — ia
**berpindah peran menjadi MENTOR** (jadi **sumber kesempatan** bagi yang lebih muda, Hukum 3),
**tidak dipensiunkan diam-diam karena statnya turun**. Memensiunkannya karena angka = melanggar
Hukum 8 secara langsung.
