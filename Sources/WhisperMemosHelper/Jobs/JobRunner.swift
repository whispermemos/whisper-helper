import Foundation
import os

/*
 * Starts a Claude Code session for each job the worker sends, one at a time.
 * MailboxConnection adds jobs as they arrive; the rest wait in memory. The worker
 * already chose the folder, so this only finds it on disk and hands the memo to
 * ClaudeLauncher. What happened last is kept as one sentence for the menu.
 */
@MainActor
final class JobRunner: ObservableObject {
    /// One plain sentence for the menu, e.g. "Started a session in whisper-memos".
    @Published private(set) var lastEvent: String?

    private let folders: FoldersStore
    private let logger = Logger(subsystem: "tech.median.Whisper.Helper", category: "jobs")
    private let (waitingJobs, queue) = AsyncStream.makeStream(of: Job.self)

    // MARK: - Lifecycle

    init(folders: FoldersStore) {
        self.folders = folders

        // a single loop takes jobs off the queue, so only one runs at a time
        Task {
            for await job in waitingJobs {
                await run(job)
            }
        }
    }

    // MARK: - Jobs

    func add(_ job: Job) {
        queue.yield(job)
    }

    private func run(_ job: Job) async {
        guard let folder = folders.folder(named: job.folder) else {
            report("Could not find the folder \(job.folder)")
            return
        }

        report("Working on a memo in \(job.folder)")
        do {
            let prompt = MemoInstructions.prompt(memo: job.prompt, instructions: MemoInstructions.current)
            try await ClaudeLauncher.launch(prompt: prompt, title: job.title, in: folder)
            report("Started a session in \(job.folder)")
        } catch {
            report("Could not start a session in \(job.folder): \(error.localizedDescription)")
        }
    }

    private func report(_ event: String) {
        logger.info("\(event, privacy: .public)")
        lastEvent = event
    }
}
