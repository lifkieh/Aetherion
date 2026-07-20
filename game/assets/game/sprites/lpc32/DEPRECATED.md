# Aset RUSAK — jangan dipakai

Ditemukan oleh audit-mata 2026-07-20 (`_tools/gen_lembar_audit.py`): 81 PNG dibuka
satu per satu dan **dilihat**, bukan disimpulkan dari namanya.

Berkas di bawah **tetap ada** dan sengaja tidak dihapus. Menghapusnya akan memutus
rujukan lama secara senyap, dan berkas yang lenyap tak mengajari siapa pun apa-apa;
berkas yang ditandai mengajari. Kalau ada scene yang masih memuatnya, ia harus gagal
di tempat yang jelas, bukan diam-diam menggambar noda.

| Berkas | px | Isi SEBENARNYA (dilihat) | Ganti dengan |
|---|---|---|---|
| `tree_lpc.png` | 64×64 | Potongan salah-krop: lengkungan cokelat-keemasan. **Nol batang, nol tajuk.** Dipakai 4 tempat di `Ashbrook64.gd` selama berbulan-bulan sebagai "pohon"; dari kamera main ia cuma noda tan di rumput. | `sprites/props/tree_oak.png` (berbatang & bertajuk, sudah lama ada di repo) · varian lain: `tree_birch`, `tree_giant`, `tree_pine_*`, `tree_dead_a/b/c` |
| `window_lpc.png` | 64×32 | Dua goresan biru kecil pada kanvas nyaris kosong. Bukan jendela. | Tak dipakai scene mana pun. Jendela digambar langsung di dalam sprite fasad. |

## Nama menyesatkan (BUKAN rusak)

| Berkas | Isi sebenarnya | Awas |
|---|---|---|
| `wall_ruin.png` | **Pagar kayu UTUH**, bukan reruntuhan | Jangan dipakai sebagai puing. Untuk jejak reruntuhan pakai `props/ruins.png` atau ubin `tiles/lpc32/fondasi32.png`. |

## Pelajaran yang dibayar empat kali

Lentera → ubin → ayam → pohon. Polanya selalu sama, dan bukan "aset rusak":
**asetnya ADA dan benar, kodenya menunjuk berkas lain.** `tree_oak.png` duduk di
repo ini sepanjang waktu. Yang mahal bukan aset yang hilang — melainkan aset salah
yang cukup kecil di layar untuk lolos dari mata.

Karena itu audit dilakukan dengan **merasterisasi tiap berkas**, bukan membaca
daftar nama.

## Aset yatim — dibuat lalu digantikan

| Berkas | Kenapa lahir | Kenapa mati |
|---|---|---|
| `tiles/lpc32/kabut32.png` | C4 tepi hantu butuh kabut; sapuan 111 zip gudang menemukan NOL kabut bergaya LPC, jadi digambar sendiri (`gen_c4.py`). | Terbaca sebagai **PITA PUCAT**: rata dan terang — dua sifat yang membunuh kedalaman, dan tak satu pun bisa disembuhkan dengan menebalkannya. Digantikan **treeline pinus** (`gen_treeline.py`): massa gelap punya siluet, tumpang-tindih, dan bayangan — tiga hal yang membuat mata membaca jarak. |

Berkasnya **tetap ada dan tetap punya kreditnya**, tidak dihapus — alasan yang sama
dengan `tree_lpc.png` di atas: berkas yang lenyap tak mengajari siapa pun; berkas
yang ditandai mengajari. Kalau suatu saat kabut dibutuhkan sebagai **cuaca** (bukan
sebagai batas), ubin ini titik mulainya — yang salah dulu bukan asetnya, melainkan
pekerjaan yang dibebankan kepadanya.
