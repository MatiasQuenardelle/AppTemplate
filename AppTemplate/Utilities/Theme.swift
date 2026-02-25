import SwiftUI

/// Unified color namespace for the app's dark premium theme.
/// Bronze/copper accent with deep black backgrounds.
enum Theme {
    // MARK: - Backgrounds
    static let deepBlack = Color(red: 0.05, green: 0.05, blue: 0.06)
    static let cardBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let elevatedBackground = Color(red: 0.14, green: 0.14, blue: 0.15)

    // MARK: - Accent Colors
    static let copperGold = Color(red: 0.85, green: 0.65, blue: 0.45)
    static let accentCoral = Color(red: 0.96, green: 0.45, blue: 0.35)
    static let salmonAccent = Color(red: 0.98, green: 0.55, blue: 0.45)

    // MARK: - Text Colors
    static let primaryText = Color(white: 0.95)
    static let secondaryText = Color(white: 0.65)
    static let tertiaryText = Color(white: 0.40)

    // MARK: - Tab Bar
    static let tabBarBackground = Color(red: 0.08, green: 0.08, blue: 0.09)
    static let selectedTint = Color(red: 0.85, green: 0.65, blue: 0.45)
    static let unselectedTint = Color(white: 0.45)
}
