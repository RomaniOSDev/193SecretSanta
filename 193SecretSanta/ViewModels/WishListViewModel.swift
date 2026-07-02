import Combine
import SwiftUI

final class WishListViewModel: ObservableObject {
    @Published var participant: Participant
    @Published var event: Event

    private let storageService: StorageServiceProtocol
    private let coordinator: AppCoordinator

    init(
        participant: Participant,
        event: Event,
        storageService: StorageServiceProtocol,
        coordinator: AppCoordinator
    ) {
        self.participant = participant
        self.event = event
        self.storageService = storageService
        self.coordinator = coordinator
        reloadData()
    }

    func reloadData() {
        let events: [Event] = storageService.load(forKey: StorageKeys.events)
        if let updatedEvent = events.first(where: { $0.id == event.id }),
           let updatedParticipant = updatedEvent.participants.first(where: { $0.id == participant.id }) {
            event = updatedEvent
            participant = updatedParticipant
        }
    }

    func addWish(title: String, description: String, price: Double, priority: WishPriority, link: String = "") {
        let wish = WishItem(
            id: UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description,
            link: link.isEmpty ? nil : link,
            price: price > 0 ? price : nil,
            isPurchased: false,
            priority: priority
        )

        var updatedEvent = event
        if let index = updatedEvent.participants.firstIndex(where: { $0.id == participant.id }) {
            updatedEvent.participants[index].wishItems.append(wish)
            storageService.update(updatedEvent, forKey: StorageKeys.events)
            event = updatedEvent
            participant = updatedEvent.participants[index]
        }
    }

    func togglePurchased(_ wish: WishItem) {
        var updatedEvent = event
        guard let pIndex = updatedEvent.participants.firstIndex(where: { $0.id == participant.id }),
              let wIndex = updatedEvent.participants[pIndex].wishItems.firstIndex(where: { $0.id == wish.id }) else {
            return
        }
        updatedEvent.participants[pIndex].wishItems[wIndex].isPurchased.toggle()
        storageService.update(updatedEvent, forKey: StorageKeys.events)
        event = updatedEvent
        participant = updatedEvent.participants[pIndex]
    }

    func deleteWish(_ wish: WishItem) {
        var updatedEvent = event
        guard let pIndex = updatedEvent.participants.firstIndex(where: { $0.id == participant.id }) else { return }
        updatedEvent.participants[pIndex].wishItems.removeAll { $0.id == wish.id }
        storageService.update(updatedEvent, forKey: StorageKeys.events)
        event = updatedEvent
        participant = updatedEvent.participants[pIndex]
    }

    func goBack() {
        coordinator.pop()
    }
}
