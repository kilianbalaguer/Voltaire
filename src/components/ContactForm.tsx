"use client";

import type { FormEvent } from "react";
import { CONTACT_EMAIL } from "@/lib/site";

export default function ContactForm() {
  const onSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const name = String(data.get("name") ?? "");
    const email = String(data.get("email") ?? "");
    const subject = String(data.get("subject") ?? "");
    const message = String(data.get("message") ?? "");
    const body = `From: ${name}\nEmail: ${email}\n\n${message}`;
    window.location.href = `mailto:${CONTACT_EMAIL}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
  };

  return (
    <form className="form" onSubmit={onSubmit}>
      <div className="field">
        <label htmlFor="contact-name">Name</label>
        <input id="contact-name" name="name" type="text" placeholder="Your name" autoComplete="name" required />
      </div>
      <div className="field">
        <label htmlFor="contact-email">Email</label>
        <input id="contact-email" name="email" type="email" placeholder="you@example.com" autoComplete="email" required />
      </div>
      <div className="field full">
        <label htmlFor="contact-subject">Subject</label>
        <input id="contact-subject" name="subject" type="text" placeholder="What's this about?" />
      </div>
      <div className="field full">
        <label htmlFor="contact-message">Message</label>
        <textarea id="contact-message" name="message" rows={5} placeholder="Your message…" required />
      </div>
      <button type="submit" className="btn btn-dark">
        Send message <i className="fa-solid fa-arrow-right"></i>
      </button>
    </form>
  );
}
