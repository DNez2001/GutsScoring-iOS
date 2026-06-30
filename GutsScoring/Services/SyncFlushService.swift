import Foundation
import SwiftData

/// Flushes score + event outboxes — used on foreground resume and BG tasks.
@MainActor
enum SyncFlushService {
    static func flushPendingOutboxes(context: ModelContext) async -> SyncFlushResult {
        let scoreOutbox = ScoreSyncOutbox(context: context)
        let eventOutbox = EventSyncOutbox(context: context)
        var scoreFlushed = 0
        var eventsFlushed = 0
        var lastError: String?

        do {
            scoreFlushed = try await scoreOutbox.flushAll()
        } catch {
            lastError = error.localizedDescription
        }

        do {
            eventsFlushed = try await eventOutbox.flushAll()
        } catch {
            lastError = error.localizedDescription
        }

        let scorePending = (try? scoreOutbox.pendingCount()) ?? 0
        let eventsPending = (try? eventOutbox.pendingCount()) ?? 0

        return SyncFlushResult(
            scoreFlushed: scoreFlushed,
            eventsFlushed: eventsFlushed,
            scorePending: scorePending,
            eventsPending: eventsPending,
            lastError: lastError
        )
    }

    static func flushPendingOutboxes(container: ModelContainer) async -> SyncFlushResult {
        let context = ModelContext(container)
        return await flushPendingOutboxes(context: context)
    }
}

struct SyncFlushResult {
    let scoreFlushed: Int
    let eventsFlushed: Int
    let scorePending: Int
    let eventsPending: Int
    let lastError: String?

    var hasPendingWork: Bool { scorePending + eventsPending > 0 }
}
