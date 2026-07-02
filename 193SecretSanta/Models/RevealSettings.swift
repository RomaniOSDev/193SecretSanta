import Foundation

enum RevealMode: String, Codable, CaseIterable, Hashable {
    case standard
    case envelope
    case scratchCard

    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .envelope: return "Envelope"
        case .scratchCard: return "Scratch Card"
        }
    }

    var icon: String {
        switch self {
        case .standard: return "🎁"
        case .envelope: return "✉️"
        case .scratchCard: return "🎫"
        }
    }
}

struct RevealSettings: Codable, Hashable {
    var mode: RevealMode
    var onlyOnEventDay: Bool
    var passcode: String?

    init(mode: RevealMode = .standard, onlyOnEventDay: Bool = false, passcode: String? = nil) {
        self.mode = mode
        self.onlyOnEventDay = onlyOnEventDay
        self.passcode = passcode
    }

    func canReveal(eventDate: Date, now: Date = Date()) -> Bool {
        guard onlyOnEventDay else { return true }
        return Calendar.current.isDate(now, inSameDayAs: eventDate) || now >= eventDate
    }

    func verifyPasscode(_ input: String) -> Bool {
        guard let passcode, !passcode.isEmpty else { return true }
        return input == passcode
    }
}
