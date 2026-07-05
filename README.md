# Voltaire Website

The official marketing website for [Voltaire](https://github.com/kilianbalaguer/Voltaire), an on-device AI chat app for iPhone.

## Tech Stack

- **Next.js 16** — React framework with App Router
- **TypeScript** — Type-safe development
- **CSS** — Custom dark theme with CSS Grid layout

## Features

- Dark theme with cyan/blue accent
- Responsive design for all screen sizes
- Contact form with mailto integration
- Privacy and Terms pages
- Smooth scroll navigation

## Getting Started

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the site.

## Build

```bash
npm run build
```

Output is generated in the `.next/` directory.

## Structure

```
src/app/
├── page.tsx          # Homepage
├── layout.tsx        # Root layout
├── globals.css       # Global styles
├── privacy/
│   └── page.tsx      # Privacy Policy
└── terms/
    └── page.tsx      # Terms & Conditions
```

## License

This project is licensed under the **Voltaire Source Available License** — see the [LICENSE](./LICENSE) file for details.
