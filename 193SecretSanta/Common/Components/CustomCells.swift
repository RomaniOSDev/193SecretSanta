import SwiftUI

// MARK: - Event Card

struct EventCardView: View {
    let event: Event
    let onTap: () -> Void

    private var daysLeft: Int { max(0, event.daysUntilEvent) }
    private var purchaseProgress: (current: Int, total: Int) {
        let total = event.assignments?.count ?? 0
        let current = event.assignments?.filter { $0.isGiftPurchased }.count ?? 0
        return (current, total)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent.opacity(0.28), Color.appSurface.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
                            )
                        Text(event.preset.icon)
                            .font(.title2)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.name)
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(event.preset.displayName)
                            .font(.caption)
                            .foregroundColor(.appAccent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .trailing, spacing: 6) {
                        StatusBadgeView(status: event.status)
                        CountdownBadge(days: daysLeft)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        InfoChip(icon: "person.2.fill", text: "\(event.participants.count)")
                        InfoChip(icon: "calendar", text: event.date.formattedEventDate())
                        if let budget = event.budget, budget > 0 {
                            InfoChip(icon: "dollarsign.circle", text: budget.formattedCurrency())
                        }
                    }
                }

                if purchaseProgress.total > 0 {
                    ProgressChip(
                        current: purchaseProgress.current,
                        total: purchaseProgress.total,
                        label: "Gifts purchased"
                    )
                }
            }
            .padding(AppTheme.cardPadding)
            .appSurface(.list, accent: .appAccent.opacity(0.35))
        }
        .buttonStyle(.plain)
    }
}

struct CountdownBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock.fill")
                .font(.system(size: 9))
            Text(days == 0 ? "Today" : "\(days)d")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(days <= 3 ? Color(hex: "ff8a65") : .appAccentSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.appBackground.opacity(0.65), Color.appBackground.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(Capsule().stroke(days <= 3 ? Color(hex: "ff8a65").opacity(0.35) : Color.appAccentSecondary.opacity(0.25), lineWidth: 1))
        )
    }
}

struct InfoChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .foregroundColor(.appTextSecondary)
    }
}

// MARK: - Participant Cell

struct ParticipantCell: View {
    let participant: Participant
    var groupName: String? = nil
    var groupColor: Color = .appAccent
    let onTap: () -> Void
    var onWishList: (() -> Void)? = nil
    var onHints: (() -> Void)? = nil

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                AvatarView(name: participant.name, color: groupColor)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(participant.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appTextPrimary)
                        if !participant.isActive {
                            Text("Inactive")
                                .font(.caption2)
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.red.opacity(0.15)))
                        }
                    }

                    HStack(spacing: 8) {
                        if let groupName {
                            TagView(text: groupName, color: groupColor)
                        }
                        if !participant.wishItems.isEmpty {
                            TagView(text: "\(participant.wishItems.count) wishes", icon: "gift.fill", color: .appAccent)
                        }
                        if !participant.santaHints.isEmpty {
                            TagView(text: "\(participant.santaHints.count) hints", icon: "lightbulb.fill", color: .appAccentSecondary)
                        }
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    if let onHints {
                        CellActionButton(icon: "lightbulb.fill", color: .appAccentSecondary, action: onHints)
                    }
                    if let onWishList {
                        CellActionButton(icon: "gift.fill", color: .appAccent, action: onWishList)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.appTextSecondary.opacity(0.5))
                }
            }
            .padding(14)
            .appSurface(.list, accent: groupColor.opacity(0.25))
        }
        .buttonStyle(.plain)
    }
}

struct CellActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .padding(8)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.18), color.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
    }
}

struct TagView: View {
    let text: String
    var icon: String? = nil
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 8))
            }
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(Capsule().stroke(color.opacity(0.22), lineWidth: 0.5))
        )
    }
}

// MARK: - Wish Cell

struct WishCell: View {
    let wish: WishItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(wish.isPurchased ? Color(hex: "6bcb77") : Color.appTextSecondary.opacity(0.4), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if wish.isPurchased {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundColor(Color(hex: "6bcb77"))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(wish.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appTextPrimary)
                    .strikethrough(wish.isPurchased, color: .appTextSecondary)

                if let description = wish.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    if let price = wish.price, price > 0 {
                        TagView(text: price.formattedCurrency(), icon: "dollarsign.circle", color: .appAccent)
                    }
                    WishPriorityBadge(priority: wish.priority)
                    if let link = wish.link, let url = URL(string: link) {
                        Link(destination: url) {
                            TagView(text: "Link", icon: "link", color: .appAccentSecondary)
                        }
                    }
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
                    .padding(8)
                    .background(Circle().fill(Color.red.opacity(0.1)))
            }
        }
        .padding(14)
        .appSurface(.list, accent: wish.isPurchased ? Color(hex: "6bcb77").opacity(0.35) : .clear)
        .opacity(wish.isPurchased ? 0.75 : 1)
    }
}

// MARK: - Hint Cell

struct HintCell: View {
    let hint: AnonymousHint
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appAccentSecondary.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text("💡")
                    .font(.body)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(hint.text)
                    .font(.subheadline)
                    .foregroundColor(.appTextPrimary)
                Text("Anonymous hint")
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.appTextSecondary)
                    .padding(8)
                    .background(Circle().fill(Color.appBackground.opacity(0.5)))
            }
        }
        .padding(14)
        .appSurface(.list, accent: .appAccentSecondary.opacity(0.35))
    }
}

// MARK: - Preset Cell

struct PresetCell: View {
    let preset: ExchangePreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.appAccent.opacity(0.2) : Color.appBackground.opacity(0.4))
                        .frame(width: 48, height: 48)
                    Text(preset.icon)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(preset.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextPrimary)
                    Text(preset.subtitle)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.appAccent : Color.appTextSecondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(Color.appAccent)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(14)
            .appSurface(.list, accent: isSelected ? .appAccent : .clear)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Settings Cell

struct SettingsCell: View {
    let icon: String
    let title: String
    var value: String? = nil
    var color: Color = .appAccent
    var destructive: Bool = false
    let action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) { rowContent }
            } else {
                rowContent
            }
        }
        .buttonStyle(.plain)
    }

    private var rowContent: some View {
        HStack(spacing: 14) {
            IconBadge(icon: icon, color: destructive ? .red : color)
            Text(title)
                .font(.subheadline)
                .foregroundColor(destructive ? .red : .appTextPrimary)
            Spacer()
            if let value {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appAccent)
            }
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(14)
    }
}

// MARK: - Rule Cell

struct RuleCell: View {
    let title: String
    var subtitle: String? = nil
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red.opacity(0.7))
                .font(.caption)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.appTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.6))
            }
        }
        .padding(12)
        .appSurface(.inset, cornerRadius: AppTheme.smallRadius)
    }
}
