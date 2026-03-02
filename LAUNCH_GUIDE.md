# Launch Day Playbook

Go from `git clone` to App Store submission in one day. Follow each step in order.

---

## Phase 1: Project Setup (~30 min)

### 1.1 Clone and rename

```bash
git clone <repo-url> && cd AppTemplate
./setup.sh
```

The script will prompt you for:
- **App name** (e.g. `FocusTracker`) — must start with uppercase, no spaces
- **Bundle ID prefix** (e.g. `com.yourcompany`) — reverse domain format

It renames all files, directories, constants, and regenerates the Xcode project.

### 1.2 Open in Xcode

```bash
open YourApp.xcodeproj
```

Wait for Swift Package Manager to resolve dependencies (Firebase, GoogleSignIn, RevenueCat). This can take 2-5 minutes on first open.

### 1.3 Set your team and signing

1. Select the project in the navigator
2. Select your target under "Targets"
3. Go to "Signing & Capabilities"
4. Select your Team from the dropdown
5. Xcode should auto-create the provisioning profile

---

## Phase 2: Firebase Setup (~30 min)

### 2.1 Create Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project", name it, disable Google Analytics if you want faster setup (you can enable it later)
3. Wait for project creation

### 2.2 Add iOS app

1. Click the iOS icon to add an app
2. Enter your bundle ID (e.g. `com.yourcompany.focustracker`)
3. Enter your app nickname
4. Download `GoogleService-Info.plist`
5. **Replace** the placeholder file at `YourApp/Resources/GoogleService-Info.plist` with the downloaded one

### 2.3 Enable Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable the providers you want:
   - **Apple** — requires Apple Developer account setup (see Phase 4)
   - **Google** — auto-configured from your Firebase project
   - **Email/Password** — just toggle it on
3. If you don't need all three, you can remove the unused sign-in buttons from the onboarding view later

### 2.4 Create Firestore database

1. Go to **Firestore Database** > **Create database**
2. Choose **Start in production mode** (we have security rules)
3. Select a region close to your users
4. After creation, go to **Rules** tab
5. Copy the contents of `firestore.rules` from this repo and paste them in
6. Click **Publish**

### 2.5 Enable Storage (for bug reports)

1. Go to **Storage** > **Get started**
2. Choose **Start in production mode**
3. Select the same region as Firestore
4. Go to **Rules** tab
5. Copy the contents of `storage.rules` from this repo and paste them in
6. Click **Publish**

---

## Phase 3: RevenueCat Setup (~30 min)

### 3.1 Create RevenueCat project

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create a new project
3. Add an **Apple App Store** app
4. You'll need your **App Store Connect Shared Secret** (see Phase 5)

### 3.2 Configure products in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com) > Your App > **Subscriptions**
2. Create a subscription group (e.g. "Premium")
3. Add your subscription products:
   - Weekly (e.g. `com.yourcompany.focustracker.weekly`)
   - Monthly (e.g. `com.yourcompany.focustracker.monthly`)
   - Yearly (e.g. `com.yourcompany.focustracker.yearly`)
4. For each product, set the price and reference name
5. Add at least one localization (display name, description)

### 3.3 Connect RevenueCat to App Store Connect

1. In App Store Connect > **Users and Access** > **Integrations** > **In-App Purchase**
2. Generate a Shared Secret and copy it
3. In RevenueCat dashboard, paste the Shared Secret under your app's configuration
4. Create **Entitlements** in RevenueCat: create one called "Premium"
5. Create **Products** in RevenueCat matching your App Store Connect product IDs
6. Attach the products to the "Premium" entitlement
7. Create an **Offering** (call it "default") and add your packages (weekly, monthly, yearly)

### 3.4 Add API keys to your app

1. In RevenueCat dashboard > **API Keys**
2. Copy the **public** API key
3. Open `YourApp/Services/SubscriptionManager.swift`
4. Replace `YOUR_REVENUECAT_DEBUG_API_KEY` and `YOUR_REVENUECAT_PRODUCTION_API_KEY` with your key(s)

> **Tip:** For initial development, you can use the same key for both debug and production. Create separate keys when you're ready to ship.

---

## Phase 4: Apple Developer Setup (~20 min)

### 4.1 Register App ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account) > **Certificates, Identifiers & Profiles**
2. Under **Identifiers**, click "+" to register a new App ID
3. Select "App IDs" and "App"
4. Enter your bundle ID
5. Enable these capabilities:
   - **Sign in with Apple**
   - **Push Notifications** (if you want notifications)
   - **App Groups** — add a group matching `group.<your-bundle-id>`

### 4.2 Create App Store Connect listing

1. Go to [App Store Connect](https://appstoreconnect.apple.com) > **My Apps** > "+"
2. Fill in:
   - **Platform**: iOS
   - **Name**: Your app name (as it appears on App Store)
   - **Primary language**: English (or your language)
   - **Bundle ID**: Select from dropdown (must match your registered App ID)
   - **SKU**: Any unique string (e.g. `focustracker-ios-v1`)
3. Click **Create**

---

## Phase 5: Build Your App (~3-5 hrs)

This is where you customize the template into your actual app.

### 5.1 Remove the Example module

Follow the steps in README.md under "Removing the Example Notes Module". The key steps:
1. Delete the `Example/` folder
2. Remove `Note.self` from the Schema in `YourAppApp.swift`
3. Remove `FSNote` from `FirestoreModels.swift`
4. Remove note methods from `FirestoreService.swift`
5. Remove note sync from `SyncManager.swift`
6. Replace tab cases in `ContentView.swift` and `CustomTabBar.swift`

### 5.2 Add your data models

1. Create your SwiftData models in `Models/`
2. Add them to the Schema in `YourAppApp.swift`
3. Create Firestore structs in `FirestoreModels.swift`
4. Add CRUD methods in `FirestoreService.swift`
5. Add sync logic in `SyncManager.swift`

### 5.3 Build your screens

1. Create your views in `Views/`
2. Wire them up to tabs in `ContentView.swift` and `CustomTabBar.swift`
3. Use the existing components (`SyncStatusView`, `CircularProgressView`, etc.)

### 5.4 Customize the theme

Edit `YourApp/Utilities/Theme.swift` to match your brand colors.

### 5.5 Customize strings

Edit `YourApp/Utilities/Strings.swift` to update all user-facing copy (onboarding text, button labels, feature descriptions, etc.) in one place.

### 5.6 Customize the onboarding

1. Edit `OnboardingPhaseViews.swift`:
   - Update the welcome icon and text
   - Update the paywall feature list
2. Edit `OnboardingState.swift` if you want to add/remove phases

### 5.7 Add analytics events

The template includes an analytics event catalog in `Services/Analytics.swift`. Standard events (onboarding, auth, purchases, sync) are already wired up. To add custom events:

1. Add a new case to `AnalyticsEvent` in `Analytics.swift`
2. Call `Analytics.log(.yourEvent)` from your code
3. In DEBUG builds, events are printed to console; in Release, they go to Firebase Analytics

### 5.8 Add your app icon

1. Create your icon (1024x1024 PNG, no transparency)
2. Use a tool like [App Icon Generator](https://www.appicon.co) to generate all sizes
3. Replace the images in `Resources/Assets.xcassets/AppIcon.appiconset/`

---

## Phase 6: App Store Assets (~1-2 hrs)

### 6.1 Screenshots

You need screenshots for these device sizes (at minimum the first two):

| Device | Size (pixels) | Required |
|--------|---------------|----------|
| iPhone 16 Pro Max (6.9") | 1320 x 2868 | Yes (covers 6.5"+ too) |
| iPhone 16 Pro (6.3") | 1206 x 2622 | Yes |
| iPhone SE (4") | 640 x 1136 | No (only if supporting SE) |

**How to take screenshots:**
1. Run your app in the Simulator (select the right device)
2. Press `Cmd + S` to save a screenshot to Desktop
3. You need 3-10 screenshots per device size
4. Screenshots should show your app's best features

**Pro tip:** Use [Screenshots.pro](https://screenshots.pro), [Hotpot.ai](https://hotpot.ai/app-store-screenshot-generator), or Figma with a device frame template to add captions and frames.

### 6.2 App metadata

Fill in the template at `AppStore/metadata.md` with your app's details, then copy-paste into App Store Connect.

### 6.3 Privacy Policy

1. Edit the template at `AppStore/privacy-policy.html`
2. Host it somewhere (GitHub Pages, your website, Notion public page)
3. Add the URL to App Store Connect

### 6.4 Support URL

You need a support URL. Options:
- Create a simple page on your website
- Use a Google Form for support requests
- Use the template at `AppStore/support.html`
- Link to an email address on a hosted page

---

## Phase 7: Testing (~30 min)

### 7.1 Run unit tests

Before testing on device, run the included test suite:

1. In Xcode, press `Cmd + U` to run all tests
2. The suite covers onboarding logic, sync status, constants, strings, and deep link routing
3. All tests should pass — if any fail, investigate before continuing

### 7.2 Test on real device

1. Connect your iPhone
2. Select it as the build target
3. Build and run (`Cmd + R`)
4. Test the full flow:
   - [ ] Onboarding completes
   - [ ] Sign in with each enabled auth method
   - [ ] Create/edit/delete your data
   - [ ] Data syncs to Firestore (check Firebase Console)
   - [ ] Settings page works
   - [ ] Sign out and sign back in
   - [ ] Data persists after sign-out/sign-in

### 7.3 Test deep links

Test that your URL scheme works:

1. Open Safari on your test device
2. Navigate to `yourappscheme://settings` — should open the Settings tab
3. Navigate to `yourappscheme://profile` — should open the Settings tab (profile section)
4. Replace `yourappscheme` with the URL scheme you set in `Constants.swift`

### 7.4 Test subscriptions (sandbox)

1. In App Store Connect > **Users and Access** > **Sandbox Testers**, create a sandbox test account
2. On your test device, sign out of your real App Store account
3. Run the app and trigger the paywall
4. Sign in with the sandbox account when prompted
5. Verify the purchase completes and premium unlocks

---

## Phase 8: Submission (~30 min)

### 8.1 Archive and upload

**Option A: Xcode (simple)**
1. Set scheme to "Release"
2. Select "Any iOS Device" as destination
3. Product > Archive
4. In the Organizer, click "Distribute App"
5. Select "App Store Connect" > "Upload"
6. Wait for processing (5-15 min)

**Option B: Fastlane (faster, repeatable)**
```bash
cd fastlane
bundle install
bundle exec fastlane beta  # Upload to TestFlight
```

### 8.2 Fill in App Store Connect

1. Go to App Store Connect > Your App > iOS App > Version
2. Fill in:
   - **Screenshots** — Upload for each required device size
   - **Description** — From your `AppStore/metadata.md`
   - **Keywords** — Comma-separated, max 100 characters total
   - **Support URL** — Your hosted support page
   - **Privacy Policy URL** — Your hosted privacy policy
   - **Category** — Select the most relevant category
3. Under **App Review Information**:
   - Add a demo account if your app requires sign-in
   - Add notes explaining what the app does
4. Under **Build**, select the build you uploaded

### 8.3 App Privacy

In App Store Connect > **App Privacy**:
1. Click "Get Started"
2. Answer the data collection questions based on what your app actually collects:
   - **Contact Info** (email — from authentication)
   - **Identifiers** (user ID — from Firebase Auth)
   - **Purchases** (if using subscriptions)
3. Mark data as "Used for App Functionality" (not tracking)

### 8.4 Submit for review

1. Click "Add for Review"
2. Click "Submit to App Review"
3. Review typically takes 24-48 hours (sometimes faster)

---

## Common Rejection Reasons (and How to Avoid Them)

| Reason | Fix |
|--------|-----|
| **Broken sign-in** | Test every auth method before submitting |
| **Missing privacy policy** | Host your privacy policy and add the URL |
| **Incomplete metadata** | Fill in every required field in App Store Connect |
| **Subscription issues** | Ensure subscription terms are clear in the paywall |
| **No restore button** | Already included in the template (Settings > Restore Purchases) |
| **Crash on launch** | Test on a real device with Release config |
| **Sign in with Apple missing** | If you offer Google sign-in, you must also offer Apple sign-in |
| **Missing purpose string** | Ensure notification permission text explains why you need it |

---

## Quick Reference: File Locations

| What | Where |
|------|-------|
| Firebase config | `Resources/GoogleService-Info.plist` |
| RevenueCat keys | `Services/SubscriptionManager.swift` |
| OpenAI key | `Services/OpenAIService.swift` |
| Bundle ID | `Utilities/Constants.swift` |
| All UI strings | `Utilities/Strings.swift` |
| Theme colors | `Utilities/Theme.swift` |
| Analytics events | `Services/Analytics.swift` |
| Deep link routes | `AppTemplateApp.swift` (`DeepLinkRouter`) |
| State views | `Views/Components/StateViews.swift` |
| Onboarding flow | `Views/Onboarding/` |
| Tab configuration | `Views/Components/CustomTabBar.swift` |
| Firestore rules | `firestore.rules` (root) |
| Storage rules | `storage.rules` (root) |
| App Store metadata | `AppStore/metadata.md` |
| Privacy policy | `AppStore/privacy-policy.html` |
| Fastlane config | `fastlane/Fastfile` |
| Unit tests | `AppTemplateTests/` |
