"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import AnimatedSection from "@/components/AnimatedSection";
import CountUp from "@/components/CountUp";
import { fadeUp, slideLeft, slideRight, staggerContainer } from "@/lib/animations";

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
          <motion.div
            className="hero-text"
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
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
          </motion.div>
          <motion.div
            className="hero-image"
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <Image src="/images/voltaire-screenshot.png" alt="Voltaire on iPhone" width={400} height={866} style={{ width: "100%", maxWidth: 400, height: "auto" }} />
          </motion.div>
        </div>
      </section>

      {/* Features */}
      <section className="features-section" id="features">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-header">
              <h2>Built for what matters.</h2>
              <p>Everything you need for a complete on-device AI experience, designed for Apple hardware.</p>
            </div>
          </AnimatedSection>
          <motion.div
            className="features-grid"
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: "-80px" }}
          >
            {features.map((f, i) => (
              <AnimatedSection key={i} variants={fadeUp}>
                <div className="feature-card">
                  <div className="feature-icon">
                    <i className={f.icon}></i>
                  </div>
                  <h3 style={{ display: "flex", alignItems: "center", gap: 8 }}>
                    {f.title}
                    {"comingSoon" in f && f.comingSoon && <span className="coming-soon-badge">Coming Soon</span>}
                  </h3>
                  <p>{f.description}</p>
                </div>
              </AnimatedSection>
            ))}
          </motion.div>
        </div>
      </section>

      {/* Stats */}
      <section className="stats-section">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="stats-grid">
              <div className="stat">
                <h3><CountUp target={100} suffix="%" /></h3>
                <p>Offline</p>
              </div>
              <div className="stat">
                <h3><CountUp target={0} /></h3>
                <p>Data collected</p>
              </div>
              <div className="stat">
                <h3><CountUp target={40} suffix="+" /></h3>
                <p>Models available</p>
              </div>
              <div className="stat">
                <h3><CountUp target={3} /></h3>
                <p>Platforms</p>
              </div>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* Models */}
      <section className="models-section" id="models">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-header">
              <h2>Industry-leading models.</h2>
              <p>Choose from the most popular open-source AI models, all optimized for Apple Silicon.</p>
            </div>
          </AnimatedSection>
          <motion.div
            className="models-grid"
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: "-80px" }}
          >
            {models.map((m, i) => (
              <AnimatedSection key={i} variants={fadeUp}>
                <div className="model-card">
                  <Image src={m.logo} alt={m.alt} width={56} height={56} style={"white" in m && m.white ? { filter: "invert(1)" } : undefined} />
                  <h4>{m.name}</h4>
                  <p>{m.description}</p>
                </div>
              </AnimatedSection>
            ))}
          </motion.div>
        </div>
      </section>

      {/* Models Showcase */}
      <section className="models-showcase">
        <div className="container">
          <div className="models-showcase-inner">
            <AnimatedSection variants={slideLeft}>
              <div className="models-showcase-content">
                <h2>All your models in your hand.</h2>
                <p>
                  Browse, download, and switch between models effortlessly. From powerful reasoning to creative writing, pick the right model for every task—all running locally on your device.
                </p>
              </div>
            </AnimatedSection>
            <AnimatedSection variants={slideRight}>
              <div className="models-showcase-image">
                <Image src="/images/voltaire-screenshot-models.png" alt="Voltaire model list" width={400} height={866} style={{ width: "100%", maxWidth: 400, height: "auto" }} />
              </div>
            </AnimatedSection>
          </div>
        </div>
      </section>

      {/* Apple Silicon MLX - KEPT */}
      <section className="apple-silicon">
        <div className="container">
          <div className="apple-silicon-inner">
            <AnimatedSection variants={slideLeft}>
              <div className="apple-silicon-image">
                <Image src="/images/A19-Pro-Chip.jpg" alt="Apple A19 Pro Chip" width={800} height={800} style={{ maxWidth: 600, width: "100%", height: "auto" }} />
              </div>
            </AnimatedSection>
            <AnimatedSection variants={slideRight}>
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
            </AnimatedSection>
          </div>
        </div>
      </section>

      {/* Quote */}
      <section className="quote-section">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <blockquote>
              &ldquo;<span>The future of AI is private.</span> Run powerful models on your own hardware, with no data ever leaving your device.&rdquo;
            </blockquote>
          </AnimatedSection>
        </div>
      </section>

      {/* FAQ */}
      <section className="faq-section" id="faq">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-header">
              <h2>Questions answered.</h2>
            </div>
          </AnimatedSection>
          <motion.div
            className="faq-grid"
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: "-80px" }}
          >
            {faqs.map((faq, i) => (
              <AnimatedSection key={i} variants={fadeUp}>
                <div className="faq-item">
                  <h4>{faq.question}</h4>
                  <p>{faq.answer}</p>
                </div>
              </AnimatedSection>
            ))}
          </motion.div>
        </div>
      </section>

      {/* Contact */}
      <section className="contact-section" id="contact">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-header">
              <h2>Get in touch.</h2>
              <p>Have a question, feedback, or just want to say hi? Send us a message.</p>
            </div>
          </AnimatedSection>
          <AnimatedSection variants={fadeUp}>
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
          </AnimatedSection>
        </div>
      </section>

      {/* CTA */}
      <section className="cta-section" id="download">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <h2>Start running AI locally.</h2>
            <p>Download Voltaire and experience the power of on-device intelligence.</p>
            <div className="coming-soon-cta">
              <i className="fa-brands fa-app-store" style={{ fontSize: 28 }}></i>
              <div>
                <span className="coming-soon-cta-label">Coming soon to the</span>
                <span className="coming-soon-cta-store">App Store</span>
              </div>
            </div>
          </AnimatedSection>
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
