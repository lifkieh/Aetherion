#!/usr/bin/env python3
"""Ukur jarak tempuh Ashbrook64 (#240 - script ikut ter-commit).

BAGIAN 4: **ukur, jangan putuskan.** Berapa detik pemain berjalan dari titik ke
titik. Tata letak TIDAK diubah — kalau angkanya terasa jauh, itu penilaian Direktur
saat playtest, bukan penilaian berkas ini.

Semua koordinat & kecepatan diturunkan dari sumber, bukan disalin tangan:
  Ashbrook64.gd   - MERRIT_HOUSE, VC, koordinat titik-periksa
  Player.gd:6     - BASE_SPEED = 92 px/detik

Jarak dihitung EUCLIDEAN (garis lurus). Itu batas bawah: dengan tabrakan bangunan
sekarang terpasang, jalan sungguhan bisa lebih panjang. Ditandai di keluaran.

Keluaran -> reports/PACING_ASHBROOK64.md
"""
import math
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, ".."))
SRC = os.path.join(REPO, "game", "scenes", "world", "Ashbrook64.gd")
PLAYER = os.path.join(REPO, "game", "scenes", "actors", "Player.gd")
OUT = os.path.join(REPO, "reports", "PACING_ASHBROOK64.md")


def baca(path):
    with open(path, encoding="utf8") as f:
        return f.read()


def konstanta(src, nama):
    m = re.search(r"const %s := Vector2\((-?\d+),\s*(-?\d+)\)" % nama, src)
    return (int(m.group(1)), int(m.group(2)))


def kecepatan(src):
    return float(re.search(r"const BASE_SPEED := ([\d.]+)", src).group(1))


def titik_periksa(src):
    """Ambil koordinat _examine() apa adanya, termasuk yang relatif ke VC."""
    vc = konstanta(src, "VC")
    out = []
    for m in re.finditer(r'_examine\((.+?),\s*"([a-z_0-9]+)"\)', src):
        expr, eid = m.group(1), m.group(2)
        mv = re.match(r"Vector2\((-?\d+),\s*(-?\d+)\)$", expr.strip())
        if mv:
            pos = (int(mv.group(1)), int(mv.group(2)))
        else:
            mr = re.match(r"VC \+ Vector2\((-?\d+),\s*(-?\d+)\)$", expr.strip())
            if not mr:
                continue
            pos = (vc[0] + int(mr.group(1)), vc[1] + int(mr.group(2)))
        out.append((eid, pos))
    return out


def jarak(a, b):
    return math.hypot(b[0] - a[0], b[1] - a[1])


def main():
    src = baca(SRC)
    spd = kecepatan(baca(PLAYER))
    merrit = konstanta(src, "MERRIT_HOUSE")
    spawn = (merrit[0] + 96, merrit[1] + 64)
    pts = titik_periksa(src)

    # jenis bukti per id, dibaca dari data — bukan diketik ulang
    import json
    ev = json.load(open(os.path.join(REPO, "game", "data", "evidence.json"), encoding="utf8"))
    rows = ev if isinstance(ev, list) else ev.get("evidence", [])
    jenis = {e["id"]: e.get("kind", "?") for e in rows if isinstance(e, dict)}

    L = []
    L.append("# PACING ASHBROOK64 — UKURAN, BUKAN PENILAIAN\n")
    L.append("**Dihasilkan `_tools/gen_pacing_ashbrook64.py`.** Jalankan ulang setelah "
             "tata letak digeser — jangan sunting berkas ini.\n")
    L.append("Kecepatan jalan **%.0f px/detik** (`Player.gd` `BASE_SPEED`). "
             "Titik mulai **(%d, %d)** — depan pintu Merrit.\n" % (spd, spawn[0], spawn[1]))
    L.append("> ⚠ Jarak **garis lurus**. Dengan tabrakan bangunan yang kini terpasang, "
             "jalan sungguhan **bisa lebih panjang** — angka di bawah adalah **batas bawah**.\n")

    L.append("\n## Dari titik mulai ke tiap titik\n")
    L.append("| titik | jenis | koordinat | jarak (px) | jalan (detik) |")
    L.append("|---|---|---|---|---|")
    for i, (eid, pos) in enumerate(pts, 1):
        d = jarak(spawn, pos)
        L.append("| %d. `%s` | %s | (%d, %d) | %.0f | **%.1f s** |"
                 % (i, eid, jenis.get(eid, "?"), pos[0], pos[1], d, d / spd))

    # jalur minimum SENDIRI = tiga jenis berbeda
    urut = {eid: (eid, pos) for eid, pos in pts}
    minim = ["ev_ashbrook_gudang_gandum", "ev_ashbrook_halloran_200_roti",
             "ev_ashbrook_batu_fondasi"]
    minim = [urut[k] for k in minim if k in urut]

    L.append("\n## Jalur minimum SENDIRI — tiga JENIS berbeda\n")
    L.append("`akibat` + `kebiasaan` + `benda`. Ini rute terpendek yang membuka "
             "penulisan-ulang tanpa Elyn (#228).\n")
    L.append("| kaki | dari → ke | jarak (px) | jalan (detik) |")
    L.append("|---|---|---|---|")
    tot = 0.0
    kur = spawn
    nama_kur = "MULAI"
    for eid, pos in minim:
        d = jarak(kur, pos)
        tot += d
        L.append("| %s → %s | %s | %.0f | %.1f s |"
                 % (nama_kur, eid.replace("ev_ashbrook_", ""), "", d, d / spd))
        kur, nama_kur = pos, eid.replace("ev_ashbrook_", "")
    L.append("| **TOTAL** | | **%.0f** | **%.1f detik** |" % (tot, tot / spd))

    L.append("\n## Enam titik berurutan (pengumpul menyeluruh)\n")
    tot6 = 0.0
    kur = spawn
    for eid, pos in pts:
        tot6 += jarak(kur, pos)
        kur = pos
    L.append("Berjalan dari titik mulai melewati keenam titik menurut urutan "
             "deklarasinya: **%.0f px = %.1f detik** berjalan terus-menerus.\n"
             % (tot6, tot6 / spd))

    L.append("\n## Rentang peta, untuk perbandingan\n")
    L.append("- Peta **60×34 petak** = **1920×1088 px**.")
    L.append("- Menyeberangi peta secara mendatar: **%.1f detik**." % (1920.0 / spd))
    L.append("- Menyeberangi peta secara tegak: **%.1f detik**." % (1088.0 / spd))
    L.append("- Titik terjauh dari mulai: **%.1f detik**."
             % (max(jarak(spawn, p) for _e, p in pts) / spd))

    L.append("\n---\n\n**Nol penilaian di berkas ini.** Apakah angka-angka ini terasa "
             "jauh, tepat, atau kosong — itu putusan Direktur saat playtest.\n")

    with open(OUT, "w", encoding="utf8", newline="\n") as f:
        f.write("\n".join(L))
    print("pacing -> %s" % OUT)
    print("  minimum SENDIRI: %.0f px = %.1f detik" % (tot, tot / spd))
    print("  enam titik: %.0f px = %.1f detik" % (tot6, tot6 / spd))


if __name__ == "__main__":
    main()
