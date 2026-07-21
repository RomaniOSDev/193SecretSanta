//
//  AppDelegate.swift
//  193SecretSanta
//
//  Created by Roman on 6/26/26.
//

import UIKit
import UserNotifications
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppsFlyer()
        configurePushNotifications(application)
        capturePushURLFromLaunchOptions(launchOptions)
        return true
    }

    private func configureAppsFlyer() {
        #if canImport(AppsFlyerLib)
        AppsFlyerLib.shared().appsFlyerDevKey = "Xpot5ZNgdk6XZr8CFUqRER"
        AppsFlyerLib.shared().appleAppID = "6786362758"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().start()
        #endif

        #if canImport(FirebaseCore)
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            #if canImport(FirebaseMessaging)
            Messaging.messaging().delegate = self
            if let app = FirebaseApp.app() {
                ConfigManagerOptionalData.firebaseProjectId = app.options.gcmSenderID
            }
            #endif
        }
        #endif
    }

    private func configurePushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            case .notDetermined, .denied:
                break
            @unknown default:
                break
            }
        }
    }

    private func capturePushURLFromLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any],
              let url = PushNotificationURLRouter.shared.extractURL(from: userInfo) else { return }
        PushNotificationURLRouter.shared.setPendingURL(url)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = deviceToken
        #endif
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        #if canImport(AppsFlyerLib)
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        #endif
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        #if canImport(AppsFlyerLib)
        AppsFlyerLib.shared().handleOpen(url, options: options)
        #endif
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let url = PushNotificationURLRouter.shared.extractURL(from: userInfo) {
            DispatchQueue.main.async { [weak self] in
                self?.openPushURLInWebView(url)
            }
        }
        completionHandler()
    }

    private func openPushURLInWebView(_ url: URL) {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first else {
            PushNotificationURLRouter.shared.setPendingURL(url)
            return
        }
        window.rootViewController = WebviewVC(url: url)
    }
}

#if canImport(FirebaseMessaging)
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        ConfigManagerOptionalData.pushToken = fcmToken
        if let app = FirebaseApp.app() {
            ConfigManagerOptionalData.firebaseProjectId = app.options.gcmSenderID
        }
        if NotificationPermissionManager.shared.consumeShouldSendTokenOnce() {
            ConfigManager.shared.requestConfig { _ in }
        }
    }
}
#endif

#if canImport(AppsFlyerLib)
extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        AppsFlyerManager.shared.handleConversionDataSuccess(installData)
    }

    func onConversionDataFail(_ error: Error!) {
        AppsFlyerManager.shared.handleConversionDataFail(error)
    }
}

extension AppDelegate: DeepLinkDelegate {
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard result.status == .found, let deepLink = result.deepLink else { return }
        var payload: [AnyHashable: Any] = [:]
        for (key, value) in deepLink.clickEvent {
            payload[key] = value
        }
        payload["is_deferred"] = deepLink.isDeferred
        AppsFlyerManager.shared.handleDeepLinkData(payload)
    }
}
#endif

