//
//  CreditsView.swift
//  Voltaire
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        Form {
            Section("Models") {
                Group {
                    Link("DeepSeek R1 Distill (Qwen 1.5B)", destination: URL(string: "https://huggingface.co/mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit")!)
                        .badge("MIT")
                    Link("DeepSeek R1 Distill (Qwen 1.5B, 8bit)", destination: URL(string: "https://huggingface.co/mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-8bit")!)
                        .badge("MIT")
                    Link("DeepSeek R1 Distill (Llama 8B)", destination: URL(string: "https://huggingface.co/mlx-community/DeepSeek-R1-Distill-Llama-8B-4bit")!)
                        .badge("MIT")
                }
                Group {
                    Link("Falcon 3 3B Instruct", destination: URL(string: "https://huggingface.co/mlx-community/Falcon3-3B-Instruct-3bit")!)
                        .badge("Apache-2.0")
                    Link("Bonsai 8B (1bit)", destination: URL(string: "https://huggingface.co/prism-ml/Bonsai-8B-mlx-1bit")!)
                        .badge("Apache-2.0")
                    Link("Ternary Bonsai 8B (2bit)", destination: URL(string: "https://huggingface.co/prism-ml/Ternary-Bonsai-8B-mlx-2bit")!)
                        .badge("Apache-2.0")
                }
                Group {
                    Link("Qwen 3.5 2B", destination: URL(string: "https://huggingface.co/mlx-community/Qwen3.5-2B-MLX-4bit")!)
                        .badge("Apache-2.0")
                    Link("Qwen 3.5 0.8B", destination: URL(string: "https://huggingface.co/mlx-community/Qwen3.5-0.8B-MLX-4bit")!)
                        .badge("Apache-2.0")
                    Link("Qwen 3 4B", destination: URL(string: "https://huggingface.co/mlx-community/Qwen3-4B-4bit")!)
                        .badge("Apache-2.0")
                    Link("Qwen 3 4B Thinking", destination: URL(string: "https://huggingface.co/mlx-community/Qwen3-4B-Thinking-4bit")!)
                        .badge("Apache-2.0")
                    Link("Qwen 3 1.7B", destination: URL(string: "https://huggingface.co/mlx-community/Qwen3-1.7B-4bit")!)
                        .badge("Apache-2.0")
                    Link("Qwen 3 0.6B", destination: URL(string: "https://huggingface.co/mlx-community/Qwen3-0.6B-4bit")!)
                        .badge("Apache-2.0")
                    Link("Qwen 3 VL 2B", destination: URL(string: "https://huggingface.co/mlx-community/Qwen3-VL-2B-4bit")!)
                        .badge("Apache-2.0")
                }
                Group {
                    Link("LFM2.5 1.6B VL", destination: URL(string: "https://huggingface.co/mlx-community/LFM2.5-1.6B-VL-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2.5 450M VL", destination: URL(string: "https://huggingface.co/mlx-community/LFM2.5-450M-VL-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2.5 1.2B Thinking", destination: URL(string: "https://huggingface.co/mlx-community/LFM2.5-1.2B-Thinking-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2.5 1.2B", destination: URL(string: "https://huggingface.co/mlx-community/LFM2.5-1.2B-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2.5 350M", destination: URL(string: "https://huggingface.co/mlx-community/LFM2.5-350M-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2 3B VL", destination: URL(string: "https://huggingface.co/mlx-community/LFM2-3B-VL-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2 2.6B", destination: URL(string: "https://huggingface.co/mlx-community/LFM2-2.6B-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2 1.2B", destination: URL(string: "https://huggingface.co/mlx-community/LFM2-1.2B-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2 700M", destination: URL(string: "https://huggingface.co/mlx-community/LFM2-700M-4bit")!)
                        .badge("Apache-2.0")
                    Link("LFM2 350M", destination: URL(string: "https://huggingface.co/mlx-community/LFM2-350M-4bit")!)
                        .badge("Apache-2.0")
                }
                Group {
                    Link("Ministral 3B", destination: URL(string: "https://huggingface.co/mlx-community/Ministral-3-3B-Instruct-2512-4bit")!)
                        .badge("Apache-2.0")
                    Link("SmolLM3 3B", destination: URL(string: "https://huggingface.co/mlx-community/SmolLM3-3B-4bit")!)
                        .badge("Apache-2.0")
                    Link("Gemma 3n E2B", destination: URL(string: "https://huggingface.co/mlx-community/gemma-3n-E2B-4bit")!)
                        .badge("Gemma")
                    Link("Gemma 3 1B", destination: URL(string: "https://huggingface.co/mlx-community/gemma-3-1b-it-qat-4bit")!)
                        .badge("Gemma")
                    Link("Gemma 3 270M", destination: URL(string: "https://huggingface.co/mlx-community/gemma-3-270m-it-4bit")!)
                        .badge("Gemma")
                    Link("Gemma 2 2B", destination: URL(string: "https://huggingface.co/mlx-community/gemma-2-2b-it-4bit")!)
                        .badge("Gemma")
                }
                Group {
                    Link("Granite 4.0 Micro", destination: URL(string: "https://huggingface.co/mlx-community/granite-4.0-h-micro-4bit")!)
                        .badge("Apache-2.0")
                    Link("Granite 4.0 1B", destination: URL(string: "https://huggingface.co/mlx-community/granite-4.0-h-1b-4bit")!)
                        .badge("Apache-2.0")
                    Link("Granite 4.0 350M", destination: URL(string: "https://huggingface.co/mlx-community/granite-4.0-h-350m-4bit")!)
                        .badge("Apache-2.0")
                    Link("Cogito v1 Preview 3B", destination: URL(string: "https://huggingface.co/mlx-community/deepcogito-cogito-v1-preview-llama-3B-4bit")!)
                        .badge("Apache-2.0")
                    Link("Llama 3.2 3B", destination: URL(string: "https://huggingface.co/mlx-community/Llama-3.2-3B-Instruct-4bit")!)
                        .badge("Llama")
                    Link("Llama 3.2 1B", destination: URL(string: "https://huggingface.co/mlx-community/Llama-3.2-1B-Instruct-4bit")!)
                        .badge("Llama")
                }
            }

            Section("Libraries") {
                Link("MLX Swift", destination: URL(string: "https://github.com/ml-explore/mlx-swift")!)
                    .badge("MIT")
                Link("MLX Swift Examples", destination: URL(string: "https://github.com/ml-explore/mlx-swift-examples")!)
                    .badge("MIT")
                Link("Swift Markdown UI", destination: URL(string: "https://github.com/gonzalezreal/swift-markdown-ui")!)
                    .badge("MIT")
                Link("LaTeXSwiftUI", destination: URL(string: "https://github.com/colinc86/LaTeXSwiftUI")!)
                    .badge("MIT")
                Link("SwiftUI Shimmer", destination: URL(string: "https://github.com/markiv/SwiftUI-Shimmer")!)
                    .badge("MIT")
                Link("SlideButton", destination: URL(string: "https://github.com/no-comment/SlideButton")!)
                    .badge("MIT")
            }

            Section("Acknowledgements") {
                Text("All models are sourced from Hugging Face and are converted for MLX by the mlx-community organization. Model weights are subject to their respective licenses as indicated.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Text("This app uses the MLX framework by Apple for on-device machine learning inference. MLX is open source under the MIT license.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .modifier(CustomNavTitle(title: "Credits"))
        .navigationPopGestureDisabled(true)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    CreditsView()
}
