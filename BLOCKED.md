# BLOCKED — items needing a human (do not idle; work continues elsewhere)

Nothing currently blocks core progress. Minor/non-blocking items:

| Item | Why | Workaround in place | Needs human? |
|---|---|---|---|
| `.rar` VFX packs (Dark VFX 01-02, Smear VFX 01) | PowerShell/Expand-Archive can't read RAR; no unrar tool installed | Using original `fire_flow` VFX + particle FX for M3. RAR content optional polish | Optional: install 7-Zip/WinRAR, or ignore |
| Expired itch.io download (`eyJleHBpcmVz...==` file) | It's an HTML "link expired" page, not an asset | Ignored; ample CC0 assets already available | No |
| GameOver jingle | `GameOver1.wav` not found under that exact name in Ninja pack | Using `creature_die` SFX for death | No |

Font (m5x7) downloaded successfully and embedded — no fallback needed.

| `rcedit` not installed | Setting .exe icon/version metadata (Windows) needs `rcedit.exe` configured in Godot editor settings | `application/modify_resources=false` in export_presets.cfg → exe builds & runs fine without embedded icon/version. Install rcedit + set in Editor Settings > Export > Windows to enable metadata later | Optional (cosmetic exe metadata) |

**Export pipeline VERIFIED:** `export/Aetherion.exe` (84.8 MB, embedded PCK) builds and runs standalone.

## ⚠ Git push auth (needs human once)
The Git Credential Manager's cached GitHub token stopped working mid-session (GitHub requires token/OAuth,
not password; the browser re-auth can't run in the non-interactive agent shell). **Repo purge + `main`
force-push already landed on the remote** (verified `git ls-remote` → main = a56a78b, `.git` 5.7 MB, no
assets_raw). Commits made after that are **local-only** until re-auth. To restore pushing, run once in your
terminal: `git push origin main && git push origin v0.1-alpha --force`. After that the agent's pushes resume.
