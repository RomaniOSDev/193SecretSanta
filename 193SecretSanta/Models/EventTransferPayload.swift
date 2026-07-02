import Foundation

struct EventTransferPayload: Codable {
    let version: Int
    let event: Event
    let exportedAt: Date

    init(event: Event) {
        self.version = 1
        self.event = event
        self.exportedAt = Date()
    }
}
