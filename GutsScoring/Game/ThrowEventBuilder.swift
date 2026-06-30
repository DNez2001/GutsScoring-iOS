import Foundation

/// Form payload from the throw dialog — port of Android submit logic in `ThrowDialogFragment`.
struct ThrowDialogForm: Equatable {
    var throwerFullName: String = ""
    var shotTypeLabel: String = "Backhand"
    var resultTag: String = "1"
    var rightHanded: Bool = true
    var isAce: Bool = false
    var isSoak: Bool = false
    var isVerticalDump: Bool = false
    var isObserver: Bool = false
    var hitPlayerFullName: String = ""
    var catchPlayerFullName: String = ""
    var lineLocationTag: String?
    var dumpLocationTag: String?
    var spotTag: String?
    var hitIsThrowingTeamChoice: Bool = false
}

enum ThrowEventBuilder {
    static func buildEvent(form: ThrowDialogForm, state: GameUiState) throws -> ThrowEventInput {
        guard let matchTs = state.matchTs else {
            throw ThrowFormError.gameNotStarted
        }
        let throwingTeam = state.activeThrowTeam
        let catchTeam = throwingTeam == state.teamLeft ? state.teamRight : state.teamLeft

        if state.trackPlayerNames && form.throwerFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ThrowFormError.needThrower
        }
        if form.shotTypeLabel.isEmpty {
            throw ThrowFormError.needShotType
        }
        if form.resultTag.isEmpty {
            throw ThrowFormError.needResult
        }

        if state.trackPlayerNames && form.resultTag == "1" {
            if form.isAce && form.hitIsThrowingTeamChoice {
                if form.catchPlayerFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    throw ThrowFormError.needThrowBackOnAce
                }
            } else if form.hitPlayerFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ThrowFormError.needHitOnScore
            }
        }

        if state.trackPlayerNames && form.resultTag == "2" {
            if form.catchPlayerFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ThrowFormError.needCatcher
            }
            if !form.isSoak && form.hitPlayerFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ThrowFormError.needHitOrSoak
            }
        }

        let needsLine = ["1", "2"].contains(form.resultTag)
        let needsSpot = ["1", "2"].contains(form.resultTag)
        let needsDumpLoc = form.resultTag == "3" && !form.isVerticalDump
        if needsLine && form.lineLocationTag == nil { throw ThrowFormError.needLineLocation }
        if needsDumpLoc && form.dumpLocationTag == nil { throw ThrowFormError.needDumpLocation }
        if needsSpot && form.spotTag == nil { throw ThrowFormError.needSpotLocation }

        let throwerLast: String
        if state.trackPlayerNames {
            throwerLast = PlayerNameFormat.compactName(form.throwerFullName)
        } else {
            throwerLast = PlayerNameFormat.rosterPlaceholder
        }

        func label(_ full: String) -> String? {
            let t = full.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { return nil }
            return PlayerNameFormat.compactName(t)
        }

        let catchLast: String? = {
            guard state.trackPlayerNames else { return nil }
            switch form.resultTag {
            case "2": return label(form.catchPlayerFullName)
            case "1" where form.isAce && form.hitIsThrowingTeamChoice:
                return label(form.catchPlayerFullName)
            default: return nil
            }
        }()

        let hitLast: String? = {
            guard state.trackPlayerNames else { return nil }
            switch form.resultTag {
            case "1":
                if form.isAce && form.hitIsThrowingTeamChoice { return nil }
                return label(form.hitPlayerFullName)
            case "2":
                return form.isSoak ? catchLast : label(form.hitPlayerFullName)
            default: return nil
            }
        }()

        let locationVal: String? = {
            if form.resultTag == "3" && form.isVerticalDump { return nil }
            if form.resultTag == "3" { return form.dumpLocationTag }
            return form.lineLocationTag
        }()

        let spotVal: String? = needsSpot ? form.spotTag : nil

        return ThrowEventInput(
            matchTs: matchTs,
            gameNumber: state.gameCount,
            shotCount: state.shotCount,
            throwTeam: throwingTeam,
            throwLastName: throwerLast,
            handLabel: form.rightHanded ? "RH" : "LH",
            shotName: form.shotTypeLabel.lowercased(),
            resultTag: form.resultTag,
            isAce: form.isAce,
            isSoak: form.isSoak,
            isDump: form.resultTag == "3",
            isVert: form.isVerticalDump,
            isObsrv: form.isObserver,
            isFF: form.resultTag == "4",
            isRT: form.resultTag == "5",
            catchTeam: catchTeam,
            hitLastName: hitLast,
            catchLastName: catchLast,
            location: locationVal,
            spotTag: spotVal,
            teamL: state.teamLeft,
            teamR: state.teamRight,
            scoreLeft: state.scoreLeft,
            scoreRight: state.scoreRight,
            throwingDownwind: state.downwindTeam.map { throwingTeam.caseInsensitiveCompare($0) == .orderedSame }
        )
    }
}

enum ThrowFormError: LocalizedError {
    case gameNotStarted
    case needThrower
    case needShotType
    case needResult
    case needHitOnScore
    case needThrowBackOnAce
    case needCatcher
    case needHitOrSoak
    case needLineLocation
    case needDumpLocation
    case needSpotLocation

    var errorDescription: String? {
        switch self {
        case .gameNotStarted: return "Start the match before recording throws."
        case .needThrower: return "Select who threw."
        case .needShotType: return "Select a shot type."
        case .needResult: return "Select a result."
        case .needHitOnScore: return "Select who was hit on the score."
        case .needThrowBackOnAce: return "Select who throws back on the ace."
        case .needCatcher: return "Select who caught."
        case .needHitOrSoak: return "Select who was hit first, or check Soak."
        case .needLineLocation: return "Select a line location."
        case .needDumpLocation: return "Select a dump location."
        case .needSpotLocation: return "Select a spot on the disc."
        }
    }
}
