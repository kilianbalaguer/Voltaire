import Image from "next/image";
import Link from "next/link";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-inner">
          <Link href="/" className="footer-brand">
            <Image src="/images/logo-only-small.png" alt="Voltaire" width={28} height={28} />
            Voltaire
          </Link>
          <div className="footer-links">
            <Link href="/models">Models</Link>
            <Link href="/privacy">Privacy</Link>
            <Link href="/terms">Terms</Link>
            <Link href="/#contact">Contact</Link>
          </div>
        </div>
        <div className="footer-copy">
          &copy; 2026 Kilian Balaguer. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
