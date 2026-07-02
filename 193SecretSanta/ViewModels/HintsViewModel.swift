import Combine
import SwiftUI

final class HintsViewModel: ObservableObject {
    @Published var participant: Participant
    @Published var event: Event
    @Published var newHintText = ""
    @Published var showLimitAlert = false

    private let storageService: StorageServiceProtocol
    private let coordinator: AppCoordinator

    var canAddHint: Bool {
        participant.santaHints.count < HintLimits.maxHintsPerParticipant &&
        !newHintText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(participant: Participant, event: Event, storageService: StorageServiceProtocol, coordinator: AppCoordinator) {
        self.participant = participant
        self.event = event
        self.storageService = storageService
        self.coordinator = coordinator
        reload()
    }

    func reload() {
        let events: [Event] = storageService.load(forKey: StorageKeys.events)
        if let updatedEvent = events.first(where: { $0.id == event.id }),
           let updatedParticipant = updatedEvent.participants.first(where: { $0.id == participant.id }) {
            event = updatedEvent
            participant = updatedParticipant
        }
    }

    func addHint() {
        guard canAddHint else {
            showLimitAlert = true
            return
        }
        let text = String(newHintText.trimmingCharacters(in: .whitespacesAndNewlines).prefix(HintLimits.maxHintLength))
        guard !text.isEmpty else { return }

        var updatedEvent = event
        guard let index = updatedEvent.participants.firstIndex(where: { $0.id == participant.id }) else { return }
        updatedEvent.participants[index].santaHints.append(AnonymousHint(text: text))
        storageService.update(updatedEvent, forKey: StorageKeys.events)
        newHintText = ""
        reload()
    }

    func deleteHint(_ hint: AnonymousHint) {
        var updatedEvent = event
        guard let pIndex = updatedEvent.participants.firstIndex(where: { $0.id == participant.id }) else { return }
        updatedEvent.participants[pIndex].santaHints.removeAll { $0.id == hint.id }
        storageService.update(updatedEvent, forKey: StorageKeys.events)
        reload()
    }

    func goBack() {
        coordinator.pop()
    }
}
