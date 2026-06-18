# Zones (anchor model)

Logical "zones" layered over nehir's single horizontal column strip. A zone is an **anchor**: the leftmost column of the windows tagged to it. There is always one strip — zones don't hide or split it; they're named jump targets that keep related apps grouped.

(Ported from the madang `ZoneEngine`; the niri-style "separate/hide" mode was intentionally **not** built — the anchor model gives the same day-to-day value without rewriting the viewport engine.)

## Behavior
- **`focus-zone N`** — jump focus to zone N's anchor (its first column), scrolling it into view. No-op if the zone is empty.
- **`move-window-to-zone N`** — tag the focused window's column to zone N and slide it into that zone's region of the strip, keeping zones grouped.
- **Auto-sort** — whenever new windows appear, the whole strip is re-ordered into zone order (zone 1 → 6) so apps stay grouped. No-op when zones are disabled or already sorted; the focused window stays focused across the re-sort. (`NiriLayoutEngine.applyZoneOrdering`, called from the window-sync pass.)

### Zone = initial placement, then sticky (independent of the app)
A **bundle assignment decides a window's zone only the first time it's seen** (a new window). After that the tag is **sticky and independent of the app**:
- `move-window-to-zone N` on any window **persists** — it is not snapped back to the app's configured zone.
- Reopening an app creates a fresh window, so it lands in its configured zone again.
- Windows with no bundle assignment are inferred by strip position (and can drift as the strip changes).

Tags are recomputed each session (not persisted across restart).

## Config: `~/.config/nehir/zones.json`
The app→zone map and zone names live in their own JSON file (seeded on first run), like
[`leader.json`](leader.md) — not in `settings.toml`, whose hand-written codec makes a nested map
awkward. Reloaded whenever settings are applied; edits take effect for **newly-opened** windows (or
after a restart), since existing tags are sticky.

```json
{
  "bundleAssignments": {
    "us.zoom.xos": 1,
    "md.obsidian": 2,
    "com.tinyspeck.slackmacgap": 3,
    "com.github.wez.wezterm": 4,
    "com.kagi.kagimacOS": 5,
    "com.anthropic.claudefordesktop": 6,
    "com.openai.chat": 6
  },
  "definitions": [
    { "id": 1, "name": "meeting", "icon": "camera" },
    { "id": 2, "name": "note",    "icon": "note" }
  ]
}
```

- **`bundleAssignments`** — `bundle id → zone id (1-based)`. Decides a window's zone on first sight.
- **`definitions`** — zone `id`/`name`/`icon` (cosmetic; the engine only needs the ids). Either key
  can be omitted to keep its defaults.
- The on/off switch is **not** here — it stays in `settings.toml` (`[general] zonesEnabled`).

Default assignments: 1 meeting `us.zoom.xos` · 2 note `md.obsidian` · 3 cat `com.tinyspeck.slackmacgap` · 4 duck `com.github.wez.wezterm` · 5 web `com.kagi.kagimacOS` · 6 ai `com.anthropic.claudefordesktop`,`com.openai.chat`.

> The SketchyBar plugin (`~/dotfiles/system/sketchybar/plugins/zones.sh`) hardcodes the same map
> independently — if you change `bundleAssignments` here, mirror it there so the bar matches.

## Enable & use
```toml
[general]
zonesEnabled = true   # default false
```
```sh
nehirctl command focus-zone 3            # jump to zone 3 (Slack)
nehirctl command move-window-to-zone 2   # send focused window to zone 2
```
Also available in the Command Palette and the [Leader](leader.md) tab (the Move ▸ / Switch ▸ folders), and bindable as hotkeys (`focus.zone1…6`, `move.toZone1…6`).

## Implementation
- `Sources/Nehir/Core/Layout/Niri/ZonesConfig.swift` — config + defaults (Codable; persists only `bundleAssignments`/`definitions`).
- `Sources/Nehir/Core/Config/ZonesConfigStore.swift` — load/seed `~/.config/nehir/zones.json` (mirrors `LeaderConfigStore`).
- `Sources/Nehir/Core/Layout/Niri/NiriLayoutEngine+ColumnOps.swift` — `applyZoneOrdering` (auto-sort the strip), called from `NiriLayoutHandler.syncAndInsert`.
- `Sources/Nehir/Core/Layout/Niri/ZoneEngine.swift` — pure state machine (tag/sort/anchor/restore-focus), keyed by `"pid:windowId"`. Tested (`Tests/NehirTests/ZoneEngineTests.swift`).
- `Sources/Nehir/Core/Controller/CommandHandler.swift` — `focusZoneInNiri` / `moveWindowToZoneInNiri` (reuse `focusColumn` / `moveColumnToIndex`); bundle id via `NSRunningApplication`.
- IPC: `focus-zone` / `move-window-to-zone` (1-based) in `NehirIPC/IPCModels.swift` + `IPCCommandRouter.swift`.
