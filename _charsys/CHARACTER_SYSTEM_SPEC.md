# AETHERION CHARACTER SYSTEM v2 - SPESIFIKASI (untuk agent)
Sistem karakter modular MILIK PROYEK (nol batasan lisensi). Owner menolak LPC (share-alike);
kualitas target = "indie charm", dipoles artist nanti TANPA mengubah sistem.

## Arsitektur (sudah diimplementasi di gen_charsys_v2.py)
Karakter = komposisi LAYER per BAGIAN TUBUH, masing-masing punya RAS sendiri:
  tail(torso_race) -> legs(legs_race) -> torso+arms(torso_race) -> head(head_race) -> hair
Ras tersedia: human, human2, wolfkin (telinga+moncong+ekor+kaki digitigrade),
lizardkin (crest+ekor+sisik+cakar), candyfolk (gum hair+sprinkles), frostkin (tanduk es),
undead (tulang+mata kosong). Palet kulit per ras = (base, shadow, highlight) dari palet resmi.
CHIMERA VALID: kepala ras A + badan/tangan ras B + kaki ras C (lihat 2 demo mix_*).
Warna kulit/rambut/baju/celana = parameter bebas.

## Format sheet: 96x128, sel 32x32, kolom 3 frame (loop 0-1-2-1, frame1 idle),
## baris: down/left/right/up. Import Filter OFF.

## Tugas agent
1. IN-GAME CHARACTER CREATOR (saat new game + NPC "Cermin Jiwa" di Celestia utk re-custom berbayar):
   UI pilih per-bagian: Kepala(ras), Badan&Tangan(ras), Kaki(ras), Rambut(gaya+warna),
   Warna kulit per bagian, Warna baju/celana. Preview live 4 arah.
   Implementasi runtime: PORT logika compose() ke GDScript (gambar ke Image/ImageTexture
   saat karakter dibuat, cache hasilnya) ATAU pre-generate kombinasi via Python saat build.
   Simpan config di save (JSON), bukan PNG.
2. NPC per pemukiman = ras tematik (pakai generator ini); Greenvale tetap 100% human.
3. KANON BARU (catat DEVLOG+Pedia): CELESTIA KINGDOM = ibukota tempat SEMUA ras bersatu
   (dibangun nanti sebagai kota terbesar; multi-ras adalah identitasnya).
4. Agent DIANJURKAN memperbaiki/memperkaya generator (anatomi, frame serang, gaya rambut,
   outfit layer terpisah, ras baru per wilayah) - screenshot in-game sebagai QC, catat di DEVLOG.
5. Kualitas: bandingkan in-game vs reference owner; iterasi shading/proporsi seperlunya.
