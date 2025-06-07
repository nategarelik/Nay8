import Foundation
import Network
import Nay8Framework

public struct AIMessage: Codable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public enum AIError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case invalidAPIKey
    case chatNotActive
    case targetChatNotSet
}

public class AIHandler {
    public static let shared = AIHandler()
    
    // --- Configuration ---
    private let useLocalLLM: Bool
    private let model: String
    private let openAIKey: String?
    private let activationKeyword = "/Nay8"
    private let deactivationKeyword = "end-convo"
    private let systemPrompt = "You are Nay8, a helpful and friendly AI assistant integrated into a family group chat. Keep your responses concise and conversational."
    // IMPORTANT: Set this to the actual ID of your family group chat.
    // If nil, Nay8 will respond in any chat where it's activated.
    private let targetFamilyChatID: String? = nil // Example: "iMessage;+;chat1234567890"
    
    // --- State ---
    private var contexts: [String: ChatContext] = [:]
    private let localLLMBaseURL = "http://localhost:11434/api/chat"
    private let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
    
    public init(useLocalLLM: Bool = true, model: String = "llama3") {
        self.useLocalLLM = useLocalLLM
        self.model = model
        self.openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        
        if !useLocalLLM && openAIKey == nil {
            print("Warning: OPENAI_API_KEY environment variable not set for OpenAI usage.")
        }
        if useLocalLLM {
            print("AIHandler initialized for Local LLM (Ollama - \(model))")
        }
    }
    
    public func processMessage(_ message: Message, using sender: MessageSender) {
        print("AIHandler: Starting message processing")
        
        // Log the raw message object
        print("AIHandler: Raw message: \(message)")
        
        // Extract message text
        let messageText = (message.body as? TextBody)?.message
        print("AIHandler: Extracted message text: \(messageText ?? "(no text)")")
        
        // Check if we have a recipient
        if let recipientEntity = message.RespondTo() {
            print("AIHandler: Found recipient entity")
        } else {
            print("AIHandler: No recipient entity found")
        }
        
        guard let messageText = messageText,
              let recipientEntity = message.RespondTo() else {
            print("AIHandler: Could not process message - missing text or recipient.")
            return
        }
        
        let chatID = recipientEntity.handle
        print("AIHandler: Processing message in chat: \(chatID)")
        print("AIHandler: Message text: \(messageText)")
        
        // Get or create chat context
        let context = ChatContextManager.shared.getContext(for: chatID)
        
        // Add message to context
        let userMessage = AIMessage(role: "user", content: messageText)
        context.addMessage(userMessage)
        
        // Log the current chat context state
        print("AIHandler: Current chat state - Active chats: \(ChatContextManager.shared.activeChats)")
        print("AIHandler: Recent messages: \(context.getRecentHistory())")
        
        // If a target chat is set, only process messages from that chat.
        if let targetID = targetFamilyChatID, chatID != targetID {
            print("AIHandler: Message ignored - not in target chat")
            return
        }
        
        let lowercasedMessage = messageText.lowercased()
        
        // Activation and deactivation logic
        if messageText.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).hasPrefix(self.activationKeyword.lowercased()) {
            // Optionally set a flag in persistentMemory or ChatContext if you want to track activation
            print("AIHandler: Activated in chat: \(chatID)")
            sender.send("Nay8 is now active in this chat!", to: recipientEntity)
            return
        }
        if messageText.lowercased().contains(self.deactivationKeyword) {
            // Optionally set a flag in persistentMemory or ChatContext if you want to track deactivation
            context.recentMessages.removeAll()
            print("AIHandler: Deactivated in chat: \(chatID)")
            sender.send("Nay8 is now deactivated in this chat.", to: recipientEntity)
            return
        }
        
        // Bot is already active, process the message as part of the ongoing conversation
        Task {
            do {
                // Add user's message to history
                let response = try await self.respondToPrompt(messageText, systemPrompt: self.systemPrompt, chatID: chatID)
                
                // Add bot's response to history
                context.addMessage(AIMessage(role: "assistant", content: response))
                
                if let recipient = message.RespondTo() {
                    await MainActor.run {
                        sender.send(response, to: recipient)
                    }
                }
            } catch {
                handleError(error, for: chatID, with: sender, originalMessage: message)
            }
        }
    }
    
    private func respondToPrompt(_ prompt: String, systemPrompt: String, chatID: String) async throws -> String {
        // Get chat context
        let context = ChatContextManager.shared.getContext(for: chatID)
        
        // Build conversation history
        var messages: [AIMessage] = [
            AIMessage(role: "system", content: systemPrompt)
        ]
        
        // Add recent messages from context
        messages.append(contentsOf: context.recentMessages)
        
        // Add current message
        messages.append(AIMessage(role: "user", content: prompt))
        
        return try await getResponse(messages: messages)
    }
    
    private func handleError(_ error: Error, for chatID: String, with sender: MessageSender, originalMessage: Message) {
        print("AIHandler Error for chatID \(chatID): \(error)")
        let errorMessage = "I seem to have encountered a glitch. Please try again or say 'end-convo' to reset me."
        if let recipient = originalMessage.RespondTo() {
            Task {
                await MainActor.run {
                    sender.send(errorMessage, to: recipient)
                }
            }
        }
    }
    
    // MARK: - Core LLM Interaction (Modified from previous version)
    
    private func getResponse(messages: [AIMessage]) async throws -> String {
        if useLocalLLM {
            return try await getLocalResponse(messages: messages)
        } else {
            return try await getOpenAIResponse(messages: messages)
        }
    }
    
    private func getLocalResponse(messages: [AIMessage]) async throws -> String {
        guard let url = URL(string: self.localLLMBaseURL) else { throw AIError.invalidURL }
        let payload: [String: Any] = [
            "model": model,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "stream": false
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                print("AIHandler: Local LLM request failed. Status: \(statusCode). Body: \(responseBody)")
                throw AIError.requestFailed(NSError(domain: "AIHandler.LocalLLM", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(statusCode). Body: \(responseBody)"])) // More specific error
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let messageData = json["message"] as? [String: Any],
                  let content = messageData["content"] as? String else {
                print("AIHandler: Failed to parse local LLM response JSON.")
                throw AIError.invalidResponse
            }
            return content
        } catch {
            print("AIHandler: Error during local LLM request: \(error)")
            throw AIError.requestFailed(error)
        }
    }
    
    private func getOpenAIResponse(messages: [AIMessage]) async throws -> String {
        guard let apiKey = self.openAIKey else { throw AIError.invalidAPIKey }
        guard let url = URL(string: self.openAIBaseURL) else { throw AIError.invalidURL }
        let payload: [String: Any] = [
            "model": model,
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                print("AIHandler: OpenAI request failed. Status: \(statusCode). Body: \(responseBody)")
                throw AIError.requestFailed(NSError(domain: "AIHandler.OpenAI", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(statusCode). Body: \(responseBody)"])) // More specific error
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let messageData = firstChoice["message"] as? [String: Any],
                  let content = messageData["content"] as? String else {
                print("AIHandler: Failed to parse OpenAI response JSON.")
                throw AIError.invalidResponse
            }
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("AIHandler: Error during OpenAI request: \(error)")
            throw AIError.requestFailed(error)
        }
    }
}
