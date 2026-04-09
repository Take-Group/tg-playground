# Skill: New Page

## What it does
Adds a new route/page using Next.js 16 App Router.

## Files involved
- `src/app/<route>/page.tsx` — page component (create)
- `src/app/<route>/loading.tsx` — loading state (optional, recommended)
- `src/app/<route>/error.tsx` — error boundary (optional, recommended)
- `src/app/<route>/layout.tsx` — layout wrapper (optional, if page needs its own layout)

## Flow
1. **Create route directory** at `src/app/<route>/`
2. **Create page.tsx** — default export, server component by default
3. **Add loading.tsx** — shown while page or data loads (Suspense boundary)
4. **Add error.tsx** — catches errors in the page tree (`"use client"` required)

## Example
```tsx
// src/app/dashboard/page.tsx
export const metadata = {
  title: "Dashboard",
};

export default function DashboardPage() {
  return (
    <main className="container mx-auto p-6">
      <h1 className="text-2xl font-bold">Dashboard</h1>
    </main>
  );
}

// src/app/dashboard/loading.tsx
export default function Loading() {
  return <div className="container mx-auto p-6">Loading...</div>;
}

// src/app/dashboard/error.tsx
"use client";

export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div className="container mx-auto p-6">
      <h2>Something went wrong</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

## How to extend
- Nested routes: create subdirectories (e.g., `src/app/dashboard/settings/page.tsx`)
- Dynamic routes: use `[param]` folder naming (e.g., `src/app/users/[id]/page.tsx`)
- If the page needs client-side interactivity — extract interactive parts into client components in `src/components/`, keep the page as a server component
