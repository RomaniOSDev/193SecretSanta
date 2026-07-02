import Combine
import SwiftUI

final class AssignmentResultViewModel: ObservableObject {
    @Published var event: Event
    @Published var passcodeInput = ""
    @Published var showPasscodeError = false
    @Published var showDateLocked = false

    private let storageService: StorageServiceProtocol
    private let secretSantaEngine: SecretSantaEngine
    private let coordinator: AppCoordinator

    var assignments: [GiftAssignment] { event.assignments ?? [] }
    var participants: [Participant] { event.participants }
    var revealSettings: RevealSettings { event.revealSettings }

    init(
        event: Event,
        storageService: StorageServiceProtocol,
        secretSantaEngine: SecretSantaEngine,
        coordinator: AppCoordinator
    ) {
        self.event = event
        self.storageService = storageService
        self.secretSantaEngine = secretSantaEngine
        self.coordinator = coordinator
        reloadEvent()
    }

    func reloadEvent() {
        let events: [Event] = storageService.load(forKey: StorageKeys.events)
        if let updated = events.first(where: { $0.id == event.id }) {
            event = updated
        }
    }

    func canRevealNow() -> Bool {
        revealSettings.canReveal(eventDate: event.date)
    }

    func verifyPasscode() -> Bool {
        revealSettings.verifyPasscode(passcodeInput)
    }

    func getAssignment(for participant: Participant) -> GiftAssignment? {
        secretSantaEngine.getAssignmentForParticipant(participantId: participant.id, assignments: assignments)
    }

    func getReceiver(for participant: Participant) -> Participant? {
        secretSantaEngine.getReceiverForParticipant(
            participantId: participant.id,
            assignments: assignments,
            participants: participants
        )
    }

    func hintsForReceiver(_ receiver: Participant) -> [AnonymousHint] {
        receiver.santaHints
    }

    func revealAssignment(assignmentId: UUID) {
        let updatedAssignments = secretSantaEngine.revealAssignment(assignmentId: assignmentId, assignments: assignments)
        var updatedEvent = event
        updatedEvent.assignments = updatedAssignments
        storageService.update(updatedEvent, forKey: StorageKeys.events)
        event = updatedEvent
    }

    func markGiftPurchased(assignmentId: UUID) {
        let updatedAssignments = secretSantaEngine.markGiftPurchased(assignmentId: assignmentId, assignments: assignments)
        var updatedEvent = event
        updatedEvent.assignments = updatedAssignments
        storageService.update(updatedEvent, forKey: StorageKeys.events)
        event = updatedEvent
    }

    func addGiftIdea(assignmentId: UUID, idea: String) {
        let updatedAssignments = secretSantaEngine.addGiftIdea(assignmentId: assignmentId, idea: idea, assignments: assignments)
        var updatedEvent = event
        updatedEvent.assignments = updatedAssignments
        storageService.update(updatedEvent, forKey: StorageKeys.events)
        event = updatedEvent
    }

    func goBack() { coordinator.pop() }
}
