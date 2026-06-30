import Foundation

/// M0 mobile scoring reads — tournament-route shims (same as Android `MobileScoringApi.kt`).
final class MobileScoringService {
    private let api: APIClient

    init(api: APIClient = .shared) {
        self.api = api
    }

    func listTournaments(status: String? = nil) async throws -> [MobileTournamentSummary] {
        var query = [URLQueryItem(name: "mobileScoring", value: "1")]
        if let status { query.append(URLQueryItem(name: "status", value: status)) }
        let response: MobileTournamentListResponse = try await api.request("tournaments", query: query)
        return response.tournaments
    }

    func listScorableMatches(tournamentId: String, divisionId: String? = nil) async throws -> [ScorableMatch] {
        var query = [
            URLQueryItem(name: "mobileView", value: "scorable-matches"),
        ]
        if let divisionId { query.append(URLQueryItem(name: "divisionId", value: divisionId)) }
        let response: ScorableMatchesResponse = try await api.request(
            "tournaments/\(tournamentId)",
            query: query
        )
        return response.matches.filter(\.isOpenForScoring)
    }

    func getRosters(tournamentId: String, divisionId: String? = nil) async throws -> TournamentRostersResponse {
        var query = [URLQueryItem(name: "mobileView", value: "rosters")]
        if let divisionId { query.append(URLQueryItem(name: "divisionId", value: divisionId)) }
        return try await api.request("tournaments/\(tournamentId)", query: query)
    }

    func updateMatchProgress(tournamentId: String, request: MatchProgressRequest, ifMatch: Int? = nil) async throws -> MatchProgressResponse {
        try await api.request(
            "tournaments/\(tournamentId)",
            method: "PUT",
            query: [URLQueryItem(name: "mobileView", value: "match-progress")],
            body: request,
            ifMatch: ifMatch
        )
    }

    func appendMatchEvents(tournamentId: String, request: MatchEventsBatchRequest) async throws -> MatchEventsBatchResponse {
        try await api.request(
            "tournaments/\(tournamentId)",
            method: "PUT",
            query: [URLQueryItem(name: "mobileView", value: "match-events")],
            body: request
        )
    }
}
