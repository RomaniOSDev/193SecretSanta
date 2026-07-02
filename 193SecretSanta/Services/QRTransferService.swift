import CoreImage.CIFilterBuiltins
import Foundation
import UIKit

enum QRTransferError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case imageGenerationFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Could not encode event data."
        case .decodingFailed: return "Could not decode QR data."
        case .imageGenerationFailed: return "Could not generate QR code."
        }
    }
}

final class QRTransferService {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func encodeEvent(_ event: Event) throws -> String {
        let payload = EventTransferPayload(event: event)
        let data = try encoder.encode(payload)
        return data.base64EncodedString()
    }

    func decodeEvent(from base64: String) throws -> Event {
        guard let data = Data(base64Encoded: base64.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw QRTransferError.decodingFailed
        }
        let payload = try decoder.decode(EventTransferPayload.self, from: data)
        let imported = payload.event
        return Event(
            id: UUID(),
            name: imported.name,
            description: imported.description,
            date: imported.date,
            budget: imported.budget,
            status: .planning,
            participants: imported.participants,
            assignments: nil,
            createdAt: Date(),
            isCompleted: false,
            preset: imported.preset,
            rules: imported.rules,
            groups: imported.groups,
            revealSettings: imported.revealSettings,
            purchaseDeadline: imported.purchaseDeadline
        )
    }

    func generateQRCode(from string: String, size: CGFloat = 250) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage else { return nil }
        let scale = size / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
