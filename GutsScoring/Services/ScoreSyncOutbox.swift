import Foundation
import SwiftData

/// Offline score PUT queue — port of Android `ScoreSyncOutbox`.
@MainActor
final class ScoreSyncOutbox {
    private let context: ModelContext
    private let api: MobileScoringService

    init(context: ModelContext, api: MobileScoringService = MobileScoringService()) {
        self.context = context
        self.api = api
    }

    func pendingCount() throws -> Int {
        try context.fetchCount(FetchDescriptor<PendingScoreSyncRecord>())
    }

    func enqueue(state: GameUiState) throws {
        guard let matchRef = state.linkedMatchRef,
              let tournamentId = state.linkedTournamentId,
              let scores = LinkedMatchMapping.homeAwayScores(state) else { return }
        let games = LinkedMatchMapping.homeAwayGamesWon(state) ?? (0, 0)
        let syncKey = matchRef
        let descriptor = FetchDescriptor<PendingScoreSyncRecord>(
            predicate: #Predicate { $0.syncKey == syncKey }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.tournamentId = tournamentId
            existing.homeScore = scores.home
            existing.awayScore = scores.away
            existing.homeGamesWon = games.home
            existing.awayGamesWon = games.away
            existing.currentGameNumber = state.gameCount
            existing.matchComplete = state.matchComplete
            existing.clientProgressId = UUID().uuidString
        } else {
            context.insert(
                PendingScoreSyncRecord(
                    syncKey: syncKey,
                    matchRef: matchRef,
                    tournamentId: tournamentId,
                    clientProgressId: UUID().uuidString,
                    homeScore: scores.home,
                    awayScore: scores.away,
                    homeGamesWon: games.home,
                    awayGamesWon: games.away,
                    currentGameNumber: state.gameCount,
                    matchComplete: state.matchComplete
                )
            )
        }
        try context.save()
    }

    func remove(syncKey: String) throws {
        let descriptor = FetchDescriptor<PendingScoreSyncRecord>(
            predicate: #Predicate { $0.syncKey == syncKey }
        )
        for row in try context.fetch(descriptor) {
            context.delete(row)
        }
        try context.save()
    }

    @discardableResult
    func flushAll() async throws -> Int {
        let pending = try context.fetch(FetchDescriptor<PendingScoreSyncRecord>())
        var flushed = 0
        for item in pending {
            guard let matchRef = item.matchRef else { continue }
            let request = MatchProgressRequest(
                matchRef: matchRef,
                clientProgressId: item.clientProgressId,
                currentGameNumber: item.currentGameNumber,
                currentGameScoreHome: item.homeScore,
                currentGameScoreAway: item.awayScore,
                gamesWonHome: item.homeGamesWon,
                gamesWonAway: item.awayGamesWon,
                isComplete: item.matchComplete,
                matchRevision: nil
            )
            do {
                _ = try await api.updateMatchProgress(tournamentId: item.tournamentId, request: request)
                try remove(syncKey: item.syncKey)
                flushed += 1
            } catch {
                item.attemptCount += 1
                item.lastError = error.localizedDescription
                try context.save()
            }
        }
        return flushed
    }
}
