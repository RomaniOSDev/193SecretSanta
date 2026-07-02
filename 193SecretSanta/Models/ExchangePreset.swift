import Foundation

enum ExchangePreset: String, Codable, CaseIterable, Hashable {
    case custom
    case office
    case family
    case classroom
    case whiteElephant

    var displayName: String {
        switch self {
        case .custom: return "Custom"
        case .office: return "Office Exchange"
        case .family: return "Family Exchange"
        case .classroom: return "Classroom Exchange"
        case .whiteElephant: return "White Elephant"
        }
    }

    var shortDisplayName: String {
        switch self {
        case .custom: return "Custom"
        case .office: return "Office"
        case .family: return "Family"
        case .classroom: return "Classroom"
        case .whiteElephant: return "White\nElephant"
        }
    }

    var icon: String {
        switch self {
        case .custom: return "⚙️"
        case .office: return "💼"
        case .family: return "👨‍👩‍👧‍👦"
        case .classroom: return "🏫"
        case .whiteElephant: return "🐘"
        }
    }

    var subtitle: String {
        switch self {
        case .custom: return "Configure everything yourself"
        case .office: return "Budget, anonymity, purchase deadline"
        case .family: return "Pair exclusions, age groups"
        case .classroom: return "Simple setup, no contact info"
        case .whiteElephant: return "Steal & swap gift rules"
        }
    }

    var defaultBudget: Double? {
        switch self {
        case .office: return 25
        case .family: return 50
        case .classroom: return 15
        case .whiteElephant: return 20
        case .custom: return nil
        }
    }

    var showsContactFields: Bool {
        self != .classroom
    }

    func defaultRules() -> AssignmentRules {
        switch self {
        case .family:
            return AssignmentRules(avoidRepeatPairs: true, restrictToGroups: true)
        case .office:
            return AssignmentRules(avoidRepeatPairs: true, restrictToGroups: false)
        case .classroom:
            return AssignmentRules(avoidRepeatPairs: false, restrictToGroups: true)
        case .whiteElephant:
            return AssignmentRules(avoidRepeatPairs: false, restrictToGroups: false)
        case .custom:
            return AssignmentRules()
        }
    }

    func defaultRevealSettings() -> RevealSettings {
        switch self {
        case .office:
            return RevealSettings(mode: .envelope, onlyOnEventDay: true, passcode: nil)
        case .family:
            return RevealSettings(mode: .scratchCard, onlyOnEventDay: false, passcode: nil)
        case .classroom:
            return RevealSettings(mode: .envelope, onlyOnEventDay: true, passcode: nil)
        case .whiteElephant:
            return RevealSettings(mode: .standard, onlyOnEventDay: false, passcode: nil)
        case .custom:
            return RevealSettings()
        }
    }

    func defaultGroups() -> [ParticipantGroup] {
        switch self {
        case .family:
            return [
                ParticipantGroup(id: UUID(), name: "Adults", colorHex: "fdcc07"),
                ParticipantGroup(id: UUID(), name: "Kids", colorHex: "fdd639")
            ]
        case .classroom:
            return [
                ParticipantGroup(id: UUID(), name: "Group A", colorHex: "fdcc07"),
                ParticipantGroup(id: UUID(), name: "Group B", colorHex: "fdd639")
            ]
        default:
            return []
        }
    }

    var defaultPurchaseDeadlineDays: Int? {
        switch self {
        case .office: return 7
        case .family: return 14
        case .classroom: return 10
        case .whiteElephant: return 5
        case .custom: return nil
        }
    }
}
