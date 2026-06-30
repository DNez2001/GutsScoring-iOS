import Foundation

/// CSV / JSON export — port of Android `MatchEventSerializer.kt`.
enum MatchEventSerializer {
    static let csvHeader =
        "clientEventId,matchTs,gameNumber,shotCount,throwTeam,throwLastName,handLabel,shotName," +
        "resultTag,isAce,isSoak,isDump,isVert,isObsrv,isFF,isRT,catchTeam,hitLastName," +
        "catchLastName,location,spotTag,throwingDownwind,teamL,teamR,scoreLeft,scoreRight,recordedAt"

    static func toCsv(events: [ThrowEventInput]) -> String {
        if events.isEmpty { return csvHeader + "\n" }
        var lines = [csvHeader]
        lines.append(contentsOf: events.map(csvLine(for:)))
        return lines.joined(separator: "\n") + "\n"
    }

    static func toJson(events: [ThrowEventInput], state: GameUiState, matchRef: String?) -> String {
        let payload = MatchEventExport(
            matchRef: matchRef,
            matchTs: state.matchTs,
            tournamentName: state.tournamentName,
            events: events.map { ThrowEventMapping.toDTO(event: $0, state: state) }
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(payload) else { return "{}" }
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    static func buildExport(
        events: [ThrowEventInput],
        state: GameUiState,
        readableLog: String
    ) -> MatchLogExportPayload {
        MatchLogExportPayload(
            readableText: readableLog,
            csvText: toCsv(events: events),
            jsonText: toJson(events: events, state: state, matchRef: state.linkedMatchRef)
        )
    }

    private static func csvLine(for event: ThrowEventInput) -> String {
        [
            event.clientEventId,
            String(event.matchTs),
            String(event.gameNumber),
            String(event.shotCount),
            event.throwTeam,
            event.throwLastName,
            event.handLabel,
            event.shotName,
            event.resultTag,
            String(event.isAce),
            String(event.isSoak),
            String(event.isDump),
            String(event.isVert),
            String(event.isObsrv),
            String(event.isFF),
            String(event.isRT),
            event.catchTeam ?? "",
            event.hitLastName ?? "",
            event.catchLastName ?? "",
            event.location ?? "",
            event.spotTag ?? "",
            event.throwingDownwind.map(String.init) ?? "",
            event.teamL,
            event.teamR,
            String(event.scoreLeft),
            String(event.scoreRight),
            String(event.createdAt),
        ].map(escapeCsvField).joined(separator: ",")
    }

    private static func escapeCsvField(_ value: String) -> String {
        if value.noneSatisfy({ $0 == "," || $0 == "\"" || $0 == "\n" }) { return value }
        return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}

struct MatchEventExport: Encodable {
    let matchRef: String?
    let matchTs: Int64?
    let tournamentName: String
    let events: [ThrowEventDTO]
}

struct MatchLogExportPayload: Equatable {
    let readableText: String
    let csvText: String
    let jsonText: String

    func text(for format: MatchLogExportFormat) -> String {
        switch format {
        case .readable: return readableText
        case .csv: return csvText
        case .json: return jsonText
        }
    }
}

enum MatchLogExportError: LocalizedError {
    case noMatch
    case noEvents

    var errorDescription: String? {
        switch self {
        case .noMatch: return "Start a match before exporting."
        case .noEvents: return "No throws recorded yet."
        }
    }
}

enum MatchLogExportFormat: String, Identifiable, CaseIterable {
    case readable
    case csv
    case json

    var id: String { rawValue }

    var label: String {
        switch self {
        case .readable: return "Readable text log"
        case .csv: return "CSV (spreadsheet)"
        case .json: return "JSON (structured events)"
        }
    }
}
