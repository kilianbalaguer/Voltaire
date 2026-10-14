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
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <nav className={`nav ${scrolled ? "scrolled" : ""} ${open ? "open" : ""}`}>
      <div className="nav-bar">
        <Link href="/" className="nav-brand" onClick={() => setOpen(false)}>
          <Image src="/images/logo-only-small.png" alt="" width={26} height={26} />
          Voltaire
        </Link>
        <ul className="nav-links">
          {navItems.map((item) => (
            <li key={item.href}>
              <Link href={item.href}>{item.label}</Link>
            </li>
          ))}
        </ul>
        <Link href="/#download" className="btn btn-dark nav-cta">
          Get Voltaire
        </Link>
        <button
          className="nav-toggle"
          onClick={() => setOpen(!open)}
          aria-label={open ? "Close menu" : "Open menu"}
          aria-expanded={open}
        >
          <i className={`fa-solid ${open ? "fa-xmark" : "fa-bars-staggered"}`}></i>
        </button>
      </div>
      {open && (
        <div className="nav-menu">
          {navItems.map((item) => (
            <Link key={item.href} href={item.href} onClick={() => setOpen(false)}>
              {item.label}
            </Link>
          ))}
          <Link href="/#download" className="btn btn-dark" onClick={() => setOpen(false)}>
            Get Voltaire
          </Link>
        </div>
      )}
    </nav>
  );
}
