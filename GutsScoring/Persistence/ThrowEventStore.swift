import Foundation
import SwiftData

/// Local throw persistence — SwiftData-backed (port of Android `EventDao`).
@MainActor
final class ThrowEventStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func insert(_ input: ThrowEventInput) throws -> ThrowEventInput {
        let stored = input.withScoresAfterThisPoint()
        context.insert(ThrowEventRecord(from: stored))
        try context.save()
        return stored
    }

    func eventsForMatch(_ matchTs: Int64) throws -> [ThrowEventInput] {
        let descriptor = FetchDescriptor<ThrowEventRecord>(
            predicate: #Predicate { $0.matchTs == matchTs },
            sortBy: [SortDescriptor(\.shotCount)]
        )
        return try context.fetch(descriptor).map { $0.toInput() }
    }

    func delete(clientEventId: String) throws {
        let descriptor = FetchDescriptor<ThrowEventRecord>(
            predicate: #Predicate { $0.clientEventId == clientEventId }
        )
        if let row = try context.fetch(descriptor).first {
            context.delete(row)
            try context.save()
        }
    }

    func deleteAllForMatch(_ matchTs: Int64) throws {
        let descriptor = FetchDescriptor<ThrowEventRecord>(
            predicate: #Predicate { $0.matchTs == matchTs }
        )
        for row in try context.fetch(descriptor) {
            context.delete(row)
        }
        try context.save()
    }
}
