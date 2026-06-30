import Foundation

// MARK: - Auth (mirrors Android `PlayerAuthDtos.kt`)

struct SendOtpRequest: Encodable {
    let phoneNumber: String
}

struct MessageResponse: Decodable {
    let message: String?
}

struct VerifyOtpRequest: Encodable {
    let phoneNumber: String
    let code: String
    let firstName: String?
    let lastName: String?
    let email: String?

    init(phoneNumber: String, code: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil) {
        self.phoneNumber = phoneNumber
        self.code = code
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}

struct VerifyOtpResponse: Decodable {
    let sessionToken: String
    let player: PlayerSummary
    let isReturning: Bool?
}

struct PlayerSummary: Decodable, Equatable {
    let playerId: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let email: String?
    let roles: [String]?

    var displayName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }
}

// MARK: - Mobile scoring M0 (subset of Android `MobileScoringDtos.kt`)

struct MobileTournamentListResponse: Decodable {
    let tournaments: [MobileTournamentSummary]
}

struct MobileTournamentSummary: Decodable, Identifiable, Hashable {
    var id: String { tournamentId }
    let tournamentId: String
    let name: String
    let startDate: String
    let endDate: String
    let location: String?
    let phase: String?
    let pointsToWin: Int?
    let winBy: Int?
}

struct ScorableMatchesResponse: Decodable {
    let matches: [ScorableMatch]
}

struct ScorableMatch: Decodable, Identifiable, Hashable {
    var id: String { matchRef }
    let matchRef: String
    let matchType: String
    let tournamentId: String
    let divisionId: String
    let divisionName: String?
    let gameId: String?
    let nodeId: String?
    let homeTeamId: String
    let awayTeamId: String
    let homeTeamName: String
    let awayTeamName: String
    let fieldNumber: Int?
    let scheduledStartAt: String?
    let status: String
    let pointsToWin: Int
    let gamesToWin: Int
    let currentGameNumber: Int?
    let gamesWonHome: Int?
    let gamesWonAway: Int?
    let currentGameScoreHome: Int?
    let currentGameScoreAway: Int?
    let matchRevision: Int?
    let displayLabel: String?

    var isOpenForScoring: Bool {
        let s = status.lowercased()
        return s == "pending" || s == "in_progress"
    }

    var pickerSummary: String {
        let kind: String = switch matchType.lowercased() {
        case "bracket": "Bracket"
        case "pool": "Pool"
        default: matchType.capitalized
        }
        let label = displayLabel ?? matchRef
        let format = gamesToWin > 1 ? "win \(gamesToWin), to \(pointsToWin)" : "to \(pointsToWin)"
        return "\(kind) · \(label) · \(format) · \(homeTeamName) vs \(awayTeamName)"
    }
}

struct TournamentRostersResponse: Decodable {
    let tournamentId: String
    let teams: [MobileTeamRoster]
}

struct MobileTeamRoster: Decodable, Identifiable, Hashable {
    var id: String { teamId }
    let teamId: String
    let teamName: String
    let divisionId: String?
    let players: [MobileRosterPlayer]
}

struct MobileRosterPlayer: Decodable, Identifiable, Hashable {
    var id: String { playerId }
    let playerId: String
    let displayName: String
    let firstName: String?
    let lastName: String?
    let jerseyNumber: String?
    let throwingHand: String?
    let preferredThrows: [String]?
}

// MARK: - M1/M2 sync DTOs

struct MatchProgressRequest: Encodable {
    let matchRef: String
    let clientProgressId: String
    let currentGameNumber: Int
    let currentGameScoreHome: Int
    let currentGameScoreAway: Int
    let gamesWonHome: Int
    let gamesWonAway: Int
    let isComplete: Bool
    let matchRevision: Int?
}

struct MatchProgressResponse: Decodable {
    let matchRef: String
    let status: String
    let matchRevision: Int
    let gamesWonHome: Int?
    let gamesWonAway: Int?
    let currentGameNumber: Int?
    let currentGameScoreHome: Int?
    let currentGameScoreAway: Int?
}

struct ThrowEventDTO: Codable {
    let clientEventId: String
    let sequence: Int
    let gameNumber: Int
    let throwTeamName: String
    let throwPlayerName: String
    let throwTeamId: String?
    let throwPlayerId: String?
    let hand: String
    let shotType: String
    let result: String
    let isAce: Bool
    let isSoak: Bool
    let isDump: Bool
    let isVerticalDump: Bool
    let isObserver: Bool
    let isFootFault: Bool
    let isRethrow: Bool
    let catchTeamName: String?
    let hitPlayerName: String?
    let catchPlayerName: String?
    let hitPlayerId: String?
    let catchPlayerId: String?
    let courtZone: String?
    let spotZone: String?
    let throwingDownwind: Bool?
    let teamLeftName: String
    let teamRightName: String
    let scoreLeft: Int
    let scoreRight: Int
    let scoreHome: Int?
    let scoreAway: Int?
    let recordedAt: Int64
    let eventKind: String
    let logText: String?
    let markerKind: String?
    let activeThrowTeamName: String?
    let switchTotalPoints: Int?
}

struct MatchEventsBatchRequest: Encodable {
    let matchRef: String
    let events: [ThrowEventDTO]
    let retractions: [String]
}

struct MatchEventsBatchResponse: Decodable {
    let matchRef: String
    let accepted: Int
    let duplicate: Int
    let retracted: Int
}
