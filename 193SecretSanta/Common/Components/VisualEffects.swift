import SwiftUI

// MARK: - Shared gradients (static, no per-frame allocation)

enum AppGradients {
    static let accent = LinearGradient(
        colors: [Color.appAccent, Color.appAccentSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let accentVertical = LinearGradient(
        colors: [Color.appAccent, Color.appAccentSecondary.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surfaceSheen = LinearGradient(
        colors: [Color.white.opacity(0.10), Color.white.opacity(0.02), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let borderShine = LinearGradient(
        colors: [Color.white.opacity(0.14), Color.white.opacity(0.04), Color.white.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let insetFill = LinearGradient(
        colors: [Color.appBackground.opacity(0.75), Color.appBackground.opacity(0.45)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Elevation levels (performance budget)

/// Performance rules:
/// - `.hero` / `.raised` — real shadow, use sparingly (≤5 on screen)
/// - `.list` / `.flat` / `.inset` — border + sheen only, safe in LazyVStack
enum SurfaceElevation {
    case hero
    case raised
    case list
    case flat
    case inset
}

// MARK: - Surface modifier

struct AppSurfaceModifier: ViewModifier {
    let elevation: SurfaceElevation
    var accent: Color = .clear
    var cornerRadius: CGFloat = AppTheme.cornerRadius

    func body(content: Content) -> some View {
        content.background(backgroundShape)
    }

    @ViewBuilder
    private var backgroundShape: some View {
        switch elevation {
        case .hero:
            surfaceShape
                .compositingGroup()
                .shadow(color: .black.opacity(0.35), radius: 14, y: 8)

        case .raised:
            surfaceShape
                .compositingGroup()
                .shadow(color: .black.opacity(0.28), radius: 10, y: 5)

        case .list, .flat, .inset:
            surfaceShape
        }
    }

    private var surfaceShape: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fillColor)
            .overlay(sheenOverlay)
            .overlay(borderOverlay)
    }

    private var fillColor: some ShapeStyle {
        switch elevation {
        case .inset:
            AnyShapeStyle(AppGradients.insetFill)
        default:
            AnyShapeStyle(Color.appSurface)
        }
    }

    @ViewBuilder
    private var sheenOverlay: some View {
        if elevation != .flat {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.surfaceSheen)
                .opacity(elevation == .inset ? 0.35 : 0.55)
        }
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(borderGradient, lineWidth: borderWidth)
    }

    private var borderGradient: LinearGradient {
        if accent != .clear {
            LinearGradient(
                colors: [accent.opacity(0.55), accent.opacity(0.12), Color.white.opacity(0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            AppGradients.borderShine
        }
    }

    private var borderWidth: CGFloat {
        accent != .clear ? 1.2 : 1
    }
}

extension View {
    func appSurface(
        _ elevation: SurfaceElevation = .raised,
        accent: Color = .clear,
        cornerRadius: CGFloat = AppTheme.cornerRadius
    ) -> some View {
        modifier(AppSurfaceModifier(elevation: elevation, accent: accent, cornerRadius: cornerRadius))
    }
}

// MARK: - Accent glow (hero elements only)

struct AccentGlowModifier: ViewModifier {
    var color: Color = .appAccent

    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.28), color.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 48
                        )
                    )
                    .scaleEffect(1.45)
                    .allowsHitTesting(false)
            )
    }
}

extension View {
    func accentGlow(color: Color = .appAccent) -> some View {
        modifier(AccentGlowModifier(color: color))
    }
}

// MARK: - Section divider

struct SectionDivider: View {
    var body: some View {
        LinearGradient(
            colors: [Color.appAccent.opacity(0.5), Color.appAccentSecondary.opacity(0.2), Color.clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .opacity(0.8)
    }
}
