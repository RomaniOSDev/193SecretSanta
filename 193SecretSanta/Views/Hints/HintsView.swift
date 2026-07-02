import SwiftUI

struct HintsView: View {
    @StateObject private var viewModel: HintsViewModel

    init(viewModel: HintsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            VStack(spacing: AppTheme.itemSpacing) {
                AppCard(accent: .appAccentSecondary) {
                    VStack(spacing: 8) {
                        Text("💡")
                            .font(.largeTitle)
                        Text("Anonymous Hints")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        Text("Help your Secret Santa without revealing your identity")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                        TagView(
                            text: "\(viewModel.participant.santaHints.count)/\(HintLimits.maxHintsPerParticipant) hints for \(viewModel.participant.name)",
                            color: .appAccentSecondary
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                HStack(spacing: 10) {
                    AppTextField(
                        placeholder: "e.g. Size M, loves tea, no candles...",
                        text: $viewModel.newHintText,
                        icon: "lightbulb.fill"
                    )
                    Button(action: viewModel.addHint) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.canAddHint ? .appAccent : .gray)
                    }
                    .disabled(!viewModel.canAddHint)
                }
                .padding(.horizontal)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.participant.santaHints) { hint in
                            HintCell(hint: hint) {
                                viewModel.deleteHint(hint)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .overlay {
                    if viewModel.participant.santaHints.isEmpty {
                        EmptyStateView(
                            icon: "💡",
                            title: "No Hints Yet",
                            message: "Add up to 3 anonymous hints",
                            buttonTitle: "Add Hint",
                            action: {}
                        )
                    }
                }
            }
            .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: "Santa Hints")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: viewModel.goBack)
            }
        }
        .alert("Hint Limit", isPresented: $viewModel.showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can add up to \(HintLimits.maxHintsPerParticipant) hints.")
        }
        .onAppear { viewModel.reload() }
    }
}
