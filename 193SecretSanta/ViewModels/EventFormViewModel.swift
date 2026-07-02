import Combine
import SwiftUI

final class EventFormViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var date = Date()
    @Published var budget = ""
    @Published var status: EventStatus = .planning
    @Published var preset: ExchangePreset = .custom
    @Published var hasPurchaseDeadline = false
    @Published var purchaseDeadline = Date()
    @Published var revealMode: RevealMode = .standard
    @Published var onlyOnEventDay = false
    @Published var passcode = ""

    private let storageService: StorageServiceProtocol
    private let coordinator: AppCoordinator
    private let editingEvent: Event?

    var isEditing: Bool { editingEvent != nil }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        event: Event? = nil,
        initialPreset: ExchangePreset? = nil,
        storageService: StorageServiceProtocol,
        coordinator: AppCoordinator
    ) {
        self.editingEvent = event
        self.storageService = storageService
        self.coordinator = coordinator

        if let event {
            self.name = event.name
            self.description = event.description ?? ""
            self.date = event.date
            self.budget = event.budget.map { String(format: "%.0f", $0) } ?? ""
            self.status = event.status
            self.preset = event.preset
            self.hasPurchaseDeadline = event.purchaseDeadline != nil
            self.purchaseDeadline = event.purchaseDeadline ?? Date()
            self.revealMode = event.revealSettings.mode
            self.onlyOnEventDay = event.revealSettings.onlyOnEventDay
            self.passcode = event.revealSettings.passcode ?? ""
        } else if let initialPreset {
            self.preset = initialPreset
            applyPreset(initialPreset)
        }
    }

    func applyPreset(_ preset: ExchangePreset) {
        self.preset = preset
        if !isEditing {
            if let defaultBudget = preset.defaultBudget {
                budget = String(format: "%.0f", defaultBudget)
            }
            revealMode = preset.defaultRevealSettings().mode
            onlyOnEventDay = preset.defaultRevealSettings().onlyOnEventDay
            if let days = preset.defaultPurchaseDeadlineDays {
                hasPurchaseDeadline = true
                purchaseDeadline = Calendar.current.date(byAdding: .day, value: -days, to: date) ?? date
            }
        }
    }

    func saveEvent() {
        guard isFormValid else { return }

        let budgetValue = Double(budget.trimmingCharacters(in: .whitespacesAndNewlines))
        let budgetOptional = (budgetValue ?? 0) > 0 ? budgetValue : nil
        let revealSettings = RevealSettings(
            mode: revealMode,
            onlyOnEventDay: onlyOnEventDay,
            passcode: passcode.isEmpty ? nil : passcode
        )

        if isEditing, let event = editingEvent {
            var updated = event
            updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.description = description.isEmpty ? nil : description
            updated.date = date
            updated.budget = budgetOptional
            updated.status = status
            updated.preset = preset
            updated.revealSettings = revealSettings
            updated.purchaseDeadline = hasPurchaseDeadline ? purchaseDeadline : nil
            storageService.update(updated, forKey: StorageKeys.events)
            NotificationService.shared.scheduleNotifications(for: updated)
        } else {
            var newEvent = Event(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.isEmpty ? nil : description,
                date: date,
                budget: budgetOptional,
                preset: preset,
                rules: preset.defaultRules(),
                groups: preset.defaultGroups(),
                revealSettings: revealSettings,
                purchaseDeadline: hasPurchaseDeadline ? purchaseDeadline : nil
            )
            if hasPurchaseDeadline, newEvent.purchaseDeadline == nil,
               let days = preset.defaultPurchaseDeadlineDays {
                newEvent.purchaseDeadline = Calendar.current.date(byAdding: .day, value: -days, to: date)
            }
            storageService.append(newEvent, forKey: StorageKeys.events)
            NotificationService.shared.scheduleNotifications(for: newEvent)
        }

        coordinator.pop()
    }

    func cancel() {
        coordinator.pop()
    }
}
