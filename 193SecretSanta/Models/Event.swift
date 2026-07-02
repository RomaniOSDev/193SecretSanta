import Foundation

struct Event: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String?
    var date: Date
    var budget: Double?
    var status: EventStatus
    var participants: [Participant]
    var assignments: [GiftAssignment]?
    var createdAt: Date
    var isCompleted: Bool
    var preset: ExchangePreset
    var rules: AssignmentRules
    var groups: [ParticipantGroup]
    var revealSettings: RevealSettings
    var purchaseDeadline: Date?

    var participantCount: Int {
        participants.count
    }

    var assignedCount: Int {
        assignments?.count ?? 0
    }

    var isReadyForAssignment: Bool {
        participants.filter { $0.isActive }.count >= 2 && assignments == nil
    }

    var isFullyAssigned: Bool {
        guard let assignments else { return false }
        return assignments.count == participants.filter { $0.isActive }.count
    }

    var unpurchasedCount: Int {
        assignments?.filter { !$0.isGiftPurchased }.count ?? 0
    }

    var daysUntilEvent: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).day ?? 0
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        date: Date,
        budget: Double? = nil,
        status: EventStatus = .planning,
        participants: [Participant] = [],
        assignments: [GiftAssignment]? = nil,
        createdAt: Date = Date(),
        isCompleted: Bool = false,
        preset: ExchangePreset = .custom,
        rules: AssignmentRules = AssignmentRules(),
        groups: [ParticipantGroup] = [],
        revealSettings: RevealSettings = RevealSettings(),
        purchaseDeadline: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.date = date
        self.budget = budget
        self.status = status
        self.participants = participants
        self.assignments = assignments
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.preset = preset
        self.rules = rules
        self.groups = groups
        self.revealSettings = revealSettings
        self.purchaseDeadline = purchaseDeadline
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, date, budget, status, participants
        case assignments, createdAt, isCompleted, preset, rules, groups
        case revealSettings, purchaseDeadline
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        date = try c.decode(Date.self, forKey: .date)
        budget = try c.decodeIfPresent(Double.self, forKey: .budget)
        status = try c.decode(EventStatus.self, forKey: .status)
        participants = try c.decode([Participant].self, forKey: .participants)
        assignments = try c.decodeIfPresent([GiftAssignment].self, forKey: .assignments)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        isCompleted = try c.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        preset = try c.decodeIfPresent(ExchangePreset.self, forKey: .preset) ?? .custom
        rules = try c.decodeIfPresent(AssignmentRules.self, forKey: .rules) ?? AssignmentRules()
        groups = try c.decodeIfPresent([ParticipantGroup].self, forKey: .groups) ?? []
        revealSettings = try c.decodeIfPresent(RevealSettings.self, forKey: .revealSettings) ?? RevealSettings()
        purchaseDeadline = try c.decodeIfPresent(Date.self, forKey: .purchaseDeadline)
    }
}
