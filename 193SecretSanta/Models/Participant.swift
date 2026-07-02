import Foundation

struct Participant: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var email: String?
    var phone: String?
    var notes: String?
    var wishItems: [WishItem]
    var isActive: Bool
    var addedAt: Date
    var groupId: UUID?
    var santaHints: [AnonymousHint]

    init(
        id: UUID = UUID(),
        name: String,
        email: String? = nil,
        phone: String? = nil,
        notes: String? = nil,
        wishItems: [WishItem] = [],
        isActive: Bool = true,
        addedAt: Date = Date(),
        groupId: UUID? = nil,
        santaHints: [AnonymousHint] = []
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.notes = notes
        self.wishItems = wishItems
        self.isActive = isActive
        self.addedAt = addedAt
        self.groupId = groupId
        self.santaHints = santaHints
    }

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, notes, wishItems, isActive, addedAt, groupId, santaHints
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        phone = try c.decodeIfPresent(String.self, forKey: .phone)
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
        wishItems = try c.decodeIfPresent([WishItem].self, forKey: .wishItems) ?? []
        isActive = try c.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        addedAt = try c.decodeIfPresent(Date.self, forKey: .addedAt) ?? Date()
        groupId = try c.decodeIfPresent(UUID.self, forKey: .groupId)
        santaHints = try c.decodeIfPresent([AnonymousHint].self, forKey: .santaHints) ?? []
    }
}
