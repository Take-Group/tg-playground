# Skill: New Component

## What it does
Adds a new UI component following the shadcn/ui + CVA + Tailwind pattern used in this project.

## Files involved
- `src/components/ui/<name>.tsx` — primitive/reusable UI component
- `src/components/<name>.tsx` — composite/business component
- `src/lib/utils.ts` — `cn()` utility for className merging

## Flow
1. **Decide the component type**:
   - Primitive UI (button, card, input) → `src/components/ui/`
   - Business/feature component (user-card, order-list) → `src/components/`
2. **Create the component file**
3. **Add `"use client"` directive** if the component uses hooks, event handlers, or browser APIs
4. **Use CVA** for variant management if the component has multiple visual styles
5. **Use `cn()`** for safe className composition

## Example — primitive UI component
```tsx
// src/components/ui/badge.tsx
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const badgeVariants = cva(
  "inline-flex items-center rounded-md px-2.5 py-0.5 text-xs font-semibold",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground",
        secondary: "bg-secondary text-secondary-foreground",
        destructive: "bg-destructive text-destructive-foreground",
      },
    },
    defaultVariants: { variant: "default" },
  }
);

interface BadgeProps extends React.HTMLAttributes<HTMLDivElement>, VariantProps<typeof badgeVariants> {}

export function Badge({ className, variant, ...props }: BadgeProps) {
  return <div className={cn(badgeVariants({ variant }), className)} {...props} />;
}
```

## Example — business component
```tsx
// src/components/user-card.tsx
import { Badge } from "@/components/ui/badge";

interface UserCardProps {
  name: string;
  role: string;
}

export function UserCard({ name, role }: UserCardProps) {
  return (
    <div className="rounded-lg border p-4">
      <h3 className="font-semibold">{name}</h3>
      <Badge variant="secondary">{role}</Badge>
    </div>
  );
}
```

## How to extend
- Check if shadcn/ui already has the component: `bunx shadcn@latest add <name>`
- Keep components small — if it grows past 200 lines, split into sub-components
- Props interface always explicitly typed (no `any`)
