import SwiftUI

/*
 * The Sessions tab of Settings: how a memo's session gets into the Claude app.
 * One choice per LaunchMode, each with a short explanation of how it works.
 */
struct SessionsSettingsView: View {
    @AppStorage(DefaultsKey.launchMode) private var launchMode = LaunchMode.afterFirstTurn

    var body: some View {
        Form {
            Section {
                Picker("Open new sessions", selection: $launchMode) {
                    ForEach(LaunchMode.allCases) { mode in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mode.title)
                            Text(mode.explanation)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 4)
                        .tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
            } header: {
                Text("When a memo arrives")
            }
        }
        .formStyle(.grouped)
    }
}
