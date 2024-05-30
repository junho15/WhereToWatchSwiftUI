import SwiftUI

enum DarkAppearanceOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { self.rawValue }

    var description: String {
        switch self {
        case .system:
            NSLocalizedString("DARK_APPEARANCE_OPTION_SYSTEM", comment: "Dark Appearance Option System")
        case .light:
            NSLocalizedString("DARK_APPEARANCE_OPTION_LIGHT", comment: "Dark Appearance Option Light")
        case .dark:
            NSLocalizedString("DARK_APPEARANCE_OPTION_DARK", comment: "Dark Appearance Option Dark")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
