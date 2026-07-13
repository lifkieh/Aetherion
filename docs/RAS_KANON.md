# DELAPAN RAS BESAR — Kanon Peradaban Aetherion

**Status:** kanon (Decision Log #86, keputusan owner P1 = a). **SPEC-ONLY** — tidak ada
kode yang dibangun atas dokumen ini sekarang. Rujukan penuh: World Bible Part 02 di
`docs/Aetherion_blueprint_reasoning_and_design.txt`.

## Dua hukum yang mengikat semua ras

1. **"Races Are Cultures, Not Stats."** Ras **tidak pernah** memberi bonus stat. Ras
   memberi budaya, sejarah, hukum, prasangka — dan cara dunia memperlakukanmu.
2. **"No Race Is Monolithic."** Tiap ras punya perpecahan internal. Tak ada ras yang
   bersuara satu; siapa pun yang mengaku bicara "atas nama rasnya" sedang berbohong,
   atau sedang berkuasa.

## Delapan Ras

| Ras | Julukan | Poros budaya | Konflik internal (arah, bukan jawaban) |
|---|---|---|---|
| **Human** | *The Builders* | Membangun, mewariskan, melupakan | Ambisi vs akar: yang membangun cepat sering merobohkan yang lama |
| **Elf** | *The Long Remembering* | Ingatan panjang; waktu diukur generasi | Yang ingin melupakan agar bisa hidup vs yang menolak melupakan apa pun |
| **Dryad** | *Children of the Living Forest* | Hidup sebagai bagian hutan, bukan pemiliknya | Yang membuka diri pada dunia luar vs yang menutup hutan rapat-rapat |
| **Dwarf** | *Keepers of Stone* | Batu, kedalaman, kerja yang bertahan | Penjaga vs penggali: seberapa dalam boleh digali sebelum sesuatu terbangun |
| **Beastfolk** | *Children of Instinct* | Naluri, kebebasan, ikatan kelompok | Naluri sebagai kehormatan vs naluri sebagai rantai |
| **Astralborn** | *The Sky Watchers* | Langit, takdir, pengetahuan yang menakutkan | Yang membaca langit untuk memperingatkan vs yang membacanya untuk berkuasa |
| **Tidekin** | *People of the Endless Sea* | Laut Thalassar; adaptasi, peradaban yang hilang & kembali | Yang ingin muncul ke daratan vs yang bersumpah laut tak boleh disentuh |
| **Shadeborn** | *The Forgotten Ones* | Yang tersisa setelah dilupakan | Menerima pelupaan vs merebut kembali nama — poros tema Memori-vs-Pelupaan |

## Pemetaan ras CharGen yang SUDAH ADA (garis keturunan — bukan rework)

| Ras CharGen (kode) | Kedudukan kanon |
|---|---|
| human / human2 | **Human** |
| wolfkin, lizardkin | garis keturunan **Beastfolk** |
| frostkin | manusia utara **berdarah Astralborn** |
| undead | kasus khusus terkait **Shadeborn** (detail menyusul di World Bible pass) |
| candyfolk | **ras minor lokal Candyveil** (bukan salah satu dari Delapan) |

**Tidak ada rework CharGen sekarang.** Ras playable bertambah **bertahap mengikuti
wilayah yang lahir**: Elf ← Ancient Jungle, Dwarf ← Underground, Tidekin ← Thalassar
(v0.7 HORIZON), dst. Ras yang belum punya tanah tidak dibuka.

## Catatan untuk implementasi kelak
Karena ras = budaya, hook sistemiknya bukan tabel stat melainkan: dialog & sikap NPC,
hukum lokal, akses faksi, harga & penolakan pedagang, quest yang terbuka/tertutup, dan
apa yang dicatat Chronicle tentangmu. Bila suatu hari ada PR yang menambahkan
`race_bonus_str`, PR itu melanggar kanon — tolak.
