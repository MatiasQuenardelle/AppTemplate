import Foundation

/// Centralized user-facing strings for easy customization.
/// Update these when adapting the template to your app.
enum Strings {

    // MARK: - Onboarding

    enum Onboarding {
        static let welcomeTitle = "Welcome to \(Constants.App.displayName)"
        static let welcomeSubtitle = "Your notes, synced everywhere."
        static let welcomeIcon = "note.text"
        static let getStarted = "Get Started"
        static let alreadyHaveAccount = "I already have an account"

        static let nameTitle = "What's your name?"
        static let nameSubtitle = "We'll use this to personalize your experience."
        static let namePlaceholder = "Your name"
        static let continueButton = "Continue"

        static let notificationsTitle = "Stay Updated"
        static let notificationsSubtitle = "Get reminders and sync notifications so you never miss anything."
        static let enableNotifications = "Enable Notifications"
        static let maybeLater = "Maybe Later"

        static let paywallTitle = "Unlock Premium"
        static let paywallSubtitle = "Sync across devices, unlimited notes, and more."
        static let startFreeTrial = "Start Free Trial"
        static let restorePurchases = "Restore Purchases"
        static let continueWithoutPremium = "Continue without Premium"

        static let paywallFeatures: [(icon: String, text: String)] = [
            ("icloud.fill", "Cloud sync across all devices"),
            ("infinity", "Unlimited notes"),
            ("sparkles", "AI-powered summaries"),
            ("lock.shield.fill", "End-to-end encryption"),
        ]
    }

    // MARK: - Auth

    enum Auth {
        static let signIn = "Sign In"
        static let signUp = "Create Account"
        static let email = "Email"
        static let password = "Password"
        static let confirmPassword = "Confirm Password"
        static let forgotPassword = "Forgot your password?"
        static let noAccount = "Don't have an account?"
        static let hasAccount = "Already have an account?"
        static let sendResetLink = "Send Reset Link"
        static let resetPasswordTitle = "Reset Password"
        static let resetPasswordSubtitle = "Enter your email and we'll send you a link to reset your password"
        static let passwordsDoNotMatch = "Passwords do not match"
        static let emailSentTitle = "Email Sent"
        static let emailSentMessage = "Check your inbox to reset your password"
        static let error = "Error"
        static let ok = "OK"
    }

    // MARK: - Settings

    enum Settings {
        static let title = "Settings"
        static let syncSection = "Sync"
        static let subscriptionSection = "Subscription"
        static let supportSection = "Support"
        static let accountSection = "Account"
        static let premium = "Premium"
        static let premiumActive = "Active"
        static let premiumFree = "Free"
        static let restorePurchases = "Restore Purchases"
        static let reportBug = "Report a Bug"
        static let signOut = "Sign Out"
        static let signOutConfirmation = "Are you sure you want to sign out?"
        static let deleteAccount = "Delete Account"
        static let deleteAccountWarning = "This will permanently delete your account and all data. This cannot be undone."
        static let cancel = "Cancel"
        static let delete = "Delete"
        static let version = "Version"
        static let notSignedIn = "Not signed in"
        static let name = "Name"
    }

    // MARK: - Sync

    enum Sync {
        static let cloudSync = "Cloud Sync"
        static let signInToSync = "Sign in to enable cloud sync"
        static let tapToSync = "Tap to sync"
        static let syncing = "Syncing..."
        static let syncingData = "Syncing your data..."
        static let offline = "Offline"
        static let noConnection = "No internet connection"
        static let notSynced = "Not synced"
        static let justNow = "Just now"
        static func lastSynced(_ time: String) -> String { "Last synced \(time)" }
        static func minutesAgo(_ n: Int) -> String { "\(n)m ago" }
        static func hoursAgo(_ n: Int) -> String { "\(n)h ago" }
        static func minutesAgoLong(_ n: Int) -> String { "\(n) min ago" }
    }

    // MARK: - Bug Report

    enum BugReport {
        static let title = "Report a Bug"
        static let describeTheBug = "Describe the bug"
        static let placeholder = "What happened? What did you expect?"
        static let minCharacters = "Minimum 10 characters"
        static let attachScreenshot = "Attach screenshot"
        static let removeImage = "Remove image"
        static let deviceInfo = "Device Info"
        static let appVersion = "App Version"
        static let ios = "iOS"
        static let device = "Device"
        static let cancel = "Cancel"
        static let send = "Send"
        static let thankYou = "Thank you!"
        static let submitted = "Your bug report has been submitted. We'll look into it."
    }

    // MARK: - Notifications

    enum Notifications {
        static let trialEndsTitle = "Your free trial ends tomorrow"
        static let trialEndsBody = "Keep using \(Constants.App.displayName) \u{2014} don't lose your progress!"
    }

    // MARK: - General

    enum General {
        static let back = "Back"
    }
}
