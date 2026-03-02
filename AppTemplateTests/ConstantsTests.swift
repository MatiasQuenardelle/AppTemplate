import Testing
@testable import AppTemplate

@Suite("Constants")
struct ConstantsTests {

    @Test("bundle ID is set")
    func bundleID() {
        #expect(!Constants.App.bundleID.isEmpty)
    }

    @Test("URL scheme is set")
    func urlScheme() {
        #expect(!Constants.App.urlScheme.isEmpty)
    }

    @Test("app group ID contains bundle ID")
    func appGroupContainsBundleID() {
        #expect(Constants.App.appGroupID.contains(Constants.App.bundleID))
    }

    @Test("UI constants are positive")
    func uiConstants() {
        #expect(Constants.UI.cornerRadius > 0)
        #expect(Constants.UI.padding > 0)
        #expect(Constants.UI.animationDuration > 0)
    }

    @Test("API endpoint is HTTPS")
    func apiEndpointIsHTTPS() {
        #expect(Constants.API.openAIEndpoint.hasPrefix("https://"))
    }
}
