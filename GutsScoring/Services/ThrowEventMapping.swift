import Foundation

/// Maps local throw events to API DTOs — simplified port of Android `ThrowEventMapping.kt`.
enum ThrowEventMapping {
    static func toDTO(event: ThrowEventInput, state: GameUiState) -> ThrowEventDTO {
        let stored = event.withScoresAfterThisPoint()
        let homeAway = LinkedMatchMapping.homeAwayScores(state)
        return ThrowEventDTO(
            clientEventId: stored.clientEventId,
            sequence: stored.shotCount,
            gameNumber: stored.gameNumber,
            throwTeamName: stored.throwTeam,
            throwPlayerName: stored.throwLastName,
            throwTeamId: state.rosterIndex.teamId(for: stored.throwTeam),
            throwPlayerId: state.rosterIndex.playerId(teamName: stored.throwTeam, compactName: stored.throwLastName),
            hand: stored.handLabel,
            shotType: stored.shotName,
            result: stored.resultTag,
            isAce: stored.isAce,
            isSoak: stored.isSoak,
            isDump: stored.isDump,
            isVerticalDump: stored.isVert,
            isObserver: stored.isObsrv,
            isFootFault: stored.isFF,
            isRethrow: stored.isRT,
            catchTeamName: stored.catchTeam,
            hitPlayerName: stored.hitLastName,
            catchPlayerName: stored.catchLastName,
            hitPlayerId: state.rosterIndex.playerId(teamName: stored.catchTeam, compactName: stored.hitLastName),
            catchPlayerId: state.rosterIndex.playerId(teamName: stored.catchTeam, compactName: stored.catchLastName),
            courtZone: stored.location,
            spotZone: stored.spotTag,
            throwingDownwind: stored.throwingDownwind,
            teamLeftName: stored.teamL,
            teamRightName: stored.teamR,
            scoreLeft: stored.scoreLeft,
            scoreRight: stored.scoreRight,
            scoreHome: homeAway?.home,
            scoreAway: homeAway?.away,
            recordedAt: stored.createdAt,
            eventKind: "throw",
            logText: EventLogFormatting.readableLogLine(for: stored),
            markerKind: nil,
            activeThrowTeamName: state.activeThrowTeam,
            switchTotalPoints: nil
        )
    }
}
