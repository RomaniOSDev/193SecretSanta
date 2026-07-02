import Combine
import SwiftUI

final class EventDetailViewModel: ObservableObject {
    @Published var event: Event
    @Published var stats: EventStats
    @Published var showDeleteAlert = false
    @Published var showAssignmentError = false
    @Published var assignmentErrorMessage = ""

    private let storageService: StorageServiceProtocol
    private let secretSantaEngine: SecretSantaEngine
    private let pairHistoryService: PairHistoryService
    private let coordinator: AppCoordinator

    var canGenerateAssignments: Bool {
        event.participants.filter { $0.isActive }.count >= 2 && event.assignments == nil
    }

    init(
        event: Event,
        storageService: StorageServiceProtocol,
        secretSantaEngine: SecretSantaEngine,
        pairHistoryService: PairHistoryService,
        coordinator: AppCoordinator
    ) {
        self.event = event
        self.storageService = storageService
        self.secretSantaEngine = secretSantaEngine
        self.pairHistoryService = pairHistoryService
        self.coordinator = coordinator
        self.stats = secretSantaEngine.getStats(for: event)
    }

    func loadEvent() {
        let events: [Event] = storageService.load(forKey: StorageKeys.events)
        if let updated = events.first(where: { $0.id == event.id }) {
            event = updated
            stats = secretSantaEngine.getStats(for: event)
        }
    }

    func generateAssignments() {
        guard canGenerateAssignments else { return }

        let activeParticipants = event.participants.filter { $0.isActive }
        let history = event.rules.avoidRepeatPairs ? pairHistoryService.loadHistory() : []

        switch secretSantaEngine.generateAssignments(
            participants: activeParticipants,
            rules: event.rules,
            groups: event.groups,
            history: history
        ) {
        case .success(let assignments):
            var updatedEvent = event
            updatedEvent.assignments = assignments
            updatedEvent.status = .assigned
            storageService.update(updatedEvent, forKey: StorageKeys.events)
            event = updatedEvent
            stats = secretSantaEngine.getStats(for: event)
            NotificationService.shared.scheduleNotifications(for: event)
        case .failure(let error):
            assignmentErrorMessage = error.localizedDescription
            showAssignmentError = true
        }
    }

    func updateParticipant(_ participant: Participant) {
        var updatedEvent = event
        if let index = updatedEvent.participants.firstIndex(where: { $0.id == participant.id }) {
            updatedEvent.participants[index] = participant
            storageService.update(updatedEvent, forKey: StorageKeys.events)
            event = updatedEvent
            stats = secretSantaEngine.getStats(for: event)
        }
    }

    func completeEvent() {
        var updated = event
        updated.isCompleted = true
        updated.status = .completed
        storageService.update(updated, forKey: StorageKeys.events)
        pairHistoryService.savePairs(from: updated)
        NotificationService.shared.cancelNotifications(for: event.id)
        event = updated
        stats = secretSantaEngine.getStats(for: event)
    }

    func deleteEvent() {
        var events: [Event] = storageService.load(forKey: StorageKeys.events)
        events.removeAll { $0.id == event.id }
        storageService.save(events, forKey: StorageKeys.events)
        NotificationService.shared.cancelNotifications(for: event.id)
        coordinator.pop()
    }

    func addParticipant() { coordinator.navigateToParticipantForm(event: event) }
    func editParticipant(_ participant: Participant) { coordinator.navigateToParticipantForm(event: event, participant: participant) }
    func goToWishList(participant: Participant) { coordinator.navigateToWishList(participant: participant, event: event) }
    func goToHints(participant: Participant) { coordinator.navigateToHints(participant: participant, event: event) }
    func goToAssignmentResult() { coordinator.navigateToAssignmentResult(event: event) }
    func goToRules() { coordinator.navigateToEventRules(event: event) }
    func goToExport() { coordinator.navigateToExport(event: event) }
    func goBack() { coordinator.pop() }
}
