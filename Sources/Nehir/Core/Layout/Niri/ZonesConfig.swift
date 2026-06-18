import Foundation

/// How the zones of a workspace's column strip are presented.
enum ZoneLayoutMode: String, Codable, Equatable {
    /// All zones share one continuous strip; a zone is an ordinal region. (nehir's default behavior.)
    case consecutive
    /// Each zone is its own space; only the current zone's columns are visible. (niri-style.)
    case separate
}

struct ZoneDefinition: Codable, Equatable {
    var id: Int
    var name: String
    var icon: String?

    init(id: Int, name: String, icon: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

/// Ported from madang's ZonesConfig. Built from the `[zones]` TOML table; bundle assignments
/// map an app's bundle id to a zone id so its windows auto-tag.
struct ZonesConfig: Equatable {
    var enabled: Bool
    var layoutMode: ZoneLayoutMode
    var definitions: [ZoneDefinition]
    var bundleAssignments: [String: Int]

    init(
        enabled: Bool = false,
        layoutMode: ZoneLayoutMode = .consecutive,
        definitions: [ZoneDefinition] = ZonesConfig.defaultDefinitions,
        bundleAssignments: [String: Int] = ZonesConfig.defaultBundleAssignments
    ) {
        self.enabled = enabled
        self.layoutMode = layoutMode
        self.definitions = definitions
        self.bundleAssignments = bundleAssignments
    }

    static let defaults = ZonesConfig()

    static let defaultDefinitions: [ZoneDefinition] = [
        ZoneDefinition(id: 1, name: "meeting", icon: "camera"),
        ZoneDefinition(id: 2, name: "note", icon: "note"),
        ZoneDefinition(id: 3, name: "cat", icon: "chat"),
        ZoneDefinition(id: 4, name: "duck", icon: "terminal"),
        ZoneDefinition(id: 5, name: "web", icon: "web"),
        ZoneDefinition(id: 6, name: "ai", icon: "ai")
    ]

    static let defaultBundleAssignments: [String: Int] = [
        "us.zoom.xos": 1,
        "md.obsidian": 2,
        "com.tinyspeck.slackmacgap": 3,
        "com.github.wez.wezterm": 4,
        "com.kagi.kagimacOS": 5,
        "com.anthropic.claudefordesktop": 6,
        "com.openai.chat": 6
    ]
}
