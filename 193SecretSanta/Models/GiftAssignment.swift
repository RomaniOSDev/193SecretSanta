import Foundation

struct GiftAssignment: Identifiable, Codable, Hashable {
    let id: UUID
    let giverId: UUID
    let receiverId: UUID
    var isRevealed: Bool
    var revealDate: Date?
    var giftIdea: String?
    var isGiftPurchased: Bool
    var giverName: String?
    var receiverName: String?
}
