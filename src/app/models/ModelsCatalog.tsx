"use client";

import { useState } from "react";
import Image from "next/image";
import AnimatedSection from "@/components/AnimatedSection";
import { STATUS_LABELS, thirdPartyModels, voltaireModels } from "@/lib/models";
import { fadeUp } from "@/lib/animations";

export default function ModelsCatalog() {
  // Every Voltaire family in the data source automatically becomes a tab,
  // so adding "Voltaire 1.5", "Voltaire 2", etc. needs no changes here.
  const families = Array.from(new Set(voltaireModels.map((m) => m.family)));
  const tabs = [
    { id: "all", label: "All" },
    ...families.map((family) => ({ id: family, label: family })),
    { id: "third-party", label: "Third-party" },
  ];

  const [active, setActive] = useState("all");

  const showVoltaire = active === "all" || families.includes(active);
  const showThirdParty = active === "all" || active === "third-party";
  const visibleVoltaire =
    active === "all"
      ? voltaireModels
      : voltaireModels.filter((m) => m.family === active);

  return (
    <>
      <div className="pill-switcher" role="tablist" aria-label="Model categories">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            type="button"
            role="tab"
            aria-selected={active === tab.id}
            className={`pill-btn ${active === tab.id ? "active" : ""}`}
            onClick={() => setActive(tab.id)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div className="models-grid">
        {showVoltaire &&
          visibleVoltaire.map((model) => (
            <AnimatedSection key={model.id} variants={fadeUp}>
              <div className="model-card">
                <div className="model-card-icon">
                  <i className={model.icon}></i>
                </div>
                <h4>{model.name}</h4>
                <p>
                  {model.family} · {model.size}
                </p>
                <span className={`status-badge status-${model.status}`}>
                  {STATUS_LABELS[model.status]}
                </span>
              </div>
            </AnimatedSection>
          ))}

        {showThirdParty &&
          thirdPartyModels.map((model) => (
            <AnimatedSection key={model.id} variants={fadeUp}>
              <div className="model-card">
                <Image
                  src={model.logo}
                  alt={model.alt}
                  width={56}
                  height={56}
                  style={model.white ? { filter: "invert(1)" } : undefined}
                />
                <h4>{model.name}</h4>
                <p>{model.tagline}</p>
                <span className="model-card-dev">by {model.developer}</span>
                <a
                  className="model-card-link"
                  href={model.officialUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Official page <i className="fa-solid fa-arrow-up-right-from-square"></i>
                </a>
              </div>
            </AnimatedSection>
          ))}
      </div>
    </>
  );
}
