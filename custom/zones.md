# Zones (anchor model)

Logical "zones" layered over nehir's single horizontal column strip. A zone is an **anchor**: the leftmost column of the windows tagged to it. There is always one strip — zones don't hide or split it; they're named jump targets that keep related apps grouped.

(Ported from the madang `ZoneEngine`; the niri-style "separate/hide" mode was intentionally **not** built — the anchor model gives the same day-to-day value without rewriting the viewport engine.)

## Behavior
- **`focus-zone N`** — jump focus to zone N's anchor (its first column), scrolling it into view. No-op if the zone is empty.
- **`move-window-to-zone N`** — tag the focused window's column to zone N and slide it into that zone's region of the strip, keeping zones grouped.

Windows auto-tag by **bundle id**; untagged windows are inferred by strip position. Tags are recomputed each session (not persisted).

## Default zone assignments
| Zone | Name | Apps (bundle id) |
|------|------|------------------|
| 1 | meeting | `us.zoom.xos` |
| 2 | note | `md.obsidian` |
| 3 | cat | `com.tinyspeck.slackmacgap` |
| 4 | duck | `com.github.wez.wezterm` |
| 5 | web | `com.kagi.kagimacOS` |
| 6 | ai | `com.anthropic.claudefordesktop`, `com.openai.chat` |

(Definitions/assignments are the `ZonesConfig` defaults; not yet exposed in TOML.)

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
- `Sources/Nehir/Core/Layout/Niri/ZonesConfig.swift` — config + defaults.
- `Sources/Nehir/Core/Layout/Niri/ZoneEngine.swift` — pure state machine (tag/sort/anchor/restore-focus), keyed by `"pid:windowId"`. Tested (`Tests/NehirTests/ZoneEngineTests.swift`).
- `Sources/Nehir/Core/Controller/CommandHandler.swift` — `focusZoneInNiri` / `moveWindowToZoneInNiri` (reuse `focusColumn` / `moveColumnToIndex`); bundle id via `NSRunningApplication`.
- IPC: `focus-zone` / `move-window-to-zone` (1-based) in `NehirIPC/IPCModels.swift` + `IPCCommandRouter.swift`.
