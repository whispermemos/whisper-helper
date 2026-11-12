import SwiftUI

/*
 * Onboarding step 1: welcomes the user and explains in three lines how a voice
 * memo becomes a Claude Code session on this Mac.
 */
struct OnboardingWelcomeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 72, height: 72)

                OnboardingHeader(
                    title: "Welcome to Whisper Memos Helper",
                    subtitle: "Start Claude Code sessions on this Mac with your voice."
                )
            }

            VStack(alignment: .leading, spacing: 16) {
                OnboardingFeatureRow(
                    systemImage: "mic.fill",
                    title: "Record a memo",
                    text: "Say what you want done, and in which folder."
                )
                OnboardingFeatureRow(
                    systemImage: "desktopcomputer",
                    title: "This Mac picks it up",
                    text: "The helper stays connected and gets the memo right away."
                )
                OnboardingFeatureRow(
                    systemImage: "apple.terminal",
                    title: "Claude Code starts working",
                    text: "A session opens in the Claude desktop app, in the right folder."
                )
            }
        }
    }
}

#Preview {
    OnboardingWelcomeStep()
        .padding(40)
        .frame(width: 460)
}
