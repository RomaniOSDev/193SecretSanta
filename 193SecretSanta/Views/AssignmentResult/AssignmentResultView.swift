import SwiftUI

struct AssignmentResultView: View {
    @StateObject private var viewModel: AssignmentResultViewModel

    init(viewModel: AssignmentResultViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    revealInfoBanner

                    SectionHeader(
                        title: "Assignments",
                        subtitle: "\(viewModel.assignments.count) people matched"
                    )
                    .padding(.horizontal)

                    ForEach(viewModel.participants.filter { $0.isActive }) { participant in
                        if let assignment = viewModel.getAssignment(for: participant),
                           let receiver = viewModel.getReceiver(for: participant) {
                            AssignmentRow(
                                giver: participant,
                                receiver: receiver,
                                assignment: assignment,
                                hints: viewModel.hintsForReceiver(receiver),
                                revealSettings: viewModel.revealSettings,
                                eventDate: viewModel.event.date,
                                onReveal: { viewModel.revealAssignment(assignmentId: assignment.id) },
                                onMarkPurchased: { viewModel.markGiftPurchased(assignmentId: assignment.id) },
                                onAddIdea: { viewModel.addGiftIdea(assignmentId: assignment.id, idea: $0) }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: "Assignments")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: viewModel.goBack)
            }
        }
        .onAppear { viewModel.reloadEvent() }
    }

    private var revealInfoBanner: some View {
        AppCard(accent: .appAccentSecondary) {
            HStack(spacing: 14) {
                Text(viewModel.revealSettings.mode.icon)
                    .font(.title)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.revealSettings.mode.displayName) Reveal Mode")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextPrimary)
                    HStack(spacing: 8) {
                        if viewModel.revealSettings.onlyOnEventDay {
                            TagView(text: "Event day only", icon: "lock.fill", color: .orange)
                        }
                        if viewModel.revealSettings.passcode != nil {
                            TagView(text: "Passcode", icon: "key.fill", color: .appAccent)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct AssignmentRow: View {
    let giver: Participant
    let receiver: Participant
    let assignment: GiftAssignment
    let hints: [AnonymousHint]
    let revealSettings: RevealSettings
    let eventDate: Date
    let onReveal: () -> Void
    let onMarkPurchased: () -> Void
    let onAddIdea: (String) -> Void

    @State private var isRevealed = false
    @State private var giftIdea = ""
    @State private var showIdeaField = false
    @State private var passcodeInput = ""
    @State private var isUnlocked = false
    @State private var showPasscodeError = false

    private var revealed: Bool {
        assignment.isRevealed || isRevealed
    }

    var body: some View {
        AppCard(accent: revealed ? Color(hex: "6bcb77") : .appAccent) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    AvatarView(name: giver.name, size: 40)
                    Image(systemName: "arrow.right")
                        .foregroundColor(.appTextSecondary)
                    if revealed {
                        AvatarView(name: receiver.name, size: 40, color: Color(hex: "6bcb77"))
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.appBackground.opacity(0.5))
                                .frame(width: 40, height: 40)
                            Text("?")
                                .font(.headline)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    Spacer()
                    if revealed {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: "6bcb77"))
                    }
                }

                Text(giver.name)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)

                if !revealed {
                    if !revealSettings.canReveal(eventDate: eventDate) {
                        DateLockedView(eventDate: eventDate)
                    } else if revealSettings.passcode != nil && !isUnlocked {
                        PasscodeGateView(
                            passcode: $passcodeInput,
                            onUnlock: attemptUnlock,
                            onCancel: {}
                        )
                    } else {
                        revealExperience
                    }
                } else {
                    revealedContent
                }
            }
        }
        .onAppear { isRevealed = assignment.isRevealed }
        .alert("Wrong Passcode", isPresented: $showPasscodeError) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var revealExperience: some View {
        switch revealSettings.mode {
        case .envelope:
            EnvelopeRevealView(receiverName: receiver.name, onRevealComplete: performReveal)
        case .scratchCard:
            ScratchCardRevealView(receiverName: receiver.name, onRevealComplete: performReveal)
        case .standard:
            AppPrimaryButton(title: "Reveal Match", icon: "eye.fill", action: performReveal)
        }
    }

    @ViewBuilder
    private var revealedContent: some View {
        HStack {
            Text("Giving a gift to")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
            Text(receiver.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.appAccent)
        }

        if !hints.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Anonymous Hints")
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
                ForEach(hints) { hint in
                    HStack(spacing: 6) {
                        Text("💡")
                        Text(hint.text)
                            .font(.caption)
                            .foregroundColor(.appTextPrimary)
                    }
                }
            }
            .padding(10)
            .appSurface(.inset, cornerRadius: AppTheme.smallRadius)
        }

        HStack {
            if assignment.isGiftPurchased {
                TagView(text: "Purchased", icon: "checkmark.circle.fill", color: Color(hex: "6bcb77"))
            } else {
                TagView(text: "Not purchased", icon: "bag", color: .red)
                Spacer()
                Button("Mark Purchased", action: onMarkPurchased)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.appAccent)
            }
        }

        if let idea = assignment.giftIdea {
            TagView(text: idea, icon: "lightbulb.fill", color: .appAccentSecondary)
        }

        if showIdeaField {
            HStack {
                AppTextField(placeholder: "Gift idea...", text: $giftIdea)
                Button("Save") {
                    if !giftIdea.isEmpty {
                        onAddIdea(giftIdea)
                        showIdeaField = false
                    }
                }
                .font(.caption)
                .foregroundColor(.appAccent)
            }
        } else if assignment.giftIdea == nil {
            Button("Add Gift Idea") { showIdeaField = true }
                .font(.caption)
                .foregroundColor(.appAccent)
        }
    }

    private func attemptUnlock() {
        if revealSettings.verifyPasscode(passcodeInput) {
            isUnlocked = true
        } else {
            showPasscodeError = true
        }
    }

    private func performReveal() {
        isRevealed = true
        onReveal()
    }
}
