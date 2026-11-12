import SwiftUI

/*
 * Onboarding step 2: the QR code that pairs this Mac with a Whisper Memos
 * account. Each code is good for one answer: after Deny, or after five minutes,
 * a fresh code and QR appear. Waiting stops when the step leaves the screen.
 */
struct OnboardingPairingStep: View {
    @EnvironmentObject private var pairing: PairingStore
    @State private var code: String?

    var body: some View {
        VStack(spacing: 20) {
            OnboardingHeader(
                title: "Connect Your iPhone",
                subtitle: "Scan this code with your iPhone camera. Then tap Allow in Whisper Memos."
            )

            if let code, let qrCode = QRCode.image(for: PairingSocket.connectUrl(code: code)) {
                Image(nsImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 180, height: 180)
                    .padding(14)
                    // white edge, so the camera can read it in dark mode too
                    .background(.white, in: .rect(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
            }

            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)

                Text("Waiting for your iPhone…")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            await pair()
        }
    }

    private func pair() async {
        while !Task.isCancelled {
            let code = PairingSocket.makeCode()
            self.code = code

            do {
                if case .approved(let key, let email) = try await PairingSocket.waitForAnswer(code: code) {
                    pairing.pair(key: key, email: email)
                    return
                }
                // denied or timed out: go around for a fresh code
            } catch {
                // the worker could not be reached. wait a little before trying a new code.
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }
}
