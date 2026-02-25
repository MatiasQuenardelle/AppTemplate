# AppTemplate

A production-ready iOS app template built with SwiftUI, providing authentication, cloud sync, subscriptions, and AI integration out of the box. Clone it, swap in your credentials, delete the example module, and start building.

## Features

- **SwiftUI + SwiftData** local persistence
- **Firebase Auth** with Apple Sign-In, Google Sign-In, and Email/Password
- **Firestore cloud sync** with real-time listeners and debounced uploads
- **RevenueCat** subscription management with paywall
- **OpenAI API** integration (GPT-4o by default)
- **4-phase onboarding flow**: Welcome, Name, Notifications, Paywall
- **Custom dark theme** with copper/gold accent colors
- **Custom tab bar** navigation
- **Sync status indicators** showing upload/download state
- **Bug reporting** with image upload
- **Deep linking** support via URL scheme
- **Privacy manifest** (`PrivacyInfo.xcprivacy`)
- **Firebase Analytics + Crashlytics** (disabled in DEBUG builds)
- **Example "Notes" module** demonstrating the full CRUD + sync pattern

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
AppTemplate/
├── AppTemplateApp.swift          # App entry point, Firebase config
├── ContentView.swift             # Tab-based navigation
├── Example/                      # <- Example Notes module (delete me)
│   ├── Models/Note.swift
│   └── Views/
│       ├── NotesListView.swift
│       ├── NoteDetailView.swift
│       ├── NoteEditorView.swift
│       └── SearchView.swift
├── Models/
│   └── UserProfile.swift
├── Resources/
│   ├── Assets.xcassets/
│   ├── GoogleService-Info.plist
│   └── PrivacyInfo.xcprivacy
├── Services/
│   ├── AuthenticationService.swift
│   ├── FirestoreModels.swift
│   ├── FirestoreService.swift
│   ├── OpenAIService.swift
│   ├── ProfileCacheService.swift
│   ├── SubscriptionManager.swift
│   └── SyncManager.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions.swift
│   └── Theme.swift
└── Views/
    ├── Auth/EmailAuthView.swift
    ├── Components/
    │   ├── CircularProgressView.swift
    │   ├── CustomTabBar.swift
    │   ├── DateNavigationHeader.swift
    │   ├── ProgressBarView.swift
    │   └── SyncStatusView.swift
    ├── Onboarding/
    │   ├── OnboardingContainerView.swift
    │   ├── OnboardingPhaseViews.swift
    │   └── OnboardingState.swift
    └── Settings/
        ├── BugReportView.swift
        └── SettingsView.swift
```

## Customization Guide

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
