# Skill: API Communication

## What it does
Connects the frontend to backend API endpoints using TanStack React Query 5.

## Files involved
- `src/lib/api.ts` — base API client with fetch wrapper (create once)
- `src/hooks/use-<resource>.ts` — React Query hooks per resource (create per feature)
- `src/components/providers.tsx` — QueryClientProvider (already exists)

## Flow
1. **Create API client** (`src/lib/api.ts`) — a thin fetch wrapper that handles base URL, headers, and error responses
2. **Create a hook** (`src/hooks/use-<resource>.ts`) — wraps `useQuery` / `useMutation` for a specific backend resource
3. **Use the hook** in a client component

## Example — API client (create once)
```tsx
// src/lib/api.ts
const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

export async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { "Content-Type": "application/json", ...options?.headers },
    ...options,
  });
  if (!res.ok) {
    throw new Error(`API error: ${res.status}`);
  }
  return res.json() as Promise<T>;
}
```

## Example — query hook (read)
```tsx
// src/hooks/use-users.ts
"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiFetch } from "@/lib/api";

interface User {
  id: number;
  name: string;
}

export function useUsers() {
  return useQuery<User[]>({
    queryKey: ["users"],
    queryFn: () => apiFetch("/users"),
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { name: string }) =>
      apiFetch("/users", { method: "POST", body: JSON.stringify(data) }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["users"] }),
  });
}
```

## Example — usage in component
```tsx
// src/components/user-list.tsx
"use client";

import { useUsers } from "@/hooks/use-users";

export function UserList() {
  const { data: users, isLoading, error } = useUsers();

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <ul>
      {users?.map((user) => <li key={user.id}>{user.name}</li>)}
    </ul>
  );
}
```

## How to extend
- One hook file per resource/feature (e.g., `use-orders.ts`, `use-auth.ts`)
- Keep query keys consistent — always `["resource", ...params]`
- For mutations that modify data — always `invalidateQueries` on success
- Set `NEXT_PUBLIC_API_URL` in `.env.local` for non-default backend URL
