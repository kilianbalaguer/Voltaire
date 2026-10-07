import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Voltaire - Run AI Models Locally on iPhone, iPad & Mac",
  description:
    "Run MiniCPM 5, Qwen, Gemma, Llama, and 40+ AI models directly on your iPhone, iPad, and Mac. 100% offline. Zero data collection. Complete privacy. Optimized for Apple Silicon with MLX.",
  keywords: [
    "AI app",
    "local AI",
    "offline AI",
    "iPhone AI",
    "iPad AI",
    "Mac AI",
    "privacy AI",
    "Apple Silicon",
    "MLX",
    "LLM",
    "MiniCPM 5",
    "Qwen",
    "Gemma",
    "Llama",
    "on-device AI",
    "private AI",
    "no cloud AI",
    "run AI locally",
  ],
  authors: [{ name: "Kilian Balaguer" }],
  creator: "Kilian Balaguer",
  publisher: "Kilian Balaguer",
  metadataBase: new URL("https://voltaire.app"),
  openGraph: {
    title: "Voltaire - Run AI Models Locally on iPhone, iPad & Mac",
    description:
      "Run MiniCPM 5, Qwen, Gemma, Llama, and 40+ AI models directly on your iPhone, iPad, and Mac. 100% offline. Zero data collection. Complete privacy.",
    type: "website",
    locale: "en_US",
    siteName: "Voltaire",
    images: [
      {
        url: "/images/og-image.png",
        width: 1200,
        height: 630,
        alt: "Voltaire - On-device AI for iPhone, iPad & Mac",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Voltaire - Run AI Models Locally on iPhone, iPad & Mac",
    description:
      "Run MiniCPM 5, Qwen, Gemma, Llama, and 40+ AI models directly on your iPhone, iPad, and Mac. 100% offline. Complete privacy.",
    images: ["/images/og-image.png"],
    creator: "@voltaire",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
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
        <meta name="theme-color" content="#09090b" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
      </head>
      <body>{children}</body>
    </html>
  );
}
