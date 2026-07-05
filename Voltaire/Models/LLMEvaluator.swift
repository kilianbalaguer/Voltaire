//
//  LLMEvaluator.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import SwiftUI
import Hub

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
        LLMTypeRegistry.shared.registerModelType("mistral3") { url in
            let configuration = try JSONDecoder().decode(
                LlamaConfiguration.self,
                from: Data(contentsOf: url)
            )
            return LlamaModel(configuration)
        }

        LLMTypeRegistry.shared.registerModelType("qwen3_5") { url in
            let configuration = try JSONDecoder().decode(
                Qwen3Configuration.self,
                from: Data(contentsOf: url)
            )
            return Qwen3Model(configuration)
        }

        return LLMModelFactory(
            typeRegistry: LLMTypeRegistry.shared,
            modelRegistry: LLMRegistry.shared
        )
    }()

    func switchModel(_ model: ModelConfiguration) async {
        progress = 0.0 // reset progress
        loadState = .idle
        modelConfiguration = model
        _ = try? await load(modelName: model.name)
    }

    /// parameters controlling the output
    let generateParameters = GenerateParameters(temperature: 0.5)
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
            
            // === CREATE CUSTOM HubApi SO WE KNOW EXACTLY WHERE IT SAVES ===
            let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let hubBaseURL = cachesDir.appendingPathComponent("huggingface/hub", isDirectory: true)
            
            let hubApi = HubApi(downloadBase: hubBaseURL, useBackgroundSession: true)
            
            print("🟢 Starting download / load for: \(model.name)")
            print("📍 Saving models to: \(hubBaseURL.path)")
            
            // Optional: Also try Documents folder as fallback/debug
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("huggingface/hub", isDirectory: true)
            print("📍 Alternative (Documents): \(documentsDir.path)")
            
            let modelContainer = try await modelFactory.loadContainer(
                hub: hubApi,                    // ← Important: pass our custom hub
                configuration: model
            ) { [modelConfiguration] progress in
                Task { @MainActor in
                    self.modelInfo = "Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%"
                    self.progress = progress.fractionCompleted
                }
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

    func generate(modelName: String, thread: Thread, systemPrompt: String) async -> String {
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

            // augment the prompt as needed
            let promptHistory = model.getPromptHistory(thread: thread, systemPrompt: systemPrompt, useSystemRole: model.supportsSystemRole)

            if model.modelType == .reasoning {
                isThinking = true
            }

            // each time you generate you will get something new
            MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))

            func runGeneration(promptHistory: [[String: String]]) async throws -> Double {
                let result = try await modelContainer.perform { context in
                    let input = try await context.processor.prepare(input: .init(messages: promptHistory))
                    return try MLXLMCommon.generate(
                        input: input, parameters: generateParameters, context: context
                    ) { tokens in

                        var cancelled = false
                        Task { @MainActor in
                            cancelled = self.cancelled
                        }

                        // update the output -- this will make the view show the text as it generates
                        if tokens.count % displayEveryNTokens == 0 {
                            let text = context.tokenizer.decode(tokens: tokens)
                            Task { @MainActor in
                                self.output = text
                            }
                        }

                        // Check for end-of-turn token (Gemma, etc.)
                        let text = context.tokenizer.decode(tokens: tokens)
                        if text.contains("<end_of_turn>") {
                            Task { @MainActor in
                                self.output = text.replacingOccurrences(of: "<end_of_turn>", with: "")
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
                if result.output != output {
                    output = result.output
                }

                return result.tokensPerSecond
            }

            do {
                let tokensPerSecond = try await runGeneration(promptHistory: promptHistory)
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
                    let fallbackHistory = model.getPromptHistory(thread: thread, systemPrompt: systemPrompt, useSystemRole: false)
                    let tokensPerSecond = try await runGeneration(promptHistory: fallbackHistory)
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
