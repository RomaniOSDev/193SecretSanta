import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(icon)
                .font(.system(size: 44))
                .frame(width: 92, height: 92)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface, Color.appSurface.opacity(0.55)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(Circle().stroke(AppGradients.borderShine, lineWidth: 1))
                )
                .accentGlow(color: .appAccent)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: action) {
                Text(buttonTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appBackground)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(AppGradients.accent)
                            .overlay(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.2), Color.clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            )
                    )
                    .compositingGroup()
                    .shadow(color: Color.appAccent.opacity(0.35), radius: 10, y: 4)
            }
        }
        .padding(32)
    }
}
