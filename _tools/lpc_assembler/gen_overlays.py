#!/usr/bin/env python3
"""Gambar overlay design-time yang BELUM ada di pack LPC (spec §5 + PROP_IDENTITAS §EKSEKUSI).

Menghasilkan (832x2944, sejajar-frame dgn eulpc):
  horns.png        (Shadeborn)  — tanduk hitam di puncak kepala
  leaf_hair.png    (Dryad)      — mahkota daun hijau menutup rambut
  bark_skin.png    (Dryad)      — kulit-kayu; DITURUNKAN dari siluet badan -> sejajar sempurna,
                                  tampil di kulit (lengan/kepala) di bawah wardrobe (z-layer 2)
  sewing_basket.png (Otha)      — keranjang di pangkuan/pinggang
  lantern.png + lantern_glow.png (Sora) — lentera di tangan + GLOW WAJIB (#237)

Alignment: posisi kepala/badan dibaca dari eulpc_body_male.png per-sel -> motif nempel otomatis.
Ini FIRST-PASS pembukti-keterbacaan (hitam/kontras/ukuran-main), bukan seni per-frame final.
"""
import os
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
BODY = os.path.join(REPO, "assets_raw", "lpc_extra", "eulpc_body_male.png")
OUT = os.path.join(HERE, "overlays")
CELL = 64
W, H = 832, 2944


def _occupied_cells(alpha):
    cells = []
    for r in range(H // CELL):
        for c in range(W // CELL):
            if alpha.crop((c * CELL, r * CELL, c * CELL + CELL, r * CELL + CELL)).getbbox():
                cells.append((c, r))
    return cells


def _head_box(alpha, c, r):
    """Perkiraan kotak kepala dalam satu sel: (cx, top_y, half_w) koordinat lokal 0..64."""
    cell = alpha.crop((c * CELL, r * CELL, c * CELL + CELL, r * CELL + CELL))
    bbox = cell.getbbox()
    if not bbox:
        return None
    x0, y0, x1, y1 = bbox
    # kepala = ~14px teratas siluet; pusat horizontal dari baris itu
    px = cell.load()
    xs = []
    top = y0
    for y in range(y0, min(y0 + 14, y1)):
        for x in range(x0, x1):
            if px[x, y] > 40:
                xs.append(x)
    if not xs:
        return None
    cx = sum(xs) // len(xs)
    half = max(4, (max(xs) - min(xs)) // 2)
    return cx, top, half


def gen_horns(alpha, cells):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for c, r in cells:
        hb = _head_box(alpha, c, r)
        if not hb:
            continue
        cx, top, half = hb
        ox, oy = c * CELL, r * CELL
        for sign in (-1, 1):
            bx = ox + cx + sign * (half - 1)
            by = oy + top + 2
            # tanduk melengkung: segitiga hitam ~7px
            d.polygon([(bx, by), (bx + sign * 4, by - 7), (bx + sign * 1, by - 1)],
                      fill=(15, 12, 18, 255))
    im.save(os.path.join(OUT, "horns.png"))


def gen_leaf_hair(alpha, cells):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    dark = (44, 92, 40, 255)
    lite = (96, 150, 66, 255)
    for c, r in cells:
        hb = _head_box(alpha, c, r)
        if not hb:
            continue
        cx, top, half = hb
        ox, oy = c * CELL, r * CELL
        # mahkota daun: gugusan segitiga hijau menutup puncak kepala
        for i in range(-half, half + 1, 3):
            bx = ox + cx + i
            by = oy + top + 3
            col = lite if (i // 3) % 2 == 0 else dark
            d.polygon([(bx, by), (bx + 2, by - 6), (bx + 4, by)], fill=col)
        d.line([(ox + cx - half, oy + top + 3), (ox + cx + half, oy + top + 3)], fill=dark, width=1)
    im.save(os.path.join(OUT, "leaf_hair.png"))


def gen_bark_skin(body):
    """Kulit-kayu diturunkan dari siluet badan: recolor coklat + guratan vertikal.

    Karena diturunkan dari badan itu sendiri, ia SEJAJAR sempurna & tampil hanya di
    area kulit (di bawah wardrobe). Inilah alasan human-body+bark = wardrobe penuh.
    """
    src = body
    px = src.load()
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    op = im.load()
    for y in range(H):
        for x in range(W):
            a = px[x, y][3]
            if a == 0:
                continue
            lum = (px[x, y][0] + px[x, y][1] + px[x, y][2]) // 3
            base = 70 + lum // 3
            streak = -22 if (x % 3 == 0) else 0  # guratan kayu vertikal
            rr = max(0, min(255, base + 34 + streak))
            gg = max(0, min(255, base + 6 + streak))
            bb = max(0, min(255, base - 18))
            op[x, y] = (rr, gg, bb, a)
    im.save(os.path.join(OUT, "bark_skin.png"))


def gen_sewing_basket(alpha, cells):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for c, r in cells:
        cell = alpha.crop((c * CELL, r * CELL, c * CELL + CELL, r * CELL + CELL))
        bbox = cell.getbbox()
        if not bbox:
            continue
        x0, y0, x1, y1 = bbox
        ox, oy = c * CELL, r * CELL
        cx = ox + (x0 + x1) // 2
        wy = oy + y0 + int((y1 - y0) * 0.62)  # tinggi pinggang/pangkuan
        # keranjang ~13px + benang merah (kontras)
        d.rounded_rectangle([cx - 7, wy, cx + 7, wy + 8], radius=2, fill=(120, 84, 44, 255),
                            outline=(70, 46, 20, 255))
        d.line([cx - 6, wy + 2, cx + 6, wy + 2], fill=(150, 110, 66, 255))
        d.line([cx + 2, wy, cx + 6, wy - 5], fill=(190, 40, 40, 255), width=1)  # benang menuju tangan
    im.save(os.path.join(OUT, "sewing_basket.png"))


def gen_lantern(alpha, cells):
    lam = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    dl = ImageDraw.Draw(lam)
    dg = ImageDraw.Draw(glow)
    for c, r in cells:
        cell = alpha.crop((c * CELL, r * CELL, c * CELL + CELL, r * CELL + CELL))
        bbox = cell.getbbox()
        if not bbox:
            continue
        x0, y0, x1, y1 = bbox
        ox, oy = c * CELL, r * CELL
        hx = ox + x1 - 3          # di sisi tangan (kanan siluet)
        hy = oy + y0 + int((y1 - y0) * 0.55)
        # halo (additive-ish) — GLOW WAJIB, inti identitas Sora (#237)
        dg.ellipse([hx - 11, hy - 11, hx + 11, hy + 11], fill=(255, 196, 90, 90))
        dg.ellipse([hx - 6, hy - 6, hx + 6, hy + 6], fill=(255, 226, 140, 130))
        # kotak lentera + gagang
        dl.rectangle([hx - 4, hy - 5, hx + 4, hy + 5], fill=(210, 170, 60, 255),
                     outline=(60, 44, 16, 255))
        dl.line([hx, hy - 5, hx, hy - 9], fill=(60, 44, 16, 255))
    glow = glow.filter(ImageFilter.GaussianBlur(2))
    lam.save(os.path.join(OUT, "lantern.png"))
    glow.save(os.path.join(OUT, "lantern_glow.png"))


def main():
    os.makedirs(OUT, exist_ok=True)
    body = Image.open(BODY).convert("RGBA")
    alpha = body.split()[3]
    cells = _occupied_cells(alpha)
    gen_horns(alpha, cells)
    gen_leaf_hair(alpha, cells)
    gen_bark_skin(body)
    gen_sewing_basket(alpha, cells)
    gen_lantern(alpha, cells)
    print(f"overlay digambar -> {OUT} ({len(cells)} sel sejajar)")


if __name__ == "__main__":
    main()
