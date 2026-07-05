# Voltaire

> "No problem can withstand the assault of sustained thinking"
> — Voltaire

Voltaire is an on-device AI chat app for iPhone, built with Swift and MLX. It runs large language models locally with no cloud processing, no data collection, and no account required. Complete privacy by design.

## Features

- **Text Conversations** — Chat with powerful AI models directly on your device
- **Vision Models** — Vision-capable models available for download (in-app support coming soon)
- **100% Private** — Zero data collection, zero cloud processing
- **40+ Models** — Llama, Gemma, Qwen, DeepSeek, Cogito, and more
- **Clean UI** — Minimal, focused interface built for everyday use
- **Offline** — Works without any internet connection once models are downloaded

## Supported Models

| Model | Family | Size |
|-------|--------|------|
| Llama 3.2 1B | LLaMA | 1B |
| Llama 3.2 3B | LLaMA | 3B |
| Llama 3.1 8B | LLaMA | 8B |
| Gemma 2 2B | Gemma | 2B |
| Gemma 3 4B | Gemma | 4B |
| Gemma 3 12B | Gemma | 12B |
| Gemma 3 27B | Gemma | 27B |
| Gemma 3n E2B | Gemma | 2B |
| Gemma 3n E4B | Gemma | 4B |
| Qwen 2.5 1.5B | Qwen | 1.5B |
| Qwen 2.5 3B | Qwen | 3B |
| Qwen 2.5 7B | Qwen | 7B |
| Qwen 3 0.6B | Qwen | 0.6B |
| Qwen 3 1.7B | Qwen | 1.7B |
| Qwen 3 4B | Qwen | 4B |
| Qwen 3 8B | Qwen | 8B |
| DeepSeek R1 1.5B | DeepSeek | 1.5B |
| DeepSeek R1 8B | DeepSeek | 8B |
| DeepSeek R1 14B | DeepSeek | 14B |
| DeepSeek R1 32B | DeepSeek | 32B |
| Falcon 3 3B | Falcon | 3B |
| SmolLM 135M | SmolLM | 135M |
| SmolLM 360M | SmolLM | 360M |
| SmolLM 1.7B | SmolLM | 1.7B |
| Granite 3 2B | Granite | 2B |
| Granite 3 8B | Granite | 8B |
| Cogito 1B | LLaMA | 1B |
| Cogito 3B | LLaMA | 3B |
| Cogito 8B | LLaMA | 8B |
| Cogito 14B | LLaMA | 14B |
| Cogito 32B | LLaMA | 32B |
| Cogito 70B | LLaMA | 70B |
| LFM 150M | LFM | 150M |
| LFM 400M | LFM | 400M |
| LFM 1B | LFM | 1B |

All models are downloaded from Hugging Face and stored locally on your device.

## Tech Stack

- **Swift** — Native iOS development
- **MLX** — Apple's machine learning framework for Apple Silicon
- **SwiftData** — Local data persistence
- **Hugging Face Hub** — Model downloads with background sessions

## Requirements

- iOS 17.0+
- Apple Silicon device (iPhone 15 Pro or later recommended for larger models)

## Installation

1. Open `Voltaire.xcodeproj` in Xcode
2. Select your development team
3. Build and run on your device

## Privacy

Voltaire is built with privacy as a core principle:

- No account required
- No data transmission
- No analytics or tracking
- All processing on-device
- Delete all data anytime from settings

See [LICENSE](./LICENSE) for terms of use.

## Credits

- [MLX Swift](https://github.com/ml-explore/mlx-swift) — Apple's array framework for machine learning on Apple Silicon
- [MLX](https://github.com/ml-explore/mlx) — Core ML framework
- [Hugging Face Hub](https://huggingface.co) — Model hosting and distribution
- [LaTeXSwiftUI](https://github.com/colinc86/LaTeXSwiftUI) — LaTeX rendering

## License

This project is licensed under the **Voltaire Source Available License** — see the [LICENSE](./LICENSE) file for details. The source code is available for viewing and learning, but redistribution, commercial use, and derivative works are not permitted.
