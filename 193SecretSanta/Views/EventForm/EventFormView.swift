import SwiftUI

struct EventFormView: View {
    @StateObject private var viewModel: EventFormViewModel

    init(viewModel: EventFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    FormSection("Exchange Format", icon: "🎯") {
                        VStack(spacing: 8) {
                            ForEach(ExchangePreset.allCases, id: \.self) { preset in
                                PresetCell(
                                    preset: preset,
                                    isSelected: viewModel.preset == preset,
                                    action: { viewModel.applyPreset(preset) }
                                )
                            }
                        }
                    }

                    FormSection("Details", icon: "✏️") {
                        VStack(spacing: 10) {
                            AppTextField(placeholder: "Event name *", text: $viewModel.name, icon: "textformat")

                            TextEditor(text: $viewModel.description)
                                .frame(minHeight: 80)
                                .foregroundColor(.appTextPrimary)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .appSurface(.inset, cornerRadius: AppTheme.smallRadius)

                            AppTextField(placeholder: "Budget ($)", text: $viewModel.budget, icon: "dollarsign.circle", keyboard: .decimalPad)
                        }
                    }

                    FormSection("Schedule", icon: "📅") {
                        DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .tint(.appAccent)
                            .padding(8)
                            .appSurface(.inset, cornerRadius: AppTheme.smallRadius)
                    }

                    FormSection("Purchase Deadline", icon: "⏰") {
                        Toggle(isOn: $viewModel.hasPurchaseDeadline) {
                            Text("Set purchase deadline")
                                .foregroundColor(.appTextPrimary)
                        }
                        .tint(.appAccent)
                        if viewModel.hasPurchaseDeadline {
                            DatePicker("", selection: $viewModel.purchaseDeadline, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .tint(.appAccent)
                        }
                    }

                    FormSection("Reveal Experience", icon: "🎭") {
                        VStack(spacing: 12) {
                            Picker("Mode", selection: $viewModel.revealMode) {
                                ForEach(RevealMode.allCases, id: \.self) { mode in
                                    Text("\(mode.icon) \(mode.displayName)").tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)

                            Toggle("Reveal only on event day", isOn: $viewModel.onlyOnEventDay)
                                .tint(.appAccent)
                                .foregroundColor(.appTextPrimary)

                            AppTextField(placeholder: "Passcode (optional)", text: $viewModel.passcode, icon: "lock.fill")
                        }
                    }

                    if viewModel.isEditing {
                        FormSection("Status") {
                            Picker("Status", selection: $viewModel.status) {
                                ForEach(EventStatus.allCases, id: \.self) { status in
                                    Text("\(status.icon) \(status.displayName)").tag(status)
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(.appTextPrimary)
                        }
                    }

                    AppPrimaryButton(
                        title: viewModel.isEditing ? "Save Changes" : "Create Event",
                        icon: "checkmark.circle.fill",
                        isEnabled: viewModel.isFormValid,
                        action: viewModel.saveEvent
                    )
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: viewModel.isEditing ? "Edit Event" : "New Event")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", action: viewModel.cancel).foregroundColor(.appAccent)
            }
        }
    }
}
