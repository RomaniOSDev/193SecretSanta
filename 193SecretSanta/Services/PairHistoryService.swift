import Foundation

final class PairHistoryService {
    private let storageService: StorageServiceProtocol

    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
    }

    func loadHistory() -> [HistoricalPair] {
        let store: PairHistoryStore = storageService.loadObject(forKey: StorageKeys.pairHistory) ?? PairHistoryStore()
        return store.pairs
    }

    func savePairs(from event: Event) {
        guard let assignments = event.assignments else { return }
        var store: PairHistoryStore = storageService.loadObject(forKey: StorageKeys.pairHistory) ?? PairHistoryStore()
        let year = Calendar.current.component(.year, from: event.date)

        for assignment in assignments {
            let pair = HistoricalPair(
                giverId: assignment.giverId,
                receiverId: assignment.receiverId,
                eventId: event.id,
                eventName: event.name,
                year: year
            )
            if !store.pairs.contains(where: { $0.giverId == pair.giverId && $0.receiverId == pair.receiverId }) {
                store.pairs.append(pair)
            }
        }
        storageService.saveObject(store, forKey: StorageKeys.pairHistory)
    }
}
