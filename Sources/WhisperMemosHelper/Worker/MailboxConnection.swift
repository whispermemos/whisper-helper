import AppKit
import Combine
import os

/*
 * The one WebSocket between this Mac and the user's mailbox on the worker.
 * It stays open while the Mac is paired: tells the worker which folders exist,
 * pings every 30 seconds, and passes each job to JobRunner after acking it.
 * When the socket drops it reconnects, waiting 1 s, 2 s, 4 s... up to a minute,
 * and right away after the Mac wakes up. When the worker says the key is dead
 * (HTTP 401 or close code 4001) it unpairs, which brings the QR code back.
 */
@MainActor
final class MailboxConnection: ObservableObject {
    private static let removedCloseCode = 4001

    @Published private(set) var isOnline = false

    private let pairing: PairingStore
    private let folders: FoldersStore
    private let jobs: JobRunner
    private let logger = Logger(subsystem: "tech.median.Whisper.Helper", category: "mailbox")

    private var socket: URLSessionWebSocketTask?
    private var connecting: Task<Void, Never>?
    private var sentFolderNames: [String]?
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Lifecycle

    init(pairing: PairingStore, folders: FoldersStore, jobs: JobRunner) {
        self.pairing = pairing
        self.folders = folders
        self.jobs = jobs

        // @Published tells us just before the value changes, so use the value it hands over
        pairing.$key
            .sink { [weak self] key in
                self?.restart(key: key)
            }
            .store(in: &subscriptions)

        folders.$folders
            .dropFirst()
            .sink { [weak self] pickedFolders in
                Task {
                    try? await self?.sendFolders(pickedFolders)
                }
            }
            .store(in: &subscriptions)

        // sockets die silently while the Mac sleeps
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in
                self?.restart(key: self?.pairing.key)
            }
            .store(in: &subscriptions)
    }

    // MARK: - Disconnecting

    /// "Disconnect this Mac": tells the worker to forget this Mac, then forgets the key.
    func disconnect() async {
        try? await socket?.send(json: RemoveMessage())
        pairing.unpair()
    }

    // MARK: - Connecting

    /// Drops the current socket. With a key, starts connecting from scratch.
    private func restart(key: String?) {
        connecting?.cancel()
        socket?.cancel()
        isOnline = false
        connecting = key.map { key in
            Task {
                await stayConnected(key: key)
            }
        }
    }

    private func stayConnected(key: String) async {
        var delay = 1

        while !Task.isCancelled {
            let socket = openSocket(key: key)
            do {
                sentFolderNames = nil
                try await sendFolders(folders.folders)
                isOnline = true
                delay = 1
                try await listen(on: socket)
            } catch {
                logger.info("Socket closed: \(error.localizedDescription, privacy: .public)")
            }

            // a restart cancelled this loop and already started the next one
            if Task.isCancelled {
                return
            }
            isOnline = false

            if wasKeyRejected(by: socket) {
                pairing.unpair()
                return
            }

            try? await Task.sleep(for: .seconds(delay))
            delay = min(delay * 2, Config.maxReconnectDelay)
        }
    }

    private func openSocket(key: String) -> URLSessionWebSocketTask {
        var request = URLRequest(url: Config.socketUrl(path: "/api/socket"))
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")

        let socket = URLSession.shared.webSocketTask(with: request)
        socket.resume()
        self.socket = socket
        return socket
    }

    /// True when the worker refused the key on connecting, or closed the socket
    /// because this Mac was removed in the iOS app.
    private func wasKeyRejected(by socket: URLSessionWebSocketTask) -> Bool {
        let statusCode = (socket.response as? HTTPURLResponse)?.statusCode
        return statusCode == 401 || socket.closeCode.rawValue == Self.removedCloseCode
    }

    // MARK: - Messages

    /// Runs until the socket closes, which makes `receiveText` throw.
    private func listen(on socket: URLSessionWebSocketTask) async throws {
        let pinging = Task {
            await keepPinging(socket)
        }
        defer { pinging.cancel() }

        while true {
            let text = try await socket.receiveText()
            let message = try? JSONDecoder().decode(MailboxMessage.self, from: Data(text.utf8))

            if case .job(let job) = message {
                // ack before running anything. the worker deletes the job on ack,
                // so a job we could not ack comes again and must not run now.
                try await socket.send(json: AckMessage(jobId: job.id))
                jobs.add(job)
            }
        }
    }

    private func keepPinging(_ socket: URLSessionWebSocketTask) async {
        while (try? await Task.sleep(for: Config.pingInterval)) != nil {
            try? await socket.send(.string("ping"))
        }
    }

    /// Sends the folder names, unless the worker already has exactly this list.
    private func sendFolders(_ folders: [URL]) async throws {
        let names = folders.map(\.lastPathComponent)
        if names == sentFolderNames {
            return
        }
        try await socket?.send(json: FoldersMessage(folders: names))
        sentFolderNames = names
    }
}
