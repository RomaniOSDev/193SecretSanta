import SwiftUI

enum AppTheme {
    static let cornerRadius: CGFloat = 16
    static let smallRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 12
}

// MARK: - Screen wrapper

struct AppScreen<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            GradientBackground()
            content
        }
    }
}

// MARK: - Card

struct AppCard<Content: View>: View {
    var accent: Color = .clear
    let content: Content

    init(accent: Color = .clear, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.cardPadding)
            .appSurface(.raised, accent: accent == .clear ? .clear : accent)
    }
}

// MARK: - Section

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .fixedSize(horizontal: false, vertical: true)
                }
                SectionDivider()
                    .padding(.top, 2)
            }
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.appAccent)
                }
            }
        }
    }
}

struct FormSection<Content: View>: View {
    let title: String
    var icon: String? = nil
    let content: Content

    init(_ title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                if let icon { Text(icon).font(.caption) }
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextSecondary)
                    .tracking(0.8)
            }
            content
        }
    }
}

// MARK: - Buttons

struct AppPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isEnabled ? .appBackground : .appTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius, style: .continuous)
                        .fill(isEnabled ? AnyShapeStyle(AppGradients.accent) : AnyShapeStyle(Color.gray.opacity(0.35)))
                    if isEnabled {
                        RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.22), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                }
            )
            .compositingGroup()
            .shadow(color: isEnabled ? Color.appAccent.opacity(0.4) : .clear, radius: 12, y: 5)
        }
        .disabled(!isEnabled)
    }
}

struct AppSecondaryButton: View {
    let title: String
    var icon: String? = nil
    var accent: Color = .appAccent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.appTextPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .appSurface(.list, accent: accent)
        }
    }
}

struct ActionTile: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var accent: Color = .appAccent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.22), accent.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(accent.opacity(0.2), lineWidth: 1))
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundColor(accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)
            }
            .padding(14)
            .appSurface(.list, accent: accent.opacity(0.6))
        }
    }
}

// MARK: - Inputs

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(.appTextSecondary)
                    .frame(width: 20)
            }
            TextField(placeholder, text: $text)
                .foregroundColor(.appTextPrimary)
                .keyboardType(keyboard)
                .tint(.appAccent)
        }
        .padding(14)
        .appSurface(.inset, cornerRadius: AppTheme.smallRadius)
    }
}

struct AppSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appAccent)
            TextField(placeholder, text: $text)
                .foregroundColor(.appTextPrimary)
                .tint(.appAccent)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(14)
        .appSurface(.list, accent: .appAccent.opacity(0.35))
    }
}

// MARK: - Stats

struct MetricCell: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(color.opacity(0.2), lineWidth: 0.5))
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .appSurface(.list, accent: color.opacity(0.45))
    }
}

struct ProgressChip: View {
    let current: Int
    let total: Int
    let label: String
    var color: Color = .appAccent

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text("\(current)/\(total)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBackground.opacity(0.5))
                    Capsule()
                        .fill(LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Avatar

struct AvatarView: View {
    let name: String
    var size: CGFloat = 40
    var color: Color = .appAccent

    private var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.8), color.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(initials.isEmpty ? "?" : initials)
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundColor(.appBackground)
        }
        .frame(width: size, height: size)
    }
}

struct IconBadge: View {
    let icon: String
    var color: Color = .appAccent
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.22), color.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .stroke(color.opacity(0.25), lineWidth: 1)
                )
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(color)
        }
    }
}
