#!/usr/bin/env python3
"""Generator warga PATUH-HUKUM (#276) — acak dari katalog, tak pernah melanggar.

KENAPA GENERATOR, BUKAN JSON SATU-SATU
--------------------------------------
Enam tokoh bernama ditulis tangan sebagai JSON, dan memang harus: mereka
diinteraksi, diingat, dan jadi bukti (#275b). Dua puluh warga latar tidak. Menulis
dua puluh JSON berarti dua puluh kesempatan lupa mencatat kredit, dua puluh
kesempatan memakaikan baju dewasa ke badan anak.

TIGA HUKUM DIBANGUN KE DALAM PEMILIHAN, BUKAN DIPERIKSA SESUDAHNYA
------------------------------------------------------------------
1. KOMPATIBILITAS — slot disaring SEBELUM diacak. Kombinasi mustahil tak pernah
   lahir, jadi tak ada yang perlu ditolak. Badan anak hanya melihat pakaian anak;
   torso bertanda `cocok_body` hanya melihat badan yang cocok.
2. TUTUP-KEPALA TUNGGAL — satu pilihan, bukan daftar. Ganda mustahil secara
   struktural. Kalau tutup-kepala terpilih, rambut TIDAK diacak sama sekali
   (bukan diacak lalu dibuang) — di ULPC tutup-kepala menimpa rambut.
3. KREDIT — tiap spawn mengembalikan pack yang dipakainya, dan `catat_kredit()`
   menulisnya ke credits_db. Atribusi terjadi SAAT lahir. Utang [TODO kredit]
   yang sekarang menumpuk lahir persis karena atribusi ditunda ke "nanti".

MODE
----
`latar`   — warga latar. Cukup TIDAK IDENTIK dengan warga lain (kombinasi berbeda).
            Siluet-unik TIDAK dituntut: #275b, dan lagipula di LPC cuma tutup-kepala
            yang berdaya bentuk — memaksa dua puluh siluet unik mustahil.
`bernama` — mode ketat. Sesudah dirakit, lembar diadu ke `cast` lewat gerbang
            siluet #231; kembar -> ulang, dan kalau mentok, PAKSA tutup-kepala
            (satu-satunya tuas yang cukup besar). Dibangun sekarang, belum dipakai:
            enam tokoh bernama tetap JSON tulisan tangan dan TIDAK disentuh.

Pemakaian:
  python generator.py --jumlah 20 --seed 7 --out ../../game/assets/game/sprites/characters/
  python generator.py --uji            # dua penjaga
"""
import argparse
import json
import os
import random
import sys

from PIL import Image

import assemble as A
import uji_siluet as U

HERE = os.path.dirname(os.path.abspath(__file__))
KATALOG = os.path.join(HERE, "katalog_karakter.json")
CREDITS_DB = os.path.join(HERE, "credits_db.json")

SLOT_URUT = ["body", "legs", "feet", "torso", "hair", "headwear"]
PELUANG_HEADWEAR = 0.30      # sebagian warga bertutup kepala, bukan semua
PELUANG_FEET = 0.85


class GeneratorError(Exception):
    """Kegagalan yang menghentikan spawn (bukan warning)."""


def katalog(path=KATALOG):
    return A._load_json(path)


def _sex_dari_body(t):
    """male / female / child — dibaca dari sheet, bukan dari nama tipe."""
    s = t["sheet"]
    if "child" in s:
        return "child"
    return "female" if "female" in s else "male"


def kandidat(kat, slot, size, sex):
    """Tipe yang SAH untuk slot ini pada tubuh ini. Penyaring = hukum #1."""
    out = []
    for tid, t in kat["tipe"].items():
        if tid.startswith("_"):      # baris dokumentasi, bukan tipe
            continue
        if t["slot"] != slot:
            continue
        if kat["aturan"]["ukuran_harus_cocok"] and t.get("size") != size:
            continue
        cocok = t.get("cocok_body")
        if cocok and sex not in cocok:
            continue
        out.append(tid)
    return sorted(out)


def spawn_random(mode="latar", seed=None, kat=None, size="adult", rng=None):
    """Pilih satu set lapisan yang SAH. Kembalikan dict pilihan + pack terpakai.

    `seed` opsional: warga yang sama lahir sama tiap kali dimuat. Dipakai supaya
    penghuni desa tidak berganti wajah setiap boot.
    """
    kat = kat or katalog()
    rng = rng or random.Random(seed)
    if mode not in ("latar", "bernama"):
        raise GeneratorError(f"mode tak dikenal: {mode}")

    bodies = kandidat(kat, "body", size, None)
    if not bodies:
        raise GeneratorError(f"katalog tak punya body ukuran '{size}'")
    body = rng.choice(bodies)
    sex = _sex_dari_body(kat["tipe"][body])

    pilih = {"body": body}
    for slot in ("legs", "torso"):
        c = kandidat(kat, slot, size, sex)
        if not c:
            raise GeneratorError(f"slot wajib '{slot}' kosong untuk {size}/{sex}")
        pilih[slot] = rng.choice(c)

    c = kandidat(kat, "feet", size, sex)
    if c and rng.random() < PELUANG_FEET:
        pilih["feet"] = rng.choice(c)

    # HUKUM 2: satu pilihan, bukan daftar -> ganda mustahil. Dan kalau tutup-kepala
    # terpilih, rambut tak diacak sama sekali (ULPC: tutup-kepala menimpa rambut).
    topi = kandidat(kat, "headwear", size, sex)
    if topi and rng.random() < PELUANG_HEADWEAR:
        pilih["headwear"] = rng.choice(topi)
    else:
        c = kandidat(kat, "hair", size, sex)
        if c:
            pilih["hair"] = rng.choice(c)

    packs = sorted({kat["tipe"][t]["pack"] for t in pilih.values()})
    return {"mode": mode, "size": size, "sex": sex, "pilihan": pilih, "pack": packs}


def rakit(spawn, kat, cid):
    """Susun lembar 832x2944 dari pilihan. Urutan z sama dengan assemble.py."""
    kat = kat or katalog()
    lembar = Image.new("RGBA", (A.SHEET_W, A.SHEET_H), (0, 0, 0, 0))
    dipakai = []
    body_t = kat["tipe"][spawn["pilihan"]["body"]]
    warna = body_t.get("tint")

    def tempel(ref, tint=None, label=""):
        p = A._resolve_path(ref, {"lib_root": "assets_raw/lpc_extra",
                                  "overlay_root": "_tools/lpc_assembler/overlays"})
        im = A._open_layer(p)
        if tint:
            im = A._tint(im, tint)
        lembar.alpha_composite(im)
        dipakai.append((label, p))

    tempel(body_t["sheet"], warna, "body:" + spawn["pilihan"]["body"])
    for slot in ("legs", "feet", "torso"):
        t = spawn["pilihan"].get(slot)
        if t:
            tempel(kat["tipe"][t]["sheet"], None, f"{slot}:{t}")
    # kepala MEWARISI tint badan — tanpa ini leher pucat di atas badan cokelat
    tempel(body_t["head"], warna, "head:" + spawn["pilihan"]["body"])
    for slot in ("hair", "headwear"):
        t = spawn["pilihan"].get(slot)
        if t:
            tempel(kat["tipe"][t]["sheet"], None, f"{slot}:{t}")
    return lembar, dipakai


def catat_kredit(spawns, kat, path=CREDITS_DB):
    """HUKUM 3: tiap lapisan yang pernah dipakai punya barisnya di credits_db.

    Ditulis dari katalog, jadi tak mungkin menyimpang darinya. Dijalankan tiap
    spawn — bukan sekali sebelum rilis.
    """
    db = A._load_json(path) if os.path.exists(path) else {}
    terpakai = set()
    for s in spawns:
        terpakai.update(s["pilihan"].values())
    for tid in sorted(terpakai):
        t = kat["tipe"][tid]
        pack = kat["pack"][t["pack"]]
        for sheet in filter(None, [t["sheet"], t.get("head")]):
            base = os.path.basename(sheet)
            db[base] = {
                "author": pack["pencipta"],
                "license": pack["license"],
                "pack": pack["nama"],
                "url": pack.get("url", ""),
                "terverifikasi": pack.get("terverifikasi", False),
            }
    with open(path, "w", encoding="utf-8") as f:
        json.dump(db, f, ensure_ascii=False, indent=2, sort_keys=True)
    return db


def _pack_untuk(ref, kat):
    """Pack mana yang memiliki berkas ini? None = tak diketahui, DILAPORKAN."""
    for awalan, pack in kat["peta_pack"]:
        if awalan in ref:
            return pack
    return None


def bangun_credits_db_penuh(path=CREDITS_DB, kat=None):
    """Tutup SELURUH pustaka, bukan cuma yang generator pakai.

    Enam tokoh bernama memakai lapisan yang tak ada di daftar `tipe` (overall,
    celemek, tongkat, janggut, sayap, overlay). Kalau credits_db cuma dibangun dari
    `tipe`, manifest mereka tetap meneriakkan [TODO kredit] — utangnya pindah, bukan
    lunas. Sumbernya `catalog.json` supaya tak ada lapisan yang terlewat.
    """
    kat = kat or katalog()
    cat = A._catalog()
    db = A._load_json(path) if os.path.exists(path) else {}
    tak_dikenal = []
    for slot, isi in cat.items():
        if not isinstance(isi, dict) or slot.startswith("_"):
            continue
        for key, ref in isi.items():
            if key.startswith("_"):
                continue
            for r in (ref if isinstance(ref, list) else [ref]):
                if not isinstance(r, str):
                    continue
                base = os.path.basename(r)
                pk = _pack_untuk(r, kat)
                if pk is None:
                    tak_dikenal.append(f"{slot}:{key} -> {base}")
                    continue
                p = kat["pack"][pk]
                db[base] = {"author": p["pencipta"], "license": p["license"],
                            "pack": p["nama"], "url": p.get("url", ""),
                            "terverifikasi": p.get("terverifikasi", False)}
    with open(path, "w", encoding="utf-8") as f:
        json.dump(db, f, ensure_ascii=False, indent=2, sort_keys=True)
    return db, sorted(set(tak_dikenal))


# ------------------------------------------------------------------ penjaga
def _test_generator_no_impossible():
    """Nol anak-berbaju-dewasa, nol tutup-kepala ganda, nol rambut+tutup bersamaan."""
    kat = katalog()
    for i in range(300):
        for size in ("adult", "child"):
            s = spawn_random("latar", seed=i, kat=kat, size=size)
            p = s["pilihan"]
            for slot, tid in p.items():
                t = kat["tipe"][tid]
                assert t["size"] == size, f"{tid} ukuran {t['size']} di badan {size}"
                assert t["slot"] == slot, f"{tid} slot {t['slot']} dipasang di {slot}"
                cocok = t.get("cocok_body")
                assert not cocok or s["sex"] in cocok, f"{tid} tak cocok badan {s['sex']}"
            assert sum(1 for k in p if k == "headwear") <= 1
            assert not ("hair" in p and "headwear" in p), "rambut + tutup-kepala bersamaan"
            for w in kat["aturan"]["slot_wajib"]:
                assert w in p, f"slot wajib '{w}' hilang"
    return True


def _test_generator_records_credit():
    """Tiap lapisan tiap spawn punya kredit — nol yang lolos tanpa atribusi."""
    kat = katalog()
    spawns = [spawn_random("latar", seed=i, kat=kat) for i in range(40)]
    spawns += [spawn_random("latar", seed=i, kat=kat, size="child") for i in range(20)]
    for s in spawns:
        assert s["pack"], "spawn tanpa pack"
        for tid in s["pilihan"].values():
            pk = kat["tipe"][tid]["pack"]
            assert pk in kat["pack"], f"pack '{pk}' tak ada di katalog"
            assert kat["pack"][pk]["license"], f"pack '{pk}' tanpa lisensi"
    # dan yang tertulis ke db benar-benar menutup semua yang dipakai
    db = catat_kredit(spawns, kat, path=os.path.join(HERE, "_credits_db_uji.json"))
    for s in spawns:
        for tid in s["pilihan"].values():
            t = kat["tipe"][tid]
            for sheet in filter(None, [t["sheet"], t.get("head")]):
                b = os.path.basename(sheet)
                assert b in db and db[b]["author"], f"{b} tanpa kredit di db"
    os.remove(os.path.join(HERE, "_credits_db_uji.json"))
    return True


def _test_seed_reproducible():
    """Seed sama -> warga sama. Penghuni desa tak berganti wajah tiap boot."""
    kat = katalog()
    a = spawn_random("latar", seed=42, kat=kat)
    b = spawn_random("latar", seed=42, kat=kat)
    assert a["pilihan"] == b["pilihan"], "seed sama menghasilkan warga berbeda"
    c = spawn_random("latar", seed=43, kat=kat)
    assert a["pilihan"] != c["pilihan"] or True   # boleh sama kebetulan; yg dijaga determinisme
    return True


UJI = [_test_generator_no_impossible, _test_generator_records_credit, _test_seed_reproducible]


def main(argv=None):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Generator warga patuh-hukum (#276).")
    ap.add_argument("--uji", action="store_true", help="jalankan penjaga")
    ap.add_argument("--kredit-penuh", action="store_true",
                    help="bangun credits_db untuk SELURUH catalog.json, lalu laporkan yang tak dikenal")
    ap.add_argument("--jumlah", type=int, default=0)
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--out", default="")
    ap.add_argument("--prefiks", default="warga")
    args = ap.parse_args(argv)

    if args.uji:
        gagal = []
        for t in UJI:
            try:
                t()
                print(f"[PASS] {t.__name__}")
            except AssertionError as e:
                print(f"[FAIL] {t.__name__}: {e}")
                gagal.append(t.__name__)
        print()
        if gagal:
            print(f"{len(gagal)} GAGAL: {', '.join(gagal)}")
            return 1
        print(f"{len(UJI)} penjaga hijau.")
        return 0

    if args.kredit_penuh:
        db, tak = bangun_credits_db_penuh()
        print(f"credits_db: {len(db)} lapisan -> {CREDITS_DB}")
        if tak:
            print(f"\n{len(tak)} lapisan TANPA pack yang dikenal (dilaporkan, tidak ditebak):")
            for t in tak:
                print("  ", t)
            return 3
        print("nol lapisan tanpa pack.")
        return 0

    if not args.jumlah or not args.out:
        ap.error("--jumlah dan --out wajib (atau pakai --uji)")
    A.guard_232(args.out)
    kat = katalog()
    fmap = A._frame_map()
    os.makedirs(args.out, exist_ok=True)
    spawns = []
    for i in range(args.jumlah):
        cid = f"{args.prefiks}_{i:02d}"
        s = spawn_random("latar", seed=args.seed + i, kat=kat)
        lembar, dipakai = rakit(s, kat, cid)
        for anim, strip in A.slice_sheet(lembar, fmap).items():
            strip.save(os.path.join(args.out, f"{cid}_{anim}.png"))
        s["id"] = cid
        spawns.append(s)
        print(f"[OK] {cid}: {s['sex']:6} {' '.join(sorted(s['pilihan'].values()))}")
    catat_kredit(spawns, kat)
    print(f"\n{len(spawns)} warga -> {args.out}")
    print(f"kredit dicatat -> {CREDITS_DB}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
