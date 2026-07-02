import Foundation
import UIKit

final class ExportService {

    func makeShareText(for event: Event) -> String {
        var lines: [String] = []
        lines.append("Gift Exchange: \(event.name)")
        lines.append("Date: \(event.date.formattedEventDate())")
        lines.append("Preset: \(event.preset.displayName)")

        if let budget = event.budget, budget > 0 {
            lines.append("Budget: \(budget.formattedCurrency())")
        }

        if let deadline = event.purchaseDeadline {
            lines.append("Purchase deadline: \(deadline.formattedEventDate())")
        }

        lines.append("")
        lines.append("Participants (\(event.participants.count)):")
        for p in event.participants {
            var row = "• \(p.name)"
            if let group = event.groups.first(where: { $0.id == p.groupId }) {
                row += " [\(group.name)]"
            }
            row += p.isActive ? "" : " (inactive)"
            lines.append(row)
        }

        if let assignments = event.assignments, !assignments.isEmpty {
            lines.append("")
            lines.append("Assignment Status:")
            for a in assignments {
                let purchased = a.isGiftPurchased ? "✅" : "❌"
                lines.append("• \(a.giverName ?? "?") → \(a.receiverName ?? "?") \(purchased)")
            }
        }

        lines.append("")
        lines.append("Rules:")
        lines.append("• Avoid repeat pairs: \(event.rules.avoidRepeatPairs ? "Yes" : "No")")
        lines.append("• Group restriction: \(event.rules.restrictToGroups ? "Yes" : "No")")
        lines.append("• Exclusions: \(event.rules.exclusionPairs.count)")
        lines.append("• Manual bans: \(event.rules.forbiddenPairs.count)")

        return lines.joined(separator: "\n")
    }

    func makePDF(for event: Event) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 40
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            func draw(_ text: String, font: UIFont, color: UIColor = .black) {
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let rect = CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 1000)
                let height = (text as NSString).boundingRect(
                    with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    attributes: attrs,
                    context: nil
                ).height
                (text as NSString).draw(in: CGRect(x: margin, y: y, width: rect.width, height: height), withAttributes: attrs)
                y += height + 8
            }

            draw(event.name, font: .boldSystemFont(ofSize: 22))
            draw("Date: \(event.date.formattedEventDate())", font: .systemFont(ofSize: 14), color: .darkGray)
            draw("Format: \(event.preset.displayName)", font: .systemFont(ofSize: 14), color: .darkGray)

            if let budget = event.budget, budget > 0 {
                draw("Budget: \(budget.formattedCurrency())", font: .systemFont(ofSize: 14))
            }

            y += 8
            draw("Participants", font: .boldSystemFont(ofSize: 16))
            for p in event.participants {
                draw("• \(p.name)", font: .systemFont(ofSize: 13))
            }

            if let assignments = event.assignments {
                y += 8
                draw("Assignments", font: .boldSystemFont(ofSize: 16))
                for a in assignments {
                    let status = a.isGiftPurchased ? "Purchased" : "Pending"
                    draw("• \(a.giverName ?? "?") → \(a.receiverName ?? "?") — \(status)", font: .systemFont(ofSize: 13))
                }
            }
        }
    }
}
