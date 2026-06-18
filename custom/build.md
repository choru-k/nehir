# Building & running this fork

## Toolchain
The project pins **Swift 6.3** tools; the system default may be older. Build with swiftly:
```sh
~/.swiftly/bin/swiftly run swift build          # debug
~/.swiftly/bin/swiftly run swift build -c release
~/.swiftly/bin/swiftly run swift test
```

## macOS-15 SDK shim
`Sources/Nehir/UI/VisualEffectsCompatibility.swift` was reduced to its **macOS-15 fallbacks** because upstream uses macOS 26 "Liquid Glass" APIs (`glassEffect`, `backgroundExtensionEffect`) that aren't in the macOS 15 SDK. Marked with a `// ponytail:` note. **Revert it from upstream once building against the Xcode 26 SDK.**

## Package & run (local, no install)
There's no signed-release pipeline locally; assemble an ad-hoc `.app` and launch it:
```sh
APP=dist/Nehir.app
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Nehir   "$APP/Contents/MacOS/Nehir"
cp .build/release/nehirctl "$APP/Contents/MacOS/nehirctl"
cp Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp -R .build/release/Nehir_Nehir.bundle "$APP/Contents/Resources/"
codesign --force --deep --sign - --entitlements Nehir.entitlements "$APP"
pkill -x Nehir; open "$APP"
```
(Or, to replace the Homebrew app system-wide: `PATH="$HOME/.swiftly/bin:$PATH" mise run install:system` — needs sudo.)

## Permissions (TCC)
- **Accessibility** — required for tiling.
- **Input Monitoring** — required for the [F15](f15.md) tap only.

Each **ad-hoc rebuild gets a new code signature**, so macOS drops the grants and you must re-approve. Reset + re-grant:
```sh
tccutil reset Accessibility dev.guria.nehir
tccutil reset ListenEvent dev.guria.nehir
# relaunch, then enable Nehir in System Settings → Privacy & Security → {Accessibility, Input Monitoring}
```
To avoid re-granting on every rebuild, sign with a **stable self-signed certificate** instead of ad-hoc (`--sign -`) — TCC then keys on the signing identity, not the content hash.

## Custom test suites
`NehirF15ChordEngineTests`, `ZoneEngineTests`, `LeaderConfigTests`. Two upstream suites (`RefreshRoutingTests`, `AXEventHandlerTests`) fail under the macOS 15 SDK — pre-existing/environmental, unrelated to these features.
