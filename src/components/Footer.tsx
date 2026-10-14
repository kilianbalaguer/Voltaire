import Image from "next/image";
import Link from "next/link";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-top">
          <Link href="/" className="nav-brand">
            <Image src="/images/logo-only-small.png" alt="" width={26} height={26} />
            Voltaire
          </Link>
          <div className="footer-links">
            <Link href="/#features">Features</Link>
            <Link href="/models">Models</Link>
            <Link href="/#faq">FAQ</Link>
            <Link href="/privacy">Privacy</Link>
            <Link href="/terms">Terms</Link>
            <Link href="/#contact">Contact</Link>
          </div>
        </div>
        <div className="footer-bottom">
          <span>&copy; 2026 Kilian Balaguer. All rights reserved.</span>
          <span className="mono">Made to run offline.</span>
        </div>
      </div>
    </footer>
  );
}
