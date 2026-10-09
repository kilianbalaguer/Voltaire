import type { Metadata } from "next";
import Image from "next/image";
import AnimatedSection from "@/components/AnimatedSection";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ScrollTopButton from "@/components/ScrollTopButton";
import {
  STATUS_LABELS,
  roadmapSteps,
  thirdPartyModels,
  voltaireModels,
} from "@/lib/models";
import { fadeUp } from "@/lib/animations";

export const metadata: Metadata = {
  title: "Models - Voltaire 1 & Third-Party On-Device AI",
  description:
    "Explore the Voltaire 1 model family and the open-weight models available in Voltaire. See what is in development, what is available, and the roadmap ahead.",
  alternates: { canonical: "/models" },
  openGraph: {
    title: "Models - Voltaire 1 & Third-Party On-Device AI",
    description:
      "Explore the Voltaire 1 model family and the open-weight models available in Voltaire.",
    type: "website",
    url: "/models",
  },
};

export default function Models() {
  return (
    <main className="models-page">
      <Navbar />

      {/* Page hero */}
      <section className="page-hero">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <span className="page-eyebrow">Model catalogue</span>
            <h1>Models</h1>
            <p>
              Voltaire runs open-weight language and vision models on your own device.
              Here you can see the Voltaire 1 family we are building, the third-party
              models available to download in the app, and what is coming next.
            </p>
          </AnimatedSection>
        </div>
      </section>

      {/* Voltaire 1 family */}
      <section className="models-block" id="voltaire-1">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-header">
              <h2>The Voltaire 1 family.</h2>
              <p>Our own compact, on-device models. None of these are publicly available yet, but Voltaire 1 Instruct is our first priority.</p>
            </div>
          </AnimatedSection>

          <div className="family-grid">
            {voltaireModels.map((model) => (
              <AnimatedSection key={model.id} variants={fadeUp}>
                <div className="family-card">
                  <div className="family-card-top">
                    <div className="family-icon">
                      <i className={model.icon}></i>
                    </div>
                    <span className={`status-badge status-${model.status}`}>
                      {STATUS_LABELS[model.status]}
                    </span>
                  </div>
                  <h3>{model.name}</h3>
                  <div className="family-sub">
                    {model.family} · {model.specialization}
                  </div>
                  <p>{model.purpose}</p>
                  <div className="detail-chips">
                    <span className="detail-chip">
                      <i className="fa-solid fa-ruler"></i> {model.size}
                    </span>
                    {model.runtime && (
                      <span className="detail-chip">
                        <i className="fa-solid fa-microchip"></i> {model.runtime}
                      </span>
                    )}
                    {model.formats?.map((format) => (
                      <span className="detail-chip" key={format}>
                        <i className="fa-solid fa-cube"></i> {format}
                      </span>
                    ))}
                    {model.version && (
                      <span className="detail-chip">
                        <i className="fa-solid fa-tag"></i> {model.version}
                      </span>
                    )}
                  </div>
                </div>
              </AnimatedSection>
            ))}
          </div>

          <AnimatedSection variants={fadeUp}>
            <div className="naming-note">
              <i className="fa-solid fa-circle-info"></i>
              <p>
                <strong>Naming.</strong> Each model is named as
                <em> Family + Specialization</em> (for example, Voltaire 1 Instruct), with a
                size such as 1.7B. Versions and formats are added once a model is assigned one.
              </p>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* Roadmap */}
      <section className="models-block alt" id="roadmap">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-header">
              <h2>Roadmap.</h2>
              <p>How we plan to grow the Voltaire 1 family, in order.</p>
            </div>
          </AnimatedSection>
          <AnimatedSection variants={fadeUp}>
            <ol className="roadmap-list">
              {roadmapSteps.map((step, i) => (
                <li className="roadmap-step" key={step.title}>
                  <span className="roadmap-number">{i + 1}</span>
                  <div>
                    <h3>{step.title}</h3>
                    <p>{step.detail}</p>
                  </div>
                </li>
              ))}
            </ol>
          </AnimatedSection>
        </div>
      </section>

      {/* Third-party models */}
      <section className="models-block" id="third-party">
        <div className="container">
          <AnimatedSection variants={fadeUp}>
            <div className="section-header">
              <h2>Third-party models.</h2>
              <p>Open-weight models from other developers, available to download in the app. Each model is the property of its respective developer.</p>
            </div>
          </AnimatedSection>

          <div className="third-party-grid">
            {thirdPartyModels.map((model) => (
              <AnimatedSection key={model.id} variants={fadeUp}>
                <div className="third-party-card">
                  <div className="tp-logo">
                    <Image
                      src={model.logo}
                      alt={model.alt}
                      width={44}
                      height={44}
                      style={model.white ? { filter: "invert(1)" } : undefined}
                    />
                  </div>
                  <div className="tp-body">
                    <div className="tp-head">
                      <h3>{model.name}</h3>
                      <span className="tp-dev">by {model.developer}</span>
                    </div>
                    <p>{model.purpose}</p>
                    <div className="detail-chips">
                      <span className="detail-chip">
                        <i className="fa-solid fa-microchip"></i> {model.runtime}
                      </span>
                      <span className="detail-chip">
                        <i className="fa-solid fa-mobile-screen"></i> {model.platforms.join(", ")}
                      </span>
                      <span className="detail-chip success">
                        <i className="fa-solid fa-check"></i> Supported
                      </span>
                    </div>
                    <a
                      href={model.officialUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="tp-link"
                    >
                      Official page <i className="fa-solid fa-arrow-up-right-from-square"></i>
                    </a>
                  </div>
                </div>
              </AnimatedSection>
            ))}
          </div>

          <AnimatedSection variants={fadeUp}>
            <div className="info-note">
              <i className="fa-solid fa-flask"></i>
              <p>
                <strong>Experimental and internal builds.</strong> Base checkpoints,
                unfinished training runs, and private experiments are not listed here.
                Voltaire 2.5 1.7B remains an experimental build and is not publicly
                available.
              </p>
            </div>
          </AnimatedSection>
        </div>
      </section>

      <Footer />
      <ScrollTopButton />
    </main>
  );
}
