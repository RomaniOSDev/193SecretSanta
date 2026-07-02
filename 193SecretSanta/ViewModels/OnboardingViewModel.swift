import Combine
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0

    let pages = OnboardingPage.allPages
    private let onComplete: () -> Void

    var isLastPage: Bool {
        currentPage >= pages.count - 1
    }

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    func next() {
        if isLastPage {
            finish()
        } else {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentPage += 1
            }
        }
    }

    func skip() {
        finish()
    }

    func finish() {
        OnboardingService.shared.markCompleted()
        onComplete()
    }
}
