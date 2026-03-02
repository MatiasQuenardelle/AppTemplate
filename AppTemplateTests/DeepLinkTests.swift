import Testing
@testable import AppTemplate

@Suite("DeepLinkRouter")
struct DeepLinkTests {

    @Test("parses settings route")
    func parseSettings() {
        let url = URL(string: "apptemplate://settings")!
        let action = DeepLinkRouter.parse(url: url)
        #expect(action == .showSettings)
    }

    @Test("parses profile route")
    func parseProfile() {
        let url = URL(string: "apptemplate://profile")!
        let action = DeepLinkRouter.parse(url: url)
        #expect(action == .showProfile)
    }

    @Test("returns none for unknown route")
    func parseUnknown() {
        let url = URL(string: "apptemplate://unknown")!
        let action = DeepLinkRouter.parse(url: url)
        #expect(action == .none)
    }

    @Test("returns none for wrong scheme")
    func parseWrongScheme() {
        let url = URL(string: "https://example.com/settings")!
        let action = DeepLinkRouter.parse(url: url)
        #expect(action == .none)
    }

    @Test("parses item route with ID")
    func parseItemWithID() {
        let url = URL(string: "apptemplate://item/abc-123")!
        let action = DeepLinkRouter.parse(url: url)
        #expect(action == .showItem(id: "abc-123"))
    }
}
