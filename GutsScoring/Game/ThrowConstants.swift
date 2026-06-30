import Foundation

/// Shot types, results, court zones — mirrors Android `throw_dialog.xml` tags.
enum ThrowConstants {
    struct LabeledTag: Identifiable, Hashable {
        let id: String
        let label: String
        let tag: String
    }

    static let shotTypes: [LabeledTag] = [
        .init(id: "back", label: "Backhand", tag: "back"),
        .init(id: "side", label: "Sidearm", tag: "side"),
        .init(id: "thumb", label: "Thumber", tag: "thumb"),
        .init(id: "flip", label: "Flip", tag: "flip"),
        .init(id: "invert", label: "Invert", tag: "invert"),
        .init(id: "staker", label: "Staker", tag: "staker"),
        .init(id: "wrist", label: "Wrist flick", tag: "wristflick"),
    ]

    static let results: [LabeledTag] = [
        .init(id: "1", label: "Score", tag: "1"),
        .init(id: "2", label: "Catch", tag: "2"),
        .init(id: "3", label: "Dump", tag: "3"),
        .init(id: "4", label: "Foot fault", tag: "4"),
        .init(id: "5", label: "Rethrow", tag: "5"),
    ]

    static let lineLocations: [LabeledTag] = [
        .init(id: "1", label: "RE", tag: "1"),
        .init(id: "2", label: "RW", tag: "2"),
        .init(id: "3", label: "C", tag: "3"),
        .init(id: "4", label: "LW", tag: "4"),
        .init(id: "5", label: "LE", tag: "5"),
    ]

    static let dumpLocations: [LabeledTag] = [
        .init(id: "10", label: "Dump High", tag: "10"),
        .init(id: "20", label: "DR", tag: "20"),
        .init(id: "30", label: "DL", tag: "30"),
        .init(id: "40", label: "Dump Low", tag: "40"),
    ]

    static let spots: [LabeledTag] = [
        .init(id: "s1", label: "TL", tag: "1"),
        .init(id: "s2", label: "TC", tag: "2"),
        .init(id: "s3", label: "TR", tag: "3"),
        .init(id: "s4", label: "MR", tag: "4"),
        .init(id: "s5", label: "MC", tag: "5"),
        .init(id: "s6", label: "ML", tag: "6"),
        .init(id: "s7", label: "BR", tag: "7"),
        .init(id: "s8", label: "BC", tag: "8"),
        .init(id: "s9", label: "BL", tag: "9"),
    ]

    static let throwingTeamChoiceLabel = "Throwing Team Choice"
}
