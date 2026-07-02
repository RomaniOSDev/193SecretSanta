import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func scheduleNotifications(for event: Event) {
        cancelNotifications(for: event.id)
        guard !event.isCompleted else { return }

        if event.daysUntilEvent == 7 || event.daysUntilEvent > 7 {
            schedule(
                id: "\(event.id)-7days",
                title: "Gift Exchange in 7 Days",
                body: "\"\(event.name)\" is coming up. Check your wish lists!",
                date: daysBefore(event.date, 7)
            )
        }

        if let deadline = event.purchaseDeadline {
            schedule(
                id: "\(event.id)-deadline",
                title: "Purchase Deadline Today",
                body: "Today is the deadline to buy gifts for \"\(event.name)\".",
                date: deadline
            )
        }

        if let assignments = event.assignments {
            let unpurchased = assignments.filter { !$0.isGiftPurchased }.count
            if unpurchased > 0 {
                schedule(
                    id: "\(event.id)-unpurchased",
                    title: "Gifts Still Needed",
                    body: "\(unpurchased) gift\(unpurchased == 1 ? "" : "s") still not purchased for \"\(event.name)\".",
                    date: daysBefore(event.date, 3)
                )
            }
        }
    }

    func cancelNotifications(for eventId: UUID) {
        let ids = ["\(eventId)-7days", "\(eventId)-deadline", "\(eventId)-unpurchased"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func schedule(id: String, title: String, body: String, date: Date) {
        guard date > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func daysBefore(_ date: Date, _ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: date) ?? date
    }
}
