import SwiftUI

struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let imageName: String?
    let emoji: String
    let systemIcon: String
    let title: String
    let subtitle: String
    let features: [OnboardingFeature]
    let accent: Color

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "home_hero_banner",
            emoji: "🎁",
            systemIcon: "gift.fill",
            title: "Plan Your Exchange",
            subtitle: "Organize secret gift swaps for friends, family, or coworkers in minutes.",
            features: [
                OnboardingFeature(icon: "calendar.badge.plus", text: "Create events with dates & budgets"),
                OnboardingFeature(icon: "person.2.fill", text: "Add participants and wish lists"),
                OnboardingFeature(icon: "sparkles", text: "Pick a preset: Office, Family & more")
            ],
            accent: .appAccent
        ),
        OnboardingPage(
            id: 1,
            imageName: nil,
            emoji: "🔀",
            systemIcon: "shuffle",
            title: "Smart Assignments",
            subtitle: "Fair matching with rules that keep surprises secret and stress-free.",
            features: [
                OnboardingFeature(icon: "hand.raised.slash.fill", text: "Exclusions and group restrictions"),
                OnboardingFeature(icon: "clock.arrow.circlepath", text: "Avoid repeat pairs from past events"),
                OnboardingFeature(icon: "slider.horizontal.3", text: "Fine-tune rules before you draw names")
            ],
            accent: .appAccentSecondary
        ),
        OnboardingPage(
            id: 2,
            imageName: "home_empty_state",
            emoji: "✨",
            systemIcon: "theatermasks.fill",
            title: "Reveal the Magic",
            subtitle: "Make unwrapping assignments a moment everyone remembers.",
            features: [
                OnboardingFeature(icon: "envelope.open.fill", text: "Envelope & scratch-card reveals"),
                OnboardingFeature(icon: "lightbulb.fill", text: "Anonymous Santa hints"),
                OnboardingFeature(icon: "square.and.arrow.up", text: "Export, share & QR transfer")
            ],
            accent: Color(hex: "6bcb77")
        )
    ]
}

struct OnboardingFeature: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let text: String
}
