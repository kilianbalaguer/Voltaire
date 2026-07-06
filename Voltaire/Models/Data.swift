//
//  Data.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/5/24.
//

import SwiftUI
import SwiftData
import MLXLMCommon

class AppManager: ObservableObject {
    @AppStorage("systemPrompt") var systemPrompt = "You are a helpful assistant. You can use Markdown and LaTeX (enclosed in $$) to format your messages, but try not to use Markdown styling in a line that contains a LaTeX formula."
    @AppStorage("appTintColor") var appTintColor: AppTintColor = .monochrome
    @AppStorage("appFontDesign") var appFontDesign: AppFontDesign = .standard
    @AppStorage("appFontSize") var appFontSize: AppFontSize = .small
    @AppStorage("appFontWidth") var appFontWidth: AppFontWidth = .standard
    @AppStorage("currentModelName") var currentModelName: String?
    @AppStorage("shouldPlayHaptics") var shouldPlayHaptics = true
    @AppStorage("showKeyboardOnLaunch") var showKeyboardOnLaunch = false
    @AppStorage("numberOfVisits") var numberOfVisits = 0
    @AppStorage("numberOfVisitsOfLastRequest") var numberOfVisitsOfLastRequest = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("userName") var userName = ""
    
    var hasInstalledModels: Bool { !installedModels.isEmpty }
    
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
    
    init() {
        loadInstalledModelsFromUserDefaults()
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
            // DeepSeek R1
            "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit": "DeepSeek R1 Distill Qwen (1.5B)",
            "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-8bit": "DeepSeek R1 Distill Qwen (1.5B)",
            "mlx-community/DeepSeek-R1-Distill-Llama-8B-4bit": "DeepSeek R1 Distill Llama (8B)",
            // Falcon 3
            "mlx-community/Falcon3-3B-Instruct-3bit": "Falcon 3 Instruct (3B)",
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
            // Gemma 3
            "mlx-community/gemma-3-1b-it-qat-4bit": "Gemma 3 QAT (1B)",
            "mlx-community/gemma-3-270m-it-4bit": "Gemma 3 (270M)",
            // Gemma 2
            "mlx-community/gemma-2-2b-it-4bit": "Gemma 2 (2B)",
            // Granite 4.0
            "mlx-community/granite-4.0-h-micro-4bit": "Granite 4.0 Micro (3B)",
            "mlx-community/granite-4.0-h-1b-4bit": "Granite 4.0 (1B)",
            "mlx-community/granite-4.0-h-350m-4bit": "Granite 4.0 (350M)",
            // Cogito v1
            "mlx-community/deepcogito-cogito-v1-preview-llama-3B-4bit": "Cogito v1 (3B)",
            // Llama 3.2
            "mlx-community/Llama-3.2-3B-Instruct-4bit": "Llama 3.2 Instruct (3B)",
            "mlx-community/Llama-3.2-1B-Instruct-4bit": "Llama 3.2 Instruct (1B)",
            // Qwen 3
            "mlx-community/Qwen3-VL-2B-4bit": "Qwen 3 VL (2B)",
            "mlx-community/Qwen3-4B-Thinking-4bit": "Qwen 3 Thinking (4B)",
            "mlx-community/Qwen3-4B-4bit": "Qwen 3 (4B)",
            "mlx-community/Qwen3-1.7B-4bit": "Qwen 3 (1.7B)",
            "mlx-community/Qwen3-0.6B-4bit": "Qwen 3 (0.6B)",
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
        let pattern = #"(\d+\.?\d*)B"#
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
    
    @Relationship(inverse: \Thread.messages) var thread: Thread?
    
    init(role: Role, content: String, thread: Thread? = nil, generatingTime: TimeInterval? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.thread = thread
        self.generatingTime = generatingTime
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
