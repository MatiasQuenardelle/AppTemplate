import Foundation

// MARK: - API Configuration

private struct APIConfig {
    // TODO: Replace with your API key or use a proxy endpoint
    static let apiKey = "YOUR_API_KEY"
    static let endpoint = Constants.API.openAIEndpoint
    static let model = Constants.API.openAIModel
}

// MARK: - Chat Message

struct ChatMessage: Sendable {
    enum Role: String, Sendable {
        case system
        case user
        case assistant
    }

    let role: Role
    let content: String
}

// MARK: - OpenAI Service

actor OpenAIService {
    static let shared = OpenAIService()

    private var lastRequestTime: Date?
    private let minRequestInterval: TimeInterval = 1.0

    private init() {}

    // MARK: - Rate Limiting

    private func waitForRateLimit() async {
        if let lastTime = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < minRequestInterval {
                let waitTime = minRequestInterval - elapsed
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }

    // MARK: - General Chat Completion

    /// Send a chat completion request with a custom system prompt and messages.
    /// This is the primary method — use it for any AI feature.
    ///
    /// Example:
    /// ```swift
    /// let response = try await OpenAIService.shared.chat(
    ///     systemPrompt: "You are a helpful fitness coach.",
    ///     userMessage: "Create a 5-minute morning routine."
    /// )
    /// ```
    func chat(
        systemPrompt: String,
        userMessage: String,
        maxTokens: Int = Constants.API.maxTokens
    ) async throws -> String {
        let messages = [
            ChatMessage(role: .system, content: systemPrompt),
            ChatMessage(role: .user, content: userMessage),
        ]
        return try await chatWithMessages(messages, maxTokens: maxTokens)
    }

    /// Send a multi-turn chat completion request.
    /// Use this for conversations that need history.
    func chatWithMessages(
        _ messages: [ChatMessage],
        maxTokens: Int = Constants.API.maxTokens
    ) async throws -> String {
        await waitForRateLimit()

        var request = URLRequest(url: URL(string: APIConfig.endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(APIConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": APIConfig.model,
            "max_tokens": maxTokens,
            "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] },
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            return result.choices.first?.message.content ?? ""
        case 429:
            throw OpenAIError.rateLimited
        case 400...499:
            throw OpenAIError.clientError(httpResponse.statusCode)
        case 500...599:
            throw OpenAIError.serverError(httpResponse.statusCode)
        default:
            throw OpenAIError.invalidResponse
        }
    }

    // MARK: - Convenience Methods

    /// Summarize text concisely.
    func summarize(_ text: String) async throws -> String {
        try await chat(
            systemPrompt: "You are a helpful assistant. Summarize the following text concisely.",
            userMessage: text
        )
    }

    /// Extract key points from text.
    func extractKeyPoints(_ text: String) async throws -> String {
        try await chat(
            systemPrompt: "You are a helpful assistant. Extract the key points from the following text as a bulleted list.",
            userMessage: text
        )
    }

    /// Generate a response with a custom persona.
    func generate(persona: String, prompt: String) async throws -> String {
        try await chat(systemPrompt: persona, userMessage: prompt)
    }
}

// MARK: - Error Types

enum OpenAIError: LocalizedError {
    case invalidResponse
    case rateLimited
    case clientError(Int)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid API response"
        case .rateLimited: return "Rate limited. Please try again later."
        case .clientError(let code): return "Client error (\(code))"
        case .serverError(let code): return "Server error (\(code))"
        }
    }
}

// MARK: - Response Models

private struct ChatCompletionResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}
