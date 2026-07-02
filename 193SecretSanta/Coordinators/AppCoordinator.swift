import Combine
import SwiftUI

struct EventListDestination: Hashable {}
struct EventFormDestination: Hashable {
    let event: Event?
    var preset: ExchangePreset? = nil
}
struct EventDetailDestination: Hashable {
    let event: Event
}
struct ParticipantFormDestination: Hashable {
    let event: Event
    let participant: Participant?
}
struct WishListDestination: Hashable {
    let participant: Participant
    let event: Event
}
struct AssignmentResultDestination: Hashable {
    let event: Event
}
struct SettingsDestination: Hashable {}
struct EventRulesDestination: Hashable {
    let event: Event
}

struct ExportDestination: Hashable {
    let event: Event
}

struct HintsDestination: Hashable {
    let participant: Participant
    let event: Event
}

final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    let storageService: StorageServiceProtocol
    let secretSantaEngine: SecretSantaEngine
    let pairHistoryService: PairHistoryService

    init(
        storageService: StorageServiceProtocol = UserDefaultsStorageService(),
        secretSantaEngine: SecretSantaEngine = SecretSantaEngine()
    ) {
        self.storageService = storageService
        self.secretSantaEngine = secretSantaEngine
        self.pairHistoryService = PairHistoryService(storageService: storageService)
    }

    func navigateToEventList() { path.append(EventListDestination()) }
    func navigateToEventForm(event: Event? = nil, preset: ExchangePreset? = nil) {
        path.append(EventFormDestination(event: event, preset: preset))
    }
    func navigateToEventDetail(event: Event) { path.append(EventDetailDestination(event: event)) }
    func navigateToParticipantForm(event: Event, participant: Participant? = nil) {
        path.append(ParticipantFormDestination(event: event, participant: participant))
    }
    func navigateToWishList(participant: Participant, event: Event) {
        path.append(WishListDestination(participant: participant, event: event))
    }
    func navigateToHints(participant: Participant, event: Event) {
        path.append(HintsDestination(participant: participant, event: event))
    }
    func navigateToAssignmentResult(event: Event) { path.append(AssignmentResultDestination(event: event)) }
    func navigateToEventRules(event: Event) { path.append(EventRulesDestination(event: event)) }
    func navigateToExport(event: Event) { path.append(ExportDestination(event: event)) }
    func navigateToSettings() { path.append(SettingsDestination()) }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

struct CoordinatorDestinations: ViewModifier {
    @ObservedObject var coordinator: AppCoordinator

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: EventListDestination.self) { _ in
                EventListView(viewModel: EventListViewModel(
                    storageService: coordinator.storageService,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: EventFormDestination.self) { dest in
                EventFormView(viewModel: EventFormViewModel(
                    event: dest.event,
                    initialPreset: dest.preset,
                    storageService: coordinator.storageService,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: EventDetailDestination.self) { dest in
                EventDetailView(viewModel: EventDetailViewModel(
                    event: dest.event,
                    storageService: coordinator.storageService,
                    secretSantaEngine: coordinator.secretSantaEngine,
                    pairHistoryService: coordinator.pairHistoryService,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: ParticipantFormDestination.self) { dest in
                ParticipantFormView(viewModel: ParticipantFormViewModel(
                    event: dest.event,
                    participant: dest.participant,
                    storageService: coordinator.storageService,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: WishListDestination.self) { dest in
                WishListView(viewModel: WishListViewModel(
                    participant: dest.participant,
                    event: dest.event,
                    storageService: coordinator.storageService,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: HintsDestination.self) { dest in
                HintsView(viewModel: HintsViewModel(
                    participant: dest.participant,
                    event: dest.event,
                    storageService: coordinator.storageService,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: AssignmentResultDestination.self) { dest in
                AssignmentResultView(viewModel: AssignmentResultViewModel(
                    event: dest.event,
                    storageService: coordinator.storageService,
                    secretSantaEngine: coordinator.secretSantaEngine,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: EventRulesDestination.self) { dest in
                EventRulesView(viewModel: EventRulesViewModel(
                    event: dest.event,
                    storageService: coordinator.storageService,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: ExportDestination.self) { dest in
                ExportView(viewModel: ExportViewModel(
                    event: dest.event,
                    storageService: coordinator.storageService,
                    coordinator: coordinator
                ))
            }
            .navigationDestination(for: SettingsDestination.self) { _ in
                SettingsView(viewModel: SettingsViewModel(
                    storageService: coordinator.storageService,
                    coordinator: coordinator
                ))
            }
    }
}

extension View {
    func coordinatorDestinations(coordinator: AppCoordinator) -> some View {
        modifier(CoordinatorDestinations(coordinator: coordinator))
    }
}
