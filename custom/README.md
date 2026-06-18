# Custom features (this fork)

Features added on top of upstream `guria/nehir`. All are **off by default** — upstream behavior is unchanged until you opt in.

- [F15 chord layer](f15.md) — hold-F15 + key runs commands; double-tap opens the Leader tab.
- [Zones](zones.md) — named "anchor" regions in the single column strip; jump to / send windows to a zone.
- [Leader](leader.md) — a configurable, vim-style single-key menu tree, shown as a Command Palette tab.
- [Building & running this fork](build.md) — toolchain, the macOS-15 SDK shim, packaging, permissions.

## Quick enable
`~/.config/nehir/settings.toml`:
```toml
[general]
f15Enabled = true
zonesEnabled = true
# f15DoubleTapSeconds = 0.3   # optional
```
Structured custom-feature config lives in its own JSON file (seeded on first run):
- `~/.config/nehir/leader.json` — the leader tree.
- `~/.config/nehir/zones.json` — the app→zone map (`bundleAssignments`) + zone names.

After enabling F15, grant **Input Monitoring** (System Settings → Privacy & Security → Input Monitoring); tiling needs **Accessibility** as usual.
