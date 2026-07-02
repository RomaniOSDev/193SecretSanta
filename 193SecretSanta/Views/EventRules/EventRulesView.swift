import SwiftUI

struct EventRulesView: View {
    @StateObject private var viewModel: EventRulesViewModel

    init(viewModel: EventRulesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    FormSection("Smart Rules", icon: "🧠") {
                        AppCard {
                            VStack(spacing: 14) {
                                ruleToggle(
                                    icon: "arrow.triangle.2.circlepath",
                                    title: "Avoid repeat pairs",
                                    subtitle: "Never repeat giver-receiver from past events",
                                    isOn: viewModel.event.rules.avoidRepeatPairs,
                                    action: viewModel.toggleAvoidRepeat
                                )
                                Divider().background(Color.appBackground)
                                ruleToggle(
                                    icon: "person.3.fill",
                                    title: "Same group only",
                                    subtitle: "Givers and receivers must be in the same group",
                                    isOn: viewModel.event.rules.restrictToGroups,
                                    action: viewModel.toggleRestrictGroups
                                )
                            }
                        }
                    }

                    FormSection("Groups", icon: "👥") {
                        AppCard {
                            VStack(spacing: 10) {
                                ForEach(viewModel.event.groups) { group in
                                    HStack {
                                        Circle().fill(Color(hex: group.colorHex)).frame(width: 10, height: 10)
                                        Text(group.name).foregroundColor(.appTextPrimary)
                                        Spacer()
                                        Button { viewModel.removeGroup(group) } label: {
                                            Image(systemName: "trash").font(.caption).foregroundColor(.red.opacity(0.7))
                                        }
                                    }
                                }
                                HStack(spacing: 10) {
                                    AppTextField(placeholder: "New group name", text: $viewModel.newGroupName, icon: "plus")
                                    Button("Add") { viewModel.addGroup() }
                                        .foregroundColor(.appAccent)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }

                    FormSection("Exclusion Pairs", icon: "🚫") {
                        AppCard {
                            VStack(spacing: 12) {
                                Text("These people cannot give gifts to each other")
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                participantPickers
                                AppTextField(placeholder: "Label (optional)", text: $viewModel.exclusionLabel, icon: "tag")
                                AppSecondaryButton(title: "Add Exclusion", icon: "plus.circle", action: viewModel.addExclusion)

                                ForEach(viewModel.event.rules.exclusionPairs) { pair in
                                    RuleCell(
                                        title: "\(viewModel.participantName(pair.participantIdA)) ↔ \(viewModel.participantName(pair.participantIdB))",
                                        subtitle: pair.label,
                                        onDelete: { viewModel.removeExclusion(pair) }
                                    )
                                }
                            }
                        }
                    }

                    FormSection("Manual Bans", icon: "⛔") {
                        AppCard {
                            VStack(spacing: 12) {
                                Text("One direction: A cannot give to B")
                                    .font(.caption)
                                    .foregroundColor(.appTextSecondary)
                                participantPickers
                                AppTextField(placeholder: "Reason (optional)", text: $viewModel.forbiddenReason, icon: "text.bubble")
                                AppSecondaryButton(title: "Add Ban", icon: "hand.raised.fill", action: viewModel.addForbidden)

                                ForEach(viewModel.event.rules.forbiddenPairs) { pair in
                                    RuleCell(
                                        title: "\(viewModel.participantName(pair.giverId)) → ✕ → \(viewModel.participantName(pair.receiverId))",
                                        subtitle: pair.reason,
                                        onDelete: { viewModel.removeForbidden(pair) }
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: "Assignment Rules")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: viewModel.goBack)
            }
        }
        .onAppear { viewModel.reload() }
    }

    private var participantPickers: some View {
        VStack(spacing: 8) {
            Picker("Person A", selection: $viewModel.selectedGiverId) {
                Text("Select...").tag(UUID?.none)
                ForEach(viewModel.participants) { p in
                    Text(p.name).tag(Optional(p.id))
                }
            }
            Picker("Person B", selection: $viewModel.selectedReceiverId) {
                Text("Select...").tag(UUID?.none)
                ForEach(viewModel.participants) { p in
                    Text(p.name).tag(Optional(p.id))
                }
            }
        }
    }

    private func ruleToggle(icon: String, title: String, subtitle: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        HStack(spacing: 14) {
            IconBadge(icon: icon, color: .appAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appTextPrimary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
            }
            Spacer()
            Toggle("", isOn: Binding(get: { isOn }, set: { _ in action() }))
                .tint(.appAccent)
                .labelsHidden()
        }
    }
}
