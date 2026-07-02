import Combine
import SwiftUI

final class EventListViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var searchText = ""
    @Published var showCompletedOnly = false

    private let storageService: StorageServiceProtocol
    private let coordinator: AppCoordinator

    var filteredEvents: [Event] {
        var result = events

        if showCompletedOnly {
            result = result.filter { $0.isCompleted }
        } else {
            result = result.filter { !$0.isCompleted }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.participants.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return result.sorted { $0.date < $1.date }
    }

    init(storageService: StorageServiceProtocol, coordinator: AppCoordinator) {
        self.storageService = storageService
        self.coordinator = coordinator
        loadEvents()
    }

    func loadEvents() {
        events = storageService.load(forKey: StorageKeys.events)
    }

    func deleteEvent(_ event: Event) {
        var allEvents = events
        allEvents.removeAll { $0.id == event.id }
        storageService.save(allEvents, forKey: StorageKeys.events)
        loadEvents()
    }

    func goToEventDetail(_ event: Event) {
        coordinator.navigateToEventDetail(event: event)
    }

    func goToEventForm() {
        coordinator.navigateToEventForm()
    }

    func goBack() {
        coordinator.pop()
    }
}
