import Foundation

/// Match scoring rules — port of Android `MatchRules.kt`.
struct MatchFormat: Equatable {
    let pointsToWin: Int
    let gamesToWinMatch: Int

    var isMultiGameMatch: Bool { gamesToWinMatch > 1 }
}

enum GameSide {
    case left
    case right
}

enum MatchRules {
    static let defaultFormat = MatchFormat(pointsToWin: 21, gamesToWinMatch: 2)

    static func gameWinnerSide(state: GameUiState) -> GameSide? {
        if state.scoreLeft >= state.pointsToWin { return .left }
        if state.scoreRight >= state.pointsToWin { return .right }
        return nil
    }

    static func fieldSwitchJustReached(before: GameUiState, after: GameUiState) -> Bool {
        let beforeTotal = before.scoreLeft + before.scoreRight
        let afterTotal = after.scoreLeft + after.scoreRight
        return afterTotal > 0 && afterTotal % 11 == 0 && beforeTotal != afterTotal
    }

    static func withGameWinApplied(state: GameUiState, winner: GameSide) -> GameUiState {
        var next = state
        switch winner {
        case .left: next.gamesWonLeft += 1
        case .right: next.gamesWonRight += 1
        }
        let matchDone = next.gamesWonLeft >= next.gamesToWinMatch || next.gamesWonRight >= next.gamesToWinMatch
        next.currentGameOver = next.isMultiGameMatch
        next.matchComplete = matchDone
        next.leftEnabled = false
        next.rightEnabled = false
        return next
    }

    static func withFieldEndsSwitched(_ state: GameUiState) -> GameUiState {
        var swapped = state
        swapped.teamLeft = state.teamRight
        swapped.teamRight = state.teamLeft
        swapped.scoreLeft = state.scoreRight
        swapped.scoreRight = state.scoreLeft
        swapped.gamesWonLeft = state.gamesWonRight
        swapped.gamesWonRight = state.gamesWonLeft
        if let downwind = state.downwindTeam {
            if downwind.caseInsensitiveCompare(state.teamLeft) == .orderedSame {
                swapped.downwindTeam = state.teamRight
            } else if downwind.caseInsensitiveCompare(state.teamRight) == .orderedSame {
                swapped.downwindTeam = state.teamLeft
            }
        }
        let throwingOnLeft = swapped.activeThrowTeam == swapped.teamLeft
        swapped.leftEnabled = throwingOnLeft
        swapped.rightEnabled = !throwingOnLeft
        return swapped
    }

    /// M1: sync on switch boundaries (not rethrows), game end, or match complete.
    static func shouldSyncScoreAfterEvent(resultTag: String, before: GameUiState, after: GameUiState) -> Bool {
        if resultTag != "5" { return true }
        if after.currentGameOver && !before.currentGameOver { return true }
        if after.matchComplete && !before.matchComplete { return true }
        return false
    }
}

extension GameUiState {
    var isMultiGameMatch: Bool { gamesToWinMatch > 1 }
}
