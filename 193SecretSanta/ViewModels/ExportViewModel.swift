import Combine
import SwiftUI

final class ExportViewModel: ObservableObject {
    @Published var event: Event
    @Published var qrImage: UIImage?
    @Published var exportPayload = ""
    @Published var importPayload = ""
    @Published var showImportSuccess = false
    @Published var showImportError = false
    @Published var importErrorMessage = ""
    @Published var pdfURL: URL?

    private let storageService: StorageServiceProtocol
    private let coordinator: AppCoordinator
    private let exportService = ExportService()
    private let qrService = QRTransferService()

    var shareText: String { exportService.makeShareText(for: event) }

    init(event: Event, storageService: StorageServiceProtocol, coordinator: AppCoordinator) {
        self.event = event
        self.storageService = storageService
        self.coordinator = coordinator
        prepareExport()
    }

    func prepareExport() {
        if let payload = try? qrService.encodeEvent(event) {
            exportPayload = payload
            qrImage = qrService.generateQRCode(from: payload)
        }
        if let data = exportService.makePDF(for: event) {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(event.name)-export.pdf")
            try? data.write(to: url)
            pdfURL = url
        }
    }

    func importEvent() {
        do {
            var imported = try qrService.decodeEvent(from: importPayload)
            imported.name = "\(imported.name) (Imported)"
            storageService.append(imported, forKey: StorageKeys.events)
            showImportSuccess = true
            importPayload = ""
        } catch {
            importErrorMessage = error.localizedDescription
            showImportError = true
        }
    }

    func goBack() {
        coordinator.pop()
    }
}
