import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Voltaire - Run AI models locally on your iPhone, iPad, and Mac.",
  description:
    "Run DeepSeek, Qwen, Gemma, Llama, and more on your iPhone, iPad, and Mac. Optimized for Apple Silicon. Offline. Private.",
  keywords: "AI, iPhone, iPad, Mac, local AI, privacy, Apple Silicon, LLM, MLX, DeepSeek, Qwen, Gemma, Llama, offline AI",
  openGraph: {
    title: "Voltaire - Run AI models locally on your iPhone, iPad, and Mac.",
    description: "Run DeepSeek, Qwen, Gemma, Llama, and more on your iPhone, iPad, and Mac. Optimized for Apple Silicon. Offline. Private.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"
          integrity="sha512-DTOQO9RWCH3ppGqcWaEA1BIZOC6xxalwEsw9c2QQeAIftl+Vegovlnee1c9QX4TctnWMn13TZye+giMm8e2LwA=="
          crossOrigin="anonymous"
          referrerPolicy="no-referrer"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
