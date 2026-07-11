from PIL import Image, ImageDraw, ImageFont
import os

OUT = "/home/claude/charsys"
os.makedirs(OUT + "/sheets", exist_ok=True)
OUTLINE = (36, 31, 54, 255)
CW, CH = 32, 32

# ---------- palet ras: (base, shadow, highlight) ----------
RACE_SKIN = {
  "human":    ("#f5c9a2", "#c98a5c", "#ffe4c8"),
  "human2":   ("#c98a5c", "#a5713f", "#e0b088"),
  "wolfkin":  ("#a5713f", "#6b4226", "#c98a5c"),
  "lizardkin":("#4fa352", "#2e6b3f", "#8fd46a"),
  "candyfolk":("#f78fc8", "#d95fa4", "#ffc2e2"),
  "frostkin": ("#6fb4d9", "#3a6fa0", "#b8e4f2"),
  "undead":   ("#a89fc4", "#6f6690", "#e8e2f4"),
}
RACE_FEATURES = {
  "human": [], "human2": [],
  "wolfkin": ["ears_wolf", "muzzle", "tail_wolf"],
  "lizardkin": ["crest", "tail_lizard", "scales"],
  "candyfolk": ["sprinkles", "gum_hair"],
  "frostkin": ["horns_ice"],
  "undead": ["ribs", "hollow_eyes"],
}

def P(d, x, y, c): d.point((x, y), fill=c)
def R(d, a, b, cx, dy, c): d.rectangle([a, b, cx, dy], fill=c)

# ================= PART: KAKI (y 18..27) =================
def draw_legs(d, race, frame, side, pants=None):
    base, sh, hi = RACE_SKIN[race]
    col = pants if pants else base
    csh = sh if not pants else pants
    l = -1 if frame == 0 else (1 if frame == 2 else 0)
    r = -l
    R(d, 6, 18, 6+2, 18, "#241f36")  # sabuk pinggul kecil
    if race == "lizardkin" or race == "wolfkin":
        # kaki digitigrade: paha lebih tebal, "tekukan" 1px
        R(d, 5, 19, 7, 22+l, col); P(d, 5, 22+l, csh)
        R(d, 8, 19, 10, 22+r, col); P(d, 10, 22+r, csh)
        R(d, 5, 23+l, 6, 24+l, csh); R(d, 9, 23+r, 10, 24+r, csh)  # betis mundur
        R(d, 4, 25+l, 7, 25+l, sh); R(d, 8, 25+r, 11, 25+r, sh)     # kaki/cakar panjang
        if race == "lizardkin":
            P(d, 4, 25+l, hi); P(d, 11, 25+r, hi)  # kuku
    else:
        R(d, 5, 19, 7, 24+l, col); R(d, 5, 19, 5, 24+l, csh)
        R(d, 8, 19, 10, 24+r, col); R(d, 10, 19, 10, 24+r, csh)
        shoe = "#241f36" if race != "undead" else sh
        R(d, 5, 25+l, 7, 25+l, shoe); R(d, 8, 25+r, 10, 25+r, shoe)
        if race == "undead":  # tulang kering terlihat
            P(d, 6, 21+l, hi); P(d, 9, 22+r, hi)

# ================= PART: BADAN + TANGAN (y 9..18) =================
def draw_torso(d, race, frame, side, direction, shirt=None):
    base, sh, hi = RACE_SKIN[race]
    col = shirt if shirt else base
    csh = sh
    l = -1 if frame == 0 else (1 if frame == 2 else 0)
    r = -l
    R(d, 4, 10, 11, 18, col)
    R(d, 4, 10, 4, 18, csh); R(d, 4, 16, 11, 18, csh)      # shade kiri+bawah
    R(d, 5, 10, 10, 10, hi if not shirt else col)           # bahu highlight
    if "ribs" in RACE_FEATURES[race] and not shirt:
        for y in (12, 14, 16): R(d, 6, y, 9, y, hi)
    if "scales" in RACE_FEATURES[race] and not shirt:
        for (x, y) in [(6,12),(9,13),(7,15),(10,16)]: P(d, x, y, hi)
    if "sprinkles" in RACE_FEATURES[race]:
        for (x, y, c) in [(6,12,"#f5e042"),(9,14,"#6fb4d9"),(7,16,"#fff0f8")]: P(d, x, y, c)
    # tangan (kulit ras torso — inilah "tangan ras X")
    if direction in ("down", "up"):
        R(d, 3, 11+max(0,l), 3, 15+l, base); P(d, 3, 16+l, sh)
        R(d, 12, 11+max(0,r), 12, 15+r, base); P(d, 12, 16+r, sh)
    else:
        ax = 3 if direction == "left" else 12
        R(d, ax, 11, ax, 15+l, base); P(d, ax, 16+l, sh)

# ================= PART: KEPALA (y 0..9) =================
def draw_head(d, race, direction, hair=None, hair_color="#241f36"):
    base, sh, hi = RACE_SKIN[race]
    R(d, 4, 2, 11, 9, base)
    R(d, 4, 8, 11, 9, sh)                                   # rahang shade
    R(d, 5, 2, 10, 2, hi)
    f = RACE_FEATURES[race]
    if direction == "down":
        if "hollow_eyes" in f:
            R(d, 5, 5, 6, 6, OUTLINE); R(d, 9, 5, 10, 6, OUTLINE)
        else:
            P(d, 6, 5, OUTLINE); P(d, 9, 5, OUTLINE)
            P(d, 6, 4, (255,255,255,255)); P(d, 9, 4, (255,255,255,255))
        if "muzzle" in f:
            R(d, 6, 6, 9, 8, hi); P(d, 7, 6, OUTLINE); P(d, 8, 6, OUTLINE)  # moncong + hidung
        elif "crest" not in f:
            P(d, 7, 7, sh)
    elif direction in ("left", "right"):
        P(d, 6, 5, OUTLINE); P(d, 6, 4, (255,255,255,255))
        if "muzzle" in f or "crest" in f:
            R(d, 3, 6, 4, 8, base); P(d, 3, 6, OUTLINE)      # moncong samping
        R(d, 11, 2, 11, 8, sh)
    # fitur atas kepala
    if "ears_wolf" in f:
        for x in (4, 10):
            P(d, x, 1, base); P(d, x, 0, base); P(d, x+1, 1, sh)
    if "crest" in f:
        for i, x in enumerate((5, 7, 9)):
            R(d, x, 0, x, 1, sh)
    if "horns_ice" in f:
        P(d, 4, 0, "#b8e4f2"); P(d, 4, 1, "#eefaff"); P(d, 11, 0, "#b8e4f2"); P(d, 11, 1, "#eefaff")
    # rambut
    if "gum_hair" in f:
        R(d, 3, 0, 12, 3, hair_color); R(d, 3, 3, 4, 5, hair_color); R(d, 11, 3, 12, 5, hair_color)
        P(d, 5, 1, "#fff0f8"); P(d, 9, 2, "#fff0f8")         # kilau permen
    elif hair == "short":
        R(d, 4, 1, 11, 3, hair_color); P(d, 4, 4, hair_color); P(d, 11, 4, hair_color)
    elif hair == "long":
        R(d, 4, 1, 11, 3, hair_color)
        R(d, 3, 2, 3, 11, hair_color); R(d, 12, 2, 12, 11, hair_color)
    elif hair == "spiky":
        for x in (4, 6, 8, 10): R(d, x, 0, x, 2, hair_color)
        R(d, 4, 2, 11, 3, hair_color)
    if direction == "up":
        R(d, 4, 2, 11, 8, hair_color if hair or "gum_hair" in f else sh)

# ================= EKOR (layer belakang) =================
def draw_tail(d, race, direction, frame):
    base, sh, hi = RACE_SKIN[race]
    if "tail_wolf" in RACE_FEATURES[race]:
        if direction == "down": pass
        elif direction == "up":
            R(d, 7, 18, 8, 22, base); P(d, 7, 23, hi)
        else:
            x0, x1 = (12, 13) if direction == "left" else (2, 3)
            R(d, x0, 17, x1, 18, base)
            P(d, 14 if direction == "left" else 1, 16, hi)
    if "tail_lizard" in RACE_FEATURES[race]:
        if direction == "up":
            R(d, 7, 18, 8, 24, base); R(d, 8, 24, 9, 25, sh)
        elif direction in ("left", "right"):
            xs = (12, 14) if direction == "left" else (1, 3)
            R(d, xs[0], 18, xs[1], 19, base); P(d, xs[1] if direction=="left" else xs[0], 20, sh)

def compose(config, direction, frame):
    """config: head_race, torso_race, legs_race, hair, hair_color, shirt, pants"""
    im = Image.new("RGBA", (16, 28), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    draw_tail(d, config.get("torso_race"), direction, frame)
    draw_legs(d, config["legs_race"], frame, direction in ("left","right"), config.get("pants"))
    draw_torso(d, config["torso_race"], frame, direction in ("left","right"), direction, config.get("shirt"))
    draw_head(d, config["head_race"], direction, config.get("hair"), config.get("hair_color", "#241f36"))
    if direction == "right":
        im = im.transpose(Image.FLIP_LEFT_RIGHT)
    return im

def outline(im):
    b = Image.new("RGBA", (im.width+2, im.height+2), (0,0,0,0))
    a = im.split()[3]
    for dx, dy in [(0,1),(2,1),(1,0),(1,2)]:
        s = Image.new("RGBA", b.size, (0,0,0,0))
        s.paste(Image.new("RGBA", im.size, OUTLINE), (dx, dy), a)
        b = Image.alpha_composite(b, s)
    b.paste(im, (1,1), im)
    return b

def make_sheet(config):
    sheet = Image.new("RGBA", (CW*3, CH*4), (0,0,0,0))
    for r, dr in enumerate(["down","left","right","up"]):
        for f in range(3):
            spr = outline(compose(config, dr, f))
            cell = Image.new("RGBA", (CW, CH), (0,0,0,0))
            cell.paste(spr, ((CW-spr.width)//2, CH-spr.height-1), spr)
            sheet.paste(cell, (f*CW, r*CH))
    return sheet

def pure(race, hair="short", hc="#241f36", shirt=None, pants=None):
    return dict(head_race=race, torso_race=race, legs_race=race, hair=hair, hair_color=hc, shirt=shirt, pants=pants)

DEMOS = {
  "human_m":    pure("human", "short", "#6b4226", shirt="#2e6b3f", pants="#453d5c"),
  "human_f":    pure("human2", "long", "#241f36", shirt="#8a3a6b", pants="#5c2380"),
  "wolfkin":    pure("wolfkin", None, shirt="#8f2611", pants="#453d5c"),
  "lizardkin":  pure("lizardkin", None, shirt=None, pants="#6b4226"),
  "candyfolk":  pure("candyfolk", None, hc="#c4302b"),
  "frostkin":   pure("frostkin", "spiky", "#eefaff", shirt="#1e3a5c", pants="#3a6fa0"),
  "undead":     pure("undead", None, pants="#453d5c"),
  # CHIMERA: campuran ras per bagian — fitur inti creator
  "mix_wolf_head_human_body": dict(head_race="wolfkin", torso_race="human", legs_race="human",
                                   hair=None, shirt="#3a6fa0", pants="#453d5c"),
  "mix_lizard_legs_frost_head": dict(head_race="frostkin", torso_race="human2", legs_race="lizardkin",
                                     hair="spiky", hair_color="#b8e4f2", shirt="#2e6b3f"),
}

sheets = {}
for name, cfg in DEMOS.items():
    s = make_sheet(cfg)
    s.save(f"{OUT}/sheets/{name}_32x32.png")
    sheets[name] = s

# preview
S = 5; gap = 14; cols = 3
rows = (len(sheets)+cols-1)//cols
cw = CW*3*S+gap; chh = CH*S+30
W = cols*cw+gap; H = rows*chh+60
pv = Image.new("RGB", (W, H), "#171425")
pd = ImageDraw.Draw(pv)
try:
    f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 13)
    ft = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 18)
except Exception:
    f = ft = ImageFont.load_default()
pd.text((gap, 10), "AETHERION CHARACTER SYSTEM v2 - 6 ras + 2 chimera (baris 'down')", font=ft, fill="#e8e2f4")
for i, (name, sh) in enumerate(sheets.items()):
    x = gap + (i % cols)*cw; y = 46 + (i // cols)*chh
    row = sh.crop((0, 0, CW*3, CH)).resize((CW*3*S, CH*S), Image.NEAREST)
    pv.paste(row, (x, y), row)
    pd.text((x, y+CH*S+2), name, font=f, fill="#a89fc4")
pv.save(f"{OUT}/charsys_preview.png")
print("ok", len(sheets))
