# MIGRASI `_charsys` → LPC 64px (#250)

**Status:** `_charsys` **DIPENSIUNKAN, BUKAN DIHAPUS.** Ia masih menyuplai **setiap karakter
yang hidup di dunia hari ini.** Daftar di bawah = urutan migrasi, bukan daftar hapus.

`CharGen.gd:5` sudah dicabut dari "LPC rejected" → kanon #250.

---

## Siapa yang masih memanggil `_charsys` (via autoload `CharGen`)

**7 berkas, 30 pemanggilan.** Nol pemanggilan langsung ke `_charsys/` di `game/` —
semuanya lewat `CharGen.gd`, yang merupakan port GDScript dari `_charsys/gen_charsys_v2.py`.
**Itu kabar baik: ada satu titik cekik.** Ganti `CharGen`, dan seluruh dunia ikut berganti.

| # | Berkas | Baris | Yang dipakai | Kenapa berat |
|---|---|---|---|---|
| 1 | `actors/Player.gd` | 41–42 | `sprite_frames`, `default_config` | **PEMAIN.** Butuh 4 arah × animasi jalan. Jalur terpanas — migrasi paling akhir atau di belakang saklar. |
| 2 | `actors/Villager.gd` | 51 | `sprite_frames`, `default_config` | Semua warga berjalan di tiap kota. |
| 3 | `world/Interactable.gd` | 153–156 | `sheet_texture`, `CW`/`CH` | 8 jenis NPC (pedagang · astrolog · pemandu · guru · enchanter · juru lelang · penjaga pohon · shop). Memotong frame diam dari atlas — **`CW`/`CH` = 32 di-hardcode**; LPC = 64. |
| 4 | `ui/CharacterCreator.gd` | 30, 103–106, 188, 194, 199, 210–213 | `races`, `hair_styles`, `sprite_frames`, `default_config` | **PALING BERAT.** UI-nya dibangun dari daftar `_charsys`: 7 ras × per-bagian (kepala/badan/kaki) + 6 rambut. Katalog LPC punya bentuk berbeda — UI ini praktis ditulis ulang, bukan dialihkan. |
| 5 | `autoload/PlayerData.gd` | 224, 757 | `default_config` | **Berdampak SIMPAN/MUAT.** `char_config` tersimpan di save; simpanan lama berisi konfigurasi `_charsys`. Butuh migrasi save atau lapisan terjemah. |
| 6 | `scenes/Main.gd` | 284, 299 | `default_config`, `sheet_image` | Pratinjau/montase demo. Ringan. |
| 7 | `tests/TestRunner.gd` | 1419–1450 | `races`, `hair_styles`, `sheet_image`, `sprite_frames`, `default_config` | 8 assertion mematok **96 px lebar lembar** dan **6 gaya rambut**. Akan merah begitu LPC masuk — **itu benar**, bukan bug. |

## Urutan yang saya sarankan (termurah → termahal)

1. **`Interactable.gd`** — NPC diam, satu frame, tanpa animasi. Uji terkecil yang membuktikan
   LPC benar-benar tampil di dunia nyata. Hati-hati: `CW`/`CH` 32→64 dan `offset` −8 ikut berubah.
2. **`Villager.gd`** — menambah jalan 4 arah. Kalau ini benar, karakter LPC terbukti hidup.
3. **`Player.gd`** — di belakang saklar, supaya bisa dibalik dalam satu baris.
4. **`CharacterCreator.gd` + `PlayerData.char_config`** — bersama, karena UI dan bentuk simpanan
   adalah satu keputusan. **Di sini letak migrasi save.**
5. **`TestRunner.gd`** — perbarui assertion **setelah** perilaku benar, jangan sebelum. Gerbang
   tetap **0 gagal** (#249); kenaikan cakupan dibuktikan lewat **nama** test baru.

## Yang sudah siap dipakai

- `_tools/lpc_assembler/assemble.py` + `catalog.json` + `frame_map.json` + 6 `characters/*.json`
  — **kini benar-benar ter-commit** (#251). Mesin perakitnya ada; spec di `reports/PERAKIT_SPEC.md`.
- `assets_raw/lpc_extra/eulpc_*` — format kanonik 832×2944 (#233/#236).

## Yang BELUM ada (jujur)

- Perakit belum terhubung ke runtime Godot. `assemble.py` = Python design-time; `CharGen` = GDScript
  runtime. **Salah satu harus menyeberang:** pra-panggang lembar ke `game/assets/`, atau port perakit ke GDScript.
- **Dunia 32px belum diputuskan** — lihat `reports/LISENSI_DUNIA_32PX.md`. Karakter LPC di atas
  ubin 16px akan terlihat kebesaran sampai itu beres.
