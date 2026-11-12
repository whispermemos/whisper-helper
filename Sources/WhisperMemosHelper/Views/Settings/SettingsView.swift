import SwiftUI

/*
 * The Settings window (⌘,). Four tabs along the top: General, Sessions, Instructions
 * and Account. The tab icons come from SettingsTabIcon.
 */
struct SettingsView: View {
    private enum Tab {
        case general
        case sessions
        case instructions
        case account
    }

    @State private var selectedTab: Tab = .general

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label {
                        Text("General")
                    } icon: {
                        SettingsTabIcon.picture("settings-general", fallbackSymbol: "gearshape")
                    }
                }
                .tag(Tab.general)

            SessionsSettingsView()
                .tabItem {
                    Label {
                        Text("Sessions")
                    } icon: {
                        SettingsTabIcon.light(symbol: "macwindow")
                    }
                }
                .tag(Tab.sessions)

            InstructionsSettingsView()
                .tabItem {
                    Label {
                        Text("Instructions")
                    } icon: {
                        SettingsTabIcon.picture("settings-instructions", fallbackSymbol: "text.alignleft")
                    }
                }
                .tag(Tab.instructions)

            AccountSettingsView()
                .tabItem {
                    Label {
                        Text("Account")
                    } icon: {
                        SettingsTabIcon.light(symbol: "person.fill")
                    }
                }
                .tag(Tab.account)
        }
        .frame(width: 480, height: 380)
    }
}
