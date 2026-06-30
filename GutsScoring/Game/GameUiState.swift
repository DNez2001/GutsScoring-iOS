import Foundation

/// On-screen scoring state — port of Android `GameUiState`.
struct GameUiState: Equatable {
    var teamLeft: String = "Team A"
    var teamRight: String = "Team B"
    var scoreLeft: Int = 0
    var scoreRight: Int = 0
    var leftEnabled: Bool = true
    var rightEnabled: Bool = false

    var matchTs: Int64?
    var gameCount: Int = 1
    var shotCount: Int = 1

    var teamPlayers: [String: [String]] = [:]

    var activeThrowTeam: String = "Team A"
    var lastThrowTeam: String = ""
    var preferredNextThrowerLastName: String?

    var tournamentName: String = "Untitled"
    var tournamentLocation: String = ""
    var tournamentDate: String = ""

    var linkedMatchRef: String?
    var linkedTournamentId: String?
    var linkedHomeTeamKey: String?
    var linkedAwayTeamKey: String?
    var linkedMatchDisplayLabel: String?
    var linkedMatchType: String?
    var linkedDivisionId: String?
    var linkedGameId: String?
    var linkedNodeId: String?
    var linkedHomeTeamId: String?
    var linkedAwayTeamId: String?

    var trackPlayerNames: Bool = true
    var pointsToWin: Int = MatchRules.defaultFormat.pointsToWin
    var gamesWonLeft: Int = 0
    var gamesWonRight: Int = 0
    var gamesToWinMatch: Int = MatchRules.defaultFormat.gamesToWinMatch
    var currentGameOver: Bool = false
    var matchComplete: Bool = false
    var pendingScoreSyncCount: Int = 0
    var pendingEventSyncCount: Int = 0
    var fieldSwitchAtTotal: Int?
    var downwindTeam: String?
    var rosterIndex: RosterIndex = RosterIndex()
}
