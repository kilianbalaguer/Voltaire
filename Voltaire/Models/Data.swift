//
//  Data.swift
//  Voltaire
//
//  Created by Kilian Balaguer on 10/7/26.
//

import SwiftUI
import SwiftData
import MLXLMCommon

class AppManager: ObservableObject {
    static let defaultSystemPrompt = ""
    static let temperatureOptions = ["Default", "Precise - 0.0", "Consistent - 0.2", "Balanced - 0.4", "Creative - 0.6", "Very creative - 0.8", "Experimental - 1.0"]

    static func temperatureValue(for option: String) -> Double {
        if option == "Default" { return 0.5 }
        if let last = option.split(separator: " ").last, let value = Double(last) {
            return value
        }
        return 0.5
    }

    @AppStorage("systemPromptV2") var systemPrompt = AppManager.defaultSystemPrompt
    @AppStorage("customizationEnabled") var customizationEnabled = false
    @AppStorage("customTemperature") var customTemperature = "Default"
    @AppStorage("thinkingModeOn") var thinkingModeOn = true
    @AppStorage("appTintColor") var appTintColor: AppTintColor = .monochrome
    @AppStorage("appFontDesign") var appFontDesign: AppFontDesign = .standard
    @AppStorage("appFontSize") var appFontSize: AppFontSize = .small
    @AppStorage("appFontWidth") var appFontWidth: AppFontWidth = .standard
    @AppStorage("currentModelName") var currentModelName: String?
    @AppStorage("shouldPlayHaptics") var shouldPlayHaptics = true
    @AppStorage("showKeyboardOnLaunch") var showKeyboardOnLaunch = false
    @AppStorage("numberOfVisits") var numberOfVisits = 0
    @AppStorage("numberOfVisitsOfLastRequest") var numberOfVisitsOfLastRequest = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("userName") var userName = ""

    var hasInstalledModels: Bool { !installedModels.isEmpty }

    /// The prompt actually sent to models: custom instructions when enabled, otherwise the default.
    var effectiveSystemPrompt: String {
        if customizationEnabled, !systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return systemPrompt
        }
        return Self.defaultSystemPrompt
    }
    
    var userInterfaceIdiom: LayoutType {
        return UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
    }

    enum LayoutType {
        case phone, pad, unknown
    }
        
    private let installedModelsKey = "installedModels"
        
    @Published var installedModels: [String] = [] {
        didSet {
            saveInstalledModelsToUserDefaults()
        }
    }

    /// Transient launch state: true once splash/onboarding intros are done
    /// and the home greeting is allowed to start typing.
    @Published var splashComplete = false
    
    init() {
        loadInstalledModelsFromUserDefaults()
        // Drop models that no longer exist (e.g. removed families)
        let known = Set(ModelConfiguration.availableModels.map(\.name))
        let filtered = installedModels.filter { known.contains($0) }
        if filtered.count != installedModels.count {
            installedModels = filtered
        }
        if let current = currentModelName, !known.contains(current) {
            currentModelName = nil
        }
    }
    
    func incrementNumberOfVisits() {
        numberOfVisits += 1
        print("app visits: \(numberOfVisits)")
    }
    
    // Function to save the array to UserDefaults as JSON
    private func saveInstalledModelsToUserDefaults() {
        if let jsonData = try? JSONEncoder().encode(installedModels) {
            UserDefaults.standard.set(jsonData, forKey: installedModelsKey)
        }
    }
    
    // Function to load the array from UserDefaults
    private func loadInstalledModelsFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: installedModelsKey),
           let decodedArray = try? JSONDecoder().decode([String].self, from: jsonData) {
            self.installedModels = decodedArray
        } else {
            self.installedModels = [] // Default to an empty array if there's no data
        }
    }
    
    @MainActor func playHaptic() {
        if shouldPlayHaptics {
            Haptic.shared.play(.light)
        }
    }
    
    func addInstalledModel(_ model: String) {
        if !installedModels.contains(model) {
            installedModels.append(model)
        }
    }
    
    func modelDisplayName(_ modelName: String) -> String {
        // Known model display names mapping
        let displayNames: [String: String] = [
            // Bonsai
            "prism-ml/Ternary-Bonsai-8B-mlx-2bit": "Bonsai Ternary (8B)",
            "prism-ml/Bonsai-8B-mlx-1bit": "Bonsai (8B)",
            // Qwen 3.5
            "mlx-community/Qwen3.5-2B-MLX-4bit": "Qwen 3.5 (2B)",
            "mlx-community/Qwen3.5-0.8B-MLX-4bit": "Qwen 3.5 (0.8B)",
            // LFM 2.5
            "mlx-community/LFM2.5-1.6B-VL-4bit": "LFM 2.5 VL (1.6B)",
            "mlx-community/LFM2.5-450M-VL-4bit": "LFM 2.5 VL (450M)",
            "mlx-community/LFM2.5-1.2B-Thinking-4bit": "LFM 2.5 Thinking (1.2B)",
            "mlx-community/LFM2.5-1.2B-4bit": "LFM 2.5 (1.2B)",
            "mlx-community/LFM2.5-350M-4bit": "LFM 2.5 (350M)",
            // LFM 2
            "mlx-community/LFM2-3B-VL-4bit": "LFM 2 VL (3B)",
            "mlx-community/LFM2-1.6B-VL-4bit": "LFM 2 VL (1.6B)",
            "mlx-community/LFM2-450M-VL-4bit": "LFM 2 VL (450M)",
            "mlx-community/LFM2-2.6B-Exp-4bit": "LFM 2 Experimental (2.6B)",
            "mlx-community/LFM2-2.6B-4bit": "LFM 2 (2.6B)",
            "mlx-community/LFM2-1.2B-4bit": "LFM 2 (1.2B)",
            "mlx-community/LFM2-700M-4bit": "LFM 2 (700M)",
            "mlx-community/LFM2-350M-4bit": "LFM 2 (350M)",
            // Ministral 3
            "mlx-community/Ministral-3-3B-Instruct-2512-4bit": "Ministral 3 Instruct (3B)",
            // SmolLM 3
            "mlx-community/SmolLM3-3B-4bit": "SmolLM 3 (3B)",
            // Gemma 3n
            "mlx-community/gemma-3n-E2B-4bit": "Gemma 3n (2B)",
            // Gemma 2
            "mlx-community/gemma-2-2b-it-4bit": "Gemma 2 (2B)",
            // Granite 4.0
            "mlx-community/granite-4.0-h-micro-4bit": "Granite 4.0 Micro (3B)",
            "mlx-community/granite-4.0-h-1b-4bit": "Granite 4.0 (1B)",
            "mlx-community/granite-4.0-h-350m-4bit": "Granite 4.0 (350M)",
            // Llama 3.2
            "mlx-community/Llama-3.2-3B-Instruct-4bit": "Llama 3.2 Instruct (3B)",
            "mlx-community/Llama-3.2-1B-Instruct-4bit": "Llama 3.2 Instruct (1B)",
            // Qwen 3
            "mlx-community/Qwen3-VL-2B-4bit": "Qwen 3 VL (2B)",
            "mlx-community/Qwen3-4B-Thinking-4bit": "Qwen 3 Thinking (4B)",
            "mlx-community/Qwen3-4B-4bit": "Qwen 3 (4B)",
            "mlx-community/Qwen3-1.7B-4bit": "Qwen 3 (1.7B)",
            "mlx-community/Qwen3-0.6B-4bit": "Qwen 3 (0.6B)",
            // MiniCPM 5
            "mlx-community/MiniCPM5-1B-4bit": "MiniCPM 5 (1B)",
            "mlx-community/MiniCPM5-2B-mlx-4Bit": "MiniCPM 5 (2B)",
            // Voltaire
            "kilianbalaguer9/Voltaire-2.5-MLX-4bit": "Voltaire 2.5 (1.7B)",
        ]
        
        // Try exact match first
        if let displayName = displayNames[modelName] {
            return displayName
        }
        
        // Try case-insensitive match
        let lowercasedName = modelName.lowercased()
        for (key, value) in displayNames {
            if key.lowercased() == lowercasedName {
                return value
            }
        }
        
        // Fallback
        return modelName.replacingOccurrences(of: "mlx-community/", with: "").replacingOccurrences(of: "prism-ml/", with: "")
    }
    
    func modelParameterCount(_ modelName: String) -> String? {
        let known: [String: String] = [
            "kilianbalaguer9/Voltaire-2.5-MLX-4bit": "1.7B",
        ]
        if let value = known[modelName] { return value }

        let pattern = #"(\d+\.?\d*)B\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        // Try to find in the model name directly
        let range = NSRange(modelName.startIndex..., in: modelName)
        if let match = regex.firstMatch(in: modelName, range: range),
           let valueRange = Range(match.range(at: 1), in: modelName) {
            let value = String(modelName[valueRange])
            return "\(value)B"
        }
        
        // If not found, look up the model configuration and check its id
        if let model = ModelConfiguration.getModelByName(modelName) {
            let id = String(describing: model.id)
            let idRange = NSRange(id.startIndex..., in: id)
            if let match = regex.firstMatch(in: id, range: idRange),
               let valueRange = Range(match.range(at: 1), in: id) {
                let value = String(id[valueRange])
                return "\(value)B"
            }
        }
        
        return nil
    }
}

enum Role: String, Codable {
    case assistant
    case user
    case system
}

@Model
class Message {
    @Attribute(.unique) var id: UUID
    var role: Role
    var content: String
    var timestamp: Date
    var generatingTime: TimeInterval?
    var imageData: Data?
    
    @Relationship(inverse: \Thread.messages) var thread: Thread?
    
    init(role: Role, content: String, thread: Thread? = nil, generatingTime: TimeInterval? = nil, imageData: Data? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.thread = thread
        self.generatingTime = generatingTime
        self.imageData = imageData
    }
}

@Model
final class Thread: Sendable {
    @Attribute(.unique) var id: UUID
    var title: String?
    var timestamp: Date
    
    @Relationship var messages: [Message] = []
    
    var sortedMessages: [Message] {
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    init() {
        self.id = UUID()
        self.timestamp = Date()
    }
}

enum AppTintColor: String, CaseIterable {
    case monochrome, blue, brown, gray, green, indigo, mint, orange, pink, purple, red, teal, yellow
    
    func getColor() -> Color {
        switch self {
        case .monochrome:
            .primary
        case .blue:
            .blue
        case .red:
            .red
        case .green:
            .green
        case .yellow:
            .yellow
        case .brown:
            .brown
        case .gray:
            .gray
        case .indigo:
            .indigo
        case .mint:
            .mint
        case .orange:
            .orange
        case .pink:
            .pink
        case .purple:
            .purple
        case .teal:
            .teal
        }
    }
}

enum AppFontDesign: String, CaseIterable {
    case serif, standard, monospaced, rounded
    
    func getFontDesign() -> Font.Design {
        switch self {
        case .standard:
            .default
        case .monospaced:
            .monospaced
        case .rounded:
            .rounded
        case .serif:
            .serif
        }
    }
}

enum AppFontWidth: String, CaseIterable {
    case compressed, condensed, expanded, standard
    
    func getFontWidth() -> Font.Width {
        switch self {
        case .compressed:
            .compressed
        case .condensed:
            .condensed
        case .expanded:
            .expanded
        case .standard:
            .standard
        }
    }
}

enum AppFontSize: String, CaseIterable {
    case xsmall, small, medium, large, xlarge
    
    func getFontSize() -> DynamicTypeSize {
        switch self {
        case .xsmall:
            .xSmall
        case .small:
            .small
        case .medium:
            .medium
        case .large:
            .large
        case .xlarge:
            .xLarge
        }
    }
}
