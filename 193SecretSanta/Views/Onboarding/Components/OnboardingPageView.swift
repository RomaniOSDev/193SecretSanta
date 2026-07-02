import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                visual
                    .padding(.top, 8)

                VStack(spacing: 10) {
                    Text(page.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(page.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                VStack(spacing: 10) {
                    ForEach(page.features) { feature in
                        OnboardingFeatureRow(feature: feature, accent: page.accent)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private var visual: some View {
        if let imageName = page.imageName {
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [Color.appBackground.opacity(0.1), Color.appBackground.opacity(0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text(page.emoji)
                    .font(.system(size: 56))
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .appSurface(.hero, accent: page.accent)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [page.accent.opacity(0.22), Color.appSurface.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)

                VStack(spacing: 12) {
                    Image(systemName: page.systemIcon)
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [page.accent, page.accent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(page.emoji)
                        .font(.system(size: 40))
                }
            }
            .appSurface(.hero, accent: page.accent)
        }
    }
}

struct OnboardingFeatureRow: View {
    let feature: OnboardingFeature
    let accent: Color

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(icon: feature.icon, color: accent, size: 36)

            Text(feature.text)
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(14)
        .appSurface(.list, accent: accent.opacity(0.35))
    }
}

#Preview {
    OnboardingPageView(page: OnboardingPage.allPages[0])
        .background(Color.appBackground)
}
