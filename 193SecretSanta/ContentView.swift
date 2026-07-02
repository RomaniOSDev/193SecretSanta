import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator: AppCoordinator
    @StateObject private var homeViewModel: HomeViewModel
    @State private var hasCompletedOnboarding = OnboardingService.shared.hasCompletedOnboarding

    init() {
        let coordinator = AppCoordinator()
        _coordinator = StateObject(wrappedValue: coordinator)
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(
            storageService: coordinator.storageService,
            coordinator: coordinator
        ))
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                HomeView(viewModel: homeViewModel, coordinator: coordinator)
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
