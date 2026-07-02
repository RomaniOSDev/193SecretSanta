import Combine
import SwiftUI

final class ParticipantFormViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var notes = ""
    @Published var isActive = true
    @Published var selectedGroupId: UUID?

    private let storageService: StorageServiceProtocol
    private let coordinator: AppCoordinator
    private var event: Event
    private let editingParticipant: Participant?

    var isEditing: Bool { editingParticipant != nil }
    var groups: [ParticipantGroup] { event.groups }
    var showsContactFields: Bool { event.preset.showsContactFields }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        event: Event,
        participant: Participant? = nil,
        storageService: StorageServiceProtocol,
        coordinator: AppCoordinator
    ) {
        self.event = event
        self.editingParticipant = participant
        self.storageService = storageService
        self.coordinator = coordinator

        if let participant {
            self.name = participant.name
            self.email = participant.email ?? ""
            self.phone = participant.phone ?? ""
            self.notes = participant.notes ?? ""
            self.isActive = participant.isActive
            self.selectedGroupId = participant.groupId
        }
    }

    func saveParticipant() {
        guard isFormValid else { return }
        reloadEvent()

        if isEditing, let participant = editingParticipant {
            var updated = participant
            updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.email = email.isEmpty ? nil : email
            updated.phone = phone.isEmpty ? nil : phone
            updated.notes = notes.isEmpty ? nil : notes
            updated.isActive = isActive
            updated.groupId = selectedGroupId
            if let index = event.participants.firstIndex(where: { $0.id == participant.id }) {
                event.participants[index] = updated
            }
        } else {
            let newParticipant = Participant(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.isEmpty ? nil : email,
                phone: phone.isEmpty ? nil : phone,
                notes: notes.isEmpty ? nil : notes,
                groupId: selectedGroupId
            )
            event.participants.append(newParticipant)
        }

        storageService.update(event, forKey: StorageKeys.events)
        coordinator.pop()
    }

    func cancel() { coordinator.pop() }

    private func reloadEvent() {
        let events: [Event] = storageService.load(forKey: StorageKeys.events)
        if let updated = events.first(where: { $0.id == event.id }) {
            event = updated
        }
    }
}
