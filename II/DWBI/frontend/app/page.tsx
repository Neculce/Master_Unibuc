"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

type Ticket = {
  ticket_id: number;
  titlu: string;
  data_creare: string;
  data_ultima_actualizare: string | null;
  data_rezolvare: string | null;
  status_nume: string;
  prioritate_nume: string;
  departament_nume: string;
  client_email: string;
  client_nume: string | null;
};

type User = {
  id: number;
  role: string;
  email: string;
  name: string;
};

type StatusStat = {
  status_id: number;
  nume: string;
  este_final: boolean;
  count: number;
};

type DashboardStats = {
  total: number;
  statuses: StatusStat[];
};

function formatDate(v: string | null) {
  if (!v) return "—";
  const d = new Date(v);
  return isNaN(d.getTime()) ? v : d.toLocaleString("ro-RO", { dateStyle: "short", timeStyle: "short" });
}

function statusClass(s: string) {
  if (s === "Rezolvat" || s === "Inchis") return "bg-green-100 text-green-800";
  if (s === "In desfasurare" || s === "In asteptare") return "bg-blue-100 text-blue-800";
  return "bg-gray-100 text-gray-800";
}

function accentClasses(accent: "primary" | "green" | "blue" | "gray") {
  return accent === "primary"
    ? "bg-primary/10 text-primary border-primary/20"
    : accent === "green"
      ? "bg-green-50 text-green-700 border-green-200/60"
      : accent === "blue"
        ? "bg-blue-50 text-blue-700 border-blue-200/60"
        : "bg-gray-50 text-gray-700 border-gray-200/80";
}

function statusIcon(esteFinal: boolean, index: number): string {
  if (esteFinal) return index % 2 === 0 ? "check_circle" : "archive";
  const icons = ["inbox", "pending_actions", "schedule"];
  return icons[index % icons.length];
}

export default function DashboardPage() {
  const [user, setUser] = useState<User | null>(null);
  const [tickets, setTickets] = useState<Ticket[]>([]);
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [statusFilters, setStatusFilters] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const isAgent = user?.role === "agent";
  const statusNumeToFinal =
    stats != null ? new Map(stats.statuses.map((s) => [s.nume, s.este_final])) : new Map<string, boolean>();
  const clientOpenCount = stats?.statuses.filter((s) => !s.este_final).reduce((a, s) => a + s.count, 0) ?? 0;
  const clientClosedCount = stats?.statuses.filter((s) => s.este_final).reduce((a, s) => a + s.count, 0) ?? 0;

  const filteredTickets = (() => {
    if (statusFilters.size === 0) return tickets;
    if (!isAgent) {
      const wantOpen = statusFilters.has("Deschis");
      const wantClosed = statusFilters.has("Închis");
      if (!wantOpen && !wantClosed) return tickets;
      return tickets.filter((t) => {
        const closed = statusNumeToFinal.get(t.status_nume) === true;
        return (wantOpen && !closed) || (wantClosed && closed);
      });
    }
    return tickets.filter((t) => statusFilters.has(t.status_nume));
  })();

  const toggleStatusFilter = (nume: string) => {
    setStatusFilters((prev) => {
      const next = new Set(prev);
      if (next.has(nume)) next.delete(nume);
      else next.add(nume);
      return next;
    });
  };

  const clearStatusFilters = () => setStatusFilters(new Set());

  const isTicketClosed = (t: Ticket) => statusNumeToFinal.get(t.status_nume) === true;

  useEffect(() => {
    Promise.all([
      fetch("/api/auth/me").then((r) => (r.ok ? r.json() : null)),
      fetch("/api/tickets?stats=true").then((r) => {
        if (!r.ok) throw new Error("Failed to load");
        return r.json();
      }),
    ])
      .then(([me, data]) => {
        setUser(me || null);
        const list = Array.isArray(data) ? data : data?.tickets ?? [];
        setTickets(list);
        setStats(data?.stats ?? null);
      })
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-28 gap-4">
        <span className="material-symbols-outlined animate-spin text-5xl text-primary">progress_activity</span>
        <p className="text-sm text-gray-500">Se încarcă…</p>
      </div>
    );
  }
  if (error) {
    return (
      <div className="rounded-2xl border border-red-200/80 bg-red-50 p-6 text-red-700 flex items-start gap-4 shadow-card">
        <span className="material-symbols-outlined text-2xl shrink-0">error</span>
        <div>
          <p className="font-semibold">Eroare la încărcare</p>
          <p className="text-sm mt-1 opacity-90">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-8">
      {/* Header: role-aware */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-3xl font-bold tracking-tight text-[#0e141b]">Dashboard</h1>
            <span
              className={
                isAgent
                  ? "rounded-lg bg-primary/10 px-2.5 py-0.5 text-xs font-semibold text-primary"
                  : "rounded-lg bg-gray-100 px-2.5 py-0.5 text-xs font-semibold text-gray-700"
              }
            >
              {isAgent ? "Agent" : "Client"}
            </span>
          </div>
          <p className="text-gray-500 mt-1.5 text-sm">
            {isAgent ? "Toate ticketurile de suport" : "Ticketurile tale"}
            {user?.name ? ` · ${user.name}` : ""}
          </p>
        </div>
      </div>

      {/* Filtre pe status – pentru client doar Deschis/Închis, pentru agent toate statusurile */}
      {stats != null && (
        <div className="rounded-2xl border border-gray-200/90 bg-white shadow-card-lg overflow-hidden">
          <div className="border-b border-gray-100 bg-gray-50/60 px-6 py-3">
            <h2 className="text-sm font-semibold text-[#0e141b]">Filtre</h2>
            <p className="text-xs text-gray-500 mt-0.5">
              {isAgent ? "Poți selecta mai multe statusuri." : "Deschis = în lucru, Închis = rezolvat sau închis."}
            </p>
          </div>
          <div className="p-4 flex flex-wrap gap-2">
            <button
              type="button"
              onClick={clearStatusFilters}
              className={`inline-flex items-center gap-2 rounded-xl border px-4 py-2.5 text-sm font-medium transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/40 focus-visible:ring-offset-1 ${
                statusFilters.size === 0
                  ? "bg-primary text-white border-primary shadow-sm"
                  : "bg-white text-gray-700 border-gray-200 hover:bg-gray-50 hover:border-gray-300"
              }`}
            >
              <span className="material-symbols-outlined text-lg">confirmation_number</span>
              <span>Toate</span>
              <span className="tabular-nums opacity-90">({stats.total})</span>
            </button>
            {isAgent ? (
              stats.statuses.map((st, index) => {
                const accent = st.este_final ? "green" : "blue";
                const icon = statusIcon(st.este_final, index);
                const isActive = statusFilters.has(st.nume);
                const activeClasses =
                  accent === "green"
                    ? "bg-green-600 text-white border-green-600 hover:bg-green-700"
                    : accent === "blue"
                      ? "bg-blue-600 text-white border-blue-600 hover:bg-blue-700"
                      : "bg-gray-700 text-white border-gray-700 hover:bg-gray-800";
                const inactiveClasses = "bg-white text-gray-700 border-gray-200 hover:bg-gray-50 hover:border-gray-300";
                return (
                  <button
                    key={st.status_id}
                    type="button"
                    onClick={() => toggleStatusFilter(st.nume)}
                    className={`inline-flex items-center gap-2 rounded-xl border px-4 py-2.5 text-sm font-medium transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-1 ${
                      isActive ? activeClasses : inactiveClasses
                    } ${isActive && accent === "green" ? "focus-visible:ring-green-500" : ""} ${isActive && accent === "blue" ? "focus-visible:ring-blue-500" : ""}`}
                  >
                    <span className="material-symbols-outlined text-lg">{icon}</span>
                    <span>{st.nume}</span>
                    <span className="tabular-nums opacity-90">({st.count})</span>
                  </button>
                );
              })
            ) : (
              <>
                <button
                  type="button"
                  onClick={() => toggleStatusFilter("Deschis")}
                  className={`inline-flex items-center gap-2 rounded-xl border px-4 py-2.5 text-sm font-medium transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-1 ${
                    statusFilters.has("Deschis")
                      ? "bg-blue-600 text-white border-blue-600 hover:bg-blue-700 focus-visible:ring-blue-500"
                      : "bg-white text-gray-700 border-gray-200 hover:bg-gray-50 hover:border-gray-300"
                  }`}
                >
                  <span className="material-symbols-outlined text-lg">inbox</span>
                  <span>Deschis</span>
                  <span className="tabular-nums opacity-90">({clientOpenCount})</span>
                </button>
                <button
                  type="button"
                  onClick={() => toggleStatusFilter("Închis")}
                  className={`inline-flex items-center gap-2 rounded-xl border px-4 py-2.5 text-sm font-medium transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-1 ${
                    statusFilters.has("Închis")
                      ? "bg-green-600 text-white border-green-600 hover:bg-green-700 focus-visible:ring-green-500"
                      : "bg-white text-gray-700 border-gray-200 hover:bg-gray-50 hover:border-gray-300"
                  }`}
                >
                  <span className="material-symbols-outlined text-lg">check_circle</span>
                  <span>Închis</span>
                  <span className="tabular-nums opacity-90">({clientClosedCount})</span>
                </button>
              </>
            )}
          </div>
        </div>
      )}

      {/* Tickets table */}
      <div className="rounded-2xl border border-gray-200/90 bg-white shadow-card-lg overflow-hidden">
        <div className="border-b border-gray-100 bg-gray-50/60 px-6 py-4">
          <h2 className="text-base font-semibold text-[#0e141b]">Tickets</h2>
          <p className="text-sm text-gray-500 mt-0.5">
            {statusFilters.size > 0
              ? `${filteredTickets.length} ticketuri afișate (filtru: ${Array.from(statusFilters).join(", ")})`
              : isAgent
                ? "Lista tuturor ticketurilor din sistem"
                : "Lista ticketurilor deschise de tine"}
          </p>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[800px] text-left border-collapse">
            <thead>
              <tr className="bg-gray-50/90 border-b border-gray-200">
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500 w-24">ID</th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Titlu</th>
                {isAgent && (
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Client</th>
                )}
                {isAgent && (
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Departament</th>
                )}
                {!isAgent && (
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Stare</th>
                )}
                {isAgent && (
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Status</th>
                )}
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Prioritate</th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Creat</th>
                {!isAgent && (
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Data rezolvare</th>
                )}
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-gray-500">Ultima actualizare</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filteredTickets.length === 0 ? (
                <tr>
                  <td colSpan={isAgent ? 8 : 7} className="px-6 py-20 text-center">
                    <span className="material-symbols-outlined text-5xl text-gray-300 mb-3 block">
                      {statusFilters.size > 0 ? "filter_list_off" : "inbox"}
                    </span>
                    <p className="text-gray-600 font-medium">
                      {statusFilters.size > 0 ? "Niciun ticket pentru filtrele alese" : "Niciun ticket"}
                    </p>
                    <p className="text-sm text-gray-400 mt-1">
                      {statusFilters.size > 0
                        ? "Schimbă sau resetează filtrele pentru a vedea mai multe rezultate."
                        : isAgent
                          ? "Nu există ticketuri în sistem."
                          : "Ticketurile tale vor apărea aici."}
                    </p>
                  </td>
                </tr>
              ) : (
                filteredTickets.map((t) => (
                  <tr key={t.ticket_id} className="hover:bg-gray-50/80 transition-colors duration-200 group">
                    <td className="px-6 py-4 text-sm font-medium text-gray-500">
                      <Link
                        href={"/tickets/" + t.ticket_id}
                        className="text-primary hover:text-primary-hover transition-colors rounded focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/30 focus-visible:ring-offset-1"
                      >
                        #{t.ticket_id}
                      </Link>
                    </td>
                    <td className="px-6 py-4 text-sm font-medium text-[#0e141b]">
                      <Link
                        href={"/tickets/" + t.ticket_id}
                        className="hover:text-primary transition-colors rounded focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/30 focus-visible:ring-offset-1 line-clamp-1"
                      >
                        {t.titlu}
                      </Link>
                    </td>
                    {isAgent && (
                      <td className="px-6 py-4 text-sm text-gray-600">{t.client_nume || t.client_email}</td>
                    )}
                    {isAgent && (
                      <td className="px-6 py-4 text-sm text-gray-600">{t.departament_nume}</td>
                    )}
                    {!isAgent && (
                      <td className="px-6 py-4">
                        <span
                          className={
                            isTicketClosed(t)
                              ? "inline-flex px-2.5 py-1 rounded-lg text-xs font-medium bg-green-100 text-green-800"
                              : "inline-flex px-2.5 py-1 rounded-lg text-xs font-medium bg-blue-100 text-blue-800"
                          }
                          title={t.status_nume}
                        >
                          {isTicketClosed(t) ? "Închis" : "Deschis"}
                        </span>
                      </td>
                    )}
                    {isAgent && (
                      <td className="px-6 py-4">
                        <span
                          className={
                            "inline-flex px-2.5 py-1 rounded-lg text-xs font-medium " + statusClass(t.status_nume)
                          }
                        >
                          {t.status_nume}
                        </span>
                      </td>
                    )}
                    <td className="px-6 py-4 text-sm text-gray-600">{t.prioritate_nume}</td>
                    <td className="px-6 py-4 text-sm text-gray-500 tabular-nums">{formatDate(t.data_creare)}</td>
                    {!isAgent && (
                      <td className="px-6 py-4 text-sm text-gray-500 tabular-nums">
                        {formatDate(t.data_rezolvare)}
                      </td>
                    )}
                    <td className="px-6 py-4 text-sm text-gray-500 tabular-nums">
                      {formatDate(t.data_ultima_actualizare ?? t.data_creare)}
                    </td>
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
