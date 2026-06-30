import Foundation
import SwiftData

@MainActor
final class ScoringViewModel: ObservableObject {
    @Published private(set) var ui = GameUiState()
    @Published private(set) var gameLog = ""
    @Published var uiMessage: String?

    private let eventStore: ThrowEventStore
    private let scoreOutbox: ScoreSyncOutbox
    private let eventOutbox: EventSyncOutbox
    private let modelContext: ModelContext
    private let scoring = MobileScoringService()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        eventStore = ThrowEventStore(context: modelContext)
        scoreOutbox = ScoreSyncOutbox(context: modelContext)
        eventOutbox = EventSyncOutbox(context: modelContext)
    }

    func configure(match: ScorableMatch, tournament: MobileTournamentSummary) {
        ui = MatchSelection.applyScorableMatch(match, tournament: tournament, to: GameUiState())
        Task { await loadRosters() }
    }

    func startMatch(startingTeam: String, downwindTeam: String?) {
        guard let home = ui.linkedHomeTeamKey, let away = ui.linkedAwayTeamKey else { return }
        let left = ui.teamLeft
        let right = ui.teamRight
        let ts = Int64(Date().timeIntervalSince1970 * 1000)
        ui = GameUiState(
            teamLeft: left,
            teamRight: right,
            leftEnabled: startingTeam == left,
            rightEnabled: startingTeam == right,
            matchTs: ts,
            teamPlayers: ui.teamPlayers,
            activeThrowTeam: startingTeam,
            tournamentName: ui.tournamentName,
            tournamentLocation: ui.tournamentLocation,
            tournamentDate: ui.tournamentDate,
            linkedMatchRef: ui.linkedMatchRef,
            linkedTournamentId: ui.linkedTournamentId,
            linkedHomeTeamKey: home,
            linkedAwayTeamKey: away,
            linkedMatchDisplayLabel: ui.linkedMatchDisplayLabel,
            linkedMatchType: ui.linkedMatchType,
            linkedDivisionId: ui.linkedDivisionId,
            linkedGameId: ui.linkedGameId,
            linkedNodeId: ui.linkedNodeId,
            linkedHomeTeamId: ui.linkedHomeTeamId,
            linkedAwayTeamId: ui.linkedAwayTeamId,
            pointsToWin: ui.pointsToWin,
            gamesToWinMatch: ui.gamesToWinMatch,
            downwindTeam: downwindTeam,
            rosterIndex: ui.rosterIndex
        )
        gameLog = ""
        appendMatchStartHeader()
    }

    func recordThrow(form: ThrowDialogForm) {
        do {
            let event = try ThrowEventBuilder.buildEvent(form: form, state: ui)
            applyEvent(event)
        } catch {
            uiMessage = error.localizedDescription
        }
    }

    func recordQuickResult(resultTag: String, for team: String) {
        guard canRecordThrow(resultTag: resultTag) else { return }
        guard ui.matchTs != nil else { return }
        let event = ThrowEventInput.quickScore(state: ui, throwingTeam: team, resultTag: resultTag)
        applyEvent(event)
    }

    func statsSnapshot() -> MatchStatsSnapshot? {
        guard let matchTs = ui.matchTs else { return nil }
        let events = (try? eventStore.eventsForMatch(matchTs)) ?? []
        return StatsCalculator.buildSnapshot(events: events, teamLeft: ui.teamLeft, teamRight: ui.teamRight)
    }

    var canOpenThrowDialog: Bool {
        canRecordThrow(resultTag: "1")
    }

    func exportPayload() throws -> MatchLogExportPayload {
        guard ui.matchTs != nil else { throw MatchLogExportError.noMatch }
        guard let matchTs = ui.matchTs else { throw MatchLogExportError.noMatch }
        let events = try eventStore.eventsForMatch(matchTs)
        guard !events.isEmpty else { throw MatchLogExportError.noEvents }
        return MatchEventSerializer.buildExport(events: events, state: ui, readableLog: gameLog)
    }

    func flushPendingSync() async {
        let result = await SyncFlushService.flushPendingOutboxes(context: modelContext)
        ui.pendingScoreSyncCount = result.scorePending
        ui.pendingEventSyncCount = result.eventsPending
        if let error = result.lastError, result.hasPendingWork {
            uiMessage = "Sync pending: \(error)"
        }
    }

    func undoLastShot() {
        guard let matchTs = ui.matchTs else { return }
        do {
            let events = try eventStore.eventsForMatch(matchTs)
            guard let removed = events.last else {
                uiMessage = "No shots to undo."
                return
            }
            try eventStore.delete(clientEventId: removed.clientEventId)
            try eventOutbox.remove(clientEventId: removed.clientEventId)
            let remaining = Array(events.dropLast())
            rebuildStateFromEvents(remaining: remaining, anchor: removed)
            uiMessage = "Undid last shot."
            Task { await syncScore() }
        } catch {
            uiMessage = error.localizedDescription
        }
    }

    func startNextGame(startingTeam: String) {
        guard ui.currentGameOver, !ui.matchComplete else { return }
        ui.gameCount += 1
        ui.scoreLeft = 0
        ui.scoreRight = 0
        ui.shotCount = 1
        ui.currentGameOver = false
        ui.activeThrowTeam = startingTeam
        ui.lastThrowTeam = ""
        ui.leftEnabled = startingTeam == ui.teamLeft
        ui.rightEnabled = startingTeam == ui.teamRight
        ui.fieldSwitchAtTotal = nil
        appendLog("— Game \(ui.gameCount) — \(startingTeam) throws first —\n")
        Task { await syncScore() }
    }

    func consumeUiMessage() {
        uiMessage = nil
    }

    private func canRecordThrow(resultTag: String) -> Bool {
        !ui.matchComplete && (!ui.currentGameOver || resultTag == "5")
    }

    private func applyEvent(_ event: ThrowEventInput) {
        guard canRecordThrow(resultTag: event.resultTag) else { return }
        guard ui.matchTs != nil else { return }
        var working = event
        do {
            let stored = try eventStore.insert(working)
            working = stored
            appendLog(EventLogFormatting.readableLogLine(for: stored))
            let before = ui
            let applied = GameEngine.applyEvent(current: ui, event: working)
            ui = applied.state
            if applied.fieldSwitchTotal != nil {
                appendLog("FIELD SWITCH at \(applied.fieldSwitchTotal!) total points\n")
            }
            if ui.currentGameOver && !before.currentGameOver {
                uiMessage = ui.matchComplete
                    ? "Match complete."
                    : (ui.isMultiGameMatch ? "Game over. Tap Next Game." : "Match complete.")
            }
            if MatchRules.shouldSyncScoreAfterEvent(resultTag: working.resultTag, before: before, after: ui) {
                Task { await syncScore() }
            }
            if let matchRef = ui.linkedMatchRef, let tournamentId = ui.linkedTournamentId {
                try eventOutbox.enqueue(event: stored, state: ui, matchRef: matchRef, tournamentId: tournamentId)
                Task { await flushOutboxes() }
            }
        } catch {
            uiMessage = error.localizedDescription
        }
    }

    private func loadRosters() async {
        guard let tournamentId = ui.linkedTournamentId else { return }
        do {
            let response = try await scoring.getRosters(
                tournamentId: tournamentId,
                divisionId: ui.linkedDivisionId
            )
            var players = ui.teamPlayers
            for team in response.teams {
                let names = team.players.map(\.displayName)
                let rosterName = team.teamName.trimmingCharacters(in: .whitespacesAndNewlines)
                if team.teamId == ui.linkedHomeTeamId
                    || rosterName.caseInsensitiveCompare(ui.teamLeft) == .orderedSame {
                    players[ui.teamLeft] = names
                } else if team.teamId == ui.linkedAwayTeamId
                    || rosterName.caseInsensitiveCompare(ui.teamRight) == .orderedSame {
                    players[ui.teamRight] = names
                } else if !rosterName.isEmpty {
                    players[rosterName] = names
                }
            }
            ui.teamPlayers = players
            ui.rosterIndex = RosterIndexBuilder.build(teams: response.teams)
        } catch {
            uiMessage = "Rosters unavailable; player pickers may be empty."
        }
    }

    private func rebuildStateFromEvents(remaining: [ThrowEventInput], anchor: ThrowEventInput) {
        let startThrowTeam = remaining.first?.throwTeam ?? anchor.throwTeam
        let sideAnchor = remaining.first ?? anchor
        var rebuilt = ui
        rebuilt.teamLeft = sideAnchor.teamL
        rebuilt.teamRight = sideAnchor.teamR
        rebuilt.scoreLeft = 0
        rebuilt.scoreRight = 0
        rebuilt.gamesWonLeft = 0
        rebuilt.gamesWonRight = 0
        rebuilt.gameCount = 1
        rebuilt.currentGameOver = false
        rebuilt.matchComplete = false
        rebuilt.activeThrowTeam = startThrowTeam
        rebuilt.leftEnabled = startThrowTeam == sideAnchor.teamL
        rebuilt.rightEnabled = startThrowTeam == sideAnchor.teamR
        rebuilt.shotCount = 1
        rebuilt.fieldSwitchAtTotal = nil
        ui = rebuilt
        gameLog = ""
        appendMatchStartHeader()
        for event in remaining {
            if rebuilt.currentGameOver && event.gameNumber > rebuilt.gameCount {
                rebuilt.gameCount = event.gameNumber
                rebuilt.scoreLeft = 0
                rebuilt.scoreRight = 0
                rebuilt.currentGameOver = false
                rebuilt.activeThrowTeam = event.throwTeam
                rebuilt.leftEnabled = event.throwTeam == rebuilt.teamLeft
                rebuilt.rightEnabled = event.throwTeam == rebuilt.teamRight
                rebuilt.shotCount = event.shotCount
            }
            appendLog(EventLogFormatting.readableLogLine(for: event))
            let before = rebuilt
            let applied = GameEngine.applyEvent(current: rebuilt, event: event)
            rebuilt = applied.state
            if ["1", "3"].contains(event.resultTag),
               MatchRules.fieldSwitchJustReached(before: before, after: applied.state) {
                rebuilt = MatchRules.withFieldEndsSwitched(rebuilt)
            }
        }
        ui = rebuilt
    }

    private func appendMatchStartHeader() {
        appendLog("=== \(ui.tournamentName) ===\n\(ui.teamLeft) vs \(ui.teamRight)\n")
    }

    private func appendLog(_ block: String) {
        gameLog += block.hasSuffix("\n") ? block : block + "\n"
    }

    private func syncScore() async {
        do {
            try scoreOutbox.enqueue(state: ui)
            let result = await SyncFlushService.flushPendingOutboxes(context: modelContext)
            ui.pendingScoreSyncCount = result.scorePending
            ui.pendingEventSyncCount = result.eventsPending
        } catch {
            ui.pendingScoreSyncCount = (try? scoreOutbox.pendingCount()) ?? ui.pendingScoreSyncCount
            uiMessage = "Score saved locally; sync pending."
        }
    }

    private func flushOutboxes() async {
        let result = await SyncFlushService.flushPendingOutboxes(context: modelContext)
        ui.pendingScoreSyncCount = result.scorePending
        ui.pendingEventSyncCount = result.eventsPending
    }
}
