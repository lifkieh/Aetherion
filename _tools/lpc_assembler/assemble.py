#!/usr/bin/env python3
"""Perakit sprite LPC Aetherion — design-time (#162).

JSON per-karakter  ->  sheet 832x2944 flatten + slice per-animasi + manifest kredit.
Mesin HANYA menumpuk lapisan yang sudah ada; ia tak menggambar (overlay digambar oleh gen_overlays.py).

Hukum dikodekan:
  #231  dua tokoh bernama berbagi hook rambut/tutup-kepala  -> HARD FAIL (guard_231)
  #232  output HANYA ke .../characters/                     -> HARD FAIL (guard_232)
  SA    tiap sprite bawa <id>.credits.txt + LICENSE-CC-BY-SA.txt

Pemakaian:
  python assemble.py characters/merrit_fane.json --out game/assets/game/sprites/characters/
  python assemble.py --all characters/ --out game/assets/game/sprites/characters/
"""
import argparse
import json
import os
import sys
from PIL import Image

# Gerbang #231 hidup di uji_siluet.py — SATU sumber kebenaran. assemble.py
# memanggilnya, tidak menyalin rumusnya (dua salinan = dua ambang yang menyimpang).
from uji_siluet import AMBANG as AMBANG_SILUET, pasangan_kembar, silhouette_of_sheet

SHEET_W, SHEET_H = 832, 2944
CELL = 64

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))


class AssemblyError(Exception):
    """Kegagalan rakit yang menghentikan build (bukan warning)."""


# ------------------------------------------------------------------ util io
def _load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _catalog():
    return _load_json(os.path.join(HERE, "catalog.json"))


def _frame_map():
    return _load_json(os.path.join(HERE, "frame_map.json"))


def _credits_db():
    p = os.path.join(HERE, "credits_db.json")
    return _load_json(p) if os.path.exists(p) else {}


def _resolve_path(ref, cat):
    """Ubah nilai katalog jadi path absolut. '@overlay/x.png' -> overlay_root."""
    if ref.startswith("@overlay/"):
        return os.path.join(REPO_ROOT, cat["overlay_root"], ref[len("@overlay/"):])
    return os.path.join(REPO_ROOT, cat["lib_root"], ref)


# ------------------------------------------------------------------ imaging
def _open_layer(path):
    """Buka PNG, pastikan RGBA, tempel rata-ATAS ke kanvas 832x2944.

    Lapisan klasik 832x1344 -> baris 0-20 sejajar dgn sheet expanded (terbukti probe).
    Ukuran lain -> error (bukan diam): perakit tak menebak alignment.
    """
    if not os.path.exists(path):
        raise AssemblyError(f"lapisan hilang di pustaka: {path} — id tak ada, rakit DITOLAK (spec §5).")
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    if (w, h) == (SHEET_W, SHEET_H):
        return im
    if w == SHEET_W and h <= SHEET_H:
        canvas = Image.new("RGBA", (SHEET_W, SHEET_H), (0, 0, 0, 0))
        canvas.alpha_composite(im, (0, 0))  # rata-atas: baris 0..h/64 sejajar
        return canvas
    raise AssemblyError(
        f"lebar lapisan bukan 832 ({w}x{h}) di {os.path.basename(path)} — bukan format ULPC, rakit DITOLAK.")


def _tint(im, hexcol):
    """Recolor multiply per-lapisan (mempertahankan alpha & shading)."""
    r = int(hexcol[1:3], 16) / 255.0
    g = int(hexcol[3:5], 16) / 255.0
    b = int(hexcol[5:7], 16) / 255.0
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            cr, cg, cb, ca = px[x, y]
            if ca:
                px[x, y] = (int(cr * r), int(cg * g), int(cb * b), ca)
    return im


def _palette_shift(im, mode):
    """Recolor badan/kepala untuk ras. shadow=Shadeborn gelap, bark_green=Dryad."""
    if mode == "shadow":
        return _tint(im, "#4a4a5a")
    if mode in ("bark_green", "bark"):
        return _tint(im, "#8a9a6a")
    raise AssemblyError(f"palette_shift tak dikenal: {mode}")


# ------------------------------------------------------------------ z-order
def _layer_plan(char, cat):
    """Kembalikan daftar (label, path, tint) urut BELAKANG->DEPAN (spec §3).

    label dipakai manifest kredit. tint bisa None.
    """
    plan = []
    tints = char.get("tint", {}) or {}
    ro = char.get("race_overlay", []) or []
    props = char.get("story_prop", []) or []
    pshift = char.get("palette_shift")

    def add(slot, key, *, tint=None, required=True, table=None):
        table = table or cat.get(slot, {})
        if key is None:
            return
        if key not in table:
            if required:
                raise AssemblyError(
                    f"'{char['id']}': slot '{slot}' rujuk id '{key}' yang tak ada di katalog. Rakit DITOLAK (spec §5).")
            return
        ref = table[key]
        refs = ref if isinstance(ref, list) else [ref]
        for r in refs:
            plan.append((f"{slot}:{key}", _resolve_path(r, cat), tint))

    # 1 sayap belakang
    for o in ro:
        if o in cat["wing_back"]:
            plan.append((f"wing_back:{o}", _resolve_path(cat["wing_back"][o], cat), None))
    # 2 badan (+ palette shift / bark skin overlay)
    body_tint = tints.get("body")
    plan.append(("body:" + char["body"], _resolve_path(cat["body"][char["body"]], cat),
                 ("__pshift__:" + pshift) if pshift else body_tint))
    if "bark_skin" in ro:
        add("skin_overlay", "bark_skin")
    # 4-5 legs, feet (ras berkaki-native bisa skip via "skip_legs")
    if not char.get("skip_legs"):
        add("legs", char.get("legs"), tint=tints.get("legs"), required=bool(char.get("legs")))
        add("feet", char.get("feet"), tint=tints.get("feet"), required=bool(char.get("feet")))
    # 6 undershirt -> torso -> apron. TIGA lapis, bukan satu.
    #    `overalls`/`sleeveless2` di pustaka ULPC memang TANPA LENGAN — mereka dirancang
    #    dipakai DI ATAS kemeja, bukan langsung di kulit. Katalog #239 tak punya slot untuk
    #    kemeja itu, jadi enam tokoh Ashbrook lahir berlengan & berdada telanjang meski
    #    JSON-nya menyebut `torso`. Slot ini menutup celah itu (lapisan dari gen_layers.py).
    add("undershirt", char.get("undershirt"), tint=tints.get("undershirt"),
        required=bool(char.get("undershirt")))
    add("torso", char.get("torso"), tint=tints.get("torso"), required=bool(char.get("torso")))
    add("apron", char.get("apron"), tint=tints.get("apron"), required=bool(char.get("apron")))
    # 7 kepala (+ palette shift)  — KOREKSI SPEC §3: kepala SEBELUM janggut, kalau tidak
    #    kepala menimpa janggut & hook Old Bram hilang (ditemukan uji visual #151b).
    #    KEPALA MEWARISI WARNA BADAN. Pustaka eulpc cuma punya SATU nada kulit, jadi variasi
    #    kulit dilakukan lewat `tint.body`. Sebelum ini kepala tak ikut diwarnai — badan cokelat
    #    di atas leher pucat, cacat yang cuma kelihatan kalau tint dipakai (dan #239 tak memakainya,
    #    jadi ia tak pernah ketahuan). `tint.head` bisa menimpa bila memang diinginkan beda.
    head_key = char.get("head", char["body"])
    head_tint = tints.get("head", body_tint)
    plan.append(("head:" + head_key, _resolve_path(cat["head"][head_key], cat),
                 ("__pshift__:" + pshift) if pshift else head_tint))
    # 8 beard (DI DEPAN wajah, kanon ULPC z-beard > z-head)
    facial = char.get("facial", {}) or {}
    add("beard", facial.get("beard"), required=bool(facial.get("beard")))
    # 9 horns
    if "horns" in ro:
        add("race_overlay", "horns")
    # 10 rambut XOR tutup-kepala
    if char.get("headwear"):
        add("headwear", char["headwear"])
    elif char.get("hair"):
        add("hair", char["hair"], tint=tints.get("hair"))
    # 11 leaf_hair / starhat
    if "leaf_hair" in ro:
        add("race_overlay", "leaf_hair")
    # 12-13 props cerita (basket lap dulu, lalu cane/lantern; glow paling depan)
    order = {"sewing_basket": 0, "cane": 1, "lantern": 2, "lantern_glow": 3}
    for p in sorted(props, key=lambda x: order.get(x, 1)):
        add("story_prop", p, required=True)
    # 14 sayap depan
    for o in ro:
        if o in cat["wing_front"]:
            plan.append((f"wing_front:{o}", _resolve_path(cat["wing_front"][o], cat), None))
    return plan


def assemble_sheet(char, cat):
    """Rakit satu sheet 832x2944 flatten dari plan lapisan."""
    canvas = Image.new("RGBA", (SHEET_W, SHEET_H), (0, 0, 0, 0))
    used = []
    for label, path, tint in _layer_plan(char, cat):
        im = _open_layer(path)
        if isinstance(tint, str) and tint.startswith("__pshift__:"):
            im = _palette_shift(im, tint.split(":", 1)[1])
        elif tint:
            im = _tint(im.copy(), tint)
        canvas.alpha_composite(im)
        used.append((label, path))
    return canvas, used


# ------------------------------------------------------------------ slicing
def slice_sheet(sheet, fmap):
    """Potong slice per-animasi (putusan #3). Lewati animasi calibrate:true."""
    out = {}
    c = fmap["cell"]
    for anim, spec in fmap["animations"].items():
        if spec.get("calibrate"):
            continue
        dirs = spec["rows"]
        frames = spec["frames"]
        w = len(frames) * c
        h = len(dirs) * c
        strip = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        for di, d in enumerate(fmap["dir_order"]):
            if d not in dirs:
                continue
            row = dirs[d]
            for fi, fr in enumerate(frames):
                cell = sheet.crop((fr * c, row * c, fr * c + c, row * c + c))
                strip.alpha_composite(cell, (fi * c, di * c))
        out[anim] = strip
    return out


# ------------------------------------------------------------------ guards
def guard_231(sheets_per_id):
    """#231: dua tokoh bernama tak boleh punya SILUET kembar -> HARD FAIL.

    KENAPA INI MENGGANTI GERBANG LAMA
    ---------------------------------
    Versi lama membandingkan STRING id hook kepala: dua tokoh lolos asal nama
    rambutnya berbeda. Itu menangkap `curly_short` vs `curly_short`, tapi
    meloloskan `curly_short` vs `curly_short2` — dua rambut keriting yang nyaris
    identik BENTUKNYA. Old Bram lolos gerbang itu berbulan-bulan dan tetap terbaca
    kembar dengan Halloran di layar. Gerbang yang membandingkan NAMA tak pernah
    bisa menangkap kemiripan BENTUK.

    Versi ini mengukur bentuk: siluet alpha frame hadap-bawah, XOR antar-pasangan.
    Jalan SEBELUM PNG ditulis — tokoh kembar tak pernah mendarat di repo.

    Batasnya jujur: alpha buta WARNA. Dua tokoh berkerudung abu dan berkerudung
    biru lolos identik. Untuk itu tetap perlu mata (lihat uji_siluet.py).
    """
    sil = {cid: silhouette_of_sheet(sheet) for cid, sheet in sheets_per_id.items()}
    gagal = pasangan_kembar(sil)
    if gagal:
        rinci = "; ".join(f"{a} & {b} = {d} px" for a, b, d in gagal)
        raise AssemblyError(
            f"#231 DILANGGAR: siluet kembar (< {AMBANG_SILUET} px XOR): {rinci}. "
            f"Tokoh bernama WAJIB berbeda BENTUK, bukan cuma berbeda nama lapisan. "
            f"Rakit DITOLAK.")


def guard_232(out_dir):
    """#232: output HANYA ke .../characters/. Struktural, bukan harapan."""
    norm = os.path.normpath(os.path.abspath(out_dir)).replace("\\", "/")
    if not norm.rstrip("/").endswith("/characters") and "/characters/" not in norm + "/":
        raise AssemblyError(
            f"#232 DILANGGAR: output '{out_dir}' bukan folder characters/. "
            f"Perakit tak boleh menyentuh tiles/ atau ui/. Rakit DITOLAK.")
    for forbidden in ("/tiles/", "/tiles", "/ui/", "/ui"):
        if norm.endswith(forbidden) or (forbidden + "/") in (norm + "/"):
            if "/characters" not in norm:
                raise AssemblyError(f"#232 DILANGGAR: output menyentuh {forbidden}. Rakit DITOLAK.")


# ------------------------------------------------------------------ credits
LICENSE_TEXT = (
    "Aset sprite karakter di folder ini diturunkan dari Liberated Pixel Cup (LPC).\n"
    "Lisensi: CC-BY-SA 3.0 / GPL 3.0 (atribusi + share-alike WAJIB).\n"
    "Kredit per-sprite ada di <id>.credits.txt. Jangan hapus file ini (kewajiban SA).\n"
)


def write_credits(out_dir, char_id, used, cdb):
    lines = [f"# Kredit sprite: {char_id}", "# Lisensi: CC-BY-SA 3.0 (LPC). Atribusi WAJIB.", ""]
    flagged = False
    for label, path in used:
        base = os.path.basename(path)
        meta = cdb.get(base)
        if meta:
            lines.append(f"- {label}: {base} — {meta.get('author','?')} ({meta.get('license','CC-BY-SA 3.0')})")
        else:
            lines.append(f"- {label}: {base} — [TODO kredit: CC-BY-SA 3.0 LPC, seniman belum dicatat]")
            flagged = True
    if flagged:
        lines.append("")
        lines.append("# ⚠ ada lapisan tanpa kredit tercatat — lengkapi credits_db.json sebelum rilis (kewajiban SA).")
    with open(os.path.join(out_dir, f"{char_id}.credits.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    with open(os.path.join(out_dir, "LICENSE-CC-BY-SA.txt"), "w", encoding="utf-8") as f:
        f.write(LICENSE_TEXT)
    return flagged


# ------------------------------------------------------------------ build
def build_one(char, out_dir, cat, fmap, cdb, emit_sheet=True, sheet=None, used=None):
    if sheet is None:
        sheet, used = assemble_sheet(char, cat)
    cid = char["id"]
    os.makedirs(out_dir, exist_ok=True)
    written = []
    if emit_sheet:
        sp = os.path.join(out_dir, f"{cid}.png")
        sheet.save(sp)
        written.append(sp)
    for anim, strip in slice_sheet(sheet, fmap).items():
        sp = os.path.join(out_dir, f"{cid}_{anim}.png")
        strip.save(sp)
        written.append(sp)
    flagged = write_credits(out_dir, cid, used, cdb)
    return written, flagged, len(used)


def main(argv=None):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Perakit sprite LPC (design-time).")
    ap.add_argument("input", help="file JSON karakter, atau folder bila --all")
    ap.add_argument("--out", required=True, help="folder output (WAJIB .../characters/)")
    ap.add_argument("--all", action="store_true", help="rakit semua *.json di folder + guard_231 lintas-tokoh")
    ap.add_argument("--no-sheet", action="store_true", help="jangan tulis sheet penuh, slice saja")
    args = ap.parse_args(argv)

    guard_232(args.out)
    cat, fmap, cdb = _catalog(), _frame_map(), _credits_db()

    if args.all:
        files = sorted(f for f in os.listdir(args.input) if f.endswith(".json"))
        chars = [_load_json(os.path.join(args.input, f)) for f in files]
        # Rakit ke MEMORI dulu, gerbang siluet, BARU tulis. Urutan ini disengaja:
        # gerbang lama jalan sebelum perakitan karena ia cuma membaca JSON; gerbang
        # bentuk butuh lembar jadi. Kalau menulis dulu lalu menguji, tokoh kembar
        # sudah terlanjur mendarat di repo dan gerbangnya jadi laporan, bukan gerbang.
        siap, ok = [], 0
        for c in chars:
            try:
                sheet, used = assemble_sheet(c, cat)
                siap.append((c, sheet, used))
            except AssemblyError as e:
                print(f"[GAGAL] {c.get('id','?')}: {e}", file=sys.stderr)
        guard_231({c["id"]: s for c, s, _ in siap if c.get("named")})
        for c, sheet, used in siap:
            try:
                w, flagged, n = build_one(c, args.out, cat, fmap, cdb,
                                          emit_sheet=not args.no_sheet, sheet=sheet, used=used)
                print(f"[OK] {c['id']}: {n} lapisan -> {len(w)} file" + ("  ⚠kredit" if flagged else ""))
                ok += 1
            except AssemblyError as e:
                print(f"[GAGAL] {c.get('id','?')}: {e}", file=sys.stderr)
        print(f"\n{ok}/{len(chars)} tokoh dirakit.")
        return 0 if ok == len(chars) else 2

    # Satu tokoh sendirian tak punya lawan banding — gerbang #231 hanya berarti
    # lintas-tokoh (--all). Merakit satu-satu TIDAK menjamin #231.
    char = _load_json(args.input)
    w, flagged, n = build_one(char, args.out, cat, fmap, cdb, emit_sheet=not args.no_sheet)
    print(f"[OK] {char['id']}: {n} lapisan -> {len(w)} file" + ("  ⚠kredit" if flagged else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
