import SwiftUI

struct MatchSetupView: View {
    let match: ScorableMatch
    let tournament: MobileTournamentSummary
    let onStart: (String, String?) -> Void

    @State private var startingSide: StartingSide = .left
    @State private var downwindSide: DownwindSide = .none
    @Environment(\.dismiss) private var dismiss

    enum StartingSide: String, CaseIterable, Identifiable {
        case left, right
        var id: String { rawValue }
    }

    enum DownwindSide: String, CaseIterable, Identifiable {
        case none, left, right
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Match") {
                    Text(match.pickerSummary)
                        .font(.subheadline)
                }
                Section("Who throws first?") {
                    Picker("Starting team", selection: $startingSide) {
                        Text(match.homeTeamName).tag(StartingSide.left)
                        Text(match.awayTeamName).tag(StartingSide.right)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Wind (optional)") {
                    Picker("Downwind team", selection: $downwindSide) {
                        Text("Not tracked").tag(DownwindSide.none)
                        Text(match.homeTeamName).tag(DownwindSide.left)
                        Text(match.awayTeamName).tag(DownwindSide.right)
                    }
                }
            }
            .navigationTitle("Match setup")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        let startTeam = startingSide == .left ? match.homeTeamName : match.awayTeamName
                        let downwind: String? = switch downwindSide {
                        case .none: nil
                        case .left: match.homeTeamName
                        case .right: match.awayTeamName
                        }
                        onStart(startTeam, downwind)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MatchSetupView(
        match: ScorableMatch(
            matchRef: "t#1#pool#1",
            matchType: "pool",
            tournamentId: "t1",
            divisionId: "d1",
            divisionName: "Open",
            gameId: nil,
            nodeId: nil,
            homeTeamId: "h1",
            awayTeamId: "a1",
            homeTeamName: "Alpha",
            awayTeamName: "Beta",
            fieldNumber: 1,
            scheduledStartAt: nil,
            status: "in_progress",
            pointsToWin: 21,
            gamesToWin: 1,
            currentGameNumber: 1,
            gamesWonHome: 0,
            gamesWonAway: 0,
            currentGameScoreHome: 0,
            currentGameScoreAway: 0,
            matchRevision: 1,
            displayLabel: "Pool A · G1"
        ),
        tournament: MobileTournamentSummary(
            tournamentId: "t1",
            name: "Test Open",
            startDate: "2026-06-01",
            endDate: "2026-06-02",
            location: "Field",
            phase: "live",
            pointsToWin: 21,
            winBy: 2
        ),
        onStart: { _, _ in }
    )
}
