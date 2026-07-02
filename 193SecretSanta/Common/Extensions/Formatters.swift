import Foundation

extension Date {
    func formattedEventDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: self)
    }
}

extension Double {
    func formattedCurrency() -> String {
        if self == 0 { return "" }
        return String(format: "$%.0f", self)
    }
}
