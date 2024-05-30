import SwiftUI

@main
struct WhereToWatchApp: App {
    @AppStorage("darkAppearanceOption") private var darkAppearanceOption: DarkAppearanceOption = .system

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(darkAppearanceOption.colorScheme)
        }
    }
}
