import Foundation
import SwiftUI

enum Constants {
    enum App {
        static let bundleID = "com.apptemplate.app"
        static let urlScheme = "apptemplate"
        static let appGroupID = "group.com.apptemplate.app"
        static let displayName = "AppTemplate"
    }

    enum API {
        static let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
        static let openAIModel = "gpt-4o"
        static let maxTokens = 1000
    }

    enum UI {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let animationDuration: Double = 0.3
    }
}
