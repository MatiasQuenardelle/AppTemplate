import Testing
@testable import AppTemplate

@Suite("Strings")
struct StringsTests {

    @Test("onboarding strings are not empty")
    func onboardingStrings() {
        #expect(!Strings.Onboarding.welcomeTitle.isEmpty)
        #expect(!Strings.Onboarding.welcomeSubtitle.isEmpty)
        #expect(!Strings.Onboarding.getStarted.isEmpty)
        #expect(!Strings.Onboarding.nameTitle.isEmpty)
        #expect(!Strings.Onboarding.continueButton.isEmpty)
        #expect(!Strings.Onboarding.paywallTitle.isEmpty)
    }

    @Test("paywall features list is not empty")
    func paywallFeatures() {
        #expect(!Strings.Onboarding.paywallFeatures.isEmpty)
        for feature in Strings.Onboarding.paywallFeatures {
            #expect(!feature.icon.isEmpty)
            #expect(!feature.text.isEmpty)
        }
    }

    @Test("auth strings are not empty")
    func authStrings() {
        #expect(!Strings.Auth.signIn.isEmpty)
        #expect(!Strings.Auth.signUp.isEmpty)
        #expect(!Strings.Auth.email.isEmpty)
        #expect(!Strings.Auth.password.isEmpty)
    }

    @Test("sync format functions produce output")
    func syncFormatFunctions() {
        #expect(Strings.Sync.minutesAgo(5).contains("5"))
        #expect(Strings.Sync.hoursAgo(2).contains("2"))
        #expect(Strings.Sync.lastSynced("just now").contains("just now"))
    }

    @Test("welcome title contains app name")
    func welcomeTitleContainsAppName() {
        #expect(Strings.Onboarding.welcomeTitle.contains(Constants.App.displayName))
    }
}
