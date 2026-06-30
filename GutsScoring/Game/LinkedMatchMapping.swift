import Foundation

/// Maps left/right UI scores to tournament home/away — port of `LinkedGutsGameMapping.kt`.
enum LinkedMatchMapping {
    static func homeAwayScores(_ state: GameUiState) -> (home: Int, away: Int)? {
        guard state.linkedMatchRef != nil else { return nil }
        guard let homeKey = state.linkedHomeTeamKey, let awayKey = state.linkedAwayTeamKey else { return nil }
        guard let home = scoreForTeamKey(homeKey, in: state),
              let away = scoreForTeamKey(awayKey, in: state) else { return nil }
        return (home, away)
    }

    static func homeAwayGamesWon(_ state: GameUiState) -> (home: Int, away: Int)? {
        guard state.linkedMatchRef != nil else { return nil }
        guard let homeKey = state.linkedHomeTeamKey, let awayKey = state.linkedAwayTeamKey else { return nil }
        guard let home = gamesWonForTeamKey(homeKey, in: state),
              let away = gamesWonForTeamKey(awayKey, in: state) else { return nil }
        return (home, away)
    }

    private static func scoreForTeamKey(_ teamKey: String, in state: GameUiState) -> Int? {
        if teamKey == state.teamLeft { return state.scoreLeft }
        if teamKey == state.teamRight { return state.scoreRight }
        return nil
    }

    private static func gamesWonForTeamKey(_ teamKey: String, in state: GameUiState) -> Int? {
        if teamKey == state.teamLeft { return state.gamesWonLeft }
        if teamKey == state.teamRight { return state.gamesWonRight }
        return nil
    }
}
