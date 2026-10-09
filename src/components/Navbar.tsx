"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";

const navItems = [
  { label: "Features", href: "/#features" },
  { label: "Models", href: "/models" },
  { label: "Requirements", href: "/#requirements" },
  { label: "FAQ", href: "/#faq" },
  { label: "Contact", href: "/#contact" },
];

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 50);
    onScroll();
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <>
      <nav className={`navbar ${scrolled ? "scrolled" : ""}`}>
        <div className="container">
          <div className="nav-inner">
            <Link href="/" className="nav-brand">
              <Image src="/images/logo-only-small.png" alt="Voltaire" width={36} height={36} />
              Voltaire
            </Link>
            <ul className="nav-links">
              {navItems.map((item) => (
                <li key={item.href}>
                  <Link href={item.href}>{item.label}</Link>
                </li>
              ))}
            </ul>
            <Link href="/#download" className="nav-cta">Download</Link>
            <button
              className="nav-hamburger"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              aria-label="Menu"
              aria-expanded={mobileMenuOpen}
            >
              <i className={`fa-solid ${mobileMenuOpen ? "fa-xmark" : "fa-bars"}`}></i>
            </button>
          </div>
        </div>
      </nav>
      {mobileMenuOpen && (
        <div className="mobile-menu">
          {navItems.map((item) => (
            <Link key={item.href} href={item.href} onClick={() => setMobileMenuOpen(false)}>
              {item.label}
            </Link>
          ))}
          <Link href="/#download" className="mobile-menu-cta" onClick={() => setMobileMenuOpen(false)}>
            Download
          </Link>
        </div>
      )}
    </>
  );
}
