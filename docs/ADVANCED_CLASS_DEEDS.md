# PETA PERBUATAN-GERBANG — Advanced Class (C2, Decision Log #197)

> ## KEPUTUSAN DIREKTUR: **LEVEL *DAN* PERBUATAN** — bukan salah satu.
> **Gerbang Advanced Class terbuka hanya bila KETIGANYA terpenuhi:**
> 1. **LEVEL mencukupi** (band konten — kini **55**; skala final 60, #153) — *"kau sanggup."*
> 2. **PERBUATAN tercatat di CHRONICLE** — berbeda per class — *"kau sudah menjadi."*
> 3. **UJIAN tanpa-tumbang** (30 monster ≥Lv40, mati = ulang dari nol) — *"buktikan sekarang."*
>
> Ini **lebih ketat** daripada tiga opsi yang diajukan (a/b/c). Level saja **tidak cukup**;
> perbuatan saja **tidak cukup**.
>
> **Status: SPEC.** Kode hari ini masih memeriksa **level + ujian**. **Pemeriksaan perbuatan
> dibangun v0.5**, saat Chronicle mulai mencatat perbuatan bertipe (bukan hanya peristiwa).
> **Detail naratif akan difinalkan Designer.**

---

## Kenapa konjungtif (dan bukan "salah satu")

**Level** menjawab *"apakah kau sanggup bertahan di puncak?"* — pertanyaan yang sah, dan jujur.
**Perbuatan** menjawab *"siapa kau sudah menjadi selama perjalanan itu?"* — pertanyaan yang
**tidak bisa di-grind**.

Kalau hanya level: gerbangnya **mesin absensi** — siapa pun yang bertahan cukup lama akan lewat,
dan dua pemain dengan jalan hidup yang sepenuhnya berbeda melewatinya dengan cara yang **identik**.

Kalau hanya perbuatan: pemain bisa **menyelinap** ke jalur lanjutan sebelum ia sanggup memikulnya —
dan momen besarnya menjadi murah.

**Keduanya → gerbang itu berkata: *"kau kuat, DAN kau sudah menjadi seseorang."***

---

## PETA PERBUATAN — 6 class tempur

**Aturan bentuk (mengikat):**
- Perbuatan **wajib tercatat Chronicle** — kalau dunia tak mengingatnya, ia tak terjadi (#168 §XVI).
- Perbuatan **tidak boleh berupa counter** (*"bunuh N"*, *"kumpulkan N"*). Ia **peristiwa**.
- Perbuatan **tidak boleh dipandu quest-marker**. Pemain **tidak diberi tahu** bahwa ia sedang
  membuka gerbang — ia baru tahu **sesudahnya**. *(Hidden Class tidak dipilih — **DITEMUKAN**.)*
- Tiap class punya **dua jalur lanjutan**; perbuatan menentukan **jalur mana yang terbuka**, dan
  **pemain boleh membuka keduanya** bila keduanya pernah ia lakukan.

| Class | Jalur | **PERBUATAN GERBANG** *(tercatat Chronicle)* | Yang diukur |
|---|---|---|---|
| **WARRIOR** | *Sword Saint* | **Melindungi seseorang sampai tuntas** — sebuah nyawa (NPC/companion) yang **selamat karena kau berdiri di depannya**, bukan karena kau membunuh lebih cepat | kau berdiri **untuk** seseorang |
| | *Berserker* | **Menyelesaikan pertarungan yang seharusnya kau tinggalkan** — bertahan dan menang dalam keadaan yang setiap orang waras akan mundur darinya | kau **tidak mundur** |
| **MAGE** | *Archmage* | **Menemukan sesuatu yang belum ada di Grimoire siapa pun** — sebuah fusi/interaksi elemen yang **pertama kali** kau catat | kau **bertanya**, bukan menghafal |
| | *Stormcaller* | **Membiarkan cuaca/langit menentukan pertarunganmu** — memenangkan pertempuran besar yang **hanya mungkin** karena kau membaca langit (badai, purnama, rasi) | kau **tunduk pada dunia**, lalu memakainya |
| **ARCHER** | *Sniper* | **Satu tembakan yang menyelesaikan segalanya** — mengakhiri ancaman besar **tanpa pertarungan panjang**: kesabaran, bukan kecepatan | kau **menunggu** |
| | *Windrider* | **Melintasi jarak yang mustahil** — menempuh perjalanan/pengejaran yang tercatat dunia sebagai **tak masuk akal** | kau **tak bisa ditahan tempat** |
| **ASSASSIN** | *Phantom* | **Menyelesaikan sesuatu yang besar tanpa satu pun saksi** — dunia melihat **akibatnya**, tak pernah tahu siapa. *(Chronicle mencatatnya sebagai **peristiwa tanpa pelaku**.)* | kau **memilih tak dikenang** |
| | *Vipermaster* | **Mengalahkan sesuatu yang jauh lebih kuat dengan kesabaran, bukan kekuatan** — racun, waktu, dan pengetahuan | kau **melumpuhkan**, bukan menghancurkan |
| **PALADIN** | *Crusader* | **Menahan sesuatu yang tak bisa kau kalahkan, cukup lama untuk orang lain selamat** — kau **kalah**, dan mereka **hidup** | kau **membayar** dengan dirimu |
| | *High Cleric* | **Menyembuhkan/menolong seseorang yang tak bisa membalasmu apa pun** — dan **tidak ada yang tahu** kau melakukannya | kau **memberi tanpa harga** |
| **NECROMANCER** | *Lich* | **MEMBAYAR harga kebangkitan** — kau membangkitkan seseorang, dan **sesuatu terlupakan** (#119). *Kau memilih mengingat orang itu lebih dari kau menghargai ingatanmu sendiri.* | kau **menolak kehilangan** |
| | *Reaper* | **MENOLAK sebuah kebangkitan yang bisa kau lakukan** — kau berdiri di sisi seseorang yang bisa kau kembalikan, dan **membiarkannya pergi** | kau **menghormati akhir** |

> ### ⚖ Necromancer adalah poros kitab ini
> Dua jalurnya adalah **dua jawaban atas Pertanyaan Nirnama**, diletakkan di tangan pemain:
> **Lich membayar apa pun agar tidak kehilangan** *(dan itu adalah Nirnama muda)*.
> **Reaper menerima bahwa yang berakhir memang berakhir** *(dan itu adalah tesis Aetherion)*.
> **Tak satu pun dari keduanya salah.** Itulah sebabnya keduanya harus ada.

---

## Yang HARUS dibangun agar spec ini hidup (v0.5)

| Potongan | Status | Catatan |
|---|---|---|
| **Chronicle mencatat perbuatan BERTIPE** (`deed:<class>:<jalur>`) | ❌ **belum** | hari ini Chronicle mencatat peristiwa, bukan perbuatan berlabel |
| `AdvancedClass.has_deed(class, path)` | ❌ **belum** | |
| Gerbang konjungtif di `adv_available()` | 🟡 **separuh** — level ✅, ujian ✅, **perbuatan ❌** | |
| **Pemain TIDAK diberi tahu** bahwa perbuatan sedang dinilai | ⚠ **aturan** | tak ada quest-marker, tak ada progress bar |

⚠ **Jangan bangun gerbang perbuatan sebelum Chronicle bisa mencatatnya** — kalau tidak, gerbangnya
menjadi **mustahil** dan Advanced Class mati diam-diam. *(Persis pola #127 yang tak boleh terulang.)*
