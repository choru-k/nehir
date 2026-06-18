# Leader

A vim-style **leader menu** as a tab in the Command Palette: a configurable, single-key **tree** where each key either fires an action, focuses an app, or opens a **folder** (submenu).

## Opening
- **Double-tap F15** → palette opens on the **Leader** tab at the root menu.
- Or pick the **Leader** tab manually (`⌘4`).

## Keys
- Press an item's **key** → fires immediately (no Enter). Folder items (shown with `▸`) descend into a submenu.
- **Esc** → back out one level; **Esc** at the root → close. **Backspace** also backs out.
- Arrow keys + **Enter** work too, if you prefer selecting.

## Config: `~/.config/nehir/leader.json`
Seeded on first run with the tree below. Reloaded each time the leader opens, so edits apply on next open (no restart needed).

```json
{
  "doubleTapOpensLeader": true,
  "rootMenu": "main",
  "menus": {
    "main": [
      { "key": "c", "title": "Slack",  "app": "com.tinyspeck.slackmacgap" },
      { "key": "f", "title": "Full",   "action": "toggleFullscreen" },
      { "key": "a", "title": "AI",     "menu": "ai" },
      { "key": "m", "title": "Move",   "menu": "move" },
      { "key": "s", "title": "Switch", "menu": "switch" }
    ],
    "ai":     [ { "key": "c", "title": "Claude", "app": "com.anthropic.claudefordesktop" } ],
    "move":   [ { "key": "1", "title": "→ Meeting", "action": "moveWindowToZone.1" } ],
    "switch": [ { "key": "1", "title": "Meeting", "action": "focusZone.1" } ]
  }
}
```

### Item schema
Each item is `{ "key", "title" }` plus **exactly one** of:
- `"menu"` — name of a submenu to open (folder).
- `"app"` — a bundle id; focuses the running app or launches it.
- `"action"` — an action id (resolved via `ActionCatalog`), e.g. `focusZone.3`, `moveWindowToZone.2`, `toggleFullscreen`, `toggleFocusedWindowFloating`, `move.left`, `focusMonitorNext`. Any catalog action id works.

`doubleTapOpensLeader: false` makes double-tap F15 open the normal palette instead.

## Default tree (mirrors the old Hammerspoon leader)
- **main**: `c` Slack · `t` WezTerm · `w` Web · `n` Notes · `f` Full · `g` Float · `a` AI ▸ · `m` Move ▸ · `s` Switch ▸
- **ai**: `c` Claude · `o` ChatGPT
- **move**: `h/j/k/l` swap · `1`–`6` move window to zone
- **switch**: `1`–`6` focus zone · `H/L` focus prev/next monitor

## Implementation
- `Sources/Nehir/Core/Config/LeaderConfig.swift` — `LeaderConfig` / `LeaderMenuItem` + default tree + pure `LeaderNavigator` (tested in `Tests/NehirTests/LeaderConfigTests.swift`).
- `Sources/Nehir/Core/Config/LeaderConfigStore.swift` — load/seed `leader.json`.
- `Sources/Nehir/UI/CommandPalette/CommandPaletteController.swift` — `.leader` palette mode: single-key handling, folder stack + breadcrumb, app/action dispatch.
- Opened via `HotkeyCommand.openLeader` (F15 double-tap → `F15EventTap` → `CommandHandler` → `WMController.openLeaderPalette()`).
