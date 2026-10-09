import type { Metadata } from "next";
import AnimatedSection from "@/components/AnimatedSection";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ScrollTopButton from "@/components/ScrollTopButton";
import ModelsCatalog from "./ModelsCatalog";
import { roadmapSteps } from "@/lib/models";
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
              Use the switcher to browse the Voltaire 1 family we are building and the
              third-party models available to download in the app.
            </p>
          </AnimatedSection>
        </div>
      </section>

      {/* Catalogue */}
      <section className="models-block alt" id="catalogue">
        <div className="container">
          <ModelsCatalog />

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

      {/* Roadmap */}
      <section className="models-block" id="roadmap">
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

      <Footer />
      <ScrollTopButton />
    </main>
  );
}
