"use client";

import { useState } from "react";
import Image from "next/image";
import AnimatedSection from "@/components/AnimatedSection";
import {
  STATUS_LABELS,
  thirdPartyModels,
  voltaireFamilies,
  voltaireModels,
  type ModelStatus,
} from "@/lib/models";
import { fadeUp } from "@/lib/animations";

// A family is only worth showing in "All" once it has something real in it.
function familyStatus(family: string): ModelStatus {
  const models = voltaireModels.filter((m) => m.family === family);
  if (models.some((m) => m.status === "in-development")) return "in-development";
  if (models.some((m) => m.status === "available")) return "available";
  return "planned";
}

function familyLogo(family: string) {
  return voltaireModels.find((m) => m.family === family)?.logo;
}

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

  const isFamilyTab = families.includes(active);

  // "All" shows one clean entry per Voltaire family that has something real
  // in it, alongside the downloadable third-party models. Sizes, versions and
  // formats stay in the family tab.
  const visibleFamilies =
    active === "all"
      ? voltaireFamilies.filter((f) => familyStatus(f.name) !== "planned")
      : [];

  const visibleModels = isFamilyTab
    ? voltaireModels.filter((m) => m.family === active)
    : [];

  const visibleThirdParty =
    active === "all" || active === "third-party" ? thirdPartyModels : [];

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
        {visibleFamilies.map((family) => (
          <AnimatedSection key={family.name} variants={fadeUp}>
            <div className="model-card">
              {familyLogo(family.name) && (
                <Image
                  src={familyLogo(family.name)!}
                  alt={family.name}
                  width={56}
                  height={56}
                  style={{ filter: "brightness(0) invert(1)" }}
                />
              )}
              <h4>{family.name}</h4>
              <p>{family.tagline}</p>
              <span className="model-card-dev">by Voltaire</span>
              <span className={`status-badge status-${familyStatus(family.name)}`}>
                {STATUS_LABELS[familyStatus(family.name)]}
              </span>
            </div>
          </AnimatedSection>
        ))}

        {visibleModels.map((model) => (
          <AnimatedSection key={model.id} variants={fadeUp}>
            <div className="model-card">
              {model.logo ? (
                <Image
                  src={model.logo}
                  alt={model.name}
                  width={56}
                  height={56}
                  style={{ filter: "brightness(0) invert(1)" }}
                />
              ) : (
                <div className="model-card-icon">
                  <i className={model.icon}></i>
                </div>
              )}
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

        {visibleThirdParty.map((model) => (
          <AnimatedSection key={model.id} variants={fadeUp}>
            <div className="model-card">
              <Image
                src={model.logo}
                alt={model.alt}
                width={56}
                height={56}
                style={model.white ? { filter: "brightness(0) invert(1)" } : undefined}
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
