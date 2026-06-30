import Foundation

/// UUID lookups from production mobile roster — port of Android `RosterIndex.kt`.
struct RosterIndex: Equatable {
    var teamIdsByName: [String: String] = [:]
    var playerIdsByTeamAndCompactName: [String: String] = [:]

    func teamId(for teamName: String?) -> String? {
        guard let teamName, !teamName.isEmpty else { return nil }
        if let id = teamIdsByName[teamName] { return id }
        return teamIdsByName.first { $0.key.caseInsensitiveCompare(teamName) == .orderedSame }?.value
    }

    func playerId(teamName: String?, compactName: String?) -> String? {
        guard let teamName, !teamName.isEmpty, let compactName, !compactName.isEmpty else { return nil }
        let exact = "\(teamName)|\(compactName)"
        if let id = playerIdsByTeamAndCompactName[exact] { return id }
        return playerIdsByTeamAndCompactName.first { key, _ in
            let parts = key.split(separator: "|", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { return false }
            return parts[0].caseInsensitiveCompare(teamName) == .orderedSame
                && parts[1].caseInsensitiveCompare(compactName) == .orderedSame
        }?.value
    }
}

enum RosterIndexBuilder {
    static func build(teams: [MobileTeamRoster]) -> RosterIndex {
        var teamIds: [String: String] = [:]
        var playerIds: [String: String] = [:]
        for team in teams {
            let teamName = team.teamName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !teamName.isEmpty {
                teamIds[teamName] = team.teamId
            }
            for player in team.players {
                let compact = PlayerNameFormat.compactName(player.displayName)
                if !teamName.isEmpty, !compact.isEmpty {
                    playerIds["\(teamName)|\(compact)"] = player.playerId
                }
            }
        }
        return RosterIndex(teamIdsByName: teamIds, playerIdsByTeamAndCompactName: playerIds)
    }
}
