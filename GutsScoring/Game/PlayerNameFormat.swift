import Foundation

enum PlayerNameFormat {
    static let rosterPlaceholder = "?"

    /// "Dave Nesbitt" → "DNesbitt"
    static func compactName(_ fullName: String) -> String {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "" }
        if trimmed == rosterPlaceholder { return trimmed }
        let parts = trimmed.split(whereSeparator: \.isWhitespace).map(String.init)
        if parts.count == 1 { return parts[0] }
        let firstInitial = parts[0].prefix(1).uppercased()
        return "\(firstInitial)\(parts[parts.count - 1])"
    }

    static func compactNameMatches(fullName: String, compact: String) -> Bool {
        let target = compact.trimmingCharacters(in: .whitespacesAndNewlines)
        if target.isEmpty { return false }
        if compactName(fullName).caseInsensitiveCompare(target) == .orderedSame { return true }
        let lastOnly = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ").last ?? ""
        return !lastOnly.isEmpty && lastOnly.caseInsensitiveCompare(target) == .orderedSame
    }
}
