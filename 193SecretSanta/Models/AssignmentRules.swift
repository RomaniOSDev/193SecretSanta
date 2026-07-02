import Foundation

struct ExclusionPair: Identifiable, Codable, Hashable {
    let id: UUID
    var participantIdA: UUID
    var participantIdB: UUID
    var label: String?

    init(id: UUID = UUID(), participantIdA: UUID, participantIdB: UUID, label: String? = nil) {
        self.id = id
        self.participantIdA = participantIdA
        self.participantIdB = participantIdB
        self.label = label
    }

    func involves(_ participantId: UUID) -> Bool {
        participantIdA == participantId || participantIdB == participantId
    }

    func blocks(giverId: UUID, receiverId: UUID) -> Bool {
        (participantIdA == giverId && participantIdB == receiverId) ||
        (participantIdB == giverId && participantIdA == receiverId)
    }
}

struct ForbiddenPair: Identifiable, Codable, Hashable {
    let id: UUID
    var giverId: UUID
    var receiverId: UUID
    var reason: String?

    init(id: UUID = UUID(), giverId: UUID, receiverId: UUID, reason: String? = nil) {
        self.id = id
        self.giverId = giverId
        self.receiverId = receiverId
        self.reason = reason
    }
}

struct ParticipantGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var colorHex: String

    init(id: UUID = UUID(), name: String, colorHex: String = "fdcc07") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}

struct AssignmentRules: Codable, Hashable {
    var exclusionPairs: [ExclusionPair]
    var forbiddenPairs: [ForbiddenPair]
    var avoidRepeatPairs: Bool
    var restrictToGroups: Bool

    init(
        exclusionPairs: [ExclusionPair] = [],
        forbiddenPairs: [ForbiddenPair] = [],
        avoidRepeatPairs: Bool = false,
        restrictToGroups: Bool = false
    ) {
        self.exclusionPairs = exclusionPairs
        self.forbiddenPairs = forbiddenPairs
        self.avoidRepeatPairs = avoidRepeatPairs
        self.restrictToGroups = restrictToGroups
    }
}

struct HistoricalPair: Codable, Hashable, Identifiable {
    var id: String { "\(giverId)-\(receiverId)-\(eventId)" }
    let giverId: UUID
    let receiverId: UUID
    let eventId: UUID
    let eventName: String
    let year: Int
}

struct PairHistoryStore: Codable {
    var pairs: [HistoricalPair]

    init(pairs: [HistoricalPair] = []) {
        self.pairs = pairs
    }
}

enum AssignmentError: LocalizedError {
    case notEnoughParticipants
    case groupTooSmall(String)
    case constraintsUnsatisfiable
    case ungroupedParticipants

    var errorDescription: String? {
        switch self {
        case .notEnoughParticipants:
            return "Need at least 2 active participants."
        case .groupTooSmall(let name):
            return "Group \"\(name)\" needs at least 2 active participants."
        case .constraintsUnsatisfiable:
            return "Could not satisfy all rules. Try relaxing exclusions or group restrictions."
        case .ungroupedParticipants:
            return "All participants must belong to a group when group restriction is enabled."
        }
    }
}
