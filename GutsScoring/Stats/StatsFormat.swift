import Foundation

enum StatsFormat {
    static func pct(_ count: Int, _ total: Int) -> Double {
        total == 0 ? 0.0 : Double(count) * 100.0 / Double(total)
    }

    static func formatRate(count: Int, total: Int, pct: Double) -> String {
        if total == 0 { return "0 of 0 throws · 0.0%" }
        return String(format: "%d of %d throws · %.1f%%", count, total, pct)
    }

    static func formatZoneRate(successes: Int, attempts: Int) -> String {
        if attempts == 0 { return "—" }
        let pctInt = Int(Double(successes) * 100.0 / Double(attempts))
        return "\(pctInt)% (\(successes)/\(attempts))"
    }

    static func formatGameScores(_ scores: [Int]) -> String {
        if scores.isEmpty { return "—" }
        return scores.enumerated().map { "G\($0.offset + 1): \($0.element)" }.joined(separator: " · ")
    }

    static func formatThrowOutcomes(_ team: TeamStats) -> String {
        var base = "\(team.throwsScored) scored · \(team.throwsCaught) caught · \(team.dumps) dump · \(team.footFaults) foot fault"
        if team.rethrows > 0 { base += " · \(team.rethrows) rethrown" }
        return base
    }

    static func sumThrowStats(_ rows: [PlayerThrowStats]) -> PlayerThrowStats {
        PlayerThrowStats(
            player: "Team totals",
            throws: rows.reduce(0) { $0 + $1.throws },
            scored: rows.reduce(0) { $0 + $1.scored },
            aces: rows.reduce(0) { $0 + $1.aces },
            dumps: rows.reduce(0) { $0 + $1.dumps },
            vertical: rows.reduce(0) { $0 + $1.vertical },
            footFaults: rows.reduce(0) { $0 + $1.footFaults },
            throws1to3: rows.reduce(0) { $0 + $1.throws1to3 },
            scored1to3: rows.reduce(0) { $0 + $1.scored1to3 },
            throws4to6: rows.reduce(0) { $0 + $1.throws4to6 },
            scored4to6: rows.reduce(0) { $0 + $1.scored4to6 },
            throws7to9: rows.reduce(0) { $0 + $1.throws7to9 },
            scored7to9: rows.reduce(0) { $0 + $1.scored7to9 }
        )
    }

    static func sumCatchStats(_ rows: [PlayerCatchStats]) -> PlayerCatchStats {
        PlayerCatchStats(
            player: "Team totals",
            opportunities: rows.reduce(0) { $0 + $1.opportunities },
            uppedOrSoaked: rows.reduce(0) { $0 + $1.uppedOrSoaked },
            soaked: rows.reduce(0) { $0 + $1.soaked },
            acesAgainst: rows.reduce(0) { $0 + $1.acesAgainst },
            spots1to3: rows.reduce(0) { $0 + $1.spots1to3 },
            spots4to6: rows.reduce(0) { $0 + $1.spots4to6 },
            spots7to9: rows.reduce(0) { $0 + $1.spots7to9 },
            caught1to3: rows.reduce(0) { $0 + $1.caught1to3 },
            caught4to6: rows.reduce(0) { $0 + $1.caught4to6 },
            caught7to9: rows.reduce(0) { $0 + $1.caught7to9 }
        )
    }
}
