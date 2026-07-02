import Foundation

final class OnboardingService {
    static let shared = OnboardingService()

    private let completedKey = "has_completed_onboarding"

    private init() {}

    var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }

    func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: completedKey)
    }
}
