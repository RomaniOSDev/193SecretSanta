import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            AppScreen {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.sectionSpacing) {
                        HomeHeroBanner(
                            nextEvent: viewModel.dashboard.nextEvent,
                            daysUntil: viewModel.dashboard.daysUntilNext,
                            onCreate: { viewModel.goToEventForm() },
                            onOpenNext: viewModel.openNextEvent
                        )
                        .padding(.horizontal)

                        HomeWidgetGrid(
                            dashboard: viewModel.dashboard,
                            totalEvents: viewModel.totalEvents,
                            totalParticipants: viewModel.totalParticipants,
                            activeCount: viewModel.activeEvents.count
                        )
                        .padding(.horizontal)

                        if viewModel.dashboard.totalUnpurchased > 0 {
                            HomeAttentionBanner(
                                pendingGifts: viewModel.dashboard.totalUnpurchased,
                                eventsCount: viewModel.dashboard.eventsWithPendingGifts
                            )
                            .padding(.horizontal)
                        }

                        if viewModel.hasActiveEvents {
                            upcomingSection
                        } else if !viewModel.hasEvents {
                            HomeEmptyState(onCreate: { viewModel.goToEventForm() })
                                .padding(.horizontal)
                        }

                        HomePresetShortcuts(onSelect: { preset in
                            viewModel.goToEventForm(preset: preset)
                        })
                        .padding(.horizontal)

                        HomeQuickActions(
                            onCreate: { viewModel.goToEventForm() },
                            onAllEvents: viewModel.goToEventList,
                            onSettings: viewModel.goToSettings
                        )
                        .padding(.horizontal)

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 8)
                    .padding(.bottom)
                }
            }
            .coordinatorDestinations(coordinator: coordinator)
        }
        .preferredColorScheme(.dark)
        .onAppear { viewModel.loadData() }
        .onChange(of: coordinator.path.count) { _, _ in viewModel.loadData() }
    }

    private var upcomingSection: some View {
        VStack(spacing: AppTheme.itemSpacing) {
            SectionHeader(
                title: "Upcoming Events",
                subtitle: "\(viewModel.activeEvents.count) active · \(viewModel.dashboard.upcomingThisMonth) this month",
                actionTitle: viewModel.activeEvents.count > 3 ? "See All" : nil,
                action: viewModel.activeEvents.count > 3 ? { viewModel.goToEventList() } : nil
            )
            .padding(.horizontal)

            ForEach(viewModel.activeEvents.prefix(3)) { event in
                EventCardView(event: event) {
                    viewModel.goToEventDetail(event: event)
                }
                .padding(.horizontal)
            }
        }
    }
}
