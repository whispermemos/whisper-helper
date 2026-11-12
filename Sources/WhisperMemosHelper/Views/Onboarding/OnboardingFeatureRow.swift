import SwiftUI

/*
 * One "how it works" line on the onboarding welcome step: an icon, a short
 * title and a sentence under it.
 */
struct OnboardingFeatureRow: View {
    let systemImage: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)

                Text(text)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    OnboardingFeatureRow(
        systemImage: "mic.fill",
        title: "Record a memo",
        text: "Say what you want done, and in which folder."
    )
    .padding()
    .frame(width: 380)
}
