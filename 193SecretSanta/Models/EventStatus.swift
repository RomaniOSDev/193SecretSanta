import SwiftUI

enum EventStatus: String, CaseIterable, Codable {
    case planning
    case assigned
    case inProgress
    case completed

    var displayName: String {
        switch self {
        case .planning: return "Planning"
        case .assigned: return "Assigned"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    var icon: String {
        switch self {
        case .planning: return "📝"
        case .assigned: return "🎁"
        case .inProgress: return "🎄"
        case .completed: return "✅"
        }
    }

    var colorHex: String {
        switch self {
        case .planning: return "AccentPrimary"
        case .assigned: return "AccentSecondary"
        case .inProgress: return "ff8a65"
        case .completed: return "6bcb77"
        }
    }
}
