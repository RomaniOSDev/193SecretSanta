import Foundation

struct WishItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var link: String?
    var price: Double?
    var isPurchased: Bool
    var priority: WishPriority
}

enum WishPriority: String, CaseIterable, Codable {
    case high
    case medium
    case low

    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }

    var icon: String {
        switch self {
        case .high: return "🔥"
        case .medium: return "⭐"
        case .low: return "💤"
        }
    }

    var colorHex: String {
        switch self {
        case .high: return "AccentPrimary"
        case .medium: return "AccentSecondary"
        case .low: return "TextSecondary"
        }
    }
}
