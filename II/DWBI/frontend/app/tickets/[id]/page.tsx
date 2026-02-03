"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useCallback, useEffect, useState } from "react";

type TicketDetail = {
  ticket: {
    ticket_id: number;
    titlu: string;
    descriere: string | null;
    data_creare: string;
    data_rezolvare: string | null;
    data_inchidere: string | null;
    status_nume: string;
    prioritate_nume: string;
    departament_nume: string;
    categorie_nume: string | null;
    client_email: string;
    client_nume: string | null;
    agent_nume: string | null;
    agent_email: string | null;
  };
  comments: {
    comment_id: number;
    content: string;
    created_date: string;
    source: string;
    author_name: string;
  }[];
  attachments: {
    atasament_id: number;
    file_name: string;
    file_path: string;
    file_size: number | null;
    file_type: string | null;
    upload_date: string;
    uploader_type: string;
  }[];
};

function formatDate(v: string | null) {
  if (!v) return "—";
  const d = new Date(v);
  return isNaN(d.getTime()) ? v : d.toLocaleString("ro-RO", { dateStyle: "short", timeStyle: "short" });
}

function formatBytes(n: number | null) {
  if (n == null) return "—";
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
  return `${(n / (1024 * 1024)).toFixed(1)} MB`;
}

function statusClass(s: string) {
  if (s === "Rezolvat" || s === "Închis") return "bg-green-100 text-green-800";
  if (s === "În desfășurare" || s === "În așteptare") return "bg-blue-100 text-blue-800";
  return "bg-gray-100 text-gray-800";
}

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5 py-2.5 border-b border-gray-100 last:border-0">
      <span className="text-xs font-medium uppercase tracking-wider text-gray-500">{label}</span>
      <span className="text-sm text-[#0e141b] font-medium">{value}</span>
    </div>
  );
}

function TicketView({ data }: { data: TicketDetail }) {
  const { ticket, comments, attachments } = data;
  const hasAgent = ticket.agent_nume != null || ticket.agent_email != null;

  return (
    <div className="flex flex-col gap-8">
      <div className="flex items-center gap-2 text-sm">
        <Link href="/" className="text-gray-500 hover:text-primary transition-colors font-medium flex items-center gap-1.5 rounded-lg py-1 pr-1 focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/30 focus-visible:ring-offset-1">
          <span className="material-symbols-outlined text-[18px]">arrow_back</span>
          Dashboard
        </Link>
        <span className="material-symbols-outlined text-gray-300 text-[16px]">chevron_right</span>
        <span className="text-[#0e141b] font-semibold truncate">#{ticket.ticket_id} {ticket.titlu}</span>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_280px] gap-6 lg:gap-8">
        {/* Conținut principal: titlu, descriere, comentarii, atașamente */}
        <div className="min-w-0 flex flex-col gap-6">
          {/* Card titlu + descriere */}
          <div className="bg-white border border-gray-200/90 rounded-2xl shadow-card-lg overflow-hidden">
            <div className="px-6 py-5">
              <div className="flex flex-wrap items-center gap-3">
                <h1 className="text-xl font-bold text-[#0e141b]">{ticket.titlu}</h1>
                <span className={"inline-flex px-2.5 py-1 rounded-lg text-xs font-medium " + statusClass(ticket.status_nume)}>
                  {ticket.status_nume}
                </span>
              </div>
              {ticket.descriere ? (
                <div className="mt-4 pt-4 border-t border-gray-100">
                  <p className="text-sm text-gray-700 whitespace-pre-wrap leading-relaxed">{ticket.descriere}</p>
                </div>
              ) : null}
            </div>
          </div>

          {/* Card Comentarii */}
          <div className="bg-white border border-gray-200/90 rounded-2xl shadow-card-lg overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 bg-primary/5">
              <h2 className="text-sm font-semibold text-[#0e141b] flex items-center gap-2">
                <span className="material-symbols-outlined text-lg text-primary">chat_bubble_outline</span>
                Comentarii
                {comments.length > 0 && (
                  <span className="text-xs font-normal text-gray-500">({comments.length})</span>
                )}
              </h2>
            </div>
            <div className="px-6 py-5">
              {comments.length === 0 ? (
                <p className="text-sm text-gray-500 flex items-center gap-2.5 py-2">
                  <span className="material-symbols-outlined text-lg text-gray-400">forum</span>
                  Niciun comentariu încă.
                </p>
              ) : (
                <ul className="space-y-4">
                  {comments.map((c) => (
                    <li key={c.source + "-" + c.comment_id} className="flex gap-3">
                      <div className={"shrink-0 size-10 rounded-full flex items-center justify-center text-xs font-bold " + (c.source === "agent" ? "bg-primary/10 text-primary" : "bg-gray-100 text-gray-600")}>
                        {c.source === "agent" ? "A" : "C"}
                      </div>
                      <div className="min-w-0 flex-1 rounded-xl bg-gray-50/80 px-4 py-3 border border-gray-100">
                        <div className="flex items-baseline gap-2 flex-wrap">
                          <span className="text-sm font-medium text-[#0e141b]">{c.author_name}</span>
                          <span className="text-xs text-gray-500">{c.source === "agent" ? "Agent" : "Client"}</span>
                          <span className="text-xs text-gray-400 tabular-nums">{formatDate(c.created_date)}</span>
                        </div>
                        <p className="text-sm text-gray-700 mt-1.5 whitespace-pre-wrap leading-relaxed">{c.content}</p>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>

          {/* Card Atașamente */}
          <div className="bg-white border border-gray-200/90 rounded-2xl shadow-card-lg overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 bg-primary/5">
              <h2 className="text-sm font-semibold text-[#0e141b] flex items-center gap-2">
                <span className="material-symbols-outlined text-lg text-primary">attach_file</span>
                Atașamente
                {attachments.length > 0 && (
                  <span className="text-xs font-normal text-gray-500">({attachments.length})</span>
                )}
              </h2>
            </div>
            <div className="px-6 py-5">
              {attachments.length === 0 ? (
                <p className="text-sm text-gray-500 flex items-center gap-2.5 py-2">
                  <span className="material-symbols-outlined text-lg text-gray-400">attach_file</span>
                  Niciun atașament.
                </p>
              ) : (
                <ul className="space-y-2">
                  {attachments.map((a) => (
                    <li key={a.atasament_id} className="flex items-center gap-3 py-3 px-4 rounded-xl bg-gray-50/80 border border-gray-100 hover:bg-gray-50 transition-colors duration-200">
                      <span className="material-symbols-outlined text-gray-400">attach_file</span>
                      <div className="min-w-0 flex-1">
                        <span className="text-sm font-medium text-[#0e141b] truncate block">{a.file_name}</span>
                        <span className="text-xs text-gray-500">
                          {formatBytes(a.file_size)}
                          {a.file_type ? " · " + a.file_type : ""}
                          {" · "}
                          <span className="tabular-nums">{formatDate(a.upload_date)}</span>
                          {a.uploader_type === "C" ? " (Client)" : " (Agent)"}
                        </span>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        </div>

        {/* Secțiune separată: Informații ticket */}
        <div>
          <div className="bg-white border border-gray-200/90 rounded-2xl shadow-card-lg overflow-hidden sticky top-24">
            <div className="px-5 py-4 border-b border-gray-100 bg-gray-50/60">
              <h2 className="text-sm font-semibold text-[#0e141b] flex items-center gap-2">
                <span className="material-symbols-outlined text-lg text-primary">info</span>
                Informații ticket
              </h2>
            </div>
            <div className="px-5 py-1">
              <InfoRow label="ID" value={`#${ticket.ticket_id}`} />
              <InfoRow label="Client" value={ticket.client_nume || ticket.client_email || "—"} />
              <InfoRow
                label="Agent"
                value={
                  hasAgent ? (
                    <span className="truncate block" title={ticket.agent_email || undefined}>
                      {ticket.agent_nume || ticket.agent_email}
                    </span>
                  ) : (
                    <span className="text-amber-600 font-medium">Unassigned</span>
                  )
                }
              />
              <InfoRow label="Prioritate" value={ticket.prioritate_nume} />
              <InfoRow label="Categorie" value={ticket.categorie_nume ?? "—"} />
              <InfoRow label="Departament" value={ticket.departament_nume} />
              <InfoRow label="Status" value={ticket.status_nume} />
              <InfoRow label="Data creare" value={<span className="tabular-nums">{formatDate(ticket.data_creare)}</span>} />
              <InfoRow label="Data rezolvare" value={<span className="tabular-nums">{formatDate(ticket.data_rezolvare)}</span>} />
              <InfoRow label="Data închidere" value={<span className="tabular-nums">{formatDate(ticket.data_inchidere)}</span>} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function TicketDetailPage() {
  const params = useParams();
  const id = params.id as string;
  const [data, setData] = useState<TicketDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(() => {
    if (!id) return;
    setLoading(true);
    fetch("/api/tickets/" + id)
      .then((r) => {
        if (r.status === 404) throw new Error("Ticket not found");
        return r.ok ? r.json() : r.json().then((j: { error?: string }) => Promise.reject(new Error(j.error || "Failed to load")));
      })
      .then(setData)
      .catch((e: Error) => setError(e.message))
      .finally(() => setLoading(false));
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-28 gap-4">
        <span className="material-symbols-outlined animate-spin text-5xl text-primary">progress_activity</span>
        <p className="text-sm text-gray-500">Loading ticket…</p>
      </div>
    );
  }
  if (error || !data) {
    return (
      <div className="rounded-2xl border border-red-200/80 bg-red-50 p-6 text-red-700 flex items-start gap-4 shadow-card">
        <span className="material-symbols-outlined text-2xl shrink-0">error</span>
        <div>
          <p className="font-semibold">Error</p>
          <p className="text-sm mt-1 opacity-90">{error || "Ticket not found."}</p>
          <Link href="/" className="inline-flex items-center gap-1.5 mt-4 text-sm font-medium text-primary hover:underline rounded focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/30 focus-visible:ring-offset-1">
            <span className="material-symbols-outlined text-[18px]">arrow_back</span>
            Back to Dashboard
          </Link>
        </div>
      </div>
    );
  }

  return <TicketView data={data} />;
}
