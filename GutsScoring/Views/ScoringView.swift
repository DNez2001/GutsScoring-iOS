import SwiftUI
import SwiftData

/// Main field scoring screen with full throw dialog, stats, and export.
struct ScoringView: View {
    let match: ScorableMatch
    let tournament: MobileTournamentSummary

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScoringViewBody(match: match, tournament: tournament, modelContext: modelContext)
    }
}

private struct ScoringViewBody: View {
    let match: ScorableMatch
    let tournament: MobileTournamentSummary

    @StateObject private var viewModel: ScoringViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSetup = true
    @State private var showThrowDialog = false
    @State private var showStats = false
    @State private var showExportOptions = false
    @State private var showShareSheet = false
    @State private var shareText = ""

    init(match: ScorableMatch, tournament: MobileTournamentSummary, modelContext: ModelContext) {
        self.match = match
        self.tournament = tournament
        _viewModel = StateObject(wrappedValue: ScoringViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                scoreboard
                noteBar

                Button {
                    showThrowDialog = true
                } label: {
                    Text("Record throw — \(viewModel.ui.activeThrowTeam)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canOpenThrowDialog)

                HStack(spacing: 12) {
                    Button("Undo") { viewModel.undoLastShot() }
                    Button("Stats") { showStats = true }
                        .disabled(viewModel.ui.matchTs == nil)
                    Button("Export") { showExportOptions = true }
                        .disabled(viewModel.ui.matchTs == nil)
                }
                .buttonStyle(.bordered)

                if viewModel.ui.isMultiGameMatch && viewModel.ui.currentGameOver && !viewModel.ui.matchComplete {
                    Button("Next game") {
                        viewModel.startNextGame(startingTeam: viewModel.ui.teamLeft)
                    }
                    .buttonStyle(.borderedProminent)
                }

                ScrollView {
                    Text(viewModel.gameLog.isEmpty ? "Game log will appear here." : viewModel.gameLog)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 220)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
            .navigationTitle(viewModel.ui.linkedMatchDisplayLabel ?? "Scoring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                viewModel.configure(match: match, tournament: tournament)
            }
            .sheet(isPresented: $showSetup) {
                MatchSetupView(match: match, tournament: tournament) { startingTeam, downwind in
                    viewModel.startMatch(startingTeam: startingTeam, downwindTeam: downwind)
                }
            }
            .sheet(isPresented: $showThrowDialog) {
                ThrowDialogView(
                    state: viewModel.ui,
                    onSubmit: { form in
                        viewModel.recordThrow(form: form)
                        showThrowDialog = false
                    },
                    onCancel: { showThrowDialog = false }
                )
            }
            .sheet(isPresented: $showStats) {
                if let snapshot = viewModel.statsSnapshot() {
                    StatsSheetView(snapshot: snapshot)
                } else {
                    Text("No throws recorded yet.")
                        .padding()
                }
            }
            .confirmationDialog("Export match log", isPresented: $showExportOptions, titleVisibility: .visible) {
                ForEach(MatchLogExportFormat.allCases) { format in
                    Button(format.label) { beginExport(format) }
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityShareSheet(items: [shareText])
            }
            .overlay(alignment: .top) {
                if let message = viewModel.uiMessage {
                    Text(message)
                        .font(.caption)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 4)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                viewModel.consumeUiMessage()
                            }
                        }
                }
            }
        }
    }

    private func beginExport(_ format: MatchLogExportFormat) {
        do {
            let payload = try viewModel.exportPayload()
            let text = payload.text(for: format)
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                viewModel.uiMessage = "Nothing to export yet."
                return
            }
            shareText = text
            showShareSheet = true
        } catch {
            viewModel.uiMessage = error.localizedDescription
        }
    }

    private var scoreboard: some View {
        HStack {
            VStack {
                Text(viewModel.ui.teamLeft).font(.headline)
                Text("\(viewModel.ui.scoreLeft)").font(.system(size: 44, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            Text(":").font(.title)
            VStack {
                Text(viewModel.ui.teamRight).font(.headline)
                Text("\(viewModel.ui.scoreRight)").font(.system(size: 44, weight: .bold))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var noteBar: some View {
        Group {
            if viewModel.ui.matchComplete {
                Text("Match complete").foregroundStyle(.red).fontWeight(.semibold)
            } else if viewModel.ui.currentGameOver {
                Text("Game \(viewModel.ui.gameCount) complete").foregroundStyle(.red)
            } else if let total = viewModel.ui.fieldSwitchAtTotal {
                Text("FIELD SWITCH at \(total)").foregroundStyle(.orange).fontWeight(.semibold)
            } else if viewModel.ui.pendingScoreSyncCount > 0 || viewModel.ui.pendingEventSyncCount > 0 {
                let total = viewModel.ui.pendingScoreSyncCount + viewModel.ui.pendingEventSyncCount
                Text("Sync pending (\(total))").foregroundStyle(.orange)
            } else {
                Text("Throwing: \(viewModel.ui.activeThrowTeam)").foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
    }
}
