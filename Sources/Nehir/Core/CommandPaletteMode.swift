import Foundation

enum CommandPaletteMode: String, CaseIterable, Codable {
    case windows
    case menu
    case commands
    case leader

    var displayName: String {
        switch self {
        case .windows: "Windows"
        case .menu: "Menu"
        case .commands: "Commands"
        case .leader: "Leader"
        }
    }
}
