import SwiftUI

// MARK: - Hero Banner

struct HomeHeroBanner: View {
    let nextEvent: Event?
    let daysUntil: Int
    let onCreate: () -> Void
    let onOpenNext: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_hero_banner")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.appBackground.opacity(0.15),
                            Color.appBackground.opacity(0.55),
                            Color.appBackground.opacity(0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text("🎄")
                    Text("Gift Exchange")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.appAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.appBackground.opacity(0.6)))
                }

                Text(nextEvent?.name ?? "Start Your Exchange")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)

                if let nextEvent {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(nextEvent.date.formattedEventDate(), systemImage: "calendar")
                        Label(daysUntil == 0 ? "Today!" : "\(daysUntil) days left", systemImage: "clock.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                    Button(action: onOpenNext) {
                        HStack(spacing: 6) {
                            Text("Open Event")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appBackground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.appAccent))
                    }
                    .padding(.top, 4)
                } else {
                    Text("Create your first secret gift swap")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)

                    Button(action: onCreate) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Event")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appBackground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.appAccent))
                    }
                    .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .appSurface(.hero, accent: .appAccent)
    }
}

// MARK: - Widget Grid

struct HomeWidgetGrid: View {
    let dashboard: HomeDashboardData
    let totalEvents: Int
    let totalParticipants: Int
    let activeCount: Int

    var body: some View {
        VStack(spacing: AppTheme.itemSpacing) {
            HStack(alignment: .top, spacing: AppTheme.itemSpacing) {
                CountdownWidget(
                    days: dashboard.daysUntilNext,
                    eventName: dashboard.nextEvent?.name
                )
                .frame(maxWidth: .infinity)

                PurchaseProgressWidget(
                    purchased: dashboard.totalPurchased,
                    total: dashboard.totalAssigned,
                    progress: dashboard.purchaseProgress,
                    unpurchased: dashboard.totalUnpurchased
                )
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: AppTheme.itemSpacing) {
                MiniStatWidget(
                    icon: "calendar.badge.clock",
                    value: "\(totalEvents)",
                    label: "Events",
                    color: .appAccent
                )
                MiniStatWidget(
                    icon: "person.2.fill",
                    value: "\(totalParticipants)",
                    label: "People",
                    color: .appAccentSecondary
                )
                MiniStatWidget(
                    icon: "sparkles",
                    value: "\(activeCount)",
                    label: "Active",
                    color: Color(hex: "6bcb77")
                )
            }
        }
    }
}

struct CountdownWidget: View {
    let days: Int
    let eventName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.appAccent)
                Text("Countdown")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
            }

            Text(days == 0 ? "Today" : "\(days)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.appAccent)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(days == 0 ? "Exchange day!" : "days to go")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
                .lineLimit(1)

            if let eventName {
                Text(eventName)
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .appSurface(.list, accent: .appAccent)
    }
}

struct PurchaseProgressWidget: View {
    let purchased: Int
    let total: Int
    let progress: Double
    let unpurchased: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("widget_gifts_progress")
                .resizable()
                .scaledToFill()
                .opacity(0.35)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "bag.fill")
                        .foregroundColor(.appAccentSecondary)
                    Text("Gifts")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                }

                Text("\(purchased)/\(total)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                CompactProgressBar(progress: progress, color: .appAccentSecondary)

                if unpurchased > 0 {
                    Text("\(unpurchased) to buy")
                        .font(.caption2)
                        .foregroundColor(Color(hex: "ff8a65"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .appSurface(.list, accent: .appAccentSecondary)
    }
}

private struct CompactProgressBar: View {
    let progress: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.appBackground.opacity(0.5))
                Capsule()
                    .fill(LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, geo.size.width * progress))
            }
        }
        .frame(height: 6)
    }
}

struct MiniStatWidget: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .appSurface(.list, accent: color)
    }
}

// MARK: - Quick Actions Row

struct HomeQuickActions: View {
    let onCreate: () -> Void
    let onAllEvents: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            AppPrimaryButton(title: "Create Event", icon: "plus.circle.fill", action: onCreate)

            HStack(spacing: 10) {
                QuickActionChip(icon: "list.bullet.rectangle.fill", title: "All Events", color: .appAccent, action: onAllEvents)
                QuickActionChip(icon: "gearshape.fill", title: "Settings", color: .appAccentSecondary, action: onSettings)
            }
        }
    }
}

struct QuickActionChip: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(.appTextPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .appSurface(.list, accent: color.opacity(0.4))
        }
    }
}

// MARK: - Empty State

struct HomeEmptyState: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image("home_empty_state")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(spacing: 6) {
                Text("No Exchanges Yet")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                Text("Plan a secret gift swap with friends, family, or coworkers")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                featureRow(icon: "shuffle", text: "Smart gift assignment rules")
                featureRow(icon: "theatermasks.fill", text: "Fun reveal experiences")
                featureRow(icon: "lightbulb.fill", text: "Anonymous Santa hints")
            }
            .padding(.vertical, 8)

            AppPrimaryButton(title: "Create First Event", icon: "gift.fill", action: onCreate)
        }
        .padding(20)
        .appSurface(.raised, accent: .appAccent.opacity(0.3))
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            IconBadge(icon: icon, color: .appAccent, size: 28)
            Text(text)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Attention Banner

struct HomeAttentionBanner: View {
    let pendingGifts: Int
    let eventsCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color(hex: "ff8a65"))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(pendingGifts) gifts still to buy")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextPrimary)
                Text("Across \(eventsCount) active exchange\(eventsCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            Spacer()
        }
        .padding(14)
        .appSurface(.list, accent: Color(hex: "ff8a65").opacity(0.5))
    }
}

// MARK: - Preset Shortcuts

struct HomePresetShortcuts: View {
    let onSelect: (ExchangePreset) -> Void

    private let shortcuts: [ExchangePreset] = [.office, .family, .classroom, .whiteElephant]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Quick Start", subtitle: "Pick a format")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(shortcuts, id: \.self) { preset in
                        Button { onSelect(preset) } label: {
                            VStack(spacing: 8) {
                                Text(preset.icon)
                                    .font(.title2)
                                Text(preset.shortDisplayName)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appTextPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.85)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(minWidth: 76, maxWidth: 88)
                            }
                            .frame(width: 92)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 6)
                            .appSurface(.list, accent: .appAccent.opacity(0.25))
                        }
                    }
                }
            }
        }
    }
}
