import Combine
import StoreKit
import SwiftUI
import UIKit

struct AppSettings: Codable {
    var showCompletedEvents: Bool = false
    var defaultBudget: Double = 0
}

final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var showClearDataAlert = false
    @Published var showClearSuccess = false

    private let storageService: StorageServiceProtocol
    private let coordinator: AppCoordinator

    var totalEvents: Int {
        let events: [Event] = storageService.load(forKey: StorageKeys.events)
        return events.count
    }

    init(storageService: StorageServiceProtocol, coordinator: AppCoordinator) {
        self.storageService = storageService
        self.coordinator = coordinator
        self.settings = storageService.loadObject(forKey: StorageKeys.settings) ?? AppSettings()
    }

    func saveSettings() {
        storageService.saveObject(settings, forKey: StorageKeys.settings)
    }

    func clearAllData() {
        storageService.delete(forKey: StorageKeys.events)
        storageService.delete(forKey: StorageKeys.pairHistory)
        showClearSuccess = true
    }

    func goBack() {
        coordinator.pop()
    }

    func openPrivacyPolicy() {
        if let url = URL(string: AppLinks.privacyPolicy) {
            UIApplication.shared.open(url)
        }
    }

    func openTermsOfUse() {
        if let url = URL(string: AppLinks.termsOfUse) {
            UIApplication.shared.open(url)
        }
    }

    func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}