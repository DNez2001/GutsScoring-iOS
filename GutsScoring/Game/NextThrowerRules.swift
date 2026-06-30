import Foundation

enum NextThrowerRules {
    static func preferredNextThrower(after event: ThrowEventInput) -> String? {
        switch event.resultTag {
        case "1":
            let hit = event.hitLastName?.trimmingCharacters(in: .whitespacesAndNewlines)
            if event.isAce, hit == nil || hit?.isEmpty == true { return nil }
            return hit
        case "2":
            return event.catchLastName?.trimmingCharacters(in: .whitespacesAndNewlines).flatMap { $0.isEmpty ? nil : $0 }
        default:
            return nil
        }
    }
}
