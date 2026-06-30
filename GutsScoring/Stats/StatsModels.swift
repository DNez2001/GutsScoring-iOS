import Foundation

struct TeamStats: Equatable {
    let teamName: String
    let gameScores: [Int]
    let totalThrows: Int
    let throwsScored: Int
    let throwsCaught: Int
    let scoredPct: Double
    let caughtPct: Double
    let catchOpportunities: Int
    let catchesMade: Int
    let dumps: Int
    let footFaults: Int
    let rethrows: Int
}

struct PlayerThrowStats: Equatable {
    let player: String
    let throws: Int
    let scored: Int
    let aces: Int
    let dumps: Int
    let vertical: Int
    let footFaults: Int
    let throws1to3: Int
    let scored1to3: Int
    let throws4to6: Int
    let scored4to6: Int
    let throws7to9: Int
    let scored7to9: Int

    init(
        player: String,
        throws: Int,
        scored: Int,
        aces: Int,
        dumps: Int,
        vertical: Int,
        footFaults: Int,
        throws1to3: Int = 0,
        scored1to3: Int = 0,
        throws4to6: Int = 0,
        scored4to6: Int = 0,
        throws7to9: Int = 0,
        scored7to9: Int = 0
    ) {
        self.player = player
        self.throws = throws
        self.scored = scored
        self.aces = aces
        self.dumps = dumps
        self.vertical = vertical
        self.footFaults = footFaults
        self.throws1to3 = throws1to3
        self.scored1to3 = scored1to3
        self.throws4to6 = throws4to6
        self.scored4to6 = scored4to6
        self.throws7to9 = throws7to9
        self.scored7to9 = scored7to9
    }
}

struct PlayerCatchStats: Equatable {
    let player: String
    let opportunities: Int
    let uppedOrSoaked: Int
    let soaked: Int
    let acesAgainst: Int
    let spots1to3: Int
    let spots4to6: Int
    let spots7to9: Int
    let caught1to3: Int
    let caught4to6: Int
    let caught7to9: Int

    init(
        player: String,
        opportunities: Int,
        uppedOrSoaked: Int,
        soaked: Int,
        acesAgainst: Int,
        spots1to3: Int,
        spots4to6: Int,
        spots7to9: Int,
        caught1to3: Int = 0,
        caught4to6: Int = 0,
        caught7to9: Int = 0
    ) {
        self.player = player
        self.opportunities = opportunities
        self.uppedOrSoaked = uppedOrSoaked
        self.soaked = soaked
        self.acesAgainst = acesAgainst
        self.spots1to3 = spots1to3
        self.spots4to6 = spots4to6
        self.spots7to9 = spots7to9
        self.caught1to3 = caught1to3
        self.caught4to6 = caught4to6
        self.caught7to9 = caught7to9
    }
}

struct TeamWindStats: Equatable {
    var downwindThrows: Int = 0
    var downwindScored: Int = 0
    var upwindThrows: Int = 0
    var upwindScored: Int = 0
    var catchVsDownwindOpportunities: Int = 0
    var catchVsDownwindMade: Int = 0
    var catchVsUpwindOpportunities: Int = 0
    var catchVsUpwindMade: Int = 0

    var hasData: Bool {
        downwindThrows + upwindThrows + catchVsDownwindOpportunities + catchVsUpwindOpportunities > 0
    }
}

struct MatchStatsSnapshot: Equatable {
    let teamLeft: TeamStats
    let teamRight: TeamStats
    let windLeft: TeamWindStats
    let windRight: TeamWindStats
    let leftThrowStats: [PlayerThrowStats]
    let leftCatchStats: [PlayerCatchStats]
    let rightThrowStats: [PlayerThrowStats]
    let rightCatchStats: [PlayerCatchStats]
}
