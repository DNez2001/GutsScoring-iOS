import Foundation
import SwiftData

/// Offline throw-event batch queue — port of Android `EventSyncOutbox` (skeleton).
@MainActor
final class EventSyncOutbox {
    private let context: ModelContext
    private let api: MobileScoringService
    private let encoder = JSONEncoder()

    init(context: ModelContext, api: MobileScoringService = MobileScoringService()) {
        self.context = context
        self.api = api
    }

    func pendingCount() throws -> Int {
        try context.fetchCount(FetchDescriptor<PendingEventSyncRecord>())
    }

    func enqueue(event: ThrowEventInput, state: GameUiState, matchRef: String, tournamentId: String) throws {
        let dto = ThrowEventMapping.toDTO(event: event, state: state)
        let payload = try encoder.encode(dto)
        let json = String(data: payload, encoding: .utf8) ?? "{}"
        context.insert(
            PendingEventSyncRecord(
                clientEventId: event.clientEventId,
                matchRef: matchRef,
                tournamentId: tournamentId,
                payloadJson: json
            )
        )
        try context.save()
        BackgroundSyncScheduler.schedule()
    }

    func remove(clientEventId: String) throws {
        let descriptor = FetchDescriptor<PendingEventSyncRecord>(
            predicate: #Predicate { $0.clientEventId == clientEventId }
        )
        for row in try context.fetch(descriptor) {
            context.delete(row)
        }
        try context.save()
    }

    @discardableResult
    func flushAll() async throws -> Int {
        let pending = try context.fetch(FetchDescriptor<PendingEventSyncRecord>())
        let grouped = Dictionary(grouping: pending, by: \.matchRef)
        var flushed = 0
        for (matchRef, items) in grouped {
            guard let tournamentId = items.first?.tournamentId else { continue }
            let decoder = JSONDecoder()
            let events: [ThrowEventDTO] = items.compactMap { row in
                guard let data = row.payloadJson.data(using: .utf8) else { return nil }
                return try? decoder.decode(ThrowEventDTO.self, from: data)
            }
            let request = MatchEventsBatchRequest(matchRef: matchRef, events: events, retractions: [])
            do {
                _ = try await api.appendMatchEvents(tournamentId: tournamentId, request: request)
                for item in items {
                    try remove(clientEventId: item.clientEventId)
                }
                flushed += events.count
            } catch {
                for item in items {
                    item.attemptCount += 1
                    item.lastError = error.localizedDescription
                }
                try context.save()
            }
        }
        return flushed
    }
}
