import { AdminLayout } from "@/components/admin-layout";

export default function Home() {
  return (
    <AdminLayout>
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Dashboard</h1>
        <p className="text-muted-foreground">
          Welcome to TG Playground admin panel.
        </p>
      </div>
    </AdminLayout>
  );
}
