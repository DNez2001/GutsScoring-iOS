import Foundation
import SwiftData

/// Persisted throw event — SwiftData mirror of Android `EventEntity`.
@Model
final class ThrowEventRecord {
    @Attribute(.unique) var clientEventId: String
    var matchTs: Int64
    var gameNumber: Int
    var shotCount: Int
    var throwTeam: String
    var throwLastName: String
    var handLabel: String
    var shotName: String
    var resultTag: String
    var isAce: Bool
    var isSoak: Bool
    var isDump: Bool
    var isVert: Bool
    var isObsrv: Bool
    var isFF: Bool
    var isRT: Bool
    var catchTeam: String?
    var hitLastName: String?
    var catchLastName: String?
    var location: String?
    var spotTag: String?
    var teamL: String
    var teamR: String
    var scoreLeft: Int
    var scoreRight: Int
    var throwingDownwind: Bool?
    var createdAt: Int64

    init(from input: ThrowEventInput) {
        clientEventId = input.clientEventId
        matchTs = input.matchTs
        gameNumber = input.gameNumber
        shotCount = input.shotCount
        throwTeam = input.throwTeam
        throwLastName = input.throwLastName
        handLabel = input.handLabel
        shotName = input.shotName
        resultTag = input.resultTag
        isAce = input.isAce
        isSoak = input.isSoak
        isDump = input.isDump
        isVert = input.isVert
        isObsrv = input.isObsrv
        isFF = input.isFF
        isRT = input.isRT
        catchTeam = input.catchTeam
        hitLastName = input.hitLastName
        catchLastName = input.catchLastName
        location = input.location
        spotTag = input.spotTag
        teamL = input.teamL
        teamR = input.teamR
        scoreLeft = input.scoreLeft
        scoreRight = input.scoreRight
        throwingDownwind = input.throwingDownwind
        createdAt = input.createdAt
    }

    func toInput() -> ThrowEventInput {
        ThrowEventInput(
            clientEventId: clientEventId,
            matchTs: matchTs,
            gameNumber: gameNumber,
            shotCount: shotCount,
            throwTeam: throwTeam,
            throwLastName: throwLastName,
            handLabel: handLabel,
            shotName: shotName,
            resultTag: resultTag,
            isAce: isAce,
            isSoak: isSoak,
            isDump: isDump,
            isVert: isVert,
            isObsrv: isObsrv,
            isFF: isFF,
            isRT: isRT,
            catchTeam: catchTeam,
            hitLastName: hitLastName,
            catchLastName: catchLastName,
            location: location,
            spotTag: spotTag,
            teamL: teamL,
            teamR: teamR,
            scoreLeft: scoreLeft,
            scoreRight: scoreRight,
            throwingDownwind: throwingDownwind,
            createdAt: createdAt
        )
    }
}

@Model
final class PendingScoreSyncRecord {
    @Attribute(.unique) var syncKey: String
    var matchRef: String?
    var tournamentId: String
    var clientProgressId: String
    var homeScore: Int
    var awayScore: Int
    var homeGamesWon: Int
    var awayGamesWon: Int
    var currentGameNumber: Int
    var matchComplete: Bool
    var enqueuedAt: Int64
    var attemptCount: Int
    var lastError: String?

    init(
        syncKey: String,
        matchRef: String?,
        tournamentId: String,
        clientProgressId: String,
        homeScore: Int,
        awayScore: Int,
        homeGamesWon: Int = 0,
        awayGamesWon: Int = 0,
        currentGameNumber: Int = 1,
        matchComplete: Bool = false
    ) {
        self.syncKey = syncKey
        self.matchRef = matchRef
        self.tournamentId = tournamentId
        self.clientProgressId = clientProgressId
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.homeGamesWon = homeGamesWon
        self.awayGamesWon = awayGamesWon
        self.currentGameNumber = currentGameNumber
        self.matchComplete = matchComplete
        enqueuedAt = Int64(Date().timeIntervalSince1970 * 1000)
        attemptCount = 0
        lastError = nil
    }
}

@Model
final class PendingEventSyncRecord {
    @Attribute(.unique) var clientEventId: String
    var matchRef: String
    var tournamentId: String
    var payloadJson: String
    var enqueuedAt: Int64
    var attemptCount: Int
    var lastError: String?

    init(clientEventId: String, matchRef: String, tournamentId: String, payloadJson: String) {
        self.clientEventId = clientEventId
        self.matchRef = matchRef
        self.tournamentId = tournamentId
        self.payloadJson = payloadJson
        enqueuedAt = Int64(Date().timeIntervalSince1970 * 1000)
        attemptCount = 0
        lastError = nil
    }
}

enum ScoringModelContainer {
    static let schema = Schema([
        ThrowEventRecord.self,
        PendingScoreSyncRecord.self,
        PendingEventSyncRecord.self,
    ])

    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }
}
