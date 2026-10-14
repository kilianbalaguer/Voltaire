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

function badgeClass(status: ModelStatus) {
  if (status === "available") return "badge-ok";
  if (status === "in-development") return "badge-soon";
  return "badge-muted";
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
      <div className="segmented" role="tablist" aria-label="Model categories">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            type="button"
            role="tab"
            aria-selected={active === tab.id}
            onClick={() => setActive(tab.id)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div className="catalog-grid">
        {visibleFamilies.map((family) => {
          const status = familyStatus(family.name);
          const logo = familyLogo(family.name);
          return (
            <AnimatedSection key={family.name} variants={fadeUp}>
              <div className="model-card voltaire">
                <div className="model-card-top">
                  <div className="model-card-logo">
                    {logo && (
                      <Image src={logo} alt="" width={28} height={28} style={{ filter: "brightness(0) invert(1)" }} />
                    )}
                  </div>
                  <span className={`badge ${badgeClass(status)}`}>{STATUS_LABELS[status]}</span>
                </div>
                <h3>{family.name}</h3>
                <p>{family.tagline}</p>
                <div className="model-card-meta">
                  <span>by Voltaire</span>
                </div>
              </div>
            </AnimatedSection>
          );
        })}

        {visibleModels.map((model) => (
          <AnimatedSection key={model.id} variants={fadeUp}>
            <div className="model-card voltaire">
              <div className="model-card-top">
                <div className="model-card-logo">
                  {model.logo ? (
                    <Image src={model.logo} alt="" width={28} height={28} style={{ filter: "brightness(0) invert(1)" }} />
                  ) : (
                    <i className={model.icon}></i>
                  )}
                </div>
                <span className={`badge ${badgeClass(model.status)}`}>{STATUS_LABELS[model.status]}</span>
              </div>
              <h3>{model.name}</h3>
              <p>{model.purpose}</p>
              <div className="model-card-meta">
                <span>{model.size}</span>
                {model.runtime && <span>{model.runtime}</span>}
              </div>
            </div>
          </AnimatedSection>
        ))}

        {visibleThirdParty.map((model) => (
          <AnimatedSection key={model.id} variants={fadeUp}>
            <div className="model-card">
              <div className="model-card-top">
                <div className="model-card-logo">
                  <Image
                    src={model.logo}
                    alt=""
                    width={28}
                    height={28}
                    className={model.white ? "on-light-invert" : undefined}
                  />
                </div>
                <span className="badge badge-muted mono">{model.runtime}</span>
              </div>
              <h3>{model.name}</h3>
              <p>{model.purpose}</p>
              <div className="model-card-meta">
                <span>by {model.developer}</span>
                <a href={model.officialUrl} target="_blank" rel="noopener noreferrer">
                  Official page <i className="fa-solid fa-arrow-up-right-from-square"></i>
                </a>
              </div>
            </div>
          </AnimatedSection>
        ))}
      </div>
    </>
  );
}
