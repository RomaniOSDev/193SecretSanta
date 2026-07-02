import SwiftUI

/// Static background — rasterized once via drawingGroup to avoid re-compositing while scrolling.
struct GradientBackground: View {
    var body: some View {
        ZStack {
            Color.appBackground

            LinearGradient(
                colors: [
                    Color.appAccent.opacity(0.07),
                    Color.clear,
                    Color(hex: "6bcb77").opacity(0.04)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            RadialGradient(
                colors: [Color.appAccentSecondary.opacity(0.06), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
        .drawingGroup(opaque: false)
    }
}

struct AppBackground: View {
    var body: some View {
        GradientBackground()
    }
}

struct HeroHeader: View {
    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 52))
                .frame(width: 96, height: 96)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface, Color.appSurface.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(Circle().stroke(AppGradients.borderShine, lineWidth: 1))
                )
                .accentGlow(color: .appAccent)

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.appTextPrimary, .appTextPrimary.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }
}
