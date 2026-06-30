import Foundation

/// Readable game log lines — port of Android `EventEntity.toReadableLogLine()`.
enum EventLogFormatting {
    static func readableLogLine(for event: ThrowEventInput) -> String {
        let stored = event.withScoresAfterThisPoint()
        let throwText = "\(stored.throwLastName)'s \(stored.handLabel) \(stored.shotName)"
        let court = courtZoneLabel(stored.location).trimmingCharacters(in: .whitespaces)
        let spot = spotZoneLabel(stored.spotTag).trimmingCharacters(in: .whitespaces)
        let wherePhrase = [court, spot].filter { !$0.isEmpty }.joined(separator: " ")
        let whereClause = wherePhrase.isEmpty ? "" : " at \(wherePhrase)"
        let obsrvText = stored.isObsrv ? " (Obs)" : ""

        let resultText: String = switch stored.resultTag {
        case "1":
            formatScoreResult(throwText: throwText, event: stored, whereClause: whereClause, obsrvText: obsrvText)
        case "2":
            formatCatchResult(throwText: throwText, event: stored, whereClause: whereClause, obsrvText: obsrvText)
        case "3":
            stored.isVert
                ? "\(throwText) vertical dump\(obsrvText)"
                : "\(throwText) dumped \(courtZoneLabel(stored.location))\(obsrvText)".trimmingCharacters(in: .whitespaces)
        case "4":
            "\(throwText) foot faulted"
        case "5":
            "\(throwText) had to be re-thrown\(obsrvText)"
        default:
            "→ UNKNOWN RESULT"
        }

        let scoreText = "\(stored.teamL) \(stored.scoreLeft) - \(stored.teamR) \(stored.scoreRight)"
        let resultText2: String = switch stored.resultTag {
        case "1":
            if stored.isAce, let catchName = stored.catchLastName, !catchName.isEmpty {
                "\(stored.throwTeam) aces (throwing team choice): "
            } else if stored.isAce {
                "\(stored.throwTeam) aces: "
            } else {
                "\(stored.throwTeam) scores: "
            }
        case "2":
            "\(stored.throwTeam) are caught: same score"
        case "3":
            stored.isVert ? "\(stored.throwTeam) vertical dump: " : "\(stored.throwTeam) dumps: "
        case "4":
            "\(stored.throwTeam) foot faults: same score"
        case "5":
            "\(stored.throwTeam) rethrows: same score"
        default:
            ""
        }

        return "[\(stored.shotCount)] \(resultText)\n\(resultText2) \(scoreText)\n"
    }

    private static func formatScoreResult(
        throwText: String,
        event: ThrowEventInput,
        whereClause: String,
        obsrvText: String
    ) -> String {
        let defender = event.hitLastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let throwBack = event.catchLastName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if event.isAce {
            if let throwBack, !throwBack.isEmpty {
                return "\(throwText) aces (throwing team choice, throw-back \(throwBack))\(whereClause)\(obsrvText)"
            }
            let who = defender.isEmpty ? "" : " \(defender)"
            return "\(throwText) aces\(who)\(whereClause)\(obsrvText)"
        }
        let who = defender.isEmpty ? "" : " on \(defender)"
        return "\(throwText) scores\(who)\(whereClause)\(obsrvText)"
    }

    private static func formatCatchResult(
        throwText: String,
        event: ThrowEventInput,
        whereClause: String,
        obsrvText: String
    ) -> String {
        let hit = event.hitLastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let catcher = event.catchLastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if event.isSoak {
            let byPart = hit.isEmpty ? "" : " by \(hit)"
            return "\(throwText) is soaked\(byPart)\(whereClause)\(obsrvText)"
        }
        let hitPart = hit.isEmpty ? "" : " by \(hit)"
        let catchPart = catcher.isEmpty ? "" : " & caught by \(catcher)"
        return "\(throwText) is upped\(hitPart)\(whereClause)\(catchPart)\(obsrvText)"
    }

    private static func courtZoneLabel(_ location: String?) -> String {
        switch location {
        case "10": "Dump High"
        case "20": "DR"
        case "30": "DL"
        case "40": "Dump Low"
        case "1": "RE"
        case "2": "RW"
        case "3": "C"
        case "4": "LW"
        case "5": "LE"
        default: ""
        }
    }

    private static func spotZoneLabel(_ spotTag: String?) -> String {
        switch spotTag {
        case "1": "Top Left"
        case "2": "Top Center"
        case "3": "Top Right"
        case "4": "Mid Right"
        case "5": "Mid Center"
        case "6": "Mid Left"
        case "7": "Bottom Right"
        case "8": "Bottom Center"
        case "9": "Bottom Left"
        default: ""
        }
    }
}
