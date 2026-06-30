import Foundation

@MainActor
final class TournamentPickerViewModel: ObservableObject {
    @Published var tournaments: [MobileTournamentSummary] = []
    @Published var matches: [ScorableMatch] = []
    @Published var selectedTournament: MobileTournamentSummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let scoring = MobileScoringService()

    func loadTournaments() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            tournaments = try await scoring.listTournaments()
            if selectedTournament == nil {
                selectedTournament = tournaments.first
            }
            if let id = selectedTournament?.tournamentId {
                await loadMatches(tournamentId: id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMatches(tournamentId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            matches = try await scoring.listScorableMatches(tournamentId: tournamentId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectTournament(_ tournament: MobileTournamentSummary) async {
        selectedTournament = tournament
        await loadMatches(tournamentId: tournament.tournamentId)
    }
}
