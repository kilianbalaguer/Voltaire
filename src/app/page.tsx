import Image from "next/image";
import Link from "next/link";
import AnimatedSection from "@/components/AnimatedSection";
import Aurora from "@/components/Aurora";
import ContactForm from "@/components/ContactForm";
import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import Requirements from "@/components/Requirements";
import ScrollTopButton from "@/components/ScrollTopButton";
import Typewriter from "@/components/Typewriter";
import { fadeUp, scaleUp } from "@/lib/animations";
import { thirdPartyModels } from "@/lib/models";
import { CONTACT_EMAIL } from "@/lib/site";

const greetings = [
  "Ready to roll?",
  "Summarise this PDF for me.",
  "What's in this photo?",
  "Explain MLX like I'm five.",
];

const features = [
  {
    icon: "fa-solid fa-comments",
    title: "Text conversations",
    description: "Fast, fluid chat with capable language models, fully on-device.",
  },
  {
    icon: "fa-solid fa-eye",
    title: "Vision",
    description: "Download a vision model and ask about photos and screenshots, right on your phone.",
  },
  {
    icon: "fa-solid fa-folder-open",
    title: "File support",
    description: "Drop files into a conversation for summaries and analysis.",
  },
  {
    icon: "fa-solid fa-layer-group",
    title: "Model library",
    description: "Llama, Gemma, Qwen, MiniCPM and more. Pick the right model for every task.",
  },
  {
    icon: "fa-solid fa-microphone-lines",
    title: "Voice input",
    description: "Speak your prompts instead of typing. Hands-free and natural.",
    comingSoon: true,
  },
];

const faqs = [
  {
    question: "What AI models does Voltaire support?",
    answer:
      "Voltaire supports Meta Llama 3.2 & 3.1, Google Gemma 2, 3 & 3n, Qwen 2 VL, 2.5 & 3, MiniCPM 5, and more. All models run entirely on your device.",
  },
  {
    question: "Does it work without internet?",
    answer:
      "Yes. Once you download a model, it runs entirely on your device. An internet connection is only needed to download models.",
  },
  {
    question: "Is my data private?",
    answer:
      "Absolutely. Your prompts and conversations never leave your device. There is no cloud processing, no data collection, and no tracking.",
  },
  {
    question: "What devices are supported?",
    answer:
      "Voltaire will launch on iPhone 13 and later. iPad and Mac support is planned to follow after launch.",
  },
  {
    question: "How do I get started?",
    answer:
      "Voltaire is coming soon to the App Store. When it is released, download it, pick one or more models to download, and start chatting. No account is needed.",
  },
  {
    question: "Can I customize the AI?",
    answer:
      "Yes, you can set a custom system prompt to tailor the AI's personality and responses to your preferences.",
  },
];

export default function Home() {
  return (
    <main>
      <Navbar />

      {/* Hero */}
      <section className="hero">
        <Aurora />
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="hero-prompt">
              <span className="hero-prompt-dot">
                <i className="fa-solid fa-bolt"></i>
              </span>
              <Typewriter lines={greetings} />
            </div>
            <h1>
              Private AI, <em>right on your iPhone.</em>
            </h1>
            <p className="hero-sub">
              Voltaire runs powerful open models directly on your device. No cloud, no account, nothing
              ever leaves your phone.
            </p>
            <div className="hero-actions">
              <Link href="#download" className="btn btn-dark">
                Coming soon to the App Store <i className="fa-solid fa-arrow-right"></i>
              </Link>
              <Link href="/models" className="btn btn-ghost">
                Browse models
              </Link>
            </div>
            <ul className="hero-pills">
              <li><i className="fa-solid fa-check"></i> Works offline</li>
              <li><i className="fa-solid fa-check"></i> Zero data collected</li>
              <li><i className="fa-solid fa-check"></i> Built on Apple MLX</li>
            </ul>
          </AnimatedSection>

          <AnimatedSection variants={scaleUp} delay={0.15}>
            <div className="hero-stage">
              <Image
                className="hero-phone back left"
                src="/images/voltaire-screenshot-models.png"
                alt=""
                width={1179}
                height={2403}
                sizes="280px"
              />
              <Image
                className="hero-phone"
                src="/images/voltaire-screenshot.png"
                alt="Voltaire's home screen on iPhone"
                width={1179}
                height={2403}
                sizes="330px"
                priority
              />
              <div className="hero-chat b">
                <small><i className="fa-solid fa-lock"></i> on-device · 0 bytes sent</small>
                Here&apos;s a three-line summary of your notes. Nothing left this iPhone.
              </div>
              <div className="hero-fade" />
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* Model makers */}
      <section className="strip">
        <div className="container">
          <p className="strip-label">Run the best open models from</p>
          <div className="strip-row">
            {thirdPartyModels.map((m) => (
              <span key={m.id} className={`strip-item ${m.white ? "dark" : ""}`}>
                <Image src={m.logo} alt="" width={24} height={24} />
                {m.name}
              </span>
            ))}
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="section" id="features">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-head">
              <span className="eyebrow">Features</span>
              <h2>Everything you need. Nothing you don&apos;t.</h2>
              <p>A complete AI assistant, designed for Apple hardware and built around one rule: your data stays yours.</p>
            </div>
          </AnimatedSection>

          <div className="bento">
            <AnimatedSection variants={fadeUp} className="tile hero-tile">
              <Aurora />
              <div className="hero-tile-body">
                <div className="tile-icon">
                  <i className="fa-solid fa-shield-halved"></i>
                </div>
                <h3>100% private. By design.</h3>
                <p>
                  Your prompts and conversations never leave your device. No cloud processing, no data
                  collection, no tracking. Not even an account.
                </p>
                <div className="terminal" aria-hidden="true">
                  <div><b>$</b> voltaire chat --model gemma-3n</div>
                  <div>→ running locally on Apple Silicon</div>
                  <div>→ network requests: <span className="ok">0</span></div>
                  <div>→ data shared: <span className="ok">none</span></div>
                </div>
              </div>
            </AnimatedSection>

            {features.map((f, i) => (
              <AnimatedSection key={f.title} variants={fadeUp} delay={0.05 * i} className="tile">
                <div className="tile-icon">
                  <i className={f.icon}></i>
                </div>
                <h3>
                  {f.title}
                  {f.comingSoon && <span className="badge badge-soon">Coming soon</span>}
                </h3>
                <p>{f.description}</p>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* Models */}
      <section className="section" id="models" style={{ paddingTop: 0 }}>
        <div className="container">
          <div className="showcase">
            <AnimatedSection variants={fadeUp}>
              <div className="showcase-visual">
                <Image
                  src="/images/voltaire-screenshot-models.png"
                  alt="Managing models in Voltaire"
                  width={1179}
                  height={2403}
                  sizes="340px"
                />
              </div>
            </AnimatedSection>
            <AnimatedSection variants={fadeUp} delay={0.1}>
              <span className="eyebrow">Models</span>
              <h2 className="display">All your models, in your hand.</h2>
              <p className="soft" style={{ marginTop: 20, fontSize: 18 }}>
                Browse, download and switch between models in a tap. From reasoning to creative writing,
                pick the right one for the job, all running locally.
              </p>
              <ul className="model-list">
                {thirdPartyModels.slice(0, 5).map((m) => (
                  <li key={m.id}>
                    <Image
                      src={m.logo}
                      alt=""
                      width={32}
                      height={32}
                      className={m.white ? "on-light-invert" : undefined}
                    />
                    <div>
                      <div className="model-list-name">{m.name}</div>
                      <div className="model-list-dev">{m.developer}</div>
                    </div>
                    <span className="badge badge-muted mono">MLX</span>
                  </li>
                ))}
              </ul>
              <Link href="/models" className="text-link">
                See all models, including Voltaire 1 <i className="fa-solid fa-arrow-right"></i>
              </Link>
            </AnimatedSection>
          </div>
        </div>
      </section>

      {/* Apple Silicon */}
      <section className="section night">
        <Aurora />
        <div className="container">
          <div className="silicon">
            <AnimatedSection variants={fadeUp}>
              <div className="silicon-chip">
                <Image src="/images/A19-Pro-Chip.jpg" alt="Apple A19 Pro chip" width={1200} height={658} />
              </div>
            </AnimatedSection>
            <AnimatedSection variants={fadeUp} delay={0.1}>
              <div className="section-head" style={{ marginBottom: 0 }}>
                <span className="eyebrow">Apple Silicon · MLX</span>
                <h2>Built for the chip in your pocket.</h2>
              </div>
              <div className="silicon-copy soft" style={{ marginTop: 20, fontSize: 17 }}>
                <p>
                  Voltaire is built on MLX, Apple&apos;s machine learning framework, to take full advantage of
                  the unified memory in Apple Silicon. Models load fast, answer fast, and use less power.
                </p>
                <p>
                  On Mac, Voltaire is for Apple Silicon (M-series) only. Intel Macs are not supported.
                </p>
              </div>
              <a href="https://mlx-framework.org" target="_blank" rel="noopener noreferrer" className="text-link" style={{ color: "var(--mint)" }}>
                Learn more about MLX <i className="fa-solid fa-arrow-right"></i>
              </a>
            </AnimatedSection>
          </div>

          <div className="stats">
            <div className="stat">
              <strong>100%</strong>
              <span>On-device</span>
            </div>
            <div className="stat">
              <strong>0</strong>
              <span>Data collected</span>
            </div>
            <div className="stat">
              <strong>0</strong>
              <span>Accounts required</span>
            </div>
            <div className="stat">
              <strong>{thirdPartyModels.length}</strong>
              <span>Model families</span>
            </div>
          </div>
        </div>
      </section>

      {/* Requirements */}
      <section className="section" id="requirements">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-head">
              <span className="eyebrow">Requirements</span>
              <h2>Will it run on mine?</h2>
              <p>iPhone 13 and later at launch, with iPad and Mac to follow.</p>
            </div>
          </AnimatedSection>
          <AnimatedSection variants={fadeUp}>
            <Requirements />
          </AnimatedSection>
        </div>
      </section>

      {/* FAQ */}
      <section className="section" id="faq" style={{ paddingTop: 0 }}>
        <div className="container">
          <div className="faq-layout">
            <div className="section-head">
              <span className="eyebrow">FAQ</span>
              <h2>Questions, answered.</h2>
              <p>
                Something else? <Link href="#contact" style={{ color: "var(--teal-deep)" }}>Ask us directly.</Link>
              </p>
            </div>
            <AnimatedSection variants={fadeUp}>
              <div className="faq">
                {faqs.map((faq, i) => (
                  <details key={faq.question} open={i === 0}>
                    <summary>
                      {faq.question}
                      <i className="fa-solid fa-plus" aria-hidden="true"></i>
                    </summary>
                    <p>{faq.answer}</p>
                  </details>
                ))}
              </div>
            </AnimatedSection>
          </div>
        </div>
      </section>

      {/* Download */}
      <section id="download">
        <div className="container">
          <AnimatedSection variants={scaleUp}>
            <div className="cta">
              <Aurora />
              <span className="eyebrow">Coming soon</span>
              <h2 className="display">Your AI. Your device.</h2>
              <p>Voltaire is coming soon to the App Store for iPhone. iPad and Mac will follow.</p>
              <span className="cta-badge" aria-label="Coming soon on the App Store">
                <Image
                  src="/images/Coming-Soon-On-The_AppStoreBadge.svg"
                  alt="Coming soon on the App Store"
                  width={200}
                  height={66}
                />
              </span>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* Contact */}
      <section className="section" id="contact" style={{ paddingBottom: 0 }}>
        <div className="container">
          <div className="contact">
            <div className="contact-aside section-head" style={{ marginBottom: 0 }}>
              <span className="eyebrow">Contact</span>
              <h2>Say hello.</h2>
              <p>Questions, feedback, or a model you&apos;d like to see? Send a message.</p>
              <a href={`mailto:${CONTACT_EMAIL}`}>
                <i className="fa-regular fa-envelope"></i> {CONTACT_EMAIL}
              </a>
            </div>
            <AnimatedSection variants={fadeUp}>
              <ContactForm />
            </AnimatedSection>
          </div>
        </div>
      </section>

      <Footer />
      <ScrollTopButton />
    </main>
  );
}
