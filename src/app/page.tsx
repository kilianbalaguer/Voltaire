"use client";

import { useEffect, useState } from "react";
import Image from "next/image";

const models = [
  { name: "Llama", description: "Meta's flagship family", logo: "/images/meta-logo.png", alt: "Meta Llama" },
  { name: "Gemma", description: "Google's lightweight AI", logo: "/images/google-logo.png", alt: "Google Gemma" },
  { name: "SmolLM", description: "Hugging Face models", logo: "/images/huggingface-logo.png", alt: "Hugging Face SmolLM" },
  { name: "DeepSeek", description: "Reasoning & coding", logo: "/images/deepseek-logo.png", alt: "DeepSeek" },
  { name: "Qwen", description: "Alibaba multilingual", logo: "/images/qwen-logo.png", alt: "Qwen" },
  { name: "Granite", description: "IBM enterprise AI", logo: "/images/ibm-logo.png", alt: "IBM Granite" },
  { name: "Cogito", description: "Reasoning-focused", logo: "/images/cogito-logo.png", alt: "Deep Cogito" },
  { name: "LFM", description: "Liquid Foundation Models", logo: "/images/liquid-logo.png", alt: "Liquid AI LFM", white: true },
];

const features = [
  { icon: "fa-solid fa-comments", title: "Text Conversations", description: "Chat with powerful AI models directly on your device. Fast, responsive, and completely offline." },
  { icon: "fa-solid fa-eye", title: "Vision", description: "Vision-capable models available for download in-app. Vision support coming soon.", comingSoon: true },
  { icon: "fa-solid fa-microphone-lines", title: "Voice Input", description: "Speak your prompts instead of typing. Hands-free interaction that's fast and natural. Coming soon.", comingSoon: true },
  { icon: "fa-solid fa-folder-open", title: "File Support", description: "Drop files into your conversations for AI-powered summaries and analysis. Coming soon.", comingSoon: true },
  { icon: "fa-solid fa-shield-halved", title: "100% Private", description: "Zero data collection. Zero cloud processing. Everything stays on your device, always." },
  { icon: "fa-solid fa-puzzle-piece", title: "40+ Models", description: "Choose from Llama, Gemma, Qwen, DeepSeek, and more. Pick the right model for every task." },
];

const faqs = [
  { question: "What AI models does Voltaire support?", answer: "Voltaire supports Meta Llama 3.2 & 3.1, Google Gemma 2, 3 & 3n, Qwen 2 VL, 2.5 & 3, DeepSeek R1, and more. All models run completely offline." },
  { question: "Does it work without internet?", answer: "Yes! Once you download a model, everything runs locally. No internet connection needed for any AI processing." },
  { question: "Is my data private?", answer: "Absolutely. Your data never leaves your device. No cloud processing, no data collection, no tracking." },
  { question: "What devices are supported?", answer: "Voltaire is available on iPhone now. iPad and Mac support coming soon." },
  { question: "How do I get started?", answer: "As soon as Voltaire is released, it will be available on the App Store. Download it, pick one or multiple models to download, and start chatting. No accounts needed at all." },
  { question: "Can I customize the AI?", answer: "Yes, you can set a custom system prompt to tailor the AI's personality and responses to your preferences." },
];

export default function Home() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 50);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <main>
      {/* Navbar */}
      <nav className={`navbar ${scrolled ? "scrolled" : ""}`}>
        <div className="container">
          <div className="nav-inner">
            <a href="#" className="nav-brand">
              <Image src="/images/logo-only-small.png" alt="Voltaire" width={36} height={36} />
              Voltaire
            </a>
            <ul className="nav-links">
              <li><a href="#features">Features</a></li>
              <li><a href="#models">Models</a></li>
              <li><a href="#faq">FAQ</a></li>
              <li><a href="#contact">Contact</a></li>
            </ul>
            <a href="#download" className="nav-cta">Download</a>
            <button className="nav-hamburger" onClick={() => setMobileMenuOpen(!mobileMenuOpen)} aria-label="Menu">
              <i className={`fa-solid ${mobileMenuOpen ? "fa-xmark" : "fa-bars"}`}></i>
            </button>
          </div>
        </div>
      </nav>
      {mobileMenuOpen && (
        <div className="mobile-menu">
          <a href="#features" onClick={() => setMobileMenuOpen(false)}>Features</a>
          <a href="#models" onClick={() => setMobileMenuOpen(false)}>Models</a>
          <a href="#faq" onClick={() => setMobileMenuOpen(false)}>FAQ</a>
          <a href="#contact" onClick={() => setMobileMenuOpen(false)}>Contact</a>
          <a href="#download" className="mobile-menu-cta" onClick={() => setMobileMenuOpen(false)}>Download</a>
        </div>
      )}

      {/* Hero */}
      <section className="hero">
        <div className="container">
          <div className="hero-text">
            <h1>
              AI that lives<br />
              <span className="gradient">on your device.</span>
            </h1>
            <p>
              Run powerful language and vision models directly on your iPhone, iPad, and Mac. No cloud. No login. Complete privacy.
            </p>
            <a href="#download" className="hero-cta">
              Get Voltaire
              <i className="fa-solid fa-arrow-right"></i>
            </a>
          </div>
          <div className="hero-image">
            <Image src="/images/voltaire-screenshot.png" alt="Voltaire on iPhone" width={400} height={866} style={{ width: "100%", maxWidth: 400, height: "auto" }} />
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="features-section" id="features">
        <div className="container">
          <div className="section-header">
            <h2>Built for what matters.</h2>
            <p>Everything you need for a complete on-device AI experience, designed for Apple hardware.</p>
          </div>
          <div className="features-grid">
            {features.map((f, i) => (
              <div key={i} className="feature-card">
                <div className="feature-icon">
                  <i className={f.icon}></i>
                </div>
                <h3 style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  {f.title}
                  {"comingSoon" in f && f.comingSoon && <span className="coming-soon-badge">Coming Soon</span>}
                </h3>
                <p>{f.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="stats-section">
        <div className="container">
          <div className="stats-grid">
            <div className="stat">
              <h3>100%</h3>
              <p>Offline</p>
            </div>
            <div className="stat">
              <h3>0</h3>
              <p>Data collected</p>
            </div>
            <div className="stat">
              <h3>40+</h3>
              <p>Models available</p>
            </div>
            <div className="stat">
              <h3>3</h3>
              <p>Platforms</p>
            </div>
          </div>
        </div>
      </section>

      {/* Models */}
      <section className="models-section" id="models">
        <div className="container">
          <div className="section-header">
            <h2>Industry-leading models.</h2>
            <p>Choose from the most popular open-source AI models, all optimized for Apple Silicon.</p>
          </div>
          <div className="models-grid">
            {models.map((m, i) => (
              <div key={i} className="model-card">
                <Image src={m.logo} alt={m.alt} width={56} height={56} style={"white" in m && m.white ? { filter: "invert(1)" } : undefined} />
                <h4>{m.name}</h4>
                <p>{m.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Apple Silicon MLX - KEPT */}
      <section className="apple-silicon">
        <div className="container">
          <div className="apple-silicon-inner">
            <div className="apple-silicon-image">
              <Image src="/images/a18_chip.jpg" alt="Apple A18 Chip" width={500} height={500} style={{ maxWidth: 400, width: "100%", height: "auto" }} />
            </div>
            <div className="apple-silicon-content">
              <h2>Optimized for Apple Silicon. Powered by MLX.</h2>
              <p>
                Voltaire is built to shine on Apple Silicon, taking full advantage of MLX, Apple&apos;s advanced machine learning framework. MLX is designed to harness the incredible speed and efficiency of the unified memory architecture.
              </p>
              <p>
                From loading models to answering questions, Voltaire delivers remarkable performance while using less power. The result is a seamless experience that feels effortless, whether you are creating, learning, or exploring.
              </p>
              <p>
                And with MLX designed to run across every Apple device, Voltaire is always at its best on iPhone, iPad, or Mac.
              </p>
              <a href="https://mlx-framework.org" target="_blank" rel="noopener noreferrer">
                Learn more about MLX <i className="fa-solid fa-arrow-right" style={{ fontSize: 12, marginLeft: 4 }}></i>
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* Quote */}
      <section className="quote-section">
        <div className="container">
          <blockquote>
            &ldquo;<span>The future of AI is private.</span> Run powerful models on your own hardware, with no data ever leaving your device.&rdquo;
          </blockquote>
        </div>
      </section>

      {/* FAQ */}
      <section className="faq-section" id="faq">
        <div className="container">
          <div className="section-header">
            <h2>Questions answered.</h2>
          </div>
          <div className="faq-grid">
            {faqs.map((faq, i) => (
              <div key={i} className="faq-item">
                <h4>{faq.question}</h4>
                <p>{faq.answer}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Contact */}
      <section className="contact-section" id="contact">
        <div className="container">
          <div className="section-header">
            <h2>Get in touch.</h2>
            <p>Have a question, feedback, or just want to say hi? Send us a message.</p>
          </div>
          <div className="contact-form">
            <div className="contact-row">
              <div className="contact-field">
                <label>Full Name</label>
                <input type="text" id="contact-name" placeholder="Your name" />
              </div>
              <div className="contact-field">
                <label>Email</label>
                <input type="email" id="contact-email" placeholder="your@email.com" />
              </div>
            </div>
            <div className="contact-field">
              <label>Subject</label>
              <input type="text" id="contact-subject" placeholder="What's this about?" />
            </div>
            <div className="contact-field">
              <label>Message</label>
              <textarea id="contact-message" rows={5} placeholder="Your message..."></textarea>
            </div>
            <button className="send-btn" onClick={() => {
              const name = (document.getElementById("contact-name") as HTMLInputElement)?.value || "";
              const email = (document.getElementById("contact-email") as HTMLInputElement)?.value || "";
              const subject = (document.getElementById("contact-subject") as HTMLInputElement)?.value || "";
              const message = (document.getElementById("contact-message") as HTMLTextAreaElement)?.value || "";
              window.location.href = `mailto:kilianbalaguer67@icloud.com?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(`From: ${name}\nEmail: ${email}\n\n${message}`)}`;
            }}>
              Send Message
              <i className="fa-solid fa-paper-plane"></i>
            </button>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="cta-section" id="download">
        <div className="container">
          <h2>Start running AI locally.</h2>
          <p>Download Voltaire and experience the power of on-device intelligence.</p>
          <div className="coming-soon-cta">
            <i className="fa-brands fa-app-store" style={{ fontSize: 28 }}></i>
            <div>
              <span className="coming-soon-cta-label">Coming soon to the</span>
              <span className="coming-soon-cta-store">App Store</span>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="container">
          <div className="footer-inner">
            <div className="footer-brand">
              <Image src="/images/logo-only-small.png" alt="Voltaire" width={28} height={28} />
              Voltaire
            </div>
            <div className="footer-links">
              <a href="/privacy">Privacy</a>
              <a href="/terms">Terms</a>
              <a href="#contact">Contact</a>
            </div>
          </div>
          <div className="footer-copy">
            &copy; 2026 Kilian Balaguer. All rights reserved.
          </div>
        </div>
      </footer>
    </main>
  );
}
