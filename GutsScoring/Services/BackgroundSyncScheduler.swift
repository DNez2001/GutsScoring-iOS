import BackgroundTasks
import Foundation
import SwiftData

/// Schedules background outbox flush — port of Android WorkManager retry in `ScoreSyncOutbox`.
enum BackgroundSyncScheduler {
    static let taskIdentifier = "com.nezsports.gutsscoring.sync-flush"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(refreshTask)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Simulator often rejects background tasks; foreground flush still runs.
        }
    }

    private static func handle(_ task: BGAppRefreshTask) {
        schedule()

        let work = Task {
            let container = ScoringModelContainer.makeContainer()
            let result = await SyncFlushService.flushPendingOutboxes(container: container)
            task.setTaskCompleted(success: !result.hasPendingWork)
        }

        task.expirationHandler = {
            work.cancel()
        }
    }
}
