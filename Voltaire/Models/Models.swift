//
//  Models.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import MLXLMCommon
import Foundation

public extension ModelConfiguration {
    enum ModelType {
        case regular, reasoning
    }
    
    var modelType: ModelType {
        switch self {
        case .deepseek_r1_distill_qwen_1_5b_4bit, .deepseek_r1_distill_llama_8b_4bit,
             .qwen3_thinking_4b_4bit,
             .smollm3_3b_4bit, .cogito_v1_3b_4bit,
             .lfm2_5_thinking_1_2b_4bit:
            return .reasoning
        default:
            return .regular
        }
    }
}

extension ModelConfiguration: @retroactive Equatable {
    public static func == (lhs: MLXLMCommon.ModelConfiguration, rhs: MLXLMCommon.ModelConfiguration) -> Bool {
        return lhs.name == rhs.name
    }
    
    // MARK: - DeepSeek R1 (kept)
    
    public static let deepseek_r1_distill_qwen_1_5b_4bit = ModelConfiguration(
        id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit"
    )
    
    public static let deepseek_r1_distill_qwen_1_5b_8bit = ModelConfiguration(
        id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-8bit"
    )
    
    public static let deepseek_r1_distill_llama_8b_4bit = ModelConfiguration(
        id: "mlx-community/DeepSeek-R1-Distill-Llama-8B-4bit"
    )
    
    // MARK: - Falcon 3 (kept)
    
    public static let falcon3_3b_instruct_3bit = ModelConfiguration(
        id: "mlx-community/Falcon3-3B-Instruct-3bit"
    )
    
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
    
    // MARK: - Gemma 3
    
    public static let gemma_3_qat_1b_4bit = ModelConfiguration(
        id: "mlx-community/gemma-3-1b-it-qat-4bit"
    )
    
    public static let gemma_3_270m_4bit = ModelConfiguration(
        id: "mlx-community/gemma-3-270m-it-4bit"
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
    
    // MARK: - Cogito v1
    
    public static let cogito_v1_3b_4bit = ModelConfiguration(
        id: "mlx-community/deepcogito-cogito-v1-preview-llama-3B-4bit"
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
    
    // MARK: - Available Models
    
    #if os(iOS)
    public static var availableModels: [ModelConfiguration] = [
        // DeepSeek R1
        deepseek_r1_distill_qwen_1_5b_4bit,
        deepseek_r1_distill_qwen_1_5b_8bit,
        deepseek_r1_distill_llama_8b_4bit,
        // Falcon 3
        falcon3_3b_instruct_3bit,
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
        // Gemma 3
        gemma_3_qat_1b_4bit,
        gemma_3_270m_4bit,
        // Gemma 2
        gemma_2_2b_it_4bit,
        // Granite 4.0
        granite_4_0_micro_4bit,
        granite_4_0_1b_4bit,
        granite_4_0_350m_4bit,
        // Cogito v1
        cogito_v1_3b_4bit,
        // Llama 3.2
        llama_3_2_3b_4bit,
        llama_3_2_1b_4bit,
        // Qwen 3
        qwen3_vl_2b_4bit,
        qwen3_thinking_4b_4bit,
        qwen3_4b_4bit,
        qwen3_1_7b_4bit,
        qwen3_0_6b_4bit,
    ]
    #else
    public static var availableModels: [ModelConfiguration] = [
        deepseek_r1_distill_llama_8b_4bit,
        deepseek_r1_distill_qwen_1_5b_8bit,
        deepseek_r1_distill_qwen_1_5b_4bit,
        falcon3_3b_instruct_3bit,
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
        gemma_3_qat_1b_4bit,
        gemma_3_270m_4bit,
        gemma_2_2b_it_4bit,
        granite_4_0_micro_4bit,
        granite_4_0_1b_4bit,
        granite_4_0_350m_4bit,
        cogito_v1_3b_4bit,
        llama_3_2_3b_4bit,
        llama_3_2_1b_4bit,
        qwen3_vl_2b_4bit,
        qwen3_thinking_4b_4bit,
        qwen3_4b_4bit,
        qwen3_1_7b_4bit,
        qwen3_0_6b_4bit,
    ]
    #endif
    
    public static var defaultModel: ModelConfiguration {
        #if os(iOS)
        qwen3_0_6b_4bit
        #else
        deepseek_r1_distill_llama_8b_4bit
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
        case .gemma_2_2b_it_4bit, .gemma_3_qat_1b_4bit, .gemma_3_270m_4bit, .gemma_3n_e2b_4bit:
            return false
        default:
            return true
        }
    }

    var requiresAlternatingRoles: Bool {
        switch self {
        case .gemma_2_2b_it_4bit, .gemma_3_qat_1b_4bit, .gemma_3_270m_4bit, .gemma_3n_e2b_4bit:
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
    
    func formatForTokenizer(_ message: String) -> String {
        if self.modelType == .reasoning {
            return " " + message
                .replacingOccurrences(of: "<think>", with: "")
                .replacingOccurrences(of: "</think>", with: "")
        }
        
        return message
    }
    
    /// Returns the model's approximate size, in GB.
    public var modelSize: Decimal? {
        switch self {
        case .deepseek_r1_distill_qwen_1_5b_4bit: 1
        case .deepseek_r1_distill_llama_8b_4bit: 4.5
        case .falcon3_3b_instruct_3bit: 1.8
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
        case .gemma_3_qat_1b_4bit: 0.733
        case .gemma_3_270m_4bit: 0.463
        case .gemma_2_2b_it_4bit: 1.47
        case .granite_4_0_micro_4bit: 1.81
        case .granite_4_0_1b_4bit: 1.2
        case .granite_4_0_350m_4bit: 0.372
        case .cogito_v1_3b_4bit: 1.82
        case .llama_3_2_3b_4bit: 1.81
        case .llama_3_2_1b_4bit: 0.695
        case .qwen3_vl_2b_4bit: 1.8
        case .qwen3_thinking_4b_4bit: 2.26
        case .qwen3_4b_4bit: 2.26
        case .qwen3_1_7b_4bit: 0.979
        case .qwen3_0_6b_4bit: 0.346
        default: nil
        }
    }
    
    public var familyName: String {
        switch self {
        case .deepseek_r1_distill_qwen_1_5b_4bit, .deepseek_r1_distill_qwen_1_5b_8bit, .deepseek_r1_distill_llama_8b_4bit: "DeepSeek R1"
        case .falcon3_3b_instruct_3bit: "Falcon 3"
        case .bonsai_ternary_8b_2bit, .bonsai_8b_1bit: "Bonsai"
        case .qwen3_5_2b_4bit, .qwen3_5_0_8b_4bit: "Qwen 3.5"
        case .lfm2_5_vl_1_6b_4bit, .lfm2_5_vl_450m_4bit, .lfm2_5_thinking_1_2b_4bit, .lfm2_5_1_2b_4bit, .lfm2_5_350m_4bit: "LFM 2.5"
        case .lfm2_vl_3b_4bit, .lfm2_vl_1_6b_4bit, .lfm2_vl_450m_4bit, .lfm2_exp_2_6b_4bit, .lfm2_2_6b_4bit, .lfm2_1_2b_4bit, .lfm2_700m_4bit, .lfm2_350m_4bit: "LFM 2"
        case .ministral_3_3b_instruct_4bit: "Ministral 3"
        case .smollm3_3b_4bit: "SmolLM 3"
        case .gemma_3n_e2b_4bit: "Gemma 3n"
        case .gemma_3_qat_1b_4bit, .gemma_3_270m_4bit: "Gemma 3"
        case .gemma_2_2b_it_4bit: "Gemma 2"
        case .granite_4_0_micro_4bit, .granite_4_0_1b_4bit, .granite_4_0_350m_4bit: "Granite 4.0"
        case .cogito_v1_3b_4bit: "Cogito v1"
        case .llama_3_2_3b_4bit, .llama_3_2_1b_4bit: "LLaMa 3.2"
        case .qwen3_vl_2b_4bit, .qwen3_thinking_4b_4bit, .qwen3_4b_4bit, .qwen3_1_7b_4bit, .qwen3_0_6b_4bit: "Qwen 3"
        default: self.name.replacing("mlx-community/", with: "").components(separatedBy: "-")[0].capitalized
        }
    }
}
