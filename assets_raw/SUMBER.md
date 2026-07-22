# SUMBER MENTAH — apa yang dibutuhkan tiap generator, dan dari mana

**Berkas ini di-commit; zip yang didaftarkannya TIDAK.**

## Kenapa dipisah begini

`assets_raw/` berisi **1,5 GB** pack pihak ketiga. Meng-commit-nya akan membuat
`git clone` berjam-jam demi barang yang tak kita buat dan tak kita ubah.

Tapi #240 menuntut tiap PNG punya generator yang bisa **dijalankan ulang**, dan
generator yang sumbernya hilang cuma setengah generator. Jadi yang di-commit bukan
zip-nya melainkan **cara mendapatkannya kembali**: URL, ukuran, dan SHA256.

> Sidik jari lebih penting daripada URL. URL bisa berubah, dan pack yang "sama namanya"
> tapi beda isinya adalah cara paling senyap untuk membuat aset bergeser satu baris
> tanpa ada yang menyadarinya.

## Yang HARUS diunduh sebelum menjalankan generator

| zip | dipakai | MB | SHA256 |
|---|---|---|---|
| `lpc_extra/lpc-2024-10-15-expanded-ulpc-clothing.zip` | `panen_clothing.py` | 66,2 | `fc8aaee0db0b840a596fa72d965420b31e8599e89db3ce51d81f409fba462bf2` |
| `lpc_extra/lpc-2025-02-03-expanded-ulpc-pants-cleaned-split.zip` | `panen_legs.py` | 21,5 | `7ad7117676c5ad309394d249cfa2b313b24ec03a8c50d850d3372b5d380919da` |
| `lpc_extra/lpc-2025-03-08-fixed-feet-assets.zip` | `panen_feet.py` | 9,0 | `f1812627cd027df8d438c581febc5ca7546088c86459147e9e9888ba6e7e7415` |
| `lpc_extra/lpc-2025-03-08-fixed-body-head-assets.zip` | `gen_kepala.py` | 18,3 | `fed7ee37f5912842c476b24e83d2842565ad05892e5c21b518aee7782af4c25f` |
| `lpc/lpc-character-bases-v3_1.zip` | `gen_base_karakter.py` | 32,4 | `f2ff8125c8ba5692d269046c26f534fda6e18b52178f6e3a7d5473dce6d44cb7` |

Empat yang pertama dari **[LPC Expanded] Sit, Run, Jump & More** oleh JaidynReiman —
<https://opengameart.org/content/expanded-universal-lpc-spritesheet-idle-run-jump-lpc-revised-combat-and-assets>
Lisensi **OGA-BY 3.0 / 4.0**.

Yang kelima dari **LPC Character Bases** —
<https://opengameart.org/content/lpc-character-bases>

Pola URL unduhan OGA: `https://opengameart.org/sites/default/files/<nama-zip>`

## Yang TIDAK bisa direproduksi dari clone bersih

**`gen_hewan.py` membaca gudang di Desktop** (`Gudang_asset/`), bukan dari repo.
Itu berarti sprite hewan **tak bisa dibuat ulang** oleh siapa pun selain pemilik mesin
ini. Dicatat sebagai kekurangan nyata, bukan diklaim beres:

| hewan | sumber | bisa diulang? |
|---|---|---|
| babi | `pig-1.1/` (Desktop) | tidak — perlu gudang |
| rusa · serigala | `assets_raw/oga/` | **ya** — sumbernya ter-commit |
| kucing · anjing · burung | `assets_raw/lpc/` | sebagian |

Jalan membayarnya sama dengan yang sudah ditempuh untuk rusa & serigala: pindahkan
sumber kecil berlisensi permisif ke `assets_raw/oga/` (yang **dikecualikan** dari
`.gitignore`), lalu arahkan generatornya ke sana.

## Yang SUDAH ter-commit dan cukup

`assets_raw/oga/` — 338 PNG, 0,8 MB. Sumber rusa, serigala, sepatu male, kemeja &
celana & rok anak, torso pregnant. `ambil_lpc.py` bahkan tak butuh berkas lokal sama
sekali: ia mengunduh langsung dari repo generator LPC resmi.

## Turunan — jangan di-commit, jangan disunting tangan

| lokasi | isi | dibuat oleh |
|---|---|---|
| `lpc_extra/eulpc_*.png` | 1.962 lembar pakaian | `panen_*.py`, `ambil_lpc.py` |
| `lpc_extra/bases/` | 154 badan (7 build × 22 kulit) | `gen_base_karakter.py` |
| `lpc_extra/heads/` | 154 kepala (7 varian × 22 kulit) | `gen_kepala.py` |

Semuanya bisa dihapus dan dibuat ulang. Kalau salah satu disunting tangan, suntingannya
akan hilang tanpa peringatan pada panen berikutnya.
