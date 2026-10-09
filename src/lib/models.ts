export type ModelStatus = "available" | "in-development" | "planned";

export type VoltaireModel = {
  id: string;
  family: string;
  specialization: string;
  name: string;
  size: string;
  purpose: string;
  status: ModelStatus;
  icon: string;
  logo?: string;
  version?: string;
  runtime?: string;
  formats?: string[];
  platforms?: string[];
};

export type ThirdPartyModel = {
  id: string;
  name: string;
  developer: string;
  logo: string;
  alt: string;
  tagline: string;
  purpose: string;
  officialUrl: string;
  runtime: string;
  platforms: string[];
  white?: boolean;
};

export const STATUS_LABELS: Record<ModelStatus, string> = {
  available: "Available",
  "in-development": "In development",
  planned: "Planned",
};

// Voltaire's own model family. None of these are publicly available yet.
export const voltaireModels: VoltaireModel[] = [
  {
    id: "voltaire-1-instruct",
    family: "Voltaire 1",
    specialization: "Instruct",
    name: "Voltaire 1 Instruct",
    size: "1.7B",
    purpose:
      "Our main general-purpose assistant, built for everyday conversation, following instructions, writing, summaries, and clear explanations.",
    status: "in-development",
    icon: "fa-solid fa-comments",
    logo: "/images/Voltaire_1.png",
    version: "v1.0.0",
    runtime: "MLX",
    formats: ["4-bit MLX"],
  },
  {
    id: "voltaire-1-mini",
    family: "Voltaire 1",
    specialization: "Mini",
    name: "Voltaire 1 Mini",
    size: "0.5B–1B",
    purpose:
      "A smaller, lightweight model for simple tasks and devices with limited memory, while keeping the same on-device philosophy.",
    status: "planned",
    icon: "fa-solid fa-feather",
    logo: "/images/Voltaire_1.png",
    runtime: "MLX",
    formats: ["4-bit MLX"],
  },
  {
    id: "voltaire-1-thinking",
    family: "Voltaire 1",
    specialization: "Thinking",
    name: "Voltaire 1 Thinking",
    size: "1.7B",
    purpose:
      "Intended for multi-step reasoning, maths, and logic. Reasoning abilities are being evaluated and will be demonstrated through testing before release.",
    status: "planned",
    icon: "fa-solid fa-brain",
    logo: "/images/Voltaire_1.png",
    runtime: "MLX",
    formats: ["4-bit MLX"],
  },
  {
    id: "voltaire-1-code",
    family: "Voltaire 1",
    specialization: "Code",
    name: "Voltaire 1 Code",
    size: "1.7B–3B",
    purpose:
      "Intended for coding, debugging, code explanations, and programming assistance directly on your device.",
    status: "planned",
    icon: "fa-solid fa-code",
    logo: "/images/Voltaire_1.png",
    runtime: "MLX",
    formats: ["4-bit MLX"],
  },
  {
    id: "voltaire-1-vision",
    family: "Voltaire 1",
    specialization: "Vision",
    name: "Voltaire 1 Vision",
    size: "TBD",
    purpose:
      "Intended for image understanding, screenshots, and visual inputs. Requires a vision-capable model and a compatible runtime.",
    status: "planned",
    icon: "fa-solid fa-eye",
    logo: "/images/Voltaire_1.png",
    runtime: "MLX",
    formats: ["4-bit MLX"],
  },
];

// Third-party open-weight models available in the app. Only verified
// information is listed; check the official source for exact variants.
export const thirdPartyModels: ThirdPartyModel[] = [
  {
    id: "llama",
    name: "Llama",
    developer: "Meta",
    logo: "/images/meta-logo.png",
    alt: "Meta Llama",
    tagline: "Meta's flagship family",
    purpose: "Meta's flagship family of open-weight language models.",
    officialUrl: "https://www.llama.com/",
    runtime: "MLX",
    platforms: ["iPhone"],
  },
  {
    id: "gemma",
    name: "Gemma",
    developer: "Google",
    logo: "/images/google-logo.png",
    alt: "Google Gemma",
    tagline: "Google's lightweight AI",
    purpose: "Google's family of lightweight open models for text and multimodal tasks.",
    officialUrl: "https://ai.google.dev/gemma",
    runtime: "MLX",
    platforms: ["iPhone"],
  },
  {
    id: "smollm",
    name: "SmolLM",
    developer: "Hugging Face",
    logo: "/images/huggingface-logo.png",
    alt: "Hugging Face SmolLM",
    tagline: "Hugging Face models",
    purpose: "Compact language models from Hugging Face, designed for efficiency on small devices.",
    officialUrl: "https://huggingface.co/HuggingFaceTB",
    runtime: "MLX",
    platforms: ["iPhone"],
  },
  {
    id: "minicpm",
    name: "MiniCPM",
    developer: "OpenBMB",
    logo: "/images/OpenBMB.png",
    alt: "OpenBMB MiniCPM",
    tagline: "OpenBMB's efficient models",
    purpose: "Efficient models from OpenBMB, including reasoning- and vision-capable variants.",
    officialUrl: "https://huggingface.co/openbmb",
    runtime: "MLX",
    platforms: ["iPhone"],
  },
  {
    id: "qwen",
    name: "Qwen",
    developer: "Alibaba",
    logo: "/images/qwen-logo.png",
    alt: "Qwen",
    tagline: "Alibaba multilingual",
    purpose: "Alibaba's multilingual model family, covering text and vision-language tasks.",
    officialUrl: "https://qwen.ai/",
    runtime: "MLX",
    platforms: ["iPhone"],
  },
  {
    id: "granite",
    name: "Granite",
    developer: "IBM",
    logo: "/images/ibm-logo.png",
    alt: "IBM Granite",
    tagline: "IBM enterprise AI",
    purpose: "IBM's enterprise-oriented family of open language models.",
    officialUrl: "https://www.ibm.com/granite",
    runtime: "MLX",
    platforms: ["iPhone"],
  },
  {
    id: "lfm",
    name: "LFM",
    developer: "Liquid AI",
    logo: "/images/liquid-logo.png",
    alt: "Liquid AI LFM",
    tagline: "Liquid Foundation Models",
    purpose: "Liquid Foundation Models from Liquid AI, built for fast on-device inference.",
    officialUrl: "https://www.liquid.ai/",
    runtime: "MLX",
    platforms: ["iPhone"],
    white: true,
  },
];
