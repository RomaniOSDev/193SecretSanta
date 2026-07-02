import Combine
import SwiftUI

final class EventRulesViewModel: ObservableObject {
    @Published var event: Event
    @Published var selectedGiverId: UUID?
    @Published var selectedReceiverId: UUID?
    @Published var exclusionLabel = ""
    @Published var forbiddenReason = ""
    @Published var newGroupName = ""

    private let storageService: StorageServiceProtocol
    private let coordinator: AppCoordinator

    var participants: [Participant] { event.participants.filter { $0.isActive } }

    init(event: Event, storageService: StorageServiceProtocol, coordinator: AppCoordinator) {
        self.event = event
        self.storageService = storageService
        self.coordinator = coordinator
        reload()
    }

    func reload() {
        let events: [Event] = storageService.load(forKey: StorageKeys.events)
        if let updated = events.first(where: { $0.id == event.id }) {
            event = updated
        }
    }

    func save() {
        storageService.update(event, forKey: StorageKeys.events)
        NotificationService.shared.scheduleNotifications(for: event)
    }

    func toggleAvoidRepeat() {
        event.rules.avoidRepeatPairs.toggle()
        save()
    }

    func toggleRestrictGroups() {
        event.rules.restrictToGroups.toggle()
        save()
    }

    func addExclusion() {
        guard let a = selectedGiverId, let b = selectedReceiverId, a != b else { return }
        let pair = ExclusionPair(
            participantIdA: a,
            participantIdB: b,
            label: exclusionLabel.isEmpty ? nil : exclusionLabel
        )
        guard !event.rules.exclusionPairs.contains(where: {
            $0.participantIdA == pair.participantIdA && $0.participantIdB == pair.participantIdB ||
            $0.participantIdA == pair.participantIdB && $0.participantIdB == pair.participantIdA
        }) else { return }
        event.rules.exclusionPairs.append(pair)
        exclusionLabel = ""
        selectedGiverId = nil
        selectedReceiverId = nil
        save()
    }

    func removeExclusion(_ pair: ExclusionPair) {
        event.rules.exclusionPairs.removeAll { $0.id == pair.id }
        save()
    }

    func addForbidden() {
        guard let giver = selectedGiverId, let receiver = selectedReceiverId, giver != receiver else { return }
        let pair = ForbiddenPair(giverId: giver, receiverId: receiver, reason: forbiddenReason.isEmpty ? nil : forbiddenReason)
        event.rules.forbiddenPairs.append(pair)
        forbiddenReason = ""
        selectedGiverId = nil
        selectedReceiverId = nil
        save()
    }

    func removeForbidden(_ pair: ForbiddenPair) {
        event.rules.forbiddenPairs.removeAll { $0.id == pair.id }
        save()
    }

    func addGroup() {
        let name = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        event.groups.append(ParticipantGroup(name: name))
        newGroupName = ""
        save()
    }

    func removeGroup(_ group: ParticipantGroup) {
        event.groups.removeAll { $0.id == group.id }
        for i in event.participants.indices where event.participants[i].groupId == group.id {
            event.participants[i].groupId = nil
        }
        save()
    }

    func participantName(_ id: UUID) -> String {
        event.participants.first { $0.id == id }?.name ?? "Unknown"
    }

    func goBack() {
        coordinator.pop()
    }
}
