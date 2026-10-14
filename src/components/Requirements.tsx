"use client";

import { useState } from "react";
import { platforms } from "@/lib/devices";

export default function Requirements() {
  const [active, setActive] = useState(platforms[0].id);
  const platform = platforms.find((p) => p.id === active) ?? platforms[0];

  return (
    <>
      <div className="segmented" role="tablist" aria-label="Platforms">
        {platforms.map((p) => (
          <button
            key={p.id}
            type="button"
            role="tab"
            aria-selected={p.id === active}
            aria-controls="req-panel"
            onClick={() => setActive(p.id)}
          >
            <i className={p.icon}></i>
            {p.name}
            {p.status === "later" && <span className="dot" aria-label="coming later" />}
          </button>
        ))}
      </div>

      <div className="req-card" id="req-panel" role="tabpanel">
        <div className="req-card-head">
          <h3>{platform.name}</h3>
          {platform.status === "launch" ? (
            <span className="badge badge-ok">Launch platform</span>
          ) : (
            <span className="badge badge-soon">Coming later</span>
          )}
          <p>{platform.note}</p>
        </div>
        <div className="req-cols">
          <div className="req-yes">
            <h4><i className="fa-solid fa-check"></i> Supported</h4>
            <div className="chips">
              {platform.supported.map((d) => (
                <span key={d} className="chip">{d}</span>
              ))}
            </div>
          </div>
          <div className="req-no">
            <h4><i className="fa-solid fa-xmark"></i> Not supported</h4>
            <div className="chips">
              {platform.unsupported.map((d) => (
                <span key={d} className="chip">{d}</span>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="specs">
        <div className="spec">
          <i className="fa-brands fa-apple"></i>
          <div>
            <small>OS</small>
            <span>iOS 26+ · iPadOS 26+ · macOS 26+</span>
          </div>
        </div>
        <div className="spec">
          <i className="fa-solid fa-hard-drive"></i>
          <div>
            <small>Storage</small>
            <span>700 MB minimum</span>
          </div>
        </div>
        <div className="spec">
          <i className="fa-solid fa-wifi"></i>
          <div>
            <small>Internet</small>
            <span>Only to download models</span>
          </div>
        </div>
      </div>
    </>
  );
}
