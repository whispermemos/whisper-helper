import Foundation

/*
 * Remembers which Whisper Memos account this Mac is paired with.
 * The key the worker handed out stays in the keychain, the account's email in
 * UserDefaults. OnboardingPairingStep fills it in, MailboxConnection connects
 * while there is a key and clears it when the worker says the key is dead.
 */
@MainActor
final class PairingStore: ObservableObject {
    private static let keychainKey = "macKey"

    @Published private(set) var key: String?
    @Published private(set) var email: String?

    var isPaired: Bool { key != nil }

    // MARK: - Lifecycle

    init() {
        key = Keychain.read(Self.keychainKey)
        email = UserDefaults.standard.string(forKey: DefaultsKey.email)
    }

    // MARK: - Pairing

    func pair(key: String, email: String) {
        Keychain.write(Self.keychainKey, value: key)
        UserDefaults.standard.set(email, forKey: DefaultsKey.email)
        self.key = key
        self.email = email
    }

    func unpair() {
        Keychain.delete(Self.keychainKey)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.email)
        key = nil
        email = nil
    }
}
