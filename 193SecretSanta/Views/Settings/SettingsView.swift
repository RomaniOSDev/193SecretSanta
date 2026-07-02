import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    HeroHeader(
                        emoji: "⚙️",
                        title: "Settings",
                        subtitle: "Preferences & data management"
                    )

                    AppCard {
                        VStack(spacing: 0) {
                            SettingsCell(
                                icon: "calendar.badge.clock",
                                title: "Total Events",
                                value: "\(viewModel.totalEvents)",
                                action: nil
                            )
                            Divider().background(Color.appBackground)
                            HStack {
                                IconBadge(icon: "eye.fill", color: .appAccentSecondary)
                                Toggle(isOn: $viewModel.settings.showCompletedEvents) {
                                    Text("Show completed by default")
                                        .font(.subheadline)
                                        .foregroundColor(.appTextPrimary)
                                }
                                .tint(.appAccent)
                            }
                            .padding(14)
                            .onChange(of: viewModel.settings.showCompletedEvents) { _, _ in
                                viewModel.saveSettings()
                            }
                        }
                    }
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                        SettingsCell(
                            icon: "star.fill",
                            title: "Rate Us",
                            color: Color(hex: "ffd700"),
                            action: viewModel.rateApp
                        )
                        Divider().background(Color.appBackground)
                        SettingsCell(
                            icon: "hand.raised.fill",
                            title: "Privacy",
                            color: .appAccent,
                            action: viewModel.openPrivacyPolicy
                        )
                        Divider().background(Color.appBackground)
                        SettingsCell(
                            icon: "doc.text.fill",
                            title: "Terms",
                            color: .appAccentSecondary,
                            action: viewModel.openTermsOfUse
                        )
                    }
                    .padding(.horizontal)
                    .appSurface(.raised)
                    .padding(.horizontal)

                    VStack(spacing: 10) {
                        SettingsCell(
                            icon: "bell.badge.fill",
                            title: "Enable Notifications",
                            color: .appAccent,
                            action: { NotificationService.shared.requestAuthorization() }
                        )
                        SettingsCell(
                            icon: "trash.fill",
                            title: "Clear All Data",
                            color: .red,
                            destructive: true,
                            action: { viewModel.showClearDataAlert = true }
                        )
                    }
                    .padding(.horizontal)
                    .appSurface(.raised)
                    .padding(.horizontal)

                    AppCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)
                            Text("Smart gift exchange organizer with constraint rules, reveal experiences, anonymous hints, and offline QR transfer.")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                            TagView(text: "Version 1.0", color: .appTextSecondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: "Settings")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: viewModel.goBack)
            }
        }
        .alert("Clear All Data?", isPresented: $viewModel.showClearDataAlert) {
            Button("Clear", role: .destructive, action: viewModel.clearAllData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all events and participants.")
        }
        .alert("Data Cleared", isPresented: $viewModel.showClearSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All events have been removed.")
        }
    }
}
