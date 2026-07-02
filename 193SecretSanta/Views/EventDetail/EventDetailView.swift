import SwiftUI

struct EventDetailView: View {
    @StateObject private var viewModel: EventDetailViewModel
    @State private var selectedParticipant: Participant?

    init(viewModel: EventDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    eventHeader
                    OrganizerDashboardView(
                        stats: viewModel.stats,
                        preset: viewModel.event.preset,
                        unpurchasedCount: viewModel.event.unpurchasedCount
                    )

                    HStack(spacing: 10) {
                        MetricCell(value: "\(viewModel.stats.activeParticipants)", label: "People", icon: "person.2.fill", color: .appAccent)
                        MetricCell(value: "\(viewModel.stats.assignedCount)", label: "Assigned", icon: "arrow.triangle.swap", color: .appAccentSecondary)
                        MetricCell(value: "\(viewModel.stats.revealedCount)", label: "Revealed", icon: "eye.fill", color: Color(hex: "6bcb77"))
                    }
                    .padding(.horizontal)

                    ParticipantListView(
                        participants: viewModel.event.participants,
                        groups: viewModel.event.groups,
                        onSelect: { selectedParticipant = $0 },
                        onWishList: { viewModel.goToWishList(participant: $0) },
                        onHints: { viewModel.goToHints(participant: $0) },
                        onAdd: viewModel.addParticipant
                    )

                    AssignmentView(
                        canGenerate: viewModel.canGenerateAssignments,
                        hasAssignments: viewModel.event.assignments != nil && !(viewModel.event.assignments?.isEmpty ?? true),
                        isCompleted: viewModel.event.isCompleted,
                        onGenerate: viewModel.generateAssignments,
                        onViewResults: viewModel.goToAssignmentResult,
                        onComplete: viewModel.completeEvent,
                        onRules: viewModel.goToRules,
                        onExport: viewModel.goToExport,
                        onDelete: { viewModel.showDeleteAlert = true }
                    )
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: viewModel.event.name)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: viewModel.goBack)
            }
        }
        .alert("Delete Event?", isPresented: $viewModel.showDeleteAlert) {
            Button("Delete", role: .destructive, action: viewModel.deleteEvent)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showAssignmentError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.assignmentErrorMessage)
        }
        .sheet(item: $selectedParticipant) { participant in
            ParticipantDetailSheet(
                participant: participant,
                onEdit: {
                    viewModel.editParticipant(participant)
                    selectedParticipant = nil
                },
                onWishList: {
                    viewModel.goToWishList(participant: participant)
                    selectedParticipant = nil
                },
                onHints: {
                    viewModel.goToHints(participant: participant)
                    selectedParticipant = nil
                },
                onDismiss: { selectedParticipant = nil }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .onAppear { viewModel.loadEvent() }
    }

    private var eventHeader: some View {
        AppCard(accent: .appAccent) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Text(viewModel.event.preset.icon)
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.event.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appTextPrimary)
                        Text(viewModel.event.preset.displayName)
                            .font(.caption)
                            .foregroundColor(.appAccent)
                    }
                    Spacer()
                    StatusBadgeView(status: viewModel.event.status)
                }

                if let description = viewModel.event.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }

                HStack(spacing: 16) {
                    InfoChip(icon: "calendar", text: viewModel.event.date.formattedEventDate())
                    if let budget = viewModel.event.budget, budget > 0 {
                        InfoChip(icon: "dollarsign.circle", text: budget.formattedCurrency())
                    }
                    if let deadline = viewModel.event.purchaseDeadline {
                        InfoChip(icon: "clock", text: deadline.formattedEventDate())
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ParticipantDetailSheet: View {
    let participant: Participant
    let onEdit: () -> Void
    let onWishList: () -> Void
    let onHints: () -> Void
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            AvatarView(name: participant.name, size: 64)

            Text(participant.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)

            HStack(spacing: 24) {
                statBubble("\(participant.wishItems.count)", label: "Wishes", icon: "gift.fill")
                statBubble("\(participant.santaHints.count)", label: "Hints", icon: "lightbulb.fill")
            }

            VStack(spacing: 10) {
                sheetAction("Wishes", icon: "gift.fill", color: .appAccent, action: { dismiss(); onWishList() })
                sheetAction("Santa Hints", icon: "lightbulb.fill", color: .appAccentSecondary, action: { dismiss(); onHints() })
                sheetAction("Edit Profile", icon: "pencil", color: .appTextSecondary, action: { dismiss(); onEdit() }, secondary: true)
            }
            .padding(.horizontal)

            Button(action: { dismiss(); onDismiss() }) {
                Text("Close")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(24)
        .background(
            ZStack {
                Color.appBackground
                LinearGradient(
                    colors: [Color.appAccent.opacity(0.06), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
    }

    private func statBubble(_ value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.appAccent)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
        }
    }

    private func sheetAction(_ title: String, icon: String, color: Color, action: @escaping () -> Void, secondary: Bool = false) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .font(.subheadline)
            .foregroundColor(secondary ? .appTextPrimary : .appBackground)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background {
                if secondary {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .fill(Color.appSurface)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous).stroke(AppGradients.borderShine, lineWidth: 1))
                } else {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .fill(color)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.18), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        )
                }
            }
        }
    }
}
