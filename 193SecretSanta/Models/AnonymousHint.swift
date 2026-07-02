import Foundation

struct AnonymousHint: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

enum HintLimits {
    static let maxHintsPerParticipant = 3
    static let maxHintLength = 120
}
