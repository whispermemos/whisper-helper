import Combine
import Sparkle

/*
 * Gives the helper's menus and Settings access to Sparkle updates. Created by HelperApp.
 * Sparkle reads the signed feed named in Info.plist (SUFeedURL) and keeps its own
 * preferences. Development builds never start the updater.
 */
final class UpdateManager: NSObject, ObservableObject, SPUStandardUserDriverDelegate {
    @Published private(set) var canCheckForUpdates = false
    @Published private(set) var wantsAutomaticChecks = false
    @Published private(set) var wantsAutomaticUpdates = false
    @Published private(set) var hasUpdateAvailable = false

    private lazy var controller = SPUStandardUpdaterController(
        startingUpdater: false, updaterDelegate: nil, userDriverDelegate: self
    )

    var isEnabled: Bool {
        #if DEBUG
        false
        #else
        true
        #endif
    }

    /// For example "1.0.2 (5)": the version people see and the build number Sparkle compares.
    static var version: String {
        let info = Bundle.main.infoDictionary
        let shortVersion = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(shortVersion) (\(build))"
    }

    func start() {
        guard isEnabled else { return }

        let updater = controller.updater
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
        updater.publisher(for: \.automaticallyChecksForUpdates)
            .assign(to: &$wantsAutomaticChecks)
        updater.publisher(for: \.automaticallyDownloadsUpdates)
            .assign(to: &$wantsAutomaticUpdates)

        do {
            try updater.start()
        } catch {
            NSLog("Could not start updater: %@", error.localizedDescription)
        }
    }

    func checkForUpdates() {
        guard isEnabled, canCheckForUpdates else { return }
        controller.checkForUpdates(nil)
    }

    func setAutomaticChecks(_ wantsChecks: Bool) {
        controller.updater.automaticallyChecksForUpdates = wantsChecks
    }

    func setAutomaticUpdates(_ wantsUpdates: Bool) {
        controller.updater.automaticallyDownloadsUpdates = wantsUpdates
    }

    // The helper often runs with no window open, so Sparkle shows a found update quietly
    // and we mark it in the menus instead.
    var supportsGentleScheduledUpdateReminders: Bool { true }

    func standardUserDriverWillHandleShowingUpdate(
        _ handleShowingUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState
    ) {
        hasUpdateAvailable = true
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        hasUpdateAvailable = false
    }

    func standardUserDriverWillFinishUpdateSession() {
        hasUpdateAvailable = false
    }
}
