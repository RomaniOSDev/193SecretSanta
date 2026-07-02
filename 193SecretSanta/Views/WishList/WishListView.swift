import SwiftUI

struct WishListView: View {
    @StateObject private var viewModel: WishListViewModel
    @State private var showAddWish = false
    @State private var newWishTitle = ""
    @State private var newWishDescription = ""
    @State private var newWishPrice = ""
    @State private var newWishLink = ""
    @State private var newWishPriority: WishPriority = .medium

    init(viewModel: WishListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            VStack(spacing: AppTheme.itemSpacing) {
                AppCard(accent: .appAccent) {
                    HStack(spacing: 14) {
                        AvatarView(name: viewModel.participant.name, size: 48)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.participant.name)
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)
                            Text("Wish List")
                                .font(.caption)
                                .foregroundColor(.appTextSecondary)
                        }
                        Spacer()
                        VStack {
                            Text("\(viewModel.participant.wishItems.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.appAccent)
                            Text("items")
                                .font(.caption2)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: { showAddWish = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Wish")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        ZStack {
                            Capsule().fill(AppGradients.accent)
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                        }
                    )
                    .compositingGroup()
                    .shadow(color: Color.appAccent.opacity(0.35), radius: 10, y: 4)
                }
                .padding(.horizontal)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.participant.wishItems) { wish in
                            WishCell(
                                wish: wish,
                                onToggle: { viewModel.togglePurchased(wish) },
                                onDelete: { viewModel.deleteWish(wish) }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .overlay {
                    if viewModel.participant.wishItems.isEmpty {
                        EmptyStateView(
                            icon: "🎁",
                            title: "No Wishes Yet",
                            message: "Add gift ideas to help your Secret Santa",
                            buttonTitle: "Add Wish",
                            action: { showAddWish = true }
                        )
                    }
                }
            }
            .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: "Wish List")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: viewModel.goBack)
            }
        }
        .sheet(isPresented: $showAddWish) {
            AddWishSheet(
                title: $newWishTitle,
                description: $newWishDescription,
                price: $newWishPrice,
                link: $newWishLink,
                priority: $newWishPriority,
                onSave: {
                    viewModel.addWish(
                        title: newWishTitle,
                        description: newWishDescription,
                        price: Double(newWishPrice) ?? 0,
                        priority: newWishPriority,
                        link: newWishLink
                    )
                    resetWishForm()
                    showAddWish = false
                },
                onCancel: {
                    resetWishForm()
                    showAddWish = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear { viewModel.reloadData() }
    }

    private func resetWishForm() {
        newWishTitle = ""
        newWishDescription = ""
        newWishPrice = ""
        newWishLink = ""
        newWishPriority = .medium
    }
}

struct AddWishSheet: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var price: String
    @Binding var link: String
    @Binding var priority: WishPriority

    let onSave: () -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Wish")
                .font(.headline)
                .foregroundColor(.appTextPrimary)

            AppTextField(placeholder: "Title *", text: $title, icon: "gift.fill")
            AppTextField(placeholder: "Link (optional)", text: $link, icon: "link")
            AppTextField(placeholder: "Price ($)", text: $price, icon: "dollarsign.circle", keyboard: .decimalPad)

            TextEditor(text: $description)
                .frame(height: 60)
                .foregroundColor(.appTextPrimary)
                .scrollContentBackground(.hidden)
                .padding(12)
                .appSurface(.inset, cornerRadius: AppTheme.smallRadius)

            Picker("Priority", selection: $priority) {
                ForEach(WishPriority.allCases, id: \.self) { p in
                    Text("\(p.icon) \(p.displayName)").tag(p)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                AppSecondaryButton(title: "Cancel", action: { onCancel(); dismiss() })
                AppPrimaryButton(title: "Add", icon: "plus", isEnabled: isFormValid, action: onSave)
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color.appBackground
                LinearGradient(
                    colors: [Color.appAccent.opacity(0.05), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
    }
}
