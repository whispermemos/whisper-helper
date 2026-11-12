import SwiftUI

/*
 * The centred title and one-line explanation at the top of every onboarding
 * step, so all three steps share the same type sizes.
 */
struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.title2.bold())

            Text(subtitle)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    OnboardingHeader(title: "Welcome", subtitle: "One line that says what this step is about.")
        .padding()
}
