import SwiftUI

struct StatusBadgeView: View {
    let status: EventStatus

    var body: some View {
        HStack(spacing: 4) {
            Text(status.icon)
                .font(.caption2)
            Text(status.displayName)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [statusColor.opacity(0.18), statusColor.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(Capsule().stroke(statusColor.opacity(0.35), lineWidth: 1))
        )
        .foregroundColor(statusColor)
    }

    private var statusColor: Color {
        if status.colorHex.hasPrefix("Accent") || status.colorHex.hasPrefix("Text") {
            return Color(status.colorHex)
        }
        return Color(hex: status.colorHex)
    }
}

struct WishPriorityBadge: View {
    let priority: WishPriority

    var body: some View {
        HStack(spacing: 3) {
            Text(priority.icon)
                .font(.caption2)
            Text(priority.displayName)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(priorityColor.opacity(0.12))
        )
        .foregroundColor(priorityColor)
    }

    private var priorityColor: Color {
        Color(priority.colorHex)
    }
}
