//
//  Models.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import MLXLMCommon
import CoreImage
import Foundation

public extension ModelConfiguration {
    enum ModelType {
        case regular, reasoning
    }
    
    var modelType: ModelType {
        switch self {
        case .qwen3_thinking_4b_4bit,
             .smollm3_3b_4bit,
             .lfm2_5_thinking_1_2b_4bit:
            return .reasoning
        default:
            return .regular
        }
    }

    /// Whether this model offers the thinking on/off switch: Thinking tag plus
    /// a real no-think mechanism (Qwen template flag, SmolLM3 system flag).
    var supportsThinkingSwitch: Bool {
        guard getModelTags(self).contains("Thinking") else { return false }
        return familyName.hasPrefix("Qwen") || familyName == "SmolLM 3" || familyName == "MiniCPM 5"
    }

    /// Whether this model can see attached photos (vision-language models).
    var supportsVision: Bool {
        switch self {
        case .lfm2_5_vl_1_6b_4bit, .lfm2_5_vl_450m_4bit,
             .lfm2_vl_3b_4bit, .lfm2_vl_1_6b_4bit, .lfm2_vl_450m_4bit,
             .qwen3_vl_2b_4bit, .qwen3_5_2b_4bit, .qwen3_5_0_8b_4bit,
             .ministral_3_3b_instruct_4bit, .gemma_3n_e2b_4bit:
            return true
        default:
            return false
        }
    }
}

extension ModelConfiguration: @retroactive Equatable {
    public static func == (lhs: MLXLMCommon.ModelConfiguration, rhs: MLXLMCommon.ModelConfiguration) -> Bool {
        return lhs.name == rhs.name
    }
    
    // MARK: - Bonsai
    
    public static let bonsai_ternary_8b_2bit = ModelConfiguration(
        id: "prism-ml/Ternary-Bonsai-8B-mlx-2bit"
    )
    
    public static let bonsai_8b_1bit = ModelConfiguration(
        id: "prism-ml/Bonsai-8B-mlx-1bit"
    )
    
    // MARK: - Qwen 3.5
    
    public static let qwen3_5_2b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3.5-2B-MLX-4bit"
    )
    
    public static let qwen3_5_0_8b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3.5-0.8B-MLX-4bit"
    )
    
    // MARK: - LFM 2.5
    
    public static let lfm2_5_vl_1_6b_4bit = ModelConfiguration(
        id: "mlx-community/LFM2.5-1.6B-VL-4bit"
    )
    
    public static let lfm2_5_vl_450m_4bit = ModelConfiguration(
        id: "mlx-community/LFM2.5-450M-VL-4bit"
    )
    
    public static let lfm2_5_thinking_1_2b_4bit = ModelConfiguration(
        id: "mlx-community/LFM2.5-1.2B-Thinking-4bit"
    )
    
    public static let lfm2_5_1_2b_4bit = ModelConfiguration(
        id: "mlx-community/LFM2.5-1.2B-4bit"
    )
    
    public static let lfm2_5_350m_4bit = ModelConfiguration(
        id: "mlx-community/LFM2.5-350M-4bit"
    )
    
    // MARK: - LFM 2
    
    public static let lfm2_vl_3b_4bit = ModelConfiguration(
        id: "mlx-community/LFM2-3B-VL-4bit"
    )
    
    public static let lfm2_vl_1_6b_4bit = ModelConfiguration(
        id: "mlx-community/LFM2-1.6B-VL-4bit"
    )
    
    public static let lfm2_vl_450m_4bit = ModelConfiguration(
        id: "mlx-community/LFM2-450M-VL-4bit"
    )
    
    public static let lfm2_exp_2_6b_4bit = ModelConfiguration(
        id: "mlx-community/LFM2-2.6B-Exp-4bit"
    )
    
    public static let lfm2_2_6b_4bit = ModelConfiguration(
        id: "mlx-community/LFM2-2.6B-4bit"
    )
    
    public static let lfm2_1_2b_4bit = ModelConfiguration(
        id: "mlx-community/LFM2-1.2B-4bit"
    )
    
    public static let lfm2_700m_4bit = ModelConfiguration(
        id: "mlx-community/LFM2-700M-4bit"
    )
    
    public static let lfm2_350m_4bit = ModelConfiguration(
        id: "mlx-community/LFM2-350M-4bit"
    )
    
    // MARK: - Ministral 3
    
    public static let ministral_3_3b_instruct_4bit = ModelConfiguration(
        id: "mlx-community/Ministral-3-3B-Instruct-2512-4bit"
    )
    
    // MARK: - SmolLM 3
    
    public static let smollm3_3b_4bit = ModelConfiguration(
        id: "mlx-community/SmolLM3-3B-4bit"
    )
    
    // MARK: - Gemma 3n
    
    public static let gemma_3n_e2b_4bit = ModelConfiguration(
        id: "mlx-community/gemma-3n-E2B-4bit"
    )
    
    // MARK: - Gemma 2
    
    public static let gemma_2_2b_it_4bit = ModelConfiguration(
        id: "mlx-community/gemma-2-2b-it-4bit"
    )
    
    // MARK: - Granite 4.0
    
    public static let granite_4_0_micro_4bit = ModelConfiguration(
        id: "mlx-community/granite-4.0-h-micro-4bit"
    )
    
    public static let granite_4_0_1b_4bit = ModelConfiguration(
        id: "mlx-community/granite-4.0-h-1b-4bit"
    )
    
    public static let granite_4_0_350m_4bit = ModelConfiguration(
        id: "mlx-community/granite-4.0-h-350m-4bit"
    )
    
    // MARK: - Llama 3.2
    
    public static let llama_3_2_3b_4bit = ModelConfiguration(
        id: "mlx-community/Llama-3.2-3B-Instruct-4bit"
    )
    
    public static let llama_3_2_1b_4bit = ModelConfiguration(
        id: "mlx-community/Llama-3.2-1B-Instruct-4bit"
    )
    
    // MARK: - Qwen 3
    
    public static let qwen3_vl_2b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3-VL-2B-4bit"
    )
    
    public static let qwen3_thinking_4b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3-4B-Thinking-4bit"
    )
    
    public static let qwen3_4b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3-4B-4bit"
    )
    
    public static let qwen3_1_7b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3-1.7B-4bit"
    )
    
    public static let qwen3_0_6b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3-0.6B-4bit"
    )
    
    // MARK: - MiniCPM
    
    public static let minicpm_1b_4bit = ModelConfiguration(
        id: "mlx-community/MiniCPM5-1B-4bit"
    )
    
    public static let minicpm_2b_4bit = ModelConfiguration(
        id: "mlx-community/MiniCPM5-2B-mlx-4Bit"
    )
    
    // MARK: - Available Models
    
    #if os(iOS)
    public static var availableModels: [ModelConfiguration] = [
        // Bonsai
        bonsai_ternary_8b_2bit,
        bonsai_8b_1bit,
        // Qwen 3.5
        qwen3_5_2b_4bit,
        qwen3_5_0_8b_4bit,
        // LFM 2.5
        lfm2_5_vl_1_6b_4bit,
        lfm2_5_vl_450m_4bit,
        lfm2_5_thinking_1_2b_4bit,
        lfm2_5_1_2b_4bit,
        lfm2_5_350m_4bit,
        // LFM 2
        lfm2_vl_3b_4bit,
        lfm2_vl_1_6b_4bit,
        lfm2_vl_450m_4bit,
        lfm2_exp_2_6b_4bit,
        lfm2_2_6b_4bit,
        lfm2_1_2b_4bit,
        lfm2_700m_4bit,
        lfm2_350m_4bit,
        // Ministral 3
        ministral_3_3b_instruct_4bit,
        // SmolLM 3
        smollm3_3b_4bit,
        // Gemma 3n
        gemma_3n_e2b_4bit,
        // Gemma 2
        gemma_2_2b_it_4bit,
        // Granite 4.0
        granite_4_0_micro_4bit,
        granite_4_0_1b_4bit,
        granite_4_0_350m_4bit,
        // Llama 3.2
        llama_3_2_3b_4bit,
        llama_3_2_1b_4bit,
        // Qwen 3
        qwen3_vl_2b_4bit,
        qwen3_thinking_4b_4bit,
        qwen3_4b_4bit,
        qwen3_1_7b_4bit,
        qwen3_0_6b_4bit,
        // MiniCPM
        minicpm_1b_4bit,
        minicpm_2b_4bit,
    ]
    #else
    public static var availableModels: [ModelConfiguration] = [
        bonsai_ternary_8b_2bit,
        bonsai_8b_1bit,
        qwen3_5_2b_4bit,
        qwen3_5_0_8b_4bit,
        lfm2_5_vl_1_6b_4bit,
        lfm2_5_vl_450m_4bit,
        lfm2_5_thinking_1_2b_4bit,
        lfm2_5_1_2b_4bit,
        lfm2_5_350m_4bit,
        lfm2_vl_3b_4bit,
        lfm2_vl_1_6b_4bit,
        lfm2_vl_450m_4bit,
        lfm2_exp_2_6b_4bit,
        lfm2_2_6b_4bit,
        lfm2_1_2b_4bit,
        lfm2_700m_4bit,
        lfm2_350m_4bit,
        ministral_3_3b_instruct_4bit,
        smollm3_3b_4bit,
        gemma_3n_e2b_4bit,
        gemma_2_2b_it_4bit,
        granite_4_0_micro_4bit,
        granite_4_0_1b_4bit,
        granite_4_0_350m_4bit,
        llama_3_2_3b_4bit,
        llama_3_2_1b_4bit,
        qwen3_vl_2b_4bit,
        qwen3_thinking_4b_4bit,
        qwen3_4b_4bit,
        qwen3_1_7b_4bit,
        qwen3_0_6b_4bit,
        // MiniCPM
        minicpm_1b_4bit,
        minicpm_2b_4bit,
    ]
    #endif
    
    public static var defaultModel: ModelConfiguration {
        #if os(iOS)
        qwen3_0_6b_4bit
        #else
        qwen3_4b_4bit
        #endif
    }
    
    public static func getModelByName(_ name: String) -> ModelConfiguration? {
        if let model = availableModels.first(where: { $0.name == name }) {
            return model
        } else {
            return nil
        }
    }

    var supportsSystemRole: Bool {
        switch self {
        case .gemma_2_2b_it_4bit, .gemma_3n_e2b_4bit:
            return false
        default:
            return true
        }
    }

    var requiresAlternatingRoles: Bool {
        switch self {
        case .gemma_2_2b_it_4bit, .gemma_3n_e2b_4bit:
            return true
        default:
            return false
        }
    }
    
    func getPromptHistory(thread: Thread, systemPrompt: String, useSystemRole: Bool = true) -> [[String: String]] {
        if requiresAlternatingRoles {
            return getAlternatingPromptHistory(thread: thread, systemPrompt: systemPrompt)
        }

        var history: [[String: String]] = []
        
        if !systemPrompt.isEmpty {
            history.append([
                "role": useSystemRole ? "system" : "user",
                "content": systemPrompt
            ])
        }
        
        for message in thread.sortedMessages {
            let role = message.role.rawValue
            history.append([
                "role": role,
                "content": formatForTokenizer(message.content),
            ])
        }
        
        return history
    }

    private func getAlternatingPromptHistory(thread: Thread, systemPrompt: String) -> [[String: String]] {
        var history: [[String: String]] = []
        var pendingUserPrefix = systemPrompt

        func append(role: String, content: String) {
            guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }

            if history.last?["role"] == role {
                history[history.count - 1]["content", default: ""] += "\n\n\(content)"
            } else {
                history.append([
                    "role": role,
                    "content": content,
                ])
            }
        }

        for message in thread.sortedMessages {
            switch message.role {
            case .system:
                pendingUserPrefix = [pendingUserPrefix, message.content]
                    .filter { !$0.isEmpty }
                    .joined(separator: "\n\n")

            case .user:
                let content = [pendingUserPrefix, formatForTokenizer(message.content)]
                    .filter { !$0.isEmpty }
                    .joined(separator: "\n\n")
                append(role: "user", content: content)
                pendingUserPrefix = ""

            case .assistant:
                guard !history.isEmpty else { continue }
                append(role: "assistant", content: formatForTokenizer(message.content))
            }
        }

        if history.isEmpty, !pendingUserPrefix.isEmpty {
            append(role: "user", content: pendingUserPrefix)
        }

        if history.last?["role"] == "assistant" {
            history.removeLast()
        }

        return history
    }

    /// Chat-message version of the prompt history for vision models, carrying
    /// any attached photos on their owning messages.
    func getChatMessages(thread: Thread, systemPrompt: String, useSystemRole: Bool = true) -> [Chat.Message] {
        func attachedImages(_ data: Data?) -> [UserInput.Image] {
            guard let data = data, let ciImage = CIImage(data: data) else { return [] }
            return [UserInput.Image.ciImage(ciImage)]
        }

        if requiresAlternatingRoles {
            var messages: [Chat.Message] = []
            var pendingPrefix = systemPrompt
            var pendingImages: [UserInput.Image] = []

            func appendUser(content: String, images: [UserInput.Image]) {
                let text = [pendingPrefix, content].filter { !$0.isEmpty }.joined(separator: "\n\n")
                let imgs = pendingImages + images
                pendingPrefix = ""
                pendingImages = []
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                if let last = messages.last, last.role == .user {
                    messages[messages.count - 1] = .user(last.content + "\n\n" + text, images: last.images + imgs)
                } else {
                    messages.append(.user(text, images: imgs))
                }
            }

            for message in thread.sortedMessages {
                switch message.role {
                case .system:
                    pendingPrefix = [pendingPrefix, message.content]
                        .filter { !$0.isEmpty }
                        .joined(separator: "\n\n")
                    pendingImages += attachedImages(message.imageData)
                case .user:
                    appendUser(content: formatForTokenizer(message.content), images: attachedImages(message.imageData))
                case .assistant:
                    guard !messages.isEmpty else { continue }
                    messages.append(.assistant(formatForTokenizer(message.content)))
                }
            }

            if messages.isEmpty, !pendingPrefix.isEmpty {
                appendUser(content: "", images: [])
            }

            if messages.last?.role == .assistant {
                messages.removeLast()
            }

            return messages
        }

        var messages: [Chat.Message] = []
        if !systemPrompt.isEmpty {
            messages.append(useSystemRole ? .system(systemPrompt) : .user(systemPrompt))
        }
        for message in thread.sortedMessages {
            let content = formatForTokenizer(message.content)
            switch message.role {
            case .system:
                messages.append(.system(content, images: attachedImages(message.imageData)))
            case .user:
                messages.append(.user(content, images: attachedImages(message.imageData)))
            case .assistant:
                messages.append(.assistant(content))
            }
        }
        return messages
    }
    
    func formatForTokenizer(_ message: String) -> String {
        if self.modelType == .reasoning {
            // Drop thinking traces from history so they don't pollute context.
            // Handles both <think>...</think> and bare ...</think> (some
            // reasoning models omit the opening tag).
            if let endRange = message.range(of: "</think>") {
                return " " + String(message[endRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return " " + message
                .replacingOccurrences(of: "<think>", with: "")
                .replacingOccurrences(of: "</think>", with: "")
        }
        
        return message
    }
    
    /// Returns the model's approximate size, in GB.
    public var modelSize: Decimal? {
        switch self {
        case .bonsai_ternary_8b_2bit: 2.1
        case .bonsai_8b_1bit: 1.2
        case .qwen3_5_2b_4bit: 2.22
        case .qwen3_5_0_8b_4bit: 1.03
        case .lfm2_5_vl_1_6b_4bit: 1.5
        case .lfm2_5_vl_450m_4bit: 0.471
        case .lfm2_5_thinking_1_2b_4bit: 0.956
        case .lfm2_5_1_2b_4bit: 0.663
        case .lfm2_5_350m_4bit: 0.399
        case .lfm2_vl_3b_4bit: 2.29
        case .lfm2_vl_1_6b_4bit: 1.47
        case .lfm2_vl_450m_4bit: 0.565
        case .lfm2_exp_2_6b_4bit: 1.45
        case .lfm2_2_6b_4bit: 1.45
        case .lfm2_1_2b_4bit: 0.663
        case .lfm2_700m_4bit: 0.784
        case .lfm2_350m_4bit: 0.382
        case .ministral_3_3b_instruct_4bit: 2.78
        case .smollm3_3b_4bit: 1.73
        case .gemma_3n_e2b_4bit: 2.51
        case .gemma_2_2b_it_4bit: 1.47
        case .granite_4_0_micro_4bit: 1.81
        case .granite_4_0_1b_4bit: 1.2
        case .granite_4_0_350m_4bit: 0.372
        case .llama_3_2_3b_4bit: 1.81
        case .llama_3_2_1b_4bit: 0.695
        case .qwen3_vl_2b_4bit: 1.8
        case .qwen3_thinking_4b_4bit: 2.26
        case .qwen3_4b_4bit: 2.26
        case .qwen3_1_7b_4bit: 0.979
        case .qwen3_0_6b_4bit: 0.346
        case .minicpm_1b_4bit: 0.608
        case .minicpm_2b_4bit: 1.42
        default: nil
        }
    }

    /// Display size: "x,x GB" for gigabytes, "xxx MB" for megabytes.
    public var formattedSize: String? {
        guard let size = modelSize else { return nil }
        let gb = NSDecimalNumber(decimal: size).doubleValue
        if gb < 1 {
            return "\(Int((gb * 1000).rounded())) MB"
        }
        return String(format: "%.1f", gb).replacingOccurrences(of: ".", with: ",") + " GB"
    }
    
    public var familyName: String {
        switch self {
        case .bonsai_ternary_8b_2bit, .bonsai_8b_1bit: "Bonsai"
        case .qwen3_5_2b_4bit, .qwen3_5_0_8b_4bit: "Qwen 3.5"
        case .lfm2_5_vl_1_6b_4bit, .lfm2_5_vl_450m_4bit, .lfm2_5_thinking_1_2b_4bit, .lfm2_5_1_2b_4bit, .lfm2_5_350m_4bit: "LFM 2.5"
        case .lfm2_vl_3b_4bit, .lfm2_vl_1_6b_4bit, .lfm2_vl_450m_4bit, .lfm2_exp_2_6b_4bit, .lfm2_2_6b_4bit, .lfm2_1_2b_4bit, .lfm2_700m_4bit, .lfm2_350m_4bit: "LFM 2"
        case .ministral_3_3b_instruct_4bit: "Ministral 3"
        case .smollm3_3b_4bit: "SmolLM 3"
        case .gemma_3n_e2b_4bit: "Gemma 3n"
        case .gemma_2_2b_it_4bit: "Gemma 2"
        case .granite_4_0_micro_4bit, .granite_4_0_1b_4bit, .granite_4_0_350m_4bit: "Granite 4.0"
        case .llama_3_2_3b_4bit, .llama_3_2_1b_4bit: "LLaMa 3.2"
        case .qwen3_vl_2b_4bit, .qwen3_thinking_4b_4bit, .qwen3_4b_4bit, .qwen3_1_7b_4bit, .qwen3_0_6b_4bit: "Qwen 3"
        case .minicpm_1b_4bit, .minicpm_2b_4bit: "MiniCPM 5"
        default: self.name.replacing("mlx-community/", with: "").components(separatedBy: "-")[0].capitalized
        }
    }
}
