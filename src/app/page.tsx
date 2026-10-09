"use client";

import Image from "next/image";
import Link from "next/link";
import { motion } from "framer-motion";
import AnimatedSection from "@/components/AnimatedSection";
import CountUp from "@/components/CountUp";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ScrollTopButton from "@/components/ScrollTopButton";
import { thirdPartyModels } from "@/lib/models";
import { fadeUp, slideLeft, slideRight, staggerContainer } from "@/lib/animations";

const features = [
  { icon: "fa-solid fa-comments", title: "Text Conversations", description: "Chat with powerful AI models directly on your device. Fast, responsive, and fully on-device." },
  { icon: "fa-solid fa-eye", title: "Vision", description: "Vision-capable models available for download in-app. Analyze images directly on your device." },
  { icon: "fa-solid fa-microphone-lines", title: "Voice Input", description: "Speak your prompts instead of typing. Hands-free interaction that's fast and natural. Coming soon.", comingSoon: true },
  { icon: "fa-solid fa-folder-open", title: "File Support", description: "Drop files into your conversations for AI-powered summaries and analysis." },
  { icon: "fa-solid fa-shield-halved", title: "100% Private", description: "Your prompts and conversations never leave your device. No cloud processing, no data collection, no tracking." },
  { icon: "fa-solid fa-puzzle-piece", title: "Model Library", description: "Choose from Llama, Gemma, Qwen, MiniCPM, and more. Pick the right model for every task." },
];

const faqs = [
  { question: "What AI models does Voltaire support?", answer: "Voltaire supports Meta Llama 3.2 & 3.1, Google Gemma 2, 3 & 3n, Qwen 2 VL, 2.5 & 3, MiniCPM 5, and more. All models run entirely on your device." },
  { question: "Does it work without internet?", answer: "Yes. Once you download a model, it runs entirely on your device. An internet connection is only needed to download models." },
  { question: "Is my data private?", answer: "Absolutely. Your prompts and conversations never leave your device. There is no cloud processing, no data collection, and no tracking." },
  { question: "What devices are supported?", answer: "Voltaire will launch on iPhone 13 and later. iPad and Mac support is planned to follow after launch." },
  { question: "How do I get started?", answer: "Voltaire is coming soon to the App Store. When it is released, download it, pick one or more models to download, and start chatting. No account is needed." },
  { question: "Can I customize the AI?", answer: "Yes, you can set a custom system prompt to tailor the AI's personality and responses to your preferences." },
];

export default function Home() {
  return (
    <main>
      <Navbar />

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
              Bring powerful language and vision models to your iPhone, iPad, and Mac. No cloud. No login. Complete privacy. Coming soon to the App Store.
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
                <p>On-device</p>
              </div>
              <div className="stat">
                <h3><CountUp target={0} /></h3>
                <p>Data collected</p>
              </div>
              <div className="stat">
                <h3><CountUp target={0} /></h3>
                <p>Accounts required</p>
              </div>
              <div className="stat">
                <h3><CountUp target={thirdPartyModels.length} /></h3>
                <p>Model families</p>
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
              <p>Choose from the most popular open-source AI models, all optimized for Apple Silicon, plus the upcoming Voltaire 1 family.</p>
            </div>
          </AnimatedSection>
          <motion.div
            className="models-grid"
            variants={staggerContainer}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: "-80px" }}
          >
            {thirdPartyModels.map((m, i) => (
              <AnimatedSection key={i} variants={fadeUp}>
                <div className="model-card">
                  <Image src={m.logo} alt={m.alt} width={56} height={56} style={m.white ? { filter: "invert(1)" } : undefined} />
                  <h4>{m.name}</h4>
                  <p>{m.tagline}</p>
                </div>
              </AnimatedSection>
            ))}
          </motion.div>
          <AnimatedSection variants={fadeUp}>
            <div className="models-cta">
              <Link href="/models" className="btn-secondary">
                Explore all models <i className="fa-solid fa-arrow-right"></i>
              </Link>
            </div>
          </AnimatedSection>
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

      {/* Apple Silicon MLX */}
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
                  On Mac, Voltaire is built for Apple Silicon (M-series) models. Intel-based Macs are not supported. On iPhone and iPad, Voltaire runs on the devices listed in the system requirements below.
                </p>
                <a href="https://mlx-framework.org" target="_blank" rel="noopener noreferrer">
                  Learn more about MLX <i className="fa-solid fa-arrow-right" style={{ fontSize: 12, marginLeft: 4 }}></i>
                </a>
              </div>
            </AnimatedSection>
          </div>
        </div>
      </section>

      {/* System Requirements */}
      <section className="requirements-section" id="requirements">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-header">
              <h2>System requirements.</h2>
              <p>Voltaire is coming soon to the App Store. iPhone 13 and later will be supported at launch, with iPad and Mac to follow.</p>
            </div>
          </AnimatedSection>
          <AnimatedSection variants={fadeUp}>
            <div className="requirements-devices-grid">
              {/* iPhone */}
              <div className="requirements-device-group">
                <div className="device-group-header">
                  <i className="fa-solid fa-mobile-screen"></i>
                  <h3>iPhone</h3>
                  <span className="coming-soon-badge">Launch platform</span>
                </div>
                <div className="devices-columns">
                  <div className="devices-column">
                    <h4><i className="fa-solid fa-check"></i> Supported</h4>
                    <div className="device-list">
                      <span className="device-tag supported">iPhone 13 mini</span>
                      <span className="device-tag supported">iPhone 13</span>
                      <span className="device-tag supported">iPhone 13 Pro</span>
                      <span className="device-tag supported">iPhone 13 Pro Max</span>
                      <span className="device-tag supported">iPhone 14</span>
                      <span className="device-tag supported">iPhone 14 Plus</span>
                      <span className="device-tag supported">iPhone 14 Pro</span>
                      <span className="device-tag supported">iPhone 14 Pro Max</span>
                      <span className="device-tag supported">iPhone 15</span>
                      <span className="device-tag supported">iPhone 15 Plus</span>
                      <span className="device-tag supported">iPhone 15 Pro</span>
                      <span className="device-tag supported">iPhone 15 Pro Max</span>
                      <span className="device-tag supported">iPhone 16</span>
                      <span className="device-tag supported">iPhone 16 Plus</span>
                      <span className="device-tag supported">iPhone 16e</span>
                      <span className="device-tag supported">iPhone 16 Pro</span>
                      <span className="device-tag supported">iPhone 16 Pro Max</span>
                      <span className="device-tag supported">iPhone 17</span>
                      <span className="device-tag supported">iPhone 17 Air</span>
                      <span className="device-tag supported">iPhone 17e</span>
                      <span className="device-tag supported">iPhone 17 Pro</span>
                      <span className="device-tag supported">iPhone 17 Pro Max</span>
                    </div>
                  </div>
                  <div className="devices-column">
                    <h4><i className="fa-solid fa-xmark"></i> Not Supported</h4>
                    <div className="device-list">
                      <span className="device-tag unsupported">iPhone X or earlier</span>
                      <span className="device-tag unsupported">iPhone XS</span>
                      <span className="device-tag unsupported">iPhone XS Max</span>
                      <span className="device-tag unsupported">iPhone XR</span>
                      <span className="device-tag unsupported">iPhone 11</span>
                      <span className="device-tag unsupported">iPhone 11 Pro</span>
                      <span className="device-tag unsupported">iPhone 11 Pro Max</span>
                      <span className="device-tag unsupported">iPhone 12 mini</span>
                      <span className="device-tag unsupported">iPhone 12</span>
                      <span className="device-tag unsupported">iPhone 12 Pro</span>
                      <span className="device-tag unsupported">iPhone 12 Pro Max</span>
                      <span className="device-tag unsupported">iPhone SE (1st gen)</span>
                      <span className="device-tag unsupported">iPhone SE (2nd gen)</span>
                      <span className="device-tag unsupported">iPhone SE (3rd gen)</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* iPad */}
              <div className="requirements-device-group coming-soon">
                <div className="device-group-header">
                  <i className="fa-solid fa-tablet-screen-button"></i>
                  <h3>iPad</h3>
                  <span className="coming-soon-badge">Coming later</span>
                </div>
                <div className="devices-columns">
                  <div className="devices-column">
                    <h4><i className="fa-solid fa-check"></i> Supported</h4>
                    <div className="device-list">
                      <span className="device-tag supported">iPad Pro (M1)</span>
                      <span className="device-tag supported">iPad Pro (M2)</span>
                      <span className="device-tag supported">iPad Pro (M4)</span>
                      <span className="device-tag supported">iPad Air (M1)</span>
                      <span className="device-tag supported">iPad Air (M2)</span>
                      <span className="device-tag supported">iPad Air (M3)</span>
                      <span className="device-tag supported">iPad mini (A17 Pro)</span>
                    </div>
                  </div>
                  <div className="devices-column">
                    <h4><i className="fa-solid fa-xmark"></i> Not Supported</h4>
                    <div className="device-list">
                      <span className="device-tag unsupported">iPad (1st-9th gen)</span>
                      <span className="device-tag unsupported">iPad (10th gen)</span>
                      <span className="device-tag unsupported">iPad Pro (pre-M1)</span>
                      <span className="device-tag unsupported">iPad Air (pre-M1)</span>
                      <span className="device-tag unsupported">iPad mini (pre-A17)</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Mac */}
              <div className="requirements-device-group coming-soon">
                <div className="device-group-header">
                  <i className="fa-solid fa-laptop"></i>
                  <h3>Mac</h3>
                  <span className="coming-soon-badge">Coming later</span>
                </div>
                <div className="devices-columns">
                  <div className="devices-column">
                    <h4><i className="fa-solid fa-check"></i> Supported</h4>
                    <div className="device-list">
                      <span className="device-tag supported">MacBook Air (M1)</span>
                      <span className="device-tag supported">MacBook Air (M2)</span>
                      <span className="device-tag supported">MacBook Air (M3)</span>
                      <span className="device-tag supported">MacBook Pro (M1)</span>
                      <span className="device-tag supported">MacBook Pro (M2)</span>
                      <span className="device-tag supported">MacBook Pro (M3)</span>
                      <span className="device-tag supported">MacBook Pro (M4)</span>
                      <span className="device-tag supported">iMac (M1)</span>
                      <span className="device-tag supported">iMac (M3)</span>
                      <span className="device-tag supported">iMac (M4)</span>
                      <span className="device-tag supported">Mac mini (M1)</span>
                      <span className="device-tag supported">Mac mini (M2)</span>
                      <span className="device-tag supported">Mac mini (M4)</span>
                      <span className="device-tag supported">Mac Studio (M1)</span>
                      <span className="device-tag supported">Mac Studio (M2)</span>
                      <span className="device-tag supported">Mac Pro (M2 Ultra)</span>
                    </div>
                  </div>
                  <div className="devices-column">
                    <h4><i className="fa-solid fa-xmark"></i> Not Supported</h4>
                    <div className="device-list">
                      <span className="device-tag unsupported">All Intel Macs</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="requirements-specs">
              <div className="spec-item">
                <i className="fa-brands fa-apple"></i>
                <div>
                  <span className="spec-label">OS</span>
                  <span className="spec-value">iOS 26+ / iPadOS 26+ / macOS 26+</span>
                </div>
              </div>
              <div className="spec-item">
                <i className="fa-solid fa-hard-drive"></i>
                <div>
                  <span className="spec-label">Storage</span>
                  <span className="spec-value">700 MB min</span>
                </div>
              </div>
              <div className="spec-item">
                <i className="fa-solid fa-wifi"></i>
                <div>
                  <span className="spec-label">Internet</span>
                  <span className="spec-value">Downloads only</span>
                </div>
              </div>
            </div>
          </AnimatedSection>
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
              <Image src="/images/Coming-Soon-On-The_AppStoreBadge.svg" alt="Coming Soon on the App Store" width={200} height={66} style={{ width: 200, height: "auto" }} />
            </div>
          </AnimatedSection>
        </div>
      </section>

      <Footer />
      <ScrollTopButton />
    </main>
  );
}
