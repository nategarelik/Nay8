import Foundation
import Nay8Framework

// Ensure AIMessage is accessible (defined in AIHandler.swift as public struct AIMessage: Codable)
// If AIMessage is not in a module that's imported, this won't work directly without other project settings.
// Assuming AIMessage is available in the current module target.

// Define ChatState as a top-level Codable enum
enum ChatState: String, Codable {
    case idle
    case active
    case waiting
    case processing
}

class ChatContext: Codable {
    // Chat identifier
    let chatID: String
    
    // Recent messages (last N messages)
    var recentMessages: [AIMessage] = [] // Uses AIMessage from AIHandler.swift
    private let maxRecentMessages = 20
    
    // Persistent memory (stored in UserDefaults)
    var persistentMemory: [String: String] = [:]
    
    // Chat-specific settings
    var settings: [String: String] = [:]
    
    // Current conversation state
    var state: ChatState = .idle // Uses the ChatState defined above
    
    // Last interaction timestamp
    var lastInteraction: Date = Date()
    
    // Initialize with chat ID
    init(chatID: String) {
        self.chatID = chatID
    }
    
    // Custom coding keys to exclude non-Codable properties
    private enum CodingKeys: String, CodingKey {
        case chatID, recentMessages, persistentMemory, settings, state, lastInteraction
    }
    
    // Add a new message to recent messages
    func addMessage(_ message: AIMessage) {
        recentMessages.append(message)
        if recentMessages.count > maxRecentMessages {
            recentMessages.removeFirst()
        }
        lastInteraction = Date()
    }
    
    // Get recent conversation history as a string
    func getRecentHistory() -> String {
        return recentMessages.map { "\($0.role): \($0.content)\n" }.joined()
    }
    
    // Update persistent memory
    func updateMemory(_ key: String, value: String) {
        persistentMemory[key] = value
    }
    
    // Get memory value
    func getMemory(_ key: String) -> String? {
        return persistentMemory[key]
    }
    
    // Update chat settings
    func updateSetting(_ key: String, value: String) { // Value is String
        settings[key] = value
    }
    
    // Get chat setting
    func getSetting(_ key: String) -> String? { // Return type is String?
        return settings[key]
    }
    
    // Update conversation state
    func setState(_ newState: ChatState) {
        state = newState
    }
    
    // Check if chat is idle
    var isIdle: Bool {
        return state == .idle // Should now correctly reference ChatState.idle
    }
}

// Chat context storage manager
class ChatContextManager {
    static let shared = ChatContextManager()
    private var contexts: [String: ChatContext] = [:]
    
    // Load context from UserDefaults
    func getContext(for chatID: String) -> ChatContext {
        if let context = contexts[chatID] {
            return context
        }
        
        let newContext = ChatContext(chatID: chatID)
        contexts[chatID] = newContext
        return newContext
    }
    
    // Save context to UserDefaults
    func saveContext(_ context: ChatContext) {
        contexts[context.chatID] = context
    }
    
    // Remove context
    func removeContext(for chatID: String) {
        contexts.removeValue(forKey: chatID)
    }
    
    // Get all active chats
    var activeChats: [String] {
        return contexts.keys.filter { contexts[$0]?.state != .idle }
    }
}
