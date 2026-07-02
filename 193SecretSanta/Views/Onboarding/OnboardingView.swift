import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel

    init(onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(onComplete: onComplete))
    }

    var body: some View {
        AppScreen {
            VStack(spacing: 0) {
                header

                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentPage)

                footer
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Spacer()
            if !viewModel.isLastPage {
                Button("Skip", action: viewModel.skip)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .frame(height: 44)
    }

    private var footer: some View {
        VStack(spacing: 20) {
            OnboardingPageIndicator(
                count: viewModel.pages.count,
                current: viewModel.currentPage
            )

            AppPrimaryButton(
                title: viewModel.isLastPage ? "Get Started" : "Continue",
                icon: viewModel.isLastPage ? "arrow.right.circle.fill" : "chevron.right",
                action: viewModel.next
            )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .padding(.top, 8)
    }
}

struct OnboardingPageIndicator: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == current
                            ? AnyShapeStyle(AppGradients.accent)
                            : AnyShapeStyle(Color.appTextSecondary.opacity(0.25))
                    )
                    .frame(width: index == current ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
