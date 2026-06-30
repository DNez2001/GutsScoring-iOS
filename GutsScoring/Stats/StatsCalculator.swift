import Foundation

/// Match statistics — port of Android `StatsCalculator.kt`.
enum StatsCalculator {
    static func calcTeamStats(
        events: [ThrowEventInput],
        teamAName: String,
        teamBName: String,
        maxGamesShown: Int = 3
    ) -> (TeamStats, TeamStats) {
        var aScores = Array(repeating: 0, count: maxGamesShown)
        var bScores = Array(repeating: 0, count: maxGamesShown)

        var aThrows = 0, bThrows = 0
        var aScored = 0, bScored = 0
        var aDumps = 0, bDumps = 0
        var aFF = 0, bFF = 0
        var aRT = 0, bRT = 0
        var aCaughtThrows = 0, bCaughtThrows = 0

        let sorted = events.sorted { lhs, rhs in
            if lhs.gameNumber != rhs.gameNumber { return lhs.gameNumber < rhs.gameNumber }
            return lhs.id < rhs.id
        }

        for event in sorted {
            let gIdx = min(max(event.gameNumber - 1, 0), maxGamesShown - 1)
            let isAThrow = event.throwTeam.caseInsensitiveCompare(teamAName) == .orderedSame
            let isBThrow = event.throwTeam.caseInsensitiveCompare(teamBName) == .orderedSame

            if event.resultTag != "5" {
                if isAThrow { aThrows += 1 }
                if isBThrow { bThrows += 1 }
            }

            switch event.resultTag {
            case "1":
                if isAThrow { aScored += 1; aScores[gIdx] += 1 }
                if isBThrow { bScored += 1; bScores[gIdx] += 1 }
            case "2":
                if isAThrow { aCaughtThrows += 1 }
                if isBThrow { bCaughtThrows += 1 }
            case "3":
                if isAThrow { aDumps += 1; bScores[gIdx] += 1 }
                if isBThrow { bDumps += 1; aScores[gIdx] += 1 }
            case "4":
                if isAThrow { aFF += 1 }
                if isBThrow { bFF += 1 }
            case "5":
                if isAThrow { aRT += 1 }
                if isBThrow { bRT += 1 }
            default: break
            }
        }

        func pct(_ n: Int, _ d: Int) -> Double { d == 0 ? 0.0 : Double(n) * 100.0 / Double(d) }

        let aCatchOpportunities = bThrows - bDumps - bFF
        let aCatchesMade = bThrows - bScored - bDumps - bFF
        let bCatchOpportunities = aThrows - aDumps - aFF
        let bCatchesMade = aThrows - aScored - aDumps - aFF

        let aTop = TeamStats(
            teamName: teamAName,
            gameScores: aScores,
            totalThrows: aThrows,
            throwsScored: aScored,
            throwsCaught: aCaughtThrows,
            scoredPct: pct(aScored, aThrows),
            caughtPct: pct(aCatchesMade, aCatchOpportunities),
            catchOpportunities: aCatchOpportunities,
            catchesMade: aCatchesMade,
            dumps: aDumps,
            footFaults: aFF,
            rethrows: aRT
        )
        let bTop = TeamStats(
            teamName: teamBName,
            gameScores: bScores,
            totalThrows: bThrows,
            throwsScored: bScored,
            throwsCaught: bCaughtThrows,
            scoredPct: pct(bScored, bThrows),
            caughtPct: pct(bCatchesMade, bCatchOpportunities),
            catchOpportunities: bCatchOpportunities,
            catchesMade: bCatchesMade,
            dumps: bDumps,
            footFaults: bFF,
            rethrows: bRT
        )
        return (aTop, bTop)
    }

    static func calcPlayerThrowStats(events: [ThrowEventInput], teamName: String) -> [PlayerThrowStats] {
        var map: [String: PlayerThrowStats] = [:]

        func spotBucket(_ spotTag: String?) -> Int {
            guard let i = spotTag.flatMap(Int.init) else { return 0 }
            switch i {
            case 1...3: return 1
            case 4...6: return 2
            case 7...9: return 3
            default: return 0
            }
        }

        func acc(_ last: String, _ f: (PlayerThrowStats?) -> PlayerThrowStats) {
            map[last] = f(map[last])
        }

        for event in events where event.throwTeam.caseInsensitiveCompare(teamName) == .orderedSame {
            let last = event.throwLastName.isEmpty ? "?" : event.throwLastName
            let isRethrow = event.resultTag == "5"
            let isScore = event.resultTag == "1"
            let bucket = spotBucket(event.spotTag)

            acc(last) { cur in
                let base = cur ?? PlayerThrowStats(player: last, throws: 0, scored: 0, aces: 0, dumps: 0, vertical: 0, footFaults: 0)
                var next = PlayerThrowStats(
                    player: last,
                    throws: base.throws + (isRethrow ? 0 : 1),
                    scored: base.scored + (isScore ? 1 : 0),
                    aces: base.aces + (isScore && event.isAce ? 1 : 0),
                    dumps: base.dumps + (event.isDump ? 1 : 0),
                    vertical: base.vertical + (event.isDump && event.isVert ? 1 : 0),
                    footFaults: base.footFaults + (event.isFF ? 1 : 0),
                    throws1to3: base.throws1to3,
                    scored1to3: base.scored1to3,
                    throws4to6: base.throws4to6,
                    scored4to6: base.scored4to6,
                    throws7to9: base.throws7to9,
                    scored7to9: base.scored7to9
                )
                if !isRethrow {
                    switch bucket {
                    case 1:
                        next = PlayerThrowStats(
                            player: next.player, throws: next.throws, scored: next.scored, aces: next.aces,
                            dumps: next.dumps, vertical: next.vertical, footFaults: next.footFaults,
                            throws1to3: next.throws1to3 + 1, scored1to3: next.scored1to3 + (isScore ? 1 : 0),
                            throws4to6: next.throws4to6, scored4to6: next.scored4to6,
                            throws7to9: next.throws7to9, scored7to9: next.scored7to9
                        )
                    case 2:
                        next = PlayerThrowStats(
                            player: next.player, throws: next.throws, scored: next.scored, aces: next.aces,
                            dumps: next.dumps, vertical: next.vertical, footFaults: next.footFaults,
                            throws1to3: next.throws1to3, scored1to3: next.scored1to3,
                            throws4to6: next.throws4to6 + 1, scored4to6: next.scored4to6 + (isScore ? 1 : 0),
                            throws7to9: next.throws7to9, scored7to9: next.scored7to9
                        )
                    case 3:
                        next = PlayerThrowStats(
                            player: next.player, throws: next.throws, scored: next.scored, aces: next.aces,
                            dumps: next.dumps, vertical: next.vertical, footFaults: next.footFaults,
                            throws1to3: next.throws1to3, scored1to3: next.scored1to3,
                            throws4to6: next.throws4to6, scored4to6: next.scored4to6,
                            throws7to9: next.throws7to9 + 1, scored7to9: next.scored7to9 + (isScore ? 1 : 0)
                        )
                    default: break
                    }
                }
                return next
            }
        }
        return Array(map.values)
    }

    static func calcPlayerCatchStats(events: [ThrowEventInput], teamName: String) -> [PlayerCatchStats] {
        var map: [String: PlayerCatchStats] = [:]

        func spotBucket(_ spotTag: String?) -> Int {
            guard let i = spotTag.flatMap(Int.init) else { return 0 }
            switch i {
            case 1...3: return 1
            case 4...6: return 2
            case 7...9: return 3
            default: return 0
            }
        }

        func acc(_ last: String, _ f: (PlayerCatchStats?) -> PlayerCatchStats) {
            map[last] = f(map[last])
        }

        for event in events {
            guard event.catchTeam?.caseInsensitiveCompare(teamName) == .orderedSame else { continue }
            guard event.resultTag == "1" || event.resultTag == "2" else { continue }

            let last: String = {
                func nonEmpty(_ value: String?) -> String? {
                    guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
                        return nil
                    }
                    return trimmed
                }
                switch event.resultTag {
                case "1":
                    return nonEmpty(event.hitLastName) ?? nonEmpty(event.catchLastName) ?? "?"
                case "2":
                    return nonEmpty(event.catchLastName) ?? nonEmpty(event.hitLastName) ?? "?"
                default:
                    return nonEmpty(event.catchLastName) ?? "?"
                }
            }()

            let bucket = spotBucket(event.spotTag)
            let isCatch = event.resultTag == "2"
            let isAce = event.resultTag == "1" && event.isAce
            let isSoak = event.isSoak && isCatch

            acc(last) { cur in
                let base = cur ?? PlayerCatchStats(
                    player: last, opportunities: 0, uppedOrSoaked: 0, soaked: 0, acesAgainst: 0,
                    spots1to3: 0, spots4to6: 0, spots7to9: 0
                )
                return PlayerCatchStats(
                    player: last,
                    opportunities: base.opportunities + 1,
                    uppedOrSoaked: base.uppedOrSoaked + (isCatch ? 1 : 0),
                    soaked: base.soaked + (isSoak ? 1 : 0),
                    acesAgainst: base.acesAgainst + (isAce ? 1 : 0),
                    spots1to3: base.spots1to3 + (bucket == 1 ? 1 : 0),
                    spots4to6: base.spots4to6 + (bucket == 2 ? 1 : 0),
                    spots7to9: base.spots7to9 + (bucket == 3 ? 1 : 0),
                    caught1to3: base.caught1to3 + (bucket == 1 && isCatch ? 1 : 0),
                    caught4to6: base.caught4to6 + (bucket == 2 && isCatch ? 1 : 0),
                    caught7to9: base.caught7to9 + (bucket == 3 && isCatch ? 1 : 0)
                )
            }
        }
        return Array(map.values)
    }

    static func calcTeamWindStats(events: [ThrowEventInput], teamName: String) -> TeamWindStats {
        var stats = TeamWindStats()

        for event in events {
            guard let wind = event.throwingDownwind else { continue }
            let isTeamThrow = event.throwTeam.caseInsensitiveCompare(teamName) == .orderedSame
            let isTeamCatch = event.catchTeam?.caseInsensitiveCompare(teamName) == .orderedSame

            if isTeamThrow && event.resultTag != "5" {
                if wind {
                    stats.downwindThrows += 1
                    if event.resultTag == "1" { stats.downwindScored += 1 }
                } else {
                    stats.upwindThrows += 1
                    if event.resultTag == "1" { stats.upwindScored += 1 }
                }
            }

            if isTeamCatch && (event.resultTag == "1" || event.resultTag == "2") {
                let isCatch = event.resultTag == "2"
                if wind {
                    stats.catchVsDownwindOpportunities += 1
                    if isCatch { stats.catchVsDownwindMade += 1 }
                } else {
                    stats.catchVsUpwindOpportunities += 1
                    if isCatch { stats.catchVsUpwindMade += 1 }
                }
            }
        }
        return stats
    }

    static func buildSnapshot(events: [ThrowEventInput], teamLeft: String, teamRight: String) -> MatchStatsSnapshot {
        let (left, right) = calcTeamStats(events: events, teamAName: teamLeft, teamBName: teamRight)
        return MatchStatsSnapshot(
            teamLeft: left,
            teamRight: right,
            windLeft: calcTeamWindStats(events: events, teamName: teamLeft),
            windRight: calcTeamWindStats(events: events, teamName: teamRight),
            leftThrowStats: calcPlayerThrowStats(events: events, teamName: teamLeft),
            leftCatchStats: calcPlayerCatchStats(events: events, teamName: teamLeft),
            rightThrowStats: calcPlayerThrowStats(events: events, teamName: teamRight),
            rightCatchStats: calcPlayerCatchStats(events: events, teamName: teamRight)
        )
    }
}
