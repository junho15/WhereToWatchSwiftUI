import SwiftUI

struct SettingsView: View {
    @AppStorage("darkAppearanceOption") private var darkAppearanceOption: DarkAppearanceOption = .system

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("DARK_APPEARANCE_OPTION", selection: $darkAppearanceOption) {
                        ForEach(DarkAppearanceOption.allCases) { option in
                            Text(option.description).tag(option)
                        }
                    }
                } header: {
                    Text("DARK_APPEARANCE_OPTION")
                }
            }
            .navigationTitle("SETTINGS_TAB_TITLE")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
