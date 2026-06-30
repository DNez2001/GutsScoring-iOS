import SwiftUI

/// Match statistics sheet — port of Android `StatsDialogBuilder` + `StatsFormat`.
struct StatsSheetView: View {
    let snapshot: MatchStatsSnapshot
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Team match stats")
                        .font(.headline)

                    teamCard(snapshot.teamLeft, wind: snapshot.windLeft)
                    teamCard(snapshot.teamRight, wind: snapshot.windRight)

                    playerSection(
                        teamName: snapshot.teamLeft.teamName,
                        throws: snapshot.leftThrowStats,
                        catches: snapshot.leftCatchStats
                    )
                    playerSection(
                        teamName: snapshot.teamRight.teamName,
                        throws: snapshot.rightThrowStats,
                        catches: snapshot.rightCatchStats
                    )
                }
                .padding()
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func teamCard(_ team: TeamStats, wind: TeamWindStats) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(team.teamName)
                .font(.headline)
                .foregroundStyle(.blue)
            statLine("Games: \(StatsFormat.formatGameScores(team.gameScores))")
            statLine("Throws: \(team.totalThrows)")
            statLine("Scored: \(StatsFormat.formatRate(count: team.throwsScored, total: team.totalThrows, pct: team.scoredPct))")
            statLine("Throw outcomes: \(StatsFormat.formatThrowOutcomes(team))", muted: true)
            statLine("Caught: \(StatsFormat.formatRate(count: team.catchesMade, total: team.catchOpportunities, pct: team.caughtPct))")
            statLine("Dumps \(team.dumps) · FF \(team.footFaults) · RT \(team.rethrows)")

            if wind.hasData {
                Text("Wind direction")
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 4)
                statLine("Throw downwind: \(StatsFormat.formatRate(count: wind.downwindScored, total: wind.downwindThrows, pct: StatsFormat.pct(wind.downwindScored, wind.downwindThrows)))")
                statLine("Throw upwind: \(StatsFormat.formatRate(count: wind.upwindScored, total: wind.upwindThrows, pct: StatsFormat.pct(wind.upwindScored, wind.upwindThrows)))")
                statLine(String(format: "Catch vs downwind throws: %d of %d · %.1f%%", wind.catchVsDownwindMade, wind.catchVsDownwindOpportunities, StatsFormat.pct(wind.catchVsDownwindMade, wind.catchVsDownwindOpportunities)))
                statLine(String(format: "Catch vs upwind throws: %d of %d · %.1f%%", wind.catchVsUpwindMade, wind.catchVsUpwindOpportunities, StatsFormat.pct(wind.catchVsUpwindMade, wind.catchVsUpwindOpportunities)))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func playerSection(teamName: String, throws throwStats: [PlayerThrowStats], catches: [PlayerCatchStats]) -> some View {
        if throwStats.isEmpty && catches.isEmpty { EmptyView() }
        else {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(teamName) — players")
                    .font(.headline)

                if !throwStats.isEmpty {
                    Text("Throwing")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    statsTable(
                        headers: ["Player", "Thr", "Sc", "Ace", "Dump", "Vert", "FF", "Sc High", "Sc Zone", "Sc Low"],
                        rows: throwStats.map { p in
                            [
                                p.player,
                                "\(p.throws)", "\(p.scored)", "\(p.aces)", "\(p.dumps)", "\(p.vertical)", "\(p.footFaults)",
                                StatsFormat.formatZoneRate(successes: p.scored1to3, attempts: p.throws1to3),
                                StatsFormat.formatZoneRate(successes: p.scored4to6, attempts: p.throws4to6),
                                StatsFormat.formatZoneRate(successes: p.scored7to9, attempts: p.throws7to9),
                            ]
                        },
                        totals: {
                            let t = StatsFormat.sumThrowStats(throwStats)
                            return [
                                t.player,
                                "\(t.throws)", "\(t.scored)", "\(t.aces)", "\(t.dumps)", "\(t.vertical)", "\(t.footFaults)",
                                StatsFormat.formatZoneRate(successes: t.scored1to3, attempts: t.throws1to3),
                                StatsFormat.formatZoneRate(successes: t.scored4to6, attempts: t.throws4to6),
                                StatsFormat.formatZoneRate(successes: t.scored7to9, attempts: t.throws7to9),
                            ]
                        }()
                    )
                }

                if !catches.isEmpty {
                    Text("Catching")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    statsTable(
                        headers: ["Player", "Opp", "Up/Soak", "Soak", "Ace↯", "Ct High", "Ct Zone", "Ct Low"],
                        rows: catches.map { p in
                            [
                                p.player,
                                "\(p.opportunities)", "\(p.uppedOrSoaked)", "\(p.soaked)", "\(p.acesAgainst)",
                                StatsFormat.formatZoneRate(successes: p.caught1to3, attempts: p.spots1to3),
                                StatsFormat.formatZoneRate(successes: p.caught4to6, attempts: p.spots4to6),
                                StatsFormat.formatZoneRate(successes: p.caught7to9, attempts: p.spots7to9),
                            ]
                        },
                        totals: {
                            let t = StatsFormat.sumCatchStats(catches)
                            return [
                                t.player,
                                "\(t.opportunities)", "\(t.uppedOrSoaked)", "\(t.soaked)", "\(t.acesAgainst)",
                                StatsFormat.formatZoneRate(successes: t.caught1to3, attempts: t.spots1to3),
                                StatsFormat.formatZoneRate(successes: t.caught4to6, attempts: t.spots4to6),
                                StatsFormat.formatZoneRate(successes: t.caught7to9, attempts: t.spots7to9),
                            ]
                        }()
                    )
                }
            }
        }
    }

    private func statsTable(headers: [String], rows: [[String]], totals: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: true) {
            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 4) {
                GridRow {
                    ForEach(headers, id: \.self) { header in
                        Text(header)
                            .font(.caption2.weight(.bold))
                            .frame(minWidth: 44, alignment: .center)
                    }
                }
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    GridRow {
                        ForEach(Array(row.enumerated()), id: \.offset) { index, cell in
                            Text(cell)
                                .font(.caption2)
                                .foregroundStyle(index == 0 ? .blue : .primary)
                                .fontWeight(index == 0 ? .semibold : .regular)
                                .frame(minWidth: 44, alignment: index == 0 ? .leading : .center)
                        }
                    }
                }
                GridRow {
                    ForEach(Array(totals.enumerated()), id: \.offset) { index, cell in
                        Text(cell)
                            .font(.caption2.weight(.bold))
                            .frame(minWidth: 44, alignment: index == 0 ? .leading : .center)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func statLine(_ text: String, muted: Bool = false) -> some View {
        Text(text)
            .font(muted ? .caption : .subheadline)
            .foregroundStyle(muted ? .secondary : .primary)
    }
}
