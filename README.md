# Voltaire

> "No problem can withstand the assault of sustained thinking"
> — Voltaire

Voltaire is an on-device AI chat app for iPhone, built with Swift and MLX. It runs large language models locally with no cloud processing, no data collection, and no account required. Complete privacy by design.

## Features

- **Text & Vision** — Chat with text and vision-language models directly on your device
- **Thinking Mode** — Reasoning models with a thinking on/off toggle where supported
- **100% Private** — Zero data collection, zero cloud processing
- **30+ Models** — Llama, Gemma, Qwen, MiniCPM 5, LFM, Granite, and more
- **Clean UI** — Minimal, focused interface built for everyday use
- **Offline** — Works without any internet connection once models are downloaded

## Supported Models

| Model | Family | Size |
|-------|--------|------|
| Bonsai (8B, 1-bit / 2-bit) | Bonsai | 8B |
| Qwen 3.5 2B / 0.8B | Qwen 3.5 | 2B / 0.8B |
| Qwen 3 4B / 1.7B / 0.6B | Qwen 3 | 4B / 1.7B / 0.6B |
| Qwen 3 VL 2B | Qwen 3 | 2B |
| Qwen 3 Thinking 4B | Qwen 3 | 4B |
| LFM 2.5 VL 1.6B / 450M | LFM 2.5 | 1.6B / 450M |
| LFM 2.5 Thinking 1.2B | LFM 2.5 | 1.2B |
| LFM 2.5 1.2B / 350M | LFM 2.5 | 1.2B / 350M |
| LFM 2 VL 3B / 1.6B / 450M | LFM 2 | 3B / 1.6B / 450M |
| LFM 2 2.6B / 1.2B / 700M / 350M | LFM 2 | 2.6B / 1.2B / 700M / 350M |
| Ministral 3 Instruct 3B | Ministral 3 | 3B |
| SmolLM 3 | SmolLM 3 | 3B |
| Gemma 3n | Gemma 3n | 2B |
| Gemma 2 2B | Gemma 2 | 2B |
| Granite 4.0 Micro / 1B / 350M | Granite 4.0 | 3B / 1B / 350M |
| Llama 3.2 Instruct 3B / 1B | LLaMa 3.2 | 3B / 1B |
| MiniCPM 5 (1B) | MiniCPM 5 | 1B |
| MiniCPM 5 (2B) | MiniCPM 5 | 2B |

All models are downloaded from Hugging Face and stored locally on your device.

## Tech Stack

- **Swift** — Native iOS development
- **MLX** — Apple's machine learning framework for Apple Silicon
- **SwiftData** — Local data persistence
- **Hugging Face Hub** — Model downloads with background sessions

## Requirements

- iOS 26.0+
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
