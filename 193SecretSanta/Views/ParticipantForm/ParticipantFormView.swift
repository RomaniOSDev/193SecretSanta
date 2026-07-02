import SwiftUI

struct ParticipantFormView: View {
    @StateObject private var viewModel: ParticipantFormViewModel

    init(viewModel: ParticipantFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    FormSection("Profile", icon: "👤") {
                        VStack(spacing: 10) {
                            AppTextField(placeholder: "Full name *", text: $viewModel.name, icon: "person.fill")

                            if viewModel.showsContactFields {
                                AppTextField(placeholder: "Email", text: $viewModel.email, icon: "envelope.fill", keyboard: .emailAddress)
                                AppTextField(placeholder: "Phone", text: $viewModel.phone, icon: "phone.fill", keyboard: .phonePad)
                            }

                            if !viewModel.groups.isEmpty {
                                Picker("Group", selection: $viewModel.selectedGroupId) {
                                    Text("No group").tag(UUID?.none)
                                    ForEach(viewModel.groups) { group in
                                        Text("\(group.name)").tag(Optional(group.id))
                                    }
                                }
                                .pickerStyle(.menu)
                                .foregroundColor(.appTextPrimary)
                                .padding(14)
                                .appSurface(.inset, cornerRadius: AppTheme.smallRadius)
                            }

                            TextEditor(text: $viewModel.notes)
                                .frame(minHeight: 80)
                                .foregroundColor(.appTextPrimary)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .appSurface(.inset, cornerRadius: AppTheme.smallRadius)
                        }
                    }

                    AppCard {
                        Toggle(isOn: $viewModel.isActive) {
                            HStack {
                                IconBadge(icon: "person.fill.checkmark", color: .appAccent, size: 28)
                                Text("Active participant")
                                    .foregroundColor(.appTextPrimary)
                            }
                        }
                        .tint(.appAccent)
                    }

                    AppPrimaryButton(
                        title: viewModel.isEditing ? "Save Changes" : "Add Participant",
                        icon: "checkmark.circle.fill",
                        isEnabled: viewModel.isFormValid,
                        action: viewModel.saveParticipant
                    )
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: viewModel.isEditing ? "Edit Participant" : "Add Participant")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", action: viewModel.cancel).foregroundColor(.appAccent)
            }
        }
    }
}
