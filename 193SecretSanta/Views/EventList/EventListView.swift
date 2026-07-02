import SwiftUI

struct EventListView: View {
    @StateObject private var viewModel: EventListViewModel

    init(viewModel: EventListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            VStack(spacing: AppTheme.itemSpacing) {
                AppSearchBar(text: $viewModel.searchText, placeholder: "Search events or people...")
                    .padding(.horizontal)

                HStack {
                    FilterChip(
                        title: "Active",
                        isSelected: !viewModel.showCompletedOnly,
                        action: { viewModel.showCompletedOnly = false }
                    )
                    FilterChip(
                        title: "Completed",
                        isSelected: viewModel.showCompletedOnly,
                        action: { viewModel.showCompletedOnly = true }
                    )
                    Spacer()
                    Text("\(viewModel.filteredEvents.count) events")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.horizontal)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: AppTheme.itemSpacing) {
                        ForEach(viewModel.filteredEvents) { event in
                            EventCardView(event: event) {
                                viewModel.goToEventDetail(event)
                            }
                            .padding(.horizontal)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    viewModel.deleteEvent(event)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .overlay {
                    if viewModel.filteredEvents.isEmpty {
                        EmptyStateView(
                            icon: "🎄",
                            title: "No Events",
                            message: viewModel.showCompletedOnly
                                ? "No completed events yet"
                                : "Create your first gift exchange event",
                            buttonTitle: "Create Event",
                            action: viewModel.goToEventForm
                        )
                    }
                }
            }
            .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: "Events")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: viewModel.goBack)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.goToEventForm) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.appAccent)
                }
            }
        }
        .onAppear { viewModel.loadEvents() }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .appBackground : .appTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(AppGradients.accent)
                                .overlay(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.2), Color.clear],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                                .compositingGroup()
                                .shadow(color: Color.appAccent.opacity(0.3), radius: 6, y: 2)
                        } else {
                            Capsule()
                                .fill(Color.appSurface.opacity(0.8))
                                .overlay(Capsule().stroke(AppGradients.borderShine, lineWidth: 1))
                        }
                    }
                )
        }
    }
}

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.appAccent)
        }
    }
}
