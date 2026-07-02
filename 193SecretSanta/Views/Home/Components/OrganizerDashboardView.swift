import SwiftUI

struct OrganizerDashboardView: View {
    let stats: EventStats
    let preset: ExchangePreset
    let unpurchasedCount: Int

    var body: some View {
        AppCard(accent: .appAccent) {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Organizer Dashboard")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        Text("Track your group's progress")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    Spacer()
                    TagView(text: "\(preset.icon) \(preset.displayName)", color: .appAccent)
                }

                HStack(spacing: 10) {
                    DashboardTile(value: stats.missingWishes, label: "No Wishes", icon: "gift", color: .orange)
                    DashboardTile(value: stats.missingHints, label: "No Hints", icon: "lightbulb", color: .appAccentSecondary)
                    DashboardTile(value: unpurchasedCount, label: "Unbought", icon: "bag", color: .red)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DashboardTile: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(value > 0 ? color : Color(hex: "6bcb77"))
            Text(label)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .appSurface(.inset, cornerRadius: AppTheme.smallRadius)
    }
}
