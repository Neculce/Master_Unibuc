"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

type Ticket = {
  ticket_id: number;
  titlu: string;
  data_creare: string;
  data_rezolvare: string | null;
  status_nume: string;
  prioritate_nume: string;
  departament_nume: string;
  client_email: string;
  client_nume: string | null;
};

type User = {
  role: string;
  email: string;
  name: string;
};

function formatDate(v: string | null) {
  if (!v) return "—";
  const d = new Date(v);
  return isNaN(d.getTime()) ? v : d.toLocaleString("ro-RO", { dateStyle: "short", timeStyle: "short" });
}

function statusClass(s: string) {
  if (s === "Rezolvat" || s === "Închis") return "bg-green-100 text-green-800";
  if (s === "În desfășurare" || s === "În așteptare") return "bg-blue-100 text-blue-800";
  return "bg-gray-100 text-gray-800";
}

export default function DashboardPage() {
  const [user, setUser] = useState<User | null>(null);
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    Promise.all([
      fetch("/api/auth/me").then((r) => (r.ok ? r.json() : null)),
      fetch("/api/tickets").then((r) => (r.ok ? r.json() : Promise.reject(new Error("Failed to load")))),
    ])
      .then(([me, list]) => {
        setUser(me || null);
        setTickets(Array.isArray(list) ? list : []);
      })
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-28 gap-4">
        <span className="material-symbols-outlined animate-spin text-5xl text-primary">progress_activity</span>
        <p className="text-sm text-gray-500">Loading tickets…</p>
      </div>
    );
  }
  if (error) {
    return (
      <div className="rounded-2xl border border-red-200/80 bg-red-50 p-6 text-red-700 flex items-start gap-4 shadow-card">
        <span className="material-symbols-outlined text-2xl shrink-0">error</span>
        <div>
          <p className="font-semibold">Error loading tickets</p>
          <p className="text-sm mt-1 opacity-90">{error}</p>
        </div>
      </div>
    );
  }

  const isAgent = user?.role === "agent";

  return (
    <div className="flex flex-col gap-8">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-[#0e141b]">Tickets</h1>
          <p className="text-gray-500 mt-2 text-sm">
            {isAgent ? "All support tickets" : "Your tickets"}
            {user?.name ? ` · ${user.name}` : ""}
          </p>
        </div>
      </div>
      <div className="bg-white border border-gray-200/90 rounded-2xl shadow-card-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[800px] text-left border-collapse">
            <thead>
              <tr className="bg-gray-50/90 border-b border-gray-200">
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500 w-24">ID</th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Title</th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Client</th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Department</th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Status</th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Priority</th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Created</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {tickets.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-20 text-center">
                    <span className="material-symbols-outlined text-5xl text-gray-300 mb-3 block">inbox</span>
                    <p className="text-gray-600 font-medium">No tickets found</p>
                    <p className="text-sm text-gray-400 mt-1">Tickets will appear here when created.</p>
                  </td>
                </tr>
              ) : (
                tickets.map((t) => (
                  <tr key={t.ticket_id} className="hover:bg-gray-50/80 transition-colors duration-200 group">
                    <td className="px-6 py-4 text-sm font-medium text-gray-500">
                      <Link href={"/tickets/" + t.ticket_id} className="text-primary hover:text-primary-hover hover:underline transition-colors rounded focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/30 focus-visible:ring-offset-1">
                        #{t.ticket_id}
                      </Link>
                    </td>
                    <td className="px-6 py-4 text-sm font-medium text-[#0e141b]">
                      <Link href={"/tickets/" + t.ticket_id} className="hover:text-primary transition-colors hover:underline rounded focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/30 focus-visible:ring-offset-1">
                        {t.titlu}
                      </Link>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">{t.client_nume || t.client_email}</td>
                    <td className="px-6 py-4 text-sm text-gray-600">{t.departament_nume}</td>
                    <td className="px-6 py-4">
                      <span className={"inline-flex px-2.5 py-1 rounded-lg text-xs font-medium " + statusClass(t.status_nume)}>
                        {t.status_nume}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">{t.prioritate_nume}</td>
                    <td className="px-6 py-4 text-sm text-gray-500 tabular-nums">{formatDate(t.data_creare)}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
