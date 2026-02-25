import Foundation

// MARK: - Onboarding Phase

enum OnboardingPhase: Int, CaseIterable {
    case welcome = 0
    case nameInput = 1
    case notifications = 2
    case paywall = 3

    var progressValue: Double {
        Double(rawValue) / Double(Self.allCases.count - 1)
    }
}

// MARK: - Onboarding State

@MainActor @Observable
final class OnboardingState {
    var currentPhase: OnboardingPhase = .welcome
    var userName: String = ""
    var notificationsGranted: Bool = false

    func advance() {
        guard let next = OnboardingPhase(rawValue: currentPhase.rawValue + 1) else { return }
        currentPhase = next
    }

    func goBack() {
        guard let prev = OnboardingPhase(rawValue: currentPhase.rawValue - 1) else { return }
        currentPhase = prev
    }

    var canGoBack: Bool {
        currentPhase.rawValue > 0
    }

    var isComplete: Bool {
        currentPhase == .paywall
    }
}
