"use client";

import { useEffect, useState } from "react";

// Types each line, pauses, deletes it, then moves on — like the app's greeting.
export default function Typewriter({ lines }: { lines: string[] }) {
  const [index, setIndex] = useState(0);
  // Start with the first line already typed so the server-rendered page is never empty
  const [text, setText] = useState(lines[0]);
  const [deleting, setDeleting] = useState(false);

  useEffect(() => {
    const full = lines[index];
    let delay = deleting ? 28 : 55;
    if (!deleting && text === full) delay = 2200;
    if (deleting && text === "") delay = 300;

    const timer = setTimeout(() => {
      if (!deleting && text === full) {
        setDeleting(true);
      } else if (deleting && text === "") {
        setDeleting(false);
        setIndex((i) => (i + 1) % lines.length);
      } else {
        setText(full.slice(0, text.length + (deleting ? -1 : 1)));
      }
    }, delay);

    return () => clearTimeout(timer);
  }, [text, deleting, index, lines]);

  return (
    <span aria-label={lines[0]}>
      <span aria-hidden="true">{text}</span>
      <span className="caret" aria-hidden="true" />
    </span>
  );
}
