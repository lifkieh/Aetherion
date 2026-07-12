# REPORT-02 — Scope Risk Audit (2026-07-12)

Skala kompleksitas: S (≤0.5 sesi) · M (≈1 sesi) · L (1.5–2 sesi) · XL (>2 sesi, wajib dipecah).

## Peringkat risiko tertinggi

### 1. LIFE EVENTS (B1) — risiko #1 · kompleksitas XL
Peristiwa hidup bermakna per domain × 5 tier × (nanti) 50 tokoh Companion Bible =
ledakan kombinatorik konten TULISAN, bukan kode. Dependensi: Domain 5-tier (belum ada),
Companion Bible (B17), sistem memori NPC (World Remembers v1), musim (belum ada).
**Rekomendasi pecahan:** (a) v0.5: engine Life-Event data-driven + 3 event pilot untuk
1 domain; (b) v0.6: 1 chain per companion Tier-S (15); (c) pasca-v0.6: matriks penuh.
JANGAN mencoba matriks penuh sekali jalan.

### 2. AUTONOMOUS KINGDOM + Stability + Expansion (B11–13) — kompleksitas XL
Simulasi otonom = kelas sistem baru (tick ekonomi markas, keputusan AI, 3 metrik,
3 jalur ekspansi). Dependensi: Living HQ dasar, rekrutan (Companion Bible), monster
bekerja (B2), dunia-maju-saat-ditinggal (B4 — bisa share engine "offline tick" dengan
homestead yang sudah terbukti). **Rekomendasi:** v0.6 dipecah 3 milestone: HQ statis →
penduduk+pekerjaan (B2 ikut) → otonomi+Stability; Expansion digeser v0.6.1.

### 3. ACTIVE LOADOUT (B10-A) — kompleksitas L, risiko UX tinggi
Konflik desain dengan hotbar-prime 5 slot (REPORT-01 konflik #2) — butuh klarifikasi
Direktur 1 paragraf SEBELUM dibangun. Dependensi teknis kecil (PlayerData.known_skills
sudah memisahkan "tahu" vs hotbar). **Rekomendasi:** bangun saat pool skill >30
(pasca-v0.5); pilot UI preset di v0.4.4 bersamaan keybind remap.

### 4. LEGACY FAMILY tanpa-makan-slot (B3) — kompleksitas L, risiko save-schema
Menyentuh identitas karakter + save schema + chronicle. Murah kalau dibangun SETELAH
chronicle (benih v0.5); mahal kalau sebelum. **Rekomendasi:** v0.6 setelah chronicle;
siapkan `schema_version` migrasi sejak sekarang (sudah ada di SaveManager ✓).

### 5. LOKALISASI RETROFIT (B15) — kompleksitas L, risiko menjalar
±700+ string hardcode di UI/toast/dialog. Konvensi key sudah dipasang (Loc + contoh)
sehingga HUTANG BERHENTI TUMBUH mulai sekarang. **Rekomendasi:** retrofit per-layar di
v0.4.4 dengan script audit string (grep literal ber-huruf di add_child(_lbl(...)));
EN pass terakhir sekali jalan.

### 6. Level tanpa batas (B10) — kompleksitas M, risiko balancing
Rekalibrasi kurva (XP, HP growth, THREAT) — harness v2 sudah ada sebagai jaring
pengaman; jalankan ulang penuh saat cap dibuka. **Rekomendasi:** bersamaan pembukaan
konten wilayah (v0.7), bukan sebelum.

## Matriks dependensi ringkas
```
Life Events ──▶ Domain 5-tier ──▶ (profesi ada ✓)
     │              └───────────▶ Musim (v0.4.3)
     └────▶ Companion Bible (B17) ──▶ v0.5 gate
Kingdom ──▶ Living HQ ──▶ Homestead ✓ ──▶ offline-tick engine (share B4)
Loadout ──▶ skill pool >30 ──▶ v0.5 skill baru
Legacy Family ──▶ Chronicle (benih v0.5)
Lokalisasi retrofit ──▶ Loc ✓ (hutang berhenti hari ini)
```

## Rekomendasi urutan aman
v0.4.2 (tanpa item berisiko) → v0.4.3 (MUSIM = prasyarat Life Events) → v0.4.4
(lokalisasi retrofit + pilot preset loadout) → v0.5 (Bible gates + Life-Event engine
pilot + benih chronicle) → v0.6 (Kingdom 3-milestone + Legacy Family + B2/B4).
