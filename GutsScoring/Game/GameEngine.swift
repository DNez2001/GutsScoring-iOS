import Foundation

/// Pure scoring state transitions — port of Android `GameViewModel.stateAfterEvent`.
enum GameEngine {
    static func stateAfterEvent(current: GameUiState, event: ThrowEventInput) -> GameUiState {
        var scoreLeft = current.scoreLeft
        var scoreRight = current.scoreRight
        let isLeftThrowing = event.throwTeam == current.teamLeft

        switch event.resultTag {
        case "1":
            if isLeftThrowing { scoreLeft += 1 } else { scoreRight += 1 }
        case "3":
            if isLeftThrowing { scoreRight += 1 } else { scoreLeft += 1 }
        default:
            break
        }

        let leftEnabled: Bool
        let rightEnabled: Bool
        let nextThrowTeam: String
        if event.resultTag == "5" {
            if isLeftThrowing {
                leftEnabled = true
                rightEnabled = false
                nextThrowTeam = current.teamLeft
            } else {
                leftEnabled = false
                rightEnabled = true
                nextThrowTeam = current.teamRight
            }
        } else {
            if isLeftThrowing {
                leftEnabled = false
                rightEnabled = true
                nextThrowTeam = current.teamRight
            } else {
                leftEnabled = true
                rightEnabled = false
                nextThrowTeam = current.teamLeft
            }
        }

        var afterThrow = current
        afterThrow.scoreLeft = scoreLeft
        afterThrow.scoreRight = scoreRight
        afterThrow.leftEnabled = leftEnabled
        afterThrow.rightEnabled = rightEnabled
        afterThrow.activeThrowTeam = nextThrowTeam
        afterThrow.lastThrowTeam = event.throwTeam
        afterThrow.preferredNextThrowerLastName = NextThrowerRules.preferredNextThrower(after: event)
        afterThrow.shotCount = current.shotCount + 1

        if afterThrow.currentGameOver || afterThrow.matchComplete {
            return afterThrow
        }
        guard let winner = MatchRules.gameWinnerSide(state: afterThrow) else {
            return afterThrow
        }
        return MatchRules.withGameWinApplied(state: afterThrow, winner: winner)
    }

    static func applyEvent(
        current: GameUiState,
        event: ThrowEventInput
    ) -> (state: GameUiState, fieldSwitchTotal: Int?) {
        let prior = current
        let cleared = prior.fieldSwitchAtTotal == nil ? prior : {
            var c = prior
            c.fieldSwitchAtTotal = nil
            return c
        }()
        let newState = stateAfterEvent(current: cleared, event: event)
        let combinedTotal = newState.scoreLeft + newState.scoreRight
        let fieldSwitch = ["1", "3"].contains(event.resultTag)
            && MatchRules.fieldSwitchJustReached(before: cleared, after: newState)
        let finalState = fieldSwitch ? MatchRules.withFieldEndsSwitched(newState) : newState
        var ui = finalState
        ui.fieldSwitchAtTotal = fieldSwitch ? combinedTotal : nil
        return (ui, fieldSwitch ? combinedTotal : nil)
    }
}
