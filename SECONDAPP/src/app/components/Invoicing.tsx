import { motion } from "motion/react";
import { FileText, Building2, Calendar, Euro, Plus, Trash2, Save, Pencil } from "lucide-react";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  getInvoicingData,
  formatInvoiceState,
  formatPaymentState,
  formatMoveType,
  type OdooInvoice,
  type OdooPartner,
  type OdooInvoiceLine,
} from "../services/invoicingApi";
import {
  mergeApiWithPersisted,
  loadPersistedDrafts,
  upsertPersistedDraft,
  removePersistedDraft,
} from "../services/invoicingPersistence";
import {
  recalcInvoice,
  createEmptyDraftInvoice,
  nextLineId,
} from "../services/invoicingCalculations";
import { Badge } from "./ui/badge";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from "./ui/sheet";
import { useTheme } from "../contexts/ThemeContext";
import { toast } from "sonner";

type FilterKey = "all" | "draft" | "posted_unpaid" | "paid";

type SheetState =
  | null
  | { mode: "readonly"; inv: OdooInvoice }
  | { mode: "editor"; inv: OdooInvoice };

function partnerById(partners: OdooPartner[], id: number): OdooPartner | undefined {
  return partners.find((p) => p.id === id);
}

function matchesFilter(inv: OdooInvoice, key: FilterKey): boolean {
  if (key === "all") return true;
  if (key === "draft") return inv.state === "draft";
  if (key === "posted_unpaid") {
    return inv.state === "posted" && (inv.payment_state === "not_paid" || inv.payment_state === "partial");
  }
  if (key === "paid") return inv.payment_state === "paid";
  return true;
}

function stateBadgeVariant(
  state: OdooInvoice["state"],
  payment: OdooInvoice["payment_state"],
): "default" | "secondary" | "outline" | "destructive" {
  if (state === "draft") return "secondary";
  if (state === "cancel") return "destructive";
  if (payment === "paid") return "default";
  return "outline";
}

const inputDark =
  "bg-zinc-900/80 border-white/20 text-white placeholder:text-white/40 focus-visible:ring-purple-500/50";

export default function Invoicing() {
  const { theme } = useTheme();
  const apiInvoicesRef = useRef<OdooInvoice[]>([]);
  const [partners, setPartners] = useState<OdooPartner[]>([]);
  const [invoices, setInvoices] = useState<OdooInvoice[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<FilterKey>("all");
  const [sheet, setSheet] = useState<SheetState>(null);

  const syncMerged = useCallback(() => {
    setInvoices(mergeApiWithPersisted(apiInvoicesRef.current, loadPersistedDrafts()));
  }, []);

  useEffect(() => {
    let alive = true;
    setLoading(true);
    getInvoicingData().then((bundle) => {
      if (!alive) return;
      setPartners(bundle?.partners ?? []);
      apiInvoicesRef.current = bundle?.invoices ?? [];
      syncMerged();
      setLoading(false);
    });
    return () => {
      alive = false;
    };
  }, [syncMerged]);

  const filtered = useMemo(
    () => invoices.filter((i) => matchesFilter(i, filter)).sort((a, b) => b.id - a.id),
    [invoices, filter],
  );

  const noBackend = !loading && partners.length === 0 && invoices.length === 0;

  const openInvoice = (inv: OdooInvoice) => {
    if (inv.state === "draft") {
      setSheet({ mode: "editor", inv: structuredClone(inv) });
    } else {
      setSheet({ mode: "readonly", inv });
    }
  };

  const openCreate = () => {
    if (partners.length === 0) {
      toast.error("Aucun client dans la base — impossible de créer une facture.");
      return;
    }
    setSheet({ mode: "editor", inv: createEmptyDraftInvoice(partners[0].id) });
  };

  const saveDraft = (inv: OdooInvoice) => {
    if (!inv.partner_id) {
      toast.error("Choisis un client.");
      return;
    }
    if (!inv.invoice_line_ids.length) {
      toast.error("Ajoute au moins une ligne.");
      return;
    }
    const hasEmptyLine = inv.invoice_line_ids.some((l) => !l.name.trim());
    if (hasEmptyLine) {
      toast.error("Chaque ligne doit avoir un libellé.");
      return;
    }
    const finalInv = recalcInvoice(inv);
    upsertPersistedDraft(finalInv);
    syncMerged();
    toast.success("Brouillon enregistré (stocké dans ce navigateur).");
    setSheet(null);
  };

  const deleteClientDraft = (id: number) => {
    if (id >= 0) return;
    removePersistedDraft(id);
    syncMerged();
    toast.message("Brouillon supprimé.");
    setSheet(null);
  };

  const filters: { key: FilterKey; label: string }[] = [
    { key: "all", label: "Toutes" },
    { key: "draft", label: "Brouillon" },
    { key: "posted_unpaid", label: "À encaisser" },
    { key: "paid", label: "Payées" },
  ];

  return (
    <div className="p-6 space-y-6">
      <motion.div
        initial={{ opacity: 0, y: -12 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-16"
      >
        <div className="flex items-start gap-3 justify-between">
          <div className="flex items-start gap-3">
            <div className={`p-3 rounded-2xl bg-gradient-to-br ${theme.gradient} shadow-lg`}>
              <FileText className="w-7 h-7 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold">Facturation</h1>
              <p className="text-gray-400 text-sm mt-0.5">
                Brouillons modifiables · persistance locale (navigateur)
              </p>
            </div>
          </div>
        </div>
      </motion.div>

      {!loading && partners.length > 0 && (
        <Button
          type="button"
          onClick={openCreate}
          className="w-full rounded-2xl h-12 bg-white text-purple-700 hover:bg-white/90 font-semibold shadow-lg"
        >
          <Plus className="w-5 h-5" />
          Nouvelle facture (brouillon)
        </Button>
      )}

      {loading && (
        <p className="text-white/70 text-sm animate-pulse">Chargement des écritures…</p>
      )}

      {noBackend && !loading && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="rounded-2xl border border-white/20 bg-white/10 backdrop-blur-md p-4 text-sm text-white/90"
        >
          <p className="font-medium mb-1">Aucune donnée</p>
          <p className="text-white/70">
            Démarre le conteneur json-server :{" "}
            <code className="text-xs bg-black/20 px-1 rounded">docker compose up -d</code> dans{" "}
            <code className="text-xs bg-black/20 px-1 rounded">SECONDAPP</code>, puis rafraîchis la page.
          </p>
        </motion.div>
      )}

      {!loading && invoices.length > 0 && (
        <div className="flex gap-2 overflow-x-auto pb-1 -mx-1 px-1 scrollbar-thin">
          {filters.map((f) => (
            <button
              key={f.key}
              type="button"
              onClick={() => setFilter(f.key)}
              className={`shrink-0 px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
                filter === f.key
                  ? "bg-white text-purple-700 shadow-md"
                  : "bg-white/15 text-white/90 hover:bg-white/25"
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      )}

      <div className="space-y-3">
        {filtered.map((inv, idx) => {
          const partner = partnerById(partners, inv.partner_id);
          return (
            <motion.button
              key={inv.id}
              type="button"
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.04 }}
              onClick={() => openInvoice(inv)}
              className="w-full text-left rounded-2xl border border-white/20 bg-white/10 backdrop-blur-xl p-4 hover:bg-white/15 transition-colors shadow-lg"
            >
              <div className="flex justify-between items-start gap-2">
                <div>
                  <p className="font-semibold text-white flex items-center gap-2 flex-wrap">
                    {inv.name}
                    <Badge variant={stateBadgeVariant(inv.state, inv.payment_state)} className="text-[10px]">
                      {formatInvoiceState(inv.state)}
                    </Badge>
                    {inv.state === "draft" && (
                      <span className="text-[10px] text-amber-200 flex items-center gap-0.5">
                        <Pencil className="w-3 h-3" />
                        Cliquer pour modifier
                      </span>
                    )}
                  </p>
                  <p className="text-sm text-white/70 flex items-center gap-1 mt-1">
                    <Building2 className="w-3.5 h-3.5 shrink-0" />
                    {partner?.name ?? `Partenaire #${inv.partner_id}`}
                  </p>
                </div>
                <div className="text-right shrink-0">
                  <p className="font-bold text-white flex items-center justify-end gap-0.5">
                    <Euro className="w-4 h-4" />
                    {inv.amount_total.toLocaleString("fr-FR", {
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2,
                    })}
                  </p>
                  <p className="text-[11px] text-white/60 mt-0.5">{inv.currency}</p>
                </div>
              </div>
              <div className="flex flex-wrap gap-2 mt-3">
                <span className="text-[11px] px-2 py-0.5 rounded-md bg-black/20 text-white/80">
                  {formatMoveType(inv.move_type)}
                </span>
                <span className="text-[11px] px-2 py-0.5 rounded-md bg-emerald-500/20 text-emerald-200">
                  {formatPaymentState(inv.payment_state)}
                </span>
                <span className="text-[11px] text-white/50 flex items-center gap-1">
                  <Calendar className="w-3 h-3" />
                  Échéance {inv.invoice_date_due}
                </span>
              </div>
            </motion.button>
          );
        })}
      </div>

      {!loading && invoices.length > 0 && filtered.length === 0 && (
        <p className="text-white/60 text-sm text-center py-6">Aucune facture pour ce filtre.</p>
      )}

      <Sheet
        open={!!sheet}
        onOpenChange={(open) => {
          if (!open) setSheet(null);
        }}
      >
        <SheetContent
          side="bottom"
          className="h-[92vh] max-h-[720px] rounded-t-3xl border-t border-white/20 bg-zinc-950 text-white overflow-y-auto sm:max-w-md mx-auto left-0 right-0 flex flex-col"
        >
          {sheet?.mode === "readonly" && (
            <ReadOnlyInvoiceBody
              selected={sheet.inv}
              partners={partners}
              partnerById={partnerById}
            />
          )}
          {sheet?.mode === "editor" && (
            <EditorInvoiceBody
              draft={sheet.inv}
              partners={partners}
              inputDark={inputDark}
              onChange={(next) => setSheet({ mode: "editor", inv: next })}
              onSave={saveDraft}
              onDelete={() => deleteClientDraft(sheet.inv.id)}
              onRevertServer={() => {
                removePersistedDraft(sheet.inv.id);
                syncMerged();
                setSheet(null);
                toast.message("Modifications locales annulées — version d’origine rechargée.");
              }}
            />
          )}
        </SheetContent>
      </Sheet>
    </div>
  );
}

function ReadOnlyInvoiceBody({
  selected,
  partners,
  partnerById,
}: {
  selected: OdooInvoice;
  partners: OdooPartner[];
  partnerById: (p: OdooPartner[], id: number) => OdooPartner | undefined;
}) {
  const p = partnerById(partners, selected.partner_id);
  return (
    <>
      <SheetHeader className="text-left border-b border-white/10 pb-4 shrink-0">
        <SheetTitle className="text-xl text-white">{selected.name}</SheetTitle>
        <SheetDescription className="text-white/60">
          {formatMoveType(selected.move_type)} · {formatInvoiceState(selected.state)} ·{" "}
          {formatPaymentState(selected.payment_state)}
        </SheetDescription>
        <p className="text-xs text-amber-200/90 pt-2">
          Facture comptabilisée ou payée : consultation seule (comme après envoi en Odoo).
        </p>
      </SheetHeader>

      <div className="px-4 py-4 space-y-4 flex-1">
        {p && (
          <div className="rounded-xl bg-white/5 border border-white/10 p-3 text-sm">
            <p className="font-semibold text-white mb-1">{p.name}</p>
            <p className="text-white/60 text-xs">Réf. {p.ref}</p>
            <p className="text-white/70 mt-2">{p.street}</p>
            <p className="text-white/70">
              {p.zip} {p.city} — {p.country}
            </p>
            <p className="text-white/60 text-xs mt-2">N° TVA : {p.vat}</p>
            <p className="text-white/60 text-xs">{p.email}</p>
          </div>
        )}

        <div className="grid grid-cols-2 gap-2 text-xs">
          <div className="rounded-lg bg-white/5 p-2">
            <p className="text-white/50">Date facture</p>
            <p className="text-white font-medium">{selected.invoice_date}</p>
          </div>
          <div className="rounded-lg bg-white/5 p-2">
            <p className="text-white/50">Échéance</p>
            <p className="text-white font-medium">{selected.invoice_date_due}</p>
          </div>
        </div>

        {selected.narration ? (
          <p className="text-sm text-white/70 italic border-l-2 border-purple-400 pl-3">{selected.narration}</p>
        ) : null}

        <InvoiceLinesTable lines={selected.invoice_line_ids} />

        <TotalsBlock inv={selected} />
      </div>
    </>
  );
}

function EditorInvoiceBody({
  draft,
  partners,
  inputDark,
  onChange,
  onSave,
  onDelete,
  onRevertServer,
}: {
  draft: OdooInvoice;
  partners: OdooPartner[];
  inputDark: string;
  onChange: (inv: OdooInvoice) => void;
  onSave: (inv: OdooInvoice) => void;
  onDelete: () => void;
  onRevertServer: () => void;
}) {
  const updateLine = (lineId: number, patch: Partial<OdooInvoiceLine>) => {
    const merged = draft.invoice_line_ids.map((l) => {
      if (l.id !== lineId) return l;
      const updated = { ...l, ...patch };
      const sub = Math.round(updated.quantity * updated.price_unit * 100) / 100;
      return { ...updated, price_subtotal: sub };
    });
    onChange(recalcInvoice({ ...draft, invoice_line_ids: merged }));
  };

  const addLine = () => {
    onChange(
      recalcInvoice({
        ...draft,
        invoice_line_ids: [
          ...draft.invoice_line_ids,
          {
            id: nextLineId(),
            name: "",
            quantity: 1,
            price_unit: 0,
            tax_percent: 20,
            price_subtotal: 0,
          },
        ],
      }),
    );
  };

  const removeLine = (lineId: number) => {
    if (draft.invoice_line_ids.length <= 1) {
      toast.error("Garde au moins une ligne.");
      return;
    }
    onChange(
      recalcInvoice({
        ...draft,
        invoice_line_ids: draft.invoice_line_ids.filter((l) => l.id !== lineId),
      }),
    );
  };

  return (
    <>
      <SheetHeader className="text-left border-b border-white/10 pb-4 shrink-0">
        <SheetTitle className="text-xl text-white">
          {draft.id < 0 ? "Nouvelle facture" : "Modifier le brouillon"}
        </SheetTitle>
        <SheetDescription className="text-white/60">
          Enregistrement dans le navigateur (localStorage). Les factures comptabilisées restent en lecture seule.
        </SheetDescription>
      </SheetHeader>

      <div className="px-4 py-4 space-y-4 flex-1 pb-8">
        <div className="space-y-2">
          <label className="text-xs text-white/60">Numéro / référence</label>
          <Input
            className={inputDark}
            value={draft.name}
            onChange={(e) => onChange({ ...draft, name: e.target.value })}
          />
        </div>

        <div className="space-y-2">
          <label className="text-xs text-white/60">Client</label>
          <select
            className={`flex h-9 w-full rounded-md border px-3 text-sm ${inputDark}`}
            value={String(draft.partner_id)}
            onChange={(e) => onChange({ ...draft, partner_id: Number(e.target.value) })}
          >
            {partners.map((p) => (
              <option key={p.id} value={p.id} className="bg-zinc-900">
                {p.name}
              </option>
            ))}
          </select>
        </div>

        <div className="grid grid-cols-2 gap-2">
          <div className="space-y-2">
            <label className="text-xs text-white/60">Date facture</label>
            <Input
              type="date"
              className={inputDark}
              value={draft.invoice_date}
              onChange={(e) => onChange({ ...draft, invoice_date: e.target.value })}
            />
          </div>
          <div className="space-y-2">
            <label className="text-xs text-white/60">Échéance</label>
            <Input
              type="date"
              className={inputDark}
              value={draft.invoice_date_due}
              onChange={(e) => onChange({ ...draft, invoice_date_due: e.target.value })}
            />
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-xs text-white/60">Notes (pied de facture)</label>
          <textarea
            className={`min-h-[72px] w-full rounded-md border px-3 py-2 text-sm ${inputDark}`}
            value={draft.narration}
            onChange={(e) => onChange({ ...draft, narration: e.target.value })}
            placeholder="Texte libre…"
          />
        </div>

        <div className="flex items-center justify-between pt-2">
          <p className="text-sm font-semibold text-white">Lignes</p>
          <Button type="button" size="sm" variant="secondary" onClick={addLine} className="bg-white/15 text-white hover:bg-white/25">
            <Plus className="w-4 h-4" />
            Ligne
          </Button>
        </div>

        <div className="space-y-3">
          {draft.invoice_line_ids.map((line) => (
            <div key={line.id} className="rounded-xl border border-white/15 bg-white/5 p-3 space-y-2">
              <Input
                placeholder="Libellé"
                className={inputDark}
                value={line.name}
                onChange={(e) => updateLine(line.id, { name: e.target.value })}
              />
              <div className="grid grid-cols-4 gap-2">
                <div className="col-span-1">
                  <label className="text-[10px] text-white/50">Qté</label>
                  <Input
                    type="number"
                    min={0}
                    step="0.01"
                    className={inputDark}
                    value={line.quantity}
                    onChange={(e) => updateLine(line.id, { quantity: Number(e.target.value) || 0 })}
                  />
                </div>
                <div className="col-span-1">
                  <label className="text-[10px] text-white/50">P.U. HT</label>
                  <Input
                    type="number"
                    min={0}
                    step="0.01"
                    className={inputDark}
                    value={line.price_unit}
                    onChange={(e) => updateLine(line.id, { price_unit: Number(e.target.value) || 0 })}
                  />
                </div>
                <div className="col-span-1">
                  <label className="text-[10px] text-white/50">TVA %</label>
                  <Input
                    type="number"
                    min={0}
                    className={inputDark}
                    value={line.tax_percent}
                    onChange={(e) => updateLine(line.id, { tax_percent: Number(e.target.value) || 0 })}
                  />
                </div>
                <div className="flex items-end justify-end">
                  <Button
                    type="button"
                    size="icon"
                    variant="ghost"
                    className="text-red-300 hover:text-red-200 hover:bg-red-500/20"
                    onClick={() => removeLine(line.id)}
                  >
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </div>
              </div>
              <p className="text-[11px] text-white/50 text-right">
                Sous-total HT :{" "}
                {line.price_subtotal.toLocaleString("fr-FR", { minimumFractionDigits: 2 })}{" "}
                {draft.currency}
              </p>
            </div>
          ))}
        </div>

        <TotalsBlock inv={draft} />

        <div className="flex flex-col gap-2 pt-4">
          <Button
            type="button"
            className="w-full rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white"
            onClick={() => onSave(draft)}
          >
            <Save className="w-4 h-4" />
            Enregistrer le brouillon
          </Button>
          {draft.id < 0 && (
            <Button type="button" variant="destructive" className="w-full rounded-xl" onClick={onDelete}>
              <Trash2 className="w-4 h-4" />
              Supprimer ce brouillon
            </Button>
          )}
          {draft.id > 0 && (
            <Button
              type="button"
              variant="outline"
              className="w-full rounded-xl border-white/30 text-white/90 hover:bg-white/10"
              onClick={onRevertServer}
            >
              Reprendre la version du serveur (annuler mes modifications)
            </Button>
          )}
        </div>
      </div>
    </>
  );
}

function InvoiceLinesTable({ lines }: { lines: OdooInvoiceLine[] }) {
  return (
    <div>
      <p className="text-sm font-semibold text-white mb-2">Lignes de facture</p>
      <div className="rounded-xl border border-white/10 overflow-hidden">
        <table className="w-full text-xs">
          <thead className="bg-white/10 text-white/80 text-left">
            <tr>
              <th className="p-2 font-medium">Libellé</th>
              <th className="p-2 font-medium w-10">Qté</th>
              <th className="p-2 font-medium w-16">P.U.</th>
              <th className="p-2 font-medium w-10">TVA</th>
              <th className="p-2 font-medium w-16 text-right">Sous-total HT</th>
            </tr>
          </thead>
          <tbody>
            {lines.map((line) => (
              <tr key={line.id} className="border-t border-white/10">
                <td className="p-2 text-white/90">{line.name}</td>
                <td className="p-2 text-white/80">{line.quantity}</td>
                <td className="p-2 text-white/80">{line.price_unit.toLocaleString("fr-FR")}</td>
                <td className="p-2 text-white/80">{line.tax_percent}%</td>
                <td className="p-2 text-right text-white">
                  {line.price_subtotal.toLocaleString("fr-FR", { minimumFractionDigits: 2 })}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function TotalsBlock({ inv }: { inv: OdooInvoice }) {
  return (
    <div className="rounded-xl bg-gradient-to-br from-purple-900/40 to-zinc-900 border border-white/10 p-4 space-y-2 text-sm">
      <div className="flex justify-between text-white/70">
        <span>Montant HT</span>
        <span>
          {inv.amount_untaxed.toLocaleString("fr-FR", { minimumFractionDigits: 2 })} {inv.currency}
        </span>
      </div>
      <div className="flex justify-between text-white/70">
        <span>TVA</span>
        <span>
          {inv.amount_tax.toLocaleString("fr-FR", { minimumFractionDigits: 2 })} {inv.currency}
        </span>
      </div>
      <div className="flex justify-between text-lg font-bold text-white pt-2 border-t border-white/20">
        <span>Total TTC</span>
        <span>
          {inv.amount_total.toLocaleString("fr-FR", { minimumFractionDigits: 2 })} {inv.currency}
        </span>
      </div>
    </div>
  );
}
