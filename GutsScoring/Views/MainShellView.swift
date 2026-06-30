import SwiftUI

/// M0 shell — tournament/match list after sign-in. Scoring engine not started yet.
struct MainShellView: View {
    @ObservedObject var appState: AppState
    @StateObject private var pickerModel = TournamentPickerViewModel()

    @State private var selectedMatch: ScorableMatch?
    @State private var selectedTournament: MobileTournamentSummary?

    var body: some View {
        NavigationStack {
            List {
                if let name = appState.signedInDisplayName {
                    Section {
                        Text("Signed in as \(name)")
                    }
                }

                Section("Tournaments") {
                    if pickerModel.isLoading && pickerModel.tournaments.isEmpty {
                        ProgressView()
                    }
                    ForEach(pickerModel.tournaments) { tournament in
                        Button {
                            Task { await pickerModel.selectTournament(tournament) }
                        } label: {
                            HStack {
                                Text(tournament.name)
                                Spacer()
                                if pickerModel.selectedTournament?.tournamentId == tournament.tournamentId {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accent)
                                }
                            }
                        }
                    }
                    Button("Refresh tournaments") {
                        Task { await pickerModel.loadTournaments() }
                    }
                }

                Section("Scorable matches") {
                    if pickerModel.matches.isEmpty {
                        Text("No open matches loaded.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(pickerModel.matches) { match in
                            Button {
                                selectedTournament = pickerModel.selectedTournament
                                selectedMatch = match
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(match.pickerSummary)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Text(match.status)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section {
                    Text("Tap a match to open the scoring screen (M1 shell). Full throw dialog and stats are still in progress.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let error = pickerModel.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Guts Scoring")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign out", role: .destructive) {
                        appState.signOut()
                    }
                }
            }
            .task {
                await pickerModel.loadTournaments()
            }
            .fullScreenCover(item: $selectedMatch) { match in
                if let tournament = selectedTournament {
                    ScoringView(match: match, tournament: tournament)
                }
            }
        }
    }
}

#Preview {
    MainShellView(appState: AppState())
}
