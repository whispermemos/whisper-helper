import SwiftUI

/*
 * The onboarding sheet on the main window, shown while this Mac is not paired.
 * Three steps: a welcome that explains how it works, the QR code to scan, and
 * a confirmation with the connected account. It moves to the last step by
 * itself when pairing succeeds; Done then reveals the list of folders.
 */
struct OnboardingSheet: View {
    private enum Step {
        case welcome
        case pairing
        case connected
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var pairing: PairingStore
    @State private var step = Step.welcome

    var body: some View {
        Group {
            switch step {
            case .welcome:
                OnboardingWelcomeStep()
            case .pairing:
                OnboardingPairingStep()
            case .connected:
                OnboardingConnectedStep(email: pairing.email ?? "")
            }
        }
        .padding(.horizontal, 36)
        .frame(width: 440, height: 430)
        .interactiveDismissDisabled()
        .onChange(of: pairing.isPaired) { _, isPaired in
            step = isPaired ? .connected : .welcome
        }
        .toolbar {
            switch step {
            case .welcome:
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        step = .pairing
                    }
                }
            case .pairing:
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        step = .welcome
                    }
                }
                // moves on by itself once the phone allows this Mac
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {}
                        .disabled(true)
                }
            case .connected:
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
