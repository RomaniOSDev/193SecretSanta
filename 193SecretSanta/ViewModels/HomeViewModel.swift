import Combine
import SwiftUI

struct HomeDashboardData {
    let nextEvent: Event?
    let daysUntilNext: Int
    let totalUnpurchased: Int
    let totalPurchased: Int
    let totalAssigned: Int
    let purchaseProgress: Double
    let eventsWithPendingGifts: Int
    let upcomingThisMonth: Int

    static let empty = HomeDashboardData(
        nextEvent: nil,
        daysUntilNext: 0,
        totalUnpurchased: 0,
        totalPurchased: 0,
        totalAssigned: 0,
        purchaseProgress: 0,
        eventsWithPendingGifts: 0,
        upcomingThisMonth: 0
    )
}

final class HomeViewModel: ObservableObject {
    @Published var activeEvents: [Event] = []
    @Published var completedEvents: [Event] = []
    @Published var totalEvents: Int = 0
    @Published var totalParticipants: Int = 0
    @Published var dashboard: HomeDashboardData = .empty

    private let storageService: StorageServiceProtocol
    let coordinator: AppCoordinator

    init(storageService: StorageServiceProtocol, coordinator: AppCoordinator) {
        self.storageService = storageService
        self.coordinator = coordinator
        loadData()
    }

    var hasEvents: Bool { totalEvents > 0 }
    var hasActiveEvents: Bool { !activeEvents.isEmpty }

    func loadData() {
        let events: [Event] = storageService.load(forKey: StorageKeys.events)
        activeEvents = events.filter { !$0.isCompleted }.sorted { $0.date < $1.date }
        completedEvents = events.filter { $0.isCompleted }.sorted { $0.date > $1.date }
        totalEvents = events.count
        totalParticipants = events.reduce(0) { $0 + $1.participants.count }
        dashboard = buildDashboard(from: events)
    }

    private func buildDashboard(from events: [Event]) -> HomeDashboardData {
        let active = events.filter { !$0.isCompleted }
        let next = active.sorted { $0.date < $1.date }.first

        var unpurchased = 0
        var purchased = 0
        var assigned = 0
        var pendingEvents = 0

        for event in active {
            guard let assignments = event.assignments else { continue }
            assigned += assignments.count
            let eventUnpurchased = assignments.filter { !$0.isGiftPurchased }.count
            unpurchased += eventUnpurchased
            purchased += assignments.filter { $0.isGiftPurchased }.count
            if eventUnpurchased > 0 { pendingEvents += 1 }
        }

        let progress = assigned > 0 ? Double(purchased) / Double(assigned) : 0
        let calendar = Calendar.current
        let upcomingMonth = active.filter {
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
        }.count

        return HomeDashboardData(
            nextEvent: next,
            daysUntilNext: next.map { max(0, $0.daysUntilEvent) } ?? 0,
            totalUnpurchased: unpurchased,
            totalPurchased: purchased,
            totalAssigned: assigned,
            purchaseProgress: progress,
            eventsWithPendingGifts: pendingEvents,
            upcomingThisMonth: upcomingMonth
        )
    }

    func goToEventList() { coordinator.navigateToEventList() }
    func goToEventForm(preset: ExchangePreset? = nil) { coordinator.navigateToEventForm(preset: preset) }
    func goToEventDetail(event: Event) { coordinator.navigateToEventDetail(event: event) }
    func goToSettings() { coordinator.navigateToSettings() }

    func openNextEvent() {
        if let next = dashboard.nextEvent {
            goToEventDetail(event: next)
        } else {
            goToEventForm()
        }
    }
}
