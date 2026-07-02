import SwiftUI

struct AssignmentView: View {
    let canGenerate: Bool
    let hasAssignments: Bool
    let isCompleted: Bool
    let onGenerate: () -> Void
    let onViewResults: () -> Void
    let onComplete: () -> Void
    let onRules: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.itemSpacing) {
            SectionHeader(title: "Actions", subtitle: "Manage your exchange")
                .padding(.horizontal)

            VStack(spacing: 10) {
                ActionTile(icon: "slider.horizontal.3", title: "Assignment Rules", subtitle: "Exclusions, groups, history", accent: .appAccentSecondary, action: onRules)
                ActionTile(icon: "square.and.arrow.up", title: "Export & Import", subtitle: "PDF, QR, share summary", accent: .appAccent, action: onExport)
            }
            .padding(.horizontal)

            if canGenerate {
                AppPrimaryButton(title: "Assign Gifts", icon: "shuffle", action: onGenerate)
                    .padding(.horizontal)
            }

            if hasAssignments {
                AppSecondaryButton(title: "View Assignments & Reveal", icon: "theatermasks.fill", action: onViewResults)
                    .padding(.horizontal)
            }

            if !isCompleted && hasAssignments {
                Button(action: onComplete) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Complete Event")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.appTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .appSurface(.list, accent: Color(hex: "6bcb77").opacity(0.5))
                }
                .padding(.horizontal)
            }

            Button(action: onDelete) {
                Text("Delete Event")
                    .font(.subheadline)
                    .foregroundColor(.red.opacity(0.8))
            }
            .padding(.top, 4)
        }
    }
}
