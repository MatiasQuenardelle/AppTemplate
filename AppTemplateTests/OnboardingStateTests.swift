import Testing
@testable import AppTemplate

@MainActor
@Suite("OnboardingState")
struct OnboardingStateTests {

    @Test("starts at welcome phase")
    func initialPhase() {
        let state = OnboardingState()
        #expect(state.currentPhase == .welcome)
        #expect(state.userName == "")
        #expect(state.notificationsGranted == false)
    }

    @Test("advances through all phases in order")
    func advanceThroughPhases() {
        let state = OnboardingState()

        #expect(state.currentPhase == .welcome)
        state.advance()
        #expect(state.currentPhase == .nameInput)
        state.advance()
        #expect(state.currentPhase == .notifications)
        state.advance()
        #expect(state.currentPhase == .paywall)
    }

    @Test("does not advance past paywall")
    func doesNotAdvancePastEnd() {
        let state = OnboardingState()
        state.currentPhase = .paywall
        state.advance()
        #expect(state.currentPhase == .paywall)
    }

    @Test("goes back to previous phase")
    func goBack() {
        let state = OnboardingState()
        state.currentPhase = .notifications
        state.goBack()
        #expect(state.currentPhase == .nameInput)
    }

    @Test("does not go back before welcome")
    func doesNotGoBackBeforeStart() {
        let state = OnboardingState()
        state.goBack()
        #expect(state.currentPhase == .welcome)
    }

    @Test("canGoBack is false on welcome")
    func canGoBackWelcome() {
        let state = OnboardingState()
        #expect(state.canGoBack == false)
    }

    @Test("canGoBack is true after welcome")
    func canGoBackAfterWelcome() {
        let state = OnboardingState()
        state.advance()
        #expect(state.canGoBack == true)
    }

    @Test("isComplete is true only on paywall")
    func isComplete() {
        let state = OnboardingState()
        #expect(state.isComplete == false)
        state.currentPhase = .paywall
        #expect(state.isComplete == true)
    }

    @Test("progress values are correct")
    func progressValues() {
        #expect(OnboardingPhase.welcome.progressValue == 0.0)
        #expect(OnboardingPhase.nameInput.progressValue > 0.0)
        #expect(OnboardingPhase.paywall.progressValue == 1.0)
    }
}
