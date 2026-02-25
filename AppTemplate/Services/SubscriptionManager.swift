import Foundation
import RevenueCat
import UserNotifications

// MARK: - Subscription Manager

@MainActor @Observable
final class SubscriptionManager: NSObject, @unchecked Sendable {
    static let shared = SubscriptionManager()
    static let entitlementID = "Premium"

    #if DEBUG
    private(set) var isPremium = true
    #else
    private(set) var isPremium = false
    #endif
    private(set) var currentOffering: Offering?
    private(set) var weeklyPackage: Package?
    private(set) var monthlyPackage: Package?
    private(set) var yearlyPackage: Package?
    private(set) var lifetimePackage: Package?

    private(set) var isConfigured = false
    private var configurationContinuations: [CheckedContinuation<Void, Never>] = []

    // TODO: Replace with your RevenueCat API keys
    #if DEBUG
    private static let apiKey = "YOUR_REVENUECAT_DEBUG_API_KEY"
    #else
    private static let apiKey = "YOUR_REVENUECAT_PRODUCTION_API_KEY"
    #endif

    // MARK: - Configuration

    private override init() {
        super.init()
    }

    func configure() {
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .warn
        #endif
        Purchases.configure(
            with: .builder(withAPIKey: Self.apiKey)
                .build()
        )
        Purchases.shared.delegate = self

        Task {
            await refreshPremiumStatus()
            isConfigured = true
            let continuations = configurationContinuations
            configurationContinuations.removeAll()
            for continuation in continuations {
                continuation.resume()
            }
        }
    }

    func waitUntilConfigured() async {
        guard !isConfigured else { return }
        await withCheckedContinuation { continuation in
            configurationContinuations.append(continuation)
        }
    }

    // MARK: - Identity

    func login(firebaseUID: String) async {
        do {
            let (_, _) = try await Purchases.shared.logIn(firebaseUID)
            await refreshPremiumStatus()
        } catch {
            print("[SubscriptionManager] login error: \(error.localizedDescription)")
        }
    }

    func logout() async {
        do {
            _ = try await Purchases.shared.logOut()
            isPremium = false
        } catch {
            print("[SubscriptionManager] logout error: \(error.localizedDescription)")
        }
    }

    // MARK: - Restore

    @discardableResult
    func restorePurchases() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isPremium = customerInfo.entitlements[Self.entitlementID]?.isActive == true
            return isPremium
        } catch {
            print("[SubscriptionManager] restore error: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Status

    private func refreshPremiumStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements[Self.entitlementID]?.isActive == true
        } catch {
            print("[SubscriptionManager] refresh error: \(error.localizedDescription)")
        }
    }

    // MARK: - Offerings

    func fetchOfferings(forceRefresh: Bool = false) async {
        if !forceRefresh && currentOffering != nil { return }

        await waitUntilConfigured()

        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
            weeklyPackage = currentOffering?.weekly
            monthlyPackage = currentOffering?.monthly
            yearlyPackage = currentOffering?.annual
            lifetimePackage = currentOffering?.lifetime
        } catch {
            print("[SubscriptionManager] offerings error: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchase

    @discardableResult
    func purchase(_ package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        if result.userCancelled { return false }
        isPremium = result.customerInfo.entitlements[Self.entitlementID]?.isActive == true
        if isPremium {
            scheduleTrialReminderIfNeeded(for: package)
        }
        return isPremium
    }

    // MARK: - Trial Reminder Notification

    private static let trialReminderID = "app_trial_expiry_reminder"

    private func scheduleTrialReminderIfNeeded(for package: Package) {
        guard let discount = package.storeProduct.introductoryDiscount,
              discount.paymentMode == .freeTrial else { return }

        let trialDays: Int
        switch discount.subscriptionPeriod.unit {
        case .day: trialDays = discount.subscriptionPeriod.value
        case .week: trialDays = discount.subscriptionPeriod.value * 7
        default: trialDays = 3
        }

        let reminderSeconds = max(3600, TimeInterval((trialDays - 1) * 86400))

        let content = UNMutableNotificationContent()
        content.title = "Your free trial ends tomorrow"
        content.body = "Keep using \(Constants.App.displayName) \u{2014} don't lose your progress!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminderSeconds, repeats: false)
        let request = UNNotificationRequest(identifier: Self.trialReminderID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[SubscriptionManager] trial reminder scheduling error: \(error.localizedDescription)")
            }
        }
    }

    func cancelTrialReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.trialReminderID])
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        let isActive = customerInfo.entitlements[SubscriptionManager.entitlementID]?.isActive == true
        Task { @MainActor in
            self.isPremium = isActive
        }
    }
}
