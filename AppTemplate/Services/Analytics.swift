import Foundation
import FirebaseAnalytics

// MARK: - Analytics Events

enum AnalyticsEvent: String {
    // Onboarding
    case onboardingStarted = "onboarding_started"
    case onboardingNameEntered = "onboarding_name_entered"
    case onboardingNotificationsGranted = "onboarding_notifications_granted"
    case onboardingNotificationsSkipped = "onboarding_notifications_skipped"
    case onboardingCompleted = "onboarding_completed"

    // Authentication
    case signInStarted = "sign_in_started"
    case signInCompleted = "sign_in_completed"
    case signInFailed = "sign_in_failed"
    case signUpCompleted = "sign_up_completed"
    case signedOut = "signed_out"
    case accountDeleted = "account_deleted"

    // Paywall
    case paywallShown = "paywall_shown"
    case paywallSkipped = "paywall_skipped"
    case purchaseStarted = "purchase_started"
    case purchaseCompleted = "purchase_completed"
    case purchaseFailed = "purchase_failed"
    case purchaseRestored = "purchase_restored"

    // Sync
    case syncStarted = "sync_started"
    case syncCompleted = "sync_completed"
    case syncFailed = "sync_failed"

    // Content
    case itemCreated = "item_created"
    case itemUpdated = "item_updated"
    case itemDeleted = "item_deleted"

    // Support
    case bugReportSubmitted = "bug_report_submitted"

    // Engagement
    case appOpened = "app_opened"
    case tabSelected = "tab_selected"
}

// MARK: - Analytics Logger

enum Analytics {
    /// Log an event with optional parameters.
    static func log(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        #if !DEBUG
        FirebaseAnalytics.Analytics.logEvent(event.rawValue, parameters: parameters)
        #else
        let params = parameters?.map { "\($0.key): \($0.value)" }.joined(separator: ", ") ?? ""
        print("[Analytics] \(event.rawValue)\(params.isEmpty ? "" : " {\(params)}")")
        #endif
    }

    /// Log an event with a single key-value parameter.
    static func log(_ event: AnalyticsEvent, key: String, value: Any) {
        log(event, parameters: [key: value])
    }

    // MARK: - Convenience Methods

    static func logSignIn(method: String) {
        log(.signInCompleted, parameters: ["method": method])
    }

    static func logSignUp(method: String) {
        log(.signUpCompleted, parameters: ["method": method])
    }

    static func logPurchase(productId: String, price: Double) {
        log(.purchaseCompleted, parameters: [
            "product_id": productId,
            "price": price,
        ])
    }

    static func logTabSelected(_ tab: String) {
        log(.tabSelected, parameters: ["tab": tab])
    }

    static func logOnboardingPhase(_ phase: String) {
        log(.onboardingCompleted, parameters: ["phase": phase])
    }
}
