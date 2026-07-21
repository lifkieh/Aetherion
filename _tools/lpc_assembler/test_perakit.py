#!/usr/bin/env python3
"""Test perakit LPC. Jalur pemakai (panggil perakit), bukan periksa string (#151b).

  python test_perakit.py
Exit 0 = semua hijau, 1 = ada gagal.
"""
import os
import sys
import tempfile

import assemble as A

FAILS = []


def check(name, fn):
    try:
        fn()
        print(f"[PASS] {name}")
    except AssertionError as e:
        print(f"[FAIL] {name}: {e}")
        FAILS.append(name)
    except Exception as e:  # noqa
        print(f"[ERROR] {name}: {type(e).__name__}: {e}")
        FAILS.append(name)


def _raises(fn):
    try:
        fn()
    except A.AssemblyError:
        return True
    return False


# ---- #231 -----------------------------------------------------------------
# Gerbang ini DIGANTI: dulu ia membandingkan string id hook kepala, sekarang ia
# membandingkan BENTUK (siluet alpha frame hadap-bawah). Test lama ikut diganti —
# bukan karena rewel, tapi karena yang diuji memang beda: "nama lapisan berbeda"
# tak sama dengan "pemain bisa membedakan mereka". Satu test malah BALIK arah:
# dua tokoh botak dulu LULUS (hook unik per-id), padahal siluetnya 0 px beda.
# Itu persis cacat yang meloloskan Old Bram berbulan-bulan.
from PIL import Image as _Im
import uji_siluet as U


def _sheet(lebar, tinggi):
    """Lembar rakitan palsu: satu blok isi di baris hadap-bawah. Bentuk = ukuran blok."""
    s = _Im.new("RGBA", (A.SHEET_W, A.SHEET_H), (0, 0, 0, 0))
    blok = _Im.new("RGBA", (lebar, tinggi), (255, 0, 0, 255))
    s.alpha_composite(blok, (4, U.SHEET_ROW_DOWN * A.CELL + 4))
    return s


def test_231_twins_rejected():
    """Dua tokoh bernama dengan siluet sama -> HARD FAIL."""
    sheets = {"merrit": _sheet(30, 40), "halloran": _sheet(30, 40)}
    assert _raises(lambda: A.guard_231(sheets)), "siluet kembar TIDAK ditolak — gerbang mati"


def test_231_distinct_shape_ok():
    """Beda bentuk cukup jauh (>= ambang) -> lolos."""
    sheets = {"a": _sheet(30, 40), "b": _sheet(30, 10)}   # selisih 30x30 = 900 px
    A.guard_231(sheets)  # tak boleh raise


def test_231_two_bald_now_rejected():
    """BALIK ARAH dari gerbang lama. Dua botak = 0 px beda = kembar, harus DITOLAK.

    Gerbang string dulu meluluskan ini ('__bare__:<id>' selalu unik). Uji siluet
    mengukur botak-Bram vs botak-Merrit = 0 px — mereka memang orang yang sama
    di mata pemain.
    """
    sheets = {"merrit": _sheet(30, 40), "bram": _sheet(30, 40)}
    assert _raises(lambda: A.guard_231(sheets)), "dua botak identik TIDAK ditolak"


def test_231_beda_tipis_tetap_ditolak():
    """Beda ADA tapi di bawah ambang -> tetap kembar. Ini yang tak bisa diuji gerbang
    string sama sekali: `curly_short` vs `curly_short2` = nama beda, bentuk sama."""
    sheets = {"halloran": _sheet(30, 40), "bram": _sheet(30, 41)}   # selisih 30 px
    assert _raises(lambda: A.guard_231(sheets)), "beda di bawah ambang TIDAK ditolak"


def test_231_satu_tokoh_lolos():
    """Satu tokoh tak punya lawan banding — tak boleh raise, tak boleh crash."""
    A.guard_231({"merrit": _sheet(30, 40)})
    A.guard_231({})


# ---- #232 -----------------------------------------------------------------
def test_232_rejects_tiles():
    assert _raises(lambda: A.guard_232("game/assets/game/sprites/tiles/")), "output tiles/ TIDAK ditolak"


def test_232_rejects_ui():
    assert _raises(lambda: A.guard_232("game/assets/game/sprites/ui/")), "output ui/ TIDAK ditolak"


def test_232_rejects_bare_sprites():
    assert _raises(lambda: A.guard_232("game/assets/game/sprites/")), "output non-characters TIDAK ditolak"


def test_232_accepts_characters():
    A.guard_232("game/assets/game/sprites/characters/")  # tak boleh raise
    A.guard_232("game/assets/game/sprites/characters")   # tanpa slash akhir juga


# ---- resolusi lapisan / error ---------------------------------------------
def test_missing_hair_id_errors():
    """id lapisan tak ada di katalog -> error, bukan diam (spec §5)."""
    cat = A._catalog()
    char = {"id": "t", "body": "male", "hair": "TIDAK_ADA"}
    assert _raises(lambda: A._layer_plan(char, cat)), "id rambut palsu TIDAK error"


def test_layer_plan_zorder_bald_merrit():
    """Plan Merrit botak: badan sebelum kepala, tak ada slot rambut."""
    cat = A._catalog()
    char = {"id": "merrit", "body": "male", "hair": None, "headwear": None,
            "torso": "overalls", "legs": "pants_thin", "feet": "shoes_thin"}
    labels = [l for l, _, _ in A._layer_plan(char, cat)]
    assert any(x.startswith("body:") for x in labels), "badan hilang"
    assert any(x.startswith("head:") for x in labels), "kepala hilang"
    assert not any(x.startswith("hair:") for x in labels), "botak tapi ada lapisan rambut"
    bi = next(i for i, x in enumerate(labels) if x.startswith("body:"))
    hi = next(i for i, x in enumerate(labels) if x.startswith("head:"))
    assert bi < hi, "badan harus di belakang kepala (z-order §3)"


# ---- roundtrip nyata (butuh aset; skip bila pustaka tak ada) ---------------
def test_roundtrip_merrit_produces_slices():
    cat = A._catalog()
    char = {"id": "merrit_fane", "named": True, "body": "male", "head": "male",
            "hair": None, "headwear": None, "facial": {"beard": None},
            "torso": "overalls", "legs": "pants_thin", "feet": "shoes_thin"}
    # cek pustaka ada; kalau tidak, ini bukan kegagalan guard tapi lingkungan
    body_path = A._resolve_path(cat["body"]["male"], cat)
    if not os.path.exists(body_path):
        print("    (skip roundtrip: pustaka eulpc tak ada di lingkungan ini)")
        return
    with tempfile.TemporaryDirectory() as d:
        outd = os.path.join(d, "characters")
        os.makedirs(outd)
        written, flagged, n = A.build_one(char, outd, cat, A._frame_map(), A._credits_db())
        assert any(w.endswith("merrit_fane_walk.png") for w in written), "slice walk tak dihasilkan"
        assert os.path.exists(os.path.join(outd, "merrit_fane.credits.txt")), "manifest kredit hilang"
        assert os.path.exists(os.path.join(outd, "LICENSE-CC-BY-SA.txt")), "LICENSE SA hilang"


def test_232_no_sa_leak_outside_characters():
    """Penjaga CI #232: tak ada keviralan / lisensi tak dikenal di luar characters/.

    VERSI LAMA MENGHUKUM KEJUJURAN. Ia menandai SETIAP `*.credits.txt` di luar
    `characters/` sebagai kebocoran — jadi aset hewan yang benar (punya kredit, sesuai
    #277) otomatis melanggar #232 justru KARENA kreditnya ada. Penjaga yang membuat
    dua hukum proyek mustahil dipatuhi bersamaan bukan penjaga, ia jebakan.

    Yang sebenarnya dijaga #232 adalah KEVIRALAN, bukan keberadaan berkas kredit.
    Maka sekarang yang diperiksa ISI kreditnya (lihat `lisensi.py`):

        aman          -> lolos (ada lisensi non-viral yang dinyatakan)
        viral         -> GAGAL (share-alike menular ke sisa proyek)
        tak_tercatat  -> GAGAL (tak bisa dipatuhi, jadi tak bisa dirilis)

    Sheet ukuran-karakter (832x2944) dan LICENSE-CC-BY-SA tetap ditolak apa pun
    isinya: yang pertama pasti turunan LPC, yang kedua pernyataan viral itu sendiri.
    """
    from PIL import Image as _I
    import lisensi
    sprites = os.path.join(A.REPO_ROOT, "game", "assets", "game", "sprites")
    if not os.path.isdir(sprites):
        print("    (skip: folder sprites tak ada)")
        return
    leaks = []
    for root, _dirs, files in os.walk(sprites):
        if "/characters" in root.replace("\\", "/"):
            continue                                   # characters/ = karantina sah
        for fn in files:
            low, path = fn.lower(), os.path.join(root, fn)
            if low == "license-cc-by-sa.txt":
                leaks.append("%s [pernyataan SA]" % path)
            elif low.endswith(".credits.txt"):
                putusan, alasan = lisensi.periksa_berkas(path)
                if putusan != "aman":
                    leaks.append("%s [%s: %s]" % (path, putusan, alasan))
            elif low.endswith(".png"):
                try:
                    if _I.open(path).size == (A.SHEET_W, A.SHEET_H):
                        leaks.append("%s [sheet ukuran-LPC]" % path)
                except Exception:
                    pass
    assert not leaks, "lisensi bermasalah di luar characters/ (%d):\n      %s" % (
        len(leaks), "\n      ".join(leaks))


TESTS = [
    test_231_twins_rejected, test_231_distinct_shape_ok, test_231_two_bald_now_rejected,
    test_231_beda_tipis_tetap_ditolak, test_231_satu_tokoh_lolos,
    test_232_rejects_tiles, test_232_rejects_ui, test_232_rejects_bare_sprites,
    test_232_accepts_characters, test_232_no_sa_leak_outside_characters,
    test_missing_hair_id_errors, test_layer_plan_zorder_bald_merrit,
    test_roundtrip_merrit_produces_slices,
]

if __name__ == "__main__":
    for t in TESTS:
        check(t.__name__, t)
    print()
    if FAILS:
        print(f"{len(FAILS)} GAGAL: {', '.join(FAILS)}")
        sys.exit(1)
    print(f"{len(TESTS)} test hijau.")
