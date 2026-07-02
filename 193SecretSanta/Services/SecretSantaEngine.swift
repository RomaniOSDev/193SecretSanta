import Foundation

struct EventStats {
    let totalParticipants: Int
    let activeParticipants: Int
    let assignedCount: Int
    let revealedCount: Int
    let purchasedCount: Int
    let missingWishes: Int
    let missingHints: Int
}

final class SecretSantaEngine {

    private let maxAttempts = 500

    func generateAssignments(
        participants: [Participant],
        rules: AssignmentRules,
        groups: [ParticipantGroup],
        history: [HistoricalPair]
    ) -> Result<[GiftAssignment], AssignmentError> {
        let active = participants.filter { $0.isActive }
        guard active.count >= 2 else { return .failure(.notEnoughParticipants) }

        if rules.restrictToGroups {
            return generateWithGroups(active: active, rules: rules, groups: groups, history: history)
        }

        if let pairs = solve(active: active, rules: rules, history: history) {
            return .success(makeAssignments(from: pairs))
        }
        return .failure(.constraintsUnsatisfiable)
    }

    private func generateWithGroups(
        active: [Participant],
        rules: AssignmentRules,
        groups: [ParticipantGroup],
        history: [HistoricalPair]
    ) -> Result<[GiftAssignment], AssignmentError> {
        var allPairs: [(Participant, Participant)] = []

        let groupedIds = Set(groups.map(\.id))
        let ungrouped = active.filter { p in
            guard let gid = p.groupId else { return true }
            return !groupedIds.contains(gid)
        }
        if !ungrouped.isEmpty {
            return .failure(.ungroupedParticipants)
        }

        for group in groups {
            let members = active.filter { $0.groupId == group.id }
            guard members.count >= 2 else {
                if members.isEmpty { continue }
                return .failure(.groupTooSmall(group.name))
            }
            guard let pairs = solve(active: members, rules: rules, history: history) else {
                return .failure(.constraintsUnsatisfiable)
            }
            allPairs.append(contentsOf: pairs)
        }

        guard !allPairs.isEmpty else { return .failure(.notEnoughParticipants) }
        return .success(makeAssignments(from: allPairs))
    }

    private func solve(
        active: [Participant],
        rules: AssignmentRules,
        history: [HistoricalPair]
    ) -> [(Participant, Participant)]? {
        for _ in 0..<maxAttempts {
            if let result = backtrack(
                givers: active.shuffled(),
                available: active,
                current: [],
                rules: rules,
                history: history
            ) {
                return result
            }
        }
        return backtrack(
            givers: active,
            available: active,
            current: [],
            rules: rules,
            history: history
        )
    }

    private func backtrack(
        givers: [Participant],
        available: [Participant],
        current: [(Participant, Participant)],
        rules: AssignmentRules,
        history: [HistoricalPair]
    ) -> [(Participant, Participant)]? {
        guard let giver = givers.first else { return current }
        let remaining = Array(givers.dropFirst())

        for receiver in available.shuffled() {
            if isValid(giver: giver, receiver: receiver, rules: rules, history: history) {
                let nextAvailable = available.filter { $0.id != receiver.id }
                if let result = backtrack(
                    givers: remaining,
                    available: nextAvailable,
                    current: current + [(giver, receiver)],
                    rules: rules,
                    history: history
                ) {
                    return result
                }
            }
        }
        return nil
    }

    private func isValid(
        giver: Participant,
        receiver: Participant,
        rules: AssignmentRules,
        history: [HistoricalPair]
    ) -> Bool {
        guard giver.id != receiver.id else { return false }

        for pair in rules.exclusionPairs where pair.blocks(giverId: giver.id, receiverId: receiver.id) {
            return false
        }

        for pair in rules.forbiddenPairs where pair.giverId == giver.id && pair.receiverId == receiver.id {
            return false
        }

        if rules.avoidRepeatPairs {
            let repeated = history.contains { $0.giverId == giver.id && $0.receiverId == receiver.id }
            if repeated { return false }
        }

        return true
    }

    private func makeAssignments(from pairs: [(Participant, Participant)]) -> [GiftAssignment] {
        pairs.map { giver, receiver in
            GiftAssignment(
                id: UUID(),
                giverId: giver.id,
                receiverId: receiver.id,
                isRevealed: false,
                revealDate: nil,
                giftIdea: nil,
                isGiftPurchased: false,
                giverName: giver.name,
                receiverName: receiver.name
            )
        }
    }

    func getAssignmentForParticipant(participantId: UUID, assignments: [GiftAssignment]) -> GiftAssignment? {
        assignments.first { $0.giverId == participantId }
    }

    func getReceiverForParticipant(
        participantId: UUID,
        assignments: [GiftAssignment],
        participants: [Participant]
    ) -> Participant? {
        guard let assignment = assignments.first(where: { $0.giverId == participantId }) else {
            return nil
        }
        return participants.first { $0.id == assignment.receiverId }
    }

    func revealAssignment(assignmentId: UUID, assignments: [GiftAssignment]) -> [GiftAssignment] {
        var updated = assignments
        if let index = updated.firstIndex(where: { $0.id == assignmentId }) {
            updated[index].isRevealed = true
            updated[index].revealDate = Date()
        }
        return updated
    }

    func markGiftPurchased(assignmentId: UUID, assignments: [GiftAssignment]) -> [GiftAssignment] {
        var updated = assignments
        if let index = updated.firstIndex(where: { $0.id == assignmentId }) {
            updated[index].isGiftPurchased = true
        }
        return updated
    }

    func addGiftIdea(assignmentId: UUID, idea: String, assignments: [GiftAssignment]) -> [GiftAssignment] {
        var updated = assignments
        if let index = updated.firstIndex(where: { $0.id == assignmentId }) {
            updated[index].giftIdea = idea
        }
        return updated
    }

    func getStats(for event: Event) -> EventStats {
        let total = event.participants.count
        let active = event.participants.filter { $0.isActive }.count
        let assigned = event.assignments?.count ?? 0
        let revealed = event.assignments?.filter { $0.isRevealed }.count ?? 0
        let purchased = event.assignments?.filter { $0.isGiftPurchased }.count ?? 0
        let missingWishes = event.participants.filter { $0.isActive && $0.wishItems.isEmpty }.count
        let missingHints = event.participants.filter { $0.isActive && $0.santaHints.isEmpty }.count

        return EventStats(
            totalParticipants: total,
            activeParticipants: active,
            assignedCount: assigned,
            revealedCount: revealed,
            purchasedCount: purchased,
            missingWishes: missingWishes,
            missingHints: missingHints
        )
    }
}
