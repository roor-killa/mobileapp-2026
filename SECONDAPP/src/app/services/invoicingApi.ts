/**
 * Modèle aligné sur Odoo : res.partner + account.move (facture client).
 * Champs inspirés de account.move / account.move.line (Odoo 16+).
 */
import { getJsonServerBaseUrl } from "./jsonServerBaseUrl";

/**
 * json-server 0.12 (image clue/json-server) n'expose pas plusieurs routes racine
 * de type tableau (/partners, /invoices → 404). Les données facturation sont donc
 * sous GET /dashboard → clé `invoicing` (comme balanceData, transactions…).
 */

export type OdooPartner = {
  id: number;
  name: string;
  ref: string;
  vat: string;
  email: string;
  phone: string;
  street: string;
  zip: string;
  city: string;
  country: string;
};

export type OdooInvoiceLine = {
  id: number;
  name: string;
  quantity: number;
  price_unit: number;
  tax_percent: number;
  price_subtotal: number;
};

export type InvoiceMoveType = "out_invoice" | "in_invoice";
export type InvoiceState = "draft" | "posted" | "cancel";
export type PaymentState = "not_paid" | "partial" | "paid" | "reversed" | "invoicing_legacy";

export type OdooInvoice = {
  id: number;
  name: string;
  move_type: InvoiceMoveType;
  partner_id: number;
  invoice_date: string;
  invoice_date_due: string;
  state: InvoiceState;
  payment_state: PaymentState;
  currency: string;
  amount_untaxed: number;
  amount_tax: number;
  amount_total: number;
  narration: string;
  invoice_line_ids: OdooInvoiceLine[];
};

type DashboardWithInvoicing = {
  invoicing?: {
    partners?: OdooPartner[];
    invoices?: OdooInvoice[];
  };
};

export async function getInvoicingData(): Promise<{
  partners: OdooPartner[];
  invoices: OdooInvoice[];
} | null> {
  try {
    const res = await fetch(`${getJsonServerBaseUrl()}/dashboard`);
    if (!res.ok) return null;
    const data = (await res.json()) as DashboardWithInvoicing;
    const block = data.invoicing;
    if (!block) return null;
    const partners = Array.isArray(block.partners) ? block.partners : [];
    const invoices = Array.isArray(block.invoices) ? block.invoices : [];
    if (partners.length === 0 && invoices.length === 0) return null;
    return { partners, invoices };
  } catch {
    return null;
  }
}

export function formatMoveType(moveType: InvoiceMoveType): string {
  return moveType === "out_invoice" ? "Facture client" : "Facture fournisseur";
}

export function formatInvoiceState(state: InvoiceState): string {
  switch (state) {
    case "draft":
      return "Brouillon";
    case "posted":
      return "Comptabilisée";
    case "cancel":
      return "Annulée";
    default:
      return state;
  }
}

export function formatPaymentState(payment: PaymentState): string {
  switch (payment) {
    case "not_paid":
      return "Non payée";
    case "partial":
      return "Paiement partiel";
    case "paid":
      return "Payée";
    case "reversed":
      return "Extournée";
    case "invoicing_legacy":
      return "Héritage";
    default:
      return payment;
  }
}
