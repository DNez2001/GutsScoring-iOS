import Foundation

enum MatchSelection {
    /// Port of Android `GameViewModel.applyScorableMatchSelection`.
    static func applyScorableMatch(
        _ match: ScorableMatch,
        tournament: MobileTournamentSummary,
        to state: GameUiState
    ) -> GameUiState {
        var homeKey = match.homeTeamName.trimmingCharacters(in: .whitespacesAndNewlines)
        var awayKey = match.awayTeamName.trimmingCharacters(in: .whitespacesAndNewlines)
        if homeKey.isEmpty { homeKey = "Home" }
        if awayKey.isEmpty { awayKey = "Away" }
        if homeKey == awayKey {
            homeKey = "\(homeKey) (home)"
            awayKey = "\(awayKey) (away)"
        }
        let placeholder = [PlayerNameFormat.rosterPlaceholder]
        var next = state
        next.teamLeft = homeKey
        next.teamRight = awayKey
        next.teamPlayers = [homeKey: placeholder, awayKey: placeholder]
        next.linkedMatchRef = match.matchRef
        next.linkedTournamentId = match.tournamentId
        next.linkedHomeTeamKey = homeKey
        next.linkedAwayTeamKey = awayKey
        next.linkedMatchDisplayLabel = match.displayLabel ?? match.matchRef
        next.linkedMatchType = match.matchType
        next.linkedDivisionId = match.divisionId
        next.linkedGameId = match.gameId
        next.linkedNodeId = match.nodeId
        next.linkedHomeTeamId = match.homeTeamId
        next.linkedAwayTeamId = match.awayTeamId
        next.pointsToWin = max(match.pointsToWin, 1)
        next.gamesToWinMatch = max(match.gamesToWin, 1)
        next.tournamentName = tournament.name
        next.tournamentDate = tournament.startDate
        next.tournamentLocation = tournament.location ?? ""
        var roster = next.rosterIndex
        roster.teamIdsByName[homeKey] = match.homeTeamId
        roster.teamIdsByName[awayKey] = match.awayTeamId
        next.rosterIndex = roster
        return next
    }
}
