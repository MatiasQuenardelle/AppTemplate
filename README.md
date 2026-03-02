# AppTemplate

A production-ready iOS app template built with SwiftUI, providing authentication, cloud sync, subscriptions, and AI integration out of the box. Clone it, swap in your credentials, delete the example module, and start building.

**Want to launch an app in one day?** See [LAUNCH_GUIDE.md](LAUNCH_GUIDE.md) for a step-by-step playbook from `git clone` to App Store submission.

## Features

- **SwiftUI + SwiftData** local persistence
- **Firebase Auth** with Apple Sign-In, Google Sign-In, and Email/Password
- **Firestore cloud sync** with real-time listeners and debounced uploads
- **RevenueCat** subscription management with paywall
- **OpenAI API** integration with general-purpose chat, summarization, and key-point extraction
- **4-phase onboarding flow**: Welcome, Name, Notifications, Paywall
- **Custom dark theme** with copper/gold accent colors
- **Custom tab bar** navigation
- **Sync status indicators** showing upload/download state
- **Bug reporting** with image upload
- **Deep linking** with URL router (settings, profile, item routes)
- **Privacy manifest** (`PrivacyInfo.xcprivacy`)
- **Firebase Analytics + Crashlytics** (disabled in DEBUG builds)
- **Example "Notes" module** demonstrating the full CRUD + sync pattern
- **Firestore & Storage security rules** ready to deploy
- **Fastlane** configuration for TestFlight and App Store submission
- **App Store templates** for metadata, privacy policy, and support page
- **Centralized strings** (`Strings.swift`) for fast UI copy customization
- **Analytics event catalog** with standard events for onboarding, auth, purchases, and sync
- **Reusable state views** for empty, loading, and error states
- **Accessibility labels** on all interactive elements (VoiceOver-ready)
- **Sync retry with backoff** — failed uploads retry automatically with exponential backoff
- **Unit test suite** for onboarding logic, sync status, constants, strings, and deep links

## Prerequisites

Before using this template, you need accounts and projects set up for the services it integrates with:

1. **Xcode 16+** -- Install from the Mac App Store.

2. **XcodeGen** -- Install via Homebrew:
   ```bash
   brew install xcodegen
   ```

3. **Firebase project** -- Go to [Firebase Console](https://console.firebase.google.com), create a new project, then:
   - Add an iOS app with your bundle ID
   - Enable **Authentication** and turn on the sign-in providers you want (Apple, Google, Email/Password)
   - Enable **Cloud Firestore** and create a database
   - Enable **Storage** if you want image uploads (used by bug reporting)
   - Download the generated `GoogleService-Info.plist` -- you'll drop this into the project later

4. **RevenueCat account** -- Sign up at [RevenueCat](https://www.revenuecat.com), create a project, and configure your App Store Connect API key. You'll need your RevenueCat API keys (debug and production) from the project dashboard.

5. **OpenAI API key** -- Sign up at [OpenAI Platform](https://platform.openai.com), add billing, and create an API key under API Keys.

6. **Apple Developer account** -- Required for Sign in with Apple, push notifications, and App Groups. In your [Apple Developer portal](https://developer.apple.com/account):
   - Register your App ID with the Sign in with Apple capability
   - Create an App Group matching `group.<your-bundle-id>`
   - Enable Push Notifications if you want notification support

## Quick Start

1. Clone the repository:
   ```bash
   git clone <repo-url> && cd AppTemplate
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

3. **Configure Firebase** -- Download your `GoogleService-Info.plist` from the [Firebase Console](https://console.firebase.google.com) (Project Settings > iOS app) and replace the placeholder file at `AppTemplate/Resources/GoogleService-Info.plist`.

4. **Configure RevenueCat** -- Open `AppTemplate/Services/SubscriptionManager.swift` and replace the API key placeholders with your RevenueCat API keys.

5. **Configure OpenAI** -- Open `AppTemplate/Services/OpenAIService.swift` and replace the API key placeholder with your OpenAI API key.

6. Open `AppTemplate.xcodeproj` in Xcode and build.

## Placeholder Locations

All placeholders you need to replace before shipping:

| File | Placeholder | Description |
|------|-------------|-------------|
| `Resources/GoogleService-Info.plist` | `YOUR_API_KEY` | Firebase API key |
| `Resources/GoogleService-Info.plist` | `YOUR_GCM_SENDER_ID` | Firebase Cloud Messaging sender ID |
| `Resources/GoogleService-Info.plist` | `your-firebase-project-id` | Firebase project ID (appears in PROJECT_ID and STORAGE_BUCKET) |
| `Resources/GoogleService-Info.plist` | `000000000000-xxx...` | Google OAuth CLIENT_ID and REVERSED_CLIENT_ID |
| `Resources/GoogleService-Info.plist` | `1:000000000000:ios:...` | GOOGLE_APP_ID |
| `Services/SubscriptionManager.swift` | `YOUR_REVENUECAT_DEBUG_API_KEY` | RevenueCat debug API key |
| `Services/SubscriptionManager.swift` | `YOUR_REVENUECAT_PRODUCTION_API_KEY` | RevenueCat production API key |
| `Services/OpenAIService.swift` | `YOUR_API_KEY` | OpenAI API key |
| `Utilities/Constants.swift` | `com.apptemplate.app` | Bundle ID -- replace with your own |
| `Utilities/Constants.swift` | `apptemplate` | URL scheme -- replace with your own |
| `Utilities/Constants.swift` | `group.com.apptemplate.app` | App group ID -- replace with your own |

The simplest approach for Firebase is to download your project's `GoogleService-Info.plist` from the Firebase Console and drop it in, replacing the placeholder file entirely.

## Architecture / File Tree

```
├── LAUNCH_GUIDE.md              # Step-by-step launch day playbook
├── firestore.rules              # Firestore security rules (deploy to Firebase)
├── storage.rules                # Storage security rules (deploy to Firebase)
├── AppStore/                    # App Store submission templates
│   ├── metadata.md              # Description, keywords, review notes
│   ├── privacy-policy.html      # Privacy policy template
│   └── support.html             # Support page template
├── fastlane/                    # Fastlane deployment configuration
│   ├── Appfile                  # Apple Developer account config
│   ├── Fastfile                 # Build & upload lanes
│   └── Gemfile                  # Ruby dependencies
├── AppTemplate/
│   ├── AppTemplateApp.swift     # App entry point, Firebase config
│   ├── ContentView.swift        # Tab-based navigation
│   ├── Example/                 # <- Example Notes module (delete me)
│   │   ├── Models/Note.swift
│   │   └── Views/
│   │       ├── NotesListView.swift
│   │       ├── NoteDetailView.swift
│   │       ├── NoteEditorView.swift
│   │       └── SearchView.swift
│   ├── Models/
│   │   └── UserProfile.swift
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   ├── GoogleService-Info.plist
│   │   └── PrivacyInfo.xcprivacy
│   ├── Services/
│   │   ├── Analytics.swift         # Analytics event catalog
│   │   ├── AuthenticationService.swift
│   │   ├── FirestoreModels.swift
│   │   ├── FirestoreService.swift
│   │   ├── OpenAIService.swift     # General-purpose chat, summarize, extract
│   │   ├── ProfileCacheService.swift
│   │   ├── SubscriptionManager.swift
│   │   └── SyncManager.swift       # Includes retry with exponential backoff
│   ├── Utilities/
│   │   ├── Constants.swift
│   │   ├── Extensions.swift
│   │   ├── Strings.swift           # All user-facing strings (customize here)
│   │   └── Theme.swift
│   └── Views/
│       ├── Auth/EmailAuthView.swift
│       ├── Components/
│       │   ├── CircularProgressView.swift
│       │   ├── CustomTabBar.swift
│       │   ├── DateNavigationHeader.swift
│       │   ├── ProgressBarView.swift
│       │   ├── StateViews.swift    # Empty, loading, and error state views
│       │   └── SyncStatusView.swift
│       ├── Onboarding/
│       │   ├── OnboardingContainerView.swift
│       │   ├── OnboardingPhaseViews.swift
│       │   └── OnboardingState.swift
│       └── Settings/
│           ├── BugReportView.swift
│           └── SettingsView.swift
├── AppTemplateTests/               # Unit test suite
│   ├── ConstantsTests.swift
│   ├── DeepLinkTests.swift
│   ├── OnboardingStateTests.swift
│   ├── StringsTests.swift
│   └── SyncStatusTests.swift
```

## Customization Guide

### Change user-facing text

Edit `AppTemplate/Utilities/Strings.swift`. All UI copy (onboarding, auth, settings, sync status, bug report, notifications) is centralized here. Update the strings to match your app's voice and features.

### Change the theme

Edit `AppTemplate/Utilities/Theme.swift`. The template uses a dark theme with copper/gold accent colors. Modify the color definitions and font styles to match your brand.

### Change tabs

1. Open `AppTemplate/Views/Components/CustomTabBar.swift` and update the `Tab` enum -- add, remove, or rename cases.
2. Open `AppTemplate/ContentView.swift` and update the `switch` on the selected tab to return the correct view for each case.

### Customize onboarding

Edit the files in `AppTemplate/Views/Onboarding/`:
- `OnboardingState.swift` -- controls the phases and progression logic.
- `OnboardingPhaseViews.swift` -- contains the UI for each phase (Welcome, Name, Notifications, Paywall).
- `OnboardingContainerView.swift` -- orchestrates the flow.

### Add new SwiftData models

1. Create your model file in `AppTemplate/Models/`.
2. Open `AppTemplateApp.swift` and add your model type to the `Schema` array in the `ModelContainer` configuration.

### Add Firestore sync for new models

Follow the pattern established by the example Notes module:

1. **Define a Firestore-compatible struct** in `FirestoreService/FirestoreModels.swift`, following the `FSNote` pattern (a `Codable` struct that maps to your Firestore document).
2. **Add CRUD methods and a listener** in `Services/FirestoreService.swift` for reading/writing your new document type.
3. **Add sync logic** in `Services/SyncManager.swift` to handle bidirectional sync between SwiftData and Firestore (upload local changes, apply remote changes).

### Deploy Firebase security rules

After setting up your Firebase project, deploy the included security rules:

1. Go to **Firestore Database** > **Rules** in the Firebase Console
2. Copy the contents of `firestore.rules` and paste them in, then click **Publish**
3. Go to **Storage** > **Rules**
4. Copy the contents of `storage.rules` and paste them in, then click **Publish**

These rules ensure users can only access their own data and bug reports are write-only.

### Deploy with Fastlane

```bash
cd fastlane
bundle install
bundle exec fastlane beta     # Upload to TestFlight
bundle exec fastlane release  # Submit to App Store
```

Edit `fastlane/Appfile` with your Apple Developer account details first.

## Removing the Example Notes Module

The example module is marked throughout the codebase with `// MARK: EXAMPLE` comments. Follow these steps to remove it cleanly:

1. **Delete the `Example/` folder** (`AppTemplate/Example/`).

2. **`AppTemplateApp.swift`** -- Remove `Note.self` from the `Schema` array. Look for the `// MARK: EXAMPLE` comment.

3. **`FirestoreModels.swift`** -- Delete the `FSNote` struct. Look for `// MARK: - EXAMPLE`.

4. **`FirestoreService.swift`** -- Delete the Notes CRUD methods and the notes listener. Look for `// MARK: - EXAMPLE`.

5. **`SyncManager.swift`** -- Delete the Note-related sync logic, including `handleRemoteNotes` and `deleteNoteFromCloud`. All marked with `// MARK: EXAMPLE`.

6. **`ContentView.swift`** -- Replace the `.notes` and `.search` tab cases with your own views. Look for `// MARK: EXAMPLE`.

7. **`CustomTabBar.swift`** -- Replace the `.notes` and `.search` cases in the `Tab` enum with your own tabs. Look for `// MARK: - EXAMPLE`.

8. **Search the entire project for "EXAMPLE"** to catch any remaining references.

## Requirements

- iOS 17.0+
- Xcode 16+
- XcodeGen (`brew install xcodegen`)

## License

MIT
