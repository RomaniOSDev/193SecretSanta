import SwiftUI

struct ParticipantListView: View {
    let participants: [Participant]
    let groups: [ParticipantGroup]
    let onSelect: (Participant) -> Void
    let onWishList: (Participant) -> Void
    let onHints: (Participant) -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.itemSpacing) {
            SectionHeader(
                title: "Participants",
                subtitle: participants.isEmpty ? "Add at least 2 people" : "\(participants.count) total",
                actionTitle: "Add",
                action: onAdd
            )
            .padding(.horizontal)

            if participants.isEmpty {
                AppCard {
                    HStack {
                        IconBadge(icon: "person.badge.plus", color: .appAccent)
                        Text("Tap Add to invite your first participants")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(participants) { participant in
                        ParticipantCell(
                            participant: participant,
                            groupName: groups.first { $0.id == participant.groupId }?.name,
                            groupColor: groupColor(for: participant),
                            onTap: { onSelect(participant) },
                            onWishList: { onWishList(participant) },
                            onHints: { onHints(participant) }
                        )
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    private func groupColor(for participant: Participant) -> Color {
        guard let group = groups.first(where: { $0.id == participant.groupId }) else {
            return .appAccent
        }
        return Color(hex: group.colorHex)
    }
}
