import SwiftUI

/*
 * Onboarding step 3: confirms which Whisper Memos account this Mac is now
 * connected to, and says what to do next (add folders).
 */
struct OnboardingConnectedStep: View {
    let email: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)

            OnboardingHeader(
                title: "This Mac Is Connected",
                subtitle: "Memos from \(email) can now start Claude Code sessions here."
            )

            Text("Next, add the folders Claude Code may work in. Only the folder names leave this Mac.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    OnboardingConnectedStep(email: "me@example.com")
        .padding(40)
        .frame(width: 460)
}
