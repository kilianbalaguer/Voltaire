//
//  LLMEvaluator.swift
//  Voltaire
//
//  Created by Kilian Balaguer on 10/7/26.
//

import MLX
import MLXLLM
import MLXLMCommon
import MLXVLM
import MLXHuggingFace
import MLXRandom
import SwiftUI
import HuggingFace
import Tokenizers

enum LLMEvaluatorError: Error {
    case modelNotFound(String)
}

@Observable
@MainActor
class LLMEvaluator {
    var running = false
    var cancelled = false
    var output = ""
    var modelInfo = ""
    var stat = ""
    var progress = 0.0
    var thinkingTime: TimeInterval?
    var collapsed: Bool = false
    var isThinking: Bool = false

    var elapsedTime: TimeInterval? {
        if let startTime {
            return Date().timeIntervalSince(startTime)
        }

        return nil
    }

    private var startTime: Date?

    var modelConfiguration = ModelConfiguration.defaultModel

    private let modelFactory: LLMModelFactory = {
        LLMModelFactory(
            typeRegistry: LLMTypeRegistry.shared,
            modelRegistry: LLMRegistry.shared
        )
    }()

    private let vlmFactory: VLMModelFactory = {
        VLMModelFactory(
            typeRegistry: VLMTypeRegistry.shared,
            processorRegistry: VLMProcessorTypeRegistry.shared,
            modelRegistry: VLMRegistry.shared
        )
    }()

    func switchModel(_ model: ModelConfiguration) async {
        progress = 0.0 // reset progress
        loadState = .idle
        modelConfiguration = model
        _ = try? await load(modelName: model.name)
    }

    /// parameters controlling the output (repetition penalty stops
    /// small models like Gemma from looping the same sentences)
    var generateParameters: GenerateParameters {
        let enabled = UserDefaults.standard.bool(forKey: "customizationEnabled")
        let selection = UserDefaults.standard.string(forKey: "customTemperature") ?? "Default"
        let temperature: Double = enabled ? AppManager.temperatureValue(for: selection) : 0.5
        return GenerateParameters(
            temperature: Float(temperature),
            topP: 0.95,
            repetitionPenalty: 1.1,
            repetitionContextSize: 64
        )
    }
    let maxTokens = 4096

    /// update the display every N tokens -- 4 looks like it updates continuously
    /// and is low overhead.  observed ~15% reduction in tokens/s when updating
    /// on every token
    let displayEveryNTokens = 4

    enum LoadState {
        case idle
        case loading
        case loaded(ModelContainer)
    }

    var loadState = LoadState.idle

    /// load and return the model -- can be called multiple times, subsequent calls will
    /// just return the loaded model
    /// load and return the model
    func load(modelName: String) async throws -> ModelContainer {
        guard let model = ModelConfiguration.getModelByName(modelName) else {
            throw LLMEvaluatorError.modelNotFound(modelName)
        }

        switch loadState {
        case .idle, .loading:
            MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
            
            await MainActor.run {
                self.loadState = .loading
            }
            
            // Custom cache location (same layout as before: caches/huggingface/hub)
            let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let hubBaseURL = cachesDir.appendingPathComponent("huggingface/hub", isDirectory: true)

            let hubClient = HubClient(cache: HubCache(cacheDirectory: hubBaseURL))

            print("🟢 Starting download / load for: \(model.name)")
            print("📍 Saving models to: \(hubBaseURL.path)")

            // Optional: Also try Documents folder as fallback/debug
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("huggingface/hub", isDirectory: true)
            print("📍 Alternative (Documents): \(documentsDir.path)")

            let downloader = #hubDownloader(hubClient)
            let tokenizerLoader = #huggingFaceTokenizerLoader()
            let progressHandler: @Sendable (Progress) -> Void = { [modelConfiguration] progress in
                Task { @MainActor in
                    self.modelInfo = "Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%"
                    self.progress = progress.fractionCompleted
                }
            }

            // Vision-language models load through the VLM factory (same container type)
            let modelContainer: ModelContainer
            if model.supportsVision {
                modelContainer = try await vlmFactory.loadContainer(
                    from: downloader,
                    using: tokenizerLoader,
                    configuration: model,
                    progressHandler: progressHandler
                )
            } else {
                modelContainer = try await modelFactory.loadContainer(
                    from: downloader,
                    using: tokenizerLoader,
                    configuration: model,
                    progressHandler: progressHandler
                )
            }
            
            print("✅ Model successfully loaded from: \(hubBaseURL.path)")
            
            modelInfo = "Loaded \(modelConfiguration.id). Weights: \(MLX.GPU.activeMemory / 1024 / 1024)M"
            loadState = .loaded(modelContainer)
            return modelContainer

        case let .loaded(modelContainer):
            print("♻️ Model already loaded (no download needed)")
            return modelContainer
        }
    }

    func stop() {
        isThinking = false
        cancelled = true
    }

    nonisolated private func stripThinkingFromText(_ text: String) -> String {
        if let end = text.range(of: "</think>") {
            return String(text[end.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let start = text.range(of: "<think>") {
            return String(text[..<start.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }

    func generate(modelName: String, thread: Thread, systemPrompt: String, thinkingEnabled: Bool = true) async -> String {
        guard !running else { return "" }

        running = true
        cancelled = false
        output = ""
        startTime = Date()

        do {
            guard let model = ModelConfiguration.getModelByName(modelName) else {
                output = "Failed: \(LLMEvaluatorError.modelNotFound(modelName))"
                running = false
                return output
            }

            let modelContainer = try await load(modelName: modelName)

            // Real no-thinking support (switch OFF): only for Thinking-tagged models.
            // Qwen reads enable_thinking=false (template kwarg) + /no_think on the
            // user message; SmolLM3 reads /no_think in the system message. LFM's
            // thinking variant has no template switch, so its thinking is hidden instead.
            let supportsNoThink = getModelTags(model).contains("Thinking")
            let noThink = !thinkingEnabled && supportsNoThink
            let isQwen = model.familyName.hasPrefix("Qwen")
            let isSmolLM = model.familyName == "SmolLM 3"
            let hardSwitch = noThink && (isQwen || isSmolLM)
            let stripOnly = noThink && !hardSwitch
            let templateContext: [String: any Sendable]? = hardSwitch ? ["enable_thinking": false, "thinking_budget": 0] : nil

            func buildHistory(useSystemRole: Bool) -> [[String: String]] {
                var sys = systemPrompt
                if noThink && isSmolLM {
                    sys += " /no_think"
                }
                var history = model.getPromptHistory(thread: thread, systemPrompt: sys, useSystemRole: useSystemRole)
                if noThink && isQwen {
                    if let idx = history.lastIndex(where: { $0["role"] == "user" }) {
                        history[idx]["content"] = (history[idx]["content"] ?? "") + " /no_think"
                    }
                }
                return history
            }

            func buildChatMessages(useSystemRole: Bool) -> [Chat.Message] {
                var sys = systemPrompt
                if noThink && isSmolLM {
                    sys += " /no_think"
                }
                var messages = model.getChatMessages(thread: thread, systemPrompt: sys, useSystemRole: useSystemRole)
                if noThink && isQwen {
                    if let idx = messages.lastIndex(where: { $0.role == .user }) {
                        var updated = messages[idx]
                        updated.content += " /no_think"
                        messages[idx] = updated
                    }
                }
                return messages
            }

            // augment the prompt as needed
            let promptHistory = buildHistory(useSystemRole: model.supportsSystemRole)

            // Vision path: structured chat messages carrying attached photos
            // (only when the model supports vision and photos are present)
            let useVisionInput = model.supportsVision && thread.sortedMessages.contains { $0.imageData != nil }
            let chatMessages: [Chat.Message]? = useVisionInput
                ? buildChatMessages(useSystemRole: model.supportsSystemRole)
                : nil

            if !noThink && (model.modelType == .reasoning || supportsNoThink) {
                isThinking = true
            }

            // each time you generate you will get something new
            MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))

            func runGeneration(promptHistory: [[String: String]], chatMessages: [Chat.Message]?) async throws -> Double {
                let parameters = generateParameters
                let result = try await modelContainer.perform { context in
                    let input: UserInput
                    if let chatMessages {
                        input = UserInput(chat: chatMessages, additionalContext: templateContext)
                    } else {
                        input = UserInput(messages: promptHistory, additionalContext: templateContext)
                    }
                    let prepared = try await context.processor.prepare(input: input)
                    return try MLXLMCommon.generate(
                        input: prepared, parameters: parameters, context: context
                    ) { tokens in

                        var cancelled = false
                        Task { @MainActor in
                            cancelled = self.cancelled
                        }

                        // update the output -- this will make the view show the text as it generates
                        if tokens.count % displayEveryNTokens == 0 {
                            let text = context.tokenizer.decode(tokenIds: tokens)
                            let display = stripOnly ? self.stripThinkingFromText(text) : text
                            Task { @MainActor in
                                self.output = display
                            }
                        }

                        // Check for end-of-turn token (Gemma, etc.)
                        let text = context.tokenizer.decode(tokenIds: tokens)
                        if text.contains("<end_of_turn>") {
                            Task { @MainActor in
                                let cleaned = text.replacingOccurrences(of: "<end_of_turn>", with: "")
                                self.output = stripOnly ? self.stripThinkingFromText(cleaned) : cleaned
                            }
                            return .stop
                        }

                        if tokens.count >= maxTokens || cancelled {
                            return .stop
                        } else {
                            return .more
                        }
                    }
                }

                // update the text if needed, e.g. we haven't displayed because of displayEveryNTokens
                let finalText = stripOnly ? stripThinkingFromText(result.output) : result.output
                if finalText != output {
                    output = finalText
                }

                return result.tokensPerSecond
            }

            do {
                let tokensPerSecond = try await runGeneration(promptHistory: promptHistory, chatMessages: chatMessages)
                stat = " Tokens/second: \(String(format: "%.3f", tokensPerSecond))"
            } catch {
                let errorText = String(describing: error)
                let isSystemRoleError = error.localizedDescription.localizedCaseInsensitiveContains("system role")
                    || errorText.localizedCaseInsensitiveContains("system role")
                    || errorText.localizedCaseInsensitiveContains("templateexception")

                let isAlternatingRoleError = error.localizedDescription.localizedCaseInsensitiveContains("alternate")
                    || errorText.localizedCaseInsensitiveContains("alternate")
                    || errorText.localizedCaseInsensitiveContains("Conversation roles must alternate")

                if isSystemRoleError || isAlternatingRoleError {
                    let fallbackHistory = buildHistory(useSystemRole: false)
                    let fallbackChat: [Chat.Message]? = useVisionInput ? buildChatMessages(useSystemRole: false) : nil
                    let tokensPerSecond = try await runGeneration(promptHistory: fallbackHistory, chatMessages: fallbackChat)
                    stat = " Tokens/second: \(String(format: "%.3f", tokensPerSecond))"
                } else {
                    throw error
                }
            }

        } catch {
            output = "Failed: \(error)"
        }

        running = false
        return output
    }
}
