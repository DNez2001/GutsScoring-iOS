import Foundation

/// Throw input / persisted event — mirrors Android `EventEntity` (pre-persist and stored).
struct ThrowEventInput: Equatable, Identifiable {
    var id: Int64 = 0
    var clientEventId: String
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

    init(
        clientEventId: String = UUID().uuidString,
        matchTs: Int64,
        gameNumber: Int,
        shotCount: Int,
        throwTeam: String,
        throwLastName: String,
        handLabel: String,
        shotName: String,
        resultTag: String,
        isAce: Bool = false,
        isSoak: Bool = false,
        isDump: Bool = false,
        isVert: Bool = false,
        isObsrv: Bool = false,
        isFF: Bool = false,
        isRT: Bool = false,
        catchTeam: String? = nil,
        hitLastName: String? = nil,
        catchLastName: String? = nil,
        location: String? = nil,
        spotTag: String? = nil,
        teamL: String,
        teamR: String,
        scoreLeft: Int,
        scoreRight: Int,
        throwingDownwind: Bool? = nil,
        createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    ) {
        self.clientEventId = clientEventId
        self.matchTs = matchTs
        self.gameNumber = gameNumber
        self.shotCount = shotCount
        self.throwTeam = throwTeam
        self.throwLastName = throwLastName
        self.handLabel = handLabel
        self.shotName = shotName
        self.resultTag = resultTag
        self.isAce = isAce
        self.isSoak = isSoak
        self.isDump = isDump
        self.isVert = isVert
        self.isObsrv = isObsrv
        self.isFF = isFF
        self.isRT = isRT
        self.catchTeam = catchTeam
        self.hitLastName = hitLastName
        self.catchLastName = catchLastName
        self.location = location
        self.spotTag = spotTag
        self.teamL = teamL
        self.teamR = teamR
        self.scoreLeft = scoreLeft
        self.scoreRight = scoreRight
        self.throwingDownwind = throwingDownwind
        self.createdAt = createdAt
    }

    /// Scores after this point is applied — port of `EventEntity.withScoresAfterThisPoint()`.
    func withScoresAfterThisPoint() -> ThrowEventInput {
        var sl = scoreLeft
        var sr = scoreRight
        let leftThrows = throwTeam == teamL
        switch resultTag {
        case "1": if leftThrows { sl += 1 } else { sr += 1 }
        case "3": if leftThrows { sr += 1 } else { sl += 1 }
        default: break
        }
        var copy = self
        copy.scoreLeft = sl
        copy.scoreRight = sr
        return copy
    }
}

extension ThrowEventInput {
    static func quickScore(
        state: GameUiState,
        throwingTeam: String,
        resultTag: String,
        throwerName: String = PlayerNameFormat.rosterPlaceholder
    ) -> ThrowEventInput {
        ThrowEventInput(
            matchTs: state.matchTs ?? Int64(Date().timeIntervalSince1970 * 1000),
            gameNumber: state.gameCount,
            shotCount: state.shotCount,
            throwTeam: throwingTeam,
            throwLastName: throwerName,
            handLabel: "R",
            shotName: "backhand",
            resultTag: resultTag,
            teamL: state.teamLeft,
            teamR: state.teamRight,
            scoreLeft: state.scoreLeft,
            scoreRight: state.scoreRight,
            throwingDownwind: state.downwindTeam.map { throwingTeam.caseInsensitiveCompare($0) == .orderedSame }
        )
    }
}
